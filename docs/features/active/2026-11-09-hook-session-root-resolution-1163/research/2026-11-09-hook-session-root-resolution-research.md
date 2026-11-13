# Research: Agent-isolated worktrees and session-root resolution in hooks (Issue #1163)

- Issue: #1163
- Branch: bug/hook-session-root-resolution-1163
- Work mode: full-bug
- Feature folder: docs/features/active/2026-11-09-hook-session-root-resolution-1163
- Requirements source: `issue.md` in the feature folder (Problem, Proposed Behavior, Acceptance Criteria, General Constraints)
- Research mode: preparation; read-only analysis. No source, test, or configuration file was changed.

## Filename Note

The delegation named `hook-session-root-resolution-research.md`. That name does not satisfy `Test-IsValidResearchFileName` in `.claude/hooks/validate-task-researcher-output.ps1`, which requires `<timestamp>-<short-name>-research.md` (or `research.<timestamp>.md`), so the SubagentStop hook would block the stop. The artifact is therefore written as `2026-11-09-hook-session-root-resolution-research.md` in the same `research/` folder. The orchestrator should record this path as the research path.

## Summary of Findings

1. Two resolver families exist. Family A is `Resolve-HookTargetWorktree` (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, Codex twin `.codex/hooks/hook-target-worktree.ps1`): pure, porcelain-based, injectable `WorktreeListInvoker`. Family B is the filesystem-ascent family in the same folder (`WorktreeResolution.psm1`, `WorktreeTargetResolution.psm1`, `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1`, `EpicScopeResolution.psm1`), which enumerates the `.git/worktrees` administrative layout and keeps only roots that still carry a worktree marker (`Get-WorktreeItemLiveRoot`). Most gates already resolve by portable identity through one of the two.
2. The remaining session-root-bound readers are: `enforce-completion-consistency.ps1` (Claude and Codex; the feature-folder existence check runs relative to the hook process directory), `enforce-file-size-limit.ps1` (Claude and Codex; relative-path computation against the hook process directory, so an absolute path in another worktree is silently uncovered), `validate-docs-role-output.ps1` (probes repository-relative paths at the hook process directory), and `enforce-docs-complete-gate.ps1` (reads the validation receipt beneath the root that holds the hook script). The six migrated SubagentStop artifact hooks still probe the session root when a present delegation identity is not derivable or is ambiguous.
3. `Resolve-HookTargetWorktree` does not exclude `prunable` worktree records when it matches a branch, although `ConvertFrom-HookTargetWorktreePorcelain` parses the flag. After a worktree is restored at a different host path, the stale registration still matches the branch and resolves to a directory that no longer exists; when the new location is also registered, the branch matches twice and resolves `TARGET_WORKTREE_AMBIGUOUS`.
4. No hook writes, restores, or normalizes a tracked file or a checkpoint. The "validators revert in-place fixes" behavior is a read-only false-negative path that leads the agent to undo its own change (detailed under Question 2).
5. Recommended design: a new pure module `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` (Codex twin `.codex/hooks/agent-target-worktree.ps1`) that composes `Resolve-HookTargetWorktree` without modifying it, adds a prunable-record filter and an agent-working-directory source, and is adopted by minimal call-site edits.

## Sources Read

