# Feature Audit: expose-placeholder-commands

## Scope and baseline

- **Base branch:** `origin/development`
- **Primary evidence source:** `artifacts/pr_context.summary.txt`
- **Baseline diff source:** `artifacts/pr_context.appendix.txt`
- **Feature folder used:** `docs/features/active/2026-03-11-expose-placeholder-commands-92`
- **Feature folder selection rule:** Selected because `pr_context.summary.txt` identifies this folder’s `spec.md` and `user-story.md` as the primary scoping docs changed and the suffix matches issue `#92`.
- **Work mode marker:** `- Work Mode: full-feature` from `issue.md`
- **Authoritative AC source files:** `spec.md` and `user-story.md`
- **Scope note:** This is an umbrella-branch review; related merged bugfix feature folders `#93`, `#95`, and `#98` remain in range, per `evidence/other/review-scope-map.2026-03-14T15-48.md`.

## Acceptance Criteria Inventory

Primary acceptance checklist consolidated from `artifacts/pr_context.summary.txt` and `user-story.md`:

1. All four placeholder commands are replaced with real command handlers that invoke the bundled scripts.
2. Each command's Python/PowerShell modules and dependencies are bundled under `resources/scripts/dev_tools/` or `resources/templates/` as appropriate.
3. Wrapper templates follow the same thin-adapter pattern as `collect_pr_context.py` and `push_down_copilot_customizations.py`.
4. Each command gathers required user input (file paths, names, types) via VS Code input boxes or quick picks before execution.
5. Command IDs are renamed (drop `Placeholder` suffix) and `package.json` contributions are updated.
6. The `PLACEHOLDER_COMMAND_SPECS` array and `registerPlaceholderCommands` function are removed.
7. Existing placeholder command tests are replaced with tests for the new real commands.
8. All TypeScript toolchain gates pass (Prettier, ESLint, TSC, Jest).
9. Extension activation registers all new commands without errors.

Supporting acceptance/definition-of-done evidence in `spec.md` is fully checked (17/17 checked; 0 unchecked).

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. Four placeholder commands replaced with real handlers | PASS | `extensions/drm-copilot/src/extension.ts` registers live implementations for `newActiveFeatureFolder`, `potentialToIssue`, `newPotentialBugEntry`, and `newPotentialEntry`; `final-command-surface-summary.md` lists the same four live IDs. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Fresh extension-local Jest run passed 74/74 tests. |
| 2. Runtime modules and dependencies are bundled in the extension | PASS | Bundled Python modules exist under `extensions/drm-copilot/resources/scripts/dev_tools/`; PowerShell assets exist under `extensions/drm-copilot/resources/templates/`; wrapper parity evidence confirms the bug-entry split. | Static inspection; `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Bundled assets required by the command flows are present and exercised. |
| 3. Wrapper templates follow the thin-adapter pattern | PASS | `new_potential_bug_entry.py`, `potential_to_issue.py`, and `new_active_feature_folder.py` wrappers delegate to bundled `dev_tools` modules; `new-potential-bug-entry-wrapper-parity.2026-03-14T15-48.md` records `Result: PASS`. | `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_potential_bug_entry.py` | Thin-wrapper compliance is explicit in the final reviewed state. |
| 4. Required user inputs are gathered via VS Code prompts | PASS | `extension.ts` uses `showInputBox`, `showQuickPick`, and `showOpenDialog`; Jest covers happy-path and cancellation flows. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Prompt orchestration is fully exercised in the extension test suite. |
| 5. Command IDs renamed and package contributions updated | PASS | `extensions/drm-copilot/package.json` contributes only live command IDs; placeholder-suffixed IDs are absent. | Static inspection; `npm --prefix extensions/drm-copilot run typecheck` | Manifest matches the implemented command surface. |
| 6. Placeholder array/function removed | PASS | `final-command-surface-summary.md` records no `PLACEHOLDER_COMMAND_SPECS`, `PlaceholderCommandSpec`, or `registerPlaceholderCommands` symbols in the final branch state. | Static inspection; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | No contrary symbol matches surfaced during review. |
| 7. Placeholder tests replaced with real-command tests | PASS | `extensions/drm-copilot/test/extension.placeholder-commands.test.ts` is removed; active scenarios live in `extension.test.ts`, `extension.new-active-feature-folder.test.ts`, and `extension.potential-to-issue.test.ts`. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Test replacement is complete. |
| 8. TypeScript toolchain gates pass | PASS | Extension-local format, lint, typecheck, and Jest coverage all passed in this review. | `npm --prefix extensions/drm-copilot run format`; `npm --prefix extensions/drm-copilot run lint`; `npm --prefix extensions/drm-copilot run typecheck`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | Current run matched the historical final QA state. |
| 9. Extension activation registers all new commands without errors | PASS | Registration assertions exist and pass in the Jest suite. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage` | No activation or registration failures surfaced. |

## Summary

**Overall feature readiness:** **PASS**

Top verification highlights:
1. The thin-wrapper contract now holds for all relevant Python wrapper templates, including `newPotentialBugEntry`.
2. Current extension-local, Python, and direct PowerShell review runs all passed cleanly.
3. Both authoritative full-feature acceptance source files are fully checked off already, so no AC mutations were needed during this review.

Recommended follow-up verification after merge:
- Let normal CI re-run the same extension-local TypeScript, root Python, and direct PowerShell loops.
- Keep the umbrella-scope note visible in the PR description so reviewers understand why related bugfix folders appear in range.

## Acceptance Criteria Status

### Acceptance Criteria Status
- Source: `docs/features/active/2026-03-11-expose-placeholder-commands-92/spec.md`, `docs/features/active/2026-03-11-expose-placeholder-commands-92/user-story.md`
- Total AC items: 26 (9 primary criteria in `user-story.md` + 17 supporting definition-of-done / seeded verification checkboxes in `spec.md`)
- Checked off (delivered): 26
- Remaining (unchecked): 0
- Items remaining: none

### Check-off synchronization

- No source-file edits were required in this review because the authoritative full-feature files were already fully checked off.
- `issue.md` remains a non-authoritative mirror for this work mode and did not gate PASS/FAIL decisions.
