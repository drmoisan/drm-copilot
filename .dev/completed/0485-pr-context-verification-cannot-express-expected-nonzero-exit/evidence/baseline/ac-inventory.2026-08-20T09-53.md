# Acceptance-Criteria Inventory — Issue #485

Timestamp: 2026-08-20T09-53

Task: [P0-T2]
Command: sed -n '479,503p' docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/spec.md
EXIT_CODE: 0

Work Mode: full-bug. Acceptance-criteria source is `spec.md` ALONE (`spec.md` lines 479-503,
section `## Acceptance Criteria`). `user-story.md` is intentionally absent under `full-bug` and its
absence is not a blocker. `issue.md` was read in full (98 lines) and carries no separate
`## Acceptance Criteria` section; its `## Proposed Fix / Validation Ideas` checkboxes are seeded
into `spec.md` "Test Strategy" and are NOT an independent AC source.

Documents read in full for this task:
- `spec.md` (558 lines)
- `research/2026-08-17T16-10-expected-nonzero-exit-research.md` (635 lines)
- `issue.md` (98 lines)

## Verbatim acceptance criteria (25 items, quoted from `spec.md:479-503`)

> - [ ] **AC1 — Default-absent behavior, Python.** For an artifact carrying no `ExpectedExitCode` line, the parsed record is identical to the pre-change record for every one of shapes 1-8 in the Test Strategy table. Verified by `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py -k absent_expectation` covering `test_absent_expectation_records_match_pre_change_shapes`.
> - [ ] **AC2 — Default-absent behavior, TypeScript.** Same assertion in the other runtime. Verified from `extensions/drm-copilot/` by `npm run test:unit` covering the test `parseVerificationEvidenceMarkdown defaults the expectation to zero and matches pre-change records` in `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`.
> - [ ] **AC3 — Layer 1 exhaustive default-path equivalence.** In both runtimes, `normalize_result(observed, 0)` equals `"pass" if observed == 0 else "fail"` over the bounded integer range -8..8 plus at least four large-magnitude values. Verified by `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py -k normalize_default` (`test_normalize_result_with_default_expectation_matches_pre_change_expression`) and by the matching TypeScript test `normalizeResult with a zero expectation matches the pre-change expression`.
> - [ ] **AC4 — Observed equals expected passes.** An artifact with `EXIT_CODE: 1` and `ExpectedExitCode: 1` normalizes to `pass` in both runtimes, and the record retains `exit_code == 1`. Verified by `test_observed_equal_to_nonzero_expectation_passes` (Python) and `parseVerificationEvidenceMarkdown normalizes to pass when the observed code equals a non-zero expectation` (TypeScript).
> - [ ] **AC5 — Observed differs from a non-zero expectation fails.** An artifact with `EXIT_CODE: 2` and `ExpectedExitCode: 1` normalizes to `fail` in both runtimes; likewise `EXIT_CODE: 0` with `ExpectedExitCode: 1`. Verified by `test_observed_differing_from_nonzero_expectation_fails` (Python) and `parseVerificationEvidenceMarkdown normalizes to fail when the observed code differs from a non-zero expectation` (TypeScript).
> - [ ] **AC6 — Non-integer expectation yields `unparseable`.** An artifact with `ExpectedExitCode: banana` (and separately, an empty value) normalizes to `unparseable` in both runtimes, and the record carries `exit_code = None` / `exitCode = null` and expectation `0` per Invariant E. Verified by `test_non_integer_expectation_is_unparseable_and_clears_fields` (Python) and `parseVerificationEvidenceMarkdown reports unparseable for a non-integer expectation` (TypeScript).
> - [ ] **AC7 — Duplicate expectation key resolves first-wins in both runtimes.** An artifact with two `ExpectedExitCode:` lines carrying different values resolves to the first. Verified by `test_duplicate_expectation_key_takes_first_occurrence` (Python) and `parseVerificationEvidenceMarkdown takes the first occurrence of a duplicated expectation key` (TypeScript), the latter mirroring the existing test at `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts:151-159`.
> - [ ] **AC8 — Cross-runtime parity over the eleven-shape table.** For each of the eleven shapes, the Python and TypeScript records agree on `normalized_result`, on the observed exit code, and on the expectation. Verified by the two transcribed fixture tables passing under `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py` and `npm run test:unit`, and by the tables being textually diffable — the plan records the shape identifiers in both files in the same order.
> - [ ] **AC9 — Byte-identical rendered rows on the existing corpus, per runtime.** The Layer 2 differential run reports **0 rendered-row differences** between the pre-change reference and the post-change output across every artifact discovered by `CANONICAL_GLOBS`. Recorded at `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` naming the artifact count and the diff count (research-time reference: 968 artifacts).
> - [ ] **AC10 — Cross-runtime parity on the existing corpus.** The same corpus run compared runtime-to-runtime reports **0 differences** across artifacts containing exactly one `EXIT_CODE:` line. Artifacts containing two or more are excluded, and their count is recorded in the same evidence artifact together with the statement that the exclusion is attributable to the deferred duplicate-`EXIT_CODE` defect (research §3.2 measured 156 of 968 at research time).
> - [ ] **AC11 — No artifact carries the new key before the change.** Re-verification of assumption A1: `git grep -n -E "ExpectedExitCode|expected_exit|expectedExit|expected_nonzero|EXPECTED_EXIT" -- docs/features` returns matches only under `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/`. Recorded in the same evidence artifact.
> - [ ] **AC12 — `REQUIRED_FIELDS` is unchanged in both runtimes (Invariant D).** `git diff main -- scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` contains no changed line matching `REQUIRED_FIELDS`, and `git grep -n "REQUIRED_FIELDS" -- scripts/dev_tools/pr_context extensions/drm-copilot/src` shows the same three members in both files.
> - [ ] **AC13 — Result vocabulary is closed (Invariant C).** `git grep -n "unparseable" -- scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` shows the union still spelled exactly `pass | fail | unparseable`, and `git diff main -- scripts/dev_tools/pr_context/collector.py extensions/drm-copilot/src/lib/pr-context/collector-output.ts` shows no change to the record filters at `collector.py:147-149` and `collector-output.ts:98-101`.
> - [ ] **AC14 — `EXIT_CODE: SKIPPED` is still `unparseable` (Invariant F).** Verified by `test_skipped_exit_code_remains_unparseable` (Python) and `parseVerificationEvidenceMarkdown reports unparseable for EXIT_CODE SKIPPED` (TypeScript).
> - [ ] **AC15 — Unrecognized rows are still discarded.** An artifact carrying `Output Summary:` and a wrong-cased `expectedexitcode:` produces a record identical to the same artifact without those rows. Verified by `test_unrecognized_rows_are_ignored` (Python) and `parseVerificationEvidenceMarkdown ignores rows outside the accept-list` (TypeScript).
> - [ ] **AC16 — Rendering is conditional and additive.** The line `  - Expected EXIT_CODE: <int>` appears between the `EXIT_CODE` and `Normalized result` lines when and only when the parsed expectation is non-zero, and is absent when the key is omitted or written as `0`. Verified by the two new collector-level cases per runtime: the new Python sibling module of `tests/scripts/dev_tools/test_collect_pr_context_part4.py`, and the added cases in `describe("renderVerificationEvidenceSection")` at `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts:268`.
> - [ ] **AC17 — Rendering parity.** For the same artifact text, the Python and TypeScript rendered Verification sections are string-equal, including the conditional line. Verified by the corpus run of AC10 comparing rendered rows, not just normalized results.
> - [ ] **AC18 — No import edge to the atomic-executor QC path (Invariant G).** `git grep -n -E "qc_runner_expectations|pytest_expectations" -- scripts/dev_tools/pr_context extensions/drm-copilot/src/lib/pr-context` exits `1` with no output.
> - [ ] **AC19 — 500-line limit on both changed parser files.** `(Get-Content scripts/dev_tools/pr_context/verification_evidence.py).Count` and `(Get-Content extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts).Count` are each `<= 500`. The same check applied to `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` and to every new or modified test file is also `<= 500`.
> - [ ] **AC20 — Pre-existing over-limit files do not grow materially.** `git diff --numstat main -- scripts/dev_tools/pr_context/collector.py` shows at most 5 added lines, and `git diff --numstat main -- tests/scripts/dev_tools/test_collect_pr_context_part4.py` shows 0 added and 0 deleted lines.
> - [ ] **AC21 — Python coverage thresholds.** `poetry run pytest --cov --cov-branch --cov-report=term-missing` reports overall line coverage `>= 85%` and branch coverage `>= 75%`, and reports `scripts/dev_tools/pr_context/verification_evidence.py` with zero uncovered added or changed lines in the `Missing` column. No `omit` or `exclude` entry is added for any production file (`git diff main -- pyproject.toml` shows no change to `[tool.coverage.run]`).
> - [ ] **AC22 — TypeScript coverage thresholds.** From `extensions/drm-copilot/`, `npm run test:coverage` reports overall line coverage `>= 85%` and branch coverage `>= 75%`, with `src/lib/pr-context/verification-evidence.ts` showing no uncovered added or changed line.
> - [ ] **AC23 — Documentation is updated and the six copies are byte-identical.** The optional key appears in the schema block of `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (lines 106-112 region) and in all five siblings and mirrors. Verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` passing, and by `git grep -c "ExpectedExitCode" -- "*evidence-and-timestamp-conventions/SKILL.md"` reporting a match in six files.
> - [ ] **AC24 — Full toolchain pass in a single clean pass, both runtimes.** `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov --cov-branch --cov-report=term-missing` all succeed consecutively with no file modified by the formatter, and from `extensions/drm-copilot/`, `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit` all succeed consecutively. Recorded under `<FEATURE>/evidence/qa-gates/`.
> - [ ] **AC25 — Existing tests are unmodified and green.** `git diff --numstat main -- tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part4.py` shows zero changed lines, and the nine pre-existing tests in `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` and the four in `describe("renderVerificationEvidenceSection")` pass without edits to their bodies. An edit to any of them is evidence that Invariant A was broken.

