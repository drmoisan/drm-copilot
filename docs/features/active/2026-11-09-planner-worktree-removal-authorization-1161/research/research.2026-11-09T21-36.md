# Research: planner-worktree-removal-authorization (Issue #1161)

- Issue: #1161 (full-feature)
- Branch: `feature/planner-worktree-removal-authorization-1161`
- Feature folder: `docs/features/active/2026-11-09-planner-worktree-removal-authorization-1161`
- Researcher tool limits: Read, Grep, Glob, Write only. Facts that need `git show`, `git worktree list`, `gh`, or a live Claude Code run are marked "orchestrator to confirm".

## Summary of Findings

1. Two Claude PreToolUse gates and one Codex PreToolUse gate intercept `git worktree remove`, and Claude PreToolUse denials are conjunctive. An allow added only to `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is therefore insufficient: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` would still deny the same command with `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. Both Claude gates must consult the new planner branch.
2. No gate reads `artifacts/orchestration/epic-planner-state.json` today. A preparation worktree is recorded by no checkpoint the gates read, so it always reaches the final deny.
3. The epic-planner checkpoint is validated only by Python (`scripts/dev_tools/validate_epic_planner_state.py`) and TypeScript (`extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`). There is no PowerShell validator and no SubagentStop hook that validates this artifact. Both validators ignore unknown top-level keys and unknown per-feature keys, so a new key is tolerated today without any change.
4. On Codex, preparation `features[]` entries already carry `branch_name` and `worktree_path`, and `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (`_is_canonical_worktree_path`) requires `worktree_path` to be a canonical absolute path. A new field must not reuse those names, and the new record must not carry an absolute path.
5. Three hard constraints shape the file layout. `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` caps both Claude gates and the resolution sibling at 500 lines, and the gates are at 469 and 467 lines today. `parallel_orchestrator_surface_expectations.py` pins `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` by hash, so those two files cannot carry the documentation. The epic-plan and epic-planner files are not pinned.
6. A precedent for the reverse decision exists. Issue #995 decision D5, restated in the #1002 research and spec, says "Add no hook allow for scratch worktrees" for the parallel planner. That rule covers improvised, unrecorded planner scratch worktrees. Issue #1161 explicitly asks for an allow for recorded preparation worktrees with verified git state, so the new branch is a deliberate and documented exception for the epic planner only.

## 1. Current Gate Behavior

### Claude epic gate: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`

Decision entry `Invoke-EpicWorktreeRemovalGateDecision`, in order:

