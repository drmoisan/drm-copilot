# Feature Audit: PR-Context ExpectedExitCode Evidence Key (#485)

**Audit Date:** 2026-08-20
**Feature Folder:** `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485`
**Base Branch:** `main`
**Head Branch:** `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`)
- **Head branch/commit:** `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485` (commit `a1a68417dec23a67be9bf07acd335efa8ff6cefb`)
- **Merge base:** `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/**`
  - Additional evidence: direct re-execution of toolchain commands and re-parsing of `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info` at audit time (2026-08-20T11-33)
- **Feature folder used:** `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485`
- **Requirements source:** `spec.md` (sole source)
- **Work mode resolution note:** `issue.md` carries the explicit persisted marker `- Work Mode: full-bug`, so `spec.md` is the sole acceptance-criteria source and `user-story.md` is intentionally absent.
- **Scope note:** The audit scope is the full branch diff (75 files) against the merge base. The PR-context artifacts were collected by the pre-fix bundled extension, whose Verification block cannot read the `ExpectedExitCode` key this branch introduces; its 32-pass/8-fail figures were therefore treated as collection-mechanism limitation, not as evidence against the branch, and every AC verdict below rests on directly re-executed commands or executor evidence artifacts.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/spec.md` — only source (`## Acceptance Criteria`, lines 475-503; 25 checkbox items AC1-AC25)

### Acceptance criteria

Each item below preserves the source's bold label and asserted condition; full verbatim text is at the cited spec.md line.

