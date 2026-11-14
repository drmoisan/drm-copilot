# Research: Hook Parity Across Claude Code, Codex and GitHub Copilot (Issue #1030)

- Issue: #1030 (epic #1018, child 5)
- Mode: preparation, research only
- Branch: `issue-1030-prep` (tracks `feature/hook-parity-across-claude-codex-copilot-1030`)
- Settled design (not re-opened): `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`; epic manifest `docs/features/epics/shared-agent-harness-layer/epic.md`
- Scratch inputs are cited as `SCRATCH/<file name>`. The worktree hook files, `.codex/config.toml` and `.claude/settings.json` are stated by the caller to be byte-identical to `origin/main`; this research reads them in the worktree.

## 0. Sources Read

- Feature folder: `issue.md`, `spec.md` (template-level), `plan.2026-10-30T18-37.md` (template).
- Epic and settled design (above); child 2 folder `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md` (`## Write-scope literal contract (D-16)`, `### PowerShell (new .claude/lib/development-docs/DevelopmentDocsRoot.psm1)`, `## Execution Precondition`).
- Child 1 (#1025): `SCRATCH/issue-1030-child1-spec.md` (`## Interface Contracts`, `### Parity Matrix: Feature Kinds and Inventory Rules`, `## Open Owner Questions` Q6), `SCRATCH/issue-1030-child1-plan.2026-10-30T17-06.md` (skeleton `parity_group` rule).
- Child 3: `SCRATCH/issue-1030-child3-research.2026-10-30T22-46.md` (sections 1.3, 1.4, 1.5, 3, 4, 6, 7).
- `SCRATCH/issue-1030-hook-inventory-origin-main.txt`, `SCRATCH/issue-1030-parallel-manifest.md`.
- Registration surfaces: `.claude/settings.json`, `.claude/agents/*.md`, `.codex/config.toml`, `.codex/agents/*.toml`, `.github/hooks/discovery.json`.
- Hook sources under `.claude/hooks`, `.codex/hooks`, `.github/hooks`; tests under `tests/scripts/claude-hooks`, `tests/scripts/codex-hooks`, `tests/scripts/copilot-hooks`, `tests/scripts/claude-runtime`, `tests/scripts/dev_tools`.
- `.agents/skills/translate-claude-to-codex/SKILL.md` (Codex hook mapping rules used in this repository).
- `quality-tiers.yml`, `scripts/dev_tools/quality_tiers_contract.py` (discovery rules R1 to R5), `config/file-size-baseline.json`.
- Vendor documentation fetched 2026-10-30: Codex hooks (`https://developers.openai.com/codex/hooks`, which redirects to `https://learn.chatgpt.com/docs/hooks`); VS Code Copilot hooks (`https://code.visualstudio.com/docs/copilot/customization/hooks`).

## 1. Hook Registration Inventory

Each row is one (event, matcher, command) registration. "Script" is the file under the ecosystem's hook folder. Purpose is taken from the script's `.SYNOPSIS`.

### 1.1 Claude Code: `.claude/settings.json` (`hooks`)

| Event | Matcher | Script (arguments) | Purpose |
| --- | --- | --- | --- |
| SessionStart | none | `persist-session-id.ps1` | Persists the Claude Code session id (supports the `identify-session-id` skill) |
| PreToolUse | `Bash` | `validate-bash.ps1` | Denies destructive shell patterns and cd-chained read commands |
| PreToolUse | `Bash` | `enforce-promotion-mcp-only.ps1` | Denies direct promotion scripts and `gh issue create` |
| PreToolUse | `Bash` | `enforce-pr-author-skill.ps1` | Requires the pr-author skill/checkpoint before `gh pr create`/`gh pr edit` |
| PreToolUse | `Bash` | `enforce-orchestration-preimplementation-gate.ps1` | Denies implementation commands before the orchestration checkpoint is ready |
| PreToolUse | `Bash` | `enforce-epic-merge-gate.ps1` | Gates merges in epic mode (authorization, green CI) |
| PreToolUse | `Bash` | `enforce-epic-worktree-removal-gate.ps1` | Gates epic worktree removal on merge state |
| PreToolUse | `Bash` | `enforce-parallel-worktree-removal-gate.ps1` | Gates worktree removal on parallel (and epic) checkpoint merge state |
| PreToolUse | `Bash` | `enforce-parallel-abandon-gate.ps1` | Gates the parallel abandon disposition behind a confirmation marker |
| PreToolUse | `Write\|Edit` | `check-python-test-purity.ps1` | Python test-purity rules on test writes |
| PreToolUse | `Write\|Edit` | `enforce-python-batch-budget.ps1` | Direct-mode cap on distinct Python production files |
| PreToolUse | `Write\|Edit` | `check-powershell-test-purity.ps1` | PowerShell test-purity rules on test writes |
| PreToolUse | `Write\|Edit` | `enforce-powershell-batch-budget.ps1` | Direct-mode cap on distinct PowerShell production files |
| PreToolUse | `Write\|Edit` | `enforce-evidence-locations.ps1` | Denies evidence writes outside `<FEATURE>/evidence/<kind>/` |
| PreToolUse | `Write\|Edit` | `enforce-file-size-limit.ps1` | Hard 800-line block and baseline rule |
| PreToolUse | `Write\|Edit` | `enforce-orchestration-preimplementation-gate.ps1` | Same gate for implementation file writes |
| PreToolUse | `Write\|Edit` | `enforce-feature-folder-order.ps1` | Blocks plan writes until the work mode's prerequisite documents exist |
| PreToolUse | `Write\|Edit` | `enforce-checkpoint-monotonic.ps1` | Blocks out-of-order `completed_steps` in the checkpoint |
| PreToolUse | `Write\|Edit` | `enforce-completion-consistency.ps1` | Blocks completion assertions without completion evidence |
| PreToolUse | `Write\|Edit` | `enforce-mermaid-validation.ps1` | Blocks Mermaid diagrams with named structural defects |
| PreToolUse | `Bash\|Write\|Edit\|MultiEdit\|NotebookEdit\|Agent\|Task\|WebFetch\|WebSearch\|mcp__.*` | `enforce-discovery-artifact-gate.ps1` | Discovery protected-artifact authority |
| PreToolUse | `Agent` | `enforce-prd-feature-before-planner.ps1` | Blocks atomic-planner delegation until prd-feature outputs exist |
| PreToolUse | `Agent` | `enforce-discovery-planning-gate.ps1` | Discovery planning gate |
| PreToolUse | `Agent` | `enforce-orchestration-preimplementation-gate.ps1` | Same gate for implementation delegations |
| PreToolUse | `Agent` | `enforce-epic-wave-barrier.ps1` | Layer 1 deterrent: child kickoff before dependencies merge |
| PreToolUse | `Agent` | `enforce-model-routing-receipt.ps1` | Blocks gated delegations with no model-routing receipt |
| PreToolUse | `Agent` | `enforce-epic-invocation-origin.ps1` | Blocks epic/parallel planner and orchestrator delegations from an orchestrator |
| PreToolUse | `Agent` | `enforce-parallel-cohort-barrier.ps1` | Layer 1 deterrent for the parallel cohort barrier |
| PreToolUse | `Agent` | `enforce-parallel-drift-gate.ps1` | Layer 1 deterrent for the parallel drift gate |
| SubagentStart | four discovery agents | `record-discovery-agent-start.ps1` | Discovery start attestation |
| SubagentStop | fifteen-agent group (pinned by `claude-settings.Tests.ps1` `BroadSubagentStopMatcher`) | `validate-discovery-artifact-gate.ps1` | Discovery output authority |
| SubagentStop | four discovery agents | `validate-discovery-artifact-gate.ps1` | Same, dedicated group |
| SubagentStop | `feature-review` | `validate-feature-review-coverage.ps1` | Coverage verdict validation |
| SubagentStop | `atomic-planner` | `validate-planner-output.ps1` | Planner output envelope and Pre-Mortem |
| SubagentStop | `prd-feature` | `validate-prd-feature-output.ps1` | Numeric acceptance-criteria evidence |
| SubagentStop | `pr-author` | `validate-pr-author-output.ps1` | Requires a created or updated PR in the output |
| SubagentStop | `orchestrator` | `validate-orchestrator-output.ps1` | Orchestrator completion gate |
| SubagentStop | `epic-orchestrator` | `validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/epic-orchestrator-state.json -ArtifactType epic-orchestrator-state` | Epic completion gate |
| SubagentStop | `parallel-orchestrator` | `validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state` | Parallel completion gate |

### 1.2 Claude Code: agent frontmatter `hooks:` (`.claude/agents/*.md`)

| Agent file | Event | Matcher | Script (arguments) |
| --- | --- | --- | --- |
| `task-researcher.md` | SubagentStop | `task-researcher` | `validate-task-researcher-output.ps1` |
| `feature-review.md` | SubagentStop | `feature-review` | `validate-feature-review-coverage.ps1` (also in settings) |
| `epic-review.md` | SubagentStop | `epic-review` | `validate-required-artifact-output.ps1 -AgentName epic-review -RequiredArtifact 'epic-audit-path\|^docs/features/epics/...'` |
| `status-updater.md` | SubagentStop | `status-updater` | `validate-required-artifact-output.ps1 -AgentName status-updater -RequiredArtifact 'status-sync-path\|^artifacts/status/...'` |
| `staged-review.md` | SubagentStop | `staged-review` | `validate-required-artifact-output.ps1 -AgentName staged-review -RequiredArtifact 'staged-review-path\|^artifacts/reviews/...'` |
| `pr-author.md` | PreToolUse | `Bash` | `enforce-pr-author-command-allowlist.ps1` (limits the pr-author subagent's Bash forms) |
| `pr-author.md` | SubagentStop | `pr-author` | `validate-pr-author-output.ps1` (also in settings) |
| `atomic-planner.md` | SubagentStop | `atomic-planner` | `validate-planner-output.ps1` (also in settings) |
| `atomic-executor.md` | SubagentStop | `atomic-executor` | `validate-executor-output.ps1` |
| `prd-feature.md` | SubagentStop | `prd-feature` | two commands: `validate-required-artifact-output.ps1 -AgentName prd-feature -RequiredArtifact 'spec-path\|^docs/features/active/.+/spec\.md$\|...'`; `validate-prd-feature-output.ps1` (also in settings) |
| `orchestrator.md` | SubagentStop | `orchestrator` | `validate-orchestrator-output.ps1` (also in settings) |
| `epic-orchestrator.md` | SubagentStop | `epic-orchestrator` | epic-arguments form (also in settings) |
| `parallel-orchestrator.md` | SubagentStop | `parallel-orchestrator` | parallel-arguments form (also in settings) |

No other `.claude/agents/*.md` file declares `hooks:` (Grep over the folder). Agents whose SubagentStop registration appears in both `.claude/settings.json` and their own frontmatter: feature-review, atomic-planner, prd-feature (`validate-prd-feature-output.ps1`), pr-author, orchestrator, epic-orchestrator, parallel-orchestrator. Whether a frontmatter `SubagentStop` entry fires in addition to the settings entry is not verified here (child 1 experiment E5 covers Claude hook and subagent frontmatter details; orchestrator to confirm).

### 1.3 Codex: `.codex/config.toml` (`[[hooks.<Event>]]`)

All commands are `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<script>"` with a `command_windows` twin and a `timeout`.

| Event | Matcher | Script | Purpose |
| --- | --- | --- | --- |
| UserPromptSubmit | none (ignored by Codex) | `authorize-root-epic-invocation.ps1` | Records a bounded root-session authorization receipt for epic personas |
| SubagentStart | broad group (epic, orchestrator, workers, `typed-engineer`, `-c`, discovery four) | `record-subagent-routing-attestation.ps1` | Records subagent identity, model, routing and epic-root provenance |
| PreToolUse | `^Bash$` | `validate-bash.ps1` | Destructive shell patterns (no cd-chained leg, see section 3) |
| PreToolUse | `^Bash$` | `enforce-promotion-mcp-only.ps1` | As Claude |
| PreToolUse | `^Bash$` | `enforce-orchestration-preimplementation-gate.ps1` | As Claude (commands) |
| PreToolUse | `^Bash$` | `enforce-epic-merge-gate.ps1` | Epic merge gate (single file; no authorization/green-CI/resolution parts) |
| PreToolUse | `^Bash$` | `enforce-epic-worktree-removal-gate.ps1` | Epic worktree removal gate |
| PreToolUse | `^(Bash\|shell_command\|apply_patch\|Edit\|Write\|mcp__.*)$` | `enforce-discovery-artifact-gate.ps1` | As Claude |
| PreToolUse | same | `enforce-epic-root-invocation.ps1` | Denies epic-persona mutations without root provenance |
| PreToolUse | same | `enforce-codex-model-routing.ps1` | Denies subagent mutations when model/profile does not match routing |
| PreToolUse | same | `enforce-epic-planning-only.ps1` | Planning-only boundary for `route_id` preparation |
| PreToolUse | same | `enforce-epic-wave-barrier.ps1` | Denies child mutations before epic dependencies merge |
| PreToolUse | same | `enforce-epic-child-worktree-binding.ps1` | Denies epic-child mutations outside the launch-authorized worktree and profile |
| PreToolUse | `^(apply_patch\|Edit\|Write)$` | `check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`, `enforce-file-size-limit.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1` | As Claude |
| PreToolUse | `^(Agent\|Task\|spawn_agent\|run_subagent\|delegate)$` | `enforce-discovery-artifact-gate.ps1`, `enforce-discovery-planning-gate.ps1` | Discovery gates on delegation |
| SubagentStop | broad group (as SubagentStart) | `validate-codex-subagent-routing.ps1` | Requests continuation when a routed subagent stops without valid model or epic provenance |
| SubagentStop | discovery four | `validate-discovery-agent-output.ps1` | Discovery output authority |
| SubagentStop | `feature-review\|feature-reviewer` | `validate-feature-review-coverage.ps1` | Coverage verdict validation |

Codex agent definitions (`.codex/agents/*.toml`) register no hooks. Several (for example `atomic-executor.toml`, `atomic-planner.toml`, `task-researcher.toml`, `feature-review.toml`) contain a `hooks:` block only as text inside `developer_instructions` (a converted copy of Claude frontmatter); it has no runtime effect. The repository's own mapping rule states that Codex hooks are session-level, not agent-definition-level (`.agents/skills/translate-claude-to-codex/SKILL.md`, the `hooks:` on the persona bullet).

### 1.4 GitHub Copilot: `.github/hooks/discovery.json`

| Event | Matcher | Script | Purpose |
| --- | --- | --- | --- |
| SubagentStart | none | `discovery-agent-start.ps1` | Discovery start record |
| PreToolUse | none | `discovery-pre-tool.ps1` | Discovery protected-artifact gate |
| PreToolUse | none | `discovery-planning.ps1` | Discovery planning gate |
| SubagentStop | none | `discovery-agent-stop.ps1` | Discovery output validation |

`.github/hooks/discovery-capability-probe.ps1` is not registered (helper). No other Copilot hook registration file exists in the tree (`.github/copilot/settings.json` is absent; Glob over `.github`).

### 1.5 Unregistered hook files (helpers)

Under child 1's working assumption Q6 (one matrix entry per registration; helpers excluded as implementation), these files receive no matrix entry: Claude helpers such as `enforce-batch-budget-route.ps1`, `enforce-completion-helpers.ps1`, `enforce-epic-merge-gate-{authorization,command,green-ci,resolution}.ps1`, `enforce-epic-worktree-removal-gate-resolution.ps1`, `enforce-orchestration-preimplementation-gate-{epic-scope,helpers,modes,targets}.ps1`, `enforce-parallel-*-helpers.ps1`, `enforce-pr-author-skill-helpers.ps1` and the four `enforce-pr-author-skill.*.ps1` parts, `enforce-prd-feature-before-planner-helpers.ps1`, `feature-folder-resolution.ps1`, `feature-review-coverage-thresholds.ps1`, the six `hook-command-*.ps1`, `hook-dependency-guard.ps1`, `hook-docs-only-diff.ps1`, `premortem-section.ps1`, `subagentstop-envelope.ps1`, `validate-feature-review-coverage-{metrics,rules}.ps1`, `validate-orchestrator-output-{feature-folder,resolution,routing}.ps1`, `discovery-capability-probe.ps1`; Codex helpers such as `codex-agent-profile-attestation.ps1`, `codex-authority-store.ps1`, `codex-epic-child-launch-attestation.ps1`, `codex-pretooluse-file-mapping.ps1`, `discovery-start-attestation.ps1`, `file-size-policy.ps1`, `hook-target-worktree.ps1`, `enforce-orchestration-preimplementation-gate-epic-resolution.ps1` and the shared helper twins.

## 2. What Each Hook System Can Express

| Capability | Claude Code | Codex | Copilot (VS Code, Preview) |
| --- | --- | --- | --- |
| Events used here | SessionStart, PreToolUse, SubagentStart, SubagentStop | UserPromptSubmit, SubagentStart, PreToolUse, SubagentStop (vendor list also has PermissionRequest, PostToolUse, PreCompact, PostCompact, Stop, SessionStart, SessionEnd, Interrupt) | sessionStart, userPromptSubmitted, preToolUse, postToolUse, preCompact, subagentStart, subagentStop, agentStop, sessionEnd (PascalCase aliases accepted) |
| Matcher | regex-like per event | regex on `tool_name` (PreToolUse/PostToolUse/PermissionRequest), `agent_type` (SubagentStart/Stop), `source`, `trigger`; ignored for UserPromptSubmit, Stop, Interrupt | the page states the Local parser ignores matcher values; filtering must happen inside the script |
| Shell tool name | `Bash` | `Bash` (shell and `exec_command`), input `tool_input.command` | `toolName`/`toolArgs` (field names of the snake_case alias not documented) |
| File edit tool | `Write`, `Edit` (path and content in `tool_input`) | `apply_patch` (matcher may say `Edit`/`Write`; payload reports `apply_patch` with the patch in `tool_input.command`); mapped in this repo by `codex-pretooluse-file-mapping.ps1` (`ConvertFrom-CodexPreToolUsePayload`, `ConvertTo-CodexFileEditInput`, `Resolve-CodexUpdatedFileContent`) | not documented |
| Delegation tool | `Agent`/`Task` with `subagent_type` and prompt | `spawn_agent` matches as `Agent`; argument object field names are not documented on the page | not documented |
| Agent identity in PreToolUse | `agent_type` on the envelope root when called inside a subagent (read by `enforce-epic-invocation-origin.ps1`) | vendor common fields are `session_id`, `transcript_path`, `cwd`, `hook_event_name`, `model`; `agent_type` is not listed, but `enforce-codex-model-routing.ps1` and `enforce-epic-root-invocation.ps1` read `payload.agent_type` (repository assumption; unverified) | not documented |
| Per-agent registration | agent frontmatter `hooks:` | not available (session-level only) | not available |
| SubagentStop block | exit 2 with stderr continues the subagent (`Exit-SubagentStopBlock` in `subagentstop-envelope.ps1`) | `decision: "block"` with reason continues the subagent; exit 2 also accepted; `last_assistant_message`, `stop_hook_active`, `agent_type` in payload | not documented |
| SubagentStart block | not used | cannot stop the subagent (`continue: false` does not stop it) | not documented |
| PreToolUse deny | JSON `permissionDecision: deny` or exit 2 | `hookSpecificOutput.permissionDecision: "deny"`, legacy `decision: "block"`, or exit 2; `ask`, `continue: false`, `stopReason` are unsupported and make the run fail open | top-level `permissionDecision: "deny"` with reason; command errors deny |
| Coverage limits | n/a | hosted tools (WebSearch) never fire; some tool paths can opt out; vendor text: "Treat tool hooks as a useful guardrail, not a complete enforcement boundary" | Preview; cloud sessions experimental |
| Trust | none | project `.codex/` layer must be trusted; hooks reviewed via `/hooks` | n/a |
| Cross-reading | n/a | n/a | The VS Code page states the Copilot harness reads repository `.claude/settings.json` (and `.claude/settings.local.json`); the Local harness reads them only when `chat.useClaudeHooks` is enabled |

Consequences used in section 3:

- A Claude PreToolUse gate on `Bash` or `Write|Edit` is expressible in Codex when its input can be read from `tool_input.command` or from the repository's apply_patch mapping.
- A Claude SubagentStop output validator is expressible in Codex (matcher on `agent_type`, text in `last_assistant_message`, block continues the subagent). The repository already does this for `validate-discovery-agent-output.ps1` and `validate-feature-review-coverage.ps1`.
- A Claude `Agent` gate is expressible in Codex only if the `spawn_agent` argument object carries the target agent name and prompt in fields the hook can read; the field names are unverified.
- A per-agent PreToolUse restriction (pr-author frontmatter) is expressible in Codex only through a session-level registration that filters on `payload.agent_type`, which the vendor page does not list.
- A SessionStart hook is expressible in Codex (`session_id` is a common field).

## 3. Function-Level Parity Table

Labels: ALREADY-PARITY (same function present; "mechanism" when the mechanism differs), ADD (Codex can express it and the workflow exists in Codex), ADD-CONDITIONAL (expressible only if an unverified payload field exists), DEFER (expressible, but a port needs a `.claude/lib` module that Codex destinations do not receive; see section 7), NOT-APPLICABLE (the workflow the gate protects does not exist in Codex; matrix disposition `native`), NOT-EXPRESSIBLE (the Codex hook system lacks the event, matcher or payload). Copilot column: Copilot hooks are native in `.github` and child 6 finalizes the thin layer (epic `## Scope`, child 6), so child 5 records dispositions only; "C6" marks a gap whose remedy belongs to child 6.

| Function (Claude registration) | Claude | Codex | Codex label and reason | Copilot |
| --- | --- | --- | --- | --- |
| Destructive shell patterns (`validate-bash`) | yes | yes, without the cd-chained read leg | ALREADY-PARITY for destructive patterns; cd-chained leg omitted deliberately (file comment in `.codex/hooks/validate-bash.ps1`: "This copy has no cd-chained leg and none is added"); owner question OQ-4 | C6 |
| Promotion MCP-only (`enforce-promotion-mcp-only`) | yes | yes | ALREADY-PARITY | C6 |
| PR authoring requires pr-author checkpoint (`enforce-pr-author-skill`) | yes | no | DEFER: expressible (`^Bash$`), but the Claude implementation spans five files (largest 443 lines), imports `.claude/lib` worktree and checkpoint modules, and is in the parallel run's blast radius (#1001, #1011); Codex PR authoring uses its own receipts. Owner question OQ-8 | C6 |
| Preimplementation gate, commands and file writes | yes | yes | ALREADY-PARITY | C6 |
| Preimplementation gate, delegations (`Agent` matcher) | yes | script handles `subagent_type` but is not registered on the Codex `Agent` group | ADD-CONDITIONAL: registration-only change in `.codex/config.toml`; depends on the `spawn_agent` argument field name (the Codex script reads `subagent_type`, a Claude field name) | C6 |
| Epic merge gate | yes (with authorization, green-CI and resolution parts) | yes (single file) | ALREADY-PARITY with drift (section 4) | C6 |
| Epic worktree removal gate | yes | yes | ALREADY-PARITY; Claude also consults the parallel checkpoint (`Test-ParallelCheckpointAllowsWorktreeRemoval`), which Codex has no use for | C6 |
| Parallel worktree removal, abandon, cohort barrier, drift gate | yes | no | NOT-APPLICABLE: no parallel orchestration surface in Codex (no `parallel-*` skill under `.agents/skills`, no `parallel-*` base agent under `.codex/agents`) | C6 |
| Python and PowerShell test purity | yes | yes | ALREADY-PARITY | C6 |
| Python and PowerShell batch budget | yes | yes | ALREADY-PARITY with documented drift (Codex has no containment filter; brief `## Batch Budget`) | C6 |
| Evidence locations | yes | yes | ALREADY-PARITY; Claude adds a payload-anomaly deny path (section 4) | C6 |
| File-size limit | yes | yes | ALREADY-PARITY (`file-size-policy.ps1` twin pinned text-identical by `tests/scripts/codex-hooks/file-size-policy.Tests.ps1`) | C6 |
| Feature-folder order (`enforce-feature-folder-order`) | yes | no | ADD: `^(apply_patch\|Edit\|Write)$`; needs only `feature-folder-resolution.ps1` (Codex twin exists), `hook-dependency-guard.ps1` and the apply_patch mapping; docs-root literal must use child 2's resolver | C6 |
| Checkpoint monotonic, completion consistency | yes | yes | ALREADY-PARITY | C6 |
| Mermaid validation | yes | no | DEFER: expressible via the apply_patch mapping (`ConvertTo-CodexAddedLineText`), but needs `.claude/lib/mermaid/MermaidValidation.psm1` and `HookPayload.psm1`; no Codex `mermaid-diagram` skill exists | C6 |
| Discovery artifact gate, planning gate, start, stop | yes | yes | ALREADY-PARITY (Codex start via `record-subagent-routing-attestation.ps1` and `discovery-start-attestation.ps1`; stop via `validate-discovery-agent-output.ps1`) | yes (native) |
| prd-feature before planner (`Agent`) | yes | no | DEFER and ADD-CONDITIONAL: needs `spawn_agent` field names and `.claude/lib/worktree-resolution` modules | C6 |
| Epic wave barrier | yes (delegation deterrent) | yes (mutation gate) | ALREADY-PARITY (mechanism): Codex children launch through `.codex/scripts/launch-epic-child-wave.ps1`, so the Codex gate checks mutations; same-named files are not functionally identical by design | C6 |
| Model routing | `enforce-model-routing-receipt` (receipt before delegation) | `record-subagent-routing-attestation`, `enforce-codex-model-routing`, `validate-codex-subagent-routing` | ALREADY-PARITY (mechanism); different `parity_group` stems need alignment (section 6) | C6 |
| Epic invocation origin | `enforce-epic-invocation-origin` | `authorize-root-epic-invocation`, `enforce-epic-root-invocation` | ALREADY-PARITY (mechanism) | C6 |
| Epic planning-only boundary, epic child worktree binding | via agent `tools:` allowlists and isolation worktrees | `enforce-epic-planning-only`, `enforce-epic-child-worktree-binding` | Codex-native: Codex has no per-agent tool allowlist (`translate-claude-to-codex` re-grounds allowlists in hooks); no Claude ADD | C6 |
| Session id persistence (`persist-session-id`) | yes | no | NOT-APPLICABLE: expressible (Codex SessionStart carries `session_id`), but its consumer skill `identify-session-id` exists only under `.claude/skills` | not applicable |
| Planner output (`validate-planner-output`) | yes | no | ADD: SubagentStop, matcher `atomic-planner` (variants included), deps `subagentstop-envelope.ps1`, `premortem-section.ps1`, `hook-dependency-guard.ps1` only | C6 |
| Task-researcher output | yes (frontmatter) | no | ADD: same dependency set | C6 |
| Executor output | yes (frontmatter) | no | ADD: deps `subagentstop-envelope.ps1`, `hook-dependency-guard.ps1` | C6 |
| prd-feature numeric AC output | yes | no | ADD: same | C6 |
| Required artifact output (epic-review, status-updater, staged-review, prd-feature) | yes (frontmatter, with `-RequiredArtifact` arguments) | no | ADD: same; the `-RequiredArtifact` docs-root literals fall under child 2 D-16 (`REQUIRED_ARTIFACT_RULES`) | C6 |
| PR-author output | yes | no | ADD: same | C6 |
| Orchestrator, epic and parallel completion gates (`validate-orchestrator-output`) | yes | no (Codex `orchestrator.toml` names the MCP validator and CI as the hard boundary) | DEFER: imports six `.claude/lib/orchestrator-state` and `worktree-resolution` modules; parallel form NOT-APPLICABLE; in the parallel run's blast radius (#1012) | C6 |
| Feature-review coverage | yes | yes | ALREADY-PARITY (floor parity pinned by `feature-review-coverage-floor-parity.Tests.ps1`; thresholds byte-identity by `feature-review-coverage-thresholds.Tests.ps1`); both read root `CLAUDE.md` only (OQ-5) | C6 |
| pr-author Bash allowlist (frontmatter PreToolUse) | yes | no | ADD-CONDITIONAL: per-agent scoping needs `payload.agent_type` in Codex PreToolUse; file is in the parallel run's blast radius (#1011); deps `HookPayload.psm1` (reads `$env:CLAUDE_*`, forbidden in Codex hooks by `legacy-codex-hook-contracts.Tests.ps1`) replaced by the Codex mapping | C6 |

Codex-only functions with no Claude gap (Claude expresses them by other mechanisms): root epic authorization, model/profile attestation, planning-only boundary, child worktree binding. No ADD is proposed for Claude.

Copilot summary: Copilot registers only the discovery functions. Every other enforcement function above is absent in Copilot hooks. Whether Claude hooks already execute in Copilot sessions through `.claude/settings.json` is unverified and is a collision question for child 1 (experiments) and child 6 (OQ-6). Child 5 records `native`, `owner_child` 6 for the Copilot registrations, as child 1's default table states.

## 4. Drift Between Paired Claude and Codex Implementations

Method: function-name inventory (`^function` Grep) and line counts (Grep line count) of every same-named pair. Byte identity was not computed (no hash tool in this role); orchestrator to confirm with `git hash-object` on each pair listed as "same size".

| Pair | Finding | Kind |
| --- | --- | --- |
| `validate-bash.ps1` | Codex lacks `Get-CdChainedReadCommandMatch`; Codex adds `ConvertFrom-CodexBashHookPayload`. The execution-environment brief (`## Command-Text Restrictions`) names `Get-CdChainedReadCommandMatch` for both paths, which does not match the Codex file | Deliberate logic divergence; documentation inaccuracy |
| Claude PreToolUse/SubagentStop hooks generally | 30 Claude hook files contain a "payload anomaly" deny path; no Codex hook does. Codex fails closed with exit 2 and stderr on malformed input | Mechanism difference; both deny |
| `enforce-evidence-locations.ps1` | Claude has `Get-EvidenceLocationAnomalyDecision`; block text differs only in the skill pointer (`.claude/skills/...` vs `.agents/skills/...`) | Mechanism; intended text difference |
| `enforce-epic-merge-gate.ps1` | Claude splits into `-authorization`, `-green-ci`, `-resolution` helpers; Codex is one file. `enforce-epic-merge-gate-authorization.Tests.ps1` (codex-hooks) pins identical reason-code spelling between the Claude helpers file and the Codex hook | Structure; partially pinned |
| `enforce-epic-worktree-removal-gate.ps1` | Claude consults the parallel checkpoint; Codex does not | Intended (no Codex parallel workflow) |
| `enforce-epic-wave-barrier.ps1` | Different design (delegation deterrent vs mutation gate) | Intended mechanism difference |
| `enforce-discovery-artifact-gate.ps1`, `enforce-discovery-planning-gate.ps1` | Codex adds published/self-hosted module path resolution (`.codex/lib` first, `.claude/lib` second) | Packaging difference |
| `validate-feature-review-coverage.ps1` | Claude split into `-metrics` and `-rules`; Codex monolithic with its own LCOV/JaCoCo readers | Structure; floor parity pinned |
| `enforce-orchestration-preimplementation-gate*.ps1` | Codex has an extra `-epic-resolution.ps1`; gate 12 vs 13 functions, epic-scope 8 vs 5 | Structure; in parallel run blast radius |
| Batch-budget hooks | Claude 9 functions per hook, Codex 6; Codex has no containment filter | Documented drift; in parallel run blast radius (#1009) |
| `enforce-file-size-limit.ps1` | Claude imports `.claude/lib/file-size-policy`; Codex dot-sources `file-size-policy.ps1` twin | Pinned text-identical |
| Same size in both trees (likely identical, unpinned except where noted) | `hook-command-{heredoc,invocation,invocation-operands,payload,payload-powershell,scanner}.ps1`, `hook-docs-only-diff.ps1`, `hook-dependency-guard.ps1`, `feature-folder-resolution.ps1`, `enforce-completion-helpers.ps1`, `enforce-orchestration-preimplementation-gate-{targets,helpers}.ps1`, `enforce-epic-merge-gate-command.ps1`, `enforce-batch-budget-route.ps1` (pinned byte-identical by `codex-batch-budget-route-parity.Tests.ps1`), `feature-review-coverage-thresholds.ps1` (pinned) | No cross-tree identity pin for the others |

Recommendation for drift: add one Pester parity test that pins byte identity of the cross-tree shared helpers that are identical today (orchestrator confirms the set by hash at Phase 0), following the `codex-batch-budget-route-parity.Tests.ps1` pattern. Logic divergences (cd-chained leg, payload-anomaly path) are recorded in the matrix `notes` of the affected registrations, not changed, unless the owner decides otherwise (OQ-4).

## 5. Tests That Pin Hooks and Mirrors

| Candidate change | Tests to run or update |
| --- | --- |
| New Codex hook file under `.codex/hooks` plus bundle copy | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (add the name to `PreToolHookNames`/`AllHookNames` or `SharedModuleNames`; parse check, 500-line cap, root/bundle byte identity, stdin read, no `$env:CLAUDE_`, core manifest listing); `codex-pretooluse-integration.Tests.ps1` (derives handlers from `config.toml`; every handler must allow a benign payload for every tool name its matcher admits and fail closed with exit 2 on malformed input); `hook-dependency-failure.Codex.Tests.ps1`; `codex-epic-runtime-contracts.Tests.ps1` (`keeps hook, config, and agent files within the shared hard file-size limit`, root/bundle byte identity); `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`; `enforcement-hooks-no-python-invocation.Tests.ps1`; `hook-imported-modules-no-stdout.Tests.ps1`; `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`; `test_push_down_codex_and_agents_pack_manifest_completeness.py`; `test_push_down_pack_manifest_dependency_closure.py`; `test_codex_core_manifest_closure.py`; a new behavior suite under `tests/scripts/codex-hooks/` |
| New Codex twin of a Claude helper (`subagentstop-envelope.ps1`, `premortem-section.ps1`) | as above, plus a text-identity row per function following `file-size-policy.Tests.ps1` (`defines the same function names`, `keeps every function definition text-identical`) |
| `.codex/config.toml` `[[hooks.*]]` edits (root and bundle) | `codex-pretooluse-integration.Tests.ps1`; `codex-epic-runtime-contracts.Tests.ps1` (`uses the current nested command-handler hook schema`, `registers root provenance, attestation, planning, wave, merge, worktree, and stop gates`); `test_push_down_codex_and_agents_resource_contracts.py` (root/bundle equality and the MCP-section pins); `test_push_down_pack_manifest_dependency_closure.py`; `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` and `post-codex-worktree-session.Tests.ps1` read `config.toml` (orchestrator to confirm they are unaffected by a `[[hooks]]`-only edit) |
| `.claude/settings.json` (not in the recommended scope) | `tests/scripts/claude-runtime/claude-settings.Tests.ps1` (fifteen-agent matcher, dedicated prd-feature group, canonical/bundled byte identity), `PreToolUsePayload.Contract.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py` |
| Agent frontmatter `hooks:` (not in scope; generator-owned after child 3) | `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_claude_resource_contracts.py`, `parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`, includes `.claude/agents/epic-orchestrator.md`), child 3 generator `--check` |
| `config/harness-parity-matrix.json` hook entries | child 1 `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1`; the new hook-parity gate (section 10) |
| Extending the no-Python scan to `.github/hooks` | `enforcement-hooks-no-python-invocation.Tests.ps1` and `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (scan roots today: `.claude/hooks`, `.claude/lib`, `.codex/hooks`) |
| Execution-environment brief fact change (for example the `validate-bash` sentence) | all six copies plus `test_execution_environment_brief_contracts.py` |

CI shape: `tests/scripts/codex-hooks` runs in `poshqc / PowerShell hook suites (Linux)` and in the Windows shards; `tests/scripts/copilot-hooks` runs only in the shards.

## 6. Parity Matrix: What Child 5 Writes and What Child 1 Owns

Child 1 owns the file location, schema, `kind` enum, inventory rules, completeness test and the bootstrap. Its default for `hook-registration` is `disposition: native`, `owner_child: 5` (Copilot registrations `owner_child: 6`), `decision_status: provisional`, with `parity_group` emitted as `hook:<command-stem>` by `New-HarnessParityMatrixSkeleton` (`SCRATCH/issue-1030-child1-plan.2026-10-30T17-06.md`).

Child 5 writes, per hook-registration entry:

- `parity_group`: re-key entries whose equivalent function has a different script stem into one group (for example `hook:model-routing` for `enforce-model-routing-receipt`, `record-subagent-routing-attestation`, `enforce-codex-model-routing`, `validate-codex-subagent-routing`; `hook:epic-invocation-origin` for `enforce-epic-invocation-origin`, `authorize-root-epic-invocation`, `enforce-epic-root-invocation`; `hook:discovery-start` and `hook:discovery-stop` across all three ecosystems).
- `notes`: the gap class from section 3 for each Claude registration whose `parity_group` has no Codex member (NOT-APPLICABLE, NOT-EXPRESSIBLE, DEFER with the blocking dependency) and the recorded logic divergences from section 4.
- `decision_status: approved` and `decision_ref: #1030:<path>` once the owner approves child 5's disposition record.
- New entries for each Codex registration child 5 adds (inventoried automatically by child 1's rules from `.codex/config.toml`).
- `dropped` only with owner approval (for example if the owner removes a duplicate settings/frontmatter registration, OQ-9).

Open encoding issues the plan must re-check at Phase 0 (child 1 `id` grammar is an open preflight defect per child 3 research section 7):

- The specified `id` pattern `^(claude|codex|copilot|cross-tool):[a-z-]+:[A-Za-z0-9._@/#:+-]+$` cannot hold the matchers in use (`Write|Edit`, `^Bash$`, `^(apply_patch|Edit|Write)$`, `mcp__.*`), all of which contain characters outside the allowed class.
- The `name` form `<Event>/<matcher>/<command-stem>` collides for the seven agents registered both in `.claude/settings.json` and in frontmatter (section 1.2) and for the two `validate-required-artifact-output` commands that share the prd-feature matcher with `validate-prd-feature-output`; it also drops arguments, so the three `validate-orchestrator-output` registrations differ only by matcher.
- Copilot registrations have no matcher (empty middle segment).
- Child 5 should select entries by `ecosystem`, `kind`, `name`, `source_path` and `source_pointer`, not by parsing `id`.

Expressibility is not a schema field. Two options: (a) a `notes` prefix convention checked by child 5's gate; (b) a structured optional field (for example `parity_gap`) added by child 1 under a minor `schema_version` bump. Recommendation: (b) if child 1 has not merged when child 5 is planned, otherwise (a); owner question OQ-2.

Terminology: the issue text says "disposition shared" for hooks with equivalent function. Under child 1's `### Disposition Semantics`, `shared` means one source file mirrored to several locations, which hooks are not. Recommendation: hooks stay `native`, and "shared function" means a `parity_group` that has members in two or more ecosystems (OQ-1). The acceptance criterion "every hook whose disposition is shared has a counterpart" should be restated in those terms when the spec is written.

## 7. Interaction With Child 3 Generators and Child 2

- Agent frontmatter `hooks:` (`.claude/agents/*.md`): generator-owned after child 3 (child 3 research section 4: "the generator must reproduce `hooks:` exactly"). Child 5 must edit the generator's agent source, not the `.md` output, if it changes any Claude per-agent registration. The recommended scope changes none.
- `.codex/config.toml`: child 3 recommends that its MCP generator own only the `[mcp_servers.*]` region (child 3 research section 6, MCP-config generator row). Under that design `[[hooks.*]]` stays hand-edited and child 5 edits it directly, in root and bundle. Child 3's spec is still at template level (orchestrator to confirm at Phase 0); if child 3 takes the whole file, child 5 edits the generator source instead.
- `.codex/agents/*.toml`: generator-owned after child 3; they hold no hook registrations, so no child 5 edit.
- `.claude/settings.json`: not generated by child 3; child 2 edits its `permissions` allow literals (D-16 `SETTINGS_ALLOW_RULES`). Child 5's recommended scope does not edit it.
- Child 2 D-16 governs `-RequiredArtifact` hook arguments (`REQUIRED_ARTIFACT_RULES`). A Codex registration of `validate-required-artifact-output.ps1` with docs-root arguments must carry the expanded pattern from `expandRequiredArtifactPattern` and be covered by child 2's write-scope checker. Orchestrator to confirm whether the checker scans `.codex/config.toml`; if not, child 5 needs either a checker extension (TypeScript, child 2's module) or a Pester assertion against the same rule table (owner question OQ-10).
- Child 2 publishes `.claude/lib/development-docs` to `.codex/lib/development-docs` through `VIRTUAL_RESOURCE_DIRECTORIES`. A Codex `enforce-feature-folder-order.ps1` must resolve the docs root through that module (published path first, self-hosted `.claude/lib` second), as the discovery hooks do.
- Library availability: Codex destinations do not receive `.claude/lib` (`.codex/hooks/file-size-policy.ps1` header: "Codex hooks cannot import .claude/lib in a consumer repository"). The two repository precedents are a text-identical twin under `.codex/hooks` with a parity test, and publication under `.codex/lib/<name>` through `VIRTUAL_RESOURCE_PAIRS`/`VIRTUAL_RESOURCE_DIRECTORIES` in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` and its Python twin. Publication edits push-down code that child 4 consolidates; that is why the lib-dependent ports are DEFER.

## 8. Parallel-Run Blast Radius

Files in the run `bugs-1001-1002-1003-1006` (`SCRATCH/issue-1030-parallel-manifest.md`) that the recommended scope would also touch or read as a pinned contract:

- `.codex/config.toml` (#1009, #1010) and its bundle copy.
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (#1009, #1010).
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (#1009, #1010), `codex-pretooluse-integration.Tests.ps1` (#1009), `hook-dependency-failure.Codex.Tests.ps1` (#1009).
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (#1001, #1009, #1011, #1012), `hook-dependency-guard-completeness.Tests.ps1` (#1009, #1010, #1011, #1012).
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py` (#1010).
- `.claude/settings.json` (#1002, #1009, #1010, #1012), not edited in the recommended scope.
- The hook scripts named by the caller (merge gate, model-routing receipt, pr-author skill and allowlist, batch budgets, preimplementation gate, orchestrator output, `hook-target-worktree.ps1`), all excluded from child 5's edit set; #1012 also adds `.claude/hooks/validate-orchestrator-output-rejection.ps1`, which is not yet on `main`.

Recommendation: defer all execution until the run has merged (the epic's `## Execution Preconditions` already requires this, and child 5 is wave 2 behind child 3). Do not edit any of the listed hook scripts in child 5. The Phase 0 gate re-checks every named file, symbol and heading against the merge base of `origin/main` and `HEAD` and stops for re-planning on any change.

## 9. Language Classification

Owner rule (verbatim): "Avoid new Python (existing Python is tolerated: reuse, call or extend in place only). The language depends on where the new code runs: (1) anything pushed down to destination repos, meaning skills, skill helpers, hooks and libs, must be PowerShell or bash, never TypeScript and never Python; (2) TypeScript is ONLY for MCP commands (tools in the MCP server package) and extension commands." Exception E2: a language-native analyzer is allowed when it analyzes that same language and ships only with that language's pack; PowerShell remains the baseline. Enforcement hooks must not invoke Python.

| Artifact | Runs where | Classification |
| --- | --- | --- |
| New Codex hooks (`enforce-feature-folder-order.ps1`, SubagentStop validators) and their bundle copies | pushed down | PowerShell; no Python invocation |
| Codex twins of `subagentstop-envelope.ps1` and `premortem-section.ps1` | pushed down | PowerShell |
| `.codex/config.toml` `[[hooks.*]]` entries (root and bundle) | pushed down | configuration data (TOML); commands invoke `pwsh` only |
| Codex `core.json` pack-manifest entries | pushed down manifest | JSON data |
| `config/harness-parity-matrix.json` hook entries | repository only (not bundled per child 1) | JSON data |
| Child 5 disposition record under the feature folder | repository docs | Markdown |
| Hook-parity repository gate and new behavior suites | CI | Pester (PowerShell) |
| Cross-tree helper identity test | CI | Pester |
| No-Python scan extension to `.github/hooks` | CI | Pester (edit in place) |
| Existing Python contract tests (`test_push_down_*`) | CI | existing Python, run; edit in place only if an expected list must change |
| Publication of `.claude/lib` modules to `.codex/lib` (only if the owner moves a DEFER item into child 5) | extension push-down | TypeScript in `codex-agents-customizations.ts` plus the existing Python twin extended in place; belongs to child 4 |

E2: not applicable (no analyzer). No artifact in the recommended scope requires a language outside the rule. The only case that touches the rule's boundary is the lib publication in the last row, which is a push-down (extension) change rather than a hook; it is raised as OQ-3 rather than decided here.

## 10. Recommended Approach

### Candidates

| Approach | Description | Assessment |
| --- | --- | --- |
| A. Matrix-first, minimal ports (recommended) | Record dispositions and gap classes for every hook registration; add Codex counterparts only where the event and payload are verified and the port needs no `.claude/lib` module; pin cross-tree helper identity; defer lib-dependent and blast-radius-bound gates | Fits the C3 band, avoids push-down edits (child 4), avoids the parallel run's files, satisfies "Codex gains a hook only where its system can express the behavior" |

Rejected alternatives: (B) port every expressible Claude gate including lib-dependent ones, which requires `.codex/lib` publication in push-down code owned by child 4 and edits files in the parallel run's blast radius; (C) a shared single-source hook body generated into both trees, which re-opens the settled design ("Hooks, permissions, subagent frontmatter: Native; parity of function").

### Phases

- **Phase 0, re-check gate** (evidence `<FEATURE>/evidence/baseline/phase0-gate.<timestamp>.md`):
  1. Parallel run `bugs-1001-1002-1003-1006` merged to `main` (all items, orchestrator via `gh`).
  2. Child 1 merged: matrix and schema exist; `schema_version` major 1; record the final `id` grammar and `name` form for `hook-registration`, how matchers with `|^$()*` and duplicate settings/frontmatter registrations are encoded, whether a structured gap field exists (OQ-2), and the Q6 answer.
  3. Child 3 merged: confirm which file regions are generator-owned (agent frontmatter `hooks:`; whether any part of `.codex/config.toml` outside `[mcp_servers.*]` is generated).
  4. Child 2 merged: `.codex/lib/development-docs` published path, PowerShell resolver function names, and whether the D-16 checker covers `.codex/config.toml` hook arguments.
  5. Codex payload facts: `spawn_agent` argument field names under the `Agent` matcher and presence of `agent_type` in subagent PreToolUse payloads (owner-run Codex check or a child 1 runbook result); ADD-CONDITIONAL rows proceed only on a recorded positive result.
  6. Edit-set re-check against the merge base: every file, function and test name in this research, the line counts of Codex hooks near the 500-line cap, and the cross-tree identical-helper set by hash.
  Stop for one plan revision on any mismatch (owner decision E3).
- **Phase 1, dispositions and gate:** update every `hook-registration` entry (section 6); write the child 5 disposition record in the feature folder (decision_ref target); add the hook-parity repository gate (Pester) asserting that each Claude `hook-registration` `parity_group` either has a Codex member or carries a recorded gap class, and that no Codex `parity_group` is unmatched without a Codex-native note; add the cross-tree helper identity test.
- **Phase 2, Codex SubagentStop validators (ADD):** Codex twins of `subagentstop-envelope.ps1` and `premortem-section.ps1` with text-identity rows; Codex `validate-planner-output.ps1`, `validate-task-researcher-output.ps1`, `validate-executor-output.ps1`, `validate-prd-feature-output.ps1`, `validate-pr-author-output.ps1`, `validate-required-artifact-output.ps1` (each honoring `stop_hook_active` with one continuation, as `legacy-codex-hook-contracts.Tests.ps1` `uses one SubagentStop continuation and stops repeated continuation loops` requires of Codex stop hooks); `[[hooks.SubagentStop]]` registrations with matchers that admit the generated variants; bundle copies; core manifest entries; behavior suites under `tests/scripts/codex-hooks/`. Precondition: child 3 generates Codex and Claude agent bodies from one definition, so the output envelope the validators check is the same in both (OQ-7).
- **Phase 3, Codex PreToolUse (ADD):** Codex `enforce-feature-folder-order.ps1` in the `^(apply_patch|Edit|Write)$` group using the apply_patch mapping and the child 2 resolver.
- **Phase 4, conditional (ADD-CONDITIONAL, only with a positive Phase 0 item 5):** register the existing Codex preimplementation gate on the Codex `Agent` group; port the pr-author Bash allowlist as a session-level `^Bash$` hook filtered on `agent_type`.
- **Phase 5, Copilot and no-Python:** record Copilot dispositions (`native`, `owner_child` 6); extend the no-Python scan roots to `.github/hooks`.
- **Out of scope (recorded as DEFER with reason):** `enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `validate-orchestrator-output` (all three forms), `enforce-pr-author-skill`. Owner decides whether child 4's lib publication brings them into a later child (OQ-3).

Batch budget: Phase 2 alone creates more than three PowerShell production files in one worktree (each bundle copy counts). The plan needs the `large` route checkpoint in the item worktree or a phase split across sessions (brief `## Batch Budget`).

## 11. Module, Tier and File-Size Notes

- `quality-tiers.yml` exists. `.codex/hooks` is classified T3 and is a discovered project under rule R5 (`scripts/dev_tools/quality_tiers_contract.py`), so new files there need no tier entry. A new `.claude/lib/<name>` folder (R4) or a `scripts/<name>` folder (R3) would need an entry in the same change; the recommended scope creates neither. `.codex/lib/<name>` is not a discovery rule unless it holds a same-stem `.psd1`/`.psm1` pair (R2). If the hook-parity gate needs a production module rather than test-only logic, place it in child 1's `scripts/harness/` (classified by child 1) rather than a new folder.
- `config/file-size-baseline.json` has no entry under `.claude/hooks` or `.codex/hooks` (Grep for `hooks`). No hook exceeds 800 lines.
- Codex hooks listed in `legacy-codex-hook-contracts.Tests.ps1` are capped at 500 lines. Line counts (Grep line count; orchestrator to confirm with `wc -l`): `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` 500, `-modes.ps1` 493, `-epic-resolution.ps1` 493, `enforce-completion-consistency.ps1` 491. These have no headroom; the recommended scope does not edit them (Phase 4's Agent registration is a `config.toml` change only).
- Claude sources for the Phase 2 ports: `validate-planner-output.ps1` 454, `validate-executor-output.ps1` 450, `validate-task-researcher-output.ps1` 310, `validate-required-artifact-output.ps1` 201, `subagentstop-envelope.ps1` 192, `premortem-section.ps1` 149, `validate-prd-feature-output.ps1` 120, `validate-pr-author-output.ps1` 131; `enforce-feature-folder-order.ps1` 287. A Codex twin that adds payload handling to a 450-line source approaches the 500 cap; new Codex-specific logic goes into a separate file.
- Claude batch-budget hooks are 532 and 535 lines (above the 500 guidance tier); not edited here.

## 12. Requirements Mapping (draft for prd-feature)

| Issue AC | Design |
| --- | --- |
| Every registration has a disposition and the completeness test passes | Child 1's inventory and completeness test produce the entries; child 5 sets `parity_group`, gap class, `decision_status`, `decision_ref`; child 1 RepoGate plus child 5 hook-parity gate pass |
| Every hook whose function is shared has a counterpart where expressible, with an equivalence test | Restate as `parity_group` with members in two or more ecosystems (OQ-1); each Phase 2/3 Codex hook gets a behavior suite running the same decision cases as the Claude suite on equivalent payloads |
| No enforcement hook invokes Python | Existing scan plus `.github/hooks` scan root |
| Bundled mirrors and parity tests green | Section 5 test list |

## Numeric Derivation Evidence

No numeric count, enumeration or population is proposed for a `spec.md` acceptance criterion. Counts in this document (registration rows, line counts, function counts) are informational. Acceptance criteria should be stated against the set enumerated at execution time by child 1's inventory module, not against a fixed number.

## Testing Implications

- Unit (Pester): one behavior suite per new Codex hook, using in-memory payloads and injected seams; decision cases mirrored from the Claude suites (for example `tests/scripts/claude-hooks/validate-planner-output*.Tests.ps1`) with Codex envelopes built like `ConvertTo-CodexPreToolPayload` in `legacy-codex-hook-contracts.Tests.ps1`.
- Parity: text-identity rows for twinned helpers; cross-tree identity test for unchanged shared helpers.
- Matrix: hook-parity repository gate over `config/harness-parity-matrix.json`, read-only, no git history, runs in the PowerShell shards.
- Integration: `codex-pretooluse-integration.Tests.ps1` picks up new PreToolUse handlers from `config.toml` automatically.
- Coverage: PowerShell line coverage at least 85% per changed hook file from `artifacts/pester/powershell-coverage.xml`; `.codex/hooks` is already a coverage root.
- Isolation: three seeded shuffled file-order runs of `tests/scripts/codex-hooks` and the touched harness suites, plus one fresh single-process run over `tests/scripts`.

## Open Owner Questions

| ID | Question | Recommended default |
| --- | --- | --- |
| OQ-1 | Hooks with equivalent function: keep `native` with a common `parity_group` (child 1 semantics), rather than `shared`? | Yes; restate the issue AC accordingly |
| OQ-2 | Record expressibility gaps as a structured optional matrix field (child 1 minor schema bump) or as a `notes` prefix? | Structured field if child 1 has not merged; otherwise `notes` prefix |
| OQ-3 | Codex ports that need `.claude/lib` modules (`enforce-prd-feature-before-planner`, `enforce-mermaid-validation`, `validate-orchestrator-output`, `enforce-pr-author-skill`): defer until child 4 decides `.codex/lib` publication, or twin the modules under `.codex/hooks`? | Defer; publication belongs to child 4 |
| OQ-4 | Codex `validate-bash.ps1` omits the cd-chained read leg by design, while the brief names the function for both paths. Add the leg to Codex, or correct the brief (six copies)? | Correct the brief text; keep the Codex omission unless a Codex prompt-approval problem is shown |
| OQ-5 | Feature-review coverage hooks read only root `CLAUDE.md` (child 3 OQ-7). In a Codex-only destination, should they also read `AGENTS.md`? | Yes for the Codex hook, after child 3 settles `AGENTS.md` content; otherwise unchanged |
| OQ-6 | The VS Code page states the Copilot harness reads `.claude/settings.json` hooks. Are Claude hooks expected to run in Copilot sessions, or must child 6 prevent it? | Child 1 experiment and child 6 decision; child 5 records only |
| OQ-7 | Enable Codex SubagentStop validators only after child 3 generates both agent bodies from one definition? | Yes |
| OQ-8 | Is a Codex counterpart of `enforce-pr-author-skill` wanted, given Codex PR authoring uses its own receipts? | Not in child 5; record DEFER |
| OQ-9 | Keep the duplicate SubagentStop registrations in both `.claude/settings.json` and agent frontmatter for the seven agents in section 1.2, or drop one copy? | Keep until E5 shows whether both fire; any drop needs an owner decision |
| OQ-10 | Should child 2's D-16 checker cover `-RequiredArtifact` arguments in `.codex/config.toml`, or does child 5 add a Pester assertion against the same rule table? | Extend child 2's checker if it has not merged; otherwise a Pester assertion |

## Items for the Orchestrator to Confirm

- The parallel run's merge state and that every named file, function and heading is unchanged at the merge base.
- Byte identity of the same-size helper pairs in section 4 (`git hash-object`).
- Physical line counts of the Codex hooks near 500 lines (`wc -l`).
- Whether frontmatter `SubagentStop` entries fire in addition to settings entries (child 1 E5).
- Codex `spawn_agent` argument field names and `agent_type` presence in subagent PreToolUse payloads.
- Child 3's final ownership of `.codex/config.toml` regions.
- That `Invoke-FullRelease.Tests.ps1` and `post-codex-worktree-session.Tests.ps1` are unaffected by a `[[hooks]]`-only change.

## Pre-Mortem

- Review checklists: a reviewer may find that a new Codex hook lacks the guarded dot-source pattern, the payload-anomaly or fail-closed path, or a matrix entry; mitigation: the plan's per-hook task list names `hook-dependency-guard-completeness.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, child 1's RepoGate and the child 5 hook-parity gate as acceptance for each port.
- Coverage: a new Codex hook below 85% line coverage, or entry-point lines left unexecuted; mitigation: decision logic in testable functions with an `Invoke-*EntryPoint` wrapper as in existing Codex hooks, per-file figures read from `artifacts/pester/powershell-coverage.xml` and recorded under `<FEATURE>/evidence/qa-gates/`.
- Mirror parity: a root hook, `config.toml` or `core.json` change without its bundle counterpart fails `legacy-codex-hook-contracts.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1` and `test_push_down_codex_and_agents_resource_contracts.py`; mitigation: each root edit task is paired with its bundle task and those tests run after each phase; any brief fact change (OQ-4) updates all six copies in the same change and runs `test_execution_environment_brief_contracts.py`.
- File size: a Codex twin of a 450-line Claude validator crosses the 500-line cap in `legacy-codex-hook-contracts.Tests.ps1`; an edit to the 500-line Codex preimplementation gate fails immediately; mitigation: Codex-specific logic in a separate file, no edits to Codex files at 490 lines or more, Phase 0 recount.
- Test isolation: new suites that import hooks leak functions, mocks or `$script:` state across files in the single-process shard run; mitigation: `AfterAll` removal of imported functions and modules, no temporary files, three seeded shuffled file-order runs plus a fresh single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/codex-hooks` on a case-sensitive file system, and `codex-pretooluse-integration.Tests.ps1` spawns `pwsh` per admitted tool name; mitigation: `Join-Path`, forward-slash relative fixtures, exact file-name case, no drive letters, and a benign-payload allow path for every tool name each new matcher admits.
- Evidence: ADD-CONDITIONAL work proceeds without a recorded Codex payload verification, or a Phase 0 item is asserted without a command record; mitigation: Phase 0 evidence file with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary` per check, `SCRATCH` used for scratch paths, and Phase 4 gated on a recorded positive result.
