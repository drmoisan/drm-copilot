# P5-T6 QA Loop Step 5: Coverage Comparison (CR-COV), Pass 1

Timestamp: 2026-09-27T10-20
Command: Route C (scratchpad cr-cov.ps1 = CR-COV ending `exit $code`; run by `pwsh -NoProfile -File` via `sh` from the worktree root), immediately after P5-T5, reading artifacts/pester/powershell-coverage.xml; then `git merge-base HEAD origin/main` (printed 849aae609787172240c1ae7c33d10d6dd337d497); `git diff --numstat 849aae609787172240c1ae7c33d10d6dd337d497 -- .claude extensions scripts`; `git status --porcelain --untracked-files=all -- .claude extensions scripts`
EXIT_CODE: 0
Output Summary:
SOURCEFILE-MATCHES: 1
EPIC-SCOPE-LINE-COVERAGE: covered=95 | missed=9 | percent=91.35
EXIT_CODE_COMPUTED: 0
git diff --numstat (production paths): printed nothing (exit 0)
git status --porcelain (production paths): printed nothing (exit 0)

## Comparison for .claude/lib/worktree-resolution/EpicScopeResolution.psm1

| Measure | Value |
|---|---|
| Baseline line coverage (P0-T12, evidence/baseline/coverage-epic-scope-baseline.2026-09-27T10-06.md) | 90.38% (covered=94, missed=10) |
| Post-change line coverage | 91.35% (covered=95, missed=9) |
| Delta | +0.97 percentage points (one additional covered line) |
| Line threshold | 85% |
| Changed production lines | 0 |
| New/changed-code coverage | not applicable (no production line changed) |

Post-change percent (91.35) is greater than or equal to the baseline percent (90.38) and above the 85% threshold. The additional covered line most likely comes from the new seam-sufficiency control row for the gate-4 selector shape, which drives Resolve-EpicScopeCheckpoint through the -WorktreeSelector branch; the specific line was not identified from the report. Branch coverage is not measured for PowerShell and is not recorded.
