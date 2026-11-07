# Documentation Workflow

This page describes how agents and maintainers build and maintain a documentation estate with the
documentation roles and skills.

## Roles

| Role | Responsibility |
|---|---|
| `docs-architect` | Inventories the documented surface and plans the information architecture; read-only, through the docs MCP tools. |
| `docs-author` | Writes and revises narrative and reference pages from the page templates; the only documentation role that writes files. |
| `docs-reconciler` | Records coverage dispositions, evidence pins and parity dimensions through `update_docs_ledger`; writes no file directly. |
| `docs-coverage-reviewer` | Reviews coverage and accuracy and validates `docs-complete` for one revision; read-only. |

The role definitions are under `.claude/agents/`.

## Skills

| Skill | Purpose |
|---|---|
| `documentation-workflow` | Runs the whole workflow from initialization to `docs-complete` validation by dispatching the other skills in order. |
| `docs-init` | Creates the docs profile and validates it; runs from the root session before any other docs skill. |
| `docs-inventory-surface` | Inventories the documented surface through the docs MCP tools. |
| `docs-plan-ia` | Plans pages, Diataxis modes, audiences and owners. |
| `docs-author-page` | Writes or revises one page from the template for its mode. |
| `docs-reconcile-behavior` | Records dispositions, pins and parity dimensions through `update_docs_ledger`, previewing each change as a dry run first. |
| `docs-review-coverage` | Reviews coverage, page accuracy and the surface delta of a branch, read-only. |
| `docs-validate` | Validates the artifacts for one mode and the head revision, read-only. |

The skills are under `.claude/skills/`.

## Sequence

1. Inventory: `docs-architect` runs `docs-inventory-surface` at a full revision.
2. Plan: `docs-architect` runs `docs-plan-ia`.
3. Author: `docs-author` runs `docs-author-page` for each planned page, and `generate-reference -Write`
   produces the reference pages.
4. Reconcile: `docs-reconciler` runs `docs-reconcile-behavior` to record dispositions, pins and
   parity dimensions.
5. Review: `docs-coverage-reviewer` runs `docs-review-coverage`.
6. Validate: `docs-coverage-reviewer` runs `docs-validate` with `validate -Mode docs-complete` at the
   head revision.

## Receipt Persistence

The roles validate without persisting a receipt, and `validate_docs_artifacts` never persists one.
The `docs-complete` receipt is persisted only from the root session or CI, with
`validate -Mode docs-complete -Revision <head revision> -WriteReceipt`.

## Integration-PR Gate

The gate is opt-in. When the docs profile sets `completion_gates.integration_pr_gate.enabled` to
`true`, the hook `.claude/hooks/enforce-docs-complete-gate.ps1` denies a `gh pr merge` of an epic
integration branch into `main` unless the persisted `docs-complete` receipt passes at the pull
request head revision. Its deny reasons start with `DOCS_COMPLETE_GATE_BLOCKED:`. Without the key
the hook allows every command.

## Surface-Delta Review Step

Before a change that alters the documented surface is merged, the root session runs
`surface-delta -Base <base revision or branch>`, and `docs-review-coverage` reviews the added,
changed and removed elements it reports, so that each one receives a ledger disposition and, when
documented, an updated page and pin.
