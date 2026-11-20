# Mirror: codex-payload group ([P3-T4])

Timestamp: 2026-10-08T17-58
Command: sh <SCRATCHPAD>/s-mirror.sh codex-payload
EXIT_CODE: 0
Output Summary:
COPIED .claude/hooks/hook-command-payload.ps1 -> .codex/hooks/hook-command-payload.ps1 2a04f766d77603d7c1bfe84e7b347e016aa3fbf024d11ec725f2108a7cad4b46
COPIED .claude/hooks/hook-command-payload-powershell.ps1 -> .codex/hooks/hook-command-payload-powershell.ps1 2c059c6450ba811716c17f2b5166e02064850cee7aecacc29fbc44c486a10224
COPIED .claude/hooks/hook-command-invocation.ps1 -> .codex/hooks/hook-command-invocation.ps1 e2089a3a2740ef228a55e8ade043ecd07798154fda3aee91d6fa292e4b802c15
Source and target SHA256 are equal for all three files (recorded in evidence/other/mirror-log.md).

Note: after this run, hook-command-payload.ps1 was condensed to meet the 500-line cap and both payload modules received a continuation-indent formatting fix. Rule 6 therefore re-runs this group before [P3-T6]; see mirror-codex-payload-phase3.
