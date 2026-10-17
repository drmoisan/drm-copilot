# Linux Baseline Failure Set (P0-T4, expect-fail, fail-before evidence for AC-10 rows 1 to 12)

Timestamp: 2026-10-01T19-01
Baseline run: 36901896617 (head ecba8829), artifact `poshqc-linux-hook-test-results`.

Command: gh run download 36901896617 --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-baseline-743
EXIT_CODE: 0
Output Summary: `pester-junit-linux-hooks.xml` downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/linux-baseline-743/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=3412 failures=12 errors=0`; exactly 12 `FAIL:` lines (SUITE lines omitted below):
```
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.denies when the only finding file predates the latest drift event
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.allows when the finding file timestamp equals the latest drift event at
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.allows when the finding file timestamp follows the latest drift event at
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.denies when the finding file name carries a non-conforming embedded substring
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.Layer-1 finding-presence narrowing to the current drift event.names the current-event requirement in the deny reason for a stale finding file
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.read seams.Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.read seams.Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present
FAIL: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | enforce-parallel-drift-gate.ps1.read seams.Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file
FAIL: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
FAIL: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
FAIL: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | Codex enforce-powershell-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
FAIL: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | Codex enforce-python-batch-budget.ps1 large-path routing.checkpoint seam.the default reader yields direct mode when the checkpoint file is absent
```

Command: poetry run python <session-scratchpad>/pester_xml_summary.py inventory <session-scratchpad>/linux-baseline-743/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: ROW 1 to ROW 12 all `FAIL`; `INVENTORY-SUMMARY: pass=0 fail=12 missing=0 other-fail=0`.

Acceptance: JUNIT-ROOT line matches; 12 FAIL lines; inventory summary matches. Met. This is the expected failing state (expect-fail) and shows that the inventory mode reports a failure when one exists.
