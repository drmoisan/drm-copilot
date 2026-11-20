# R1 Fail-Before — Stale TypeScript lcov at HEAD

- Issue: #344
- Timestamp: 2026-07-10T20-46
- Command: `pwsh -NoLogo -NoProfile -Command "Select-String -Path extensions/drm-copilot/coverage/lcov.info -Pattern 'poshqc-scan-config|poshqc-terminal-output|poshqc-folder-picker' | Measure-Object | Select-Object -ExpandProperty Count"` plus `(Get-Item extensions/drm-copilot/coverage/lcov.info).LastWriteTime`
- EXIT_CODE: 0

## Output Summary

- Match count for the three new modules (`poshqc-scan-config`, `poshqc-terminal-output`, `poshqc-folder-picker`) in the on-disk lcov: **0**.
- `extensions/drm-copilot/coverage/lcov.info` LastWriteTime: `2026-07-10T17:43:17.7165210-04:00`.
- Stale repo-wide totals recorded in the current lcov: 31877/32985 lines = 96.64%; 4056/4577 branches = 88.62%.

The current lcov omits the three new modules, confirming the R1 fail-before state: the TypeScript coverage artifact is stale at HEAD and does not reflect the newly added source modules.
