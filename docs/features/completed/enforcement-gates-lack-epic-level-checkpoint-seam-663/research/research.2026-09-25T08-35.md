# Research: enforcement-gates-lack-epic-level-checkpoint-seam (Issue #663)

- Issue: #663 (consolidates #657, #662, #664)
- Work mode: full-bug
- Branch: `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663`, based on `origin/main` `26d57cb37f91e6a695f4ab4c1f57366229756fdc`
- Researched: 2026-09-25T08-35
- Purpose: re-verify each gate named in `issue.md` against the current tree, after the changes delivered by #554, #573, #669, #671, #672/#673 (PR #695), #687 (PR #691), and #688 (PR #689), so the plan is scoped to residual defects only.

## Evidence Method and Limits

- Every claim below cites `file:line` on this tree, read with the Read/Grep/Glob tools.
- `git log` could not be run in this session: the researcher tool set is Read, Grep, Glob, Write, Edit, and WebFetch; no shell tool is available. Change attribution therefore relies on the issue markers the code itself carries (for example `issue #688`, `issue #673`), plus the PR numbers the delegation prompt supplied. **Action for the plan (P0):** run `git -C <worktree> log --oneline --since=2026-09-08 -- <path>` for each file in the scope table below and record the output as baseline evidence, so the attribution is verified rather than inferred.
- No test was executed. Classifications are derived from reading the code paths.

## Summary of Residual Defects

| # | Gate | Current implementation | Classification | Residual |
|---|---|---|---|---|
| 1 | pr-author PR-creation preflight | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` `Get-PrAuthorBypassReason` :331-349, `Get-PrAuthorTargetCheckpointResolution` :71-118 | **STILL-DEFECTIVE** | Only the per-feature checkpoint family is ever read (`WorktreeItemResolution.psm1:36`, `:59-76`). #673 changed which worktree is read, not which checkpoint. Under the #673 hygiene rule the coordinator root must not hold a per-feature checkpoint, so the integration PR is now denied deterministically. |
| 2 | Epic base-branch check 6 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` `Test-EpicBaseBranchOverride` :50-126 | **STILL-DEFECTIVE (latent)** | No epic-scope branch. Reached only after gate 1 passes (`helpers:228`, `:352-356`); once gate 1 is fixed, check 6 needs an epic-scope rule (`--base main`). |
| 3 | Model-routing receipt | `.claude/hooks/enforce-model-routing-receipt.ps1` `Invoke-ModelRoutingReceiptDecision` :198-264 | **STILL-DEFECTIVE** | Receipts are looked up only in the resolved per-feature checkpoint (:185-189, :252-253). No contract names where `epic-orchestrator` records its own `pr-author` receipt. |
| 4 | Preimplementation gate, command and path legs | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` `Invoke-OrchestrationPreimplementationGateDecision` :374-442, `Test-OrchestrationReady` :223-251 | **STILL-DEFECTIVE** (delegation leg FIXED by #554) | The command and path legs are pinned to the single-feature mode (:374-378) and to a cwd-relative per-feature checkpoint (:27, :253-262) whose `feature-folder` must start with `docs/features/active/` (:247). |
| 4b | Bash-side staging exemption | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` `Test-ExemptOrchestrationStagingCommand` :382-441 | **STILL-DEFECTIVE** | Row 12 rejects `<` and `>` anywhere in the line, including inside a quoted `-m` value (:33, :413). The single-quoted `'\''` apostrophe idiom is rejected as unbalanced (:75-104). |
| 5 | Completion-consistency hook | `.claude/hooks/enforce-completion-consistency.ps1` :316-404 with `.claude/hooks/enforce-completion-helpers.ps1` `Test-IsValidFeatureFolder` :57-104 | **STILL-DEFECTIVE (code); resolvable by contract** | Activates only on `orchestrator-state.json` (:96), requires the `docs/features/active/` prefix (`helpers:90-93`). Under the recommended design no per-feature epic-shaped checkpoint is written, so the denial path is not reached; see Decision D3. |
| 6 | Parallel worktree-removal gate | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` :303-326 | **FIXED** by #688 (PR #689) | Epic `features[]` fallback present; proven by `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1` (11 cases, :34-127). Bundle mirror carries the change (4 `issue #688` markers). |
| 7 | Epic-issue promotion / `epic_issue_num` | `.claude/skills/epic-plan/SKILL.md`, `.claude/agents/epic-planner.md` | **STILL-DEFECTIVE (contract)** | `epic_issue_num` appears in no code or skill (Grep: only `issue.md` and the promoted potential record). `epic-planner` has no promotion tool (`epic-planner.md:5-16`). |
| 8 | Integration-PR checkpoint shape | `.claude/skills/epic-orchestrate/SKILL.md` :105-111, :166-178, :285-308 | **STILL-DEFECTIVE (contract)** | No readiness shape for the integration PR; no receipt location for the epic's own `pr-author` delegation; the canonical-issue-line requirement (:173-178) presumes an epic issue that planning never creates. |

