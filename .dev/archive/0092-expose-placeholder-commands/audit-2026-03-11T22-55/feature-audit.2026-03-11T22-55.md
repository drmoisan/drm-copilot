# Feature Audit — expose-placeholder-commands (#92)

- **Timestamp:** 2026-03-11T22-55
- **Base branch assumption:** `main` (defaulted because `PRBaseBranch` input was not provided)
- **Primary feature folder:** `docs/features/active/2026-03-11-expose-placeholder-commands-92/`
- **Feature folder selection rule:** Used the explicit user-provided active feature folder, which also matches the branch issue suffix `-92`.
- **Evidence sources:**
  - `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` for branch/base metadata
  - direct inspection of the current working-tree files under `extensions/drm-copilot/` and `tests/`
  - feature evidence under `docs/features/active/2026-03-11-expose-placeholder-commands-92/evidence/`
- **Scope note:** The refreshed PR-context artifacts reflect committed `HEAD`; because the implementation under review currently exists as working-tree changes, this audit uses direct file inspection as the authoritative source for the feature delta.

## Scope and baseline

This audit validates the completed Issue #92 implementation that replaces four placeholder extension commands with bundled-script handlers:

- `drmCopilotExtension.newPotentialBugEntry`
- `drmCopilotExtension.newPotentialEntry`
- `drmCopilotExtension.potentialToIssue`
- `drmCopilotExtension.newActiveFeatureFolder`

The review compares the active feature docs (`issue.md`, `spec.md`, `user-story.md`, `plan.2026-03-11T21-40.md`) against the current working tree and fresh verification runs completed during this audit.

## Acceptance criteria inventory (authoritative)

Work mode in `issue.md` is `full-feature`, so the authoritative acceptance-criteria sources are:

- `docs/features/active/2026-03-11-expose-placeholder-commands-92/spec.md`
- `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`

The AC lists in those files are materially the same; this audit evaluates the shared set once.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| All four placeholder commands are replaced with real command handlers that invoke the bundled scripts | **FAIL** | `src/extension.ts` defines live handlers, but `out/extension.js` still contains placeholder registrations and `package.json` still loads `./out/extension.js`. | Static inspection; `npm --prefix extensions/drm-copilot run test:unit` | Source is updated, shipped runtime is not. |
| Each command's Python/PowerShell modules and dependencies are bundled under `resources/scripts/dev_tools/` or `resources/templates/` as appropriate | **PASS** | Bundled Python modules exist for active-folder and potential-to-issue flows; `new-potential-entry.ps1` and `vscode-cli.helpers.ps1` are present and co-located in `resources/templates/`. | Static inspection | File inventory matches intended bundle surface. |
| Wrapper templates follow the same thin-adapter pattern as `collect_pr_context.py` and `push_down_copilot_customizations.py` | **PARTIAL** | `new_active_feature_folder.py` and `potential_to_issue.py` are thin wrappers; `new_potential_bug_entry.py` is a full implementation copy rather than a thin adapter. | Static inspection; `poetry run pytest --cov-report=term-missing` | Functional behavior is present, but the pattern is inconsistent with the documented wrapper requirement. |
| Each command gathers required user input (file paths, names, types) via VS Code input boxes or quick picks before execution | **PARTIAL** | All handlers gather inputs; however, `potentialToIssue` omits the documented `defaultUri` to `docs/features/potential/`. | Static inspection; `npm --prefix extensions/drm-copilot run test:unit` | User-story scenario is only partially met because the starting folder is not deterministic. |
| Command IDs are renamed (drop `Placeholder` suffix) and `package.json` contributions are updated | **PASS** | `extensions/drm-copilot/package.json` contributes only live IDs for the four workflows. | Static inspection | This source-level rename is complete. |
| The `PLACEHOLDER_COMMAND_SPECS` array and `registerPlaceholderCommands` function are removed | **FAIL** | Removed from `src/extension.ts`, but still present in `out/extension.js`. | Static inspection | Effective runtime still retains placeholder infrastructure. |
| Existing placeholder command tests are replaced with tests for the new real commands | **PASS** | `extension.placeholder-commands.test.ts` is deleted; replacement tests exist in three Jest files. | `npm --prefix extensions/drm-copilot run test:unit` | Source-level test replacement is complete. |
| All TypeScript toolchain gates pass (Prettier, ESLint, TSC, Jest) | **PASS** | Fresh review run passed Prettier, ESLint, TSC, and Jest. | `npm --prefix extensions/drm-copilot run format`; `npm --prefix extensions/drm-copilot run lint`; `npm --prefix extensions/drm-copilot run typecheck`; `npm --prefix extensions/drm-copilot run test:unit` | 5 suites / 66 tests passed. |
| Extension activation registers all new commands without errors | **FAIL** | The live registrations exist only in `src/extension.ts`; the packaged runtime loaded by VS Code still points at stale `out/extension.js`. | Static inspection | Effective extension activation remains on the old command surface. |

## Focus-area verification

