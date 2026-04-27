# Atomic Implementation Plan — Worktree Naming Bug Fix

**Feature folder:** `docs/features/active/2026-04-26-worktree-naming-bug/`
**Work mode:** `full-bug`
**Plan path:** `docs/features/active/2026-04-26-worktree-naming-bug/plan.md`
**Evidence root:** `docs/features/active/2026-04-26-worktree-naming-bug/evidence/`

---

## Acceptance Criteria Reference

- AC1: `formatWorktreeTimestamp` returns `yyyy-MM-dd-HH-mm` (no seconds, dashes between all fields).
- AC2: `buildWorktreePath` accepts `repoName` and returns `<parent>/<repoName>-wt-<timestamp>`.
- AC3: `buildBranchName` accepts `repoName` and returns `<repoName>-wt-<timestamp>` (no `feature/` prefix).
- AC4: `extension.ts` no longer prompts for ShortName; derives `repoName` from `path.basename(workspaceRoot)`.
- AC5: `Get-WorktreeTimestamp` returns `yyyy-MM-dd-HH-mm` in both PowerShell scripts.
- AC6: `Build-WorktreePath` accepts `$RepoName` and returns `$WorktreeParentPath/$RepoName-wt-$Timestamp`.
- AC7: `Build-BranchName` accepts `$RepoName` and returns `$RepoName-wt-$Timestamp`.
- AC8: `$ShortName` parameter removed from both PowerShell scripts.
- AC9: All TypeScript tests pass.
- AC10: All Pester tests pass.
- AC11: Full toolchain passes with zero errors and no coverage regression.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read policy file `CLAUDE.md` to confirm tone and policy-compliance reading order. No artifact required; reading is prerequisite only.

- [x] [P0-T2] Read policy file `.claude/rules/general-code-change.md` and confirm the mandatory toolchain loop order (format → lint → typecheck → test) and 500-line file limit. No artifact required.

- [x] [P0-T3] Read policy file `.claude/rules/general-unit-test.md` and confirm coverage thresholds (repository-wide >= 80%, new code >= 90%) and Arrange-Act-Assert structure requirement. No artifact required.

- [x] [P0-T4] Read policy file `.claude/rules/typescript.md` and confirm TypeScript toolchain commands: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:unit`, `npm run test:unit:coverage`. No artifact required.

- [x] [P0-T5] Read policy file `.claude/rules/powershell.md` and confirm PowerShell toolchain MCP commands: `mcp__drmCopilotExtension__run_poshqc_format`, `mcp__drmCopilotExtension__run_poshqc_analyze`, `mcp__drmCopilotExtension__run_poshqc_test`. No artifact required.

- [x] [P0-T6] Write policy-read evidence artifact to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/phase0-instructions-read.md`. File must include: `Timestamp:`, `Policy Order:` (list of files read in order), and confirmation that all five policy files were read.

- [x] [P0-T7] Run TypeScript baseline format check from `extensions/drm-copilot/` with command `npm run format`. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/ts-baseline-format.md`. File must include: `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T8] Run TypeScript baseline lint check from `extensions/drm-copilot/` with command `npm run lint`. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/ts-baseline-lint.md`. File must include: `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T9] Run TypeScript baseline type check from `extensions/drm-copilot/` with command `npm run typecheck`. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/ts-baseline-typecheck.md`. File must include: `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T10] Run TypeScript baseline unit tests with coverage from `extensions/drm-copilot/` with command `npm run test:unit:coverage`. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/ts-baseline-test-coverage.md`. File must include: `Timestamp:`, `Command: npm run test:unit:coverage`, `EXIT_CODE:`, `Output Summary:` (must include numeric coverage percentage for overall repo and for `claude-worktree-session.ts` module).

- [x] [P0-T11] Run PowerShell baseline format check using MCP tool `mcp__drmCopilotExtension__run_poshqc_format`. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/ps-baseline-format.md`. File must include: `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T12] Run PowerShell baseline analyze check using MCP tool `mcp__drmCopilotExtension__run_poshqc_analyze`. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/ps-baseline-analyze.md`. File must include: `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T13] Run PowerShell baseline tests using MCP tool `mcp__drmCopilotExtension__run_poshqc_test`. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/baseline/ps-baseline-test.md`. File must include: `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_test`, `EXIT_CODE:`, `Output Summary:` (must include numeric pass/fail counts and coverage percentage for `new-claude-worktree-session.ps1`).

---

