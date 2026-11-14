# Coverage Comparison (P6-T4)

Timestamp: 2026-11-13T23-48
Command: pwsh -NoProfile -File SCRATCH/issue-1169-covcmp.ps1 -Root <worktree root> -Baseline SCRATCH/issue-1169-p0-coverage.xml -Final SCRATCH/issue-1169-final3-coverage.xml (per-file LINE counters and per-line hit counts of the Phase 0 and final merged powershell-coverage.xml; changed lines are the added lines of git diff -U0 <merge base of origin/main and HEAD> HEAD for each changed production file)
EXIT_CODE: 0
Output Summary:
- Sources: Phase 0 baseline = evidence/baseline/pester-baseline.2026-11-13T19-48.md (its coverage report copied to SCRATCH at that run); final = evidence/qa-gates/final-qc-pester.2026-11-13T23-48.md.
- New files (threshold 85% line coverage; no pre-change run): DocsReceiptRevision.psm1 100.00% (40/40); DocsValidateCommands.psm1 100.00% (102/102); .claude/hooks/hook-docs-estate-context.ps1 100.00% (58/58); .codex/hooks/hook-docs-estate-context.ps1 96.55% (56/58); .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 94.20% (130/138); .codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1 91.30% (126/138); enforce-model-routing-receipt-docs.ps1 95.06% (77/81). All at or above 85% (and at or above 90%).
- Changed files, baseline to final (no drop allowed): .claude/hooks/hook-docs-only-diff.ps1 98.43% to 98.46%; .codex/hooks/hook-docs-only-diff.ps1 97.64% to 97.69%; .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 96.32% to 96.36%; .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 100.00% to 100.00%; .claude/hooks/enforce-model-routing-receipt.ps1 95.70% to 96.00%; .claude/hooks/enforce-docs-complete-gate.ps1 94.57% to 95.00%; DocsCompleteGate.psm1 100.00% to 100.00%; DocsLedgerCommands.psm1 99.14% to 99.67%; DocsProfileCommands.psm1 97.33% to 97.33%; Invoke-DocsCommand.ps1 89.56% to 90.82%. No changed file dropped.
- Changed-line coverage: 96.14% (673/700) across all changed production files; per file 100.00% for every changed existing file except enforce-docs-complete-gate.ps1 96.55% (28/29). No regression on changed lines.
- Repo-wide Pester line coverage: 95.83% (37807/39454) baseline, 95.83% (38425/40095) final: no drop.
- pytest totals (evidence/baseline/pytest-baseline.2026-11-13T19-54.md vs evidence/qa-gates/final-qc-pytest.2026-11-13T23-39.md): line 97.11% to 97.11%, branch 94.37% to 94.37%: no drop.
- No value is missing; the outcome is PASS.
