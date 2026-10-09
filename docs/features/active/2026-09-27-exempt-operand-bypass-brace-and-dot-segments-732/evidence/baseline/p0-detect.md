# Phase 0 Anchor Detection (issue #732)

Timestamp: 2026-10-09T03-09
Task: [P0-T10]
ROUTE: sh-launcher
Command: sh <SCRATCHPAD>/c1b732/p0-t10.sh (R-DETECT over the [P0-T10] anchors)
EXIT_CODE: 0

## Output

```text
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
SHA256: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
SHA256: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
CR_PRESENT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
SHA256: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
CR_PRESENT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
SHA256: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 DC4E7DA545D2A8DADF9C11CDD0F1B08A5485ECAE2EE3AE2C1E090835035B0D65
FUNCTION: Split-OrchestrationCommandLine start=58
FUNCTION: Test-OrchestrationCommandTextUnresolvable start=110
FUNCTION: ConvertTo-OrchestrationCommandToken start=163
FUNCTION: Test-ExemptOrchestrationOperand start=220
FUNCTION: Test-ExemptOrchestrationSelector start=278
FUNCTION: Test-ExemptOrchestrationSegmentToken start=339
FUNCTION: Test-ExemptOrchestrationStagingCommand start=438
ANCHOR: E1 mode=whole count=1 line=10 region=preamble
ANCHOR: K1 mode=whole count=1 line=31 region=preamble
ANCHOR: K2 mode=whole count=1 line=32 region=preamble
ANCHOR: K3 mode=whole count=1 line=33 region=preamble
ANCHOR: K4 mode=whole count=1 line=35 region=preamble
ANCHOR: K5 mode=whole count=1 line=38 region=preamble
ANCHOR: K6 mode=whole count=1 line=39 region=preamble
ANCHOR: E3a mode=whole count=1 line=115 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: E3b mode=whole count=1 line=120 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: B1 mode=whole count=1 line=130 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: B2 mode=whole count=1 line=131 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: E5a mode=whole count=1 line=144 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: E6 mode=whole count=1 line=220 region=Test-ExemptOrchestrationOperand
ANCHOR: S1 mode=whole count=1 line=447 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: S2 mode=whole count=1 line=467 region=Test-ExemptOrchestrationStagingCommand
ANCHOR: S3 mode=whole count=1 line=468 region=Test-ExemptOrchestrationStagingCommand
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 489
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 False
ANCHOR: CX1 mode=whole count=1 line=4 region=preamble
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 279
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 False
ANCHOR: ES-C mode=whole count=1 line=240 region=Get-OrchestrationEpicScopeDecision
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 189
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 False
ANCHOR: ES-X mode=whole count=1 line=150 region=Get-OrchestrationEpicScopeDecision
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 493
CR_PRESENT: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 False
ANCHOR: CE-C-IT mode=whole count=1 line=106 region=preamble
ANCHOR: CE-C-AS mode=whole count=1 line=115 region=preamble
ANCHOR: CE-C-L3 mode=prefix count=1 line=310 region=preamble
ANCHOR: CE-C-L7 mode=prefix count=1 line=339 region=preamble
LINES: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 496
CR_PRESENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 False
ANCHOR: CE-X-IT mode=whole count=1 line=106 region=preamble
ANCHOR: CE-X-AS mode=whole count=1 line=115 region=preamble
ANCHOR: CE-X-L3 mode=prefix count=1 line=313 region=preamble
ANCHOR: CE-X-L7 mode=prefix count=1 line=342 region=preamble
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 198
CR_PRESENT: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 False
ANCHOR: CH-IT mode=whole count=1 line=177 region=preamble
ANCHOR: CH-AS mode=whole count=1 line=185 region=preamble
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 103
CR_PRESENT: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 False
ANCHOR: TR-A mode=prefix count=1 line=55 region=preamble
ANCHOR: TR-D mode=prefix count=1 line=93 region=preamble
LINES: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 362
CR_PRESENT: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 False
ANCHOR: G1 mode=whole count=1 line=232 region=preamble
ANCHOR_IN_BLOCK: G2 line=247 owner=G1
ANCHOR: G3 mode=whole count=1 line=248 region=preamble
LINES: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 480
CR_PRESENT: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 False
ANCHOR: H1 mode=whole count=1 line=213 region=preamble
ANCHOR_IN_BLOCK: H2 line=227 owner=H1
LINES: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 497
CR_PRESENT: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 False
ANCHOR: LG1 mode=contains count=1 line=30 region=preamble
LINES: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json 214
CR_PRESENT: extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json False
ANCHOR: MF-C mode=contains count=1 line=42 region=preamble
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json 128
CR_PRESENT: extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json False
ANCHOR: MF-X mode=contains count=1 line=44 region=preamble
LINES: .claude/skills/epic-plan/SKILL.md 231
CR_PRESENT: .claude/skills/epic-plan/SKILL.md False
ANCHOR: QR-E mode=prefix count=1 line=214 region=preamble
LINES: .claude/skills/parallel-plan/SKILL.md 661
CR_PRESENT: .claude/skills/parallel-plan/SKILL.md False
ANCHOR: QR-P mode=prefix count=1 line=639 region=preamble
LINES: .agents/skills/epic-plan/SKILL.md 231
CR_PRESENT: .agents/skills/epic-plan/SKILL.md False
ANCHOR: AG1 mode=whole count=1 line=61 region=preamble
ANCHOR: AG2 mode=whole count=1 line=66 region=preamble
BYTE_IDENTICAL: True
HRS_COUNT: 39
```

Output Summary: PASS. BYTE_IDENTICAL True (four helpers copies); all 41 ANCHOR lines report the listed mode and count=1, every listed region matches (no REGION_MISMATCH); ANCHOR_IN_BLOCK G2 line=247 and H2 line=227; LINES: Codex gate 489 (<=493), Claude epic-scope 279 and Codex epic-scope 189 (<=420), AttributionTrailer 103 (<=495), CommandExemption 493 / 496, ChainEscape 198, EpicScope 362 / 480, legacy-codex 497 (<=500); no HRS_MISSING line (HRS_COUNT 39); no CR in any anchored file.
