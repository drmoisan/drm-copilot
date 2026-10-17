# coverage-comparison

Timestamp: 2026-10-16T00-36
Command: git diff --name-only origin/main...HEAD -- src scripts
EXIT_CODE: 0
Output Summary: Coverage unchanged or higher on every metric; no production file changed; P2-T6 recorded EXIT_CODE: 0. Verdict PASS.

BaselineArtifacts:

- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-pytest-coverage.2026-10-16T00-18.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-thresholds.2026-10-16T00-18.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md

FinalArtifacts:

- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-pytest-coverage.2026-10-16T00-34.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-coverage-thresholds.2026-10-16T00-34.md
- docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-coverage-percentages.2026-10-16T00-34.md

BaselineTotalCover: 92%
PostChangeTotalCover: 92%
BaselineLinePercent: 93.79748270779
PostChangeLinePercent: 93.79748270779
BaselineBranchPercent: 88.11243718592965
PostChangeBranchPercent: 88.12814070351759

ChangedProductionFiles:

- `git fetch origin main` (exit 0): `From https://github.com/drmoisan/drm-copilot` / ` * branch                main       -> FETCH_HEAD`
- `git diff --name-only origin/main...HEAD -- src scripts` (exit 0): no output
- `git status --porcelain -- src scripts` (exit 0): no output

NewOrChangedCodeCoverage: not applicable - no production line changed

Notes: both changed files are under `tests/`, which `pyproject.toml` `[tool.coverage.run] omit` excludes. The branch total moved from 505 to 504 partial branches (TOTAL row), a difference in production code paths exercised by the suite that this change did not touch; the post-change branch percentage is at least the baseline value.

Verdict: PASS
