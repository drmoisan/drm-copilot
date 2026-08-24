# Policy Compliance Audit: legacy-discovery-reports (Issue #368)

**Audit Date:** 2026-07-18
**Code Under Test:** `scripts/dev_tools/discovery/io.py`, `scripts/dev_tools/discovery/rendering.py`,
`scripts/dev_tools/discovery/coverage_report.py`, `scripts/dev_tools/discovery/parity_report.py`,
`scripts/dev_tools/discovery/completion_report.py`, `tests/scripts/dev_tools/discovery/test_io.py`,
`tests/scripts/dev_tools/discovery/test_rendering.py`,
`tests/scripts/dev_tools/discovery/test_coverage_report.py`,
`tests/scripts/dev_tools/discovery/test_parity_report.py`,
`tests/scripts/dev_tools/discovery/test_completion_report.py`, `pyproject.toml`
(3 new `[tool.poetry.scripts]` entries).

**Base branch:** `epic/legacy-discovery-and-parity-integration` (resolved
`origin/epic/legacy-discovery-and-parity-integration @ 3a4985fa904da7b5925091b393f9551c874ab006`)
**Head:** `feature/legacy-discovery-reports-368 @ 20c26abd85dd2a58b28d77578edd7bc2fc403f8c`
**Merge-base:** `e395efb7cf55953a93088964f10edc4d9dede404`
**Diff range verified:** `git diff --stat e395efb7c..20c26abd8` — 26 files changed,
1950 insertions(+), 60 deletions(-) (11 files under `scripts/dev_tools/discovery/` +
`tests/scripts/dev_tools/discovery/` + `pyproject.toml`; 15 docs/evidence files under
`docs/features/active/2026-07-17-legacy-discovery-reports-368/`). Confirmed by direct
`git diff --stat` re-run during this audit, not taken from the PR context artifact alone.

**Coverage Metrics by Language:**

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|----------|--------------|-------|-------------|-------------------|---------------------|-------------------|
| Python | 10 code files (5 production + 5 test) + `pyproject.toml` | 30 new (1869 total) | PASS 1869 passed, 0 failed | 88.87% lines, 79.51% branch | 88.95% lines, 79.60% branch | io.py 100%/100%, rendering.py 100%/100%, coverage_report.py 95.0%/100%, parity_report.py 95.0%/100%, completion_report.py 92.16%/100% |

### Coverage Evidence Checklist

- Python baseline coverage artifact:
  `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/baseline/py-test.2026-07-18T21-19.md`
- Python post-change coverage artifact:
  `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/qa-gates/final-py-test.2026-07-18T22-25.md`
- Canonical repo-wide coverage artifact: `artifacts/python/lcov.info` — inspected directly during
  this audit (parsed `SF:`/`LH:`/`LF:`/`BRH:`/`BRF:` records). Repo-wide totals computed from this
  artifact: 88.95% line, 79.60% branch — matches the evidence file's claimed figures exactly.
  Per-file figures for all five new production modules were independently recomputed from the
  same `lcov.info` and matched the evidence file exactly: `io.py` 100%/100%,
  `rendering.py` 100%/100% (13/13 lines, 2/2 branches), `coverage_report.py` 95.00%/100%
  (38/40, 4/4), `parity_report.py` 95.00%/100% (38/40, 4/4), `completion_report.py` 92.16%/100%
  (47/51, 6/6).
- PowerShell / TypeScript / C#: N/A — zero changed files in this branch diff for these languages
  (confirmed by `git diff --stat` above: only Python source/test files and Markdown/TOML changed).
- Per-language comparison summary: `evidence/qa-gates/coverage-delta.2026-07-18T22-28.md`,
  independently reconciled against `artifacts/python/lcov.info` above.

**Non-negotiable verdict rule:** satisfied — numeric baseline and post-change coverage metrics are
present for Python, the only language in scope, plus per-new-file coverage.

**Fail-closed rule:** satisfied — all required baseline, QA-gate, and coverage-comparison
artifacts are present under the canonical `evidence/` location and were independently verified
against the raw coverage artifact rather than taken on faith.

**Evidence rule:** No evidence was synthesized or backfilled from memory; all coverage figures
above were recomputed directly from `artifacts/python/lcov.info` during this audit.

---

## Rejected Scope Narrowing

No caller instruction in this session attempted to narrow the audit scope to a plan subset, a
task/phase subset, a subset of changed files, or to mark any in-scope language as
"plan scope only" / "out of scope" / "informational only." The delegating prompt's contextual
notes (binding correction for the validator module, evidence-artifact pointers, coverage-delta
pointer) were treated as pointers to verify independently, not as instructions to narrow scope,
and this audit re-derived the full base-branch diff (`git diff --stat` against the resolved
merge-base) rather than accepting the caller's file list at face value. Nothing to record here.

## Evidence Location Compliance

