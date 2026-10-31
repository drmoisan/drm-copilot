# Research: Preimplementation Gate Denies Item Worktree With Valid Checkpoint (Issue #1010)

- Issue: #1010
- Branch: `bug/preimplementation-gate-item-worktree-1010`
- Timestamp: 2026-10-30T12-17 (UTC, read from a time service because this agent has no shell)
- Lifecycle record: `docs/features/potential/promoted/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint.md`
- Environment facts (tool routes, hook execution context, batch budget, CI shape, contract tests) are those of `.claude/skills/execution-environment/SKILL.md`; they are cited, not restated.

## Summary of Verified Findings

1. The stated root cause does not hold for the Claude gate's Write/Edit leg. The `Split-Path (Split-Path $PSScriptRoot)` derivation exists only in the batch-budget hooks (`.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, parameter defaults of their `$Root` parameters). No file of the Claude gate set uses `Split-Path` or `$PSScriptRoot` for a root. The Claude gate uses `(Get-Location).Path` as the session root and, for the path leg, already reads the checkpoint beneath the worktree that contains `file_path` (`Resolve-OrchestrationGateTarget` -> `Resolve-WorktreeOperandTarget` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, an upward `.git` ascent through `Find-WorktreeResolutionRoot`). Existing test `O1 admits a Write inside another worktree whose checkpoint is ready, reading that checkpoint` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` pins that behavior.
2. The Claude gate's command leg (`git add` / `git commit`) is session-root bound in most shapes. `Get-OrchestrationEpicScopeSelector` reads only a `git -C <value>` that is the first two tokens of the first command segment. It returns `$null` (session root) for: a `-C` after another global option (`git -c k=v -C <wt> commit`), a `-C` on a later segment, an absolute file argument without `-C` (`git add <wt>/file`), and a `cd <wt> && git commit` chain. This matches the lifecycle record's "committing an owner-decision record onto a prepared item branch" case.
3. The Codex gate is session-root bound on every single-feature leg. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` reads `$script:CheckpointPath` (`artifacts/orchestration/orchestrator-state.json`) as a cwd-relative path in its own `Get-CheckpointContent` (no parameter). Write/Edit (mapped to `file_path`), `apply_patch`, and Bash legs all evaluate the session root's checkpoint. This is the defect as described, on the Codex surface.
4. A further Claude coordinator-rooted denial exists in epic topology. `Get-OrchestrationEpicScopeDecision` runs before the single-feature read. Its verdict rule V1 (`Resolve-OrchestrationEpicTargetVerdict` in `enforce-orchestration-preimplementation-gate-targets.ps1`) always includes the session-root scope, so a coordinator whose session root is on an epic integration branch denies a Write into a child worktree with `target-mixed` even when the child checkpoint is ready. This is epic-scope policy from issues #663/#732/#738, not the single-feature read, and is recorded under Open Risks rather than changed (the spec excludes relaxing preimplementation requirements).
5. `Test-OrchestrationReady` casts `lifecycle_ready` with `[bool]` in all four runtime copies, so the JSON string `"false"` (and any non-empty string or non-zero number) is treated as ready.
6. Codex hooks cannot import `.claude/lib` in a consumer repository (`.codex/hooks/file-size-policy.ps1` header). The Codex gate therefore cannot consume `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` directly; it needs a Codex twin of the resolver.

## 1. Current Gate Map

### Claude surface (`.claude/hooks/`)

| File | Role | Logical lines |
|---|---|---|
| `enforce-orchestration-preimplementation-gate.ps1` | Entry point. Classifiers `Test-ImplementationPath`, `Test-ImplementationCommand`, `Test-ImplementationDelegation`, `Test-PreparationModeDelegation`; readiness `Test-OrchestrationReady`; decision `Invoke-OrchestrationPreimplementationGateDecision`; `Invoke-OrchestrationPreimplementationGateEntryPoint`. Imports `../lib/hook-payload/HookPayload.psm1`; dot-sources `hook-dependency-guard.ps1`, `-helpers`, `-modes`, `-epic-scope`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1`. | 471 |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | Issue #539 staging exemption (`Test-ExemptOrchestrationStagingCommand`, `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`). Not changed. | 470 |
| `enforce-orchestration-preimplementation-gate-modes.ps1` | Delegation mode dispatch, `Get-OrchestrationDelegationCheckpointPath`, epic/parallel readiness predicates, `Find-OrchestrationDelegationTargetFolder`, `Find-OrchestrationDelegationIssueNumber`. Not changed. | 496 |
| `enforce-orchestration-preimplementation-gate-epic-scope.ps1` | Guarded imports of `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1`, `EpicScopeResolution.psm1`, `EpicScopeReadiness.psm1`; dot-sources `-targets`. Read seams `Get-CheckpointContent`, `Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent` (mandatory absolute `-Path`); `Get-OrchestrationModeDenyReason`; `Resolve-OrchestrationGateTarget`; `Read-OrchestrationGateCheckpoint`; `Get-OrchestrationEpicScopeSelector`; `Get-OrchestrationEpicScopeDecision`. | 267 |
| `enforce-orchestration-preimplementation-gate-targets.ps1` | Pure per-segment target resolution for the epic-scope decision (`Get-OrchestrationCommandTarget`, `Resolve-OrchestrationEpicTargetVerdict`, `Resolve-OrchestrationEpicTargetOutcome`). Byte-identical in four copies. Not changed. | 433 |

