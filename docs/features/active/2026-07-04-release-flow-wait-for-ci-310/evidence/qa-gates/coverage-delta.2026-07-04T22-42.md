# Coverage Delta (Issue #310)

Timestamp: 2026-07-04T22-42

Source artifacts:
- Baseline: `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/baseline/test-baseline.2026-07-04T22-20.md`
- Final: `docs/features/active/2026-07-04-release-flow-wait-for-ci-310/evidence/qa-gates/test-final.2026-07-04T22-40.md`

| Metric | Baseline | Post-change | Threshold | Result |
|---|---|---|---|---|
| Line coverage (`scripts/dev-tools/Invoke-FullReleaseFlow.ps1`) | 93.75% (90/96) | 94.26% (115/122) | >= 85% | PASS (improved, no regression) |
| Branch coverage | Not emitted by tool (no BRANCH counter type in this repo's JaCoCo/CoverageGutters output) | Not emitted by tool (same) | >= 75% | Not numerically measurable by this PowerShell tool; consistent, pre-existing, repo-wide tooling limitation (see issue #298 precedent) rather than a regression introduced by this change |

Output Summary: Line coverage increased from 93.75% to 94.26%, both above the 85% threshold, confirming no
regression. The added lines (Wait-ForPullRequestChecks: 26 lines, all covered by the six new
Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 tests; the single-line Invoke-Sleep wrapper body, uncovered by
design because it is always mocked in tests per the wrapper-seam mocking convention) do not reduce coverage
on any changed line; the only uncovered changed line (`Invoke-Sleep`'s `Start-Sleep` call) mirrors the
identical, pre-existing uncovered pattern of the other three external-call wrapper seams
(`Invoke-GitExe`/`Invoke-GhExe`/`Invoke-ChildPowerShellScript`) already present in the baseline. No
production line touched by this change regressed from covered to uncovered.
