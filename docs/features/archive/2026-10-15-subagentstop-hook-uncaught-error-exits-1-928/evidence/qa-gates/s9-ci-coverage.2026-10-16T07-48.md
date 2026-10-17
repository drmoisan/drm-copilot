# S9 CI gate and AC14 coverage verification (Issue #928)

Timestamp: 2026-10-16T07-48
Command: gh pr checks 954; gh run download 38867388618 --name poshqc-test-results --dir SCRATCH/928/ci-pr-b43188f; poetry run python SCRATCH/928/coverage_rows.py SCRATCH/928/ci-pr-b43188f/powershell-coverage.xml <ten changed hook paths>
EXIT_CODE: 0
COVERAGE_SOURCE: ci-pr 38867388618 (PR #954 head b43188f8377b5c2bbbfd5484f52b7fc226876353)

Output Summary:
- PR #954 checks on head b43188f8377b5c2bbbfd5484f52b7fc226876353: 20 total, 20 pass, 0 skipped, 0 pending, 0 failing.
- `poshqc / PowerShell QC`: pass (run 38867388618, job 116863252217). `poshqc / PowerShell hook suites (Linux)`: pass. `quality-checks7 / Code Quality & Tests` (3.10, 3.11, 3.12, 3.13): pass.
- MTIME_UTC 2026-10-16T07-47 (download time of the CI artifact)
- REPORT LINE missed 1736 covered 16434

| File | Baseline pct (ci-main 38730332356) | PR-head pct | Delta | Catch line | Missed lines |
|---|---|---|---|---|---|
| .claude/hooks/validate-discovery-artifact-gate.ps1 | 100.00 | 100.00 | 0.00 | 253 | none |
| .claude/hooks/validate-executor-output.ps1 | 98.32 | 98.33 | +0.01 | 322 | 83, 180 |
| .claude/hooks/validate-orchestrator-output.ps1 | 99.09 | 99.10 | +0.01 | 344 | 235 |
| .claude/hooks/validate-planner-output.ps1 | 99.50 | 99.50 | 0.00 | 440 | 158 |
| .claude/hooks/validate-pr-author-output.ps1 | 100.00 | 100.00 | 0.00 | 129 | none |
| .claude/hooks/validate-prd-feature-output.ps1 | 100.00 | 100.00 | 0.00 | 118 | none |
| .claude/hooks/validate-required-artifact-output.ps1 | 98.36 | 98.39 | +0.03 | 199 | 96 |
| .claude/hooks/validate-task-researcher-output.ps1 | 98.06 | 98.08 | +0.02 | 290 | 217, 276 |
| .claude/hooks/subagentstop-envelope.ps1 | 100.00 | 100.00 | 0.00 | n/a | none |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | 98.96 | 98.96 | 0.00 | n/a | 380 |

- AGGREGATE (ten changed files): baseline 99.12 (901/909), PR head 99.13 (909/917).
- Result: every changed file is at least 85.00 and not below its baseline; the aggregate is at least 85.00; no catch line appears in its validator's missed lines. The missed lines are the pre-existing ones shifted by the inserted lines.
- AC14 coverage clause: satisfied. AC15: satisfied.
