# CI Shell Coverage (P4-T9, P4-T10), pass 1 -- FAILED, loop restarted

Timestamp: 2026-09-27T10-38
Workflow: .github/workflows/_shell-coverage.yml
CI_SHA: b6d86d8c651ded29825ff28eb535e7f039881c15
Dispatch time (UTC): 2026-09-27T14:17:01Z
RUN_ID: 36325350057
Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/36325350057

## Dispatch

Command: gh workflow run _shell-coverage.yml --ref bug/cleanup-report-registration-lost-false-positive-706
EXIT_CODE: 0
Output Summary: https://github.com/drmoisan/drm-copilot/actions/runs/36325350057

## Poll 1

Command: gh run list --workflow=_shell-coverage.yml --branch bug/cleanup-report-registration-lost-false-positive-706 --event workflow_dispatch --limit 1 --json databaseId,headSha,status,conclusion,createdAt
EXIT_CODE: 0
Output Summary: [{"conclusion":"","createdAt":"2026-09-27T14:17:03Z","databaseId":36325350057,"headSha":"b6d86d8c651ded29825ff28eb535e7f039881c15","status":"in_progress"}] -- created after the dispatch time; headSha equals CI_SHA.

## Log filter: named tests and headline

Command: gh run view 36325350057 --log | grep -F -e 'scan-dirs reports target_exists' -e 'scan_helper_is_absolute_path returns' -e 'scan-dirs emits has_gitfile' -e 'Bash coverage (lines):'
EXIT_CODE: 0
Output Summary: (log prefixes removed)
- `ok 426 scan-dirs emits has_gitfile/target_exists/size for each candidate directory`
- `not ok 427 scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory`
- `ok 428 scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist`
- `not ok 429 scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths`
- `not ok 430 scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths`
- No numeric `Bash coverage (lines):` headline was printed (only three help-text lines quoting `"Bash coverage (lines): NN.N%" summary.`).

## Log filter: not ok lines

Command: gh run view 36325350057 --log | grep -E ' not ok [0-9]+ '
EXIT_CODE: 0
Output Summary: Three failing tests: 427 (test 1), 429 (test 3), 430 (test 4). Each failed at `[ "$status" -eq 0 ]` (bats detail lines: test file line 49, 75, and 91). None is in the P0-T13 CI baseline failure set (none), so neither loop-rule exception applies; the loop restarts at P4-T1.

## Root cause and remediation

All three failing tests load the helper with `source "$1"` at the top level of a `bash -c` child; test 2 and the existing test run the helper as a script and pass. The helper runs `set -euo pipefail` at top level, so sourcing enables nounset in the child. Under kcov, child bash shells are traced with a PS4 that expands `${BASH_SOURCE}`, which is unset at the top level of `bash -c`, so the next traced command aborts with `BASH_SOURCE: unbound variable`. Reproduced locally with a simulated trace environment (`PS4='kcov@${BASH_SOURCE}@${LINENO}@'`, `set -x` via `BASH_ENV`): the `bash -c` + `source` form exits 1 with `_: line 3: BASH_SOURCE: unbound variable`; the script form exits 0. Remediation (test code only; the production helper is unchanged): each of the three blocks now loads the helper through `load_helper() { source "$1"; set +u; }` followed by `load_helper "$1"`, which passed under the same simulation and without it.

## Watch (written last)

Command: gh run watch 36325350057 --exit-status
EXIT_CODE: 1
Output Summary: Run concluded failure. `Run shell-qc check (shfmt diff + shellcheck)` succeeded; `Run shell-qc test with coverage` failed (`Process completed with exit code 1.`); `Upload shell coverage artifacts` was skipped, so no `shell-coverage` artifact exists for this run.
