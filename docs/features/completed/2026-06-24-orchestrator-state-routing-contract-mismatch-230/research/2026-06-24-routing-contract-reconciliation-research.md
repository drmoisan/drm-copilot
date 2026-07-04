# Routing Contract Reconciliation Research — Issue #230

- **Feature:** orchestrator-state-routing-contract-mismatch-230
- **Date:** 2026-06-24
- **Author:** task-researcher

---

## 1. Actual Agent Roster

### Enumerated agents (`.claude/agents/*.md` — `name:` frontmatter field)

| File | `name:` value |
|---|---|
| `.claude/agents/atomic-executor.md` | `atomic-executor` |
| `.claude/agents/atomic-planner.md` | `atomic-planner` |
| `.claude/agents/csharp-typed-engineer.md` | `csharp-typed-engineer` |
| `.claude/agents/epic-review.md` | `epic-review` |
| `.claude/agents/feature-review.md` | `feature-review` |
| `.claude/agents/orchestrator.md` | `orchestrator` |
| `.claude/agents/powershell-typed-engineer.md` | `powershell-typed-engineer` |
| `.claude/agents/prd-feature.md` | `prd-feature` |
| `.claude/agents/python-typed-engineer.md` | `python-typed-engineer` |
| `.claude/agents/staged-review.md` | `staged-review` |
| `.claude/agents/status-updater.md` | `status-updater` |
| `.claude/agents/task-researcher.md` | `task-researcher` |
| `.claude/agents/typescript-engineer.md` | `typescript-engineer` |

### Routing-matrix name mismatches

**`feature-reviewer` (routing matrix) vs. `feature-review` (real agent)**

The routing matrix (`config/orchestration-routing.json`, lines 10, 39, 63) lists `feature-reviewer` in all three routes. No agent named `feature-reviewer` exists under `.claude/agents/`. The actual review agent is `feature-review` (`.claude/agents/feature-review.md`, frontmatter `name: feature-review`). The orchestrator skill (`.claude/skills/orchestrate/SKILL.md`, line 63) and `orchestrator.md` (`.claude/agents/orchestrator.md`, line 5) both reference `feature-review`.

**`commit-steward` (routing matrix) — no such agent exists**

The routing matrix lists `commit-steward` in all three routes (lines 11, 44, 64). No agent named `commit-steward` exists anywhere under `.claude/agents/`. The Codex-era `orchestrator-workflow` skill (from `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`) references `commit-steward` as a Codex agent from the Copilot ecosystem. In the Claude Code runtime, commits are produced directly by the orchestrator: the orchestrate skill (`.claude/skills/orchestrate/SKILL.md`, lines 96–104 "Pre-Feature-Review Commit" and lines 121 "Pre-R4 commit") requires the orchestrator to invoke the `commit-message` skill and run `git commit` itself, with no subagent delegation. There is no approved non-delegation path for `commit-steward` in the Claude Code runtime.

**`prd-feature` — present in large route (correct)**

The large route includes `prd-feature` (line 38), and `.claude/agents/prd-feature.md` exists with `name: prd-feature`. This entry is correct.

**`task-researcher` — present in large route (correct)**

The large route includes `task-researcher` (line 37), and `.claude/agents/task-researcher.md` exists with `name: task-researcher`. This entry is correct.

---

## 2. Actual Skill Inventory

### Enumerated skills (`.claude/skills/*/` directories)

Verified via glob `.claude/skills/**`:

