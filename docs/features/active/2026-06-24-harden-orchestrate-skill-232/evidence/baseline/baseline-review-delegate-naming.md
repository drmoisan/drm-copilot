Timestamp: 2026-06-24T16-08
Command: rg -n "feature-review" .agents/skills/orchestrate/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md config/orchestration-routing.json
EXIT_CODE: 0
Output Summary:
- The route matrix requires `feature-reviewer` in three route entries.
- `.agents/skills/orchestrator-workflow/SKILL.md` already uses `feature-reviewer` for required review delegation steps and also lists `feature-review` as a workflow skill.
- `.agents/skills/orchestrate/SKILL.md` contains orchestration-facing `feature-review` delegate references that require alignment for Issue #232.

Output:
```text
config/orchestration-routing.json:10:        "feature-reviewer",
config/orchestration-routing.json:39:        "feature-reviewer",
config/orchestration-routing.json:66:        "feature-reviewer",
.agents/skills/orchestrator-workflow/SKILL.md:24:- `feature-review`
.agents/skills/orchestrator-workflow/SKILL.md:33:  - `feature-review`
.agents/skills/orchestrator-workflow/SKILL.md:34:  - `feature-reviewer`
.agents/skills/orchestrator-workflow/SKILL.md:172:  - Step 10 -> `feature-reviewer`
.agents/skills/orchestrator-workflow/SKILL.md:176:  - Step 9 -> `feature-reviewer`
.agents/skills/orchestrator-workflow/SKILL.md:182:  - remediation re-review -> `feature-reviewer`
.agents/skills/orchestrator-workflow/SKILL.md:263:   - MUST delegate to `feature-reviewer`
.agents/skills/orchestrator-workflow/SKILL.md:308:10. Spawn `feature-reviewer` for post-implementation review.
.agents/skills/orchestrator-workflow/SKILL.md:334:11. Delegate `feature-reviewer` again with the refreshed PR context.
.agents/skills/orchestrate/SKILL.md:91:- `feature-review` — produces policy, code, and feature audit artifacts
.agents/skills/orchestrate/SKILL.md:149:Before delegating to the `feature-review` subagent, the orchestrator must:
.agents/skills/orchestrate/SKILL.md:155:5. Only after a successful commit may the orchestrator proceed to the `feature-review` delegation.
.agents/skills/orchestrate/SKILL.md:161:After each `feature-review` delegation returns:
.agents/skills/orchestrate/SKILL.md:176:- **R4 — Re-audit:** Refresh PR context via MCP tool `collect_pr_context`, then delegate to `feature-review` with the same inputs as the original review (resolved base branch, feature folder, refreshed PR context artifacts, acceptance-criteria source). No scope narrowing. The canonical issue number line must be included.
.agents/skills/orchestrate/SKILL.md:185:Every delegation prompt to `atomic-planner`, `atomic-executor`, and `feature-review` must include the line:
.agents/skills/orchestrate/SKILL.md:202:1. `blocking_findings_resolved: true` — the most recent `feature-review` produced zero blocking findings.
.agents/skills/orchestrate/SKILL.md:213:When delegating to the `feature-review` subagent, the orchestrator prompt MUST NOT:
.agents/skills/orchestrate/SKILL.md:220:The orchestrator supplies only the following to the `feature-review` subagent:
.agents/skills/orchestrate/SKILL.md:226:- a neutral instruction to execute the full `feature-review-workflow` SKILL contract end-to-end.
```
