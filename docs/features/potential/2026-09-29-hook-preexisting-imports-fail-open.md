# hook-preexisting-imports-fail-open (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #690

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
