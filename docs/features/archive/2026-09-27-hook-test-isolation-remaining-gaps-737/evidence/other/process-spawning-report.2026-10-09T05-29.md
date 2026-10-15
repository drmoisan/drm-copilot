# P5-T32 Process-spawning evidence for AC-5

Timestamp: 2026-10-09T05-29
Command: Route C: Get-EpicStateProcessSpawningReport over the Claude and Codex populations (CR-ENUM derivation) via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT-TOTAL: 6
DIFFERENT-SOURCE: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/differential-before.2026-10-09T03-00.md
DIFFERENT-COUNT: 1
DEV-2: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | NOT-IN-REPORT | FIX=docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/dev2-e4-isolation.2026-10-09T04-06.md
INDEPENDENCE-NOT-PROVEN-STATICALLY: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
INDEPENDENCE-NOT-PROVEN-STATICALLY: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1
INDEPENDENCE-NOT-PROVEN-STATICALLY: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
INDEPENDENCE-NOT-PROVEN-STATICALLY: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
INDEPENDENCE-NOT-PROVEN-STATICALLY: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
INDEPENDENCE-NOT-PROVEN-STATICALLY: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1
EXIT_CODE_COMPUTED: 0
