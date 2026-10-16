# Scratch directory holds no PowerShell file (P0-T6)

Timestamp: 2026-10-16T02-16

Command: git status --porcelain; git ls-files --others --exclude-standard -- SCRATCH; git ls-files --others --exclude-standard -- SCRATCH | grep -c -E -e '[.](ps1|psm1|psd1)$'

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- `git status --porcelain` printed one line: `?? SCRATCH/`.
- `git ls-files --others --exclude-standard -- SCRATCH` listed `SCRATCH/issue-930/P0-T4.sh` and `SCRATCH/issue-930/P0-T5.sh`.
- The `grep -c` command printed `0` and exited 1 (grep exits 1 when the count is zero; that is the expected result) (no `.ps1`, `.psm1`, or `.psd1` file under SCRATCH).
- No path outside the allowed set appeared.
