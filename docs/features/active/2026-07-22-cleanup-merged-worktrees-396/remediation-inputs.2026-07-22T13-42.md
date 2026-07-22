# Remediation Inputs — 2026-07-22T13:42 (cycle 1)

Canonical issue number for this feature is 396.

## Source

CI required check failure on PR #400 (branch `drm-copilot-wt-2026-07-21T21-57`, head SHA `691883474ef76e89f94551f5bbdcbe3436514893`).

- Failing check: `quality-checks7 / Code Quality & Tests (3.12)`
- Failing job: https://github.com/drmoisan/drm-copilot/actions/runs/29924839016/job/88939221580
- Cascading cancellations (same matrix, cancelled as a side effect, not independent failures): `quality-checks7 / Code Quality & Tests (3.10)`, `(3.11)`, `(3.13)`

## Finding

**Severity: Blocking**

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails with:

```
AssertionError: Repo file missing from bundle: .claude/skills/cleanup-merged-worktrees/SKILL.md
```

This repo-wide contract test requires every non-memory `.claude/**` file to also exist under the bundled payload root `extensions/drm-copilot/resources/claude-customizations/.claude/**`. The new skill added by this feature (`.claude/skills/cleanup-merged-worktrees/SKILL.md`) was created under `.claude/` but was never pushed down into the bundled resources tree, so the repo-wide mirror contract is violated.

## Required Fix

Run the `mcp__drm-copilot__push_down_claude_customizations` tool (or an equivalent deterministic copy) to mirror `.claude/skills/cleanup-merged-worktrees/SKILL.md` (and any other newly-added `.claude/**` files from this branch, if any are also missing) into `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`, byte-identical, then commit and push. Re-run `test_bundled_claude_payload_contains_all_repo_runtime_contracts` and the full `quality-checks7` matrix to confirm.
