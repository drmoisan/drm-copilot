# LASTEXITCODE Guard Decision (P1-T5)

Timestamp: 2026-11-04T01-19
Command: rule of remediation plan P1-T5 applied to evidence/regression-testing/fail-before-guard-globals.2026-11-04T01-18.md (P1-T3) and evidence/regression-testing/fail-before-lastexitcode.2026-11-04T01-19.md (P1-T4)
EXIT_CODE: 0
Output Summary:

LastExitCodeGuardForm: p

| Input | Recorded value | Required for p | Holds |
|---|---|---|---|
| P1-T3 control probe value | 41 | 41 | yes |
| P1-T3 RD2 testcase outcome | passed | passed | yes |
| P1-T4 acceptance (EXIT_CODE 1, RD2 fails with target probe other than 41, hashes equal) | EXIT_CODE 1; target probe 0; hashes equal | met | yes |

Reason: all three inputs hold, so the rule gives form p. The RD2 testcase passes on the DD1 tree and fails when only the DD1 LASTEXITCODE restore is removed, so it can fail, which closes finding F2. This artifact supersedes the LASTEXITCODE note under `## Guard Decision` of plan.2026-11-03T17-43.md.

## P1-T6

not applicable: LastExitCodeGuardForm p (GUARD unchanged since P1-T2).

## P1-T7

not applicable: LastExitCodeGuardForm p.
