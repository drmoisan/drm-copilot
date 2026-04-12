# Feature Audit: expose-placeholder-commands

## Scope and baseline

- **Base branch:** `origin/development`
- **Primary evidence source:** `artifacts/pr_context.summary.txt`
- **Baseline diff source:** `artifacts/pr_context.appendix.txt`
- **Feature folder used:** `docs/features/active/2026-03-11-expose-placeholder-commands-92`
- **Work mode:** `full-feature` (resolved from `issue.md`)
- **Acceptance-criteria source rule:** authoritative checkbox source for this review is `user-story.md` (full-feature mode). `spec.md` provides supporting behavior/DoD detail.

## Acceptance Criteria Inventory

Authoritative criteria consolidated from `artifacts/pr_context.summary.txt` and `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`:

1. All four placeholder commands are replaced with real command handlers that invoke the bundled scripts.
2. Each command's Python/PowerShell modules and dependencies are bundled under `resources/scripts/dev_tools/` or `resources/templates/` as appropriate.
3. Wrapper templates follow the same thin-adapter pattern as `collect_pr_context.py` and `push_down_copilot_customizations.py`.
4. Each command gathers required user input (file paths, names, types) via VS Code input boxes or quick picks before execution.
5. Command IDs are renamed (drop `Placeholder` suffix) and `package.json` contributions are updated.
6. The `PLACEHOLDER_COMMAND_SPECS` array and `registerPlaceholderCommands` function are removed.
7. Existing placeholder command tests are replaced with tests for the new real commands.
8. All TypeScript toolchain gates pass (Prettier, ESLint, TSC, Jest).
9. Extension activation registers all new commands without errors.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. Four placeholder commands replaced with real handlers | PASS | `extensions/drm-copilot/src/extension.ts` registers the live commands at lines 247-404; `final-command-surface-summary.md` lists the four live IDs. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Fresh Jest coverage run passed and exercises each handler. |
| 2. Modules/dependencies bundled into extension resources | PASS | Bundled assets exist under `extensions/drm-copilot/resources/scripts/dev_tools/**` for `new_active_feature_folder*`, `potential_to_issue*`, and `prompt_mode_contract.py`; PowerShell assets exist under `resources/templates/new-potential-entry.ps1` and `vscode-cli.helpers.ps1`. | Static inspection; `npm --prefix extensions/drm-copilot run test:unit -- --coverage`; `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | The branch does package the runtime assets required to execute the commands. |
| 3. Wrapper templates follow thin-adapter pattern | PASS | `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py` now matches the thin-wrapper pattern used by `new_active_feature_folder.py` and `potential_to_issue.py`, and delegates to bundled `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`; parity evidence is recorded in `evidence/qa-gates/new-potential-bug-entry-wrapper-parity.2026-03-14T15-48.md`. | `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_potential_bug_entry.py`; static inspection | Wrapper parity is now satisfied for the Python bug-entry command. |
| 4. User input is gathered via VS Code prompts/picks | PASS | `extension.ts` uses `showInputBox`, `showQuickPick`, and `showOpenDialog`; Jest tests cover happy-path and cancellation flows. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Verified for all four command flows. |
| 5. Command IDs renamed and package contributions updated | PASS | `extensions/drm-copilot/package.json` lines 29-41 contribute the live IDs only. | Static inspection; `npm --prefix extensions/drm-copilot run typecheck` | Placeholder-suffixed IDs are absent from the package manifest. |
| 6. Placeholder array/function removed | PASS | `final-command-surface-summary.md` states `PLACEHOLDER_COMMAND_SPECS`, `PlaceholderCommandSpec`, and `registerPlaceholderCommands` are absent from `extension.ts`. | Static inspection; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | No contrary symbol matches surfaced in review. |
| 7. Placeholder tests replaced with real-command tests | PASS | `extensions/drm-copilot/test/extension.placeholder-commands.test.ts` was removed; new tests exist in `extension.test.ts`, `extension.new-active-feature-folder.test.ts`, and `extension.potential-to-issue.test.ts`. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Fresh run passed 74 tests across 5 suites. |
| 8. TypeScript toolchain gates pass | PASS | Fresh review run: format, lint, typecheck, and Jest coverage all passed. | `npm --prefix extensions/drm-copilot run format`; `npm --prefix extensions/drm-copilot run lint`; `npm --prefix extensions/drm-copilot run typecheck`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Command surface is currently TypeScript-clean. |
| 9. Extension activation registers all new commands without errors | PASS | Registration assertions exist in `extension.test.ts`, `extension.new-active-feature-folder.test.ts`, and `extension.potential-to-issue.test.ts`; fresh Jest run passed. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | No activation failure surfaced in the current review run. |

## Summary

**Overall feature readiness:** **PASS**

Top verification highlights:
1. Criterion 3 now passes because `newPotentialBugEntry` ships as a thin wrapper over bundled module `dev_tools.new_potential_bug_entry`.
2. Python changed-module coverage now clears the repo policy minimums (`new_active_feature_folder_models.py` 93%, `potential_to_issue_content.py` 90%, `prompt_mode_contract.py` 94%).
3. TypeScript, Python, and PowerShell final QA evidence is complete in `evidence/qa-gates/`.

Recommended follow-up verification after remediation:
- Re-run `npm --prefix extensions/drm-copilot run test:unit -- --coverage`
- Re-run `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
- Re-run `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`

## Acceptance Criteria Status

- Source: `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining:
  - none

### Check-off synchronization

- Criterion 3 was checked off in `user-story.md` after `evidence/qa-gates/new-potential-bug-entry-wrapper-parity.2026-03-14T15-48.md` and `evidence/qa-gates/remediation-threshold-verification.2026-03-14T15-48.md` both recorded `Result: PASS`.

- PASS: criterion 3 (Wrapper templates follow the same thin-adapter pattern as collect_pr_context.py and push_down_copilot_customizations.py)
