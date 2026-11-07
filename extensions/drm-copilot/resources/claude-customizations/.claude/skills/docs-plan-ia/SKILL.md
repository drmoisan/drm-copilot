---
name: docs-plan-ia
description: 'Plan the documentation information architecture: pages, Diataxis modes, audiences and owners. Use after the surface inventory, before any page is written.'
---

# Docs Plan IA

## When to Use This Skill

[docs-architect](../../../.claude/agents/docs-architect.md) runs this skill after
`docs-inventory-surface` to decide which pages exist, which Diataxis mode each
page uses and which surface elements each page covers.

## Prerequisites

Root steps run the docs helper library at `.claude/lib/docs/` under PowerShell 7.4 or later.

## Steps

1. Call `run_docs_coverage` with `workspace_root` and `profile` to list the
   elements without a documented, excluded or deferred disposition.
2. Call `run_docs_check` with `workspace_root`, `profile` and optionally `paths`
   to list the findings on existing pages.
3. Call `run_docs_inventory` again only when the surface changed during planning.
4. Assign each uncovered element to a planned page. Choose the Diataxis mode from
   the templates of `docs-author-page`: tutorial, how-to, explanation or one of
   the four reference families.
5. Give each planned page an owner and an audience from the profile.

## Result

Write a `## Information Architecture` section into the report with one line per
planned page: its repository-relative path, Diataxis mode, audience, owner and the
element ids it covers.
