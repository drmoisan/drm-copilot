# docs-prose-markdown-lint — User Story

- Issue: #1219
- Epic: #1217 (documentation-estate-families)
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-23
- Spec: `.dev/active/1219-docs-prose-markdown-lint/spec.md`

## Story Statement

- As a consumer repository maintainer, I want the init-written `_docs-quality.yml` to run Markdown lint and a pinned, checksum-verified Vale release against my documentation pages, so that Markdown and prose defects are reported in CI without my writing or maintaining linter steps.
- As a consumer repository maintainer, I want every action and the Vale binary pinned to an exact commit or hash under read-only permissions, so that the workflow cannot run code I have not reviewed.
- As a documentation author, I want tonality rules that report hyperbole, unsupported certainty, filler, exclamations, and intensifiers, so that pages follow the repository tonality policy before review.
- As a documentation author, I want to mark unfinished content with `SME input required` and see its count in docs coverage output, so that I can track which pages still need subject-matter-expert input.

## Problem / Why

The workflow template that docs init writes copies `.vale.ini` and `.markdownlint.json` into a consumer repository but runs neither tool, so prose and Markdown defects in documentation pages are not reported in CI. The default Vale style set has no rule tied to the tonality policy, and pages have no counted placeholder for content that needs subject-matter-expert input. The docs-init skill and the onboarding page state that no workflow step runs the linters; that statement becomes false with this change.

## Personas and Scenarios

- Persona: consumer repository maintainer
  - Owns CI for a repository that adopted the documentation workflow through docs init.
  - Cares about supply-chain integrity (pinned actions and binaries, least-privilege permissions) and about findings that arrive in one CI run.
  - Constraint: does not want a second runtime (Node or Python setup) added to the docs workflow.
- Persona: documentation author
  - Writes and revises pages under the profile's documentation roots.
  - Cares about clear findings that name the rule and the line, and about knowing which pages are unfinished.
  - Constraint: some pages document the placeholder token itself in code examples; those uses must not be counted.

- Scenario: first CI run after re-initialization
  1. The maintainer runs docs init with `-Write -Force` to receive the new workflow, `.vale.ini`, and `DocsTonality` style files.
  2. A pull request changes a page under `docs/guide` that contains the word `perfect`.
  3. The workflow runs the documentation commands, resolves the lint scope from `documentation_roots`, runs markdownlint, downloads Vale 3.25.1, verifies its SHA-256, and runs Vale.
  4. Vale reports `DocsTonality.Hyperbole` at error level and the step fails; the receipt is still uploaded.
  5. The author rewrites the sentence, and the next run passes.

- Scenario: checksum mismatch
  1. The downloaded Vale archive does not match the pinned SHA-256.
  2. The install step fails with `VALE_SHA256_MISMATCH` before extraction, and no Vale binary runs.

- Scenario: tracking unfinished pages
  1. An author writes `SME input required` in two sections of a page and once in an example inside a fenced code block.
  2. The author runs the docs `coverage` command.
  3. The output lists `placeholders: token="SME input required" total=2 pages=1` and `placeholder <page_path> count=2`; the fenced example is not counted, and the command exit code is unchanged.

## Acceptance Criteria

- [x] The init-written `_docs-quality.yml` runs `DavidAnson/markdownlint-cli2-action`, pinned by commit, with `config: docs/documentation-estate/.markdownlint.json` over globs derived from the profile `documentation_roots`, as asserted by a passing Pester content test.
- [x] The init-written `_docs-quality.yml` downloads Vale 3.25.1, compares its SHA-256 with the pinned value, and throws `VALE_SHA256_MISMATCH` before extraction on a mismatch, as asserted by a passing Pester content test and shown by recorded mismatch-run evidence.
- [x] The init-written `_docs-quality.yml` runs Vale with `--config docs/documentation-estate/.vale.ini` and fails the step on an error-level alert, as asserted by a passing Pester content test.
- [x] Every `uses:` reference in the template is pinned to a full commit SHA with a version comment, permissions are `contents: read` at the workflow and job levels, and no `run:` block contains `${{`, as asserted by passing Pester content tests.
- [x] Docs init writes the five `DocsTonality` rule files (Certainty, Exclamation, Filler, Hyperbole, Intensifiers) with error level for the first four and warning level for Intensifiers, and the written `.vale.ini` contains `BasedOnStyles = Vale, DocsBase, DocsTonality` and `Vale.Spelling = warning`, as asserted by passing Pester tests.
- [x] A page containing the word `perfect` produces a `DocsTonality.Hyperbole` error and Vale exit code 1, shown by recorded live Vale evidence under the feature `evidence/other/` folder.
- [x] The docs `coverage` command reports a `placeholders` section with the token, the total, and one line per page with a non-zero count sorted by page path; occurrences in front matter, fenced code, inline code, and HTML comments are not counted; wrong-case text is not counted; one line break between the words is tolerated; and the exit code is unchanged, as asserted by passing Pester tests.
- [x] `DocsCoverageReport.psm1` is unchanged on the branch, and the new `DocsPagePlaceholder.psm1` reaches at least 85% line coverage, recorded as QA evidence.
- [x] The docs-init skill on every surface and the consumer onboarding page describe the workflow as running markdownlint and Vale, and contain no statement that no workflow step runs the linters, as asserted by passing Pester content tests.
- [x] Bundle copies are byte-identical, `core.json` lists the new files, the push-down contract tests pass, and `Invoke-HarnessGeneration.ps1 -Check` exits 0.
- [x] `DocsLedgerCommands.psm1` grows by at most 4 logical lines, and every new or changed code and test file stays at or below 800 logical lines, shown by recorded evidence.

## Non-Goals

- Documentation family schema, the docs-complete family check, and review cadence (other children of epic #1217).
- Gating CI on the placeholder count.
- Adding the placeholder token to the DocsBase `Placeholders` Vale rule.
- Migrating estates initialized before this change; the documentation states the `init -Write -Force` route.
- Changes to the envelope schema, TypeScript types, or the MCP tool description.
