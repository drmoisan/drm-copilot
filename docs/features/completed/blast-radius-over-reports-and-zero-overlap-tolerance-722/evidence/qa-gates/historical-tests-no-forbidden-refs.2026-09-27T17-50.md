# Historical Tests Read Committed Fixtures Only (P12-T10)

Timestamp: 2026-09-27T17-50
Command: git grep -n -F -e origin/ -e artifacts/ -e worktree -- tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The forbidden-reference search exits 1 and prints nothing: neither historical test file contains origin/, artifacts/, or worktree. Both files are tracked: git ls-files --error-unmatch exits 0 for each. Run at HEAD 5ee710b3 (the Phase 12 commit), so the searched content is the committed content.

The EXIT_CODE and ExpectedExitCode fields refer to the git grep run. The two tracked-file checks are recorded below.

## Commands and results

The three git commands were run separately through a small Python wrapper (SCRATCH/exit-code.py) that prints each command's exact argv, stdout, stderr, and exit code, because the Bash tool does not display the exit status of a command that prints nothing.

| Command | EXIT_CODE | Output |
| --- | --- | --- |
| git ls-files --error-unmatch -- tests/scripts/dev_tools/test_blast_radius_historical_runs.py | 0 | tests/scripts/dev_tools/test_blast_radius_historical_runs.py |
| git ls-files --error-unmatch -- tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 | 0 | tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1 |
| git grep -n -F -e origin/ -e artifacts/ -e worktree -- (both files) | 1 | (no output) |

## Wrapper output

```text
COMMAND git ls-files --error-unmatch -- tests/scripts/dev_tools/test_blast_radius_historical_runs.py
STDOUT-BEGIN
tests/scripts/dev_tools/test_blast_radius_historical_runs.py
STDOUT-END
STDERR-BEGIN
STDERR-END
EXIT_CODE=0
COMMAND git ls-files --error-unmatch -- tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
STDOUT-BEGIN
tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
STDOUT-END
STDERR-BEGIN
STDERR-END
EXIT_CODE=0
COMMAND git grep -n -F -e origin/ -e artifacts/ -e worktree -- tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1
STDOUT-BEGIN
STDOUT-END
STDERR-BEGIN
STDERR-END
EXIT_CODE=1
```

The same three commands were also run directly through the Bash tool as plain git commands; the two ls-files runs printed their paths and the grep printed nothing.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
