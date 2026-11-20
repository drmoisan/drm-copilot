# Hook Parity Dispositions — Issue #1030

- **Issue:** #1030 (epic #1018, child 5)
- **Decision reference:** `#1030:hook-parity-dispositions.md` (the `decision_ref` of every `hook-registration` entry of `config/harness-parity-matrix.json`)
- **Decision status:** provisional until the owner approves; every `hook-registration` entry records `decision_status: provisional`.
- **Requirements:** `spec.md` version 0.4 (`## Decisions` AD-1 to AD-6 and AD-8), `research/research.2026-10-30T22-59.md` (`## 3. Function-Level Parity Table`, `## 4. Drift Between Paired Claude and Codex Implementations`).
- **Gate:** `tests/scripts/harness/HarnessHookParity.RepoGate.Tests.ps1` applies rules H1 to H5 of `scripts/harness/HarnessHookParity.psm1` to the committed matrix.

Every `hook-registration` entry keeps `disposition: native` (spec OQ-1). A `parity_group` with members in more than one ecosystem is a shared function. A Claude group without a Codex member carries a gap class in `notes` (`GAP:NOT-APPLICABLE: `, `GAP:NOT-EXPRESSIBLE: ` or `GAP:DEFER: `), and a Codex group without a Claude member carries `CODEX-NATIVE: ` (spec OQ-2, notes form). Divergence notes carry no gap prefix. Copilot entries from `.github/hooks/discovery.json` record `owner_child: 6`; child 5 records them only.

## Hook Groups

### hook:check-powershell-test-purity

- Members:
  - claude: `PreToolUse/Write|Edit/check-powershell-test-purity` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/2`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/check-powershell-test-purity` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/2`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:check-python-test-purity

- Members:
  - claude: `PreToolUse/Write|Edit/check-python-test-purity` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/0`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/check-python-test-purity` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/0`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:discovery-stop

- Members:
  - claude: `SubagentStop/atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|csharp-typed-engineer|typescript-engineer|orchestrator|epic-orchestrator|epic-planner/validate-discovery-artifact-gate` (`.claude/settings.json`, `/hooks/SubagentStop/0/hooks/0`)
  - claude: `SubagentStop/legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer/validate-discovery-artifact-gate` (`.claude/settings.json`, `/hooks/SubagentStop/1/hooks/0`)
  - codex: `SubagentStop/legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer/validate-discovery-agent-output` (`.codex/config.toml`, `[[hooks.SubagentStop]]`)
  - copilot: `SubagentStop//discovery-agent-stop` (`.github/hooks/discovery.json`, `/hooks/SubagentStop/0`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member, and a Copilot member).
- Divergence notes: none.

### hook:enforce-checkpoint-monotonic

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-checkpoint-monotonic` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/8`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/enforce-checkpoint-monotonic` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/7`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-completion-consistency

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-completion-consistency` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/9`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/enforce-completion-consistency` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/8`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-discovery-artifact-gate

- Members:
  - claude: `PreToolUse/Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*/enforce-discovery-artifact-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/0`)
  - codex: `PreToolUse/^(Agent|Task|spawn_agent|run_subagent|delegate)$/enforce-discovery-artifact-gate` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/0`)
  - codex: `PreToolUse/^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$/enforce-discovery-artifact-gate` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/0`)
  - copilot: `PreToolUse//discovery-pre-tool` (`.github/hooks/discovery.json`, `/hooks/PreToolUse/0`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member, and a Copilot member).
- Divergence notes: none.

### hook:enforce-discovery-planning-gate

- Members:
  - claude: `PreToolUse/Agent/enforce-discovery-planning-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/1`)
  - codex: `PreToolUse/^(Agent|Task|spawn_agent|run_subagent|delegate)$/enforce-discovery-planning-gate` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/1`)
  - copilot: `PreToolUse//discovery-planning` (`.github/hooks/discovery.json`, `/hooks/PreToolUse/1`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member, and a Copilot member).
- Divergence notes: none.

### hook:enforce-docs-complete-gate

- Members:
  - claude: `PreToolUse/Bash/enforce-docs-complete-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/5`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/docs/DocsCompleteGate.psm1, .claude/lib/hook-payload/HookPayload.psm1 and .claude/lib/worktree-resolution/AgentTargetWorktree.psm1; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3).
- Divergence notes: none.

### hook:enforce-docs-role-write-scope

