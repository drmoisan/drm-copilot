---
name: docs-reconcile-behavior
description: 'Record coverage dispositions, evidence pins and parity dimensions through update_docs_ledger, previewing each change as a dry run first. Use when coverage findings or review judgments must be written to the estate artifacts.'
---

# Docs Reconcile Behavior

## When to Use This Skill

[docs-reconciler](../../../.claude/agents/docs-reconciler.md) runs this skill to
turn coverage findings and review judgments into ledger, matrix and pin changes.
`update_docs_ledger` is the only tool that changes those artifacts.

## Prerequisites

Root steps run the docs helper library at `.claude/lib/docs/` under PowerShell 7.4 or later.

## Steps

1. Call `run_docs_coverage` with `workspace_root` and `profile` to list the
   uncovered elements.
2. For each change, call `update_docs_ledger` with `workspace_root`, `profile`,
   `operation` and the fields the operation needs:
   - `set-disposition`: exactly one of `element` and `limit`, `disposition`
     (`documented`, `excluded` or `deferred`), and optionally `pages`,
     `rationale`, `owner` and `target`;
   - `remove-entry`: exactly one of `element` and `limit`;
   - `pin`: `element`, `pages` with exactly one page without an anchor, and
     optionally `claim`;
   - `unpin`: `element` and `pages` with exactly one page without an anchor;
   - `set-dimension`: `element`, `pages` with exactly one page without an anchor,
     `dimension` (`exists`, `accurate`, `example_present`, `owner_assigned` or
     `diataxis_mode`), `state` (`pass`, `fail`, `not-assessed` or
     `not-applicable`), and optionally `rationale`;
   - `sync-refs`: no element, limit or page field; it refreshes the snapshot and
     ledger pins only;
   - `bind-page-refs`: no element, limit or page field; it binds every snapshot
     element named in the front-matter `surface_refs` of a page as `documented`
     with the union of its pages, warns for an unknown id and removes no binding.
   `pin` must precede `set-dimension` with `dimension: accurate` and
   `state: pass` for the same element and page; without the pin the change is
   rejected with `DOCS_MATRIX_ACCURACY_UNPINNED`.
   Always supply `actor_kind: agent` and `actor_id: docs-reconciler`. Call first
   without `write` (a dry run), read the planned change, then call again with
   `write: true` only for the change that is applied.
   For many changes, call `update_docs_ledger` once with `operations` (an array
   of items with the fields above) instead of `operation`; the CLI form is
   `-Operations <path>` or `-Operations -` (standard input). The batch is
   all-or-nothing: an invalid item, an unknown target or an introduced error
   rejects the whole batch, names the item index and writes nothing. sync-refs is
   not a batch item; run it as its own call. A `set-dimension` item with
   `dimension: accurate` and `state: pass` may carry `claim`, which pins the page
   first.
3. Call `validate_docs_artifacts` with `workspace_root`, `profile`, `mode`
   (`ledger` or `matrix`) and `revision` to confirm the artifacts stay valid. The
   tool never persists a receipt.
4. When the MCP server is unavailable, the root session can apply the same change.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command update-ledger -Profile docs/documentation-estate/docs-profile.json -Operation sync-refs -ActorKind human -ActorId <operator-id> -Write`

## Result

Report the number of applied operations, the exit code of the last
`update_docs_ledger` call and the element ids changed.
