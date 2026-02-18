# 2026-02-17-link-parent-child-failure (Spec)

- **Issue:** #9
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-18T01-22
- **Status:** Implemented
- **Version:** 0.2

## Context
Running `scripts/dev-tools/link-parent-child.ps1` fails when it cannot fetch the child issue, throwing an `InvalidOperationException` with a message that suggests either the issue number is invalid or `gh` is not authenticated.

When invoked from the VS Code integrated terminal/task, the wrapper message only showed exit code 1; running directly reveals the underlying exception message.

Environment:
- OS/version: Linux (dev container; exact distro/version not captured in the error)
- OS/version: Linux (dev container)
- Python version: N/A (PowerShell script)
- Command/flags used:
	- `/usr/bin/pwsh -NoLogo -c "pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8"`
	- Script args: `-ChildIssueNumber 2 -ParentIssueNumber 8`
- Data source or fixture: GitHub Issues (issue #2 as child, issue #8 as parent)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. In the repo workspace, invoke the script via the VS Code integrated terminal/task (or equivalent wrapper) using:
	- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8`
2. Observe the terminal wrapper command shown by VS Code (nested `pwsh -c 'pwsh ... -File ...'`).
3. The terminal process terminates with exit code 1.

Alternative direct repro (shows underlying error):

1. Run the script directly in a terminal:
	- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8`
2. Observe the exception thrown at `link-parent-child.ps1:12` indicating it was unable to fetch child issue #2.

Expected:
The script should successfully link GitHub issue #2 as a child of issue #8 and exit with code 0.

If it fails (auth, permissions, missing tooling, invalid issue numbers), it should print a clear, actionable error message to stderr.

Actual:
The PowerShell terminal process terminates with exit code 1.

Error shown:

`The terminal process "/usr/bin/pwsh '-NoLogo', '-c', 'pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8'" terminated with exit code: 1.`

Direct invocation output (shows underlying error):

`OperationStopped: /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1:12:5`

`Unable to fetch child issue #2. Check the number and gh auth.`

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:
	- VS Code wrapper message:
		- `The terminal process "/usr/bin/pwsh '-NoLogo', '-c', 'pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1 -ChildIssueNumber 2 -ParentIssueNumber 8'" terminated with exit code: 1.`
	- Direct invocation:
		- `OperationStopped: /workspaces/drm-copilot/scripts/dev-tools/link-parent-child.ps1:12:5`
		- `Unable to fetch child issue #2. Check the number and gh auth.`


## Scope & Non-Goals
- In scope:
	- Improve fetch-failure diagnostics in `scripts/dev-tools/link-parent-child.ps1` for `Get-Issue` when retrieving child or parent issue data via `gh issue view`.
	- Preserve existing non-zero failure behavior while making thrown error text self-diagnosing in both direct terminal and VS Code task-wrapper execution.
	- Add regression coverage in `tests/scripts/dev-tools/link-parent-child.Tests.ps1` for child/parent fetch failure categories and actionable guidance text.
- Out of scope / non-goals:
	- No changes to the parent-body update algorithm (`## Child Issues` parsing/rewrite) beyond what is required to pass through improved diagnostics.
	- No workflow/task redesign in `.vscode/tasks.json` unless script-level diagnostics are proven insufficient after implementation validation.
	- No refactor into a shared cross-script gh wrapper module for this bug fix.
- Explicitly excluded systems, integrations, or datasets:
	- No changes to GitHub issue template content or issue metadata conventions.
	- No changes to extension command registration/labels in `src/task-command-map.ts` unless required by an implementation-side command-surface change (not expected).
	- No external data sources beyond GitHub issue APIs already accessed through `gh`.

## Root Cause Analysis
The script throws early when child issue retrieval fails and currently provides a generic error path that is easy to miss when invoked through a VS Code task wrapper. This can obscure whether the root cause is authentication, repository targeting, permissions, or an invalid issue number.

- Current failure collapse point:
	- `Get-Issue` treats all `gh issue view` failures as one generic branch (`ExitCode -ne 0` or empty output) and emits the same message for all causes.
- Why this hurts troubleshooting:
	- `gh` exits with shared non-zero codes for multiple problems; without classification, users cannot quickly distinguish invalid issue numbers, auth/token errors, repo mismatch, or permission limits.
	- VS Code shell tasks often surface a terminal-wrapper failure line first, so generic script messaging slows diagnosis.
- Evidence:
	- Repro in `issue.md` shows wrapper exit code and direct `InvalidOperationException` with non-specific guidance.
	- Research confirms `gh` supports meaningful context through exit semantics and command output, plus repo-context behavior (`GH_REPO`, `-R/--repo`).


## Proposed Fix

### Design summary (what changes where):
- Add a small, local diagnostic-classification helper in `scripts/dev-tools/link-parent-child.ps1` and use it from `Get-Issue` failure paths.
- Build error messages that include: issue label (`child`/`parent`), issue number, best-effort failure category, and concrete remediation commands/checks.
- Expand `tests/scripts/dev-tools/link-parent-child.Tests.ps1` to assert actionable diagnostics for representative failure categories while preserving current throw semantics.

### Boundaries and invariants to preserve:
- Keep script entrypoint and parameter surface unchanged:
	- `-ChildIssueNumber`
	- `-ParentIssueNumber`
- Keep exception contract unchanged: failures still raise `System.InvalidOperationException` via `Write-ScriptError` and return non-zero exit to callers/tasks.
- Keep success-path behavior unchanged for:
	- parent issue body update,
	- child comment creation,
	- no-op behavior when links already exist.
- Do not introduce new runtime dependencies; continue using `gh` CLI.

### Dependencies or blocked work:
- Dependency: `gh` CLI output/exit behavior for `issue view` and `auth status` guidance messaging.
- Dependency: existing Pester test harness in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
- No known blockers from provided issue + research context.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- `scripts/dev-tools/link-parent-child.ps1`
	- Add helper(s) to classify gh fetch failures and compose actionable diagnostic text.
	- Update `Get-Issue` failure branch to call the helper and emit enriched message.
- `tests/scripts/dev-tools/link-parent-child.Tests.ps1`
	- Add regression tests that validate richer diagnostics for fetch failure branches.

#### Functions/classes/CLI commands impacted:
- PowerShell functions:
	- `Get-Issue` (primary change)
	- `Invoke-GhCli` (read/forward raw output context as needed)
	- New local helper(s) for failure classification/message composition (name to be finalized during implementation)
- External CLI command usage remains:
	- `gh issue view <n> --json number,title,url,body`
	- Guidance references `gh auth status` and repo context validation.

#### Data flow and validation changes:
- Current flow:
	- `Get-Issue` executes `gh issue view` and inspects only `ExitCode` + empty/non-empty output.
- Updated flow:
	- Capture both `ExitCode` and command text returned via `Invoke-GhCli`.
	- Parse/classify failure signals (auth required, likely not found/invalid issue, likely repo context mismatch, likely permission issue, unknown).
	- Emit category-aware message including issue identifier and remediation hints.
- Input validation remains unchanged for issue number prompt/trim behavior in `Read-IssueNumber`.

#### Error handling and logging updates:
- Replace the generic `Unable to fetch ... Check the number and gh auth.` branch with diagnostic text that is still concise but action-oriented.
- Expected guidance snippets by category:
	- Auth-related: run `gh auth status`, verify token scopes.
	- Repo targeting mismatch: verify current repo and `GH_REPO`/host context.
	- Invalid/missing issue: verify issue number exists in target repo.
	- Permission denied: verify collaborator/role permissions for the repository.
- Preserve single throw point behavior (`Write-ScriptError`) and non-zero termination.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag required (message-only logic change).
- Rollback is low risk: revert diagnostic helper + `Get-Issue` message path and test additions if regression is detected.

### Technical specifications (interfaces/contracts):
- `Invoke-LinkParentChild` contract is unchanged for callers.
- On fetch failure, thrown message contract is strengthened:
	- Must include failing role (`child` or `parent`) and issue number.
	- Must include at least one actionable next step.
	- Must not suppress the failure (still throws).

#### Inputs/outputs and formats:
- Inputs:
	- Script parameters: `-ChildIssueNumber <string>`, `-ParentIssueNumber <string>`.
	- Environment context indirectly used by `gh` (repo/host/auth context such as `GH_REPO`, auth session).
- Outputs:
	- Success: existing `Write-Output` informational lines (unchanged).
	- Failure: `InvalidOperationException` message text with classified guidance.
- Format:
	- Human-readable plain text error string suitable for direct terminal and VS Code task terminal output.

#### Required configuration keys and defaults:
- No new configuration keys.
- Existing implicit defaults remain:
	- repo context inferred by `gh` unless environment overrides are present,
	- script relies on installed/authenticated `gh`.

#### Backward-compatibility expectations:
- Backward compatible for automation invoking this script:
	- Parameter names and script path unchanged.
	- Failure still returns non-zero.
	- Exception type remains `InvalidOperationException`.
- Intentional change:
	- Failure message text becomes more specific and therefore may require test assertion updates where exact strings are matched.

#### Performance constraints (latency/throughput/memory):
- No meaningful runtime impact expected:
	- classification is string inspection on already captured command output.
	- no new network calls required for baseline implementation.
- Optional best-effort repo-context lookup should be avoided unless needed to keep failure path lightweight.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- `gh` CLI is installed and callable from PowerShell in the target environment.
	- GitHub issue numbers provided correspond to the repository context selected by `gh`.
	- Existing Pester harness can mock `Invoke-GhCli` responses deterministically for category tests.
- Constraints (budget, performance, compatibility):
	- Keep changes minimal and localized to the link-parent-child script + tests.
	- Preserve current CLI surface and throw/non-zero semantics.
	- Maintain PowerShell 7+ compatibility and existing PoshQC expectations.
- External dependencies (services, libraries, releases):
	- GitHub CLI (`gh`)
	- GitHub Issues API access mediated by `gh`
	- No additional libraries or services added.

## Data / API / Config Impact
- User-facing or API changes:
	- User-visible failure messages for fetch failures are more explicit and categorized.
	- No command-line API shape changes.
- Data or migration considerations:
	- None; no persisted data format or migration path is affected.
- Logging/telemetry updates (if any):
	- No new telemetry pipeline introduced; diagnostics remain terminal-visible script error text.
- Compatibility notes (CLI flags, config schemas, versioning):
	- CLI flags unchanged.
	- No config schema/version changes.
	- Existing task/extension command mapping remains compatible.

## Test Strategy
Seeded from issue:

- [ ] Improve `scripts/dev-tools/link-parent-child.ps1` error handling so failures include actionable diagnostics (issue number, repository context, and `gh auth` status guidance).
- [ ] Preserve non-zero exit behavior but ensure the root error is surfaced clearly in task-invoked output.
- [ ] Add/adjust tests in `tests/scripts/dev-tools/` to validate both success and child-fetch failure messaging paths.
- [ ] Manual verification: run the script with valid and invalid child issue numbers and confirm error messages remain explicit in both direct terminal and task-wrapper invocation.

- Regression tests to add or update:
	- Update/add tests in `tests/scripts/dev-tools/link-parent-child.Tests.ps1` under `Describe "link-parent-child.ps1 - Get-Issue"`:
		- `It "errors with actionable diagnostics when gh command fails for child issue"`
		- `It "errors with actionable diagnostics when gh command fails for parent issue"`
		- `It "keeps non-zero failure semantics while improving message specificity"`
	- Ensure existing baseline tests that assert generic wording are updated to expected diagnostic wording.
- Unit tests (pytest) for the fixed behavior and boundaries:
	- Not applicable for this PowerShell script; use Pester unit tests in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
	- Invalid/non-existent issue number for child and parent fetch paths.
	- Auth-required/expired token simulation via mocked gh exit/output.
	- Permission-denied and repo-context mismatch signatures.
	- Unknown/uncategorized gh failure still emits actionable generic fallback guidance.
- Error handling and logging verification:
	- Assert thrown exception remains `InvalidOperationException`.
	- Assert error text includes `child`/`parent` role, issue number, and at least one explicit next action.
	- Confirm no silent failures and no conversion of hard failure into warning/no-op.
- Coverage impact and targets for changed lines/modules:
	- Maintain or increase branch coverage for `Get-Issue` failure branches in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`.
	- Ensure newly introduced classification helper branches are covered by deterministic mocks.
- Toolchain commands to run (format → lint → type-check → test):
	- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCFormat -Root ."`
	- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCAnalyze -Root ."`
	- Type checking step is not applicable for PowerShell; proceed to tests.
	- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root ."`
- Manual validation steps (if required):
	- Run direct script invocation with a known-invalid child issue number and verify diagnostic text includes actionable guidance.
	- Run via VS Code task `Dev: 4 Link GitHub Parent/Child Issues` with same invalid input and verify actionable script error remains visible in terminal output before/with wrapper failure.
	- Run a valid child/parent pair in a repo where access exists and verify success outputs are unchanged.


## Acceptance Criteria
- [ ] Repro now emits actionable diagnostics for fetch failures in both direct script invocation and VS Code task-wrapper execution, while still exiting non-zero.
- [ ] Regression tests in `tests/scripts/dev-tools/link-parent-child.Tests.ps1` cover child-fetch and parent-fetch failure diagnostics and pass.
- [ ] Failure messages for invalid/missing issue, auth required, and repo/permission context each include issue role + number + at least one explicit next action.
- [ ] Success-path behavior (parent update/comment logic and existing informational outputs) is unchanged for valid inputs.
- [ ] No new runtime dependencies, CLI flags, or config keys are introduced.
- [ ] Failure contract remains `InvalidOperationException` and does not downgrade hard failures to warnings.
- [ ] PowerShell quality loop passes for final implementation changes (format → analyze → test; type-check N/A for PowerShell).
- [ ] Feature docs in `docs/features/active/2026-02-17-link-parent-child-failure-9/` reflect final diagnostic behavior and test coverage.

## Risks & Mitigations
- Technical or operational risks:
	- Overfitting classification to specific gh error wording may cause brittle message paths across gh versions.
	- Updating exact-message assertions may increase maintenance overhead if wording changes again.
	- Optional task-level wrapper output can still be noisy even with better script diagnostics.
- Mitigations and rollbacks:
	- Keep category matching conservative and include robust fallback guidance for unknown failures.
	- Assert key message fragments (action + issue identifier) instead of full fixed strings where appropriate.
	- If diagnostics still appear buried in task execution, evaluate minimal `.vscode/tasks.json` presentation adjustments as a scoped follow-up issue.
	- Roll back to prior messaging by reverting helper + test deltas if unexpected regressions occur.

## Rollout & Follow-up
- Release/rollout steps:
	- Merge script + test changes on the issue branch.
	- Validate local and CI PowerShell checks pass.
	- Run one manual task-wrapper reproduction to confirm message visibility in developer workflow.
- Post-fix monitoring or clean-up tasks:
	- Monitor subsequent reports for uncategorized gh failures and capture additional signatures only if they recur.
	- If recurring repo-context confusion remains, open a follow-up issue for explicit `-R/--repo` support.
- Links: issue, PRs, related docs
	- Issue: `docs/features/active/2026-02-17-link-parent-child-failure-9/issue.md` and GitHub Issue #9
	- Research: `docs/features/active/2026-02-17-link-parent-child-failure-9/research.2026-02-18T01-09.md`
	- Plan: `docs/features/active/2026-02-17-link-parent-child-failure-9/plan.2026-02-17T20-05.md`

## Implementation Outcome

- Implemented diagnostic category helpers in `scripts/dev-tools/link-parent-child.ps1`:
	- `Get-IssueFetchFailureCategory`
	- `Get-IssueFetchFailureMessage`
- `Get-Issue` now classifies fetch failures and emits actionable, category-aware guidance while still throwing via `Write-ScriptError` (`InvalidOperationException`).
- Covered and validated the following fetch failure scenarios in `tests/scripts/dev-tools/link-parent-child.Tests.ps1`:
	- auth-required
	- not-found
	- permission/repo-context
	- unknown fallback
- Added a success-path stability guard for `Invoke-LinkParentChild` to ensure parent update + child comment behavior remains unchanged.
