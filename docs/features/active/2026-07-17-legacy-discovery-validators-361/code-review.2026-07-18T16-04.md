# Code Review — legacy-discovery-validators (#361)

- Timestamp: 2026-07-18T16-04
- Scope: full branch diff, `feature/legacy-discovery-validators-361` vs.
  `origin/epic/legacy-discovery-and-parity-integration` (merge-base
  `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`).

## Summary

The implementation is small, well-factored, and closely follows the
repository's canonical validator pattern
(`validate_orchestration_artifacts.py`) and the plan's six binding Design
Decisions without deviation, except for two disclosed, narrow,
toolchain-forced fixes (documented below). Code is Pyright-strict clean,
Black/Ruff clean, and the new modules are each single-purpose and well under
the 500-line cap. The main quality gap is a coverage shortfall in one new
file (`schema_loading.py`) and a mislabeled percentage in one evidence
artifact — both addressed in `remediation-inputs`.

## Strengths

- **Separation of concerns.** `schema_loading.py` (pure I/O/caching seam),
  `validate_discovery_profile.py` (pure profile parsing/checks),
  `validate_discovery_schema_artifacts.py` (pure schema validation), and
  `validate_discovery_artifacts.py` (CLI-only, no validation logic) cleanly
  separate transformation logic from I/O and CLI glue, matching
  general-code-change.md's separation-of-concerns principle.
- **Verbatim extraction, no behavior drift.** `cache_path`/`load_schema` in
  `schema_loading.py` are byte-for-byte equivalent to the moved-from logic in
  `validate_json.py` (confirmed by diff); `validate_json.py`'s `_cache_path`
  and `_load_schema` remain as thin one-line delegating wrappers preserving
  their original signatures, so every existing caller (including tests) keeps
  working without change to its own logic.
- **Consistent, bare error-string contract.** Every `validate_<artifact>_text`
  function returns `list[str]` with no artifact-type prefix, no raised
  exceptions for malformed/missing input, and predictable error text
  (`"Missing required field: ...."`, `"invalid JSON (...)"`,
  `"schema resolution failed (...)"`, `"[...]: ... is a required property"`),
  matching Design Decision 2 and the canonical pattern from
  `validate_orchestration_artifacts.py`.
- **Isolated upstream seams.** `_check_required_profile_fields` (the #9001
  seam) and `_extract_schema_uri` (the #9002 seam) are each a single small
  function with a `# TODO(#9001)` marker where applicable, exactly matching
  spec.md's stated intent to isolate the seams most likely to change once the
  upstream contracts (#9001/#9002) finalize.
- **Honest, well-documented deviations.** Both toolchain-forced deviations
  from the plan's literal task text (the `test_validate_json.py` monkeypatch
  retarget, and the `__all__` addition to silence Pyright's
  `reportUnusedFunction`) are disclosed in
  `evidence/regression-testing/validate-json-regression.2026-07-18T09-30.md`
  and `evidence/qa-gates/final-qc-rerun-log.2026-07-18T10-45.md` with a clear
  rationale, rather than being silently made. Independently confirmed both are
  narrow and do not change tested behavior — see Verification below.
- **Typed-adapter pattern for a partially-typed third party.** `
  _as_schema_validator` in `validate_discovery_schema_artifacts.py` isolates
  `jsonschema`'s partially-typed concrete validator class behind its own
  fully-typed `Validator` protocol, following `.claude/rules/python.md`'s
  "wrap untyped libraries behind small typed adapters" convention rather than
  reaching for a suppression.

## Verification Performed (independent, not taken on faith)

- Re-ran `black --check .`, `ruff check .`, `poetry run pyright`, and
  `poetry run pytest --cov --cov-branch --cov-report=json:...` at HEAD.
  Results reproduce the executor's claims exactly: 0/0/0/1717-passed,
  88.21% line / 79.02% branch aggregate (10005/11342 lines, 3352/4242
  branches).
- Re-ran the domain-neutrality grep gate with an additional `email` token
  (present in spec.md's wording but not in the plan's literal P6-T1 command);
  still zero matches.
- Diffed `validate_json.py` against the merge-base commit line-by-line;
  confirmed the change is exactly the claimed import/`__all__`/two-line-body
  edit, with the `_collect_schema_errors` fallback function and all other
  logic untouched.
- Diffed `test_validate_json.py`; confirmed the only change is retargeting one
  `monkeypatch.setattr` call from `val.urllib.request.urlopen` to
  `schema_loading.urllib.request.urlopen`, with no change to any assertion,
  input, or the test's intent. Ran the file in isolation (27 passed) both at
  the merge-base commit and at HEAD.
- Used a temporary `git worktree` at the merge-base commit to compute
  `validate_json.py`'s own isolated coverage before the feature
  (79.67%/61.54%) versus after (79.59%/57.89%), to determine whether the
  small file-level dip represents a real regression on changed lines (it does
  not — see `policy-audit`).
- Computed per-file coverage for all four new modules directly from
  `artifacts/python/lcov.info`'s `LF/LH/BRF/BRH` fields, cross-checked against
  `coverage.py`'s JSON summary. This is what surfaced the
  `schema_loading.py` branch-coverage shortfall (see Findings below).

## Findings

### Finding 1 — Coverage gap: `schema_loading.py`'s `file://` scheme branch is entirely untested (Medium)

`load_schema`'s `file://` branch (lines 98-103) and the `FileNotFoundError`
branches for both the scheme-less-relative-path case (line 94) and the
`file://` case (line 101) are not exercised by any test in the repository —
neither the new `test_schema_loading.py` (which tests the no-scheme-relative,
http-cache-hit, unsupported-scheme, and missing-scheme cases, but not
`file://` or either `FileNotFoundError` path) nor the pre-existing
`test_validate_json.py` (which tests the http-fetch-and-cache path and the
no-scheme-relative path, but likewise never exercises `file://`). This yields
71.43% branch coverage (10/14) for a new file, below the uniform 75%
threshold.

This branch was already untested before this feature (verified: the same gap
existed in `validate_json.py::_load_schema` at the merge-base commit), so this
is an inherited gap rather than new incorrect logic — but the code now lives
in a brand-new file, subject to the new-file coverage gate, and the gap
represents genuinely unverified behavior (`load_schema` resolving a `file://`
URI has never been exercised by a test, for either module, at any point in
this repository's history that this review could inspect).

**Recommendation:** add two tests to `test_schema_loading.py`:
1. `test_load_schema_from_file_scheme_uri` — write a schema file via
   `mem_fs_path`, call
   `schema_loading.load_schema(f"file://{schema_path.as_posix()}", cache_dir)`,
   assert the parsed content is returned.
2. `test_load_schema_file_scheme_missing_file` — assert
   `schema_loading.load_schema("file:///nonexistent/schema.json", cache_dir)`
   raises `FileNotFoundError`.

This closes the branch-coverage gap for the new file without touching
production logic.

### Finding 2 — Evidence artifact mislabels a blended metric as "line coverage" (Low, documentation-only)

`evidence/qa-gates/final-qc-pytest-new-code.2026-07-18T10-42.md` states:
"the full-suite run (P7-T4) confirms `schema_loading.py` reaches 82% line
coverage." The figure 82% (81.63% precisely) is `coverage.py`'s combined
`percent_covered` metric (which blends statement and branch coverage into one
number), not the pure line-coverage percentage. The actual pure line coverage
for `schema_loading.py` in the full-suite run is 85.71% (30/35 statements);
the branch coverage — never stated in that artifact — is 71.43% (10/14
branches), which is the figure that actually falls below threshold. The
artifact's own stated rationale for using the blended figure elsewhere (P0-T10
and P7-T4's `Output Summary:` text) is that the blended "Cover" column "does
not itself expose the two values separately required by this task" — the same
caution was not applied to this specific per-file aside. This is a
documentation-accuracy issue, not a functional defect, but it obscured the
real branch-coverage shortfall (Finding 1) from a reader of the evidence
alone.

**Recommendation:** correct the sentence to state both figures precisely
(85.71% line / 71.43% branch) once Finding 1's remediation lands and the
numbers change; do not reuse the blended `percent_covered` figure as "line
coverage" in future evidence.

### Finding 3 — `validate_json.py`'s own file-level coverage remains (and slightly worsens) below the uniform threshold (Low, disclosure gap, not a defect)

`validate_json.py`, a modified file, already had sub-threshold coverage before
this feature (79.67% line / 61.54% branch, isolated to its own tests at the
merge-base commit) due to the untested optional-jsonschema-absent fallback
path (`_collect_schema_errors`), which this feature does not touch. After the
extraction, the same isolated measurement is 79.59% line / 57.89% branch — a
small further dip, caused entirely by denominator shrinkage (previously
well-tested branches moved out of the file into `schema_loading.py`, leaving
the already-untested fallback logic as a larger share of the remainder), not
by any newly-uncovered line. Both of the feature's actual changed lines in
this file (`_cache_path`'s and `_load_schema`'s new one-line delegating
bodies) are confirmed covered.

**Recommendation:** no code change required. Future plans that touch
`validate_json.py` should consider tracking file-level coverage deltas (not
just pass/fail of the pre-existing test file) in evidence, so a reviewer does
not need to reconstruct this via a temporary worktree, as this review did.

### Non-Findings (explicitly checked, no issue)

- No suppression comments (`# noqa`, `# type: ignore`) were added anywhere in
  this diff.
- No colocated tests in `scripts/dev_tools/`; all five new test files are
  correctly placed under `tests/scripts/dev_tools/`, mirroring the source
  tree.
- No hardcoded `schemas/vN` layout, version string, or domain-specific
  identifier anywhere in the new modules (independently re-verified via grep,
  not just the plan's own gate).
- `pyproject.toml`'s nine new console-script entries all target the correct
  `main_<artifact>`/`main` functions and were independently confirmed to
  parse as valid TOML.
- The `all` CLI subcommand's fixed dispatch order, single-empty-list success
  rule, and per-type-prefixed aggregated failure output were all
  independently exercised via direct code read plus the existing dispatch
  tests; behavior matches Design Decision 1 exactly.

## Naming Note (cosmetic, non-blocking)

The plan's task text (P4-T15) names the test
`test_main_all_returns_one_with_aggregated_per_type_errors_when_path_conforms_to_none`;
the committed test is named
`test_main_all_returns_one_with_aggregated_errors_when_nothing_conforms`. Both
names accurately describe the same verified behavior; this is a cosmetic
naming drift from the plan's literal text, not a functional gap, and does not
require remediation.
