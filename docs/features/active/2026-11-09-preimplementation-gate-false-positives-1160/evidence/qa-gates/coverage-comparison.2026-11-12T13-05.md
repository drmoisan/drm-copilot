# Coverage Comparison Against the Phase 0 Baseline (P5-T3)

Timestamp: 2026-11-12T13-05
Command: sh SCRATCH/issue-1160-summary.sh (git merge-base origin/main HEAD; git diff -U0 <merge base> HEAD for each gate file to list its changed line ranges; then PowerShell 7 reads the LINE counters and the per-line entries of artifacts/pester/powershell-coverage.xml written by the P5-T2 run)
EXIT_CODE: 0
Output Summary:
- Source: `artifacts/pester/powershell-coverage.xml` from the single P5-T2 gate run (`evidence/qa-gates/pester-gate.2026-11-12T13-03.md`). Baseline: `evidence/baseline/pester-gate.2026-11-10T04-19.md`.
- Repo-wide line coverage: baseline 95.80% (37558/39203) -> post-change 95.83% (37874/39521); no drop.
- New siblings (no pre-change run; threshold 90% for new code):
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`: 98.68% (75/76). PASS.
  - `.codex/hooks/enforce-orchestration-preimplementation-gate-commands.ps1`: 98.68% (75/76). PASS.
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`: 100.00% (78/78). PASS.
  - `.codex/hooks/enforce-orchestration-preimplementation-gate-bookkeeping.ps1`: 100.00% (78/78). PASS.
  - The one missed line in each commands copy is the `continue` of `Test-OrchestrationGateInvocationConfirmed` for an opaque `NoPayload` record that carries no governed word while the text carries none either.
- Gate files (baseline -> post-change):
  - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 96.32% (157/163) -> 96.43% (162/168); no drop. PASS.
  - `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: 100.00% (173/173) -> 100.00% (178/178); no drop. PASS.
- Changed-line coverage against the merge base of origin/main and HEAD (per-line entries of the same XML; AC-22):
  - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 17 changed lines, 9 executable, 9 covered = 100.00%, at or above the 96.32% baseline. PASS.
  - `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: 11 changed lines, 9 executable, 9 covered = 100.00%, at or above the 100.00% baseline. PASS.
- Every required figure is present; result: PASS (no remediation required).
- `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <FEATURE>/evidence/coverage/ (spec AC-22) replaced with <FEATURE>/evidence/qa-gates/`, as the plan preamble records.
