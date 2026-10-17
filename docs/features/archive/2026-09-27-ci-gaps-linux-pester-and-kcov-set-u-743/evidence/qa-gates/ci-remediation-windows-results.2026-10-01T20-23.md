# Windows JUnit and Coverage Results (P4-T9, AC-7, AC-21 coverage part)

Timestamp: 2026-10-01T20-23
RUN_ID: 36918378249; WINDOWS_JOB_ID: 110557965705; CI_SHA 42db4491a6a7af4d0a876bf4022f7153e66f5c88.

Command: gh run download 36918378249 --name poshqc-test-results --dir <session-scratchpad>/windows-final-743-36918378249
EXIT_CODE: 0
Output Summary: pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/windows-final-743-36918378249/pester-junit.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=6101 failures=0 errors=0`; 0 `FAIL:` lines (output captured to `<session-scratchpad>/windows-final-junit.txt` and filtered). The four named suites:
```
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | tests=7 | failures=0 | errors=0 | skipped=0
```

Command: poetry run python <session-scratchpad>/pester_xml_summary.py coverage <session-scratchpad>/windows-final-743-36918378249/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: `PS-LINE-COVERAGE: covered=11236 missed=430 percent=96.31`

Acceptance: `failures=0 errors=0`; no `FAIL:` line; the four suites report `failures=0 errors=0`; percent 96.31 is at least 85.00 and at least B_PS (96.31); covered 11236 and missed 430 recorded. Met.
