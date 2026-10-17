# Linux Hook-Suite JUnit Result (P4-T6, AC-6, AC-8, AC-9)

Timestamp: 2026-10-01T20-22
RUN_ID: 36918378249; LINUX_JOB_ID: 110557965901.

Command: gh run download 36918378249 --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-final-743-36918378249
EXIT_CODE: 0
Output Summary: `pester-junit-linux-hooks.xml` downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/linux-final-743-36918378249/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=3412 failures=0 errors=0`; 135 SUITE lines; 0 `FAIL:` lines (output captured to `<session-scratchpad>/linux-final-junit.txt` and filtered). Selected SUITE lines:
```
SUITE: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | tests=48 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | tests=47 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | tests=32 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | tests=49 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | tests=34 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=0 | errors=0 | skipped=0
```

Acceptance: `failures=0 errors=0` (tests=3412 recorded, not asserted); no `FAIL:` line; the three named Codex suites report `failures=0` (AC-8 and AC-9 on Linux). Met.
