# mcp-promotion-tooling-defects (Issue #401)

- Date captured: 2026-07-22
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/mcp-promotion-tooling-defects/ (Issue #401)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #401
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/401
- Last Updated: 2026-07-22T20-17
- Work Mode: full-bug

## Summary

Two defects in the drm-copilot MCP tooling (extension under `extensions/drm-copilot/`) were discovered while filing issue #399. Defect A: the shared `workspace_root` default resolution returns the long-running MCP server process's own `process.cwd()` (the main repo checkout) instead of the calling agent's isolated git worktree, silently writing promotion artifacts to the wrong repo checkout. Defect B: `potential_to_issue` renders every section of the created GitHub bug issue body as the placeholder `(not provided in potential file)` because the issue-body section-heading mapping does not match the actual bug-potential template headings.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (defects are in the TypeScript MCP server under `extensions/drm-copilot/src/`)
- Command/flags used: `mcp__drm-copilot__new_potential_bug_entry`, `mcp__drm-copilot__potential_to_issue`, `mcp__drm-copilot__new_active_feature_folder` invoked from an Agent tool run with `isolation: "worktree"`
- Data source or fixture: `docs/features/potential/promoted/2026-07-22-npm-audit-vulnerabilities-ci-gate.md` and the bug-potential template; GitHub issue https://github.com/drmoisan/drm-copilot/issues/399

## Steps to Reproduce

Defect A:
1. Run an agent inside an isolated git worktree (`Agent` tool `isolation: "worktree"`, working dir under `.claude/worktrees/<id>/`).
2. Call a `workspace_root`-accepting drm-copilot MCP tool (for example `new_potential_bug_entry`) without passing `workspace_root`.
3. Observe that the artifact is written to the main repo checkout (`process.cwd()` of the shared MCP server process), not the calling worktree; `git status` in the worktree shows nothing new.

Defect B:
1. Create a bug potential entry from the bug template and populate its real headings (`Summary`, `Steps to Reproduce`, `Expected Behavior`, `Actual Behavior`, etc.).
2. Promote it with `potential_to_issue`.
3. Open the created GitHub issue and observe every section body renders as `(not provided in potential file)` even though the source potential doc has complete content.

## Expected Behavior

- Defect A: the tool resolves the calling agent's actual worktree directory when `workspace_root` is omitted, or fails closed / loudly warns when the resolved default cannot be trusted, so silent misdirection to the wrong checkout is impossible.
- Defect B: the created GitHub issue body contains the real content from the potential doc, mapped from the potential doc's actual section headings for the given promotion type.

## Actual Behavior

- Defect A: `extensions/drm-copilot/src/mcp-tools.ts` resolves the omitted `workspace_root` to `process.cwd()` of the long-running MCP server process, which is the main checkout rather than the caller's worktree. Artifacts land in the wrong checkout with no error.
- Defect B: `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` `buildIssueBody` selects a body builder whose section headings do not match the actual template headings for the affected path, so `getSection` returns empty for each heading and the placeholder `(not provided in potential file)` (defined in `content.ts`) is emitted for every section.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `extensions/drm-copilot/src/mcp-tools.ts` line 79 `return process.cwd();` and line 85 `normalizeWorkspaceRoot(workspaceRoot, process.cwd())`; `promotion.ts` `buildIssueBody` minor-audit branch precedes the `promotionType === "bug"` branch. GitHub issue #399 body shows `(not provided in potential file)` in every section.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Rationale: Defect A silently corrupts the target checkout for promotion artifacts under worktree isolation (data-misdirection risk with no error). Defect B produces empty GitHub issues for bug promotions, discarding all authored content.

## Suspected Cause / Notes

- Defect A: `resolveWorkspaceRootForTool` (or equivalent) in `extensions/drm-copilot/src/mcp-tools.ts` defaults to the MCP server process `process.cwd()`, which does not reflect the calling agent's worktree because the MCP server is a long-running process shared across the session. Determine whether a reliable worktree signal exists (environment variable set by the harness, per-call originating context) or whether the fix is to make `workspace_root` effectively required / fail-closed when the resolved default does not match an expected signal.
- Defect B: `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts` `buildIssueBody` orders the minor-audit branch (`buildMinorAuditBody`, headings `Problem / Why`, `Implementation Intent`, `Acceptance Criteria`, `Dependencies / Risks`, `Verification Steps`, `Evidence Checklist`) before the `promotionType === "bug"` branch (`buildBugBody`, headings from `BUG_SECTION_HEADINGS`). Confirm which work_mode + promotion_type combinations mis-route, and check whether `feature` / `epic` / `refactor` promotion types share the same class of heading-mapping defect against their own templates.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: `mcp-tools.ts` workspace_root resolution; `promotion.ts` `buildIssueBody` per (promotion_type x work_mode) matrix; `content.ts` body builders and heading maps.
- [x] Integration scenario to retest: promote a bug potential and assert the created issue body contains real section content, not placeholders; assert an omitted `workspace_root` under worktree isolation does not silently target the wrong checkout.
- [x] Manual verification notes: compare the created GitHub issue body against the populated potential doc for each promotion type.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch

## Fix Outcome (2026-07-22T20-17)

Both defects are resolved on branch `bug/mcp-promotion-tooling-defects-401`; all 14 acceptance criteria (AC-1..AC-14 in `spec.md`) are delivered and verified.

- Defect A (fail-closed `workspace_root`): `normalizeWorkspaceRoot` (`extensions/drm-copilot/src/workflow-command-arguments.ts`) now throws an actionable error when `workspace_root` is omitted with no explicit fallback, instead of silently returning `process.cwd()`. All 28 MCP tools list `workspace_root` in `inputSchema.required` (`mcp-repo-automation-tool-definitions.ts`, `mcp-discovery-tool-definitions.ts`, and the test-only base mirror `mcp-tool-definitions.ts`), and `workspaceRootProperty.description` no longer advertises a `process.cwd()` default. A workspace-relative `potential_path` is now resolved against the resolved `workspace_root` in `resolvePotentialToIssueToolInput` (extracted to `mcp-tool-inputs-potential-to-issue.ts` to keep `mcp-tool-inputs.ts` within the 500-line limit). The omitted-`workspace_root` error surfaces through the existing `toFailureToolResult` failure envelope.
- Defect B (heading mapping): `buildIssueBody` in `promotion.ts` and its Python parity twin `scripts/dev_tools/potential_to_issue.py` were reordered so a `bug` promotion routes to the bug-section body before the minor-audit branch. A (bug, minor-audit) promotion now renders the real bug headings with authored content while still recording `- Work Mode: minor-audit`. The stale parity-header path and routing-table docblock in `promotion.ts` were corrected.

Breaking change: `workspace_root` is now a required input for all 28 drm-copilot MCP tools. Agent callers that previously relied on the silent `process.cwd()` default receive a structured `ok: false` error until they pass the absolute worktree/checkout root explicitly. In-repo instructional docs (skills, READMEs, bundled resource mirrors) were swept to reflect the required contract.

Files changed: `promotion.ts`, `workflow-command-arguments.ts`, `mcp-tool-inputs.ts` (+ new sibling `mcp-tool-inputs-potential-to-issue.ts`), `mcp-repo-automation-tool-definitions.ts`, `mcp-discovery-tool-definitions.ts`, `mcp-tool-definitions.ts`, `mcp-push-down-schema-properties.ts`, `scripts/dev_tools/potential_to_issue.py`, associated Jest/pytest suites, and documentation. Protected files (`content.ts`, `promotion-filesystem.ts`, `prompt-mode-contract.ts`, `potential_to_issue_content.py`, and the Python CLI workspace default) are unchanged.

Toolchain: TypeScript format/lint/typecheck clean; Jest 2031 passed; coverage lines 96.33%, branches 89.21%. Python black/ruff/pyright clean; pytest 1982 passed; TOTAL coverage 88%, `potential_to_issue.py` 85% with no regression versus baseline.
