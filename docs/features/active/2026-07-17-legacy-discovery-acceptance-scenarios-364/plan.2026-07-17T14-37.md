# legacy-discovery-acceptance-scenarios - Plan

- **Issue:** #364
- **Parent (optional):** epic `legacy-discovery-and-parity` (child feature; epic placeholder #9009)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-37
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature

## Required References

- Standing instructions: `CLAUDE.md`
- General code change policy: `.claude/rules/general-code-change.md`
- General unit test policy: `.claude/rules/general-unit-test.md`
- Python toolchain and coding standards: `.claude/rules/python.md`
- Python suppressions policy: `.claude/rules/python-suppressions.md`
- Quality tiers: `.claude/rules/quality-tiers.md` (feature complexity band C3; coverage uniform: line >= 85%, branch >= 75%)
- Authoritative spec: `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/spec.md`
- User story: `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/user-story.md`
- Research: `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/research/2026-07-17T15-00-acceptance-scenario-generation-research.md`

**All work must comply with these policies; do not duplicate their content here.**

## Scope Summary

Deliver a deterministic, domain-neutral acceptance-scenario generator:

- New Python module `scripts/dev_tools/generate_acceptance_scenarios.py` with `def main(argv=None) -> int`, its own argparse parser, and exit codes `0`/`1`.
- Schema-location seam `resolve_discovery_schema(schema_name, *, root, version=None) -> Path`.
- Named projection/adapter read surfaces for the Feature Contract, Parity Matrix, and Runtime Characterization Scenario inputs.
- Deterministic JSON scenario-document output via `json.dumps(sort_keys=True, indent=2, ensure_ascii=False) + "\n"` with stable scenario ordering and sorted input paths; no seeded RNG or injected clock.
- One `pyproject.toml` `[tool.poetry.scripts]` line mapping `dev.discovery.generate-acceptance-scenarios` to `scripts.dev_tools.generate_acceptance_scenarios:main`.
- Tests at `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` covering positive, determinism, negative/malformed-input, seam, and CLI categories.

Domain-neutrality invariant: no TaskMaster/TMW/Outlook/VSTO/email/task-management identifiers in the generator module or its output field names. Module and test file each stay under 500 lines.

## Evidence Location Invariant

All evidence artifacts MUST be written under `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/evidence/<kind>/`. Canonical sub-paths: `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/other/`. Any `artifacts/`-rooted evidence path is prohibited. Each command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (with numeric coverage headline values for test steps).

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Compliance and Python Baseline Capture

- [x] [P0-T1] Read the policy files in required order (`CLAUDE.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/rules/python.md`; `.claude/rules/python-suppressions.md`) and record the read.
  - Acceptance: `evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read in the required order.
- [x] [P0-T2] Run `poetry run black --check .` from the repository root and capture the baseline formatting state.
  - Command: `poetry run black --check .`
  - Acceptance: `evidence/baseline/black-baseline.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and count of files that would be reformatted).
