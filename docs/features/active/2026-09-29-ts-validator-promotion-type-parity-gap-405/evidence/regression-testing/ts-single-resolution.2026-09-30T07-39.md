# P4-T3 validateRoutingContract resolves once

Timestamp: 2026-09-30T07-39

## Command 1
Command: git grep -c -F -e "resolvePromotionEntryTools(" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts
EXIT_CODE: 0
Output Summary: `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts:1` (one line contains the call, so the resolved list is computed once).

## Command 2
Command: git grep -c -F -e "./orchestrator-state-promotion-tools" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts
EXIT_CODE: 0
Output Summary: `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts:1` (one import line).

Behavioral proof that the one resolved value feeds both the equality check and the receipt loop is the test `rejects a bug-type large-route checkpoint that declares and records only new_potential_entry` in P3-T3 (19 passed), which asserts both errors.
