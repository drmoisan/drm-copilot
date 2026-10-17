# Acceptance Evidence Map, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T12-29
Task: P4-T14 (remediation-plan.2026-10-16T08-40.md)
Command: derived from the AC-MAPPING table of the plan and the recorded evidence artifacts (no command run)
EXIT_CODE: 0
Output Summary: AC-20, RI-7, and RI-8 each map to evidence artifacts that exist under FEATURE/evidence/, and every mapped acceptance condition was observed as met. AC-20 is eligible for check-off in spec.md (P4-T15). AC-15 is CI-dependent and stays unchecked for S9; run 38898218767 is provisional evidence for it.

All artifact paths below are relative to `docs/features/active/exempt-operand-unc-path-leg-937/evidence/`.

## AC-20

- Implementation: P2-T3 (criterion text in spec.md); P3-T1 (`[A-Za-z][A-Za-z0-9+.-]+:` alternative in the canonical targets copy); P3-T2 (byte-copied mirrors).
- Tests: U27 rows `http-uri`, `smb-uri`, `vscode-remote-uri`, `scheme-plus-uri` and U32 on `.claude/hooks` and `.codex/hooks` (new suite `enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1`); the six gate rows named `(issue #937 RI-7)` in the Claude `EpicScopeTargets` suite and the Codex `epic-scope-targets` suite.
- Evidence and observed status:

| Artifact | Acceptance condition | Observed | Status |
|---|---|---|---|
| `regression-testing/ps-fail-before-c2.2026-10-16T11-27.md` | Fail-before: F2 14 of 14 failed; unfiltered failed set equals F2 (ExpectedExitCode 1) | F2 COUNT_MATCHED=14 COUNT_FAILED=14; failed set equals F2; EXIT_CODE 1 = ExpectedExitCode 1 | met |
| `qa-gates/ci-pass-after-c2.2026-10-16T12-27.md` | Pass-after: F2 14 of 14 passed; F1 84 of 84; unfiltered COUNT_FAILED=0; both poshqc jobs success | F2 14/14, F1 84/84, unfiltered failed 0, both jobs success (run 38898218767) | met |
| `other/targets-diff-shape-c2.2026-10-16T11-30.md` | Production diff limited to lines 40 and 42 of each copy | Two hunks, `@@ -40 +40 @@` and `@@ -42 +42 @@`; 2/2 per copy | met |
| `qa-gates/coverage-final-c2.2026-10-16T12-28.md` | Changed executable lines 41, 230, 231 covered in both copies; per-copy and report line_pct conditions | 3 of 3 covered per copy; 99.40 per copy; report 90.44 | met |

## RI-7

- Implementation: P2-T1, P2-T4 to P2-T7 (test rows), P3-T1 to P3-T5 (pattern change, mirrors, identity, size, diff shape).
- Tests: same as AC-20; existing-row classification by `pathleg_rows_c2.py`.
- Evidence and observed status:

| Artifact | Acceptance condition | Observed | Status |
|---|---|---|---|
| `regression-testing/ps-fail-before-c2.2026-10-16T11-27.md` | as for AC-20 | as for AC-20 | met |
| `qa-gates/ci-pass-after-c2.2026-10-16T12-27.md` | as for AC-20 | as for AC-20 | met |
| `other/targets-diff-shape-c2.2026-10-16T11-30.md` | as for AC-20 | as for AC-20 | met |
| `qa-gates/coverage-final-c2.2026-10-16T12-28.md` | as for AC-20 | as for AC-20 | met |
| `remediation-baseline/pathleg-rows-baseline-c2.2026-10-16T09-46.md` | COUNT_OLD=38, COUNT_NEW=0, COUNT_NONE=15, COUNT_TOTAL=53 | 38, 0, 15, 53 | met |
| `other/pathleg-rows-after-edit-c2.2026-10-16T10-49.md` | The only NEW literals are the 10 new RI-7 inputs; U32 input classified NONE | COUNT_NEW=10 (4 U27 + 3 Claude + 3 Codex), U32 input NONE | met |
| `qa-gates/coverage-delta-c2.2026-10-16T12-29.md` | Numeric values; copy rows 3 of 3 and not below baseline; report rows at least 85.00 | 99.40 -> 99.40 per copy; local 94.58; CI 90.44 | met |

## RI-8

- Implementation: P1-T1 to P1-T3 (move of U27 to U31 to the sibling suite), P2-T2 (spec note).
- Tests: filter sets FM, FOLD, FNEW, FDISC; local `TESTCASES` = `L + 17`.
- Evidence and observed status:

| Artifact | Acceptance condition | Observed | Status |
|---|---|---|---|
| `other/test-move-shape-c2.2026-10-16T10-35.md` | Source numstat 0/97; line counts 399 and 119; moved-block and header cmp exit 0 | 0/97; 399 and 119; both cmp exit 0 | met |
| `other/pathleg-rows-after-move-c2.2026-10-16T10-36.md` | Six-file run COUNT_NEW=0, totals unchanged (53) | COUNT_OLD=38 COUNT_NEW=0 COUNT_NONE=15 COUNT_TOTAL=53 | met |
| `regression-testing/ps-fail-before-c2.2026-10-16T11-27.md` (move proof) | Passed FM name set equals c2baseline (cmp exit 0); FOLD = X - 56; FDISC 1 of 1 | cmp exit 0; FOLD 109; FDISC 1/1 | met |
| `qa-gates/ci-pass-after-c2.2026-10-16T12-27.md` | FM 64/64; FOLD 109 with 0 failed; FNEW 67/67; TESTCASES = T + 17 | 64/64; 109, 0 failed; 67/67; 6374 | met |
| `qa-gates/coverage-canonical-c2.2026-10-16T11-57.md` | Local TESTCASES = L + 17, FAILED=0 | 10507 = 10490 + 17, FAILED=0 | met |

## Gaps

None for AC-20, RI-7, or RI-8. AC-15 (CI-dependent) stays unchecked and is checked off at S9 against the PR head.