1. Dependency failure. `Get-HookDependencyFailureDecision` denies with prefix `EPIC_WORKTREE_REMOVAL_BLOCKED:` when a guarded import or dot-source failed. Guarded edges: `hook-dependency-guard.ps1`, `HookPayload.psm1`, `CleanupWorktreeManifest.psm1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, and `enforce-epic-worktree-removal-gate-resolution.ps1`. The resolution file in turn imports `WorktreeRunRecordPath.psm1` and `WorktreeRunResolution.psm1`.
2. Payload anomaly. `Resolve-ClaudeHookToolInput` fails, and the gate denies with `EPIC_WORKTREE_REMOVAL_BLOCKED: payload anomaly - ...`.
3. No `command` string: the gate allows.
4. Scope filter. `Test-CommandLineInvocation -CommandWord 'git' -SubcommandPath @('worktree','remove')` is false, and the gate allows. The test is structural (issue #545), so `git -C <dir> worktree remove` is in scope and quoted prose is not.
5. Target derivation. `Resolve-CommandLineInvocationTarget`: `NoMatch` allows, any status other than `Targets` denies with `EPIC_WORKTREE_REMOVAL_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: ...`, and every derived target must be authorized on its own (issue #824).
6. Per target, `Get-EpicWorktreeRemovalTargetDenial`:
   - `Read-EpicWorktreeGateRunCheckpoint` (in the resolution file) runs for kind `epic` and kind `parallel`. Each calls `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path -SessionRoot (Get-Location).Path`, which enumerates live worktree roots through `Get-WorktreeItemLiveRoot`, reads each root's `artifacts/orchestration/epic-orchestrator-state.json` or `artifacts/orchestration/parallel-orchestrator-state.json` through `Get-WorktreeRunCheckpointText`, keeps only those whose `route_id` is `epic` or `parallel`, and matches `features[].worktree_path` or `items[].worktree_path` against the target through `Test-WorktreeRunRecordedPathMatchesTarget`. A relative record is joined to the main checkout root and to the checkpoint's own root (issue #995).
   - An `Ambiguous` status for either kind denies with `EPIC_WORKTREE_REMOVAL_BLOCKED: <ReasonCode>: <Detail>`.
   - Epic allow: `Find-EpicWorktreeFeatureRecord` followed by `Test-EpicWorktreeRemovalAllowed` (`merge_status` in `merged` or `worktree_removed`).
   - Parallel allow: `Test-ParallelCheckpointAllowsWorktreeRemoval` (`route_id` is `parallel`, and the matching `items[]` entry has `merge_status` in the allowed set).
   - Manifest allow (issue #635): the target is covered by neither checkpoint (`Test-CleanupManifestCheckpointCoversPath`), and `Test-CleanupWorktreeManifestAuthorizesRemoval` accepts the session-root `artifacts/orchestration/cleanup-worktrees-manifest.json`.
   - Final deny: `EPIC_WORKTREE_REMOVAL_BLOCKED: ` + optional `TARGET_WORKTREE_NOT_DERIVABLE` prefix (when both kinds are `NoTarget`) + fixed sentence + the diagnostics clause from `Get-EpicWorktreeGateDenyDiagnostics` (issues #789 and #851).
7. Entry tail. `Invoke-EpicWorktreeRemovalGateEntryPoint` always returns 0, and a guard failure exits 2.

Read seams (mockable): `Get-EpicWorktreeGateCheckpointContent` and `Get-EpicWorktreeGateParallelCheckpointContent` in the resolution file. The library seams are `Get-WorktreeRunCheckpointText` (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`) and `Get-WorktreeItemLiveRoot` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`).

### Claude parallel gate: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

It has the same structure, with its own seams (`Get-ParallelWorktreeRemovalGateCheckpointContent`, `Get-ParallelWorktreeRemovalGateEpicCheckpointContent`, `Resolve-ParallelWorktreeGateRunTarget`, `Read-ParallelWorktreeGateRunCheckpoint`). The cascade in `Get-ParallelWorktreeRemovalTargetDenial` runs parallel `items[]`, then epic `features[]` (issue #688), then the manifest (exclusion over `items` only). It denies with `PARALLEL_WORKTREE_REMOVAL_BLOCKED: ...` and has no diagnostics clause. It has no pattern for planner or scratch worktrees. #1002 avoided the problem at the instruction level ("No planner worktrees." in `.claude/skills/parallel-plan/SKILL.md`) and changed no hook.

### Codex twin: `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`

This is a separate and simpler implementation, not byte-identical to the Claude gate. It uses the same structural scope filter and target derivation (`hook-command-scanner.ps1`, `hook-command-invocation.ps1`). It reads only `artifacts/orchestration/epic-orchestrator-state.json` at the repository root computed from `$PSScriptRoot` (entry tail), with no worktree resolution and no parallel or manifest branch. The record match is `Find-CodexWorktreeFeature` (full-path normalization against payload `cwd`), and the decision is `Get-CodexWorktreeRemovalTargetDenial`. It denies with `EPIC_WORKTREE_REMOVAL_BLOCKED: '<target>' requires a matching epic feature with merge_status merged or worktree_removed.` `.codex/config.toml` registers only this removal gate. `.codex/hooks/enforce-epic-planning-only.ps1` restricts Bash only when the local orchestrator checkpoint selects `preparation` (preparation children), not the planner.

### Registration and conjunctive behavior

`.claude/settings.json` registers both Claude gates under the Bash PreToolUse matcher, and both must allow. The two promoted records confirm this coupling: `docs/features/potential/promoted/2026-10-08-epic-worktree-removal-gate-denies-merged-parallel-item-worktree.md` (#851) records a case where one gate denied while the other allowed, and #688 added the epic branch to the parallel gate for the same reason.

## 2. Epic-Planner Checkpoint Schema and Validators

- Producer contract: `.claude/agents/epic-planner.md` `## Checkpoint Persistence` (top-level keys and `features[]` keys) and `.claude/skills/epic-plan/SKILL.md` `## Checkpoint Handling`. On Codex: `.agents/skills/epic-plan/SKILL.md` `## Checkpoint and Completion` and `.codex/agents/epic-planner.toml` `## Checkpoint`.
- Python authority: `scripts/dev_tools/validate_epic_planner_state.py`. `REQUIRED_KEYS` and `REQUIRED_FEATURE_KEYS` are presence checks. `validate_epic_planner_state_text` checks `epic_worthiness`, `features` shape, dependency waves, `max_parallel_features`, and the non-epic `next_step`, and checks readiness only under `require_ready_for_execution`. Unknown keys at both levels are ignored. The file has 411 lines. The CLI dispatcher is `scripts/dev_tools/validate_orchestration_artifacts.py` (`epic-planner-state` subparser).
- TypeScript port: `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` (`validateEpicPlannerStateText`, same order and same error strings), dispatched from `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` (`case "epic-planner-state"`). The MCP artifact type `epic-planner-state` is declared in `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, and `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`. No schema change is needed, because the artifact type already exists.
- PowerShell: there is no epic-planner-state validator under `.claude/lib/`. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` names the path only as an exempt bookkeeping write.
- Shared corpora: no corpus exists for epic-planner-state. The Python and TypeScript tests are hand-mirrored (`tests/scripts/dev_tools/test_validate_epic_planner_state*.py` and `extensions/drm-copilot/test/lib/validate/epic-planner-state-*.test.ts`). The precedent for a byte-identical cross-runtime corpus is `tests/fixtures/orchestrator_state_issue_adoption/`, a directory of `{name, notes, checkpoint, expected_errors}` JSON files read by the Python tests and by `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts`.
- Where a new optional key-gated field is validated:
  - Python: extend `validate_epic_planner_state.py` in place with a private `_validate_planner_worktrees(state, indexed_features)`, called inside `validate_epic_planner_state_text` immediately after the `max_parallel_features` check. In-place extension complies with the no-new-Python constraint, and the file stays under 500 lines with about 80 added lines.
  - TypeScript: a new module `extensions/drm-copilot/src/lib/validate/epic-planner-state-planner-worktrees.ts`, called from `validateEpicPlannerStateText` at the same position. The core file has about 496 lines, so in-place growth would cross the 500 guidance tier. The new file needs its own `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs`.
  - Byte-identical strings are pinned by a new corpus `tests/fixtures/epic_planner_state_planner_worktrees/`.

