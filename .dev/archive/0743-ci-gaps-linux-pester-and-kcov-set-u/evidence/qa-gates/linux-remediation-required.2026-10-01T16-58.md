# Linux Remediation-Required Set (P5-T7)

Timestamp: 2026-10-01T16-58
Source inventory: `linux-first-run-failures.2026-10-01T16-56.md` (RUN_ID 36894194578, CI_SHA 90b6bd4a8646f0a510509c839e9daec77dff69d1).

The following inventory rows are Linux-only failures in files outside this plan's `Files written by this plan` list. They are not fixed here. Each fails with `DriveNotFoundException: Cannot find drive. A drive with the name 'C' does not exist.` on `ubuntu-latest`.

| Inventory row | File | Testcase |
| --- | --- | --- |
| 1 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the only finding file predates the latest drift event |
| 2 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp equals the latest drift event at |
| 3 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | allows when the finding file timestamp follows the latest drift event at |
| 4 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | denies when the finding file name carries a non-conforming embedded substring |
| 5 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | names the current-event requirement in the deny reason for a stale finding file |
| 6 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when the feature folder does not exist |
| 7 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports absence when no remediation-inputs file is present |
| 8 | tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | Test-ParallelDriftFindingPresent reports presence for a remediation-inputs markdown file |
| 9 | tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent |
| 10 | tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent |
| 11 | tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent |
| 12 | tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 | the default reader yields direct mode when the checkpoint file is absent |

Row count: 12, equal to the number of `REMEDIATION-REQUIRED` rows in the inventory (rows 1 to 12).

Consequence: AC-6 and AC-10 stay unchecked, and the plan outcome is REMEDIATION-REQUIRED (not PASS). The plan continues so the remaining acceptance criteria are evaluated. No file outside the `Files written by this plan` list was edited.

REMEDIATION-REQUIRED: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
REMEDIATION-REQUIRED: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
REMEDIATION-REQUIRED: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
REMEDIATION-REQUIRED: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
REMEDIATION-REQUIRED: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
