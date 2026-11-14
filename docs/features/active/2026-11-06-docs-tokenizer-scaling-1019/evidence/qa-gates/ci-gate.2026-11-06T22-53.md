# CI Gate on the Pull Request Head - Issue 1019

Timestamp: 2026-11-06T22-53
Command: gh pr checks 1092 --json bucket,name,state,link,workflow, parsed by .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -RequireWorkflow CI; coverage from the poshqc-test-results artifact of CI run 42305647687
EXIT_CODE: 0
Output Summary: PR 1092 at head 25936b4d2b2a5f0b6255197db2391c463b228883 reported 26 checks, 26 passed, 0 failed, 0 pending, 0 skipped, and the parser returned conclusion success. CI full run and CI Required Gate both succeeded, so this is a full run. Merged PowerShell coverage is 95.22% lines (32116 of 33729), and MODULE is 100% lines (151 of 151).

## Coverage From the Merged CI Artifact

| Scope | Lines covered | Lines missed | Line coverage |
| --- | --- | --- | --- |
| Repository, merged shards | 32116 | 1613 | 95.22% |
| `.claude/lib/docs/DocsPythonTokens.psm1` | 151 | 0 | 100.00% |

The 85% line floor holds for both rows. Pester measures no branch coverage, so no branch figure applies.

## Run

- CI run: https://github.com/drmoisan/drm-copilot/actions/runs/42305647687
- `mergeStateStatus` at the poll: `CLEAN`; `mergeable`: `MERGEABLE`.
