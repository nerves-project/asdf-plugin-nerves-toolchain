# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test nerves-toolchain https://github.com/bjyoungblood/asdf-nerves-toolchain.git --asdf-tool-version="13.2.0-aarch64-nerves-linux-gnu" "aarch64-nerves-linux-gnu-gcc --help"
```

Tests are automatically run in GitHub Actions on push and PR.
