<!-- markdownlint-disable-file -->

# Task Research Notes: potential-entry-opening-different-ide

## Research Executed

### File Analysis

- `docs/features/active/2026-04-04-potential-entry-opening-different-ide-116/issue.md`
  - Defined Issue #116, named the affected commands, identified likely implementation files, and established the expected behavior that new files must open in the current VS Code window rather than a separate window.
- `change-plan.md`
  - Reviewed for repository workflow context; no feature-specific guidance existed for this issue.
- `extensions/drm-copilot/src/repo-automation-service.ts`
  - Confirmed `newPotentialBugEntry` and `newActiveFeatureFolder` execute Python-backed bundled templates, while `newPotentialEntry` executes a PowerShell template. Also confirmed the affected Python-backed workflows do not currently parse or return created artifact paths to the extension host.
- `extensions/drm-copilot/src/extension.ts`
  - Confirmed the command handlers for `drmCopilotExtension.newPotentialBugEntry` and `drmCopilotExtension.newActiveFeatureFolder` await service calls and return without opening generated files in the extension host.
- `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`
  - Verified `default_code_launcher(files)` resolves `code` and launches `code <files>` without `--reuse-window` and without Insiders-aware CLI selection.
- `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`
  - Verified `default_code_launcher(files)` launches `code <files>` without `--reuse-window` and without Insiders-aware CLI selection.
- `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_flow.py`
  - Confirmed the active-feature workflow collects generated file paths and delegates editor opening to the injected `code_launcher`, making the launcher the narrow behavioral seam.
- `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`
  - Verified the working reference implementation uses `Invoke-VSCodeOpen` with `--reuse-window` and Insiders-aware CLI selection.
- `extensions/drm-copilot/resources/templates/vscode-cli.helpers.ps1`
  - Verified existing repository behavior for detecting VS Code Insiders and resolving the appropriate CLI command.
- `extensions/drm-copilot/resources/templates/new_potential_bug_entry.py`
  - Confirmed the extension-side template is a thin Python wrapper over bundled `resources/scripts/dev_tools` logic.
- `extensions/drm-copilot/resources/templates/new_active_feature_folder.py`
  - Confirmed the extension-side template is a thin Python wrapper over bundled `resources/scripts/dev_tools` logic.
- `scripts/dev_tools/new_potential_bug_entry.py`
  - Verified the root mirror matches the bundled Python launcher behavior and would need to stay aligned if the runtime contract is updated.
- `scripts/dev_tools/new_active_feature_folder_io.py`
  - Verified the root mirror matches the bundled Python launcher behavior and would need to stay aligned if the runtime contract is updated.
- `tests/scripts/dev_tools/test_new_potential_bug_entry.py`
  - Confirmed existing unit tests cover launcher presence/absence and open invocation, but not `--reuse-window` or Insiders-specific command resolution.
- `tests/scripts/dev_tools/test_new_active_feature_folder.py`
  - Confirmed existing unit tests cover launcher invocation but not CLI argument parity with the PowerShell behavior.
- `tests/extensions/drm_copilot/resources/templates/test_new_potential_bug_entry.py`
  - Confirmed wrapper delegation is already covered and does not require architectural changes for the recommended fix.
- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
  - Confirmed the extension-level tests verify command/service orchestration rather than file-opening behavior.
- `extensions/drm-copilot/test/repo-automation-service.test.ts`
  - Confirmed artifact parsing is covered for some workflows, which highlights that an extension-host opening redesign would require new result plumbing for the affected Python workflows.

### Code Search Results

- `default_code_launcher`
  - Found in both bundled and root Python workflows for potential bug entry and active feature folder creation; both affected implementations currently invoke `code` without `--reuse-window`.
- `Invoke-VSCodeOpen|reuse-window|code-insiders`
  - Found in the PowerShell `new-potential-entry.ps1` template and shared helper, which already implement the desired current-window behavior and Insiders-aware command selection.
- `newPotentialBugEntry|newActiveFeatureFolder|newPotentialEntry`
  - Found in `extensions/drm-copilot/src/extension.ts` and `extensions/drm-copilot/src/repo-automation-service.ts`, confirming the split between Python-backed workflows and the PowerShell-backed control workflow.
- `artifacts/research/*`
  - No existing research note existed before this file was created.

### External Research

- #githubRepo:"microsoft/vscode vscode.d.ts showTextDocument TextDocumentShowOptions"
  - Official VS Code source defines `window.showTextDocument(uri, options?)`, with `TextDocumentShowOptions.viewColumn` defaulting to `ViewColumn.Active` and using `ViewColumn.Beside` only when explicitly requested. This supports the conclusion that an extension-host alternative could open files in the active editor area, but would require new artifact-path plumbing in this repository.
- #fetch:https://code.visualstudio.com/docs/editor/command-line
  - Official CLI documentation states `--new-window` opens a new session/window and `--reuse-window` forces the last active window to be reused. The same page documents `code-insiders` as the VS Code Insiders CLI.
- #fetch:https://github.com/microsoft/vscode/blob/main/src/vscode-dts/vscode.d.ts
  - Official source view confirms `window.showTextDocument` overloads and `TextDocumentShowOptions`, providing a valid extension API basis for an alternative design, but not reducing the additional repository changes that alternative would require.

### Project Conventions

- Standards referenced: repository general code change policy, Python code change policy, Python unit test policy, repository tone policy, and Task Researcher scratch-space restriction.
- Instructions followed: `.github/skills/policy-compliance-order/SKILL.md`, attached repository instruction files, and the research note template/constraints supplied via `research-issue.prompt.md`.

