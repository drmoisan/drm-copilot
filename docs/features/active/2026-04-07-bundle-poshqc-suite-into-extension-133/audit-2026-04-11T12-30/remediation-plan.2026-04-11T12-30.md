# Remediation Plan: bundle-poshqc-suite-into-extension-133 (2026-04-11T12-30) - Plan

- **Issue:** #133
- **Parent (optional):** N/A
- **Owner:** developer
- **Last Updated:** 2026-04-11T12-30
- **Status:** Complete
- **Version:** 1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Suppression Policy: [`.github/instructions/python-suppressions.instructions.md`](../../../../.github/instructions/python-suppressions.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance & Context
- [x] [P0-T1] Read `.github/instructions/general-code-change.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, and `.github/instructions/general-unit-test.instructions.md` before touching code
  - Acceptance: Policy files read; no changes to policy documents

### Phase 1 — Fix Ruff TCH003 Lint Error
- [x] [P1-T1] Read `extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py` and identify the `Callable` import at line 29
  - Acceptance: File contents reviewed; `from collections.abc import Callable` located at line 29
- [x] [P1-T2] Move `from collections.abc import Callable` into a `if TYPE_CHECKING:` block in `extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py`; ensure `from __future__ import annotations` is present at the top of the file and that `TYPE_CHECKING` is imported from `typing`
  - Acceptance: The `Callable` import is inside `if TYPE_CHECKING:` block; `from __future__ import annotations` is present
- [x] [P1-T3] Run `poetry run ruff check extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py` and verify exit code 0 with no TCH003 error
  - Acceptance: Ruff exits 0 with no errors for this file
- [x] [P1-T4] Run `poetry run black --check extensions/drm-copilot/resources/templates/validate_orchestration_artifacts.py` and verify formatting is clean
  - Acceptance: Black reports file unchanged
- [x] [P1-T5] Run `poetry run pyright` and verify no new type errors introduced
  - Acceptance: Pyright reports 0 errors, 0 warnings

### Phase 2 — Re-sync C# Orchestrator Bundled Agent Mirror
- [x] [P2-T1] Identify the root C# orchestrator agent file under `.github/agents/` and its corresponding mirror under `extensions/drm-copilot/resources/` by reading `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py` to find the exact file paths used in `test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence`
  - Acceptance: Root agent path and mirror path identified from the test assertions
- [x] [P2-T2] Copy the root agent file content to the mirror location, replacing the existing mirror file so that they are byte-identical
  - Acceptance: Root and mirror files have identical content
- [x] [P2-T3] Run `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py::test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence -x -v` and verify it passes
  - Acceptance: Test passes (1 passed, 0 failed)

### Phase 3 — Full Toolchain Verification
- [x] [P3-T1] Run `poetry run black --check .` and verify all Python files pass formatting
  - Acceptance: Black reports all files unchanged
- [x] [P3-T2] Run `poetry run ruff check .` and verify exit code 0 with no errors
  - Acceptance: Ruff exits 0
- [x] [P3-T3] Run `poetry run pyright` and verify 0 errors, 0 warnings
  - Acceptance: Pyright clean
- [x] [P3-T4] Run `poetry run pytest tests/ -x -q` and verify all tests pass with 0 failures
  - Acceptance: All tests pass (349 passed, 0 failed expected)
- [x] [P3-T5] Run TypeScript toolchain in `extensions/drm-copilot/`: `npm run format && npm run lint && npm run typecheck && npm run test:unit` and verify all pass
  - Acceptance: Prettier, ESLint, TSC, Jest all exit 0

## Test Plan

- Unit: `poetry run pytest tests/ -x -q` (all Python tests pass, 0 failures)
- Lint: `poetry run ruff check .` (exit code 0)
- Parity: `poetry run pytest tests/scripts/dev_tools/test_csharp_orchestration_contracts.py -x` (passes)
- TypeScript: `npm run test:unit` (228 tests pass)

## Open Questions / Notes

- Both fixes are low-complexity: one import move and one file copy/sync.
- This plan was authored by the feature_code_review_agent in-session because the atomic_planner agent could not be independently invoked within this review conversation. The plan follows the atomic-plan-contract structure with [P#-T#] identifiers and binary completion criteria.