- Members:
  - claude: `PreToolUse/Write|Edit|MultiEdit|NotebookEdit|Bash/enforce-docs-role-write-scope` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/5/hooks/0`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/hook-payload/HookPayload.psm1; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3).
- Divergence notes: none.

### hook:enforce-epic-child-worktree-binding

- Members:
  - codex: `PreToolUse/^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$/enforce-epic-child-worktree-binding` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/5`)
- Research label: CODEX-NATIVE
- Gap class: `CODEX-NATIVE`. Reason: Claude binds epic children to their item worktrees through agent isolation worktrees; Codex launches children through .codex/scripts/launch-epic-child-wave.ps1 and expresses the binding as a hook (research section 3).
- Divergence notes: none.

### hook:enforce-epic-merge-gate

- Members:
  - claude: `PreToolUse/Bash/enforce-epic-merge-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/4`)
  - codex: `PreToolUse/^Bash$/enforce-epic-merge-gate` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/3`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-epic-planning-only

- Members:
  - codex: `PreToolUse/^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$/enforce-epic-planning-only` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/3`)
- Research label: CODEX-NATIVE
- Gap class: `CODEX-NATIVE`. Reason: Claude bounds the epic planner through the agent tools: allowlist; Codex has no per-agent tool allowlist and expresses the planning-only boundary as a hook (research section 3).
- Divergence notes: none.

### hook:enforce-epic-wave-barrier

- Members:
  - claude: `PreToolUse/Agent/enforce-epic-wave-barrier` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/3`)
  - codex: `PreToolUse/^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$/enforce-epic-wave-barrier` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/4`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-epic-worktree-removal-gate

- Members:
  - claude: `PreToolUse/Bash/enforce-epic-worktree-removal-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/6`)
  - codex: `PreToolUse/^Bash$/enforce-epic-worktree-removal-gate` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/4`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-evidence-locations

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-evidence-locations` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/4`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/enforce-evidence-locations` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/4`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: claude: Divergence (research section 4): the Claude copy adds a payload-anomaly deny path (Get-EvidenceLocationAnomalyDecision), and the block text differs only in the skill-pointer path (.claude/skills versus .agents/skills). codex: Divergence (research section 4): the Claude copy adds a payload-anomaly deny path (Get-EvidenceLocationAnomalyDecision), and the block text differs only in the skill-pointer path (.claude/skills versus .agents/skills)..

### hook:enforce-feature-folder-order

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-feature-folder-order` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/7`)
- Research label: DEFER (research label ADD, amended by AD-8)
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/development-docs/DevelopmentDocsRoot.psm1 (the #1035 resolver; Test-IsFeaturePlanPath calls Get-DevelopmentDocsKnownRootPattern), which is not published to .codex/lib; the port is deferred to child 4 (spec AD-8, OQ-3).
- Divergence notes: none.
- AD-8 deferral: the Codex `enforce-feature-folder-order.ps1` port is deferred (spec AD-8). The Claude source imports `.claude/lib/development-docs/DevelopmentDocsRoot.psm1` (child 2, #1035), which is not published to `.codex/lib`; the group has a Claude member only, and no Codex file, bundle copy, dispatch-registry entry or dispatcher `timeout` change is produced.
- Phase 0 check (c), quoted from `evidence/baseline/phase0-gate.2026-11-18T07-55.md`:
  - `FFO-RESOLVER: hook-dependency-guard.ps1, ../lib/hook-payload/HookPayload.psm1, ../lib/development-docs/DevelopmentDocsRoot.psm1, feature-folder-resolution.ps1; Test-IsFeaturePlanPath calls Get-DevelopmentDocsKnownRootPattern`
  - `CODEX-LIB-DEVDOCS: ABSENT`

### hook:enforce-file-size-limit

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-file-size-limit` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/5`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/enforce-file-size-limit` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/5`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-mermaid-validation

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-mermaid-validation` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/10`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source needs .claude/lib/mermaid/MermaidValidation.psm1 and .claude/lib/hook-payload/HookPayload.psm1, and Codex has no mermaid-diagram skill; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3).
- Divergence notes: none.

### hook:enforce-orchestration-preimplementation-gate

- Members:
  - claude: `PreToolUse/Bash/enforce-orchestration-preimplementation-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/3`)
  - claude: `PreToolUse/Write|Edit/enforce-orchestration-preimplementation-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/6`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/enforce-orchestration-preimplementation-gate` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/6`)
  - codex: `PreToolUse/^Bash$/enforce-orchestration-preimplementation-gate` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/2`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-owner-directive-pass-down

