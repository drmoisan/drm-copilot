# Policy Audit — legacy-discovery-validators (#361)

- Timestamp: 2026-07-18T16-04
- Branch: `feature/legacy-discovery-validators-361`
- Base for diff: `origin/epic/legacy-discovery-and-parity-integration` (merge-base
  `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`), per instruction. Diff computed as
  `git diff f18c1c16f3eb111f0acef5eb3c46be1fb563aac0 HEAD`, NOT against `main`.
- Work mode: `full-feature` (per `issue.md` marker) — AC sources are `spec.md`
  and `user-story.md`.
- No `artifacts/pr_context.summary.txt` or `artifacts/pr_context.appendix.txt`
  exist in this worktree. In their absence, scope and evidence were derived
  directly from `git diff` against the resolved base branch and the feature
  folder documents, per the "Context Sources" fallback ("regenerate before
  proceeding" was not applicable — no orchestrator/PR-authoring tooling was
  invoked in this review session; the branch diff itself is authoritative and
  was independently recomputed and re-verified, satisfying the Scope
  Invariant).

## Rejected Scope Narrowing

None. No delegation prompt, plan text, or caller instruction in this session
attempted to narrow scope to a plan/task/phase subset, mark a language
"out of scope," or waive a toolchain/coverage check. This audit covers the
full branch diff listed below.

## Files in Branch Diff (excluding feature folder docs/evidence)

```
pyproject.toml
scripts/dev_tools/schema_loading.py                          (new)
scripts/dev_tools/validate_discovery_artifacts.py             (new)
scripts/dev_tools/validate_discovery_profile.py                (new)
scripts/dev_tools/validate_discovery_schema_artifacts.py       (new)
scripts/dev_tools/validate_json.py                              (modified)
tests/scripts/dev_tools/test_schema_loading.py                  (new)
tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py (new)
tests/scripts/dev_tools/test_validate_discovery_profile.py       (new)
tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py (new)
tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py (new)
tests/scripts/dev_tools/test_validate_json.py                    (modified, one line)
```

Only Python files are present in the branch diff. No TypeScript, PowerShell,
or C# files were changed; those language coverage gates are not applicable
(zero changed files for those languages) and are correctly omitted, not
narrowed.

## Evidence Location Compliance

All evidence for this plan is under
`docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/{baseline,regression-testing,qa-gates,other}/`,
matching the canonical `<FEATURE>/evidence/<kind>/` convention. `ran
validate_evidence_locations.py --root .` was not available as a named script
in this repository; a manual scan of the branch diff and the evidence folder
found no files written under `artifacts/baselines/`, `artifacts/qa/`,
`artifacts/evidence/`, or `artifacts/coverage/`. **No violation found.**

## Policy Reading Order Compliance

Confirmed via `evidence/other/phase0-instructions-read.md` (Timestamp
2026-07-18T09-00) that the executor read, in order: `CLAUDE.md`,
`.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
`.claude/rules/python.md`, `.claude/rules/python-suppressions.md`. This
matches the required reading order for a Python-only change. **PASS.**

## Design Decision Compliance (plan.2026-07-17T14-03.md, binding, lines 36-93)

| # | Decision | Verdict | Evidence |
|---|---|---|---|
| 1 | `all` subparser semantics: fixed order, succeeds on first empty-list validator, else aggregates `f"{artifact_type}: {message}"` | **PASS** | `validate_discovery_artifacts.py::_validate_all_text` (lines 120-149) implements exactly this; `_ARTIFACT_VALIDATORS` tuple order matches Decision 1's fixed order; `build_parser` gives `all` a single positional `path` (no directory scan / no content-based type inference). Verified by re-reading source and by `test_main_all_returns_zero_when_path_conforms_to_at_least_one_type` / `test_main_all_returns_one_with_aggregated_errors_when_nothing_conforms`. |
| 2 | No double error-prefixing: per-artifact `validate_<x>_text` returns bare errors; only `all`'s aggregation adds the `artifact_type:` prefix | **PASS** | `_validate_against_schema` (schema artifacts) and `validate_profile_text` (profile) both return bare, unprefixed strings. The prefix is added only inside `_validate_all_text`. Confirmed by direct source read. |
| 3 | Shared-extraction scope limited to `cache_path`/`load_schema`; `Draft202012Validator` error-formatting re-implemented independently, not extracted | **PASS** | `schema_loading.py` contains only `cache_path` and `load_schema`. The sort/format expression (`sorted(...); f"{list(err.path)}: {err.message}"`) is written independently in `validate_discovery_schema_artifacts.py::_validate_against_schema`, matching the moved-from expression in `validate_json.py::validate_file` without sharing code. `_collect_schema_errors` (the optional-jsonschema fallback) was left untouched in `validate_json.py` and has no discovery-validator counterpart, matching the decision's stated rationale. |
| 4 | Profile parser uses `yaml.safe_load` | **PASS** | `validate_discovery_profile.py::_parse_profile_mapping` calls `yaml.safe_load(text)` inside `try/except yaml.YAMLError`. |
| 5 | Single placeholder required field `legacy_source_path` | **PASS** | `_PLACEHOLDER_REQUIRED_FIELDS: tuple[str, ...] = ("legacy_source_path",)` — exactly one element, with the required `# TODO(#9001)` comment. |
| 6 | Per-schema validators resolve schemas solely via the artifact's own `$schema` field, no hardcoded schema layout; `load_schema` called without `base_path` (only explicit-scheme URIs resolve) | **PASS** | `_extract_schema_uri` reads only `data.get("$schema")`; `_validate_against_schema` calls `load_schema(schema_uri, cache_dir)` with no `base_path`, so a scheme-less `$schema` value raises `ValueError` (caught and reported as `"schema resolution failed (...)"`, never an uncaught exception). Grep confirms no `schemas/v` or version-string literal in any new module (only a docstring reference to the prohibited pattern, describing what is *not* done). |

