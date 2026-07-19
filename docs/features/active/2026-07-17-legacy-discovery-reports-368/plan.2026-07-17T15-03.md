# legacy-discovery-reports - Plan

- **Issue:** #368
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/368
- **Parent (optional):** none — epic child (`legacy-discovery-and-parity`, manifest issue 9010)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T15-03
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature

## Required References

- Policy reading order per `.claude/skills/policy-compliance-order`: `CLAUDE.md` →
  `.claude/rules/general-code-change.md` → `.claude/rules/general-unit-test.md` →
  `.claude/rules/quality-tiers.md` → `.claude/rules/python.md` →
  `.claude/rules/python-suppressions.md`.
- Authoritative requirements: `docs/features/active/2026-07-17-legacy-discovery-reports-368/spec.md`
  and `docs/features/active/2026-07-17-legacy-discovery-reports-368/user-story.md` (Acceptance
  Criteria sections are identical across `issue.md`/`spec.md`/`user-story.md`).
- Preparation research: `docs/features/active/2026-07-17-legacy-discovery-reports-368/research/research.2026-07-17T15-10.md`.
- Epic contract: `docs/features/epics/legacy-discovery-and-parity/objective-source.md` (section 12,
  "Reports") and `docs/features/epics/legacy-discovery-and-parity/epic.md` ("Shared Design",
  "Validator pattern" and "Schema-versioning convention").

**All work must comply with these policies; do not duplicate their content here.**

## Plan Invariants (apply to every phase)

- **Language scope:** Python only. No TypeScript/PowerShell/C# files are touched by this feature.
- **Toolchain order (restart on any failure or auto-fix):** `poetry run black .` →
  `poetry run ruff check .` → `poetry run pyright` →
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
- **Coverage gates (uniform T1–T4 per `.claude/rules/quality-tiers.md`):** line coverage >= 85%,
  branch coverage >= 75%, no regression on changed lines. `[tool.coverage.run] source` in
  `pyproject.toml` already includes `scripts/dev_tools`, so every new module under
  `scripts/dev_tools/discovery/` is automatically in the coverage denominator; no `omit` entry
  may be added for `scripts/dev_tools/discovery/**`.
- **File size:** no file created by this plan may exceed 500 lines
  (`.claude/rules/general-code-change.md` "File Size Limit").
- **Domain neutrality (hard constraint):** no renderer, module, docstring, or test fixture may
  contain a hardcoded domain-specific identifier (`TaskMaster`, `TMW`, `Outlook`, `VSTO`,
  `email`, task-management vocabulary). All human-facing labels come from artifact field values
  only.
- **Determinism:** no wall-clock time or RNG in any rendering path. Any Python collection that
  determines output ordering (dict iteration, set iteration) must be explicitly sorted before
  rendering.
- **I/O boundary separation:** parsing, row-building, and rendering functions are pure (no
  `Path`, no `open()`, no `sys.argv`); only `read_artifact_text`/`write_report` touch the
  filesystem, and only `parse_args`/`main` touch `sys.argv`/process exit codes.
- **No temp files in tests.** All filesystem interaction in unit tests uses `monkeypatch` on
  `Path` methods (matching `tests/scripts/dev_tools/test_format_json.py`) or the `mem_fs_path`
  fixture in `tests/conftest.py`; no `tmp_path` and no real files are created or read by tests.