1. **AC1 — Default-absent behavior, Python** (spec.md:479): records for artifacts without `ExpectedExitCode` are identical to pre-change records for shapes 1-8; verified by `test_absent_expectation_records_match_pre_change_shapes`.
2. **AC2 — Default-absent behavior, TypeScript** (spec.md:480): same assertion via `defaults the expectation to zero and matches pre-change records`.
3. **AC3 — Layer 1 exhaustive default-path equivalence** (spec.md:481): `normalize_result(observed, 0)` equals the pre-change expression over -8..8 plus large-magnitude values, both runtimes.
4. **AC4 — Observed equals expected passes** (spec.md:482): `EXIT_CODE: 1` with `ExpectedExitCode: 1` normalizes to `pass`, retaining the observed code, both runtimes.
5. **AC5 — Observed differs from a non-zero expectation fails** (spec.md:483): `2` vs `1` and `0` vs `1` normalize to `fail`, both runtimes.
6. **AC6 — Non-integer expectation yields `unparseable`** (spec.md:484): `banana` and empty values produce `unparseable` with null observed code and expectation `0` (Invariant E), both runtimes.
7. **AC7 — Duplicate expectation key resolves first-wins in both runtimes** (spec.md:485).
8. **AC8 — Cross-runtime parity over the eleven-shape table** (spec.md:486): records agree on result, observed code, and expectation; tables textually diffable in the same order.
9. **AC9 — Byte-identical rendered rows on the existing corpus, per runtime** (spec.md:487): 0 rendered-row differences pre-vs-post across every `CANONICAL_GLOBS` artifact, recorded in the parity evidence artifact.
10. **AC10 — Cross-runtime parity on the existing corpus** (spec.md:488): 0 runtime-to-runtime differences across single-`EXIT_CODE` artifacts, with multi-`EXIT_CODE` exclusions counted and attributed.
11. **AC11 — No artifact carries the new key before the change** (spec.md:489): namespace grep over `docs/features` matches only inside this feature folder.
12. **AC12 — `REQUIRED_FIELDS` is unchanged in both runtimes (Invariant D)** (spec.md:490).
13. **AC13 — Result vocabulary is closed (Invariant C)** (spec.md:491): `pass | fail | unparseable` unchanged; collector record filters unchanged.
14. **AC14 — `EXIT_CODE: SKIPPED` is still `unparseable` (Invariant F)** (spec.md:492).
15. **AC15 — Unrecognized rows are still discarded** (spec.md:493): `Output Summary:` and wrong-cased `expectedexitcode:` do not alter the record.
16. **AC16 — Rendering is conditional and additive** (spec.md:494): `  - Expected EXIT_CODE: <int>` appears between `EXIT_CODE` and `Normalized result` when and only when the expectation is non-zero.
17. **AC17 — Rendering parity** (spec.md:495): Python and TypeScript rendered sections string-equal for the same artifact text, verified by the AC10 corpus run over rendered rows.
18. **AC18 — No import edge to the atomic-executor QC path (Invariant G)** (spec.md:496): the grep exits `1` with no output.
19. **AC19 — 500-line limit on both changed parser files** (spec.md:497): both parsers, `collector-output.ts`, and every new or modified test file are <= 500 lines.
20. **AC20 — Pre-existing over-limit files do not grow materially** (spec.md:498): `collector.py` at most 5 added lines; `test_collect_pr_context_part4.py` 0 added and 0 deleted.
21. **AC21 — Python coverage thresholds** (spec.md:499): overall line >= 85% and branch >= 75%; zero uncovered added/changed lines in `verification_evidence.py`; no coverage-config exclusion added.
22. **AC22 — TypeScript coverage thresholds** (spec.md:500): overall line >= 85% and branch >= 75%; no uncovered added/changed line in `verification-evidence.ts`.
23. **AC23 — Documentation is updated and the six copies are byte-identical** (spec.md:501): the key documented in the conventions skill and all mirrors; push-down contract tests pass; six files match the grep.
24. **AC24 — Full toolchain pass in a single clean pass, both runtimes** (spec.md:502).
25. **AC25 — Existing tests are unmodified and green** (spec.md:503).

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 Default-absent, Python | PASS | 8 shape cases pass in the new module; suite green at audit time | `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py -q` (54 passed) | Named test present and collected (8 parametrized shapes) |
| 2 | AC2 Default-absent, TypeScript | PASS | Named Jest test passes | `npx jest test/lib/pr-context/verification-evidence.test.ts` (suite green) | Title matches spec contract |
| 3 | AC3 Exhaustive default-path equivalence | PASS | 21 parametrized Python cases (-8..8, 2147483647 and other large values) plus TS mirror pass | same as above | Bounded-range exhaustive per spec |
| 4 | AC4 Observed equals expected passes | PASS | Cases 1-1, 137-137, -3--3 pass; record retains observed code | same as above | Both runtimes |
| 5 | AC5 Differing non-zero expectation fails | PASS | Cases 2-1 and 0-1 pass | same as above | Both runtimes |
| 6 | AC6 Non-integer expectation unparseable | PASS | `banana` and empty cases pass; Invariant E fields pinned | same as above | Both runtimes |
| 7 | AC7 Duplicate expectation first-wins | PASS | Named tests pass in both suites; implementation guards verified in diff (`key not in parsed` / `!parsed.has(key)`) | test runs plus diff inspection | Distinct from the deferred required-key precedence |
| 8 | AC8 Eleven-shape parity table | PASS | `test_eleven_shape_fixture_table` and `it.each(shapeCases)` pass; tables transcribed in the same order | test runs | Single-`EXIT_CODE` fixtures only, per spec R3 mitigation |
| 9 | AC9 Byte-identical rendered rows per runtime | PASS | 1293 artifacts discovered; 0 rendered-row differences pre-vs-post in BOTH runtimes; worktree-resolved module paths recorded | evidence artifact inspection | `evidence/other/additive-corpus-parity.2026-08-20T09-53.md` |
| 10 | AC10 Cross-runtime corpus parity | PARTIAL | 641 single-`EXIT_CODE` artifacts compared: 5 content + 1 presence differences, all pre-existing artifacts with duplicated `Command:`/`Timestamp:` lines; 165 multi-`EXIT_CODE` exclusions counted and attributed as required | evidence artifact inspection | The divergence cause is the deferred duplicate-required-key defect, wider than AC10's exclusion clause anticipated; no difference touches an `EXIT_CODE`, `Normalized result`, or `Expected EXIT_CODE` row. Left unchecked in spec.md |
| 11 | AC11 No prior use of the new key | PASS | Namespace grep matches only inside this feature folder | `git grep -n -E "ExpectedExitCode|expected_exit|expectedExit|expected_nonzero|EXPECTED_EXIT" -- docs/features` | Recorded in the parity evidence artifact; re-checked at audit time |
| 12 | AC12 `REQUIRED_FIELDS` unchanged | PASS | No changed diff line matches `REQUIRED_FIELDS`; same three members in both files | `git diff 71aebdb9..HEAD -- <both parsers>`; `git grep -n "REQUIRED_FIELDS" -- scripts/dev_tools/pr_context extensions/drm-copilot/src/lib/pr-context` | Audit re-ran both commands |
| 13 | AC13 Result vocabulary closed | PASS | Union still `pass | fail | unparseable`; collector record filters untouched (diff shows only the render-row hunks) | diff inspection of `collector.py` and `collector-output.ts` | Filters at `collector.py:147-149` / `collector-output.ts:98-101` unchanged |
| 14 | AC14 `SKIPPED` still unparseable | PASS | Named tests pass (with and without an expectation present) | test runs | Invariant F |
| 15 | AC15 Unrecognized rows discarded | PASS | Named tests pass; wrong-cased key ignored | test runs | Accept-list confinement |
| 16 | AC16 Conditional, additive rendering | PASS | 3 Python collector-level cases and the added `renderVerificationEvidenceSection` cases pass; row position between `EXIT_CODE` and `Normalized result` pinned | `poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py -q`; Jest suite | Zero expectation and absent key render identically |
| 17 | AC17 Rendering parity | PARTIAL | Same corpus run as AC10 over rendered rows: the 6 residual differences are all attributable to the deferred pre-existing defect; parity for rows involving the new key is clean | evidence artifact inspection | Left unchecked in spec.md; remediation via follow-up promotion |
| 18 | AC18 No executor-QC import edge | PASS | Grep exits `1` with no output (audit re-run) | `git grep -n -E "qc_runner_expectations|pytest_expectations" -- scripts/dev_tools/pr_context extensions/drm-copilot/src/lib/pr-context` | Invariant G holds |
| 19 | AC19 500-line limit on changed files | PASS | 215 / 303 / 454 / 408 / 141 / 456 / 445 lines — all <= 500 | `wc -l` on each changed parser, renderer, and test file | `collector.py` is governed by AC20, not AC19 |
| 20 | AC20 Over-limit files capped | PASS | `collector.py`: 4 added, 0 deleted (cap 5); `test_collect_pr_context_part4.py`: absent from numstat (0/0) | `git diff --numstat 71aebdb9..HEAD -- scripts/dev_tools/pr_context/collector.py tests/scripts/dev_tools/test_collect_pr_context_part4.py` | Audit re-ran the command |
| 21 | AC21 Python coverage thresholds | PASS | Overall 92.45% lines / 84.93% branches; the only uncovered line in `verification_evidence.py` (124) and branches (98, 123) are outside the changed hunks; no `[tool.coverage.run]` change (pyproject.toml absent from diff) | LCOV re-parse of `artifacts/python/lcov.info`; `git diff --name-only 71aebdb9..HEAD` | Independently re-derived, agrees with `evidence/qa-gates/coverage-delta.2026-08-20T09-53.md` |
| 22 | AC22 TypeScript coverage thresholds | PASS | Overall 96.62% lines / 89.98% branches; no uncovered added/changed line in `verification-evidence.ts` | LCOV re-parse of `extensions/drm-copilot/coverage/lcov.info` | Independently re-derived |
| 23 | AC23 Six-copy documentation | PASS | `ExpectedExitCode` present 3 times in each of the six SKILL.md copies; both push-down contract test modules pass | `git grep -c "ExpectedExitCode" -- "*evidence-and-timestamp-conventions/SKILL.md"`; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q` | Audit re-ran both |
| 24 | AC24 Single clean toolchain pass, both runtimes | PASS | Audit re-ran format/lint/type-check (changed scope) and both full test suites in one pass with no file modified: Python 3995 passed / 5 skipped; TypeScript 2580 passed / 185 suites | commands in policy-audit Appendix B | Executor's full-scope pass recorded in `evidence/qa-gates/final-qc-single-clean-pass.2026-08-20T09-53.md` |
| 25 | AC25 Existing tests unmodified and green | PASS | Numstat shows additions only for both TS suites (237+0, 62+0) and zero changes to the two named Python modules; all pre-existing tests pass | `git diff --numstat 71aebdb9..HEAD -- <four test files>`; full suite runs | An edit would have signaled an Invariant A break; none occurred |

---

## Summary

**Overall Feature Readiness:** PASS (with two documented PARTIAL criteria routed to remediation inputs)

**Criteria summary:**
- **PASS:** 23 criteria
- **PARTIAL:** 2 criteria (AC10, AC17)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC10 and AC17 assert zero cross-runtime differences over single-`EXIT_CODE` artifacts; execution measured 6 residual differences, all caused by the pre-existing duplicate-required-key precedence divergence (Python last-wins, TypeScript first-wins), which is wider than the exclusion clause AC10 anticipated. Fixing it on this branch is prohibited by the change's own additive requirement (spec Invariant A); the remediation is the separately promoted follow-up defect. None of the residual differences touches the behavior this branch changed.

**Recommended follow-up verification steps:**

1. Promote the duplicate-REQUIRED-KEY precedence divergence via the potential-to-issue path (queued in `issue.md` "Next Step"), scoping it to any duplicated required key and widening AC10's exclusion clause there, per spec "Post-fix monitoring or clean-up tasks".
2. After that follow-up lands, re-run the cross-runtime corpus comparison; AC10 and AC17 should then be satisfiable and checkable.
3. Push head `a1a68417` to origin before PR authoring (the branch is 1 commit ahead of its upstream).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 23 PASS criteria were already checked off (`- [x]`) in `spec.md` by the executor, and this audit's independent evaluation agrees with each of them, so no source-file checkbox change was made by this review. AC10 (spec.md:488) and AC17 (spec.md:495) are evaluated PARTIAL and correctly remain unchecked (`- [ ]`).

### AC Status Summary

- Source: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/spec.md`
- Total AC items: 25
- Checked off (delivered): 23
- Remaining (unchecked): 2
- Items remaining: AC10 — Cross-runtime parity on the existing corpus; AC17 — Rendering parity

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 23 | 2 | Checkbox-backed; sole authoritative source under `full-bug` work mode |
