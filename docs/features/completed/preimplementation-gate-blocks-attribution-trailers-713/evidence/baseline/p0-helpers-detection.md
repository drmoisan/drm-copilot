# P0-T5 Merge-Order Detection (R-DETECT)

Timestamp: 2026-09-27T03-15
Command: sh <SCRATCHPAD>/x713-detect.sh (R-DETECT, script <SCRATCHPAD>/x713-detect.ps1)
EXIT_CODE: 0
Output Summary: The four helpers copies are byte-identical (BYTE_IDENTICAL: True), 497 lines each, LF only. All 16 old anchors count=1 in their expected regions; all 16 new anchors count=0. REDIRECTION_REF_LINES 2, OUTSIDE_QUOTE_REF_LINES 0, both token counts 0. #710's change is present (SIBLING_710_PRESENT: True). No stop condition applies.

PRE_EDIT_LINE_COUNT: 497
SIBLING_710_PRESENT: True

Output (verbatim):

```text
LINES: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
LINES: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 497
SHA256: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 EBE15355E3BD95F7CDC8AC64B0BD2F230DB88304FC21D8C1E6D7DA458F9C6F7A
CR_PRESENT: extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 False
BYTE_IDENTICAL: True
FUNCTION: Split-OrchestrationCommandLine start=58
FUNCTION: Test-OrchestrationCommandTextUnresolvable start=110
FUNCTION: ConvertTo-OrchestrationCommandToken start=163
FUNCTION: Test-ExemptOrchestrationOperand start=220
FUNCTION: Test-ExemptOrchestrationSelector start=278
FUNCTION: Test-ExemptOrchestrationSegmentToken start=339
FUNCTION: Test-ExemptOrchestrationStagingCommand start=438
ANCHOR: K1_OLD count=1 line=31 region=preamble
ANCHOR: K2_OLD count=1 line=32 region=preamble
ANCHOR: K3_OLD count=1 line=33 region=preamble
ANCHOR: K4_OLD count=1 line=34 region=preamble
ANCHOR: K5_OLD count=1 line=36 region=preamble
ANCHOR: U1_OLD count=1 line=115 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U2_OLD count=1 line=116 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U3_OLD count=1 line=117 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U4_OLD count=1 line=118 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U5_OLD count=1 line=138 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U6_OLD count=1 line=140 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: U7_OLD count=1 line=156 region=Test-OrchestrationCommandTextUnresolvable
ANCHOR: S1_OLD count=1 line=396 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: S2_OLD count=1 line=402 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: S3_OLD count=1 line=403 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: S4_OLD count=1 line=410 region=Test-ExemptOrchestrationSegmentToken
ANCHOR: K1_NEW count=0 line=0 region=none
ANCHOR: K2_NEW count=0 line=0 region=none
ANCHOR: K3_NEW count=0 line=0 region=none
ANCHOR: K4_NEW count=0 line=0 region=none
ANCHOR: K5_NEW count=0 line=0 region=none
ANCHOR: U1_NEW count=0 line=0 region=none
ANCHOR: U2_NEW count=0 line=0 region=none
ANCHOR: U3_NEW count=0 line=0 region=none
ANCHOR: U4_NEW count=0 line=0 region=none
ANCHOR: U5_NEW count=0 line=0 region=none
ANCHOR: U6_NEW count=0 line=0 region=none
ANCHOR: U7_NEW count=0 line=0 region=none
ANCHOR: S1_NEW count=0 line=0 region=none
ANCHOR: S2_NEW count=0 line=0 region=none
ANCHOR: S3_NEW count=0 line=0 region=none
ANCHOR: S4_NEW count=0 line=0 region=none
REDIRECTION_REF_LINES: 2
OUTSIDE_QUOTE_REF_LINES: 0
SIBLING_710_PRESENT: True
TOKEN_663_713_LINES: 0
TOKEN_COMMENT_INTRODUCER_LINES: 0
```