### Phase 1 — TypeScript Pure Helpers (Production)

Target file: `extensions/drm-copilot/src/claude-worktree-session.ts`

- [x] [P1-T1] In `extensions/drm-copilot/src/claude-worktree-session.ts`, update the JSDoc for `formatWorktreeTimestamp`: change the `@returns` description from "14-character string composed of zero-padded calendar fields" to "16-character dash-separated string in `yyyy-MM-dd-HH-mm` format". Remove the `@remarks` or description references to `yyyyMMddHHmmss`. Acceptance: JSDoc reflects the new format; no functional code changed yet.

- [x] [P1-T2] In `extensions/drm-copilot/src/claude-worktree-session.ts`, in the body of `formatWorktreeTimestamp`, remove the `const second = ...` line. Change the return statement from `` `${year}${month}${day}${hour}${minute}${second}` `` to `` `${year}-${month}-${day}-${hour}-${minute}` ``. Acceptance: Function returns `yyyy-MM-dd-HH-mm` with no seconds and dashes between all fields (AC1).

- [x] [P1-T3] In `extensions/drm-copilot/src/claude-worktree-session.ts`, update the JSDoc for `buildWorktreePath`: replace the `@param shortName` tag with `@param repoName` (description: "Basename of the destination repository"). Update the `@returns` description to reflect the new format `<parent>/<repoName>-wt-<timestamp>`. Remove the `@remarks` reference to `yyyyMMddHHmmss` timestamp format. Acceptance: JSDoc is consistent with new parameter names and return format.

- [x] [P1-T4] In `extensions/drm-copilot/src/claude-worktree-session.ts`, change the signature of `buildWorktreePath` from `(workspaceParent: string, timestamp: string, shortName: string)` to `(workspaceParent: string, timestamp: string, repoName: string)`. Change the return template literal from `` `${normalizedParent}/drm-copilot-wt-${timestamp}-${shortName}` `` to `` `${normalizedParent}/${repoName}-wt-${timestamp}` ``. Acceptance: Function returns `<parent>/<repoName>-wt-<timestamp>` (AC2).

- [x] [P1-T5] In `extensions/drm-copilot/src/claude-worktree-session.ts`, update the JSDoc for `buildBranchName`: replace the `@param shortName` tag with `@param repoName` (description: "Basename of the destination repository"). Update the `@returns` description from "conventional `feature/<timestamp>-<shortName>` branch name" to "branch name in `<repoName>-wt-<timestamp>` format". Acceptance: JSDoc is consistent with new parameter names and return format.

- [x] [P1-T6] In `extensions/drm-copilot/src/claude-worktree-session.ts`, change the signature of `buildBranchName` from `(timestamp: string, shortName: string)` to `(timestamp: string, repoName: string)`. Change the return statement from `` `feature/${timestamp}-${shortName}` `` to `` `${repoName}-wt-${timestamp}` ``. Acceptance: Function returns `<repoName>-wt-<timestamp>` with no `feature/` prefix (AC3).

---

### Phase 2 — TypeScript Helper Tests

Target file: `extensions/drm-copilot/test/claude-worktree-session.test.ts`

- [x] [P2-T1] In `extensions/drm-copilot/test/claude-worktree-session.test.ts`, in the `formatWorktreeTimestamp` describe block, update the first `it` description from `"formats a fixed local-time date as a 14-character yyyyMMddHHmmss string"` to `"formats a fixed local-time date as a 16-character yyyy-MM-dd-HH-mm string"`. Update the `expect(result).toBe("20260420095937")` assertion to `expect(result).toBe("2026-04-20-09-59")`. Acceptance: Test description and expected value match new format.

- [x] [P2-T2] In the second `it` block for `formatWorktreeTimestamp`, update `expect(result).toBe("20260101000000")` to `expect(result).toBe("2026-01-01-00-00")` and update `expect(result).toHaveLength(14)` to `expect(result).toHaveLength(16)`. Acceptance: Both assertions reflect the new 16-character dash-separated format (AC1).

- [x] [P2-T3] In the `buildWorktreePath` describe block, update all three `it` tests: replace `shortName = "auth"` variable name with `repoName = "auth"` (same string value). In the first test, update the description from `"composes the canonical drm-copilot-wt path with forward slashes"` to `"composes the canonical repoName-wt path with forward slashes"` and update `expect(result).toBe("/parent/drm-copilot-wt-20260420095937-auth")` to `expect(result).toBe("/parent/auth-wt-2026-04-20-09-59")` (using `timestamp = "2026-04-20-09-59"`). Acceptance: Test variable names, descriptions, and expected values use new naming scheme (AC2).

