# 2026-04-20-claude-cli-background-script - Plan

- **Issue:** #155
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-20T10-30
- **Status:** Complete
- **Version:** 0.2

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell Coding Standards: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

### Phase 0 — Compliance & Baseline Capture

- [x] [P0-T1] Read `.github/instructions/general-code-change.instructions.md` and confirm all baseline code-change rules are understood before writing any implementation code
  - Acceptance: Policy file read without error; content acknowledged in development log prior to Phase 1 execution

- [x] [P0-T2] Read `.github/instructions/powershell-code-change.instructions.md` and confirm all PowerShell-specific coding standards are understood before writing any implementation code
  - Acceptance: Policy file read without error; content acknowledged in development log prior to Phase 1 execution

- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` and confirm all baseline unit-test rules are understood before writing any test code
  - Acceptance: Policy file read without error; content acknowledged in development log prior to Phase 2 execution

- [x] [P0-T4] Read `.github/instructions/powershell-unit-test.instructions.md` and confirm all PowerShell-specific unit-test standards are understood before writing any test code
  - Acceptance: Policy file read without error; content acknowledged in development log prior to Phase 2 execution

- [x] [P0-T5] Stash the staged file `scripts/dev-tools/start-claudeworktree.ps1` via `git stash` so the working tree is clean before capturing the baseline test run
  - Preconditions: `scripts/dev-tools/start-claudeworktree.ps1` is staged (confirmed by git status at conversation start)
  - Acceptance: `git stash` exits 0; `git status` shows no staged or modified files for `start-claudeworktree.ps1`

- [x] [P0-T6] Run Pester baseline using `mcp__drmCopilotExtension__run_poshqc_test`; after the run completes, copy `artifacts/pester/pester-junit.xml` to `artifacts/pester/pester-baseline-issue-155.xml` so the pre-change result is preserved before Phase 3 overwrites it
  - Preconditions: P0-T5 complete; working tree is clean
  - Acceptance: Tool exits 0 or non-zero (both are valid baselines); `artifacts/pester/pester-baseline-issue-155.xml` exists on disk and is a copy of the pre-change JUnit output

- [x] [P0-T7] Restore the stashed file via `git stash pop` so the partial implementation is available for reference during development
  - Preconditions: P0-T6 complete; stash entry exists from P0-T5
  - Acceptance: `git stash pop` exits 0; `scripts/dev-tools/start-claudeworktree.ps1` is restored to the working tree

### Phase 1 — Script Implementation

- [x] [P1-T1] Unstage and delete `scripts/dev-tools/start-claudeworktree.ps1` using `git rm --cached` followed by `Remove-Item` (or `git checkout -- .` if unstage is sufficient), so the path is fully removed before the replacement script is created
  - Preconditions: P0-T7 complete; `start-claudeworktree.ps1` present in working tree
  - Acceptance: `scripts/dev-tools/start-claudeworktree.ps1` does not exist on disk and is not staged

- [x] [P1-T2] Create `scripts/dev-tools/new-claude-worktree-session.ps1` with the script-level `[CmdletBinding(SupportsShouldProcess)]` param block declaring `-ShortName` (mandatory `[string]`), `-Objective` (optional `[string]`), `-WorktreeParentPath` (optional `[string]`), and `-BranchName` (optional `[string]`); set `$ErrorActionPreference = 'Stop'` and `$InformationPreference = 'Continue'` at the top of the script body
  - Acceptance: File exists at `scripts/dev-tools/new-claude-worktree-session.ps1`; param block passes PowerShell syntax check; `[CmdletBinding(SupportsShouldProcess)]` present

- [x] [P1-T3] Implement `Get-WorktreeTimestamp` function in `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding()]` and a `$GetDateTime` injectable `[scriptblock]` parameter (default: `{ [datetime]::Now }`); function returns the timestamp as a `yyyyMMddHHmmss`-formatted string
  - Acceptance: Function definition present in the file; accepts `$GetDateTime` override; returns a string matching the format when invoked with a fixed datetime

- [x] [P1-T4] Implement `Build-WorktreePath` pure function in `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding()]`; accepts `$WorktreeParentPath`, `$Timestamp`, and `$ShortName` string parameters; returns the string `"$WorktreeParentPath/drm-copilot-wt-$Timestamp-$ShortName"`
  - Acceptance: Function definition present; output matches the `drm-copilot-wt-<timestamp>-<ShortName>` pattern for any input combination

- [x] [P1-T5] Implement `Build-BranchName` pure function in `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding()]`; accepts `$Timestamp`, `$ShortName`, and `$BranchName` string parameters; returns `$BranchName` unchanged when it is non-empty, otherwise returns `"feature/$Timestamp-$ShortName"`
  - Acceptance: Function definition present; returns passthrough when `$BranchName` provided; returns default format otherwise

- [x] [P1-T6] Implement `Test-PreconditionsMet` function in `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding()]` and injectable `$GetCommand` (`[scriptblock]`, default: `{ param([string]$Name) Get-Command $Name -ErrorAction SilentlyContinue }`) and `$TestPath` (`[scriptblock]`, default: `{ param([string]$Path) Test-Path $Path }`) parameters; function must `throw` a descriptive error message (not call `exit`) when `git` is not found on PATH, when `claude` is not found on PATH, or when the target worktree path already exists — in that order, before any filesystem mutation; the main script body (P1-T10) catches the throw and calls `exit 1`; this design is required for Pester testability via `Import-ScriptFunction`
  - Acceptance: Function definition present; throws a terminating error for each failure condition (not `exit 1`); non-failing invocation returns without error

- [x] [P1-T7] Implement `Invoke-GitWorktreeAdd` function in `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding()]` and injectable `$InvokeGit` (`[scriptblock]`, default: `{ param([string[]]$Args) & git @Args }`) parameter; function calls `git worktree add <worktreePath> -b <branchName>` using the injected scriptblock
  - Acceptance: Function definition present; uses `$InvokeGit` scriptblock for the git call; no direct `& git` call in the function body outside the default scriptblock

- [x] [P1-T8] Implement `Start-ClaudeBackground` function in `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding()]` and injectable `$InvokeStartProcess` (`[scriptblock]`, default: invokes `Start-Process` without `-Wait`) parameter; function launches `claude` with `--dangerously-skip-permissions` and the `-Objective` value (when non-empty) as arguments, sets the working directory to `$WorktreePath`, redirects stdout and stderr to `$WorktreePath/claude-session.log`, and returns the process object
  - Acceptance: Function definition present; `Start-Process` is called without `-Wait` in the production default; `--dangerously-skip-permissions` is present in the argument list; log file path is `<worktreePath>/claude-session.log`

- [x] [P1-T9] Implement `Write-LaunchResult` pure function in `scripts/dev-tools/new-claude-worktree-session.ps1` with `[CmdletBinding()]`; accepts `$WorktreePath`, `$ProcessId`, and `$LogFile` string parameters; writes three labeled lines to stdout via `Write-Output`: `"WorktreePath: $WorktreePath"`, `"ProcessId: $ProcessId"`, `"LogFile: $LogFile"`
  - Acceptance: Function definition present; output lines match the labeled format exactly

- [x] [P1-T10] Implement the script body in `scripts/dev-tools/new-claude-worktree-session.ps1` that calls all helper functions in sequence: `Get-WorktreeTimestamp`, `Build-WorktreePath`, `Build-BranchName`; wraps `Test-PreconditionsMet` in a `try/catch` that calls `exit 1` on throw; then gates `Invoke-GitWorktreeAdd` and `Start-ClaudeBackground` each behind `$PSCmdlet.ShouldProcess`; then calls `Write-LaunchResult`
  - Acceptance: Script body present after all function definitions; `try/catch` wraps `Test-PreconditionsMet` call and calls `exit 1` on error; `$PSCmdlet.ShouldProcess` guards both state-mutating calls; functions called in the required order

### Phase 2 — Unit Tests

- [x] [P2-T1] Create `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` with a top-level `BeforeAll` block that sets `$script:scriptPath` via `Join-Path -Path $PSScriptRoot -ChildPath "../../../scripts/dev-tools/new-claude-worktree-session.ps1"` and dot-sources `tests/scripts/powershell/Support/TestHelpers.ps1` to make `Import-ScriptFunction` available
  - Acceptance: File exists at `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`; `BeforeAll` block present; `$script:scriptPath` resolves to the correct absolute path

- [x] [P2-T2] Add `Describe "new-claude-worktree-session.ps1 - Get-WorktreeTimestamp"` block with `It` assertions: timestamp return value is a non-empty string; when `$GetDateTime` override returns a fixed datetime, the returned string matches `yyyyMMddHHmmss` format for that datetime
  - Acceptance: Both `It` blocks present; tests are self-contained and require no external dependencies

- [x] [P2-T3] Add `Describe "new-claude-worktree-session.ps1 - Build-WorktreePath"` block with `It` assertions: output contains the `drm-copilot-wt-` prefix; output ends with `-<ShortName>`; full path matches `<WorktreeParentPath>/drm-copilot-wt-<Timestamp>-<ShortName>` format
  - Acceptance: All three `It` blocks present; function exercised with representative input values

- [x] [P2-T4] Add `Describe "new-claude-worktree-session.ps1 - Build-BranchName"` block with `It` assertions: returns `feature/<Timestamp>-<ShortName>` when `$BranchName` is empty or not provided; returns the exact `$BranchName` value unchanged when it is non-empty
  - Acceptance: Both `It` blocks present; passthrough and default-derivation paths each exercised

- [x] [P2-T5] Add `Describe "new-claude-worktree-session.ps1 - Test-PreconditionsMet"` block with `It` assertions using the Pester `Should -Throw` pattern: throws when `claude` is not on PATH (injecting `$GetCommand` that returns `$null` for `claude`); throws when the target worktree path already exists (injecting `$TestPath` that returns `$true`); returns without error (does not throw) when all preconditions pass; use `{ Test-PreconditionsMet ... } | Should -Throw` for the failure cases
  - Acceptance: Three `It` blocks present; each failure case uses `Should -Throw`; no real `Get-Command` or `Test-Path` calls occur; passing case asserts no exception is thrown

- [x] [P2-T6] Add `Describe "new-claude-worktree-session.ps1 - Start-ClaudeBackground"` block with `It` assertions: `Start-Process` is called without `-Wait` (verified via `$InvokeStartProcess` capture scriptblock); `--dangerously-skip-permissions` is present in the arguments captured by `$InvokeStartProcess`; when `$Objective` is non-empty it is present in the arguments; returned value is the process object returned by `$InvokeStartProcess`
  - Acceptance: Four `It` blocks present; all external calls are intercepted via injectable scriptblocks; no real `Start-Process` or `claude` invocation occurs in these tests

- [x] [P2-T7] Add `Describe "new-claude-worktree-session.ps1 - Write-LaunchResult"` block with `It` assertions: output captured from `Write-LaunchResult` contains a line starting with `WorktreePath:`; contains a line starting with `ProcessId:`; contains a line starting with `LogFile:`
  - Acceptance: Three `It` blocks present; output captured via PowerShell stream capture or `$output = Write-LaunchResult ... | Out-String`

- [x] [P2-T8] Add `Describe "new-claude-worktree-session.ps1 - Integration Validation"` block with a single `It` assertion that reads `scripts/dev-tools/new-claude-worktree-session.ps1` as text and verifies all seven expected function names are present: `Get-WorktreeTimestamp`, `Build-WorktreePath`, `Build-BranchName`, `Test-PreconditionsMet`, `Invoke-GitWorktreeAdd`, `Start-ClaudeBackground`, `Write-LaunchResult`
  - Acceptance: One `It` block present; assertion checks all seven function names in a single pass

### Phase 3 — Toolchain QC

- [x] [P3-T1] Run `mcp__drmCopilotExtension__run_poshqc_format` to format `scripts/dev-tools/new-claude-worktree-session.ps1` and `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`
  - Acceptance: Tool exits 0; no formatting errors reported

- [x] [P3-T2] Run `mcp__drmCopilotExtension__run_poshqc_analyze` to lint `scripts/dev-tools/new-claude-worktree-session.ps1` and `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`; fix all findings reported; if any findings were fixed, restart the QC loop from P3-T1
  - Acceptance: Tool exits 0 with zero findings; if findings required fixes, P3-T1 re-executed before this task is marked complete

- [x] [P3-T3] Run `mcp__drmCopilotExtension__run_poshqc_test` to execute the full Pester suite; save the JUnit output to `artifacts/pester/pester-junit.xml`; if any tests fail, fix the failures and restart the QC loop from P3-T1
  - Acceptance: Tool exits 0; all tests pass; `artifacts/pester/pester-junit.xml` written; if failures required fixes, P3-T1 and P3-T2 re-executed before this task is marked complete

- [x] [P3-T4] Compare `artifacts/pester/pester-junit.xml` against `artifacts/pester/pester-baseline-issue-155.xml` to confirm no pre-existing tests regressed; document the test-count delta (new tests added for issue-155 vs baseline)
  - Acceptance: No previously passing test appears as failed in the post-change run; test count is equal to or greater than the baseline count

### Phase 4 — Documentation Update

- [x] [P4-T1] Mark all acceptance criteria checkboxes in `docs/features/active/2026-04-20-claude-cli-background-script-155/issue.md` as complete by changing `- [ ]` to `- [x]` for each criterion satisfied by the implementation
  - Acceptance: All acceptance criteria checkboxes in `issue.md` are checked; no criterion left unchecked after a passing Phase 3 run

- [x] [P4-T2] Update this plan file (`docs/features/active/2026-04-20-claude-cli-background-script-155/plan.2026-04-20T09-59.md`) to set **Status** to `Complete` and check off all completed task checkboxes
  - Acceptance: Plan header shows `Status: Complete`; all `- [ ]` task lines changed to `- [x]`

## Test Plan

- **Unit:** `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` — covers all seven helper functions and one integration-validation assertion via Pester v5 and `Import-ScriptFunction`
- **Integration:** Manual invocation: `./scripts/dev-tools/new-claude-worktree-session.ps1 -ShortName "auth-refactor" -Objective "Refactor the auth module."` from the main worktree; verify new worktree appears in `git worktree list` and a background `claude` process is running in the correct working directory (out of scope for automated Pester run)
- **Manual/CLI:** Confirm `WorktreePath:`, `ProcessId:`, and `LogFile:` appear on stdout immediately after invocation; confirm the script returns to the caller without blocking
- **Coverage evidence:**
  - Baseline artifact: `artifacts/pester/pester-baseline-issue-155.xml`
  - Post-change artifact: `artifacts/pester/pester-junit.xml`
  - Comparison: P3-T4 delta check confirms no regressions and documents test-count increase from baseline

## Open Questions / Notes

- The timestamp format `yyyyMMddHHmmss` is selected based on the repo convention observed in the working tree directory name (`drm-copilot-wt-20260314-224838`) and the research artifact recommendation. Two sessions started within the same second with the same `-ShortName` will collide on branch creation; this is a documented constraint from the issue and is out of scope for this implementation.
- The `$WorktreeParentPath` default (when not supplied) should resolve to `../` relative to the repo root. The exact default value resolution is left to the implementation step (P1-T2) to align with PowerShell's `$PSScriptRoot`-relative path resolution.
- Integration scenario testing (verify `git worktree list`, verify background process working directory) is explicitly out of scope for the automated Pester suite and is a manual verification step only.
