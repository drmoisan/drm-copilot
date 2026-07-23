# Issue Update Mirror — Issue #401 (mcp-promotion-tooling-defects)

Timestamp: 2026-07-22T20-17

PostedAs: unknown

Note: This mirror records the fix-outcome update written to the local feature `issue.md` (`## Fix Outcome (2026-07-22T20-17)` section). The orchestrator handles any GitHub posting/commit; this executor does not run `gh`. If the update is posted to GitHub issue #401, record the comment/issue URL here.

## Exact update text (as written to issue.md `## Fix Outcome`)

Both defects are resolved on branch `bug/mcp-promotion-tooling-defects-401`; all 14 acceptance criteria (AC-1..AC-14 in `spec.md`) are delivered and verified.

- Defect A (fail-closed `workspace_root`): `normalizeWorkspaceRoot` (`extensions/drm-copilot/src/workflow-command-arguments.ts`) now throws an actionable error when `workspace_root` is omitted with no explicit fallback, instead of silently returning `process.cwd()`. All 28 MCP tools list `workspace_root` in `inputSchema.required` (`mcp-repo-automation-tool-definitions.ts`, `mcp-discovery-tool-definitions.ts`, and the test-only base mirror `mcp-tool-definitions.ts`), and `workspaceRootProperty.description` no longer advertises a `process.cwd()` default. A workspace-relative `potential_path` is now resolved against the resolved `workspace_root` in `resolvePotentialToIssueToolInput` (extracted to `mcp-tool-inputs-potential-to-issue.ts` to keep `mcp-tool-inputs.ts` within the 500-line limit). The omitted-`workspace_root` error surfaces through the existing `toFailureToolResult` failure envelope.
- Defect B (heading mapping): `buildIssueBody` in `promotion.ts` and its Python parity twin `scripts/dev_tools/potential_to_issue.py` were reordered so a `bug` promotion routes to the bug-section body before the minor-audit branch. A (bug, minor-audit) promotion now renders the real bug headings with authored content while still recording `- Work Mode: minor-audit`. The stale parity-header path and routing-table docblock in `promotion.ts` were corrected.

Breaking change: `workspace_root` is now a required input for all 28 drm-copilot MCP tools. Agent callers that previously relied on the silent `process.cwd()` default receive a structured `ok: false` error until they pass the absolute worktree/checkout root explicitly. In-repo instructional docs (skills, READMEs, bundled resource mirrors) were swept to reflect the required contract.

Toolchain: TypeScript format/lint/typecheck clean; Jest 2031 passed; coverage lines 96.33%, branches 89.21%. Python black/ruff/pyright clean; pytest 1982 passed; TOTAL coverage 88%, `potential_to_issue.py` 85% with no regression versus baseline.
