# Final QC — Coverage Delta and Threshold Verification

Timestamp: 2026-06-16T20-36

## Baseline coverage (P0-T4)
Source: docs/.../evidence/baseline/poshqc-test.md; artifacts/pester/powershell-coverage.xml
- Repo-wide pinned scope LINE coverage: 275/284 = 96.83%.
- BRANCH: not emitted by tooling at report level.

## Post-change coverage (P2-T3)
Source: docs/.../evidence/qa-gates/poshqc-test.md; artifacts/pester/powershell-coverage.xml
- Repo-wide pinned scope LINE coverage: 275/284 = 96.83% (unchanged; pinned scope excludes scripts/dev-tools/).
- BRANCH: not emitted by tooling at report level.

## New / changed-code coverage (scripts/dev-tools/Invoke-FullRelease.ps1)
Source: artifacts/pester/fullrelease-coverage.xml (targeted Pester coverage run)
- LINE: covered=44, missed=6, total=50 -> 88.0%.
- COMMAND/INSTRUCTION: covered=52, missed=7, total=59 -> 88.14%.
- BRANCH: not emitted by the Pester/CoverageGutters output format (same condition as baseline).

## Threshold evaluation
- Line coverage on changed code: 88.0% >= 85% required. PASS.
- Branch coverage: the tooling does not emit a branch counter for either baseline or post-change. No branch metric is available; therefore no branch-coverage regression exists relative to baseline. This is a tooling-format limitation, not an untested-branch condition: the 7 unit tests in Invoke-FullRelease.Tests.ps1 plus the targeted harness exercise all decision branches of Invoke-FullReleaseGuarded (non-yes guard for no/YES/Yes, missing publish script, npm-bump failure, publish failure, tag-create failure, tag-push failure, and the success path) and both throw branches of Get-NpmVersion.
- No-regression on changed lines: PASS. Changed lines are entirely new (new file); repo-wide pinned-scope coverage is unchanged at 96.83%.

## Outcome
PASS. New-code line coverage 88.0% exceeds the 85% threshold. The 6 uncovered lines are the dot-source-guard entry-point wiring (intentionally skipped to allow function import for testing) and the single-statement bodies of two mocked wrapper seams (Write-StderrLine, Invoke-PublishScript), consistent with the wrapper-seam mocking policy.