- [x] [P0-T3] Run `poetry run ruff check .` from the repository root and capture the baseline lint state.
  - Command: `poetry run ruff check .`
  - Acceptance: `evidence/baseline/ruff-baseline.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail and error count).
- [x] [P0-T4] Run `poetry run pyright` from the repository root and capture the baseline type-check state.
  - Command: `poetry run pyright`
  - Acceptance: `evidence/baseline/pyright-baseline.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T5] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the repository root and capture baseline test and numeric coverage state.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `evidence/baseline/pytest-baseline.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including baseline total line coverage percent and branch coverage percent as numeric headline values, plus passed/failed test counts.
- [x] [P0-T6] Confirm the target production module and test file are absent before implementation and record the fail-before basis (no test currently exercises the generator).
  - Acceptance: `evidence/regression-testing/fail-before-exception.2026-07-17T14-37.md` records `Timestamp:`, `WhyFailingRunImpossible:` (the module and test do not yet exist, so no failing run can be produced), `SearchScope:` (`scripts/dev_tools/`, `tests/scripts/dev_tools/`), `SearchPatterns:` (`generate_acceptance_scenarios.py`, `test_generate_acceptance_scenarios.py`), and `SearchResult: none`.

### Phase 1 — Module Scaffold, Schema-Location Seam, and Input Projections

- [x] [P1-T1] Create `scripts/dev_tools/generate_acceptance_scenarios.py` with the module header: `from __future__ import annotations`, standard-library imports (`argparse`, `hashlib`, `json`, `sys`, `pathlib.Path`), a `TYPE_CHECKING`-guarded `Sequence` import from `collections.abc`, and a module docstring.
  - Acceptance: `poetry run python -c "import scripts.dev_tools.generate_acceptance_scenarios"` exits `0`.
- [x] [P1-T2] Implement `resolve_discovery_schema(schema_name: str, *, root: Path, version: str | None = None) -> Path` in `scripts/dev_tools/generate_acceptance_scenarios.py`, raising `FileNotFoundError` whose message names the expected `schemas/vN/<schema_name>.schema.json` convention until #9002 lands.
  - Acceptance: the function exists with keyword-only `root`/`version` and raises `FileNotFoundError` whose message contains the literal `schemas/v` convention string.
- [x] [P1-T3] Implement three named projection functions in `scripts/dev_tools/generate_acceptance_scenarios.py` (`project_feature_contract`, `project_parity_matrix`, `project_runtime_characterization`) that map each input document to the generator read surface and ignore unknown/extra fields.
  - Acceptance: each function accepts a `dict` input and returns a typed projection object/dict exposing only the fields defined in spec.md "Input Read Surfaces"; unknown keys are ignored.
- [x] [P1-T4] Create `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` with module imports, the `mem_fs_path` fixture reference from `tests/conftest.py`, and no `tmp_path` or real temp-file usage.
  - Acceptance: file exists and `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py --collect-only` exits `0`.
- [x] [P1-T5] Add schema-location seam tests to `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`: assert `resolve_discovery_schema` raises `FileNotFoundError` naming the `schemas/vN/` convention when the schema tree is absent, and monkeypatch the seam to prove downstream code calls it rather than a hard-coded path.
  - Acceptance: both seam tests pass under `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -k seam`.
- [x] [P1-T6] Add projection unit tests to `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` covering positive projection and unknown-field-ignored behavior for each of the three projections.
  - Acceptance: projection tests pass under `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -k projection`.
- [x] [P1-T7] Run `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` and record the Phase 1 test result.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`
  - Acceptance: `evidence/regression-testing/phase1-tests.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (passed/failed counts).

### Phase 2 — Deterministic Generation Core

- [x] [P2-T1] Implement a pure scenario-assembly function in `scripts/dev_tools/generate_acceptance_scenarios.py` that combines the three projections into scenario objects carrying `id`, `title`, `feature_ref`, `parity_ref`, `characterization_ref`, `given`, `when`, `then`, and `evidence_refs`, with `given`/`when`/`then` as structured string arrays.
  - Acceptance: the function returns a list of scenario dicts with exactly those keys; `parity_ref` and `characterization_ref` are `null` when no matching row/scenario applies.
- [x] [P2-T2] Implement deterministic stable-`id` derivation (from the feature identifier plus parity/characterization reference, no RNG) and a total-order sort applied to the `scenarios` array using the key `(feature_ref, parity_ref, characterization_ref, id)` in `scripts/dev_tools/generate_acceptance_scenarios.py`.
  - Acceptance: `id` is derived only from input fields; the `scenarios` array is emitted in the stable total-order regardless of input traversal order.
- [x] [P2-T3] Implement `source_digest` as a SHA-256 hex digest over the concatenated canonicalized inputs in `scripts/dev_tools/generate_acceptance_scenarios.py`; no wall-clock value is read.
  - Acceptance: `source_digest` is a 64-character lowercase hex string that changes only when input content changes; `datetime`/`time` wall-clock reads are absent from the module.
- [x] [P2-T4] Implement a `build_document` function in `scripts/dev_tools/generate_acceptance_scenarios.py` assembling the top-level fields `$schema`, `schema_version`, `generator` (constant `"dev.discovery.acceptance-scenarios"`), `source_digest`, and `scenarios` (sorted array from P2-T2).
  - Acceptance: the returned document contains exactly those five top-level fields and the constant `generator` value.
- [x] [P2-T5] Implement a canonical serialize helper in `scripts/dev_tools/generate_acceptance_scenarios.py` returning `json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False) + "\n"`.
  - Acceptance: the helper output ends with a single trailing newline and uses two-space indentation with sorted keys.
- [x] [P2-T6] Implement sorted input-path collection in `scripts/dev_tools/generate_acceptance_scenarios.py` so collected paths are sorted before processing and generation does not depend on `glob`/`rglob` yield order.
  - Acceptance: input paths are passed through `sorted(...)` before read; no internal `set` is serialized directly.
- [x] [P2-T7] Add positive generation tests to `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` asserting the structured `given`/`when`/`then` mapping and the derived stable `id` from conforming inputs.
  - Acceptance: positive generation tests pass under `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -k positive`.
- [x] [P2-T8] Add determinism tests to `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`: generate twice from identical in-memory inputs and assert byte-identical output, and shuffle input ordering and assert identical output.
  - Acceptance: determinism tests pass under `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -k determinism`.
- [x] [P2-T9] Add a domain-neutrality assertion test to `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` verifying the module source and generated output field names contain none of the prohibited identifiers (TaskMaster, TMW, Outlook, VSTO, email, task-management).
  - Acceptance: the domain-neutrality test passes and fails if any prohibited identifier is introduced.
- [x] [P2-T10] Run `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` and record the Phase 2 test result.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`
  - Acceptance: `evidence/regression-testing/phase2-tests.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (passed/failed counts).

### Phase 3 — CLI Surface and Poetry Console-Script

- [x] [P3-T1] Implement `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace` in `scripts/dev_tools/generate_acceptance_scenarios.py` building its own `argparse.ArgumentParser` with input path arguments for the three artifacts (feature contract, parity matrix, runtime characterization scenario), an `--output` argument (stdout when omitted), and a `--check` flag mirroring `format_json` semantics.
  - Acceptance: `parse_args([...])` returns a namespace exposing the three input paths, `output`, and `check`.
- [x] [P3-T2] Implement `def main(argv: Sequence[str] | None = None) -> int` in `scripts/dev_tools/generate_acceptance_scenarios.py` calling `parse_args(argv or sys.argv[1:])`, resolving root via `Path(__file__).resolve().parents[2]`, invoking the pure generation pipeline, printing status, and returning `0`/`1`; add `if __name__ == "__main__": sys.exit(main())`.
  - Acceptance: `main` returns `0` on success and `1` on failure; the module-guard line is present.
- [x] [P3-T3] Implement error handling in `main`/pipeline of `scripts/dev_tools/generate_acceptance_scenarios.py` for missing input file, non-object JSON root, JSON parse error, document missing a required field, and `--check` mismatch, each returning exit code `1` with a clear message.
  - Acceptance: each failure path returns `1` and prints a message naming the specific failure.
- [x] [P3-T4] Add the console-script line `"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"` to the `[tool.poetry.scripts]` table in `pyproject.toml`.
  - Acceptance: `poetry run dev.discovery.generate-acceptance-scenarios --help` exits `0`.
- [x] [P3-T5] Add negative/malformed-input tests to `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` for missing input file, non-object JSON root, JSON parse error, and missing required field, each asserting exit code `1` and a clear message; use `mem_fs_path`.
  - Acceptance: negative tests pass under `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -k negative`.
- [x] [P3-T6] Add CLI tests to `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` for `parse_args` defaults and flags (`--output`, `--check`) and `main([...])` return codes for success, failure, and `--check` mismatch; use `mem_fs_path` for read/write.
  - Acceptance: CLI tests pass under `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -k cli`.
- [x] [P3-T7] Run `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` and record the Phase 3 test result.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`
  - Acceptance: `evidence/regression-testing/phase3-tests.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (passed/failed counts).

### Phase 4 — Final QC Loop and Coverage Verification

Run the full Python toolchain in order: format -> lint -> type-check -> test. If any step changes files or fails, restart from P4-T1 until a single clean pass completes.

- [x] [P4-T1] Run `poetry run black .` from the repository root and record the final formatting result.
  - Command: `poetry run black .`
  - Acceptance: `evidence/qa-gates/black-final.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (files reformatted count); if any file changed, restart the loop from P4-T1.
