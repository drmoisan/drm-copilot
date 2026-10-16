# R1 Merge-base CI Coverage Baseline (Issue #927, PA-1 baseline)

Timestamp: 2026-10-16T07-40
Command: gh run view 38852748136 --json headSha,status,conclusion,event
EXIT_CODE: 0
Output Summary: Baseline CI run 38852748136 (push, completed, success) has headSha equal to MERGE_BASE afa951ac0207eae934ac695e7340f18b3cf77522. Repo-wide PowerShell LINE 16381/18116 (90.42%), JUnit tests=10376 failures=0 errors=0. Per-file baseline: docs-only 93.44%, pr-author 92.98%, Claude gate 99.25%, resolution 95.24%, Codex gate 87.9%.

RUN_VIEW: {"conclusion":"success","event":"push","headSha":"afa951ac0207eae934ac695e7340f18b3cf77522","status":"completed"}
BASELINE_CI_RUN_ID: 38852748136
HEADSHA_EQUALS_MERGE_BASE: true

Command 2: gh run download 38852748136 -n poshqc-test-results -D SCRATCH/927/ci-base/38852748136
EXIT_CODE_2: 0
DOWNLOADED: pester-junit.xml, powershell-coverage.koverage.xml, powershell-coverage.xml (new, empty directory before the download)

Command 3: poetry run python -I SCRATCH/927/tools/read_report_totals_927.py SCRATCH/927/ci-base/38852748136/powershell-coverage.xml SCRATCH/927/ci-base/38852748136/pester-junit.xml
EXIT_CODE_3: 0
REPORT_LINE: covered=16381 missed=1735 line_pct=90.42 threshold=85.00 result=PASS
JUNIT_TOTALS: tests=10376 failures=0 errors=0

Command 4: poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-base/38852748136/powershell-coverage.xml .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE_4: 0
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=57 missed=4 line_pct=93.44 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=132 missed=1 line_pct=99.25 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=40 missed=2 line_pct=95.24 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=138 missed=19 line_pct=87.9 threshold=85.00 result=PASS
