# Coverage Comparison (cycle 4, [P3-T4])

Timestamp: 2026-11-14T03-10
Command: sh SCRATCH/issue-1160-r4-summary.sh (reads artifacts/pester/powershell-coverage.xml written by the [P3-T2] run at 2026-11-14T03-08) and a per-line read of the same report for the D19 line; figures compared with evidence/baseline/pester-gate.2026-11-10T04-19.md (Phase 0 baseline) and evidence/remediation-baseline/baseline-reference.2026-11-14T02-14.md (cycle 3 head figures)
EXIT_CODE: 0
Output Summary: repo-wide line coverage 95.90% (39505/41192), at or above the Phase 0 baseline 95.80% (37558/39203), +0.10 points; +0.02 points against the cycle 3 head figure 95.88% (39146/40828). The `.claude/hooks` and `.codex/hooks` commands copies are each 99.00% (199/201), at or above 90%; -0.01 points against the cycle 3 head figure 99.01% (201/203), because D19 removes two covered loop lines and leaves the same two uncovered lines. The changed D19 line (`$subcommand = if ...` in `Test-OrchestrationGateMentionHostRecord`) is covered on both surfaces. PASS.

| File | Phase 0 baseline | Cycle 3 head | Final ([P3-T2]) | Threshold | Result |
|---|---|---|---|---|---|
| Repo-wide | 95.80% (37558/39203) | 95.88% (39146/40828) | 95.90% (39505/41192) | >= 95.80% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | new file in this PR | 99.01% (201/203) | 99.00% (199/201) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1` | new file in this PR | 99.01% (201/203) | 99.00% (199/201) | >= 90% | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | see Phase 0 artifact | 96.43% (162/168) | 96.43% (162/168) | >= 85%, no drop | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | see Phase 0 artifact | 100.00% (178/178) | 100.00% (178/178) | >= 85%, no drop | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` | new file in this PR | 100.00% (78/78) | 100.00% (78/78) | >= 90% | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1` | new file in this PR | 100.00% (78/78) | 100.00% (78/78) | >= 90% | PASS |

The two bundle copies under `extensions/drm-copilot/resources/` are not in the coverage population; they are byte-identical to the measured copies (one SHA256, [P2-T1]).

## The D19 line

The D19 line in `Test-OrchestrationGateMentionHostRecord` is covered in both measured copies (2 covered instructions, 1 missed instruction). The missed instruction is the `else { '' }` arm, which runs only for a record whose subcommand-scoped host word has no following token (a bare `git` or `npm` that carries a governed word elsewhere in the same record cannot occur, so the arm is reached only through a record with no carrying token). Pester measures line coverage only; this is reported, not gated.

## Uncovered lines of the commands sibling (both measured copies, unchanged from cycle 3)

- The `break` after a PowerShell `-CommandWithArgs`, `-cwa`, or `-EncodedCommand` flag whose payload is the last word, in `Test-OrchestrationGateCommandModelled`.
- The `continue` after an Opaque NoPayload record that carries no governed word, in `Test-OrchestrationGateInvocationConfirmed` (review note N2).

## Correction (appended 2026-11-14T03-11)

The parenthetical in `## The D19 line` that calls the `else { '' }` arm reachable only through a record with no carrying token is inaccurate as a general statement: `Test-OrchestrationGateAcceptedConsumer` calls `Test-OrchestrationGateMentionHostRecord` for pipeline consumers that do not carry the governed word, so a bare subcommand-scoped host word as a consumer (for example `echo pytest | git`) reaches that arm and returns `$false` (not a host), which confirms the hit. No test in the run drives that shape, which is why the instruction is missed. The line itself is covered, and every figure above is unchanged.
