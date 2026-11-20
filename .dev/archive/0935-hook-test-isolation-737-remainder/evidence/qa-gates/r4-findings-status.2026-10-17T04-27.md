# R4 Findings Ledger after the pre-push review fixes (P6-T29, issue #935)

Timestamp: 2026-10-17T04-27

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
PLAN-1: FIXED (P3-T5, P3-T6, P3-T7; qa-gates/r4-main-plan-validation.2026-10-17T00-49.md, qa-gates/r4-plan-validation.2026-10-17T03-55.md) — main-plan P7-T6 and P7-T10 accept option 1; P3-T7 recorded VALIDATOR-UNAVAILABLE (authorized skip; the orchestrator runs the validator before S9).
COV-2: FIXED (P5-T5, P6-T24; qa-gates/r4-ps-test-repo.2026-10-17T04-25.md, qa-gates/r4-ps-test-repo.2026-10-17T01-40.md, qa-gates/r4-coverage-delta.2026-10-17T01-41.md) — COV-2-STATUS: FIXED; root pct=89.61 (covered=17017 missed=1973 total=18990, report `Pester (10/17/2026 04:22:37)`; local repo-scope population of the merged tree, packaged MCP runner).
PERF-1: FIXED (P4-T3, P4-T4, P4-T5; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-2: FIXED (P4-T6, P4-T7; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-3: FIXED (P4-T2, P4-T7; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-4: FIXED (P4-T8, P4-T10; qa-gates/r4-perf-status.2026-10-17T01-10.md)
PERF-5: MEASURED-JUNIT-ONLY (P4-T1, P4-T11, P4-T12; qa-gates/r4-perf-status.2026-10-17T01-10.md, qa-gates/r4-perf-timing-before.2026-10-17T00-54.md, qa-gates/r4-perf-timing-after.2026-10-17T01-09.md, qa-gates/r4-perf-shuffled-run.2026-10-17T01-10.md) — PERF-JUNIT-DELTA: before JUNIT_SUITE_TIME_S=222.758 after JUNIT_SUITE_TIME_S=78.931 (relative; coverage enabled; no target applies); no target line (PERF-COMPARISON-UNAVAILABLE; direct timing PENDING-ORCHESTRATOR (PERF-TIMING-REFUSED)).
AC-CHK-2: FIXED (P6-T5, P6-T6; other/r4-ac-recheck-note.2026-10-17T03-42.md) — 17 spec AC lines unchecked pending the S9 re-check; 8 checked, 18 unchecked.
CR-G1: FIXED (P6-T9, P6-T17; qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md) — the Describe BeforeAll catches a report-build throw per surface; the AC-5b row asserts on the recorded message.
CR-G2: FIXED (P6-T8, P6-T17; qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md) — Get-EpicStateProbeFinding returns the suite-state error before Test-EpicStateProbeCalledFromIt.
CR-G3: FIXED (P6-T11, P6-T12, P6-T13, P6-T17; regression-testing/r4-rf-cr-g3-fail-before.2026-10-17T03-46.md, qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md) — ordinal parse-memo dictionary; row `PERF parse memo keeps texts that differ only in letter case apart` failed before and passes after.
TEST-2: FIXED (P6-T10, P6-T17; qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md) — two braced bound-by-assignment rows in the R1 identifies table.
TEST-3: FIXED (P6-T11, P6-T17; qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md, qa-gates/r4-rf-order-check.2026-10-17T04-12.md) — exact read count, reader-memo, library-directory and supplied-seam rows, placed in enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1 under the 500-line limit.
TEST-4: FIXED (P6-T11, P6-T17; qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md) — the dot-source row populates and checks all four memos.
DOC-5: FIXED (P6-T7) — spec performance constraint restated and decision D7 added.
DOC-6: FIXED (P6-T7) — spec decision D6 cites the header paragraph instead of line numbers.
CR-G4: FIXED (P6-T14) — Discovery-helper header names the three dot-sourcing suites and the compliance-helper dependency.
CR-G5: FIXED (P6-T14) — header and three help texts describe the memo writes as deterministic instead of pure.
CR-G6: FIXED (P6-T10, P6-T17; qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md) — R1 does-not-identify message corrected.
CR-G7: FIXED (P6-T15, P6-T16; qa-gates/r4-rf-cr-g7-analyze.2026-10-17T03-48.md) — five `[CmdletBinding()]` attributes; Get-EpicStateHookLiteral emits elements.
PLAN-2: FIXED (revision 5 of this plan; qa-gates/r4-rf-prestate.2026-10-17T03-24.md, PLAN-REVISION-COMMIT: d48f58cf8fe60268be43cfc4240f7bf3e3e9f67a)
EV-4: FIXED (P6-T18; qa-gates/r4-plan-validation.2026-10-17T03-55.md) — review and orchestrator validator results recorded with derived line numbers; VALIDATOR-UNAVAILABLE-TO-EXECUTOR.
DOC-2: out of scope; orchestrator re-runs pr-author after S9
