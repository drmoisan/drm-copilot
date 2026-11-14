# Research: Harness Survey, Gold-Standard Contracts and Parity Matrix (Issue #1025)

- Issue: #1025 (child 1 of epic #1018)
- Feature folder: `docs/features/active/2026-10-30-harness-survey-gold-standard-contracts-parity-matrix-1025/`
- Mode: preparation (planning only); no source, configuration or test file was changed
- Inputs read: `docs/features/epics/shared-agent-harness-layer/epic.md`, `docs/features/potential/promoted/2026-10-30-shared-agent-harness-layer-across-claude-codex-copilot.md`, the feature `issue.md` and `spec.md`, `.claude/skills/execution-environment/SKILL.md`, and the manifest of the parallel run `bugs-1001-1002-1003-1006` (supplied by the coordinator)
- The confirmed epic design is not re-opened here. This document researches how to deliver child 1 within it.

The execution-environment brief (`.claude/skills/execution-environment/SKILL.md`) is the reference for tool routes, CI shape, coverage gates and command-text restrictions; this document cites it and does not restate it.

---

## 1. Skill Inventory and Content Survey

### 1.1 Verified inventory

Enumerated with Glob over `.claude/skills/*/SKILL.md`, `.agents/skills/*/SKILL.md` and `.github/skills/*/SKILL.md`, then cross-checked against a full file listing of each tree (see `## Numeric Derivation Evidence`).

| Set | Count | Notes |
| --- | --- | --- |
| `.claude/skills` skill folders | 66 | Every folder has `SKILL.md` |
| `.agents/skills` skill folders | 79 | Every folder has `SKILL.md`; plus a root `README.md` |
| `.github/skills` skill folders | 33 | Every folder has `SKILL.md`; plus a root `README.md` |
| Distinct names (union) | 90 | |
| In all three | 33 | Equals the whole `.github/skills` set |
| Claude and Codex only | 22 | |
| Claude only | 11 | |
| Codex only | 24 | |
| Copilot only | 0 | `.github/skills` is a strict subset of both other trees |
| Shared (Claude and Codex) | 55 | 33 + 22 |

Discrepancy with the epic record: the promoted epic record states 83 skill directories under `.agents/skills` and 34 skills under `.github/skills`. The tree on this branch holds 79 and 33 skill folders. The difference may come from counting the root `README.md` files or from a different snapshot; orchestrator to confirm with `git log` on those folders. The 90-name union and the 33/22/11/24 partition match the epic record.

Supporting files that are not `SKILL.md`:

