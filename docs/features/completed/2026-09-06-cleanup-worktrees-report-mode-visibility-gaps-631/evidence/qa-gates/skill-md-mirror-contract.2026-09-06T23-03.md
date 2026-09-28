# SKILL.md Byte-Identical Mirror Contract (P9-T3)

Timestamp: 2026-09-07T14-12
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`
EXIT_CODE: 0
Output Summary: 1 passed in 0.16s. The test enumerates every non-memory repo `.claude`
file and asserts each exists in the extension bundle with byte-identical content. It
passes after the P9-T1 Report Line Contract edit to
`.claude/skills/cleanup-merged-worktrees/SKILL.md` and the P9-T2 mirror into
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`,
confirming the two copies agree.

## Independent Mirror Check (P9-T2 acceptance)

Command: `git diff --no-index .claude/skills/cleanup-merged-worktrees/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
EXIT_CODE: 0
Output Summary: empty output, exit 0 — the two files are byte-identical.

## Record Types Documented (P9-T1 acceptance)

Each literal below was confirmed present in `.claude/skills/cleanup-merged-worktrees/SKILL.md`
via `grep -c`, one occurrence each in the new Report Line Contract bullets:

- `ORPHAN_DIR|` — 1
- `STALE_REF|` — 1
- `CHILD_OF|` — 1
- `WARN|registration-lost|` — 1

Non-duplication check: `grep -c 'flag them for plain filesystem removal'` returns 1, the
single occurrence in the Dirty Worktree Triage Procedure's step 7. The new `ORPHAN_DIR|`
bullet cross-references that step by name rather than restating its guidance.
