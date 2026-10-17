# Baseline Pester state of the existing suites (P0-T10)

Timestamp: 2026-10-16T23-25
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1,tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1,tests/scripts/workflows/CiWorkflow.Tests.ps1,tests/scripts/workflows/PoshQcWorkflow.Tests.ps1,tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1,tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1" -NamePatternList "returns success when a check is skipping (skipping is non-blocking),returns pending for an empty check array with -RequireWorkflow CI,returns pending when the only CI checks are skipping"
EXIT_CODE: 0
Output Summary: 7 containers Result=Passed; TOTAL Passed=107 Failed=0; the three PATTERNS-PARSER rows each Passed=1 Failed=0 Total=1; EXIT_CODE_COMPUTED: 0. No pre-existing suite failure. CI job: poshqc / PowerShell QC (windows-latest).

## Output (ANSI codes stripped, host paths redacted)

```
RUN-CR: cr-pester-list

Starting discovery in 7 files.
Discovery found 107 tests in 720ms.
Running tests.
[+] <WORKSPACE_ROOT>\tests\scripts\claude-hooks\hook-docs-only-diff.Tests.ps1 1.5s (459ms|733ms)
[+] <WORKSPACE_ROOT>\tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1 956ms (569ms|256ms)
[+] <WORKSPACE_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 607ms (418ms|124ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 167ms (32ms|72ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 218ms (122ms|67ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 237ms (107ms|92ms)
[+] <WORKSPACE_ROOT>\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 165ms (26ms|83ms)
Tests completed in 3.88s
Tests Passed: 107, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
CONTAINER: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | Passed=30 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | Passed=35 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | Passed=10 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/CiWorkflow.Tests.ps1 | Passed=2 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | Passed=15 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
NAMED: returns success when a check is skipping (skipping is non-blocking) | Passed=1 | Failed=0 | Total=1
NAMED: returns pending for an empty check array with -RequireWorkflow CI | Passed=1 | Failed=0 | Total=1
NAMED: returns pending when the only CI checks are skipping | Passed=1 | Failed=0 | Total=1
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns null for an all-docs set
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for .claude/hooks/x.ps1
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for .github/workflows/ci.yml
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for README.md
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for docsx/a.md
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for doc/a.md
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for Docs/a.md
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for docs
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | names the first offending path of a mixed set
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns EMPTY_DIFF for an empty set
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | splits a NUL list with spaces and non-ASCII names
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | keeps a line feed inside a name as one element
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns no element for empty and null text
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | denies non-empty output that lacks the trailing NUL (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns EMPTY_DIFF for empty diff text (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns EMPTY_DIFF for null diff text (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns NON_DOCS_PATH for a NUL-terminated list with a path outside docs (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns null for a NUL-terminated list of docs paths (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | passes -C, the root, and the arguments in order and keeps the trailing NUL (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the non-zero exit code of the injected git command (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the failure object when the injected git command throws (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the failure object without running git for a blank root (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the failure object without running git for a nonexistent root (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | runs inside the working root with the arguments in order and restores the location (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the non-zero exit code of the injected gh command (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the failure object and restores the location when the injected gh command throws (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the failure object without running gh for a blank root (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | returns the failure object without running gh for a nonexistent root (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | is byte-identical across all four copies (issue #927)
ROW: Passed | tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | imports nothing, dot-sources nothing, and names no fetch argument (issue #927)
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns success when all required checks pass
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns failure when any required check failed
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns pending when a check is in progress and none failed
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns failure when a check is cancelled (cancel maps to failure)
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns success when a check is skipping (skipping is non-blocking)
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns success for an empty required-check array without -RequireWorkflow (vacuous satisfaction)
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | prefers failure over pending when both are present
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | throws an explicit error on malformed JSON
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | throws an explicit error naming an unrecognized bucket value
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | throws an explicit error when a check element lacks a bucket property
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | produces verified_at from the injected NowProvider delegate
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | passes head_sha, pr_pipeline_run_id, and pr_pipeline_run_url through to the emitted object
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | emits all five ci_gate fields
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | emits a JSON string carrying the conclusion when -AsJson is set
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns success for a null check set
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | declares -RequireWorkflow as a string defaulting to '' on the script, Invoke-CiGateParser, and Get-CiGateConclusion
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | documents .PARAMETER RequireWorkflow in the help of the script, Invoke-CiGateParser, and Get-CiGateConclusion
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns pending for an empty check array with -RequireWorkflow CI
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns pending for a null check set with -RequireWorkflow CI
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns pending when only non-CI checks pass
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns success when a CI check passes
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns success when a CI check and a non-CI check both pass
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns failure when a CI check failed
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns failure when a CI check was cancelled
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns failure when a CI check passes and a non-CI check failed
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns pending when a CI check is pending
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns pending when a CI check passes and a non-CI check is pending
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns failure when a CI check is pending and another check failed
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | returns pending when the only CI checks are skipping
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | does not match a lowercase ci workflow name (case-sensitive)
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | treats an element without a workflow property as non-matching without throwing
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | throws an error naming -RequireWorkflow for a whitespace-only value
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | forwards -RequireWorkflow from the script entry point
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | uses the Invoke-CiGateParser default NowProvider when none is injected
ROW: Passed | tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1 | uses the script-level default NowProvider when the script runs without -NowProvider
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS01-RUNSETTINGS-PROFILER-MODE sets UseBreakpoints to false and keeps the coverage keys
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS02-PESTER-CONFIG-USEBREAKPOINTS-FALSE builds a Pester configuration whose UseBreakpoints value is false
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE sets UseBreakpoints to false in the bundled copy
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS03-INSTALLER-PESTER-590 passes Pester version 5.9.0 to the injected install seam
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS05-INSTALLER-PESTER-CEILING-BELOW-6 installs Pester 5.9.0 when only Pester 6.0.0 is present
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS06-TEST-IMPORT-PESTER-MAXIMUM imports Pester with MaximumVersion 5.99.99 through the default EnsureModule seam
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS07-WORKFLOW-LINUX-PESTER-RANGE imports Pester at minimum 5.9.0 and maximum 5.99.99
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS08-TEST-IMPORT-PESTER-RANGE-BOUNDS queries and imports Pester with minimum 5.9.0 and maximum 5.99.99
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS09-TEST-PESTER-6-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 6.0.0 is installed
ROW: Passed | tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1 | RS10-TEST-PESTER-INBOX-ONLY-ACTIONABLE-ERROR throws the install message without importing when only Pester 3.4.0 is installed
ROW: Passed | tests/scripts/workflows/CiWorkflow.Tests.ps1 | lists main, development, and epic/** in the pull_request branch filter
ROW: Passed | tests/scripts/workflows/CiWorkflow.Tests.ps1 | keeps the push branch filter exactly main and development
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | declares exactly the poshqc, poshqc-linux-hooks, poshqc-shard, and poshqc-static jobs
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | keeps the poshqc job as the PowerShell QC merge job on windows-latest after the static and shard jobs
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | runs the poshqc-linux-hooks job on ubuntu-latest under its check name
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | grants the poshqc-linux-hooks job read-only repository contents
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | limits the poshqc-linux-hooks Run.Path to the two hook-suite folders
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | fails the poshqc-linux-hooks job on a failed test and collects no coverage
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | uploads the poshqc-linux-hooks JUnit result under a distinct artifact name
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | runs the poshqc-shard job as a three-shard matrix that does not cancel sibling shards (issue #953)
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | runs Invoke-PoshQCTest with the shard parameters and uploads the shard results even on failure (issue #953)
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | runs the format and analyze gates in the poshqc-static job (issue #953)
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | WF01-POSHQC-MERGE-JOB-RUNS-ALWAYS runs the poshqc merge job on every run outcome so a failed or cancelled shard run fails the check (issue #953, CR-7)
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | WF02-POSHQC-RESULT-GATE-PRECEDES-MERGE fails the poshqc check unless the static and shard jobs succeeded (issue #953, CR-7)
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | WF03-RESULT-GATE-CHECK-DETECTS-MUTATIONS reports a removed, weakened, non-exiting, or moved gate step (issue #953, CR-7)
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | WF04-SHARD-COUNT-FROM-MATRIX passes strategy.job-total as the shard count and lists shard indices 1..N (issue #953, CR-11)
ROW: Passed | tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | WF05-MERGE-LOOPS-DERIVE-SHARD-COUNT reads the shard count from the shard 1 manifest instead of a literal (issue #953, CR-11)
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | declares a pull_request trigger scoped to the mcp-server package and the workflow file
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | guards the publish step on the tag ref and not on the event name
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | asserts tag and manifest version equality in a ref-guarded step ordered before the publish step
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | polls the exact published version after publishing and fails the job on budget expiry
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | ref-guards the post-publish registry poll step
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | resets or explicitly exits after every deliberately-failing nested command in an added pwsh step
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | polls with a bounded backoff schedule whose cumulative sleep budget is at least 600 seconds
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | caps the poll interval at 60 seconds and skips the sleep after the final attempt
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | reports a timeout message that does not claim the tag push failed to publish
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | keeps the exit-code reset, explicit exits, and exact-version operand in the poll step
ROW: Passed | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | runs the registry poll step only after a successful publish step
ROW: Passed | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | declares a schedule trigger
ROW: Passed | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | declares a pull_request trigger scoped to the workflow file and the reconciliation script
ROW: Passed | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | gates the registry sweep off pull-request runs so a branch-head run cannot fail on a pre-existing divergence
ROW: Passed | tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | resets or explicitly exits after every deliberately-failing nested command in a pwsh step
TOTAL: Passed=107 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
