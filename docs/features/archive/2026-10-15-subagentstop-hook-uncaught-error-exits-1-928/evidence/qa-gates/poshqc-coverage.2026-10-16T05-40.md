# PoshQC Coverage (remediation cycle 1 final QC, pass 1)

Timestamp: 2026-10-16T05-40
Command: poetry run python SCRATCH/928/coverage_rows.py artifacts/pester/powershell-coverage.xml .claude/hooks/validate-discovery-artifact-gate.ps1 .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-planner-output.ps1 .claude/hooks/validate-pr-author-output.ps1 .claude/hooks/validate-prd-feature-output.ps1 .claude/hooks/validate-required-artifact-output.ps1 .claude/hooks/validate-task-researcher-output.ps1 .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/subagentstop-envelope.ps1 .claude/hooks/enforce-epic-wave-barrier.ps1
EXIT_CODE: 0
COVERAGE_SOURCE: ci-pr (CI-dependent)
Output Summary:
- MTIME_UTC 2026-10-16T05-38 (not earlier than the P4-T3 poshqc-test Timestamp 2026-10-16T05-28)
- REPORT LINE missed 5896 covered 6387 (local MCP run; breakpoint coverage over the installed-extension coverage list)
- Baseline source: newest remediation-baseline/poshqc-coverage.2026-10-16T04-51.md, COVERAGE_SOURCE ci-main 38849638374.

| File | Post-change (local) | Baseline (ci-main) | Delta |
| --- | --- | --- | --- |
| .claude/hooks/validate-discovery-artifact-gate.ps1 | MATCHED 1 covered 64 total 64 pct 100.00 | 100.00 | 0.00 |
| .claude/hooks/validate-executor-output.ps1 | MATCHED 0 | 98.32 | CI-dependent |
| .claude/hooks/validate-orchestrator-output.ps1 | MATCHED 1 covered 110 total 111 pct 99.10 missed_lines 235 | 99.09 | +0.01 |
| .claude/hooks/validate-planner-output.ps1 | MATCHED 1 covered 200 total 201 pct 99.50 missed_lines 158 | 99.50 | 0.00 |
| .claude/hooks/validate-pr-author-output.ps1 | MATCHED 0 | 100.00 | CI-dependent |
| .claude/hooks/validate-prd-feature-output.ps1 | MATCHED 0 | 100.00 | CI-dependent |
| .claude/hooks/validate-required-artifact-output.ps1 | MATCHED 0 | 98.36 | CI-dependent |
| .claude/hooks/validate-task-researcher-output.ps1 | MATCHED 0 | 98.06 | CI-dependent |
| .claude/hooks/validate-feature-review-coverage.ps1 (unchanged reference, not gated) | MATCHED 0 | 98.82 | n/a |
| .claude/hooks/subagentstop-envelope.ps1 | MATCHED 0 | 100.00 | CI-dependent |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | MATCHED 1 covered 95 total 96 pct 98.96 missed_lines 380 | 98.96 | 0.00 |

- AGGREGATE (ten branch-changed files, matched files only): covered 469 total 472 pct 99.36 (baseline ci-main aggregate over all ten: 99.12)
- Every changed file that shows MATCHED 1 has pct >= 85.00 and not below its cycle-baseline pct.
- Explicitly authorized branch taken: six changed files, including `.claude/hooks/subagentstop-envelope.ps1`, show MATCHED 0 locally and the cycle baseline used `COVERAGE_SOURCE: ci-main`. The numeric check (per-file >= 85.00 and not below baseline for all ten files, repo-wide LINE >= 85.00) is performed at S9 on the `poshqc-test-results` artifact of the `poshqc / PowerShell QC` job on the PR head, together with F1 and AC15.
- This cycle's only production change to `.claude/hooks/subagentstop-envelope.ps1` is a comment-based help rewrap (no executable line changed), so its executable line set is unchanged from the ci-main baseline (60 lines, 100.00).