- `CLAUDE.md`; `.claude/skills/execution-environment/SKILL.md` (`## Hook Execution Context`, `## Batch Budget`, `## Contract Tests That Pin Mirrored Files`); `.claude/rules/powershell.md`; `.claude/rules/general-code-change.md`; `.claude/rules/general-unit-test.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Feature folder: `issue.md`, `spec.md` (template, unfilled), `plan.2026-11-09T16-33.md` (template, unfilled).
- Every `.ps1` under `.claude/hooks/` and `.codex/hooks/` was enumerated; files that read a checkpoint, artifact, receipt, or root were read in the relevant functions (cited by symbol below).
- Libraries: all eight modules under `.claude/lib/worktree-resolution/`; `.claude/lib/file-size-policy/FileSizePolicy.psm1`; `.claude/lib/docs/DocsCompleteGate.psm1`; `.claude/lib/orchestrator-state/OrchestratorState.psm1` (file probes only).
- Registration: `.claude/settings.json` (`PreToolUse`, `SubagentStop`).
- Tests: `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1`, `HookTargetWorktree.Rows.Helpers.ps1`, `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`, and the `*.TargetWorktree.Tests.ps1` family under `tests/scripts/claude-hooks/`.
- External: the Claude Code hooks reference (`code.claude.com/docs/en/hooks`), common input fields and the worktree note.
- Memory notes consulted: hook execution context for isolated subagents (probed 2026-09-18) and the rule against encoding absolute paths in artifacts.

## Question 1: Inventory of Root-Reading Hooks

Classification key: **correct** = resolves the target by portable identity or by the operand path itself; **partial** = resolves the target but falls back to the session root in a case that names another item, or ignores stale registrations; **session-root-bound** = reads a target-owned file beneath the hook process directory or the root that holds the hook script (defect); **by design** = the session root is the intended target; **n/a** = path-shape logic only, no root read.

### Claude PreToolUse hooks

| Hook (and helpers) | What it reads | Root resolution today | Class |
|---|---|---|---|
| `enforce-powershell-batch-budget.ps1`, `enforce-python-batch-budget.ps1` (+ `enforce-batch-budget-route.ps1`) | `artifacts/orchestration/orchestrator-state.json` of the edited file's worktree | `Resolve-HookTargetWorktree -FilePath`; `Test-BatchBudgetLargePathRoute` | correct (prunable records not filtered; immaterial for a FilePath source) |
| `enforce-orchestration-preimplementation-gate.ps1` (+ `-epic-scope`, `-targets`, `-modes`, `-helpers`, `-cleanup`) | item, epic, parallel checkpoints | `Read-OrchestrationGateCheckpoint` → `Resolve-OrchestrationGateTarget`; path and command legs through `Resolve-HookTargetWorktree` (#1010); delegation legs by portable identity | correct; sibling #1160 owns this file set |
| `enforce-pr-author-skill.ps1` (+ `.artifact-root`, `.current-branch`, `-helpers`) | PR context, body, receipt, checkpoint | `Resolve-PrAuthorArtifactRoot` → `Resolve-EpicScopeCheckpoint` / `Resolve-WorktreeItemTarget` (#850, #1011) | correct |
| `enforce-epic-merge-gate.ps1` (+ `-resolution`, `-review`, `-child-ci`, `-green-ci`, `-authorization`, `-command`) | item, epic, parallel checkpoints | `Resolve-EpicMergeGateItemTarget` (`Resolve-WorktreeItemTargetByPrNumber`), `Resolve-EpicMergeGateRunTarget` (`Resolve-WorktreeRunTargetByRecord -RecordField pr_number`); a bare merge with no number uses `Get-EpicMergeGateSessionWorktreeRoot`, matching the directory `gh` reads | correct |
| `enforce-epic-merge-gate-green-ci.ps1` | parallel checkpoint record for a worktree | `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path -Value <live root>` | correct for root; record comparison is host-bound (Question 3) |
| `enforce-epic-worktree-removal-gate.ps1` (+ `-resolution`), `enforce-parallel-worktree-removal-gate.ps1` | epic / parallel checkpoint `worktree_path` records | `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path`; `Get-WorktreeRunMainCheckoutRoot`; `Test-WorktreeRunRecordedPathMatchesTarget` | correct for root; record comparison is host-bound (Question 3); sibling #1161 likely touches this |
| `enforce-epic-wave-barrier.ps1` | epic checkpoint | `Resolve-WorktreeEpicTarget` by integration-branch / epic-slug signal | correct |
| `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1` | parallel checkpoint | `Resolve-WorktreeParallelTarget` by parallel-slug signal | correct |
| `enforce-model-routing-receipt.ps1` | item / epic checkpoint `model_routing_receipts` | `Resolve-WorktreeItemTarget`, `Resolve-EpicScopeCheckpoint` | correct |
| `enforce-prd-feature-before-planner.ps1` | item checkpoint, feature-folder `issue.md` | `Resolve-PrdFeatureWorktreeTarget` → `Resolve-WorktreeItemTarget` | correct |
| `enforce-completion-consistency.ps1` (+ `enforce-completion-helpers.ps1`) | written or edited checkpoint content; existence of its `feature-folder` | Edit path reads the `file_path` as given (correct); `Test-IsValidFeatureFolder` calls `FolderExistsCheck` (`Test-Path -LiteralPath docs/features/active/<x>`), which resolves against the hook process directory | **session-root-bound** for a checkpoint written by absolute path into another worktree |
| `enforce-checkpoint-monotonic.ps1` | write content only | none (content check) | n/a |
| `enforce-file-size-limit.ps1` (+ `FileSizePolicy.psm1`) | pre-edit file text | `RepositoryRoot = (Get-Location).ProviderPath`; `ConvertTo-FileSizeRelativePath` makes an absolute path relative to that root; `Test-FileSizeCoveredPath` excludes `.claude/worktrees/` | **session-root-bound**: an absolute path into an agent worktree under `.claude/worktrees/` becomes uncovered, and a path in a sibling worktree outside the root returns `$null` (uncovered); both are silently allowed |
| `enforce-docs-complete-gate.ps1` (+ `-target`) | docs profile and validation receipt | `Get-DocsCompleteGateRepositoryRoot` (two levels above `$PSScriptRoot`) | **session-root-bound** for a merge whose PR head branch is checked out in another worktree (documented as ambient state in the hook header) |
| `enforce-docs-role-write-scope.ps1` | docs profile; write target containment | `Get-DocsWriteScopeRepositoryRoot` = payload `cwd`, else current location | correct for the agent's own calls (payload `cwd` is the agent's directory); recorded here because it is the only Claude hook that already uses the agent working directory |
| `enforce-feature-folder-order.ps1` | sibling `issue.md`/`spec.md` of a plan path | derived from the plan path operand | correct |
| `enforce-evidence-locations.ps1`, `check-*-test-purity.ps1`, `enforce-mermaid-validation.ps1`, `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-parallel-abandon-gate.ps1`, `enforce-worktree-poetry-venv.ps1` | path or command shape | none / operand | n/a |
| `hook-cleanup-context.ps1` (cleanup legs) | `artifacts/orchestration/cleanup-worktrees-manifest.json` | session root | by design (#1026) |
| `enforce-discovery-artifact-gate.ps1`, `enforce-discovery-planning-gate.ps1`, `record-discovery-agent-start.ps1` | discovery authority records | discovery root-grant model (`.claude/lib/discovery-validation/`); no `Get-Location` or `cwd` reference found | not evaluated further; outside the checkpoint/output family |
| `persist-session-id.ps1` | writes session id under `.claude/state/` | session root | by design |

### Claude SubagentStop hooks

| Hook | Artifact | Resolution today | Class |
|---|---|---|---|
| `validate-task-researcher-output.ps1`, `validate-prd-feature-output.ps1`, `validate-required-artifact-output.ps1`, `validate-planner-output.ps1`, `validate-executor-output.ps1`, `validate-human-exception-runbook-output.ps1` | advertised research, spec, plan, preflight-fix record, runbook | `Resolve-SubagentStopTargetWorktree` + `Resolve-SubagentStopArtifactLocation`. A `TARGET_WORKTREE_NOT_DERIVABLE` or `TARGET_WORKTREE_AMBIGUOUS` result carries a `$null` root, so `Test-SubagentStopSessionRoot` treats it as the session root and the hook probes the session-root copy, appending the note from `Get-SubagentStopTargetNote` | **partial**: a present identity that names another item still reads the coordinator's copy |
| `validate-feature-review-coverage.ps1` (+ `-freshness`, `-metrics`, `-rules`) | PR context, `CLAUDE.md`, coverage reports | `Resolve-SubagentStopTargetWorktree`; blocks on not-derivable or ambiguous (#1105) | correct (prunable records not filtered) |
| `validate-orchestrator-output.ps1` (+ `-target`, `-resolution`, `-routing`, `-rejection`, `-feature-folder`) | `orchestrator-state`, runbook, feature folder | item kind: `Resolve-OrchestratorOutputItemTarget` (#1145) blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` on an unresolved identity and validates the session worktree with `ORCHESTRATOR_CHECKPOINT_FALLBACK:` when no identity exists; epic and parallel kinds: `Resolve-OrchestratorOutputCheckpointPath` by `integration_branch:` / `parallel_slug:` literal or by single discovered value | correct; the epic and parallel kinds are the "unchanged" checkpoints the brief names |
| `validate-docs-role-output.ps1` (+ `docs-role-contract.ps1`) | `docs-profile`, `docs-snapshot`, `docs-pages-written` paths | `Test-DocsRoleOutputFile` (`Test-Path` of a repository-relative path, so the hook process directory) | **session-root-bound** for a non-isolated documentation role working in an item worktree |
| `validate-pr-author-output.ps1` | assistant text only | none | n/a |
| `validate-discovery-artifact-gate.ps1` | discovery records | discovery model | not evaluated further |