| Directory | Exists? |
|---|---|
| `.claude/skills/acceptance-criteria-tracking/` | Yes |
| `.claude/skills/atomic-plan-contract/` | Yes |
| `.claude/skills/commit-message/` | Yes |
| `.claude/skills/evidence-and-timestamp-conventions/` | Yes |
| `.claude/skills/feature-promotion-lifecycle/` | Yes |
| `.claude/skills/feature-review-workflow/` | Yes |
| `.claude/skills/fill-feature-docs/` | Yes |
| `.claude/skills/human-exception-runbook/` | Yes |
| `.claude/skills/invoke-csharp-engineer/` | Yes |
| `.claude/skills/invoke-powershell-engineer/` | Yes |
| `.claude/skills/invoke-python-engineer/` | Yes |
| `.claude/skills/make-skill-template/` | Yes |
| `.claude/skills/orchestrate/` | Yes |
| `.claude/skills/policy-audit-template-usage/` | Yes |
| `.claude/skills/policy-compliance-order/` | Yes |
| `.claude/skills/pr-author/` | Yes |
| `.claude/skills/pr-base-branch-merge-base/` | Yes |
| `.claude/skills/pr-context-artifacts/` | Yes |
| `.claude/skills/remediation-handoff-atomic-planner/` | Yes |
| `.claude/skills/research-issue/` | Yes |

### Required-skills entries in routing matrix vs. real skill inventory

| Routing matrix entry | Skill directory exists? | Status |
|---|---|---|
| `orchestrate` | `.claude/skills/orchestrate/SKILL.md` | **EXISTS — correct** |
| `orchestrator-workflow` | No directory under `.claude/skills/` | **MISSING** |
| `feature-promotion-lifecycle` | `.claude/skills/feature-promotion-lifecycle/SKILL.md` | **EXISTS — correct** |
| `repo-automation-adapter` | No directory under `.claude/skills/` | **MISSING** |
| `atomic-plan-contract` | `.claude/skills/atomic-plan-contract/SKILL.md` | **EXISTS — correct** |
| `acceptance-criteria-tracking` | `.claude/skills/acceptance-criteria-tracking/SKILL.md` | **EXISTS — correct** |
| `pr-context-artifacts` | `.claude/skills/pr-context-artifacts/SKILL.md` | **EXISTS — correct** |
| `pr-base-branch-merge-base` | `.claude/skills/pr-base-branch-merge-base/SKILL.md` | **EXISTS — correct** |

### Missing skills — origin and mapping

**`orchestrator-workflow`**

