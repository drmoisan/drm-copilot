# Coverage comparison (P2-T9)

Timestamp: 2026-10-01T20-58

BaselineArtifacts:
- docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/baseline/baseline-pytest-coverage.2026-10-01T20-49.md
- docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/baseline/baseline-coverage-thresholds.2026-10-01T20-49.md
- docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/baseline/baseline-coverage-percentages.2026-10-01T20-49.md

FinalArtifacts:
- docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-pytest-coverage.2026-10-01T20-57.md
- docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-coverage-thresholds.2026-10-01T20-57.md
- docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-coverage-percentages.2026-10-01T20-57.md

BaselineTotalCover: 92%
PostChangeTotalCover: 92%
BaselineLinePercent: 93.52893424562217
PostChangeLinePercent: 93.52893424562217
BaselineBranchPercent: 86.76187419768935
PostChangeBranchPercent: 86.76187419768935

ChangedProductionFiles:
- Command: git fetch origin main
  Output: `From https://github.com/drmoisan/drm-copilot` / ` * branch              main       -> FETCH_HEAD` (origin/main resolves to 12fd3c26)
- Command: git diff --name-only origin/main...HEAD -- src scripts
  Output: no output
- Command: git status --porcelain -- src scripts
  Output: no output

NewOrChangedCodeCoverage: not applicable - no production line changed

P2-T6 EXIT_CODE: 0

Verdict: PASS (both production-file listings are empty; line 93.53 >= 85 and >= baseline 93.53; branch 86.76 >= 75 and >= baseline 86.76; P2-T6 exit 0)
