---
name: parallel-remove
description: Validate and remove one tracked item from an authorized open Codex parallel run through the shared mutation authority. Use when the root session must withdraw unstarted work or explicitly detach or abandon one in-flight item.
---

# Parallel Remove

Use this skill only from the root session.
This root mutation skill is a validated client and does not delegate.

Accept one parallel slug, one positive issue key, and an explicit disposition only when the target
is in flight. Operate only on the matching authorized
`artifacts/orchestration/parallel-orchestrator-state.json`.

## Shared authority seam

Do not implement removal decisions, recoloring, record construction, or checkpoint validation in
this skill. Invoke `decide_removal`, `recolor_unstarted` when the returned decision requires it,
and `build_remove_entry` from `scripts/dev_tools/parallel_mutation_protocol.py`. Pass the complete
candidate through the public `validate_orchestration_artifacts` MCP path with artifact type
`parallel-orchestrator-state`. Persist only when the Python result and MCP validation accept. Do
not copy their decision table or coloring algorithm into this file.

## Preconditions

1. Verify root mutation authority bound to the selected slug, checkpoint, item, and `remove`
   operation, then reconcile durable item, branch, worktree, PR, launch, mutation, and drift state.
2. Fail closed for a closed run, unresolved drift, invalid mutation log, duplicate request,
   unknown or already withdrawn target, or a merged target. A rejected request changes nothing.
3. Preserve every in-flight item as pinned. Removing unstarted work may recolor only the remaining
   unstarted subgraph when the shared authority directs it.
4. For an in-flight target, require the explicit disposition `detach` or `abandon` and exact
   confirmation bound to all of: operation, item key, and canonical worktree identity. The token
   must be `confirm:<operation>:<item_key>:<worktree_identity>`. Missing or mismatched confirmation
   rejects before any state change or side effect.

## Transaction

1. Submit the reconciled item map, target key, requested disposition, current generation, pin set,
   and confirmation receipt to the shared authority path.
2. Apply only the returned decision. If it requires recomputation, invoke `recolor_unstarted` on
   the remaining unstarted items and reject any returned change to an in-flight item.
3. Construct exactly one record with `build_remove_entry`, preserving the exact fields `op`,
   `item_key`, `at`, `prior_state`, `new_state`, `disposition`, and `recolor_generation`.
4. Append after the current last record with a strictly later timestamp and the authority's
   expected generation. Never insert, replace, duplicate, or leave a generation gap.
5. Validate the complete candidate checkpoint through MCP before persistence. On any finding,
   persist nothing.
6. For `abandon`, execute only the repository's receipt-bound shared abandon path after candidate
   acceptance; never issue ad hoc destructive commands. Require its successful item/worktree-bound
   receipt before committing the accepted mutation.
7. Atomically persist the accepted state, any unstarted-only cohort changes, mutation record,
   generation, and disposition receipt, then revalidate the stored checkpoint.

## Result

Report the item key, stable decision and reason code, disposition, prior and new state, generation,
record, confirmation identity, Python/MCP validation results, and whether any unstarted cohorts
were recomputed. Confirm that no in-flight item moved. A rejection reports the reason and confirms
that the checkpoint, mutation log, worktree, and branch are unchanged.
