# Code Review — Issue #155: claude-cli-background-script

- **Timestamp:** 2026-04-20T10-30
- **Branch:** claude-cli-background-script-155
- **Files Reviewed:**
  - `scripts/dev-tools/new-claude-worktree-session.ps1` (212 lines)
  - `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1` (212 lines)

---

## 1. Production Script: `scripts/dev-tools/new-claude-worktree-session.ps1`

### 1.1 Correctness vs Issue Requirements

| Requirement | Implementation | Finding |
|---|---|---|
| Script path: `scripts/dev-tools/new-claude-worktree-session.ps1` | File exists at that exact path. | CORRECT |
| Parameter `-ShortName` (required `[string]`) | Declared with `[Parameter(Mandatory = $true)] [string] $ShortName`. | CORRECT |
| Parameter `-Objective` (optional `[string]`) | Declared as optional `[string] $Objective`. | CORRECT |
| Parameter `-WorktreeParentPath` (optional `[string]`, default `../` relative to repo root) | Declared as optional; default resolved in script body via `git rev-parse --show-toplevel` + `Split-Path -Parent`. | CORRECT |
| Parameter `-BranchName` (optional `[string]`) | Declared as optional `[string] $BranchName`. | CORRECT |
| Worktree path format: `<WorktreeParentPath>/drm-copilot-wt-<timestamp>-<ShortName>` | `Build-WorktreePath` returns `"$WorktreeParentPath/drm-copilot-wt-$Timestamp-$ShortName"`. | CORRECT |
| Default branch name: `feature/<timestamp>-<ShortName>` | `Build-BranchName` returns `"feature/$Timestamp-$ShortName"` when `$BranchName` is empty. | CORRECT |
| Custom `-BranchName` passthrough | `Build-BranchName` returns `$BranchName` unchanged when non-empty. | CORRECT |
| `--dangerously-skip-permissions` in Claude args | `Start-ClaudeBackground` builds `$claudeArgs = @('--dangerously-skip-permissions')` before appending objective. | CORRECT |
| Non-blocking launch via `Start-Process` without `-Wait` | Default `$InvokeStartProcess` scriptblock calls `Start-Process @StartArgs -PassThru` (no `-Wait`). | CORRECT |
| Log redirection (stdout and stderr) to file inside worktree | `$logFile = "$WorktreePath/claude-session.log"` used as both `RedirectStandardOutput` and `RedirectStandardError`. | CORRECT — note: both stdout and stderr redirect to the same file; this is by design per the issue. |
| Write `WorktreePath:`, `ProcessId:`, `LogFile:` to stdout before exit 0 | `Write-LaunchResult` emits all three labeled lines via `Write-Output`. | CORRECT |
| Exits non-zero if `claude` not on PATH before filesystem mutation | `Test-PreconditionsMet` throws before any git or filesystem call; script body catches and calls `exit 1`. | CORRECT |
| Exits non-zero if target path already exists before `git worktree add` | `Test-PreconditionsMet` checks `$TestPath $WorktreePath` and throws; caught before `Invoke-GitWorktreeAdd`. | CORRECT |
| Exits non-zero if `git` not on PATH | `Test-PreconditionsMet` checks `git` before `claude`, throws descriptive message. | CORRECT |

### 1.2 Design Quality

**Function count and cohesion:** Seven functions are implemented as specified. Each function is single-purpose and cohesive:

- `Get-WorktreeTimestamp` — pure, injectable datetime formatting.
- `Build-WorktreePath` — pure string construction.
- `Build-BranchName` — pure string construction with passthrough/default logic.
- `Test-PreconditionsMet` — guards with all three failure conditions, injectable dependencies.
- `Invoke-GitWorktreeAdd` — thin wrapper with injectable git call.
- `Start-ClaudeBackground` — process launch with injectable `Start-Process`.
- `Write-LaunchResult` — pure output formatter.

**Total lines:** 212. Well within the 500-line limit. Average function body is 10–15 lines.

**Separation of concerns:** Pure string functions (`Build-*`, `Get-*`, `Write-*`) contain no I/O. I/O-touching functions (`Test-PreconditionsMet`, `Invoke-GitWorktreeAdd`, `Start-ClaudeBackground`) receive all external dependencies via scriptblock injection. The script body is an orchestration-only sequence.

