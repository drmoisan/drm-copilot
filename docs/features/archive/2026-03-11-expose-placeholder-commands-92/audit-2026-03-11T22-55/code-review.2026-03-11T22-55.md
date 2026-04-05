# Code Review — expose-placeholder-commands (#92)

- **Timestamp:** 2026-03-11T22-55
- **Branch reviewed:** `feature/expose-placeholder-commands-92`
- **Base branch assumption:** `main` (defaulted because `PRBaseBranch` input was not provided)
- **Feature folder selection rule:** Used the user-provided active folder `docs/features/active/2026-03-11-expose-placeholder-commands-92/`, which also matches the issue suffix `-92`.
- **Scope note:** The refreshed `artifacts/pr_context.summary.txt` reflects committed `HEAD`; the implementation under review is currently present as working-tree changes, so this review uses direct file inspection plus current verification runs as primary evidence.

## Executive summary

This branch replaces the four placeholder command registrations in `extensions/drm-copilot/src/extension.ts` with real handlers, adds bundled Python/PowerShell resources, updates command contributions in `extensions/drm-copilot/package.json`, and adds Jest/Pytest coverage for the new command flows. The implementation quality is generally solid: argument validation is reasonable, the bundled Python import rewrites are correct, the PowerShell helper is co-located as required, and the TypeScript/Python/PowerShell toolchains all pass on the current working tree.

The review outcome is **REQUEST CHANGES** because two delivery blockers remain:

1. The shipped extension entry point still points to stale compiled output in `extensions/drm-copilot/out/extension.js`, which continues to register the retired placeholder commands.
2. The push-down rewrite catalog in `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py` still rewrites script references to the retired placeholder command IDs.

A smaller spec-compliance gap also remains: `potentialToIssue` does not set the documented default open location for the file picker.

## Acceptance criteria assessment

| Criterion | Status | Evidence |
|---|---|---|
| All four placeholder commands are replaced with real command handlers that invoke the bundled scripts | **FAIL** | `src/extension.ts` registers live handlers, but `out/extension.js` still registers placeholder commands and `package.json` still loads `./out/extension.js` as the extension main entry point. |
| Each command's Python/PowerShell modules and dependencies are bundled under `resources/scripts/dev_tools/` or `resources/templates/` as appropriate | **PASS** | Bundled Python modules exist under `extensions/drm-copilot/resources/scripts/dev_tools/`; PowerShell files exist under `extensions/drm-copilot/resources/templates/`. |
| Wrapper templates follow the same thin-adapter pattern as `collect_pr_context.py` and `push_down_copilot_customizations.py` | **PARTIAL** | `resources/templates/new_active_feature_folder.py` and `resources/templates/potential_to_issue.py` are thin wrappers; `resources/templates/new_potential_bug_entry.py` is a copied self-contained implementation instead of a thin adapter. |
| Each command gathers required user input via VS Code UI before execution | **PARTIAL** | All four handlers prompt before execution, but `potentialToIssue` omits the spec’d `defaultUri` for `docs/features/potential/`. |
| Command IDs are renamed and `package.json` contributions are updated | **PASS** | `extensions/drm-copilot/package.json` contributes `drmCopilotExtension.newPotentialBugEntry`, `newPotentialEntry`, `potentialToIssue`, and `newActiveFeatureFolder`. |
| `PLACEHOLDER_COMMAND_SPECS` and `registerPlaceholderCommands` are removed | **FAIL** | Removed from `src/extension.ts`, but still present in `out/extension.js`, which is the package main. |
| Existing placeholder tests are replaced with tests for the new real commands | **PASS** | `extension.placeholder-commands.test.ts` is deleted; new command tests exist in `extension.test.ts`, `extension.potential-to-issue.test.ts`, and `extension.new-active-feature-folder.test.ts`. |
| All TypeScript toolchain gates pass | **PASS** | Final run in this review: Prettier, ESLint, TSC, and Jest all passed; Jest reported 5 suites / 66 tests passing. |
| Extension activation registers all new commands without errors | **FAIL** | The source file does; the packaged runtime entry point does not, because `out/extension.js` is stale. |

