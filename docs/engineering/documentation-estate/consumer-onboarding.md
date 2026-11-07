# Consumer Onboarding

This page describes how a repository adopts the documentation-estate tooling. Examples run from a
PowerShell 7.4 session at the repository root; `command-reference.md` lists every option.

## Prerequisites

PowerShell 7.4 or later is required on PATH as `pwsh`. This is the provisional default of owner
question Q8 of the documentation-estate epic. Under a lower PowerShell version every subcommand
exits 3 with the finding `DOCS_RUNTIME_UNSUPPORTED`. No Node.js or Python runtime is required for
the helpers.

## Optional Python Pack

The optional python pack enables the native Python analyzer. With the pack pushed down and Python
3.11 or later available as `python3`, `python` or `py -3`, `inventory` runs the native analyzers for
`python-cli`, `python-http`, `python-public-api` and `python-architecture`, and their elements
record `analysis_method: native`. Python 3.11 is the floor that the native helper enforces (owner
decision of 2026-11-04 in the native analyzer feature, which raised it from 3.10).

Without the pack or a suitable interpreter, `inventory` falls back to the PowerShell scanner and
records `analysis_method: scanner`. `inventory -AnalysisMethod` takes `auto`, `native` or
`scanner`; the default is `auto`, which uses the native analyzer when it is available and the
scanner otherwise. `native` fails with `DOCS_PYTHON_NATIVE_UNAVAILABLE` when the native analyzer
cannot run, and `scanner` never starts a process.

A push-down without a pack selection places the inert Python helper under `.claude/lib/docs/python/`
in every destination. The helper is not run without an interpreter, so its presence changes
nothing for a repository that has no Python.

## Linting

Linting is optional. `init -Write` writes linter configuration as data: `.markdownlint.json`,
`.vale.ini`, `.vale/styles/DocsBase/HeadingPunctuation.yml`,
`.vale/styles/DocsBase/Placeholders.yml` and an empty
`.vale/styles/config/vocabularies/Project/accept.txt`. No Node.js or Python linter is required to
adopt the tooling. `check` is the required page gate: it checks page structure, metadata and links
without any external linter.

## Steps

1. Push down the Claude customizations from the drm-copilot extension, so the repository has
   `.claude/lib/docs/`.
2. Preview the files `init` would write:

   ```powershell
   & ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command init -RepositoryId example-repository
   ```

3. Write them with `init -Write`, then edit the docs profile at
   `docs/documentation-estate/docs-profile.json`.
4. Validate the profile with `validate-profile`.
5. Inventory the documentable surface at a full revision:

   ```powershell
   & ./.claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Revision 0123456789abcdef0123456789abcdef01234567 -Write
   ```

6. Record a disposition for every element with `update-ledger`, and pin each documented element to
   its page.
7. Generate the reference pages with `generate-reference -Write`.
8. Check the pages with `check`.
9. Validate correspondence with `validate -Mode docs-complete -Revision <full revision>`, and
   persist the receipt with `-WriteReceipt` from the root session or CI.

## Consumer CI

`init` also writes `.github/workflows/_docs-quality.yml`, a reusable workflow (`workflow_call`, also
runnable through `workflow_dispatch`) that runs the documentation commands through
`.claude/lib/docs/Invoke-DocsCommand.ps1` at the head revision, with an optional `surface-delta`
step against a `base-ref` input. A repository calls it from its own pull-request workflow. It
assumes `pwsh` (PowerShell 7.4 or later) on the runner (epic owner question Q4), and PowerShell is
the only runtime it uses.

## Using the Epic Template

To plan the estate as an epic, copy the template manually as its `README.md` describes:
`extensions/drm-copilot/resources/feature-templates/epic/documentation-estate/epic.md` goes to
`docs/features/epics/<slug>/epic.md`, and `/epic-plan docs/features/epics/<slug>/epic.md` plans the
children. No command copies the template.
