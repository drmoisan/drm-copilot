# Remediation Inputs — legacy-discovery-validators (#361)

- Timestamp: 2026-07-18T16-04
- Source review artifacts:
  - `docs/features/active/2026-07-17-legacy-discovery-validators-361/policy-audit.2026-07-18T16-04.md`
  - `docs/features/active/2026-07-17-legacy-discovery-validators-361/code-review.2026-07-18T16-04.md`
  - `docs/features/active/2026-07-17-legacy-discovery-validators-361/feature-audit.2026-07-18T16-04.md`

## Remediation-Required Finding 1 (Blocking against the uniform coverage gate)

**What:** `scripts/dev_tools/schema_loading.py` (a new file introduced by this
feature) has branch coverage of 71.43% (10/14 branches), below the uniform
75% threshold defined in `.claude/rules/quality-tiers.md` and restated
verbatim in this feature's own `spec.md` Definition of Done ("... on all
new/changed files"). Line coverage for the same file is 85.71%, which passes
but only marginally.

**Root cause:** `load_schema`'s `file://` scheme branch (source lines 98-103)
is never exercised by any test — not `tests/scripts/dev_tools/test_schema_loading.py`
(new) and not `tests/scripts/dev_tools/test_validate_json.py` (pre-existing,
which exercises the same logic via `validate_json.py`'s thin wrapper for the
http-fetch-and-cache and no-scheme-relative-path cases only). Two
`FileNotFoundError`-raising branches are also untested: the scheme-less
relative-path case (line 94) and the `file://` case (line 101).

**Verification performed:** confirmed by direct inspection of
`artifacts/python/lcov.info` and `coverage.py`'s JSON summary after an
independently-run `poetry run pytest --cov --cov-branch
--cov-report=json:...` full-suite execution (1717 passed; aggregate
88.21% line / 79.02% branch, matching the executor's own report exactly).
`schema_loading.py`'s per-file summary from that run:
`num_statements=35, covered_lines=30 (85.71%)`,
`num_branches=14, covered_branches=10 (71.43%)`.

**Required fix:** add to `tests/scripts/dev_tools/test_schema_loading.py`:

1. A test exercising `load_schema` with a `file://` URI that resolves to an
   existing schema file (using the `mem_fs_path` fixture, consistent with the
   file's existing no-network-fetch, no-real-temp-file test style), asserting
   the parsed schema content is returned. This covers source lines 99-100,
   103 and one branch edge of line 98's scheme dispatch.
2. A test exercising `load_schema` with a `file://` URI pointing at a
   non-existent path, asserting `FileNotFoundError` is raised. This covers
   line 101 and its branch edge.
3. (Optional, for full branch closure) A test exercising the scheme-less,
   `base_path`-supplied case where the resolved relative path does not exist,
   asserting `FileNotFoundError` is raised, to cover line 94's branch edge —
   the fourth currently-missing branch (`BRDA:93,0,jump to line 94,0`).

No production code change is required; `load_schema`'s logic itself is
correct (it is a verbatim, unmodified move of pre-existing, already-reviewed
logic from `validate_json.py`).

**Acceptance for closure:** re-run
`poetry run pytest --cov=scripts.dev_tools.schema_loading --cov-branch
--cov-report=term-missing tests/scripts/dev_tools/test_schema_loading.py` and
confirm `schema_loading.py` reaches >= 75% branch coverage (ideally 100%,
since all four currently-missing branches are addressable by the three tests
above) with no reduction in any other file's coverage. Re-check the
`spec.md` Definition-of-Done item and `user-story.md` Acceptance Criteria
item this review left unchecked (both flagged `**Gap (feature-review
2026-07-18T16-04)**`), and check them off once the new tests confirm the
threshold is met.

## Remediation-Required Finding 2 (Non-blocking, documentation accuracy)

**What:**
`docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pytest-new-code.2026-07-18T10-42.md`
states "`schema_loading.py` alone shows ... schema_loading.py reaches 82% line
coverage" in its full-suite cross-reference note. This 82% (81.63% precise)
figure is `coverage.py`'s blended `percent_covered` metric (statements +
branches combined), not pure line coverage. The actual pure line coverage is
85.71%; the branch coverage (71.43%, the figure that actually fails
threshold) is not stated in that artifact at all.

**Required fix:** once Finding 1's tests are added and the toolchain is
re-run, add a corrected evidence artifact (new timestamp) restating
`schema_loading.py`'s per-file line and branch percentages precisely and
separately, avoiding the blended `percent_covered` figure. This is a
documentation correction only; no gate re-run beyond Finding 1's is required
beyond what Finding 1 already mandates.

## Non-Blocking Notes (no remediation required, listed for completeness)

- `validate_json.py`'s own isolated file-level coverage (79.59% line / 57.89%
  branch) remains below the uniform threshold, and dipped slightly from its
  pre-feature baseline (79.67%/61.54%) due to denominator shrinkage from the
  extraction — not from any newly-uncovered line. Both of this feature's
  actual changed lines in that file are covered. No action required; noted in
  `code-review.2026-07-18T16-04.md` Finding 3 for future-plan awareness only.
- Cosmetic test-name drift from the plan's literal P4-T15 task text (function
  named `test_main_all_returns_one_with_aggregated_errors_when_nothing_conforms`
  instead of the plan's
  `test_main_all_returns_one_with_aggregated_per_type_errors_when_path_conforms_to_none`).
  No action required.

## Overall Remediation Scope

Narrow: one new test file gets two-to-three additional test functions (no
production code change), plus one evidence-artifact correction. Estimated
effort: small (well under an hour). No design decision, CLI contract, or
public API changes are required.
