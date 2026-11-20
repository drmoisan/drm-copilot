Timestamp: 2026-06-24T16-09
Command: rg -n "potential entry|potential_to_issue|issue promotion|branch|new_active_feature_folder|issue-num" .agents/skills/orchestrate/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md
EXIT_CODE: 0
Output Summary:
- `.agents/skills/feature-promotion-lifecycle/SKILL.md` currently requires `${issue-num}` before branch creation.
- `.agents/skills/repo-automation-adapter/SKILL.md` currently orders potential entry creation, `potential_to_issue`, numeric issue capture, issue-numbered branch checkout, and active folder creation.
- `.agents/skills/orchestrator-workflow/SKILL.md` currently states issue promotion must complete before branch or folder creation in small and large path lifecycle preconditions.

Output:
```text
.agents/skills/orchestrator-workflow/SKILL.md:19:- `pr-base-branch-merge-base`
.agents/skills/orchestrator-workflow/SKILL.md:69:- `issue-num`
.agents/skills/orchestrator-workflow/SKILL.md:78:- `pr-context-base-branch`
.agents/skills/orchestrator-workflow/SKILL.md:233:2. Use `feature-promotion-lifecycle` as the source of truth for lifecycle variables, branch naming, and `${plan-path}` resolution.
.agents/skills/orchestrator-workflow/SKILL.md:237:   - issue promotion must complete before branch or folder creation
.agents/skills/orchestrator-workflow/SKILL.md:238:   - `${issue-num}` must be numeric before `new_active_feature_folder` runs
.agents/skills/orchestrator-workflow/SKILL.md:252:   - Record a delegation receipt and set `step6_status` to `verified` before branching
.agents/skills/orchestrator-workflow/SKILL.md:280:2. Use `feature-promotion-lifecycle` as the source of truth for lifecycle variables, branch naming, and `${plan-path}` resolution.
.agents/skills/orchestrator-workflow/SKILL.md:284:   - issue promotion must complete before branch or folder creation
.agents/skills/orchestrator-workflow/SKILL.md:285:   - `${issue-num}` must be numeric before `new_active_feature_folder` runs
.agents/skills/orchestrator-workflow/SKILL.md:289:   - fill the potential entry details
.agents/skills/orchestrator-workflow/SKILL.md:310:    - Resolve the base branch through `pr-base-branch-merge-base` unless an explicit base was already supplied.
.agents/skills/orchestrator-workflow/SKILL.md:311:    - Load canonical PR-context artifacts and refresh them through `repo-automation-adapter` when they are missing or stale relative to the current branch state.
.agents/skills/orchestrator-workflow/SKILL.md:314:    - Do not accept PASS review outcomes when required coverage fields are left unverified, when PR-context artifacts are missing or stale relative to the current branch state, or when required remediation artifacts are missing.
.agents/skills/orchestrator-workflow/SKILL.md:333:10. Use `repo-automation-adapter` to refresh PR-context artifacts through MCP tool `collect_pr_context` with the resolved base branch.
.agents/skills/orchestrator-workflow/SKILL.md:348:- `${relativeFile}` is a real promoted-input path and `${issue-num}` is numeric when lifecycle setup was required
.agents/skills/orchestrator-workflow/SKILL.md:369:- Do not create or edit active feature docs before potential-entry creation, issue promotion, and active-folder creation succeed.
.agents/skills/orchestrator-workflow/SKILL.md:370:- Do not call `new_active_feature_folder` before `${issue-num}` is numeric and backed by promotion output.
.agents/skills/orchestrator-workflow/SKILL.md:371:- Do not persist placeholder lifecycle values such as `NONE` or `TBD` for `${relativeFile}`, `${issue-num}`, `${feature-folder}`, or `${plan-path}` once lifecycle setup begins.
.agents/skills/repo-automation-adapter/SKILL.md:23:- a workflow needs PR-context collection, issue promotion, feature-folder creation, commit-context collection, customization publishing, hard-lock prompt resolution, or orchestration-artifact validation,
.agents/skills/repo-automation-adapter/SKILL.md:44:- `potential_to_issue`
.agents/skills/repo-automation-adapter/SKILL.md:45:- `new_active_feature_folder`
.agents/skills/repo-automation-adapter/SKILL.md:92:- When the caller already resolved a base branch, pass that base explicitly.
.agents/skills/repo-automation-adapter/SKILL.md:109:- `potential_to_issue`
.agents/skills/repo-automation-adapter/SKILL.md:110:- `new_active_feature_folder`
.agents/skills/repo-automation-adapter/SKILL.md:114:1. Create the potential entry.
.agents/skills/repo-automation-adapter/SKILL.md:115:2. Promote with `potential_to_issue`.
.agents/skills/repo-automation-adapter/SKILL.md:117:4. Create or check out `${promotion-type}/${short-name}-${issue-num}`.
.agents/skills/repo-automation-adapter/SKILL.md:118:5. Create the active feature folder with `new_active_feature_folder`.
.agents/skills/repo-automation-adapter/SKILL.md:120:`new_active_feature_folder` is not an allowed bootstrap substitute for missing promotion state. If `${issue-num}` is missing, non-numeric, or placeholder text, stop. Do not synthesize GitHub issue state, active-folder scaffolding, or placeholder lifecycle variables.
.agents/skills/feature-promotion-lifecycle/SKILL.md:3:description: Deterministic promotion workflow from potential feature/bug entry to issue, branch, active feature folder, and downstream spec/research handoffs. Agent sessions must use the drm-copilot MCP tool surface and record raw promotion receipts under the canonical checkpoint namespace.
.agents/skills/feature-promotion-lifecycle/SKILL.md:15:- An orchestrator must create potential docs, promote to issue, branch, and active feature folder.
.agents/skills/feature-promotion-lifecycle/SKILL.md:23:- feature potential entry: `mcp__drm-copilot__new_potential_entry` with `short_name=${short-name}`
.agents/skills/feature-promotion-lifecycle/SKILL.md:24:- bug potential entry: `mcp__drm-copilot__new_potential_bug_entry` with `short_name=${short-name}`
.agents/skills/feature-promotion-lifecycle/SKILL.md:25:- potential-to-issue promotion: `mcp__drm-copilot__potential_to_issue` with `potential_path=${relativeFile}`, `promotion_type=${promotion-type}`, `work_mode=${work-mode}`
.agents/skills/feature-promotion-lifecycle/SKILL.md:26:- active feature folder creation: `mcp__drm-copilot__new_active_feature_folder` with `feature_name=${long-name}`, `type=${promotion-type}`, `issue_number=${issue-num}`, `work_mode=${work-mode}`
.agents/skills/feature-promotion-lifecycle/SKILL.md:28:If the required MCP tools are unavailable, stop before potential-entry creation, issue promotion, or active-folder creation begins. Restore MCP connectivity first. Agent sessions do not have an approved non-MCP execution branch for promotion work.
.agents/skills/feature-promotion-lifecycle/SKILL.md:47:- `${relativeFile}`: workspace-relative path to created potential entry markdown
.agents/skills/feature-promotion-lifecycle/SKILL.md:49:- `${issue-num}`: promoted GitHub issue number
.agents/skills/feature-promotion-lifecycle/SKILL.md:57:`${issue-num}` MUST be numeric after promotion and before branch or folder creation. If promotion does not return a numeric issue number, stop. Do not infer or synthesize the missing value.
.agents/skills/feature-promotion-lifecycle/SKILL.md:63:- `${issue-num}` MUST be numeric after promotion and before branch or folder creation.
.agents/skills/feature-promotion-lifecycle/SKILL.md:65:- If `${relativeFile}` or `${issue-num}` is missing, placeholder text, or unverified, stop before branch creation, active-folder creation, or active-folder authoring.
.agents/skills/feature-promotion-lifecycle/SKILL.md:69:2) Promote the potential document through `mcp__drm-copilot__potential_to_issue` with `work_mode=minor-audit`.
.agents/skills/feature-promotion-lifecycle/SKILL.md:71:3) Create branch:
.agents/skills/feature-promotion-lifecycle/SKILL.md:72:- `${promotion-type}/${short-name}-${issue-num}`
.agents/skills/feature-promotion-lifecycle/SKILL.md:74:4) Create the active feature folder through `mcp__drm-copilot__new_active_feature_folder` with `work_mode=minor-audit`.
.agents/skills/orchestrate/SKILL.md:46:checkpoint is present. Branch protection should require this check for branches
.agents/skills/orchestrate/SKILL.md:157:The review subagent compares against a base branch; uncommitted changes are invisible to the diff tool and cannot be audited.
.agents/skills/orchestrate/SKILL.md:176:- **R4 — Re-audit:** Refresh PR context via MCP tool `collect_pr_context`, then delegate to `feature-review` with the same inputs as the original review (resolved base branch, feature folder, refreshed PR context artifacts, acceptance-criteria source). No scope narrowing. The canonical issue number line must be included.
.agents/skills/orchestrate/SKILL.md:200:The orchestrator must not create a PR, push a branch for PR purposes, or report work complete until all four conditions are simultaneously true:
.agents/skills/orchestrate/SKILL.md:205:3. The mandatory toolchain passed in its most recent run on the branch (no linting/type-check/test failures).
.agents/skills/orchestrate/SKILL.md:216:- instruct the agent to skip, waive, or mark as "out of scope," "informational only," or "not applicable" any toolchain step or coverage check for a language that has changed files in the branch diff;
.agents/skills/orchestrate/SKILL.md:217:- assert that a language category is "not applicable" when that language has changed files in the branch diff;
.agents/skills/orchestrate/SKILL.md:218:- imply that coverage is not required because the plan scope contains only documentation changes when the branch diff contains non-documentation changes contributed by prior commits on the same branch.
.agents/skills/orchestrate/SKILL.md:222:- the resolved base branch and merge-base SHA;
```
