# Acceptance Criteria Status Summary

Timestamp: 2026-08-20T09-53

Task: [P9-T3] (records the check-offs made at [P9-T2])

Command: not applicable — this artifact records acceptance-criteria status, not a command result
EXIT_CODE: 0

### Acceptance Criteria Status
- Source: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/spec.md`
- Total AC items: 25
- Checked off (delivered): 23
- Remaining (unchecked): 2
- Items remaining: **AC10 — Cross-runtime parity on the existing corpus**; **AC17 — Rendering parity**

Work mode is `full-bug`, so `spec.md` is the SOLE acceptance-criteria source. `user-story.md` is
intentionally absent and was not created. No criterion text was altered; only `- [ ]` was changed to
`- [x]`.

## Backing evidence per checked criterion

| AC | Backing evidence artifact(s) |
| --- | --- |
| AC1 | `evidence/regression-testing/parser-parity-pass-after.2026-08-20T09-53.md`; `evidence/qa-gates/py-parser-module-coverage.2026-08-20T09-53.md` (54 tests incl. `test_absent_expectation_records_match_pre_change_shapes` over shapes 01-08) |
| AC2 | `evidence/qa-gates/ts-parser-module-check.2026-08-20T09-53.md` (test `defaults the expectation to zero and matches pre-change records`) |
| AC3 | `evidence/qa-gates/py-parser-module-coverage.2026-08-20T09-53.md` (21 observed values through `normalize_result(observed, 0)`); `evidence/qa-gates/ts-parser-module-check.2026-08-20T09-53.md` (matching `normalizeResult` test) |
| AC4 | `evidence/regression-testing/py-parser-fail-before.2026-08-20T09-53.md` + `py-parser-pass-after.2026-08-20T09-53.md`; `evidence/regression-testing/ts-parser-fail-before.2026-08-20T09-53.md` + `parser-parity-pass-after.2026-08-20T09-53.md` |
| AC5 | `evidence/regression-testing/parser-parity-pass-after.2026-08-20T09-53.md` (shape-10 and the named differing-expectation tests in both runtimes) |
| AC6 | `evidence/regression-testing/parser-parity-pass-after.2026-08-20T09-53.md` (shape-11 and the named non-integer-expectation tests, asserting Invariant E in both runtimes) |
| AC7 | `evidence/regression-testing/parser-parity-pass-after.2026-08-20T09-53.md` (first-wins duplicate-expectation test in both runtimes) |
| AC8 | `evidence/regression-testing/parser-parity-pass-after.2026-08-20T09-53.md` — both transcribed eleven-shape tables pass with matching shape identifiers in matching order, and the shape-by-shape comparison reports 10 shapes compared with 0 differences (see the shape-06 note below) |
| AC9 | `evidence/other/additive-corpus-parity.2026-08-20T09-53.md` — 1293 artifacts discovered; 0 rendered-row differences in the Python leg and 0 in the TypeScript leg |
| AC11 | `evidence/baseline/namespace-clean-grep.2026-08-20T09-53.md` (pre-change) and `evidence/other/additive-corpus-parity.2026-08-20T09-53.md` (post-change): 123 matches in 16 files, all inside this feature folder, 0 outside |
| AC12 | `evidence/qa-gates/required-fields-unchanged-gate.2026-08-20T09-53.md` |
| AC13 | `evidence/qa-gates/result-vocabulary-closed-gate.2026-08-20T09-53.md`; `evidence/qa-gates/renderer-boundary-gate.2026-08-20T09-53.md` |
| AC14 | `evidence/regression-testing/parser-parity-pass-after.2026-08-20T09-53.md` (`test_skipped_exit_code_remains_unparseable` and `reports unparseable for EXIT_CODE SKIPPED`) |
| AC15 | `evidence/regression-testing/parser-parity-pass-after.2026-08-20T09-53.md` (`test_unrecognized_rows_are_ignored` and `ignores rows outside the accept-list`) |
| AC16 | `evidence/regression-testing/py-renderer-fail-before.2026-08-20T09-53.md`, `ts-renderer-fail-before.2026-08-20T09-53.md`, and `renderer-pass-after.2026-08-20T09-53.md` (two cases per runtime: emitted when non-zero, absent when omitted and when written as `0`) |
| AC18 | `evidence/qa-gates/no-executor-import-edge-gate.2026-08-20T09-53.md` |
| AC19 | `evidence/qa-gates/file-size-census-post-change.2026-08-20T09-53.md`; `evidence/qa-gates/py-parser-module-coverage.2026-08-20T09-53.md`; `evidence/qa-gates/ts-parser-module-check.2026-08-20T09-53.md` |
| AC20 | `evidence/qa-gates/file-growth-and-existing-tests-gate.2026-08-20T09-53.md` (collector.py 4 added / 0 deleted; no numstat row for the over-limit test module) |
| AC21 | `evidence/qa-gates/final-py-pytest-coverage.2026-08-20T09-53.md`; `evidence/qa-gates/coverage-config-unchanged-gate.2026-08-20T09-53.md`; `evidence/qa-gates/coverage-delta.2026-08-20T09-53.md` |
| AC22 | `evidence/qa-gates/final-ts-test-coverage.2026-08-20T09-53.md`; `evidence/qa-gates/coverage-delta.2026-08-20T09-53.md` |
| AC23 | `evidence/qa-gates/push-down-contract-tests.2026-08-20T09-53.md`; `evidence/qa-gates/push-down-contract-tests-all.2026-08-20T09-53.md`; `evidence/qa-gates/docs-six-copy-gate.2026-08-20T09-53.md` |
| AC24 | `evidence/qa-gates/final-qc-single-clean-pass.2026-08-20T09-53.md` and the eight per-command artifacts it indexes |
| AC25 | `evidence/qa-gates/file-growth-and-existing-tests-gate.2026-08-20T09-53.md`; `evidence/qa-gates/existing-tests-unmodified-final.2026-08-20T09-53.md` |

## AC8 — the shape-06 qualification required by [P9-T2]

AC8's prose clause "for each of the eleven shapes, the Python and TypeScript records agree" does NOT
hold for **shape-06**, and cannot, because `spec.md`'s own shape table defines row 6 as the duplicated
-`EXIT_CODE` case that "pins each runtime's existing precedence explicitly". Python assigns
unconditionally in the parse loop, so LAST occurrence wins and shape-06 records `(pass, 0)`;
TypeScript guards with `!parsed.has(key)`, so FIRST occurrence wins and it records `(fail, 1)`. The
convergence of that precedence is deferred by plan constraint SC3 and by the spec's own Option P2
decision, so the divergence is PRE-EXISTING and is not introduced by this change — no task in this plan
alters the `EXIT_CODE` assignment in either parse loop.

AC8 is therefore checked off on the basis of its named verification method: both transcribed fixture
tables pass, with matching shape identifiers in matching order, and the shape-by-shape cross-runtime
comparison reports 0 differences over shapes 01-05 and 07-11 (10 compared) with shape-06 excluded and
its exclusion attributed in writing. The eleven-shape tables are diffable by eye as AC8 requires.

## AC10 and AC17 — left UNCHECKED, with the measured gap

Both criteria depend on the corpus cross-runtime comparison reporting **0** differences over artifacts
containing exactly one `EXIT_CODE:` line. The measured result, recorded in
`evidence/other/additive-corpus-parity.2026-08-20T09-53.md`, is **5 content differences plus 1
presence difference** across the 641 compared artifacts, so neither criterion is satisfied as worded
and both remain unchecked.

The gap, stated precisely:

- All 6 anomalies are PRE-EXISTING artifacts authored by earlier features, each carrying a DUPLICATED
  required key — `Command:` twice in five of them, `Timestamp:` twice in the sixth — with exactly one
  `EXIT_CODE:` line.
- The cause is the same last-wins / first-wins parse-loop asymmetry that the spec defers for
  `EXIT_CODE`, acting on the other two required fields. AC10's exclusion clause is scoped to
  duplicate `EXIT_CODE` only, which is NARROWER than the actual divergence class, so these artifacts
  fall inside the comparison set while being instances of the deferred defect.
- The differences are confined to the `Timestamp` or `Command` row value, or (in the sixth case) to
  whether the row renders at all. **No artifact differs in its `EXIT_CODE` row, its
  `Normalized result` row, or the new `Expected EXIT_CODE` row.** Rendering parity for the behavior
  this change introduces is therefore clean; what fails is the broader byte-equality claim the two
  criteria assert over rows this change does not touch.
- Nothing in this change caused or worsened it. Two artifacts of THIS feature were initially in the
  set because they recorded two `Command:` lines; both were rewritten to a single `Command:` line
  before the recorded runs, so every remaining anomaly is in another feature's artifact.

Recommended disposition: widen the deferred follow-up defect from "duplicate-`EXIT_CODE` precedence
divergence" to "duplicate-REQUIRED-KEY precedence divergence" when it is promoted, and amend AC10's
exclusion clause accordingly. That is a spec amendment, outside this plan's authority to make.

Output Summary: 23 of 25 acceptance criteria are delivered and checked off in `spec.md`, each naming
its backing evidence artifact above. AC10 and AC17 are left unchecked: the cross-runtime corpus
comparison reports 5 content differences plus 1 presence difference over the 641 single-`EXIT_CODE`
artifacts, every one a pre-existing artifact with a duplicated `Command:` or `Timestamp:` line resolved
differently by the two parsers — the deferred duplicate-key precedence defect acting on a required
field other than `EXIT_CODE`. No difference touches an `EXIT_CODE`, `Normalized result`, or
`Expected EXIT_CODE` row. AC8 is checked off with its shape-06 exclusion recorded above.
