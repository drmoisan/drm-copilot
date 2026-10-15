# Phase 1 test portability (R-PORT, issue #732)

Timestamp: 2026-10-09T03-50
Task: [P1-T8]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p1-t8-t9.sh (R-PORT over the seven NEW-732, D2A, and TRAILER files; edited files compared with git show BASE_SHA:<path>)
EXIT_CODE: 0

## Output

```text
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 TestDrive matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 New-TemporaryFile matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 GetTempFileName matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 $env:TEMP matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 Set-Content matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 Out-File matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 New-Item matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 Set-Location matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 TestDrive matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 New-TemporaryFile matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 GetTempFileName matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 $env:TEMP matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 Set-Content matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 Out-File matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 New-Item matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 Set-Location matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 TestDrive matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 New-TemporaryFile matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 GetTempFileName matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 $env:TEMP matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 Set-Content matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 Out-File matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 New-Item matches=0
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 Set-Location matches=0
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 TestDrive matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 TestDrive matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 New-TemporaryFile matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 New-TemporaryFile matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 GetTempFileName matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 GetTempFileName matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 $env:TEMP matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 $env:TEMP matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 Set-Content matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 Set-Content matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 Out-File matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 Out-File matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 New-Item matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 New-Item matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 Set-Location matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 Set-Location matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 TestDrive matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 TestDrive matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 New-TemporaryFile matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 New-TemporaryFile matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 GetTempFileName matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 GetTempFileName matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 $env:TEMP matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 $env:TEMP matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 Set-Content matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 Set-Content matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 Out-File matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 Out-File matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 New-Item matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 New-Item matches=0 same=True
TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 Set-Location matches=0
BASE_TOKEN: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 Set-Location matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 TestDrive matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 TestDrive matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 New-TemporaryFile matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 New-TemporaryFile matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 GetTempFileName matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 GetTempFileName matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 $env:TEMP matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 $env:TEMP matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 Set-Content matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 Set-Content matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 Out-File matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 Out-File matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 New-Item matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 New-Item matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 Set-Location matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 Set-Location matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 TestDrive matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 TestDrive matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 New-TemporaryFile matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 New-TemporaryFile matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 GetTempFileName matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 GetTempFileName matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 $env:TEMP matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 $env:TEMP matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 Set-Content matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 Set-Content matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 Out-File matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 Out-File matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 New-Item matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 New-Item matches=0 same=True
TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 Set-Location matches=0
BASE_TOKEN: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 Set-Location matches=0 same=True
R_PORT_CONDITION_MET: True
```

Output Summary: R_PORT_CONDITION_MET: True; every TOKEN line of the three new files reports matches=0 and every edited file matches its BASE_SHA counts when the condition is True.

