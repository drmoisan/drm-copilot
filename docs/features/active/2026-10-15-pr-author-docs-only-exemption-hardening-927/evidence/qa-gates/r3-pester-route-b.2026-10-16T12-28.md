# R3 QC step 3: full-population Pester run, route B, loop pass 1 (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T12-28
Command: date -u +%s
EXIT_CODE: 0
Output Summary: Loop pass 1. Route B full-population run (CI form of the Test PowerShell step) exited 0. JUnit tests=10647 failures=0 errors=0; repo-wide line 90.37% (16656/18431); hook aggregate 90.37% PASS; all seven changed hook files PASS (both helper copies 97.6%); every Appendix R token passed; no failing test name. Both XML files were rewritten after the run started. This is the last Pester run of this cycle.

RUN_START_EPOCH: 1792152825

Command 2: sh SCRATCH/r3/run-poshqc-927.sh SCRATCH/r3/run-poshqc-927.ps1 SCRATCH/r3/direct-run.log
EXIT_CODE_2: 0

Command 3: grep -F -e 'POSHQC_EXIT_CODE=' SCRATCH/r3/direct-run.log
EXIT_CODE_3: 0
POSHQC_EXIT_CODE=0

Command 4: stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml
EXIT_CODE_4: 0
MTIME_COVERAGE: 1792153525
MTIME_JUNIT: 1792153643
MTIMES_AFTER_RUN_START: true

K1: poetry run python -I SCRATCH/r3/read_report_totals_927.py artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml
EXIT_CODE_K1: 0
REPORT_LINE: covered=16656 missed=1775 line_pct=90.37 threshold=85.00 result=PASS
JUNIT_TOTALS: tests=10647 failures=0 errors=0

K2: poetry run python -I SCRATCH/r3/read_hook_aggregate_927.py artifacts/pester/powershell-coverage.xml
EXIT_CODE_K2: 0
HOOK_AGGREGATE_LINE: counters=1981 covered=83280 missed=8875 line_pct=90.37 threshold=85.00 result=PASS

K3: grep -c -F -e '<token>" status="Passed"' artifacts/pester/pester-junit.xml (21 Appendix R tokens)
TOKEN F1 Passed=1
TOKEN F2 Passed=1
TOKEN F3 Passed=1
TOKEN F4 Passed=1
TOKEN F5 Passed=1
TOKEN F6 Passed=1
TOKEN F7 Passed=1
TOKEN F8 Passed=1
TOKEN F9 Passed=1
TOKEN F10 Passed=1
TOKEN F11 Passed=1
TOKEN F12 Passed=1
TOKEN F13 Passed=1
TOKEN F14 Passed=1
TOKEN D1 Passed=1
TOKEN D2 Passed=1
TOKEN D3 Passed=1
TOKEN D4 Passed=1
TOKEN D5 Passed=1
TOKEN D6 Passed=1
TOKEN D7 Passed=1
K3 failed names: grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml
EXIT_CODE_K3_FAILED: 1
FAILED_NAMES: (none)

K4: poetry run python -I SCRATCH/r3/read_coverage_927.py artifacts/pester/powershell-coverage.xml (seven hook files)
EXIT_CODE_K4: 0
COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=122 missed=3 line_pct=97.6 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=122 missed=3 line_pct=97.6 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS

LOOP_PASS: 1
R3_PESTER: SATISFIED
