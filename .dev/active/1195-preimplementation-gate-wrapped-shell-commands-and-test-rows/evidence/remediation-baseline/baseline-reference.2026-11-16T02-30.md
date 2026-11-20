# Remediation Cycle 1 Baseline Reference (P0-T1)

Timestamp: 2026-11-16T02-30
Plan: remediation-plan.2026-11-16T02-21.md
Command: git -C <worktree> rev-parse HEAD; git -C <worktree> fetch origin main; git -C <worktree> merge-base origin/main HEAD; git -C <worktree> status --porcelain; wc -l over the four classify copies and CASES; directory listing of FEATURE/evidence/baseline and FEATURE/evidence/qa-gates (no gate re-run)
EXIT_CODE: 0
Output Summary:
- CYCLE_BASE (branch HEAD before any change of this cycle): 995725d6974c3c18da21beb8f1e7a7d506de7a92
- MB (merge base of origin/main and HEAD): b58f045bc58d237129963543e445c7c8d2987772
- git status --porcelain: empty (no change inside or outside FEATURE).
- Physical line counts: .claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1 223; .codex/hooks copy 223; extensions/drm-copilot/resources/claude-customizations/.claude/hooks copy 223; extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks copy 223; tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1 180.
- Derived artifacts (lexicographically greatest match of each pattern):
  - Phase 0 baseline Pester: FEATURE/evidence/baseline/pester-gate.2026-11-15T23-35.md
  - Phase 0 baseline pytest: FEATURE/evidence/baseline/pytest-gate.2026-11-15T23-36.md
  - Prior-cycle final Pester: FEATURE/evidence/qa-gates/final-qc-pester.2026-11-16T01-31.md
  - Prior-cycle final pytest: FEATURE/evidence/qa-gates/final-qc-pytest.2026-11-16T01-45.md
  - Prior-cycle final static: FEATURE/evidence/qa-gates/final-qc-static.2026-11-16T01-20.md
- Copied figures:

| Figure | Phase 0 baseline | Prior-cycle final |
|---|---|---|
| Pester tests (passed / failed / skipped) | 27341 (27323 / 0 / 18) | 27484 (27466 / 0 / 18) |
| pytest (passed / failed / skipped) | 16957 / 0 / 6 | 16957 / 0 / 6 |
| Repo-wide PowerShell line coverage | 44785/46631, 96.04% | 44855/46701, 96.05% |
| .claude classify copy | 61/61, 100.00% | 96/96, 100.00% |
| .codex classify copy | 61/61, 100.00% | 96/96, 100.00% |
| .claude gate | 169/175, 96.57% | 169/175, 96.57% |
| .codex gate | 180/180, 100.00% | 180/180, 100.00% |
| Static (format / PSSA / leak scan) | n/a | 0 would change / 0 findings / exit 0 |

- Cycle reference figure for CLASSIFY: 96/96 lines, 100.00% (prior-cycle final Pester artifact).
- The two bundle copies of the classify sibling are not in the measured coverage population.
