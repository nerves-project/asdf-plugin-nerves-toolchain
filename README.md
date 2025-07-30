# asdf-nerves-toolchain [![Build](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/build.yml/badge.svg)](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/build.yml) [![Lint](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/lint.yml/badge.svg)](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/lint.yml)

[nerves-toolchain](https://github.com/nerves-project/asdf-plugin-nerves-toolchain) plugin for the [asdf version manager](https://asdf-vm.com).

This lets you use the official [Nerves](https://nerves-project.org/) cross
toolchains outside of Elixir. These provide recent versions of GCC with either
[musl libc](https://musl.libc.org/) or [GNU
libc](https://www.gnu.org/software/libc/) for Intel, 32-bit and 64-bit ARM,
RISC-V and MIPS.

```sh
$ asdf install nerves-toolchain v13.2.0-riscv64-nerves-linux-gnu
$ asdf set nerves-toolchain v13.2.0-riscv64-nerves-linux-gnu
$ riscv64-nerves-linux-gnu-gcc --version
riscv64-nerves-linux-gnu-gcc (crosstool-NG UNKNOWN) 13.2.0
Copyright (C) 2023 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `xz` / `xz-utils`
- [`jq`](https://jqlang.github.io/jq/)

Nerves toolchain releases are large and hosted on GitHub. It is recommended to
create a GitHub API token and export it as `GITHUB_API_TOKEN` to avoid
throttling. For example, if using `gh`:

```shell
export GITHUB_API_TOKEN=$(gh auth token)
```

## Install

Plugin:

```shell
asdf plugin add nerves-toolchain
```

nerves-toolchain:

```shell
# Show all installable versions. Only toolchains compatible with the current OS/arch
# will be displayed.
asdf list all nerves-toolchain

# Install specific version
asdf install nerves-toolchain v13.2.0-aarch64-nerves-linux-gnu

# Set a version globally (on your ~/.tool-versions file)
asdf set -u nerves-toolchain v13.2.0-aarch64-nerves-linux-gnu
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on
how to install & manage versions.

## Contributing

Contributions of any kind welcome! See the [contributing
guide](contributing.md).

[Thanks goes to these contributors](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/graphs/contributors)!

## License

See [LICENSE](LICENSE).
