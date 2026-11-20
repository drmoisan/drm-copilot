# Phase 0 Scratchpad Helpers (P0-T18, P0-T19)

Timestamp: 2026-09-27T14-41

`<scratchpad>` is the executing session's own scratchpad subdirectory (a dedicated `452-v2` subfolder, used so that no helper collides with files from other sessions). Helpers are never committed and are not tests.

PowerShell-side helpers written with the exact bodies fixed in P0-T18 (nine files):

1. `<scratchpad>`/run-ps.sh
2. `<scratchpad>`/line-counts.ps1
3. `<scratchpad>`/file-hashes.ps1
4. `<scratchpad>`/clear-pester-artifacts.ps1
5. `<scratchpad>`/poshqc-test.ps1
6. `<scratchpad>`/junit-report.ps1
7. `<scratchpad>`/coverage-line.ps1
8. `<scratchpad>`/pssa-count.ps1
9. `<scratchpad>`/poshqc-format.ps1

Python-side helper written with the exact body fixed in P0-T19: `<scratchpad>`/coverage_totals.py (exercised in P0-T23).

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/line-counts.ps1 docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md

EXIT_CODE: 0

Output:

```
docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/plan.2026-09-27T12-15.md LineCount=738
```

Output Summary: The runner route executed PowerShell against a repository file and printed exactly one line ending in LineCount=738 (an integer greater than 0). The worktree guard did not refuse the command.
