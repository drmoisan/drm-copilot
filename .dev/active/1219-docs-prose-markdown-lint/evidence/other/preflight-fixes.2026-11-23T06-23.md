# Preflight Fixes

Timestamp: 2026-11-23T06-23
Plan: .dev/active/1219-docs-prose-markdown-lint/plan.2026-11-23T00-38.md
Command: single-pass preflight review (DIRECTIVE: PREFLIGHT VALIDATION ONLY); validators `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>` and MCP `validate_orchestration_artifacts` (artifact_type plan)
EXIT_CODE: 0
Output Summary: Eight trivial defects were fixed in place in task text. No task was added, removed, or reordered. Both validators passed before and after the fixes. Substantive defects are returned to the planner separately.

## Fixes

1. [P0-T3] | citation correction | "the four test files edited later" replaced with "the six existing test files edited later (the updated files named under `## Test Plan`)"; the plan edits six existing test files (DocsLedgerCommands, DocsPageTemplates, DocsProfileCommands, DocsInitTemplate.DocsWorkflow, docs-authoring-roles.Skills, DocumentationEstateOnboarding).
2. [P1-T1] | validator-blind: existing tests affected by the change not named | added unchanged dispositions for `DocsPageImportIsolation.Tests.ps1` (its `DocsPage*.psm1` filter picks up `DocsPagePlaceholder.psm1`), `Docs.Manifest.Tests.ps1`, and `DocsNeutrality.Tests.ps1`, which discover the new file from disk.
3. [P2-T1] | validator-blind: existing tests affected by the change not named | added unchanged dispositions for `It 'plans and writes no linter configuration at the repository root (issue #1169)'`, `Docs.Manifest.Tests.ps1`, and `DocsNeutrality.Tests.ps1` for the five new style files.
4. [P3-T2] | validator-blind: existing tests affected by the change not named | added unchanged dispositions for `It 'states that linting is optional and check is the required page gate'`, `It 'documents every Get-DocsCommandTable row with a heading and an example'`, and `It 'fails the statement check for an in-memory <Page> with its first token removed'`, which read the edited sections.
5. [P4-T2] | literal formatting (proof route) | the extracted install body is run with every other step `env:` value as committed, including `VALE_VERSION`; without it a body that composes the asset name from `VALE_VERSION` fails on the download and never reaches the hash comparison.
6. [P4-T3] | literal formatting (proof route) | staging names the source of every page-check row of `Get-DocsInitTemplate`, including the Project vocabulary `accept.txt` that `Vocab = Project` requires, instead of "every Vale style template".
7. [P4-T4] | write-mode observation (G7 class) | the format acceptance states its success observation: no log line beginning with `Formatted:`.
8. [P4-T5] | unanchored-state diff (G8 class) | the `DocsCoverageReport.psm1` check compares the working tree with the merge base of `origin/main` and `HEAD`, so uncommitted changes are included; the prior merge-base-to-`HEAD` form passes without checking anything when the change is not committed.
