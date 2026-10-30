# Research: Hook Parity Across Claude Code, Codex and GitHub Copilot (Issue #1030)

- Issue: #1030 (epic #1018, child 5)
- Branch: `feature/hook-parity-across-claude-codex-copilot-1030`
- Research type: preparation only; nothing is implemented.
- Tree state: the working tree's code is identical to `origin/main`; only epic documents differ.
- Timestamp source: UTC read from an external clock service immediately before writing (the researcher has no shell clock).

Inputs read: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/issue.md`; `docs/features/epics/shared-agent-harness-layer/epic.md` (`## Scope` child 5, `## Dependency Rationale`, `## Shared Design`, `## Execution Preconditions`); the child 1 spec on branch `feature/harness-survey-gold-standard-contracts-parity-matrix-1025` (sections `### Parity Matrix: Feature Entry`, `### Parity Matrix: Feature Kinds and Inventory Rules`, `### Default Dispositions`, `### Disposition Semantics`, `## Open Owner Questions` Q6); the parallel-run manifest `bugs-1001-1002-1003-1006`. The promoted epic record is treated as settled and is not re-opened.

---

## 1. Current State: Hook Registration Inventory

### 1.1 Surfaces and file counts

| Surface | Registration source | Hook script folder | Script files on this tree |
| --- | --- | --- | --- |
| Claude Code | `.claude/settings.json` `hooks`; `hooks:` in `.claude/agents/*.md` frontmatter | `.claude/hooks/` | 75 `*.ps1` |
| Codex | `[[hooks.<Event>]]` tables in `.codex/config.toml` only | `.codex/hooks/` | 51 `*.ps1` |
| GitHub Copilot | `.github/hooks/discovery.json` | `.github/hooks/` | 5 `*.ps1` plus `discovery.json` |

- The issue and spec state 50 Codex hook files. The tree holds 51; the difference is `.codex/hooks/hook-target-worktree.ps1`, whose synopsis names issue #1009 (merged through pull request #1017 per the recent commit list). Counts in this record are informational only (see `## Numeric Derivation Evidence`).
- No `.codex/agents/*.toml` file declares a hook; the 53 files that contain the word `hooks` mention it in prose only (for example `.codex/agents/orchestrator.toml`, `.codex/agents/epic-planner.toml`). The Codex hook documentation names only `hooks.json`, inline `[hooks]` in `config.toml`, plugin bundles and managed `requirements.toml` as hook locations (source in section 2.4).
- Codex hooks in this repository also load PowerShell from `.codex/scripts/` (`epic-child-launch-contract.ps1`, dot-sourced by `.codex/hooks/codex-epic-child-launch-attestation.ps1` and `.codex/hooks/enforce-epic-child-worktree-binding.ps1`) and, in self-hosting mode, from `.claude/lib/discovery-validation/` (discovery hooks; published destinations use `.codex/lib/discovery-validation`).
- Copilot hooks load `.claude/lib/discovery-validation/*.psm1` by relative path from `.github/hooks/`.

### 1.2 Registration counts per surface (informational)

| Surface | Registrations | Distinct scripts registered |
| --- | --- | --- |
| `.claude/settings.json` | 39 | 34 |
| `.claude/agents/*.md` frontmatter (12 agent files) | 14 | 9 |
| `.codex/config.toml` | 27 | 25 |
| `.github/hooks/discovery.json` | 4 | 4 |

Unregistered scripts (helpers, probes) are implementation and are excluded from the matrix under child 1's working assumption for Q6 (`### Parity Matrix: Feature Kinds and Inventory Rules`, exclusion list). Examples: `.claude/hooks/discovery-capability-probe.ps1`, `.codex/hooks/discovery-capability-probe.ps1`, `.github/hooks/discovery-capability-probe.ps1` (run by `scripts/dev-tools/Test-DiscoveryHostCapability.ps1`), and every `*-helpers.ps1`, `hook-command-*.ps1`, `subagentstop-envelope.ps1`, `premortem-section.ps1`.

### 1.3 Claude Code: `.claude/settings.json` (39 registrations)

Function text comes from each script's top-level `.SYNOPSIS`.

| Ref | Event / matcher | Script | Function |
| --- | --- | --- | --- |
| CS01 | SessionStart / (none) | `persist-session-id.ps1` | Persists the current Claude Code session id |
| CS02 | PreToolUse / `Bash` | `validate-bash.ps1` | Blocks dangerous Bash commands |
| CS03 | PreToolUse / `Bash` | `enforce-promotion-mcp-only.ps1` | Blocks Bash promotion-script bypass attempts |
| CS04 | PreToolUse / `Bash` | `enforce-pr-author-skill.ps1` | Requires the pr-author skill before `gh pr create` or `gh pr edit` |
| CS05 | PreToolUse / `Bash` | `enforce-orchestration-preimplementation-gate.ps1` | Blocks implementation operations before orchestration readiness |
| CS06 | PreToolUse / `Bash` | `enforce-epic-merge-gate.ps1` | Gates pull-request merge or merge-queue enqueue behind checkpoint state |
| CS07 | PreToolUse / `Bash` | `enforce-epic-worktree-removal-gate.ps1` | Gates `git worktree remove` behind epic checkpoint merge state |
| CS08 | PreToolUse / `Bash` | `enforce-parallel-worktree-removal-gate.ps1` | Gates `git worktree remove` behind parallel checkpoint merge state |
| CS09 | PreToolUse / `Bash` | `enforce-parallel-abandon-gate.ps1` | Gates the parallel abandon disposition behind a confirmation marker |
| CS10 | PreToolUse / `Write\|Edit` | `check-python-test-purity.ps1` | Blocks forbidden patterns in Python unit tests |
| CS11 | PreToolUse / `Write\|Edit` | `enforce-python-batch-budget.ps1` | Routes more than three Python production files to the large path |
| CS12 | PreToolUse / `Write\|Edit` | `check-powershell-test-purity.ps1` | Blocks forbidden patterns in PowerShell unit tests |
| CS13 | PreToolUse / `Write\|Edit` | `enforce-powershell-batch-budget.ps1` | Routes more than three PowerShell production files to the large path |
| CS14 | PreToolUse / `Write\|Edit` | `enforce-evidence-locations.ps1` | Blocks writes to non-canonical evidence locations |
| CS15 | PreToolUse / `Write\|Edit` | `enforce-file-size-limit.ps1` | Blocks a write leaving a covered file above 800 lines |
| CS16 | PreToolUse / `Write\|Edit` | `enforce-orchestration-preimplementation-gate.ps1` | As CS05, file-edit leg |
| CS17 | PreToolUse / `Write\|Edit` | `enforce-feature-folder-order.ps1` | Blocks plan writes until the work mode's prerequisite documents exist |
| CS18 | PreToolUse / `Write\|Edit` | `enforce-checkpoint-monotonic.ps1` | Blocks checkpoint writes whose `completed_steps` are out of canonical order |
| CS19 | PreToolUse / `Write\|Edit` | `enforce-completion-consistency.ps1` | Blocks checkpoint writes asserting completion without evidence |
| CS20 | PreToolUse / `Write\|Edit` | `enforce-mermaid-validation.ps1` | Blocks Mermaid diagrams with named structural defects |
| CS21 | PreToolUse / `Bash\|Write\|Edit\|MultiEdit\|NotebookEdit\|Agent\|Task\|WebFetch\|WebSearch\|mcp__.*` | `enforce-discovery-artifact-gate.ps1` | Discovery-agent PreToolUse authorization adapter |
| CS22 | PreToolUse / `Agent` | `enforce-prd-feature-before-planner.ps1` | Blocks atomic-planner delegation until prd-feature outputs exist |
| CS23 | PreToolUse / `Agent` | `enforce-discovery-planning-gate.ps1` | Gates planner and orchestrator delegations on discovery authority |
| CS24 | PreToolUse / `Agent` | `enforce-orchestration-preimplementation-gate.ps1` | As CS05, delegation leg |
| CS25 | PreToolUse / `Agent` | `enforce-epic-wave-barrier.ps1` | Layer 1 deterrent for the epic wave barrier |
| CS26 | PreToolUse / `Agent` | `enforce-model-routing-receipt.ps1` | Blocks a gated delegation without a model-routing receipt |
| CS27 | PreToolUse / `Agent` | `enforce-epic-invocation-origin.ps1` | Blocks epic/parallel planner and orchestrator delegations from a non-root caller |
| CS28 | PreToolUse / `Agent` | `enforce-parallel-cohort-barrier.ps1` | Layer 1 deterrent for the parallel cohort barrier |
| CS29 | PreToolUse / `Agent` | `enforce-parallel-drift-gate.ps1` | Layer 1 deterrent for the parallel drift gate |
| CS30 | SubagentStart / four discovery agents | `record-discovery-agent-start.ps1` | Discovery SubagentStart attestation adapter |
| CS31 | SubagentStop / fifteen core agents | `validate-discovery-artifact-gate.ps1` | Discovery stop validation; allows non-discovery agents (script `.DESCRIPTION`) |
| CS32 | SubagentStop / four discovery agents | `validate-discovery-artifact-gate.ps1` | As CS31 for discovery specialists |
| CS33 | SubagentStop / `feature-review` | `validate-feature-review-coverage.ps1` | Validates feature-review artifacts and coverage verdicts |
| CS34 | SubagentStop / `atomic-planner` | `validate-planner-output.ps1` | Validates planner output, plan path and Pre-Mortem |
| CS35 | SubagentStop / `prd-feature` | `validate-prd-feature-output.ps1` | Validates numeric acceptance criteria from prd-feature |
| CS36 | SubagentStop / `pr-author` | `validate-pr-author-output.ps1` | Verifies pr-author reported a created or updated PR |
| CS37 | SubagentStop / `orchestrator` | `validate-orchestrator-output.ps1` | Orchestrator stop validation |
| CS38 | SubagentStop / `epic-orchestrator` | `validate-orchestrator-output.ps1 -CheckpointPath ... -ArtifactType epic-orchestrator-state` | As CS37 for the epic checkpoint |
| CS39 | SubagentStop / `parallel-orchestrator` | `validate-orchestrator-output.ps1 -CheckpointPath ... -ArtifactType parallel-orchestrator-state` | As CS37 for the parallel checkpoint |