- Members:
  - claude: `PreToolUse/Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|mcp__.*/enforce-owner-directive-pass-down` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/6/hooks/0`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1, .claude/lib/worktree-resolution and .claude/lib/hook-payload modules; .claude/rules/orchestrator-state.md records the pass-down hook as Claude only; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3).
- Divergence notes: none.

### hook:enforce-parallel-abandon-gate

- Members:
  - claude: `PreToolUse/Bash/enforce-parallel-abandon-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/8`)
- Research label: NOT-APPLICABLE
- Gap class: `NOT-APPLICABLE`. Reason: no parallel orchestration surface exists in Codex (no parallel-* skill under .agents/skills and no parallel-* base agent under .codex/agents), research section 3.
- Divergence notes: none.

### hook:enforce-parallel-cohort-barrier

- Members:
  - claude: `PreToolUse/Agent/enforce-parallel-cohort-barrier` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/6`)
- Research label: NOT-APPLICABLE
- Gap class: `NOT-APPLICABLE`. Reason: no parallel orchestration surface exists in Codex (no parallel-* skill under .agents/skills and no parallel-* base agent under .codex/agents), research section 3.
- Divergence notes: none.

### hook:enforce-parallel-drift-gate

- Members:
  - claude: `PreToolUse/Agent/enforce-parallel-drift-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/7`)
- Research label: NOT-APPLICABLE
- Gap class: `NOT-APPLICABLE`. Reason: no parallel orchestration surface exists in Codex (no parallel-* skill under .agents/skills and no parallel-* base agent under .codex/agents), research section 3.
- Divergence notes: none.

### hook:enforce-parallel-worktree-removal-gate

- Members:
  - claude: `PreToolUse/Bash/enforce-parallel-worktree-removal-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/7`)
- Research label: NOT-APPLICABLE
- Gap class: `NOT-APPLICABLE`. Reason: no parallel orchestration surface exists in Codex (no parallel-* skill under .agents/skills and no parallel-* base agent under .codex/agents), research section 3.
- Divergence notes: none.

### hook:enforce-powershell-batch-budget

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-powershell-batch-budget` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/3`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/enforce-powershell-batch-budget` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/3`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-pr-author-skill

- Members:
  - claude: `PreToolUse/Bash/enforce-pr-author-skill` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/2`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/orchestrator-state/OrchestratorState.psm1 and .claude/lib/hook-payload/HookPayload.psm1, and Codex PR authoring uses its own receipts; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3) (spec OQ-8).
- Divergence notes: none.

### hook:enforce-prd-feature-before-planner

- Members:
  - claude: `PreToolUse/Agent/enforce-prd-feature-before-planner` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/0`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1, WorktreeItemResolution.psm1 and .claude/lib/hook-payload/HookPayload.psm1; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3).
- Divergence notes: none.

### hook:enforce-promotion-mcp-only

- Members:
  - claude: `PreToolUse/Bash/enforce-promotion-mcp-only` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/1`)
  - codex: `PreToolUse/^Bash$/enforce-promotion-mcp-only` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/1`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-python-batch-budget

- Members:
  - claude: `PreToolUse/Write|Edit/enforce-python-batch-budget` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/1`)
  - codex: `PreToolUse/^(apply_patch|Edit|Write)$/enforce-python-batch-budget` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/3/hooks/1`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-test-execution-policy

- Members:
  - claude: `PreToolUse/Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite/enforce-test-execution-policy` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/1/hooks/0`)
  - codex: `PreToolUse/^(Bash|mcp__drm-copilot__run_poshqc_test|mcp__drm-copilot__run_poshqc_suite)$/enforce-test-execution-policy` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/1/hooks/0`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:enforce-worktree-poetry-venv

- Members:
  - claude: `PreToolUse/Bash/enforce-worktree-poetry-venv` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/9`)
  - codex: `PreToolUse/^Bash$/enforce-worktree-poetry-venv` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/5`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:epic-invocation-origin