### Codex hooks

| Hook | Resolution today | Class |
|---|---|---|
| `enforce-powershell-batch-budget.ps1`, `enforce-python-batch-budget.ps1` | `Resolve-HookTargetWorktree` via `hook-target-worktree.ps1` | correct |
| `enforce-orchestration-preimplementation-gate*.ps1` (incl. `-epic-resolution`, `-epic-scope`) | twin of the Claude gate | correct; #1160 territory |
| `validate-feature-review-coverage.ps1` (+ `feature-review-coverage-target.ps1`, `-freshness`) | audit path from `last_assistant_message`, `Resolve-HookTargetWorktree` (#1114) | correct |
| `enforce-completion-consistency.ps1` (+ `enforce-completion-helpers.ps1`) | same `FolderExistsCheck` default as Claude | **session-root-bound** |
| `enforce-file-size-limit.ps1` (+ `file-size-policy.ps1`) | `RepositoryRoot = (Get-Location).ProviderPath` | **session-root-bound** |
| `enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-epic-planning-only.ps1`, `record-subagent-routing-attestation.ps1`, `enforce-codex-model-routing.ps1`, `validate-codex-subagent-routing.ps1`, `codex-epic-child-launch-attestation.ps1` | repository root two levels above `$PSScriptRoot` | by design on Codex: `enforce-epic-child-worktree-binding.ps1` requires payload `cwd`, the hook repository root, and the expected worktree to be identical for a child, so the hook root is the child's worktree. Not adopted in this item. |
| `enforce-checkpoint-monotonic.ps1`, `enforce-evidence-locations.ps1`, `validate-bash.ps1` and similar | shape only | n/a |

### The "unchanged" gates named in the brief

The `## Hook Execution Context` sentence "The other gates that read `artifacts/orchestration/orchestrator-state.json` are unchanged and still use the root that holds the hook script" refers, on the Claude surface, to the gates in the table above that read a checkpoint-related path without a resolver: `enforce-completion-consistency.ps1` (its feature-folder existence probe) and `enforce-checkpoint-monotonic.ps1` (content only, no root read). Every other Claude checkpoint reader resolves by identity through Family A or Family B. On the Codex surface the sentence covers the `$PSScriptRoot`-rooted hooks listed above, which are root-bound by design under the child worktree binding. The sentence is therefore inaccurate for the Claude merge, removal, barrier, drift, and model-routing gates (they resolve by identity) and should be rewritten when the brief is updated.

## Question 2: Mechanism Behind "Validators Revert In-Place Fixes"

- Writer search. Scope: `.claude/hooks/`, `.codex/hooks/`, `.claude/lib/`, and `scripts/dev_tools/*orchestrat*` plus `scripts/dev_tools/validate*.py`. Patterns: `Set-Content`, `Out-File`, `WriteAllText`, `WriteAllLines`, `Copy-Item`, `Move-Item`, `Remove-Item`, `New-Item`, `IO.File]::`, `FileStream`, `git ... checkout|restore|reset|stash`, `write_text`, `json.dump`, `writeFileSync`, `--fix`, `--repair`. Result: the only writers are the batch-budget state files under the session root's `.claude/state/` (Claude) and `.codex/state/` (Codex), `persist-session-id.ps1`, the Codex attestation and authority writers (`record-subagent-routing-attestation.ps1`, `authorize-root-epic-invocation.ps1`), and the discovery start records in `.claude/lib/discovery-validation/`. None writes a tracked file, a checkpoint, a plan, or evidence, and none runs `git checkout`, `restore`, or `reset`. No hook or validator rewrites a child's file.
- The revert is agent behavior driven by a false block. Three verified paths produce it:
  1. **Completion write denied by a session-root existence probe.** A coordinator that writes or edits the item checkpoint by absolute path (`<item root>/artifacts/orchestration/orchestrator-state.json`) to assert completion is evaluated by `Get-MissingCompletionEvidence`, which calls `Test-IsValidFeatureFolder` with the default `FolderExistsCheck`. The relative `docs/features/active/<folder>` is tested beneath the hook process directory (the coordinator root), where a new, uncommitted feature folder does not exist. The deny names `feature-folder value ... is not a valid feature folder`, and the remedy text offers "remove the completion assertion", which the agent applies to its own correct checkpoint.
  2. **SubagentStop probe of the coordinator copy.** When the delegation prompt carries an identity that does not resolve (stale `prunable` registration after a host move, or a branch checked out twice), `Resolve-SubagentStopArtifactLocation` receives a `$null` root and probes the session-root path. The child's fixed artifact lives in its worktree; the hook reports "no file exists" or validates the coordinator's older copy and blocks repairably. The child then edits, re-creates, or reverts the artifact to satisfy the copy that was actually read.
  3. **Orchestrator stop with no identity.** `validate-orchestrator-output.ps1` validates the session worktree's checkpoint when the prompt carries no `branch:` or canonical issue line (`ORCHESTRATOR_CHECKPOINT_FALLBACK:`). A child orchestrator in a different worktree that repaired its own checkpoint is blocked on the coordinator's checkpoint. This path is already annotated by #1145 and becomes reachable only when a delegation omits identity lines.
- Regression scope: path 1 is fixed by rooting the existence probe at the worktree that holds the written checkpoint; path 2 by the prunable filter plus fail-closed handling of an unresolved identity; path 3 stays as designed (fallback with note), because the session root is the agent's own worktree for an isolated child and identity lines are mandatory for coordinator delegations.

## Question 3: Host-Path Portability

- Portable identity already in use: the `branch:` label (git checks a branch out in at most one worktree), the canonical issue line matched against each live checkpoint's `issue-num`, the epic `integration_branch` / `parallel_slug` signals, and repository-relative `feature-folder` values. `Resolve-HookTargetWorktree` and Family B read registered worktrees at run time and persist no path.
- Host-bound comparisons found:
  - `Test-WorktreeRunRecordedPathMatchesTarget` (`WorktreeRunRecordPath.psm1`) compares a recorded absolute `worktree_path` with the live removal target. After a move, an absolute record never matches; the removal gates deny and the green-CI item lookup (`Resolve-WorktreeRunTargetByRecord -RecordField worktree_path`) resolves `NoTarget`. Both fail closed. A relative record is portable. The epic skill records `worktree_path` and `branch_name` together, so `branch_name` is the portable alternative.
  - `Resolve-OrchestratorOutputRunbookPath` returns a rooted `runbook_path` unchanged, so a rooted runbook path from another host is probed and reported missing.
  - `Get-HookTargetWorktreeKey` hashes the absolute root, so batch-budget state is not portable; the state is per session, so this has no cross-host effect.
- Registration after a move: Family B reads each `.git/worktrees/<name>/gitdir`, which still points to the old path until `git worktree repair` runs; the marker test then excludes it, so identity resolution returns `NoTarget` (fail closed). Family A lists the old registration with `prunable` and, because branch matching ignores that flag, resolves the branch to the missing directory. If the worktree was re-added at the new path with `git worktree add -f`, the branch matches two records and resolves `TARGET_WORKTREE_AMBIGUOUS`. This is the verified mechanism for "agents could not locate their own worktree's checkpoint after a session moved between hosts".
- Recommendation: exclude `prunable` records before branch, issue, and enclosing-root matching, and when the only record for a branch is prunable, return `TARGET_WORKTREE_NOT_DERIVABLE` with a detail that names `git worktree repair`. Do not persist any absolute path; the portable handoff intake in `.claude/skills/orchestrate/SKILL.md` (`## Prepared-State Portable Handoff Intake`) already derives `expected_workspace_root` from the destination checkout, never from the envelope. The absolute `worktree_path` record comparison in the removal gates is left unchanged in this item (decision D9).

## Question 4: Agent Working-Directory Input

- Claude common hook input (hooks reference): `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`, `prompt_id`, `scratchpad_dir`, `effort`; tool events fired inside a subagent also carry `agent_id` and `agent_type`. `cwd` is "the worktree root after Claude enters a worktree, and the new directory after Claude runs `cd`". `CLAUDE_PROJECT_DIR` stays at the original project root in a worktree session. SubagentStop fields read by this repository: `last_assistant_message`, `stop_hook_active`, `agent_type` (`subagentstop-envelope.ps1`), and `agent_transcript_path` (`Get-TranscriptPathFromEnvelope`). The memory probe of 2026-09-18 observed no agent-identity field in PreToolUse payloads; the current reference documents `agent_id`/`agent_type`, so that observation is likely out of date (unverified in this session).
- Codex: payloads carry `cwd`; `enforce-epic-child-worktree-binding.ps1` requires it to equal the hook repository root and the expected child worktree.
- Reliability: for an isolated subagent, hooks run inside its worktree with that worktree's (main's) scripts, so the hook process directory and payload `cwd` are both the agent's worktree. For a coordinator-issued or non-isolated call, payload `cwd` is the coordinator's directory and does not identify the item. `cwd` is therefore reliable only as "the agent's own directory", never as an item selector for coordinator calls. Agent threads also have their working directory reset between Bash calls, so `cwd` does not follow a `cd` inside a compound command.
- `Resolve-HookTargetWorktree` has no working-directory input; its fallback is `SessionRoot`, which callers pass as `(Get-Location).Path`. `enforce-docs-role-write-scope.ps1` is the only Claude hook that reads payload `cwd`. Whether a transcript's JSONL entries carry a per-entry `cwd` was not verified (the researcher cannot read transcripts safely); the design does not depend on it.
- Consequence for design: the agent working directory is a fallback source placed after delegation identity and before the session root. Mapped to its enclosing non-prunable registered worktree, it equals the session root in every observed case, so it changes no decision there, and it decides correctly in a case where the hook process directory and payload `cwd` differ.

