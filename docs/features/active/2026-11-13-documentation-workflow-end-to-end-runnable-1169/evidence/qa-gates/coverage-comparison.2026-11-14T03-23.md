# Coverage Comparison (Remediation Cycle 1, P4-T4)

Timestamp: 2026-11-14T03-23
Command: sh SCRATCH/issue-1169-cc.sh (pwsh -File SCRATCH/issue-1169-covcmp2.ps1 -Root <worktree root> -Baseline SCRATCH/issue-1169-p0-coverage.xml -Final SCRATCH/issue-1169-r1final-coverage.xml -From <parent of the first cycle-1 commit>: per-file LINE counters and per-line hit counts of the Phase 0 and final merged powershell-coverage.xml; changed lines are the added lines of git diff -U0 <parent of the first cycle-1 commit> HEAD for each changed production file)
EXIT_CODE: 0
Output Summary:
- Reference: evidence/remediation-baseline/baseline-reference.2026-11-14T01-36.md (P0-T2). Final: evidence/qa-gates/final-qc-pester.2026-11-14T03-21.md and final-qc-pytest.2026-11-14T03-23.md.
- Per file (threshold 85%; no drop below the P0-T2 reference):
  - .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: reference 94.20% (130/138), final 97.04% (131/135). Pass.
  - .codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: reference 91.30% (126/138), final 93.33% (126/135). Pass.
  - .claude/hooks/hook-docs-estate-context.ps1: reference 100.00% (58/58), final 100.00% (58/58). Pass.
  - .codex/hooks/hook-docs-estate-context.ps1: reference 96.55% (56/58), final 100.00% (58/58). Pass.
  - .claude/lib/docs/DocsCompleteGate.psm1: reference 100.00% (38/38), final 100.00% (39/39). Pass.
- Repo-wide Pester line coverage: Phase 0 baseline 95.83% (37807/39454), final 95.87% (39201/40891). No drop.
- Changed-line coverage of this cycle's production edits: 100.00% (13/13) instrumented added lines (docs leg 3/3 per copy, hook-docs-estate-context.ps1 3/3 per copy, DocsCompleteGate.psm1 1/1). The deleted Get-OrchestrationDocsEstateFileText lines are no longer in the denominator.
- pytest totals: Phase 0 baseline 16598 passed, line 97.11% (34334/35355), branch 94.37% (12668/13424); final 16676 passed, 0 failed, line 97.13% (34525/35546), branch 94.41% (12758/13514). No drop.
- No value is missing; the outcome is PASS.
