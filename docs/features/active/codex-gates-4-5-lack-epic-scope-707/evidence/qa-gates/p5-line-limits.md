# Phase 5 Base Re-check and Line Limits ([P5-T1], AC-18)

Timestamp: 2026-09-27T07-22
Command: git merge-base HEAD daae7f796ebbd87e2170df3c86a9901ce11a4b68; then sh <SCRATCHPAD>/x707p1-run.sh x707p5-collect (fresh PowerShell 7 process, section `T1 LINE COUNTS`: `@(Get-Content -LiteralPath <path>).Count` for the 16 PowerShell paths of plan section 7)
EXIT_CODE: 0
Output Summary: Merge base daae7f796ebbd87e2170df3c86a9901ce11a4b68 equals BASE_SHA in p0-base-ref.md, so REBASED: no. 16 line counts recorded; the largest is 497 (legacy suite); every count is at most 500. The resolution sibling is 493 lines (limit 500) and the epic-scope sibling is 189 lines (limit 250).

Base-ref substitution: per the orchestrator directive the stale local `main` ref is replaced by the literal SHA daae7f796ebbd87e2170df3c86a9901ce11a4b68 (the value recorded as `BASE_SHA:` in `evidence/baseline/p0-base-ref.md`).

Merge-base output: `daae7f796ebbd87e2170df3c86a9901ce11a4b68`
Recorded BASE_SHA: `daae7f796ebbd87e2170df3c86a9901ce11a4b68`

REBASED: no

BASE_SHA in force for Phases 5 to 7: daae7f796ebbd87e2170df3c86a9901ce11a4b68

## Line counts (16 paths)

| Path | Lines | Limit |
| --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 487 | 500 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 189 | 250 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | 493 | 500 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 487 | 500 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 189 | 500 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` | 493 | 500 |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 322 | 500 |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 322 | 500 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` | 445 | 500 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` | 480 | 500 |
| `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` | 151 | 500 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 244 | 500 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 496 | 500 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` | 352 | 500 |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` | 492 | 500 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 497 | 500 |

Result: 16 counts recorded, all at most 500; `.codex/hooks` sibling counts 493 (at most 500) and 189 (at most 250). Because `REBASED: no`, the rebased-branch checks do not apply.
