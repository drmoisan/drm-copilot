# CI Shell Coverage (P4-T9, P4-T10), pass 2

Timestamp: 2026-09-27T10-48
Workflow: .github/workflows/_shell-coverage.yml
CI_SHA: 3bcaee4d87dae9d077ddbe9b6cb9f357230e3548
Dispatch time (UTC): 2026-09-27T14:28:06Z
RUN_ID: 36326020967
Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/36326020967

## Dispatch

Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-report-registration-lost-false-positive-706
EXIT_CODE: 0
Output Summary: https://github.com/drmoisan/drm-copilot/actions/runs/36326020967

## Poll 1

Command: gh run list --workflow=_shell-coverage.yml --branch bug/cleanup-report-registration-lost-false-positive-706 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: [{"conclusion":"","createdAt":"2026-09-27T14:28:09Z","databaseId":36326020967,"headSha":"3bcaee4d87dae9d077ddbe9b6cb9f357230e3548","status":"in_progress"}] -- created after the dispatch time; headSha equals CI_SHA.

## Log filter: named tests and headline

Command: gh run view 36326020967 --log | grep -F -e 'scan-dirs reports target_exists' -e 'scan_helper_is_absolute_path returns' -e 'scan-dirs emits has_gitfile' -e 'Bash coverage (lines):'
EXIT_CODE: 0
Output Summary: (log prefixes removed)
- `ok 426 scan-dirs emits has_gitfile/target_exists/size for each candidate directory`
- `ok 427 scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory`
- `ok 428 scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist`
- `ok 429 scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths`
- `ok 430 scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths`
- `Bash coverage (lines): 93.3%` (three further matches are help-text lines quoting the literal with `NN.N%`).

Bash coverage (lines): 93.3% (at least 85.0)

## Log filter: not ok lines

Command: gh run view 36326020967 --log | grep -E ' not ok [0-9]+ '
EXIT_CODE: 1
Output Summary: No output; no failing test names.

## Watch (written last)

Command: gh run watch 36326020967 --exit-status
EXIT_CODE: 0
Output Summary: Run concluded success. `Run shell-qc check (shfmt diff + shellcheck)` (CI shfmt 3.8.0 printed no diff), `Run shell-qc test with coverage`, and `Upload shell coverage artifacts` all succeeded.