- `.claude/skills/mermaid-diagram/references/*.md` (nine files) — the only existing `references/` folder in the repository; bundled under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/mermaid-diagram/references/` and listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- `.claude/skills/cleanup-merged-worktrees/scripts/*.sh`, `.claude/skills/human-exception-runbook/example.runbook.md`, `.agents/skills/human-exception-runbook/example.runbook.md`.
- `.agents/skills/codex-model-routing/agents/openai.yaml` and `.agents/skills/repo-automation-adapter/agents/openai.yaml` (Codex per-skill metadata; both listed in the Codex `core.json`).
- No `.agents/skills/*/references/` folder exists.

### 1.2 Characterization of real differences (content sample)

Read by content: `feature-promotion-lifecycle` (all three copies), `feature-review-workflow` (all three, differing sections), and heading-level comparisons of `remediation-handoff-atomic-planner`, `powershell-orchestration-state-machine`, `csharp-change-budget-router`, `epic-orchestrate` and `pr-author`. Four kinds of difference were observed.

1. **Substantive policy conflict.** `.github/skills/feature-promotion-lifecycle/SKILL.md` (`## MCP-First Execution Rule`, `## Canonical Fallback Command Sequence`, `## Canonical Fallback Short-Path Sequence (Minor Audit Mode)`) permits VS Code command and direct-script fallbacks. The Claude and Codex copies (`## MCP Tool Availability Preflight`, `## Agent-Session Promotion Execution Rule`) state that agent sessions have no approved non-MCP branch. A completed feature folder `docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/` exists, which suggests the Copilot copy predates that hardening; orchestrator to confirm with history. This is a candidate "negative / stale" classification for the Copilot copy.
2. **Substantive one-sided additions (three-way divergence).** In the same skill: only the Claude copy has `## Pre-Existing Issue Path` and step 4b (promoted-record retention, issue #487); only the Codex copy has the pre-issue-branch and final-branch rename flow, lifecycle guardrails, route-metadata readiness and deterministic plan-path enumeration; the Copilot and Codex copies carry an "Automation rule" that the Claude copy lacks (the Claude copy reads "manual bootstrap: save state and stop" without the opt-in qualifier). The Claude copy also lost the short-path sub-heading, so its steps appear under `## Canonical Variables`. Each of these is a candidate "positive" to port in one direction.
3. **Placement (mechanism-only).** The Copilot-only `## File Size Advisory` in `.github/skills/feature-review-workflow/SKILL.md` has the same text in `.claude/agents/feature-review.md` (`## File Size Advisory`) and in the Codex-only `.agents/skills/feature-review/SKILL.md` (`## File Size Advisory`). The content is not missing from Claude or Codex; it lives in a different artifact. Conversely, the Claude and Codex copies of `feature-review-workflow` have `## Policy Rules` / `### modified-workflow-needs-green-run`, and the Claude copy has two additional `## Constraints` bullets (rejected scope narrowing; explicit coverage verdicts).
4. **Stale subset.** `.github/skills/csharp-change-budget-router/SKILL.md` lacks `## Invocation Mode`, `## Per-Batch Cap` and `## Orchestrator-Mode Delegation Chain`, which the Claude and Codex copies share with identical headings. `.agents/skills/remediation-handoff-atomic-planner/SKILL.md` and its Copilot copy are the short form; the Claude copy adds `## Full Handoff Chain`, `## Preflight Sub-Loop`, `## Execution and Reaudit` and `## Exit Gate`. `.claude/skills/powershell-orchestration-state-machine/SKILL.md` alone has `## Portable Prepared-State Projection`.

Ecosystem mechanism differences that are expected and do not affect the gold standard: Codex-specific launch and deployment policy in `.agents/skills/epic-orchestrate/SKILL.md` (`## Model and Deployment Policy`) versus Claude's `## Model Selection` and `## Bounded Child Return Contract`; Claude `pr-author` content split in Codex between `pr-author` and the Codex-only `pr-authoring`.

Frontmatter: Claude-only fields are used by eight shared skills (`allowed-tools` in `execute-hard-lock`, `pr-author`, `research-issue`, `commit-message`; `argument-hint`, `context: fork` and `agent:` in `epic-orchestrate`, `epic-plan`, `epic-run`; `argument-hint` in `orchestrate`). No `.agents` or `.github` skill uses any field other than `name` and `description` (Grep over `**/SKILL.md` frontmatter keys returned none).

Survey method consequence: a section missing from one copy must be searched for across that ecosystem's other surfaces (agent bodies, rules, sibling skills) before it is recorded as missing. A skill-to-skill comparison alone misclassifies placement differences as substantive.

### 1.3 Heuristic for the material-difference set

Non-empty line counts per copy (Grep count of `\S` over `**/SKILL.md` in each tree) differ for 24 of the 55 shared names and are equal in all present copies for 31. Equal counts do not prove identity, and execution must hash. The epic record's list of 16 materially different skills is not recorded in the repository (Grep over `docs/` found the figure only in the epic, issue and spec documents); orchestrator to confirm which 16 were meant. The largest deltas (Claude / Codex / Copilot non-empty lines):

| Skill | Claude | Codex | Copilot |
| --- | --- | --- | --- |
| `epic-orchestrate` | 308 | 144 | – |
| `orchestrate` | 322 | 393 | – |
| `remediation-handoff-atomic-planner` | 93 | 36 | 35 |
| `pr-author` | 98 | 35 | – |
| `atomic-plan-contract` | 197 | 168 | 159 |
| `csharp-change-budget-router` | 63 | 63 | 35 |
| `powershell-orchestration-state-machine` | 68 | 45 | 44 |
| `epic-run` | 49 | 34 | – |
| `evidence-and-timestamp-conventions` | 133 | 134 | 112 |
| `feature-promotion-lifecycle` | 95 | 112 | 93 |
| `feature-review-workflow` | 148 | 153 | 138 |
| `csharp-qa-gate` | 63 | 51 | – |
| `epic-plan` | 175 | 187 | – |
| `research-issue` | 55 | 46 | – |

The remaining differing names have small deltas (`acceptance-criteria-tracking`, `commit-message`, `csharp-orchestration-state-machine`, `execute-hard-lock`, `fill-feature-docs`, `human-exception-runbook`, the three `invoke-*-engineer` skills, `policy-compliance-order`). These figures are a planning heuristic and are not proposed for `spec.md`.

### 1.4 Recommended execution of the full survey

**Identity pass (one task).** For each of the 55 shared names, compute `git hash-object` of each copy (byte identity) and a normalized comparison (whitespace collapsed, heading levels ignored) to classify each name as `byte-identical`, `wording-only` or `substantive`. Run it from a PowerShell script stored under `SCRATCH` and launched with `sh` (brief, `## Tool Routes by Agent`); it is a throwaway session script, not a committed tool, so it does not add a new script to the repository. Record the command and output as evidence under `<FEATURE>/evidence/baseline/`.

**Content pass, batched by skill family (six tasks).** Only names classified `wording-only` or `substantive` need a full read; `byte-identical` names get a one-line record.

| Batch | Skills | Size |
| --- | --- | --- |
| A Discovery | the seven `discovery-*` skills, `initialize-discovery-workspace`, `inventory-legacy-system`, `characterize-runtime-behavior`, `extract-feature-contract`, `generate-acceptance-scenarios`, `adjudicate-unspecified-behavior`, `reconcile-parity-matrix`, `review-discovery-coverage`, `validate-discovery-artifacts` | 16 |
| B Foundation and policy | `policy-compliance-order`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `evidence-and-timestamp-conventions`, `execution-environment`, `skill-canonical-location-audit`, `make-skill-template`, `policy-audit-template-usage` | 8 |
| C Integration | `pr-base-branch-merge-base`, `pr-context-artifacts`, `feature-promotion-lifecycle`, `remediation-handoff-atomic-planner`, `feature-review-workflow` | 5 |
| D Language routing and gates | `csharp-change-budget-router`, `csharp-orchestration-state-machine`, `powershell-change-budget-router`, `powershell-orchestration-state-machine`, `python-change-budget-router`, `csharp-qa-gate`, `powershell-qa-gate`, `python-qa-gate`, `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer` | 11 |
| E Orchestration | `orchestrate`, `epic-orchestrate`, `epic-plan`, `epic-run`, `execute-hard-lock`, `human-exception-runbook` | 6 |
| F Authoring and review wrappers | `commit-message`, `pr-author`, `research-issue`, `review-epic`, `review-feature`, `review-staged`, `update-status`, `fill-feature-docs`, `translate-copilot-to-claude` | 9 |

The 35 single-ecosystem names (11 Claude-only, 24 Codex-only) get a disposition record (proposed `native` or `shared`), not a difference table.

**Artifact location.** Under the feature folder (docs-only paths per `config/ci-docs-only-paths.json`, so survey commits do not trigger heavy CI):

- `<FEATURE>/survey/skill-survey.md` — index: one row per name for all 90 (presence in each tree, identity class, proposed disposition, batch).
- `<FEATURE>/survey/batch-<A..F>-<family>.md` — one per batch, holding the per-skill records.

**Per-skill record shape** (fixed so that a reviewer or a later check can grep it):

```markdown
### <skill-name>

- Presence: claude=`.claude/skills/<name>/SKILL.md` | codex=`.agents/skills/<name>/SKILL.md` | copilot=`.github/skills/<name>/SKILL.md` | absent
- Identity: byte-identical | wording-only | substantive (git hash-object values in evidence)
- Proposed disposition: shared | native
- Objective (draft): <one sentence; feeds references/standard.md>

| Diff ID | Location (ecosystem:path#heading) | Difference | Present elsewhere in that ecosystem? | Class | Port direction | Rationale against objective |
| --- | --- | --- | --- | --- | --- | --- |
| D-<skill>-01 | copilot:.github/skills/<name>/SKILL.md#<heading> | ... | yes: `.claude/agents/<file>.md#<heading>` / no | positive / negative / neutral / mechanism-only | codex->claude / none | ... |
```

Diff identifiers are stable (`D-<skill-name>-<two digits>`) so the approval artifact can reference them.

---

## 2. Gold-Standard Contract Format

### 2.1 How each tool treats a `references/` subfolder

| Tool | Documented behavior | Source |
| --- | --- | --- |
| Agent Skills specification | `references/` is an optional directory of documentation that "agents can read when needed"; resources "are loaded only when required" (progressive disclosure). | https://agentskills.io/specification |
| Claude Code | Supporting files are loaded on demand when `SKILL.md` references them; Claude Code discovers skills only under `.claude/skills` (and personal, nested, add-dir, plugin locations), not `.agents/skills`. | https://code.claude.com/docs/en/skills |
| VS Code Copilot | Supporting files may live anywhere in the skill folder; "If a file isn't referenced in the instructions, it won't be loaded." | https://code.visualstudio.com/docs/copilot/customization/agent-skills |
| Codex | `references/` is listed as optional "documentation"; Codex reads the full `SKILL.md` when a skill is selected. The page does not describe loading of `references/`. | https://learn.chatgpt.com/docs/build-skills (redirect target of https://developers.openai.com/codex/skills) |

Conclusion: a file named `references/standard.md` has no `SKILL.md`, so no tool discovers it as a skill and none lists it twice. It is loaded only when `SKILL.md` links to it. This is resolved by documentation; no experiment is needed.

Recommendation: do not link `standard.md` from any `SKILL.md` in child 1. The contract is a judging standard; leaving it unlinked keeps the runtime context of every tool unchanged and keeps every `SKILL.md` (several of which are in the parallel run's blast radius) out of child 1's edit set. Whether child 3 links it is an owner question (Q2).

### 2.2 Proposed format

Path: `.agents/skills/<skill-name>/references/standard.md`, one per skill whose approved matrix disposition is `shared` (kind `skill`, ecosystem `codex`).

No YAML frontmatter. Exact structure:

```markdown
# Gold Standard: <skill-name>

## Objective

<One paragraph: the outcome the skill exists to produce, tool-neutral.>

## Observable Behaviors

- **OB-1** <a behavior an observer can see in outputs, files, or tool calls, independent of the tool>
- **OB-2** ...

## Acceptance Checks

- **AC-1** (OB-1) <a verifiable statement that an ecosystem's expression satisfies OB-1>
- **AC-2** (OB-1, OB-2) ...
```

Rules:

- The H1 is exactly `# Gold Standard: <skill-name>` with the folder name.
- Exactly three H2 headings, in this order: `## Objective`, `## Observable Behaviors`, `## Acceptance Checks`; no other H2.
- Each section is non-empty. Observable behaviors use `**OB-<n>**`; acceptance checks use `**AC-<n>**` followed by a parenthesized list of the OB identifiers they verify; every cited OB exists.
- No checkbox syntax (`- [ ]`), so acceptance-criteria tooling that scans for checkboxes cannot mistake contract checks for feature acceptance criteria.
- Tool names may appear only to state that mechanism differs; the objective and behaviors are tool-neutral.
- No consuming-product names: `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` scans every file under `.agents` (`SOLUTION_SCAN_ROOTS`) for `TaskMaster.sln`.

### 2.3 Presence check

A Pester repository gate (see topic 5) reads the matrix, selects entries with `kind == "skill"`, `ecosystem == "codex"` and `disposition == "shared"`, and for each name asserts the rules above. Deriving the required set from the matrix keeps the check and the matrix in agreement and avoids a hard-coded count.

---

## 3. Difference Classification and Owner Approval

### 3.1 Classification semantics

Judged against the skill's objective (the draft objective in the survey record, later the contract's `## Objective`):

