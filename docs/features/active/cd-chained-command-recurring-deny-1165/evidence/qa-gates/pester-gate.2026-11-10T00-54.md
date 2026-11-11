# Pester Final Gate (issue #1165)

Timestamp: 2026-11-10T00-54
Command: sh SCRATCH/issue-1165-pester.sh (pwsh 7 from the item worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; $result = Invoke-PoshQCParallelTest -Root <item worktree root>; exit [int]$result.ExitCode). Counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml by SCRATCH/issue-1165-pesterstats.ps1, SCRATCH/issue-1165-suites.ps1, and SCRATCH/issue-1165-ctx.ps1.
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=720.3s; returned ExitCode=0.
- Merged JUnit: tests=21311 passed=21301 failed=0 errors=0 skipped=10 (Phase 0 baseline: tests=21277 passed=21267 failed=0 skipped=10). No test that passed in the baseline fails.
- validate-bash.CdChainGuidance.Tests.ps1: decision regression corpus Context 60 total, 60 passed (baseline 60 passed); reason-shape Context 8 total, 8 passed.
- bash-command-shape-guidance.Tests.ps1: 22 tests, 0 failures.
- Venv suites: tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1 89 tests 0 failures; tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1 63 tests 0 failures.
- Suites named in [P1-T2] (all 0 failures, 0 errors):
  - tests/scripts/claude-hooks/validate-bash.Tests.ps1 tests=26 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 tests=16 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 tests=24 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 tests=16 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/review-verdict-status.HookAllowance.Tests.ps1 tests=12 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 tests=221 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 tests=17 failures=0 errors=0 skipped=0
  - tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 tests=731 failures=0 errors=0 skipped=0
  - tests/scripts/claude-runtime/claude-settings.Tests.ps1 tests=10 failures=0 errors=0 skipped=0
  - tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 tests=35 failures=0 errors=0 skipped=0
  - tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1 tests=56 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 tests=12 failures=0 errors=0 skipped=0
  - tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1 tests=13 failures=0 errors=0 skipped=0
  - tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 tests=37 failures=0 errors=0 skipped=0
  - tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 tests=8 failures=0 errors=0 skipped=0
  - tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 tests=11 failures=0 errors=0 skipped=0
  - tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests=43 failures=0 errors=0 skipped=0
  - tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 tests=100 failures=0 errors=0 skipped=0
  - tests/scripts/codex-hooks/enforce-worktree-poetry-venv.Tests.ps1 tests=63 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1 tests=89 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/bash-command-shape-guidance.Tests.ps1 tests=22 failures=0 errors=0 skipped=0
  - tests/scripts/claude-hooks/validate-bash.CdChainGuidance.Tests.ps1 tests=68 failures=0 errors=0 skipped=0
  - tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 tests=5 failures=0 errors=0 skipped=0
  - tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 tests=114 failures=0 errors=0 skipped=0
  - tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 tests=56 failures=0 errors=0 skipped=0
- Line coverage (final vs Phase 0 baseline):
  - Repo-wide: 95.80% (covered=37557 missed=1646) vs 95.79% (covered=37491 missed=1646).
  - .claude/hooks/bash-command-shape-guidance.ps1 (new file): 100.00% (covered=65 missed=0); threshold 85%.
  - .claude/hooks/validate-bash.ps1: 94.23% (covered=98 missed=6) vs 94.17% (covered=97 missed=6); no drop. Changed lines: the guarded dot-source statement (ci=3) and the cd-chained reason return statement in Get-BashBlockReason (ci=3) are covered; the comment line is not instrumented. The six missed lines are the pre-existing entry-point tail and the sed branch continue.
  - .claude/hooks/worktree-poetry-venv-policy.ps1: 100.00% (covered=117 missed=0) vs 100.00%; no drop.
  - .codex/hooks/worktree-poetry-venv-policy.ps1: 100.00% (covered=117 missed=0) vs 100.00%; no drop.