- **Upstream-dependency seam (execution-time risk, do not resolve here):**
  `legacy-discovery-schemas` (#9002) and `legacy-discovery-validators` (#9003) are not present in
  this worktree. This plan does not author schemas or validators. Every module below is designed
  against the documented contract (`ArtifactValidator` Protocol injected with a lazily-imported
  default binding to `scripts.dev_tools.legacy_discovery_validators.validate_coverage_ledger_text`
  / `validate_parity_matrix_text`) so importing a report module never hard-fails before #9002/#9003
  merge, and so unit tests always inject a fake validator and never import the real upstream
  module. The concrete Coverage Ledger / Parity Matrix field names used below (a top-level
  `"entries"` list, each entry an arbitrary dict with an optional `"id"` field) are a documented,
  minimal, domain-neutral placeholder shape pending #9002; field-mapping finalization is an
  explicit execution-time follow-up once the real schema lands (see "Open Questions / Notes").
- **Evidence root (non-overridable):** all evidence artifacts are written under
  `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/<kind>/`. Writing to
  `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path
  is prohibited. Timestamp format `yyyy-MM-ddTHH-mm`.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline capture and policy read

- [x] [P0-T1] Read the policy files in the required order plus this feature's own requirement
  documents, and record the read.
  - Command: none (read-only review).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-reports-368/evidence/baseline/phase0-instructions-read.md`
    exists and contains `Timestamp:`, `Policy Order:` (listing `CLAUDE.md`,
    `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
    `.claude/rules/quality-tiers.md`, `.claude/rules/python.md`,
    `.claude/rules/python-suppressions.md` in that order), and an explicit list of
    `issue.md`, `spec.md`, `user-story.md`, and `research/research.2026-07-17T15-10.md` read
    alongside the policy files.
- [x] [P0-T2] Capture the Python formatting baseline.
  - Command: `poetry run black --check .`
  - Acceptance: `.../evidence/baseline/py-format.<ts>.md` contains `Timestamp:`, `Command:`,
    `EXIT_CODE:`, `Output Summary:` (pass/fail and count of files that would be reformatted).
- [x] [P0-T3] Capture the Python lint baseline.
  - Command: `poetry run ruff check .`
  - Acceptance: `.../evidence/baseline/py-lint.<ts>.md` contains the four schema fields;
    `Output Summary:` records the Ruff finding count.
- [x] [P0-T4] Capture the Python type-check baseline.
  - Command: `poetry run pyright`
  - Acceptance: `.../evidence/baseline/py-typecheck.<ts>.md` contains the four schema fields;
    `Output Summary:` records the error/warning counts.
- [x] [P0-T5] Capture the Python test + coverage baseline.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `.../evidence/baseline/py-test.<ts>.md` contains the four schema fields;
    `Output Summary:` records passed/failed counts and the numeric total line coverage % and
    branch coverage % (this is the pre-change reference for the Phase 5 coverage-delta check).

### Phase 1 — Discovery subpackage scaffold: I/O boundary and deterministic-rendering helpers

- [x] [P1-T1] Create `scripts/dev_tools/discovery/__init__.py` as an empty subpackage marker.
  - Acceptance: the file exists and `scripts.dev_tools.discovery` imports successfully.
- [x] [P1-T2] Create `tests/scripts/dev_tools/discovery/__init__.py` as an empty test-package
  marker, mirroring `tests/scripts/dev_tools/atomic_executor/__init__.py`.
  - Acceptance: the file exists at that path.
- [x] [P1-T3] Create `scripts/dev_tools/discovery/io.py` defining: an `ArtifactValidator`
  `Protocol` with `__call__(self, text: str) -> list[str]`; an `ArtifactValidationError(Exception)`
  carrying an `errors: list[str]` attribute; `read_artifact_text(path: Path) -> str` (thin
  `path.read_text(encoding="utf-8")` wrapper); `validate_or_raise(text: str, validator:
  ArtifactValidator) -> None` (calls the validator, raises `ArtifactValidationError` when the
  returned list is non-empty); `write_report(path: Path, content: str) -> None` (thin
  `path.write_text(content, encoding="utf-8")` wrapper). No function in this file reads
  `sys.argv` or performs rendering logic.
  - Acceptance: the file exists, is <= 500 lines, and every listed symbol is present with full
    type hints (Pyright-clean).
- [x] [P1-T4] Create `tests/scripts/dev_tools/discovery/test_io.py` covering: `validate_or_raise`
  with a fake validator returning `[]` does not raise; `validate_or_raise` with a fake validator
  returning `["bad field"]` raises `ArtifactValidationError` whose `.errors == ["bad field"]`;
  `read_artifact_text` via `monkeypatch.setattr(Path, "read_text", ...)` returns the stubbed
  text; `write_report` via `monkeypatch.setattr(Path, "write_text", ...)` is called with the
  exact content argument. No `tmp_path` or real file I/O is used.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_io.py -v`
  - Acceptance: all four cases pass.
- [x] [P1-T5] Create `scripts/dev_tools/discovery/rendering.py` defining: `sort_rows(rows:
  list[dict], *, id_field: str = "id") -> list[dict]` (sorts by `row[id_field]` when every row
  has a non-empty string value for `id_field`; otherwise sorts by a case-insensitive join of
  every present string field's value, per `research.2026-07-17T15-10.md` Section 5); and
  `render_pretty_json(data: object) -> str` implementing the single fixed formatting discipline
  `json.dumps(data, sort_keys=True, indent=2) + "\n"` (LF only), matching
  `scripts/dev_tools/format_json.py` line 55's canonicalization precedent. Neither function
  reads wall-clock time or randomness.
  - Acceptance: the file exists, is <= 500 lines, both functions are fully type-hinted.
- [x] [P1-T6] Create `tests/scripts/dev_tools/discovery/test_rendering.py` covering:
  `sort_rows` on rows supplied in reverse-`id_field` order returns ascending `id_field` order;
  `sort_rows` on rows with no `id_field` present falls back to the case-insensitive
  joined-field sort and produces a stable order; `render_pretty_json` on a fixed sample dict
  asserts the exact literal expected string (byte-for-byte, not a fuzzy comparison); calling
  `render_pretty_json` twice on the same input dict asserts the two returned strings are
  identical (determinism property).
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_rendering.py -v`
  - Acceptance: all four cases pass.

### Phase 2 — Coverage report: parse → build rows → render → CLI

- [x] [P2-T1] Create `scripts/dev_tools/discovery/coverage_report.py` defining:
  `parse_coverage_ledger(text: str) -> dict` (`json.loads(text)`); `build_coverage_rows(artifact:
  dict) -> tuple[list[dict], dict]` returning `(rendering.sort_rows(artifact.get("entries", [])),
  {"total_entries": len(artifact.get("entries", []))})`; `render_coverage_report(rows: list[dict],
  summary: dict) -> str` returning
  `rendering.render_pretty_json({"summary": summary, "entries": rows})`;
  `_default_coverage_ledger_validator(text: str) -> list[str]` which lazily imports
  `from scripts.dev_tools.legacy_discovery_validators import validate_coverage_ledger_text`
  inside the function body and returns its result (import happens only when this default is
  actually invoked, never at module import time); `parse_args(argv: Sequence[str] | None) ->
  argparse.Namespace` with a required `--input` and optional `--output`; `main(argv: Sequence[str]
  | None = None) -> int` wiring `read_artifact_text` → `validate_or_raise` (using
  `_default_coverage_ledger_validator` unless a test-injected validator parameter is supplied) →
  `parse_coverage_ledger` → `build_coverage_rows` → `render_coverage_report` → `write_report` (or
  stdout when `--output` is omitted), catching `ArtifactValidationError` to print one error line
  per entry to stderr and return `1`, otherwise returning `0`.
  - Acceptance: the file exists, is <= 500 lines, `parse_args`/`main` match the repository's
    canonical CLI shape (`format_json.py`, `validate_json.py`), and Pyright reports zero errors.
- [x] [P2-T2] Create `tests/scripts/dev_tools/discovery/test_coverage_report.py` with a positive
  test: given a synthetic conforming Coverage Ledger dict with 3 entries (varied `id` values, out
  of order), `build_coverage_rows` then `render_coverage_report` produce sorted entries and a
  correct `total_entries` count in the rendered JSON body.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_coverage_report.py -v`
  - Acceptance: the positive case passes.
- [x] [P2-T3] Add a determinism test to `test_coverage_report.py`: calling
  `render_coverage_report` twice on the same `(rows, summary)` pair asserts the two returned
  strings are byte-identical.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_coverage_report.py -v`
  - Acceptance: the determinism case passes.
- [x] [P2-T4] Add a negative-validation test to `test_coverage_report.py`: injecting a fake
  `ArtifactValidator` that returns `["malformed field X"]` into `main(argv=["--input",
  "ledger.json"], validator=<fake>)` (with `read_artifact_text` monkeypatched to avoid real I/O)
  asserts `main` returns `1`, the error text is printed to stderr, and a monkeypatched
  `write_report`/stdout-write spy was never called.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_coverage_report.py -v`
  - Acceptance: the negative case passes.
- [x] [P2-T5] Add an empty-ledger edge-case test to `test_coverage_report.py`: an artifact dict
  with no `"entries"` key renders a header/summary-only body (`total_entries == 0`, `entries ==
  []`) without raising.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_coverage_report.py -v`
  - Acceptance: the empty-ledger case passes.
- [x] [P2-T6] Add a CLI exit-code test to `test_coverage_report.py`: calling
  `main(argv=["--input", "ledger.json"], validator=<passing fake>)` with monkeypatched
  `read_artifact_text`/`write_report` asserts return value `0`; the same call with a
  `<failing fake>` validator asserts return value `1`.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_coverage_report.py -v`
  - Acceptance: both exit-code assertions pass.
- [x] [P2-T7] Add the Poetry console-script entry for the coverage report to root
  `pyproject.toml` under `[tool.poetry.scripts]`:
  `"dev.discovery.coverage-report" = "scripts.dev_tools.discovery.coverage_report:main"`.
  - Acceptance: the line exists verbatim in `pyproject.toml`; `poetry check` reports no error.

### Phase 3 — Parity report: parse → build rows → render → CLI

- [x] [P3-T1] Create `scripts/dev_tools/discovery/parity_report.py` defining the analogous
  pipeline to Phase 2 for the Parity Matrix: `parse_parity_matrix(text: str) -> dict`;
  `build_parity_rows(artifact: dict) -> tuple[list[dict], dict]` (same `"entries"`/`"id"`
  placeholder shape as coverage, returning `{"total_entries": ...}`); `render_parity_report(rows,
  summary) -> str` via `rendering.render_pretty_json`; `_default_parity_matrix_validator(text:
  str) -> list[str]` lazily importing
  `from scripts.dev_tools.legacy_discovery_validators import validate_parity_matrix_text` inside
  the function body; `parse_args`/`main(argv=None) -> int` with the same required `--input`/
  optional `--output` shape and the same fail-fast/exit-code contract as `coverage_report.py`.
  - Acceptance: the file exists, is <= 500 lines, `parse_args`/`main` match the canonical CLI
    shape, and Pyright reports zero errors.
- [x] [P3-T2] Create `tests/scripts/dev_tools/discovery/test_parity_report.py` with a positive
  test: a synthetic conforming Parity Matrix dict with 3 out-of-order entries renders sorted
  entries and a correct `total_entries` count.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -v`
  - Acceptance: the positive case passes.
- [x] [P3-T3] Add a determinism test to `test_parity_report.py`: `render_parity_report` called
  twice on the same `(rows, summary)` pair returns byte-identical strings.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -v`
  - Acceptance: the determinism case passes.
- [x] [P3-T4] Add a negative-validation test to `test_parity_report.py`: a fake
  `ArtifactValidator` returning non-empty errors causes `main` to return `1`, print the errors,
  and never call `write_report`.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -v`
  - Acceptance: the negative case passes.
- [x] [P3-T5] Add an empty-matrix edge-case test to `test_parity_report.py`: an artifact dict
  with no `"entries"` key renders a header/summary-only body without raising.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -v`
  - Acceptance: the empty-matrix case passes.
- [x] [P3-T6] Add a CLI exit-code test to `test_parity_report.py`: a passing injected validator
  yields `main(...) == 0`; a failing injected validator yields `main(...) == 1`.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_parity_report.py -v`
  - Acceptance: both exit-code assertions pass.
- [x] [P3-T7] Add the Poetry console-script entry for the parity report to root `pyproject.toml`
  under `[tool.poetry.scripts]`:
  `"dev.discovery.parity-report" = "scripts.dev_tools.discovery.parity_report:main"`.
  - Acceptance: the line exists verbatim in `pyproject.toml`; `poetry check` reports no error.

### Phase 4 — Completion report: aggregate readiness across artifacts

- [x] [P4-T1] Create `scripts/dev_tools/discovery/completion_report.py` defining:
  `build_completion_summary(coverage_artifact: dict, parity_artifact: dict) -> dict` returning a
  dict with one entry per artifact category (`"coverage_ledger"`, `"parity_matrix"`), each an
  object `{"present": True, "entry_count": len(artifact.get("entries", []))}`, plus a top-level
  `"readiness"` field equal to `"ready"` (both artifacts were validated successfully — validation
  already occurred in `main` before this function is called) — this function performs no
  validation itself, only aggregation, per the v1 scope restricted to Coverage Ledger + Parity
  Matrix (`spec.md` "Completion-report scope risk"); `render_completion_report(summary: dict) ->
  str` via `rendering.render_pretty_json`; `parse_args(argv) -> argparse.Namespace` with two
  required flags, `--coverage-input` and `--parity-input` (an explicit, unambiguous naming
  deviation from `spec.md`'s generic repeated `--input` example — documented in "Open Questions /
  Notes" below), plus optional `--output`; `main(argv=None) -> int` wiring: read + validate the
  coverage input (via `_default_coverage_ledger_validator`-equivalent injected validator), read +
  validate the parity input (via the parity-equivalent injected validator) — if either validator
  returns non-empty errors, print all errors from both to stderr and return `1` without calling
  `build_completion_summary` or any write function; otherwise call `build_completion_summary`,
  `render_completion_report`, and write the result, returning `0`.
  - Acceptance: the file exists, is <= 500 lines, `parse_args`/`main` match the canonical CLI
    shape, and Pyright reports zero errors.
- [x] [P4-T2] Create `tests/scripts/dev_tools/discovery/test_completion_report.py` with a
  positive test: synthetic conforming Coverage Ledger (2 entries) and Parity Matrix (3 entries)
  dicts produce a summary with `entry_count` 2 and 3 respectively and `readiness == "ready"`.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_completion_report.py -v`
  - Acceptance: the positive case passes.
- [x] [P4-T3] Add a determinism test to `test_completion_report.py`: `render_completion_report`
  called twice on the same summary dict returns byte-identical strings.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_completion_report.py -v`
  - Acceptance: the determinism case passes.
- [x] [P4-T4] Add a negative-validation test to `test_completion_report.py`: a fake coverage
  validator returning non-empty errors (with a passing fake parity validator) causes `main` to
  return `1`, print the coverage errors, and never call `build_completion_summary` or
  `write_report` (assert via a monkeypatched spy on each).
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_completion_report.py -v`
  - Acceptance: the negative case passes.
- [x] [P4-T5] Add an empty-artifacts edge-case test to `test_completion_report.py`: both
  Coverage Ledger and Parity Matrix dicts have no `"entries"` key; `build_completion_summary`
  returns `entry_count` `0` for both categories and `readiness == "ready"` (validation, not entry
  count, gates readiness in v1) without raising.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_completion_report.py -v`
  - Acceptance: the empty-artifacts case passes.
- [x] [P4-T6] Add a CLI exit-code test to `test_completion_report.py`: both fake validators
  passing yields `main(argv=["--coverage-input", "a.json", "--parity-input", "b.json"]) == 0`;
  either fake validator failing yields `main(...) == 1`.
  - Command: `poetry run pytest tests/scripts/dev_tools/discovery/test_completion_report.py -v`
  - Acceptance: both exit-code assertions pass.
- [x] [P4-T7] Add the Poetry console-script entry for the completion report to root
  `pyproject.toml` under `[tool.poetry.scripts]`:
  `"dev.discovery.completion-report" = "scripts.dev_tools.discovery.completion_report:main"`.
  - Acceptance: the line exists verbatim in `pyproject.toml`; `poetry check` reports no error.

### Phase 5 — Domain-neutrality verification, coverage delta, AC mapping, and final QA loop

- [x] [P5-T1] Verify no domain-specific identifier appears anywhere under
  `scripts/dev_tools/discovery/` or `tests/scripts/dev_tools/discovery/`.
  - Command: `rg -in "taskmaster|\\btmw\\b|outlook|vsto|task-management" scripts/dev_tools/discovery tests/scripts/dev_tools/discovery`
  - Acceptance: `.../evidence/qa-gates/domain-neutrality-check.<ts>.md` records the command and
    `EXIT_CODE:` (a ripgrep no-match exit code, e.g. `1`, confirming zero matches) plus
    `Output Summary:` stating zero matches found.
- [x] [P5-T2] Run the final Python formatting gate.
  - Command: `poetry run black --check .`
  - Acceptance: `.../evidence/qa-gates/final-py-format.<ts>.md` contains the four schema fields
    and `EXIT_CODE: 0`.
- [x] [P5-T3] Run the final Python lint gate.
  - Command: `poetry run ruff check .`
  - Acceptance: `.../evidence/qa-gates/final-py-lint.<ts>.md` contains the four schema fields
    and `EXIT_CODE: 0`.
- [x] [P5-T4] Run the final Python type-check gate.
  - Command: `poetry run pyright`
  - Acceptance: `.../evidence/qa-gates/final-py-typecheck.<ts>.md` contains the four schema
    fields and `EXIT_CODE: 0` (0 errors).
- [x] [P5-T5] Run the final Python test + coverage gate.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `.../evidence/qa-gates/final-py-test.<ts>.md` contains the four schema fields,
    `EXIT_CODE: 0`, and `Output Summary:` recording passed count and numeric total line % (>= 85)
    and branch % (>= 75). Note: if P5-T2, P5-T3, P5-T4, or P5-T5 fails or rewrites any file,
    restart the loop from P5-T2.
- [x] [P5-T6] Verify coverage deltas and the `omit`-list invariant.
  - Command: compare P0-T5's baseline coverage against P5-T5's post-change coverage; inspect
    `[tool.coverage.run] omit` in `pyproject.toml`.
  - Acceptance: `.../evidence/qa-gates/coverage-delta.<ts>.md` records baseline line/branch %,
    post-change line/branch %, and the new-module coverage % for
    `scripts/dev_tools/discovery/**`; confirms no regression on changed/pre-existing lines and
    both post-change thresholds are met; confirms `pyproject.toml`'s `[tool.coverage.run] omit`
    list contains no entry matching `scripts/dev_tools/discovery/**` (unchanged from baseline).
- [x] [P5-T7] Verify each acceptance criterion maps to concrete implementation/test tasks.
  - Acceptance: `.../evidence/qa-gates/ac-mapping.<ts>.md` maps each of the eight ACs — AC-1
    (coverage report rendered deterministically) → P2-T1, P2-T2, P2-T3; AC-2 (parity report
    rendered deterministically) → P3-T1, P3-T2, P3-T3; AC-3 (completion report presents
    aggregate readiness) → P4-T1, P4-T2, P4-T3; AC-4 (byte-identical output for identical input)
    → P1-T6, P2-T3, P3-T3, P4-T3; AC-5 (fail-fast validation, non-zero exit) → P1-T3, P1-T4,
    P2-T4, P2-T6, P3-T4, P3-T6, P4-T4, P4-T6; AC-6 (`dev.discovery.*` Poetry console-script CLI
    entry points) → P2-T7, P3-T7, P4-T7; AC-7 (no domain-specific identifiers) → P5-T1; AC-8
    (tests satisfy quality-tier coverage policy) → P0-T5, P5-T5, P5-T6 — each to the concrete
    evidence artifact or test file satisfying it.

## Test Plan

- Unit (pure functions): `sort_rows`/`render_pretty_json` (`test_rendering.py`);
  `build_coverage_rows`/`render_coverage_report` (`test_coverage_report.py`);
  `build_parity_rows`/`render_parity_report` (`test_parity_report.py`);
  `build_completion_summary`/`render_completion_report` (`test_completion_report.py`).
- Unit (I/O boundary, monkeypatched, no temp files): `read_artifact_text`, `write_report`,
  `validate_or_raise` (`test_io.py`).
- Unit (CLI, direct `main(argv=[...])` calls with injected validators, no subprocess): exit-code
  and fail-fast-before-write assertions in `test_coverage_report.py`, `test_parity_report.py`,
  `test_completion_report.py`.
- Determinism: render-twice byte-identical-string assertions in every report test module plus
  `test_rendering.py`.
- Negative: fake `ArtifactValidator` returning non-empty errors in every report test module.
- Edge case: empty-artifact (zero `"entries"`) rendering in every report test module.
- Domain-neutrality: static grep check (P5-T1); no test fixture uses a domain-specific label.
- Coverage evidence: baseline `evidence/baseline/py-test.<ts>.md`; post-change
  `evidence/qa-gates/final-py-test.<ts>.md`; comparison `evidence/qa-gates/coverage-delta.<ts>.md`.

## Open Questions / Notes

- **Field-mapping placeholder (execution-time follow-up).** The Coverage Ledger / Parity Matrix
  field-level shape used by this plan (a top-level `"entries"` list, each entry an arbitrary dict
  with an optional `"id"` sort key) is a minimal, domain-neutral placeholder documented as an
  upstream-dependency assumption in `spec.md` "Constraints & Risks" and `research.2026-07-17T15-10.md`
  Section 6/Section 9 "Open Items for Execution Time". When `legacy-discovery-schemas` (#9002)
  merges with concrete field names, `build_coverage_rows`/`build_parity_rows` must be revisited
  to route through a `resolve_field_mapping(artifact: dict) -> FieldMapping` dispatcher per
  `spec.md` "Versioning or backward-compatibility constraints" — this revisit is out of scope
  for this plan and is not required for the acceptance criteria as drafted.
- **Completion-report CLI flag naming deviation.** `spec.md`'s "Example invocations" section
  shows `--input` passed twice for the completion report without a type discriminator. This plan
  uses explicit `--coverage-input`/`--parity-input` flags instead (Phase 4) to keep CLI parsing
  unambiguous without depending on an unverified type-indicating field inside the not-yet-defined
  schema. This is a plan-level design decision, not a resolution of the upstream schema shape.
- **Upstream validator module path is unverified.** `scripts.dev_tools.legacy_discovery_validators`
  is the module path this plan's lazily-imported default validator bindings target, per the
  canonical pattern in `research.2026-07-17T15-10.md` Section 3.2. The exact module path is
  confirmed only once `legacy-discovery-validators` (#9003) merges; until then, every test in
  this plan injects a fake `ArtifactValidator` and the lazy-import default path is never
  exercised by tests.
- **Out of scope (confirmed, not implemented by this plan):** MCP tool exposure and VS Code
  command exposure of `dev.discovery.*` (owned by `legacy-discovery-mcp-vscode`, #9011); actual
  migration execution; authoring the Coverage Ledger / Parity Matrix schemas or their validators.
