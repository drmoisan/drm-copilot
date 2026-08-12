---
name: parallel-close
description: Validate and close one authorized open Codex parallel run through the shared mutation authority. Use when the root session must end admissions after all in-flight work has stopped.
---

# Parallel Close

Use this skill only from the root session.
This root mutation skill is a validated client and does not delegate.

Accept one parallel slug and operate only on the matching authorized
`artifacts/orchestration/parallel-orchestrator-state.json`. Closing ends admission; it does not
launch, detach, abandon, merge, or otherwise mutate an item.

## Shared authority seam

Do not implement close admission, completion, record construction, or checkpoint validation in
this skill. Invoke `decide_close` and `build_close_entry` from
`scripts/dev_tools/parallel_mutation_protocol.py`. Pass the complete candidate through the public
`validate_orchestration_artifacts` MCP path with artifact type `parallel-orchestrator-state`.
Persist only when the Python result and MCP validation accept. Do not copy their decision table or
completion algorithm into this file.

## Preconditions

1. Verify root mutation authority bound to the selected slug, checkpoint, and `close` operation,
   then reconcile durable item, branch, worktree, PR, launch, mutation, and drift state.
2. Require a valid open-mode run with a valid complete mutation log and no unresolved drift.
   Reject a closed run, a duplicate close, and any other invalid candidate without writing state.
3. Submit the complete reconciled item map to `decide_close`. If any item is in flight, reject the
   close, report every blocking key returned by the authority, and persist nothing.

## Transaction

1. Apply only the shared authority's accepted close decision; never infer completion or remove an
   item as part of closing.
2. Construct exactly one run-scoped record with `build_close_entry`, preserving the exact fields
   `op`, `item_key`, `at`, `prior_state`, `new_state`, `disposition`, and
   `recolor_generation`. Closing does not recolor items.
3. Append after the current last record with a strictly later timestamp and the authority's
   expected generation. Never insert, replace, duplicate, or leave a generation gap.
4. Build the complete candidate checkpoint in memory and validate it through MCP. On any finding,
   persist nothing.
5. Atomically persist the accepted closed mode, close record, generation, and timestamp, then
   revalidate the stored checkpoint. Reject every later add, remove, or duplicate close mutation.

## Completion contract

An open-mode run cannot complete until this explicit close transaction is accepted and persisted.
After close, apply only the shared closed-mode completion authority; this skill does not duplicate
its terminal-item predicate. A rejected close leaves mode and completion state unchanged.

## Result

Report the stable close decision and reason code, prior and new mode, generation, appended record,
Python/MCP validation results, and explicit confirmation that no item, cohort, branch, worktree, or
launch identity changed. A rejection reports the blocking reason and confirms the checkpoint and
mutation log are unchanged.
