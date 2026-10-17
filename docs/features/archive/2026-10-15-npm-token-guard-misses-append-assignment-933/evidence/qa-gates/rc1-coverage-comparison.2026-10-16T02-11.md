# rc1 Coverage Comparison (P2-T9, plan revision 1.1, decision D6)

Timestamp: 2026-10-16T02-11
Command: git diff --name-only origin/main...HEAD -- src scripts
EXIT_CODE: 0
Output Summary: Verdict PASS under decision D6; PostChangeLinePercent 93.79748270779 >= OriginalBaselineLinePercent 93.79748270779; PostChangeBranchPercent 88.11243718592965 >= OriginalBaselineBranchPercent 88.11243718592965; no production file changed; P2-T6 EXIT_CODE 0.

Supersedes: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T01-52.md (halted run, left unedited)

BaselineArtifacts:
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-pytest-coverage.2026-10-16T01-36.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-coverage-thresholds.2026-10-16T01-36.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc1-baseline-coverage-percentages.2026-10-16T01-36.md

FinalArtifacts:
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-pytest-coverage.2026-10-16T01-47.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-coverage-thresholds.2026-10-16T01-47.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc1-final-coverage-percentages.2026-10-16T01-47.md

PriorCycleArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/coverage-comparison.2026-10-16T00-36.md

BaselineTotalCover: 92%
PostChangeTotalCover: 92%
BaselineLinePercent: 93.79748270779
PostChangeLinePercent: 93.79748270779
BaselineBranchPercent: 88.12814070351759
PostChangeBranchPercent: 88.11243718592965
PriorCycleLinePercent: 93.79748270779
PriorCycleBranchPercent: 88.12814070351759

BaselineLinePercent and BaselineBranchPercent are the P0-T16 cycle values and are informational under D6. PostChangeLinePercent and PostChangeBranchPercent are copied from the lexicographically greatest rc1-final-coverage-percentages.*.md in evidence/qa-gates/ (rc1-final-coverage-percentages.2026-10-16T01-47.md). P2-T5 through P2-T7 were not rerun.

ChangedProductionFiles:
- git fetch origin main -> exit 0 (branch main -> FETCH_HEAD)
- git diff --name-only origin/main...HEAD -- src scripts -> exit 0, no output
- git status --porcelain -- src scripts -> exit 0, no output

NewOrChangedCodeCoverage: not applicable - no production line changed

OriginalBaselineArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md
OriginalBaselineLinePercent: 93.79748270779
OriginalBaselineBranchPercent: 88.11243718592965

SourceIdenticalRunsEvidence:
- evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md 88.11243718592965 (before any change on the item)
- evidence/qa-gates/final-coverage-percentages.2026-10-16T00-34.md 88.12814070351759
- evidence/remediation-baseline/rc1-baseline-coverage-percentages.2026-10-16T01-36.md 88.12814070351759 (before any cycle edit)
- evidence/qa-gates/rc1-final-coverage-percentages.2026-10-16T01-47.md 88.11243718592965

CycleBaselineNote: the cycle baseline BaselineBranchPercent 88.12814070351759 was measured on identical production source and differs from PostChangeBranchPercent by one partial branch (TOTAL partial branches 504 vs 505); per decision D6 it is recorded, not used as a floor

Checks (decision D6):
- (a) Both production-file listings empty: yes
- (b) PostChangeLinePercent 93.79748270779 >= 85: yes; >= OriginalBaselineLinePercent 93.79748270779: yes
- (c) PostChangeBranchPercent 88.11243718592965 >= 75: yes; >= OriginalBaselineBranchPercent 88.11243718592965: yes
- (d) P2-T6 artifact rc1-final-coverage-thresholds.2026-10-16T01-47.md recorded EXIT_CODE: 0: yes
- SourceIdenticalRunsEvidence names all four runs with the quoted branch values: yes
- CycleBaselineNote present: yes

Verdict: PASS
