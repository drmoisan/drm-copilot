# Coverage comparison - remediation cycle 1

Timestamp: 2026-11-18T02-49
Command: comparison of evidence/qa-gates/final-qc-pester.2026-11-18T02-49.md with evidence/remediation-baseline/pester.2026-11-18T02-04.md (both read from their single Invoke-PoshQCParallelTest runs through SCRATCH/issue-1201-pester-report.sh)
EXIT_CODE: 0
Output Summary: no failing test, no new failing test, and no repo-wide or per-file coverage drop; every measured hook file is at 100% line coverage.

| Figure | Baseline | Final | Delta | Result |
|---|---|---|---|---|
| Tests (total / passed / failed / skipped) | 28105 / 28087 / 0 / 18 | 28105 / 28087 / 0 / 18 | 0 | PASS (no failing test; none new) |
| Repo-wide line coverage | 45276/47121 = 96.08% | 45276/47121 = 96.08% | 0.00 | PASS |
| .claude/hooks/hook-release-allowance-context.ps1 | 171/171 = 100.00% | 171/171 = 100.00% | 0.00 | PASS (>= 85%) |
| .codex/hooks/hook-release-allowance-context.ps1 | 171/171 = 100.00% | 171/171 = 100.00% | 0.00 | PASS (>= 85%) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1 | 32/32 = 100.00% | 32/32 = 100.00% | 0.00 | PASS (>= 85%) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1 | 32/32 = 100.00% | 32/32 = 100.00% | 0.00 | PASS (>= 85%) |

- Cycle 1 changes test files only, and test files are outside the coverage population, so identical figures are the expected result. Branch coverage is not measured by Pester (no PowerShell branch gate).
- New/changed production code in cycle 1: none.
