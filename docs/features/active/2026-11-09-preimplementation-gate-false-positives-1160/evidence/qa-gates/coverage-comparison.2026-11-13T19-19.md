# Coverage Comparison ([P3-T4])

Timestamp: 2026-11-13T19-19
Command: sh SCRATCH/issue-1160-r4-summary.sh (reads artifacts/pester/powershell-coverage.xml of the [P3-T2] run; per-file LINE counters and per-line `ci` hit counts)
EXIT_CODE: 0
Output Summary: repo-wide line coverage 95.86% (38163/39812) against the Phase 0 baseline 95.80% (37558/39203): no drop. Commands sibling `.claude/hooks` and `.codex/hooks` copies each 98.96% (95/96) against 98.68% (75/76) at head: no drop, above 90%. Every new D16 line is covered; the one missed line is the pre-existing `continue` of the Opaque NoPayload branch. PASS.

Sources: Phase 0 baseline `evidence/baseline/pester-gate.2026-11-10T04-19.md`; head figures `evidence/qa-gates/coverage-comparison.2026-11-13T17-27.md` (recorded in `evidence/remediation-baseline/baseline-reference.2026-11-13T18-34.md`); post-change `evidence/qa-gates/pester-gate.2026-11-13T19-19.md`.

| File | Phase 0 / head | Post-change | Threshold | Result |
|---|---|---|---|---|
| Repo-wide | 95.80% (37558/39203) | 95.86% (38163/39812) | >= 95.80% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 98.68% (75/76) | 98.96% (95/96) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | 98.68% (75/76) | 98.96% (95/96) | >= 90% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` (unchanged) | 100% | 100.00% (78/78) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` (unchanged) | 100% | 100.00% (78/78) | >= 90% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` (unchanged in this cycle) | 96.43% | 96.43% (162/168) | >= 85% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (unchanged in this cycle) | 100% | 100.00% (178/178) | >= 85% | PASS |

The two bundle copies under `extensions/drm-copilot/resources/` are not in the coverage population of `config/poshqc-coverage.json`, so the report lists no figure for them; they are byte-identical to the measured `.claude/hooks` and `.codex/hooks` copies (SHA256 `e32ac31e98c618d9857b9ad3b0ea0cd3223a58a54e519f79fabffd6579cdf9e4`).

## Changed sibling lines

The D16 change adds `Test-OrchestrationGateMentionHostRecord`, the `NotHost` and `sort` table entries, and the consumer loop in `Test-OrchestrationGateInvocationConfirmed`. Executable lines in the commands sibling rose from 76 to 96; all 20 added executable lines, and every executable line of the new function and the consumer loop, have a hit count above zero in both measured copies. The only line with zero hits is the `continue` after the Opaque record check (`if ($record.Opaque) { ... continue }`), which is unchanged text and was the one missed line at head; it runs only for an Opaque NoPayload record when neither the record nor the whole text carries a governed word as a whole token, a case no current test reaches.
