# Remediation Inputs — 2026-08-28T23-45

## Source

CI failure on PR #585 (branch `feature/cleanup-worktrees-dirty-triage-procedure-584`), head SHA
`4f0b7b4dc7a2e48711dde8325395fbde7bf49231`, required check `quality-checks7 / Code Quality & Tests
(3.11)`, GitHub Actions run
https://github.com/drmoisan/drm-copilot/actions/runs/33220636915/job/99013749006.

The sibling matrix jobs `Code Quality & Tests (3.10)`, `(3.12)`, and `(3.13)` were `CANCELLED`
(fail-fast cascade triggered by the 3.11 failure), not independently failing checks.

## Severity

**Blocking.**

## Finding

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
failed:

```
AssertionError: Bundle content differs from repo for: .claude/skills/cleanup-merged-worktrees/SKILL.md
assert '---\nname: c...convention.\n' == '---\nname: c...duct scope.\n'
```

The cherry-picked commit (`c7e0a28f`, cherry-picked from `00663e1151d0777e8e74d468b89bacd61c5c45b8`)
correctly updated the repo-side skill file at
`.claude/skills/cleanup-merged-worktrees/SKILL.md` but did not update its bundled mirror copy at
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
This repository maintains byte-for-byte parity between the two copies (enforced by the failing
test), and an `mcp__drm-copilot__push_down_claude_customizations` MCP tool exists specifically to
perform this sync. The cherry-picked commit was authored in a separate, adjacent worktree and never
ran that push-down step before being cherry-picked here.

Independently confirmed via `diff -u` between the two files: the bundled copy is missing the entire
"Dirty Worktree Triage Procedure" section, the six new frontmatter `allowed-tools` entries, the new
"When to Use This Skill" bullet, the forward-pointer in the existing "End-to-End Workflow" step 6,
the two new "Prohibited Shortcuts" bullets, and the new "Cross-References" entry -- i.e., the bundle
is simply the pre-cherry-pick version of the file.

## Required Fix

Run the `mcp__drm-copilot__push_down_claude_customizations` MCP tool (or the equivalent bundled
resource copy) to bring
`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`
into byte-for-byte parity with `.claude/skills/cleanup-merged-worktrees/SKILL.md`, then re-run the
failing test locally to confirm, then commit the synced bundle file.

## Scope Note

This is a single additional file (the bundled mirror copy of the one already-changed skill file);
no other production file is affected. The repo-side `.claude/skills/cleanup-merged-worktrees/SKILL.md`
content itself is correct and unchanged by this remediation -- verified against all 10 issue.md
acceptance criteria in the prior feature-review pass.