## Key Discoveries

### Project Structure

The defect is introduced below the extension command-registration layer. The extension host registers commands in `extensions/drm-copilot/src/extension.ts` and delegates execution to `extensions/drm-copilot/src/repo-automation-service.ts`. The service launches bundled workflow entrypoints under `extensions/drm-copilot/resources/templates/`, which in turn delegate to bundled Python modules under `extensions/drm-copilot/resources/scripts/dev_tools/`.

For the affected workflows, editor-opening behavior is implemented inside Python helper functions named `default_code_launcher`, not in the extension host. The currently correct comparison path, `newPotentialEntry`, is implemented in PowerShell and already contains explicit VS Code CLI reuse logic.

### Implementation Patterns

The repository already has an established pattern for opening newly generated artifacts in the current VS Code session: resolve the appropriate CLI (`code` vs `code-insiders`) and pass `--reuse-window`. That pattern exists in PowerShell, but the two Python-backed workflows use a narrower implementation that only runs `code <files>`.

Because `newPotentialBugEntry` and `newActiveFeatureFolder` already gather the created file paths before invoking their launchers, the smallest correct fix is to align the Python launcher behavior with the existing PowerShell reference. Changing the extension host instead would expand scope because the service currently does not return artifact paths for the affected workflows.

### Complete Examples

```python
# Source: extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py
def default_code_launcher(files: Sequence[Path]) -> bool:
    """Open the created file in VS Code if available."""
    code = shutil.which("code")
    if code is None:
        return False
    subprocess.run([code, *(str(f) for f in files)], check=False)
    return True


# Source: extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py
def default_code_launcher(files: Sequence[Path]) -> bool:
    """Open files in VS Code if available."""
    code = shutil.which("code")
    if code is None:
        return False
    subprocess.run([code, *(f.as_posix() for f in files)], check=False)
    return True
```

### API and Schema Documentation

- VS Code CLI documentation:
  - `code --new-window` opens a new session/window.
  - `code --reuse-window` reuses the last active window.
  - `code-insiders` is the CLI for VS Code Insiders.
- VS Code extension API source:
  - `window.showTextDocument(uri, options?)` can show a file in the active editor area.
  - `TextDocumentShowOptions.viewColumn` defaults to `ViewColumn.Active`; `ViewColumn.Beside` is opt-in.

### Configuration Examples

```powershell
# Source: extensions/drm-copilot/resources/templates/new-potential-entry.ps1
function Invoke-VSCodeOpen {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Paths
    )

    $codeCommand = if (Test-IsVSCodeInsidersSession) { 'code-insiders' } else { 'code' }
    $null = Start-Process -FilePath $codeCommand -ArgumentList @('--reuse-window') + $Paths
}
```

### Technical Requirements

- The affected commands are:
  - `drmCopilotExtension.newPotentialBugEntry`
  - `drmCopilotExtension.newActiveFeatureFolder`
- The expected behavior must match `drmCopilotExtension.newPotentialEntry` by reusing the current VS Code window.
- The narrowest safe implementation seam is the Python `default_code_launcher` in both affected workflows.
- Any repository change should keep root Python mirrors aligned with bundled extension-side scripts because both currently implement the same launcher contract.
- Regression coverage should be added at the Python unit-test layer for:
  - normal VS Code CLI selection
  - Insiders-aware CLI selection
  - inclusion of `--reuse-window`
  - graceful no-CLI fallback

**Mandatory unachievable objective callout**:
- No mandatory objective was proven unachievable during this research.

## Recommended Approach

Implement a minimal Python launcher parity fix in the affected workflow modules and their mirrors. Specifically, introduce a shared helper or equivalent local logic that:

- detects whether the current environment should prefer `code-insiders` over `code`, using the same intent as the existing PowerShell helpers,
- resolves the chosen executable with `shutil.which`,
- launches the generated file list with `--reuse-window`, and
- preserves the current `False` return when no suitable CLI is available.

This is the best approach because it corrects the actual defect at the point where the incorrect behavior is introduced, preserves current workflow boundaries, and avoids widening the change to service/result contracts in the extension host.

Rejected alternatives summary:

- Extension-host opening redesign using `window.showTextDocument` was rejected as the primary recommendation because the affected service methods do not currently return created artifact paths, so this would require additional subprocess-output or artifact-plumbing changes beyond the defect seam.
- Independent one-off fixes in each Python module without a shared helper were rejected because the behavioral rules already need to stay aligned across bundled and root mirrors, and duplication would make future drift more likely.

## Implementation Guidance

- **Objectives**: Ensure the potential bug entry and active feature folder workflows open newly created files in the current VS Code window, matching existing `newPotentialEntry` behavior.
- **Key Tasks**:
  - Update bundled Python launcher logic in `extensions/drm-copilot/resources/scripts/dev_tools/new_potential_bug_entry.py`.
  - Update bundled Python launcher logic in `extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py`.
  - Keep root mirrors in `scripts/dev_tools/` behaviorally aligned.
  - Add Python regression tests covering CLI selection and `--reuse-window` arguments.
- **Dependencies**: Existing Python subprocess launcher structure, `shutil.which`, existing PowerShell Insiders/reuse behavior as the reference contract, and existing pytest test seams in `tests/scripts/dev_tools/`.
- **Success Criteria**:
  - Both affected workflows invoke VS Code with `--reuse-window`.
  - Insiders sessions prefer `code-insiders` when available.
  - No-CLI environments continue to fail gracefully without raising new errors.
  - New regression tests prove the command arguments and launcher selection behavior.