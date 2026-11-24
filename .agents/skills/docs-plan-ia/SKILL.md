---
name: docs-plan-ia
description: 'Plan the documentation information architecture: pages, Diataxis modes, audiences and owners. Use after the surface inventory, before any page is written.'
---

# Docs Plan IA

## When to Use This Skill

[docs-architect](../../../.codex/agents/docs-architect.toml) runs this skill after
`docs-inventory-surface` to decide which pages exist, which Diataxis mode each
page uses and which surface elements each page covers.

## Prerequisites

Root steps run `Invoke-DocsCommand.ps1` from the docs helper library that the Claude customization push-down delivers, under PowerShell 7.4 or later. Without that library every root step in this skill is unavailable; the docs MCP tools stay available.

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
6. Give each planned page a file name that does not contain the words `report`,
   `summary`, `findings` or `analysis`, or assign such a page to a root step: a
   subagent write of a Markdown page with one of those words in its name may be
   refused by the runtime.
7. Plan the documentation families. Read the `families` section of the
   `run_docs_coverage` result, which holds one entry per `required_families` item
   of the profile with its status (`present`, `missing` or `not-applicable`) and the
   `legacy_exclusions` list. For each `missing` family, plan at least one `.md` page
   under the family directory, or, when the family does not apply to the repository,
   plan an `exclusion` with a reason and `recorded_at` on the family in the profile.
   When the `security` family is required and has no `exclusion`, plan the
   repository-root `SECURITY.md` and `CODEOWNERS` files that its
   `missing_root_files` lists. Plan a move or retirement for each
   `legacy_exclusions` entry.

## Result

Write a `## Information Architecture` section into the report with one line per
planned page: its repository-relative path, Diataxis mode, audience, owner and the
element ids it covers.

Add one line per `required_families` entry with its id, directory, status and
planned pages or `exclusion` reason, one line per planned `SECURITY.md` or
`CODEOWNERS` file, and one line per `legacy_exclusions` entry with its planned move
or retirement.
