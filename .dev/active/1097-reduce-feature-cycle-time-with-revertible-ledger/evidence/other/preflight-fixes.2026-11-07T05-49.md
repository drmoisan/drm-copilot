# Preflight Fixes, Stage D

Timestamp: 2026-11-07T05-49
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T00-22.md

Every fix is in plan text only. No task was added, removed, or reordered, and no asserted value changed.

1. `## Design`, Installed MCP outcome table, Claude row. Defect class: stale citation. The executor checked the `.claude/skills/orchestrate/SKILL.md` text: the MCP-or-CLI wording sits under `### Model-choice reconciliation on resume` and `## PR Authoring (pr-author Handoff)`, not under `## Model Selection`, and the quoted form occurs in only one of the two. Change: the citation names `### Model-choice reconciliation on resume`, and the quotation marks are removed.
2. `## Design`, detection paragraph. Defect class: unstated consequence of a rule the plan already states. The detection fallback did not state what `plan_path` names afterwards, while `**Light cycle.**` states it for the executor-stop fallback. It also said "rewrites" the mode line, while `**Orchestrator rule.**` writes `light` only after detection passes. Change: the fallback writes the mode line and continues at R1, after which `plan_path` names the remediation plan.
3. `## Design`, `**Pins.**`. Defect class: inaccurate prose. A planner also runs on a proportionate cycle, as `## Remediation Loop (R1–R5)` states. Change: "only after the mode line is `proportionate` or `design`".
4. [P1-T6], agent bullet. Defect class: incomplete anchor list within a file the task already names. The `preflight` bullet of `### Remediation Loop Checkpoint Shape` and the `execution_status` sentence of `### Preflight Sub-State Semantics` in `.claude/agents/orchestrator.md` restate the rule that a light cycle changes, and would be false for a light cycle if left as they are. A search of the test tree found no pin on either. Change: both join the list of text updated for a light cycle.
5. [P1-T6], orchestrate skills bullet. Defect class: anchor absent from one copy. `## Remediation Loop — CI-Failure Handling` exists only in the `.claude` copy; the `.agents` copy carries that behavior under `## CI Green Gate`. Change: the sentence names each heading with its copy.
