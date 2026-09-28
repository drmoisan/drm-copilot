# Acceptance-Criteria Sign-Off — [P6-T11]

Timestamp: 2026-08-28T12-46

Command: n/a (synthesis task)

EXIT_CODE: 0

This task produces no shell command. It maps each of the 21 acceptance criteria from the `##
Acceptance Criteria` section of
`docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/spec.md` — the sole
acceptance-criteria source under `full-bug` — to the task identifiers that discharged it and to the
evidence artifact path that substantiates it. Criteria are numbered in the document order of that
section. Every artifact path below is relative to the repository root and exists on disk.

| AC | Subject | Discharging tasks | Substantiating artifact | Verdict |
| --- | --- | --- | --- | --- |
| AC1 | `test_bool_is_false_for_a_disjoint_pair` exists and passes | P1-T1, P1-T2, P2-T2 | `docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/regression-testing/pass-after.2026-08-28T12-46.md` (exit 0, `1 passed`); fail-before at `.../evidence/regression-testing/fail-before.2026-08-28T12-46.md` | PASS |
| AC2 | `test_bool_is_true_for_an_overlapping_pair` exists and passes | P3-T1 | `.../evidence/qa-gates/python-scoped-coverage.2026-08-28T12-46.md` (inside the `48 passed` single-file run); node run exit 0, `1 passed` | PASS |
| AC3 | `test_bool_matches_the_conflict_field_on_constructed_results` exists and passes | P3-T2 | `.../evidence/qa-gates/python-scoped-coverage.2026-08-28T12-46.md`; node run exit 0, `1 passed` | PASS |
| AC4 | `test_boolean_projection_agrees_with_the_conflict_field` passes for every `RADIUS_PAIRS` entry | P3-T4 | `.../evidence/qa-gates/python-scoped-coverage.2026-08-28T12-46.md` (the 10 parametrized cases inside `112 passed`); node run exit 0, `10 passed` | PASS |
| AC5 | `test_conflict_reason_defines_no_boolean_projection` exists and passes | P3-T3 | `.../evidence/qa-gates/python-scoped-coverage.2026-08-28T12-46.md`; node run exit 0, `1 passed` | PASS |
| AC6 | Pester `It` asserting both halves of the divergence | P4-T3, P4-T5 | `.../evidence/qa-gates/powershell-conflict-tests.2026-08-28T12-46.md` (`testcase` `status` `Passed`) | PASS |
| AC7 | Pester `It` asserting the help literal | P4-T4, P4-T5 | `.../evidence/qa-gates/powershell-conflict-tests.2026-08-28T12-46.md` (`testcase` `status` `Passed`) | PASS |
| AC8 | Existing key-set assertion unmodified and still passing | P4-T5, P6-T12 | `.../evidence/qa-gates/parity-suites-unmodified.2026-08-28T12-46.md` (single additive hunk at line 83, `It` at lines 56-67 untouched); `.../evidence/qa-gates/powershell-conflict-tests.2026-08-28T12-46.md` (`status` `Passed`) | PASS |
| AC9 | Add-skill literal in source and bundled copy | P5-T1, P5-T2, P5-T6 | `.../evidence/qa-gates/skill-literal-presence.2026-08-28T12-46.md` (six rows, count 1 each) | PASS |
| AC10 | Plan-skill literals in source and bundled copy | P5-T3, P5-T4, P5-T5, P5-T6, P5-T7 | `.../evidence/qa-gates/skill-literal-presence.2026-08-28T12-46.md` (six rows for the hashtable literal, two rows for the ConflictResult literal) | PASS |
| AC11 | Push-down payload contract test passes | P5-T8 | `.../evidence/qa-gates/push-down-parity.2026-08-28T12-46.md`, including the addendum recording the confirming run at exit 0 with `1 passed` after the untracked gitignored `.claude/state` session directory was removed; `.../evidence/qa-gates/final-python-test.2026-08-28T12-46.md` records the same node inside the green 4209-passed run | PASS |
| AC12 | SHA-256 parity evidence for the three pairs | P0-T9, P5-T9 | `.../evidence/other/bundle-parity-post-change.2026-08-28T12-46.md`; baseline at `.../evidence/baseline/bundle-parity.2026-08-28T12-46.md` | PASS |
| AC13 | Scoped coverage run and captured, data collected | P3-T5, P6-T5 | `.../evidence/qa-gates/python-scoped-coverage.2026-08-28T12-46.md`; `.../evidence/qa-gates/final-python-scoped-coverage.2026-08-28T12-46.md` (Stmts 60, no `No data was collected`) | PASS |
| AC14 | Python line and branch thresholds met | P3-T5, P6-T5 | `.../evidence/qa-gates/final-python-scoped-coverage.2026-08-28T12-46.md` (branch-enabled run, combined Cover 100 percent, Miss 0, BrPart 0) | PASS |
| AC15 | PowerShell line threshold met | P0-T11, P4-T5, P6-T8 | `.../evidence/qa-gates/final-powershell-test.2026-08-28T12-46.md` (JaCoCo LINE missed 0, covered 109, 100 percent); baseline at `.../evidence/baseline/powershell-test-observable.2026-08-28T12-46.md` | PASS |
| AC16 | Four-stage Python toolchain clean in a single pass | P6-T1, P6-T2, P6-T3, P6-T4, P6-T9 | `.../evidence/qa-gates/final-python-format.2026-08-28T12-46.md`, `.../evidence/qa-gates/final-python-lint.2026-08-28T12-46.md`, `.../evidence/qa-gates/final-python-typecheck.2026-08-28T12-46.md`, `.../evidence/qa-gates/final-python-test.2026-08-28T12-46.md`, `.../evidence/qa-gates/final-qa-loop-outcome.2026-08-28T12-46.md` (iteration count 1) | PASS |
| AC17 | Three-stage PowerShell toolchain clean in a single pass | P6-T6, P6-T7, P6-T8, P6-T9 | `.../evidence/qa-gates/final-powershell-format.2026-08-28T12-46.md`, `.../evidence/qa-gates/final-powershell-analyze.2026-08-28T12-46.md`, `.../evidence/qa-gates/final-powershell-test.2026-08-28T12-46.md`, `.../evidence/qa-gates/final-qa-loop-outcome.2026-08-28T12-46.md` | PASS |
| AC18 | Delivered file scope matches the declaration | P6-T10 | `.../evidence/qa-gates/scope-verification.2026-08-28T12-46.md` (porcelain plus anchored `--name-only` union, all five exclusion checks confirmed) | PASS |
| AC19 | No length dunder added; validation unchanged | P2-T1, P2-T3 | `.../evidence/qa-gates/python-diff-review.2026-08-28T12-46.md` (15 added lines, one method, no added `def __len__`, `__post_init__` untouched) | PASS |
| AC20 | Parity suites unmodified and passing | P3-T6, P6-T12, P6-T4, P6-T8 | `.../evidence/qa-gates/parity-suites-unmodified.2026-08-28T12-46.md`; `.../evidence/qa-gates/python-parity-suite-unmodified.2026-08-28T12-46.md` | PASS |
| AC21 | Both module copies remain below 500 lines | P4-T6 | `.../evidence/qa-gates/powershell-file-size.2026-08-28T12-46.md` (493 and 493) | PASS |

All 21 rows are present. Each names at least one task identifier and at least one artifact path that
exists on disk. No row is marked PASS without its artifact.

## Checklist State

All 21 checkboxes in the `## Acceptance Criteria` section of `spec.md` are marked `[x]`. The count
was verified programmatically: 21 total checkbox items in that section, 21 checked.

Output Summary: `EXIT_CODE: 0`. All 21 acceptance criteria are mapped to their discharging task
identifiers and to a substantiating evidence artifact that exists on disk. All 21 are marked PASS and
all 21 checkboxes in `spec.md` are checked. Two conditions are recorded rather than hidden: the
[P5-T8] push-down run failed under branch (b) of its own acceptance on an untracked, gitignored
session state file outside this change's file scope, with a confirming run at exit 0 recorded in the
same artifact after that session state was removed; and the [P6-T4] full-suite gate is judged on its
second, environment-parity-restored run, with the first run recorded in full.
