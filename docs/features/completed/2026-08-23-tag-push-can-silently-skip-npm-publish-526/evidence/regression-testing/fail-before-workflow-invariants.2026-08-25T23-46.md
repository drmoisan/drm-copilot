# Fail-Before Evidence — publish-mcp-npm.yml Workflow Invariants (P1-T4)

Timestamp: 2026-08-25T23-46

Filename-stamp substitution: the plan fixes the evidence filename suffix at
`.2026-08-24T13-10.md`. This execution ran on 2026-08-25 at 23:46, so the executor
substituted its own `yyyy-MM-ddTHH-mm` stamp `2026-08-25T23-46` into that position,
as the plan's "Evidence filename timestamps" clause directs. The path prefix and base
name `fail-before-workflow-invariants` are unchanged.

Command: `mcp__drm-copilot__run_poshqc_test` (workspace_root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`, no
`scan_folders` argument, so the scan set resolved from `config/poshqc-scan.json`;
coverage enabled by `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)

EXIT_CODE: 3

Note on the absent expectation field: this artifact deliberately omits the optional
`ExpectedExitCode` field, per the plan's "Fail-before exit-code declaration" clause.
That clause is confirmed by observation in this phase: the P1-T2 run of the same
command exited 1 with one failing test, and this run exited 3 with three failing
tests, so the runner's exit code tracks the failure count rather than being a fixed
value. A declared `ExpectedExitCode: 1` would therefore have normalized this correct
fail-before run to `fail`. The assertion recorded here is instead: the observed exit
code is non-zero (observed value 3), and both named tests are reported as failing.

Output Summary:

- Result: non-zero exit code observed (3). The run is deliberately red; this is the
  expected outcome of an `[expect-fail]` task.
- Totals parsed from `artifacts/pester/pester-junit.xml`: 3595 tests, 3 failures,
  9 skipped, 3583 passed, 111.699 s.
- Baseline for comparison (Phase 0, `evidence/baseline/powershell-pester-baseline`):
  3592 tests, 3583 passed, 0 failed, 9 skipped. The delta is exactly the three tests
  added by P1-T1 and P1-T3: total tests 3592 -> 3595, failures 0 -> 3, passed
  unchanged at 3583. No pre-existing test regressed.
- The new suite `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` is discovered
  by the runner, confirming the plan's "Test-location note": `tests/scripts` is one of
  the roots declared in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

Failing tests from `tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1` (both named
by this task):

1. `declares a pull_request trigger scoped to the mcp-server package and the workflow file`
   - Full node name:
     `publish-mcp-npm.yml workflow invariants.declares a pull_request trigger scoped to the mcp-server package and the workflow file`
   - Failure message, quoted verbatim from the JUnit `failure` element:
     `Expected regular expression '(?m)^\s{2}pull_request:' to match '  push:`
     `    tags:`
     `      - "mcp-server-v*"`
     `  workflow_dispatch:`
     `', but it did not match.`
   - Defect demonstrated: the trigger block of `.github/workflows/publish-mcp-npm.yml`
     declares only `push` (tags `mcp-server-v*`) and `workflow_dispatch`. There is no
     `pull_request` trigger, so the workflow has no trigger able to produce a green
     branch-head run, which is what the `modified-workflow-needs-green-run` policy rule
     requires before a diff to the file can merge.

2. `guards the publish step on the tag ref and not on the event name`
   - Full node name:
     `publish-mcp-npm.yml workflow invariants.guards the publish step on the tag ref and not on the event name`
   - Failure message, quoted verbatim from the JUnit `failure` element:
     `Expected 0, but got 1.`
   - Failing assertion: `$eventNameGuards.Count | Should -Be 0`
   - Defect demonstrated: line 61 of `.github/workflows/publish-mcp-npm.yml` guards the
     publish step with `if: github.event_name == 'push'`. One event-name guard is present
     where zero are permitted, and the required ref guard
     `startsWith(github.ref, 'refs/tags/mcp-server-v')` is absent.

Also failing in this run, and expected: the P1-T1 test
`pushes the mcp-server tag before the extension tag` in
`tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`, message
`Expected the actual value to be less than 0, but got 1.`, recorded separately in
`fail-before-push-order.2026-08-25T23-46.md`. Those three are the only failures in the run.

- No production file was modified to produce this evidence. Both failures are against
  the unmodified `.github/workflows/publish-mcp-npm.yml`.
