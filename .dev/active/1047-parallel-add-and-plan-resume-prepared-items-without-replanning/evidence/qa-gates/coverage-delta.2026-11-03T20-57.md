# Coverage Comparison (remediation cycle 1)

Timestamp: 2026-11-03T20-57
Task: [P6-T13]
Command: comparison of remediation-baseline/pester-coverage-baseline.2026-11-03T19-45.md ([P0-T3]) and remediation-baseline/python-coverage-baseline.2026-11-03T19-32.md ([P0-T5]) with qa-gates/pester-coverage.2026-11-03T20-57.md ([P6-T6], loop pass 3) and qa-gates/python-coverage.2026-11-03T20-40.md ([P6-T12], loop pass 3)
EXIT_CODE: 0
Output Summary: every value is present, and every value is at or above its threshold and its baseline. PowerShell: Invoke-ParallelAdmission.ps1 96.15% to 96.44%; ParallelAdmission.psm1, ParallelAdmissionPrecedence.psm1, and the cohort-barrier helpers stay at 100.00%; new ParallelAdmissionJson.psm1 100.00%; repo-wide 92.59% to 92.61%. Python: line 96.67% to 96.67%, branch 93.64% to 93.64%; no new or changed production Python. Outcome: PASS on coverage. The separate test-outcome deviation of [P0-T3] and [P6-T6] (pre-existing host failures) is not a coverage value and is reported in those artifacts.

## PowerShell (line coverage; Pester measures no branch coverage)

| File | Baseline covered/missed | Baseline % | Post-change covered/missed | Post-change % | Threshold | Result |
| --- | --- | --- | --- | --- | --- | --- |
| .claude/lib/parallel-admission/ParallelAdmission.psm1 | 141/0 | 100.00 | 141/0 | 100.00 | 85 | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 179/0 | 100.00 | 179/0 | 100.00 | 85 | PASS |
| .claude/lib/parallel-admission/ParallelAdmissionJson.psm1 (new) | n/a (code was in Invoke-ParallelAdmission.ps1) | n/a | 55/0 | 100.00 | 85 | PASS |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 250/10 | 96.15 | 217/8 | 96.44 | 85 and baseline | PASS |
| .claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1 | 97/0 | 100.00 | 97/0 | 100.00 | baseline 100.00 | PASS |
| Repo-wide (report-level LINE counter) | 21572/1726 | 92.59 | 21594/1724 | 92.61 | 85 and baseline | PASS |

Invoke-ParallelAdmission.ps1 and ParallelAdmissionJson.psm1 together, the code that was one file at baseline: 272 covered, 8 missed, 97.14%.

### Missed lines in functions changed in Phases 1 to 4

| Function | Change | Missed lines after |
| --- | --- | --- |
| Invoke-ParallelAdmissionGit | M3 stream split; synopsis wording | 2 (the real git call and its result; every suite mocks this seam). Baseline also had 2 missed. |
| Invoke-ParallelAdmissionGitChecked | M3 stderr message rule | 0 |
| Get-ParallelAdmissionUsageError | M1 -Slug and -IssueNum checks | 0 |
| Get-ParallelAdmissionRecordedEdge | M1 non-object record rejection | 0 |
| Invoke-ParallelAdmissionEdgeReuse (new) | M1 reuse-edges subcommand | 0 |
| Invoke-ParallelAdmissionCli | M1 options and dispatch | 0 |
| Invoke-ParallelAdmissionAssess | M2 description wording | 0 |
| Guarded entry body | M1 option pass-through | 4 (runs only under pwsh -File; baseline also had 4 missed) |
| ConvertFrom-ParallelAdmissionJsonElement, ConvertFrom-ParallelAdmissionJson, Write-ParallelAdmissionJsonValue, ConvertTo-ParallelAdmissionJson (moved to ParallelAdmissionJson.psm1) | Phase 1 move | 0 (baseline had 2 missed in the script copy) |

Unchanged functions with missed lines: Read-ParallelAdmissionJsonText (1, the real file read seam), Get-ParallelAdmissionPlannerItem (1).

## Python

| Metric | Baseline | Post-change | Threshold | Result |
| --- | --- | --- | --- | --- |
| Line (JSON totals covered_lines/num_statements) | 96.67% (32257/33367) | 96.67% (32257/33367) | 85% | PASS |
| Branch (JSON totals covered_branches/num_branches) | 93.64% (11720/12516) | 93.64% (11720/12516) | 75% | PASS |

New or changed production Python: none. The one changed .py path, tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py, is under tests/ and is omitted from measurement.

Loop history: loop pass 2 measured Invoke-ParallelAdmission.ps1 at 95.18% (217/11), below the baseline, so the seam was reduced to two executable statements and the loop restarted at [P6-T1]; pass 3 gives the figures above.
