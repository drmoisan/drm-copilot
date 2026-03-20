# extension-template-resolution (Issue #93)

- Date captured: 2026-03-12
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/extension-template-resolution/ (Issue #93)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #93
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/93
- Last Updated: 2026-03-12
- Work Mode: minor-audit

## Summary

Extension commands (new-potential-entry, new-potential-bug-entry, new-active-feature-folder) fail to copy template files when running in a destination workspace because they resolve templates relative to `workspace` (cwd) instead of the extension's bundled resources. Commands may report success despite producing no output.

## Environment

- OS/version: Windows / any
- Python version: 3.x
- Command/flags used: Any extension command that uses templates (newPotentialEntry, newPotentialBugEntry, newActiveFeatureFolder)
- Data source or fixture: Template markdown files under docs/features/templates/ and docs/features/potential/template.md

## Steps to Reproduce

1. Publish and install the drm-copilot extension in VS Code
2. Open a destination workspace that does NOT contain docs/features/templates/ or docs/features/potential/template.md
3. Run any command: New Potential Entry, New Potential Bug Entry, or New Active Feature Folder
4. Observe the output channel

## Expected Behavior

The command creates the appropriate docs/features/ files in the workspace using template files bundled with the extension.

## Actual Behavior

The command reports success but the template files are not found (they exist only in the dev repo, not in the destination workspace). The PS1 script issues non-terminating errors but exits 0, so the extension reports "command success." Python scripts raise FileNotFoundError which is caught and exits 1, but output may not be visible.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: PS1 scripts silently fail with non-terminating Copy-Item errors; Python scripts fail with FileNotFoundError on workspace-relative template paths.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

All bundled scripts resolve templates relative to workspace (cwd):
- `new-potential-entry.ps1`: `$template = Join-Path $workspace 'docs/features/potential/template.md'`
- `new_potential_bug_entry.py`: `template = workspace_path / "docs" / "features" / "templates" / "bug" / "potential_bug.md"`
- `new_active_feature_folder_flow.py`: `template_dir = workspace_path / "docs" / "features" / "templates" / feature_type`

These paths only exist in the development repo. The extension bundles the scripts but not the template markdown files.

## Proposed Fix / Validation Ideas

- [x] Bundle template markdown files in extension resources/feature-templates/
- [x] Each script resolves templates from bundled resources (via --template-root or relative to __file__ / $PSScriptRoot), with fallback to workspace for backward compat
- [x] Unit tests verify template resolution from both bundled and workspace paths
- [x] Integration test: run new-potential-entry in workspace without docs/features/templates/ → should succeed using bundled templates

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch

---

## Sync Summary (as of 2026-03-13T19-35)

- Status: Remediation verified — 4 of 4 issue acceptance items are evidenced
- Branch: `bug/extension-template-resolution-93`
- Plan: `plan.2026-03-12T19-08.md`
- Remediation plan: `remediation-plan.2026-03-13T19-35.md`
- Work Mode: `minor-audit` — AC source is this file only
- Fresh remediation evidence: new-potential-entry-template-less-workspace.2026-03-13T19-35.md
- Fresh TypeScript QA evidence: remediation-ts-test-final.2026-03-13T19-35.md

### Changes in this sync run

- Checked off the final `## Proposed Fix / Validation Ideas` criterion after the targeted integration regression and full TypeScript QA both recorded `EXIT_CODE: 0`
- Synced the remediation-specific Python docstring evidence and QA-loop closure artifacts into the active feature folder

## Sync Summary (as of 2026-03-13T18-10)

- **Status:** In Progress — 3 of 4 issue acceptance items are evidenced; the integration scenario remains open
- **Branch:** `bug/extension-template-resolution-93`
- **Plan:** `plan.2026-03-12T19-08.md` (latest)
- **Work Mode:** `minor-audit` — AC source is this file only
- **Remote Issue State:** OPEN (read-only check via `gh issue view 93 --repo drmoisan/drm-copilot --json number,state,title,url`)

### Changes in this sync run

- Checked off P1-T2 via `evidence/other/issue-validation.md` after validating the three checked `## Proposed Fix / Validation Ideas` items against code and tests
- Checked off P1-T3 via `evidence/other/reduced-audit-handoff.md`
- Checked off P2-T1, P2-T2, P2-T3, P2-T5, P2-T6, and P2-T7 using the existing QA-gate artifacts under `evidence/qa-gates/`
- Added current evidence-missing notes for P2-T4, P2-T8, P2-T9, P2-T10, P2-T11, and P2-T12 where the exact required artifacts are still absent or incomplete

### Acceptance Criteria Status (from `## Proposed Fix / Validation Ideas`)

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | Bundle template markdown files in `resources/feature-templates/` | ✅ Evidenced | `extensions/drm-copilot/resources/feature-templates/{bug,epic,feature,potential,refactor}` now exists with template markdown files |
| 2 | Each script resolves templates from bundled resources (via `--template-root` or relative to bundled files) with workspace fallback | ✅ Evidenced | `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`, `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`, `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`, and `scripts/dev_tools/new_active_feature_folder_flow.py` now route through bundled template roots with fallback |
| 3 | Unit tests verify template resolution from both bundled and workspace paths | ✅ Evidenced | `extensions/drm-copilot/test/extension.test.ts`, `tests/scripts/dev_tools/test_new_potential_bug_entry.py`, and `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py` cover bundled-template and fallback behavior |
| 4 | Integration test: run new-potential-entry in workspace without `docs/features/templates/` → should succeed using bundled templates | ✅ Evidenced | `evidence/regression-testing/new-potential-entry-template-less-workspace.2026-03-13T19-35.md`; `evidence/qa-gates/remediation-ts-test-final.2026-03-13T19-35.md` |

### History / Prior Notes

- Existing report `status-sync.2026-03-13T19-22.md` captured a no-implementation snapshot. This sync supersedes that assessment based on the current working-tree code, test, and QA-gate artifacts.

### Recommended gh commands (GitHub mutations disabled)

```sh
# No remote state change recommended yet — issue #93 is still not fully delivered
# Optional progress comment:
# gh issue comment 93 --body "3 of 4 local acceptance items are evidenced; integration test and final QA coverage/PowerShell artifacts remain open."
```

## Acceptance Criteria Evidence (partial, as of 2026-03-13T18-10)

| Criterion | Evidence | Verification command(s) |
|---|---|---|
| Bundle template markdown files in extension resources | `extensions/drm-copilot/resources/feature-templates/bug/potential_bug.md`; `extensions/drm-copilot/resources/feature-templates/feature/spec.md`; `extensions/drm-copilot/resources/feature-templates/potential/template.md` | Code artifact inspection during status sync |
| Scripts resolve bundled templates with fallback | `extensions/drm-copilot/src/extension.ts`; `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`; `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`; `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`; `scripts/dev_tools/new_active_feature_folder_flow.py`; `scripts/dev_tools/new_potential_bug_entry.py` | `npm --prefix extensions/drm-copilot run typecheck`; `poetry run pyright` |
| Unit tests cover bundled + workspace template resolution | `extensions/drm-copilot/test/extension.test.ts`; `tests/scripts/dev_tools/test_new_potential_bug_entry.py`; `tests/scripts/dev_tools/test_new_active_feature_folder_part2.py`; `tests/scripts/dev_tools/test_new_active_feature_folder_part4.py` | `npm --prefix extensions/drm-copilot run test:unit`; `poetry run pytest` |

### Open criteria

- None; all issue acceptance criteria are now evidenced.