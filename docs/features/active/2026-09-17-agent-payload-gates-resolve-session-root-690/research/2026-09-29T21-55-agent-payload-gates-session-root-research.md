# Research: agent-payload gates resolve the session root (Issue #690)

- Issue: #690
- Branch: `bug/agent-payload-gates-resolve-session-root-690` at `91805f15`
- Researched: 2026-09-29
- Sources: repository files cited by `path:line`; issue #690 comments read through the GitHub REST API (`/repos/drmoisan/drm-copilot/issues/690/comments`); issues #565, #736, #737 read the same way; live worktree state read directly from disk.

## 1. Settled design and delivered work (verified)

The 2026-09-19 comment on #690 (created 2026-09-19T14:46:57Z) states the design: resolve the target by portable identity through `Resolve-WorktreeItemTarget` (canonical issue number matched against each live worktree's `issue-num`, plus a `--head`/`--branch`/`branch:` signal); never a feature-folder or file path, never the payload `cwd`; deny an unidentifiable target after the scope filter with `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS`; stay fail-closed and keep each gate's decision semantics otherwise. The 2026-09-29 status comment names the remaining sites as `enforce-orchestration-preimplementation-gate.ps1:31,262-265` and `enforce-epic-merge-gate.ps1:63-82`.

Reference pattern, PR #695 (`enforce-model-routing-receipt.ps1`):

- Resolution seam `Resolve-ModelRoutingWorktreeTarget` calls `Resolve-WorktreeItemTarget -Text $PromptText -SessionRoot (Get-Location).Path` (`:140-162`). The session path only finds the repository and labels a result `SessionRoot`; it never selects the target (`WorktreeItemResolution.psm1:343-357`).
- `SessionRoot` and `OtherWorktree` share one branch that composes an absolute path with `Get-WorktreeItemCheckpointPath`; `NoTarget`/`Ambiguous` deny with the accessor-supplied code (`:187-197`).
- The read seam takes a mandatory absolute path with no default (`:56-80`), so no relative fallback survives.
- Resolution sits after the scope filter and before the read (`:231-242`).

Reference pattern, PR #726 (Claude `enforce-completion-consistency.ps1`): an Edit is evaluated against the checkpoint at the Edit's own `file_path` operand (`:369-374`), not a session-relative literal. This is the precedent for placing a path leg by its own absolute operand.

## 2. The 2026-09-29 epic-run failure, explained

Verified state:

- `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-29T14-15-epic-770` holds `artifacts/orchestration/epic-orchestrator-state.json` (`route_id: "epic"`, `integration_branch: "epic/push-down-payload-correctness-integration"`, `epic_issue_num: 770`, lines 3-8) and its HEAD is `ref: refs/heads/epic/push-down-payload-correctness-integration` (read from `.git/worktrees/2026-09-29T14-15-epic-770/HEAD`).
- This worktree (`2026-09-29T13-45`, branch `bug/...-690`) now also holds a byte-similar copy of the same epic checkpoint (same first 30 lines). How it arrived is not known from the tree; it is relevant to the tie-break design in section 4.

Call path of the denial:

1. `/epic-run` is a forked skill (`.claude/skills/epic-run/SKILL.md:5-6`, `context: fork`, `agent: epic-orchestrator`), so `epic-orchestrator` runs in the invoking session's process; its `Agent(orchestrator)` calls fire the `Agent`-matcher hooks with the session root as process directory (`.claude/settings.json:177-205`).
2. The prompt carries `Epic mode: true` (`.claude/skills/epic-orchestrate/SKILL.md:118`), so `Resolve-OrchestrationDelegationMode` returns `epic` (`enforce-orchestration-preimplementation-gate-modes.ps1:45,167-181`).
3. The mode branch reads `Get-EpicCheckpointContent` (`enforce-orchestration-preimplementation-gate.ps1:396-401`), which calls `Test-Path -LiteralPath 'artifacts/orchestration/epic-orchestrator-state.json'` relative to the process location (`enforce-orchestration-preimplementation-gate-epic-scope.ps1:36-46`, path from `-modes.ps1:58`). The file is absent at that session root, so it returns `''`.
4. `ConvertFrom-CheckpointJson ''` fails, `$modeCheckpoint = $null` (`gate.ps1:402-404`), and `Get-EpicOrchestrationReadinessFailure` returns `checkpoint-absent` (`-modes.ps1:387`). The deny text names the relative literal from `Get-OrchestrationDelegationCheckpointPath` (`gate.ps1:301-313`), which is the reported message.

