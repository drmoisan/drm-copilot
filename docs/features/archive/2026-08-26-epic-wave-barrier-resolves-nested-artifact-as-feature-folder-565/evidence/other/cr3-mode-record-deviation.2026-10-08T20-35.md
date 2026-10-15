# CR-3 Record: Find-OrchestrationModeRecord Left Unchanged

Timestamp: 2026-10-08T20-35
Command: grep -n "function Find-OrchestrationModeRecord" .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
EXIT_CODE: 0
Output Summary: The grep prints two matches, one per surface (line 327 in each file after the ED-1..ED-3 help and parameter lines; line 324 at the remediation base). Spec "Callers" (`FEATURE/spec.md` line 173) says `Find-OrchestrationModeRecord` becomes a thin delegate to the shared resolver. It was left unchanged on both surfaces. It compares with case-insensitive `-eq`, while `Find-FeatureFolderRecord` compares ordinally. Its existing semantics are pinned by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` lines 238-239 (first-match issue fallback) and line 297 (renamed-folder fallback), and the Codex copy iterates per record (`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` lines 340-351 at the remediation base). This cycle records the deviation and does not refactor. Conversion is a follow-up candidate for C1b (#732).

```
.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:327:function Find-OrchestrationModeRecord {
.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:327:function Find-OrchestrationModeRecord {
```