### 1.4 Claude Code: agent frontmatter (14 registrations in 12 files)

| Ref | Agent file | Event / matcher | Script | Duplicate of settings entry |
| --- | --- | --- | --- | --- |
| CF01 | `.claude/agents/atomic-executor.md` | SubagentStop / `atomic-executor` | `validate-executor-output.ps1` (validates executor output) | no |
| CF02 | `.claude/agents/atomic-planner.md` | SubagentStop / `atomic-planner` | `validate-planner-output.ps1` | CS34 |
| CF03 | `.claude/agents/epic-orchestrator.md` | SubagentStop / `epic-orchestrator` | `validate-orchestrator-output.ps1` (epic args) | CS38 |
| CF04 | `.claude/agents/epic-review.md` | SubagentStop / `epic-review` | `validate-required-artifact-output.ps1 -AgentName epic-review ...` (generic required-artifact check) | no |
| CF05 | `.claude/agents/feature-review.md` | SubagentStop / `feature-review` | `validate-feature-review-coverage.ps1` | CS33 |
| CF06 | `.claude/agents/orchestrator.md` | SubagentStop / `orchestrator` | `validate-orchestrator-output.ps1` | CS37 |
| CF07 | `.claude/agents/parallel-orchestrator.md` | SubagentStop / `parallel-orchestrator` | `validate-orchestrator-output.ps1` (parallel args) | CS39 |
| CF08 | `.claude/agents/pr-author.md` | PreToolUse / `Bash` | `enforce-pr-author-command-allowlist.ps1` (limits pr-author Bash to an allowlist) | no |
| CF09 | `.claude/agents/pr-author.md` | SubagentStop / `pr-author` | `validate-pr-author-output.ps1` | CS36 |
| CF10 | `.claude/agents/prd-feature.md` | SubagentStop / `prd-feature` | `validate-required-artifact-output.ps1 -AgentName prd-feature ...` | no |
| CF11 | `.claude/agents/prd-feature.md` | SubagentStop / `prd-feature` | `validate-prd-feature-output.ps1` | CS35 |
| CF12 | `.claude/agents/staged-review.md` | SubagentStop / `staged-review` | `validate-required-artifact-output.ps1 -AgentName staged-review ...` | no |
| CF13 | `.claude/agents/status-updater.md` | SubagentStop / `status-updater` | `validate-required-artifact-output.ps1 -AgentName status-updater ...` | no |
| CF14 | `.claude/agents/task-researcher.md` | SubagentStop / `task-researcher` | `validate-task-researcher-output.ps1` (research path and Pre-Mortem) | no |

Seven frontmatter registrations (CF02, CF03, CF05, CF06, CF07, CF09, CF11) repeat a settings registration with the same event, matcher and script. Whether both fire for one stop is not documented: the Claude Code subagent documentation (fetched 2026-10-30 from `https://code.claude.com/docs/en/sub-agents`, section on hooks in subagents) documents frontmatter `Stop` as converted to `SubagentStop`, states "All hook events are supported", and does not state whether a `SubagentStop` declared directly in frontmatter fires or how it combines with a settings `SubagentStop` for the same agent. This is a child 1 E5 item; see Owner Question O3.

### 1.5 Codex: `.codex/config.toml` (27 registrations)