The same `Agent` call is also evaluated by `enforce-epic-wave-barrier.ps1`, which reads the same relative literal (`:38,54-57,272`) and would deny with `EPIC_WAVE_BARRIER_BLOCKED` for the same reason. Fixing only the preimplementation gate therefore does not unblock the epic run.

Why `Resolve-WorktreeItemTarget` cannot be reused unchanged for this call: the epic kickoff line carries `integration_branch: epic/<slug>-integration` and `pass --base <integration_branch>` (`epic-orchestrate/SKILL.md:118`). `Find-WorktreeResolutionBranchSignal` matches only `--head`, `--branch`, or `\bbranch:` (`WorktreeTargetResolution.psm1:61`); `integration_branch:` does not match because `_` and `b` are both word characters, so `\b` does not hold, and `--base` is not in the alternation. The canonical issue-number line is contractually required only for the six receipt-gated agent types (`.claude/skills/orchestrate/SKILL.md:259-261`), and `orchestrator` is not one of them. An epic kickoff therefore resolves `NoTarget` under the item resolver.

## 3. Inventory of session-relative reads of `artifacts/orchestration/*.json` (question 1)

Search scope: `.claude/hooks/*.ps1` and `.claude/lib/**/*.{ps1,psm1}`, patterns `artifacts/orchestration`, `Test-Path`, `Get-Content`, `ReadAllText`, `Get-Location`, `Resolve-Worktree`, and the literal names `epic-child-launches`, `epic-planner-state`, `parallel-planner-state`, `parallel-.*-state.json`.

Scope classes: **item** = one feature's `orchestrator-state.json`; **epic** = `epic-orchestrator-state.json`; **parallel** = `parallel-orchestrator-state.json`; **session** = a document owned by the calling session itself.