## 1. Current State per Gate

### Gate 1 — pr-author PR-creation preflight

- **Where.** `enforce-pr-author-skill.ps1` dot-sources `enforce-pr-author-skill.epic-base-branch.ps1` (:146) and `enforce-pr-author-skill-helpers.ps1` (:150). The decision is `Get-PrAuthorBypassReason` (`helpers:236-360`); the preflight block is `helpers:331-349`; the validator is `Invoke-OrchestratorStatePreflight` (`.claude/lib/orchestrator-state/OrchestratorState.psm1:401-486`), which runs the U-family checks plus `Test-OrchestratorStatePrCreationReadiness` (:356-399; steps 5-8 at :112-117 and :326-331).
- **Checkpoint resolution today.** `Resolve-PrAuthorWorktreeTarget` (`helpers:48-69`) calls `Resolve-WorktreeItemTarget` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:337-382`) with the command text. A `--head` branch signal selects the live worktree with that branch checked out (`:246-303`); the checkpoint path is then always `<root>/artifacts/orchestration/orchestrator-state.json` (`:36`, `:59-76`). `NoTarget` and `Ambiguous` deny (`helpers:113-116`; reason codes from `WorktreeResolution.psm1:463-488`, #687).
- **Epic integration PR on current main, reasoned concretely.** The integration PR is `gh pr create --head epic/<slug>-integration --base main --body-file artifacts/pr_body_<N>.md`.
  - `epic-orchestrator.md:75-85` states the integration branch is worked in a separate integration worktree and is **not** checked out in the invoking (coordinator) worktree. So the `--head` signal resolves either to that integration worktree (`OtherWorktree`) or, if no live worktree has it checked out, to `NoTarget` (`WorktreeItemResolution.psm1:259-263`), which denies.
  - When it resolves, the preflight reads that worktree's per-feature checkpoint. Either it is absent (`OrchestratorState.psm1:163-169`, fail-closed) or it describes some other run (steps 5-8 pending), producing `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` (`helpers:340-347`).
  - `epic-orchestrate/SKILL.md:308` (#673) forbids the coordinator from holding a per-feature checkpoint at its own root. The #655 workaround (a per-feature checkpoint keyed to the epic issue at the coordinator root) is therefore now a contract violation, and there is no compliant checkpoint the gate can read.
  - `epic-orchestrator-state.json` is never consulted by this gate. **STILL-DEFECTIVE.**
- **Existing shared code to reuse.** `Resolve-WorktreeItemTarget` and `Find-WorktreeResolutionBranchSignal` (`WorktreeTargetResolution.psm1:164-185`) for identity; `Get-EpicOrchestrationReadinessFailure` (`enforce-orchestration-preimplementation-gate-modes.ps1:365-407`) already encodes the epic-checkpoint shape conjuncts (`route_id`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, `features`) but is a hook-local dot-sourced file, not a lib module, and its trailing target-record conjuncts are delegation-specific.

### Gate 2 — Epic base-branch check 6

- **Where.** `Test-EpicBaseBranchOverride` (`enforce-pr-author-skill.epic-base-branch.ps1:50-126`), called from `Test-PrAuthorReceiptVerification` check 6 (`helpers:227-231`) with the path gate 1 resolved (#673, `helpers:338`, `:353`).
- **Behavior.** No-op unless the read checkpoint has `epic_mode: true` (:100-103); then `--base` must equal `epic_context.integration_branch` (:105-123).
- **Epic integration PR.** Check 6 is only reached after the preflight passes. With no compliant checkpoint (gate 1), it is unreachable today; with the #655 workaround shape (`epic_mode: false`) it is a no-op. Once gate 1 routes to the epic checkpoint, check 6 has no rule for that scope: the epic checkpoint has no `epic_mode` key, so it would silently no-op rather than assert `--base main`. **STILL-DEFECTIVE (latent)**; the fix is an epic-scope rule, not a removal.
- **Tests.** `enforce-pr-author-skill.epic-base-branch.Tests.ps1` (per-feature epic_mode cases, `--base main` only as a no-op fixture at :78, :84), `...epic-base-branch.TriggerScoping.Tests.ps1`, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1:198-206`. Gap: no epic-scope case.