- Members:
  - claude: `PreToolUse/Agent/enforce-epic-invocation-origin` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/5`)
  - codex: `PreToolUse/^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$/enforce-epic-root-invocation` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/1`)
  - codex: `UserPromptSubmit//authorize-root-epic-invocation` (`.codex/config.toml`, `[[hooks.UserPromptSubmit]]`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:invoke-pretooluse-dispatch

- Members:
  - claude: `PreToolUse/Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*/invoke-pretooluse-dispatch` (`.claude/settings.json`, `/hooks/PreToolUse/0/hooks/0`)
  - codex: `PreToolUse/^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*|Agent|Task|spawn_agent|run_subagent|delegate)$/invoke-pretooluse-dispatch` (`.codex/config.toml`, `[[hooks.PreToolUse]]`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:model-routing

- Members:
  - claude: `PreToolUse/Agent/enforce-model-routing-receipt` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/4`)
  - codex: `PreToolUse/^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$/enforce-codex-model-routing` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/2/hooks/2`)
  - codex: `SubagentStop/epic-planner|epic-orchestrator|orchestrator|atomic-planner|atomic-executor|feature-review|feature-reviewer|task-researcher|prd-feature|pr-author|typed-engineer|-c|legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer/validate-codex-subagent-routing` (`.codex/config.toml`, `[[hooks.SubagentStop]]`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:persist-session-id

- Members:
  - claude: `SessionStart//persist-session-id` (`.claude/settings.json`, `/hooks/SessionStart/0/hooks/0`)
- Research label: NOT-APPLICABLE
- Gap class: `NOT-APPLICABLE`. Reason: the consumer skill identify-session-id exists only under .claude/skills, so Codex has no consumer of a persisted session id (research section 3).
- Divergence notes: none.

### hook:pr-author-command-allowlist

- Members:
  - claude: `PreToolUse/Bash/enforce-pr-author-command-allowlist` (`.claude/agents/pr-author.md`)
- Research label: DEFER (research label ADD-CONDITIONAL, settled by AD-3)
- Gap class: `DEFER`. Reason: per-agent scoping needs the agent_type field in Codex subagent PreToolUse payloads, and no recorded verification shows that Codex carries it (spec AD-3, C2).
- Divergence notes: none.

### hook:preimplementation-gate-delegation

- Members:
  - claude: `PreToolUse/Agent/enforce-orchestration-preimplementation-gate` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/4/hooks/2`)
- Research label: NOT-EXPRESSIBLE (research label ADD-CONDITIONAL, settled by AD-3)
- Gap class: `NOT-EXPRESSIBLE`. Reason: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 routes tool_input only for Bash and apply_patch and maps every other tool name through ConvertTo-CodexFileEditInput, so the delegation tool names cannot be gated without editing that file, which is at its 500-line Codex cap; the gap is owned by issue #555 (spec AD-3, C1).
- Divergence notes: none.

### hook:subagent-start-attestation

- Members:
  - claude: `SubagentStart/legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer/record-discovery-agent-start` (`.claude/settings.json`, `/hooks/SubagentStart/0/hooks/0`)
  - codex: `SubagentStart/epic-planner|epic-orchestrator|orchestrator|atomic-planner|atomic-executor|feature-review|feature-reviewer|task-researcher|prd-feature|pr-author|typed-engineer|-c|legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer/record-subagent-routing-attestation` (`.codex/config.toml`, `[[hooks.SubagentStart]]`)
  - copilot: `SubagentStart//discovery-agent-start` (`.github/hooks/discovery.json`, `/hooks/SubagentStart/0`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member, and a Copilot member).
- Divergence notes: none.

### hook:validate-bash

- Members:
  - claude: `PreToolUse/Bash/validate-bash` (`.claude/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/0`)
  - codex: `PreToolUse/^Bash$/validate-bash` (`.codex/hooks/pretooluse-dispatch.json`, `/hooks/PreToolUse/0/hooks/0`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: claude: Divergence (spec AD-5): the Codex validate-bash.ps1 omits the cd-chained read leg that the Claude copy carries; the destructive patterns are shared. codex: Divergence (spec AD-5): the Codex validate-bash.ps1 omits the cd-chained read leg that the Claude copy carries; the destructive patterns are shared..

### hook:validate-docs-role-output

- Members:
  - claude: `SubagentStop/docs-architect|docs-author|docs-reconciler|docs-coverage-reviewer/validate-docs-role-output` (`.claude/settings.json`, `/hooks/SubagentStop/9/hooks/0`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source dot-sources subagentstop-target-worktree.ps1, which imports .claude/lib/worktree-resolution/HookTargetWorktree.psm1; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3).
- Divergence notes: none.

### hook:validate-executor-output

- Members:
  - claude: `SubagentStop/atomic-executor/validate-executor-output` (`.claude/agents/atomic-executor.md`)
- Research label: DEFER (research label ADD, amended by AD-2)
- Gap class: `DEFER`. Reason: the Claude source dot-sources subagentstop-target-worktree.ps1, which imports .claude/lib/worktree-resolution/HookTargetWorktree.psm1 (with AgentTargetWorktree.psm1, WorktreeTargetResolution.psm1 and WorktreeItemResolution.psm1); lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3) (spec AD-2).
- Divergence notes: none.

### hook:validate-feature-review-coverage

- Members:
  - claude: `SubagentStop/feature-review/validate-feature-review-coverage` (`.claude/agents/feature-review.md`)
  - claude: `SubagentStop/feature-review/validate-feature-review-coverage` (`.claude/settings.json`, `/hooks/SubagentStop/2/hooks/0`)
  - codex: `SubagentStop/feature-review|feature-reviewer/validate-feature-review-coverage` (`.codex/config.toml`, `[[hooks.SubagentStop]]`)
- Research label: ALREADY-PARITY
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: none.

### hook:validate-human-exception-runbook-output

- Members:
  - claude: `SubagentStop/human-exception-runbook/validate-human-exception-runbook-output` (`.claude/agents/human-exception-runbook.md`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/runbook/RunbookCommandVersion.psm1 and dot-sources subagentstop-target-worktree.ps1 (.claude/lib/worktree-resolution); lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3).
- Divergence notes: none.

### hook:validate-orchestrator-output

- Members:
  - claude: `SubagentStop/epic-orchestrator/validate-orchestrator-output` (`.claude/agents/epic-orchestrator.md`)
  - claude: `SubagentStop/epic-orchestrator/validate-orchestrator-output` (`.claude/settings.json`, `/hooks/SubagentStop/7/hooks/0`)
  - claude: `SubagentStop/orchestrator/validate-orchestrator-output` (`.claude/agents/orchestrator.md`)
  - claude: `SubagentStop/orchestrator/validate-orchestrator-output` (`.claude/settings.json`, `/hooks/SubagentStop/6/hooks/0`)
  - claude: `SubagentStop/parallel-orchestrator/validate-orchestrator-output` (`.claude/agents/parallel-orchestrator.md`)
  - claude: `SubagentStop/parallel-orchestrator/validate-orchestrator-output` (`.claude/settings.json`, `/hooks/SubagentStop/8/hooks/0`)
- Research label: DEFER
- Gap class: `DEFER`. Reason: the Claude source imports .claude/lib/orchestrator-state/OrchestratorState.psm1 and further orchestrator-state and .claude/lib/worktree-resolution modules; lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3); the parallel registration form has no Codex workflow.
- Divergence notes: none.

### hook:validate-planner-output

- Members:
  - claude: `SubagentStop/atomic-planner/validate-planner-output` (`.claude/agents/atomic-planner.md`)
  - claude: `SubagentStop/atomic-planner/validate-planner-output` (`.claude/settings.json`, `/hooks/SubagentStop/3/hooks/0`)
- Research label: DEFER (research label ADD, amended by AD-2)
- Gap class: `DEFER`. Reason: the Claude source dot-sources subagentstop-target-worktree.ps1, which imports .claude/lib/worktree-resolution/HookTargetWorktree.psm1 (with AgentTargetWorktree.psm1, WorktreeTargetResolution.psm1 and WorktreeItemResolution.psm1); lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3) (spec AD-2).
- Divergence notes: none.