- [x] [P2-T4] In the `buildWorktreePath` second `it` test ("normalizes Windows-style backslashes"), update the call argument from `"20260420095937", "auth"` to `"2026-04-20-09-59", "auth"` and update `expect(result).toBe("C:/repos/drm-copilot-wt-20260420095937-auth")` to `expect(result).toBe("C:/repos/auth-wt-2026-04-20-09-59")`. Acceptance: Assertion reflects new path format.

- [x] [P2-T5] In the `buildWorktreePath` third `it` test ("strips trailing slashes"), update the call from `buildWorktreePath(parent, "20260420095937", "auth")` to `buildWorktreePath(parent, "2026-04-20-09-59", "auth")` and update `expect(result).toBe("/parent/drm-copilot-wt-20260420095937-auth")` to `expect(result).toBe("/parent/auth-wt-2026-04-20-09-59")`. Acceptance: Assertion reflects new path format.

- [x] [P2-T6] In the `buildBranchName` describe block, update the `it` description from `"composes a feature/<timestamp>-<shortName> branch name"` to `"composes a <repoName>-wt-<timestamp> branch name"`. Update the call from `buildBranchName("20260420095937", "auth")` to `buildBranchName("2026-04-20-09-59", "auth")`. Update `expect(result).toBe("feature/20260420095937-auth")` to `expect(result).toBe("auth-wt-2026-04-20-09-59")`. Acceptance: Test reflects new branch format (AC3).

- [x] [P2-T7] In the `buildWorktreeSessionCommands` describe block, update the `baseInput` fixture: change `worktreePath: "/parent/drm-copilot-wt-20260420095937-auth"` to `worktreePath: "/parent/auth-wt-2026-04-20-09-59"` and change `branchName: "feature/20260420095937-auth"` to `branchName: "auth-wt-2026-04-20-09-59"`. Acceptance: Fixture uses new path and branch naming.

- [x] [P2-T8] In the `buildWorktreeSessionCommands` first `it` test ("emits a git command"), update the `expect(commands.git).toBe(...)` assertion to use the new worktree path and branch: `"git -C '/parent/drm-copilot' worktree add '/parent/auth-wt-2026-04-20-09-59' -b 'auth-wt-2026-04-20-09-59'"`. Acceptance: Assertion matches new path and branch.

- [x] [P2-T9] In the `buildWorktreeSessionCommands` second `it` test ("emits a Set-Location command"), update `expect(commands.setLocation).toBe(...)` to `"Set-Location '/parent/auth-wt-2026-04-20-09-59'"`. Acceptance: Assertion matches new worktree path.

---

### Phase 3 — Extension Handler

Target file: `extensions/drm-copilot/src/extension.ts`

- [x] [P3-T1] In `extensions/drm-copilot/src/extension.ts`, remove the `promptForShortName` import from the import statement at line 22 (the destructured import from `"./extension-command-helpers"`). Acceptance: `promptForShortName` no longer appears in the import list; all other imports from that module are preserved.

- [x] [P3-T2] In `extensions/drm-copilot/src/extension.ts`, within the `newClaudeWorktreeSessionDisposable` handler body, remove the block:
  ```typescript
  const shortName = await promptForShortName(
    "drm-copilot: New Claude Worktree Session",
    "Enter a kebab-case short name for the worktree and branch.",
  );
  if (!shortName) {
    return;
  }
  ```
  Acceptance: The `shortName` variable and its early-return guard no longer exist in the handler.

- [x] [P3-T3] In `extensions/drm-copilot/src/extension.ts`, in the `newClaudeWorktreeSessionDisposable` handler body, after the line `const workspaceRoot = getWorkspaceRoot();` add: `const repoName = path.basename(workspaceRoot);`. Acceptance: `repoName` is declared as a `const` derived from `path.basename(workspaceRoot)` (AC4).

- [x] [P3-T4] In `extensions/drm-copilot/src/extension.ts`, update the `buildWorktreePath` call from `buildWorktreePath(workspaceParent, timestamp, shortName)` to `buildWorktreePath(workspaceParent, timestamp, repoName)`. Acceptance: Call uses `repoName` in place of `shortName`.

