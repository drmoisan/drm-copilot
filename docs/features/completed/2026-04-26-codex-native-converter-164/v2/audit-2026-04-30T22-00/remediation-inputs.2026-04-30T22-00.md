# Remediation Inputs: codex-native-converter v2 (#164)

**Review timestamp:** 2026-04-30T22-00
**Source artifacts:**
- `policy-audit.2026-04-30T22-00.md` (§8, Gaps and Exceptions)
- `code-review.2026-04-30T22-00.md` (Findings Table, Required Actions)
- `feature-audit.2026-04-30T22-00.md` (§6, Policy Compliance Notes)

**Classification:** Structural + coverage hygiene. All 5 items are self-contained. No behavioral changes are required.

---

## Required Remediation Items

### R1 — Split `engine.py` (1015 lines → ≤500 lines each)

**Severity:** Major
**File:** `scripts/dev_tools/codex_native_converter/engine.py`
**Current state:** 1015 lines. The v2 additions grew the file from ~471 to 1015 lines.
**Target state:** `engine.py` ≤500 lines after split.

**Approach:**
- Extract the v2 stage functions (`_classify_sections`, `_plan_emissions`, and their private helpers) into a new module, tentatively named `pipeline.py` (or `engine_pipeline.py`) in the same package directory.
- `engine.py` remains the public entry-point module and imports the extracted stage functions from `pipeline.py`.
- The public API (`convert`, `RunOptions`, `ConverterRunResult`) must remain accessible from `engine.py` without change to callers.
- No behavioral change. No renaming of public symbols.
- Update imports in all callers of the extracted functions (likely only `engine.py` itself and test files that reach internal helpers).
- Run the full Python toolchain after the split: Black → Ruff → Pyright → Pytest.

**Acceptance criteria for R1:**
- `engine.py` line count ≤500.
- `pipeline.py` (or the equivalent new module) line count ≤500.
- All 1060 Python tests pass with zero failures.
- Pyright exits 0.
- The public surface of `engine.py` (the `convert` function signature) is unchanged.

---

### R2 — Split `models.py` (599 lines → ≤500 lines each)

**Severity:** Minor
**File:** `scripts/dev_tools/codex_native_converter/models.py`
**Current state:** 599 lines. The v2 additions (+212 lines) introduced six new intermediate types and three new enums.
**Target state:** `models.py` ≤500 lines after split.

**Approach:**
- Move the six v2 intermediate representation types (`SourceArtifact`, `SourceSection`, `SemanticCue`, `SectionIntent`, `PlannedEmission`, `TranslationTrace`) and their associated v2 enums into a new `models_intermediate.py` module in the same package directory.
- In `models.py`, add explicit re-exports for backward compatibility: `from .models_intermediate import SourceArtifact, SourceSection, SemanticCue, SectionIntent, PlannedEmission, TranslationTrace`.
- Callers that import directly from `models.py` will continue to work unchanged; callers that import from `models_intermediate.py` directly will also work.
- Run the full Python toolchain after the split.

**Acceptance criteria for R2:**
- `models.py` line count ≤500.
- `models_intermediate.py` line count ≤500.
- All 1060 Python tests pass.
- Pyright exits 0.
- Existing import paths (e.g., `from scripts.dev_tools.codex_native_converter.models import SourceArtifact`) continue to resolve without change.

---

### R3 — Split `reporting.py` (512 lines → ≤500 lines)

**Severity:** Minor
**File:** `scripts/dev_tools/codex_native_converter/reporting.py`
**Current state:** 512 lines. Marginally over the limit (12 lines).
**Target state:** `reporting.py` ≤500 lines after split.

**Approach:**
- Identify the topology view builder methods added in v2 (the section-level report generators). Extract these private methods into a `_reporting_topology.py` helper module (underscore prefix signals it is internal to the package).
- `reporting.py` imports the extracted helpers from `_reporting_topology.py` and delegates.
- Alternatively, if the topology methods are sufficiently small and cohesive, they may be inlined into `reporting.py` by removing unused utility code or consolidating duplicate logic to bring the line count below 500.
- Run the full Python toolchain after the change.

**Acceptance criteria for R3:**
- `reporting.py` line count ≤500.
- All 1060 Python tests pass.
- Pyright exits 0.
- Report artifacts produced by the topology tests (`test_reporting_topology_end_to_end.py`) are structurally identical to pre-remediation outputs.

---

### R4 — Add unit tests for `section_intent.py` to reach ≥90% coverage

**Severity:** Minor
**File:** `tests/scripts/dev_tools/codex_native_converter/test_section_intent.py`
**Current state:** `section_intent.py` is at 76% coverage. Uncovered lines: 163-166, 179-182, 203-204, 214-215, 240-243.
**Target state:** `section_intent.py` ≥90% coverage.

