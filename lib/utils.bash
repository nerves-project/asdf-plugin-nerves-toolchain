#!/usr/bin/env bash

set -euo pipefail

GH_REPO="nerves-project/toolchains"
TOOL_NAME="nerves-toolchain"

HOST_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
HOST_ARCH=$(uname -m)
HOST_ARCH_PATTERN="^$HOST_ARCH$"

case "$HOST_ARCH" in
arm | arm64 | aarch64)
	HOST_ARCH_PATTERN="^(aarch64|arm64|arm)$"
	;;
*) ;;
esac

if [ "$HOST_ARCH" = "arm64" ]; then
	HOST_ARCH="arm"
fi

JQ_MAP_AND_FILTER_RELEASES_FOR_HOST=$(
	cat <<EOF
[.[] | {
    version: .tag_name,
    toolchains: [.assets[] | {
        filename: .name,
        toolchain: .name | capture("nerves_toolchain_(?<target_arch>[A-Za-z0-9_]+)_(?<vendor>[A-Za-z0-9]+)_linux_(?<abi>[A-Za-z0-9]+)-([0-9\\\\.]+(-rc\\\\.\\\\d+)?\\\\.)?(?<host_os>[A-Za-z0-9]+)[-_](?<host_arch>[A-Za-z0-9_]+)"),
        browser_download_url: .browser_download_url
    } | select(.toolchain.host_os == "$HOST_OS" and (.toolchain.host_arch | test("$HOST_ARCH_PATTERN")))]
} | select(.toolchains | length > 0)]
EOF
)

JQ_FILTER_VERSIONS=$(
	cat <<EOF
[.[] | .version as \$version | (
    .toolchains[] | .toolchain | \$version + "-" + .target_arch + "-" + .vendor + "-linux-" + .abi
)]
EOF
)

fail() {
	IFS=""
	echo -e "asdf-$TOOL_NAME: $*" >&2
	exit 1
}

curl_opts=(-fsSL)

github_token="${GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"

# NOTE: You might want to remove this if nerves-toolchain is not hosted on GitHub releases.
if [ -n "$github_token" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $github_token" -H "Accept: application/vnd.github+json")
fi

list_github_release_assets() {
	releases=$(curl "${curl_opts[@]}" "https://api.github.com/repos/$GH_REPO/releases?per_page=100" 2>&1)

	# shellcheck disable=SC2181
	if [ $? -eq 0 ]; then
		releases=$(echo "$releases" | tr -d '\r\n' | jq -r "$JQ_MAP_AND_FILTER_RELEASES_FOR_HOST")
		if [ "$releases" = "[]" ]; then
			fail "No matching toolchains could be found for OS $HOST_OS, arch $HOST_ARCH."
		else
			echo "$releases"
		fi
	else
		if [[ $releases == *401 ]]; then
			fail "Failed to fetch releases from GitHub.\n\n" \
				"If you have GITHUB_API_TOKEN or GITHUB_TOKEN set, the value must be a valid GitHub API token."

		elif [[ $releases == *403 ]]; then
			fail "Failed to fetch releases from GitHub.\n\n" \
				"You may have exceeded the API rate limit. Authenticated requests receive\n" \
				"a higher rate limit. Try setting GITHUB_API_TOKEN to a valid GitHub API token."
		fi

		fail "Failed to fetch releases from GitHub."
	fi
}

find_target_release() {
	local version="$1"
	local target_arch="$2"
	local vendor="$3"
	local abi="$4"

	local jq_filter=".[] | select(.version == \"$version\") | .toolchains[] | select(.toolchain.target_arch == \"$target_arch\" and .toolchain.vendor == \"$vendor\" and .toolchain.abi == \"$abi\")"

	list_github_release_assets |
		jq -r "$jq_filter"
}

list_all_versions() {
	list_github_release_assets | jq -r "$JQ_FILTER_VERSIONS | reverse | .[]"
}

download_release() {
	local version_str filename version target_arch vendor abi target_release url
	version_str=$(fix_version "$1")
	filename="$2"

	IFS='-' read -ra version_parts <<<"$version_str"

	version="${version_parts[0]}"
	target_arch="${version_parts[1]}"
	vendor="${version_parts[2]}"
	# target_os="${version_parts[3]}"
	abi="${version_parts[4]}"

	# target_release=$(find_target_release "$version" "$target_arch" "$vendor" "$abi" || fail "Could not find release for $version_str")
	target_release=$(find_target_release "$version" "$target_arch" "$vendor" "$abi")

	url=$(echo "$target_release" | jq -r '.browser_download_url')

	echo "* Downloading $TOOL_NAME release $version_str..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type version_str install_path target_release version target_arch vendor abi
	install_type="$1"
	version_str=$(fix_version "$2")
	install_path="${3%/bin}"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	IFS='-' read -ra version_parts <<<"$version_str"

	version="${version_parts[0]}"
	target_arch="${version_parts[1]}"
	vendor="${version_parts[2]}"
	# target_os="${version_parts[3]}"
	abi="${version_parts[4]}"

	target_release=$(find_target_release "$version" "$target_arch" "$vendor" "$abi" || fail "Could not find release for $version_str")

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		local gcc
		gcc="$target_arch-$vendor-linux-$abi-gcc"
		test -x "$install_path/bin/$gcc" || fail "Expected $install_path/bin/$gcc to be executable."

		echo "$TOOL_NAME $version_str installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version_str."
	)
}

# prepend a v to the version string if it doesn't already have one for
# cross-compatibility between asdf, rtx, and mise
fix_version() {
	local version="$1"
	if [[ "$version" != v* ]]; then
		version="v$version"
	fi
	echo "$version"
}
