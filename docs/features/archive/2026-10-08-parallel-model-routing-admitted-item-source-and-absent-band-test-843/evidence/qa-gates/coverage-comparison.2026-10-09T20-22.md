# Coverage comparison (P2-T18)

Timestamp: 2026-10-09T20-22

BaselineArtifacts:
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/baseline/baseline-pytest-routing-coverage.2026-10-09T20-11.md (P0-T14)
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/baseline/baseline-python-coverage-percentages.2026-10-09T20-11.md (P0-T15)
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/baseline/baseline-jest-coverage.2026-10-09T20-11.md (P0-T25)
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/baseline/baseline-ts-coverage-readout.2026-10-09T20-11.md (P0-T26)

FinalArtifacts:
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/qa-gates/final-pytest-routing-coverage.2026-10-09T20-20.md (P2-T7)
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/qa-gates/final-python-coverage-percentages.2026-10-09T20-20.md (P2-T8)
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/qa-gates/final-python-coverage-thresholds.2026-10-09T20-20.md (P2-T9; EXIT_CODE 0)
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/qa-gates/final-jest-coverage.2026-10-09T20-20.md (P2-T13)
- docs/features/active/2026-10-08-parallel-model-routing-admitted-item-source-and-absent-band-test-843/evidence/qa-gates/final-ts-coverage-readout.2026-10-09T20-20.md (P2-T14)

BaselinePythonLinePercent: 100.0
PostChangePythonLinePercent: 100.0
BaselinePythonBranchPercent: 100.0
PostChangePythonBranchPercent: 100.0
BaselineTsLinePercent: 100
PostChangeTsLinePercent: 100
BaselineTsBranchPercent: 92.59
PostChangeTsBranchPercent: 100

ChangedProductionFiles:
- `git fetch origin main`: completed, exit 0 ("From https://github.com/drmoisan/drm-copilot, branch main -> FETCH_HEAD").
- `git diff --name-only origin/main...HEAD -- scripts extensions/drm-copilot/src`: empty.
- `git status --porcelain -- scripts extensions/drm-copilot/src`: empty.

NewOrChangedCodeCoverage: not applicable - no production line changed

Policy floors: line 85, branch 75. Every post-change percentage meets its floor and is at least its baseline; P2-T9 recorded EXIT_CODE 0.

Verdict: PASS
