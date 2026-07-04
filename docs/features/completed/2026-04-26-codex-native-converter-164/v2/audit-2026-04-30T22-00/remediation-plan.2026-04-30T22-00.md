# codex-native-converter v2 (#164) — Remediation Plan

- **Issue:** #164
- **Parent:** N/A
- **Owner:** Unassigned
- **Last Updated:** 2026-04-30T22-00
- **Status:** pending
- **Version:** 1

## Context

This plan addresses structural and coverage remediation items identified in the post-implementation feature review for codex-native-converter v2. All five items are self-contained. No behavioral changes to the converter are required. All acceptance criteria from the feature (Issue #164) are already delivered.

**Authoritative spec:** `docs/features/active/2026-04-26-codex-native-converter-164/remediation-inputs.2026-04-30T22-00.md`

**Branch:** `feature/20260429090101-port-codex-skill` (remediation commits should be made to this branch)

**Required references (read, do not restate):**
- `general-code-change.instructions.md` — 500-line limit, toolchain loop
- `general-unit-test.instructions.md` — coverage thresholds
- `python-code-change.instructions.md` — Black, Ruff, Pyright, Pytest
- `python-unit-test.instructions.md` — Pytest conventions, no temp files

**Fail-closed evidence rule:** Every baseline artifact task and final-QA artifact task must record `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` in the artifact. No evidence-backed task may be marked complete without the artifact. Coverage tasks must record numeric coverage values.

---

## Strategy

Five targeted changes:
1. **R1** — Split `engine.py` (1015 lines) by extracting v2 stage functions into `pipeline.py`.
2. **R2** — Split `models.py` (599 lines) by extracting v2 intermediate types into `models_intermediate.py`.
3. **R3** — Split `reporting.py` (512 lines) by extracting topology helpers into `_reporting_topology.py`.
4. **R4** — Add unit tests in `test_section_intent.py` for LAUNCHER_ONLY, UNSUPPORTED, and fallback branches.
5. **R5** — Add one unit test in `test_intermediate_state.py` for non-empty-state serialization.

All changes are Python-only. No TypeScript changes required. The public API of `engine.py`, `models.py`, and `reporting.py` must remain identical to pre-remediation.

---

## Work Breakdown

### Phase 0 — Baseline Capture [0%]

- [x] [P0-T1] Read policy documents in required order: `general-code-change.instructions.md`, `general-unit-test.instructions.md`, `python-code-change.instructions.md`, `python-unit-test.instructions.md`. Record at `evidence/remediation/phase0-policy-read.md`.
- [x] [P0-T2] Capture baseline Python format state. Command: `poetry run black --check scripts tests`. Record exit code and output at `evidence/remediation/baseline-python-format.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T3] Capture baseline Python lint state. Command: `poetry run ruff check scripts tests`. Record at `evidence/remediation/baseline-python-lint.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T4] Capture baseline Python type check state. Command: `poetry run pyright`. Record at `evidence/remediation/baseline-python-typecheck.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T5] Capture baseline Python test + coverage. Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing`. Record at `evidence/remediation/baseline-python-tests.md`. Must include: overall coverage %, converter package coverage %, `section_intent.py` line coverage %, `intermediate_state.py` line coverage %. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T6] Record current line counts for the three files to be split. Commands: `(Get-Content scripts/dev_tools/codex_native_converter/engine.py).Count`, `(Get-Content scripts/dev_tools/codex_native_converter/models.py).Count`, `(Get-Content scripts/dev_tools/codex_native_converter/reporting.py).Count`. Record at `evidence/remediation/baseline-line-counts.md`.

---

### Phase 1 — R1: Split `engine.py` [0%]

- [x] [P1-T1] Review `engine.py` to identify all v2 stage functions and their private helpers eligible for extraction. Record the target function list (names + line ranges) as an annotation in `evidence/remediation/r1-engine-split-plan.md`. Criteria: functions added or substantially changed in the v2 PR commits (`14c4eca`, `2a33fe3`).
- [x] [P1-T2] Create `scripts/dev_tools/codex_native_converter/pipeline.py` containing the extracted stage functions and their private helpers. Ensure:
  - All extracted functions have their full docstrings and type annotations preserved.
  - The file includes the `from __future__ import annotations` import.
  - All imports required by the extracted functions are present in `pipeline.py`.
  - The file has a module-level docstring describing its purpose.
- [x] [P1-T3] Update `engine.py` to import the extracted functions from `pipeline.py` and delegate to them. Verify:
  - `engine.py` line count ≤500.
  - `pipeline.py` line count ≤500.
  - The public `convert` function signature is unchanged.
  - No caller outside `engine.py` needs to be updated.