| Class | Meaning | Port action |
| --- | --- | --- |
| positive | The variant that has it serves the objective better | Port to the other ecosystems, in the recorded direction |
| negative | The variant that has it works against the objective, or is stale | Remove from that variant |
| neutral | Different wording or structure with equal effect | None; the shared body picks one |
| mechanism-only | The behavior is equal but expressed through a tool-specific mechanism or in a different artifact | None; record the mechanism per tool |

### 3.2 Approval artifact

Path: `<FEATURE>/survey/difference-approval.md`. It is a decision record, not evidence, so it sits outside `evidence/` (the same reasoning the `human-exception-runbook` skill applies to `runbooks/`).

Shape:

```markdown
# Difference Classification Approval (Issue #1025)

- Approval-Status: pending        <!-- owner sets: approved | approved-with-overrides -->
- Approved-By:                    <!-- owner fills -->
- Approved-At:                    <!-- owner fills, UTC yyyy-MM-ddTHH-mm -->

## Bulk Approval Set
| Diff ID | Skill | Class | Port direction | One-line rationale |
| ... |

## Disposition Proposals
| Skill or feature id | Proposed disposition | Reason |   <!-- the 35 single-ecosystem skills and every matrix entry proposed as dropped -->

## Owner Overrides
| Diff ID or feature id | Owner decision | Note |       <!-- owner fills; empty means none -->

## Disputed Cases
### D-<skill>-<nn>
- Context: ...
- Option A: ... / Option B: ...
- Recommendation: ...
- Owner-Decision:                 <!-- owner fills: A | B | other -->
```

A case is disputed when any of the following holds: the difference changes an enforcement behavior (a gate, a hook, an MCP-only rule, a stop condition); two copies each assert authority for conflicting rules (for example, MCP-only versus fallback in `feature-promotion-lifecycle`); the classification depends on information the survey could not verify; or the proposal drops a native feature. Everything else goes into the bulk set.

### 3.3 Stop mechanism

Execution writes the approval artifact and the experiment runbooks (topic 6), then stops once for both, which avoids two owner round trips. The orchestrator records the stop in `artifacts/orchestration/orchestrator-state.json` with `blocked_reason: "human_decision_required"` and a `human_interaction.requirements[]` entry per pending item (`response: "halt"` for the approval, `response: "exception"` with `runbook_path` for each runbook), per `.claude/rules/orchestrator-state.md` (`## Invariants (human_interaction block)`) and `.claude/skills/human-exception-runbook/SKILL.md`. Resume condition: `Approval-Status` is `approved` or `approved-with-overrides`, and every runbook has a recorded result (or an owner statement that it is deferred, which leaves the dependent matrix entries `provisional`).

---

## 4. Machine-Readable Parity Matrix

### 4.1 Precedent

- `config/` holds repository JSON configuration; `config/orchestration-handoff.schema.json` is a JSON Schema Draft 2020-12 file with `$id` `https://drm-copilot.dev/schemas/orchestration-handoff/2.0.0/schema.json`, kept next to the data it governs (`config/orchestration-handoff-registry.json`).
- `config/*.json` files are not bundled unless named: only `blast-radius.json` and `orchestration-routing.json` have copies under `extensions/drm-copilot/resources/claude-customizations/config/`. A new `config/` file therefore stays repository-local and creates no mirror obligation.
- `schemas/discovery/v1/` and `schemas/discovery/v2/` hold product schemas for the legacy-discovery feature, including `parity-matrix.schema.json`. The new matrix needs a distinct name to avoid confusion with that artifact.
- PowerShell precedent for schema validation: `.claude/lib/discovery-validation/DiscoveryValidation.psm1` documents `Test-Json -SchemaFile` with a PowerShell 7.4 floor for Draft 2020-12.
- No Node JSON-schema library is a dependency (`ajv`, `zod` absent from every `package.json`); `js-yaml` appears in the root `package.json` only under `overrides`.
- `config/file-size-baseline.json` with `scripts/ci/FileSizeBaseline.psm1` and `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` is the closest analogue: a committed JSON file, a PowerShell module, and a repository gate that reads the real tree in the PowerShell shards.
- The file-size policy covers `.py`, `.ps1`, `.psm1`, `.ts`, `.tsx`, `.js`, `.cjs`, `.mjs`, `.cs`, `.sh`, `.bats` only (`.claude/lib/file-size-policy/FileSizePolicy.psm1`), so a large JSON matrix is not subject to the 800-line limit.

### 4.2 Location and format

- Matrix: `config/harness-parity-matrix.json`
- Schema: `config/harness-parity-matrix.schema.json` (Draft 2020-12, `$id` `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json`)

Both are outside `docs/`, so child 7's move of development docs to `.dev` does not move them.

### 4.3 Schema

Top level (`additionalProperties: false`):

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `$schema` | string | yes | const `https://drm-copilot.dev/schemas/harness-parity-matrix/1.0.0/schema.json` |
| `schema_version` | string | yes | semver pattern `^\d+\.\d+\.\d+$`; `1.0.0` initially |
| `features` | array of feature | yes | `minItems: 1` |

Feature entry (`additionalProperties: false`):

| Field | Type | Required | Rule |
| --- | --- | --- | --- |
| `id` | string | yes | `<ecosystem>:<kind>:<name>`, pattern `^(claude\|codex\|copilot\|cross-tool):[a-z-]+:[A-Za-z0-9._@/#:+-]+$`; unique across `features` (checked by the test; JSON Schema cannot express uniqueness by property) |
| `ecosystem` | enum | yes | `claude`, `codex`, `copilot`, `cross-tool`; the ecosystem that owns the feature's current location. `cross-tool` is used only for `AGENTS.md`. `.agents/**` is `codex` (`.agents/README.md` describes it as the Codex surface) |
| `kind` | enum | yes | see 4.4 |
| `name` | string | yes | the bare feature name (skill folder, agent file stem, event+script, key) |
| `source_path` | string | yes | repository-relative POSIX path of the defining file |
| `source_pointer` | string | no | location inside the file: a JSON pointer (`/permissions/deny`), a TOML table (`[mcp_servers.drm-copilot]`) or a frontmatter key |
| `disposition` | enum | yes | `shared`, `native`, `generated`, `dropped` |
| `reason` | string | when `dropped` | `minLength: 1`; optional otherwise |
| `target_paths` | array of string | when `shared` or `generated` | `minItems: 1`; absent or empty when `dropped` |
| `generated_from` | string | when `generated` | repository-relative path of the single source |
| `generator` | string | no | generator identifier, filled by child 3 |
| `parity_group` | string | yes | logical function key shared by equivalent features across ecosystems (for example `skill:orchestrate`, `hook:validate-bash`, `mcp:drm-copilot`); supports hook parity of function in child 5 |
| `consumers` | array of enum | yes | tools that load the feature with default settings: `claude-code`, `codex`, `copilot-vscode`, `copilot-cli`, `copilot-cloud`; may be empty; values pending an experiment are set provisionally |
| `owner_child` | integer or null | yes | epic child that realizes the disposition (3 to 7), or null when no change is needed |
| `decision_status` | enum | yes | `approved`, `provisional` |
| `decision_ref` | string | when `provisional` or `dropped` | path of the approval artifact section or runbook result that settles it |
| `notes` | string | no | |

