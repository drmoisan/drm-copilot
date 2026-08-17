# Git Baseline (Issue #476)

Timestamp: 2026-08-16T17-08

Command: `git rev-parse HEAD` and `git status --porcelain` (run from the repository root `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-15T12-46`)

EXIT_CODE: 0

## Raw Output

```text
$ git rev-parse HEAD
687380a695c3fae873e75fbd22235d80ede0166a

$ git rev-parse --abbrev-ref HEAD
bug/powershell-branch-coverage-gate-unsatisfiable-476

$ git status --porcelain
?? docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/
```

Output Summary: HEAD SHA is `687380a695c3fae873e75fbd22235d80ede0166a`, matching the plan's stated base `main` at `687380a6`. The active branch is `bug/powershell-branch-coverage-gate-unsatisfiable-476`. The working tree carries no tracked-file modifications; the only entry is the untracked feature folder `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/` holding this feature's own documentation and evidence. No file in the closed 17-file edit surface is modified at baseline.
