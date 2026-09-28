# [P1-T8] Bash library format and lint gate

Timestamp: 2026-08-30T06-46

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && shfmt -d .claude/lib/bash/parallel-lane-assertion.sh && shellcheck .claude/lib/bash/parallel-lane-assertion.sh'`

EXIT_CODE: 0

Output Summary: empty output. The captured stream measured 0 bytes, so
`shfmt -d` printed no unified diff and `shellcheck` printed no diagnostic. Both
halves are read-only: `shfmt -d` prints a diff and returns non-zero when a file
needs reformatting, and the `&&` sequencing means the recorded exit code is 0
only when both halves passed.

Acceptance: met. `EXIT_CODE: 0` with empty stdout.

## Findings resolved before this run

An earlier probe of this same command returned exit 1 with three shellcheck
warnings on the then-current file:

- SC2178 at the `local input="${1-}" seen=""` declaration in
  `pla_count_distinct`.
- SC2128 at the two expansions of that `seen` inside the same function.

Cause: shellcheck resolves a variable name across the whole file, and
`pla_derive_components` declares `seen` as an associative array. The string
accumulator in `pla_count_distinct` was therefore read as that array. Fix: the
accumulator was renamed to `counted`, with an inline comment recording why the
name must stay distinct. No shellcheck suppression was added.