Root and checkpoint derivation (Claude):
- Session root: `(Get-Location).Path` inside `Resolve-OrchestrationGateTarget` and `Get-OrchestrationEpicScopeDecision`. The hook command in `.claude/settings.json` is `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (relative), so the process cwd is the session directory.
- Checkpoint path: `Get-WorktreeRunCheckpointPath -Kind item|epic|parallel -WorktreeRoot <resolved root>`, read through the three seams.
- Agent delegations: `Resolve-WorktreeItemTarget` (issue line plus `branch:` label), `Resolve-WorktreeEpicTarget` (`integration_branch:`), `Resolve-WorktreeParallelTarget` (`parallel_slug:`). These stay unchanged.
- Hook matchers in `.claude/settings.json`: `Bash`, `Write|Edit`, `Agent`. `MultiEdit` and `NotebookEdit` do not reach this gate.

Code paths that must switch to the resolved target worktree (Claude):
- `Resolve-OrchestrationGateTarget`, branches `if ($FilePath)` and `if ($Command)`: replace `Resolve-WorktreeOperandTarget` and `Get-OrchestrationEpicScopeSelector` with a call to `Resolve-HookTargetWorktree`, adapting its result to the existing `{ Status, WorktreeRoot, ReasonCode, Detail }` shape that `Read-OrchestrationGateCheckpoint` reads. The `epic`/`parallel` branches and the prompt branch are not touched.
- `Get-OrchestrationEpicScopeSelector` becomes unused on the Claude surface and is removed (no Claude test references it; the Codex test that references it uses the Codex copy).
- `Get-OrchestrationEpicScopeDecision` is not changed (see Open Risks R2).

### Codex surface (`.codex/hooks/`)

| File | Role | Logical lines |
|---|---|---|
| `enforce-orchestration-preimplementation-gate.ps1` | Entry point; same classifiers and `Test-OrchestrationReady`; its own cwd-relative `Get-CheckpointContent` and `Get-OrchestrationModeDenyReason`; entry tail maps Bash/apply_patch raw input and Edit/Write via `ConvertTo-CodexFileEditInput` from `codex-pretooluse-file-mapping.ps1`. | 500 |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | Mirror of the Claude helpers. Not changed. | 470 |
| `enforce-orchestration-preimplementation-gate-modes.ps1` | Codex modes (relative mode paths). Not changed. | 493 |
| `enforce-orchestration-preimplementation-gate-epic-scope.ps1` | Relative read seams `Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent`; `Get-OrchestrationEpicScopeSelector`; `Get-EpicCommandLegReadinessFailure`; `Get-OrchestrationEpicScopeDecision`; dot-sources `-epic-resolution` and `-targets`. | 210 |
| `enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | Codex-local port of the worktree ascent and epic-scope resolution (`Find-WorktreeResolutionRoot`, `Resolve-EpicScopeCheckpoint`, seams `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`). Not changed. | 493 |
| `enforce-orchestration-preimplementation-gate-targets.ps1` | Byte-identical to the Claude copy. Not changed. | 433 |

