# Code Review — Worktree Naming Bug Fix

**Feature:** `2026-04-26-worktree-naming-bug`
**Branch:** `feature/20260426193133-wt-bug`
**Base:** `main`
**Reviewer:** Feature Review Agent
**Review timestamp:** 2026-04-26T00-00

---

## Scope

All files changed between `main` and `feature/20260426193133-wt-bug`:

- `extensions/drm-copilot/src/claude-worktree-session.ts`
- `extensions/drm-copilot/src/extension.ts`
- `scripts/dev-tools/new-claude-worktree-session.ps1`
- `extensions/drm-copilot/resources/templates/new-claude-worktree-session.ps1`
- `extensions/drm-copilot/test/claude-worktree-session.test.ts`
- `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
- `tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1`

---

## 1. `claude-worktree-session.ts` — Pure Helpers

**Overall: PASS**

### Correctness

- `formatWorktreeTimestamp`: Returns `` `${year}-${month}-${day}-${hour}-${minute}` ``. The `second` variable and field have been removed. The format is `yyyy-MM-dd-HH-mm`, 16 characters, matching the spec. The function correctly uses local-time fields (`getFullYear`, `getMonth`, etc.) to stay consistent with the PowerShell `[datetime]::Now` counterpart.
- `buildWorktreePath`: Accepts `(workspaceParent, timestamp, repoName)`. Returns `` `${normalizedParent}/${repoName}-wt-${timestamp}` ``. Backslash normalization and trailing slash stripping are preserved from the prior implementation. No regression.
- `buildBranchName`: Accepts `(timestamp, repoName)`. Returns `` `${repoName}-wt-${timestamp}` ``. The `feature/` prefix and `shortName` are fully removed.

### Design

- All three changed functions remain pure (no I/O, no side effects). The module-level remark that imports from `vscode`, `node:child_process`, and `node:fs` are prohibited is enforced correctly — no such imports are present.
- Separation of concerns is intact: the pure helpers continue to be entirely independent of the VS Code extension host.
- Parameter naming is consistent (`repoName` throughout, matching both TypeScript and PowerShell counterparts).

### API Compatibility

- `buildWorktreePath` and `buildBranchName` signatures changed (`shortName` → `repoName`). All callers in the repository (`extension.ts`) have been updated. No remaining callers with the old signature were found.

### JSDoc

- All three functions have updated `@param` and `@returns` tags consistent with the new signatures and output format. No stale references to `shortName` or `yyyyMMddHHmmss` remain.

### Findings

None. This file is clean.

---

## 2. `extension.ts` — VS Code Command Handler

**Overall: PASS with findings**

### Correctness

- `newClaudeWorktreeSession` handler: The `promptForShortName` call and `shortName` variable have been removed. `repoName` is derived via `path.basename(workspaceRoot)` (line 253). Both `buildWorktreePath` and `buildBranchName` are called with `repoName`. The terminal name uses `branchName` (`Claude: ${branchName}`), which now takes the form `Claude: <repoName>-wt-<timestamp>` — verified by the test assertion on line 386: `/^Claude: workspace-wt-/`.
- `promptForShortName` remains imported because other command handlers (`newPotentialBugEntry`, `newPotentialEntry`) still use it. The import is not dead code.
- Early-return guard on `objective === undefined` is preserved correctly. The objective prompt is the only `showInputBox` call remaining for this command, confirmed by the test assertion `expect(showInputBoxMock).toHaveBeenCalledTimes(1)` at line 376.

### Design

- The `pyprojectHasPoetry` helper is well-factored: it reads `pyproject.toml` from the workspace root and tests for the literal substring `"poetry"`. The helper correctly handles the case where the file does not exist (returns `false`). The approach is consistent with the module's I/O boundary pattern (filesystem access isolated from pure logic).
- `TERMINAL_AUTO_ACTIVATION_GRACE_MS = 5000` is a named constant with a clear JSDoc explaining the motivating concern (VS Code Python extension auto-activation). This is appropriate.
- `detectRuntime` is re-exported for backward compatibility with existing test imports (`export { detectRuntime }`). This is a valid compatibility shim.

### File Size

**Finding (non-blocking, flagged in policy audit):** `extension.ts` is 673 lines on this branch, up from 538 lines on `main`. The 500-line policy limit was already exceeded on `main`; this branch worsens the situation by 135 lines. The additional lines come from the `pyprojectHasPoetry` helper (~15 lines), `TERMINAL_AUTO_ACTIVATION_GRACE_MS` constant and JSDoc (~15 lines), the `newClaudeWorktreeSession` handler expansion (~85 lines), and refactored imports (~20 lines). Splitting `extension.ts` into per-command registration modules would resolve this violation but is outside the scope of this bug fix. The pre-existing violation should be addressed in a dedicated refactor.

### Findings

- **F1 (informational):** `extension.ts` exceeds the 500-line file size limit (673 lines). Pre-existing condition worsened on this branch. Remediation is recommended but is out of scope for this bug fix.

---

## 3. `new-claude-worktree-session.ps1` (standalone and template)

**Overall: PASS**

Both scripts are identical in content. The review observations apply equally to both.

### Correctness

- `Get-WorktreeTimestamp`: `.ToString('yyyy-MM-dd-HH-mm')` produces the correct format. Seconds are gone.
- `Build-WorktreePath`: Parameter name changed from `$ShortName` to `$RepoName`. Return value is `"$WorktreeParentPath/$RepoName-wt-$Timestamp"`. This matches the spec.
- `Build-BranchName`: Parameter name changed from `$ShortName` to `$RepoName`. Default return is `"$RepoName-wt-$Timestamp"`. Custom `$BranchName` passthrough is preserved.
- Script body: `$repoName = Split-Path -Leaf $repoRoot` is correctly placed after `$repoRoot` is resolved via `git rev-parse --show-toplevel`. The `$repoRoot` assignment is unconditional (occurs before the `if (-not $WorktreeParentPath)` block), so `$repoName` is available regardless of whether `$WorktreeParentPath` was supplied.
- No `$ShortName` references remain anywhere in either script.

### Design

- The script follows the established DI pattern: injectable `$GetDateTime`, `$GetCommand`, `$TestPath`, `$InvokeGit`, and `$InvokeStartProcess` parameters with safe defaults. No new seams were needed for this change.
- `CmdletBinding(SupportsShouldProcess)` and `[Parameter(Mandatory = $true)]` attributes are correctly applied throughout.
- `$ErrorActionPreference = 'Stop'` ensures fail-fast behavior.
- The Windows `cmd.exe` workaround for `.cmd` shim resolution (the `$isWindowsHost` branch in `Start-ClaudeBackground`) is unmodified and correctly preserved.
- The `.SYNOPSIS`, `.DESCRIPTION`, and `.PARAMETER` doc blocks accurately reflect the new API — no stale references to `ShortName`.

### Findings

None. Both scripts are clean.

---

## 4. `claude-worktree-session.test.ts`

**Overall: PASS**

### Test Quality

- All tests follow Arrange-Act-Assert structure with inline comments.
- `formatWorktreeTimestamp` tests: two cases covering a representative timestamp (`"2026-04-20-09-59"`, 16 chars) and zero-padded fields (`"2026-01-01-00-00"`). Both cases assert the value and, in the second case, the length. Coverage of the function is 100%.
- `buildWorktreePath` tests: three cases covering a forward-slash path, Windows backslash normalization, and trailing slash stripping. All expected values use the new format.
- `buildBranchName` test: one case confirming the `<repoName>-wt-<timestamp>` format with no `feature/` prefix.
- `buildWorktreeSessionCommands` tests: comprehensive coverage of poetry/no-poetry paths, objective presence/absence, empty objective, apostrophe escaping, and paths with spaces. Fixtures use `worktreePath: "/parent/auth-wt-2026-04-20-09-59"` and `branchName: "auth-wt-2026-04-20-09-59"`.

### Test Isolation

- Tests import only from `../src/claude-worktree-session`. No VS Code host required. No external I/O. Tests are fully deterministic.

### Findings

None.

---

## 5. `extension.workflow-commands.test.ts`

**Overall: PASS with findings**

### Test Quality

- The `newClaudeWorktreeSession` handler tests cover: no-poetry path (git + Set-Location only), poetry path (git + Set-Location + poetry install + activate), non-poetry pyproject, blank objective, grace-period deferral, cancelled objective (early return), and missing PowerShell runtime error.
- The test at line 376 asserts `showInputBoxMock.toHaveBeenCalledTimes(1)`, confirming the ShortName prompt has been removed.
- Terminal name regex `/^Claude: workspace-wt-/` at line 386 correctly validates the new naming scheme using the workspace fixture name (`workspace`).
- Git command regex `/-b 'workspace-wt-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}'$/` at line 413 correctly validates the timestamp format `yyyy-MM-dd-HH-mm`.
- Set-Location regex `/^Set-Location 'C:\/workspace-wt-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}'$/` at line 415 is consistent.

### File Size

**Finding (non-blocking, flagged in policy audit):** `extension.workflow-commands.test.ts` is 722 lines on this branch, up from 399 lines on `main`. The branch adds approximately 323 lines of new test content covering the `newClaudeWorktreeSession` handler scenarios. The 500-line policy limit is exceeded. This is a new violation introduced on this branch. Splitting this file into per-command test files would resolve the violation.

### Findings

- **F2 (informational):** `extension.workflow-commands.test.ts` exceeds the 500-line file size limit (722 lines). New violation introduced on this branch as a result of adding comprehensive `newClaudeWorktreeSession` handler coverage. Remediation is recommended.

---

## 6. `new-claude-worktree-session.Tests.ps1`

**Overall: PASS**

### Test Quality

- `Get-WorktreeTimestamp` tests: two cases covering non-null output and the specific `"2026-04-20-09-59"` format with an injected fixed datetime. Clear and sufficient.
- `Build-WorktreePath` tests: three cases — segment match (`"auth-wt-"`), tail match (`"-2026-04-20-09-59$"`), and full-path equality (`"/parent/auth-wt-2026-04-20-09-59"`). Provides good coverage of the construction logic.
- `Build-BranchName` tests: two cases covering the default derivation and the custom passthrough. Both use `-RepoName "auth"` (not `$ShortName`).
- `Test-PreconditionsMet`, `Start-ClaudeBackground`, `Write-LaunchResult`, and Integration Validation tests are present and unmodified in structure; they correctly use the injectable seam pattern.

### Mock Usage

- The `Import-ScriptFunction` helper is used consistently to dot-source individual functions for isolation testing. Mocks are injected via scriptblock parameters, following the established DI pattern.

### Findings

None.

---

## Summary of Findings

| ID | Severity | File | Finding |
|----|----------|------|---------|
| F1 | Informational | `extension.ts` | 673 lines — exceeds 500-line limit. Pre-existing condition worsened on branch. |
| F2 | Informational | `extension.workflow-commands.test.ts` | 722 lines — exceeds 500-line limit. New violation introduced on this branch. |

No correctness, security, design, or naming violations were found in any changed file. The two file-size findings are policy violations but do not affect runtime correctness. Both should be addressed in a follow-up refactor.
