# Remediation Inputs — expose-placeholder-commands (#92)

- **Timestamp:** 2026-03-11T22-55
- **Authoritative source for remediation planning:** this file
- **Base branch assumption:** `main`

## Required fixes

1. **Regenerate or otherwise realign the packaged extension entry point**
   - **Files:**
     - `extensions/drm-copilot/out/extension.js`
     - `extensions/drm-copilot/package.json`
     - any tracked source-map/build outputs associated with the extension entry point
   - **Current problem:** `package.json` loads `./out/extension.js`, but that file still contains `PLACEHOLDER_COMMAND_SPECS`, `registerPlaceholderCommands`, and the four retired placeholder command IDs.
   - **Expected behavior:** The extension artifact loaded by VS Code must register the live handlers for `newPotentialBugEntry`, `newPotentialEntry`, `potentialToIssue`, and `newActiveFeatureFolder`, with no remaining placeholder registrations.
   - **Acceptance criteria impacted:**
     - All four placeholder commands are replaced with real command handlers that invoke the bundled scripts
     - The `PLACEHOLDER_COMMAND_SPECS` array and `registerPlaceholderCommands` function are removed
     - Extension activation registers all new commands without errors
   - **Minimum verification:**
     - `npm --prefix extensions/drm-copilot run test:unit`
     - confirm `extensions/drm-copilot/out/extension.js` contains the live command IDs and no placeholder IDs/symbols
     - confirm sideload/packaged runtime uses the updated command surface

2. **Update the push-down rewrite catalog to the live command IDs**
   - **Files:**
     - `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
     - related tests under `tests/scripts/dev_tools/` as needed
   - **Current problem:** The rewrite catalog still emits `drmCopilotExtension.newActiveFeatureFolderPlaceholder`, `potentialToIssuePlaceholder`, `newPotentialBugEntryPyPlaceholder`, and `newPotentialEntryPsPlaceholder`.
   - **Expected behavior:** Rewritten references must target the live command IDs and live command titles introduced by this feature.
   - **Acceptance criteria impacted:**
     - All four placeholder commands are replaced with real command handlers that invoke the bundled scripts
     - Command IDs are renamed and package contributions are updated
     - Placeholder infrastructure is removed from the effective command surface
   - **Minimum verification:**
     - `poetry run pytest --cov-report=term-missing`
     - grep/static inspection confirms no retired placeholder command IDs remain in the rewrite catalog

3. **Close the documented file-picker UX gap for `potentialToIssue`**
   - **Files:**
     - `extensions/drm-copilot/src/extension.ts`
     - `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
   - **Current problem:** `showOpenDialog(...)` does not set the documented default folder for `docs/features/potential/`.
   - **Expected behavior:** The file picker should open with a deterministic default location under the workspace’s potential-docs folder, matching the spec and user story.
   - **Acceptance criteria impacted:**
     - Each command gathers required user input (file paths, names, types) via VS Code input boxes or quick picks before execution
   - **Minimum verification:**
     - `npm --prefix extensions/drm-copilot run test:unit`
     - a focused Jest assertion verifies the `showOpenDialog` options include the expected default path

4. **Add regression coverage for runtime-package drift and rewrite-catalog drift**
   - **Files:**
     - extension tests and/or packaging checks under `extensions/drm-copilot/test/`
     - Python tests covering `push_down_copilot_customizations_rewrites.py`
   - **Current problem:** Existing tests validate `src/extension.ts` but do not validate the packaged `out/extension.js` entry point or the rewrite catalog, allowing the two blocking mismatches to ship unnoticed.
   - **Expected behavior:** Future QA should fail if the packaged extension entry point or rewrite catalog drifts from the intended live command surface.
   - **Acceptance criteria impacted:**
     - Existing placeholder command tests are replaced with tests for the new real commands
     - Extension activation registers all new commands without errors
   - **Minimum verification:**
     - `npm --prefix extensions/drm-copilot run test:unit`
     - `poetry run pytest --cov-report=term-missing`

## Do not do

- Do **not** weaken or bypass tests to make the review green.
- Do **not** leave `out/extension.js` stale while claiming the feature is complete.
- Do **not** keep placeholder command IDs in rewrite output after this feature.
- Do **not** widen scope into unrelated extension refactors.
- Do **not** modify policy documents under `.github/instructions/`.

## Acceptance-criteria gaps still open

1. **Live packaged extension command surface is still placeholder-based**
   - **Minimum change required:** update/regenerate the runtime artifact used by `package.json`.
2. **Push-down published command references still point at retired placeholder IDs**
   - **Minimum change required:** update the rewrite catalog and add coverage.
3. **`potentialToIssue` file picker is not deterministic per spec/user story**
   - **Minimum change required:** set and test `defaultUri`.
4. **Regression coverage does not protect packaged runtime/rewrite surfaces**
   - **Minimum change required:** add checks that fail when those surfaces drift.