- [x] [P1-T4] Run Python toolchain checkpoint after R1. Commands in order:
  - `poetry run black scripts tests` — must exit 0 (or only auto-format the new file).
  - `poetry run ruff check scripts tests` — must exit 0.
  - `poetry run pyright` — must exit 0.
  - `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing` — must exit 0, ≥1060 tests passing.
  Record results at `evidence/remediation/r1-toolchain-checkpoint.md`. Include exit codes and test counts.

---

### Phase 2 — R2: Split `models.py` [0%]

- [x] [P2-T1] Create `scripts/dev_tools/codex_native_converter/models_intermediate.py` containing the six v2 intermediate types (`SourceArtifact`, `SourceSection`, `SemanticCue`, `SectionIntent`, `PlannedEmission`, `TranslationTrace`) and their associated v2 enums. Ensure:
  - All moved types have their docstrings preserved.
  - The file has a module-level docstring describing its purpose.
  - All required imports are present in `models_intermediate.py`.
- [x] [P2-T2] Update `models.py` to add re-exports for the moved types for backward compatibility. Verify:
  - `models.py` line count ≤500.
  - `models_intermediate.py` line count ≤500.
  - Existing imports (`from scripts.dev_tools.codex_native_converter.models import SourceArtifact`) continue to resolve.
- [x] [P2-T3] Run Python toolchain checkpoint after R2. Same commands as P1-T4. Record at `evidence/remediation/r2-toolchain-checkpoint.md`.

---

### Phase 3 — R3: Split `reporting.py` [0%]

- [x] [P3-T1] Identify the topology view builder and section-level report methods in `reporting.py` to extract (approximately the last 20-30 lines added in the v2 commits, or the topology-related private methods). Create `scripts/dev_tools/codex_native_converter/_reporting_topology.py` with the extracted helpers. Ensure:
  - Extracted helpers have their docstrings preserved.
  - File has a module-level docstring.
  - All imports required by the extracted helpers are present.
- [x] [P3-T2] Update `reporting.py` to import from `_reporting_topology.py` and delegate. Verify:
  - `reporting.py` line count ≤500.
  - `_reporting_topology.py` line count ≤500.
- [x] [P3-T3] Run Python toolchain checkpoint after R3. Same commands as P1-T4. Record at `evidence/remediation/r3-toolchain-checkpoint.md`. Verify topology end-to-end tests (`test_reporting_topology_end_to_end.py`) all pass.

---

### Phase 4 — R4: Add `section_intent.py` unit tests [0%]

- [x] [P4-T1] Review `section_intent.py` lines 163-166, 179-182, 203-204, 214-215, 240-243 to understand each branch condition. Document the triggering input for each group in a comment or docstring in the new test.
- [x] [P4-T2] Add the following tests to `tests/scripts/dev_tools/codex_native_converter/test_section_intent.py`:
  - `test_classify_section_intent_returns_launcher_only_for_sections_with_only_launch_directives` (covers lines 163-166)
  - `test_classify_section_intent_returns_unsupported_for_sections_with_unrecognized_content` (covers lines 179-182)
  - Tests for lines 203-204, 214-215, 240-243 (add one test per line group or combine where the triggering condition is closely related).
  All tests must:
  - Use `_make_section` and `_make_artifact` factories already in the test file.
  - Have docstrings.
  - Use no temporary files.
  - Pass deterministically.
- [x] [P4-T3] Run Python targeted coverage to verify `section_intent.py` ≥90%. Command: `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing`. Record at `evidence/remediation/r4-coverage-checkpoint.md`. Must show `section_intent.py` ≥90%.
- [x] [P4-T4] Run full Python toolchain checkpoint after R4. Record at `evidence/remediation/r4-toolchain-checkpoint.md`.

---

### Phase 5 — R5: Add `intermediate_state.py` non-empty-state unit test [0%]

- [x] [P5-T1] Add the following test to `tests/scripts/dev_tools/codex_native_converter/test_intermediate_state.py`:
  - `test_write_intermediate_state_artifacts_serializes_non_empty_collections_correctly`
  - Construct an `IntermediateState` with at least one populated entry in each of the four collection fields.
  - Use `_RecordingFileSystem` to capture outputs without real filesystem writes.
  - Assert: all four files written, each is valid JSON, each JSON is a non-empty list.
  - The test must cover lines 96, 128, 150, 174 (the `if collection:` branches).
- [x] [P5-T2] Run Python targeted coverage to verify `intermediate_state.py` ≥90%. Command: same as P4-T3. Record at `evidence/remediation/r5-coverage-checkpoint.md`. Must show `intermediate_state.py` ≥90%.
- [x] [P5-T3] Run full Python toolchain checkpoint after R5. Record at `evidence/remediation/r5-toolchain-checkpoint.md`.

---

### Phase 6 — Final QA Loop [100%]

