# Scope Boundary (Issue #710, AC-7 and AC-11)

Timestamp: 2026-09-27T02-18
Command: git merge-base --is-ancestor b59d74e92d6b5d171f5d18bc5feb20bcd84fc7bb HEAD; git diff --numstat b59d74e92d6b5d171f5d18bc5feb20bcd84fc7bb HEAD; git status --porcelain; git diff -U0 b59d74e92d6b5d171f5d18bc5feb20bcd84fc7bb HEAD (hunk headers only)
EXIT_CODE: 0
Output Summary: BASE_ANCESTOR_EXIT 0. The numstat lists exactly the five section 2 paths 1 to 5; each of the four helper copies reads 5 added / 5 deleted; the new ChainEscape test file reads 198 added / 0 deleted. Porcelain lists only paths inside the feature folder. Every helper hunk (pre-image lines 63, 77, 78 in each copy) lies within the Split-OrchestrationCommandLine region [58, 108], so Test-ExemptOrchestrationOperand (base line 220), Test-OrchestrationCommandTextUnresolvable (base line 110), and ConvertTo-OrchestrationCommandToken (base line 163) are unchanged.

BASE_ANCESTOR_EXIT: 0

## Numstat (`git diff --numstat b59d74e92d6b5d171f5d18bc5feb20bcd84fc7bb HEAD`)

```text
5	5	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
5	5	.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
5	5	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
5	5	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
198	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1
```

## Porcelain (`git status --porcelain`)

```text
 M docs/features/active/preimplementation-helpers-backslash-chain-operator-710/plan.2026-09-26T22-56.md
?? docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/
```

No path outside the feature folder is listed.

## Hunk Headers

Recorded in [P2-T2] (`qa-gates/canonical-edit-checks.md`) for the canonical copy:

```text
@@ -63,4 +63,3 @@ function Split-OrchestrationCommandLine {
@@ -77 +76 @@ function Split-OrchestrationCommandLine {
@@ -78,0 +78 @@ function Split-OrchestrationCommandLine {
```

Observed now against `HEAD` for each of the four helper copies: the same three hunk headers, identically, in `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. The test file has the single hunk `@@ -0,0 +1,198 @@` (new file).

## Region Check

| Function (base) | Base start line | Contains a hunk |
| --- | --- | --- |
| `Split-OrchestrationCommandLine` | 58 (region end 108) | yes (pre-image 63, 77, 78) |
| `Test-OrchestrationCommandTextUnresolvable` | 110 | no |
| `ConvertTo-OrchestrationCommandToken` | 163 | no |
| `Test-ExemptOrchestrationOperand` | 220 | no |

Every pre-image start line (63, 77, 78) lies within [58, 108]. No hunk touches lines 110 onward, so `Test-ExemptOrchestrationOperand`, `Test-OrchestrationCommandTextUnresolvable`, and `ConvertTo-OrchestrationCommandToken` are unchanged in all four copies.
