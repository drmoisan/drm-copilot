# QA Gate — Rejected Guard Form Absent from the Shipped Code (Issue #630)

Timestamp: 2026-09-07T14-30

Task: [P5-T3]

Command: `grep -rnF -- "rev-list --count" scripts/bash/ | wc -l`

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-adf4f49cbc48904be`

## Command Substitution

The plan's [P5-T3] literal is:

```
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a06652a3fd875c703 && grep -rnF -- "rev-list --count" scripts/bash/ | wc -l'
```

That literal wrapper was unavailable in this environment and was not run. Two substitutions
were applied.

1. **Worktree path.** The plan names the stale worktree `agent-a06652a3fd875c703`; the real
   worktree is `agent-adf4f49cbc48904be`.
2. **Invocation form.** The `wsl -d Ubuntu -- bash -lc '...'` wrapper is refused by the
   worktree-isolation guard. The `grep`/`wc` pipeline was run natively from the worktree
   root with the same flags, the same fixed-string pattern, and the same search root.

## Raw Output

```
0
```

## What the Zero Means

`grep -rnF` searches recursively for the fixed string `rev-list --count` under
`scripts/bash/`, and `wc -l` counts the matching lines. A count of **0** means the
commit-counting guard form appears nowhere in the shipped bash sources. That form was
rejected in research section 7.4 and again in [P5-T1]: the count is also `0` after the
consolidation PR merges with a merge commit, so a guard built on it would permanently block
the documented post-merge cleanup step in
`.claude/skills/cleanup-merged-worktrees/SKILL.md`. The guard that did ship is a
tip-equality comparison that treats an empty or unresolvable `rev-parse` as a hard failure.

This assertion is falsifiable rather than vacuous. The same pipeline against the same search
root with the fixed string `rev-parse` returns `25`:

```
$ grep -rnF -- "rev-parse" scripts/bash/ | wc -l
25
```

The search root is therefore non-empty and the pipeline does report matches when they exist,
so the `0` above is a statement about this specific pattern rather than about the search
being unable to find anything.

Output Summary: The command printed **`0`** and exited **0**. The rejected `rev-list
--count` guard form is **absent** from every file under `scripts/bash/`. This is the
evidence for AC17's negative half.