## Findings

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| **Blocker** | `extensions/drm-copilot/out/extension.js` | lines 45-157 | The compiled runtime artifact still contains `PLACEHOLDER_COMMAND_SPECS`, `registerPlaceholderCommands`, and the four retired placeholder registrations. | Rebuild and commit/update the extension runtime output, or add a deterministic build/prepublish step that regenerates `out/` before side-load/packaging. Add a regression check that the built artifact matches the live command surface. | `extensions/drm-copilot/package.json` loads `./out/extension.js` as the extension `main`, so a sideloaded/published extension will still behave like the old placeholder implementation even though `src/extension.ts` is updated. | `package.json` sets `"main": "./out/extension.js"`; `out/extension.js` still registers `drmCopilotExtension.newActiveFeatureFolderPlaceholder`, `potentialToIssuePlaceholder`, `newPotentialBugEntryPyPlaceholder`, and `newPotentialEntryPsPlaceholder`. |
| **Major** | `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py` | lines 82-109 | The rewrite catalog still maps the four workflows to placeholder command IDs and placeholder titles. | Update the rewrite catalog to the live command IDs/titles introduced by this feature and add coverage that prevents future drift. | Any pushed-down customization that references these workflows will still be rewritten to dead/retired placeholder command IDs, which directly contradicts the new command surface and updated README text. | Static inspection shows `command_id="drmCopilotExtension.newActiveFeatureFolderPlaceholder"` and the other three placeholder IDs still present in the catalog. |
| **Minor** | `extensions/drm-copilot/src/extension.ts` | around lines 261-266 | `potentialToIssue` opens a file picker without the documented `defaultUri` pointing at `docs/features/potential/`. | Set `defaultUri` relative to the workspace root and add a Jest assertion for the file-picker options. | The user story and spec both call for the file dialog to default to the potential-docs folder; current behavior depends on editor state instead of a deterministic starting location. | `showOpenDialog` is called with `canSelectMany`, `openLabel`, and `filters`, but no `defaultUri`. |
| **Minor** | `extensions/drm-copilot/test/*.test.ts` | suite-wide | Test coverage exercises `../src/extension` only; it does not validate the built `out/extension.js` package entry point or the rewrite catalog used by push-down publishing. | Add a packaging/runtime smoke check and a focused test for `push_down_copilot_customizations_rewrites.py`. | Current tests are good at validating source behavior but missed the two branch-blocking drift issues above. | All extension tests import `../src/extension`; none target `out/extension.js` or the rewrite catalog. |

## Code quality observations

### Patterns and consistency

- The new handlers in `src/extension.ts` follow the established `executeBundledScript(...)` pattern used by `collectPrContext` and `pushDownCopilotCustomizations`.
- `promptForShortName` and `promptForFeatureName` are cohesive helpers that keep activation wiring thin and readable.
- The Python wrapper templates for `new_active_feature_folder` and `potential_to_issue` correctly mimic the `collect_pr_context.py` thin-adapter style.
- Bundled Python imports are correctly rewritten from `scripts.dev_tools...` to `dev_tools...` throughout the newly added bundled modules.

### Error handling

- Runtime-not-found and non-zero-exit behaviors are surfaced clearly through the shared launcher.
- User cancellation is handled cleanly by returning early when input widgets resolve to `undefined`.
- The PowerShell wrapper uses validated CLI resolution patterns and avoids `Invoke-Expression`.

### Typed Python audit

- The bundled Python modules are strongly typed overall and avoid introducing new `Any` surfaces.
- Protocol usage in `potential_to_issue.py` and the active-folder helpers is appropriate for wrapping untyped process/filesystem behavior.
- Exception handling is generally specific enough; no new broad `except:` blocks were introduced in the reviewed files.

## Test coverage assessment

### What is covered well

The branch adds strong source-level coverage for the new command handlers:

- registration for each new command
- expected bundled script path and CLI args
- cancellation behavior
- missing-runtime behavior
- non-zero exit propagation
- Python wrapper importability for `potential_to_issue.py` and `new_active_feature_folder.py`

### Gaps that matter

- No test guards the packaged runtime entry point (`out/extension.js`) against drifting from `src/extension.ts`.
- No test guards `push_down_copilot_customizations_rewrites.py` from continuing to emit placeholder IDs after the feature landed.
- No Jest assertion verifies `potentialToIssue`’s file picker uses the documented default folder.

## Security and safety observations

- The shared launcher uses argv arrays with `shell: false`, which is good command-execution hygiene.
- The bundled Python code generally resolves executables through `shutil.which()` before invoking external tools.
- No secrets or embedded credentials were introduced in the reviewed files.
- Boundary validation for user-entered short names and issue numbers is present and reasonable.

## Verification performed

### Fresh commands run in this review

- `npm --prefix extensions/drm-copilot run format`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit`
- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov-report=term-missing`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

### Results

- TypeScript: **PASS** — 5 suites / 66 tests passed.
- Python: **PASS** — 830 tests passed, Pyright clean.
- PowerShell: **PASS** — formatter clean, analyzer clean, Pester passed (222 passed / 7 skipped).

## Recommendation

**REQUEST CHANGES**

The feature is close, but it is not yet safe to sideload or merge as-is because the packaged runtime still points at stale placeholder behavior, and push-down rewrite output still references retired placeholder IDs. Fix those two blockers and tighten the regression coverage around packaging/rewrite drift; after that, the remaining UX-spec gap (`defaultUri`) can be addressed as a small follow-up within the same remediation pass.
