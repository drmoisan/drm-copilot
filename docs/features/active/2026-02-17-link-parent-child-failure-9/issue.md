# link-parent-child-failure (Issue #9)

- Date captured: 2026-02-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/link-parent-child-failure/ (Issue #9)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #9
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/9
- Last Updated: 2026-02-17
## Summary

Running `scripts/dev-tools/link-parent-child.ps1` fails when it cannot fetch the child issue, throwing an `InvalidOperationException` with a message that suggests either the issue number is invalid or `gh` is not authenticated.

When invoked from the VS Code integrated terminal/task, the wrapper message only showed exit code 1; running directly reveals the underlying exception message.

## Environment

- OS/version: Linux (dev container; exact distro/version not captured in the error)
- OS/version: Linux (dev container)
- Python version: N/A (PowerShell script)
- Command/flags used:
	- `/usr/bin/pwsh -NoLogo -c "pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8"`
	- Script args: `-ChildIssueNumber 2 -ParentIssueNumber 8`
- Data source or fixture: GitHub Issues (issue #2 as child, issue #8 as parent)

## Steps to Reproduce

1. In the repo workspace, invoke the script via the VS Code integrated terminal/task (or equivalent wrapper) using:
	- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8`
2. Observe the terminal wrapper command shown by VS Code (nested `pwsh -c 'pwsh ... -File ...'`).
3. The terminal process terminates with exit code 1.

Alternative direct repro (shows underlying error):

1. Run the script directly in a terminal:
	- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8`
2. Observe the exception thrown at `link-parent-child.ps1:12` indicating it was unable to fetch child issue #2.

## Expected Behavior

The script should successfully link GitHub issue #2 as a child of issue #8 and exit with code 0.

If it fails (auth, permissions, missing tooling, invalid issue numbers), it should print a clear, actionable error message to stderr.

## Actual Behavior

The PowerShell terminal process terminates with exit code 1.

Error shown:

`The terminal process "/usr/bin/pwsh '-NoLogo', '-c', 'pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8'" terminated with exit code: 1.`

Direct invocation output (shows underlying error):

`OperationStopped: /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1:12:5`

`Unable to fetch child issue #2. Check the number and gh auth.`

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:
	- VS Code wrapper message:
		- `The terminal process "/usr/bin/pwsh '-NoLogo', '-c', 'pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8'" terminated with exit code: 1.`
	- Direct invocation:
		- `OperationStopped: /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1:12:5`
		- `Unable to fetch child issue #2. Check the number and gh auth.`

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

The script throws early when child issue retrieval fails and currently provides a generic error path that is easy to miss when invoked through a VS Code task wrapper. This can obscure whether the root cause is authentication, repository targeting, permissions, or an invalid issue number.

## Proposed Fix / Validation Ideas

- [ ] Improve `scripts/dev-tools/link-parent-child.ps1` error handling so failures include actionable diagnostics (issue number, repository context, and `gh auth` status guidance).
- [ ] Preserve non-zero exit behavior but ensure the root error is surfaced clearly in task-invoked output.
- [ ] Add/adjust tests in `tests/scripts/dev-tools/` to validate both success and child-fetch failure messaging paths.
- [ ] Manual verification: run the script with valid and invalid child issue numbers and confirm error messages remain explicit in both direct terminal and task-wrapper invocation.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

## Implementation Outcome (2026-02-18)

Completed in-scope bugfix for `Get-Issue` failure diagnostics with no success-path behavior regressions.

Changed files:

- `scripts/dev-tools/link-parent-child.ps1`
- `tests/scripts/dev-tools/link-parent-child.Tests.ps1`
- `docs/features/active/2026-02-17-link-parent-child-failure-9/spec.md`
- `docs/features/active/2026-02-17-link-parent-child-failure-9/issue.md`

Validation commands executed:

- `Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*auth-required failure messaging*'`
- `Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*not-found failure messaging*'`
- `Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*permission/repo-context failure messaging*'`
- `Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*unknown failure messaging fallback*'`
- `Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -FullNameFilter '*success path stability*'`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`