- `git diff --name-only e395efb7c..20c26abd8` scanned for any path under `artifacts/baselines/`,
  `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: **zero matches**.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — **EXIT_CODE 0**,
  no violations reported.
- All evidence for this feature is under the canonical
  `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/{baseline,qa-gates}/`
  paths. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` events were necessary.

---

## Executive Summary

This feature adds a new, additive `scripts/dev_tools/discovery/` reporting subpackage (three
report renderers, a shared I/O boundary module, and a shared rendering-primitives module) plus
mirrored tests, and three new Poetry console-script entries. No existing module was modified. The
toolchain (Black, Ruff, Pyright, Pytest+coverage) passes cleanly on the full repository, including
the new files. Coverage improved slightly relative to baseline and both uniform thresholds
(line >= 85%, branch >= 75%) are met repo-wide and on every new file (all new-file line coverage
is >= 92%, comfortably above the 90% new-file bar this workflow applies). Determinism, I/O
isolation, and domain-neutrality claims were independently verified by direct code inspection and
by running the CLI end-to-end twice on identical input, confirming byte-identical output.

**Policy documents evaluated:**
- [OK] `.github/instructions/general-code-change.instructions.md` / `.claude/rules/general-code-change.md`
- [OK] `.github/instructions/general-unit-test.instructions.md` / `.claude/rules/general-unit-test.md`

