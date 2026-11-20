# Remediation Inputs: Bundle PoshQC Suite into Extension (#133)

**Date:** 2026-04-11T12-30  
**Source:** `policy-audit.2026-04-11T12-30.md`, `code-review.2026-04-11T12-30.md`  
**Feature Folder:** `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133`

---

## Required Fixes

### 1. Fix Ruff TCH003 lint error in bundled template wrapper

- **File:** `extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py`
- **Line:** 29
- **Problem:** `from collections.abc import Callable` is not used at runtime — it is only referenced in a string-form `cast("Callable[..., int]", ...)` call. Ruff TCH003 requires moving it to a `TYPE_CHECKING` block.
- **Expected behavior:** `poetry run ruff check .` returns exit code 0 with no errors.
- **Fix approach:** Move `from collections.abc import Callable` into `if TYPE_CHECKING:` block. The import is already guarded by `from __future__ import annotations` if present; otherwise add that import. Verify that `cast()` still works correctly at runtime.
- **Acceptance criteria:**
  - `poetry run ruff check .` exits 0.
  - `poetry run black --check .` still passes.
  - `poetry run pyright` still passes.
- **Verification commands:**
  ```bash
  poetry run ruff check extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py
  poetry run black --check extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py
  poetry run pyright
  ```

### 2. Re-sync C# orchestrator bundled agent mirror

- **Root agent file:** Identify the root agent file under `.github/agents/` that corresponds to the C# orchestrator.
- **Mirror file:** Identify the matching mirror under `extensions/drm-copilot/resources/` (the C# customization bundle).
- **Problem:** The `tools:` YAML list in the bundled mirror differs in ordering and/or quoting from the root agent file. This breaks the parity test `test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence` in `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py`.
- **Expected behavior:** The mirror file content exactly matches the root agent file content. The parity test passes.
- **Fix approach:** Copy the root agent file content to the mirror location, replacing the drifted copy.
- **Acceptance criteria:**
  - `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -x` passes.
  - The full Python test suite (`poetry run pytest tests/ -x -q`) passes with 0 failures.
- **Verification commands:**
  ```bash
  poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py::test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence -x -v
  poetry run pytest tests/ -x -q
  ```

### 3. Full toolchain clean pass

After fixes 1 and 2, run the complete toolchain loop and verify a clean pass:

- **TypeScript:** Prettier → ESLint → TSC → Jest (expected: all pass)
- **Python:** Black → Ruff → Pyright → Pytest (expected: all pass, 0 failures)
- **PowerShell:** PoshQC format → PoshQC analyze → Pester (expected: all pass)

---

## Do Not Do

- Do NOT modify any policy or instruction documents.
- Do NOT add new suppressions (no `# noqa`, no `# type: ignore`) for these fixes.
- Do NOT change the structure or behavior of any tested code — these are parity/lint fixes only.
- Do NOT modify test expectations or weaken test assertions.
- Do NOT expand scope beyond the two identified fixes.
- Do NOT modify `spec.md`, `user-story.md`, or `issue.md`.

---

## Acceptance Criteria Not Yet Met

All 10 feature acceptance criteria evaluate as PASS. The remediation items are **policy-compliance blockers** (toolchain must complete a clean pass), not acceptance-criteria gaps.

| Criterion | Status | Gap |
|-----------|--------|-----|
| Ruff clean pass | FAIL | TCH003 in bundled template wrapper |
| Full test suite pass | FAIL | 1 regression in C# mirror parity test |
| All other AC | PASS | No gaps |
