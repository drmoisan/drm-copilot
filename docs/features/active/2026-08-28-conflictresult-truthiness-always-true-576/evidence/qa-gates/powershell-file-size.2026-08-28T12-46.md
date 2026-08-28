# PowerShell Module File Size — [P4-T6]

Timestamp: 2026-08-28T12-46

Command: `(Get-Content .claude/lib/blast-radius/BlastRadius.psm1).Count` and `(Get-Content extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1).Count`

EXIT_CODE: 0

## Measurements

```
SRC=493
BUNDLED=493
```

| Path | Line count | Below 500 |
| --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 493 | Yes |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1` | 493 | Yes |

The two numbers are equal to each other.

## Budget Check Against Verified Fact 9

| Item | Value |
| --- | --- |
| Line count before the comment-based-help addition | 482 |
| Budget stated in verified fact 9 | 17 lines |
| Lines actually added | 11 |
| Line count after | 493 |
| Headroom remaining to the 500-line limit | 7 |

The anchored stat diff `git diff --stat origin/main -- .claude/lib/blast-radius/BlastRadius.psm1`
reports `1 file changed, 11 insertions(+)`, confirming the eleven-line addition and zero deletions.
The addition is inside the 17-line budget.

Output Summary: `EXIT_CODE: 0`. Both copies of `BlastRadius.psm1` measure 493 lines. Both are
strictly below the 500-line limit and both are equal to each other. The comment-based-help addition
added 11 lines to a 482-line file, inside the 17-line budget recorded in verified fact 9, leaving 7
lines of headroom. This task discharges AC21.
