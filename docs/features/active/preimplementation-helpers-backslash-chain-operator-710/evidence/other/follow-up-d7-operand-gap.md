# Follow-Up Record: D7 Operand Gap (Issue #710, AC-11)

Timestamp: 2026-09-27T02-17

Title: Unquoted .\. operand segments pass the staging exemption

Function: `Test-ExemptOrchestrationOperand` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three copies (`.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`).

Reproduction: the operand `docs/features/active/.\./.\./.\./src/x.ps1` in a `git add` command normalizes to `docs/features/active/././././././src/x.ps1` (each of the three `.\./` groups becomes two `./` segments under the `-replace '\\', '/'` at line 246 on base; the line number is unchanged after #710 because the #710 edit has a net line delta of zero), which has no `..` segment, while bash removes the escapes and stages `src/x.ps1`. This reproduction is analytical (research section 8, D-b); it has not been executed against a live hook.

Candidate fixes: reject `.` segments as LACS L5 does at `Test-ExemptOrchestrationSelector`, or treat an unquoted backslash adjacent to `.` as unresolvable; to be confirmed test-first.

Relation to #710: not widened or closed; the scanner change does not alter tokenization or operand normalization. The #710 edit is confined to `Split-OrchestrationCommandLine` (see `qa-gates/scope-boundary.md`).

Filing route: a separate issue promoted through `mcp__drm-copilot__potential_to_issue` by the orchestrator; this plan runs no `gh issue create`.
