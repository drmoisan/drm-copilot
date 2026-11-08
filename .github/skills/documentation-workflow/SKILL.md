---
name: documentation-workflow
description: 'Run the documentation estate workflow from initialization to docs-complete validation by dispatching the seven docs skills in order. Use when a repository documentation estate must be created, extended or brought to docs-complete.'
---

# Documentation Workflow

## When to Use This Skill

Use this skill from the root session to run the whole documentation workflow, or
to resume it at a named step. It is an alias: it adds no tool call, receipt or
write authority of its own and dispatches to the seven skills below.

## Prerequisites

Root steps run `Invoke-DocsCommand.ps1` from the docs helper library that the Claude customization push-down delivers, under PowerShell 7.4 or later. Without that library every root step in this skill is unavailable; the docs MCP tools stay available.

## Dispatch Order

Run the skills in this order. Each step names the role that runs it; a root step
runs in the root session.

1. [docs-init](../docs-init/SKILL.md) (root): create and validate the docs profile.
2. [docs-inventory-surface](../docs-inventory-surface/SKILL.md) ([docs-architect](../../agents/docs-architect.agent.md)): inventory the documented surface.
3. [docs-plan-ia](../docs-plan-ia/SKILL.md) ([docs-architect](../../agents/docs-architect.agent.md)): plan the information architecture.
4. [docs-author-page](../docs-author-page/SKILL.md) ([docs-author](../../agents/docs-author.agent.md)): write and revise pages.
5. [docs-reconcile-behavior](../docs-reconcile-behavior/SKILL.md) ([docs-reconciler](../../agents/docs-reconciler.agent.md)): record dispositions, pins and dimensions.
6. [docs-review-coverage](../docs-review-coverage/SKILL.md) ([docs-coverage-reviewer](../../agents/docs-coverage-reviewer.agent.md)): review coverage and accuracy.
7. [docs-validate](../docs-validate/SKILL.md) ([docs-coverage-reviewer](../../agents/docs-coverage-reviewer.agent.md) or root): validate `docs-complete` for the head revision.

## Rules

- Pass each role its prepared inputs: `workspace_root`, the profile path and the
  outputs of the earlier steps.
- Read each role's report tokens before the next step. A `BLOCKED` or `FAIL`
  result stops the workflow until the cause is resolved.
- Every write of a profile artifact goes through a root step or through
  `update_docs_ledger`; no role writes the profile, the ledger, the matrix, the
  pins or a receipt directly.
