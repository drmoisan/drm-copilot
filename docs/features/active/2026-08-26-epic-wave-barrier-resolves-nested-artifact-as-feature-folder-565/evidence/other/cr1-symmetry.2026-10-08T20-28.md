# CR-1 Surface Symmetry (Token Counts)

Timestamp: 2026-10-08T20-28
Command: foreach ($p in @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1', '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1', '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1')) { $t = Get-Content -Raw -LiteralPath $p; $c = { param($s) ([regex]::Matches($t, [regex]::Escape($s))).Count }; 'TOKENS ' + $p + ' KeyedOnlyVar=' + (& $c '$KeyedOnly') + ' FallbackVar=' + (& $c '$FallbackIssueNumber') + ' KeyedOnlySwitch=' + (& $c '-KeyedOnly') + ' FallbackArg=' + (& $c '-FallbackIssueNumber $fallbackIssue') }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P2-T12.ps1
EXIT_CODE: 0
Output Summary: RW01 and RW02 each print KeyedOnlyVar=2 FallbackVar=4 KeyedOnlySwitch=1 FallbackArg=0; RW03 and RW04 each print KeyedOnlyVar=0 FallbackVar=0 KeyedOnlySwitch=1 FallbackArg=2. Both surfaces received identical edits.

```
TOKENS .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 KeyedOnlyVar=2 FallbackVar=4 KeyedOnlySwitch=1 FallbackArg=0
TOKENS .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 KeyedOnlyVar=2 FallbackVar=4 KeyedOnlySwitch=1 FallbackArg=0
TOKENS .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 KeyedOnlyVar=0 FallbackVar=0 KeyedOnlySwitch=1 FallbackArg=2
TOKENS .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 KeyedOnlyVar=0 FallbackVar=0 KeyedOnlySwitch=1 FallbackArg=2
```
