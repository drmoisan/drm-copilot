---
name: docs-author-page
description: 'Write or revise one documentation page from the template for its Diataxis mode, fill its front matter and link it from its root entry page. Use for every page docs-author writes.'
---

# Docs Author Page

## When to Use This Skill

[docs-author](../../../.claude/agents/docs-author.md) runs this skill for each page
planned in the `## Information Architecture` section of the `docs-architect`
report.

## Prerequisites

Root steps run the docs helper library at `.claude/lib/docs/` under PowerShell 7.4 or later.

## Templates

The templates live in the `templates/` folder of this skill, outside every
documentation root, so `run_docs_check` does not scan them.

| Template | `diataxis_mode` | Use when |
| --- | --- | --- |
| [tutorial.md](templates/tutorial.md) | `tutorial` | The page teaches a newcomer through a guided sequence that ends in a working result. |
| [how-to.md](templates/how-to.md) | `how-to` | The page gives the steps for one task a reader already understands. |
| [explanation.md](templates/explanation.md) | `explanation` | The page explains the context, design and trade-offs behind a part of the system. |
| [architecture-overview.md](templates/architecture-overview.md) | `explanation` | The page describes components, interactions, data flow, trust boundaries and failure domains of a system. |
| [cli-reference.md](templates/cli-reference.md) | `reference` | The page documents command-line commands, options and exit codes from surface elements. |
| [http-reference.md](templates/http-reference.md) | `reference` | The page documents HTTP routes, authentication and errors from surface elements. |
| [config-reference.md](templates/config-reference.md) | `reference` | The page documents configuration keys, precedence and defaults from surface elements. |
| [api-reference.md](templates/api-reference.md) | `reference` | The page documents public symbols and their usage from surface elements. |
| [product-overview.md](templates/product-overview.md) | `explanation` | The page states what a product is for, who uses it, how it is deployed and where support ends. |
| [onboarding.md](templates/onboarding.md) | `how-to` | The page walks one audience role through the first setup and its verification. |
| [runbook.md](templates/runbook.md) | `how-to` | The page lists diagnostic and remediation steps for a named trigger. |
| [playbook.md](templates/playbook.md) | `how-to` | The page coordinates roles, channels and runbooks during a named scenario. |
| [adr.md](templates/adr.md) | `explanation` | The page records one architecture decision with its context, alternatives and consequences. |
| [security.md](templates/security.md) | `explanation` | The page describes data classification, access, secrets, audit and vulnerability handling. |
| [service-management.md](templates/service-management.md) | `explanation` | The page covers service objectives, change and release management, or incident management. |
| [alerts-catalog.md](templates/alerts-catalog.md) | `reference` | The page lists alerts with condition, severity, owner and responding runbook. |

## Steps

1. Copy the template for the page's mode to the planned page path. Choose the
   template by family from the table above. A family page that covers no surface
   element uses `surface_refs: []`. An `alerts-catalog` page is a `reference` page
   and may need its own `directory_modes` entry in the docs profile when its
   directory holds pages of another mode. Replace every
   placeholder in the front matter: `owner`, `last_reviewed`, `audience`,
   `diataxis_mode` and `surface_refs` (the element ids the page covers). Each value
   is a JSON value on its own line.
2. For a reference page, call `generate_docs_reference` with `workspace_root`,
   `profile` and optionally `snapshot` and `output_directory`. The tool plans the
   generated blocks as a dry run and never writes pages. When the generated blocks
   must be written, report that the root step below is required.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference -Profile docs/documentation-estate/docs-profile.json -Write`
   To narrow a run to part of the source tree, pass `path_prefixes` (MCP) or
   `-PathPrefix <prefix>` (CLI, repeatable): only the snapshot elements whose
   `path` starts with one of the repository-relative prefixes (ordinal match) are
   generated; with no prefix every element is generated.
   A family page whose rendered size exceeds 921,600 UTF-8 bytes is split. The
   family path then holds an index page that links one page per group,
   `<output_directory>/<family-stem>/<group>.md`, where the group is the first
   path segment beneath the longest matching `surface_selection.source_roots`
   entry (`_root` otherwise); an oversize group continues in `<group>-<n>.md`.
   Existing split pages are updated in place. A split page whose group no longer
   exists is reported as `REFERENCE_SPLIT_GROUP_STALE` and is never deleted.
3. Write the prose around the generated-block markers. Do not edit the content
   between a `docs:generated:start` marker and its `docs:generated:end` marker.
4. Link every new page from its root entry page (`README.md` or `index.md` of its
   documentation root).
5. Call `run_docs_check` with `workspace_root`, `profile` and `paths` set to the
   pages written, and fix every finding the check reports on those pages.
6. A subagent write of a Markdown page whose name contains the words `report`,
   `summary`, `findings` or `analysis` may be refused by the runtime. Report such a
   page as unwritten; the root writes it.

## Result

Report the pages written and the exit code of the last `run_docs_check` call.