**Language-specific policies evaluated:**
- [OK] `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- N/A PowerShell (zero changed files)
- N/A TypeScript (zero changed files)
- N/A C# (zero changed files)

**Temporary artifacts cleanup:**
- [OK] No temporary/one-time scripts were left in the diff. Scratch smoke-test files this audit
  created during CLI verification (`scratch_ledger.json`, `scratch_report1.json`,
  `scratch_report2.json`, a scratchpad `smoke_test.py`) were created outside the diff (working
  tree scratch files under the repo root during the audit session, and a temp-directory script)
  and deleted before this audit concluded; none were committed.

---

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Independence** | PASS | Every test file uses `monkeypatch` fixtures scoped per-test (function scope, pytest default); no shared module-level mutable state. Fake validators (`_passing_validator`/`_failing_validator`) are pure functions with no shared state. Verified by reading all five new test files in full. |
| **Isolation** | PASS | Each test targets one behavior: sort/render primitives (`test_rendering.py`), I/O wrappers (`test_io.py`), and per-report pipeline/CLI behavior (`test_coverage_report.py`, `test_parity_report.py`, `test_completion_report.py`). |
| **Fast Execution** | PASS | `poetry run pytest tests/scripts/dev_tools/discovery/test_completion_report.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_parity_report.py tests/scripts/dev_tools/discovery/test_io.py tests/scripts/dev_tools/discovery/test_rendering.py -q` re-run during this audit: 30 passed in 0.06s. |
| **Determinism** | PASS | No `sleep`, `datetime`, `time.*`, `random`, or `uuid` usage found in the five new production modules (`grep -n "datetime\|time\.\|random\|uuid"` — only docstring prose mentions). Two explicit "render twice, assert equal" tests exist per report type plus `test_rendering.py`. This audit additionally ran the real `coverage_report.main()` CLI twice against identical input with an injected passing validator and confirmed byte-identical file output via `diff`. |
| **Readability & Maintainability** | PASS | Descriptive `test_<behavior>` names, Arrange/Act/Assert structure, module/function docstrings explaining scenario and expected outcome throughout. |

### 1.2 Coverage and Scenarios

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Baseline Coverage Documented** | PASS | `evidence/baseline/py-test.2026-07-18T21-19.md`: 88.87% line, 79.51% branch, `poetry run pytest --cov --cov-branch --cov-report=term-missing`, captured before any discovery-report file was added. |
| **No Coverage Regression** | PASS | Baseline 88.87%/79.51% -> post-change 88.95%/79.60% (+0.08pp / +0.09pp), independently recomputed from `artifacts/python/lcov.info` during this audit and matching `evidence/qa-gates/coverage-delta.2026-07-18T22-28.md` exactly. No existing module was modified (this feature is additive-only per `git diff --stat`), so no changed-line regression is possible. |
| **New Code Coverage >= 90% (per this workflow's uniform new-file bar)** | PASS | All five new production modules independently recomputed from `artifacts/python/lcov.info`: `io.py` 100.00%/100.00%, `rendering.py` 100.00%/100.00%, `coverage_report.py` 95.00%/100.00%, `parity_report.py` 95.00%/100.00%, `completion_report.py` 92.16%/100.00%. All exceed both the 85%/75% uniform tier floor and the 90% new-file bar for line coverage. |
| **Comprehensive Coverage** | PASS | Every public function in the five new modules is exercised: `sort_rows`/`render_pretty_json` (id-sort, fallback-sort, partial-id fallback, exact literal output, determinism); `parse_*`/`build_*_rows`/`render_*_report` per report (positive, empty-artifact edge case); `main()` per report (success, validation failure, stdout vs `--output` path). Uncovered lines in `coverage_report.py`/`parity_report.py`/`completion_report.py` are the bodies of the lazy-imported default-validator functions (`_default_coverage_ledger_validator`, `_default_parity_matrix_validator`), which are deliberately never exercised by unit tests per the injectable-validator seam design (`evidence/qa-gates/final-py-test.2026-07-18T22-25.md`); this is a documented, deliberate exclusion, not an oversight. |
| **Positive Flows** | PASS | `test_build_and_render_*_report_sorts_and_counts_entries`, `test_build_completion_summary_reports_entry_counts_and_readiness`, `test_main_returns_0_*` across all three report test modules. |
| **Negative Flows** | PASS | `test_main_returns_1_and_prints_errors_on_validation_failure`, `test_main_returns_1_on_failure`, `test_main_returns_1_on_coverage_validation_failure_and_skips_build`, `test_main_returns_1_when_either_validator_fails`, `test_validate_or_raise_raises_with_errors`. |
| **Edge Cases** | PASS | Empty-artifact (missing `"entries"` key) rendering: `test_build_coverage_rows_handles_missing_entries_key`, `test_build_parity_rows_handles_missing_entries_key`, `test_build_completion_summary_handles_missing_entries_key`. Partial-id-field fallback: `test_sort_rows_falls_back_when_id_field_partially_present`. |
| **Error Handling** | PASS | `ArtifactValidationError` raise/catch paths tested in `test_io.py` and every report's `main()` fail-fast test; write-never-called assertions confirm no partial/misleading report is produced on failure. |
| **Concurrency** | N/A | No concurrency-relevant code in this feature (pure functions plus thin sequential I/O). |
| **State Transitions** | N/A | No stateful component is introduced; reports are stateless renderings. |

### 1.2.1 Per-Language Coverage Comparison

- Python: Baseline 88.87% line / 79.51% branch -> Post-change 88.95% line / 79.60% branch. Change:
  +0.08pp line / +0.09pp branch. New-file coverage: 100%/100%, 100%/100%, 95.00%/100%,
  95.00%/100%, 92.16%/100% (five new modules, individually recomputed from `artifacts/python/lcov.info`
  during this audit). Disposition: PASS. Evidence: `evidence/baseline/py-test.2026-07-18T21-19.md`,
  `evidence/qa-gates/final-py-test.2026-07-18T22-25.md`,
  `evidence/qa-gates/coverage-delta.2026-07-18T22-28.md`, `artifacts/python/lcov.info`.

### 1.3 Test Structure and Diagnostics

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clear Failure Messages** | PASS | Assertions use behavioral checks (`assert exit_code == 1`, `assert "..." in stderr_capture.getvalue()`, `assert write_calls == []`) that fail with actionable pytest diff output. |
| **Arrange-Act-Assert Pattern** | PASS | Every test in the five new test files follows Arrange (fixture/monkeypatch setup) -> Act (call under test) -> Assert, with comment-documented scenarios. |
| **Document Intent** | PASS | Every test function has a docstring stating the scenario and expected outcome (verified directly in all five test files). |

### 1.4 External Dependencies and Environment

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Avoid External Dependencies** | PASS | No network, database, or subprocess calls in any new test. `grep -n "tempfile\|NamedTemporaryFile\|mkdtemp\|tmp_path\|TemporaryDirectory"` across all five new test files returned zero matches. |
| **Use Mocks/Stubs** | PASS | `monkeypatch.setattr(Path, "read_text"/"write_text", ...)` for I/O boundary tests; fake `ArtifactValidator` callables injected via the `validator=`/`coverage_validator=`/`parity_validator=` keyword seam for CLI tests — never the real, lazily-imported upstream validator. |
| **Environment Stability** | PASS | No global state, no config files, no temp files (confirmed above). |

### 1.5 Policy Audit Requirement

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Pre-submission Review** | PASS | This audit, plus the accompanying `code-review.2026-07-18T23-05.md` and `feature-audit.2026-07-18T23-10.md`, serve as the required policy review prior to PR submission. |

---

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Clarify the objective** | PASS | `issue.md` (#368), `spec.md`, `user-story.md` all state the objective: deterministic human-readable reports over the Coverage Ledger and Parity Matrix. |
| **Read existing change plans** | PASS | `evidence/baseline/phase0-instructions-read.md` records the P0-T1 policy-reading task; `plan.2026-07-17T15-03.md` documents the full 39-task plan, all checked off. |
| **Document the plan** | PASS | `plan.2026-07-17T15-03.md`, including an "Open Questions / Notes" section documenting the two plan-level deviations from `spec.md` (CLI flag naming, validator module path). |

### 2.2 Design Principles

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Simplicity first** | PASS | Each report module follows one fixed `parse -> build_rows -> render -> CLI` pipeline with no unnecessary abstraction; `rendering.py` factors out the only genuinely shared logic (sort + JSON formatting). |
| **Reusability** | PASS | `rendering.sort_rows`/`rendering.render_pretty_json` are shared by all three report modules rather than reimplemented per module; `io.py`'s `ArtifactValidator`/`validate_or_raise`/`read_artifact_text`/`write_report` are shared by all three CLIs. |
| **Extensibility** | PASS | `main()` accepts keyword-only injected validators with real-validator defaults (keyword-style parameters with sensible defaults, per policy); `build_completion_summary` is structured to allow future artifact categories to be added as parameters without a rewrite (documented in the module docstring and `spec.md` "Completion-report scope risk"). |
| **Separation of concerns** | PASS | I/O (`io.py`) is fully isolated from pure rendering (`rendering.py`) and from per-report parsing/building logic; CLI argument parsing (`parse_args`) is separated from `main()`'s orchestration. |

### 2.3 Module & File Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Cohesive modules** | PASS | `io.py` = I/O boundary only; `rendering.py` = shared pure formatting; one module per report type. |
| **Under 500 lines** | PASS | `wc -l` on all five new production files: `io.py` 156, `rendering.py` 101, `coverage_report.py` 207, `parity_report.py` 208, `completion_report.py` 269. All well under the 500-line limit. Test files: 88, 86, 175, 175, 200 lines — also well under limit. |
| **Public vs internal** | PASS | Lazy-import default-validator functions are `_`-prefixed (`_default_coverage_ledger_validator`, `_default_parity_matrix_validator`), signaling internal-only status; public surface is `parse_*`, `build_*`, `render_*`, `parse_args`, `main`. |
| **No circular dependencies** | PASS | `coverage_report.py`/`parity_report.py`/`completion_report.py` import only from `scripts.dev_tools.discovery.rendering` and `scripts.dev_tools.discovery.io`; no cycle. |

### 2.4 Naming, Docs, and Comments

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Descriptive names** | PASS | `read_artifact_text`, `validate_or_raise`, `build_coverage_rows`, `render_coverage_report`, etc.; `snake_case` functions/variables throughout, matching Python naming policy. |
| **Docs/docstrings** | PASS | Every class and function in all five new production modules carries a Google-style docstring with Purpose/Args/Returns/Raises/Side Effects, satisfying `.claude/rules/self-explanatory-code-commenting.md`. |
| **Comment why, not what** | PASS with one Minor note | Branch/decision comments explain rationale (e.g., `rendering.py`'s comment on why a single missing id disqualifies the whole collection from id-based sorting). One inline docstring inaccuracy noted in `code-review.2026-07-18T23-05.md` (a citation to `spec.md` for a note that actually lives in `plan.2026-07-17T15-03.md`) — Minor, not a "what not why" violation. |

### 2.5 After Making Changes - Toolchain Execution

| Requirement | Status | Evidence |
|------------|--------|----------|
| **1. Formatting** | PASS | `poetry run black --check .` — `evidence/qa-gates/final-py-format.2026-07-18T22-10.md`, EXIT_CODE 0, re-run scoped to the 10 new files during this audit: "All done ... 10 files would be left unchanged." |
| **2. Linting** | PASS | `poetry run ruff check .` — `evidence/qa-gates/final-py-lint.2026-07-18T22-11.md`, EXIT_CODE 0; re-run scoped to the 10 new files during this audit: "All checks passed!" |
| **3. Type checking** | PASS | `poetry run pyright` — `evidence/qa-gates/final-py-typecheck.2026-07-18T22-12.md`, EXIT_CODE 0; re-run scoped to the 5 new production files during this audit: "0 errors, 0 warnings, 0 informations." The lazy-imported `validate_coverage_ledger_text`/`validate_parity_matrix_text` calls resolve cleanly against the real upstream module signatures (see Section 3A.2 below). |
| **4. Testing** | PASS | `poetry run pytest --cov --cov-branch --cov-report=term-missing` — `evidence/qa-gates/final-py-test.2026-07-18T22-25.md`, EXIT_CODE 0, 1869 passed; re-run scoped to the five new discovery-report test files during this audit: 30 passed in 0.06s. |
| **Full toolchain loop** | PASS | `evidence/qa-gates/final-py-test.2026-07-18T22-25.md` states no restart of the loop was required for the final pass (format/lint/type-check/test all clean on first run after the last edit). |
| **Explicit reporting** | PASS | All four toolchain stages have a dedicated timestamped evidence artifact under `evidence/qa-gates/`. |

### 2.6 Summarize and Document

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Summarize changes** | PASS | Single commit `20c26abd` "feat(discovery): add coverage, parity, and completion report CLIs" summarizes the change; `plan.2026-07-17T15-03.md` fully documents scope. |
| **Design choices explained** | PASS | `spec.md` "Data & State" and "Implementation Strategy," plus the plan's "Open Questions / Notes," explain the field-mapping placeholder and CLI flag-naming deviation design choices. |
| **Update supporting documents** | PARTIAL | `spec.md` Definition of Done leaves "Docs updated (README, docs/features/active/... links)" unchecked. `README.md` was independently confirmed to contain zero `dev.discovery` references (consistent with the pre-existing sibling `dev.discovery.*` commands, none of which are documented in `README.md` either) — this is a pre-existing repository documentation gap, not one newly introduced or hidden by this feature, and the feature's own `spec.md`/`user-story.md`/`issue.md` are fully updated and AC-checked. Non-blocking; recorded as a gap in Section 8. |
| **Provide next steps** | PASS | `spec.md` and `plan.2026-07-17T15-03.md` "Open Questions / Notes" identify the follow-up `resolve_field_mapping` dispatcher work once `legacy-discovery-schemas` (#9002) lands, explicitly marked out of scope for this plan. |

---

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Formatting with Black** | PASS | `poetry run black --check .` — EXIT_CODE 0 (full repo, `evidence/qa-gates/final-py-format.2026-07-18T22-10.md`; independently re-verified scoped to the 10 new files during this audit). |
| **Linting with Ruff** | PASS | `poetry run ruff check .` — EXIT_CODE 0 (full repo; independently re-verified scoped to the 10 new files). |
| **Type checking with Pyright** | PASS | `poetry run pyright` — 0 errors/warnings (full repo; independently re-verified scoped to the 5 new production files). |
| **Testing with Pytest** | PASS | `poetry run pytest --cov --cov-branch --cov-report=term-missing` — 1869 passed, 0 failed (full repo; independently re-verified scoped to the 5 new test files: 30 passed). |

#### 3A.2 Python Design & Typing

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Strong typing** | PASS | Every public function/method in the five new modules has full parameter and return type annotations (`from __future__ import annotations` used throughout); `Any` is used only where the artifact shape is genuinely undetermined (`dict[str, Any]` for parsed JSON, consistent with the upstream-schema-pending constraint documented in `spec.md`). |
| **Dataclasses for value objects** | N/A | No value object with invariant-bearing state is introduced; artifacts are handled as plain `dict[str, Any]` by explicit design (`spec.md` "Data & State": "no dataclass is introduced yet, since the upstream schema is not final"). |
| **Protocols/ABCs for interfaces** | PASS | `ArtifactValidator` is a `typing.Protocol` with a single `__call__(self, text: str) -> list[str]` method, matching the "multiple implementations expected" design-rule trigger (real upstream validator vs. test fakes). |
| **Avoid utility classes** | PASS | All five new modules use module-level functions, not static-method-only utility classes. |
| **Binding-correction verification (context item 1)** | PASS | Read `scripts/dev_tools/validate_discovery_schema_artifacts.py` directly: `def validate_coverage_ledger_text(text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR) -> list[str]` (line 150) and `def validate_parity_matrix_text(text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR) -> list[str]` (line 164). Both are called as `validate_coverage_ledger_text(text)` / `validate_parity_matrix_text(text)` (positional `text: str` only, relying on the `cache_dir` default) from `_default_coverage_ledger_validator`/`_default_parity_matrix_validator` in `coverage_report.py`, `parity_report.py`, and `completion_report.py`. The call shape and return type (`list[str]`) exactly satisfy the `ArtifactValidator` `Protocol.__call__(self, text: str) -> list[str]` contract. Pyright resolves the lazy import with 0 errors (independently re-run during this audit). This is the plan-anticipated correction documented in `plan.2026-07-17T15-03.md` "Open Questions / Notes" ("Upstream validator module path is unverified" — now resolved to the real, merged `validate_discovery_schema_artifacts` module) and is technically correct and type-safe. |

#### 3A.3 Python Error Handling

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Specific exceptions** | PASS | `ArtifactValidationError` is a dedicated exception carrying `errors: list[str]`; `main()` catches only this specific exception type, not a bare `except Exception`. |
| **Logging over print** | PASS with documented exception | `main()` uses `print(..., file=sys.stderr)` for validator error output and `print(report_text, end="")` for stdout report output. This is CLI output (user-facing report/error text), not application logging, and matches the repository's existing CLI precedent (`scripts/dev_tools/format_json.py`, `scripts/dev_tools/validate_json.py`, cited directly in `spec.md`). No `# noqa` suppression was needed or used. |
| **Invariants at construction** | PASS | `ArtifactValidationError.__init__` builds its message from the non-empty `errors` list at construction time; `ArtifactValidator` as a `Protocol` carries no state to construct. |

