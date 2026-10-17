# P10-T25 Follow-ups record

Timestamp: 2026-10-09T05-57

## Process-spawning suites with independence not proven statically (from P5-T32)

Source artifact: `evidence/other/process-spawning-report.2026-10-09T05-29.md`. Each suite launches a hook as a child process. The differential of P1-T11 reported no difference for any of them, so the guard records `INDEPENDENCE-NOT-PROVEN-STATICALLY`, not a failure.

- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
- tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (the launched names `a.ps1` and `x.ps1` are fixture strings, not real hooks)
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
- tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
- tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1

## Production defects (from P1-T12)

NONE. The P1-T12 screen (`evidence/other/census-production-defects.2026-10-09T03-00.md`) recorded `PRODUCTION-DEFECTS: 0`. The one differential difference, `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, is a test-side local-state dependence resolved under DEV-2 (P5-T2); no hook or library file is edited under this feature.

## `.codex/hooks` no-Python findings (from P6-T8)

NONE. The P6-T8 run (`evidence/regression-testing/no-python-codex-pass-after.2026-10-09T05-35.md`) shows the extended scan over `.codex/hooks` with `Failed=0`, so no finding and no carve-out classification is outstanding.