- [x] [P6-T1] Run final Python format. Command: `poetry run black scripts tests`. Must exit 0 with 0 files reformatted. Record at `evidence/remediation/final-python-format.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P6-T2] Run final Python lint. Command: `poetry run ruff check scripts tests`. Must exit 0 with `All checks passed!`. Record at `evidence/remediation/final-python-lint.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P6-T3] Run final Python type check. Command: `poetry run pyright`. Must exit 0 with 0 errors. Record at `evidence/remediation/final-python-typecheck.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P6-T4] Run final Python tests + coverage (repo-wide). Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing`. Must exit 0, ≥1060 passing, ≥84% repo-wide coverage. Record at `evidence/remediation/final-python-tests.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with overall coverage %, total tests.
- [x] [P6-T5] Run final Python targeted coverage (converter package). Command: `poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing`. Must show: converter package ≥95%, `section_intent.py` ≥90%, `intermediate_state.py` ≥90%, `engine.py` ≥90% (no regression), `models.py` ≥90% (no regression), `reporting.py` ≥90% (no regression). Record at `evidence/remediation/final-python-targeted-coverage.md`. Include: `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with per-file coverage values.
- [x] [P6-T6] Verify line counts of all split files. Command: `Get-ChildItem scripts/dev_tools/codex_native_converter/*.py | ForEach-Object { "$((Get-Content $_).Count) $($_.Name)" } | Sort-Object -Descending`. Must show: `engine.py` ≤500, `models.py` ≤500, `reporting.py` ≤500, all new split files ≤500. Record at `evidence/remediation/final-line-counts.md`.

---

### Phase 7 — Reduced Audit [100%]

- [x] [P7-T1] Confirm all five remediation items (R1–R5) are resolved: all production files ≤500 lines, `section_intent.py` ≥90% coverage, `intermediate_state.py` ≥90% coverage. Write a one-paragraph remediation closure note at `evidence/remediation/remediation-closure.md` citing the final-QA evidence artifact paths.
- [x] [P7-T2] Confirm no regressions against the pre-remediation state: test count ≥1060, repo-wide coverage ≥84%, TypeScript state unchanged (no TypeScript files modified). Record at `evidence/remediation/remediation-closure.md`.

---

## Evidence Artifact Index

All artifacts for this plan are written under:
`docs/features/active/2026-04-26-codex-native-converter-164/evidence/remediation/`

| Phase | Artifact | Required Fields |
|-------|---------|-----------------|
| P0-T2 | `baseline-python-format.md` | Timestamp, Command, EXIT_CODE, Output Summary |
| P0-T3 | `baseline-python-lint.md` | Timestamp, Command, EXIT_CODE, Output Summary |
| P0-T4 | `baseline-python-typecheck.md` | Timestamp, Command, EXIT_CODE, Output Summary |
| P0-T5 | `baseline-python-tests.md` | Timestamp, Command, EXIT_CODE, Output Summary, coverage % values |
| P0-T6 | `baseline-line-counts.md` | Timestamp, Command, EXIT_CODE, Output Summary |
| P1-T1 | `r1-engine-split-plan.md` | Function list, line ranges |
| P1-T4 | `r1-toolchain-checkpoint.md` | Timestamp, Command, EXIT_CODE, Output Summary per step |
| P2-T3 | `r2-toolchain-checkpoint.md` | Timestamp, Command, EXIT_CODE, Output Summary per step |
| P3-T3 | `r3-toolchain-checkpoint.md` | Timestamp, Command, EXIT_CODE, Output Summary per step |
| P4-T3 | `r4-coverage-checkpoint.md` | Timestamp, Command, EXIT_CODE, section_intent.py coverage % |
| P4-T4 | `r4-toolchain-checkpoint.md` | Timestamp, Command, EXIT_CODE, Output Summary per step |
| P5-T2 | `r5-coverage-checkpoint.md` | Timestamp, Command, EXIT_CODE, intermediate_state.py coverage % |
| P5-T3 | `r5-toolchain-checkpoint.md` | Timestamp, Command, EXIT_CODE, Output Summary per step |
| P6-T1 | `final-python-format.md` | Timestamp, Command, EXIT_CODE, Output Summary |
| P6-T2 | `final-python-lint.md` | Timestamp, Command, EXIT_CODE, Output Summary |
| P6-T3 | `final-python-typecheck.md` | Timestamp, Command, EXIT_CODE, Output Summary |
| P6-T4 | `final-python-tests.md` | Timestamp, Command, EXIT_CODE, coverage %, test count |
| P6-T5 | `final-python-targeted-coverage.md` | Timestamp, Command, EXIT_CODE, per-file coverage values |
| P6-T6 | `final-line-counts.md` | Timestamp, Command, EXIT_CODE, line count per file |
| P7-T1 | `remediation-closure.md` | Closure note, evidence artifact paths |
