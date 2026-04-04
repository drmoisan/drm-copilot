# potential-entry-opening-different-ide (Issue #116)

- Date captured: 2026-04-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-entry-opening-different-ide/ (Issue #116)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #116
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/116
- Last Updated: 2026-04-04
## Summary

Running `drmCopilotExtension.newPotentialBugEntry` creates the expected potential bug file, but the extension opens that file in a separate IDE window instead of reusing the current VS Code session. The same separate-window behavior also occurs with `drm-copilot: New Active Feature Folder` (`drmCopilotExtension.newActiveFeatureFolder`), while the comparable potential feature command, `drmCopilotExtension.newPotentialEntry`, reuses the current IDE correctly.

## Environment

- OS/version: Windows
- Python version: Not captured; the bug-entry workflow runs through the extension's Python-backed launcher
- Command/flags used: `drmCopilotExtension.newPotentialBugEntry` and `drmCopilotExtension.newActiveFeatureFolder` from the VS Code extension command surface
- Data source or fixture: Live workspace `c:\Users\DanMoisan\repos\drm-copilot-2026-04-02`

## Steps to Reproduce

1. Open the `drm-copilot-2026-04-02` workspace in the current VS Code session on Windows.
2. Invoke `drmCopilotExtension.newPotentialBugEntry` and provide any valid kebab-case short name.
3. Wait for the extension to create the potential bug Markdown file.
4. Observe that the file opens in a separate IDE window rather than the existing one.
5. Invoke `drm-copilot: New Active Feature Folder` and complete the required prompts for any valid feature folder.
6. Observe that the created active-feature files also open in a separate IDE window rather than the existing one.
7. As a control, invoke `drmCopilotExtension.newPotentialEntry` with a valid short name and observe that it opens in the current IDE window.

## Expected Behavior

The potential bug workflow and the active-feature-folder workflow should both open their newly created files in the current VS Code window, matching the existing behavior of the potential feature workflow.

## Actual Behavior

The potential bug workflow creates the file successfully, but launching the file opens a separate IDE window. `drm-copilot: New Active Feature Folder` shows the same incorrect window-launch behavior after generating its files. No user-facing error text is required to trigger the issue; the failure is the incorrect window-launch behavior.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet:
	```text
	Observed behavior: invoking drmCopilotExtension.newPotentialBugEntry creates the new Markdown file and opens a separate IDE window.
	Observed behavior: invoking drm-copilot: New Active Feature Folder creates the expected active feature files and opens them in a separate IDE window.
	Control behavior: invoking drmCopilotExtension.newPotentialEntry opens the created file in the existing IDE window.
	```

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The bug-entry and active-feature workflows appear to share a Python-side launcher behavior that differs from the PowerShell feature-entry flow:

- `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py` uses `default_code_launcher()`, which invokes `code <file>` without `--reuse-window` and without the `code-insiders` detection used elsewhere.
- `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py` uses a similar `default_code_launcher()` implementation, which also invokes `code <file>` without `--reuse-window`.
- `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` uses `Invoke-VSCodeOpen`, which explicitly passes `--reuse-window` and prefers `code-insiders` when the current session is running Insiders.
- `extensions/drm-copilot/src/repo-automation-service.ts` routes both `drmCopilotExtension.newPotentialBugEntry` and `drmCopilotExtension.newActiveFeatureFolder` through Python scripts, while `drmCopilotExtension.newPotentialEntry` runs through the PowerShell script, so the mismatch is likely in the launcher behavior rather than the command registration.

This suggests the Python launchers for bug-entry creation and active-feature-folder creation have drifted from the PowerShell feature-entry launcher and need the same reuse-window and IDE-selection behavior.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: add regression coverage for the Python bug-entry and active-feature launchers so both use the same window-reuse behavior as the feature-entry flow, including Insiders-aware command resolution when applicable
- [ ] Integration scenario to retest: run `drmCopilotExtension.newPotentialBugEntry`, `drmCopilotExtension.newActiveFeatureFolder`, and `drmCopilotExtension.newPotentialEntry` from the same Windows workspace and verify all open their generated files in the current IDE window
- [ ] Manual verification notes: confirm the bug-entry workflow still creates the expected file under `docs/features/potential/`, confirm the active-feature workflow still creates its expected files, and verify that no additional VS Code or VS Code Insiders window is spawned

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch