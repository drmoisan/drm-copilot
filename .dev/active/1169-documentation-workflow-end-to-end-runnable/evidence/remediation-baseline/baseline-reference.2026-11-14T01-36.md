# Baseline Reference (Remediation Cycle 1, P0-T2)

Timestamp: 2026-11-14T01-36
Command: read of recorded evidence (no test run): evidence/baseline/pester-baseline.2026-11-13T19-48.md, evidence/qa-gates/coverage-comparison.2026-11-13T23-48.md, evidence/baseline/pytest-baseline.2026-11-13T19-54.md; then git -C <item worktree> grep -l Get-OrchestrationDocsEstateFileText -- tests | wc -l
EXIT_CODE: 0
Output Summary:
- Pester Phase 0 baseline (pester-baseline.2026-11-13T19-48.md): 21666 tests, 21656 passed, 0 failed, 10 skipped; repo-wide line coverage 95.83% (37807/39454).
- Per-file reference (coverage-comparison.2026-11-13T23-48.md):
  - .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: 94.20% (130/138)
  - .codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: 91.30% (126/138)
  - .claude/hooks/hook-docs-estate-context.ps1: 100.00% (58/58)
  - .codex/hooks/hook-docs-estate-context.ps1: 96.55% (56/58)
  - .claude/lib/docs/DocsCompleteGate.psm1: 100.00% (38/38)
- pytest Phase 0 baseline (pytest-baseline.2026-11-13T19-54.md): 16598 passed, 0 failed, 6 skipped; line 97.11% (34334/35355); branch 94.37% (12668/13424).
- Observed file count of `git grep -l Get-OrchestrationDocsEstateFileText -- tests`: 39 (39 expected).
- Context only (not the reference): the post-main-sync gates (post-main-sync-gates.2026-11-14T00-06.md) recorded Pester 22643 passed, 0 failed, repo-wide 95.84% (39196/40897), and pytest 16676 passed, 0 failed, line 97.13%, branch 94.41%.
