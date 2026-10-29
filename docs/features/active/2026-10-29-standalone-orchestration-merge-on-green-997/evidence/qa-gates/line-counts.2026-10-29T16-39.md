# Post-Change Physical Line Counts (issue #997)

Timestamp: 2026-10-29T16-39
Command: wc -l <files below>
EXIT_CODE: 0

| File | Baseline | Now | Limit check |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 460 | 476 | at most 500: pass |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 443 | 443 | equals 443: pass |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | 278 | 278 | unchanged |
| `.claude/hooks/hook-docs-only-diff.ps1` | 497 | 497 | unchanged |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 471 | 471 | unchanged from baseline: pass |
| `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | 236 | 247 | at most 500: pass |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` | 183 | 183 | one line value changed |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` | 204 | 204 | one line value changed |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` | 216 | 216 | one line value changed |
| `.claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | new | 321 | at most 500: pass |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1` | new | 267 | at most 500: pass |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1` | new | 288 | at most 500: pass |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` | new | 109 | at most 500: pass |

Output Summary: every limit in P5-T9 holds; the authorization helper reads 443 and `enforce-epic-merge-gate.Tests.ps1` reads 471, both equal to baseline.