Code paths that must switch (Codex): the single-feature read `if (-not $CheckpointRaw) { $CheckpointRaw = Get-CheckpointContent }` in `Invoke-OrchestrationPreimplementationGateDecision`, for the `file_path`, `command` (Bash), and `apply_patch` legs. The Codex mode legs (`Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent`) are delegation-only and stay unchanged.

### Existing `.claude/lib/worktree-resolution/` modules used by the gate

`WorktreeResolution.psm1` (ascent, enumeration via the admin directory, reason codes `TARGET_WORKTREE_AMBIGUOUS` and `TARGET_WORKTREE_NOT_DERIVABLE`), `WorktreeTargetResolution.psm1` (`New-WorktreeResolutionTargetResult`), `WorktreeItemResolution.psm1`, `WorktreeRunResolution.psm1`, `WorktreeRunRecordPath.psm1`, `EpicScopeResolution.psm1`, `EpicScopeReadiness.psm1`. None starts a process. Nested imports inside these modules are module-scoped, so reason-code accessors are not visible in the gate's scope unless imported there.

## 2. Runtime Copies, Mirrors, Manifests

| Surface | Repository path | Bundle path | Relationship |
|---|---|---|---|
| Claude | `.claude/hooks/enforce-orchestration-preimplementation-gate*.ps1` (5 files) | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (5 files) | Hand-maintained mirrors; text equality enforced by `test_push_down_claude_resource_contracts.py`. Line counts are equal for all 5 pairs. |
| Codex | `.codex/hooks/enforce-orchestration-preimplementation-gate*.ps1` (6 files, includes `-epic-resolution`) | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (6 files) | Hand-maintained mirrors; enforced by `test_push_down_codex_and_agents_resource_contracts.py`. Line counts are equal for all 6 pairs. |

- None of these hook files is generated. `scripts/dev_tools/generate_codex_agent_variants.py` generates only agent variants and adds agent paths to Codex pack manifests (`render_manifest` preserves existing entries and re-serializes with `json.dumps(indent=2)` plus a trailing newline).
- Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists the 5 Claude gate files and the 7 worktree-resolution modules; `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists the 6 Codex gate files.
- New module dependency: the Claude `-epic-scope` sibling gains a guarded `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/HookTargetWorktree.psm1')`. `test_push_down_pack_manifest_dependency_closure.py` requires that module in Claude `core.json`; issue #1009 adds the module, and this item depends on #1009 also listing it in Claude `core.json` (the batch-budget hooks are core). If #1009 lists it in another pack, this item must move or add it to core. The `$PSScriptRoot` form must match the existing named form so the "every `$PSScriptRoot` occurrence matches a named form" test passes.
- Codex: if a Codex resolver twin is a new `.codex/hooks/` file, it must be added to Codex `core.json` and mirrored in the bundle.

## 3. Tests That Assert Current Behavior

