# Baseline Physical Line Counts (issue #997)

Timestamp: 2026-10-29T16-08
Command: wc -l <files below>
EXIT_CODE: 0

| File | Physical lines |
| --- | --- |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 460 |
| `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` | 443 |
| `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` | 278 |
| `.claude/hooks/hook-docs-only-diff.ps1` | 497 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 471 |
| `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` | 236 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` | 183 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` | 204 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` | 216 |

Output Summary: gate reads 460 and the authorization helper reads 443, matching the plan premise; no premise change.
