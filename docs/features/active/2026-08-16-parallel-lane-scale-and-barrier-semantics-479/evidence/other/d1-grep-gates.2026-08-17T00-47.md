# D1 Grep Gates (Issue #479, [P1-T17], AC4)

Timestamp: 2026-08-17T00-47

## Gate command

Command: `git grep -n "only after every cohort" -- .claude docs/features/templates`

EXIT_CODE: 1

Output Summary: **zero matches** (git grep exits 1 when no match is found). The global-barrier
sentence survives on no runtime surface under `.claude/` or `docs/features/templates/`.

## Positive control

Command: `git grep -c "conflicting neighbour" -- .claude/skills/parallel-orchestrate/SKILL.md`

EXIT_CODE: 0

Output Summary: `.claude/skills/parallel-orchestrate/SKILL.md:1` — one match, so the search
reached the edited surface and the zero-match gate above is a real negative, not a search that
failed to look.

## Why a recursive `grep -r` is invalid as a gate in this checkout

`.gitignore:21` ignores `.claude/worktrees/`, but this working copy contains a LIVE
`git worktree` at `.claude/worktrees/agent-afc9f4fd25ec235a5/` (confirmed by
`git worktree list --porcelain`; it holds branch
`feature/enforcement-hooks-must-not-invoke-python-475`). That directory carries a full second
copy of the repository, including a second `.claude/`, a second
`extensions/drm-copilot/resources/claude-customizations/.claude/`, historical feature folders,
and compiled `__pycache__` artifacts.

A recursive `grep -rc "only after every cohort" .claude/` run at this timestamp reports **18
files with matches**, of which **17 are inside `.claude/worktrees/agent-afc9f4fd25ec235a5/`**
and are phantom matches against a different branch's checkout. The one non-worktree match is
`.claude/agent-memory/atomic-executor/feedback-orchestration-toolchain-gotchas.md`, an agent
memory file that is out of the gate's scope (it is not a runtime contract surface, and the
memory index is excluded from the mirror parity scope by
`test_push_down_claude_resource_contracts.py`).

`git grep` with explicit pathspecs searches tracked files only, which is why it is the
acceptance instrument for AC4 and every other search gate in this plan.

## AC4 disposition

AC4 is satisfied: the gate records zero matches, the positive control records `>= 1`, and the
worktree caveat is recorded above.
