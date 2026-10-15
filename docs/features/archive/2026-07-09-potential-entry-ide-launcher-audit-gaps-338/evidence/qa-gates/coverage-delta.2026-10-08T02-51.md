Timestamp: 2026-10-08T02-51
Command: derived from evidence/qa-gates/python-pytest-coverage.2026-10-08T02-49.md, evidence/qa-gates/python-coverage-values.2026-10-08T02-49.md and evidence/qa-gates/ts-jest-coverage.2026-10-08T02-50.md (no new command executed)
EXIT_CODE: 0
Output Summary: Source exit codes recorded by P2-T4, P2-T5 and P2-T9 are all 0. Baselines come from evidence/baseline/python-coverage-values.2026-10-08T02-41.md (P0-T11) and evidence/baseline/ts-jest-coverage.2026-10-08T02-43.md (P0-T15). Floors: line >= 85, branch >= 75.

| File | Baseline line % | Baseline branch % | Post-change line % | Post-change branch % | New-code figure | Post-change source |
|---|---|---|---|---|---|---|
| scripts/dev_tools/new_potential_bug_entry.py | 91.89 | 76.67 | 91.89 | 76.67 | no changed executable lines | evidence/qa-gates/python-coverage-values.2026-10-08T02-49.md |
| scripts/dev_tools/new_active_feature_folder_io.py | 97.27 | 88.0 | 97.27 | 88.0 | no changed executable lines | evidence/qa-gates/python-coverage-values.2026-10-08T02-49.md |
| extensions/drm-copilot/src/lib/new-potential-bug-entry.ts | 95.87 | 82.97 | 97.83 | 87.27 | no changed executable lines | evidence/qa-gates/ts-jest-coverage.2026-10-08T02-50.md |
| extensions/drm-copilot/src/lib/new-active-feature-folder/io-launcher.ts | 97.87 | 84.61 | 100 | 93.75 | no changed executable lines | evidence/qa-gates/ts-jest-coverage.2026-10-08T02-50.md |

Result: each post-change line percent is at least 85 and each post-change branch percent is at least 75; none is lower than its baseline. The production changes are two docstring lines and touch no executable statement, so the 90% new-code target is informational.
