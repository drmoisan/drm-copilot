# Coverage comparison (P4-T4)

Timestamp: 2026-11-14T23-11
Command: pwsh -NoProfile -File SCRATCH/issue-1188-read-gate.ps1 (P0 and final JUnit and coverage copies); pwsh -NoProfile -File SCRATCH/issue-1188-changed-lines.ps1 -Coverage SCRATCH/issue-1188-final-coverage.xml -MergeBase <git merge-base origin/main HEAD>
EXIT_CODE: 0
Output Summary: PASS. Inputs: evidence/baseline/pester-gate.2026-11-14T21-02.md (Phase 0 baseline) and evidence/qa-gates/final-qc-pester.2026-11-14T23-10.md (final gate), the lexicographically greatest files of each name; the final coverage XML was copied when the P4-T2 run ended, before any later Pester run. Both operands copies 100.00% (threshold 85%); no drop on either epic-scope file; repo-wide coverage rises; every changed executable line of both epic-scope files is covered.

## Line coverage

| File | Baseline (P0-T2) | Post-change (P4-T2) | Result |
|---|---|---|---|
| Repo-wide | 95.96% (43686/45525) | 95.99% (44002/45841) | no drop |
| .claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1 | new file (no pre-change run) | 100.00% (154/154) | at or above 85% |
| .codex/hooks/enforce-orchestration-preimplementation-gate-operands.ps1 | new file (no pre-change run) | 100.00% (154/154) | at or above 85% |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 97.73% (129/132) | 97.79% (133/136) | no drop |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 98.01% (148/151) | 98.06% (152/155) | no drop |

New and changed code: 308 new lines in the two operands copies, all covered; 10 changed executable lines in the two epic-scope files, all covered (100%).

## Changed-lines condition (AC-11)

New-side line numbers from the `@@` hunk headers of `git diff -U0 <merge-base> HEAD` per file; `ci` read from the `line` element under the file's `sourcefile` in the P4-T2 coverage XML.

.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 (15 changed lines):

| Line | Coverage element | Statement |
|---|---|---|
| 28-32 | no line element | comment-based help text |
| 63 | ci=2 | guarded dot-source of enforce-orchestration-preimplementation-gate-operands.ps1 (required) |
| 248-251 | no line element | comment-based help text |
| 277 | ci=3 | `$operand = ... Get-OrchestrationGateCommandTargetOperand -Command $Command` (required call) |
| 278 | ci=1 | `if ($null -ne $operand -and $operand.Unresolved) {` |
| 279 | ci=6 | `return [pscustomobject]@{ Status = 'NoTarget'; ... }` (required Unresolved return) |
| 280 | no line element | closing brace |
| 286 | ci=2 | `Resolve-HookTargetWorktree ... -CommandOperandPath @($operand.Paths) ...` |

.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 (8 changed lines):

| Line | Coverage element | Statement |
|---|---|---|
| 52 | ci=2 | guarded dot-source of enforce-orchestration-preimplementation-gate-operands.ps1 (required) |
| 232-233 | no line element | comment-based help text |
| 250 | ci=4 | `$operand = ... Get-OrchestrationGateCommandTargetOperand -Command ([string]$Command)` (required call) |
| 251 | ci=1 | `if ($null -ne $operand -and $operand.Unresolved) {` |
| 252 | ci=5 | `return [pscustomobject]@{ Status = 'NoTarget'; ... }` (required Unresolved return) |
| 253 | no line element | closing brace |
| 259 | ci=2 | `Resolve-HookTargetWorktree ... -CommandOperandPath @($operand.Paths) ...` |

Changed executable lines with ci 0: none on either file. Every required statement has a line element with ci greater than 0.