## Question 5: Design Options and Recommendation

### Candidate A (recommended): new pure module composing the existing resolver

`.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`, Codex twin `.codex/hooks/agent-target-worktree.ps1` with byte-identical function text.

- `ConvertTo-AgentTargetLiveWorktreeListText` (pure): parses porcelain with `ConvertFrom-HookTargetWorktreePorcelain`, drops `Prunable` records, and re-renders porcelain text; also returns the dropped records so a not-derivable detail can name them.
- `Resolve-AgentTargetWorktree` (pure; seams: `WorktreeListInvoker`, `CheckpointIssueReader`): parameters `SessionRoot`, `FilePath`, `CommandOperandPath`, `CommandBranch`, `DelegationPrompt`, `AgentWorkingDirectory`, `Policy` (`SessionFallback` or `FailClosedOnIdentity`). Precedence: absolute FilePath → command operand/branch → delegation identity (`branch:` label, cross-checked with the canonical issue line) → canonical issue line alone (through `CheckpointIssueReader`) → agent working directory (enclosing non-prunable registered worktree) → session root. It calls `Resolve-HookTargetWorktree` with a wrapped invoker that returns the filtered porcelain, so prunable filtering applies without editing `HookTargetWorktree.psm1`. Result adds `Source = 'AgentWorkingDirectory'`, `Unresolved` (bool), and `StaleRegistration` (dropped prunable roots) to the existing fields; the existing result of `Resolve-HookTargetWorktree` is never altered for existing callers.
- Policy per hook class:
  - SubagentStop artifact hooks: `FailClosedOnIdentity`. A present identity that resolves to no worktree or several blocks without probing any root; no identity falls through to the agent working directory and then the session root (unchanged for isolated agents).
  - PreToolUse write gates with an absolute `file_path` (completion consistency, file size): the FilePath source decides; a path inside no registered worktree, or a listing failure, keeps today's behavior.
  - Docs-complete gate: `CommandBranch = headRefName` from the existing `gh pr view` lookup; a single non-prunable match decides the receipt root, otherwise today's root.
