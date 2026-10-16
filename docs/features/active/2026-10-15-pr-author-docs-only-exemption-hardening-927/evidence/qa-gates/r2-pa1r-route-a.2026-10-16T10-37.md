# R2 PA-1R Route A, Loop Pass 1 (Issue #927)

Timestamp: 2026-10-16T10-37
Command: date -u +%s
EXIT_CODE: 0
Output Summary: QC step 3, route A (PoshQC MCP test over SCAN_FULL per D-RUN-9a). The MCP call returned and both XML files were rewritten after RUN_START_EPOCH. JUnit tests=10606 failures=0 errors=0; report-level line 94.25% (PASS); hook aggregate 94.25% (PASS); all 19 Appendix R rows Passed; no failed test name. K4 found no class entry (CLASS_COUNT=0) for `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, and `.claude/hooks/enforce-pr-author-skill.docs-only.ps1`, so the R2-READ pass condition does not hold. PA-1R passes to route B ([P4-T7]).

RUN_START_EPOCH: 1792146190

## Commands

- Command 1: `date -u +%s`
  - EXIT_CODE_1: 0
  - Output: `1792146190`
- Command 2: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `<WORKSPACE_ROOT>` and `scan_folders` = `["scripts", "tests/scripts"]` (SCAN_FULL)
  - MCP_CALL: returned
- Command 3: `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`
  - EXIT_CODE_3: 0
  - Output: `1792146893` (coverage); `1792146999` (JUnit); both greater than RUN_START_EPOCH

## R2-READ

- K1: `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`
  - EXIT_CODE_K1: 0

REPORT_LINE: covered=11609 missed=708 line_pct=94.25 threshold=85.00 result=PASS
JUNIT_TOTALS: tests=10606 failures=0 errors=0

- K2: `poetry run python -I SCRATCH/927/tools/read_hook_aggregate_927.py artifacts/pester/powershell-coverage.xml`
  - EXIT_CODE_K2: 0

HOOK_AGGREGATE_LINE: counters=1329 covered=58045 missed=3540 line_pct=94.25 threshold=85.00 result=PASS

- K3: `grep -c -F -e '<token>" status="Passed"' artifacts/pester/pester-junit.xml` for each Appendix R token
  - Counts: F1 1, F2 1, F3 1, F4 1, F5 1, F6 1, F7 1, F8 1, F9 1, F10 1, F11 1, F12 1, F13 1, D1 1, D2 1, D3 1, D4 1, D5 1, D6 1
  - `grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml`
  - EXIT_CODE_K3_FAILED_NAMES: 1 (no failed name)
- K4: `poetry run python -I SCRATCH/927/tools/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`
  - EXIT_CODE_K4: 1

COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 CLASS_COUNT=0
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 CLASS_COUNT=0
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 CLASS_COUNT=0
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS

Observation: the population ran in full (10606 tests), but the coverage population omits three files, which is consistent with the MCP runner reading the installed-extension coverage configuration rather than the repository `config/poshqc-coverage.json`.

PA1R_ROUTE_A: NOT_SATISFIED K4 CLASS_COUNT=0 for .claude/hooks/hook-docs-only-diff.ps1, .codex/hooks/hook-docs-only-diff.ps1, .claude/hooks/enforce-pr-author-skill.docs-only.ps1; K4 exit 1
