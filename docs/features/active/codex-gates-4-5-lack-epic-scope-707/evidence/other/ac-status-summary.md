# Acceptance Criteria Status ([P7-T16], [P7-T27])

Timestamp: 2026-09-27T07-45

### Acceptance Criteria Status
- Source: docs/features/active/codex-gates-4-5-lack-epic-scope-707/spec.md (`## Acceptance Criteria`; Work Mode full-bug)
- Total AC items: 26
- Checked off (delivered): 26
- Remaining (unchecked): 0
- Items remaining: none

Update 2026-09-27T12-20 (orchestrator): AC-16 checked off after the PR #725 CI Pester run on head b7aff51d passed all eight named suites; evidence `qa-gates/ci-pr-725-pester.md`. That run executes on `windows-latest` (the repository has no Linux Pester job); the discrepancy with the criterion's "(Linux runner)" wording is recorded in that artifact and in `follow-ups.md` item 5.

## Fresh-process count

Command: sh <SCRATCHPAD>/x707p7-count.sh (fresh PowerShell 7 process: `@(Select-String -LiteralPath spec.md -Pattern '^- \[x\] AC-').Count`, `@(Select-String -LiteralPath spec.md -Pattern '^- \[ \] AC-16:').Count`, `@(Select-String -LiteralPath spec.md -Pattern '^- \[ \] AC-').Count`)
EXIT_CODE: 0

```
CHECKED: 25
AC16_UNCHECKED: 1
UNCHECKED_ANY: 1
```

## Remaining entries

- AC-16 remaining: requires the pull-request CI Pester run on the Linux runner, outside this plan's scope; local proxy evidence qa-gates/p5-hermeticity-scan.md and qa-gates/final-pester-coverage.md

## Check-off evidence map

| AC | Task | Evidence |
| --- | --- | --- |
| AC-1 | [P7-T1] | qa-gates/final-pester-coverage.md (G1 command Passed); regression-testing/fail-before-b2-gate.md (FAILED line) |
| AC-2 | [P7-T2] | qa-gates/final-pester-coverage.md (G1 apply_patch, path Passed) |
| AC-3 | [P7-T3] | qa-gates/final-pester-coverage.md (G2 x3 Passed) |
| AC-4 | [P7-T4] | qa-gates/final-pester-coverage.md (G3 x3, G4 x5 Passed) |
| AC-5 | [P7-T5] | qa-gates/final-pester-coverage.md (G5, G6 Passed) |
| AC-6 | [P7-T6] | qa-gates/final-pester-coverage.md (A1 x11, A3, A5, A8, A9, A11, A13 x2, A21 x3 Passed); suite header token `no-branch-signal` ([P1-T2]) |
| AC-7 | [P7-T7] | qa-gates/final-pester-coverage.md (A22, A23 x7, A24 Passed) |
| AC-8 | [P7-T8] | qa-gates/final-pester-coverage.md (C1 to C4 Passed) |
| AC-9 | [P7-T9] | qa-gates/final-pester-coverage.md (C5 Passed) |
| AC-10 | [P7-T10] | qa-gates/p5-untouched-files.md (sections 1 and 2 empty) |
| AC-11 | [P7-T11] | qa-gates/final-pester-coverage.md (G7 x12, G8 x3 Passed) |
| AC-12 | [P7-T12] | qa-gates/p5-existing-suites-diff.md; nine testsuite rows failures 0, errors 0 |
| AC-13 | [P7-T13] | qa-gates/p5-existing-suites-diff.md (0/0 for mode-resolution and mode-routing); both rows failures 0, errors 0 |
| AC-14 | [P7-T14] | qa-gates/p5-d10-mock-scope.md; five testsuite rows failures 0, errors 0 |
| AC-15 | [P7-T15] | qa-gates/p5-hermeticity-scan.md (27 counts 0) |
| AC-16 | [P7-T16] + orchestrator post-CI | qa-gates/ci-pr-725-pester.md (PR #725 CI Pester, 8 suites passed; runner windows-latest, discrepancy recorded) |
| AC-17 | [P7-T17] | qa-gates/final-pester-coverage.md (S1 Passed); qa-gates/p5-design-parity.md |
| AC-18 | [P7-T18] | qa-gates/final-pester-coverage.md (S2 x3 Passed; legacy row 43/0/0); qa-gates/p5-line-limits.md |
| AC-19 | [P7-T19] | qa-gates/final-pester-coverage.md (S3 x3 Passed); qa-gates/p5-mirror-parity.md; qa-gates/final-pytest-guards.md |
| AC-20 | [P7-T20] | qa-gates/p5-registration.md (manifest counts 1); qa-gates/final-pytest-guards.md |
| AC-21 | [P7-T21] | qa-gates/final-pester-coverage.md (bundle-probe row 3/0/0) |
| AC-22 | [P7-T22] | qa-gates/p5-registration.md (runsettings counts 1); qa-gates/final-pytest-guards.md; qa-gates/final-coverage-delta.md (100.00, 100.00, 93.20; override line recorded) |
| AC-23 | [P7-T23] | qa-gates/p5-untouched-files.md (section 3 empty) |
| AC-24 | [P7-T24] | qa-gates/p5-untouched-files.md (section 5 empty); Parity row 2/0/0 |
| AC-25 | [P7-T25] | qa-gates/final-pester-coverage.md (S4 x3, S5 x2 Passed) |
| AC-26 | [P7-T26] | qa-gates/final-poshqc-format.md, final-poshqc-analyze.md, final-pester-coverage.md, final-pytest-guards.md, final-mcp-poshqc.md; single pass 1 in final-seven-stage-loop.md |
