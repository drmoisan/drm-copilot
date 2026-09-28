# P4-T5 — the clearing sequence never forces and never touches ignored files

Timestamp: 2026-09-08T02-15
Command: `grep -nE "^[[:space:]]*cleanup_wt_git" scripts/bash/cleanup_worktrees_dirt_lib.sh`
EXIT_CODE: 0

Route: the plan's `wsl -d Ubuntu -- bash -lc` wrapper is superseded by EA-1. The command was
executed against the absolute path of the file in the worktree
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`.

Full grep output, verbatim:

```
107:		cleanup_wt_git --no-optional-locks -C "$wt" diff-index --cached --quiet \
266:		cleanup_wt_git --no-optional-locks -C "$wt" diff --quiet main -- "$rel" \
302:		cleanup_wt_git --no-optional-locks -C "$wt" rev-parse --verify --quiet \
413:	cleanup_wt_git -C "$wt" reset --hard >/dev/null || rrc=$?
418:	cleanup_wt_git -C "$wt" clean -fd >/dev/null || clrc=$?
```

Output Summary: reading the subcommand position of each listed statement — the first token
after `cleanup_wt_git` once the leading global options `--no-optional-locks` and `-C <path>`
are skipped — the five subcommands are `diff-index`, `diff`, `rev-parse`, `reset`, and
`clean`. Exactly one line carries `clean` in that position and exactly one carries `reset`.

- The `clean` line's flag list is exactly `-fd`. It carries none of `-x`, `-X`, `-ff`,
  `-fdx`. Without `-x` the ignored files that the classifier never classifies are never
  cleared, which is the invariant the library header records.
- The `reset` line's flag list is exactly `--hard`.

The count is read at the subcommand token position and is not a substring search over the
matched lines. The wrapper name `cleanup_wt_git` itself contains the letters `clean`, so a
substring count would match all five lines and would report the number of wrapper
statements whatever was written. The grep pattern is anchored to a statement line beginning
with the wrapper for the same class of reason: the library's header comment describes the
clearing behavior in prose, and a prose match would make an "exactly one" count fail for a
documentation reason.

`clear_disposable_dirt` invokes no `git worktree remove`. The sequence is classify, require
the aggregate to be exactly `ALL_DISPOSABLE`, `reset --hard`, `clean -fd`, then emit the
`ACTION|dirt-clear|<path>|OK` record. Any other aggregate, a hard status read that emits no
aggregate at all, and a worktree with no entries all take the same fail-closed refusal
branch. The caller retries the existing unforced removal through `remove_worktree_safe`, so
this path introduces no new removal call site; that invariant is measured across the
production tree by P5-T13.

The behavioral gate for this function is P5-T9.
