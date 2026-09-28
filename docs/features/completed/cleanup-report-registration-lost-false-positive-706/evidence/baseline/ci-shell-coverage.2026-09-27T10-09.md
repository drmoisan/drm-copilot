# Baseline CI Shell Coverage (P0-T13)

Timestamp: 2026-09-27T10-09
Workflow: .github/workflows/_shell-coverage.yml
Pushed SHA: c84938edb744aa08dd51fe55652714939467f8e5
Dispatch time (UTC): 2026-09-27T14:01:13Z
RUN_ID: 36324413557
Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/36324413557

## Push

Command: git push -u origin bug/cleanup-report-registration-lost-false-positive-706
EXIT_CODE: 0
Output Summary: `Everything up-to-date`; upstream tracking set to origin/bug/cleanup-report-registration-lost-false-positive-706. Remote head is c84938edb744aa08dd51fe55652714939467f8e5.

## Dispatch

Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-report-registration-lost-false-positive-706
EXIT_CODE: 0
Output Summary: https://github.com/drmoisan/drm-copilot/actions/runs/36324413557

## Poll 1

Command: gh run list --workflow=_shell-coverage.yml --branch bug/cleanup-report-registration-lost-false-positive-706 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: [{"conclusion":"","createdAt":"2026-09-27T14:01:16Z","databaseId":36324413557,"headSha":"c84938edb744aa08dd51fe55652714939467f8e5","status":"in_progress"}] -- created after the dispatch time; headSha equals the pushed SHA.

## Log filter: headline

Command: gh run view 36324413557 --log | grep -F 'Bash coverage (lines):'
EXIT_CODE: 0
Output Summary: Headline line `Bash coverage (lines): 93.3%` (step `Run shell-qc test with coverage`, 2026-09-27T14:08:05Z). Three further matches are help-text lines quoting the literal `"Bash coverage (lines): NN.N%" summary.` and carry no value.

Bash coverage (lines): 93.3%

## Log filter: not ok count

Command: gh run view 36324413557 --log | grep -c -E ' not ok [0-9]+ '
EXIT_CODE: 1
Output Summary: 0

## Log filter: not ok lines

Command: gh run view 36324413557 --log | grep -E ' not ok [0-9]+ '
EXIT_CODE: 1
Output Summary: No output.

CI baseline failure set: none

## Watch (started before the log filters; written last)

Command: gh run watch 36324413557 --exit-status
EXIT_CODE: 0
Output Summary: Run completed with conclusion success. Steps `Run shell-qc check (shfmt diff + shellcheck)`, `Run shell-qc test with coverage`, and `Upload shell coverage artifacts` all succeeded.
