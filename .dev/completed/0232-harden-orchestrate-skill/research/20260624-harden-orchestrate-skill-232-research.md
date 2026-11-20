<!-- markdownlint-disable-file -->

# Task Research Notes: Issue #232 Harden Orchestrate Skill

## Research Executed

### File Analysis

- `.github/agents/task-researcher.agent.md`
  - Verified the canonical task-researcher contract for feature-associated research: write research under the orchestrator-supplied feature folder research root, document only verified findings, compare approaches, select one recommendation, and keep rejected alternatives brief.
- `.codex/agents/task-researcher.toml`
  - Verified the migrated Codex task-researcher surface still references `artifacts/research/`, but its developer instructions require reading and preserving the canonical source agent. Because the user supplied `docs/features/active/2026-06-24-harden-orchestrate-skill-232`, this artifact uses that feature folder's `research/` root.
- `AGENTS.md`
  - Verified the repository tone policy, architecture summary, and canonical orchestration checkpoint path `artifacts/orchestration/orchestrator-state.json`.
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/issue.md`
  - Identified the primary requirement: update `.agents/skills/orchestrate/SKILL.md` so orchestration requires read-only scope assessment, route selection, checkpoint state, ordered lifecycle MCP calls, implementation gates, violation handling, and review delegate naming aligned to `feature-reviewer`.
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md`
  - Confirmed the same behavior requirements as the issue, including the need to prevent direct implementation before scope assessment, route selection, checkpoint state, and lifecycle setup.
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`
  - Confirmed the acceptance criteria, including pre-lifecycle read-only scope assessment and route selection, pre-implementation checkpoint and lifecycle readiness, violation handling, and `feature-reviewer` receipt alignment.
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md`
  - Found that the plan is still template-heavy and does not yet provide implementation sequencing. The issue and current orchestration skills are the stronger sources for design.
- `.agents/skills/orchestrate/SKILL.md`
  - Verified current checkpoint validation, route metadata, delegation, evidence location, pre-review commit, remediation loop, issue-number consistency, CI, PR gate, and review prompt constraints. Gaps found: no explicit entry-point contract, no explicit read-only scope gate before lifecycle MCP calls, no pre-issue branch gate, no post-promotion branch rename gate, and many review references still name `feature-review` instead of route-required `feature-reviewer`.
- `.agents/skills/orchestrator-workflow/SKILL.md`
  - Verified this skill already contains detailed route selection, checkpoint schema, small/large route behavior, mandatory delegation maps, completion gates, and hard constraints. It currently says issue promotion must complete before branch creation, which conflicts with Issue #232's pre-issue branch creation requirement.
- `.agents/skills/feature-promotion-lifecycle/SKILL.md`
  - Verified this skill is the current source of lifecycle variables and branch naming. It currently orders promotion before branch creation and creates `${promotion-type}/${short-name}-${issue-num}` only after issue promotion. This conflicts with the requested pre-issue branch creation and post-promotion branch rename sequence.
- `.agents/skills/repo-automation-adapter/SKILL.md`
  - Verified this skill centralizes required MCP execution and currently encodes the lifecycle order as potential entry, issue promotion, numeric issue capture, branch creation or checkout, and active folder creation. This is a companion consistency risk if only `orchestrate` and `feature-promotion-lifecycle` are updated.
- `config/orchestration-routing.json`
  - Verified all route entries require `feature-reviewer`, not `feature-review`. Small, large, and remediation routes all include `feature-reviewer` in `required_agents`.
- `.codex/agents/feature-reviewer.toml`
  - Verified the native Codex `feature-reviewer` agent exists and uses the `feature-review` skill as its workflow source.
- `.codex/agents/feature-review.toml`
  - Verified a separate `feature-review` agent also exists, converted from the canonical GitHub agent. This explains the current naming drift: one name is a workflow/legacy agent surface, while the route matrix requires `feature-reviewer` receipts.
