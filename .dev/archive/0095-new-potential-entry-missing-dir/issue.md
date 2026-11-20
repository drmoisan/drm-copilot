# new-potential-entry-missing-dir (Issue #95)

- Date captured: 2026-03-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/new-potential-entry-missing-dir/ (Issue #95)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #95
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/95
- Last Updated: 2026-03-14
- Work Mode: minor-audit

## Summary

`new-potential-entry.ps1` (both the `scripts/dev-tools/` and `extensions/drm-copilot/resources/templates/` copies) has two distinct defects: (1) `Copy-Item -Force` silently fails when the parent `docs/features/potential/` directory does not yet exist in the target workspace, causing a cascade of further failures; and (2) `Invoke-VSCodeOpen` uses `Start-Process` to launch the editor, which always opens a new standalone window and may invoke the wrong binary (`code` instead of `code-insiders`) when environment-variable-based IDE detection fails in the extension subprocess context.

## Environment

- OS/version: Windows (any); reproduced on Windows 11 with VS Code Insiders
- Python version: N/A — pure PowerShell script
- Command/flags used: `drmCopilotExtension.newPotentialEntry` command (VS Code extension); also reproducible via `scripts/dev-tools/new-potential-entry.ps1 -ShortName <name>`
- Data source or fixture: any workspace that does not have a pre-existing `docs/features/potential/` folder

## Steps to Reproduce

### Bug 1 — Missing directory

1. Open a workspace that does **not** contain a `docs/features/potential/` folder.
2. Run `drmCopilotExtension.newPotentialEntry` (or invoke the script directly with `-ShortName test`).
3. Observe the terminal output — the script prints `Created: …` but the file does not exist on disk.

### Bug 2 — Wrong IDE / new window opened

1. Open VS Code Insiders with a workspace.
2. Run `drmCopilotExtension.newPotentialEntry` (the extension spawns a PowerShell subprocess to execute the script).
3. Observe that a **new** editor window opens, and it may be regular VS Code rather than VS Code Insiders.

## Expected Behavior

- **Bug 1**: If `docs/features/potential/` does not exist, the script creates it (recursively) before copying the template, and the newly created markdown file appears on disk with all placeholders replaced.
- **Bug 2**: The newly created file opens in the **same** VS Code Insiders window that the user is already working in (reusing the existing workspace), using the same IDE binary that is currently running.

## Actual Behavior

- **Bug 1**: `Copy-Item -Force` fails silently (no `$ErrorActionPreference = 'Stop'`). Execution continues: `Write-Output "Created: $target"` prints a misleading success message; `Get-Content` then fails because the file was never created; `Convert-TemplateContent` receives null/empty content; `Set-Content` also fails. The potential entry file is never created.
- **Bug 2**: `Invoke-VSCodeOpen` calls `Start-Process 'code-insiders' $Files` (or `Start-Process 'code' $Files`), which always spawns a new detached process and opens a new standalone editor window. When `$env:TERM_PROGRAM_VERSION` does not propagate into the extension subprocess (a common Windows PowerShell subprocess limitation), the Insiders detection branch is skipped entirely and regular `code` is launched — counterproductive when the user is working in VS Code Insiders.

**Key error text (Bug 1, if `$ErrorActionPreference = 'Stop'` were set):**
```
Copy-Item : Could not find a part of the path
'C:\<workspace>\docs\features\potential\2026-03-13-<name>.md'.
```

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `Created: C:\<workspace>\docs\features\potential\2026-03-13-test.md` (misleading success line printed even though the file does not exist on disk)

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

**Bug 1 — Root cause:**
`Copy-Item -Force` overwrites existing files but does **not** create missing intermediate directory segments. Both affected scripts — `scripts/dev-tools/new-potential-entry.ps1` (line ~149) and `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` (line ~158) — call `Copy-Item $template $target -Force` with no preceding parent-directory guard. The bug was not caught during development because the `drm-copilot` repo itself always has the `potential/` folder present.

**Bug 2 — Root cause:**
`Invoke-VSCodeOpen` relies on `$env:TERM_PROGRAM_VERSION -match 'insider'` to detect VS Code Insiders. This environment variable is set by the VS Code integrated terminal but is frequently **not** inherited by child processes spawned by the VS Code extension host (a Windows PowerShell subprocess isolation behavior). When detection fails, the function falls back to launching `code`, opening regular VS Code. Additionally, `Start-Process` always creates a new detached process, so even when the correct binary is chosen, the file opens in a brand-new window rather than being added to the currently active workspace. The correct primitives are direct CLI invocation with `--reuse-window` (to reuse the existing editor window) combined with a more reliable IDE-detection strategy (e.g., inspecting `$env:VSCODE_IPC_HOOK_CLI` or the running process name).

**Affected files:**

| File | Bug 1 line | Bug 2 function |
|------|-----------|----------------|
| `scripts/dev-tools/new-potential-entry.ps1` | ~149 | `Invoke-VSCodeOpen` (~93) |
| `extensions/drm-copilot/resources/templates/new-potential-entry.ps1` | ~158 | `Invoke-VSCodeOpen` (~94) |

## Proposed Fix / Validation Ideas

**Bug 1 fix** — Insert a parent-directory guard immediately before `Copy-Item` in both files:
```powershell
$targetDir = Split-Path -Parent $target
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}
Copy-Item $template $target -Force
```

**Bug 2 fix** — Replace `Start-Process` with a direct CLI call that passes `--reuse-window` and improves IDE detection:
- Use direct invocation (`& code-insiders --reuse-window $Files`) instead of `Start-Process`.
- Detect the correct binary by checking `$env:VSCODE_IPC_HOOK_CLI` (set by VS Code's CLI resolver in extension-host subprocesses) in addition to `$env:TERM_PROGRAM_VERSION`, and/or by inspecting the parent-process name for `insiders`.

- [x] Unit coverage areas — regression test in `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`: (a) directory guard present in script content; (b) `Invoke-VSCodeOpen` with `--reuse-window` flag in generated command
- [x] Integration scenario to retest — run `newPotentialEntry` against a workspace with no `docs/features/potential/` folder and confirm file is created and opens in the existing VS Code Insiders window
- [ ] Manual verification notes

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch