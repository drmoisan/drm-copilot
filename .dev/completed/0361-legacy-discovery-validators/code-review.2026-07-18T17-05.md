# Code Review — legacy-discovery-validators (#361) — Remediation Cycle 1 Exit Reaudit

- Timestamp: 2026-07-18T17-05
- Scope: remediation-cycle-1 delta (`d580d5a5..HEAD`) against the
  pre-remediation state, in the context of the full feature diff against
  `origin/epic/legacy-discovery-and-parity-integration`
  (merge-base `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`). This review does
  not re-litigate code-quality findings from `code-review.2026-07-18T16-04.md`
  that are unaffected by this cycle (e.g., the CLI umbrella, the profile and
  schema-artifact validators); it focuses on the three new test functions
  and confirms no other file changed.

## Files Changed This Cycle

```
tests/scripts/dev_tools/test_schema_loading.py   | 37 +++++++++++++++++++++++
docs/.../spec.md                                 | 16 ++++++++++-
docs/.../user-story.md                           |  2 +-
docs/.../remediation-plan.2026-07-18T16-04.md    | 39 ++++++++++++++++++++
+ 8 evidence Markdown artifacts under evidence/{remediation-baseline,qa-gates}/
```

No production source file (anything under `scripts/`) was changed. This was
independently confirmed via `git diff --stat d580d5a5..HEAD -- 'scripts/**'`
(empty output).

## New Test Functions — Branch-Coverage Claim Verification

Cross-referenced each new test against the current line numbers of
`scripts/dev_tools/schema_loading.py`:

1. **`test_load_schema_file_scheme_returns_parsed_content`** — writes a
   schema JSON file under `mem_fs_path`, builds a `file://` URI from its
   resolved path, calls `load_schema`, and asserts the returned dict equals
   the written content. This exercises `load_schema`'s `parsed.scheme ==
   "file"` branch (line 98), the `local_path.is_file()` true branch (line
   100), and the return statement (line 103) — the `file://` success path,
   previously entirely untested. **Confirmed accurate.**

2. **`test_load_schema_file_scheme_missing_raises_file_not_found`** — builds
   a `file://` URI pointing at a path under `mem_fs_path` that is never
   created, and asserts `load_schema` raises `FileNotFoundError`. This
   exercises the `file://`-scheme not-found branch at line 101
   (`raise FileNotFoundError(...)`), reached via the line-100 `is_file()`
   false branch. **Confirmed accurate.**

3. **`test_load_schema_relative_path_missing_raises_file_not_found`** —
   calls `load_schema` with a scheme-less URI and a `base_path` whose
   resolved sibling file is never created, and asserts `FileNotFoundError`.
   This exercises the scheme-less relative-path not-found branch at line 94
   (`raise FileNotFoundError(...)`), reached via the line-93 `is_file()`
   false branch — the fourth previously-missing branch identified in
   `remediation-inputs.2026-07-18T16-04.md`. **Confirmed accurate.**

All three tests were independently re-run
(`poetry run pytest --cov=scripts.dev_tools.schema_loading --cov-branch
--cov-report=term-missing tests/scripts/dev_tools/test_schema_loading.py`):
8 passed, `schema_loading.py` line coverage 85.71% / branch coverage 92.86%
in the scoped run, exactly matching the executor's evidence artifact and
the remediation plan's acceptance criteria for P1-T1 through P1-T3 and
P2-T1.

## Code-Quality Assessment of the New Tests

- **Structure (Arrange-Act-Assert):** all three tests follow AAA. Tests 2
  and 3 combine Act+Assert via `pytest.raises(...)` context managers,
  consistent with the file's five pre-existing tests and the repository's
  established style elsewhere in this test suite.
- **Naming and documentation:** each function name states the scenario and
  expected outcome; each has a one-line docstring. Consistent with
  `.claude/rules/general-unit-test.md` documentation requirements.
- **Determinism / isolation / no temp files:** all three use the `mem_fs_path`
  fixture (an in-memory `Path` fixture defined in `tests/conftest.py`), make
  no network calls, and share no mutable state with other tests. No
  `sleep`, no wall-clock reads, no real temporary files — compliant with the
  general-unit-test policy's determinism-infrastructure and
  no-temp-files rules.
- **Independence:** each test constructs its own `cache_dir`/`schema_path`/
  `source_path` values from a fresh `mem_fs_path` fixture instance; none
  depends on execution order or shared fixtures beyond `mem_fs_path` itself.
  Re-run and full-suite re-run both confirm no order-dependence issue (1720
  passed, deterministic).
- **Scope/isolation of the unit under test:** each test targets `load_schema`
  alone (or, for test 1, `load_schema` plus a same-module `cache_path`-free
  `file://` path), consistent with the file's stated purpose ("Cover
  `cache_path` and `load_schema` in isolation").
- **File size:** `test_schema_loading.py` is now 105 lines;
  `schema_loading.py` remains 117 lines. Both are far under the 500-line
  cap in `.claude/rules/general-code-change.md`.
- **No production code change:** `load_schema`'s logic is unchanged, as
  claimed. This is consistent with the root-cause analysis in
  `remediation-inputs.2026-07-18T16-04.md` (the branches were always
  logically correct; they were simply untested).

No code-quality defect was found in the three new test functions.

## Toolchain Reverification (scoped to changed files, independently re-run)

- Black (`--check`, scoped + full repo): PASS.
- Ruff (`check`, scoped + full repo): PASS, "All checks passed!" — this
  independently corroborates the executor's own noted mid-remediation
  self-correction (an `E501` in a docstring was fixed and Black was
  re-run before this final Ruff pass; the current state is clean).
  Note: the noted first `E501` violation was not itself observed
  first-hand (it was already fixed before this reaudit began), but the
  final state is independently confirmed clean, which is the state that
  matters for merge readiness.
- Pyright (scoped): PASS, "0 errors, 0 warnings, 0 informations".

## New Issues Introduced by This Remediation Cycle

None found. Specifically checked and cleared:

- No new production code — nothing to introduce a defect.
- No new domain-specific token (`taskmaster|outlook|vsto|tmw`) in the
  changed files — re-ran the domain-neutrality grep gate on both changed
  files; zero matches.
- No coverage regression anywhere (aggregate line/branch both moved up,
  not down; `validate_json.py`'s isolated figures are unchanged from the
  pre-remediation baseline).
- No new lint, format, or type error.
- No evidence-location violation (`validate_evidence_locations.py --root .`
  exits 0).

## Prior Non-Blocking Notes — Re-Confirmed, No Action Required

1. **`validate_json.py` isolated coverage (79.59% line / 57.89% branch),
   below the uniform threshold due to denominator shrinkage from the
   `schema_loading.py` extraction, not a same-line regression.**
   Re-verified via the independent full-suite JSON coverage read in this
   reaudit: the figures are byte-identical to those recorded in
   `remediation-inputs.2026-07-18T16-04.md` (79.59%/57.89%), confirming
   `validate_json.py` was untouched by this remediation cycle (also
   confirmed directly by the empty `git diff --stat ... -- 'scripts/**'`
   result). No action required; this remains a pre-existing,
   already-adjudicated non-blocking note for future-plan awareness, not a
   defect in this cycle.
2. **Cosmetic test-name drift** (`test_main_all_returns_one_with_aggregated_errors_when_nothing_conforms`
   vs. the plan's literal task text). Unaffected by this remediation cycle
   (the file in question was not touched). No action required.

## Overall Code-Review Verdict

**PASS.** The three new test functions are well-formed, correctly target
the branches they claim to close, and introduce no code-quality defect or
policy violation. No new issue was introduced by this remediation cycle.
