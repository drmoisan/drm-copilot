# P1-T11 Differential comparison (without and with the local epic checkpoint)

Timestamp: 2026-10-09T03-00
Command: Route C: CR-COMPARE with BEFORE = P0-T12 artifact and AFTER = P1-T9 artifact, empty by-design list, via pwsh -NoProfile -File (result=EQUAL lines summarized by count; every other COMPARE line kept)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
BEFORE-ARTIFACT: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/pester-population-baseline.2026-10-09T02-31.md
AFTER-ARTIFACT: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/baseline/pester-population-with-local-checkpoint.2026-10-09T03-00.md
EQUAL-LINES: 176
COMPARE: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | result=DIFFERENT
COMPARE-DIFFERENT-COUNT: 1
