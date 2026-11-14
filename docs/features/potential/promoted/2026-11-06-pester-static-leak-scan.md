# pester-static-leak-scan (Issue #1096)

- Date captured: 2026-11-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pester-static-leak-scan/ (Issue #1096)

- Issue: #1096
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1096
- Last Updated: 2026-11-07
## Problem / Why

Split from issue #1094 by owner decision on 2026-11-07. #1094 keeps the parallel-only test gate change, so that it can merge first. This item carries the static leak scan and the test fixes.

With parallel-only gates, the repository no longer runs the single-process and shuffled runs that detected state leaking between test files. Test independence remains policy under `.claude/rules/general-unit-test.md`. Files in the same shard still share a process, so a leak can surface later as a failure when shard contents change. Detection needs to move to a scan that adds no test run.

A text search of the 509 Pester files in `tests/scripts` gives the candidate scale. These are candidates, not confirmed leaks: 30 files write `$env:`, 45 write `$global:`, 2 define global functions, 16 change location, and 2 change the process directory.

Two tests in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1` fail in single-process runs, including at merge base `e3e4aa551`. That file is one of the two that change the process directory. `tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` fails when the process does not start at the repository root.

## Proposed Behavior

- Add a PowerShell scan to PoshQC that parses Pester test files and reports state changes with no matching restore in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
- Detect at least writes to `$env:`, writes to `$global:`, global function definitions, `Set-Location` and `Push-Location`, and changes to the process directory.
- Findings name the file, the line, and the kind of state changed.
- Run the scan in a fast quality stage and in CI, so it adds no test run.
- Confirmed findings are fixed on both sides, in the leaking suite and in any suite that relies on the leaked state. False positives go in a committed allowlist in which every entry states a reason.
- Fix the three tests named above so they no longer depend on the process directory.

Reuse the research, spec, and Phases 1 to 4 of the plan in the #1094 feature folder, `docs/features/active/2026-11-06-parallel-only-test-gates-and-leak-scan-1094/`.

Out of scope: a runtime check that compares session state before and after each test file, which remains a later step, and Pester `Run.Parallel`, which is experimental.

## Acceptance Criteria (early draft)

- [ ] The scan detects each listed state-change kind, and does not report a change that is restored in the same scope or in `AfterEach`, `AfterAll`, or `finally`.
- [ ] The scan runs in CI and fails on an unallowlisted finding.
- [ ] Every finding in `tests/scripts` is fixed or allowlisted with a reason.
- [ ] The two `Enter-DrmCopilotShell.Tests.ps1` tests and the `PoshQC.TestingInvokeConfigPaths.Tests.ps1` test no longer depend on the process directory.
- [ ] `## Test Isolation Checks` in the `execution-environment` skill names the scan, and all mirrored copies match.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.

## Constraints & Risks

- The scan is static, so it can miss state changed indirectly through a helper.
- A static scan produces false positives. The allowlist must require a reason so that it does not become a blanket suppression.
- New tooling is PowerShell, not Python.
- Tests must create no temporary files, and the scan must take file content through a seam so that it can be tested in memory.
- This item starts after #1094 merges. It uses the parallel-only gates and must not edit Epic #1019 feature folders.

## Test Conditions to Consider

- [ ] Unit coverage for each detected state-change kind, positive and negative, using in-memory script text
- [ ] Restore recognised in `AfterEach`, `AfterAll`, `finally`, and the same scope; restore absent; restore of a different variable
- [ ] Allowlist entries: valid, missing reason, and stale
- [ ] CI step failure on an unallowlisted finding

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/pester-static-leak-scan/` folder from the template