| Focus area | Status | Evidence |
|---|---|---|
| Handlers follow the `collectPrContext` / `pushDownCopilotCustomizations` bundling pattern | **PARTIAL** | `newActiveFeatureFolder` and `potentialToIssue` do; `newPotentialBugEntry` is self-contained instead of thin-wrapper-based. |
| Bundled Python imports rewritten from `scripts.dev_tools.X` to `dev_tools.X` | **PASS** | New bundled modules under `resources/scripts/dev_tools/` import `dev_tools...`; grep found no `scripts.dev_tools` imports in those new files. |
| `new_potential_bug_entry.py` uses `Path.cwd()` for workspace resolution | **PASS** | `resources/templates/new_potential_bug_entry.py` defines `_resolve_workspace()` as `Path.cwd()`. |
| `new-potential-entry.ps1` uses `Get-Location` for workspace resolution | **PASS** | The bundled template assigns `$workspace = (Get-Location).Path`. |
| `vscode-cli.helpers.ps1` is co-located with `new-potential-entry.ps1` | **PASS** | Both files are in `extensions/drm-copilot/resources/templates/`, and the script dot-sources the helper via `$PSScriptRoot`. |
| All commands handle user cancellation gracefully | **PASS** | All four handlers return early on `undefined`, and Jest covers cancellation paths. |
| Command IDs updated in both `extension.ts` and `package.json` | **PASS** | Source and contribution manifest are aligned on live IDs. |
| All placeholder infrastructure removed | **FAIL** | Not from the packaged runtime (`out/extension.js`) and not from the push-down rewrite catalog. |
| Tests cover registration, args, cancellation, missing runtime, and exit code for each command | **PASS** | The new Jest suites cover all listed categories at the source level. |

## User-story scenario coverage

| Scenario | Status | Evidence | Notes |
|---|---|---|---|
| New Potential Bug Entry from command palette | **PASS** | Source handler, bundled template, and Jest coverage all line up; `Path.cwd()` workspace resolution is correct. | Functional source-level coverage is strong. |
| Potential To Issue from command palette | **PARTIAL** | Core prompt and execution flow exists and is tested. | The documented default starting folder for the file picker is missing. |
| Repository maintainer gets reliable live command surface instead of placeholders | **FAIL** | Packaged extension still loads stale placeholder registrations from `out/extension.js`; push-down rewrite output still references placeholder IDs. | This is the main feature-readiness blocker. |

## Plan phase completion verification

| Phase | Status | Evidence |
|---|---|---|
| **P0 — Context & Inputs** | **PASS** | Baseline evidence files exist in `evidence/baseline/`. |
| **P1 — New Potential Bug Entry** | **PASS** | Handler, template, and Jest coverage exist. |
| **P2 — New Potential Entry** | **PASS** | PowerShell template/helper exist; handler and tests exist. |
| **P3 — Potential To Issue** | **PASS** | Bundled modules, wrapper template, handler, and tests exist. |
| **P4 — New Active Feature Folder** | **PASS** | Bundled modules, wrapper template, handler, and tests exist. |
| **P5 — Placeholder Cleanup** | **PARTIAL** | Cleanup is complete in `src/extension.ts` and tests, but stale placeholder references remain in `out/extension.js` and the push-down rewrite catalog. |
| **P6 — Final QA** | **PARTIAL** | Evidence files exist and fresh toolchain runs passed, but the final command-surface summary is contradicted by the current packaged runtime artifact and rewrite catalog. |

## Evidence artifact inventory

### Baseline evidence

Present under `evidence/baseline/`:

- `phase0-instructions-read.md`
- TypeScript baseline artifacts (`typescript-format.*`, `typescript-lint.*`, `typescript-typecheck.*`, `typescript-test.*`)
- Python baseline artifacts (`python-format.*`, `python-lint.*`, `python-typecheck.*`, `python-test.*`)
- PowerShell baseline artifacts (`powershell-format.*`, `powershell-analyze.*`, `powershell-test.*`)
- `requirements-snapshot.md`

### QA-gate evidence

Present under `evidence/qa-gates/`:

- TypeScript QA artifacts (`typescript-format.*`, `typescript-lint.*`, `typescript-typecheck.*`, `typescript-test.*`)
- Python QA artifacts (`python-format.*`, `python-lint.*`, `python-typecheck.*`, `python-test.*`)
- PowerShell QA artifacts (`powershell-format.*`, `powershell-analyze.*`, `powershell-test.*`)
- `final-command-surface-summary.md`

### Evidence inventory verdict

**PASS** — the expected baseline and QA gate evidence files exist.

## Summary

### Final verdict: **FAIL**

The implementation is close, but the feature is not complete enough to approve because the actual packaged extension still points to stale placeholder behavior and the push-down rewrite catalog still emits retired placeholder command IDs. Those two issues undermine the user-visible command surface, which is the core point of the feature.

### Top gaps preventing PASS

1. `extensions/drm-copilot/out/extension.js` is stale and still registers placeholder commands.
2. `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py` still rewrites to placeholder command IDs.
3. `potentialToIssue` does not fully match the spec’d file-picker UX because it lacks `defaultUri`.

### Recommended follow-up verification

- Rebuild/regenerate the packaged extension runtime and confirm `out/extension.js` matches the live source command surface.
- Update and test the push-down rewrite catalog so copied docs reference the live command IDs.
- Add a small Jest assertion for `potentialToIssue` file-picker options.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-03-11-expose-placeholder-commands-92/spec.md`, `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`
- Total AC items: 9
- Checked off (delivered): 5
- Remaining (unchecked in audit outcome): 4
- Items remaining:
  - All four placeholder commands are replaced with real command handlers that invoke the bundled scripts
  - Wrapper templates follow the same thin-adapter pattern as `collect_pr_context.py` and `push_down_copilot_customizations.py`
  - Each command gathers required user input (file paths, names, types) via VS Code input boxes or quick picks before execution
  - The `PLACEHOLDER_COMMAND_SPECS` array and `registerPlaceholderCommands` function are removed
  - Extension activation registers all new commands without errors

> Note: The AC source files were already pre-checked before this review. This audit does **not** re-check failing criteria and records the review outcome separately so the discrepancy is explicit and auditable.
