# R3 COV-1 Bisection Derivation (P1-T15)

Timestamp: 2026-10-16T14-13
TARGET: 142 (TARGET-SOURCE: lib-only)
TARGET-CHECK: EQUALS-ESTABLISHED
Module token (P0-T3): MODULE-UNCHANGED
UseBreakpoints (P0-T5): repository runsettings count 0; installed copies `undefined_publisher.drm-copilot-0.0.1` (.vscode) 0, `undefined_publisher.drm-copilot-0.0.1` (.vscode-insiders) 0, `danmoisan.drm-copilot-1.1.18` (.vscode-insiders) 0. No INSTALLED-SETTINGS-NOT-BREAKPOINT.
covered_HEAD (N1): 127

## Node table

| Node | Task | Set S (reverted to REF) | Ran | Validity | covered | credited | Classification | Artifact |
|---|---|---|---|---|---|---|---|---|
| N0 | P1-T1 | none; scan_folders `tests/scripts/claude-lib/worktree-resolution` | ran | VALID | 142 | 30 | TARGET: 142 (lib-only) | `r3-cov-n0-lib-only.2026-10-16T12-50.md` |
| N1 | P1-T2 | empty (HEAD) | ran | VALID | 127 | 18 | REPRODUCED | `r3-cov-n1-head.2026-10-16T13-08.md` |
| N2 | P1-T3 | S-A = P_HRS | ran | VALID | 127 | 18 | NO-EFFECT | `r3-cov-n2-sa.2026-10-16T13-26.md` |
| N3 | P1-T4 | S-C = P_DS, P_LGS, P_BRS, P_PRS | ran | VALID | 127 | 18 | NO-EFFECT | `r3-cov-n3-sc.2026-10-16T13-42.md` |
| N3a | P1-T5 | P_DS | not reached | - | - | - | - | none |
| N3b | P1-T6 | P_LGS | not reached | - | - | - | - | none |
| N3c | P1-T7 | P_BRS | not reached | - | - | - | - | none |
| N3d | P1-T8 | P_PRS | not reached | - | - | - | - | none |
| N4 | P1-T9 | S-B = P_HRH, P_H, P_DH, P_CH | ran | VALID | 127 | 18 | NO-EFFECT | `r3-cov-n4-sb.2026-10-16T13-58.md` |
| N4a | P1-T10 | P_HRH, P_H | not reached | - | - | - | - | none |
| N4b | P1-T11 | P_H | not reached | - | - | - | - | none |
| N4c | P1-T12 | P_DH | not reached | - | - | - | - | none |
| N4d | P1-T13 | P_CH | not reached | - | - | - | - | none |
| N5 | P1-T14 | U4 (all nine paths) | ran | VALID | 127 | 18 | NO-EFFECT | `r3-cov-n5-u4.2026-10-16T14-13.md` |

BISECTION-PATH: N0 TARGET 142 (lib-only); N1 REPRODUCED; N2 NO-EFFECT; N3 NO-EFFECT; N4 NO-EFFECT; N5 NO-EFFECT

## Terminal derivation (first match)
1. T-NOT-MEASURED: N1 is not NOT-MEASURED -> no.
2. T-NOT-REPRODUCED: N1 is not NOT-REPRODUCED -> no.
3. T-HRS: N2 is NO-EFFECT -> no.
4-7. T-DS, T-LGS, T-BRS, T-PRS: N3a-N3d not reached -> no.
8. T-SC-AGG: N3 is NO-EFFECT -> no.
9-12. T-H, T-HRH, T-DH, T-CH: N4a-N4d not reached -> no.
13. T-SB-AGG: N4 is NO-EFFECT -> no.
14. T-U4-AGG: N5 is NO-EFFECT -> no.
15. T-U4-NO-LONGER: otherwise -> yes.

BISECTION-TERMINAL: T-U4-NO-LONGER

After the task: `git status --porcelain -- tests` empty.
