# rc1 Coverage Comparison (P2-T9)

Timestamp: 2026-10-16T01-52
Command: git diff --name-only origin/main...HEAD -- src scripts
EXIT_CODE: 0
Output Summary: Verdict REMEDIATION-REQUIRED; PostChangeBranchPercent 88.11243718592965 is below BaselineBranchPercent and PriorCycleBranchPercent 88.12814070351759.

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

ChangedProductionFiles:
- git fetch origin main -> exit 0 (branch main -> FETCH_HEAD)
- git diff --name-only origin/main...HEAD -- src scripts -> no output
- git status --porcelain -- src scripts -> no output

NewOrChangedCodeCoverage: not applicable - no production line changed

TOTAL rows: baseline `17638 1094 6368 504 92%`; post-change `17638 1094 6368 505 92%`. Statements, missed statements, and branch count are identical; one additional branch is reported partial after the change.

Reproduction check (diagnostic only, not a gate): a second full-suite coverage run with JSON written to SCRATCH reported totals num_partial_branches 505 and covered_branches 5611, identical to the P2-T5 report, so the post-change value is reproducible. The per-file location of the additional partial branch could not be determined, because the baseline per-file report (artifacts/python/coverage.json at P0-T14) was overwritten by the P2-T5 run as the plan specifies.

Checks:
- Both production-file listings empty: yes
- PostChangeLinePercent >= 85, >= BaselineLinePercent, >= 93.79748270779: yes
- PostChangeBranchPercent >= 75: yes
- PostChangeBranchPercent >= BaselineBranchPercent (88.12814070351759): no
- PostChangeBranchPercent >= 88.12814070351759 (prior cycle): no
- P2-T6 recorded EXIT_CODE 0: yes

Verdict: REMEDIATION-REQUIRED