This skill exists only in the bundled Copilot/Codex customization payload at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md`. That file defines a Codex-era top-level orchestration workflow. In the Claude Code runtime, the equivalent role is filled by `.claude/skills/orchestrate/SKILL.md`, which defines the same top-level delivery orchestration logic. The `orchestrate` skill is what the Claude Code orchestrator consults, not `orchestrator-workflow`. The `orchestrator-workflow` skill is not part of the `.claude/skills/` inventory and is not invoked at runtime.

**`repo-automation-adapter`**

This skill exists only in the bundled Copilot/Codex payload at `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/repo-automation-adapter/SKILL.md`. It defines a Codex-era abstraction layer for MCP tool invocation (PR context, commit context, promotion, validation). In the Claude Code runtime, the orchestrator invokes MCP tools directly using the `mcp__drm-copilot__*` tool names listed in `.claude/agents/orchestrator.md` (lines 22–28). There is no separate `repo-automation-adapter` skill under `.claude/skills/`. The `feature-promotion-lifecycle` skill at `.claude/skills/feature-promotion-lifecycle/SKILL.md` and the `pr-context-artifacts` + `pr-base-branch-merge-base` skills cover the same coordination responsibilities in the Claude Code runtime.

---

## 3. Actual MCP Tool Inventory

### Tools registered by the `drm-copilot` MCP server

The authoritative tool registration is in two TypeScript sources:

- `extensions/drm-copilot/src/mcp-tool-definitions.ts` — exported `toolDefinitions` array (lines 20–408), consumed by `mcp-tools.ts` dispatcher via the `collect_commit_context`, `collect_pr_context`, `validate_orchestration_artifacts`, etc. case branches (line 137 for `collect_commit_context`)
- `extensions/drm-copilot/src/repo-automation-tool-names.ts` — `REPO_AUTOMATION_TOOLS` const (lines 1–22) is the exhaustive typed registry; `mcp-repo-automation-tool-definitions.ts` (lines 20–444) provides the second tool-definition array used by the MCP repo-automation surface

The complete tool roster exposed by the MCP server (union of both definition sources):

`collect_commit_context`, `collect_pr_context`, `run_codex_native_converter`, `push_down_copilot_customizations`, `push_down_codex_and_agents_customizations`, `push_down_claude_customizations`, `new_potential_bug_entry`, `new_potential_entry`, `link_parent_child`, `potential_to_issue`, `new_active_feature_folder`, `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`, `run_poshqc_analyze_autofix`, `run_poshqc_suite`, `resolve_policy_audit_template_asset`, `resolve_execute_hard_lock_prompt`, `resolve_atomic_plan_prompt`, `validate_orchestration_artifacts`

### Routing matrix `required_mcp_tools` vs. real tool inventory

| Routing matrix entry | Exists in MCP server? |
|---|---|
| `new_potential_entry` | **YES** — `mcp-tool-definitions.ts` line 155, `mcp-repo-automation-tool-definitions.ts` line 153 |
| `potential_to_issue` | **YES** — `mcp-tool-definitions.ts` line 172, `mcp-repo-automation-tool-definitions.ts` line 190 |
| `new_active_feature_folder` | **YES** — `mcp-tool-definitions.ts` line 201, `mcp-repo-automation-tool-definitions.ts` line 219 |
| `collect_commit_context` | **YES** — `mcp-tool-definitions.ts` line 22, `mcp-repo-automation-tool-definitions.ts` line 22, `repo-automation-tool-names.ts` line 2 |
| `collect_pr_context` | **YES** — `mcp-tool-definitions.ts` line 34, `mcp-repo-automation-tool-definitions.ts` line 34 |
| `validate_orchestration_artifacts` | **YES** — `mcp-tool-definitions.ts` line 375, `mcp-repo-automation-tool-definitions.ts` line 411 |

All six tools referenced in `required_mcp_tools` exist in the MCP server. The tool-name list is correct.

### `collect_commit_context` — is it receipted at runtime?

The MCP tool `collect_commit_context` is a real, registered tool. However, the orchestrate skill's "Pre-Feature-Review Commit" procedure (`.claude/skills/orchestrate/SKILL.md`, lines 96–104) instructs the orchestrator to invoke the `commit-message` skill and run `git commit` directly — not to call `collect_commit_context` via MCP. The skill does not call `mcp__drm-copilot__collect_commit_context` as part of its commit procedure. In contrast, the Codex-era `orchestrator-workflow` skill (bundled Copilot customization) required `collect_commit_context` via `repo-automation-adapter` before delegating to `commit-steward`.

The Claude Code orchestrate skill does not call `collect_commit_context` at all. Whether the orchestrator ever calls it in practice depends entirely on whether a particular orchestration session uses it for commit-context generation before feature review — the current orchestrate skill does not mandate this. There is no guaranteed `mcp_call_receipt` for `collect_commit_context` in a Claude Code orchestration run.

---

## 4. Receipt Emission Reality

### How receipts are produced

The orchestrator runtime produces three categories of receipts by writing them into `artifacts/orchestration/orchestrator-state.json`:

**`delegation_receipts` (list form):** Each time the orchestrator delegates to a subagent (`atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`), it is expected to record a receipt object under `delegation_receipts[]` with fields `step`, `agent_name`, `agent_id`, `skill_source`, `started_at`, `completed_at`, `result_signal`, `artifact_paths`. The validator reads `delegation_receipts[].agent_name` to collect the set of agents for which a receipt exists (`_receipt_agents`, `_orchestrator_state_routing.py` lines 63–71). These are written by the orchestrator (or the Codex `orchestrator-workflow` skill) after each delegation returns.

**`skill_receipts` (list form):** The Codex `orchestrator-workflow` skill (`extensions/.../orchestrator-workflow/SKILL.md`, lines 141–148) defines a receipt schema with `skill`, `required`, `acknowledged_at_phase`, `evidence`. The validator reads this via `_receipt_skills` (`_orchestrator_state_routing.py` lines 74–96). In the Claude Code runtime, the `orchestrate` skill does not define a mechanism for emitting discrete `skill_receipts` entries. The orchestrator skill (`orchestrate/SKILL.md`) contains no instruction to write `skill_receipts[]` objects to the checkpoint. As a result, a Claude Code orchestration run does not naturally produce `skill_receipts` entries, making the required-skills check structurally unsatisfiable.

**`mcp_call_receipts` (list form):** The Codex `orchestrator-workflow` skill (lines 148–153) defines a receipt schema with `tool`, `ok`, `evidence`. The validator reads this via `_mcp_tools` (`_orchestrator_state_routing.py` lines 99–121). The Claude Code orchestrate skill does not instruct the orchestrator to write `mcp_call_receipts[]` entries after each MCP call. As a result, MCP calls (even to real tools like `new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`, `collect_pr_context`, `validate_orchestration_artifacts`) are not automatically receipted.

### Summary of the receipt-emission gap

The receipt-emission contract (three arrays: `skill_receipts`, `mcp_call_receipts`, `delegation_receipts`) was designed for the Codex `orchestrator-workflow` runtime where the skill emitted these receipts explicitly. The Claude Code orchestrate skill does not include corresponding receipt-emission instructions. The `required_complete: true` validation therefore fails on two axes:

1. Agent name mismatch: `feature-reviewer` and `commit-steward` do not match real agents.
2. No receipt-emission contract: even if names were correct, no mechanism in the Claude Code orchestrate skill populates `skill_receipts[]` or `mcp_call_receipts[]`.

---

## 5. Candidate Approaches and Recommendation

Three axes require a decision: agents, skills, and MCP tools. The fix applies to the routing matrix (`config/orchestration-routing.json`) plus the `orchestrate` skill to add receipt-emission instructions.

### Axis A — Agent names

**Option A1 (Rename to match real agents):** Change `feature-reviewer` → `feature-review` and remove `commit-steward` from all three routes. Validation then checks against the actual agent names the orchestrator delegates to.

**Option A2 (Create stub agent files):** Add `.claude/agents/feature-reviewer.md` and `.claude/agents/commit-steward.md`. This is wrong: `feature-reviewer` is a Codex name with no mapping to any Claude Code concept, and `commit-steward` does not exist as a Claude Code agent (commits are orchestrator-direct). Creating stub files would misrepresent the runtime.

**Recommendation for Axis A:** Option A1. Replace `feature-reviewer` with `feature-review` in all three routes. Remove `commit-steward` from all three routes. The orchestrator's direct commit step (pre-feature-review and pre-R4) is not a delegated agent handoff; it does not produce a `delegation_receipt`. No `delegation_receipt` entry should be required for a step the orchestrator performs directly. If the orchestrator's commit step needs to be tracked, it belongs in a separate mechanism (e.g., a checkpoint field), not as a `required_agents` receipt.

### Axis B — Skill names

**Option B1 (Remove non-existent skills; add a receipt-emission contract to the orchestrate skill):** Remove `orchestrator-workflow` and `repo-automation-adapter` from `required_skills` in all routes. Update the `orchestrate` skill to include instructions for writing `skill_receipts[]` entries for each skill it actually uses. The remaining skills (`orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `acceptance-criteria-tracking`, `pr-context-artifacts`, `pr-base-branch-merge-base`) all exist under `.claude/skills/` and can be truthfully receipted.