**One design note:** `Start-ClaudeBackground` is declared with `[CmdletBinding(SupportsShouldProcess)]` but does not internally call `$PSCmdlet.ShouldProcess(...)`. The ShouldProcess gate is applied at the script body level (`if ($PSCmdlet.ShouldProcess($worktreePath, 'Start-Process claude'))`). The inner function's `SupportsShouldProcess` declaration is therefore not exercised and adds minor noise, but it does not cause incorrect behavior. The outer gate is what matters.

### 1.3 Error Handling

`Test-PreconditionsMet` throws for all three required failure conditions:

1. `git` not on PATH — throws with message containing "git is not available on PATH".
2. `claude` not on PATH — throws with message containing "claude is not available on PATH".
3. Target path already exists — throws with message containing "Target worktree path already exists".

The checks are performed in the order specified by the issue (git, then claude, then path). The `try/catch` in the script body calls `Write-Error $_.Exception.Message` followed by `exit 1`, which surfaces the failure message to the caller without a stack trace.

**No gaps in error handling for the three specified conditions.**

One unhandled edge case: if `git worktree add` fails (e.g., branch already exists due to same-second collision), the error will propagate as an unhandled terminating error because `$ErrorActionPreference = 'Stop'` is set. The issue documents the same-second collision as an out-of-scope constraint. The behavior (unhandled termination) is acceptable given that constraint is documented, though a more explicit error message would improve diagnostics.

### 1.4 ShouldProcess Gates

Both state-mutating calls are gated:

```powershell
if ($PSCmdlet.ShouldProcess($worktreePath, 'git worktree add')) {
    Invoke-GitWorktreeAdd -WorktreePath $worktreePath -BranchName $resolvedBranch
}

if ($PSCmdlet.ShouldProcess($worktreePath, 'Start-Process claude')) {
    $process = Start-ClaudeBackground -WorktreePath $worktreePath -Objective $Objective
}
```

The `$process` variable is initialized to `$null` before the second gate, and `$processId` falls back to `'0'` if `$process` is `$null` (which occurs when `-WhatIf` is used). This is correct behavior for `-WhatIf` support.

### 1.5 Security Observations

- `--dangerously-skip-permissions` is hardcoded as required by the issue spec. No way to omit it at call time. The issue documents this as an accepted risk; callers must supply well-scoped objectives.
- No `Invoke-Expression` usage.
- No hardcoded credentials or paths.
- The `$WorktreeParentPath` default resolution calls `git rev-parse --show-toplevel` in the script body (outside the injected dependency pattern). This is the only external call in the script body that is not abstracted. It will fail if run outside a git repository. For the documented use case (run from the main worktree), this is acceptable.

### 1.6 Edge Cases

| Edge Case | Handling |
|---|---|
| `-Objective` is empty string | `Start-ClaudeBackground`: `if ($Objective)` guard omits the objective from args when empty. Claude launches with only `--dangerously-skip-permissions`. This matches the optional parameter spec. |
| `-BranchName` is empty string (vs not supplied) | `Build-BranchName` uses `if ($BranchName)`, which treats both `""` and `$null` as absent. Consistent behavior. |
| `-WorktreeParentPath` is empty string | `if (-not $WorktreeParentPath)` guard in script body triggers default resolution. Treats `""` as unset. |
| Same-second collision (same `$ShortName`, same second) | Not handled — documented constraint in issue. Git will fail on branch creation; `$ErrorActionPreference = 'Stop'` surfaces the error. |
| `git rev-parse` fails (run outside git repo) | Not guarded; will produce an error before any worktree operation. Acceptable for the documented use case. |

---

## 2. Test File: `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`

### 2.1 Coverage of Acceptance Criteria

