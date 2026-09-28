# Baseline — Bash Format and Lint (`shell-qc.sh check`)

Timestamp: 2026-08-30T06-22
Task: [P0-T2]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `wsl -d Ubuntu -e bash -lc 'cd /mnt/c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab2cbeea5d3050501 && bash scripts/bash/shell-qc.sh check'`

EXIT_CODE: 0

Output Summary: The command produced no stdout and no stderr. Both streams were empty, reproduced
verbatim below between the fence markers.

```
```

Exit code 0 with empty output matches the expected value the plan records for this baseline against
the pre-Phase-1 tree. No pre-existing drift is present, so no drift report is owed to Phase 1.

## Read-Only Confirmation

`shell-qc.sh check` runs `shfmt -d` in diff mode and then `shellcheck` once per file, returning the
maximum exit code (`scripts/bash/shell_qc_lib.sh:164-202`). Neither stage writes. The exit code
alone therefore distinguishes a clean tree from a drifted one, which is why the acceptance for this
task rests on it.

Independently verified: `git status --porcelain` over the worktree, excluding this feature's own
folder, returned no output after the run. No tracked file was rewritten by this command, so this
baseline was not taken after a formatter silently repaired pre-existing drift.

## Bearing on Later Tasks

P4-T1's attribution argument depends on this baseline being clean. It is clean, so any `shfmt`
rewrite observed at P4-T1 is attributable to a file this feature added rather than to pre-existing
drift.
