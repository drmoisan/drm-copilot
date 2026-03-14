# Remediation Inputs — extension-template-resolution (#93)

## Required fixes

1. **Add the missing `newPotentialEntry` integration scenario**
   - **Files:** `extensions/drm-copilot/test/extension.integration.test.ts` (preferred) and any closely related extension test helper/fixture files needed for the scenario.
   - **Current gap:** The branch proves `-TemplateRoot` argument injection in `extension.test.ts`, but it does not verify the issue’s required runtime scenario: running `drmCopilotExtension.newPotentialEntry` in a workspace that does **not** contain `docs/features/templates/` and succeeding via bundled templates.
   - **Expected behavior:** The integration test must demonstrate that the command executes successfully against a template-less workspace and uses the bundled `extensions/drm-copilot/resources/feature-templates/potential/template.md` asset path rather than depending on workspace-local templates.
   - **Acceptance criteria:** Satisfies `issue.md` criterion 4.
   - **Verification commands:**
     - `npm --prefix extensions/drm-copilot run format`
     - `npm --prefix extensions/drm-copilot run lint`
     - `npm --prefix extensions/drm-copilot run typecheck`
     - `npm --prefix extensions/drm-copilot run test:unit -- --coverage`

2. **Bring changed Python helper functions into compliance with the intent-first docstring policy**
   - **Files:** `scripts/dev_tools/new_potential_bug_entry.py`, `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`
   - **Locations:** helper definitions at lines 25, 33, 47, 52, 64, 104, 148, and 163 in both files.
   - **Current gap:** The repo’s mandatory Python commenting policy requires robust function/method docstrings for agent-authored code. These helper functions currently have no function docstrings.
   - **Expected behavior:** Add contract-level docstrings that describe purpose, args, returns, raises, and side effects for each helper. Keep the bundled mirror aligned with the canonical script.
   - **Acceptance criteria:** Policy compliance remediation (not a feature AC), required for a clean audit outcome.
   - **Verification commands:**
     - `poetry run black --check .`
     - `poetry run ruff check`
     - `poetry run pyright`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`

3. **Synchronize plan/checklist status after remediation**
   - **Files:** `docs/features/active/2026-03-12-extension-template-resolution-93/plan.2026-03-12T19-08.md`, `docs/features/active/2026-03-12-extension-template-resolution-93/issue.md`
   - **Current gap:** The remediation workflow must explicitly resync plan and acceptance tracking after fixes land.
   - **Expected behavior:**
     - Perform a baseline sync immediately after remediation-plan creation.
     - Perform a final sync after remediation execution.
     - Leave unmet AC items unchecked; check off only criteria that are implemented and freshly verified.
   - **Acceptance criteria:** Required by remediation workflow contract.
   - **Verification commands:**
     - Re-read `issue.md` and `plan.2026-03-12T19-08.md` after verification runs
     - Confirm AC/checklist state matches the evidence on disk

## Unmet acceptance criteria and minimum changes required

| Criterion | Current status | Minimum change required |
|---|---|---|
| `Integration test: run new-potential-entry in workspace without docs/features/templates/ → should succeed using bundled templates` | Not met | Add and pass an integration-level automated test in the extension test suite that exercises this exact workspace scenario and records success through bundled templates. |

## Do not do

- Do **not** weaken repo policies, toolchain commands, or acceptance criteria wording.
- Do **not** replace the missing integration scenario with a manual-only note unless automation is demonstrably impossible and a concrete exception is documented.
- Do **not** introduce scope creep into unrelated `.github/agents`, prompt, or customization files while fixing the feature gap.
- Do **not** silently skip baseline/final sync of `issue.md` and `plan.2026-03-12T19-08.md`.
- Do **not** leave the bundled Python mirror out of sync with the canonical `scripts/dev_tools` implementation.