---

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

#### 4A.1 Framework and Scope

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | All five new test files use plain `pytest`/`monkeypatch`/`capsys` fixtures; no alternative test runner. |
| **Coverage expectation** | PASS | New-file line coverage 92.16%-100% (all >= 90%); repo-wide 88.95% line / 79.60% branch (both >= the uniform 85%/75% tier floor). |

#### 4A.2 Test Style and Structure

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Focused unit tests** | PASS | Each test targets one function/scenario (see Section 1.1 Isolation). |
| **Mocking sparingly** | PASS | Mocking is limited to `monkeypatch.setattr(Path, "read_text"/"write_text")` and injected fake validators; pure logic (`sort_rows`, `render_pretty_json`, `build_*_rows`, `render_*_report`, `build_completion_summary`) is tested with real, unmocked calls. |
| **Organization** | PASS | `tests/scripts/dev_tools/discovery/test_<module>.py` mirrors `scripts/dev_tools/discovery/<module>.py` exactly, per the required test-file-location convention. |

#### 4A.3 Naming and Readability

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Naming conventions** | PASS | `test_<behavior>_<expected_outcome>` pattern throughout, e.g. `test_main_returns_1_and_prints_errors_on_validation_failure`. |
| **Docstrings/comments** | PASS | Every test function and every test module has a docstring describing scope and intent. |

