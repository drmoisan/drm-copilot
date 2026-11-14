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

| Template | `diataxis_mode` |
| --- | --- |
| [tutorial.md](templates/tutorial.md) | `tutorial` |
| [how-to.md](templates/how-to.md) | `how-to` |
| [explanation.md](templates/explanation.md) | `explanation` |
| [architecture-overview.md](templates/architecture-overview.md) | `explanation` |
| [cli-reference.md](templates/cli-reference.md) | `reference` |
| [http-reference.md](templates/http-reference.md) | `reference` |
| [config-reference.md](templates/config-reference.md) | `reference` |
| [api-reference.md](templates/api-reference.md) | `reference` |

## Steps

1. Copy the template for the page's mode to the planned page path. Replace every
   placeholder in the front matter: `owner`, `last_reviewed`, `audience`,
   `diataxis_mode` and `surface_refs` (the element ids the page covers). Each value
   is a JSON value on its own line.
2. For a reference page, call `generate_docs_reference` with `workspace_root`,
   `profile` and optionally `snapshot` and `output_directory`. The tool plans the
   generated blocks as a dry run and never writes pages. When the generated blocks
   must be written, report that the root step below is required.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command generate-reference -Profile docs/documentation-estate/docs-profile.json -Write`
3. Write the prose around the generated-block markers. Do not edit the content
   between a `docs:generated:start` marker and its `docs:generated:end` marker.
4. Link every new page from its root entry page (`README.md` or `index.md` of its
   documentation root).
5. Call `run_docs_check` with `workspace_root`, `profile` and `paths` set to the
   pages written, and fix every finding the check reports on those pages.

## Result

Report the pages written and the exit code of the last `run_docs_check` call.
