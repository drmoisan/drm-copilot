# P0-T12 CI Coverage Baseline (issue #927)

Timestamp: 2026-10-16T00-48
Command: gh run list --workflow ci.yml --commit adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 --json databaseId,event,status,conclusion,headSha --limit 10
EXIT_CODE: 0
Output Summary: One CI run exists at the merge base (38730332356, push, success). Its poshqc-test-results artifact was downloaded to SCRATCH/927/ci-base/38730332356 and read with the Appendix S reader (exit 0). Baseline line coverage: docs-only 93.44%, pr-author 92.98%, Claude merge gate 99.25%, resolution sibling 95.24%, Codex merge gate 87.9%. The four AC-9 seam statements (lines 64, 65, 68, 70) have ci=0 at baseline.

## Commands and results

- Run list output: `[{"conclusion":"success","databaseId":38730332356,"event":"push","headSha":"adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99","status":"completed"}]`
- `gh run download 38730332356 -n poshqc-test-results -D SCRATCH/927/ci-base/38730332356` -> exit 0 (files: pester-junit.xml, powershell-coverage.koverage.xml, powershell-coverage.xml)
- `poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-base/38730332356/powershell-coverage.xml .claude/hooks/enforce-pr-author-skill.docs-only.ps1:64,65,68,70 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1` -> exit 0

BASELINE_CI_RUN_ID: 38730332356
BASELINE_CI_HEAD_SHA: adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99 (equals MERGE_BASE)

## Reader output (verbatim)

COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=57 missed=4 line_pct=93.44 threshold=85.00 result=PASS
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=64 ci=0 mi=2
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=65 ci=0 mi=1
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=68 ci=0 mi=1
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=70 ci=0 mi=4
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=132 missed=1 line_pct=99.25 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=40 missed=2 line_pct=95.24 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=138 missed=19 line_pct=87.9 threshold=85.00 result=PASS
