# Uncovered Codex helper lines mapped to Codex cases (remediation cycle 1, R1, Phase 1)

Timestamp: 2026-10-16T15-40
Task: [P1-T4]
Command: Read .codex/hooks/enforce-epic-merge-gate-command.ps1:60-68 and :153-183; .codex/hooks/enforce-epic-merge-gate.ps1:80-84 and :132-199; tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:105-179; tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1:63-95; tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1:84-128
EXIT_CODE: 0
Output Summary:
DRIVEN_BUT_REPORTED_UNCOVERED=63, 64, 173, 176, 177, 178, 179, 180, 183
NOT_DRIVEN=68, 160, 161, 166
TRACE_DIFFERS_FROM_PLANNER=true (line 180 only; see note)

## Code path

- `Get-CodexMergeCommandPrNumber` (gate `:84`) returns `Get-EpicMergeGateSelectorPrNumber -CommandText $Command`.
- `Invoke-CodexEpicMergeDecision` reaches `Get-CodexMergeCommandPrNumber` at gate `:160` only when the command is in scope (`:151`) and the child checkpoint is not merge-ready (`:156`); an empty or record-only child checkpoint is not merge-ready.
- Helper `:153` takes the first Structural `gh pr merge` match; a `gh api` command has none, so control reaches `:176`.

## Line map

| Helper line | Statement | Codex cases that reach it | Path |
|---|---|---|---|
| 63 | `elseif ($Selector -match '/pull/(\d+)...')` | merge-queue `:134` (URL selector, direct); merge-queue `:149` (URL selector, record-only child checkpoint, gate `:160`) | selector `https://.../pull/5` fails `:61`, evaluated at `:63` |
| 64 | `$digits = $Matches[1]` | merge-queue `:134`, `:149` | `:63` matches |
| 68 | `return $null` (converter) | none | every Codex selector is all digits or a pull URL that parses, so `:67` returns |
| 160 | `--` with a following token | none | no Codex command carries a bare `--` |
| 161 | `--` as the last token | none | same |
| 166 | `--merge=<value>` return | none | no Codex command carries an equals-joined `--merge` |
| 173 | `return $null` after the token loop | trigger-scoping `:76` (`gh pr merge --merge`, direct); authorization `:123-125` (`gh pr merge --merge`, record-691 child, gate `:160`); merge-queue `:170-171` (`gh pr merge --squash`, empty checkpoints, gate `:160`) | only flags, loop ends |
| 176 | `foreach ($apiMatch ...)` | merge-queue `:107-110` (gate `:160`), `:135` (direct), `:151` (record-only child, gate `:160`) | no Structural pr-merge match |
| 177 | `foreach ($token ...)` | merge-queue `:107-110`, `:135`, `:151` | one `gh api` match |
| 178 | `$rest = [regex]::Match(...)` | merge-queue `:107-110`, `:135`, `:151` | per token |
| 179 | `$number = 0` | merge-queue `:107-110`, `:135`, `:151` | per token |
| 180 | `if ($rest.Success -and ...) { return $number }` | merge-queue `:107-109` (condition evaluated, false for every token), `:110`, `:135`, `:151` (condition true, returns 5) | per token |
| 183 | `return $null` (end of function) | merge-queue `:107-109` (GraphQL mutations, no REST path, gate `:160`) | loops finish without a return |

Merge-queue `:111` (read query) is out of scope at gate `:151` and does not reach the reader.

## Difference from the planner's trace

The planner listed line 180 as reached from merge-queue `:110`, `:135` and `:151` only. Line 180 is the `if` statement inside the token loop, so it is executed (with a false condition) for every token of the GraphQL rows `:107-109` as well. The sets DRIVEN_BUT_REPORTED_UNCOVERED and NOT_DRIVEN are unchanged by this difference. Not a stop condition.