## Discharge mapping (criterion -> plan task IDs)

| AC | Short title | Discharging plan tasks |
| --- | --- | --- |
| AC1 | Default-absent behavior, Python | [P3-T2], [P3-T11] |
| AC2 | Default-absent behavior, TypeScript | [P4-T10], [P4-T11] |
| AC3 | Layer 1 exhaustive default-path equivalence | [P2-T3], [P3-T3], [P4-T3], [P4-T10] |
| AC4 | Observed equals expected passes | [P1-T1], [P1-T3], [P3-T4], [P4-T10] |
| AC5 | Observed differs from a non-zero expectation fails | [P3-T5], [P4-T10] |
| AC6 | Non-integer expectation yields unparseable | [P2-T5], [P2-T6], [P3-T6], [P4-T5], [P4-T6], [P4-T10] |
| AC7 | Duplicate expectation key resolves first-wins | [P2-T4], [P3-T7], [P4-T4], [P4-T10] |
| AC8 | Cross-runtime parity over the eleven-shape table | [P3-T1], [P4-T9], [P4-T12] |
| AC9 | Byte-identical rendered rows on the existing corpus | [P7-T1], [P7-T2], [P7-T3], [P7-T6] |
| AC10 | Cross-runtime parity on the existing corpus | [P7-T4], [P7-T6] |
| AC11 | No artifact carries the new key before the change | [P0-T5], [P7-T5], [P7-T6] |
| AC12 | REQUIRED_FIELDS unchanged in both runtimes | [P2-T1], [P4-T1], [P7-T8] |
| AC13 | Result vocabulary is closed | [P5-T5], [P7-T9] |
| AC14 | EXIT_CODE SKIPPED still unparseable | [P3-T8], [P4-T10] |
| AC15 | Unrecognized rows still discarded | [P3-T9], [P4-T10] |
| AC16 | Rendering is conditional and additive | [P5-T1], [P5-T2], [P5-T3], [P5-T4] |
| AC17 | Rendering parity | [P7-T4], [P7-T6] |
| AC18 | No import edge to the atomic-executor QC path | [P7-T10] |
| AC19 | 500-line limit on both changed parser files | [P3-T11], [P4-T11], [P7-T11] |
| AC20 | Pre-existing over-limit files do not grow materially | [P5-T1], [P5-T6] |
| AC21 | Python coverage thresholds | [P7-T12], [P8-T4], [P9-T1] |
| AC22 | TypeScript coverage thresholds | [P8-T9], [P9-T1] |
| AC23 | Documentation updated and six copies byte-identical | [P6-T1], [P6-T2], [P6-T3], [P6-T4], [P6-T5], [P6-T6], [P6-T7] |
| AC24 | Full toolchain pass in a single clean pass | [P8-T1] through [P8-T10] |
| AC25 | Existing tests unmodified and green | [P5-T6], [P5-T7], [P8-T11] |

Every one of the 25 criteria maps to at least one `[P#-T#]` task in
`plan.2026-08-17T15-00.md`. Check-off of the criteria themselves occurs at [P9-T2]; the status
summary is written at [P9-T3].

Output Summary: 25 acceptance criteria extracted verbatim from `spec.md:479-503` and each mapped to
one or more discharging plan tasks. Count verified with
`grep -c '^- \[ \] \*\*AC' spec.md` = 25. `spec.md`, the research document, and `issue.md` were each
read in full. No requirement source other than `spec.md` is treated as an AC source under
`full-bug`.
