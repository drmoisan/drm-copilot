# PoshQC Coverage (remediation cycle 1 baseline)

Timestamp: 2026-10-16T04-51
Command: poetry run python SCRATCH/928/coverage_rows.py artifacts/pester/powershell-coverage.xml .claude/hooks/validate-discovery-artifact-gate.ps1 .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-planner-output.ps1 .claude/hooks/validate-pr-author-output.ps1 .claude/hooks/validate-prd-feature-output.ps1 .claude/hooks/validate-required-artifact-output.ps1 .claude/hooks/validate-task-researcher-output.ps1 .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/subagentstop-envelope.ps1 .claude/hooks/enforce-epic-wave-barrier.ps1
EXIT_CODE: 0
COVERAGE_SOURCE: ci-main 38849638374
Output Summary:

Local run (artifacts/pester/powershell-coverage.xml, written by the P0-T10 MCP test run):
- MTIME_UTC 2026-10-16T04-47 (not earlier than poshqc-test Timestamp 2026-10-16T04-29)
- REPORT LINE missed 5896 covered 6387
- FILE .claude/hooks/validate-discovery-artifact-gate.ps1 MATCHED 1 covered 64 total 64 pct 100.00
- FILE .claude/hooks/validate-executor-output.ps1 MATCHED 0
- FILE .claude/hooks/validate-orchestrator-output.ps1 MATCHED 1 covered 110 total 111 pct 99.10 missed_lines 235
- FILE .claude/hooks/validate-planner-output.ps1 MATCHED 1 covered 200 total 201 pct 99.50 missed_lines 158
- FILE .claude/hooks/validate-pr-author-output.ps1 MATCHED 0
- FILE .claude/hooks/validate-prd-feature-output.ps1 MATCHED 0
- FILE .claude/hooks/validate-required-artifact-output.ps1 MATCHED 0
- FILE .claude/hooks/validate-task-researcher-output.ps1 MATCHED 0
- FILE .claude/hooks/validate-feature-review-coverage.ps1 MATCHED 0
- FILE .claude/hooks/subagentstop-envelope.ps1 MATCHED 0
- FILE .claude/hooks/enforce-epic-wave-barrier.ps1 MATCHED 1 covered 95 total 96 pct 98.96 missed_lines 380
- AGGREGATE (ten branch-changed files) covered 469 total 472 pct 99.36 (matched files only)

Fallback trigger: `.claude/hooks/subagentstop-envelope.ps1` shows MATCHED 0 locally, so the explicitly authorized ci-main fallback was taken.
- Command: gh run list --branch main --workflow ci.yml --status success --limit 1 -> run 38849638374 (CI, main, push, completed success, 2026-10-16T04:14:57Z)
- Command: gh run download 38849638374 --name poshqc-test-results --dir SCRATCH/928/ci-main-cycle1 -> EXIT_CODE 0 (pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml)
- Command: poetry run python SCRATCH/928/coverage_rows.py SCRATCH/928/ci-main-cycle1/powershell-coverage.xml <same eleven arguments> -> EXIT_CODE 0

ci-main run 38849638374 (authoritative baseline for this cycle):
- MTIME_UTC 2026-10-16T04-50 (download time)
- REPORT LINE missed 1735 covered 16381
- FILE .claude/hooks/validate-discovery-artifact-gate.ps1 MATCHED 1 covered 63 total 63 pct 100.00
- FILE .claude/hooks/validate-executor-output.ps1 MATCHED 1 covered 117 total 119 pct 98.32 missed_lines 82,179
- FILE .claude/hooks/validate-orchestrator-output.ps1 MATCHED 1 covered 109 total 110 pct 99.09 missed_lines 234
- FILE .claude/hooks/validate-planner-output.ps1 MATCHED 1 covered 199 total 200 pct 99.50 missed_lines 157
- FILE .claude/hooks/validate-pr-author-output.ps1 MATCHED 1 covered 32 total 32 pct 100.00
- FILE .claude/hooks/validate-prd-feature-output.ps1 MATCHED 1 covered 65 total 65 pct 100.00
- FILE .claude/hooks/validate-required-artifact-output.ps1 MATCHED 1 covered 60 total 61 pct 98.36 missed_lines 95
- FILE .claude/hooks/validate-task-researcher-output.ps1 MATCHED 1 covered 101 total 103 pct 98.06 missed_lines 216,275
- FILE .claude/hooks/validate-feature-review-coverage.ps1 MATCHED 1 covered 84 total 85 pct 98.82 missed_lines 203
- FILE .claude/hooks/subagentstop-envelope.ps1 MATCHED 1 covered 60 total 60 pct 100.00
- FILE .claude/hooks/enforce-epic-wave-barrier.ps1 MATCHED 1 covered 95 total 96 pct 98.96 missed_lines 380
- AGGREGATE (ten branch-changed files) covered 901 total 909 pct 99.12
