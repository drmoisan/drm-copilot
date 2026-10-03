# r1 P8-T18 — no absolute host path in the feature folder

Timestamp: 2026-10-03T13-42
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p8-t18.ps1 -Worktree WORKTREE (A0; the run-time-assembled two-token `git grep --untracked -i -l` over FEATURE; the JUNIT-COUNT line; the closing `if` exit line)
EXIT_CODE: 0
Output Summary:
- No file-name line printed; HOSTPATH-GREP-EXIT=1
- JUNIT-COUNT=0
- `-l` prints file names only, and the two tokens are assembled at run time, so this artifact carries no matched text.