## Coverage Verification (mandatory, per-language)

**Language with changed files: Python.** Coverage artifact:
`artifacts/python/lcov.info` (path exists per the Coverage Artifact table).
Repo-wide/`.claude/rules/quality-tiers.md` thresholds apply uniformly: line
>= 85%, branch >= 75%, across new files, modified files, and repo-wide, with
no regression on changed lines.

Independent re-verification performed in this review session (not the
executor's report taken on faith): ran
`poetry run pytest --cov --cov-branch --cov-report=json:...` for the full
suite at HEAD. Result: **1717 passed**, aggregate **88.21% line / 79.02%
branch** — this exactly reproduces the executor's `final-qc-pytest` artifact
figures (`10005/11342` statements, `3352/4242` branches). A second isolated
run against `tests/scripts/dev_tools/test_validate_json.py` at the merge-base
commit (via a temporary `git worktree`) gave baseline-isolated
`validate_json.py` coverage of 79.67% line / 61.54% branch; the same isolated
run at HEAD gives 79.59% line / 57.89% branch.

### Repo-wide (Python)

**PASS.** 88.21% line (>= 85%), 79.02% branch (>= 75%). No regression against
the P0-T10 baseline (88.07%/78.87%) — both figures improved.

### New files (Python)

Per-file coverage, independently computed from the full-suite coverage JSON
(not the executor's aggregated new-code figure alone):

| New file | Line % | Branch % | Verdict |
|---|---|---|---|
| `validate_discovery_profile.py` | 100.00% | 100.00% | PASS |
| `validate_discovery_schema_artifacts.py` | 100.00% | 100.00% | PASS |
| `validate_discovery_artifacts.py` | 98.36% | 100.00% | PASS |
| `schema_loading.py` | 85.71% | **71.43%** | **FAIL** (branch < 75%) |

**Aggregate across the four new files** (165 statements, 44 branches):
93.33% line / 88.64% branch — exceeds threshold as an aggregate, matching the
executor's `final-qc-pytest-new-code` artifact figures exactly (independently
reproduced from `artifacts/python/lcov.info`'s per-file `LF/LH/BRF/BRH`
totals: `154/165` lines, `39/44` branches).

**Finding (FAIL, file-level):** `schema_loading.py` is a new file. Its branch
coverage (71.43%, 10/14) is below the uniform 75% threshold, and this shortfall
is concentrated entirely in one untested code path: the `file://` scheme
branch (`load_schema` lines 98-103) is **never exercised by any test in the
repository** (not the new `test_schema_loading.py`, and not the pre-existing
`test_validate_json.py`), and the `FileNotFoundError` branches for both the
scheme-less-relative-path case (line 94) and the `file://` case (line 101) are
likewise untested. The evidence artifact
`evidence/qa-gates/final-qc-pytest-new-code.2026-07-18T10-42.md` states
"the full-suite run (P7-T4) confirms `schema_loading.py` reaches 82% line
coverage" — this figure (81.63%, `coverage.py`'s blended `percent_covered`
combining statement and branch coverage) is mislabeled as "line coverage" in
that artifact; the actual pure line coverage is 85.71%, and the branch
coverage (71.43%, not stated anywhere in the evidence) is the figure that
actually fails the threshold. See `code-review` and `remediation-inputs` for
detail and a concrete fix.

This finding is scoped narrowly: it does not indicate incorrect production
behavior, only an untested branch inherited from `validate_json.py`'s
pre-existing, equally-untested `_load_schema` logic (verified: the `file://`
branch was already untested before this feature's extraction — this is not a
coverage regression introduced by new logic, but it is newly subject to the
new-file coverage gate because the code now lives in a brand-new file).

### Modified files (Python)

