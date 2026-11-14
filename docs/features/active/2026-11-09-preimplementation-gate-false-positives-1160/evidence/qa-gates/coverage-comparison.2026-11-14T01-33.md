# Coverage Comparison (cycle 3, [P3-T4])

Timestamp: 2026-11-14T01-33
Command: sh SCRATCH/issue-1160-r4-summary.sh (reads artifacts/pester/powershell-coverage.xml written by the [P3-T2] run at 2026-11-14T01-28); figures compared with evidence/baseline/pester-gate.2026-11-10T04-19.md (Phase 0 baseline) and evidence/remediation-baseline/baseline-reference.2026-11-14T00-38.md (head figures from evidence/qa-gates/pester-gate.2026-11-13T19-43.md)
EXIT_CODE: 0
Output Summary: repo-wide line coverage 95.88% (39146/40828), at or above the Phase 0 baseline 95.80% (37558/39203) and the head figure 95.86% (38934/40614). The `.claude/hooks` and `.codex/hooks` commands copies are each 99.01% (201/203), at or above 90% and above the head figure 98.96% (95/96). Both gate files and both bookkeeping copies are unchanged in figure. The D17 change adds 107 instrumented lines to each measured commands copy; 106 are covered, and the one uncovered new line is named below with its reason. PASS.

| File | Phase 0 baseline | Head (cycle 2, post-merge) | Final ([P3-T2]) | Threshold | Result |
|---|---|---|---|---|---|
| Repo-wide | 95.80% (37558/39203) | 95.86% (38934/40614) | 95.88% (39146/40828) | >= 95.80% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | new file in this PR | 98.96% (95/96) | 99.01% (201/203) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | new file in this PR | 98.96% (95/96) | 99.01% (201/203) | >= 90% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | see Phase 0 artifact | 96.43% (162/168) | 96.43% (162/168) | >= 85%, no drop | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | see Phase 0 artifact | 100.00% (178/178) | 100.00% (178/178) | >= 85%, no drop | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` | new file in this PR | 100.00% (78/78) | 100.00% (78/78) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` | new file in this PR | 100.00% (78/78) | 100.00% (78/78) | >= 90% | PASS |

The two bundle copies under `extensions/drm-copilot/resources/` are not in the coverage population; they are byte-identical to the measured copies (one SHA256, [P2-T1]).

## Uncovered lines of the commands sibling (both measured copies)

- The `break` after a PowerShell `-CommandWithArgs`, `-cwa`, or `-EncodedCommand` flag whose payload is the last word, in `Test-OrchestrationGateCommandModelled` (new in D17). It runs only for an otherwise modelled mention written with one of those flags and nothing after the payload; no corpus row or suite case uses that shape. The opposite branch (a word after the payload) is covered by `keeps PowerShell -CommandWithArgs arguments after the payload classified`.
- The `continue` after an Opaque NoPayload record that carries no governed word, in `Test-OrchestrationGateInvocationConfirmed` (unchanged since cycle 1; review note N2, uncovered at head as well).