Conditional rules expressed in the schema with `if`/`then`: `dropped` requires `reason` and `decision_ref`; `shared` and `generated` require non-empty `target_paths`; `generated` requires `generated_from`; `provisional` requires `decision_ref`.

### 4.4 Feature kinds and inventory sources

Each kind has a deterministic enumeration rule. The completeness test enumerates features from these rules and compares them with the matrix.

| Kind | Ecosystem | Inventory source and rule |
| --- | --- | --- |
| `instructions` | cross-tool / claude / copilot | `AGENTS.md`; `CLAUDE.md`; `.github/copilot-instructions.md` (one entry per file) |
| `path-scoped-rule` | claude / copilot | `.claude/rules/*.md`; `.github/instructions/*.instructions.md` |
| `skill` | claude / codex / copilot | `.claude/skills/<name>/SKILL.md`; `.agents/skills/<name>/SKILL.md`; `.github/skills/<name>/SKILL.md` (one entry per folder) |
| `skill-frontmatter-field` | per tree | each distinct frontmatter key used in a tree's `SKILL.md` files (one entry per tree and key) |
| `skill-metadata-file` | codex | `.agents/skills/<name>/agents/openai.yaml` |
| `agent` | claude / codex / copilot | `.claude/agents/*.md`; `.codex/agents/*.toml` (base and generated variants); `.github/agents/*.agent.md` |
| `subagent-frontmatter-field` | per tree | each distinct frontmatter key in `.claude/agents/*.md` and `.github/agents/*.agent.md`, and each distinct top-level key in `.codex/agents/*.toml` |
| `handoff` | copilot | each `.github/agents/*.agent.md` that declares `handoffs:` |
| `prompt` | copilot / codex | `.github/prompts/**/*.prompt.md` (including `drafts/`); `.codex/prompts/*.md` |
| `hook-registration` | claude / codex / copilot | each (event, matcher, command) in `.claude/settings.json` `hooks`; each `[[hooks.<Event>]]` entry in `.codex/config.toml`; each registration in `.github/hooks/*.json`; each `hooks:` entry in `.claude/agents/*.md` frontmatter |
| `permission` | claude / codex | `.claude/settings.json` `permissions` sub-keys (`allow`, `deny`, `ask`, `defaultMode`, `additionalDirectories`); `.codex/config.toml` `[permissions.<profile>]` tables |
| `setting` | claude / codex | other top-level keys of `.claude/settings.json`; other top-level tables and keys of `.codex/config.toml` (`[features]`, `[agents]`, ...) |
| `mcp-server` | claude / codex | each server under `mcpServers` in `.mcp.json`; each `[mcp_servers.<id>]` table in `.codex/config.toml` |

Verified source facts: `.claude/settings.json` registers `SessionStart`, `PreToolUse`, `SubagentStart` and `SubagentStop`; `.codex/config.toml` registers `UserPromptSubmit`, `SubagentStart`, `PreToolUse` and `SubagentStop` and has `[mcp_servers.drm-copilot]`, `[permissions.orchestrator-workspace]`, `[features]` and `[agents]`; `.mcp.json` declares `drm-copilot`; `.github/hooks/` holds `discovery.json` and five scripts; `.github/prompts/` holds 30 prompt files including five under `drafts/`; `.codex/prompts/` holds four files.

Exclusions (recorded as inclusion rules in the schema description and the test):

- Gitignored or local-only paths: `.claude/settings.local.json`, `.claude/agent-memory/`, `.claude/state/`, `.claude/worktrees/`, `.codex/state/`, `.vscode/settings.json` (gitignored per `.gitignore`). Whether `.claude/settings.local.json` is tracked is to be confirmed by the orchestrator (`git ls-files`); it is excluded either way as local scope.
- Implementation libraries that are not themselves registered features: `.claude/lib/**`, `.codex/scripts/**`, and hook helper scripts that no registration names. Their function is represented by the registrations that load them. Owner question Q6 asks whether a per-file entry is wanted for these.
- Bundle copies under `extensions/drm-copilot/resources/**`, which mirror features already enumerated.
- README files (`.agents/README.md`, `.agents/skills/README.md`, `.github/skills/README.md`).

### 4.5 Default dispositions from the confirmed design

These follow the structure table in the promoted epic record and are the starting values execution writes; the owner approves them through the approval artifact.

| Feature | Disposition | Owner child | Note |
| --- | --- | --- | --- |
| `codex:skill:<shared name>` | shared | 3 | source of truth; `target_paths` includes `.claude/skills/<name>/SKILL.md` |
| `claude:skill:<shared name>` | generated | 3 | `generated_from` `.agents/skills/<name>/SKILL.md` |
| `copilot:skill:<name>` | dropped | 6 | reason: superseded by the shared `.agents/skills/<name>`, which Copilot reads natively; `decision_ref` the approval artifact |
| Claude-only and Codex-only skills | native or shared | 3 | per approved disposition proposal |
| `cross-tool:instructions:AGENTS.md` | shared | 3 | |
| `claude:instructions:CLAUDE.md` | native | 3 | `@AGENTS.md` plus Claude-only text |
| `copilot:instructions:copilot-instructions.md` | native | 6 | Copilot-only text |
| `.claude/rules/*`, `.github/instructions/*` | generated | 3 | from one rule source |
| `claude:agent:*`, `codex:agent:*` base | generated | 3 | from one logical definition |
| `codex:agent:*-c1..c4`, `*-c3-elevated` | generated | none | existing `scripts/dev_tools/generate_codex_agent_variants.py` |
| `copilot:agent:*` | provisional | 6 | dropped or generated per experiment E3 |
| `mcp-server` entries | generated | 3 | from one server list |
| `hook-registration`, `permission`, subagent frontmatter fields | native | 5 | parity of function via `parity_group` |
| `prompt`, `handoff`, Copilot hooks | native | 6 | thin Copilot layer |

---

## 5. Completeness Test: Language and Harness

### 5.1 Options

| Criterion | A. Pester under `tests/scripts/harness/` | B. Root TypeScript (`src/`, `tests/unit/`) | C. Extension TypeScript (`extensions/drm-copilot/`) |
| --- | --- | --- | --- |
| CI job | `poshqc / PowerShell QC` shards (`_poshqc.yml`), picked up automatically from `config/poshqc-scan.json` (`scanFolders` includes `tests/scripts`) | `root-typescript-tests / Root TypeScript Tests (<os>)` | `drm-copilot-extension-tests / ...` |
| Required check | yes (`poshqc / PowerShell QC` is in the ruleset list in the brief) | no (absent from the required contexts) | yes |
| Coverage gate | 85% line on any new `scripts/**` PowerShell file (`config/poshqc-coverage.json` root `scripts`); no config edit needed | none configured: root `jest.config.cjs` has no `coverageThreshold` and `npm test` runs without `--coverage`; a gate needs new root config | per-file `coverageThreshold` entry required in `extensions/drm-copilot/jest.config.cjs` |
| OS | Windows only (the Linux job runs only `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`) | Windows and Linux | Windows and Linux |
| Parsing | `ConvertFrom-Json`; `Test-Json -SchemaFile` (7.4 floor, repository precedent); no TOML or YAML parser, so frontmatter keys and TOML table headers are read with anchored regular expressions | `JSON.parse`; no schema validator, TOML or YAML parser without a new dependency, so the same regex approach applies | same as B |
| Destination dependency | PowerShell 7 is already required by every enforcement hook | Node is already required for the MCP server | Node |
| Parallel-run overlap | none (new paths) | none | `extensions/drm-copilot/jest.config.cjs` is in the blast radius of 1003 and 1006 |
| Fit | repository gate on repository files, same pattern as `FileSizePolicy.RepoGate.Tests.ps1` | root `src/` holds only `src/hello-typescript.ts`; no gate precedent | shipped extension product code; a self-check of this repository's harness does not belong there |

