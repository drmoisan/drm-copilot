# Remediation Canonical Copy Check (issue #671, R1)

Timestamp: 2026-09-17T09-52
Task: [P2-T4]
Command: `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/klines.ps1` — against `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`: `[System.Management.Automation.Language.Parser]::ParseFile(...)` error count; `@(Get-Content -LiteralPath <p>).Count` (D7); D5 derivation (line number of the single line containing each anchor literal via `Select-String -SimpleMatch`, plus the offset); and `Select-String -SimpleMatch` counts for the purity literals, the purity sentence, and `Accepted widening`.
EXIT_CODE: 0
File hash at check: `AAD0BAAF088BAA3227E42D6E0B4171352C4F51BA611DBF7BD145024C6F958989`

Output Summary:

| Check | Observed | Expected | Result |
| --- | --- | --- | --- |
| ParseFile error count | 0 | 0 | PASS |
| Line count (D7) | 441 | 441 | PASS |
| K1 (anchor `PREIMPL_SELECTOR_MALFORMED: no subcommand immediately follows the selector value.`, +0) | 255 | 255 | PASS |
| K2 (same anchor, +1) | 256 | 256 | PASS |
| K3 (anchor `PREIMPL_SELECTOR_MALFORMED: the selector value is empty.`, +0) | 260 | 260 | PASS |
| K4 (same anchor, +1) | 261 | 261 | PASS |
| K5 (anchor `if ($subcommand -cne 'add' -and $subcommand -cne 'commit') {`, +1) | 321 | 321 | PASS |
| K6 (anchor `if (-not $Operand) {`, +1) | 180 | 180 | PASS |
| K7 (anchor `} catch {`, +1) | 438 | 438 | PASS |
| `git worktree` | 0 | 0 | PASS |
| `Test-Path` | 0 | 0 | PASS |
| `Start-Process` | 0 | 0 | PASS |
| `Resolve-Path` | 0 | 0 | PASS |
| `Invoke-Expression` | 0 | 0 | PASS |
| `env:` | 0 | 0 | PASS |
| `Import-Module` | 0 | 0 | PASS |
| `Pure string logic only: no disk, process, network, or environment access` | 1 | 1 | PASS |
| `Accepted widening` | 1 | >= 1 | PASS |

Each anchor literal matched exactly one line. A first invocation of the script exited 1 because its anchor table was declared with newline-separated nested arrays, which PowerShell flattened; the table was rewritten with the unary comma and the values above come from the corrected run. The helpers file was not modified between the two runs.