- Advantages: `HookTargetWorktree.psm1` and its twin stay byte-unchanged, so the pinned contracts in `HookTargetWorktree.Tests.ps1` ("exports exactly the six functions", the result-field list `WorktreeRoot,Source,Ambiguous,ReasonCode,Detail,Candidates`, the allowed `Source` set) and `hook-target-worktree.Tests.ps1` ("defines the same function names", `$twin.Count | Should -Be 6`) need no edits. The preimplementation gate and batch-budget hooks, which #1160 and #1009 own, are untouched. Pure logic is separated from the single process seam.
- Limitations: one more module and twin to mirror and manifest; two resolvers coexist until a later consolidation.

### Rejected alternatives

- **B. Extend `HookTargetWorktree.psm1` in place** (add the prunable filter and a working-directory source). Rejected: it changes the behavior of every existing caller, including the preimplementation gate that #1160 is editing, and breaks the six-function export pin, the result-field pin, and the twin count pin, which widens the merge-conflict surface with #1160 and #1159.
- **C. Migrate all gates onto one resolver family (retire Family B).** Rejected for this item: Family B carries the live-marker filter, the PR-number and record resolvers, and the epic/parallel signals used by ten gates; replacing it is a large refactor with no defect to fix in those gates.
- **D. Fail closed on every missing identity, including the no-identity SubagentStop case.** Rejected: for an isolated subagent the session root is the agent's own worktree, so this would block every single-feature run that omits identity lines, changing correct decisions.

