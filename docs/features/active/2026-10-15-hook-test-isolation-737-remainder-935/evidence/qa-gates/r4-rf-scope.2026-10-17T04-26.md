# R4 Phase 6 scope (P6-T27, pre-mortem risk 2)

Timestamp: 2026-10-17T04-26
Command: git diff --name-only origin/main...HEAD; git diff --name-only 009f7d0c763b6e4ce360d6e10824ed0463771093 HEAD (MERGE-COMMIT from qa-gates/r4-rf-merge.2026-10-17T03-25.md); git status --porcelain
EXIT_CODE: 0
Output Summary:
- Branch diff (origin/main...HEAD, merge-base 7516050be): 69 paths: 60 under FEATURE/ (the feature-folder documents and evidence) and the nine CODE9 paths:
  - tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
  - tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
  - tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
  - tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1
  - tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
  - tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1
  - tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
  - tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
  - tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1
  No path begins .claude/, .codex/, .github/, extensions/, scripts/ or config/; none of the seven AC-6 suites, no validate- suite, no hook-dependency-failure suite, no enforce-orchestration-preimplementation-gate-modes suite and not tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1.
- Review-fix diff (MERGE-COMMIT..HEAD), 17 paths:
  - FEATURE/evidence/other/r4-ac-recheck-note.2026-10-17T03-42.md
  - FEATURE/evidence/qa-gates/r4-plan-validation.2026-10-17T03-55.md
  - FEATURE/evidence/qa-gates/r4-rf-cr-g7-analyze.2026-10-17T03-48.md
  - FEATURE/evidence/qa-gates/r4-rf-merge.2026-10-17T03-25.md
  - FEATURE/evidence/qa-gates/r4-rf-merged-tree-test.2026-10-17T03-41.md
  - FEATURE/evidence/qa-gates/r4-rf-prestate.2026-10-17T03-24.md
  - FEATURE/evidence/qa-gates/r4-rf-ps-test-fixes.2026-10-17T03-54.md
  - FEATURE/evidence/qa-gates/r4-rf-runner.2026-10-17T03-26.md
  - FEATURE/evidence/regression-testing/r4-rf-cr-g3-fail-before.2026-10-17T03-46.md
  - FEATURE/remediation-plan.2026-10-16T20-56.md
  - FEATURE/spec.md
  - tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1
  - tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1
  - tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1
  - tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
  - tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1
  - tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1
  FEATURE/evidence/other/cov1-decision-option1.2026-10-16T20-38.md is absent.
- git status --porcelain:
  - " M FEATURE/remediation-plan.2026-10-16T20-56.md"
  - "?? FEATURE/evidence/qa-gates/r4-ps-test-repo.2026-10-17T04-25.md"
  - "?? FEATURE/evidence/qa-gates/r4-rf-line-counts.2026-10-17T04-26.md"
  - "?? FEATURE/evidence/qa-gates/r4-rf-loop-status.2026-10-17T04-26.md"
  - "?? FEATURE/evidence/qa-gates/r4-rf-order-check.2026-10-17T04-12.md"
  - "?? FEATURE/evidence/qa-gates/r4-rf-ps-analyze.2026-10-17T03-56.md"
  - "?? FEATURE/evidence/qa-gates/r4-rf-ps-format.2026-10-17T03-56.md"
  - "?? FEATURE/evidence/qa-gates/r4-rf-ps-test.2026-10-17T04-06.md"
  No path outside FEATURE/ and .claude/agent-memory/.
