# Phase 5 D10 Mock Scope ([P5-T4], AC-14)

Timestamp: 2026-09-27T07-22
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p5-collect (fresh PowerShell 7 process, section `T4 MOCK SCOPE`: `[System.Management.Automation.Language.Parser]::ParseFile` per file; locate every `CommandAst` whose extent text equals `Mock Get-EpicScopeCheckpointText { $null }`; walk parents to the nearest `BeforeAll`/`BeforeEach` invocation and then to that block's nearest `Describe`/`Context` invocation)
EXIT_CODE: 0
Output Summary: Five MOCK-SCOPE lines, each reading `BeforeAll Describe`; each of the five section 4.4 files carries exactly one such mock (MOCK-COUNT 1).

## Output

```
MOCK-COUNT: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | 1
MOCK-SCOPE: tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | BeforeAll Describe
MOCK-COUNT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | 1
MOCK-SCOPE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | BeforeAll Describe
MOCK-COUNT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | 1
MOCK-SCOPE: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | BeforeAll Describe
MOCK-COUNT: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | 1
MOCK-SCOPE: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | BeforeAll Describe
MOCK-COUNT: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 1
MOCK-SCOPE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | BeforeAll Describe
```
