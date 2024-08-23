# Contributing

## When developing the plugin

- Testing Locally:

```shell
# Hack in a branch
# commit locally (adjust to your git workflow/command preferences)
git add .
git commit -m "feat/fix/chore/...: {some semantic commit message or not}"
# remove the plugin, and install it from your local branch
asdf plugin remove k9s
asdf plugin add k9s .
# Test commands
asdf list all k9s
asdf install k9s latest
# Repeat if needed
```

- Tests are automatically run in GitHub Actions on push and PR.
- You can adjust the `bats` test suite if needed

## Before pushing

- Make sure you installed the required dev dependencies with `asdf install`
- Run the pre-commit hooks: `pre-commit run --all-files`
