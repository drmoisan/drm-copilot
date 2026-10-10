# P1-T7 Process-spawning cross-check by two derivations

Timestamp: 2026-10-09T02-37
Command: Route C: Strategy 1 = process-spawning=True suites in the P1-T6 census artifact; Strategy 2 = Select-String over LIST-POP (ProcessStartInfo, the process-start cmdlet name, -NoProfile; and a hooks/<name>.ps1 literal), via pwsh -NoProfile -File
EXIT_CODE: 0
Output Summary:
CENSUS-ARTIFACT: docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/regression-testing/census-fail-before.2026-10-09T02-37.md
STRATEGY-1-COUNT: 5
STRATEGY-2-COUNT: 18
STRATEGY-2-ONLY: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/enforce-pr-author-skill.Issue824.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1
CLASSIFICATION: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1
CLASSIFICATION: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
STRATEGY-2-ONLY: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
CLASSIFICATION: tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | S2-ONLY-NO-PROCESS-START-TOKEN
CROSSCHECK-DIFFERENCES: 13
CROSSCHECK-UNEXPLAINED: 0
DETECTION-GAP-COUNT: 0
