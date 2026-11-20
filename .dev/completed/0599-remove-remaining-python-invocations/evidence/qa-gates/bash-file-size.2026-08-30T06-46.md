# [P1-T7] Bash library file-size gate

Timestamp: 2026-08-30T06-46

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && wc -l .claude/lib/bash/parallel-lane-assertion.sh'`

EXIT_CODE: 0

Output Summary: `495 .claude/lib/bash/parallel-lane-assertion.sh`. The recorded
line count is 495, which is at or below the 500-line cap in
`.claude/rules/general-code-change.md` and `.claude/rules/shell.md`. Headroom is
5 lines. No split was performed, because the task's split fallback is
conditional on the count exceeding 500 and it does not.

## How the count settled at 495

The first measurement of this file was 499. Resolving the shellcheck findings
SC2178 and SC2128 (a local string named `seen` colliding with the associative
array `seen` in `pla_derive_components`, which shellcheck resolves file-wide)
required a rename and an explanatory comment, taking the file to 502 and over
the cap.

The cap was restored by condensing this module's own comment prose, not by
splitting the module and not by removing documented behavior. Splitting was
rejected as out of scope: it would add an eleventh `.claude/lib/bash/*.sh` file,
which contradicts `MINIMUM_LIB_FILE_COUNT=11` in Fixed Design Decision 6, the
`core.json` registration set in Phase 4, and the "seven sourceable libraries"
and "four entry-point-specific allowlist entries" counts that P5-T4 writes.

The count is stable against the later formatter runs at P4-T1 and P6-T1:
`shfmt -d` on this file reports no diff, so `shfmt -w` rewrites nothing and
cannot move the count.
