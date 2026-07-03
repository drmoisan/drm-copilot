# PowerShell Line-Count Baseline — `enforce-pr-author-skill.ps1` (Remediation Cycle 1)

- **Timestamp:** 2026-07-02T23-06
- **Task:** [P0-T2]
- **Command:** `(Get-Content .claude/hooks/enforce-pr-author-skill.ps1 | Measure-Object -Line).Lines`
- **EXIT_CODE:** 0

## Output Summary

The literal command specified in the task returned `471`, not the expected `543`. Investigation
confirmed this is a known `Measure-Object -Line` quirk: it counts embedded newline characters
within each string it receives, but `Get-Content` already strips line terminators and returns one
empty-string element per blank line, so blank lines contribute `0` instead of `1` to the tally.
The file contains 72 blank lines (`471 + 72 = 543`).

Two independent corroborating counts were taken to confirm the true baseline:

- `(Get-Content .claude/hooks/enforce-pr-author-skill.ps1).Count` → `543`
- `wc -l .claude/hooks/enforce-pr-author-skill.ps1` → `543`

Both agree with each other and with the plan's stated baseline value. The authoritative baseline
for this task is **543 lines**, consistent with the plan's acceptance criterion. The literal
`Measure-Object -Line` command is not used for the Phase 1 confirmation step ([P1-T3]); the
`.Count`-based (or `wc -l`-equivalent) measurement is used there instead, for the same reason.
