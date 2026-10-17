# Release-Flow Script Static Check (Issue #931)

Timestamp: 2026-10-16T01-34
Command: git grep -n -i -F -e "required check" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PASS. Both searches print nothing and exit 1. Before P1-T6 and P1-T9 both matched the file (plan-time lines 165, 167, 196, 200, 220, 239).

| Command | Output | Exit |
|---|---|---|
| `git grep -n -i -F -e "required check" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | (none) | 1 |
| `git grep -n -F -e "--required" -- scripts/dev-tools/Invoke-FullReleaseFlow.ps1` | (none) | 1 |

Both runs were taken after the edits for P1-T4 to P1-T10 and repeated after the P1-T12 blank-line trim; the results were unchanged.
