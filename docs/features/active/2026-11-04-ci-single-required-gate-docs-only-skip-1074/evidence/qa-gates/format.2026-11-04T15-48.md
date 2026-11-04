# PowerShell Format Check (Issue #1074)

Timestamp: 2026-11-04T15-48
Task: [P6-T1]
Command: sh SCRATCH/issue-1074-qa.sh (PowerShell 7: for each file, Invoke-Formatter -ScriptDefinition <LF-normalized content> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, then an ordinal comparison of the formatted text with the content; no file written)
EXIT_CODE: 0
Output Summary:
- `scripts/ci/CiRequiredGate.psm1`: formatted text equals content.
- `scripts/ci/Invoke-CiRequiredGate.ps1`: formatted text equals content.
- `tests/scripts/ci/CiRequiredGate.Tests.ps1`: formatted text equals content.
- `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1`: formatted text equals content.
- `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1`: formatted text equals content.
- Differing files: 0 (`FORMAT_DIFFERING=0`). Existing files were not reformatted.
- History: during Phase 3 the formatter aligned the hashtable assignments of `CiRequiredGateWorkflow.Tests.ps1` (one write), after which the suite was re-run and passed; this final pass changed nothing.