- `.agents/skills/review-feature/SKILL.md`
  - Verified the direct-use wrapper delegates to the `feature-review` worker, which conflicts with route-required `feature-reviewer` naming if reused by orchestration.
- `.codex/agents/orchestrator.toml`
  - Verified the orchestrator profile already says the main thread runs orchestration, reads route config early, persists route metadata, and blocks if MCP validation is unavailable. It still lists `feature-review` as the review delegate in its delegation model.
- `.codex/hooks/enforce-promotion-mcp-only.ps1`
  - Verified there is a read-only hook that blocks direct promotion script bypass attempts and requires the MCP promotion tools instead. It does not enforce route selection, checkpoint readiness, pre-issue branch creation, branch rename, or implementation-start gates.
- `.codex/config.toml`
  - Verified the required `drm-copilot` MCP server and enabled lifecycle tools: `new_potential_entry`, `new_potential_bug_entry`, `potential_to_issue`, `new_active_feature_folder`, and `validate_orchestration_artifacts`.
- `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
  - Verified audit and evidence timestamp conventions and the canonical evidence path scheme. No evidence artifacts were produced by this research.
- `.agents/skills/atomic-plan-contract/SKILL.md`
  - Verified Phase 0, preflight validation, final QA loop, and plan validator gates that implementation plans must preserve.
- `.agents/skills/feature-review-workflow/SKILL.md`
  - Verified feature review uses route-independent full branch diff scope, PR context artifacts, required audit artifacts, validator gates, and remediation triggers.
- `.github/instructions/general-code-change.instructions.md`
  - Verified repository expectations for pre-change planning, full toolchain loops for code changes, file size limits, and scoped design.
- `.github/instructions/general-unit-test.instructions.md`
  - Verified unit-test policy for any future executable validator or hook tests.
- `.github/instructions/tonality.instructions.md`
  - Verified the professional tone requirement for generated repository content.

### Code Search Results

- `feature-reviewer`
  - `config/orchestration-routing.json` requires `feature-reviewer` for small, large, and remediation routes.
  - `.agents/skills/orchestrator-workflow/SKILL.md` maps small Step 10, large Step 9, and remediation re-review to `feature-reviewer`.
  - `.agents/skills/orchestrate/SKILL.md` still uses `feature-review` throughout its delegation, result, re-audit, issue-number prompt, PR gate, and prohibited-prompt sections.
- `new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`
  - `.agents/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/repo-automation-adapter/SKILL.md`, `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, `.codex/config.toml`, and `.codex/hooks/enforce-promotion-mcp-only.ps1` contain the lifecycle MCP references.
- `branch`
  - `.agents/skills/feature-promotion-lifecycle/SKILL.md` currently creates the issue-numbered branch after promotion.
  - `.agents/skills/repo-automation-adapter/SKILL.md` currently creates or checks out the issue-numbered branch after numeric issue capture.
  - `.agents/skills/orchestrator-workflow/SKILL.md` currently states issue promotion must complete before branch or folder creation.
- `blocked_reason`, `local_execution_overrides`, `delegation_bypasses`, `lifecycle_operations`
  - `.agents/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrator-workflow/SKILL.md` require empty local override and delegation bypass lists at completion and require lifecycle operations to use MCP surface.
  - `.agents/skills/orchestrator-workflow/SKILL.md` defines a finite `blocked_reason` enum, but it does not currently include a dedicated pre-implementation gate violation value.

### External Research

- #githubRepo:"drmoisan/drm-copilot issue 232 harden orchestrate skill"
  - Attempted public issue lookup and search. No fetchable public issue content was returned through the available tools. The local feature folder contains the verified Issue #232 requirements and the GitHub issue URL.
- #fetch:https://github.com/drmoisan/drm-copilot/issues/232
  - Attempted fetch. No additional content was available through the current tool response. Research conclusions are therefore grounded in repository-local authoritative sources.

### Project Conventions

- Standards referenced: `AGENTS.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/tonality.instructions.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`.
- Instructions followed: canonical task-researcher source from `.github/agents/task-researcher.agent.md`; feature-associated artifact written under the supplied feature folder research root.

