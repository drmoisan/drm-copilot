# Baseline: Non-Writing PowerShell Format Check (Issue #973)

Timestamp: 2026-10-17T13-07
Command: sh SCRATCH/issue-973-run.sh issue-973-fmtcheck.ps1 -Root <worktree> -FileList <seven files> (PowerShell 7; per file: Get-Content -Raw, CRLF to LF normalization, Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1, compare formatted text with file text; no write)
EXIT_CODE: 0

Files checked:

- `scripts/ci/CiChangeScope.psm1`: SAME
- `scripts/ci/Invoke-CiChangeScope.ps1`: SAME
- `tests/scripts/ci/CiChangeScope.Tests.ps1`: SAME
- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`: SAME
- `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`: SAME
- `tests/scripts/workflows/CiWorkflow.Tests.ps1`: SAME
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`: SAME

`git status --porcelain` before and after: only the untracked `FEATURE/evidence/baseline/` directory (Phase 0 artifacts); no source file changed by the task.

Output Summary: FORMAT_DIFF_COUNT=0. Zero of seven files differ from their formatted text.
