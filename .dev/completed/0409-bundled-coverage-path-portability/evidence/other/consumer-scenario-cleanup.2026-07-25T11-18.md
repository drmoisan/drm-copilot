# Consumer-Scenario Tool-Output Cleanup (issue #409)

Timestamp: 2026-07-25T11-18

Command: `pwsh -NoLogo -NoProfile -Command "Remove-Item -Recurse -Force tests/artifacts -ErrorAction Stop; git status --porcelain tests/"` (run from the repository root)

EXIT_CODE: 0

Output Summary:
- State before cleanup, `git status --porcelain tests/`:
  ```
  ?? tests/artifacts/
  ?? tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1
  ```
- State after cleanup, `git status --porcelain tests/`:
  ```
  ?? tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1
  ```
- `tests/artifacts/` was removed. `Remove-Item ... -ErrorAction Stop` succeeded, confirming the directory existed and was deleted.
- The only remaining untracked entry under `tests/` is the intended new test file `tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1`, which is the approved test surface for this change.
- No unexpected residue. Note that `.gitignore` anchors `/artifacts` at the repository root only, so `tests/artifacts/` is genuinely visible to `git status` and its removal is genuinely verifiable by this check rather than being masked by an ignore rule.