## Key Discoveries

### Project Structure

The Codex orchestration runtime is split across these surfaces:

- `.agents/skills/orchestrate/SKILL.md` is the direct-use skill invoked by users and should be the first place that prevents premature implementation.
- `.agents/skills/orchestrator-workflow/SKILL.md` contains the detailed path state machine, route selection, checkpoint schema, step maps, and completion gates.
- `.agents/skills/feature-promotion-lifecycle/SKILL.md` contains canonical lifecycle variables, MCP promotion requirements, branch naming, folder integrity, and downstream handoff outputs.
- `.agents/skills/repo-automation-adapter/SKILL.md` centralizes the MCP-only execution surface and currently repeats the old lifecycle ordering.
- `config/orchestration-routing.json` is the route matrix that completion validation uses for required agents, skills, and MCP tools.
- `.codex/agents/feature-reviewer.toml` is the route-required native review agent, while `.agents/skills/feature-review/SKILL.md` is the workflow skill the agent uses.

### Implementation Patterns

The existing orchestration model already uses a checkpoint-first pattern:

- Read `artifacts/orchestration/orchestrator-state.json`.
- Read `config/orchestration-routing.json`.
- Select a route and persist `route_id`, `required_agents`, `required_skills`, and `required_mcp_tools`.
- Record required handoffs as receipts.
- Validate completion with `validate_orchestration_artifacts` and `require_complete: true`.

The current lifecycle pattern is inconsistent with Issue #232:

- Current `feature-promotion-lifecycle` and `repo-automation-adapter` both create the branch after issue promotion.
- Issue #232 requires pre-issue branch creation before potential-entry creation, then branch rename after promotion to include the issue number.
- Current `orchestrator-workflow` hard constraints also state issue promotion must complete before branch creation, so updating only `orchestrate` would leave contradictory instructions.

The current review naming pattern is also inconsistent:

- The route matrix and `orchestrator-workflow` require `feature-reviewer`.
- `orchestrate`, `review-feature`, and `.codex/agents/orchestrator.toml` still contain `feature-review` delegate wording.
- Because completion validation requires `delegation_receipts[].agent_name` to match route-required agents, orchestration-facing references should use `feature-reviewer` for delegated agent receipts and reserve `feature-review` for the workflow skill.

### Complete Examples

```markdown
Current verified route matrix pattern:
- required_agents includes `feature-reviewer` for small, large, and remediation routes.
- required_mcp_tools includes `new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`, and `validate_orchestration_artifacts`.

Current verified lifecycle pattern that must be replaced for Issue #232:
1. Create the potential entry.
2. Promote with `potential_to_issue`.
3. Capture numeric issue number.
4. Create or check out `${promotion-type}/${short-name}-${issue-num}`.
5. Create the active feature folder.
```

### API and Schema Documentation

Relevant checkpoint fields already documented by `.agents/skills/orchestrator-workflow/SKILL.md`:

- Route and required-surface fields: `route_id`, `required_agents`, `required_skills`, `required_mcp_tools`.
- Lifecycle fields: `promotion-type`, `short-name`, `relativeFile`, `long-name`, `issue-num`, `feature-folder`, `work-mode`, `plan-path`.
- Gate status fields: `step5_status` through `step10_status`, `blocked_reason`, `completed_steps`, `next_step`.
- Receipt fields: `delegation_receipts`, `skill_receipts`, `mcp_call_receipts`.
- Bypass guard fields: `local_execution_overrides`, `delegation_bypasses`, `lifecycle_operations`.

Existing `blocked_reason` enum values do not include a dedicated pre-implementation violation. Existing values that partially fit are `lifecycle_preconditions_missing` and `validator_failed`, but neither clearly describes an implementation-start violation after a mutation has already occurred.

### Configuration Examples