**Option B2 (Eliminate `required_skills` checking entirely):** Remove the `required_skills` list from the routing matrix and remove the skill-receipt validation from `validate_routing_contract`. This eliminates the invariant entirely. This is a significant quality reduction: skills are genuine policy documents that govern behavior, and verifying their acknowledgment provides real assurance.

**Recommendation for Axis B:** Option B1. Removing the two non-existent skills is a targeted correction, not a regression. The `orchestrate` skill should include explicit instructions for writing `skill_receipts` entries at the beginning of each phase (read and acknowledge the required skills, record the evidence). The corrected skill list is actionable and maps to real `.claude/skills/` files.

### Axis C — MCP tools

All six tools in `required_mcp_tools` exist in the MCP server and are correct names. The issue is not the tool names — it is the absence of a `mcp_call_receipts` emission contract in the orchestrate skill.

**Option C1 (Remove `collect_commit_context` from `required_mcp_tools`; add receipt-emission to orchestrate skill for the remaining tools):** The orchestrate skill does not mandate calling `collect_commit_context` via MCP. Its "Pre-Feature-Review Commit" procedure invokes the `commit-message` skill and runs `git commit` directly. There is no structural guarantee that `collect_commit_context` is called during a Claude Code orchestration. The other five tools (`new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`, `collect_pr_context`, `validate_orchestration_artifacts`) are mandated by the `feature-promotion-lifecycle` skill and the completion gate. The orchestrate skill should include instructions to write `mcp_call_receipts[]` entries after each of these five calls.

