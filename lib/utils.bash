#!/usr/bin/env bash

# set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for nerves-toolchain.
GH_REPO="nerves-project/toolchains"
TOOL_NAME="nerves-toolchain"

HOST_ARCH=$(uname -p)
HOST_OS=$(uname -s | tr '[:upper:]' '[:lower:]')

JQ_MAP_RELEASES=$(
	cat <<EOF
[.[] | {
    version: .tag_name,
    toolchains: [.assets[] | {
        filename: .name,
        toolchain: .name | capture("nerves_toolchain_(?<target_arch>[A-Za-z0-9_]+)_(?<vendor>[A-Za-z0-9]+)_linux_(?<abi>[A-Za-z0-9]+)-([0-9\\\\.]+(-rc\\\\.\\\\d+)?\\\\.)?(?<host_os>[A-Za-z0-9]+)[-_](?<host_arch>[A-Za-z0-9_]+)"),
        browser_download_url: .browser_download_url
    } | select(.toolchain.host_os == "$HOST_OS" and .toolchain.host_arch == "$HOST_ARCH")]
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
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if nerves-toolchain is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN" -H "Accept: application/vnd.github+json")
fi

list_github_release_assets() {
	curl "${curl_opts[@]}" "https://api.github.com/repos/$GH_REPO/releases?per_page=100" | jq -r "$JQ_MAP_RELEASES"
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
	# TODO: Adapt this. By default we simply list the tag names from GitHub releases.
	# Change this function if nerves-toolchain has other means of determining installable versions.
	list_github_release_assets | jq -r "$JQ_FILTER_VERSIONS | reverse | .[]"
}

download_release() {
	local version filename url
	version_str="$1"
	filename="$2"

	IFS='-' read -ra version_parts <<<"$version_str"

	local version="v${version_parts[0]}"
	local target_arch="${version_parts[1]}"
	local vendor="${version_parts[2]}"
	# local target_os="${version_parts[3]}"
	local abi="${version_parts[4]}"

	echo "version: $version"
	echo "target_arch: $target_arch"
	echo "vendor: $vendor"
	echo "abi: $abi"

	# target_release=$(find_target_release "$version" "$target_arch" "$vendor" "$abi" || fail "Could not find release for $version_str")
	target_release=$(find_target_release "$version" "$target_arch" "$vendor" "$abi")
	echo "$target_release"
	url=$(echo "$target_release" | jq -r '.browser_download_url')
	echo "$url"

	echo "* Downloading $TOOL_NAME release $version_str..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version_str="$2"
	local install_path="${3%/bin}"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	IFS='-' read -ra version_parts <<<"$version_str"

	local version="${version_parts[0]}"
	local target_arch="${version_parts[1]}"
	local vendor="${version_parts[2]}"
	# local target_os="${version_parts[3]}"
	local abi="${version_parts[4]}"

	target_release=$(find_target_release "$version" "$target_arch" "$vendor" "$abi" || fail "Could not find release for $version_str")

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		# TODO: Assert nerves-toolchain executable exists.
		local gcc
		gcc="$target_arch-$vendor-linux-$abi-gcc"
		test -x "$install_path/bin/$gcc" || fail "Expected $install_path/bin/$gcc to be executable."

		echo "$TOOL_NAME $version_str installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version_str."
	)
}
