# rc2 Coverage Comparison (P2-T9)

Timestamp: 2026-10-16T03-08
BaselineArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-coverage-reference.2026-10-16T02-57.md
FinalArtifacts:

- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-pytest-coverage.2026-10-16T03-07.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-coverage-thresholds.2026-10-16T03-07.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-coverage-percentages.2026-10-16T03-07.md

OriginalBaselineArtifact: docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md
BaselineLinePercent: 93.79748270779
BaselineBranchPercent: 88.11243718592965
PostChangeTotalCover: 92%
PostChangeLinePercent: 93.79748270779
PostChangeBranchPercent: 88.11243718592965

FetchCommand: git fetch origin main
FetchExitCode: 0
Command: git diff --name-only origin/main...HEAD -- src scripts
EXIT_CODE: 0
Output Summary: diff listing empty; porcelain listing empty; coverage at the D6 floor.
StatusCommand: git status --porcelain -- src scripts
ChangedProductionFiles:

- diff listing: no output
- porcelain listing: no output

NewOrChangedCodeCoverage: not applicable - no production line changed

Checks (decision D6):

- (a) both production-file listings are empty: yes
- (b) PostChangeLinePercent 93.79748270779 >= 85 and >= 93.79748270779: yes
- (c) PostChangeBranchPercent 88.11243718592965 >= 75 and >= 88.11243718592965: yes
- (d) last P2-T6 artifact recorded EXIT_CODE 0: yes

Verdict: PASS
