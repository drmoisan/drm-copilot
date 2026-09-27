# Final QA — Coverage Delta (P8-T2)

Timestamp: 2026-09-27T15-54

Command: none (tabulation from recorded artifacts)

EXIT_CODE: 0

Inputs:

- Baseline: baseline/phase0-python-pytest-coverage.2026-09-27T14-44.md (P0-T23), baseline/phase0-python-pytest-targeted-coverage.2026-09-27T14-45.md (P0-T24), baseline/phase0-powershell-pester-coverage.2026-09-27T14-52.md (P0-T27).
- Final (newest per Loop Re-entry and Recovery item 5): qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md (P6-T5; supersedes the 2026-09-27T15-09 artifact), qa-gates/final-python-pytest-targeted-coverage.2026-09-27T15-40.md (P6-T6), qa-gates/final-powershell-pester-coverage.2026-09-27T15-53.md (P7-T3).

## Python repository-wide

| Metric | Baseline | Final | Threshold | Result |
| --- | --- | --- | --- | --- |
| Line | 92.97 (14727/15841) | 92.97 (14727/15841) | >= 85.00 | pass, no regression |
| Branch | 85.68 (4935/5760) | 85.68 (4935/5760) | >= 75.00 | pass, no regression |

## Python targeted (five blast-radius modules)

| Metric | Baseline | Final | Threshold | Result |
| --- | --- | --- | --- | --- |
| Targeted line | 99.75 (393/394) | 99.75 (393/394) | >= 85.00 | pass, no regression |
| Targeted branch | 99.28 (137/138) | 99.28 (137/138) | >= 75.00 | pass, no regression |
| _blast_radius_conflicts line/branch | 100.00/100.00 | 100.00/100.00 | not lower | pass |
| _blast_radius_extraction line/branch | 100.00/100.00 | 100.00/100.00 | not lower | pass |
| _blast_radius_glob line/branch | 98.28/96.43 | 98.28/96.43 | not lower | pass |
| _blast_radius_validation line/branch | 100.00/100.00 | 100.00/100.00 | not lower | pass |
| compute_blast_radius line/branch | 100.00/100.00 | 100.00/100.00 | not lower | pass |

## PowerShell repository-wide

| Metric | Baseline | Final | Threshold | Result |
| --- | --- | --- | --- | --- |
| Line | 96.04 (10224 covered, 422 missed) | 96.04 (10224 covered, 422 missed) | >= 85.00 | pass, no regression |

## New or changed production-code coverage

Not applicable. qa-gates/final-non-goals-scope-diff.2026-09-27T15-54.md (P8-T1) shows zero changed production lines (branch NO-CORRECTION-REQUIRED); this cycle adds only a JSON corpus and two test files.

## Issue #510 allowance

- P6-T5 (qa-gates/final-python-pytest-coverage.2026-09-27T15-40.md): invoked. Excused node ID tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts; normalized path .claude/state/powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json.
- P6-T6 (qa-gates/final-python-pytest-targeted-coverage.2026-09-27T15-40.md): invoked. Excused node ID tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts; normalized path .claude/state/powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json.

Excused under issue #510: local-only gitignored hook state; not evidence of CI behaviour.

Output Summary: PASS. Every value is numeric and no final value is below its baseline. Python repository-wide line 92.97% and branch 85.68% (unchanged); Python targeted line 99.75% and branch 99.28% (unchanged, every per-module value unchanged); PowerShell repository-wide line 96.04% (unchanged). The 85% line, 75% branch (Python), and 85% line (PowerShell) thresholds hold. New or changed production-code coverage: not applicable (zero changed production lines).
