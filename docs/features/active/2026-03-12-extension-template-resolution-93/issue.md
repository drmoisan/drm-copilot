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
- [ ] Integration test: run new-potential-entry in workspace without docs/features/templates/ → should succeed using bundled templates

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch