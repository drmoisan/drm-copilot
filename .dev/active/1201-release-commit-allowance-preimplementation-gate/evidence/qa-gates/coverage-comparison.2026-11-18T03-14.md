# Coverage comparison - remediation cycle 1 (loop restart)

Timestamp: 2026-11-18T03-14
Command: comparison of evidence/qa-gates/final-qc-pester.2026-11-18T03-14.md with evidence/remediation-baseline/pester.2026-11-18T02-04.md (each figure read from its single Invoke-PoshQCParallelTest run)
EXIT_CODE: 0
Output Summary: no failing test, no new failing test, and no repo-wide or per-file coverage drop; every measured hook file is at 100% line coverage.

| Figure | Baseline | Final | Delta | Result |
|---|---|---|---|---|
| Tests (total / passed / failed / skipped) | 28105 / 28087 / 0 / 18 | 28105 / 28087 / 0 / 18 | 0 | PASS |
| Repo-wide line coverage | 45276/47121 = 96.08% | 45276/47121 = 96.08% | 0.00 | PASS |
| .claude/hooks/hook-release-allowance-context.ps1 | 171/171 = 100.00% | 171/171 = 100.00% | 0.00 | PASS (>= 85%) |
| .codex/hooks/hook-release-allowance-context.ps1 | 171/171 = 100.00% | 171/171 = 100.00% | 0.00 | PASS (>= 85%) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-release.ps1 | 32/32 = 100.00% | 32/32 = 100.00% | 0.00 | PASS (>= 85%) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-release.ps1 | 32/32 = 100.00% | 32/32 = 100.00% | 0.00 | PASS (>= 85%) |

- Cycle 1 changes test files only, which are outside the coverage population. New or changed production code: none.
