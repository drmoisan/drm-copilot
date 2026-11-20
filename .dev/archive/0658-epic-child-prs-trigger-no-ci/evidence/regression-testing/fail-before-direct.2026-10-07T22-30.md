# Fail-Before, New Suite Against Unmodified ci.yml ([P1-T4] [expect-fail])

Timestamp: 2026-10-07T22-30
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/CiWorkflow.Tests.ps1 -Output Detailed"
Route: ci-evidence
Deviation: DEV-CI-FAILBEFORE, DEV-PWSH-ROUTE
ExecutedCommand: none locally; values read from workflow_dispatch CI run 37715960709, job 113112343480 "poshqc / PowerShell QC" (Invoke-PoshQCTest over the full repository at Normal verbosity)
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37715960709/job/113112343480 (workflow CI, event workflow_dispatch, head 632fe595199cc75e7e1560f010acc3a0e611aab2, conclusion failure)
EXIT_CODE: 1
ExpectedExitCode: 1
CiYmlStatus: (empty) - ci.yml unmodified at the run head: `git diff --numstat origin/main...632fe595 -- .github/workflows/ci.yml` printed nothing (exit 0); `git show --stat 632fe595` lists only the handoff and hermeticity evidence, the plan, and tests/scripts/workflows/CiWorkflow.Tests.ps1.
Output Summary:
- `[-]` line (log line 1253, ANSI codes and the `##[error]` annotation prefix stripped): `[-] ci.yml workflow triggers.lists main, development, and epic/** in the pull_request branch filter 7ms (7ms|0ms)`
- Failure message (log line 1255): `Expected 'epic/**' to be found in collection @('main', 'development'), because epic child PRs into epic/<slug>-integration must run CI (issue #658), but it was not found.`
- Failure location (log line 1256): `<WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1:161`
- `[+]` line for `keeps the push branch filter exactly main and development`: not printed individually. The CI run uses `Output.Verbosity = 'Normal'`, which prints per-test `[-]` lines for failures and per-file `[+]` lines only for files with no failures; CiWorkflow.Tests.ps1 has a failure, so no per-file `[+]` line exists for it and passing tests in it are not listed. This is part of DEV-CI-FAILBEFORE.
- Push It passed (derived): the run's only `[-]` line in the whole log (`grep -c '\[-\]'` = 1) is the pull_request It, and the counts line moved from the [P0-T18] baseline `Tests Passed: 6519, Failed: 0` to `Tests Passed: 6520, Failed: 1` (log line 1263), i.e. exactly one more pass and one more fail. The suite has exactly two It blocks, so the added pass is the push It.
- Full-repository counts line (log line 1263): `Tests Passed: 6520, Failed: 1, Skipped: 10, Inconclusive: 0, NotRun: 0`. A suite-alone `Tests Passed: 1, Failed: 1` line was not produced by this route; the per-suite result is 1 passed (push It, derived as above) and 1 failed (pull_request It).
- Job end (log line 1266): `Process completed with exit code 1.`
- BaselineArtifact: docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/evidence/baseline/baseline-poshqc-test.2026-10-07T21-58.md