### 5.2 Recommendation: PowerShell (option A)

Reasons: it runs in a required check, it has an existing coverage gate with no configuration change, it follows the `config/file-size-baseline.json` + `scripts/ci/FileSizeBaseline.psm1` + repository-gate pattern, it has a schema-validation precedent, and it adds no dependency for destinations. No part of child 1 needs new Python; no owner question about Python is raised.

Proposed files:

- `scripts/harness/HarnessInventory.psm1` — enumerates native features per the rules in 4.4. File listing and file reading go through injected script-block parameters that default to the real file system, so unit tests use in-memory content.
- `scripts/harness/HarnessParityMatrix.psm1` — loads and validates the matrix: schema conformance (`Test-Json -SchemaFile`), id uniqueness, completeness (every enumerated feature has exactly one entry), no orphans (an entry whose feature is no longer enumerated must be `dropped`), conditional fields. Exposes a skeleton function that emits entries for unmatched features, which execution uses once to bootstrap the matrix.
- `scripts/harness/HarnessSkillContract.psm1` — the contract presence and structure check from 2.3.
- `tests/scripts/harness/HarnessInventory.Tests.ps1`, `tests/scripts/harness/HarnessParityMatrix.Tests.ps1`, `tests/scripts/harness/HarnessSkillContract.Tests.ps1` — unit tests with in-memory seams covering: missing disposition, unknown disposition, dropped without reason, dropped without `decision_ref`, duplicate id, missing entry, orphan entry, `generated` without `generated_from`, `provisional` without `decision_ref`, contract heading order and identifier rules.
- `tests/scripts/harness/HarnessParityMatrix.RepoGate.Tests.ps1` — reads the committed tree and `config/harness-parity-matrix.json`, applies all rules, and also runs the contract check. Failure messages list each offending id.

Test locations mirror production paths as required by `.claude/rules/general-unit-test.md` (`## Test File Location`).

Costs and risks:

- Three new production `.psm1` files equal the direct-mode batch budget of three per worktree session (brief, `## Batch Budget`); a fourth would be denied. The plan keeps three modules or splits the work across sessions.
- `Test-Json -SchemaFile` with Draft 2020-12 needs PowerShell 7.4 or later on the Windows runner; orchestrator to confirm the runner version. If it is lower, the schema would be authored in Draft 7, or the module would apply the schema rules in code and keep the schema file as documentation.
- The inventory module covers 13 kinds and may approach the 500-line guidance tier; split by kind family if it does.
- Children 3 to 6 that work in TypeScript read the JSON directly; they do not need the PowerShell module.

---

## 6. Unverified-Behavior Experiments

Fetched 2026-10-30. "Resolved" means the documentation settles the question for planning.

### E1. Copilot listing of a skill present in `.github/skills`, `.claude/skills` and `.agents/skills`

