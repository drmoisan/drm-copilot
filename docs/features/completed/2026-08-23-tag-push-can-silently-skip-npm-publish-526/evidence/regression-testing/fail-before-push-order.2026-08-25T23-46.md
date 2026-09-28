# Fail-Before Evidence — Push Order (P1-T2)

Timestamp: 2026-08-25T23-46

Filename-stamp substitution: the plan fixes the evidence filename suffix at
`.2026-08-24T13-10.md`. This execution ran on 2026-08-25 at 23:46, so the executor
substituted its own `yyyy-MM-ddTHH-mm` stamp `2026-08-25T23-46` into that position,
as the plan's "Evidence filename timestamps" clause directs. The path prefix and base
name `fail-before-push-order` are unchanged.

Command: `mcp__drm-copilot__run_poshqc_test` (workspace_root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3c3e2a8cfa4dbcd5`, no
`scan_folders` argument, so the scan set resolved from `config/poshqc-scan.json`;
coverage enabled by `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`)

EXIT_CODE: 1

Note on the absent expectation field: this artifact deliberately omits the optional
`ExpectedExitCode` field, per the plan's "Fail-before exit-code declaration" clause.
The exact exit code the Pester runner returns on test failure is not confirmed anywhere
in this repository, so declaring a specific value would normalize a correct fail-before
run to `fail` whenever the runner exits with a different non-zero code. The assertion
recorded here is instead: the observed exit code is non-zero (observed value 1), and
the named test is reported as failing.

Output Summary:

- Result: non-zero exit code observed (1). The run is deliberately red; this is the
  expected outcome of an `[expect-fail]` task.
- Totals parsed from `artifacts/pester/pester-junit.xml`: 3593 tests, 1 failure,
  9 skipped, 3583 passed, 112.521 s.
- Baseline for comparison (Phase 0, `evidence/baseline/powershell-pester-baseline`):
  3592 tests, 3583 passed, 0 failed, 9 skipped. The delta is exactly the one test
  added by P1-T1: total tests 3592 -> 3593, failures 0 -> 1, passed unchanged at 3583.
  No pre-existing test regressed.
- Failing test (exactly one): `pushes the mcp-server tag before the extension tag`
  - Full node name:
    `Invoke-ReleaseTagPush.ps1 - Invoke-ReleaseTagPushGuarded.tag push ordering.pushes the mcp-server tag before the extension tag`
  - File: `tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1`
  - Failure message, quoted verbatim from the JUnit `failure` element:
    `Expected the actual value to be less than 0, but got 1.`
  - Failing assertion: `$mcpPushIndex | Should -BeLessThan $extensionPushIndex`
- Defect the failure demonstrates: the loop in `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`
  (the `foreach ($entry in @(...))` block) orders the extension tag entry before the
  mcp-server tag entry, so the captured push argument vectors place
  `push origin v0.0.3` at index 0 and `push origin mcp-server-v0.0.2` at index 1. The
  extension consumer tag is therefore pushed before the mcp-server dependency tag it
  pins, which is the ordering that allowed the 1.0.25 outcome.
- No production file was modified to produce this evidence. The failure is against the
  unmodified production surface.