**Option C2 (Keep `collect_commit_context` in the list and add MCP call to orchestrate skill):** The orchestrate skill could be updated to call `mcp__drm-copilot__collect_commit_context` before invoking `commit-message`, providing a commit-context artifact as input. This aligns with the Codex-era workflow. The tradeoff is adding a required MCP dependency to a commit step that currently works without it.

**Recommendation for Axis C:** Option C1. Remove `collect_commit_context` from all three routes' `required_mcp_tools`. The five remaining tools are real, mandated operations that occur in every completed orchestration run. The orchestrate skill must add instructions for emitting `mcp_call_receipts` after each call. This produces a truthful, satisfiable receipt set.

---

## 6. Recommended Target Values for the Routing Matrix

### `small` route

```json
{
  "required_agents": [
    "atomic-planner",
    "atomic-executor",
    "feature-review"
  ],
  "required_skills": [
    "orchestrate",
    "feature-promotion-lifecycle",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "pr-context-artifacts",
    "pr-base-branch-merge-base"
  ],
  "required_mcp_tools": [
    "new_potential_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "collect_pr_context",
    "validate_orchestration_artifacts"
  ]
}
```

Changes from current: removed `feature-reviewer`, removed `commit-steward`, removed `orchestrator-workflow`, removed `repo-automation-adapter`, removed `collect_commit_context`.

### `large` route

```json
{
  "required_agents": [
    "task-researcher",
    "prd-feature",
    "atomic-planner",
    "atomic-executor",
    "feature-review"
  ],
  "required_skills": [
    "orchestrate",
    "feature-promotion-lifecycle",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "pr-context-artifacts",
    "pr-base-branch-merge-base"
  ],
  "required_mcp_tools": [
    "new_potential_entry",
    "potential_to_issue",
    "new_active_feature_folder",
    "collect_pr_context",
    "validate_orchestration_artifacts"
  ]
}
```

Changes from current: removed `feature-reviewer`, removed `commit-steward`, removed `orchestrator-workflow`, removed `repo-automation-adapter`, removed `collect_commit_context`.

### `remediation` route

```json
{
  "required_agents": [
    "atomic-planner",
    "atomic-executor",
    "feature-review"
  ],
  "required_skills": [
    "orchestrate",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "pr-context-artifacts"
  ],
  "required_mcp_tools": [
    "collect_pr_context",
    "validate_orchestration_artifacts"
  ]
}
```

Changes from current: removed `feature-reviewer`, removed `commit-steward`, removed `orchestrator-workflow`, removed `repo-automation-adapter`, removed `collect_commit_context`.

Note: `feature-promotion-lifecycle` and `pr-base-branch-merge-base` are not listed in the current remediation route and are not added here; the remediation route does not include promotion lifecycle steps.

---

## 7. Receipt Emission Contract — Recommended Design

The orchestrate skill (`orchestrate/SKILL.md`) must be extended with explicit instructions for writing the three receipt arrays. No changes to `_orchestrator_state_routing.py` or the validator logic are needed because the validator already reads exactly these arrays.

**For `skill_receipts[]`:** At the start of each orchestration (after policy reading), the orchestrator emits one `skill_receipts` entry per required skill. Each entry has:
- `skill`: the skill name as it appears in `required_skills`
- `required`: `true`
- `acknowledged_at_phase`: the phase name (e.g., `"startup"`, `"planning"`, `"review"`)
- `evidence`: a non-empty string identifying the skill file read (e.g., `"read:.claude/skills/orchestrate/SKILL.md"`)

