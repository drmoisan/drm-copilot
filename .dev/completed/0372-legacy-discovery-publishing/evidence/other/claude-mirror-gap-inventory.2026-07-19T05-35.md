# Claude-Side Mirror Gap Inventory

Timestamp: 2026-07-19T05-35

Source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-claude-resource-contracts-baseline.2026-07-19T05-16.md`
(P0-T12), `EXIT_CODE: 0`, 7/7 tests passed, including
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`.

That test enumerates every repo-root `.claude/**` file (excluding `.claude/settings.local.json`
and the scope-filtered `.claude/agent-memory/**` subtree) and asserts each is present
byte-identically under `extensions/drm-copilot/resources/claude-customizations/.claude/**`. Since
the test reported zero assertion failures, there is no missing or byte-mismatched `.claude/**`
path at this worktree's current HEAD. All five upstream epic children that could have landed
Claude-side assets (#365 legacy-discovery-agent-roles, #366 legacy-discovery-hooks, #367
legacy-discovery-skills, and conditionally #359 legacy-discovery-schemas and #362
legacy-discovery-init-templates) were already fully mirrored into
`extensions/drm-copilot/resources/claude-customizations/.claude/` by an earlier wave (PRs #374,
#383, #380, #376, #381 per the delegation prompt) before this feature's branch point.

## agents

(`.claude/agents/*.md`)

- (none — zero-count; no missing or byte-mismatched agent-persona path)

## skills

(`.claude/skills/<name>/**`)

- (none — zero-count; no missing or byte-mismatched skill path)

## hooks-and-settings

(`.claude/hooks/*`, `.claude/settings.json`)

- (none — zero-count; no missing or byte-mismatched hook or settings path)

## other

- (none — zero-count; no other missing or byte-mismatched `.claude`-relative path)

**Total count: 0**