```json
{
  "routes": {
    "small": {
      "required_agents": ["atomic-planner", "atomic-executor", "feature-reviewer", "commit-steward"],
      "required_mcp_tools": ["new_potential_entry", "potential_to_issue", "new_active_feature_folder", "collect_commit_context", "collect_pr_context", "validate_orchestration_artifacts"]
    },
    "large": {
      "required_agents": ["task-researcher", "prd-feature", "atomic-planner", "atomic-executor", "feature-reviewer", "commit-steward"]
    }
  }
}
```

### Technical Requirements

- The orchestrate skill should define an entry-point contract: the already-active main session is the orchestrator runtime; optional orchestrator profiles are configuration aids, not a separate runtime requirement.
- The first phase of orchestration must be read-only: policy reads, existing checkpoint read, route config read, scope assessment, likely file/language assessment, route selection, and route metadata checkpointing.
- Lifecycle MCP calls must not start until route selection and checkpoint route metadata are persisted.
- The lifecycle sequence should be updated to:
  1. Create a pre-issue branch with a non-issue-number branch name derived from `${promotion-type}` and `${short-name}`.
  2. Create the potential entry through `new_potential_entry` or `new_potential_bug_entry`.
  3. Promote through `potential_to_issue`.
  4. Capture numeric `${issue-num}` from the promotion receipt.
  5. Rename the branch to `${promotion-type}/${short-name}-${issue-num}`.
  6. Create the active feature folder through `new_active_feature_folder`.
  7. Verify mode-specific folder integrity before requirements authoring, planning, implementation, or review.
- Branch operations are not currently MCP tools in `.codex/config.toml`. To preserve the existing completion invariant that `lifecycle_operations[]` records MCP lifecycle operations with `surface: "mcp"`, branch creation and branch rename should be tracked in separate checkpoint fields or receipts, not as MCP lifecycle operations, unless the validator and MCP surface are extended.
- The pre-implementation gate must block edits, formatters, tests, staging, commits, and implementation delegation until checkpoint route metadata, lifecycle readiness, and required receipts match the selected route.
- Violation handling must require the orchestrator to stop, record blocked state, identify the violated gate, record the mutated files or attempted action when known, and avoid continuing as if the preconditions had passed.
- Review delegation wording in orchestration-facing instructions should use `feature-reviewer` as the delegated agent name. References to `feature-review` should remain only where they explicitly mean the workflow skill used by `feature-reviewer`.

**Mandatory unachievable objective callout**:
- No requested objective was proven unachievable. However, implementing pre-issue branch creation and post-promotion branch rename only in `.agents/skills/orchestrate/SKILL.md` is insufficient because `.agents/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/repo-automation-adapter/SKILL.md`, and `.agents/skills/orchestrator-workflow/SKILL.md` currently encode conflicting branch order.

## Recommended Approach

Use a layered contract update rather than putting all hardened behavior in `orchestrate` alone.

Recommended implementation targets:

- Update `.agents/skills/orchestrate/SKILL.md` as the entry-point guard:
  - Add an "Entry-Point Contract" section stating the active main session is the orchestrator runtime and optional orchestrator profiles do not replace the main-session contract.
  - Add a "Read-Only Intake and Route Selection Gate" before lifecycle MCP calls.
  - Add a "Pre-Implementation Gate" that blocks edits, formatters, tests, staging, commits, and implementation delegation until route metadata and lifecycle readiness are checkpointed.
  - Add a "Violation Handling" section that records blocked state when an implementation action occurs before the gate.
  - Replace orchestration-facing `feature-review` delegate wording with `feature-reviewer` while preserving `feature-review` as the review workflow skill where needed.

- Update `.agents/skills/feature-promotion-lifecycle/SKILL.md` as the lifecycle source of truth:
  - Replace the current promotion-before-branch sequence with pre-issue branch creation, potential entry creation, promotion, numeric issue capture, branch rename, and active folder creation.
  - Define `${pre-issue-branch}` and `${final-branch}` or equivalent checkpoint variables.
  - State that branch rename is blocked until `${issue-num}` is numeric and backed by the promotion receipt.
  - Preserve MCP-only rules for potential entry, promotion, and active folder creation.