The skill-read step is already required by the orchestrate skill's prerequisites section (lines 13–17). Adding a checkpoint-write instruction after each skill read is the minimal extension needed.

**For `mcp_call_receipts[]`:** After each successful MCP tool call (any of the five required tools), the orchestrator appends one entry with:
- `tool`: the tool name as called
- `ok`: `true`
- `evidence`: the MCP response summary or artifact path

This is consistent with the existing `lifecycle_operations` pattern already used by the validator (checking `surface: "mcp"` on each entry, `_orchestrator_state_routing.py` lines 135–155).

**For `delegation_receipts[]`:** These are already produced by delegations to subagents. The only change is that the agent names in the checkpoint's `delegation_receipts[].agent_name` fields must match the corrected routing matrix names (`feature-review`, not `feature-reviewer`; no `commit-steward`).

---

## 8. Blast Radius — Files That Must Change

### Files that encode the wrong names and must be updated

| File | Type | Change required |
|---|---|---|
| `config/orchestration-routing.json` | JSON config | Rename agents, remove missing skills, remove `collect_commit_context` per recommended values above |
| `extensions/drm-copilot/resources/config/orchestration-routing.json` | Bundled copy (parity-checked by bundle-parity test) | Identical change — must stay in lockstep with canonical |

### Files that consume the routing matrix and must be regression-tested

| File | Type | Impact |
|---|---|---|
| `scripts/dev_tools/_orchestrator_state_routing.py` | Python module | No logic change required; it reads the matrix dynamically at runtime. No source changes needed, but existing tests (`test_validate_orchestrator_state_routing_contract.py`) use `load_routing_matrix()` to read the live matrix, so they will automatically test the corrected values after the config change |
| `extensions/drm-copilot/resources/scripts/dev_tools/_orchestrator_state_routing.py` | Bundled Python mirror | This file is a mirror of the canonical source with import-path rewrite only (`scripts.dev_tools.` → `dev_tools.`). The bundled copy reads the bundled config at `extensions/drm-copilot/resources/config/orchestration-routing.json`. It contains no hardcoded names and requires no logic changes |
| `scripts/dev_tools/validate_orchestrator_state.py` | Python validator | No changes needed; it calls `validate_routing_contract` which reads the matrix |
| `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestrator_state.py` | Bundled mirror | No changes needed (same reasoning as above) |

### Test files that assert specific agent/skill/tool names and must be updated

| File | Lines asserting stale names | Update required |
|---|---|---|
| `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` | Line 115: asserts `"Checkpoint missing required agent receipt: task-researcher."` (correct, this agent exists) — but `_build_complete_large_state()` at lines 20–88 builds the complete state from `load_routing_matrix()`, so it will automatically use the corrected matrix values. Line 138: asserts `"Checkpoint missing successful MCP receipt: new_potential_entry."` (this name is unchanged). All fixtures in this test are generated from `load_routing_matrix()` and do not hardcode agent/skill/tool names explicitly — they will be correct after the config change with no test logic modification needed. | Verify test still passes after config change; no code edits expected |

### Bundle-parity test

