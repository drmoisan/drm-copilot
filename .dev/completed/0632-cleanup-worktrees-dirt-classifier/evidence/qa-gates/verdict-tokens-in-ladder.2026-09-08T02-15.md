# P4-T3 — all six verdict tokens are emitted by executable ladder code

Timestamp: 2026-09-08T02-15
Command: `bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh && for t in DISPOSABLE_BUILD_ARTIFACT DISPOSABLE_SESSION_ARTIFACT CONTENT_ON_MAIN CONTENT_IN_HISTORY STAGED_TREE_IS_COMMIT UNIQUE; do printf "%s=%s\n" "$t" "$(grep -vE "^[[:space:]]*#" scripts/bash/cleanup_worktrees_dirt_lib.sh | grep -c "$t")"; done`
EXIT_CODE: 0

Route: the plan's `wsl -d Ubuntu -- bash -lc` wrapper is superseded by EA-1. The command was
executed from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`.

`bash -n` exit: 0.

Loop output, verbatim:

```
DISPOSABLE_BUILD_ARTIFACT=1
DISPOSABLE_SESSION_ARTIFACT=1
CONTENT_ON_MAIN=2
CONTENT_IN_HISTORY=1
STAGED_TREE_IS_COMMIT=1
UNIQUE=7
```

Output Summary: every one of the six `<token>=<count>` pairs carries a count of at least 1,
measured after comment lines were filtered out. The filter and the per-token separation are
both load-bearing: a single aggregated count over the whole file would be satisfied by a
header comment that merely lists the six verdicts and would pass with no ladder present.
`CONTENT_ON_MAIN` appears twice because the rung-4 tracked half and the rung-4 untracked
half each emit it; `UNIQUE` appears seven times because the C-quoted-path branch, the
staged-probe error branch, the build-artifact hard-failure branch, the rung-4 tracked
hard-failure branch, the hash-object failure branch, the find-object failure branch, and
rung 6 each emit it, which is the fail-closed direction the header describes.

The two-way classification of non-zero exits is implemented as the plan requires. A probe
whose non-zero exit is its defined negative answer advances the ladder: `rev-parse
main:<path>` failing means the path is absent from `main`, and `diff --quiet main --
<path>` exiting 1 means the contents differ; both are rung-4 misses that fall through to
rung 5. A probe whose non-zero exit carries no verdict maps the entry to `UNIQUE`:
`status --porcelain`, `hash-object`, `log --find-object`, and `diff-index --cached --quiet`
above 1. A path field beginning with a double quote returns `UNIQUE` immediately with no
unquoting attempt, and a rename or copy entry classifies the text after the ` -> `
separator.

The behavioral gate for the ladder is P4-T4: `classify_dirt_entry` is not reachable from
the bats suites until `classify_worktree_dirt` drives it.