### Gate 3 — Model-routing receipt

- **Where.** `.claude/hooks/enforce-model-routing-receipt.ps1`: `Get-ModelRoutingTargetCheckpointResolution` (:162-196) maps `Resolve-WorktreeItemTarget` onto the per-feature checkpoint path (:189); `Test-ModelRoutingReceiptPresent` (:101-136) scans `model_routing_receipts[]`; decision at :252-263.
- **Epic `Agent(pr-author)` delegation.** `epic-orchestrate/SKILL.md:173-178` requires the canonical issue line and a `branch:` label. With `branch: epic/<slug>-integration`, resolution is the same as gate 1 (integration worktree or `NoTarget`); the per-feature checkpoint there is absent or foreign, so `Get-ModelRoutingCheckpoint` returns `$null` (:67-69) or lacks a `pr-author` receipt and the gate denies `MODEL_ROUTING_RECEIPT_BLOCKED` (:257-263). **STILL-DEFECTIVE.**
- **Contract gap.** `epic-orchestrate/SKILL.md:166-171` says `epic-orchestrator` applies per-delegation model resolution, but the epic checkpoint field list (:287-292, and `epic-orchestrator.md:131-139`) names no `model_routing_receipts[]` or `complexity_assessments[]`. `validate_epic_orchestrator_state.py:35-48` has no additional-properties restriction in its required-key sets and only validates the Codex receipt key (:468-471), so adding the Claude receipt array to the epic checkpoint is additive; this should be confirmed by a validator test in the plan.
- **Tests.** `enforce-model-routing-receipt.Tests.ps1`, `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`. Gap: zero epic references (Grep count 0).

### Gate 4 — Preimplementation gate (command and path legs)