- [x] [P3-T5] In `extensions/drm-copilot/src/extension.ts`, update the `buildBranchName` call from `buildBranchName(timestamp, shortName)` to `buildBranchName(timestamp, repoName)`. Acceptance: Call uses `repoName` in place of `shortName`.

---

### Phase 4 — PowerShell Standalone Script

Target file: `scripts/dev-tools/new-claude-worktree-session.ps1`

- [x] [P4-T1] In `scripts/dev-tools/new-claude-worktree-session.ps1`, update the `.SYNOPSIS` block: replace "derived from -ShortName" with "derived from the destination repository's basename". Update the `.DESCRIPTION` block similarly. Remove the `.PARAMETER ShortName` doc block entirely. Add or update `.PARAMETER BranchName` to reflect the new default format `<repoName>-wt-<timestamp>`. Acceptance: Doc-comment block has no `ShortName` references.

- [x] [P4-T2] In `scripts/dev-tools/new-claude-worktree-session.ps1`, in the `param()` block at the top of the script, remove the mandatory `$ShortName` parameter:
  ```powershell
  [Parameter(Mandatory = $true)]
  [string] $ShortName,
  ```
  Acceptance: `$ShortName` is no longer declared as a script-level parameter (AC8).

- [x] [P4-T3] In `scripts/dev-tools/new-claude-worktree-session.ps1`, in `Get-WorktreeTimestamp`, change `.ToString('yyyyMMddHHmmss')` to `.ToString('yyyy-MM-dd-HH-mm')`. Acceptance: Function returns a dash-separated string with no seconds field (AC5).

- [x] [P4-T4] In `scripts/dev-tools/new-claude-worktree-session.ps1`, in `Build-WorktreePath`, replace the parameter `[Parameter(Mandatory = $true)] [string] $ShortName` with `[Parameter(Mandatory = $true)] [string] $RepoName`. Change the return statement from `"$WorktreeParentPath/drm-copilot-wt-$Timestamp-$ShortName"` to `"$WorktreeParentPath/$RepoName-wt-$Timestamp"`. Acceptance: Function signature uses `$RepoName` and returns `$WorktreeParentPath/$RepoName-wt-$Timestamp` (AC6).

- [x] [P4-T5] In `scripts/dev-tools/new-claude-worktree-session.ps1`, in `Build-BranchName`, replace the parameter `[Parameter(Mandatory = $true)] [string] $ShortName` with `[Parameter(Mandatory = $true)] [string] $RepoName`. Change the default return from `"feature/$Timestamp-$ShortName"` to `"$RepoName-wt-$Timestamp"`. Acceptance: Function signature uses `$RepoName` and returns `$RepoName-wt-$Timestamp` when `$BranchName` is not supplied (AC7).

- [x] [P4-T6] In `scripts/dev-tools/new-claude-worktree-session.ps1`, in the script body, after the block that resolves `$WorktreeParentPath`, add:
  ```powershell
  $repoName = Split-Path -Leaf $repoRoot
  ```
  Ensure `$repoRoot` is assigned before this line (it is already assigned in the `if (-not $WorktreeParentPath)` block; move or duplicate the `$repoRoot` assignment outside that conditional when `$WorktreeParentPath` is explicitly supplied). Acceptance: `$repoName` is available in the script body derived from the repo root basename (AC6, AC7).

- [x] [P4-T7] In `scripts/dev-tools/new-claude-worktree-session.ps1`, in the script body, update the `Build-WorktreePath` call from `-ShortName $ShortName` to `-RepoName $repoName`. Update the `Build-BranchName` call from `-ShortName $ShortName` to `-RepoName $repoName`. Update the `Test-PreconditionsMet` error message that references `-ShortName` to reference the repo name concept instead. Acceptance: Script body calls helpers with `$repoName` and no `$ShortName` references remain.

---

### Phase 5 — PowerShell Template

Target file: `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`

- [x] [P5-T1] In `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`, apply the identical doc-comment update as P4-T1: update `.SYNOPSIS`, `.DESCRIPTION`, remove `.PARAMETER ShortName`, update `.PARAMETER BranchName` default description. Acceptance: Doc-comment block has no `ShortName` references.

- [x] [P5-T2] In `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`, apply the identical `param()` block change as P4-T2: remove the mandatory `$ShortName` parameter. Acceptance: `$ShortName` is no longer declared as a script-level parameter (AC8).