#### 4A.4 Running the Toolchain

| Requirement | Status | Evidence |
|------------|--------|----------|
| **Use Pytest** | PASS | `poetry run pytest --cov --cov-branch --cov-report=term-missing` — EXIT_CODE 0. |
| **No Alternative Test Runners** | PASS | No `unittest.main()`, no `nose`, no ad hoc runner script found in the new test files. |

---

## 5. Test Coverage Detail

### `scripts/dev_tools/discovery/io.py` (4 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_validate_or_raise_passes_with_no_errors` | Positive | PASS |
| `test_validate_or_raise_raises_with_errors` | Negative | PASS |
| `test_read_artifact_text_returns_stubbed_text` | Positive (I/O boundary) | PASS |
| `test_write_report_calls_write_text_with_exact_content` | Positive (I/O boundary) | PASS |

**Coverage:** 100% line, 100% branch (16/16 lines, 2/2 branches, from `artifacts/python/lcov.info`).
**Not covered:** None.

### `scripts/dev_tools/discovery/rendering.py` (5 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_sort_rows_sorts_ascending_by_id_field` | Positive | PASS |
| `test_sort_rows_falls_back_to_joined_field_sort_when_id_absent` | Edge case | PASS |
| `test_sort_rows_falls_back_when_id_field_partially_present` | Edge case | PASS |
| `test_render_pretty_json_exact_literal_output` | Positive (exact literal) | PASS |
| `test_render_pretty_json_is_deterministic` | Determinism | PASS |