- **Where.** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (496 lines). Leg selection :380-395; delegation leg mode dispatch :389-393 and :409-428 (#554); single-feature fallback :430-442; `Test-OrchestrationReady` :223-251; checkpoint read `Get-CheckpointContent` :253-262 against the cwd-relative `$script:CheckpointPath` (:27).
- **Behavior.** Comment :374-377 states the path and command legs are "single-feature by construction"; `$mode` stays `single-feature` for them (:378). Readiness requires `issue-num`, `feature-folder` starting with `docs/features/active/` (:247), a route id, and `lifecycle_ready`.
- **Epic operations on current main.**
  - `git add <resolved production path>` during `git merge origin/main` on the integration branch: `Test-ImplementationCommand` (:122-157) classifies it as implementation (production path fails the #539 exemption, `helpers:214-219`); the gate reads the cwd-relative per-feature checkpoint, which the #673 hygiene rule requires to be absent at the coordinator root, so `PREIMPLEMENTATION_GATE_BLOCKED` (:442). **STILL-DEFECTIVE.**
  - Committing `docs/features/epics/<slug>/epic-status.md`: the operand is inside an exempt tree (`helpers:22-28`), so it passes only through the exemption, which is blocked by defect 4b when the message carries the trailer. A pathless `git commit -m "..."` is denied by design (D4 row 4; test `CommandExemption.Tests.ps1:197`).
- **What #554 fixed.** The delegation leg resolves `Epic mode: true` to the epic checkpoint (`modes.ps1:39-61`, `:153-183`) and evaluates `Get-EpicOrchestrationReadinessFailure` (`modes.ps1:365-407`). That is the "#554 fixed the delegation leg but not its command leg" statement in the issue, and it still holds.
- **Tests.** `enforce-orchestration-preimplementation-gate.Tests.ps1` (only a null-payload `Test-OrchestrationReady` case at :237-238), `...-mode-resolution.Tests.ps1`, `...-classifier.Tests.ps1`, `...-absolute-paths.Tests.ps1`, `...TriggerScoping.Tests.ps1`, `...CommandExemption.Tests.ps1`. Gap: no epic-scope case for the command or path leg.

### Gate 4b — Staging exemption and the Co-Authored-By trailer

- **Where.** `Test-ExemptOrchestrationStagingCommand` (`helpers:382-441`).
- **Angle brackets.** `$script:UnresolvableCommandCharacters = '$', '`', '>', '<'` (:33) is tested across the whole command text before any quote parsing (:413-415). `Co-Authored-By: Claude ... <noreply@anthropic.com>` inside a quoted `-m` value therefore returns false. In POSIX shells `<` and `>` inside single or double quotes are literal, so this is a false denial. `$` and backtick inside double quotes do perform substitution, so those must remain denied (this is also what keeps a `-m "$(cat <<'EOF' ... EOF)"` heredoc denied).
- **Apostrophes.** `Split-OrchestrationCommandLine` (:55-105) treats `'` as a quote opener outside quotes and does not model backslash escapes. A double-quoted message containing an apostrophe is balanced (an apostrophe inside double quotes is appended literally, :76-81) and is expected to pass; this has no test today. A single-quoted message using the POSIX `'\''` idiom ends unbalanced and is denied (:418-421). Whether to model backslash-escaped quotes is Decision D4.
- **Classification.** **STILL-DEFECTIVE.** The Parity test (`...-helpers.Parity.Tests.ps1:31-42`) requires four byte-identical copies, and the file is 441 lines (headroom 59).

### Gate 5 — Completion-consistency hook

- **Where.** Located by `COMPLETION_CONSISTENCY_BLOCKED`: `.claude/hooks/enforce-completion-consistency.ps1` (:343, :396). Path filter `Test-IsCheckpointPath` :88-97 (only `artifacts/orchestration/orchestrator-state.json`); evidence `Get-MissingCompletionEvidence` :172-260; folder rule `Test-IsValidFeatureFolder` (`enforce-completion-helpers.ps1:57-104`, prefix at :90-93; message at `consistency:209`).
- **Epic operation.** The #655 denial occurred on a per-feature-shaped checkpoint whose `feature-folder` was `docs/features/epics/<slug>` (issue log line 54). That path is still denied (`helpers:92-93`). An Edit or Write of `epic-orchestrator-state.json` is not intercepted at all (:96-97, :357-359).
- **Adjacent latent defect (not in issue scope).** The Edit path resolves the on-disk content from the literal relative path `artifacts/orchestration/orchestrator-state.json` (:300), not from the tool's `file_path`, so an Edit that targets another worktree's checkpoint by absolute path is validated against the session root's file. The plan should record this as a follow-up candidate, not fix it here.
- **Classification.** **STILL-DEFECTIVE in code.** Under the recommended design (epic-level evidence lives only in `epic-orchestrator-state.json`, and the #673 hygiene rule forbids the per-feature epic-shaped checkpoint), the denial path is no longer reached. See Decision D3.
- **Tests.** `enforce-completion-consistency.Tests.ps1`, `...Payload.Tests.ps1`, `...-codex.Tests.ps1`. Gap: no case for an epics-tree folder or for a non-intercepted epic checkpoint write.

### Gate 6 — Parallel worktree-removal gate

- **Where.** `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`. Epic fallback seam `Get-ParallelWorktreeRemovalGateEpicCheckpointContent` :73-93; epic branch :303-326 (`issue #688`); `Find-ParallelWorktreeItemRecord` parameterized by `-RecordArrayName` :141-192.
- **Reciprocal.** `enforce-epic-worktree-removal-gate.ps1:70-71` reads the parallel checkpoint (#573).
- **Proof.** `enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1:28-127`: allow on `merged` and `worktree_removed`, allow when a parallel checkpoint exists but does not cover the target, backslash normalization, and deny on non-terminal status, missing status, different worktree, unparseable, absent, missing `features`, and unmerged parallel item.
- **Classification.** **FIXED** (#688, PR #689). No residual in scope. Both removal gates read cwd-relative checkpoints, which is consistent with the coordinator root holding the epic checkpoint.

### Contract items 7 and 8 — skills and agents

- `epic-plan/SKILL.md`: child issues only (:37, :65-66, :99-132); no epic-level promotion; no `epic_issue_num`.
- `epic-planner.md`: tools (:5-16) lack `mcp__drm-copilot__potential_to_issue`; `Write`/`Edit` are scoped to `docs/features/epics/**` and `artifacts/orchestration/**`, so it cannot author a potential entry under `docs/features/potential/`. Checkpoint field list (:104-108) has no `epic_issue_num`. `potential_to_issue.py:35-38` already supports `promotion_type: epic`. `gh issue create` is hook-blocked in this repository, so the MCP path is the only promotion route.
- `epic-orchestrate/SKILL.md`: integration-PR step (:105-111) records only the post-PR result in `epic_merge_pr`; no pre-PR readiness shape, no receipt location, no statement that the integration PR is gated against the epic checkpoint. The #673 hygiene paragraph (:308) is pinned by `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1:100-110`, whose header (:11-13) also records that three gates still read a process-directory-relative checkpoint.
- `epic-orchestrator.md:131-139` mirrors the epic checkpoint field list; it will need the same additions.

## 2. Candidate Approaches

### Approach A (recommended) — one epic-scope resolver, anchored to the epic checkpoint's `integration_branch`

A new lib module decides, for a call, whether it is an epic-level operation and, if so, returns the absolute path of the governing `epic-orchestrator-state.json`. Selection rule, evaluated in order:

1. Locate the session worktree root (`Find-WorktreeResolutionRoot`, already used at `WorktreeItemResolution.psm1:199`) and read `<root>/artifacts/orchestration/epic-orchestrator-state.json` through a mockable seam.
2. The call is epic-scope when that checkpoint has `route_id == "epic"` and its `integration_branch` equals (a) the call's branch signal (`--head`, `--branch`, or `branch:` via `Find-WorktreeResolutionBranchSignal`), or (b) for a command leg with no branch signal, the HEAD branch of the command's effective worktree (the `-C <value>` selector when present, otherwise the session root). Optionally (c) the canonical issue number equals `epic_issue_num` once item 7 lands.
3. Otherwise the existing per-feature resolution runs unchanged.

Gate wiring:

- Gate 1: epic scope evaluates an epic PR-creation readiness predicate on the epic checkpoint (`route_id`, `integration_branch` equals `--head`, `features` non-empty and every `merge_status` in `{merged, worktree_removed}`) instead of `Invoke-OrchestratorStatePreflight`.
- Gate 2: epic scope requires `--base main` (or the recorded target) rather than no-op.
- Gate 3: epic scope checks `model_routing_receipts[]` in the epic checkpoint.
- Gate 4: epic scope on the command and path legs evaluates the epic-shape conjuncts of `Get-EpicOrchestrationReadinessFailure` without the target-record conjuncts; Decision D2 covers whether to also require an in-progress merge.
- Gate 5: no code change required (Decision D3).
- Gate 6: none.

Advantages: data-anchored, so it works when the epic runs in the main session with no `agent_type` on the envelope; never selects a checkpoint from prompt text (consistent with the #554 posture at `modes.ps1:12-16`); composes absolute paths from a resolved root (the #673 invariant at `WorktreeItemResolution.psm1:59-76`); needs no per-feature epic-shaped checkpoint, so it agrees with the #673 hygiene rule. Limitation: a new module plus a PowerShell-only epic readiness predicate with no Python parity reference (acceptable; enforcement hooks must not invoke Python).

### Rejected alternatives

- **B — widen the per-feature predicates** (`Test-OrchestrationReady` and `Test-IsValidFeatureFolder` accept `docs/features/epics/` when `route_id == epic`). Rejected: it legitimizes the per-feature epic-shaped checkpoint the #673 hygiene rule forbids (`epic-orchestrate/SKILL.md:308`), and it does not fix gate 1, whose steps 5-8 would still have to be asserted untruthfully (the `INTEGRATION_PR_CANNOT_BE_OPENED` problem in the issue log).
- **C — select scope from the envelope `agent_type`.** Rejected as the primary signal: `agent_type` is present only inside a subagent context (`enforce-epic-invocation-origin.ps1:18-20`), and #655 ran its integration steps from the main session. It may be recorded as a secondary tie-in only.

## 3. Behavior Semantics

- Epic scope is decided only from the session root's epic checkpoint plus a branch or HEAD match; it never reads a checkpoint path from prompt or command text.
- Fail-closed: an absent, unparseable, or non-`epic` epic checkpoint yields "not epic scope", and the per-feature path then runs unchanged (including its denials). An epic-scope call whose epic readiness fails denies with a reason naming the epic checkpoint and the failed conjunct, following `Get-OrchestrationModeDenyReason` (`gate:324-336`).
- Standalone, parallel, and child-feature runs must be byte-for-byte unchanged in decision and reason text: every existing suite must pass unmodified except where a test is deliberately extended.
- Ordering: gate 1 resolves scope before the preflight; check 6 receives the same scope result so the two cannot disagree (the #673 single-resolution rule, `helpers:336-339`).
- Staging exemption (4b): `<` and `>` are unresolvable only outside quoted spans; `$` and backtick remain unresolvable anywhere; the whole-line all-segments rule and the pathspec requirement are unchanged.

## 4. Requirements Mapping and File Scope

### Capacity constraints (measured line counts; 500-line cap)

| File | Lines | Consequence |
|---|---|---|
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | 500 | No headroom; do not modify. |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 499 | No headroom; put the epic readiness predicate elsewhere. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 496 | 4 lines; wiring requires moving code out (for example the two per-mode read seams at :264-289) into a sibling. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 480 | 20 lines; its header declares purity (no I/O), so the resolver cannot live here. |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 441 | 59 lines; four byte-identical copies. |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | 392 | 108 lines; a candidate host only if the resolver is small. |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 360 | Headroom 140. |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 275 | Headroom 225. |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 126 | Headroom 374. |

### Proposed file changes (Claude surface)

Production PowerShell:

1. New `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (resolver and seams). Name and folder are a planner choice; a new folder module must be added to its folder's Manifest test `ExpectedPaths`, because `WorktreeResolution.Manifest.Tests.ps1:60-71` and `OrchestratorState.Manifest.Tests.ps1:78-84` fail on any unregistered on-disk module.
2. Optional second new module for the pure epic readiness predicates, if item 1 would exceed about 400 lines.
3. `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (gate 1).
4. `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` (gate 2).
5. `.claude/hooks/enforce-model-routing-receipt.ps1` (gate 3).
6. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` plus one new sibling to recover headroom (gate 4).
7. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (4b).

Configuration and manifests: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`CodeCoverage.Path` is an explicit allow-list, :289-297 for worktree-resolution; `.psd1` counts as production under the batch-budget hook, `enforce-powershell-batch-budget.ps1:273`, `:284`); `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (new modules).

Documentation: `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, `.claude/agents/epic-planner.md` (frontmatter gains `mcp__drm-copilot__potential_to_issue` and a potential-entry write scope, or the procedure names another author), and `.claude/agents/epic-orchestrator.md` (checkpoint field list). Additive edits must keep the guard fragments at `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py:47-62`.

### Mirror and parity obligations

| Source | Mirror(s) | Enforcing test |
|---|---|---|
| Every non-memory `.claude/**` file | `extensions/drm-copilot/resources/claude-customizations/.claude/**` (text-identical) | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` |
| `.claude/lib/worktree-resolution/*.psm1` | bundle copy, SHA-256 identical | `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1:74-91` |
| `.claude/lib/orchestrator-state/*.psm1` | bundle copy, SHA-256 identical | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:96` |
| New `.claude/**` files | `core.json` pack membership | `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | `.codex/hooks/`, `extensions/.../claude-customizations/.claude/hooks/`, `extensions/.../codex-and-agents-customizations/.codex/hooks/` (SHA-256 identical, four copies) | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:31-42`; `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:8`, `:30` (root/bundle identity for shared modules) |

Codex counterparts that carry the same defect but are **not** byte-coupled to the Claude files: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:272` (`docs/features/active/` prefix), `.codex/hooks/enforce-completion-helpers.ps1:90`, `.codex/hooks/enforce-completion-consistency.ps1:217`. Codex hooks do not import `.claude/lib` (they dot-source only `.codex/hooks` siblings), so an epic-scope fix there needs its own resolver copy. No Codex counterpart exists for gates 1, 2, 3, or 6. See Decision D1.

## Numeric Derivation Evidence

Claim: the staging-exemption helpers module exists in exactly four copies that must change in lockstep.

- Complete Family: every file named `enforce-orchestration-preimplementation-gate-helpers.ps1` in the repository tree.
- Exhaustive Search Scope: entire worktree root.
- Inclusion Rules: exact filename match at any depth.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate-helpers.ps1` at the worktree root.
- Primary Member Set: `.claude/hooks/…`, `.codex/hooks/…`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/…`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/…`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: read `$script:HelpersSurfaceRoots` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:18-23`.
- Cross-check Member Set: `.claude/hooks`, `.codex/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`.
- Cross-check Count: 4.
- Member-set Comparison: the normalized directory sets are identical; the counts agree.

No other numeric acceptance criterion is proposed here. Any count the spec asserts (for example the number of new test cases) must receive its own derivation.

## 5. Testing Implications

Pester cases by gate (all hermetic: mock the read seams, no temporary files, no live git state):

- Resolver module: epic scope when the branch signal equals `integration_branch`; not epic scope when absent, unparseable, `route_id` not `epic`, or branch mismatch; command-leg HEAD match via the `-C` selector and via the session root; path composition is absolute.
- Gate 1: allow when the epic checkpoint is ready; deny when a feature is not merged, when `--head` does not equal `integration_branch`, and when the epic checkpoint is absent; a standalone per-feature regression row unchanged.
- Gate 2: epic scope with `--base main` allows; any other `--base` denies; the per-feature `epic_mode` rows unchanged.
- Gate 3: allow when the epic checkpoint has a `pr-author` receipt; deny when absent; a per-feature regression row.
- Gate 4: command leg `git add <production path>` in epic scope allows or denies per the readiness conjuncts (and the D2 merge-in-progress rule if adopted); standalone rows unchanged.
- Gate 4b: `-m` values with `<` and `>` inside double and single quotes allow; `>`/`<` outside quotes still deny (the existing rows 12c and 12d at `CommandExemption.Tests.ps1:218-219` must keep passing); `$(`, `$VAR`, and backtick inside a double-quoted message still deny; a double-quoted apostrophe allows; the `'\''` idiom per Decision D4. Mirror each new row into `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
- Gate 5 (if D3 includes a change): a pinning row showing a completion-asserting Write to `epic-orchestrator-state.json` is not intercepted.
- Contracts: extend `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` with rows for the new epic-orchestrate integration-PR paragraph and the epic-plan promotion step; add a validator test showing `validate_epic_orchestrator_state` accepts `epic_issue_num` and `model_routing_receipts` (additive).
- Integration scenario (issue): rerun the #655 sequence from its recorded provenance block with zero denials. It needs live GitHub and a real epic, so record it as a manual verification step.

## Toolchain Commands

- Format: `mcp__drm-copilot__run_poshqc_format` on each changed `.ps1`/`.psm1`/`.psd1`.
- Lint: `mcp__drm-copilot__run_poshqc_analyze` (optional `mcp__drm-copilot__run_poshqc_analyze_autofix`).
- Test: `mcp__drm-copilot__run_poshqc_test` with repo settings `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, scoped to:
  - `tests/scripts/claude-hooks/enforce-pr-author-skill*.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-model-routing-receipt*.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate*.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-completion-consistency*.Tests.ps1`
  - `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate*.Tests.ps1` (regression)
  - `tests/scripts/claude-lib/worktree-resolution/`, `tests/scripts/claude-lib/orchestrator-state/`
  - `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
  - `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- Python contract tests: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` plus the epic validator test file the plan adds.
- TypeScript: the extension jest suite covering `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`; the planner must confirm the npm script name before writing it into a gate.

### Known pitfalls (from repository memory; the plan should verify each before relying on it)

- The PoshQC MCP result summary carries no test output, so a plan must not assert a pass count, coverage percentage, or finding count read from it.
- The MCP PoshQC test runner reads the installed extension's settings, so new `CodeCoverage.Path` entries may be ignored; coverage evidence for new modules may require invoking the self-hosted PoshQC module directly.
- Linux CI only: absolute fixture roots such as `C:/workspace` fail; Pester rows that read a gitignored checkpoint from disk fail; path comparisons are case-sensitive. `tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1` is the existing fixture helper to reuse.
- Mirrors written with the Write/Edit tools count against the PowerShell batch budget (`enforce-powershell-batch-budget.ps1:284-298`); the #673 plan mirrored by byte copy as a separate task, and this plan should do the same.
- The agent-worktree isolation guard denies text containing `bash`, `pwsh`, or `wsl`; mirror copy commands and test invocations must avoid those tokens.

## Change Budget and Packaging Recommendation

Estimated residual (Claude surface, excluding optional items): about 7-8 production PowerShell files (2 new modules, 1 new gate sibling, 5 modified hooks), 1 `.psd1`, 1 JSON manifest, 4 Markdown contract files; about 5 new and 4 modified test files; about 12 mirror copies (every modified `.claude/**` file plus 3 extra helpers copies).

Recommendation: **one large feature with explicit batch caps, delivered as a standalone PR to `main`**, not a two-child epic. An epic executing this fix would itself hit gates 1, 3, and 4 at its own integration PR, which is the defect being fixed.

Proposed batches (at most 3 production and 3 test PowerShell files each; mirrors by byte copy after each batch):

| Batch | Production | Tests |
|---|---|---|
| B1 — staging exemption (4b), independent | `enforce-orchestration-preimplementation-gate-helpers.ps1` (+3 byte copies) | `...CommandExemption.Tests.ps1`, `codex-hooks/...-command-exemption.Tests.ps1` |
| B2 — shared resolver | `EpicScopeResolution.psm1` (new), optional readiness module (new), `pester.runsettings.psd1` | resolver tests (new), folder Manifest test (`ExpectedPaths`) |
| B3 — gates 1 and 2 | `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1` | `enforce-pr-author-skill.EpicScope.Tests.ps1` (new), `...epic-base-branch.Tests.ps1` |
| B4 — gates 3 and 4 | `enforce-model-routing-receipt.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, new gate sibling | `enforce-model-routing-receipt.EpicScope.Tests.ps1` (new), `...preimplementation-gate.EpicScope.Tests.ps1` (new) |
| B5 — contracts | Markdown only (skills, agents); `core.json`; optional gate-5 change per D3 | `checkpoint-hygiene-skill-contract.Tests.ps1`, epic validator pytest |

## Decisions Required Before Planning

- **D1 — Codex scope.** Recommended: Claude surface only for gates 1-5, except the four-way byte-identical helpers file (B1), which must change on all four surfaces. File the Codex gate-4 and gate-5 epic-scope work as a follow-up.
- **D2 — Gate-4 command-leg narrowing.** Recommended: in epic scope, allow a non-bookkeeping staging operand only while a merge is in progress in the effective worktree (a `MERGE_HEAD` file in its git directory), which covers the main-sync conflict-resolution case without opening general production staging on the integration branch. The alternative is epic-shape readiness alone.
- **D3 — Gate 5.** Recommended: no production change; pin the non-interception of the epic checkpoint with a test and let the contract (epic evidence only in `epic-orchestrator-state.json`) resolve the observed denial. The alternative is to accept `docs/features/epics/<slug>` when `route_id == epic`, which Approach B analysis rejects.
- **D4 — Apostrophe handling.** Recommended: document that commit messages must be double-quoted (already balanced) and keep the `'\''` idiom denied with an explicit test, rather than modelling backslash escapes in a fail-closed parser.
- **D5 — Epic readiness predicate authority.** The epic PR-creation readiness predicate has no Python reference. Recommended: declare it PowerShell-authoritative in its module header, since enforcement hooks must not invoke Python.

## Automation Feasibility

No third-party UI is involved. Every gate is a PowerShell PreToolUse hook exercised through hermetic Pester tests, and every contract change is Markdown checked by Pester or pytest contract tests. The only step that cannot be automated in the per-commit loop is the end-to-end rerun of the #655 sequence, which requires a live epic and GitHub; it is recorded as a manual verification step.
