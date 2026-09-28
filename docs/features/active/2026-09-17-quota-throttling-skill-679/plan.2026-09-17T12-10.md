# Plan: quota-throttling skill (Issue #679)

- Work Mode: minor-audit
- Route: small (documentation-only; no production code or hook behavior changes)
- Canonical issue number: 679

## Scope

1. `.claude/skills/quota-throttling/SKILL.md` — new skill carrying the quota throttling and
   account-switching policy.
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/quota-throttling/SKILL.md`
   — byte-identical bundled copy distributed by the extension and the MCP push-down.
3. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — add the
   skill path so manifest-scoped push-downs publish it.

## Phase 1 — Author and bundle

- [x] [P1-T1] Write `.claude/skills/quota-throttling/SKILL.md` with `name` and `description`
      frontmatter and the policy body.
- [x] [P1-T2] Copy it byte-for-byte to the bundled resources path and confirm identical SHA-256.
- [x] [P1-T3] Add `.claude/skills/quota-throttling/SKILL.md` to `core.json` `paths`.

## Phase 2 — Verification

- [x] [P2-T1] Prettier check on `core.json`.
- [x] [P2-T2] Jest: `test/lib/push-down/claude-pack-manifest-completeness.test.ts` and the
      push-down suites pass.
- [x] [P2-T3] Negative control: remove the manifest entry in a scratch copy of the check and
      confirm the completeness test reports the skill as missing.
- [x] [P2-T4] File-size and tone review of the new skill.

## Phase 3 — Delivery

- [ ] [P3-T1] Commit, push, open PR via `Agent(pr-author)`, and confirm CI green.

## Verification Record

- P1-T2: SHA-256 of both copies `DECFBCF3142FA4E5A903BE40EDB07B910F9BC1CCC24EEB2E9A48B86F7E760706`.
- P2-T1: `npx prettier --check resources/claude-customizations/pack-manifests/core.json` — clean.
- P2-T2: `npx jest test/lib/push-down test/extension.push-down-claude-customizations.test.ts test/repo-automation-service.push-down-claude.test.ts` — 21 suites, 263 tests passed.
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` — 29 passed.
- P2-T3: with the `core.json` entry removed, `claude-pack-manifest-completeness.test.ts` failed (1 failed, 15 passed) and named `.claude/skills/quota-throttling/SKILL.md`; the entry was restored.
- P2-T4: 221 lines (Markdown documentation is exempt from the 500-line cap); wording adjusted from the source policy for the repository tone rules (no figurative or dramatic phrasing), with substance and figures unchanged.