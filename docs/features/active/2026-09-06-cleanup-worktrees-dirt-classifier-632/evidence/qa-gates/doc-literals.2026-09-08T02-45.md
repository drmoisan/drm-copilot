# P6-T7 — documentation-literal counts for the SKILL.md and contract-comment criteria

Timestamp: 2026-09-08T02-45
Task: [P6-T7]
EXIT_CODE: 0

## Command 1 — SKILL.md

```
for t in "DIRTFILE|" "DIRTSUM|" "--clear-disposable" "HintPath" "apply mode only" "This is never automated:"; do
  printf "%s=%s\n" "$t" "$(grep -cF -- "$t" .claude/skills/cleanup-merged-worktrees/SKILL.md)"
done
```

Output, verbatim:

```
DIRTFILE|=4
DIRTSUM|=3
--clear-disposable=3
HintPath=2
apply mode only=1
This is never automated:=1
```

## Command 2 — report-line contract comment block

```
for t in "DIRTFILE|" "DIRTSUM|" "--clear-disposable"; do
  printf "%s=%s\n" "$t" "$(grep -cF -- "$t" scripts/bash/cleanup_worktrees_lib.sh)"
done
```

Output, verbatim:

```
DIRTFILE|=1
DIRTSUM|=1
--clear-disposable=1
```

## Output Summary

All nine printed `<token>=<count>` pairs carry a count of at least 1. `grep -cF -- ` is used so the
leading dashes of `--clear-disposable` are read as pattern text rather than as options, and each
token is counted separately so no single token can satisfy the gate on behalf of the others.

The two multi-word tokens are readable by a line-oriented count because each occupies one unwrapped
line: `apply mode only` was written on a single line by [P6-T1] for exactly this reason, and
`This is never automated:` already occupied one line in step 9 and was preserved unchanged by
[P6-T4], which is what the retention half of that task's acceptance clause requires.

## Command form note

Both commands are stated in the plan in the
`wsl -d Ubuntu -- bash -lc 'cd /mnt/c/... && ...'` form. They were executed from the Windows worktree
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d` through the same
`bash` available there. The commands, the files read, and the counting semantics are unchanged.
