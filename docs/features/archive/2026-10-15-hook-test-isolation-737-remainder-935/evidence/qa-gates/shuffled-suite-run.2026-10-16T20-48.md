# Seeded Shuffled Run of Touched Pester Suites (issue #935)

Timestamp: 2026-10-16T20-48
Head: `048d76cd8939319c08a9531015733dc53371795e` (origin/main merged; working tree equal to HEAD)
Command: python -I -c "random.Random(935).shuffle(<13 suite paths>)" to fix the order, then mcp__drm-copilot__run_poshqc_test with workspace_root = the item worktree and scan_folders = the 13 suite paths in that order; per-suite results read from `artifacts/pester/pester-junit.xml` (written 2026-10-16 16:48 local, by this call) with the D-JUNIT membership rule
EXIT_CODE: 0
Seed: 935
Output Summary:
- Call disposition: returned without error.
- Suite set: the 11 `.Tests.ps1` files in `git diff --name-only origin/main...HEAD -- tests` plus the two unchanged consumers of the split helpers (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`).
- Shuffled order and results (testcases / passed):
  1. tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1: 20 / 20
  2. tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1: 61 / 61
  3. tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1: 54 / 54
  4. tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: 365 / 365
  5. tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1: 16 / 16
  6. tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1: 41 / 41
  7. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1: 47 / 47
  8. tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1: 10 / 10
  9. tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1: 5 / 5
  10. tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1: 25 / 25
  11. tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1: 6 / 6
  12. tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1: 32 / 32
  13. tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1: 60 / 60
- Total: 742 testcases, 742 passed, 0 failed or skipped.
- Split equations (local, against the P7-T1 baseline): worktree-removal 47 + 5 = 52 = 51 + 1; prd-feature 20 + 6 = 26 = 25 + 1; command-exemption 60 + 61 = 121 = 120 + 1; consumers 32 = 32 and 54 = 54.
- Limitation: the MCP runner executes the listed paths in one Pester run; the seed fixes the container order passed to it. Pester does not randomise test order within a container.
