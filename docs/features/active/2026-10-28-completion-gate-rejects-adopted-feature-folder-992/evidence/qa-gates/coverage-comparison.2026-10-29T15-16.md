# Coverage Comparison per Language (P6-T10, AC-17)

Timestamp: 2026-10-29T15-16
Command: poetry run python SCRATCH/issue-992-covsum.py <py json>; poetry run python SCRATCH/issue-992-jestsum.py coverage/coverage-summary.json <files>; poetry run python SCRATCH/issue-992-pscov.py <coverage xml> <root> <files>; poetry run python SCRATCH/issue-992-changedlines.py <final coverage xml> <root> <files> (changed lines from git diff -U0 HEAD; all executable lines for new files)
EXIT_CODE: 0
Output Summary: No regression on any changed or existing measured file; every new module meets the thresholds (line >= 85% in all languages; branch >= 75% for Python and TypeScript). Python and TypeScript files are at 100% line and branch; PowerShell new modules at 100% and 92.59% line; repo-wide PowerShell line coverage 92.91% -> 92.93%.

## Python (JSON report; baseline `evidence/baseline/python-pytest.2026-10-29T14-16.md`, final `evidence/qa-gates/python-pytest.2026-10-29T15-04.md`)

| File | Baseline line / branch | Post-change line / branch | Status |
| --- | --- | --- | --- |
| `scripts/dev_tools/_orchestrator_state_issue_adoption.py` (changed) | 100.00% (116/116) / 100.00% (48/48) | 100.00% (118/118) / 100.00% (48/48) | no regression; changed lines covered |
| `scripts/dev_tools/_orchestrator_state_feature_folder_record.py` (new) | n/a | 100.00% (42/42) / 100.00% (14/14) | meets 85% / 75% |

## TypeScript (Jest coverage-summary.json; baseline `evidence/baseline/ts-jest.2026-10-29T14-18.md`, final `evidence/qa-gates/ts-jest.2026-10-29T14-54.md`)

| File | Baseline lines / branches | Post-change lines / branches | Status |
| --- | --- | --- | --- |
| `src/lib/validate/orchestrator-state-issue-adoption.ts` (changed) | 100% (324/324) / 100% (63/63) | 100% (332/332) / 100% (66/66) | no regression; changed lines covered |
| `src/lib/validate/orchestrator-state-feature-folder-record.ts` (new) | n/a | 100% (136/136) / 100% (22/22) | meets 85% / 75%; per-file `coverageThreshold` entry enforced |
| Extension totals | lines 97.41%, branches 92.65% | lines 97.41%, branches 92.67% | no regression |

## PowerShell (JaCoCo LINE; baseline `evidence/baseline/ps-pester.2026-10-29T14-35.md`, final `evidence/qa-gates/ps-pester.2026-10-29T15-15.md`; no branch gate for Pester)

| File | Baseline LINE | Post-change LINE | Changed executable lines covered | Status |
| --- | --- | --- | --- | --- |
| Repo-wide | 92.91% (18275/19670) | 92.93% (18349/19746) | n/a | no regression |
| `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` (changed) | 100.00% (116/116) | 100.00% (119/119) | 4/4 | no regression |
| `.claude/hooks/validate-orchestrator-output.ps1` (changed) | 99.10% (110/111) | 99.16% (118/119) | 8/8 | no regression |
| `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1` (new) | n/a | 100.00% (38/38) | 38/38 | meets 85% |
| `.claude/hooks/validate-orchestrator-output-feature-folder.ps1` (new) | n/a | 92.59% (25/27) | 25/27 | meets 85%; the two unexecuted lines are the default real-git invoker and its call |

No production path was added to a coverage exclusion: `extensions/drm-copilot/jest.config.cjs` gained only a `coverageThreshold` entry, and `config/poshqc-coverage.json` (roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`) already covers the new PowerShell files.
