# Acceptance criteria status

Plan task: `[P8-T1]`

`REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED`

The final comparison used branch `(b)`: R1 remains non-PASS and R2-R5 pass. The acceptance-criteria tracking contract therefore prohibits checking off the four remediation-dependent criteria. No checkbox token was changed in `spec.md` or `user-story.md`.

## Source counts

| Source | Total | Checked | Unchecked |
|---|---:|---:|---:|
| `spec.md` | 22 | 19 | 3 |
| `user-story.md` | 21 | 18 | 3 |
| Combined | 43 | 37 | 6 |

## Remaining criteria

- S-D13 remains unchecked: the complete four-language and zero-regression gate cannot be complete while PowerShell branch policy is unresolved.
- S-D14 remains unchecked: the repository-wide branch-coverage requirement lacks an authoritative PowerShell denominator or separately authorized policy resolution.
- S-D15 remains unchecked: exact-current-head hosted CI is deferred to the orchestrator.
- U19 remains unchecked for the same unresolved PowerShell branch-policy requirement as S-D13.
- U20 remains unchecked for the same unresolved PowerShell branch-coverage requirement as S-D14.
- U21 remains unchecked: exact-current-head hosted CI is deferred to the orchestrator.

The 41/43 state is not claimed because it requires all five remediation blockers to pass. The current verified state is 37/43, with all six named criteria unchanged and unchecked.
