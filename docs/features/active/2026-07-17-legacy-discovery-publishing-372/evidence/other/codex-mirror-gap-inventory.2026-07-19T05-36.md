# Codex/.agents-Side Mirror Gap Inventory

Timestamp: 2026-07-19T05-36

Source: `docs/features/active/2026-07-17-legacy-discovery-publishing-372/evidence/baseline/python-codex-resource-contracts-baseline.2026-07-19T05-18.md`
(P0-T13), `EXIT_CODE: 0`, 6/6 tests passed, including
`test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts`.

That test enumerates every repo-root `.codex/**` and `.agents/**` file and asserts each is
present byte-identically under
`extensions/drm-copilot/resources/codex-and-agents-customizations/**`. Since the test reported
zero assertion failures, there is no missing or byte-mismatched `.codex`/`.agents`-relative path
at this worktree's current HEAD. The Codex-converted equivalents of the same five upstream epic
children referenced in the Claude-side inventory were already fully mirrored into
`extensions/drm-copilot/resources/codex-and-agents-customizations/` by an earlier wave before this
feature's branch point.

## agent-toml

(`.codex/agents/*.toml`)

- (none — zero-count; no missing or byte-mismatched Codex agent-role path)

## agents-skills

(`.agents/skills/<name>/**`)

- (none — zero-count; no missing or byte-mismatched Codex-side skill path)

## codex-hooks-and-config

(`.codex/hooks/*`, `.codex/config.toml`)

- (none — zero-count; no missing or byte-mismatched hook or config path)

## other

- (none — zero-count; no other missing or byte-mismatched `.codex`/`.agents`-relative path)

**Total count: 0**
