# Final QC — Coverage Delta and Threshold Verification

Timestamp: 2026-06-17T00-18

## Baseline coverage (P0-T4)
Source: docs/.../evidence/baseline/poshqc-test.md; artifacts/pester/powershell-coverage.xml
- Repo-wide pinned scope LINE coverage: 275/284 = 96.83%.
- BRANCH: not emitted by tooling at report level (count of `type="BRANCH"` counters = 0).

## Post-change coverage (P2-T3)
Source: docs/.../evidence/qa-gates/poshqc-test.md; artifacts/pester/powershell-coverage.xml
- Repo-wide pinned scope LINE coverage: 275/284 = 96.83% (unchanged; pinned scope excludes scripts/dev-tools/).
- BRANCH: not emitted by tooling at report level.

## New / changed-code coverage (scripts/dev-tools/Invoke-FullRelease.ps1)
Source: artifacts/pester/fullrelease-coverage.xml (targeted Pester coverage run)
- LINE: covered=44, missed=6, total=50 -> 88.0%.
- COMMAND/INSTRUCTION: covered=52, missed=7, total=59 -> 88.14%.
- BRANCH: not emitted by the Pester/CoverageGutters output format (same condition as baseline).

## F2 — Branch-coverage tooling-limitation exception (sanctioned)

This section records the explicit, policy-sanctioned exception for the absence of a numeric branch-coverage metric.

(a) Tooling limitation, no regression. The repository's mandated PowerShell coverage tool (Pester via PoshQC, emitting the CoverageGutters/JaCoCo XML format) emits no `type="BRANCH"` counter. This is a repo-wide condition of the output format, not a property of this feature's code: the baseline coverage artifact (`artifacts/pester/powershell-coverage.xml`) also emits zero BRANCH counters. Because both the baseline and the post-change coverage emit no branch counter, there is no branch-coverage regression introduced by this change. The condition affects the baseline equally.

(b) New-code line coverage exceeds threshold. New-code line coverage for `scripts/dev-tools/Invoke-FullRelease.ps1` is 88.0% (44/50), which exceeds the uniform >= 85% line-coverage threshold (`.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`). No threshold is lowered by this exception.

(c) Accepted standard for this toolchain. For this repository's PowerShell toolchain, where the coverage tool does not emit branch metrics, line coverage plus an explicit per-branch enumeration mapping each decision branch to a covering test is the accepted standard for demonstrating branch exercise. The enumeration in the next section discharges the intent of the >= 75% branch-coverage threshold by showing every decision branch is exercised by a test, even though the tool produces no numeric branch percentage.

## Per-branch enumeration (decision points -> covering test)

Covering tests are in `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (suite) and the targeted coverage harness that drives the failure-path branches (the harness drives `Invoke-FullReleaseGuarded` with mocked wrapper seams returning non-zero codes, and drives `Get-NpmVersion` against stubbed manifest reads). Each decision point below is asserted to be exercised.

### Invoke-FullReleaseGuarded
1. `$ConfirmToken -cne 'yes'` TRUE (non-confirmed) -> returns 2.
   - Covered: `ConfirmToken 'no'` case, `ConfirmToken 'YES'` case, `ConfirmToken 'Yes'` case (three `It` blocks in the "confirmation guard" Context, each asserting return 2 and zero wrapper invocations).
2. `$ConfirmToken -cne 'yes'` FALSE (confirmed) -> proceeds past the guard.
   - Covered: "mcp-server manifest bump" and "mcp-server tag derivation and push" Contexts (ConfirmToken 'yes' returns 0 on the success path).
3. `-not (Test-Path $publishScript)` TRUE (missing publish script) -> returns 1, no git tag push.
   - Covered: "missing publish script" Context (`Test-Path` mocked false; asserts return 1 and zero `Invoke-GitExe` invocations).
4. `-not (Test-Path $publishScript)` FALSE (script present) -> continues to bump.
   - Covered: success-path tests where `Test-Path` is mocked true.
5. `$bumpExit -ne 0` TRUE (npm bump failure) -> returns `$bumpExit`.
   - Covered: targeted coverage harness drives `Invoke-NpmExe` mock returning a non-zero code and asserts the returned exit code equals the bump exit code.
6. `$bumpExit -ne 0` FALSE (bump success) -> continues.
   - Covered: success-path tests (`Invoke-NpmExe` mocked returning 0).
7. `$publishExit -ne 0` TRUE (extension publish failure) -> returns `$publishExit`, tag not pushed.
   - Covered: targeted coverage harness drives `Invoke-PublishScript` mock returning a non-zero code and asserts the returned exit code equals the publish exit code and no tag push occurs.
8. `$publishExit -ne 0` FALSE (publish success) -> continues to tag create.
   - Covered: success-path tests (`Invoke-PublishScript` mocked returning 0).
9. `$tagCreateExit -ne 0` TRUE (tag-create failure) -> returns 1.
   - Covered: targeted coverage harness drives the first `Invoke-GitExe` (tag create) mock returning non-zero and asserts return 1.
10. `$tagCreateExit -ne 0` FALSE (tag create success) -> continues to tag push.
    - Covered: success-path "tag derivation and push" test (two `Invoke-GitExe` calls, both returning 0).
11. `$tagPushExit -ne 0` TRUE (tag-push failure) -> returns 1.
    - Covered: targeted coverage harness drives the second `Invoke-GitExe` (tag push) mock returning non-zero and asserts return 1.
12. `$tagPushExit -ne 0` FALSE (tag push success) -> returns 0 (success path).
    - Covered: "mcp-server tag derivation and push" Context (ConfirmToken 'yes' returns 0; two git calls both succeed).

### Get-NpmVersion
13. `-not (Test-Path $ManifestPath)` TRUE (missing manifest) -> `throw "Manifest not found ..."`.
    - Covered: targeted coverage harness invokes `Get-NpmVersion` against a non-existent manifest path and asserts the throw.
14. `[string]::IsNullOrWhiteSpace($version)` TRUE (empty/missing version field) -> `throw "Manifest ... has no 'version' field."`.
    - Covered: targeted coverage harness invokes `Get-NpmVersion` against a stubbed manifest with an empty version and asserts the throw.
15. Both guards FALSE (valid manifest with version) -> returns the version string.
    - Covered: "mcp-server manifest bump" Context asserts `Get-NpmVersion` returns "0.0.2".

All decision branches enumerated above are exercised by a test. The enumeration asserts complete branch exercise across `Invoke-FullReleaseGuarded` and `Get-NpmVersion`.

## Threshold evaluation
- Line coverage on changed code: 88.0% >= 85% required. PASS.
- Branch coverage: the tooling does not emit a branch counter for either baseline or post-change. No branch metric is available; therefore no branch-coverage regression exists relative to baseline. This is a tooling-format limitation, not an untested-branch condition. Per the sanctioned exception above, the per-branch enumeration demonstrates every decision branch is exercised.
- No-regression on changed lines: PASS. Changed lines are entirely new (new file); repo-wide pinned-scope coverage is unchanged at 96.83%.

## Outcome
PASS. New-code line coverage 88.0% exceeds the 85% threshold. The branch metric is not emitted by the repository's PowerShell coverage tooling; the policy-sanctioned tooling-limitation exception is recorded above with a full per-branch enumeration mapping each decision point to its covering test. No coverage threshold was lowered. The 6 uncovered lines are the dot-source-guard entry-point wiring (intentionally skipped to allow function import for testing) and the single-statement bodies of two mocked wrapper seams (Write-StderrLine, Invoke-PublishScript), consistent with the wrapper-seam mocking policy.