`validate_json.py` is the only modified production file. Isolated
before/after comparison (its own test file only, at merge-base vs. HEAD):

- Line: 79.67% -> 79.59% (baseline was already below the 80%
  modified-file floor cited in this review's verification procedure, and
  below the general 85% uniform threshold; the feature did not newly cause
  the sub-threshold state).
- Branch: 61.54% -> 57.89% (same pre-existing sub-threshold condition).

Both specific changed lines (`_cache_path`'s and `_load_schema`'s new
one-line delegating bodies, at lines 78 and 132) are confirmed **covered**
(`DA:78,1`, `DA:132,1` in the regenerated lcov data) — so the "no regression on
changed lines" requirement (general-unit-test.md) is satisfied at the
changed-line granularity. The small file-level percentage decrease is a
denominator artifact of the extraction (previously-covered branches moved out
of the file, shifting the remaining, already-uncovered
`_collect_schema_errors` fallback logic — untouched by this feature — into a
larger share of the file's total). **Verdict: PASS at the changed-line
level; the file's own aggregate percentage remains below the uniform
threshold, but this predates the feature and is not a caused regression.**
Flagged as a disclosure gap in `code-review`, not a blocking finding.

### Coverage Verdict Summary

- Repo-wide: **PASS**
- New files: **FAIL** (`schema_loading.py` branch coverage 71.43% < 75%)
- Modified files: **PASS** (no regression on changed lines; pre-existing
  file-level shortfall predates this feature)

## Domain-Neutrality Gate (independently re-run)

Re-ran the exact P6-T1 command against the same ten files:

```
rg -i -l "TaskMaster|TMW|Outlook|VSTO|task-management|email" scripts/dev_tools/schema_loading.py scripts/dev_tools/validate_discovery_profile.py scripts/dev_tools/validate_discovery_schema_artifacts.py scripts/dev_tools/validate_discovery_artifacts.py scripts/dev_tools/validate_json.py tests/scripts/dev_tools/test_schema_loading.py tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py
```

Result: `EXIT: 1` (ripgrep convention: no matches). **PASS**, including the
additional `email` token not present in the plan's literal P6-T1 command but
required by spec.md/user-story.md's domain-neutrality wording.

## Toolchain Re-Verification (independently re-run, not taken on faith)

| Stage | Executor's claim | Independently re-run result | Verdict |
|---|---|---|---|
| Black (`black --check .`) | EXIT 0, 282 files unchanged | EXIT 0, "282 files would be left unchanged" | **PASS** |
| Ruff (`ruff check .`) | EXIT 0, all checks passed | EXIT 0, "All checks passed!" | **PASS** |
| Pyright (`pyright`) | EXIT 0, 0 errors/warnings | EXIT 0, "0 errors, 0 warnings, 0 informations" | **PASS** |
| Pytest (full) | 1717 passed, 88.21%/79.02% | 1717 passed, 88.21%/79.02% (recomputed from JSON) | **PASS** |

Architecture-boundary, contract/schema-compat, and integration-test stages of
the general 7-stage loop have no configured Python tooling in this repository
(no import-linter/NetArchTest-equivalent, no oasdiff-equivalent found in
`pyproject.toml`); `.claude/rules/python.md`'s language-specific toolchain
(format -> lint -> type-check -> test) is the applicable subset and was
followed in full. This is a pre-existing repository condition, not introduced
by this feature.

## Suppression Policy Compliance

No `# noqa` or `# type: ignore` suppressions were added in this diff (grep
confirms zero occurrences of either token across the new/modified files).
The one pre-existing `# noqa: S310` in `validate_json.py`/`schema_loading.py`
was carried over verbatim from the extraction (not newly added) and matches
the pre-authorized S310 pattern. The `__all__ = ["_cache_path"]` addition in
`validate_json.py` and `__all__ = ["load_schema"]` in
`validate_discovery_artifacts.py` are not suppression comments (no `# noqa`
or `# type: ignore`); they are legitimate declarations of intentionally
retained public/re-exported names, consistent with fixing the Pyright
`reportUnusedFunction`/`reportUnusedImport` root cause rather than suppressing
it. **PASS**, no suppression-policy violation.

## File Size Limit

All ten new/modified production and test files are well under the 500-line
cap (largest is `validate_discovery_artifacts.py` at 258 lines). **PASS.**

## Overall Policy-Audit Verdict

**PARTIAL.** All binding Design Decisions, domain-neutrality, suppression
policy, file-size policy, and the mandatory toolchain (format/lint/type-check/
test) are fully compliant and independently re-verified. The sole compliance
gap is the new-file coverage threshold for `schema_loading.py`
(branch coverage 71.43% < 75%), paired with an inaccurate "82% line coverage"
characterization in the P7-T5 evidence artifact. See `remediation-inputs` for
the specific fix.