| Ref | Event / matcher | Script | Function |
| --- | --- | --- | --- |
| XS01 | UserPromptSubmit / (none) | `authorize-root-epic-invocation.ps1` | Records a bounded root-session authorization receipt for epic personas |
| XS02 | SubagentStart / core plus discovery agents (`...\|typed-engineer\|-c\|...`) | `record-subagent-routing-attestation.ps1` | Records subagent identity, model, routing and epic-root provenance; dot-sources `discovery-start-attestation.ps1` |
| XS03 | PreToolUse / `^Bash$` | `validate-bash.ps1` | Blocks dangerous shell commands |
| XS04 | PreToolUse / `^Bash$` | `enforce-promotion-mcp-only.ps1` | Blocks promotion-script bypass |
| XS05 | PreToolUse / `^Bash$` | `enforce-orchestration-preimplementation-gate.ps1` | Preimplementation gate, command leg |
| XS06 | PreToolUse / `^Bash$` | `enforce-epic-merge-gate.ps1` | Gates epic child and integration merges |
| XS07 | PreToolUse / `^Bash$` | `enforce-epic-worktree-removal-gate.ps1` | Gates worktree removal until the epic feature merged |
| XS08 | PreToolUse / `^(Bash\|shell_command\|apply_patch\|Edit\|Write\|mcp__.*)$` | `enforce-discovery-artifact-gate.ps1` | Discovery-agent authorization adapter |
| XS09 | same | `enforce-epic-root-invocation.ps1` | Denies epic-persona mutations without root provenance |
| XS10 | same | `enforce-codex-model-routing.ps1` | Denies subagent mutations when model/profile does not match routing |
| XS11 | same | `enforce-epic-planning-only.ps1` | Enforces the planning-only boundary for the preparation route |
| XS12 | same | `enforce-epic-wave-barrier.ps1` | Denies child mutations before dependencies are merged |
| XS13 | same | `enforce-epic-child-worktree-binding.ps1` | Denies epic-child mutations outside the launch-authorized worktree |
| XS14 | PreToolUse / `^(apply_patch\|Edit\|Write)$` | `check-python-test-purity.ps1` | Python test purity |
| XS15 | same | `enforce-python-batch-budget.ps1` | Python batch budget |
| XS16 | same | `check-powershell-test-purity.ps1` | PowerShell test purity |
| XS17 | same | `enforce-powershell-batch-budget.ps1` | PowerShell batch budget |
| XS18 | same | `enforce-evidence-locations.ps1` | Evidence locations |
| XS19 | same | `enforce-file-size-limit.ps1` | File-size hard limit |
| XS20 | same | `enforce-orchestration-preimplementation-gate.ps1` | Preimplementation gate, file-edit leg |
| XS21 | same | `enforce-checkpoint-monotonic.ps1` | Checkpoint step ordering |
| XS22 | same | `enforce-completion-consistency.ps1` | Completion evidence consistency |
| XS23 | PreToolUse / `^(Agent\|Task\|spawn_agent\|run_subagent\|delegate)$` | `enforce-discovery-artifact-gate.ps1` | As XS08, delegation leg |
| XS24 | same | `enforce-discovery-planning-gate.ps1` | Gates planner and orchestrator launches on discovery authority |
| XS25 | SubagentStop / core plus discovery agents | `validate-codex-subagent-routing.ps1` | Requests continuation when a routed subagent stops without valid model or epic provenance |
| XS26 | SubagentStop / four discovery agents | `validate-discovery-agent-output.ps1` | Discovery stop validation |
| XS27 | SubagentStop / `feature-review\|feature-reviewer` | `validate-feature-review-coverage.ps1` | Feature-review coverage verdicts |

### 1.6 GitHub Copilot: `.github/hooks/discovery.json` (4 registrations)

`discovery.json` uses `"version": 1` with `powershell` and `bash` command keys (both `pwsh -NoProfile -File ...`) and no matcher field.

| Ref | Event | Script | Function |
| --- | --- | --- | --- |
| GH01 | SubagentStart | `discovery-agent-start.ps1` | Discovery SubagentStart attestation adapter (VS Code local harness) |
| GH02 | PreToolUse | `discovery-pre-tool.ps1` | Discovery PreToolUse authorization adapter |
| GH03 | PreToolUse | `discovery-planning.ps1` | Gates planner and orchestrator launches on discovery authority |
| GH04 | SubagentStop | `discovery-agent-stop.ps1` | Discovery SubagentStop output validation adapter |

---

## 2. Parity Groups, Expressibility and Proposed Dispositions

### 2.1 Disposition vocabulary (alignment finding)

The issue uses "shared" to mean a function present in more than one ecosystem. The child 1 spec (`### Disposition Semantics`) defines `shared` as "the feature's location is the single source used by more than one ecosystem; `target_paths` lists the native locations it is mirrored to". A Claude hook and its Codex counterpart are two files with different entry adapters, not one mirrored source, so under child 1's schema each registration is `native` and function parity is carried by a common `parity_group`. Recommendation for the spec: state that a "shared function" is a `hook:<function>` parity group with members in two or more ecosystems, that each registration's `disposition` follows child 1's semantics (`native`, or `generated` where child 3's generator writes the registering file), and that `shared` is used only if a single source file is published unchanged to both runtimes. Owner Question O1 records this.

### 2.2 Parity group table

Legend: C = Claude registration refs, X = Codex refs, G = Copilot refs. "Expressible" is judged against the Codex hook documentation in section 2.4.

