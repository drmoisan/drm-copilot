# P5-T11 — bundle-mirror gate (both parts)

Timestamp: 2026-08-30T12-10

## Part 1 (environment-conditional) — push-down contract suite

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider`
EXIT_CODE: 0
Output Summary: `11 passed in 0.25s`. All eleven cases passed. The environment-conditional branch
recorded at P0-T8 (open issue #510, a `.claude/state/` path reported as missing from the bundle)
did not fire on this run: `ls -a .claude/state` in this worktree reports
`No such file or directory`, so no gitignored state file existed for `list_scoped_files` to walk.
No assertion message was produced, so the blocking condition — an assertion naming a path under
`.claude/lib/bash/`, `.claude/skills/`, or `.claude/agents/` — did not arise.

Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -q -p no:cacheprovider`
EXIT_CODE: 0
Output Summary: `1 passed in 0.17s`. The node ID that guards the mirror is run explicitly because
`-q` prints progress characters rather than case names, so the file-level run above cannot on its
own evidence that this particular case passed.

## Part 2 (durable gate, no dependence on `.claude/state/`) — seven-file byte comparison

Command:
`wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && rc=0; for f in .claude/lib/bash/parallel-lane-assertion.sh .claude/lib/bash/report-lane-assertion.sh .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md .claude/skills/parallel-plan/SKILL.md .claude/agents/parallel-planner.md .claude/agents/parallel-orchestrator.md; do cmp -s "$f" "extensions/drm-copilot/resources/claude-customizations/$f" || { echo "DIFFERS: $f"; rc=1; }; done; exit $rc'`
EXIT_CODE: 0
Output Summary: empty stdout. No `DIFFERS:` line. All seven repository files are byte-identical to
their counterparts under `extensions/drm-copilot/resources/claude-customizations/`:

1. `.claude/lib/bash/parallel-lane-assertion.sh` (mirrored at P4-T2)
2. `.claude/lib/bash/report-lane-assertion.sh` (mirrored at P4-T2)
3. `.claude/skills/epic-orchestrate/SKILL.md` (mirrored at P5-T6)
4. `.claude/skills/parallel-orchestrate/SKILL.md` (mirrored at P5-T7)
5. `.claude/skills/parallel-plan/SKILL.md` (mirrored at P5-T8)
6. `.claude/agents/parallel-planner.md` (mirrored at P5-T9)
7. `.claude/agents/parallel-orchestrator.md` (mirrored at P5-T10)

This loop is a byte comparison over a fixed, enumerated file list, so its result is unaffected by
`.claude/state/` or by any other untracked file. It is the unconditional half of this gate and it
passed on its own terms; it is not a substitute for part 1 and part 1 is not a substitute for it.

## Per-file `cmp -s` results recorded at P5-T6 through P5-T10

Each of the five Phase 5 mirror tasks ran its own single-file `cmp -s` acceptance command and each
exited 0.
