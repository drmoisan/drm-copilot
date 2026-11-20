# File-Size Check (Issue #1074)

Timestamp: 2026-11-04T15-51
Task: [P6-T9]
Command: wc -l on every created or edited non-Markdown file; tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 result from the P6-T3 run
EXIT_CODE: 0
Output Summary:

| File | Physical lines | At or below 500 |
|---|---|---|
| `scripts/ci/CiRequiredGate.psm1` (new) | 229 | yes |
| `scripts/ci/Invoke-CiRequiredGate.ps1` (new) | 149 | yes |
| `tests/scripts/ci/CiRequiredGate.Tests.ps1` (new) | 336 | yes |
| `tests/scripts/ci/Invoke-CiRequiredGate.Tests.ps1` (new) | 169 | yes |
| `tests/scripts/workflows/CiRequiredGateWorkflow.Tests.ps1` (new) | 149 | yes |
| `.github/workflows/ci.yml` (edited) | 145 | yes |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (edited) | 497 | yes |

- Every created or edited non-Markdown file is at or below 500 lines. The other edited files are Markdown (exempt).
- `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1`: 5 tests, failures 0 in the P6-T3 run (evidence/qa-gates/pester-coverage.2026-11-04T15-49.md). The repository gate passed.