- Update companion consistency surfaces if implementation validation confirms they are in scope:
  - `.agents/skills/repo-automation-adapter/SKILL.md` because it currently repeats the old lifecycle order.
  - `.agents/skills/orchestrator-workflow/SKILL.md` because it currently states issue promotion must complete before branch creation and because its `blocked_reason` enum lacks a dedicated pre-implementation gate violation value.
  - `.codex/agents/orchestrator.toml` if orchestration profile wording must align with `feature-reviewer`.
  - `.agents/skills/review-feature/SKILL.md` if direct-use wrapper naming must align with the route matrix.

Rejected alternatives:

- Update only `.agents/skills/orchestrate/SKILL.md`: rejected because lower-level lifecycle skills would still instruct the opposite branch order and route-required review receipts could still diverge.
- Move all lifecycle details into `.agents/skills/orchestrate/SKILL.md`: rejected because `feature-promotion-lifecycle` and `repo-automation-adapter` already exist to centralize lifecycle variables and MCP execution rules. Duplicating lifecycle rules would increase drift risk.

## Implementation Guidance

- **Objectives**: Make orchestration fail closed before implementation, enforce read-only route selection before lifecycle MCP calls, create a pre-issue branch before potential-entry creation, rename the branch after issue promotion, preserve checkpoint validation, and align review receipts to `feature-reviewer`.
- **Key Tasks**:
  - Add explicit entry-point and read-only intake gates to `.agents/skills/orchestrate/SKILL.md`.
  - Add explicit route metadata checkpoint requirements before any lifecycle MCP call.
  - Add explicit pre-implementation gate requirements before edits, formatters, tests, staging, commits, or implementation delegation.
  - Update lifecycle ordering in `.agents/skills/feature-promotion-lifecycle/SKILL.md`.
  - Reconcile duplicated lifecycle ordering in `.agents/skills/repo-automation-adapter/SKILL.md` and `.agents/skills/orchestrator-workflow/SKILL.md` if those files remain contradictory after the primary edits.
  - Replace orchestration-facing `feature-review` agent references with `feature-reviewer` and keep `feature-review` only as the workflow skill name.
  - Add or map violation handling to checkpoint state. If a new blocked reason is added, update the enum consistently wherever the checkpoint schema is documented.
- **Dependencies**:
  - Existing `drm-copilot` MCP tools: `new_potential_entry`, `new_potential_bug_entry`, `potential_to_issue`, `new_active_feature_folder`, and `validate_orchestration_artifacts`.
  - Existing route matrix: `config/orchestration-routing.json`.
  - Existing native review agent: `.codex/agents/feature-reviewer.toml`.
  - Existing hook: `.codex/hooks/enforce-promotion-mcp-only.ps1` for MCP-only promotion bypass prevention. Additional hook or validator work would be a separate executable change if text-only gates are not sufficient.
- **Success Criteria**:
  - `rg "delegate to \`feature-review\`|feature-review subagent|feature-review delegation|latest \`feature-review\`" .agents/skills/orchestrate/SKILL.md` returns no orchestration-facing delegate references that conflict with route-required `feature-reviewer`.
  - `rg "issue promotion must complete before branch|Create the potential entry\\.|Promote with \`potential_to_issue\`\\.|Create or check out .*issue-num" .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md` shows no stale lifecycle sequence that places issue promotion before the initial branch.
  - The updated text states that scope assessment and route selection are read-only and must complete before `new_potential_entry`, `new_potential_bug_entry`, `potential_to_issue`, or `new_active_feature_folder`.
  - The updated text states that no implementation edit, formatter, test, staging, commit, or implementation delegation may occur before checkpoint route metadata and lifecycle readiness are present.
  - The updated text identifies violation handling and whether future enforcement belongs in hooks, the checkpoint validator, or both.
  - No `.agents/skills/*.md` or active feature docs are modified by this research step; only this research artifact is created.