## Question 6: Test Strategy

Existing suites and their injection pattern: `HookTargetWorktree.Tests.ps1` and the Codex twin suite share data rows from `HookTargetWorktree.Rows.Helpers.ps1`; every worktree list is in-memory porcelain supplied through `WorktreeListInvoker` (kinds `Synthetic`, `Porcelain`, `Throwing`, `Empty`, `FailIfCalled`). SubagentStop suites inject `ReadTranscriptHead`, `WorktreeListInvoker`, and `SessionRoot` (`subagentstop-target-worktree.Tests.ps1`: `Describe 'Resolve-SubagentStopTargetWorktree (issue #1105)'`, `'Resolve-SubagentStopArtifactLocation (issue #1105)'`, `'Get-SubagentStopTargetNote (issue #1105)'`; and `validate-*-output.TargetWorktree.Tests.ps1` for each hook). Completion consistency injects `FolderExistsCheck`, `CheckpointReader`, and `RoutingMatrixReader`; file size injects `RepositoryRoot` and `ReadFileContent`; docs-role output mocks `Test-DocsRoleOutputFile`.

New and changed tests (all in-memory, no temporary files, no clock or sleep, POSIX-style roots such as `/repo` and `/host-b/repo` so the Linux hook-suite job passes):

- `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Tests.ps1` with `AgentTargetWorktree.Rows.Helpers.ps1`, and `tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1` running the same rows plus a byte-identical function-text check and an AST purity check modeled on `Describe 'HookTargetWorktree module source (AST)'`.
  - (a) Coordinator root differs from the agent worktree: session root `/repo`, item `/repo/.claude/worktrees/item` on branch `bug/x`; prompt `branch: bug/x` resolves the item; no identity with `AgentWorkingDirectory = /repo/.claude/worktrees/item` resolves the item with `Source = AgentWorkingDirectory`; no identity and `AgentWorkingDirectory` equal to the session root returns the session root (parity row).
  - (b) Handoff restored on a different host path: porcelain lists `/host-a/repo/.claude/worktrees/item` with `prunable` and `/host-b/repo/.claude/worktrees/item` live, both on `bug/x`; resolution returns the live root (today: ambiguous). A prunable-only record returns `TARGET_WORKTREE_NOT_DERIVABLE` naming `git worktree repair`. An issue-only prompt with a `CheckpointIssueReader` map keyed by the new root resolves the new root.
  - Parity rows: every row of `Get-HookTargetWorktreeResolverRows` and `Get-HookTargetWorktreeIdentityRows` that has no prunable record yields the same `WorktreeRoot`, `ReasonCode`, and `Source` through `Resolve-AgentTargetWorktree` as through `Resolve-HookTargetWorktree`.
- (c) Regression for "validators no longer revert in-place fixes":
  - `tests/scripts/claude-hooks/enforce-completion-consistency.TargetWorktree.Tests.ps1` and the Codex counterpart: a completion-asserting Write to `/repo/.claude/worktrees/item/artifacts/orchestration/orchestrator-state.json` whose `feature-folder` exists only under the item root (injected `FolderExistsCheck` keyed by absolute path) is allowed; the same write to a session-root checkpoint keeps today's decision. Fail-before: the current hook denies the first row.
  - `subagentstop-target-worktree.Tests.ps1` and the six `validate-*-output.TargetWorktree.Tests.ps1` suites: a present identity that does not resolve now returns `Rejected` and blocks without probing; the probe seam is a `FailIfCalled` script block. The existing rows asserting "the session root was probed" (found in seven files: the six hook suites and `subagentstop-target-worktree.Tests.ps1`) are updated with the reason recorded.
- `enforce-file-size-limit.TargetWorktree.Tests.ps1` (Claude and Codex): an 801-line Write to `/repo/.claude/worktrees/item/src/a.ps1` from session root `/repo` is denied (today allowed); the same relative write is unchanged.
- `validate-docs-role-output.TargetWorktree.Tests.ps1`: a docs-author stop whose prompt names the item resolves `docs-pages-written` beneath the item root.
- `enforce-docs-complete-gate.Tests.ps1` additions: a merge whose `headRefName` is checked out in exactly one worktree reads the receipt there; zero or several matches keep today's root.
- Gate: one `Invoke-PoshQCParallelTest` run; per-file line coverage from `artifacts/pester/powershell-coverage.xml` at or above 85% for each changed or new file; `Invoke-PoshQCLeakScan` clean.

## Question 7: Mirror and Push-Down Surface

| Source file | Bundle mirror | Pack manifest | Twin / pins |
|---|---|---|---|
| `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` (new) | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (add) | Codex twin below; `test_push_down_pack_manifest_dependency_closure.py` requires it in core because hooks import it |
| `.codex/hooks/agent-target-worktree.ps1` (new) | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/agent-target-worktree.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (add; `render_manifest` in `scripts/dev_tools/generate_codex_agent_variants.py` preserves non-agent entries; confirm with `--check`) | new twin suite |
| `.claude/hooks/subagentstop-target-worktree.ps1` | claude-customizations mirror | core.json (already listed) | `hook-dependency-guard-completeness.Tests.ps1` (guarded import pattern) |
| six `validate-*-output.ps1` SubagentStop hooks | claude-customizations mirrors | already listed | none beyond the guard test |
| `.claude/hooks/enforce-completion-consistency.ps1` | claude-customizations mirror | already listed | Codex copy `.codex/hooks/enforce-completion-consistency.ps1` and its mirror |
| `.claude/hooks/enforce-file-size-limit.ps1` | claude-customizations mirror | already listed | Codex copy `.codex/hooks/enforce-file-size-limit.ps1` and its mirror |
| `.claude/hooks/validate-docs-role-output.ps1` | claude-customizations mirror | already listed | none |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | claude-customizations mirror | already listed | none |