| AC Item | Test Coverage | Finding |
|---|---|---|
| Worktree path format (`drm-copilot-wt-<timestamp>-<ShortName>`) | `Build-WorktreePath` describe: prefix test, suffix test, full path test. | COVERED |
| Default branch name (`feature/<timestamp>-<ShortName>`) | `Build-BranchName` describe: default derivation test. | COVERED |
| Custom `-BranchName` passthrough | `Build-BranchName` describe: custom branch passthrough test. | COVERED |
| Claude process starts non-blocking (no `-Wait`) | `Start-ClaudeBackground` describe: no `-Wait` assertion via captured args. | COVERED |
| `--dangerously-skip-permissions` in args | `Start-ClaudeBackground` describe: arg list contains assertion. | COVERED |
| `-Objective` included in args when supplied | `Start-ClaudeBackground` describe: objective inclusion test. | COVERED |
| Returns process object | `Start-ClaudeBackground` describe: return value test. | COVERED |
| Stdout contains `WorktreePath:`, `ProcessId:`, `LogFile:` | `Write-LaunchResult` describe: three separate line-prefix tests. | COVERED |
| `claude` not on PATH exits non-zero | `Test-PreconditionsMet` describe: throws when claude absent (error propagates to exit 1 in body). | COVERED |
| `git` not on PATH exits non-zero | `Test-PreconditionsMet` describe: throws when git absent. | COVERED |
| Target path exists exits non-zero | `Test-PreconditionsMet` describe: throws when path exists. | COVERED |
| All preconditions pass — no throw | `Test-PreconditionsMet` describe: does not throw test. | COVERED |

**All issue acceptance criteria are covered by unit tests.**

The issue's "Test Conditions to Consider" also lists integration scenario testing (verify `git worktree list`, verify background process working directory). The plan explicitly scopes integration tests as manual-only and out of scope for the automated Pester suite. This is consistent with the general test policy (unit tests must not depend on external services). Not a gap.

### 2.2 `Import-ScriptFunction` Pattern

All seven `Describe` blocks use:

```powershell
BeforeEach {
    . (Import-ScriptFunction -Path $script:scriptPath -Name "<FunctionName>")
}
```

This follows the established repo pattern from `new-potential-entry.Tests.ps1` and `run-actionlint.Tests.ps1`. The `BeforeAll` block correctly dot-sources `TestHelpers.ps1` to make `Import-ScriptFunction` available, with a `$PSScriptRoot` fallback for environments where `$PSScriptRoot` may be empty.

### 2.3 No Real External Calls

All functions with external dependencies (`Get-Command`, `Test-Path`, `git`, `Start-Process`) are tested exclusively via injected scriptblock overrides. No real process is spawned. No filesystem operations occur. Determinism is fully maintained.

### 2.4 Test Naming and Structure

- File name: `new-claude-worktree-session.Tests.ps1` — correct `*.Tests.ps1` convention.
- One `Describe` block per function under test, plus one integration-validation `Describe`.
- `Context` groups related assertions within each `Describe`.
- `It` descriptions are explicit and unambiguous.
- `$script:capturedStartArgs` is initialized in `BeforeEach` for `Start-ClaudeBackground` tests, preventing bleed between `It` blocks.

**One minor structural observation:** The `Integration Validation` `Describe` block at line 198 reads the script file as text and asserts all seven function definitions are present. This is a structural completeness check, not a behavioral test. It is a reasonable sentinel to catch accidental function deletion.

### 2.5 Test Count Delta

- Baseline (`pester-baseline-issue-155.xml`): 294 tests, 0 failures, 7 disabled.
- Post-change (`pester-junit.xml`): 313 tests, 0 failures, 7 disabled.
- Delta: +19 tests. The new test file accounts for this increase.
- No previously passing tests appear as failed in the post-change run.

---

## Overall Code Quality Verdict

**PASS WITH NOTES**

The implementation is correct, well-structured, and fully aligned with the issue requirements. Notes:

1. `Start-ClaudeBackground` carries `[CmdletBinding(SupportsShouldProcess)]` internally but does not call `$PSCmdlet.ShouldProcess` within the function body. The ShouldProcess gate is applied externally in the script body. The internal declaration is unused noise. This does not affect correctness.

2. The `git rev-parse --show-toplevel` call in the script body is not abstracted behind a scriptblock parameter, making the default-path-resolution path untestable in unit tests. This is a minor testability gap; integration testing covers the happy path.

3. `git worktree add` failures (e.g., same-second branch collision) propagate as unhandled terminating errors with the raw git error message. Adding a descriptive `try/catch` around `Invoke-GitWorktreeAdd` in the script body would improve diagnostics. This is out of scope per the issue constraints.
