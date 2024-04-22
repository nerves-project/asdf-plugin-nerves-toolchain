<!-- <div align="center"> -->

# asdf-nerves-toolchain [![Build](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/build.yml/badge.svg)](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/build.yml) [![Lint](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/lint.yml/badge.svg)](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/actions/workflows/lint.yml)

[nerves-toolchain](https://github.com/nerves-project/asdf-plugin-nerves-toolchain) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

<!-- **TODO: adapt this section** -->

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `xz` / `xz-utils`
- [`jq`](https://jqlang.github.io/jq/)

# Install

Plugin:

```shell
asdf plugin add nerves-toolchain
# until https://github.com/asdf-vm/asdf-plugins/pull/994 is merged, run this instead:
asdf plugin add nerves-toolchain https://github.com/nerves-project/asdf-plugin-nerves-toolchain.git
```

nerves-toolchain:

```shell
# Show all installable versions. Only toolchains compatible with the current OS/arch
# will be displayed.
asdf list-all nerves-toolchain

# Install specific version
asdf install nerves-toolchain v13.2.0-aarch64-nerves-linux-gnu

# Set a version globally (on your ~/.tool-versions file)
asdf global nerves-toolchain v13.2.0-aarch64-nerves-linux-gnu
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/nerves-project/asdf-plugin-nerves-toolchain/graphs/contributors)!

# License

See [LICENSE](LICENSE).