**Coverage:** 100% line, 100% branch (13/13 lines, 2/2 branches).
**Not covered:** None.

### `scripts/dev_tools/discovery/coverage_report.py` (7 tests), `parity_report.py` (7 tests, mirrored) (7 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_build_and_render_*_report_sorts_and_counts_entries` | Positive | PASS |
| `test_render_*_report_is_deterministic` | Determinism | PASS |
| `test_main_returns_1_and_prints_errors_on_validation_failure` | Negative | PASS |
| `test_build_*_rows_handles_missing_entries_key` | Edge case | PASS |
| `test_main_returns_0_on_success` | Positive (CLI) | PASS |
| `test_main_returns_1_on_failure` | Negative (CLI) | PASS |
| `test_main_writes_to_stdout_when_output_omitted` | Positive (CLI stdout path) | PASS |

**Coverage:** 95.00% line, 100% branch each (38/40 lines, 4/4 branches).
**Not covered:** Lines 128-132 (`coverage_report.py`) / 129-133 (`parity_report.py`) — the body of
the lazy-imported default-validator function, deliberately never exercised by unit tests (every
test injects a fake validator, per the injectable-seam design).

### `scripts/dev_tools/discovery/completion_report.py` (7 tests)

| Test Name | Scenario Type | Status |
|-----------|--------------|--------|
| `test_build_completion_summary_reports_entry_counts_and_readiness` | Positive | PASS |
| `test_render_completion_report_is_deterministic` | Determinism | PASS |
| `test_main_returns_1_on_coverage_validation_failure_and_skips_build` | Negative | PASS |
| `test_build_completion_summary_handles_missing_entries_key` | Edge case | PASS |
| `test_main_returns_0_when_both_validators_pass` | Positive (CLI) | PASS |
| `test_main_returns_1_when_either_validator_fails` | Negative (CLI) | PASS |
| `test_main_writes_to_stdout_when_output_omitted` | Positive (CLI stdout path) | PASS |

**Coverage:** 92.16% line, 100% branch (47/51 lines, 6/6 branches).
**Not covered:** Lines 124-128 and 154-158 — the two lazy-imported default-validator function
bodies, deliberately never exercised by unit tests.

---

## 6. Test Execution Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Total Tests (repo-wide) | 1869 | PASS |
| Tests Passed (repo-wide) | 1869 (100%) | PASS |
| Tests Failed | 0 | PASS |
| Execution Time (repo-wide) | 7.92s | PASS Fast |
| New tests added by this feature | 30 | PASS |
| New-test execution time (isolated re-run) | 0.06s | PASS Fast |
| Test File Size (largest new test file) | 200 lines (`test_completion_report.py`) | PASS Maintainable |
| Code Coverage (repo-wide) | 88.95% lines, 79.60% branches | PASS |

