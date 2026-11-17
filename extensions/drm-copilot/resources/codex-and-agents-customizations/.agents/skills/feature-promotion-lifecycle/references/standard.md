# Gold Standard: feature-promotion-lifecycle

## Objective

Deterministic promotion workflow from potential feature/bug entry to issue, branch, active feature folder, and downstream spec/research handoffs. This standard states the behavior that every expression of the skill must show, independent of the tool that runs it; where a tool uses a different mechanism, only the mechanism differs.

## Observable Behaviors

- **OB-1** MCP Tool Availability Preflight: If the required MCP tools are unavailable, stop before potential-entry creation, issue promotion, or active-folder creation begins.
- **OB-2** Agent-Session Promotion Execution Rule: Potential-entry creation, issue promotion, and active feature folder creation run only through the repository automation promotion tools, which are the sole authoritative execution path for them in agent sessions.
- **OB-3** Canonical Variables: The lifecycle uses eleven canonical variables: `${promotion-type}` (`feature` or `bug`), `${short-name}` (a lowercase hyphen-separated slug), `${relativeFile}` (the workspace-relative path of the created potential entry), `${long-name}` (the `${relativeFile}` file name without `.md`), `${issue-num}` (the promoted issue number), `${feature-folder}` (the active feature folder path), `${plan-path}` (the single canonical plan path reused across planning and preflight revisions), `${work-mode}` (`minor-audit`, `full-feature` or `full-bug`, with legacy `full` accepted only as an alias for `full-feature`), `${short-path-flag}` (`--work-mode minor-audit`, mandatory for short-path promotion and folder creation), `${pre-issue-branch}` (`${promotion-type}/${short-name}`, created or verified before issue creation) and `${final-branch}` (`${promotion-type}/${short-name}-${issue-num}`, created by branch rename after promotion returns a numeric issue number).
- **OB-4** Required Outputs for Downstream Handoffs: Before delegating research, spec or planning work, the handoff provides `${feature-folder}/issue.md`, `${feature-folder}/spec.md` (or its expected target path), `${feature-folder}/user-story.md` (or an explicit `NONE`), the latest research artifact path or paths, and the constraints, APIs and invariants to preserve, with the spec and user-story expectations set by the selected work mode and exactly one persisted work-mode marker in `issue.md`.

## Acceptance Checks

- **AC-1** (OB-1) An expression of the skill states the behavior described under MCP Tool Availability Preflight, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-2** (OB-2) An expression of the skill states the behavior described under Agent-Session Promotion Execution Rule, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-3** (OB-3) An expression of the skill states the behavior described under Canonical Variables, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-4** (OB-4) An expression of the skill states the behavior described under Required Outputs for Downstream Handoffs, and a run of the skill shows that behavior in its outputs, files or tool calls.
- **AC-5** (OB-1, OB-2, OB-3, OB-4) The expression states no rule that contradicts these behaviors, and differences between tools are limited to mechanism.