- [x] [P5-T3] In `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`, apply the identical `Get-WorktreeTimestamp` change as P4-T3: change `.ToString('yyyyMMddHHmmss')` to `.ToString('yyyy-MM-dd-HH-mm')`. Acceptance: Function returns dash-separated `yyyy-MM-dd-HH-mm` (AC5).

- [x] [P5-T4] In `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`, apply the identical `Build-WorktreePath` change as P4-T4: replace `$ShortName` parameter with `$RepoName` and update return string. Acceptance: Function returns `$WorktreeParentPath/$RepoName-wt-$Timestamp` (AC6).

- [x] [P5-T5] In `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`, apply the identical `Build-BranchName` change as P4-T5: replace `$ShortName` parameter with `$RepoName` and update default return string. Acceptance: Function returns `$RepoName-wt-$Timestamp` (AC7).

- [x] [P5-T6] In `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`, apply the identical script body changes as P4-T6 and P4-T7: add `$repoName = Split-Path -Leaf $repoRoot`, update `Build-WorktreePath` call to use `-RepoName $repoName`, update `Build-BranchName` call to use `-RepoName $repoName`, remove all `$ShortName` references. Acceptance: Template script body is functionally identical to the standalone script after Phase 4 changes.

---

### Phase 6 — PowerShell Tests

Target file: `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`

- [x] [P6-T1] In `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`, in the `Get-WorktreeTimestamp` describe block, update the `It "returns correct yyyyMMddHHmmss format..."` description to `"returns correct yyyy-MM-dd-HH-mm format for injected fixed datetime"`. Update `$result | Should -Be "20260420095937"` to `$result | Should -Be "2026-04-20-09-59"`. Acceptance: Test description and expected value match new timestamp format (AC5).

- [x] [P6-T2] In `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`, in the `Build-WorktreePath` describe block, update all three `It` tests to use `-RepoName "auth"` in place of `-ShortName "auth"` and use timestamp `"2026-04-20-09-59"` in place of `"20260420095937"`. Update the first test description from `"output contains the drm-copilot-wt- prefix"` to `"output contains the repoName-wt- segment"` and change `Should -Match "drm-copilot-wt-"` to `Should -Match "auth-wt-"`. Acceptance: All three tests use new parameter name and timestamp.

- [x] [P6-T3] In `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`, in the `Build-WorktreePath` second test ("output ends with the ShortName"), update description to `"output ends with the timestamp"` and change `Should -Match "-auth$"` to `Should -Match "-2026-04-20-09-59$"`. Acceptance: Assertion checks that the path ends with the timestamp component.

- [x] [P6-T4] In `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`, in the `Build-WorktreePath` third test ("full path matches expected format"), update `Should -Be "/parent/drm-copilot-wt-20260420095937-auth"` to `Should -Be "/parent/auth-wt-2026-04-20-09-59"`. Acceptance: Full-path assertion matches new format (AC6).

- [x] [P6-T5] In `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`, in the `Build-BranchName` describe block, update all calls from `-ShortName "auth"` to `-RepoName "auth"` and from `-Timestamp "20260420095937"` to `-Timestamp "2026-04-20-09-59"`. Update the first test description from `"returns default feature branch when BranchName is empty"` to `"returns default repoName-wt-timestamp branch when BranchName is empty"` and change `Should -Be "feature/20260420095937-auth"` to `Should -Be "auth-wt-2026-04-20-09-59"`. Acceptance: Default branch name test uses new format (AC7).

- [x] [P6-T6] In `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`, in the `Build-BranchName` second test ("returns custom BranchName unchanged when supplied"), update the call from `-Timestamp "20260420095937" -ShortName "auth"` to `-Timestamp "2026-04-20-09-59" -RepoName "auth"`. The expected value `"fix/my-custom-branch"` remains unchanged (custom override path is unaffected). Acceptance: Custom branch name passthrough test uses updated parameter name.

---

### Phase 7 — Full QA Gates

- [x] [P7-T1] Run TypeScript formatter from `extensions/drm-copilot/` with command `npm run format`. If the command changes any files, record the changed files and proceed to P7-T2 from P7-T1. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ts-qa-format.md`. File must include: `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P7-T2] Run TypeScript linter from `extensions/drm-copilot/` with command `npm run lint`. If the command fails or changes files, fix all issues and restart from P7-T1. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ts-qa-lint.md`. File must include: `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P7-T3] Run TypeScript type checker from `extensions/drm-copilot/` with command `npm run typecheck`. If it reports errors, fix all issues and restart from P7-T1. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ts-qa-typecheck.md`. File must include: `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P7-T4] Run TypeScript unit tests with coverage from `extensions/drm-copilot/` with command `npm run test:unit:coverage`. If any test fails, fix issues and restart from P7-T1. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ts-qa-test-coverage.md`. File must include: `Timestamp:`, `Command: npm run test:unit:coverage`, `EXIT_CODE:`, `Output Summary:` (must include numeric overall coverage percentage and coverage for `claude-worktree-session.ts`; must confirm no regression vs baseline captured in P0-T10).

- [x] [P7-T5] Verify AC9: confirm all `claude-worktree-session.test.ts` tests pass (zero failures) in the P7-T4 run output. Record pass/fail count in the P7-T4 artifact `Output Summary:`. No separate file required.

- [x] [P7-T6] Run PowerShell formatter using MCP tool `mcp__drmCopilotExtension__run_poshqc_format`. If the command changes files, record the changed files and proceed to P7-T7 from P7-T6. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ps-qa-format.md`. File must include: `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P7-T7] Run PowerShell analyzer using MCP tool `mcp__drmCopilotExtension__run_poshqc_analyze`. If the command fails or reports violations, fix all issues and restart from P7-T6. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ps-qa-analyze.md`. File must include: `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P7-T8] Run PowerShell tests using MCP tool `mcp__drmCopilotExtension__run_poshqc_test`. If any test fails, fix issues and restart from P7-T6. Write result to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ps-qa-test.md`. File must include: `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_test`, `EXIT_CODE:`, `Output Summary:` (must include numeric pass/fail counts and coverage for `new-claude-worktree-session.ps1`; must confirm no regression vs baseline captured in P0-T13).

- [x] [P7-T9] Verify AC10: confirm all `new-claude-worktree-session.Tests.ps1` tests pass (zero failures) in the P7-T8 run output. Record pass/fail count in the P7-T8 artifact `Output Summary:`. No separate file required.

- [x] [P7-T10] Verify AC11 coverage gate: compare the TypeScript coverage value from P7-T4 against the baseline from P0-T10. Confirm overall line coverage remains >= 80% and `claude-worktree-session.ts` module coverage remains >= 90%. Record the comparison (baseline %, post-change %, delta) in the P7-T4 artifact `Output Summary:`. If coverage regressed, fix coverage gaps and restart from P7-T1.

- [x] [P7-T11] Verify AC11 coverage gate: compare the PowerShell coverage value from P7-T8 against the baseline from P0-T13. Confirm overall coverage remains >= 80% and `new-claude-worktree-session.ps1` coverage remains >= 90%. Record the comparison (baseline %, post-change %, delta) in the P7-T8 artifact `Output Summary:`. If coverage regressed, fix coverage gaps and restart from P7-T6.

- [x] [P7-T12] Verify AC1–AC8 by code inspection: read `extensions/drm-copilot/src/claude-worktree-session.ts`, `extensions/drm-copilot/src/extension.ts`, `scripts/dev-tools/new-claude-worktree-session.ps1`, and `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`. Confirm each AC is satisfied at the source level. Write a checklist to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/qa-gates/ac-verification.md` with one line per AC (AC1 through AC11), each marked PASS or FAIL, with a one-line justification.

---

## Preflight Self-Check

The following conditions must all be true before this plan is treated as approved:

1. All phase headings follow the format `### Phase N — <Title>`.
2. All task IDs follow the format `[P#-T#]` with sequential numbering within each phase.
3. Every task specifies an exact file path and an exact command or tool call.
4. Phase 0 includes policy-read tasks for all five required policy files, a policy-read evidence artifact task, and one baseline artifact task per toolchain step for both TypeScript and PowerShell.
5. Baseline artifact tasks include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` fields with numeric coverage values for coverage-bearing languages.
6. Evidence paths resolve to `docs/features/active/2026-04-26-worktree-naming-bug/evidence/<kind>/`. No evidence is written to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or any other non-canonical path.
7. Phase 7 final-QA tasks run the complete toolchain loop for both TypeScript (format → lint → typecheck → test:coverage) and PowerShell (format → analyze → test), with restart-from-step-1 condition if any step changes files or fails.
8. Final-QA artifact tasks include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` with numeric post-change coverage values.
9. No task is a bucket task (all tasks have a single binary outcome and a single verifiable acceptance criterion).
10. AC1–AC11 are all verifiable through the tasks in Phases 1–7.

`PREFLIGHT: ALL CLEAR`
