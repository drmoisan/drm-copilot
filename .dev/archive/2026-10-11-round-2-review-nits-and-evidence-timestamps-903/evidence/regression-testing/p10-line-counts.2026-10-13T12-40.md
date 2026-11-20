# P10-T4 Phase 10 line counts

Timestamp: 2026-10-13T12-40
Command: wc -l tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
EXIT_CODE: 0
Output Summary:
- `EpicStateIsolation.Helpers.ps1` is 496 lines (at most 497); every other file is at most 500 lines.

| Lines | File |
|---|---|
| 496 | tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 (495 after P10-T1, 496 after P10-T2) |
| 362 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 (350 + 12 bindings) |
| 288 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 (280 + 8 bindings) |
| 335 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 (329 + 6 bindings) |

P10-T3 acceptance observation: a per-fixture scan of the here-string fixtures found 12 of 12 (main), 10 of 10 (Predicate), and 11 of 11 dot-sourcing (Branches, 15 fixtures total) fixtures that contain `. $script:UnderTest` also contain a `$script:UnderTest =` assignment; zero unbound fixtures remain. P10-T2 acceptance observation: the literal `no dot-source loads the hook` appears once in the helpers file.