Search scope: `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `tests/scripts/claude-runtime`, `tests/scripts/dev_tools`, for the gate file names, `Test-OrchestrationReady`, `Resolve-OrchestrationGateTarget`, `Read-OrchestrationGateCheckpoint`, `Get-CheckpointContent`, `lifecycle_ready`, `PREIMPLEMENTATION_GATE_BLOCKED`, and `TARGET_WORKTREE_NOT_DERIVABLE`.

Tests that change:

| Test file | Rows | Disposition |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` | `O4 reads the checkpoint of the worktree a git -C selector names`, `O5 reads the session worktree checkpoint for a command with no selector`, `O6 decides a Write inside the session worktree exactly as the injected checkpoint` | Updated: `Set-OperandPlacement` mocks `Find-WorktreeResolutionRoot` inside `WorktreeRunResolution`, which the new path no longer calls. Re-mock through the `Resolve-HookTargetWorktree` worktree-list invoker seam. Expected outcomes are unchanged (O5 remains a session-root fallback because `git add scripts/Sample.ps1` has a relative operand). O1 to O3, O7 to O10 are unchanged (they mock `Resolve-OrchestrationGateTarget` or test imports and literals). |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` | `$script:ReadinessCases`; `$script:CodexOnlyGateFunction` | Updated: add readiness rows for `"lifecycle_ready":"false"`, `"lifecycle_ready":"true"`, and `"lifecycle_ready":1` (all `Expected = $false` on both surfaces). If the Codex `Get-CheckpointContent` moves out of the Codex gate file, remove it from `$script:CodexOnlyGateFunction` (AC-18 inventory row `each gate's function names equal the shared set plus its declared per-surface set`). |
| `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | `$script:EpicStateBaselineModuleSeam` | Updated: register the `Resolve-HookTargetWorktree` worktree-list invoker seam (returning an empty list) so no suite starts a `git` process or reads host worktrees. |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `returns empty checkpoint content when the checkpoint file is absent`, `returns the checkpoint file content when the checkpoint file is present`, `reads the checkpoint from disk when no checkpoint text is supplied` | Updated: `Get-CheckpointContent` gains a mandatory absolute `-Path`. The third row uses `Push-Location` into `tests/`, which under target resolution ascends to the repository root and would read a real gitignored checkpoint on a developer host; it must mock the read seam and the invoker instead. |

Tests that stay unchanged but must still pass (verified by reading):
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`, row `keeps <File> at or under 500 lines in the repository and the bundle` for the Codex gate (currently exactly 500), `-epic-scope` (210), and `-epic-resolution` (493). The Codex gate must not grow net.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` (500-line pins and four-copy parity of files this item does not edit).
- Exact deny text `... to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state ...` is asserted by `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`, and the Codex `-epic-scope.Tests.ps1` and `-epic-scope-targets.Tests.ps1`. The single-feature deny wording must not change.
- `enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` rows R1 to R15 (Agent delegation and injection precedence): unchanged because the delegation branches are not touched.
- `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1`: unchanged; every decision injects `-CheckpointRaw`.
- All other suites listed by the search inject `-CheckpointRaw` or mock `Get-CheckpointContent` through `Register-EpicStateBaselineMock`; with the invoker seam mocked to an empty list, the resolver falls back to the session root, which equals the prior ascent result for synthetic paths.

New tests (no existing home covers the coordinator-rooted shape):
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1`

Each covers: Write/Edit into an item worktree with a ready checkpoint -> allow, reading the item path; the same with an absent or not-ready checkpoint -> deny; `git -c k=v -C <wt> commit`, `git add <wt>/file`, and a later-segment `-C` -> the item checkpoint; a target outside every registered worktree -> session-root checkpoint (current behavior); two candidate worktrees -> deny naming `TARGET_WORKTREE_AMBIGUOUS`; a resolver result with no root -> deny naming `TARGET_WORKTREE_NOT_DERIVABLE`; `lifecycle_ready` `"false"` -> deny. The Codex suite additionally covers `apply_patch` with an absolute marker path.

## 4. Contract Tests, Generator, and Brief Implications

