# Code Review - Issue #887 (also resolves #888)

- Branch: bug/host-tools-manifest-and-bootstrap-behavior-887, head 59fa06a04
- Scope: full diff `origin/main...HEAD` (production PowerShell, one JSON manifest, test suites)
- Timestamp: 2026-10-12T15-00

## Summary

The change is small, targeted, and consistent with the issue's implementation intent. No blocking defects were found.

## Review by file

### scripts/host-tools.manifest.json (new)
- Seven top-level keys present; winget entries, module minimums, empty `projectRepositories`, and pinned `minimumVersions` match the issue. Values are plain dotted numbers that cast to `[version]`.
- Non-blocking: minimums are pinned to the development machine's versions (python 3.13.12, node 24.14.0). Hosts with older patches fail `verify-host.ps1`. The risk is documented in issue.md and is to be stated in the PR description.

### scripts/dev-tools/HostTooling.psm1
- `Invoke-HostNativeCommand` gains a `Stream` parameter set with `DefaultParameterSetName = 'Capture'`; capture and `-MergeErrorStream` behavior and return shape are unchanged. Correct.
- `LASTEXITCODE` is reset in the global scope before every invocation, which fixes the stale-exit-code defect. The global write is intentional because the exit code is a global variable; tests restore it in `AfterEach`.
- Non-blocking: `$output = @()` then `@($output)` keeps the return shape uniform. No issue.
- `Get-HostToolsManifestPath` remains unnormalized as specified.

### scripts/dev-tools/HostBootstrapWorkspace.psm1
- All six call sites pass `-StreamToHost` and no longer re-emit captured output; throw messages unchanged.
- `Invoke-HostBootstrapNpm` uses `$null =` and, as before, does not check the exit code. This preserves existing behavior; a test (`AC11-NPM-NONZERO-NO-THROW`) pins it. Non-blocking observation: a failing `npm` step is silently non-fatal. This is pre-existing and outside the issue scope.
- `[AllowEmptyCollection()]` on `Resolve-ProjectRepoRoot -Projects` is the correct binding fix for an empty manifest list.

### scripts/dev-tools/HostBootstrap.psm1
- `@()` wrapping prevents unrolling to `$null`. Pip call site streams. Non-Windows message replaced with a reference to the dev container; no reference to a nonexistent bash script remains.

### scripts/dev-tools/publish-sideloaded-extension.ps1
- The forwarding loop is compact and data-driven. Inherited `$WhatIfPreference`, `$ConfirmPreference`, `$VerbosePreference`, and `$DebugPreference` are mapped; bound parameters take precedence.
- The cast of `$ConfirmPreference` to `[System.Management.Automation.ConfirmImpact]` correctly avoids an alphabetical string comparison (this was found and repaired during the pass-after-fix run, per evidence).
- `-ErrorAction` is not forwarded, as specified (OD-1), and the rationale is recorded.
- Non-blocking: `$VerbosePreference -eq 'Continue'` ignores other non-default values such as `Inquire`. The issue specifies `Continue` only.

### Tests
- New and extended tests use `ParameterFilter`, scenario-ID names, and mocks; no temporary files, sleeps, or wall-clock reads.
- Expect-fail evidence shows each new behavioral test failing before the fix; pass-after-fix evidence shows 142 tests, 0 failures.
- The new manifest suite exercises the verification functions against the committed manifest with mocked host seams, which guards against future manifest/schema drift.
- Non-blocking: `Should -Invoke -Times 1` (not `-Exactly`) is used for the Out-Host stream assertion, consistent with the documented uncertainty about per-item Pester call counts.

## Findings

| ID | Severity | Description |
|---|---|---|
| CR-1 | non-blocking | Pinned minimum versions are machine-specific; document in the PR description. |
| CR-2 | non-blocking | `Invoke-HostBootstrapNpm` ignores exit codes (pre-existing, pinned by test). |
| CR-3 | non-blocking | Verbose/Debug inheritance recognizes only `Continue`. Matches the issue. |

BLOCKING findings: 0.