## 3. Where the Epic Planner Creates Worktrees, and the Documentation Surfaces

- Claude: `.claude/skills/epic-plan/SKILL.md` `## Preparation-Mode Child Delegation` launches every child with `isolation: "worktree"` and `run_in_background: true`, branched from `origin/epic/<epic-slug>-integration`. The Claude Code runtime creates these worktrees, and the planner never runs `git worktree add`. `## Fan-In to the Integration Branch` step 4 ("Remove the child worktree once its branch is merged") is the removal the gate denies. `.claude/agents/epic-planner.md` has no worktree text. Its tool list includes `Bash(git *)`, so it can issue the removal.
- Codex: `.agents/skills/epic-plan/SKILL.md` `## Concurrent Preparation` has the planner prepare worktrees and pass `worktree_path` ("<canonical-absolute-path>") and `branch_name` in the launch spec to `.codex/scripts/launch-epic-child-wave.ps1`. `## Fan-In` step 5 is "Remove the worktree only after its preparation branch is merged." `.codex/agents/epic-planner.toml` `## Planning Contract` uses the text "Use isolated worktrees based on the integration branch."
- `.github/` has no epic-plan or epic-planner surface (Glob over `.github` returned only epic-review and epic prompts).
- Bundle mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-planner.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-planner.toml`.
- Gate documentation surfaces (AC4): the comment-based help `.DESCRIPTION` of the three gates. `.claude/skills/epic-orchestrate/SKILL.md` documents the epic gate but is hash-pinned and must not be edited. `.claude/skills/parallel-orchestrate/SKILL.md` (paragraph "**Worktree removal gate.**") and `.claude/rules/parallel-orchestration.md` `## Enforcement` describe the gates' allow branches from the parallel perspective, and the planner should confirm whether their sentences enumerate the allow set exhaustively; if they do, a one-sentence addition keeps them accurate. `.claude/skills/cleanup-merged-worktrees/SKILL.md` `## Sanctioned Removal Manifest` does not change.
- Branch name and path of a Claude runtime isolation worktree: the worktree folder is under `.claude/worktrees/`. The branch name the runtime assigns, and whether the child orchestrator switches branch (this research worktree runs on a feature branch, not a runtime-named branch), are orchestrator to confirm. The design below reads the branch at record time and does not assume a naming scheme.

## 4. Never-Encode-Absolute-Paths Rule and Identity Encoding (AC5)