- Contract tests to run after the edit (from the brief's `## Contract Tests That Pin Mirrored Files`): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, the Codex generator `--check`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (the new import must use the guarded `try { Import-Module ... } catch { Add-HookDependencyFailure ... }` form already used in the `-epic-scope` sibling).
- Codex generator: no generated file changes unless a Codex twin is added to Codex `core.json`; the manifest must then remain byte-equal to `render_manifest` output (two-space JSON, trailing newline), or `--check` reports it stale.
- Execution-environment brief: no fact it states changes. `## Hook Execution Context` (isolated subagents run `main`'s hook copies; branch hooks are proven by Pester) remains true, and the brief states nothing about the preimplementation gate's checkpoint source. The batch-budget exemption sentence (checkpoint "in the worktree that holds the hook script") is #1009's fact, not this item's. No brief-copy update is required by this item. `.claude/rules/orchestrator-state.md` states nothing about this gate's resolution and is not changed. `.claude/skills/orchestrate/SKILL.md` and `.claude/skills/parallel-orchestrate/SKILL.md` describe only Agent-delegation resolution, which is unchanged.

## 5. What Sibling #1011 May Rely On

Based on `Test-ImplementationPath`, `$script:CheckpointPaths`, and the resolution path after this fix:
- Checkpoint writes: any `file_path` ending in `artifacts/orchestration/` followed by one of the seven checkpoint names (`orchestrator-state.json`, `parallel-planner-state.json`, `parallel-orchestrator-state.json`, `epic-planner-state.json`, `epic-orchestrator-state.json`, `powershell-orchestrator-state.json`, `csharp-orchestrator-state.json`) is not implementation in any spelling, absolute or relative, in any worktree. This gate never denies them, before or after the fix.
- `artifacts/pr_body_<N>.md`: the `.md` extension is not an implementation extension; this gate never denies it.
- `artifacts/pr_body_<N>.receipt.json`: `.json` is an implementation extension, so the write is gated. After the fix, a Write whose absolute `file_path` lies in an item worktree is evaluated against that item worktree's `artifacts/orchestration/orchestrator-state.json` (Claude: already true for the path leg on `main`; Codex: new). It is allowed when that checkpoint has a non-empty `issue-num`, a `feature-folder` under `docs/features/active/`, a `route_id` or `path_selected`, and `lifecycle_ready` equal to the JSON boolean `true`.
- #1011 must pass the absolute item-worktree path. A relative `artifacts/pr_body_<N>.receipt.json` resolves against the session root and evaluates the coordinator's checkpoint.
- Bash-side PR commands (`gh pr create --body-file ...`, `gh pr edit`) are not implementation commands for this gate; `--body-file`/`--head` resolution matters to `enforce-pr-author-skill.ps1`, not here.
- Not covered by this fix: an epic coordinator whose session root is on the integration branch is denied with `target-mixed` for a write into a child worktree (Open Risk R2).

## 6. Coverage Population and File Sizes

- `config/poshqc-coverage.json` roots: `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. Every gate file in both surfaces and the new `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` are in the population automatically; bundle copies under `extensions/` are not. PowerShell gate: line coverage at least 85% per changed file, no branch gate.
- `config/file-size-baseline.json` lists none of the gate files or worktree-resolution modules.

| File | Lines | Tier |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 471 | below 500 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 267 | below 500 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 496 | below 500 (not edited) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 470 | below 500 (not edited; pinned at 500) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | 433 | below 500 (not edited; pinned at 500) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | at 500 guidance; pinned at 500 by test |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 210 | below 500; pinned at 500 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | 493 | below 500; pinned at 500 (not edited) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 493 | not edited |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 470 | not edited |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | 433 | not edited |

Counts are `^` line matches from Grep, which equal physical lines; bundle copies have identical counts.

## 7. Batch-Budget Implications

Production PowerShell files written by this item, assuming #1009 delivers both `HookTargetWorktree.psm1` and a Codex twin:

1. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
3. `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
5. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
6. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
7. `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
8. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`

Eight distinct production PowerShell files; ten if this item must create the Codex twin and its bundle copy (extension E2). Either count exceeds the direct-mode cap of three, so the executing worktree's checkpoint must select the `large` route (or `remediation`) as the brief's `## Batch Budget` describes. Test files do not count.

## Shared Resolver Requirements (#1009)

What the gate needs from `Resolve-HookTargetWorktree`:

- Inputs: explicit `-FilePath`, `-Command`, and `-SessionRoot` (the gate passes `(Get-Location).Path`), plus the injectable worktree-list invoker. The gate does not pass a prompt; Agent calls keep their current resolvers.
- Output: `WorktreeRoot` as an absolute, normalized path accepted by `Get-WorktreeRunCheckpointPath`; `Ambiguous`; `Source` (used in the deny detail).
- Bash semantics: every segment and every git global-option position is scanned for `-C`, and absolute file arguments are operands. Operands in two or more distinct registered worktrees yield `Ambiguous = $true`.
- Fallback: an operand outside every registered worktree, a relative operand, or no operand yields the session root (`Source` session-root). This preserves the lifecycle record's "target outside every worktree -> current behavior".
- Nearest enclosing registered worktree, so a nested `.claude/worktrees/agent-*` worktree wins over the main checkout.
- The resolver reads no file. The gate keeps its own `Get-CheckpointContent` seam.

Extensions to confirm with #1009 before planning:
- E1 (required if absent): a defined result when no root can be produced (invoker failure, session root outside any repository). The contract `{ WorktreeRoot, Source, Ambiguous }` has no no-target state. The gate needs `WorktreeRoot = $null` (or an equivalent flag) to emit `TARGET_WORKTREE_NOT_DERIVABLE`; a silent session-root substitution on invoker failure would fail open toward the coordinator's checkpoint.
- E2 (required for the Codex surface): a Codex twin under `.codex/hooks/`, because Codex hooks cannot import `.claude/lib`. If #1009 does not deliver one (its Codex batch-budget hooks would need the same), this item creates `.codex/hooks/hook-target-worktree.ps1` (name to align with #1009) as a function-identical twin with a parity test in the style of `tests/scripts/codex-hooks/file-size-policy.Tests.ps1`, plus its bundle copy and Codex `core.json` entry.
- E3 (required for Codex `apply_patch`): the gate calls the resolver once per `*** Add/Update/Delete File:` / `*** Move to:` marker path as a file-tool source, so no new source kind is needed provided `-FilePath` accepts any path string. Multiple markers resolving to different worktrees must deny as ambiguous; the gate composes that from per-path results.
- No new source kind is required for the Claude surface. A `cd <wt> && git commit` chain is not one of the four sources; it remains a session-root evaluation and denies when the coordinator holds no checkpoint. `git -C <wt>` is the supported form (Open Risk R4).

## Candidate Approaches

1. Recommended: consume the shared resolver behind the existing seam. Keep `Resolve-OrchestrationGateTarget` and `Read-OrchestrationGateCheckpoint` names and output shapes; replace only the file and command branches with a `Resolve-HookTargetWorktree` call plus a small adapter. Port the same seam pair to the Codex `-epic-scope` sibling against the Codex twin. Advantages: existing mocks of `Resolve-OrchestrationGateTarget` (Parity suite, O1 to O3, O9) keep working; Agent paths are untouched; one resolver across the four sibling bugs. Limitations: depends on #1009 merging first; adds a `git` process per gated call.
2. Rejected: extend the in-gate selector parsing (`Get-OrchestrationEpicScopeSelector`) to scan all segments and global options, and port the ascent to Codex locally. Smaller dependency surface, but it contradicts the operator decision for a shared resolver and duplicates the operand logic #1009 owns.

## Recommended Design

Claude:
- `enforce-orchestration-preimplementation-gate-epic-scope.ps1`: add the guarded `HookTargetWorktree.psm1` import; in `Resolve-OrchestrationGateTarget`, route `$FilePath` and `$Command` to `Resolve-HookTargetWorktree` and adapt: `Ambiguous` -> `Status = 'Ambiguous'`, `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`; `$null` root -> `Status = 'NoTarget'`, `ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'`; otherwise `SessionRoot` or `OtherWorktree` with the root and a `Detail` naming `Source`. Obtain the reason codes from the resolver module or a guarded import of `WorktreeResolution.psm1`, not as new literals. Remove `Get-OrchestrationEpicScopeSelector`. Update the header `.DESCRIPTION`/`.NOTES`.
- `enforce-orchestration-preimplementation-gate.ps1`: in `Test-OrchestrationReady`, replace `[bool]$Payload.lifecycle_ready` with `($Payload.lifecycle_ready -is [bool]) -and $Payload.lifecycle_ready` (JSON `true` only; string, number, and null are not ready). Same in the Codex copy. `ConvertFrom-Json` yields `[bool]` for JSON literals, so existing ready fixtures are unaffected.
- No change to the deny wording, injection precedence (`-CheckpointRaw` truthiness fall-through, `ContainsKey` for mode parameters), the epic-scope decision, or Agent resolution.

Codex:
- Move `Get-CheckpointContent` from the gate into `enforce-orchestration-preimplementation-gate-epic-scope.ps1` with a mandatory absolute `-Path` (mirroring the Claude seam), and add `Resolve-OrchestrationGateTarget`/`Read-OrchestrationGateCheckpoint` equivalents for the single-feature legs, using the Codex twin. For `apply_patch`, resolve each marker path. The gate's single-feature read calls the reader and denies on an unresolved target with the same reason text the Claude sibling uses. The move keeps the Codex gate at or below its 500-line pin.

## Automation Feasibility

No human interaction is required to implement or verify this item. All behavior is proven by Pester suites with mocked seams (the brief's `## Hook Execution Context`: isolated subagents run `main`'s hooks, so no live subagent check is part of acceptance). Ordering dependency: #1009 must merge first, or this branch must be based on #1009's branch; the orchestrator confirms that state with `git`/`gh`, which this agent cannot run.

## Numeric Derivation Evidence

### Claim N1: four runtime copies of `Test-OrchestrationReady` carry the loose `lifecycle_ready` cast

- Complete Family: every PowerShell definition that reads `lifecycle_ready` from a checkpoint.
- Exhaustive Search Scope: all `*.ps1` and `*.psm1` files in the repository, including `extensions/drm-copilot/resources/`.
- Inclusion Rules: a production `.ps1`/`.psm1` line that reads `lifecycle_ready` with a type conversion.
- Exclusion Rules: test files and Markdown.
- Primary Search Strategy or Query Expression: Grep `lifecycle_ready` restricted to `*.{ps1,psm1}`, then filter non-test lines.
- Primary Member Set: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: Grep `function Test-OrchestrationReady` across the repository, excluding `docs/`.
- Cross-check Member Set: the same four files.
- Cross-check Count: 4
- Member-set Comparison: identical sets after normalization; the only other match of the cross-check (a completed feature's evidence Markdown) is excluded by rule.

### Claim N2: eight production PowerShell files are written (ten with extension E2)

- Complete Family: production `.ps1`/`.psm1` files this design edits, including bundle mirrors.
- Exhaustive Search Scope: gate files under `.claude/hooks/`, `.codex/hooks/`, and both bundle hook trees.
- Inclusion Rules: a gate file whose functions the design changes (`Test-OrchestrationReady`, `Resolve-OrchestrationGateTarget`, `Get-CheckpointContent`, the Codex single-feature read), and each bundle mirror of such a file.
- Exclusion Rules: `-helpers`, `-modes`, `-targets`, Codex `-epic-resolution` (unchanged by the design); test files; the #1009-owned module.
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate*` restricted to `hooks/*.ps1`, then select the entry and `-epic-scope` files per surface.
- Primary Member Set: the eight paths listed in section 7.
- Primary Count: 8
- Cross-check Search Strategy or Query Expression: pack-manifest entries in both `core.json` files for the entry and `-epic-scope` files, each doubled by its bundle copy (Grep line-count listing of the bundle hook trees confirms each bundle file exists).
- Cross-check Member Set: Claude core entries `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `-epic-scope.ps1`; Codex core entries `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and `-epic-scope.ps1`; plus their four bundle copies.
- Cross-check Count: 8
- Member-set Comparison: identical sets. E2 adds `.codex/hooks/hook-target-worktree.ps1` and its bundle copy (10) only if #1009 does not deliver the twin.

## Candidate File Inventory

Production (edited):
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`

Conditional (extension E2, only if #1009 provides no Codex twin):
- `.codex/hooks/hook-target-worktree.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-target-worktree.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`

Conditional (only if #1009 does not list the module in Claude core):
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

Tests:
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` (new)
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` (new)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`
- `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`

Not changed (verified): the `-helpers`, `-modes`, `-targets` files and Codex `-epic-resolution` in all copies; `.claude/settings.json`; `.codex/config.toml`; the six execution-environment brief copies; `.claude/rules/orchestrator-state.md`.

## Open Risks

- R1 Dependency on #1009: `HookTargetWorktree.psm1` is not on `main`. Its final contract (no-target state, multi-segment ambiguity, Codex twin) decides E1 to E3. Planning should wait for #1009's merged contract or base on its branch.
- R2 Epic coordinator `target-mixed`: V1 in `Resolve-OrchestrationEpicTargetVerdict` includes the session-root scope, so an epic coordinator on its integration branch is denied when writing into a child worktree. Changing V1 relaxes epic-scope policy and is excluded by the spec; record it as an owner decision or follow-up.
- R3 Behavior narrowing: the registered-worktree lookup replaces the filesystem ascent for the path leg. A path in a worktree of a different repository, or an unregistered directory containing a `.git` entry, now falls back to the session root.
- R4 `cd <wt> && git commit` stays session-root evaluated and denies from a coordinator without a checkpoint. The supported form is `git -C <wt> ...`.
- R5 Latency: one `git worktree list --porcelain` process per gated call that requires a checkpoint (after classification only).
- R6 Session root source: the gate keeps `(Get-Location).Path`; the payload `cwd` field is not used, matching current behavior.

## Pre-Mortem

- Review checklists: a reviewer could flag dead code (`Get-OrchestrationEpicScopeSelector` left on the Claude surface), a changed deny wording, or new reason-code literals. Mitigation: remove the unused Claude function, keep the single-feature deny text byte-identical, and source reason codes from the existing accessors.
- Coverage: the new adapter branches (Ambiguous, no root, session root, other worktree) and the strict boolean could be under-covered on either surface. Mitigation: the two new suites drive every branch with mocked invoker output and assert per-file line coverage of at least 85% from `artifacts/pester/powershell-coverage.xml` for the four edited repository files.
- Mirror parity: a missed bundle copy fails `test_push_down_claude_resource_contracts.py` or `test_push_down_codex_and_agents_resource_contracts.py`; a missing core entry fails `test_push_down_pack_manifest_dependency_closure.py`. Mitigation: copy each edited file to its bundle path in the same task and run all brief-listed contract tests plus the Codex generator `--check`. No brief update is required because no brief fact changes.
- File size: the Codex gate is at its 500-line test pin (`keeps <File> at or under 500 lines in the repository and the bundle`). Mitigation: move `Get-CheckpointContent` out of the Codex gate before adding logic, and measure physical lines of all edited files before and after.
- Test isolation: the resolver's default invoker would start a real `git` process and read host worktrees in any suite that does not mock it, and the legacy Codex `Push-Location` row would read a real gitignored checkpoint. Mitigation: register the invoker in `EpicStateIsolation.Baseline.Helpers.ps1`, rewrite the legacy rows with mocked seams, and run the brief's seeded shuffled Pester runs (three seeds) plus a fresh single-process run over `tests/scripts`.
- CI-only behavior: the Linux hook-suite job runs both hook test folders on a case-sensitive file system. Mitigation: synthetic roots use forward-slash `/synthetic-worktrees/...` paths, no drive letters or backslash literals, exact file-name case, and mocked worktree-list output in porcelain form.
- Evidence: fail-before evidence must show the Codex Write/apply_patch leg and the Claude `git -c k=v -C <wt> commit` leg denying against a ready item checkpoint before the fix. Mitigation: record the fail-before and pass-after Pester runs under `<FEATURE>/evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`, reading counts from `artifacts/pester/pester-junit.xml`.
