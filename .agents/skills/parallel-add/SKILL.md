---
name: parallel-add
description: Validate and append one prepared item to an authorized open Codex parallel run through the shared mutation authority. Use when the root session must admit a unique item without moving in-flight work or duplicating mutation semantics.
---

# Parallel Add

Use this skill only from the root session.
This root mutation skill is a validated client and does not delegate.

Accept one parallel slug plus one positive issue key. Operate only on the matching authorized
`artifacts/orchestration/parallel-orchestrator-state.json`; never create or start a run.

## Shared authority seam

Do not implement admission, recoloring, generation accounting, record construction, or checkpoint
validation in this skill. Invoke the repository authority exported by
`scripts/dev_tools/parallel_mutation_protocol.py`:

- `decide_admission` for the admission decision;
- `recolor_unstarted` only when that decision requires it;
- `build_add_entry` for the complete seven-field record.

Pass the candidate checkpoint through the public `validate_orchestration_artifacts` MCP path with
artifact type `parallel-orchestrator-state`. That MCP path applies the parity-complete TypeScript
mutation validator. Persist only when both the Python decision/result contract and MCP candidate
validation accept. Do not copy their decision tables or coloring algorithm into this file.

## Preconditions

1. Verify root mutation authority bound to the selected slug, checkpoint, and `add` operation.
2. Reconcile cached items, cohorts, branches, worktrees, PRs, launch status, mutation state, and
   drift state with durable repository truth.
3. Reject a closed run, unresolved drift, an invalid existing mutation log, an invalid item key,
   or a key already present anywhere in `items[]`, including withdrawn or terminal records.
4. Require the new item to be fully prepared before admission: active feature folder, research,
   `spec.md`, `user-story.md`, committed approved atomic plan, exact
   `PREFLIGHT: ALL CLEAR`, pushed branch, declared V1/V2-clear radius, and complete routing and
   preparation receipts. This non-delegating client rejects missing preparation; it does not
   launch a preparation child or perform implementation.

## Transaction

1. Derive the in-flight pin set and full current-cohort membership from reconciled state.
2. Derive normalized conflict edges against every active item through the shared blast-radius
   authority, including edges to pinned items.
3. Submit the item, conflicts, pin set, current cohort, and current generation to the Python
   mutation authority.
4. Apply only the returned decision and, when present, its returned unstarted-item cohort
   assignments. Reject any result that changes a pinned item's cohort, state, generation, branch,
   worktree, or launch identity.
5. Construct exactly one record with `build_add_entry`. Preserve its exact seven fields: `op`,
   `item_key`, `at`, `prior_state`, `new_state`, `disposition`, and `recolor_generation`.
6. Append it after the existing last record with a strictly later timestamp and the authority's
   expected generation. Never insert, replace, duplicate, or leave a recompute-generation gap.
7. Build the complete candidate checkpoint in memory and validate it through the MCP artifact
   path. On any finding, persist nothing.
8. Atomically persist the accepted item, conflict/cohort/batch result, generation, mutation record,
   and timestamp, then revalidate the stored checkpoint.

## Result

Report the item key, stable authority decision and reason code, old and new generation, assigned
cohort/batch position, appended record, Python/MCP validation results, and explicit confirmation
that no in-flight item moved. A rejection reports the reason and confirms that the checkpoint and
mutation log are unchanged.