Contract tests to run after mirroring: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, the Codex generator `--check`, `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.

Documentation that describes hook root resolution:

- The execution-environment brief, six byte-identical copies: `.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and their bundle copies under `extensions/drm-copilot/resources/claude-customizations/`, `codex-and-agents-customizations/`, and `customizations/`. Sections: `## Hook Execution Context` (new resolver, prunable filter, fail-closed SubagentStop behavior, the corrected "unchanged gates" sentence, completion-consistency, file-size, docs-role, and docs-complete adoption) and `## Batch Budget` (only if the batch-budget text cites the prunable behavior; no batch-budget rule changes).
- `.claude/rules/orchestrator-state.md` and its mirror `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`: the paragraph that names `Resolve-HookTargetWorktree` for the batch-budget hooks gains the restored-host note (operator runs `git worktree repair`).
- No hook README exists under `.claude/hooks/`.

## Question 8: Sibling-Item Overlap

The sibling feature folders are not present in this worktree, so their file sets are inferred from the item titles and must be confirmed by the orchestrator.

- #1159 (single hook dispatcher, starts after this item merges): every hook changed here remains a standalone script registered in `.claude/settings.json` exactly as today. `.claude/settings.json` and `.codex/config.toml` are not edited by this item, and no new hook is registered (the new files are a library and a Codex helper).
- #1160 (preimplementation gate false positives, path handling): likely file set `.claude/hooks/enforce-orchestration-preimplementation-gate*.ps1` and the `.codex/hooks/` twins, possibly `HookTargetWorktree.psm1` and `hook-target-worktree.ps1`. Recommendation: this item edits none of those files. If #1160 also changes `HookTargetWorktree.psm1`, the composition in `AgentTargetWorktree.psm1` still holds, because it calls the public function and re-renders porcelain text.
- #1161 (planner worktree removal): likely `enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-worktree-removal-gate*.ps1`, `WorktreeRunRecordPath.psm1`, and planner skill text. Recommendation: this item does not edit them (decision D9).
- Shared documentation: the execution-environment brief is the likely common file with both siblings. Each item edits a distinct paragraph of `## Hook Execution Context`; the later merge resolves a text conflict in all six copies. Record this in the plan's Mirror parity bullet.

## Design Decisions

