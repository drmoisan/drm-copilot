# Phase 0 Tolerance-Layer Detection (P0-T29)

Timestamp: 2026-09-27T14-54

Run after the P0-T16 sync (HEAD contains origin/main beae3f02).

## Decisive search

Command: git grep -n -E "conflict_tolerance|overlap_tolerance|integration_cost|conflictTolerance|overlapTolerance|integrationCost" -- scripts .claude/lib .claude/hooks .codex extensions/drm-copilot/src config packages

EXIT_CODE: 1

Output: (no match lines)

## Informational search (not used for the decision)

Command: git grep -n -i -E "tolerance" -- scripts .claude/lib .claude/hooks config

EXIT_CODE: 0

Output:

```
.claude/lib/hook-payload/HookPayload.psm1:416:        Property-level tolerance lives here: an absent property returns an empty
.claude/lib/mermaid/MermaidMarkdownFences.psm1:280:    # Unclosed-fence tolerance: report whatever body was collected so a diagram at
.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1:298:        tolerance rather than fabricating a structural error.
scripts/dev_tools/_parallel_state_structures.py:72:# the loose tolerance of the standard checkpoint validators.
scripts/dev_tools/_parallel_state_structures.py:478:    deliberately not inspected, matching the loose tolerance the standard
```

All five matches are parse- or payload-tolerance comments. None is a scheduling tolerance layer.

## Positive control

Command: grep -c -E "conflict_tolerance" docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2/spec.md

EXIT_CODE: 0

Output: 1

The count is at least 1, which shows the pattern syntax matches its target.

TOLERANCE_BRANCH: NOT FOUND

Output Summary: The decisive search printed no match line and exited 1, the expected exit code for branch NOT FOUND. The positive control matched (count 1). Branch NOT FOUND is selected: both consumers take the pre-authorized skip branch for the tolerance test.