- Source: the owner's feedback memory `never-encode-absolute-paths-in-artifacts` (2026-09-18) prohibits absolute host paths in prompts, templates, checkpoints, or any persisted artifact. The reasons are host dependence and leaking host data. The memory directs host-independent identity instead: a branch name (git checks a branch out in at most one worktree), an issue number, or runtime payload data. No file under `.claude/` or `.claude/agent-memory/` states the rule. It appears in feature specs (`docs/features/active/2026-11-08-orchestrator-stop-hook-validates-wrong-worktree-checkpoint-1145/spec.md`) and in the execution-environment brief (`## Evidence and Documentation Rules`: "No artifact records an absolute path, a host name, ...").
- Existing runtime resolution by identity:
  - `Resolve-HookTargetWorktree` and `ConvertFrom-HookTargetWorktreePorcelain` in `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, with Codex twin `.codex/hooks/hook-target-worktree.ps1`. These parse `git worktree list --porcelain` through the injectable `WorktreeListInvoker` and map a branch to the one registered root that has it checked out (`TARGET_WORKTREE_NOT_DERIVABLE` for none, `TARGET_WORKTREE_AMBIGUOUS` for more than one).
  - `Get-WorktreeItemLiveRoot -Branch` in `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` enumerates registered roots and filters by checked-out branch by reading git administrative files. It starts no process, and it is already a baseline-mocked seam in the gate suites (`Register-EpicStateBaselineMock` in `session-root-reads-850.Constraints.Tests.ps1` and `hook-dependency-failure.Claude.Tests.ps1`).
  - Relative `worktree_path` records joined to the main checkout root are supported by `Test-WorktreeRunRecordedPathMatchesTarget` and `Test-WorktreeRunRelativeRecordSafe` in `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1`. Blank, `.` or `..` segments, and `:` never match.
- Recommendation: branch name as the identity, plus an optional repository-relative `path`. Absolute paths are rejected by the validators. Details are in D2.

## 5. Determining Committed-and-Pushed, Clean, and In Use

All of these signals are local. None needs network access, and each goes through an injectable seam.

- Branch of the target: `Get-WorktreeItemLiveRoot -SessionRoot <root> -Branch <record.branch>` returns the roots with that branch checked out. Exactly one root, equal to the command target by `Test-WorktreeRunPathEqual`, is required. A detached target therefore never matches, which keeps the issue's detached-HEAD workaround from opening an allow.
- Clean: `git -C <target> status --porcelain=v1 --untracked-files=all` returns empty output with exit 0. Ignored files (for example the child's gitignored `artifacts/orchestration/orchestrator-state.json`) are not reported. `git worktree remove` deletes ignored files without `--force`, which is an accepted, documented consequence. The gate evaluates cleanliness itself, so a `--force` flag cannot bypass it.
- Committed and pushed: read `git -C <target> rev-parse --verify HEAD`, then run `git -C <target> merge-base --is-ancestor <head> refs/remotes/origin/<integration_branch>` (the `integration_branch` of the planner checkpoint) and, if that fails, the same check against `refs/remotes/origin/<record.branch>`. Exit 0 means yes, 1 means no, and any other code or a missing ref denies. This reads remote-tracking refs only. A stale tracking ref makes the check more conservative, not less.
- Still in use (concrete definition; any one condition means in use):
  - U1: the target root equals, or encloses, the session root the gate was given (the caller's own checkout), or equals the root that holds the planner checkpoint.
  - U2: the target is the main checkout root (`Get-WorktreeRunMainCheckoutRoot`).
  - U3: the worktree is locked. The administrative directory named by the target's `.git` file holds a `locked` entry (git's `worktree lock`). Whether the Claude Code runtime locks isolation worktrees while an agent runs is orchestrator to confirm. Either way, the check denies a locked worktree regardless of `-f` flags.
  - U4: the target holds `artifacts/orchestration/orchestrator-state.json` that is unparseable, or whose `next_step` is not exactly `S5_atomic_execution` (the preparation terminal value from `## Child run contract (route_id: preparation)`). In that case a preparation run is still active or halted mid-run. An absent file is not in use.
  - U5: any live root's epic checkpoint (`artifacts/orchestration/epic-orchestrator-state.json`, `route_id` `epic`) records the target through `features[].worktree_path` or records `features[].branch_name` equal to the record's branch. Execution has adopted the worktree, and the existing `merge_status` branch then governs alone.
- Record eligibility (separate from in use): `purpose` is `preparation` and `preparation_status` is `prepared` or `fanned_in`.

## 6. Push-Down Payload Obligations