- **D1 — New module, not an extension.** Add `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` and the Codex twin `.codex/hooks/agent-target-worktree.ps1`; leave `HookTargetWorktree.psm1` and `hook-target-worktree.ps1` byte-unchanged.
- **D2 — Precedence.** Absolute file path → command operand/branch → delegation `branch:` label (cross-checked with the canonical issue line) → canonical issue line alone → agent working directory → session root. An absolute advertised path keeps first place, as in #1105.
- **D3 — Prunable registrations are excluded** from branch, issue, and enclosing-root matching; a branch whose only record is prunable returns `TARGET_WORKTREE_NOT_DERIVABLE` with a `git worktree repair` remedy.
- **D4 — SubagentStop artifact hooks fail closed on an unresolved present identity.** `Resolve-SubagentStopArtifactLocation` gains an optional `-Target` parameter (default `$null` keeps today's behavior); when the target carries a reason code it returns `Rejected` with a detail naming the code, and the six hooks pass `-Target $target`. Their existing `Rejected` branches block without a probe. This is the explicit behavior change the issue authorizes ("never from the coordinator's root").
- **D5 — No identity keeps the session-root fallback** for SubagentStop hooks and for `validate-orchestrator-output.ps1`, after the agent-working-directory source. Parity rows prove unchanged decisions.
- **D6 — Completion consistency roots its feature-folder probe** at the worktree that encloses the checkpoint `file_path` (FilePath source), on Claude and Codex. A relative path or a path in no registered worktree keeps the process-relative probe.
- **D7 — File-size gate measures paths in other worktrees.** `RepositoryRoot` becomes the enclosing registered worktree of an absolute `file_path`, on Claude and Codex. This turns a silent allow into the correct decision for files in agent or sibling worktrees; all other decisions are unchanged.
- **D8 — Docs-role output and docs-complete gate adopt the resolver.** `validate-docs-role-output.ps1` resolves through `Resolve-SubagentStopTargetWorktree`; `enforce-docs-complete-gate.ps1` reads the receipt beneath the worktree that has the PR `headRefName` checked out when exactly one non-prunable record matches.
- **D9 — Out of scope, recorded:** the absolute `worktree_path` record comparison in the removal and green-CI gates (fails closed after a host move; portable alternative is `branch_name`; overlaps #1161); the Codex `$PSScriptRoot`-rooted epic hooks (root-bound by design under the child worktree binding); `validate-orchestrator-output.ps1` epic and parallel kinds (already resolved by identity signals).
- **D10 — No configuration knob.** The changed decisions are the defects the issue names; adding a knob that defaults to today's behavior would leave them in place. Every other decision is pinned by parity rows.
- **D11 — Adoption order:** (1) module, twin, and their tests; (2) `subagentstop-target-worktree.ps1` routes through the module and accepts `-Target`, then the six SubagentStop hooks; (3) completion consistency on Claude and Codex; (4) file size on Claude and Codex; (5) docs-role output; (6) docs-complete gate; (7) mirrors, manifests, brief, and rule.
- **D12 — Size estimate.** Production PowerShell source files: 2 new and 13 modified (the subagent-stop helper, six SubagentStop hooks, completion consistency and file size on two surfaces, docs-role output, docs-complete gate), each with a bundle mirror, plus 2 pack manifests and 8 documentation copies. This exceeds the direct-mode batch budget and the 20-task plan guideline, so the plan needs a `## Size Justification` section, or the orchestrator splits steps 5 and 6 into a follow-up item if it judges the scope too large for one item.

## Requirements Mapping

| Acceptance criterion (issue.md) | Design |
|---|---|
| A shared pure resolver chooses the target from delegation branch/issue lines or the agent working directory, never the coordinator root; every checkpoint- or output-reading hook uses it | D1–D5 for the resolver; D4, D6, D7, D8 adopt it in the hooks found session-root-bound or partial in Question 1. Hooks already correct keep their identity resolvers (Family B) and are listed as such; the brief records which resolver each family uses. |
| Tests cover a coordinator root differing from the agent worktree, and a handoff checkpoint restored on a different host path | Question 6 (a) and (b) rows in the module suite and twin suite. |
| Validators no longer revert in-place fixes in the child worktree (regression test) | Question 6 (c): completion-consistency target rows (fail before, pass after) and SubagentStop fail-closed rows with a `FailIfCalled` probe. |
| Hook documentation and push-down payload updated | Question 7 tables. |

State model of a resolution: `Resolved(root, source)` | `Unresolved(reason code, candidates, stale registrations)` | `Fallback(session root)`. Transitions are decided once per call by the first present source in D2 order; no later source is consulted.

## Numeric Derivation Evidence

No numeric count, enumeration, or population is proposed for a `spec.md` acceptance criterion. The counts in this document (files touched, suites to update) are planning estimates only. The spec should state its criteria by named hooks and named test rows, not by counts; a criterion that adds a count needs a full derivation record first.

## Pre-Mortem

- **Review checklists**: a reviewer can flag that existing gate decisions changed without proof. Mitigation: each changed hook carries parity rows for the unchanged cases and a fail-before row for the changed case, and the plan names D4, D6, D7, and D8 as the only intended decision changes.
- **Coverage**: the new module and the edited hooks must each reach 85% line coverage in `artifacts/pester/powershell-coverage.xml`; the default `WorktreeListInvoker` body is the only uncovered seam. Mitigation: exercise every branch through injected invokers and readers, and keep the process call inside the one default invoker.
- **Mirror parity**: 15 PowerShell sources, 2 manifests, and 8 documentation copies must stay byte-identical with their bundle copies, and the Codex twin must match function text. Mitigation: a dedicated mirror task, the five push-down contract tests, the generator `--check`, and a brief-update task that names all six copies (including the conflict risk with #1160 and #1161 in `## Hook Execution Context`).
- **File size**: `enforce-completion-consistency.ps1` and the larger SubagentStop hooks approach the 500-line guidance tier. Mitigation: new logic goes into `AgentTargetWorktree.psm1` and the existing helper; hooks receive call-site edits only; check physical line counts before and after.
- **Test isolation**: the new suites import modules and dot-source hooks that define global functions. Mitigation: remove imported modules in `AfterAll`, use in-memory porcelain and readers only, no temporary files, no environment changes without restore, and run `Invoke-PoshQCLeakScan`.
- **CI-only behavior**: the Linux hook-suite job is case-sensitive and rejects drive-letter fixtures. Mitigation: use `/repo`-style roots, forward slashes, exact file-name case, and no gitignored `artifacts/` state in tests.
- **Evidence**: hook changes on the branch are not exercised by isolated subagents until merge, and an isolated executor worktree has no checkpoint, so direct-mode batch budgets apply there. Mitigation: prove behavior with Pester evidence only; run the executor non-isolated in the item worktree whose checkpoint selects the large route; write evidence append-only under `<FEATURE>/evidence/<kind>/` with UTC write-time stamps.

## Automation Feasibility

No human interaction is required. Every change is code, tests, mirrors, and documentation that the orchestrated large path can execute and verify with the parallel Pester gate and the contract tests. The only operator-facing addition is documentation text that tells an operator to run `git worktree repair` after restoring a worktree on another host; it is guidance, not a step this item performs.

## Items for Orchestrator Confirmation

- The research artifact filename deviates from the delegation (see Filename Note).
- The file sets of #1160 and #1161 were inferred, not read; confirm them before planning overlap tasks.
- Whether Claude Code ever starts a hook process whose directory differs from payload `cwd` was not verified; the agent-working-directory source is designed to be inert when they are equal.
- Whether `.claude/rules/orchestrator-state.md` or the execution-environment brief text must change for #1159 at the same time is outside this item.
