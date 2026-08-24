# Code Review: legacy-discovery-reports (#368)

**Review Date:** 2026-07-18
**Reviewer:** feature-review agent (Claude)
**Feature Folder:** `docs/features/active/2026-07-17-legacy-discovery-reports-368`
**Feature Folder Selection Rule:** Selected as the active feature folder matching the branch-name
issue suffix (`-368`) and the only feature folder with material scoping-doc changes in this diff.
**Base Branch:** `epic/legacy-discovery-and-parity-integration`
**Head Branch:** `feature/legacy-discovery-reports-368` (`20c26abd85dd2a58b28d77578edd7bc2fc403f8c`)
**Review Type:** Initial review

---

## Executive Summary

This change adds a new `scripts/dev_tools/discovery/` reporting subpackage: two shared helper
modules (`io.py` for the I/O boundary and validator seam, `rendering.py` for deterministic
sort/JSON-formatting primitives) and three CLI report modules (`coverage_report.py`,
`parity_report.py`, `completion_report.py`), each following an identical
`parse -> build_rows -> render -> CLI` pipeline. The subpackage decomposition mirrors the existing
`atomic_executor/` precedent and keeps every file well under the 500-line limit. Tests mirror the
production tree 1:1, inject fake validators, and cover positive, negative, edge-case, and
determinism scenarios for every public function.

**What changed:**
Five new production modules (941 total lines) and five mirrored test modules (724 total lines)
under `scripts/dev_tools/discovery/` and `tests/scripts/dev_tools/discovery/`, plus three new
Poetry console-script entries in `pyproject.toml`. No existing module was modified; the change is
strictly additive.

**Top 3 risks:**
1. The two `_default_*_validator` lazy-import functions in each report module are, by design,
   never exercised by unit tests (every test injects a fake validator). This is documented and
   deliberate, but it means the real upstream `validate_discovery_schema_artifacts` binding has no
   automated regression coverage beyond Pyright's static resolution — a future signature change in
   the upstream module would only be caught by Pyright, not by a failing test, unless an
   integration test is added later.
2. `completion_report.py`'s docstring (line 169) cites `spec.md` "Completion-report CLI flag
   naming deviation" as the source of the `--coverage-input`/`--parity-input` design decision, but
   that heading actually exists in `plan.2026-07-17T15-03.md` "Open Questions / Notes," not in
   `spec.md`. A future reader following the citation into `spec.md` will not find the referenced
   section.
3. The completion report's "readiness" field is hardcoded to the literal string `"ready"`
   whenever both artifacts validate successfully (`build_completion_summary`, lines 67-77);
   this is an intentional v1 scope limitation documented in the module's own header docstring and
   in `spec.md` "Completion-report scope risk," but a reader of the rendered report output alone
   (without reading the source) could reasonably expect "readiness" to reflect some completeness
   threshold rather than "both inputs parsed".

