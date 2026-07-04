# Phase 0 — Legacy-Shape Grep Baseline (13 PreToolUse hooks, runtime + mirror)

Timestamp: 2026-06-28T00-00
Command:
- grep -rn "decision = 'block'" .claude/hooks/ and the bundled mirror
- grep -rn "decision = 'allow'" .claude/hooks/ and the bundled mirror
- grep -rn "exit 1" .claude/hooks/validate-bash.ps1 (deny-path)
EXIT_CODE: 0

Mirror root: extensions/drm-copilot/resources/claude-customizations/.claude/hooks

## Aggregate counts (the set to be eliminated by Part 1)

| Legacy shape | Runtime occurrences | Mirror occurrences |
|---|---|---|
| `decision = 'block'` | 14 | 14 |
| `decision = 'allow'` | 51 | 51 |

## `decision = 'block'` occurrences (runtime)

- check-powershell-test-purity.ps1:105
- check-python-test-purity.ps1:41
- enforce-checkpoint-monotonic.ps1:265
- enforce-checkpoint-monotonic.ps1:280
- enforce-completion-consistency.ps1:390
- enforce-evidence-locations.ps1:98
- enforce-feature-folder-order.ps1:128
- enforce-orchestration-preimplementation-gate.ps1:181
- enforce-powershell-batch-budget.ps1:93
- enforce-pr-author-skill.ps1:287
- enforce-prd-feature-before-planner.ps1:183
- enforce-prd-feature-before-planner.ps1:196
- enforce-promotion-mcp-only.ps1:156
- enforce-python-batch-budget.ps1:90

(14 total; mirror has the same 14 at identical line numbers.)

## `decision = 'allow'` occurrences

51 occurrences in runtime, 51 in mirror, spanning: check-python-test-purity.ps1,
enforce-checkpoint-monotonic.ps1, enforce-completion-consistency.ps1,
enforce-evidence-locations.ps1, enforce-feature-folder-order.ps1,
enforce-orchestration-preimplementation-gate.ps1, enforce-powershell-batch-budget.ps1,
enforce-pr-author-skill.ps1, enforce-prd-feature-before-planner.ps1,
enforce-promotion-mcp-only.ps1, enforce-python-batch-budget.ps1. The
enforce-powershell-batch-budget and enforce-python-batch-budget allow literals carry sibling
keys `state` and `shouldWriteState` that must be preserved under the new
`hookSpecificOutput` envelope.

## Deny-path `exit 1`

- `.claude/hooks/validate-bash.ps1:64` (deny-path `exit 1`; the hook currently emits NO JSON
  on deny — highest priority, addressed in Phase 1).
- Mirror `validate-bash.ps1:64` carries the same deny-path `exit 1`.

These `exit 1` deny occurrences are the ones to be removed by Part 1. Error-path (malformed
JSON) `exit 1` in other hooks is RETAINED and is not part of this elimination set.

## Note on `check-powershell-test-purity.ps1`

This hook uses an inline plain `@{}` for its allow path rather than `[ordered]@{ decision =
'allow' }`, so it does not appear in the `decision = 'allow'` grep; its block literal at
line 105 does appear. Its restructuring is scoped to Phase 7 (out of this session's 0-5 range).