**Approach:**
Add the following isolated unit tests to `test_section_intent.py`. Each test constructs a minimal `SourceSection` (via the `_make_section` factory already in the test file) and asserts the returned `SectionIntentKind`.

Required new tests:

1. **`test_classify_section_intent_returns_launcher_only_for_sections_with_only_launch_directives`**
   - Arrange: a `SourceSection` with body content that matches the LAUNCHER_ONLY pattern (lines that contain only launcher/dispatch directives with no substantive guidance).
   - Act: call `classify_section_intent(section)`.
   - Assert: `result.intent_kind == SectionIntentKind.LAUNCHER_ONLY`.

2. **`test_classify_section_intent_returns_unsupported_for_sections_with_unrecognized_content`**
   - Arrange: a `SourceSection` with body content that does not match any of the seven supported intent kinds.
   - Act: call `classify_section_intent(section)`.
   - Assert: `result.intent_kind == SectionIntentKind.UNSUPPORTED`.

3. Additional tests for lines 203-204, 214-215, 240-243: review the specific branch conditions in `section_intent.py` at those lines and construct the minimal inputs that reach each branch. Each test should be deterministic and self-contained.

All new tests must:
- Use the `_make_section` and `_make_artifact` helper factories already defined in `test_section_intent.py`.
- Follow the `test_<subject>_<scenario>` naming convention.
- Include a short docstring describing the scenario and expected outcome.
- Not use temporary files or external resources.

**Acceptance criteria for R4:**
- `section_intent.py` coverage ≥90%.
- All new tests pass.
- No modifications to `section_intent.py` production code.

---

### R5 — Add unit test for `intermediate_state.py` non-empty-state serialization to reach ≥90% coverage

**Severity:** Minor
**File:** `tests/scripts/dev_tools/codex_native_converter/test_intermediate_state.py`
**Current state:** `intermediate_state.py` is at 87% coverage. Uncovered lines: 96, 128, 150, 174 (all `if collection:` branches for non-empty collections).
**Target state:** `intermediate_state.py` ≥90% coverage.

**Approach:**
Add one new test to `test_intermediate_state.py`:

**`test_write_intermediate_state_artifacts_serializes_non_empty_collections_correctly`**
- Arrange: Construct an `IntermediateState` with at least one entry in each of the four collections: `source_artifacts`, `source_sections`, `section_intents`, `planned_emissions`. Use the `_make_section` and `_make_artifact` factories already in the test file. Use the `_RecordingFileSystem` stub to capture written file contents.
- Act: Call `write_intermediate_state_artifacts(state, run_options, file_system)` with `emit_intermediate_state=True`.
- Assert:
  - All four output files are written.
  - Each written file's content is valid JSON (parseable with `json.loads`).
  - Each parsed JSON value is a non-empty list (at least one entry per file).
  - The entries contain the expected keys (e.g., source artifact entries contain `"source_path"`, `"sections"`; section entries contain `"heading"`, `"start_line"`, `"end_line"`).

This single test exercises all four uncovered `if collection:` branches in one pass.

All new tests must:
- Use the `_RecordingFileSystem` stub (not real filesystem writes).
- Follow the `test_<subject>_<scenario>` naming convention.
- Include a docstring.
- Not use temporary files.

**Acceptance criteria for R5:**
- `intermediate_state.py` coverage ≥90%.
- New test passes.
- No modifications to `intermediate_state.py` production code.

---

## Constraints and Do-Not-Do List

- **Do not change the public API** of `engine.py`, `models.py`, or `reporting.py`. Callers must not require updates.
- **Do not add new features** beyond the structural splits and coverage additions described above.
- **Do not weaken or bypass policy checks** to close these findings. The goal is structural compliance.
- **Do not suppress coverage requirements** using `# pragma: no cover` or equivalent.
- **Do not reduce test count** for existing tests.
- **Do not use temporary files** in any new test.

---

## Toolchain Requirements

After each remediation item (or after all items in a batch), run the full Python toolchain in order:

1. `poetry run black scripts tests`
2. `poetry run ruff check scripts tests`
3. `poetry run pyright`
4. `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing`

All four steps must pass without errors in the final pass. The converter package targeted coverage run is also required to verify per-file gains:

```
poetry run pytest tests/scripts/dev_tools/codex_native_converter --cov=scripts.dev_tools.codex_native_converter --cov-report=term-missing
```

The targeted run must show `section_intent.py` ≥90% and `intermediate_state.py` ≥90% before the remediation is considered complete.