---

## 7. Code Quality Checks

**For Python:**

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Black Formatting | `poetry run black --check .` | All done, 0 changes needed (full repo + scoped re-run) | PASS |
| Ruff Linting | `poetry run ruff check .` | All checks passed (full repo + scoped re-run) | PASS |
| Pyright Type Checking | `poetry run pyright` | 0 errors, 0 warnings, 0 informations (full repo + scoped re-run) | PASS |
| Pytest Tests | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 1869 passed, 0 failed (full repo); 30 passed (scoped re-run) | PASS |

**Notes:** No pre-existing failures unrelated to this work were observed. No deviation from a
clean toolchain run was required for the final pass, per `evidence/qa-gates/final-py-test.2026-07-18T22-25.md`.

---

## 8. Gaps and Exceptions

### Identified Gaps

1. **`spec.md` Definition of Done — "Docs updated" unchecked.** `README.md` has zero
   `dev.discovery` references for any of the repository's existing `dev.discovery.*` commands
   (init, profile, inventory, generate-acceptance-scenarios, validate-*), so this feature's three
   new commands are consistent with an existing, pre-established repository documentation gap
   rather than a new omission. Non-blocking; recommend a follow-up (not this feature) to document
   the full `dev.discovery.*` command surface in `README.md`.
2. **`completion_report.py` docstring cites `spec.md` for a design-deviation note that actually
   lives in `plan.2026-07-17T15-03.md`.** See `code-review.2026-07-18T23-05.md` Findings Table.
   Minor; does not affect runtime behavior or type-safety.
3. **`quality-tiers.yml` does not exist at the repository root**, so no tier classification exists
   for `scripts/dev_tools/discovery/**`. This is a pre-existing, repository-wide condition not
   introduced or worsened by this feature (confirmed: no `quality-tiers.yml` exists anywhere in
   the repository). The uniform coverage thresholds (line >= 85%, branch >= 75%) were still
   applied and independently verified regardless of tier classification. Out of scope for this
   feature's remediation.

### Approved Exceptions

**None.** No exceptions needed; both identified gaps above are pre-existing repository conditions
independent of this feature's diff, not exceptions to a requirement this feature was obligated to
meet.

### Removed/Skipped Tests

**None.** All planned tests implemented; 0 remaining unchecked tasks in `plan.2026-07-17T15-03.md`.

---

## 9. Summary of Changes

### Commits in This PR/Branch

1. **`20c26abd`** - feat(discovery): add coverage, parity, and completion report CLIs

### Files Modified

1. **`scripts/dev_tools/discovery/io.py`** (NEW, 156 lines) — `ArtifactValidator` protocol,
   `ArtifactValidationError`, `read_artifact_text`, `validate_or_raise`, `write_report`.
2. **`scripts/dev_tools/discovery/rendering.py`** (NEW, 101 lines) — `sort_rows`,
   `render_pretty_json` shared deterministic-formatting helpers.
3. **`scripts/dev_tools/discovery/coverage_report.py`** (NEW, 207 lines) — Coverage Ledger report
   CLI (`dev.discovery.coverage-report`).
4. **`scripts/dev_tools/discovery/parity_report.py`** (NEW, 208 lines) — Parity Matrix report CLI
   (`dev.discovery.parity-report`).
5. **`scripts/dev_tools/discovery/completion_report.py`** (NEW, 269 lines) — aggregate-readiness
   CLI over both artifacts (`dev.discovery.completion-report`).
6. **`tests/scripts/dev_tools/discovery/test_io.py`**, **`test_rendering.py`**,
   **`test_coverage_report.py`**, **`test_parity_report.py`**, **`test_completion_report.py`**
   (NEW, 88/86/175/175/200 lines) — mirrored test coverage for the five production modules.
7. **`pyproject.toml`** (MODIFIED, +3 lines) — three new `[tool.poetry.scripts]` entries:
   `dev.discovery.completion-report`, `dev.discovery.coverage-report`, `dev.discovery.parity-report`.
8. **`docs/features/active/2026-07-17-legacy-discovery-reports-368/{spec.md,user-story.md,plan.2026-07-17T15-03.md,evidence/**}`**
   — scoping-doc updates and evidence artifacts.

---

## 10. Compliance Verdict

### Overall Status: FULLY COMPLIANT

All uniform, cross-language and Python-specific policy requirements evaluated for this diff are
satisfied. Coverage improved slightly over baseline with no regression, all new files exceed the
90% new-file coverage bar, the toolchain passes cleanly, determinism and I/O-isolation claims were
independently verified (not merely asserted), and the plan-anticipated validator-binding
correction is confirmed technically correct via direct source inspection and a clean Pyright run.
Two Minor, non-blocking gaps are recorded in Section 8 (a pre-existing README documentation gap
and a docstring citation inaccuracy); neither affects runtime behavior, test correctness, or
policy compliance for this feature's own delivered scope.