- Bundle mirrors (byte-identical): every edited or new file under `.claude/hooks/`, `.codex/hooks/`, `.claude/skills/epic-plan/`, `.claude/agents/epic-planner.md`, `.agents/skills/epic-plan/`, and `.codex/agents/epic-planner.toml`, under `extensions/drm-copilot/resources/claude-customizations/` or `extensions/drm-copilot/resources/codex-and-agents-customizations/`.
- Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` already lists both Claude gates and `enforce-epic-worktree-removal-gate-resolution.ps1`. New Claude hook files must be added there. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists the Codex gate and `hook-epic-fan-in.ps1`. A new Codex helper must be added there, and `scripts/dev_tools/generate_codex_agent_variants.py --check` (module form) must pass afterwards, because that generator owns the agent entries of the Codex `core.json`.
- Contract tests to run (from the execution-environment brief `## Contract Tests That Pin Mirrored Files`): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py` (a new `$PSScriptRoot` dot-source dependency of a gate must be in core), the Codex generator check, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (guarded dot-source pattern). Also run `test_epic_skill_script_citations_shipped.py`, `test_single_pass_preflight_contracts.py`, `test_push_down_codex_and_agents_customizations.py`, `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`, and `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`, all of which read the epic-plan or epic-planner surfaces.
- Frozen hashes: `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` pins only `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`. The epic-plan and epic-planner files are not pinned. The two pinned files must not be edited.
- Byte-identity pin for a twin helper: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` pins `hook-epic-fan-in.ps1`, and the new twin helper needs the same pin.
- The execution-environment brief states no allow condition of the removal gates (its Command-Text Restrictions line about the parallel gate concerns command text only), so no brief update is required. Preflight should re-confirm this against the brief.

## 7. Existing Tests and Dispositions

| Test | Disposition |
| --- | --- |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` | Unchanged (500-line cap in the #850 constraints suite); must still pass |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1` | Unchanged; it asserts the exact `Get-EpicWorktreeGateDenyDiagnostics` clause, so that function must not change |
| `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`, `.Issue824.Tests.ps1`, `.RelativeRecord.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1` | Unchanged; deny texts stay byte-identical when no planner record matches |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, `.EpicAuthorization.Tests.ps1`, `.Issue824.Tests.ps1`, `.RelativeRecord.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.WorktreeResolution.Tests.ps1` | Unchanged |
| `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1`, `-issue824.Tests.ps1`, `-trigger-scoping.Tests.ps1`, `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` (dot-sources the Codex gate) | Unchanged; the gate must still dot-source cleanly |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | Unchanged; they discover the new guarded edges from the AST automatically |
| `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` | Unchanged; enforces the 500-line cap on both Claude gates and the resolution sibling |
| `tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1`, `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1` | Unchanged; they drive the gates, and the manifest branch order is preserved |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | Updated: add a byte-identity pin for the new twin helper |
| `tests/scripts/dev_tools/test_validate_epic_planner_state.py`, `_shape_errors.py`, `_feature_receipts.py`, `_feature_indices.py`, `_launch_binding.py`, `test_epic_planner_readiness.py`, `test_epic_planner_readiness_edges.py` | Unchanged; the key is absent in their inputs |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts` and its siblings for shape errors, feature receipts, feature indices, launch binding, wave rethrow, and readiness | Unchanged |

New tests:

- `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1`: pure helper.
- `tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1`: Claude adapter with mocked seams.
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.PlannerWorktree.Tests.ps1` and `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.PlannerWorktree.Tests.ps1`: gate-level allow, dirty, unrecorded, in-use, not pushed, and status not eligible.
- `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-planner-worktree.Tests.ps1`.
- `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py`: corpus-driven. It is a test file and is not pushed down. Whether the owner's no-new-Python constraint also covers test modules is orchestrator to confirm. The fallback is to append the cases to `tests/scripts/dev_tools/test_validate_epic_planner_state.py`.
- `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts`: corpus parity.
- Corpus `tests/fixtures/epic_planner_state_planner_worktrees/`.

## 8. Concurrent Sibling Items

The sibling feature folders are not present on this branch. Their scope is inferred from their titles and is orchestrator to confirm.

- #1159 single hook dispatcher: this item has the highest structural overlap. A dispatcher would change `.claude/settings.json` and `.codex/config.toml` registrations and possibly the entry tails of the gates. Mitigation: add no registration and no settings change, and keep each gate edit to one guarded dot-source line plus one call in the per-target cascade. The helper loads relative to `$PSScriptRoot`, so it keeps working whether the gates are invoked directly or by a dispatcher. Either merge order is correct, and only small textual conflicts in the gate bodies are possible.
- #1163 isolated worktrees and session-root resolution in hooks: likely touches `(Get-Location).Path` use in both gates, in `enforce-epic-worktree-removal-gate-resolution.ps1`, and in `HookTargetWorktree.psm1`. Mitigation: the planner adapter takes `-SessionRoot` from the gate and never calls `Get-Location` itself, so whichever session-root derivation lands governs the planner branch too. If #1163 lands first, this item passes the new root at its single call site. If this item lands first, #1163 updates one more call site.
- #1162 cross-epic dependencies: this is the likely overlap on `scripts/dev_tools/validate_epic_planner_state.py`, `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`, `.claude/skills/epic-plan/SKILL.md`, and `.claude/agents/epic-planner.md`. Mitigation: put the TypeScript rules in a new module, add a single private function plus one call line in Python, and put the skill text in a new section instead of rewriting shared sections. The only shared-section edits are `## Fan-In to the Integration Branch` step 4 and the `## Checkpoint Persistence` key list.
- #1157 owner directives reach agents: possible overlap on `.claude/agents/epic-planner.md` and its mirror. Edits are confined to `## Checkpoint Persistence` and `## Completion Requirements`.
- #1156 lighter integration-merge path: possible overlap on `## Fan-In to the Integration Branch` in the epic-plan skill. Limit the edit to step 4.
- #1158 test-execution policy and #1160 preimplementation gate false positives: no expected file overlap. Writes to `artifacts/orchestration/epic-planner-state.json` are already exempt bookkeeping.

## Candidate Approaches

1. Selected: record and verify. The planner records each preparation worktree in a key-gated `planner_worktrees` array. A byte-identical pure decision helper plus thin per-runtime adapters let all three gates allow a recorded, eligible, clean, pushed, not-in-use worktree.
2. Rejected: remove step 4 and rely on the runtime sweep. Claude Code removes clean, pushed isolation worktrees on its own (per the #1002 spec). This does not meet AC1 or AC2, and it does not cover the Codex launcher worktrees.
3. Rejected: route through the cleanup manifest. The manifest accepts only triage verdicts written by the `cleanup-merged-worktrees` skill and is session-root-only (research #1002). Requiring a cleanup run for every fan-in is heavier and unrelated to planning state.
4. Rejected: add the field to `features[]` (`worktree_path` or `branch_name`). Those names collide with the Codex launch-binding rules that require absolute paths, and one feature can have more than one preparation worktree after a re-plan.

## Design Decisions

D1. Field name and shape.
Options: per-feature fields; a top-level array.
Recommendation: a top-level optional array `planner_worktrees` in `artifacts/orchestration/epic-planner-state.json`. Each entry is an object:
- `branch` (required): the identity.
- `path` (optional): repository-relative to the main checkout.
- `purpose` (required).
- `preparation_status` (required).
- `feature_folder` (required): must equal some `features[].feature_folder`.
- `recorded_at` (optional): an ISO-8601 UTC string, validated for presence and type only.
The key is not added to `REQUIRED_KEYS`.

D2. Identity encoding (AC5).
Options: absolute path; repository-relative path; branch name.
Recommendation: the branch name is the authoritative identity. The gate resolves it at runtime to the single live root with that branch checked out (`Get-WorktreeItemLiveRoot -Branch` on Claude, `ConvertFrom-HookTargetWorktreePorcelain` on Codex) and requires that root to equal the command target. `path` is optional, repository-relative only, and when present must also match through `Test-WorktreeRunRecordedPathMatchesTarget` with the main checkout as base root. Validators reject a drive, a leading slash or backslash, any backslash, `:`, and `.` or `..` segments. A detached worktree never matches. Record this decision in the spec as the AC5 decision.

D3. Purpose and preparation-status vocabulary.
Recommendation: `purpose` is the closed set {`preparation`}, kept as a field so that later purposes are additive. `preparation_status` is the closed set {`preparing`, `prepared`, `fanned_in`, `removed`, `abandoned`}. Only `prepared` and `fanned_in` are gate-eligible. Comparisons are ordinal and case-sensitive.

D4. Committed and pushed.
Recommendation: the worktree `HEAD` commit is an ancestor of, or equal to, `refs/remotes/origin/<integration_branch>` (from the same planner checkpoint) or `refs/remotes/origin/<branch>`, through `git merge-base --is-ancestor`. The check reads local refs only and never fetches. Any git failure denies.

D5. Clean.
Recommendation: `git status --porcelain=v1 --untracked-files=all` in the target returns exit 0 with empty output. Ignored files do not count, and the spec states that ignored files are deleted by the removal. The check runs regardless of `--force`.

D6. In use.
Recommendation: the in-use conditions are U1 to U5 in section 5: session-root containment or planner-checkpoint root, main checkout, git `locked` entry, a non-terminal or unparseable preparation checkpoint in the target, and epic-execution adoption. Each has its own deny sub-code.

D7. Where the allow branch lives.
Options: inline in each gate; a new `.claude/lib` module; dot-sourced hook-folder files.
Recommendation:
- (a) A byte-identical pure helper `hook-planner-worktree-removal.ps1` in `.claude/hooks/` and `.codex/hooks/`, following the `hook-epic-fan-in.ps1` precedent. It holds record parsing, eligibility, and the decision function `Get-PlannerWorktreeRemovalDecision` over already-collected facts. It does no I/O, sets no StrictMode, and makes no preference assignment.
- (b) A Claude-only adapter `.claude/hooks/enforce-worktree-removal-gate-planner.ps1`. It collects the facts through existing seams (`Get-WorktreeItemLiveRoot`, `Get-WorktreeRunCheckpointText`, `Get-WorktreeRunMainCheckoutRoot`) and one new wrapper `Invoke-PlannerWorktreeGitExe -GitArgs`. It exposes `Get-PlannerWorktreeRemovalTargetDecision -WorktreePath -SessionRoot`.
- (c) The Codex adapter functions go into `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` (191 lines today), or into a Codex sibling file if they exceed about 80 lines.
Each gate adds one guarded dot-source and one call. Both Claude gates stay at or below 500 lines. The gates remain standalone hooks with unchanged registrations.

D8. Cascade position and deny text.
Recommendation: the planner check runs after the epic and parallel checkpoint allows and before the manifest branch, in both Claude gates and after the epic check in the Codex gate. Manifest exclusion semantics do not change. When no planner record names the target's branch, every deny text stays byte-identical. When a record matches and is refused, the gate appends one sentence after the existing text (after the diagnostics clause on the epic gate) of the form `Planner worktree: PLANNER_WORKTREE_<CODE>: <detail>.`. The codes are `NOT_ELIGIBLE`, `DIRTY`, `NOT_PUSHED`, `IN_USE`, `AMBIGUOUS` (the branch is recorded by more than one planner checkpoint or checked out in more than one root), and `GIT_FAILED`. `Get-EpicWorktreeGateDenyDiagnostics` is not changed, and the gate token still appears once.

D9. Planner checkpoint discovery.
Recommendation: on Claude, read `artifacts/orchestration/epic-planner-state.json` beneath every live root through `Get-WorktreeRunCheckpointText`. The adapter composes the path with the shared join, because `Get-WorktreeRunCheckpointPath` supports only `epic`, `parallel`, and `item`. Collect the checkpoints whose `planner_worktrees` name the branch. Zero means no planner authorization. More than one denies with `AMBIGUOUS`. On Codex, read the same relative path at the repository root used by the existing Codex read. Reusing baseline-mocked seams keeps every existing gate suite deterministic without new isolation registrations.

D10. Claude and Codex parity.
Recommendation: all three gates gain the branch. The pure helper is byte-identical and pinned, and the adapters differ only in I/O. Codex documentation (`.agents/skills/epic-plan/SKILL.md` and `.codex/agents/epic-planner.toml`) instructs recording `planner_worktrees` with branch identity and a relative path. The existing absolute `features[].worktree_path` requirement of the Codex launch binding is a pre-existing deviation from the never-encode rule. It is out of scope here and is reported to the orchestrator for a decision rather than changed.

D11. Validators and strictness.
Recommendation: Python (in place) and TypeScript (new module) validate `planner_worktrees` only when the key is present, in plain validation and not only under readiness. Readiness is not changed. Errors are byte-identical, 0-based like the existing `features[{index}]`, and appended after the `max_parallel_features` check, in this order per entry:
- `Epic planner checkpoint planner_worktrees must be a list when present.` (when this fires, nothing further is checked)
- `Epic planner checkpoint planner_worktrees[N] must be an object.`
- `Epic planner checkpoint planner_worktrees[N].branch must be a non-empty branch name.` (pattern `^[A-Za-z0-9][A-Za-z0-9._/-]*$`, no `..`, not ending in `/`, `.`, or `.lock`)
- `Epic planner checkpoint planner_worktrees[N].branch must be unique: <branch>.`
- `Epic planner checkpoint planner_worktrees[N].path must be a repository-relative path without a drive, a leading slash, a backslash, or dot segments.`
- `Epic planner checkpoint planner_worktrees[N].purpose must be preparation.`
- `Epic planner checkpoint planner_worktrees[N].preparation_status must be one of: preparing, prepared, fanned_in, removed, abandoned.`
- `Epic planner checkpoint planner_worktrees[N].feature_folder must name a features[] feature_folder.`
- `Epic planner checkpoint planner_worktrees[N].recorded_at must be a non-empty string when present.`
No PowerShell validator is added. The gate parses tolerantly, and a malformed entry never authorizes. Installed MCP ignores the key until the release that carries the TypeScript rule, so there is no false rejection in the interim.

D12. Recording protocol (skill and agent text, AC4).
Recommendation: a new section `## Preparation Worktree Records` in `.claude/skills/epic-plan/SKILL.md` and `.agents/skills/epic-plan/SKILL.md`:
- When a preparation child completes, the planner reads the child worktree's branch (from the completion notification or `git worktree list --porcelain`; the notification field names are orchestrator to confirm) and appends an entry with `preparation_status: prepared`.
- It sets `fanned_in` after the merge into the integration branch and the push, removes the worktree with a plain `git worktree remove <path>` in its own Bash call without `--force`, and then sets `removed`.
- On a planner-gate deny, it records the deny code and leaves the worktree. It never detaches HEAD to free a branch.
Fan-In step 4 (Claude) and step 5 (Codex) point to the section. `.claude/agents/epic-planner.md` `## Checkpoint Persistence` and `.codex/agents/epic-planner.toml` `## Checkpoint` list `planner_worktrees`. The three gates' `.DESCRIPTION` blocks document the branch and its honest disclosure.

D13. Parallel planner scope.
Recommendation: not extended. The parallel planner creates no worktrees since #1002, and its children's isolation worktrees are runtime-managed. The parallel removal gate is changed only as a conjunctive consumer of the epic-planner branch, and the parallel-planner checkpoint is not read. The issue scope (epic planner) is not reduced.

D14. Config knobs.
Recommendation: no new knob. The branch is inert unless a planner checkpoint carries `planner_worktrees` naming the target's branch. No checkpoint carries the key today, so today's behavior is the default without configuration.

D15. Honest disclosure.
Recommendation: state in the gate help and the skill that this is a policy-level control, not a security control. A same-session writer can author a record. The git checks bound the harm to removing a clean worktree whose commits are already on the remote. Removal of ignored files is accepted.

## Requirements Mapping

| AC | Design |
| --- | --- |
| AC1 checkpoint records and validators | D1, D3, D11, D12 |
| AC2 gate allows recorded, committed, pushed, and clean | D4 to D10 |
| AC3 tests for allowed, dirty, unrecorded, and in use | Section 7 new suites, one case per U1 to U5, plus not-pushed and not-eligible |
| AC4 documentation | D12 and the gate `.DESCRIPTION` blocks; pinned epic-orchestrate files untouched |
| AC5 no absolute paths | D2, plus the D11 path rule and corpus rows that reject a drive and a leading slash |

## Testing Implications

- The pure helper is tested with in-memory fact objects. The adapters are tested by mocking `Get-WorktreeItemLiveRoot`, `Get-WorktreeRunCheckpointText`, `Get-WorktreeRunMainCheckoutRoot`, and `Invoke-PlannerWorktreeGitExe` (mock signature `param([string[]]$GitArgs)`). Tests use no temporary files, no wall clock, and no live git.
- Fixture roots are synthetic, use forward slashes, carry no drive letter on the Linux hook-suite job, and contain no host path.
- Gates: one Pester run through `Invoke-PoshQCParallelTest`. Validators: one `pytest -n auto` run and the normal Jest workers. Focused runs are for debugging only.
- Coverage: each new PowerShell file has at least 85% line coverage. The TypeScript module needs at least 85% line and 75% branch coverage with its own `coverageThreshold` entry. Changed Python lines need at least 85% line and 75% branch coverage, read from the JSON report with `--cov=scripts.dev_tools.validate_epic_planner_state`.
- Fail-before: the new gate suites' allow cases fail before the change (deny today). Record them under `evidence/regression-testing/` with `ExpectedExitCode`.

## Numeric Derivation Evidence

Claim: the number of hooks that intercept `git worktree remove` and must consult the planner branch (two Claude, one Codex). This supports the D7 and D8 file set, not an AC count.

- Complete Family: PreToolUse hooks in `.claude/hooks/` and `.codex/hooks/` that act on a structural `git worktree remove` invocation.
- Exhaustive Search Scope: `.claude/settings.json`, `.codex/config.toml`, and every `.ps1` file directly under `.claude/hooks/` and `.codex/hooks/`.
- Inclusion Rules: a hook registered for Bash whose decision depends on a `worktree remove` subcommand path.
- Exclusion Rules: hooks that mention `worktree_removed` only as a merge-status literal (`enforce-orchestration-preimplementation-gate-modes.ps1`, `hook-epic-fan-in.ps1`, and the barrier hooks); helpers that are not registered (`hook-command-invocation.ps1`).
- Primary Search Strategy or Query Expression: Grep `worktree-removal` in `.claude/settings.json` and `.codex/config.toml` (registration lines).
- Primary Member Set: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.
- Primary Count: 3
- Cross-check Search Strategy or Query Expression: Grep `SubcommandPath @\('worktree', 'remove'\)` over `.ps1` files in `.claude/hooks/` and `.codex/hooks/`.
- Cross-check Member Set: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`.
- Cross-check Count: 3
- Member-set Comparison: identical normalized sets.

No numeric acceptance criterion is proposed for `spec.md`.

## Pre-Mortem

- Review checklists: reviewers may flag a hook allow that bypasses the #995 D5 "no hook allow for scratch worktrees" rule, or an unverified write of identity data. Mitigation: the spec records D13, D15, and the AC5 decision explicitly, and the allow requires a recorded branch plus the D4 to D6 git checks.
- Coverage: the adapter's git-failure and locked-worktree branches are easy to leave unexercised, which drops the new PowerShell file below 85% line coverage. The TypeScript module fails Jest if its `coverageThreshold` entry is missing. Mitigation: the plan lists one test per deny sub-code and adds the Jest threshold entry in the same task as the module.
- Mirror parity: about ten bundle copies, two pack manifests, the Codex generator check, and the new twin-helper pin in `legacy-codex-hook-contracts.Tests.ps1` must all move together. Mitigation: a final mirror task runs every contract test in section 6. `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` stay untouched (frozen hashes).
- File size: both Claude gates are within 33 lines of the 500-line cap enforced by `session-root-reads-850.Constraints.Tests.ps1`. Mitigation: gate edits are limited to a guarded dot-source and one call, and all logic lives in the helper and adapter. The plan records before and after line counts.
- Test isolation: existing gate suites now reach the planner branch on every deny path. Unmocked reads would touch real worktrees and the real planner checkpoint, and an unmocked git wrapper would start processes. Mitigation: the planner branch reads only through the already baseline-mocked seams, and git runs only after a record matches, which never happens under the baseline mocks. New suites mock `Invoke-PlannerWorktreeGitExe` and restore every script-scope variable. `Invoke-PoshQCLeakScan` must pass.
- CI-only behavior: the Linux hook-suite job is case-sensitive and has no drive letters, and `.gitattributes` normalizes line endings. A fixture with a drive-rooted target or a backslash path passes on Windows and fails on Linux. Mitigation: synthetic POSIX roots in Linux-run suites, `Join-Path`, and no CRLF fixtures. The validator corpus carries no absolute paths, except in the rejection rows, which use a drive-only token the rule rejects without any path join.
- Evidence: behavior of a branch hook cannot be shown by an isolated subagent run, because hooks run from `main`'s copies. Mitigation: AC2 and AC3 evidence comes from the Pester gate run, not a live planner run. Evidence files are append-only and stamped at write time, with `SCRATCH` for scratch paths and no absolute paths.

## Open Items for the Orchestrator

- Confirm the branch name the Claude Code runtime assigns to an `isolation: "worktree"` child, whether the preparation child switches branch, and which completion-notification fields carry the worktree path and branch.
- Confirm whether the runtime locks isolation worktrees while an agent runs (U3).
- Confirm the scope of siblings #1156 to #1163 against their feature folders on their branches.
- Decide whether the pre-existing absolute `features[].worktree_path` requirement in the Codex launch binding needs a remediation item (D10).
