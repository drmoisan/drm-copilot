# P7-T1 Acceptance-Criteria Verification (issue #927)

Timestamp: 2026-10-16T04-53
Command: AC verification against Phase 0 to Phase 6 evidence
EXIT_CODE: 0
Output Summary: AC source is spec.md `## Acceptance Criteria` (work mode full-bug): 47 items (AC-M1 to AC-M25, AC-1 to AC-22). 41 are verified from Phase 0 to Phase 6 evidence. Six are CI-dependent and pending the pull request CI run (AC-9, AC-18, AC-19, AC-21, AC-M23, AC-M24); AC-18 and AC-M23 are pending for their analyzer half, because the PoshQC MCP analyze result carries no finding detail. No item is BLOCKED; [P5-T1] recorded F901_LOCATOR: active.

AC-M1: VERIFIED p6-pester.2026-10-16T04-43.md (C1 and E1 allow rows pass; deny rows of AC-M6 to AC-M13 and AC-M15 pass), p4-merge-gate-pass.2026-10-16T03-59.md
AC-M2: VERIFIED p2-helper-identity.2026-10-16T02-37.md, p6-mirror-parity.2026-10-16T04-44.md, p6-source-tokens.2026-10-16T04-49.md
AC-M3: VERIFIED p6-pester.2026-10-16T04-43.md (suite A 30 passed, 0 failed)
AC-M4: VERIFIED p2-helper-pass.2026-10-16T03-03.md, p6-pester.2026-10-16T04-43.md (suite A seam rows pass; J14 1, 1)
AC-M5: VERIFIED p6-pester.2026-10-16T04-43.md (suite C 14 passed)
AC-M6: VERIFIED p6-pester.2026-10-16T04-43.md (suite B 36 passed)
AC-M7: VERIFIED p6-pester.2026-10-16T04-43.md (suite B M2 rows)
AC-M8: VERIFIED p6-pester.2026-10-16T04-43.md (suite B M3 rows)
AC-M9: VERIFIED p6-pester.2026-10-16T04-43.md (suite B base rev-parse rows)
AC-M10: VERIFIED p6-pester.2026-10-16T04-43.md (suite B head rows and fetch guard), p6-source-tokens.2026-10-16T04-49.md ("'fetch'" -> 0)
AC-M11: VERIFIED p6-pester.2026-10-16T04-43.md (suite B diff, allow, and range rows)
AC-M12: VERIFIED p6-pester.2026-10-16T04-43.md (suite C C2 to C4)
AC-M13: VERIFIED p6-pester.2026-10-16T04-43.md (suite C C5 to C13; existing Authorization bare-command rows pass)
AC-M14: VERIFIED p6-pester.2026-10-16T04-43.md (suite E E1), p6-source-tokens.2026-10-16T04-49.md ('-RepositoryRoot $repositoryRoot' -> 1)
AC-M15: VERIFIED p6-pester.2026-10-16T04-43.md (suite E E2 to E8)
AC-M16: VERIFIED p4-merge-gate-suite-set.2026-10-16T03-31.md, p6-pester.2026-10-16T04-43.md (J12 0, J13 all greater than 0)
AC-M17: VERIFIED p6-source-tokens.2026-10-16T04-49.md, p6-scope.2026-10-16T04-51.md
AC-M18: VERIFIED p6-pester.2026-10-16T04-43.md (hook-dependency-guard-completeness 598 passed, hook-import-failure-exemptions.Guard 10 passed), p6-source-tokens.2026-10-16T04-49.md
AC-M19: VERIFIED p6-mirror-parity.2026-10-16T04-44.md, p6-pytest-contracts.2026-10-16T04-45.md
AC-M20: VERIFIED p6-pytest-contracts.2026-10-16T04-45.md, p6-jest-manifest.2026-10-16T04-45.md, p6-scope.2026-10-16T04-51.md (manifest numstat 1 0)
AC-M21: VERIFIED p6-source-tokens.2026-10-16T04-49.md, p6-scope.2026-10-16T04-51.md
AC-M22: VERIFIED p6-line-counts.2026-10-16T04-45.md
AC-M23: PENDING_CI poshqc / PowerShell QC
AC-M24: PENDING_CI poshqc / PowerShell QC
AC-M25: VERIFIED p0-f901-locator.2026-10-16T00-11.md, p5-f901-locator.2026-10-16T04-01.md, p6-scope.2026-10-16T04-51.md
AC-1: VERIFIED p6-pester.2026-10-16T04-43.md (J7 R1-R3, V1, X3 pass)
AC-2: VERIFIED p6-pester.2026-10-16T04-43.md (J7 R4-R11, X2 pass)
AC-3: VERIFIED p6-pester.2026-10-16T04-43.md (J7 D1 pass)
AC-4: VERIFIED p6-pester.2026-10-16T04-43.md (J7 A1-A4 pass; J5 0; J6 34, 19, 9; suite A relocated rows pass)
AC-5: VERIFIED p6-pester.2026-10-16T04-43.md (J7 X4), p6-source-tokens.2026-10-16T04-49.md
AC-6: VERIFIED p6-pester.2026-10-16T04-43.md (J7 X1 and V2), p6-source-tokens.2026-10-16T04-49.md
AC-7: VERIFIED p6-source-tokens.2026-10-16T04-49.md (GitInvoker declaration 1, capture 1, '-GitInvoker' at call sites 0)
AC-8: VERIFIED p6-pester.2026-10-16T04-43.md (J7 S1-S4), p6-test-purity.2026-10-16T04-46.md, p2-test-purity.2026-10-16T02-42.md
AC-9: PENDING_CI poshqc / PowerShell QC
AC-10: VERIFIED p6-pester.2026-10-16T04-43.md (J7 V3), p6-cr3-pin.2026-10-16T04-50.md
AC-11: VERIFIED p6-source-tokens.2026-10-16T04-49.md
AC-12: VERIFIED p6-mirror-parity.2026-10-16T04-44.md, p6-pytest-contracts.2026-10-16T04-45.md
AC-13: VERIFIED pa-n3-commit-confirmation.2026-10-16T04-02.md, pa-n3-bounds.2026-10-16T04-02.md
AC-14: VERIFIED pa-n3-bounds.2026-10-16T04-02.md (13 EDIT rows; [P5-T4] to [P5-T16] greps match), p5-no-rename.2026-10-16T04-05.md
AC-15: VERIFIED p5-no-rename.2026-10-16T04-05.md ([P5-T17] and [P5-T18] greps: NOT_OBSERVED 1, OBSERVED_IN 1, 'EXIT_CODE: 0' 0, 'Exit code 0 means' 0)
AC-16: VERIFIED p5-no-rename.2026-10-16T04-05.md
AC-17: VERIFIED p5-no-rename.2026-10-16T04-05.md (issue.md listed as M; [P5-T19] greps 1, 1, 1, 0)
AC-18: PENDING_CI poshqc / PowerShell QC
AC-19: PENDING_CI poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux)
AC-20: VERIFIED p6-line-counts.2026-10-16T04-45.md
AC-21: PENDING_CI poshqc / PowerShell QC
AC-22: VERIFIED p6-scope.2026-10-16T04-51.md

## Pending-CI notes

- AC-18 and AC-M23: format half verified by p6-poshqc-format.2026-10-16T04-18.md (no file rewritten) and test half by p6-pester.2026-10-16T04-43.md; the analyzer half requires the CI `Analyze PowerShell` step ([P8-T2]).
- AC-9, AC-21, AC-M24: coverage is read only from the CI artifact `poshqc-test-results` ([P8-T3]); AC9_LINES 78,79,82,84 and CHANGED_LINES are recorded in p6-coverage-pending-ci.2026-10-16T04-52.md.
- AC-19: requires the PR head CI run ([P8-T2]).
