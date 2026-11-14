# Resolver Dependency Check (Issue #1010, P0-T2)

Timestamp: 2026-10-30T19-49
Command: git fetch origin main; git merge-base --is-ancestor origin/main HEAD; sh SCRATCH/issue-1010-resolver-suite.sh (Invoke-Pester over tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1 and tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1, then direct Resolve-HookTargetWorktree probes with synthetic roots)
EXIT_CODE: 0
Output Summary: Status BLOCKED. The module is present and its suites pass (166/166), but Resolve-HookTargetWorktree has no -Command parameter and its invoker is a scriptblock parameter, not a mockable function; the plan's command leg and test seams cannot be populated as specified.

Status: BLOCKED

Failed condition: "any other field above cannot be populated (including an absent injectable invoker seam)". The required parameter `-Command` does not exist. The invoker seam exists only as the scriptblock parameter `-WorktreeListInvoker`; there is no function that a test can `Mock` in `HookTargetWorktree` module scope.

## Merge Result

- Reconciliation performed by the orchestrator before this run: `origin/main` merged into `bug/preimplementation-gate-item-worktree-1010` as merge commit dc6a5fb28 (parents: the branch head and 0c0027fae, PR #1017 for issue 1009), no conflicts.
- This run: `git fetch origin main` succeeded; `git merge-base --is-ancestor origin/main HEAD` exited 0 (origin/main is 0c0027fae). No new merge was needed.

## Recorded Fields

| Field | Observed value |
|---|---|
| Module present | yes: `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` |
| `Resolve-HookTargetWorktree` exported | yes |
| All exports | `ConvertFrom-HookTargetWorktreePorcelain`, `ConvertTo-HookTargetWorktreeNormalizedPath`, `Get-HookTargetWorktreeEnclosingRoot`, `Get-HookTargetWorktreeKey`, `Get-HookTargetWorktreeRelativePath`, `Resolve-HookTargetWorktree` |
| Parameters | `SessionRoot` (mandatory), `FilePath` (string[]), `CommandOperandPath` (string[]), `CommandBranch` (string), `DelegationPrompt` (string), `CheckpointIssueReader` (scriptblock), `WorktreeListInvoker` (scriptblock) |
| `-FilePath` | present |
| `-Command` | ABSENT. The resolver does not parse command text; the caller must pass already-parsed operand paths (`-CommandOperandPath`) or a branch (`-CommandBranch`). |
| `-SessionRoot` | present |
| Invoker seam (exact name) | `-WorktreeListInvoker`, a `[scriptblock]` parameter `{ param($SessionRoot) <porcelain text> }` whose default runs `git -C $SessionRoot worktree list --porcelain`. No named function wraps it, so `Mock -ModuleName HookTargetWorktree <invoker>` has no target. |
| Output properties | `WorktreeRoot`, `Source`, `Ambiguous` present; also `ReasonCode`, `Detail`, `Candidates` |
| Null-`WorktreeRoot` results (E1) | Ambiguous results (any source); `TARGET_WORKTREE_NOT_DERIVABLE` only for a `-CommandBranch` or delegation identity that names no worktree. For `-FilePath` and `-CommandOperandPath`, an invoker that throws or returns no worktree falls back to the session root (probe `THROW_FILEPATH`: root = session root, Source `SessionRoot`, ReasonCode empty). The spec's E1 statement "A silent session-root substitution on invoker failure is not acceptable" is not met on the path legs. |
| `-FilePath` validation (E3) | none; any string is accepted (`[AllowNull()] [AllowEmptyCollection()] [string[]]`) |
| Empty invoker list | session root, Source `SessionRoot`, Detail `the worktree list returned no registered worktree` |
| Relative path | session root, Source `SessionRoot`, invoker not called |
| No source | session root, Source `SessionRoot` |
| `Source` values | `FilePath`, `CommandOperand`, `DelegationIdentity`, `SessionRoot` |
| Reason-code accessors exported | none. The literals `TARGET_WORKTREE_AMBIGUOUS` and `TARGET_WORKTREE_NOT_DERIVABLE` are restated inside the function and pinned by a test to `Get-WorktreeResolutionAmbiguityReasonCode` / `Get-WorktreeResolutionNoTargetReasonCode` in `WorktreeResolution.psm1`. |
| Resolver suites | `HookTargetWorktree.Tests.ps1` 83 passed / 0 failed; Codex `hook-target-worktree.Tests.ps1` 83 passed / 0 failed; total 166 / 0 |

## Supplementary Observations (for the P0-T3 decision; P0-T3 not executed)

- Codex twin delivered by #1009: `.codex/hooks/hook-target-worktree.ps1`, listed in the Codex `core.json`; same parameters and the same `-WorktreeListInvoker` scriptblock seam; no reason-code accessors; no function-name collision with `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`. Expected P0-T3 value: `E2-BRANCH: CONSUME`.
- `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. Expected P0-T3 value: `CLAUDE-MANIFEST-BRANCH: LISTED`.
- No existing command parser extracts `-C` from `git -c k=v -C <wt>`, from a later command segment, or absolute `git add` operands: the only selector is `Get-OrchestrationEpicScopeSelector` (leading `git -C` in the first segment), which P3-T2 deletes.

## Affected Tasks

- P3-T2, P3-T3: route the `$Command` branch to `Resolve-HookTargetWorktree -Command`; that parameter does not exist. Satisfying T4/T6/C4/C6 (`git -c k=v -C <wt> commit`, later-segment `-C`) and T5/C5 (absolute `git add` operand) requires a new command-operand parser in the gate (or in a shared module) that produces `-CommandOperandPath`. No task describes that parser, its location, or its tests.
- P2-T1, P2-T3, P4-T1, P4-T3, P4-T4: mock "the invoker seam recorded by P0-T2" in `HookTargetWorktree` module scope (or at script scope for the twin) and add it to `$script:EpicStateBaselineModuleSeam`; the seam is a scriptblock parameter with no mockable function, so the gate needs a named wrapper (for example a gate-level worktree-list function passed as `-WorktreeListInvoker`) that no task declares.
- P2-T1 T9, P2-T3 C11, and the Proposed Fix E1 mapping: a null root on the path legs is produced only by ambiguity, so "a resolver result with no root naming TARGET_WORKTREE_NOT_DERIVABLE" is reachable only by mocking `Resolve-HookTargetWorktree` itself; the spec's E1 requirement (no silent session-root substitution on invoker failure) is not met by the delivered resolver and the plan does not extend it.
- P3-T2, P3-T3 reason-code sourcing: no resolver accessor exists, so the `WorktreeResolution.psm1` fallback branch applies on the Claude surface; the Codex surface takes the script-scope-pair deviation branch.
