# Baseline — extension npm dependency tree (issue #643, task [P0-T2])

- Timestamp: 2026-09-07T15:09Z
- Command: `pwsh -NoProfile -Command "Test-Path extensions/drm-copilot/node_modules"` then `pwsh -NoProfile -Command 'Push-Location extensions/drm-copilot; npm ci; $code = $LASTEXITCODE; Pop-Location; exit $code'` then `pwsh -NoProfile -Command "Test-Path extensions/drm-copilot/node_modules/jest/package.json"`, all from the worktree root
- EXIT_CODE: 0

## Output Summary

Branch taken: INSTALL. The pre-install probe printed `False`, so `npm ci` was run.

Probe before install:

```text
False
```

`npm ci` output (final lines):

```text
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 444 packages, and audited 445 packages in 6s

107 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

`npm ci` exit code: 0. Installed-package count: 444 added, 445 audited.

Post-install acceptance probe:

```text
True
```

`extensions/drm-copilot/node_modules/jest/package.json` is present at the end of the task.
