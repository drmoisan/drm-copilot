# potential-entry-opening-different-ide (Issue #116)

- Date captured: 2026-04-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/potential-entry-opening-different-ide/ (Issue #116)
- Issue: #116
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/116
- Last Updated: 2026-04-04
- Work Mode: minor-audit

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

## Proposed Fix

- [ ] Implement a minimal Python launcher parity fix in `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py` and `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py` by updating each `default_code_launcher()` path to resolve the correct VS Code CLI, prefer `code-insiders` when the current session indicates Insiders, and launch generated files with `--reuse-window`
- [ ] Keep the root mirrors in `scripts/dev_tools/new_potential_bug_entry.py` and `scripts/dev_tools/new_active_feature_folder_io.py` behaviorally aligned with the bundled extension-side launcher logic so the repository does not retain two different window-launch contracts
- [ ] Unit coverage areas: add regression coverage in `tests/scripts/dev_tools/test_new_potential_bug_entry.py` and `tests/scripts/dev_tools/test_new_active_feature_folder.py` for normal CLI resolution, Insiders-aware CLI resolution, `--reuse-window` argument usage, and the existing graceful fallback when no VS Code CLI is available
- [ ] Integration scenario to retest: run `drmCopilotExtension.newPotentialBugEntry`, `drmCopilotExtension.newActiveFeatureFolder`, and `drmCopilotExtension.newPotentialEntry` from the same Windows workspace and verify all open their generated files in the current IDE window rather than spawning a separate VS Code or VS Code Insiders window
- [ ] Manual verification notes: confirm the bug-entry workflow still creates the expected file under `docs/features/potential/`, confirm the active-feature workflow still creates the expected active-feature files, and verify the file-opening behavior now matches the existing PowerShell-backed `drmCopilotExtension.newPotentialEntry` control path

## Acceptance Criteria

- [ ] On Windows, invoking `drmCopilotExtension.newPotentialBugEntry` from an already-open `drm-copilot-2026-04-02` workspace with a valid kebab-case short name creates the expected Markdown file under `docs/features/potential/` and opens that created file as an editor tab in the originating VS Code or VS Code Insiders window; the audit fails if the file opens in a newly spawned IDE window instead
- [ ] On Windows, invoking `drmCopilotExtension.newActiveFeatureFolder` from the same already-open workspace with valid prompt inputs creates the expected active-feature files under `docs/features/active/` and opens the generated files in the originating VS Code or VS Code Insiders window; the audit fails if the workflow opens those files in a newly spawned IDE window instead
- [x] Regression coverage in `tests/scripts/dev_tools/test_new_potential_bug_entry.py` and `tests/scripts/dev_tools/test_new_active_feature_folder.py` proves that the affected Python launchers resolve a VS Code CLI executable, pass `--reuse-window`, prefer `code-insiders` when the session indicates Insiders, and preserve the existing graceful fallback when no VS Code CLI executable is available

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch