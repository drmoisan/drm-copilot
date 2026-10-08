# hook-preexisting-imports-fail-open (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #690

- Work Mode: full-bug

## Summary

#690 added a guarded import of `WorktreeRunResolution.psm1` to the gates it converted, so a failed import records the failure and denies. Pre-existing module imports and dot-sources in PreToolUse hooks are not guarded in the same way. Examples include `HookPayload.psm1`, the `-helpers` and `-modes` dot-sources, and `EpicScopeReadiness.psm1`. The hooks #690 did not convert are also unguarded. They include `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1`, which import `EpicScopeResolution.psm1` and therefore `WorktreeRunResolution.psm1` without a guard. When one of these imports fails, the hook exits non-zero, and PreToolUse treats a non-zero exit other than a deny decision as non-blocking, so the gate fails open.

## Scope

- Every PreToolUse hook under `.claude/hooks/` that imports a module or dot-sources a sibling script outside a guard.
- `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1`, which reach `WorktreeRunResolution.psm1` through `EpicScopeResolution.psm1`.
- The bundle mirrors of every changed hook.

## Acceptance Criteria (early draft)

- [ ] Each such hook records a failed import or dot-source and emits a deny decision that names the failed dependency.
- [ ] A test simulates the failure for each hook without renaming, moving, or creating files.
- [ ] Every changed primary file is byte-identical to its bundle mirror.

## Constraints & Risks

- A guard that catches too broadly can hide a real parse error in the hook itself; the guard must cover only the import statement.
- Hooks that dot-source helpers define functions the decision path needs; the deny must be emitted before any of those functions is called.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.

## Bundled Issues

This feature is child C4 of epic #852 (enforcement-hook-precision). The primary issue is #786. The following existing issue is delivered by the same child and is closed by its pull request. No new issue is created.

### #792 — Bug: hook-imported-modules-must-not-write-stdout

A PowerShell module imported by a PreToolUse or SubagentStop hook must not write to the success or warning output streams. Under `pwsh -File`, a `Write-Warning` call inside an imported module prints text ahead of the hook's decision JSON, so the hook's output is no longer a single JSON document, and the harness treats an unparseable result as non-blocking. No repository guard currently prevents a recurrence. Verified on main at ae7c7779 that no `.psm1` under `.claude/lib/` or `.claude/hooks/` calls `Write-Warning`, `Write-Host`, `Write-Output`, or `Write-Information`; the defect is the missing guard.

Acceptance conditions for #792:

- [ ] A repository guard test discovers the hooks and the modules they import (not a fixed list) and fails when an imported module writes to the success stream (`Write-Output`, `Write-Host`, `Write-Information`) or the warning stream (`Write-Warning`).
- [ ] The guard test is proven able to fail: it reports an offender when given a module text that contains such a call, through a test seam rather than a file on disk.
- [ ] Hook entry-point scripts, which legitimately emit their decision through `Write-Output`, remain outside the guard's scope.
- [ ] Diagnostics from imported modules go to the process error stream (`[Console]::Error.WriteLine`), and the guard passes on the integration branch after the upstream children merge.
- [ ] The guard covers the Claude hooks, the Codex hooks, and the bundled mirrors under `extensions/drm-copilot/resources/`, and the bundle-parity tests remain green.

## Upstream Dependencies

This child executes after #732 (C1b), #850 (C3), and #787 (C6) merge into `epic/enforcement-hook-precision-integration`. Each of those children adds or moves hook imports, so the hook dependency list is derived mechanically on the integration branch at execution time, not fixed at planning time.
