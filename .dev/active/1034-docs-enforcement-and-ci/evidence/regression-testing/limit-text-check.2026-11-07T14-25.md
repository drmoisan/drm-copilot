# Limit Text Token Check - Issue 1034 Remediation Cycle 4 (P1-T3)

Timestamp: 2026-11-07T14-25
Command: sh SCRATCH/issue-1034-c4-ps.sh issue-1034-c4-tokens.ps1 (reads the HOOK help block from its opening line to its closing line and FEATURE/spec.md, removes backticks, collapses every whitespace run to one space, and tests each token with an ordinal substring match; exits 1 when any token is absent or the old phrase is present)
EXIT_CODE: 0
Output Summary: PASS. K1 to K11 are present in both the HOOK help block and SPEC, and "in the unquoted text" is absent from both (0 failing rows of 24). The same script, run on the tree before P1-T1 and P1-T2, exited 1 with 24 failing rows (every token absent and the old phrase present in both texts), so the check can fail.

## After the Edits

| ID | Token | HOOK | SPEC |
|---|---|---|---|
| K1 | `the shared scanner reads as unquoted` | present | present |
| K2 | `keeps no comment state` | present | present |
| K3 | `quote character in a # comment` | present | present |
| K4 | `heredoc opener << in a # comment` | present | present |
| K5 | `$((1<<4))` | present | present |
| K6 | `double quotes nested in a command substitution` | present | present |
| K7 | `x68` | present | present |
| K8 | `xargs gh` | present | present |
| K9 | `shell alias` | present | present |
| K10 | `base64 -d` | present | present |
| K11 | `repos/o/r/merges` | present | present |
| old | `in the unquoted text` | absent | absent |

## Before the Edits (same script, unedited tree)

EXIT_CODE of that run: 1. Every K1 to K11 row was `absent` in both texts, and `in the unquoted text` was `present` in both texts: 24 failing rows.