**PR readiness recommendation:** **Go** — no Blocking or Major findings; the two Minor findings
below are documentation/citation-quality issues that do not affect runtime behavior, type safety,
or test correctness.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `scripts/dev_tools/discovery/completion_report.py` | line 169 (docstring) | The `parse_args` docstring cites `spec.md` "Completion-report CLI flag naming deviation" as the source of the `--coverage-input`/`--parity-input` design decision. That heading does not exist in `spec.md`; the actual note lives in `plan.2026-07-17T15-03.md` "Open Questions / Notes" ("Completion-report CLI flag naming deviation"). | Update the docstring citation to reference `plan.2026-07-17T15-03.md` "Open Questions / Notes" instead of `spec.md`. | A future maintainer following the citation into `spec.md` will not find the referenced section, which weakens the self-documenting value of the docstring. | Confirmed by `grep -n "flag naming deviation" docs/features/active/2026-07-17-legacy-discovery-reports-368/spec.md` (no match) vs. `plan.2026-07-17T15-03.md:367-369` (match). |
| Minor | `scripts/dev_tools/discovery/{coverage_report,parity_report,completion_report}.py` | `_default_coverage_ledger_validator` / `_default_parity_matrix_validator` function bodies | These lazy-import default-validator bindings are, by design, never exercised by any unit test (every test in the five new test files injects a fake `ArtifactValidator`). Correctness of the real binding today relies on Pyright's static resolution plus this review's manual verification, not on an automated test. | Consider a follow-up (not blocking for this feature) integration-style test that patches `sys.modules` or otherwise exercises the lazy-import path once `legacy-discovery-validators` (#9003)/its consuming module is stable, so a future signature drift in `validate_discovery_schema_artifacts` is caught by CI rather than by a subsequent manual review. | Reduces reliance on manual/static verification alone for a runtime-critical default path. | `coverage_report.py:104-132`, `parity_report.py:105-133`, `completion_report.py:99-158`; `evidence/qa-gates/final-py-test.2026-07-18T22-25.md` explicitly confirms these lines are uncovered by design. |
| Info | `scripts/dev_tools/discovery/completion_report.py` | `build_completion_summary`, lines 39-77 | `"readiness"` is unconditionally `"ready"` once both artifacts pass validation; no entry-count or content-based readiness signal exists in v1. This is explicitly documented as an intentional scope limitation in the module docstring (lines 9-16) and in `spec.md` "Completion-report scope risk," so it is not a defect, but it is worth flagging for anyone reading only the rendered report output. | No action required for this feature; consider documenting the "ready == both validated" semantics in the rendered report body itself (e.g., a `"readiness_basis"` field) in a future iteration if reviewers report confusion. | Improves report self-explanatory-ness without expanding v1 scope. | `completion_report.py:39-77`; `spec.md` "Completion-report scope risk" (lines 166-173). |

No Blocking or Major findings.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Consistent `parse_<artifact> -> build_<x>_rows -> render_<x>_report -> main` pipeline across all
  three report modules makes the codebase easy to navigate; `parity_report.py` explicitly states
  in its module docstring that it "mirrors `coverage_report.py`'s pipeline exactly."
- The `ArtifactValidator` `Protocol` plus the lazy-import-inside-function-body pattern for the real
  upstream validator is a clean, minimal seam: it lets test code never touch the real validator
  module while keeping the production default wired correctly, and it avoids a hard import-time
  dependency on `legacy-discovery-validators`/`validate_discovery_schema_artifacts` before that
  module exists (a real execution-time risk this feature's own `spec.md` flags explicitly).
- `sort_rows`'s "all rows must have a usable id, or fall back to a full joined-field sort" rule is
  a genuinely well-reasoned invariant (a partial id-based sort would not be a total order), and the
  code has an explicit comment (`rendering.py:48-51`) explaining why, not just what.
- `render_pretty_json` and the fixed `json.dumps(data, sort_keys=True, indent=2) + "\n"` formatting
  discipline is reused identically by all three reports rather than reimplemented, and this review
  confirmed empirically (by invoking `coverage_report.main()` twice against identical input with an
  injected passing validator) that the CLI produces byte-identical output across runs.
- No domain-specific identifiers (`taskmaster`, `tmw`, `outlook`, `vsto`, `task-management`) appear
  anywhere in the five new production or five new test files; independently re-verified via
  `grep -inE "taskmaster|\btmw\b|outlook|vsto|task-management"` across all ten files (zero matches).

#### Typing and API notes

- Every public function has complete type hints; `from __future__ import annotations` is used
  consistently, and `TYPE_CHECKING`-gated imports (`collections.abc.Sequence`) avoid unnecessary
  runtime imports.
- `main(argv: Sequence[str] | None = None, *, validator: ArtifactValidator | None = None) -> int`
  (and the two-validator variant in `completion_report.py`) follows the repository's keyword-style
  extensibility convention cleanly: positional `argv` for CLI use, keyword-only injectable
  dependencies for tests.
- The plan-anticipated validator-binding correction (real module
  `scripts.dev_tools.validate_discovery_schema_artifacts`, functions `validate_coverage_ledger_text`
  and `validate_parity_matrix_text`) was independently verified against the actual function
  signatures (`text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR`) — the call sites use only the
  positional `text` argument, which is fully compatible with both the real signature and the
  `ArtifactValidator.__call__(self, text: str) -> list[str]` Protocol. Pyright reports 0 errors on
  the lazy-import call sites.
- No new public Python API surface beyond the five report modules' documented functions and the
  three new console-script entry points was added; `__init__.py` was not modified (pre-existing
  from an earlier merged feature) and this feature does not export new symbols through it.

#### Error handling and logging

- `ArtifactValidationError` is a specific, purpose-built exception (not a bare `Exception`), and
  `main()` catches only that type. Fail-fast is enforced structurally: `validate_or_raise` is
  always called before `parse_<artifact>`/`build_<x>_rows`/`render_<x>_report`, and the
  `completion_report.py` variant explicitly comments on the deliberate choice to validate both
  inputs before aggregating so a caller sees every problem in one run.
- CLI output uses `print(..., file=sys.stderr)` for validation errors and `print(report_text, end="")`
  for stdout report bodies. This is appropriate CLI-boundary output, not application logging, and
  matches the existing `format_json.py`/`validate_json.py` precedent cited in `spec.md`.

---

## Test Quality Audit

All ten new files (five production, five test) were read in full for this review. Test/QA
artifacts consumed:

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/discovery/test_io.py` — validates the `ArtifactValidator` seam and the
  thin `Path.read_text`/`Path.write_text` wrappers via `monkeypatch`; no gaps found.
- `tests/scripts/dev_tools/discovery/test_rendering.py` — validates `sort_rows` (id-sort, fallback
  sort, partial-id fallback) and `render_pretty_json` (exact literal output + determinism); no
  gaps found.
- `tests/scripts/dev_tools/discovery/test_coverage_report.py`,
  `test_parity_report.py`, `test_completion_report.py` — validate the full
  parse/build/render/CLI pipeline per report, including fail-fast, empty-artifact edge case, and
  stdout-vs-`--output` CLI paths; the lazy-import default-validator path is deliberately left
  uncovered (see Findings Table Minor #2).
- `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/qa-gates/coverage-delta.2026-07-18T22-28.md`
  — proves no coverage regression; independently re-verified against `artifacts/python/lcov.info`
  during this review with matching per-file and repo-wide figures.
- `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/qa-gates/domain-neutrality-check.2026-07-18T22-05.md`
  — proves zero domain-specific tokens in this feature's own files; independently re-verified via
  direct `grep` during this review with matching (zero-match) results.

### Quality assessment prompts

- **Determinism:** No wall-clock, RNG, or `uuid` usage in the five new production modules
  (confirmed by direct grep). Every report module has an explicit "render twice, assert equal"
  test, plus this review's own end-to-end CLI double-invocation confirming byte-identical file
  output.
- **Isolation:** Each test targets exactly one function or one `main()` scenario; no test asserts
  more than one logical outcome.
- **Speed:** The five new test files run in 0.06s in isolation (independently re-run during this
  review); the full 1869-test repo suite runs in 7.92s per
  `evidence/qa-gates/final-py-test.2026-07-18T22-25.md`.
- **Diagnostics:** Assertions are behavioral (`assert exit_code == 1`, `assert "..." in stderr...`,
  `assert write_calls == []`) and will produce clear pytest failure diffs; no over-broad
  `assert True`-style tests were found.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credentials, tokens, or hardcoded paths outside test fixtures found in any of the ten new files. |
| No unsafe subprocess or command construction | PASS | No `subprocess`, `os.system`, or shell invocation anywhere in the five new production modules. |
| Input validation at boundaries | PASS | Every artifact is validated via the injected `ArtifactValidator` seam before any parsing or rendering; `validate_or_raise` is the single, structurally enforced checkpoint. |
| Error handling remains explicit | PASS | `ArtifactValidationError` is caught explicitly by type; no bare `except Exception` in the new modules. |
| Configuration / path handling is safe | PASS | Paths are supplied via explicit `--input`/`--output`/`--coverage-input`/`--parity-input` CLI flags and passed straight to `Path(...)`; no path traversal logic, no implicit path construction from untrusted input beyond what argparse already validates as a required string flag. |

---

## Research Log

No external research was required for this review. All findings are grounded in direct inspection
of the branch diff, the five new production modules and five new test modules read in full, the
real upstream `scripts/dev_tools/validate_discovery_schema_artifacts.py` module (read directly to
verify the validator-binding correction), the raw `artifacts/python/lcov.info` coverage artifact
(parsed directly), and toolchain re-runs (Black, Ruff, Pyright, Pytest) executed independently
during this review rather than taken solely from the feature's own evidence artifacts.

---

## Verdict

This change is well-scoped, additive-only, fully typed, and independently verified against its own
evidence claims: coverage figures, domain-neutrality claims, determinism claims, and the
plan-anticipated validator-binding correction were all re-derived from primary sources (raw
coverage artifact, direct source-file inspection, live CLI invocation) rather than accepted from
the feature's own documentation. No Blocking or Major findings were identified. Two Minor findings
(a docstring citation pointing to the wrong file, and the intentionally-uncovered lazy-import
validator path) and one Info-level observation are recorded above; none require remediation before
this feature proceeds through the normal PR flow. **Ready for normal PR flow.**