| File | What it checks | Impact |
|---|---|---|
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_bundle_parity.py` | Lines 44–56: checks that each of the five Python modules (`validate_orchestration_artifacts.py`, `validate_orchestrator_state.py`, `_orchestrator_state_human_interaction.py`, `validate_orchestration_review_artifacts.py`, `validate_policy_audit_artifact.py`) in `extensions/drm-copilot/resources/scripts/dev_tools/` matches its canonical source in `scripts/dev_tools/` after import-path rewrite. The routing module `_orchestrator_state_routing.py` is **not** in the `MODULE_NAMES` tuple — it is not parity-checked by this test. | The parity test does not check the routing module or the config JSON directly. However, `_orchestrator_state_routing.py` (bundled) reads `extensions/drm-copilot/resources/config/orchestration-routing.json` via `ROUTING_MATRIX_PATH` (bundled module line 10: `Path(__file__).resolve().parents[2] / "config" / "orchestration-routing.json"`). The bundled config and canonical config must stay identical. No new parity test is needed, but both JSON files must be updated in lockstep. |

### Skill file that must be extended

| File | Change required |
|---|---|
| `.claude/skills/orchestrate/SKILL.md` | Add receipt-emission instructions: one section defining how the orchestrator writes `skill_receipts[]` entries after reading each required skill, and how it writes `mcp_call_receipts[]` entries after each MCP call. This is a documentation change to the skill file, not a Python source change. |

### Docs that enumerate the routing matrix (advisory update, not blocking)

The Codex-era skill files in the bundled extension payload reference the stale names (`orchestrator-workflow`, `repo-automation-adapter`, `commit-steward`, `feature-reviewer`):
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/orchestrator-workflow/SKILL.md` (references `commit-steward`, `feature-reviewer`)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/repo-automation-adapter/SKILL.md`

These are Copilot/Codex customization payloads pushed to destination workspaces via `push_down_codex_and_agents_customizations`. They govern the Codex runtime, not the Claude Code runtime. They are out of scope for issue #230 unless the scope is explicitly expanded to align the Codex customization payload with the Claude Code runtime. They do not affect the Python validator or the Claude Code orchestrate skill.

### Complete blast-radius file list (changes required for issue #230)

Files requiring code or content changes:

1. `config/orchestration-routing.json` — canonical routing matrix (content change)
2. `extensions/drm-copilot/resources/config/orchestration-routing.json` — bundled routing matrix copy (identical content change, must stay in lockstep)
3. `.claude/skills/orchestrate/SKILL.md` — add receipt-emission instructions for `skill_receipts[]` and `mcp_call_receipts[]`

Files requiring verification after changes but no expected source edits:

4. `scripts/dev_tools/_orchestrator_state_routing.py` — reads matrix dynamically; no changes needed
5. `extensions/drm-copilot/resources/scripts/dev_tools/_orchestrator_state_routing.py` — bundled mirror; no changes needed
6. `scripts/dev_tools/validate_orchestrator_state.py` — calls routing validator; no changes needed
7. `extensions/drm-copilot/resources/scripts/dev_tools/validate_orchestrator_state.py` — bundled mirror; no changes needed
8. `tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py` — fixtures built from `load_routing_matrix()`; auto-corrects after config change; verify passes

---

## 9. Rejected Alternatives

**Approach: eliminate `required_skills` / `required_mcp_tools` validation entirely.** This would remove the completion invariants from the routing contract, eliminating meaningful assurance that required skills were acknowledged and required MCP tools were called. Rejected.

**Approach: create stub `.claude/agents/feature-reviewer.md` and `.claude/agents/commit-steward.md`.** These names have no meaning in the Claude Code runtime. Stub files would misrepresent the runtime agent roster and cause confusion. Rejected.

**Approach: keep `orchestrator-workflow` and `repo-automation-adapter` as required skills and add stub `.claude/skills/orchestrator-workflow/SKILL.md` and `.claude/skills/repo-automation-adapter/SKILL.md` files.** These skills are specific to the Codex runtime. The `orchestrate` skill already fills the orchestrator-workflow role. Adding placeholder skill files would create documentation overhead and policy ambiguity. Rejected.

---

## 10. Automation Feasibility

All changes required for issue #230 are entirely repository-local:

- Two JSON config files (`config/orchestration-routing.json` and `extensions/drm-copilot/resources/config/orchestration-routing.json`) — file edits.
- One skill markdown file (`.claude/skills/orchestrate/SKILL.md`) — documentation addition.
- Python validator and test files — no source edits; verification only.

No third-party UIs, portal interactions, external service calls, or human-gated approvals are required. The fix is achievable autonomously with no human interaction.

The fix does not require changes to the TypeScript MCP server source, does not add or remove MCP tools, and does not modify the Python validator logic. The bundle-parity test covers the five validator Python modules but not the routing module or the config JSON; the bundled config must be updated in lockstep by the implementer as a standard two-file coordinated edit.

**Human-interaction requirement: None.**