| Parity group | C | X | G | Codex status | Expressible in Codex | Proposed disposition and reason |
| --- | --- | --- | --- | --- | --- | --- |
| `hook:validate-bash` | CS02 | XS03 | - | present | yes | native in each; function in both |
| `hook:promotion-mcp-only` | CS03 | XS04 | - | present | yes | native in each |
| `hook:preimplementation-gate` | CS05, CS16, CS24 | XS05, XS20 | - | delegation leg not registered | yes (`spawn_agent` matches `Agent`); the Codex script already classifies delegations (`enforce-orchestration-preimplementation-gate.ps1`, delegation leg, issue #554) | native; add a Codex registration on the delegation matcher (Section 8) |
| `hook:epic-merge-gate` | CS06 | XS06 | - | present | yes | native in each |
| `hook:epic-worktree-removal-gate` | CS07 | XS07 | - | present | yes | native in each |
| `hook:python-test-purity` | CS10 | XS14 | - | present | yes | native in each |
| `hook:python-batch-budget` | CS11 | XS15 | - | present | yes | native in each |
| `hook:powershell-test-purity` | CS12 | XS16 | - | present | yes | native in each |
| `hook:powershell-batch-budget` | CS13 | XS17 | - | present | yes | native in each |
| `hook:evidence-locations` | CS14 | XS18 | - | present | yes | native in each |
| `hook:file-size-limit` | CS15 | XS19 | - | present | yes | native in each |
| `hook:checkpoint-monotonic` | CS18 | XS21 | - | present | yes | native in each |
| `hook:completion-consistency` | CS19 | XS22 | - | present | yes | native in each |
| `hook:feature-review-coverage` | CS33, CF05 | XS27 | - | present | yes | native; CF05 duplicate per O3 |
| `hook:discovery-artifact-gate` | CS21 | XS08, XS23 | GH02 | present | partly: hosted tools (`WebSearch`) are not covered by Codex PreToolUse | native in each; record the hosted-tool limit in `reason` |
| `hook:discovery-planning-gate` | CS23 | XS24 | GH03 | present | yes | native in each |
| `hook:discovery-agent-start` | CS30 | XS02 | GH01 | present (inside the routing attestation) | yes | native in each |
| `hook:discovery-agent-stop` | CS31, CS32 | XS26 | GH04 | present | yes | native in each |
| `hook:epic-wave-barrier` | CS25 | XS12 | - | present, different trigger (Claude gates delegation; Codex gates child mutations) | yes | native; mechanism differs |
| `hook:model-routing` | CS26 | XS10, XS25 | - | present, different mechanism (Codex attests actual model and profile) | yes | native; mechanism differs |
| `hook:epic-root-invocation` | CS27 | XS01, XS09 | - | present, different mechanism | Claude form not expressible: Codex PreToolUse input carries no caller identity; Codex uses a UserPromptSubmit root receipt instead | native; reason records the mechanism difference |
| `hook:feature-folder-order` | CS17 | none | - | missing | yes (`apply_patch` matches as `Edit`/`Write`; file mapping exists in `codex-pretooluse-file-mapping.ps1`) | Recommend Codex counterpart (Section 8) |
| `hook:planner-output` | CS34, CF02 | none | - | missing | yes (SubagentStop matcher on `agent_type`; payload has `last_assistant_message` and `stop_hook_active`) | Recommend Codex counterpart, gated on child 3 (Section 2.3) |
| `hook:executor-output` | CF01 | none | - | missing | yes | as `hook:planner-output` |
| `hook:task-researcher-output` | CF14 | none | - | missing | yes | as `hook:planner-output` |
| `hook:required-artifact-output` | CF04, CF10, CF12, CF13 | none | - | missing | yes | as `hook:planner-output` |
| `hook:prd-feature-output` | CS35, CF11 | none | - | missing | yes | as `hook:planner-output`; the script's policy markers name `.claude/rules/` (`validate-prd-feature-output.ps1`), so Codex wording needs review |
| `hook:pr-author-output` | CS36, CF09 | none | - | missing | yes | as `hook:planner-output` |
| `hook:mermaid-validation` | CS20 | none | - | missing | yes, but depends on `.claude/lib/mermaid/*.psm1`, which a Codex-only destination does not receive | Owner Question O4 |
| `hook:prd-feature-before-planner` | CS22 | none | - | missing | yes on `spawn_agent`; depends on `.claude/lib/worktree-resolution` | Owner Question O4 |
| `hook:pr-author-skill-gate` | CS04 | none | - | missing | yes on `Bash`; depends on `.claude/lib/orchestrator-state`; Codex PR flow also involves the `commit-steward` agents | Owner Question O5 |
| `hook:orchestrator-output` | CS37, CS38, CS39, CF03, CF06, CF07 | none | - | missing | yes as an event; depends on `.claude/lib/orchestrator-state` and `.claude/lib/worktree-resolution`; `.codex/agents/orchestrator.toml` states that the MCP validator and CI are the hard completion boundary and that Codex lifecycle hooks are not the authoritative completion gate | native (Claude) with that reason; owner confirms (O5) |
| `hook:pr-author-command-allowlist` | CF08 | none | - | missing | no: Codex documents no per-agent hook declaration, and PreToolUse input carries no agent identifier | native (Claude); reason "not expressible in Codex" |
| `hook:session-id-persist` | CS01 | none | - | missing | yes (SessionStart exists) | native (Claude); consumer `.claude/skills/identify-session-id/SKILL.md` is Claude-only and Codex supplies `session_id` in every hook input |
| `hook:parallel-worktree-removal-gate` | CS08 | none | - | missing | yes as an event | native (Claude); no Codex parallel surface (no `.codex/agents/parallel-*.toml`; `parallel-orchestrate` exists only under `.claude/skills/`) |
| `hook:parallel-abandon-gate` | CS09 | none | - | missing | yes as an event | native (Claude); same reason |
| `hook:parallel-cohort-barrier` | CS28 | none | - | missing | yes as an event | native (Claude); same reason |
| `hook:parallel-drift-gate` | CS29 | none | - | missing | yes as an event | native (Claude); same reason |
| `hook:epic-planning-only` | none | XS11 | - | Codex-only | n/a | native (Codex); Claude has the preparation mode in the preimplementation gate but no equivalent checkpoint-scoped planning boundary hook (O6) |
| `hook:epic-child-worktree-binding` | none | XS13 | - | Codex-only | n/a | native (Codex); Codex epic children launch through `.codex/scripts/launch-epic-child-wave.ps1` rather than isolated subagent worktrees (O6) |

Copilot entries GH01 to GH04 are `native`, `owner_child` 6, per the child 1 spec `### Default Dispositions`; child 5 records their `parity_group` values only (O7).

### 2.3 Dependency of the SubagentStop ports on child 3

The Claude SubagentStop validators enforce an agent output contract: `validate-planner-output.ps1` requires a `plan-path:` advertisement and a `## Pre-Mortem`; `validate-task-researcher-output.ps1` requires `research-path:`; `validate-required-artifact-output.ps1` requires `spec-path`, `staged-review-path`, `status-sync-path` or `epic-audit-path`. A content search of `.codex/agents/` finds `plan-path` only in planner, executor and orchestrator profiles, and no `research-path`, `spec-path`, `staged-review-path`, `status-sync-path` or `epic-audit-path`, and no `Pre-Mortem`. Registering these validators for Codex today would block Codex agents whose instructions do not state the contract. Per the epic manifest, child 3 generates `.claude/agents/*.md` and `.codex/agents/*.toml` from one logical definition, after which both carry the same contract. The Codex ports are therefore expressible but are safe only after child 3 merges; the Phase 0 gate must confirm the generated Codex agent bodies state each contract the ported validator checks.

### 2.4 Codex hook capabilities (source)

Fetched 2026-10-30 from `https://developers.openai.com/codex/hooks`, which redirects (308) to `https://learn.chatgpt.com/docs/hooks`; the page states no date or version.

- Events: `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`, `SubagentStop`, `Stop`, `Interrupt`, `SessionStart`, `SubagentStart`, `SessionEnd`.
- Matchers are regular expressions: tool name for tool events; agent type for `SubagentStart` and `SubagentStop`; start source for `SessionStart`; ignored for `UserPromptSubmit`, `Stop`, `Interrupt`.
- PreToolUse tool names: shell and `exec_command` match as `Bash`; `apply_patch` matches as `apply_patch`, `Edit` or `Write`; MCP tools by name; `spawn_agent` also matches `Agent`; hosted tools such as `WebSearch` are not covered.
- PreToolUse can deny through `hookSpecificOutput.permissionDecision: "deny"`, the older `decision: "block"` shape, or exit code 2 with the reason on stderr. The page calls tool hooks "a useful guardrail, not a complete enforcement boundary".
- SubagentStop input adds `agent_id`, `agent_type`, `agent_transcript_path`, `stop_hook_active` and `last_assistant_message`; exit 0 requires JSON output; `decision: "block"` continues the subagent. This matches the fields `.claude/hooks/subagentstop-envelope.ps1` reads (`last_assistant_message`, `stop_hook_active`, `agent_type`); the block shape differs (Claude exit 2; Codex JSON continuation, as implemented in `.codex/hooks/validate-feature-review-coverage.ps1`).
- Common input: `session_id` (subagent hooks use the parent session id), `transcript_path`, `cwd`, `hook_event_name`, `model`. PreToolUse input carries no agent identifier; whether PreToolUse fires for tool calls inside subagents is not stated.
- Locations: `hooks.json` or inline `[hooks]` in `config.toml` at user or project layer, plugin bundles, managed `requirements.toml`; layers are additive; project hooks run only when the project `.codex/` layer is trusted. Per-agent hook declaration is not documented.
- Hooks are enabled by default; `[features] hooks = false` disables them (`codex_hooks` is a deprecated alias). `.codex/config.toml` sets `hooks = true`.

---

## 3. Python Invocation Audit

- Guard: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (issue #475) with helpers `EnforcementHooksNoPythonInvocation.Helpers.ps1` (detection) and `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (scope). It parses PowerShell ASTs for four classes (constant interpreter command among `python`, `python3`, `py`, `poetry`; subprocess start targeting an interpreter; dynamic `&`/`.` invocation that is not a `[scriptblock]` seam or a `Join-Path $PSScriptRoot '<x>.ps1'` dot-source; `Invoke-Expression`/`iex`), ships an empty allowlist, and asserts zero residual findings.
- Scan roots (`$script:ScanRoot` in `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1`): `.claude/hooks`, `.claude/lib` (excluding `.claude/lib/bash/**`), `.codex/hooks`. The bundled mirror under `extensions/` is deliberately out of scope.
- Not covered by the guard:
  - `.github/hooks/*.ps1` (five scripts). A text search finds no invocation; the only match is the comment in `discovery-planning.ps1` stating the hook "never runs Python". These scripts load only `.claude/lib/discovery-validation`, which is covered.
  - `.codex/scripts/*.ps1`, of which `epic-child-launch-contract.ps1` is dot-sourced by two registered Codex hooks. A text search finds only comments and help text naming the Python CLIs these PowerShell wrappers replace (`codex-routing-cli-common.ps1`, `Resolve-CodexTopology.ps1`, `Resolve-CodexDeployment.ps1`); no invocation was found by text search, but the AST guard has not been run over this folder.
  - `.claude/lib/bash/*.sh` (shell; excluded by design). Text matches are comments describing the Python reference implementation; no hook script invokes a `.sh` file (the matches in `.claude/hooks` are command-text analysis in `validate-bash.ps1`, `hook-command-scanner.ps1`, `hook-command-payload.ps1`, `enforce-pr-author-command-allowlist.ps1` and `enforce-parallel-abandon-gate.ps1`).
- Text-search results inside the guarded roots: language-detection data in `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/validate-feature-review-coverage-rules.ps1`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.codex/hooks/validate-feature-review-coverage.ps1`, and a deny pattern in `.codex/hooks/enforce-epic-planning-only.ps1` that matches `poetry run python -m scripts.dev_tools.validate_*` command text. None is an invocation; the AST guard is authoritative.
- Recommendation: extend the scan roots to `.github/hooks` and `.codex/scripts` so the rule "enforcement hooks do not invoke Python" covers every PowerShell file a registered hook executes, and add the corresponding `AC-15`-style root tests. Both files are in the parallel-run blast radius (Do-Not-Touch Set) and are edited only after that run merges.

---

## 4. Existing Hook Tests and CI Scope

- `tests/scripts/claude-hooks/`: per-hook suites for every registered Claude hook found in this inventory (for example `validate-planner-output.Tests.ps1`, `enforce-feature-folder-order.Tests.ps1`, `enforce-mermaid-validation.Tests.ps1`, `persist-session-id.Tests.ps1`), envelope and contract suites (`PreToolUsePayload.Contract.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, `subagentstop-envelope.Tests.ps1`), and Claude-to-Codex parity suites for the preimplementation gate (`enforce-orchestration-preimplementation-gate.Parity.Tests.ps1`, `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1`) plus `enforce-completion-consistency-codex.Tests.ps1`.
- `tests/scripts/codex-hooks/`: 82 `*.Tests.ps1` files plus one helper. Cross-cutting suites:
  - `legacy-codex-hook-contracts.Tests.ps1`: hard-coded `$script:PreToolHookNames`, `$script:AllHookNames` and `$script:SharedModuleNames`; asserts each listed file parses and is at most 500 lines in root and bundle, is byte-identical to its bundle copy, reads stdin (entrypoints), reads no `$env:CLAUDE_*`, and that each shared module is listed in the Codex `core.json` pack manifest.
  - `codex-pretooluse-integration.Tests.ps1`: derives every PreToolUse registration from `.codex/config.toml` and asserts each handler allows benign input for every tool name its matcher admits and fails closed with exit 2 on malformed input. A new PreToolUse registration is exercised automatically.
  - Parity suites: `codex-batch-budget-route-parity.Tests.ps1`, `feature-review-coverage-floor-parity.Tests.ps1`, `file-size-policy.Tests.ps1` (twin of `.claude/lib/file-size-policy/FileSizePolicy.psm1`), `hook-target-worktree.Tests.ps1` (twin of `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`).
- `tests/scripts/copilot-hooks/`: six suites (`discovery-start`, `discovery-pre-tool`, `discovery-planning`, `discovery-output`, `discovery-entrypoints`, `discovery-capability`).
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`: discovers hooks from `.claude/settings.json` and `.codex/config.toml` and requires the guarded dependency-load pattern; a new registered Codex hook is covered automatically.
- CI: `.github/workflows/_poshqc.yml` job `poshqc-linux-hooks` (`PowerShell hook suites (Linux)`) runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on `ubuntu-latest` with coverage disabled. `tests/scripts/copilot-hooks` and `tests/scripts/claude-runtime` run only in the Windows shards (`poshqc / PowerShell QC shard 1-3` over `config/poshqc-scan.json` `scanFolders`). Coverage roots in `config/poshqc-coverage.json` include `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.github/hooks` and `.codex/scripts`.
- Gap: no test compares the Claude and Codex registration sets against a declared parity record. Child 1's completeness gate checks that each registration has a matrix entry; it does not check that a parity group with a Claude member has a Codex member or a recorded reason.

---

## 5. Bundled Mirrors and Contract Tests

- Bundle locations: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` and `.claude/settings.json`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` (51 files, matching the root set by name) and `.codex/config.toml`; `extensions/drm-copilot/resources/customizations/.github/hooks/` (the six Copilot files); shared libraries published to destinations as `.codex/lib/<name>` from `extensions/drm-copilot/resources/lib/` (`discovery-validation`, `codex-routing`), mapped in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts`.
- Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (plus language packs).
- Contract tests (execution-environment brief, `## Contract Tests That Pin Mirrored Files`), each under `tests/scripts/dev_tools/`:
  - `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`: bundle text equality.
  - `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`: every bundled file is manifested.
  - `test_push_down_pack_manifest_dependency_closure.py`: `test_claude_command_text_closure` (hooks named by `.claude/settings.json` and manifested agent frontmatter are in core plus the owning pack), `test_codex_command_text_closure` (hooks named by the bundled `.codex/config.toml` are in Codex core), and `$PSScriptRoot` dependency closure.
  - `test_push_down_copilot_customizations.py` covers the Copilot bundle.
- Every new Codex hook or helper therefore needs: the root file, a byte-identical bundle copy, a Codex `core.json` entry, and a bundled `.codex/config.toml` that equals the root file.

---

## 6. Language Classification of Child 5 Artifacts

| Artifact | Runs where | Language | Rule outcome |
| --- | --- | --- | --- |
| New Codex hook entry scripts and dot-sourced helpers under `.codex/hooks/` | pushed down | PowerShell | allowed (hooks are PowerShell or bash) |
| Byte-identical bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` | pushed down | PowerShell | allowed |
| `.codex/config.toml` registration tables and the bundled copy | pushed down | TOML configuration | not code; hand-edited unless child 3 generates `[[hooks.*]]` (O8) |
| Codex `core.json` manifest entries | extension payload data | JSON | not code |
| `config/harness-parity-matrix.json` entry updates | repository only | JSON | not code |
| Pester suites under `tests/scripts/codex-hooks/` and a hook-parity repository gate | repository only | PowerShell | allowed; no new Python |
| Scan-root extension of the Python-invocation guard | repository only | PowerShell | allowed |
| Publishing a `.claude/lib/<x>` module to `.codex/lib/<x>` (only if O4 selects it) | extension command (push-down) | TypeScript in `extensions/drm-copilot/src/lib/push-down/codex-agents-customizations.ts` | allowed by the rule (extension command) but the file belongs to child 4's consolidation; raise as owner question, not decided here |

No artifact needs exception E2. No new Python is required; existing Python contract tests are run, not edited.

---

## 7. Candidate Approaches

### Selected: Codex counterparts as dot-source-safe byte-identical rule copies plus thin Codex entry adapters

- The Claude validators already separate a pure decision from the entry: `validate-planner-output.ps1`, `validate-required-artifact-output.ps1` and the other SubagentStop validators return when dot-sourced (`$MyInvocation.InvocationName -eq '.'`) and depend only on `hook-dependency-guard.ps1`, `subagentstop-envelope.ps1` and, for planner and researcher, `premortem-section.ps1` (no `.claude/lib` import, no `$env:CLAUDE_*` read). `enforce-feature-folder-order.ps1` has pure decision functions and the same guard, but imports `.claude/lib/hook-payload/HookPayload.psm1`, so its rule functions belong in a separate helper.
- Codex side: byte-identical copies of the rule files under `.codex/hooks/`, plus one Codex SubagentStop adapter that reads Codex stdin, dispatches on `agent_type`, and emits the Codex continuation shape with the `stop_hook_active` loop guard (precedent: `.codex/hooks/validate-feature-review-coverage.ps1`), and one Codex PreToolUse entry for feature-folder order using `codex-pretooluse-file-mapping.ps1`.
- Byte identity between `.claude/hooks` and `.codex/hooks` copies is pinned by a Pester test (precedent: twin tests `file-size-policy.Tests.ps1`, `hook-target-worktree.Tests.ps1`; `legacy-codex-hook-contracts.Tests.ps1` hash check for root and bundle).
- Advantages: no TypeScript or push-down change; one rule implementation in two byte-identical files; follows existing repository precedent; fits child 4's later consolidation.
- Limitations: duplicated bytes in the tree; the batch budget requires the `large` route (Pre-Mortem).

### Rejected alternatives

- Publish `.claude/lib` modules to `.codex/lib` and import from Codex hooks: requires a TypeScript push-down mapping change in child 4's file and a new `.claude/lib/<x>` project (QT008 entry); deferred to O4 for the lib-heavy hooks only.
- Separate Codex reimplementations without byte identity: drift risk; this is how the epic describes the current state.
- Generate Codex hooks from Claude hooks with a new generator: adds a generator outside child 3's settled scope.

---

## 8. Recommended Minimal-but-Complete Scope

### Behavior semantics

- Success: every registration on the four surfaces has a matrix entry with a `parity_group`; every `hook:<function>` group with a Claude member and no Codex member carries a written `reason` (not expressible, no Codex surface, or deferred by owner decision); every group with members in two ecosystems has a Pester test that runs both entries on the same inputs and asserts the same allow or deny outcome.
- Failure: a Codex counterpart that denies an input the Claude hook allows (or the reverse) on the shared fixture set; a group with no Codex member and no reason; a new Codex hook that reads `$env:CLAUDE_*`, exceeds 500 lines, lacks a bundle copy or manifest entry, or invokes Python.
- Ordering: Phase 0 (parallel run merged, child 1 and child 3 merged, Codex agent bodies carry the contracts in section 2.3); rule-helper extraction and copies; adapters; registrations; matrix updates; tests; bundle and manifest; guard scan-root extension.

### Files to edit (exist on this tree)

| File | Change | Note |
| --- | --- | --- |
| `.codex/config.toml` | add `[[hooks.SubagentStop]]` registrations for the ported validators; add the feature-folder-order handler to the `^(apply_patch\|Edit\|Write)$` group; add `enforce-orchestration-preimplementation-gate.ps1` to the `^(Agent\|Task\|spawn_agent\|run_subagent\|delegate)$` group | in #1009 and #1010 blast radius; ownership after child 3 per O8 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml` | equal to root | bundle |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | add each new `.codex/hooks/*` path | in #1009, #1010 radius |
| `.claude/hooks/enforce-feature-folder-order.ps1` | move rule functions into a new helper and dot-source it | behavior unchanged; its suites (`tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1`) must stay green |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1` | equal to root | bundle |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add the new Claude helper | in #1002, #1006, #1009, #1010, #1012, #1013 radius |
| `config/harness-parity-matrix.json` | set `parity_group`, `reason`, `decision_status`, `decision_ref` for every `hook-registration` entry | created by child 1 (not on this tree) |
| `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` | add `.github/hooks` and `.codex/scripts` roots | not in any blast radius |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | add root-membership tests for the two new roots | in #1001, #1009, #1011, #1012 radius |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | add new entrypoints and helpers to its name lists so the 500-line, stdin, `$env:CLAUDE_` and manifest checks cover them | in #1009, #1010 radius |

### Files to create

| File | Purpose |
| --- | --- |
| `.claude/hooks/feature-folder-order-rules.ps1` and `.codex/hooks/feature-folder-order-rules.ps1` | byte-identical pure rule helper (pattern: `feature-folder-resolution.ps1`) |
| `.codex/hooks/enforce-feature-folder-order.ps1` | Codex PreToolUse entry using `codex-pretooluse-file-mapping.ps1` |
| `.codex/hooks/subagentstop-envelope.ps1`, `.codex/hooks/premortem-section.ps1`, `.codex/hooks/validate-planner-output.ps1`, `.codex/hooks/validate-executor-output.ps1`, `.codex/hooks/validate-task-researcher-output.ps1`, `.codex/hooks/validate-required-artifact-output.ps1`, `.codex/hooks/validate-prd-feature-output.ps1`, `.codex/hooks/validate-pr-author-output.ps1` | byte-identical copies of the Claude rule files (dot-source-safe) |
| `.codex/hooks/validate-codex-agent-output.ps1` | Codex SubagentStop adapter: Codex stdin, `agent_type` dispatch, JSON continuation with loop guard |
| Bundle copies of each new file under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` | mirror parity |
| `tests/scripts/codex-hooks/hook-parity-twins.Tests.ps1` | byte identity of each `.claude/hooks` and `.codex/hooks` twin |
| `tests/scripts/codex-hooks/hook-parity-equivalence.Tests.ps1` | runs Claude and Codex entries on shared fixtures for each ported group and asserts equal decisions |
| `tests/scripts/codex-hooks/validate-codex-agent-output.Tests.ps1`, `tests/scripts/codex-hooks/enforce-feature-folder-order.Tests.ps1` | unit suites for the Codex adapters |
| A hook-parity repository gate under `tests/scripts/harness/` (child 1's folder) | asserts every `hook:*` group with a Claude member has a Codex member or a non-empty `reason` |

The new files are under existing projects (`.claude/hooks`, `.codex/hooks`, both T3 in `quality-tiers.yml`), so no `quality-tiers.yml` entry is required. A new `.claude/lib/<name>` folder (only if O4 selects the library route) would need an entry under rule R4 of `scripts/dev_tools/quality_tiers_contract.py`, or QT008 fails. Separately, child 1's planned `scripts/harness/` is a new project under rule R3 and is not in child 1's edit set; this is a child 1 preflight item for the orchestrator.

### Files not to touch

- `.claude/settings.json` registrations (no change is needed for parity; duplicates are resolved only if O3 decides to drop them, and that edit belongs to the file's owner after the parallel run).
- `.claude/agents/*.md` and `.codex/agents/*.toml` (generator-owned after child 3, per the epic manifest `## Dependency Rationale`); frontmatter hook changes go through child 3's agent source.
- `.github/hooks/**` and their bundle copies (child 6).
- `extensions/drm-copilot/src/lib/push-down/**` (child 4), unless O4 selects the library route.
- Every path in the Do-Not-Touch Set until the parallel run merges.
- `.claude/hooks/validate-orchestrator-output*.ps1`, `.claude/hooks/enforce-pr-author-*.ps1`, `.claude/hooks/enforce-mermaid-validation.ps1`, `.claude/hooks/enforce-prd-feature-before-planner*.ps1`, the parallel gate hooks and `.claude/lib/**` (out of the recommended port set).

---

## Automation Feasibility

- Inventory and matrix population: automatable. Child 1's `scripts/harness/HarnessInventory.psm1` enumerates `hook-registration` features from the four surfaces; child 5 edits only `parity_group`, `reason` and decision fields. Parsing of `.codex/config.toml` follows child 1's anchored-regex rule.
- Byte-identity and bundle parity: automatable with Pester hash comparisons and the existing Python contract tests.
- Behavioral equivalence: automatable for PreToolUse and SubagentStop by invoking each entry script with in-memory stdin (precedent: `Invoke-CodexHookProcess` in `legacy-codex-hook-contracts.Tests.ps1`) and comparing the normalized decision (allow, deny or continue).
- Not automatable in CI: whether Codex fires PreToolUse inside subagents, whether `spawn_agent` tool input carries the fields the preimplementation delegation leg reads, and whether Claude fires both a frontmatter and a settings `SubagentStop` for one stop. These need owner-run observation (child 1 E5 covers the Claude side; a Codex runbook is needed for the first two; O2).
- Live hook behavior on a branch is not exercised by isolated subagents until merge (execution-environment brief, `## Hook Execution Context`); Pester suites are the proof.

## Owner Questions

| ID | Question | Recommended default |
| --- | --- | --- |
| O1 | The issue's "shared" means a function present in several ecosystems; child 1's `shared` means one mirrored source. Should child 5 use child 1's semantics (each registration `native`, parity through `parity_group`) and restate its acceptance criteria accordingly? | Yes; a "shared function" is a parity group with members in two or more ecosystems. |
| O2 | Codex documents no caller identity in PreToolUse and does not state that PreToolUse fires inside subagents. Is an owner-run Codex runbook acceptable to confirm subagent PreToolUse firing and the `spawn_agent` input shape before the preimplementation delegation registration is added? | Yes; until recorded, the delegation registration stays out and the matrix records the reason. |
| O3 | Seven frontmatter `SubagentStop` registrations duplicate settings registrations (CF02, CF03, CF05, CF06, CF07, CF09, CF11). Keep both, or drop one source? Also, matrix `id` values for these collide under `<ecosystem>:<kind>:<Event>/<matcher>/<command-stem>` because the source file is not part of the name; matchers such as `Bash\|Write\|...\|mcp__.*` and `^(Agent\|...)$` contain characters outside the `id` pattern `[A-Za-z0-9._@/#:+-]`. | Keep both until child 1 E5 records firing behavior; child 1 resolves the `id` encoding (open preflight defect) with a source discriminator and matcher encoding. |
| O4 | Lib-dependent Claude gates (`hook:mermaid-validation` needs `.claude/lib/mermaid`, about 1,780 lines across four modules; `hook:prd-feature-before-planner` needs `.claude/lib/worktree-resolution`): port through a published `.codex/lib` (TypeScript push-down change, child 4's file) or Codex twins under `.codex/hooks` (500-line cap per file), or record as native with a deferral reason? | Record as native with reason "requires library publication; deferred to child 4" and file no new issue unless the owner prefers a port. |
| O5 | `hook:pr-author-skill-gate` and `hook:orchestrator-output` depend on `.claude/lib/orchestrator-state`; `.codex/agents/orchestrator.toml` names the MCP validator and CI as the hard completion boundary. Confirm both stay Claude-native. | Native (Claude) with those reasons. |
| O6 | Should Claude gain the Codex-only `hook:epic-planning-only` and `hook:epic-child-worktree-binding`? | No; record both as Codex-native with mechanism reasons. |
| O7 | Copilot boundary: child 1 assigns Copilot hook registrations `owner_child` 6. Does child 5 set their `parity_group` values (discovery groups shared with Claude and Codex) while child 6 owns their disposition and any change to `.github/hooks`? | Yes. |
| O8 | Ownership of `[[hooks.*]]` tables in `.codex/config.toml` after child 3: the epic manifest says hook registrations in `.codex/config.toml` become generator-owned, while child 3's scope lists only the `[mcp_servers]` table. Who edits the hook tables? | Child 5 edits the hook tables by hand unless child 3's merged spec states otherwise; Phase 0 re-checks. |
| O9 | `feature-review-coverage-thresholds.ps1` (both runtimes) reads coverage thresholds from root `CLAUDE.md`. After child 3 makes `AGENTS.md` the instruction source, should the Codex hook read `AGENTS.md` (a Codex-only destination may have no `CLAUDE.md`)? | Codex reads `AGENTS.md` first and falls back to `CLAUDE.md`; the change lands with child 5 only if child 3 moves the threshold text. |

## Do-Not-Touch Set

Extracted from every `blast_radius.paths` entry of the parallel-run manifest `bugs-1001-1002-1003-1006` (items 1001, 1002, 1003, 1006, 1009, 1010, 1011, 1012, 1013). Item 1009 appears merged (pull request #1017 in the recent commit list); the merge state of the other items is not verified and needs orchestrator confirmation with `gh`. Until all items merge, child 5 edits none of these paths.

Hook surfaces and runtime configuration:

- `.claude/settings.json` (1002, 1009, 1010, 1012); `.codex/config.toml` (1009, 1010)
- `.claude/agents/pr-author.md` (1011), `.claude/agents/parallel-planner.md` (1002, 1013), `.claude/agents/parallel-orchestrator.md` (1012, 1013), `.claude/agents/epic-orchestrator.md` (1013)
- `.claude/hooks/enforce-epic-merge-gate.ps1` (1001, 1011), `enforce-model-routing-receipt.ps1` (1001, 1009, 1013), `enforce-pr-author-skill.ps1` (1001, 1011), `enforce-pr-author-skill.epic-base-branch.ps1` (1001, 1011), `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.artifact-root.ps1`, `enforce-pr-author-skill.current-branch.ps1`, `enforce-pr-author-skill.docs-only.ps1`, `enforce-pr-author-command-allowlist.ps1` (1011), `enforce-powershell-batch-budget.ps1`, `enforce-python-batch-budget.ps1` (1009), `enforce-orchestration-preimplementation-gate.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (1010), `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-orchestrator-output-rejection.ps1` (new in 1012)
- `.codex/hooks/enforce-powershell-batch-budget.ps1`, `enforce-python-batch-budget.ps1` (1009), `hook-target-worktree.ps1` (1009, 1010), `enforce-orchestration-preimplementation-gate.ps1`, `enforce-orchestration-preimplementation-gate-epic-resolution.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (1010)
- `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` (1009, 1010, 1011, 1012), `WorktreeResolution.psm1` (1009); `.claude/lib/blast-radius/*` (1006, 1013)
- The bundle copies of each file above under `extensions/drm-copilot/resources/claude-customizations/` and `extensions/drm-copilot/resources/codex-and-agents-customizations/`, and both `pack-manifests/core.json` files (1002, 1006, 1009, 1010, 1012, 1013)

Tests that pin hooks:

- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (1001, 1009, 1011, 1012), `hook-dependency-guard-completeness.Tests.ps1` (1009, 1010, 1011, 1012), `HookImportFailureExemptions.Helpers.ps1` (1009), `claude-architecture-doc.Tests.ps1`, `claude-runtime-structure.Tests.ps1`, `checkpoint-hygiene-skill-contract.Tests.ps1`, `enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, `pr-author-*-contract.Tests.ps1`, `parallel-orchestrate-run-closing.Tests.ps1`
- `tests/scripts/claude-hooks/`: the merge-gate, model-routing, pr-author, batch-budget, preimplementation-gate, epic-state-isolation, validate-orchestrator-output, hook-command, hook-dependency-failure, `PreToolUseSchema.Contract.Tests.ps1`, `session-root-reads-850.Constraints.Tests.ps1` and `enforce-parallel-drift-gate.Tests.ps1` suites named in the manifest
- `tests/scripts/codex-hooks/`: `legacy-codex-hook-contracts.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, `hook-target-worktree.Tests.ps1`, `file-size-policy.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, the batch-budget suites, the preimplementation-gate suites and `enforce-epic-merge-gate-decision-surface.Tests.ps1`
- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`, `test_execution_environment_brief_contracts.py`

Shared configuration and documents:

- `config/file-size-baseline.json`, `config/poshqc-coverage.json`, `config/blast-radius.json`, `scripts/powershell/PoshQC/PoshQC.psd1`, `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `scripts/dev_tools/generate_codex_agent_variants.py`, `scripts/dev_tools/validate_orchestration_artifacts.py`
- The six execution-environment brief copies (`.claude/skills/execution-environment/SKILL.md`, `.agents/...`, `.github/...` and their bundle copies), `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`, the policy-audit templates under `docs/features/templates/policy_audit/`

Overlap with child 5's recommended edit set: `.codex/config.toml`, both `core.json` manifests, `enforcement-hooks-no-python-invocation.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1`. These edits wait for the parallel run to merge and are re-checked by the Phase 0 gate.

## Numeric Derivation Evidence

No numeric acceptance criterion is proposed. Acceptance criteria should be stated against the set that child 1's inventory module enumerates at execution time. The counts below are informational and are recorded so that a later reader can reproduce them.

| Field | Claude settings | Claude frontmatter | Codex config | Copilot |
| --- | --- | --- | --- | --- |
| Complete Family | every command hook under `hooks` in `.claude/settings.json` | every command under a `hooks:` block in `.claude/agents/*.md` frontmatter | every `[[hooks.<Event>.hooks]]` command in `.codex/config.toml` | every command entry in `.github/hooks/*.json` |
| Exhaustive Search Scope | the one settings file | all files in `.claude/agents/` | the one config file | all JSON files in `.github/hooks/` (one file) |
| Inclusion Rules | `type: command` entries under any event | `command:` lines inside frontmatter `hooks:` | `command` keys inside hook tables | entries with a `powershell` command |
| Exclusion Rules | permissions and other keys | body text | `[mcp_servers]` `command = "npx"` | none |
| Primary Search Strategy | reading the parsed JSON event by event (section 1.3) | content grep listing each `command:` with its matcher (section 1.4) | reading each table (section 1.5) | reading the JSON (section 1.6) |
| Primary Member Set | CS01 to CS39 | CF01 to CF14 | XS01 to XS27 | GH01 to GH04 |
| Primary Count | 39 | 14 | 27 | 4 |
| Cross-check Search Strategy | count of `"command": "pwsh` in the file | per-file count of `^\s+command: pwsh` | count of `^command_windows = ` (the MCP server has no `command_windows`) | count of `"powershell":` |
| Cross-check Member Set | 39 lines, one per CS row | 12 files: `prd-feature.md` 2, `pr-author.md` 2, ten files 1 each | 27 lines, one per XS row | 4 lines, one per GH row |
| Cross-check Count | 39 | 14 | 27 | 4 |
| Member-set Comparison | equal | equal (files and per-file counts match CF rows) | equal; a `^command = ` count gives 28 because it includes the MCP server, which the inclusion rules exclude | equal |

## Testing Implications

- Unit (Pester, no temporary files, in-memory stdin): each Codex adapter (allow, deny or continue, malformed stdin fails closed with exit 2, `stop_hook_active` loop guard, unknown `agent_type` allowed); the extracted feature-folder rule helper from both entries.
- Equivalence: one fixture table per ported group run through the Claude entry and the Codex entry; decisions normalized and compared.
- Twins: hash equality between `.claude/hooks` and `.codex/hooks` copies, and root versus bundle.
- Repository gate: every `hook:*` parity group with a Claude member has a Codex member or a non-empty `reason`.
- Existing suites that must stay green: `enforce-feature-folder-order.Tests.ps1` and every `validate-*-output` suite under `tests/scripts/claude-hooks/`; `codex-pretooluse-integration.Tests.ps1` (picks up new PreToolUse registrations); `hook-dependency-guard-completeness.Tests.ps1` (picks up new registrations); the Python contract tests in section 5.
- Coverage: PowerShell line coverage of at least 85 percent per new production file from `artifacts/pester/powershell-coverage.xml`; no branch gate for PowerShell.

## Pre-Mortem

- Review checklists: a review can fail because the spec uses "shared" in the issue's sense while the matrix uses child 1's semantics; mitigation: the plan restates dispositions per O1 and maps every acceptance criterion to the matrix fields it checks.
- Coverage: each new `.codex/hooks` file is in the coverage denominator (`config/poshqc-coverage.json` root `.codex/hooks`), and byte-identical copies executed only through the Codex adapter may fall below 85 percent; mitigation: the plan's unit suites dot-source each copy directly and exercise every decision branch, and records per-file coverage from `artifacts/pester/powershell-coverage.xml`.
- Mirror parity: every new root file needs a byte-identical bundle copy, a Codex or Claude `core.json` entry and an updated bundled `.codex/config.toml`, or `test_push_down_codex_and_agents_resource_contracts.py`, the pack-manifest completeness tests and `test_codex_command_text_closure` fail; mitigation: each root-file task is paired with its bundle and manifest task, and the plan runs those tests after each pair.
- File size: `legacy-codex-hook-contracts.Tests.ps1` caps listed Codex hooks at 500 lines and the repository gate caps all files at 800; `validate-planner-output.ps1` (454 lines) and `validate-executor-output.ps1` (450 lines) copied to `.codex/hooks` are near that cap; mitigation: the plan records line counts with `@(Get-Content -LiteralPath <path>).Count` before copying and adds no lines to the copies.
- Test isolation: equivalence suites dot-source Claude and Codex files with the same function names into one Pester run, which can leak function definitions between suites in the single-process shard; mitigation: each suite loads entries in separate child processes or removes functions in `AfterAll`, and the plan runs three seeded shuffled file-order runs plus one fresh single-process run over `tests/scripts`.
- CI-only behavior: `tests/scripts/codex-hooks` also runs in the Linux hook-suite job on a case-sensitive file system; mitigation: fixtures use `Join-Path`, forward-slash relative paths, exact file-name case and no drive letters; `.github/hooks` and `tests/scripts/copilot-hooks` are not in that job, so no copilot change is assumed proven by it.
- Evidence: acceptance that depends on a branch hook being exercised by an isolated subagent cannot be met before merge (brief `## Hook Execution Context`); mitigation: Pester suites are the stated proof, and evidence files under `<FEATURE>/evidence/qa-gates/` and `<FEATURE>/evidence/regression-testing/` carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` with write-time stamps.

Additional risks recorded for the planner:

- Batch budget: the recommended set is about ten new root production files plus their bundle copies and edits to existing hooks, well above three PowerShell files per worktree session; execution needs the `large` route with a checkpoint in the item worktree.
- Phase 0: confirm the parallel run merged, child 1's matrix and `id` encoding are final, child 3 merged and the generated Codex agent bodies state each output contract in section 2.3, and every file, symbol and heading named here is unchanged against the merge base of `origin/main` and `HEAD`.
- Byte identity of existing "shared" helpers (`hook-dependency-guard.ps1`, `hook-command-*.ps1`, `feature-folder-resolution.ps1` in `.claude/hooks` versus `.codex/hooks`) was not verified (no hash tool available to the researcher); the orchestrator should compare `git hash-object` values before the plan relies on them.

## Items for the Orchestrator to Confirm

- Merge state of parallel-run items 1001, 1002, 1003, 1006, 1010, 1011, 1012 and 1013 (`gh`).
- `git hash-object` equality of the Claude and Codex copies of `hook-dependency-guard.ps1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1` and `feature-folder-resolution.ps1`.
- That child 1's planned `scripts/harness/` folder receives a `quality-tiers.yml` entry (rule R3, QT008).

research-path: docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/research/research.2026-10-30T23-03.md
