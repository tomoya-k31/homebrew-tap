# homebrew-tap

Homebrew formulae for [tomoya-k31](https://github.com/tomoya-k31)'s tools.

## Install

```sh
brew install tomoya-k31/tap/totsuka
```

Or tap first and then use the bare name:

```sh
brew tap tomoya-k31/homebrew-tap
brew install totsuka
```

Update with `brew upgrade totsuka` either way.

## Formulae

| Formula | Description |
|---|---|
| `totsuka` | [Local-first orchestrator that dispatches dev tasks to AI coding agents](https://github.com/tomoya-k31/totsuka) |

## Maintenance

`Formula/totsuka.rb` is **updated automatically**. The `universal-binary` job in
totsuka's `release-please.yml` rewrites the `version` and `sha256` lines and
pushes here on every release, right after the release assets are uploaded.

Two consequences worth knowing before editing by hand:

- The `url` is derived from `version` inside the formula and is never rewritten
  by the automation. Keep it that way — it is what stops the URL from drifting
  away from the tag.
- The rewrite is two anchored `sed` expressions on `^  version "…"` and
  `^  sha256 "…"`, guarded by `grep -q` assertions. Reformatting those two lines
  (reindenting, reordering, moving `sha256` into a block) turns the next release
  red rather than silently leaving the tap a version behind.

`brew install` does not run a formula's `test do` block. To exercise it:

```sh
brew install --build-from-source ./Formula/totsuka.rb
brew test totsuka
```
