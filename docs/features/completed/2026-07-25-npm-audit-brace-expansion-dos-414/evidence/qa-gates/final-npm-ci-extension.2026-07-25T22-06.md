# Final Install — `npm ci`, `extensions/drm-copilot` (#414, [P5-T1])

Timestamp: 2026-07-25T22-06

Command: `npm ci` (working directory: `extensions/drm-copilot`, against the regenerated `package-lock.json`)
EXIT_CODE: 0

## Verbatim Output

```text
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 457 packages, and audited 458 packages in 7s

103 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

## Interpretation

`npm ci` fails hard when `package.json` and `package-lock.json` are out of sync, so an exit code of 0 proves the manifest edit and the regenerated lockfile agree in this root. This is the same check the CI gate performs.

The `glob@10.5.0` deprecation warning is a pre-existing npm registry notice about the `glob` major line, not a result of this change. `glob@10.5.0` was already the resolved version before the edit; the override changed only the `minimatch` and `brace-expansion` nodes beneath it. The warning is informational and does not affect the exit code.

Output Summary: `npm ci` exits 0 in `extensions/drm-copilot` against the regenerated lockfile, installing 457 packages and auditing 458 with `found 0 vulnerabilities`. Manifest/lockfile sync is proven. The single `npm warn deprecated glob@10.5.0` line is a pre-existing registry notice unrelated to this change.
