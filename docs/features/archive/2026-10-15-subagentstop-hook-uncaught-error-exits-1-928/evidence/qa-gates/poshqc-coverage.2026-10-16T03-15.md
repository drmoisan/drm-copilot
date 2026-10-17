# Final PoshQC Coverage (issue #928, P6-T7, loop pass 1)

Timestamp: 2026-10-16T03-15
Command: poetry run python SCRATCH/928/coverage_rows.py artifacts/pester/powershell-coverage.xml <eleven paths of P0-T11>; rerun with the ten changed paths for AGGREGATE; grep -n -F "validator error:" over the eight AC1 validators
EXIT_CODE: 0
COVERAGE_SOURCE: ci-pr (CI-dependent)

Branch taken: six of the ten changed files show `MATCHED 0` in the local report (validate-executor-output, validate-pr-author-output, validate-prd-feature-output, validate-required-artifact-output, validate-task-researcher-output, subagentstop-envelope), and the baseline (`FEATURE/evidence/baseline/poshqc-coverage.2026-10-16T01-32.md`) used `COVERAGE_SOURCE: ci-main 38730332356`. Under the plan's explicitly authorized branch the numeric check for all ten files is performed at S9 on the `poshqc-test-results` artifact of the `poshqc / PowerShell QC` job on the PR head, and AC14's coverage clause is checked off there with AC15. The local values below are recorded for reference only.

Output Summary:
- MTIME_UTC 2026-10-16T03-13 (not earlier than the P6-T6 Timestamp 2026-10-16T03-00 of qa-gates/poshqc-test.2026-10-16T03-00.md)
- REPORT LINE missed 5896 covered 6387
- FILE .claude/hooks/validate-discovery-artifact-gate.ps1 MATCHED 1 covered 64 total 64 pct 100.00 missed_lines (none) | baseline 100.00 | delta +0.00 | catch line 253 not missed
- FILE .claude/hooks/validate-executor-output.ps1 MATCHED 0 | baseline 98.32 | post-change pending CI | catch line 322
- FILE .claude/hooks/validate-orchestrator-output.ps1 MATCHED 1 covered 110 total 111 pct 99.10 missed_lines 235 | baseline 99.09 | delta +0.01 | catch line 344 not missed
- FILE .claude/hooks/validate-planner-output.ps1 MATCHED 1 covered 200 total 201 pct 99.50 missed_lines 158 | baseline 99.50 | delta +0.00 | catch line 440 not missed
- FILE .claude/hooks/validate-pr-author-output.ps1 MATCHED 0 | baseline 100.00 | post-change pending CI | catch line 129
- FILE .claude/hooks/validate-prd-feature-output.ps1 MATCHED 0 | baseline 100.00 | post-change pending CI | catch line 118
- FILE .claude/hooks/validate-required-artifact-output.ps1 MATCHED 0 | baseline 98.36 | post-change pending CI | catch line 199
- FILE .claude/hooks/validate-task-researcher-output.ps1 MATCHED 0 | baseline 98.06 | post-change pending CI | catch line 290
- FILE .claude/hooks/validate-feature-review-coverage.ps1 MATCHED 0 | baseline 98.82 | unchanged reference, not gated
- FILE .claude/hooks/subagentstop-envelope.ps1 MATCHED 0 | baseline 100.00 | post-change pending CI
- FILE .claude/hooks/enforce-epic-wave-barrier.ps1 MATCHED 1 covered 95 total 96 pct 98.96 missed_lines 380 | baseline 98.96 | delta +0.00
- AGGREGATE (ten changed files, local report; only the four matched files contribute) covered 469 total 472 pct 99.36 | baseline aggregate 99.12 (ci-main) | full ten-file aggregate pending CI
- Every locally matched changed file is at least 85.00 and not below its baseline; no locally matched catch line is in missed_lines.
