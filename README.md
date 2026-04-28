# homebrew-doorman

Homebrew tap for [doorman](https://github.com/kmatzen/doorman) — an HTTP proxy that holds your API keys and refuses to send them anywhere they don't belong.

## Install

```
brew tap kmatzen/doorman
brew install doorman
```

After install, write your config and start the service:

```
cp $(brew --prefix)/share/doorman/examples/doorman.yaml $(brew --prefix)/etc/doorman/doorman.yaml
$EDITOR $(brew --prefix)/etc/doorman/doorman.yaml
chmod 0400 $(brew --prefix)/etc/doorman/doorman.yaml
brew services start doorman
```

## Notes

`brew install` runs doorman under your user uid, not a separate `_doorman` uid. For hardened production deployment with uid separation and LaunchDaemon-level isolation, install via the `install-darwin.sh` script in the [upstream repo](https://github.com/kmatzen/doorman) instead.

## Updating

The Formula's pinned `version` and SHA256s need a manual bump on every doorman release. The release tarballs are signed with sigstore attestations — verify with `gh attestation verify` against `kmatzen/doorman` before updating.
