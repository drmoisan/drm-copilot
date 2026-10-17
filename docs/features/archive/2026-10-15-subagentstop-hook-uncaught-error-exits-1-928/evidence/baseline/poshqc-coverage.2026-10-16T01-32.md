# Baseline PoshQC Coverage (issue #928)

Timestamp: 2026-10-16T01-32
Command: poetry run python SCRATCH/928/coverage_rows.py SCRATCH/928/ci-main/powershell-coverage.xml <eleven paths>; rerun with the ten changed paths for AGGREGATE
EXIT_CODE: 0
COVERAGE_SOURCE: ci-main 38730332356

Fallback record: the local run `poetry run python SCRATCH/928/coverage_rows.py artifacts/pester/powershell-coverage.xml <eleven paths>` (local report MTIME_UTC 2026-10-16T01-27, not earlier than the P0-T10 Timestamp 2026-10-16T01-10) showed `MATCHED 0` for six changed files (validate-executor-output, validate-pr-author-output, validate-prd-feature-output, validate-required-artifact-output, validate-task-researcher-output, subagentstop-envelope) and for the reference file validate-feature-review-coverage. The authorized fallback was taken: `gh run list --branch main --workflow ci.yml --status success --limit 1` returned run 38730332356 (2026-10-15T11:51:32Z, merge of PR #939); `gh run download 38730332356 --name poshqc-test-results --dir SCRATCH/928/ci-main` (exit 0).

Output Summary:
- MTIME_UTC 2026-10-16T01-31 (download time of the CI artifact; staleness rule applies only to COVERAGE_SOURCE: local)
- REPORT LINE missed 1735 covered 16381
- FILE .claude/hooks/validate-discovery-artifact-gate.ps1 MATCHED 1 covered 63 total 63 pct 100.00 missed_lines (none)
- FILE .claude/hooks/validate-executor-output.ps1 MATCHED 1 covered 117 total 119 pct 98.32 missed_lines 82,179
- FILE .claude/hooks/validate-orchestrator-output.ps1 MATCHED 1 covered 109 total 110 pct 99.09 missed_lines 234
- FILE .claude/hooks/validate-planner-output.ps1 MATCHED 1 covered 199 total 200 pct 99.50 missed_lines 157
- FILE .claude/hooks/validate-pr-author-output.ps1 MATCHED 1 covered 32 total 32 pct 100.00 missed_lines (none)
- FILE .claude/hooks/validate-prd-feature-output.ps1 MATCHED 1 covered 65 total 65 pct 100.00 missed_lines (none)
- FILE .claude/hooks/validate-required-artifact-output.ps1 MATCHED 1 covered 60 total 61 pct 98.36 missed_lines 95
- FILE .claude/hooks/validate-task-researcher-output.ps1 MATCHED 1 covered 101 total 103 pct 98.06 missed_lines 216,275
- FILE .claude/hooks/validate-feature-review-coverage.ps1 MATCHED 1 covered 84 total 85 pct 98.82 missed_lines 203 (unchanged reference)
- FILE .claude/hooks/subagentstop-envelope.ps1 MATCHED 1 covered 60 total 60 pct 100.00 missed_lines (none)
- FILE .claude/hooks/enforce-epic-wave-barrier.ps1 MATCHED 1 covered 95 total 96 pct 98.96 missed_lines 380
- AGGREGATE (ten changed files) covered 901 total 909 pct 99.12
