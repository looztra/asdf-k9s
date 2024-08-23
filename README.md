# asdf-k9s <!-- omit in toc -->

[![Build](https://github.com/looztra/asdf-k9s/actions/workflows/code_checks.yml/badge.svg)](https://github.com/looztra/asdf-k9s/actions/workflows/code_checks.yml)
[![Build](https://github.com/looztra/asdf-k9s/actions/workflows/workflows_checks.yml/badge.svg)](https://github.com/looztra/asdf-k9s/actions/workflows/workflows_checks.yml)

[![GitHub license](https://img.shields.io/github/license/looztra/asdf-k9s?style=plastic)](https://github.com/looztra/asdf-k9s/blob/master/LICENSE)

[k9s](https://github.com/derailed/k9s) plugin for the [asdf version manager](https://asdf-vm.com).

## Contents

- [Contents](#contents)
- [Dependencies](#dependencies)
- [Install](#install)
  - [add the plugin](#add-the-plugin)
  - [install k9s](#install-k9s)
- [Notes](#notes)

## Dependencies

- `bash`, `curl`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).

## Install

### add the plugin

```shell
asdf plugin add k9s
```

Or:

```shell
asdf plugin add k9s https://github.com/looztra/asdf-k9s.git
```

### install k9s

```shell
# Show all installable versions
asdf list all k9s

# Install latest version
asdf install k9s latest

# Set a version globally (on your ~/.tool-versions file)
asdf global k9s latest

# Now k9s commands are available
k9s --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Notes

- On 2024/08/23, the default branch changed from `master` to `main` so don't forget to run `asdf plugin update k9s`