- [x] [P4-T2] Run `poetry run ruff check .` from the repository root and record the final lint result.
  - Command: `poetry run ruff check .`
  - Acceptance: `evidence/qa-gates/ruff-final.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with zero errors.
- [x] [P4-T3] Run `poetry run pyright` from the repository root and record the final type-check result.
  - Command: `poetry run pyright`
  - Acceptance: `evidence/qa-gates/pyright-final.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with zero errors.
- [x] [P4-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` from the repository root and record the final test result with numeric coverage.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Acceptance: `evidence/qa-gates/pytest-final.2026-07-17T14-37.md` records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including post-change total line coverage percent, branch coverage percent, and the per-module coverage for `scripts/dev_tools/generate_acceptance_scenarios.py` as numeric headline values, plus passed/failed test counts.
- [x] [P4-T5] Verify the file-size limit for `scripts/dev_tools/generate_acceptance_scenarios.py` and `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py`.
  - Acceptance: `evidence/other/file-size-check.2026-07-17T14-37.md` records the line count of each file and confirms both are under 500 lines.
- [x] [P4-T6] Compare baseline and post-change coverage and verify new/changed-code coverage against thresholds.
  - Acceptance: `evidence/regression-testing/coverage-delta.2026-07-17T14-37.md` reports baseline total coverage (from P0-T5), post-change total coverage (from P4-T4), and new/changed-code coverage for `scripts/dev_tools/generate_acceptance_scenarios.py`, and confirms line coverage >= 85% and branch coverage >= 75% with no regression on changed lines; if any threshold is unmet, the outcome is remediation-required, not PASS.

## Acceptance Criteria Traceability

- Module generates scenarios from the three inputs (spec AC 1; user-story AC 1): P1-T1, P2-T1..P2-T4.
- Top-level and scenario-object fields present (spec AC 2; user-story AC 2): P2-T1, P2-T4, P2-T7.
- Given/When/Then as structured string arrays (spec AC 3): P2-T1, P2-T7.
- Canonical serialization + byte-identical generation (spec AC 4; user-story AC 3): P2-T5, P2-T8.
- Output invariant to input ordering (spec AC 5): P2-T2, P2-T6, P2-T8.
- No seeded RNG / no injected clock; SHA-256 `source_digest` (spec AC 6): P2-T2, P2-T3.
- Named projection/adapter per input (spec AC 7; user-story AC 7): P1-T3, P1-T6.
- `resolve_discovery_schema` seam raises clear error naming `schemas/vN/`; runs against caller-supplied paths (spec AC 8; user-story AC 6): P1-T2, P1-T5.
- Poetry console-script maps to `main`; `def main(argv=None) -> int` with own argparse parser (spec AC 9; user-story AC 5): P3-T1, P3-T2, P3-T4.
- `0`/`1` exit-code convention (spec AC 9): P3-T2, P3-T3, P3-T5, P3-T6.
- No domain-specific identifiers (spec AC 11; user-story AC 4): P2-T9.
- Tests cover all categories, no temp files, thresholds met (spec AC 12; user-story AC 8): P1-T4..P1-T6, P2-T7..P2-T9, P3-T5, P3-T6, P4-T4, P4-T6.

## Test Plan

- Unit / positive: P1-T6, P2-T7.
- Determinism: P2-T8.
- Negative / malformed input: P3-T5.
- Schema-location seam: P1-T5.
- CLI: P3-T6.
- Domain-neutrality: P2-T9.
- Coverage evidence:
  - Baseline artifact: `evidence/baseline/pytest-baseline.2026-07-17T14-37.md`.
  - Post-change artifact: `evidence/qa-gates/pytest-final.2026-07-17T14-37.md`.
  - Comparison artifact: `evidence/regression-testing/coverage-delta.2026-07-17T14-37.md`.

## Open Questions / Notes

- Concrete schema field names and the `schemas/vN/` directory tree are owned by feature #9002; this feature designs against `objective-source.md` section 4 and isolates schema location behind the `resolve_discovery_schema` seam.
- No new third-party dependencies; the feature reuses `json`, `hashlib`, `argparse`, and `pathlib` from the standard library.