### hook:validate-pr-author-output

- Members:
  - claude: `SubagentStop/pr-author/validate-pr-author-output` (`.claude/agents/pr-author.md`)
  - claude: `SubagentStop/pr-author/validate-pr-author-output` (`.claude/settings.json`, `/hooks/SubagentStop/5/hooks/0`)
  - codex: `SubagentStop/pr-author/validate-pr-author-output` (`.codex/config.toml`, `[[hooks.SubagentStop]]`)
- Research label: ADD, delivered by this feature (research label ADD; AD-2 keeps it ADD)
- Gap class: none (the group has a Claude and a Codex member).
- Divergence notes: codex: Divergence: the Codex copy allows the one-continuation stop when stop_hook_active is true, while the Claude copy keeps validating a re-entered stop..

### hook:validate-prd-feature-output

- Members:
  - claude: `SubagentStop/prd-feature/validate-prd-feature-output` (`.claude/agents/prd-feature.md`)
  - claude: `SubagentStop/prd-feature/validate-prd-feature-output` (`.claude/settings.json`, `/hooks/SubagentStop/4/hooks/0`)
- Research label: DEFER (research label ADD, amended by AD-2)
- Gap class: `DEFER`. Reason: the Claude source dot-sources subagentstop-target-worktree.ps1, which imports .claude/lib/worktree-resolution/HookTargetWorktree.psm1 (with AgentTargetWorktree.psm1, WorktreeTargetResolution.psm1 and WorktreeItemResolution.psm1); lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3) (spec AD-2).
- Divergence notes: none.