**Fail-closed reminder:** No required baseline, QA, or coverage artifact is missing; verdict is
issued on that basis, not by default.

---

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)
- PASS Before Making Changes
- PASS Design Principles
- PASS Module & File Structure
- PASS Naming, Docs, Comments
- PASS Toolchain Execution
- PARTIAL (non-blocking) Summarize & Document — pre-existing README gap, not new

#### Language-Specific Code Change Policy (Section 3)

**For Python:**
- PASS Tooling & Baseline
- PASS Python Design & Typing (including independent validator-binding verification)
- PASS Error Handling

#### General Unit Test Policy (Section 1)
- PASS Core Principles
- PASS Coverage & Scenarios
- PASS Test Structure
- PASS External Dependencies
- PASS Policy Audit

#### Language-Specific Unit Test Policy (Section 4)

**For Python:**
- PASS Framework & Scope
- PASS Test Style & Structure
- PASS Naming & Readability
- PASS Toolchain

---

### Metrics Summary

- PASS 1869/1869 repo-wide tests passing (100%), including 30/30 new tests
- PASS All 5 new production modules independently coverage-verified from raw `lcov.info`
- PASS 88.95% line coverage, 79.60% branch coverage repo-wide (both above 85%/75% uniform floor)
- PASS Proper file organization: subpackage mirrors `atomic_executor/` precedent; tests mirror source tree
- PASS All code quality checks passing (Black, Ruff, Pyright, Pytest)
- PASS Test execution time: 0.06s for new tests, 7.92s for full repo suite (fast)

---

### Recommendation

**Ready for merge.**

No Blocking findings were identified during this audit. Two Minor, non-blocking observations are
recorded in Section 8 and in the accompanying `code-review.2026-07-18T23-05.md`; neither requires
remediation before this feature proceeds through the normal PR flow.

---

## Appendix A: Test Inventory

### Complete Test List

1. `test_io.py::test_validate_or_raise_passes_with_no_errors`
2. `test_io.py::test_validate_or_raise_raises_with_errors`
3. `test_io.py::test_read_artifact_text_returns_stubbed_text`
4. `test_io.py::test_write_report_calls_write_text_with_exact_content`
5. `test_rendering.py::test_sort_rows_sorts_ascending_by_id_field`
6. `test_rendering.py::test_sort_rows_falls_back_to_joined_field_sort_when_id_absent`
7. `test_rendering.py::test_sort_rows_falls_back_when_id_field_partially_present`
8. `test_rendering.py::test_render_pretty_json_exact_literal_output`
9. `test_rendering.py::test_render_pretty_json_is_deterministic`
10. `test_coverage_report.py::test_build_and_render_coverage_report_sorts_and_counts_entries`
11. `test_coverage_report.py::test_render_coverage_report_is_deterministic`
12. `test_coverage_report.py::test_main_returns_1_and_prints_errors_on_validation_failure`
13. `test_coverage_report.py::test_build_coverage_rows_handles_missing_entries_key`
14. `test_coverage_report.py::test_main_returns_0_on_success`
15. `test_coverage_report.py::test_main_returns_1_on_failure`
16. `test_coverage_report.py::test_main_writes_to_stdout_when_output_omitted`
17. `test_parity_report.py::test_build_and_render_parity_report_sorts_and_counts_entries`
18. `test_parity_report.py::test_render_parity_report_is_deterministic`
19. `test_parity_report.py::test_main_returns_1_and_prints_errors_on_validation_failure`
20. `test_parity_report.py::test_build_parity_rows_handles_missing_entries_key`
21. `test_parity_report.py::test_main_returns_0_on_success`
22. `test_parity_report.py::test_main_returns_1_on_failure`
23. `test_parity_report.py::test_main_writes_to_stdout_when_output_omitted`
24. `test_completion_report.py::test_build_completion_summary_reports_entry_counts_and_readiness`
25. `test_completion_report.py::test_render_completion_report_is_deterministic`
26. `test_completion_report.py::test_main_returns_1_on_coverage_validation_failure_and_skips_build`
27. `test_completion_report.py::test_build_completion_summary_handles_missing_entries_key`
28. `test_completion_report.py::test_main_returns_0_when_both_validators_pass`
29. `test_completion_report.py::test_main_returns_1_when_either_validator_fails`
30. `test_completion_report.py::test_main_writes_to_stdout_when_output_omitted`

---

## Appendix B: Toolchain Commands Reference

**For Python:**
```bash
# Formatting
poetry run black .
poetry run black --check .

# Linting
poetry run ruff check .

# Type checking
poetry run pyright

# Testing
poetry run pytest
poetry run pytest --cov --cov-branch --cov-report=term-missing

# Evidence-location validation
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
```

---

**Audit Completed By:** feature-review agent (Claude)
**Audit Date:** 2026-07-18
**Policy Version:** Current (as of audit date)