| # | Site | Document | Class | Who issues the gated call, and from where | Status |
|---|---|---|---|---|---|
| 1 | `enforce-orchestration-preimplementation-gate.ps1:31,257-266,417-419` (`Get-CheckpointContent`) | orchestrator-state | item | Write/Edit/Bash legs: any session, including a coordinator writing into another worktree (#688 incident, `issue.md:27-39`); single-feature `Agent` delegations | Session-relative. In scope (#690 comment 3). |
| 2 | `enforce-orchestration-preimplementation-gate-epic-scope.ps1:36-46` (`Get-EpicCheckpointContent`), called from `gate.ps1:396-401` | epic | epic | `epic-orchestrator` (forked, session root) `Agent(orchestrator)` epic-mode kickoffs | Session-relative. Cause of the live failure. |
| 3 | `...-epic-scope.ps1:48-58` (`Get-ParallelCheckpointContent`), called from `gate.ps1:396-401` | parallel | parallel | `parallel-orchestrator` (forked, `parallel-orchestrate/SKILL.md:5-6`) parallel-mode kickoffs | Session-relative. |
| 4 | `...-epic-scope.ps1:117` → `EpicScopeResolution.psm1:318-323` (`Resolve-EpicScopeCheckpoint`) | epic | epic | Command/path legs (staging or editing on the integration branch) | Session-root-composed. The same function serves `enforce-model-routing-receipt.ps1:247` and `enforce-pr-author-skill-helpers.ps1:344`. |
| 5 | `enforce-epic-wave-barrier.ps1:38,42-58,272` | epic | epic | Same `Agent(orchestrator)` epic-mode call as row 2 | Session-relative. Must change with row 2. |
| 6 | `enforce-parallel-cohort-barrier.ps1:52,60-76,222` | parallel | parallel | Same `Agent(orchestrator)` parallel-mode call as row 3 | Session-relative. Must change with row 3. |
| 7 | `enforce-epic-merge-gate.ps1:63,67-83,403` (child branch) | orchestrator-state | item | Epic child's own S9 step 6 merge `gh pr merge --merge <PR>` (`orchestrate/SKILL.md:278`), issued inside the child's isolated worktree | Session-relative. In scope (#690 comment 3). |
| 8 | `enforce-epic-merge-gate.ps1:64,85-101,408` (epic branch) | epic | epic | `epic-orchestrator` final integration merge (`epic-orchestrate/SKILL.md:111`), session root | Session-relative. |
| 9 | `enforce-epic-merge-gate.ps1:65,103-119,413` (parallel branch) | parallel | parallel | `parallel-orchestrator` per-item merge, session root | Session-relative. |
| 10 | `enforce-epic-worktree-removal-gate.ps1:70-71,78-112,386,393` | epic, parallel | epic / parallel | Coordinator `git worktree remove <path>` | Session-relative. |
| 11 | `enforce-parallel-worktree-removal-gate.ps1:42,49,55-92,288,313` | parallel, epic | parallel / epic | Coordinator `git worktree remove <path>` | Session-relative. |
| 12 | `enforce-parallel-drift-gate.ps1:71,83-97,310` | parallel | parallel | `Agent(feature-review)` with the parallel marker; that delegation is issued by the child orchestrator inside the child's isolated worktree, while the parallel checkpoint lives at the coordinator root | Session-relative, and the checkpoint is never at that root. Whether the child forwards the marker is not established: neither `.claude/agents/orchestrator.md` nor `.claude/skills/orchestrate/SKILL.md` contains `Parallel mode: true`. |
| 13 | `enforce-pr-author-skill.epic-base-branch.ps1:17-48` | orchestrator-state | item | pr-author | Already fixed by #687: mandatory absolute path from `Get-PrAuthorTargetCheckpointResolution` (`enforce-pr-author-skill-helpers.ps1:74-121,356-363`). Epic branch still goes through row 4. |
| 14 | `enforce-model-routing-receipt.ps1:56-80,161` | orchestrator-state | item | Receipt-gated delegations | Fixed by PR #695. Epic branch `:247` still goes through row 4. |
| 15 | `enforce-prd-feature-before-planner.ps1:155-184,232-254` | orchestrator-state | item | `Agent(atomic-planner)` | Already on `Resolve-WorktreeItemTarget`. |
| 16 | `enforce-powershell-batch-budget.ps1:329,386` | orchestrator-state | session | Budget for the session's own writes; `Root` is the hook script's checkout root, and candidates outside that root are discarded (`:288-289`) | Session by design. Out of scope. |
| 17 | `CleanupWorktreeManifest.psm1:40,86-89` (used by rows 10-11) | cleanup manifest | session | Operator cleanup in the session that wrote the manifest | Session by design. Out of scope. |
| 18 | `validate-orchestrator-output.ps1:32,60-64`, invoked by `.claude/agents/epic-orchestrator.md:29` with a relative `-CheckpointPath` | epic / item | epic / item | SubagentStop, not PreToolUse | Same topology would block epic-orchestrator termination. Out of #690's PreToolUse scope; record as follow-up. |
| 19 | `OrchestratorState.psm1:427` (`Invoke-OrchestratorStatePreflight` default) | orchestrator-state | item | The only in-repo caller passes an explicit path (`enforce-pr-author-skill-helpers.ps1:364`) | Latent default only. |

Not session reads: `enforce-orchestration-preimplementation-gate.ps1:38-46` lists `epic-planner-state.json` and `parallel-planner-state.json` only as a path-exemption membership set; `enforce-orchestration-preimplementation-gate-helpers.ps1:27` is a staging-exemption prefix. `epic-child-launches/**` has no occurrence under `.claude/`; it appears only under `.codex/` and the Codex bundle, which is #736's surface.

## 4. Identity for epic- and parallel-scoped checkpoints (question 2)

### What an epic kickoff actually carries

From `epic-orchestrate/SKILL.md:115-124,185-191` and `.claude/agents/epic-orchestrator.md:90-92,100-107`:

- `Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. PR base branch MUST be <integration_branch> ... pass --base <integration_branch> ...`
- One upstream-context citation line per dependency, the `model_budget.fable_policy:` line, and the child's committed `plan-path` with a resume instruction.
- Spawn parameters (`isolation: "worktree"`, `run_in_background: true`, `model`) are on the call, not in the prompt.
- Not required: the canonical issue-number line, a `branch:` label, the epic issue number.

The parallel kickoff carries `Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path: ... cohort_index: <n>`, the item's `docs/features/active/<basename>` token, the canonical issue-number line, the plan-path, and the model-budget line (`parallel-orchestrate/SKILL.md:239-263`). A parallel run has no integration branch (`.claude/rules/parallel-orchestration.md`, invariant 11).

The epic-mode classifier reads only the prompt field: mode from the marker table (`-modes.ps1:39-47,153-183`), the target record by folder basename then issue number (`:215-275,331-363`), and a prompt-declared `epic_checkpoint_path` used only as a cross-check that must equal the canonical relative path (`:277-308`); a prompt never selects its own readiness file (`:12-16`).

### Candidates evaluated

| Candidate | Finding |
|---|---|
| Epic issue number | Not in the kickoff. Rejected as the key; it is available only inside the checkpoint (`epic_issue_num`). |
| Integration branch in the payload | Present in every epic kickoff (`integration_branch:`) and in integration-PR commands (`--head`). Portable and not a path. Selected as the key. |
| Epic slug (`epic_feature_folder:`) | Present, but it names an epic folder that exists in every checkout branched from the integration branch. Kept only as a cross-check. |
| A worktree whose root holds an epic checkpoint with matching identity | Required, because the coordinating session is forbidden to check out the integration branch (`epic-run/SKILL.md:35-37`) while `EpicScopeResolution.psm1:6-7` places the checkpoint at the coordinating root. A HEAD-only match would miss the canonical case. |
| HEAD-only match on the integration branch | Rejected as the sole rule for the reason above; kept as the tie-breaker, since git checks a branch out in at most one worktree. |
| Session-root-first fast path | Rejected. The copy observed at this worktree's root shows that a stale session-root copy would win silently. |
| Prompt-declared `epic_checkpoint_path` / payload `cwd` | Rejected: self-selection (`-modes.ps1:12-16`) and the settled design. |

### Recommendation

Add one sibling module, `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`. It needs no change to `WorktreeResolution.psm1`, which is at exactly 500 lines. It reuses `Get-WorktreeItemLiveRoot` (exported, `WorktreeItemResolution.psm1:179-214,391`) and `New-WorktreeResolutionTargetResult`, and it returns the same four-state result shape, so gates keep one `switch` over `Status` and both reason-code accessors.

- `Find-WorktreeRunIdentitySignal -Text`: pure. It reads the contract literals `integration_branch: <name>`, `epic_feature_folder: <slug>`, and `parallel_slug: <slug>` from the prompt, case-sensitively, the same way the mode markers are read.
- `Get-WorktreeRunCheckpointText -Path`: the module's only filesystem read, and the seam tests mock.
- `Resolve-WorktreeEpicTarget -IntegrationBranch [-EpicSlug] -SessionRoot`:
  1. An empty branch returns `NoTarget`.
  2. Enumerate the live roots and keep each root whose `epic-orchestrator-state.json` parses to an object with `route_id -ceq 'epic'` and `integration_branch -ceq` the signal.
  3. If a slug is supplied and a match records a different `epic_feature_folder`, return `Ambiguous`.
  4. Zero matches return `NoTarget`, one match resolves, and several matches are narrowed to the roots that have the integration branch checked out (`Get-WorktreeItemLiveRoot -Branch`). One survivor resolves; otherwise return `Ambiguous`, with a detail naming the remedy of moving the stale copy to `artifacts/orchestration/handoff/`.
  5. For the observed state, the result is: two matches (`13-45` and `14-15-epic-770`), narrowed by branch to `14-15-epic-770`, resolving `OtherWorktree`.
- `Resolve-WorktreeParallelTarget -ParallelSlug -SessionRoot`: same shape, keyed on `route_id -ceq 'parallel'` and `parallel_slug`. It has no branch tie-breaker, so more than one match returns `Ambiguous`.
- `Resolve-WorktreeRunTargetByRecord -Kind epic|parallel -RecordField <pr_number|worktree_path> -Value`: for the merge and worktree-removal gates, whose commands carry a PR number or a path rather than an epic identity. It keeps live roots whose run checkpoint records that value (`epic_merge_pr.pr_number` or `features[].pr_number`/`worktree_path`; `items[].pr_number`/`worktree_path`), with the same 0/1/many rule.
- Export the private labelling helper `ConvertTo-WorktreeItemResolvedResult` from `WorktreeItemResolution.psm1` (one `Export-ModuleMember` line; 392 lines now), so `SessionRoot`/`OtherWorktree` labelling has one definition.

Per-gate adoption:

- **Preimplementation gate, epic/parallel delegation leg** (rows 2-3): resolve with the run resolver after the declared-path cross-check, then read the checkpoint beneath the resolved root. `NoTarget`/`Ambiguous` deny with the accessor code, behind the existing `PREIMPLEMENTATION_GATE_BLOCKED:` prefix. Keep `-EpicCheckpointRaw`/`-ParallelCheckpointRaw` precedence (`gate.ps1:399-401`): a bound injection bypasses resolution, so existing rows are unchanged.
- **Preimplementation gate, single-feature legs** (row 1):
  - Agent leg: `Resolve-WorktreeItemTarget` over the prompt.
  - Path leg: place the absolute `file_path` by ascent (`ConvertTo-WorktreeResolutionRepoRelativePath`/`Find-WorktreeResolutionRoot`), following the PR #726 operand precedent. A path under no worktree keeps the session-root read, which is today's strictness; no item owns that path, so no cross-item false approval is possible.
  - Command leg: place the `git -C <dir>` selector already parsed by `Get-OrchestrationEpicScopeSelector` (`-epic-scope.ps1:60-86`); with no selector, use the session root.
  - Keep `-CheckpointRaw` precedence (`gate.ps1:417-419`).
- **Wave barrier and cohort barrier** (rows 5-6): the same run resolution as rows 2-3, applied to the same prompt.
- **Merge gate** (rows 7-9):
  - A bare `gh pr merge --merge` targets the current branch's PR, so the session root is correct by construction; keep it.
  - With an explicit PR number, the epic and parallel branches locate their checkpoint with `Resolve-WorktreeRunTargetByRecord` on `pr_number`. They already bind the number (`:263-274,311-337`), so this removes only the false deny.
  - For the child branch, add a binding: when the per-feature checkpoint records `pr_gate.pr_number`, it must equal the command's number. The residual exposure is recorded in section 8.
- **Removal gates** (rows 10-11): `Resolve-WorktreeRunTargetByRecord` on `worktree_path`, since the command names a path.
- **Row 4** (`Resolve-EpicScopeCheckpoint`): compose the checkpoint path from the run resolver instead of the session root. This is what makes the epic integration PR (`pr-author` and model-routing epic branches) work in the two-worktree topology. It is a separate commit because it changes the #709 guard contract (section 8).
- **Row 12** (drift gate): same resolver keyed on `parallel_slug`. It is not needed for the live failure, and marker forwarding is unverified; recommend a follow-up potential entry.

The design stays fail-closed: every unresolved state denies, and a matched but unparseable checkpoint still yields the existing `checkpoint-absent` or not-epic-scope reason.

Contract text to change with it (Markdown, mirrored):

- `orchestrate/SKILL.md` `## Issue Number Consistency`: extend the identity lines to the four typed-engineer delegations and to any non-mode `Agent(orchestrator)` delegation, because the preimplementation Agent leg will deny `NoTarget` for them.
- `epic-orchestrate/SKILL.md` and `parallel-orchestrate/SKILL.md`: state that the gates key on `integration_branch:` and `parallel_slug:`.

## 5. Main-session calls versus delegated calls (question 3)

Verified runtime facts (probe recorded 2026-09-18; see also `enforce-model-routing-receipt.ps1:11-16`): for main-session calls, the hook process directory and payload `cwd` are the session root; for `isolation: "worktree"` subagents, hooks run inside the subagent's own worktree and load that checkout's (main's) hook scripts.

| Gate leg | Typical issuer | Is the session root the right answer? |
|---|---|---|
| Preimplementation Write/Edit and Bash legs | The session's own edits; an isolated executor's edits inside its own worktree | Yes when the operand is inside the session worktree. Operand placement returns `SessionRoot`, so the plain case is unchanged. No for coordinator writes into another worktree. |
| Preimplementation single-feature Agent leg | The orchestrator delegating executors or typed engineers | Only when identity resolves there. In the plain single-worktree case, a prompt with the canonical line resolves `SessionRoot` (the model-routing gate already requires the line for `atomic-executor`). A typed-engineer prompt without it is the one plain-case behaviour change and must be covered by the contract extension in section 4. |
| Epic/parallel delegation legs, wave barrier, cohort barrier | Forked coordinator at session root | Yes in the canonical topology (checkpoint at the coordinator root), because resolution returns `SessionRoot` there. No in the live topology. |
| Merge gate, bare form | The merging agent inside its own worktree | Yes, by construction. |
| Merge gate, explicit PR / removal gates | Coordinator at session root | Usually yes; identity resolution returns `SessionRoot` in the canonical case. |
| Batch-budget gates, cleanup manifest | The session itself | Yes, by design (rows 16-17). |

## 6. Bundled mirrors and parity enforcement (question 4)

Every `.claude/**` file must exist under `extensions/drm-copilot/resources/claude-customizations/.claude/**` with identical text: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`). Mirrors to change in lockstep, one for each touched `.claude` file:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `-epic-scope.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-parallel-cohort-barrier.ps1`, `enforce-epic-merge-gate.ps1` (and `-authorization.ps1` if glue moves there), `enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`.
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (new), `WorktreeItemResolution.psm1` (export line), and `EpicScopeResolution.psm1` (row-4 commit).
- `.claude/skills/orchestrate/SKILL.md`, `epic-orchestrate/SKILL.md`, `parallel-orchestrate/SKILL.md`.

Additional registration and parity gates:

- `pack-manifests/core.json:183-187` must list the new module, and `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1:27-99` must add it to its three lists. That test's "registers every on-disk module" row fails for an unlisted `.psm1` (`:66-77`). All affected hooks are already in `core.json:29-45`.
- `enforce-orchestration-preimplementation-gate-helpers.ps1` is SHA-256-pinned across four copies, including `.codex/hooks` and the Codex bundle (`enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:14-44`). Do not touch it; that keeps Codex out of scope.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:40-41` scans `.claude/hooks` and `.claude/lib`, so the new module must carry no interpreter invocation.

Codex (#736): no `.codex` hook imports `.claude/lib/worktree-resolution` (Grep over `.codex` finds only `.claude/lib/codex-routing` references). Codex carries its own port (`.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1:1-21`), and its parity tests compare the repo copy against the Codex bundle only (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1:411-444`). A shared helper in `.claude/lib` therefore does not force the Codex copies.

## 7. Tests, fixtures, and the no-temporary-file seam (question 5)

Existing suites per gate (`tests/scripts/claude-hooks/`):

- Preimplementation: `enforce-orchestration-preimplementation-gate{.Tests, .EpicScope, .TriggerScoping, .CommandExemption, .AttributionTrailer, -absolute-paths, -classifier, -mode-resolution, -helpers.ChainEscape, -helpers.Parity}.Tests.ps1`.
- Epic wave barrier: `enforce-epic-wave-barrier.Tests.ps1`.
- Parallel: `enforce-parallel-cohort-barrier{,.Payload}.Tests.ps1`, `enforce-parallel-drift-gate{,-helpers}.Tests.ps1`, `enforce-parallel-worktree-removal-gate{,.EpicAuthorization,.TriggerScoping}.Tests.ps1`.
- Merge and removal: `enforce-epic-merge-gate{,.Authorization,.AuthorizationFields,.TriggerScoping}.Tests.ps1`, `enforce-epic-worktree-removal-gate{,.TriggerScoping}.Tests.ps1`.
- References: `enforce-model-routing-receipt{,.EpicScope,.WorktreeResolution}.Tests.ps1`, `enforce-pr-author-skill{,.TargetResolution,.WorktreeResolution,.EpicScope,.OrchestratorStatePreflight,...}.Tests.ps1`.
- Isolation guard: `enforce-gate-suites.EpicStateIsolation.Tests.ps1`.
- Library: `tests/scripts/claude-lib/worktree-resolution/*.Tests.ps1`.

Pattern established by PR #695 (`enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`):

- Dot-source the hook first, then import the library modules without `-Force` so mocks bind to the hook's module instance (`:37-47`).
- Model liveness by mocking `Get-WorktreeItemLiveRoot -ModuleName WorktreeItemResolution` with a closure (`:81-91`). The real resolver and real reader then run over committed fixture bytes under `tests/fixtures/worktree-resolution/model-routing/<root>/artifacts/orchestration/orchestrator-state.json`.
- Run each row inside `Invoke-WorktreeResolutionFixtureCall -WorkingDirectory <fixture root>`, which sets and restores both the PowerShell location and the .NET current directory (`WorktreeResolutionFixture.Helpers.ps1:45-78`).
- For unresolved-state rows, mock the hook's resolution seam with `New-WorktreeResolutionFixtureTarget` and assert the read seam is invoked `-Times 0` (`:353-366`).

Recommended seams for "checkpoint in a target worktree other than the session root", with no temporary files:

- **Library rows** for `WorktreeRunResolution.psm1`: synthetic `/synthetic-worktrees/<name>` roots (the #709 convention); mock `Get-WorktreeItemLiveRoot` (both unfiltered and `-Branch` forms) and `Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution`, returning in-memory JSON per path. Cover 0, 1, and many matches; the branch tie-break (reproducing the observed 13-45/epic-770 pair); slug disagreement; route_id mismatch; and unparseable, array, or empty text.
- **Gate rows**: add one resolution seam per hook (for example, `Resolve-OrchestrationGateRunTarget`), mocked to return `OtherWorktree` at a committed fixture root, with the existing read seams left real over committed bytes. Alternatively, add committed fixtures under `tests/fixtures/worktree-resolution/epic/<root>/artifacts/orchestration/epic-orchestrator-state.json`, following the model-routing layout. The model-routing fixtures under that `artifacts/` layout exist in the tree, which indicates the ignore rule does not cover them; confirm with `git ls-files tests/fixtures/worktree-resolution` at planning.
- Pester `TestDrive:` writes real files and is excluded by policy.

Existing-row compatibility:

- Preimplementation suites inject `-CheckpointRaw`/`-EpicCheckpointRaw`/`-ParallelCheckpointRaw` (74 occurrences across 8 suites, Grep count); keeping injection precedence over resolution leaves them valid.
- The barrier, merge, and removal suites mock their read seams by name (259 `CheckpointContent` references across 12 suites, Grep count). Those seams must keep their names. Each suite also needs a default `BeforeAll` mock of the new resolution seam returning a `SessionRoot` target. Without it, existing prompts that carry no `integration_branch:`/`parallel_slug:` would resolve `NoTarget` against the developer machine.

These counts describe test churn only; no numeric `spec.md` acceptance criterion is proposed here, so no numeric-derivation section is included.

## 8. File sizes (question 6)

Line counts come from Grep `^` counts, cross-checked against the last line number `Read` showed for the gate and the epic-scope file.

| File | Lines | Headroom | Note |
|---|---|---|---|
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | 500 | 0 | Must not grow. The design does not touch it. |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 | 3 | Do not touch (4-surface parity). |
| `enforce-orchestration-preimplementation-gate.ps1` | 483 | 17 | Would exceed 500 if the resolution glue is inline. Move `Get-CheckpointContent` and the glue into `-epic-scope.ps1`, following the #663 relocation precedent (`gate.ps1:22-24`). |
| `enforce-epic-merge-gate.ps1` | 483 | 17 | Would exceed 500 inline. Put the glue in `enforce-epic-merge-gate-authorization.ps1` (443) or a new dot-sourced sibling. |
| `enforce-orchestration-preimplementation-gate-modes.ps1` | 480 | 20 | Keep the identity parsers in the new module, not here. |
| `enforce-epic-worktree-removal-gate.ps1` | 468 | 32 | Tight; prefer a one-call seam. |
| `enforce-epic-merge-gate-authorization.ps1` | 443 | 57 | |
| `enforce-parallel-worktree-removal-gate.ps1` | 397 | 103 | |
| `enforce-parallel-drift-gate.ps1` | 394 | 106 | Follow-up only. |
| `WorktreeItemResolution.psm1` | 392 | 108 | One export line. |
| `EpicScopeResolution.psm1` | 369 | 131 | Row-4 commit. |
| `enforce-epic-wave-barrier.ps1` | 333 | 167 | |
| `enforce-parallel-cohort-barrier.ps1` | 283 | 217 | |
| `enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 127 | 373 | Receives the relocated glue. |
| `WorktreeRunResolution.psm1` | new | n/a | Estimated at under 300 lines. |

More than three production PowerShell files change, so the work belongs on the orchestrated large path (`.claude/rules/powershell.md`, Change Budget).

## 9. Risks, commit ordering, and related issues (question 7)

Live-hook constraint: the settings commands are relative (`pwsh -NoProfile -File .claude/hooks/...`, `.claude/settings.json:103-205`). The session doing this work therefore runs this worktree's hook copies, and every edit takes effect on the session's next tool call. A gate whose import throws exits non-zero. Per `gate.ps1:436-440`, exit 1 is non-blocking for PreToolUse, which is a fail-open window; a gate that emits a wrong deny is a lockout. Ordering that keeps each commit safe:

1. Add `WorktreeRunResolution.psm1`, its export line, `core.json`, the manifest test, the mirrors, and library tests. No hook imports it yet, so live behaviour is unchanged.
2. Wire the preimplementation gate. Write each hook file in one `Write` rather than a sequence of `Edit`s, so no intermediate state is observed. Commit the gate, its sibling, and the mirror together. Before this commit, confirm that the session's own pending delegations carry the canonical line and `branch:` label. This worktree's `artifacts/orchestration/orchestrator-state.json` (#690) is what the path legs will resolve to, as `SessionRoot`.
3. Wire the wave barrier and cohort barrier (same prompt identity).
4. Wire the merge gate, then the removal gates.
5. Change `Resolve-EpicScopeCheckpoint` (row 4) together with the #709 guard and every suite it lists.
6. Apply the contract text changes to the skills and mirrors. These can land with step 2; they must not land later than it.

Behavioural risks:

- Typed-engineer and direct-mode `Agent` delegations without the identity lines will be denied `NoTarget`. This is the settled policy, and it is the only plain-case change.
- Enumeration cost: the run and item resolvers read one small file per live worktree per epic, parallel, or Agent delegation. Path and command legs use operand ascent, not enumeration.
- Merge-gate child-branch residual: `pr_gate` is required only for routes with `requires_pr_gate: true` (`config/orchestration-routing.json:36,124`; `small` has none). A small-route epic child checkpoint without `pr_gate.pr_number` keeps today's unbound behaviour. Checkpoint hygiene (`parallel-orchestrate/SKILL.md:237`) limits the exposure to a session that holds a stale per-feature checkpoint with `epic_mode: true` and `step9_status: passed`.
- Isolated subagents load main's hooks, so the fix is not exercised by isolated children until it merges.
- SubagentStop `validate-orchestrator-output.ps1` (row 18) remains session-relative. An epic run in the two-worktree topology can still be blocked at epic-orchestrator termination.

Related issues:

- **#565** (open): longest-match folder selection in `enforce-epic-wave-barrier.ps1:99`. It is the same file but a different function (`Find-EpicWaveBarrierFeatureFolderFromPrompt`) from the read seam this change touches. The folder token stays a record key only, never a location selector, which agrees with #565's direction. Expect a textual conflict if both land concurrently; sequence them, or have whichever lands second rebase. The same technique exists in `-modes.ps1:215-251`.
- **#736** (open): Codex completion-consistency copy. Not forced by this design (section 6).
- **#737** (open): hermeticity. `enforce-gate-suites.EpicStateIsolation.Tests.ps1:190-199` guards seven listed suites with a `$null` mock of `Get-EpicScopeCheckpointText` and pins exactly one read (`:416-431`). Any row-4 change that enumerates worktrees breaks `-Times 1 -Exactly`. It also opens a new unmocked read path through `WorktreeRunResolution`, which would read gitignored epic checkpoints on a developer machine; one such copy exists at this worktree's root. The new module's text seam must therefore be added to the guard and mocked `$null` in every suite that reaches it. Because the guard iterates a hard-coded list (#737 D9), new suites must be appended by hand. Coordinate with #737 so the two changes do not edit the guard list concurrently.

Rejected alternatives: item resolver alone for epic mode (resolves `NoTarget`, section 2); HEAD-only epic match (misses the canonical coordinator root); session-root-first fast path (a stale copy wins); prompt-declared checkpoint path or payload `cwd` (self-selection; settled design); a `NoTarget` fallback to the session root when only one live worktree exists (contradicts the settled uniform deny).

## Automation Feasibility

The work is fully automatable. Every change is PowerShell production code, Markdown contract text, JSON manifest membership, and Pester tests. All of it can be verified with the PoshQC MCP toolchain (format, analyze, test) and pytest for the bundle-parity contract, with no human interaction, credentials, or external service. The cross-worktree scenarios are reproducible deterministically through the mock seams and committed fixtures described in section 7, so no live two-worktree topology and no temporary file is needed. The only procedural constraints are the commit ordering in section 9 and one fact: isolated subagents exercise the change only after it merges to main. Neither requires a human decision.
