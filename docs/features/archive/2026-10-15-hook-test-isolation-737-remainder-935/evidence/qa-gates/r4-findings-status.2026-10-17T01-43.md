# R4 Findings Ledger (P5-T11, issue #935)

Timestamp: 2026-10-17T01-43

TEST-1: FIXED (P1-T1, P1-T5; qa-gates/r4-p1-ps-test.2026-10-17T00-32.md, qa-gates/r4-order-check.2026-10-17T01-27.md) — six F-1 non-compliant rows (switch, foreach, while, trap, matching Get-Command guard with else, with elseif) in enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1.
CR-F4: FIXED (P1-T2, P1-T3, P1-T4, P1-T5; regression-testing/r4-cr-f4-fail-before.2026-10-17T00-23.md, qa-gates/r4-p1-ps-test.2026-10-17T00-32.md) — balanced-brace ExpandableLeaf pattern; row `R1 does not identify unbalanced brace` failed before and passes after.
CR-F1: FIXED (P2-T1; qa-gates/r4-p2-ps-test.2026-10-17T00-45.md) — HookReference helper header names only Get-EpicStateIsolationElementText.
CR-F3: FIXED (P2-T2; qa-gates/r4-p2-ps-test.2026-10-17T00-45.md) — Get-EpicStateIsolationJoinPathSegment comment states an empty string.
CR-F2: FIXED (P2-T3, P2-T4, P2-T5, P2-T6, P2-T7; qa-gates/r4-p2-ps-analyze.2026-10-17T00-35.md, qa-gates/r4-p2-ps-test.2026-10-17T00-45.md) — twelve `[CmdletBinding()]` attributes; Get-EpicStateVariableHookLoad emits elements.
CR-F5: FIXED (P2-T8; qa-gates/r4-p2-ps-test.2026-10-17T00-45.md) — Get-EpicStateHookLiteral uses the shared HookLiteral pattern; comment and header corrected.
CR-F6: FIXED (P2-T9; qa-gates/r4-p2-ps-test.2026-10-17T00-45.md) — Helpers and Discovery-helper headers name every consumer suite.
CR-F7: FIXED (P2-T10; qa-gates/r4-p2-ps-test.2026-10-17T00-45.md) — HookReference suite header describes the F-3, CR-N3 and CR-R1 rows.
CR-F8: FIXED (P2-T11; qa-gates/r4-p2-ps-test.2026-10-17T00-45.md) — ManifestBranch comment names enforce-epic-worktree-removal-gate.Tests.ps1.
AC-CHK-1: FIXED (P3-T1, P3-T3; other/ac24-checkbox-note.2026-10-17T00-47.md) — spec AC-24 unchecked with the S9 amendment sentence; decision record not edited.
EV-3: FIXED (P3-T3; other/ac24-checkbox-note.2026-10-17T00-47.md) — 94.33% sourced to qa-gates/r3-ps-test-repo.2026-10-16T15-50.md line 14.
DOC-3: FIXED (P3-T2; this ledger) — spec Last Updated 2026-10-16, Status Implemented (CI-dependent acceptance criteria are confirmed at S9), Version 0.3.
DOC-4: FIXED (P3-T4; this ledger) — issue.md folder path corrected; two Next Step boxes checked.
PLAN-1: FIXED (P3-T5, P3-T6, P3-T7; qa-gates/r4-main-plan-validation.2026-10-17T00-49.md) — main-plan P7-T6 and P7-T10 accept option 1; P3-T7 recorded VALIDATOR-UNAVAILABLE (authorized skip; the orchestrator runs the validator before S9).
COV-2: FIXED (P5-T5; qa-gates/r4-ps-test-repo.2026-10-17T01-40.md, qa-gates/r4-coverage-delta.2026-10-17T01-41.md) — COV-2-STATUS: FIXED; root pct=89.67 (covered=16532 missed=1905 total=18437, report `Pester (10/17/2026 01:37:47)`).
PERF-1: FIXED (P4-T3, P4-T4, P4-T5; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-2: FIXED (P4-T6, P4-T7; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-3: FIXED (P4-T2, P4-T7; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-4: FIXED (P4-T8, P4-T10; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-5: MEASURED-JUNIT-ONLY (P4-T1, P4-T11, P4-T12; qa-gates/r4-perf-status.2026-10-17T01-10.md, qa-gates/r4-perf-timing-before.2026-10-17T00-54.md, qa-gates/r4-perf-timing-after.2026-10-17T01-09.md, qa-gates/r4-perf-shuffled-run.2026-10-17T01-10.md) — PERF-JUNIT-DELTA: before JUNIT_SUITE_TIME_S=222.758 after JUNIT_SUITE_TIME_S=78.931 (relative; coverage enabled; no target applies); no target line (PERF-COMPARISON-UNAVAILABLE; direct timing PENDING-ORCHESTRATOR (PERF-TIMING-REFUSED)).
DOC-2: out of scope; orchestrator re-runs pr-author after S9
