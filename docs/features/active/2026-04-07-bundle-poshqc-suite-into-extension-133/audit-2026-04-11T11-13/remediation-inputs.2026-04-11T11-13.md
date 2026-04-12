# Remediation Inputs — 2026-04-07-bundle-poshqc-suite-into-extension-133

## Required Fixes

1. **Recreate missing canonical baseline and QA evidence, then resynchronize the plan checklist.**
   - **Files / locations:** `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/`, `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/qa-gates/`, `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/plan.2026-04-07T08-52.md`
   - **Expected behavior:** Every completed baseline and QA task in the plan has a corresponding artifact on disk that includes `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Any unchecked/checked mismatch in the plan is corrected to match the artifacts that actually exist.
   - **Acceptance criteria:** The feature folder contains the required evidence artifacts; the plan no longer claims completed work without evidence.
   - **Verification commands/tasks:**
     - `Get-ChildItem docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence -Recurse`
     - `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts feature-audit <feature-audit-path>`

2. **Raise changed-surface TypeScript coverage for the new MCP input parsing and semantic-tool paths.**
   - **Files / locations:** `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tools.ts`, `extensions/drm-copilot/test/`
   - **Expected behavior:** Add Jest tests for success, missing-field, wrong-type, and invalid-enum cases covering `resolveRunPoshQCSuiteToolInput` and `resolveValidateOrchestrationArtifactsToolInput` until changed-surface coverage meets repository thresholds.
   - **Acceptance criteria:** The changed TypeScript input-validation surface reaches at least 90% coverage for the newly added behavior, and the Jest coverage report no longer shows `mcp-tool-inputs.ts` as a low-coverage outlier.
   - **Verification commands/tasks:**
     - `Push-Location extensions/drm-copilot; npm run test -- --coverage; Pop-Location`
     - `Push-Location extensions/drm-copilot; npm run lint; npm run typecheck; Pop-Location`

3. **Raise Python coverage for the new orchestration-artifact validator to the repository threshold.**
   - **Files / locations:** `scripts/dev_tools/validate_orchestration_artifacts.py`, `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
   - **Expected behavior:** Add targeted Pytest cases for unsupported artifact types, malformed receipt payloads, and remaining CLI failure branches until the new module reaches at least 90% line coverage.
   - **Acceptance criteria:** `scripts/dev_tools/validate_orchestration_artifacts.py` measures at least 90% coverage in a focused run, with Black, Ruff, and Pyright still clean.
   - **Verification commands/tasks:**
     - `poetry run black --check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
     - `poetry run ruff check scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
     - `poetry run pyright scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`
     - `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-report=term-missing`

4. **Raise PowerShell coverage for the expanded scan-folder-aware PoshQC module.**
   - **Files / locations:** `scripts/powershell/PoshQC/PoshQC.psm1`, `tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1`, and any additional focused Pester files needed in `tests/scripts/powershell/PoshQC/`
   - **Expected behavior:** Add focused Pester coverage for the new and changed scan-folder, wrapper, analyzer-autofix, and test-path behaviors so the changed module no longer reports 31.12% focused coverage.
   - **Acceptance criteria:** The changed PowerShell behavior is covered to repository expectations, and the review evidence no longer depends on a low-coverage focused run.
   - **Verification commands/tasks:**
     - Non-mutating `Invoke-Formatter` comparison across the changed PowerShell files
     - `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -ScanFolders @('scripts/powershell/PoshQC','extensions/drm-copilot/resources/powershell/PoshQC','extensions/drm-copilot/resources/templates','tests/scripts/powershell/PoshQC')`
     - Focused `Invoke-Pester` coverage run against the updated Pester suite

5. **Update the extension README so the advertised MCP surface matches the implemented tool surface.**
   - **Files / locations:** `extensions/drm-copilot/README.md`
   - **Expected behavior:** The `Exposed MCP Tools` and `MCP Input Summary` sections list the newly added `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`, `run_poshqc_analyze_autofix`, `run_poshqc_suite`, and `validate_orchestration_artifacts` tools with their input contracts.
   - **Acceptance criteria:** Documentation consistently reflects the public MCP surface introduced by this branch.
   - **Verification commands/tasks:**
     - Direct README inspection against `extensions/drm-copilot/src/repo-automation-service.ts` and `extensions/drm-copilot/src/mcp-tools.ts`

6. **Reduce the oversized PowerShell module and bundled mirror to comply with the file-size policy while preserving parity.**
   - **Files / locations:** `scripts/powershell/PoshQC/PoshQC.psm1`, `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`, and any new helper/module files required to split the implementation
   - **Expected behavior:** Refactor the PoshQC implementation into cohesive submodules or helper files so no production or reusable script exceeds 500 lines, while preserving the exported API and the repo/bundled parity contract.
   - **Acceptance criteria:** The module and bundled mirror comply with the 500-line repository limit, and parity/behavior tests still pass.
   - **Verification commands/tasks:**
     - `(Get-Content scripts/powershell/PoshQC/PoshQC.psm1 | Measure-Object -Line).Lines`
     - `(Get-Content extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 | Measure-Object -Line).Lines`
     - Re-run the relevant PowerShell and TypeScript tests after the split

## Do Not Do

- Do not weaken repository policy requirements, coverage gates, or validator rules to make the review pass.
- Do not mark plan tasks complete unless the corresponding evidence artifact exists on disk.
- Do not introduce repo-local fallbacks that bypass the extension’s bundled-resource execution model.
- Do not break the parity contract between the repo-root PoshQC assets and the bundled extension copies.
- Do not use temporary-file test strategies or add broad suppressions to satisfy lint/type checks.

## Unmet Acceptance Criteria and Minimum Changes Required

1. **`spec.md` — The extension and PowerShell test suites cover the new wrapper, command wiring, MCP dispatch, and folder-selection behavior.**
   - **Minimum change required:** Raise changed-surface TypeScript and PowerShell coverage to repository thresholds and capture the resulting QA artifacts under the feature folder.

2. **`spec.md` — Documentation and feature artifacts reflect the new bundled workflow and its usage.**
   - **Minimum change required:** Update the README’s advertised MCP tool surface and recreate the missing feature-folder evidence artifacts referenced by the plan.

3. **`user-story.md` — Tests and documentation are updated for the new bundled workflow and folder-selection behavior.**
   - **Minimum change required:** Complete the coverage improvements above and update the README/tool documentation so the documentation and test evidence are both complete.
