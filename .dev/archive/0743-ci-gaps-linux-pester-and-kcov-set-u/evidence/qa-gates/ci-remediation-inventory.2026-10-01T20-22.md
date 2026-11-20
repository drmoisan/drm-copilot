# AC-10 Named Inventory Result (P4-T7)

Timestamp: 2026-10-01T20-22
RUN_ID: 36918378249; k = 0 (no P4-T11 rows; contingency not applicable).

Command: poetry run python <session-scratchpad>/pester_xml_summary.py inventory <session-scratchpad>/linux-final-743-36918378249/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary:
```
ROW 1: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the only finding file predates the latest drift event
ROW 2: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp equals the latest drift event at
ROW 3: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp follows the latest drift event at
ROW 4: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the finding file name carries a non-conforming embedded substring
ROW 5: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | names the current-event requirement in the deny reason for a stale finding file
ROW 6: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist
ROW 7: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present
ROW 8: PASS | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file
ROW 9: PASS | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent
ROW 10: PASS | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent
ROW 11: PASS | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent
ROW 12: PASS | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent
INVENTORY-SUMMARY: pass=12 fail=0 missing=0 other-fail=0
```
The P0-T4 baseline for the same command was `pass=0 fail=12 missing=0 other-fail=0`.

Acceptance: `INVENTORY-SUMMARY: pass=12 fail=0 missing=0 other-fail=0` and `ROW n: PASS` for n = 1 to 12. Met.