- Documentation: VS Code reads all three project locations (https://code.visualstudio.com/docs/copilot/customization/agent-skills; default of `chat.agentSkillsLocations` in https://code.visualstudio.com/docs/copilot/reference/copilot-settings). For Marketplace installs, "If another supported location contains a skill with the same name, both skills appear on the Skills page." For multiple workspace roots, "the primary root takes precedence." Copilot CLI reads `.github/skills`, `.claude/skills` and `.agents/skills` and does not describe duplicates (https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills). Codex: "If two skills share the same `name`, Codex doesn't merge them; both can appear in skill selectors" (https://learn.chatgpt.com/docs/build-skills).
- Resolved: no. The documentation suggests duplicates are listed, but not for the same-repository case.
- Runbook `<FEATURE>/runbooks/e1-copilot-duplicate-skill-listing.runbook.md`: preconditions — a scratch repository with a probe skill `harness-probe-dup` whose `description` differs per location (`from-github`, `from-claude`, `from-agents`) in all three folders; VS Code with Copilot Chat; Copilot CLI. Steps — open the Chat Skills page and the `/` menu in VS Code, then run `/skills` in the Copilot CLI. Expected observations — the number of `harness-probe-dup` entries and which description each shows. Result — `<FEATURE>/evidence/other/e1-copilot-duplicate-skill-listing-result.<timestamp>.md`. Stop — execution does not finalize `consumers` for `copilot:skill:*` entries until recorded.

### E2. Codex tolerance of Claude-only skill frontmatter

- Documentation: Codex requires `name` and `description` and does not say how other fields are treated (https://learn.chatgpt.com/docs/build-skills). Claude Code ignores unrecognized fields "without reporting an error" (https://code.claude.com/docs/en/skills). The Agent Skills specification lists `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` (https://agentskills.io/specification). VS Code supports `argument-hint`, `user-invocable`, `disable-model-invocation` and `context: fork` for skills (agent-skills page), so a superset frontmatter in `.agents/skills` also changes Copilot behavior in VS Code.
- Resolved: no for Codex; the VS Code side effect is documented and is recorded for child 3.
- Runbook `<FEATURE>/runbooks/e2-codex-claude-frontmatter.runbook.md`: preconditions — scratch repository, trusted in Codex; `.agents/skills/harness-probe-fm/SKILL.md` with `allowed-tools`, `argument-hint`, `context: fork`, `agent: some-agent`, `disable-model-invocation`, `user-invocable`. Steps — start Codex, list skills, invoke `$harness-probe-fm`, and inspect startup output and logs for warnings. Expected — the skill is listed and runs, or a parse error or warning names a field. Optional second half — open the same folder in VS Code and record whether `context: fork` forks. Result — `<FEATURE>/evidence/other/e2-codex-claude-frontmatter-result.<timestamp>.md`. Stop — child 3's superset-frontmatter rule depends on it.

### E3. Copilot CLI and Copilot cloud agent reading `.claude/agents`

- Documentation: VS Code reads `.claude/agents` (default `chat.agentFilesLocations`; https://code.visualstudio.com/docs/copilot/customization/custom-agents). The Copilot CLI lists `~/.copilot/agents`, `.github/agents` and the organization `.github-private` repository and does not mention `.claude/agents` (https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/overview). The cloud agent documentation names `.github/agents` only (https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents). VS Code states that the CLI does "not inherit editor location settings." The configuration reference (https://docs.github.com/en/copilot/reference/custom-agents-configuration) describes no Claude-format support.
- Resolved: partly. The documentation indicates no for the CLI and the cloud agent, but absence is not proof.
- Runbook `<FEATURE>/runbooks/e3-copilot-cli-cloud-claude-agents.runbook.md`: preconditions — a scratch GitHub repository with only `.claude/agents/harness-probe-agent.md` (Claude format) and no `.github/agents`; Copilot CLI installed; cloud agent enabled on the repository. Steps — in the CLI, run `/agent` and record the list; on GitHub.com, open the agent picker for a new cloud-agent task and record the list. Expected — whether `harness-probe-agent` appears in each. Result — `<FEATURE>/evidence/other/e3-copilot-cli-cloud-claude-agents-result.<timestamp>.md`. Stop — the `copilot:agent:*` entries stay `provisional` until recorded; child 6 depends on it.

### E4. Workspace-scope Copilot settings

- Documentation: the settings that control which files Copilot reads are `chat.agentSkillsLocations`, `chat.instructionsFilesLocations`, `chat.agentFilesLocations`, `chat.useClaudeMdFile`, `chat.useAgentsMdFile`, `chat.useClaudeHooks`, `chat.hookFilesLocations`, `github.copilot.chat.codeGeneration.useInstructionFiles` (copilot-settings reference). The reference does not classify their scope. The agent-skills page contradicts itself on whether `chat.agentSkillsLocations` is deprecated. The CLI does not inherit editor location settings.
- Repository fact: `.vscode/settings.json` is gitignored (`.gitignore` lines 46-47); the repository commits `.vscode/settings_required.json` instead. Even if workspace scope works, delivering collision controls in `.vscode/settings.json` needs a delivery decision (owner question Q5).
- Resolved: no.
- Runbook `<FEATURE>/runbooks/e4-copilot-workspace-settings.runbook.md`: preconditions — scratch repository with the E1 probe skill in all three folders, a probe rule in `.claude/rules` and in `.github/instructions`, and a probe agent in `.claude/agents` and `.github/agents`; no user-level overrides for these settings. Steps — add `.vscode/settings.json` with `chat.agentSkillsLocations` `{".claude/skills": false, ".github/skills": false}`, `chat.instructionsFilesLocations` `{".claude/rules": false}`, `chat.agentFilesLocations` `{".claude/agents": false}`, `chat.useClaudeMdFile: false`; reload; record what the Skills page, the agent picker and the chat References show; then check whether VS Code marks any of these settings as not applicable at workspace level. Result — `<FEATURE>/evidence/other/e4-copilot-workspace-settings-result.<timestamp>.md`. Stop — child 6 depends on it.

### E5. Claude Code hooks, subagent and permissions details

- Documentation (resolved; no runbook needed):
  - Subagents (https://code.claude.com/docs/en/sub-agents): fields `name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `autoCompactWindow`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `omitClaudeMd`, `effort`, `isolation`, `color`, `initialPrompt`, `experimental`; unknown fields are ignored "without reporting an error"; precedence managed > `--agents` > `.claude/agents/` > `~/.claude/agents/` > plugin; frontmatter hooks support all events, with `Stop` converted to `SubagentStop`; project agents skip frontmatter hooks until the folder is trusted.
  - Hooks (https://code.claude.com/docs/en/hooks): configurable in user, project, local and managed settings, plugin `hooks/hooks.json`, skill frontmatter and subagent frontmatter; entries merge across levels; handler types `command`, `http`, `mcp_tool`, `prompt`, `agent`; exit code 2 blocks; other non-zero codes are non-blocking.
  - Permissions (https://code.claude.com/docs/en/permissions): rules evaluate deny, then ask, then allow; `//path` is absolute, `~/path` is home-relative, `/path` is relative to the settings source; Windows paths are normalized to POSIX form (`//c/...`).
  - Skills: frontmatter field list in topic 1 sources; Claude Code does not read `.agents/skills`.
- Several statements carry Claude Code version floors (for example v2.1.296); the matrix records features, not versions.

### E6 (added). Default double loading by Copilot

- Documentation: `chat.instructionsFilesLocations` defaults to both `.github/instructions` and `.claude/rules`; `chat.agentFilesLocations` defaults to both `.github/agents` and `.claude/agents`; `chat.useClaudeMdFile` defaults to `true` (copilot-settings reference). The Copilot CLI reads `AGENTS.md` and `CLAUDE.md` and combines them, removing only identical copies (https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions).
- Consequence for the "exactly once" goal: with default settings, generated rules written to both `.claude/rules` and `.github/instructions` are both visible to Copilot in VS Code, and the Claude-only text in `CLAUDE.md` is visible to Copilot. This does not change the confirmed design; it must be recorded in the matrix `consumers` field and handled by children 3 and 6.
- Resolved: the defaults are documented; actual load behavior (deduplication in the prompt) is not. Runbook `<FEATURE>/runbooks/e6-copilot-default-double-load.runbook.md`, combined with E4 in the same scratch repository: with no settings file, record the References list of a chat request that matches both probe rules, and the CLI `/instructions` list. Result — `<FEATURE>/evidence/other/e6-copilot-default-double-load-result.<timestamp>.md`.

Every runbook carries the five sections required by `.claude/skills/human-exception-runbook/SKILL.md` (Cue, Prerequisites, Step-by-step Instructions, Verification, Source and Citation with dated sources), and its Verification section gives the owner a result template with `Timestamp:`, `Command:` (the UI action or CLI command), `EXIT_CODE:` (0 when observed as described, 1 otherwise) and `Output Summary:`.

## Automation Feasibility

| Step | Needs | Can an agent run it? | Response |
| --- | --- | --- | --- |
| E1 VS Code skill list | VS Code with Copilot Chat UI | no | exception with runbook E1 |
| E1 CLI skill list | Copilot CLI, signed-in account | no (interactive, authenticated) | exception with runbook E1 |
| E2 Codex skill list and invocation | Codex CLI or app with a trusted project | no | exception with runbook E2 |
| E2 VS Code `context: fork` check | VS Code | no | exception with runbook E2 (optional part) |
| E3 CLI agent list | Copilot CLI | no | exception with runbook E3 |
| E3 cloud agent picker | GitHub.com UI with the cloud agent enabled | no | exception with runbook E3 |
| E4 workspace settings | VS Code reload and UI inspection | no | exception with runbook E4 |
| E6 References inspection | VS Code; Copilot CLI | no | exception with runbook E6 |
| E5 documentation reading | WebFetch | yes (done here) | resolved by documentation |
| Owner bulk approval | owner decision | no | `halt` with `blocked_reason: human_decision_required` |

All human steps share one stop (topic 3.3). Matrix entries whose values depend on a pending result stay `decision_status: provisional` with `decision_ref` set to the result path, so the completeness test passes before the results arrive and child 6 can require `approved` later.

---

## 7. Execution Precondition and Parallel-Run Overlap

The manifest for `bugs-1001-1002-1003-1006` lists nine items (1001, 1002, 1003, 1006, 1009, 1010, 1011, 1012, 1013). Child 1's recommended edit set, compared with every listed `blast_radius.paths` entry:

| Child 1 path | Overlap |
| --- | --- |
| `.agents/skills/<name>/references/standard.md` (new) | none. Nearest: `.agents/skills/execution-environment/SKILL.md` (1009) is a sibling file, not the same path |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/<name>/references/standard.md` (new) | none. Nearest: that bundle's `execution-environment/SKILL.md` and `pack-manifests/core.json` (1009, 1010) |
| `config/harness-parity-matrix.json`, `config/harness-parity-matrix.schema.json` (new) | no path overlap. They fall in the coarse `config` module that 1001, 1006, 1012 and 1013 declare; relevant only if run concurrently |
| `scripts/harness/*.psm1`, `tests/scripts/harness/*.Tests.ps1` (new) | none |
| `<FEATURE>/**` | none |

Paths child 1 must not edit (all in the blast radius, none needed): every `SKILL.md` (notably `.claude/skills/execution-environment/SKILL.md` and its five mirrors, `orchestrate`, `pr-author`, `epic-orchestrate`, `parallel-*`), both `pack-manifests/core.json` files, `docs/features/templates/policy_audit/*`, `config/poshqc-coverage.json` (not needed: `scripts` is already a coverage root), `config/file-size-baseline.json` (not needed: new files stay under 800 lines), `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, `extensions/drm-copilot/jest.config.cjs`, `scripts/dev_tools/generate_codex_agent_variants.py`, and every `tests/scripts/dev_tools/test_push_down_*` file (run, not edited).

Brief maintenance: child 1 adds no CI job, required context, tool route or batch-budget rule; a new test file under a scanned folder is already described by the brief. No update to the six copies of the execution-environment brief is needed.

The Phase 0 gate (epic `## Execution Preconditions`) re-checks this table against the merge base of `origin/main` and `HEAD` at execution time and confirms the parallel run has merged (orchestrator to confirm via `gh`).

---

## 8. Mirror and Bundle Impact

Verified test behavior:

- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (`test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`) walks every file under `.agents` and `.codex` with `rglob("*")` and requires a byte-equal copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/`. Each new `references/standard.md` therefore needs a bundle copy, or this existing test fails.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` enumerates only `.codex/agents/*.toml`, `.codex/hooks/*` and `.agents/skills/<name>/SKILL.md`. A `references/standard.md` file needs no manifest entry to pass.
- `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` checks only `SKILL.md` per skill folder.
- `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` checks consuming-product names in `**/SKILL.md` only, but scans every file under `.agents` for `TaskMaster.sln`.
- The Codex generator (`scripts/dev_tools/generate_codex_agent_variants.py`) generates agent variants, their bundle copies and the Codex `core.json` agent families; it does not copy skill files, so the skill bundle copies are maintained by hand (or by a scratch copy script) and the generator `--check` is unaffected.
- Precedent: `.claude/skills/mermaid-diagram/references/*.md` are bundled and listed in the Claude `core.json`, so manifest listing is how a references file reaches a destination.

Recommendation (least conflicting): add the bundle copies, which keeps the existing resource-contract test green, and add no pack-manifest entries in child 1. Because publishing is limited to files listed in a selected manifest, the contracts stay in the bundle but are not pushed to destinations until child 4 decides (owner question Q1). Both `core.json` files are in the parallel run's blast radius, which is a second reason to leave them alone.

Planning risk: a plan task that adds a contract without its bundle copy fails `test_push_down_codex_and_agents_resource_contracts.py`. The plan pairs each contract batch with its bundle-copy task and runs that test (an existing Python test, which the language directive allows) after each batch.

---

## Recommendations for spec.md

- **Survey artifacts:** `<FEATURE>/survey/skill-survey.md` (90-name index) and `<FEATURE>/survey/batch-<A..F>-<family>.md` (per-skill records in the shape in 1.4), with identity evidence under `<FEATURE>/evidence/baseline/`.
- **Contract:** `.agents/skills/<name>/references/standard.md` for every skill whose matrix entry is `codex:skill:<name>` with disposition `shared`; no frontmatter; H1 `# Gold Standard: <name>`; exactly the H2 headings `## Objective`, `## Observable Behaviors`, `## Acceptance Checks` in that order; `**OB-<n>**` and `**AC-<n>** (OB-...)` items; no checkboxes; not linked from `SKILL.md`; a byte-equal bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/`; no pack-manifest entry.
- **Approval artifact:** `<FEATURE>/survey/difference-approval.md` with `Approval-Status`/`Approved-By`/`Approved-At`, `## Bulk Approval Set`, `## Disposition Proposals`, `## Owner Overrides`, `## Disputed Cases`; classification enum `positive`, `negative`, `neutral`, `mechanism-only`; one combined owner stop with the runbooks.
- **Parity matrix:** `config/harness-parity-matrix.json`, governed by `config/harness-parity-matrix.schema.json` (Draft 2020-12). Top level `$schema`, `schema_version`, `features`. Entry fields: `id` (string, `<ecosystem>:<kind>:<name>`, unique), `ecosystem` (enum `claude|codex|copilot|cross-tool`), `kind` (enum `instructions|path-scoped-rule|skill|skill-frontmatter-field|skill-metadata-file|agent|subagent-frontmatter-field|handoff|prompt|hook-registration|permission|setting|mcp-server`), `name` (string), `source_path` (string), `source_pointer` (string, optional), `disposition` (enum `shared|native|generated|dropped`), `reason` (string, required when `dropped`), `target_paths` (string array, required non-empty when `shared` or `generated`), `generated_from` (string, required when `generated`), `generator` (string, optional), `parity_group` (string), `consumers` (array of enum `claude-code|codex|copilot-vscode|copilot-cli|copilot-cloud`), `owner_child` (integer 3-7 or null), `decision_status` (enum `approved|provisional`), `decision_ref` (string, required when `provisional` or `dropped`), `notes` (string, optional). Inventory sources and exclusions as in 4.4.
- **Completeness test:** PowerShell/Pester. Modules `scripts/harness/HarnessInventory.psm1`, `scripts/harness/HarnessParityMatrix.psm1`, `scripts/harness/HarnessSkillContract.psm1`; tests under `tests/scripts/harness/`, including `HarnessParityMatrix.RepoGate.Tests.ps1`; runs in the `poshqc / PowerShell QC` shards; fails on a missing entry, an orphan non-dropped entry, a missing or unknown disposition, a `dropped` entry without `reason` or `decision_ref`, a duplicate id, and on contract presence or structure violations; passes on the committed matrix.
- **Experiments:** E1-E4 and E6 as owner-run runbooks under `<FEATURE>/runbooks/` with results under `<FEATURE>/evidence/other/`; E5 recorded as resolved by documentation with URLs.
- **Language:** no new Python file; verified by a diff check for added `.py` files.

## Owner Questions

1. **Q1 Push-down of contracts.** Should `references/standard.md` files reach destination repositories (pack-manifest entries), or stay repository-local? Recommendation: decide in child 4; child 1 adds bundle copies only.
2. **Q2 Linking contracts from `SKILL.md`.** Should a shared `SKILL.md` link to its contract (agents may then load it on demand), or should the contract remain an unlinked judging standard? Recommendation: unlinked in child 1; child 3 decides when it authors the neutral bodies.
3. **Q3 Scope of the shared set.** Should the survey propose `shared` or `native` for each of the 35 single-ecosystem skills, with contracts written for every skill the owner approves as shared, or are contracts limited to the 55 names already in both Claude and Codex? Recommendation: the former.
4. **Q4 Porting approved positives.** Child 1 classifies and records the port direction; does porting happen in child 3 (when the shared bodies are authored) rather than in child 1? Recommendation: child 3, so child 1 edits no `SKILL.md`.
5. **Q5 `.vscode/settings.json` is gitignored.** If E4 shows that workspace scope works, should the repository commit `.vscode/settings.json` (a `.gitignore` change) or deliver the settings another way (for example the existing `settings_required.json` pattern or documentation)? This decision belongs to child 6; child 1 reports the fact.
6. **Q6 Granularity of hook and library features.** Is one matrix entry per hook registration (event, matcher, command) sufficient, or does the owner want an entry for every hook script and library file (`.claude/hooks/*`, `.codex/hooks/*`, `.claude/lib/**`, `.codex/scripts/**`)? Recommendation: registrations only, with library files excluded as implementation.
7. **Q7 E6 in scope.** Should the default double-loading experiment (E6) be part of child 1, given that it bears on the epic's "exactly once" criterion? Recommendation: yes, run it in the same scratch repository as E4.

Orchestrator to confirm (not owner questions): the epic record's 83 and 34 counts against the 79 and 33 observed; which 16 skills the epic record calls materially different; history behind `docs/features/completed/2026-04-29-harden-feature-promotion-lifecycle-mcp-only-168/` relative to the Copilot copy of `feature-promotion-lifecycle`; whether `.claude/settings.local.json` is tracked; the PowerShell version on the `windows-latest` runner; that the parallel run has merged.

---

## Numeric Derivation Evidence

### N1: 90 distinct skill names; per-folder 66 / 79 / 33

- Complete Family: skill folders directly under `.claude/skills/`, `.agents/skills/` and `.github/skills/`.
- Exhaustive Search Scope: all three trees in full, including folders that might lack `SKILL.md` and non-skill files at the tree root.
- Inclusion Rules: a direct child directory of a skills tree.
- Exclusion Rules: files at the tree root (`.agents/skills/README.md`, `.github/skills/README.md`); nested supporting folders (`references/`, `scripts/`, `agents/`).
- Primary Search Strategy or Query Expression: Glob `.claude/skills/*/SKILL.md`, `.agents/skills/*/SKILL.md`, `.github/skills/*/SKILL.md`; take the folder name.
- Primary Member Set: the union of the four sets listed under N2.
- Primary Count: 66, 79, 33; union 90.
- Cross-check Search Strategy or Query Expression: Glob `.claude/skills/**/*`, `.agents/skills/**/*`, `.github/skills/**/*` (every file, with or without `SKILL.md`); take the first path segment below the skills root; drop root-level files. A third independent pass, Grep count of `\S` over `**/SKILL.md` per tree, returned 66, 79 and 33 files.
- Cross-check Member Set: identical folder names; the only extra entries were the two root `README.md` files, removed by the exclusion rule.
- Cross-check Count: 66, 79, 33; union 90.
- Member-set Comparison: the normalized primary and cross-check sets are equal for each tree; no folder lacks `SKILL.md`.

### N2: partition 33 / 22 / 11 / 24 / 0 and shared 55

- Complete Family: the 90 names of N1.
- Exhaustive Search Scope: as N1.
- Inclusion Rules: membership by presence of the folder in each tree.
- Exclusion Rules: as N1.
- Primary Search Strategy or Query Expression: set operations on the N1 primary sets: all three = C ∩ A ∩ G; Claude and Codex only = (C ∩ A) \ G; Claude only = C \ A \ G; Codex only = A \ C \ G; Copilot only = G \ C \ A.
- Primary Member Set:
  - All three (33): `acceptance-criteria-tracking`, `adjudicate-unspecified-behavior`, `atomic-plan-contract`, `characterize-runtime-behavior`, `csharp-change-budget-router`, `csharp-orchestration-state-machine`, `discovery-behavior-reconciliation`, `discovery-coverage-ledger`, `discovery-parity-matrix`, `discovery-repo-inventory`, `discovery-runtime-characterization`, `discovery-validate-artifacts`, `discovery-workflow`, `evidence-and-timestamp-conventions`, `execution-environment`, `extract-feature-contract`, `feature-promotion-lifecycle`, `feature-review-workflow`, `generate-acceptance-scenarios`, `initialize-discovery-workspace`, `inventory-legacy-system`, `make-skill-template`, `policy-audit-template-usage`, `policy-compliance-order`, `powershell-change-budget-router`, `powershell-orchestration-state-machine`, `pr-base-branch-merge-base`, `pr-context-artifacts`, `reconcile-parity-matrix`, `remediation-handoff-atomic-planner`, `review-discovery-coverage`, `skill-canonical-location-audit`, `validate-discovery-artifacts`.
  - Claude and Codex only (22): `commit-message`, `csharp-qa-gate`, `epic-orchestrate`, `epic-plan`, `epic-run`, `execute-hard-lock`, `fill-feature-docs`, `human-exception-runbook`, `invoke-csharp-engineer`, `invoke-powershell-engineer`, `invoke-python-engineer`, `orchestrate`, `powershell-qa-gate`, `pr-author`, `python-change-budget-router`, `python-qa-gate`, `research-issue`, `review-epic`, `review-feature`, `review-staged`, `translate-copilot-to-claude`, `update-status`.
  - Claude only (11): `cleanup-merged-worktrees`, `identify-session-id`, `mermaid-diagram`, `parallel-add`, `parallel-close`, `parallel-orchestrate`, `parallel-plan`, `parallel-remove`, `parallel-run`, `quota-throttling`, `show-my-agent-tree`.
  - Codex only (24): `architecture-boundaries`, `atomic-executor`, `atomic-planner`, `benchmark-baselines`, `ci-workflows`, `codex-model-routing`, `commit-message-conventions`, `csharp`, `feature-review`, `general-code-change`, `general-unit-test`, `orchestrator-state`, `orchestrator-workflow`, `powershell`, `pr-authoring`, `python`, `python-suppressions`, `quality-tiers`, `repo-automation-adapter`, `self-explanatory-code-commenting`, `tonality`, `translate-claude-to-codex`, `typescript`, `typescript-suppressions`.
  - Copilot only (0): none.
- Primary Count: 33, 22, 11, 24, 0; shared (C ∩ A) 55.
- Cross-check Search Strategy or Query Expression: arithmetic identities over the N1 cross-check counts: |C| − |Claude only| = 66 − 11 = 55 = |C ∩ A|; |A| − |Codex only| = 79 − 24 = 55; |G| = 33 = |all three|, with every `.github/skills` folder name found in both other cross-check listings; 33 + 22 + 11 + 24 + 0 = 90.
- Cross-check Member Set: membership re-derived from the N1 full-file listings for each name.
- Cross-check Count: 33, 22, 11, 24, 0; 55.
- Member-set Comparison: equal; `.github/skills` is a strict subset of both `.claude/skills` and `.agents/skills`.

---

## Pre-Mortem

- **Review checklists:** the feature review checks the "no new Python" criterion, tone, per-file coverage, file size and mirror parity. A plan that writes a helper as `.py`, or a contract that uses informal wording, fails review. Mitigation: a final task lists added files with `git diff --name-only --diff-filter=A` against the merge base and asserts none ends in `.py`; contracts and survey records follow `.claude/rules/tonality.md`.
- **Coverage:** each new `scripts/harness/*.psm1` needs at least 85% line coverage, read from `artifacts/pester/powershell-coverage.xml` (MCP results carry no output, per the brief). The repository gate cannot reach the error branches. Mitigation: unit tests drive every rule through in-memory seams; the plan records per-file coverage from the XML and adds tests until each file meets the floor.
- **Mirror parity:** every new `.agents/skills/<name>/references/standard.md` needs a byte-equal bundle copy, or `test_push_down_codex_and_agents_resource_contracts.py` fails; contract text must not contain `TaskMaster.sln` (`test_push_down_issue_824_follow_ups.py`). Mitigation: each contract batch is paired with its bundle-copy task, and both tests run after each batch. No pack manifest, no `SKILL.md` and no copy of the execution-environment brief is edited; the plan's `Mirror parity` bullet states that no brief fact changes.
- **File size:** the inventory module covers 13 kinds and could pass the 500-line guidance tier. Mitigation: one module per concern (inventory, matrix, contract), splitting the inventory by kind family if it nears 500 lines; JSON and Markdown are exempt, and the three new modules stay within the direct-mode batch budget of three.
- **Test isolation:** unit tests must not create temporary files or leave modules or script-scope state behind. Mitigation: file listing and reading are injected script blocks; each suite removes its modules in `AfterAll`; the plan records three seeded shuffled file-order runs of `tests/scripts/harness` and a fresh single-process run over `tests/scripts` under `<FEATURE>/evidence/regression-testing/`.
- **CI-only behavior:** the gate runs only in the Windows shards, on a clean checkout. If the inventory reads gitignored paths that exist locally (`.claude/settings.local.json`, `.claude/agent-memory/`, `.vscode/settings.json`, `artifacts/`), it passes locally and fails in CI, or the reverse. `Test-Json -SchemaFile` with Draft 2020-12 needs PowerShell 7.4 on the runner. Mitigation: the exclusion list in 4.4 is applied in the inventory module and has its own unit test; the plan confirms the runner version or falls back as described in 5.2; paths use `Join-Path` and forward-slash relative forms.
- **Evidence:** owner-run experiment results may lack the machine-checkable fields, and an executor could record an absolute path. Mitigation: each runbook's Verification section supplies a result template with `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`; all artifacts use repository-relative paths and the `SCRATCH` token; evidence filenames carry the UTC write time.