### hook:validate-required-artifact-output

- Members:
  - claude: `SubagentStop/epic-review/validate-required-artifact-output` (`.claude/agents/epic-review.md`)
  - claude: `SubagentStop/prd-feature/validate-required-artifact-output` (`.claude/agents/prd-feature.md`)
  - claude: `SubagentStop/staged-review/validate-required-artifact-output` (`.claude/agents/staged-review.md`)
  - claude: `SubagentStop/status-updater/validate-required-artifact-output` (`.claude/agents/status-updater.md`)
- Research label: DEFER (research label ADD, amended by AD-2)
- Gap class: `DEFER`. Reason: the Claude source dot-sources subagentstop-target-worktree.ps1, which imports .claude/lib/worktree-resolution/HookTargetWorktree.psm1 (with AgentTargetWorktree.psm1, WorktreeTargetResolution.psm1 and WorktreeItemResolution.psm1); lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3) (spec AD-2).
- Divergence notes: none.

### hook:validate-task-researcher-output

- Members:
  - claude: `SubagentStop/task-researcher/validate-task-researcher-output` (`.claude/agents/task-researcher.md`)
- Research label: DEFER (research label ADD, amended by AD-2)
- Gap class: `DEFER`. Reason: the Claude source dot-sources subagentstop-target-worktree.ps1, which imports .claude/lib/worktree-resolution/HookTargetWorktree.psm1 (with AgentTargetWorktree.psm1, WorktreeTargetResolution.psm1 and WorktreeItemResolution.psm1); lib-dependent ports wait for .codex/lib publication by child 4 (spec OQ-3) (spec AD-2).
- Divergence notes: none.

## Registration-Shape Parity (superseded by #1159)

PreToolUse registration-shape parity is superseded by #1159 (spec AD-4). Each runtime registers one PreToolUse dispatcher: `.claude/hooks/invoke-pretooluse-dispatch.ps1` in `.claude/settings.json` and `.codex/hooks/invoke-pretooluse-dispatch.ps1` in `.codex/config.toml`. The hooks the dispatchers run are listed in `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json`, and the inventory reads both registries as registration sources. The dispatcher entries are themselves registrations and share `hook:invoke-pretooluse-dispatch`. This feature adds no PreToolUse hook (AD-8), so neither registry and neither dispatcher `timeout` changes; the Codex dispatcher `timeout` equals the sum of the registry hook timeouts (720 at Phase 0).

## Conditional Items

- **C1, Codex preimplementation gate for the delegation tool names:** gap class `NOT-EXPRESSIBLE` (spec AD-3). `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` routes `tool_input` only for `Bash` and `apply_patch` and maps every other tool name through `ConvertTo-CodexFileEditInput`; the file is at the 500-line Codex cap and is not edited. The gap is owned by issue #555. Recorded on the Claude entry `PreToolUse/Agent/enforce-orchestration-preimplementation-gate` of `.claude/hooks/pretooluse-dispatch.json`, group `hook:preimplementation-gate-delegation`.
- **C2, Codex port of the pr-author Bash allowlist:** gap class `DEFER` (spec AD-3). There is no recorded verification that Codex subagent PreToolUse payloads carry `agent_type`, which per-agent scoping needs. Recorded on the Claude entry `PreToolUse/Bash/enforce-pr-author-command-allowlist` of `.claude/agents/pr-author.md`, group `hook:pr-author-command-allowlist`.
- The Phase 0 Codex payload check is removed (AD-3).

## Classification Rule

The gap notes were assigned in this order:

1. Research `## 3. Function-Level Parity Table`, as amended by AD-2, AD-3 and AD-8: `GAP:NOT-APPLICABLE:` for `persist-session-id` and the four parallel gates (`enforce-parallel-cohort-barrier`, `enforce-parallel-drift-gate`, `enforce-parallel-abandon-gate`, `enforce-parallel-worktree-removal-gate`); `GAP:DEFER:` for every deferred Claude stem except C2 (`enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `enforce-pr-author-skill`, `validate-orchestrator-output`, the five AD-2 validators `validate-planner-output`, `validate-task-researcher-output`, `validate-executor-output`, `validate-prd-feature-output`, `validate-required-artifact-output`, and `enforce-feature-folder-order` per AD-8), each reason naming the `.claude/lib/` module that blocks the port and child 4; `GAP:DEFER:` naming the unverified `agent_type` field for C2; `GAP:NOT-EXPRESSIBLE:` for C1 naming the `Bash`/`apply_patch`-only routing, the 500-line cap and issue #555.
2. A Claude group absent from that table and without a Codex member: `GAP:DEFER:` when its script or a dot-sourced sibling imports a `.claude/lib` module (the reason names the module and child 4), otherwise `GAP:NOT-APPLICABLE:`. Outcomes: `enforce-owner-directive-pass-down` DEFER (`.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`; `.claude/rules/orchestrator-state.md` records the hook as Claude only); `enforce-docs-complete-gate` DEFER (`.claude/lib/docs/DocsCompleteGate.psm1`); `enforce-docs-role-write-scope` DEFER (`.claude/lib/hook-payload/HookPayload.psm1`); `validate-docs-role-output` DEFER (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1` through `subagentstop-target-worktree.ps1`); `validate-human-exception-runbook-output` DEFER (`.claude/lib/runbook/RunbookCommandVersion.psm1`). No step-(2) group took `NOT-APPLICABLE`, because each imports a `.claude/lib` module.
3. A Codex group without a Claude member: `CODEX-NATIVE:` naming the Claude mechanism from the research table: `enforce-epic-planning-only` (Claude uses the agent `tools:` allowlist) and `enforce-epic-child-worktree-binding` (Claude uses agent isolation worktrees).

Equivalent functions with different stems share one group: `hook:model-routing`, `hook:epic-invocation-origin`, `hook:subagent-start-attestation`, `hook:discovery-stop`; the Copilot `discovery-pre-tool` and `discovery-planning` registrations join `hook:enforce-discovery-artifact-gate` and `hook:enforce-discovery-planning-gate`. Every other entry is in `hook:<command stem>`. Selection used `ecosystem`, `kind`, `name`, `source_path` and `source_pointer`, never the parsed `id`.

## Owner Questions Applied

| ID | Applied |
| --- | --- |
| OQ-1 | Applied: every hook registration keeps `disposition: native`; a shared function is a `parity_group` with members in more than one ecosystem. |
| OQ-2 | Applied (notes form): the schema has no structured gap field (`GAP-ENCODING: NOTES` at Phase 0), so gap classes are `notes` prefixes checked by the hook-parity gate. |
| OQ-3 | Applied: Codex ports that need `.claude/lib` modules are `DEFER` until child 4 decides `.codex/lib` publication. |
| OQ-4 | Decided (AD-5): the Codex `validate-bash.ps1` keeps its omission of the cd-chained read leg; recorded as a divergence note; no brief edit. |
| OQ-5 | Default kept: the feature-review coverage hooks are unchanged; reading `AGENTS.md` waits for child 3's `AGENTS.md` content. |
| OQ-6 | Default kept: whether Claude hooks run in Copilot sessions is a child 1 experiment and a child 6 decision; child 5 records the Copilot registrations only. |
| OQ-7 | Not triggered: Phase 0 check (b) found no generator-owned `[[hooks.*]]` region (`CONFIG-HOOKS-OWNER: HAND`), so the pr-author `[[hooks.SubagentStop]]` table was edited directly. |
| OQ-8 | Applied: no Codex counterpart of `enforce-pr-author-skill` in child 5; recorded `DEFER`. |
| OQ-9 | Default kept: duplicate SubagentStop registrations in `.claude/settings.json` and agent frontmatter are kept; each has its own matrix entry. |
| OQ-10 | Decided (AD-2): not applicable; `validate-required-artifact-output` is deferred, so no `-RequiredArtifact` registration is added to `.codex/config.toml`. |
| AD-8 | Applied: the Codex `enforce-feature-folder-order.ps1` port is `DEFER`; no Codex file, bundle copy, registry entry, dispatcher `timeout` change, parity-corpus envelope or import-failure exemption row is produced. |
