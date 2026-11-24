# docs-prose-markdown-lint — Spec

- **Issue:** #1219
- **Parent (optional):** Epic #1217 (documentation-estate-families), wave 0, complexity C3
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Research:** `.dev/active/1219-docs-prose-markdown-lint/research/2026-11-23T05-45-docs-prose-markdown-lint-research.md` (decisions D1-D14 adopted)

## Problem

The workflow template that docs init writes, `.claude/lib/docs/templates/_docs-quality.yml`, copies `.vale.ini` and `.markdownlint.json` into a consumer repository but runs neither tool. Prose and Markdown defects in documentation pages are therefore not reported in CI. The default Vale style set has no rule tied to the repository tonality policy (`.claude/rules/tonality.md`). Documentation pages have no counted placeholder for content that still needs subject-matter-expert input.

The docs-init skill and the engineering page `consumer-onboarding.md` state that no workflow step runs Vale or markdownlint. That statement becomes false with this change and is corrected in this item.

## Scope

1. The init-written workflow template gains a lint-scope step, a Markdown lint step, a Vale install step with SHA-256 verification, and a Vale run step. Every `uses:` reference is pinned to a full commit SHA.
2. Docs init writes a new Vale style, `DocsTonality`, and the written `.vale.ini` loads it.
3. The placeholder token `SME input required` (owned by this feature per the epic `## Shared Design`) is counted in page bodies and reported by the docs `coverage` command in its own result key and text section.
4. Bundle copies, pack manifest entries, the docs-init skill on every surface, and the engineering pages that describe the changed behavior are updated in the same change.

## Non-Goals

- The documentation family schema (`required_families`, legacy exclusions); owned by docs-family-profile-model.
- The docs-complete family check and coverage-report family content; owned by docs-family-gate-and-ia.
- Review cadence (`review_due`, overdue findings); owned by docs-review-cadence.
- Gating on the placeholder count. The count is reported; the coverage exit code does not change.
- Adding `SME input required` to the DocsBase `Placeholders` Vale rule (D12).
- Migrating estates initialized before this change (D14).
- Changes to the envelope JSON schema or to TypeScript types (D11).
- A CI job in this repository that runs the template. The template runs only in consumer repositories.
- Changes to the `rgf-forecast` repository, which is read-only reference input.

## Design Summary

### Workflow template

`.claude/lib/docs/templates/_docs-quality.yml` keeps its triggers (`workflow_call`, `workflow_dispatch` with input `base-ref`), its single job on `ubuntu-latest`, and its destination `.github/workflows/_docs-quality.yml` (the hook docs-only exemption path). Step order after the change (D6):

1. Checkout, pinned by commit SHA, `fetch-depth: 0`.
2. Inventory, check, and validate docs-complete with `-WriteReceipt` (unchanged).
3. Surface-delta when `base-ref` is set (unchanged).
4. Resolve the lint scope (`shell: pwsh`, `id: docs-lint-scope`, `if: ${{ !cancelled() }}`).
5. Markdown lint (`DavidAnson/markdownlint-cli2-action`, `if: ${{ !cancelled() }}`).
6. Install Vale (`shell: pwsh`, `if: ${{ !cancelled() }}`).
7. Prose lint with Vale (`shell: pwsh`, `if: ${{ !cancelled() }}`).
8. Upload the receipt, pinned by commit SHA, `if: ${{ always() }}`.

Step rules:

- Lint scope (D5): reads `docs/documentation-estate/docs-profile.json` with `ConvertFrom-Json -AsHashtable`, takes each `documentation_roots[].path`, throws `DOCS_LINT_SCOPE_EMPTY` when no root exists, and writes the step outputs `globs` (one `<root>/**/*.md` per line) and `roots` (one root per line) through the `$env:GITHUB_OUTPUT` multiline delimiter form.
- Markdown lint (D2): `with: config: docs/documentation-estate/.markdownlint.json` and `globs: ${{ steps.docs-lint-scope.outputs.globs }}`.
- Vale install (D1, D4): step `env:` holds `VALE_VERSION: "3.25.1"` and `VALE_SHA256: "4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182"`. The step downloads `vale_3.25.1_Linux_64-bit.tar.gz` from `https://github.com/vale-cli/vale/releases/download/v3.25.1/` into `$env:RUNNER_TEMP`, computes `(Get-FileHash -Algorithm SHA256).Hash.ToLowerInvariant()`, compares it with `$env:VALE_SHA256` using `-cne`, and on a mismatch throws `VALE_SHA256_MISMATCH: expected <x>, got <y>` before any `tar` call. On a match it extracts only `vale` and runs `vale --version`.
- Vale run: `env: DOCS_LINT_ROOTS: ${{ steps.docs-lint-scope.outputs.roots }}`; the step runs `& "$env:RUNNER_TEMP/vale/vale" --config docs/documentation-estate/.vale.ini --output line` over the non-empty lines of `$env:DOCS_LINT_ROOTS`, then `exit $LASTEXITCODE`. Vale exit 1 (at least one error-level alert) fails the step; warnings and suggestions do not.
- No `${{ }}` expression appears inside any `run:` block; values reach scripts through `env:`.
- `permissions: contents: read` at the workflow level and the job level.
- Every run step sets `shell: pwsh`. The tokens `setup-python`, `setup-node`, `python`, `npm`, and `node` remain absent.
- The header comment states that every run step uses PowerShell 7, that Markdown lint uses the pinned markdownlint-cli2 action, and that Vale is a pinned, checksum-verified release binary.

### Tonality style

- Style name `DocsTonality` (D7). Sources: `.claude/lib/docs/templates/page-check/vale/DocsTonality/{Certainty,Exclamation,Filler,Hyperbole,Intensifiers}.yml`. Destinations: `docs/documentation-estate/.vale/styles/DocsTonality/`.
- Every rule is `extends: existence`, `ignorecase: true`, `scope: ~blockquote`. Certainty, Exclamation, Filler, and Hyperbole are `level: error`; Intensifiers is `level: warning`. Exclamation adds `nonword: true` with tokens `'!\s*$'` and `'!\s+[A-Z]'`.
- Token lists are copied from the rgf-forecast `styles/RgfTonality/` reference unchanged. Each file opens with a comment naming the `.claude/rules/tonality.md` section it enforces. The Intensifiers comment states that just, very, easy, and easily are absent because technical documentation uses them in technical senses; it does not cite any rgf-forecast file.
- The rows go in `Get-DocsInitTemplate` under a new anchor `# --- 1219: tonality styles ---`, placed after the 1034 workflow row.

### `.vale.ini`

```ini
StylesPath = .vale/styles
MinAlertLevel = warning
Vocab = Project

[*.md]
BasedOnStyles = Vale, DocsBase, DocsTonality
Vale.Spelling = warning
```

`Vale.Spelling = warning` (D8) keeps spelling reported without blocking a consumer's first run against an empty `Project` vocabulary.

### Placeholder counter

- Token: the literal `SME input required`, case-sensitive, ordinal.
- Separators: between adjacent words, one or more spaces or tabs, or a single line break with optional surrounding spaces or tabs. Pattern: `SME(?:[ \t]+|[ \t]*\n[ \t]*)input(?:[ \t]+|[ \t]*\n[ \t]*)required`. Words separated by a blank line are not counted.
- Counted region (D10): the page body starting at `BodyStartLine` of `ConvertFrom-DocsPageFrontMatter`. The searched text is the `Masked` text of `Get-DocsPageLineModel` lines joined with `\n`, so front matter, fence lines and fenced code bodies (backtick and tilde), HTML comments, and inline code-span contents are excluded. An unterminated front matter block yields `BodyStartLine` 1, and the whole page is searched.
- Page set: the `.md` pages of the page-path set returned by `Read-DocsLedgerCommandDocumentSet`. Pages are read through `Context.ReadBytes` and decoded strictly as UTF-8. A page that fails to decode contributes zero and is not listed. CRLF line endings count the same as LF.
- Totals: `total` is the sum over all pages. `pages` lists only pages with a count above zero, sorted ordinally by `page_path`.

## Interfaces

### New module `.claude/lib/docs/DocsPagePlaceholder.psm1`

Pure; no filesystem, network, or clock access. Imports `DocsJson`, `DocsPageMarkdown`, and `DocsPageFrontMatter` through `$PSScriptRoot`. Exports exactly:

| Function | Parameters | Returns |
| --- | --- | --- |
| `Get-DocsPlaceholderToken` | none | `[string]` `SME input required` |
| `Measure-DocsPagePlaceholder` | `-Text [string]`, `-PagePath [string]` | `[long]` count for one page |
| `Get-DocsPlaceholderReport` | `-PagePath [string[]]`, `-ReadBytes [scriptblock]` | ordered `placeholders` section |
| `ConvertTo-DocsPlaceholderReportLine` | `-Report` | `[string[]]` text lines |

### Coverage command result

`Invoke-DocsCoverageCommand` in `.claude/lib/docs/DocsLedgerCommands.psm1` adds the key `placeholders` to the result after `parity`:

```text
placeholders = [ordered]@{
  token = 'SME input required'
  total = [long]
  pages = @( [ordered]@{ page_path = [string]; count = [long] } )
}
```

Text lines are appended after the existing report lines:

```text
placeholders: token="SME input required" total=<n> pages=<m>
placeholder <page_path> count=<n>
```

The second line repeats once per listed page, in the `pages` order. The command's context access stays `ListFile`, `ReadBytes`, and `TestFile`; it makes no `WriteText` call. The exit code is computed exactly as before this change. `DocsCoverageReport.psm1` is not edited (D9).

### Workflow pins

| Reference | Version comment | Commit |
| --- | --- | --- |
| `actions/checkout` | `# v7.0.1` | `3d3c42e5aac5ba805825da76410c181273ba90b1` |
| `actions/upload-artifact` | `# v7.0.2` | `cf430e030ddbb5b0abf93d22962f4752f3646cd9` |
| `DavidAnson/markdownlint-cli2-action` | `# v25.0.0` | `696eb3f2509270d7b882d2aa68347bc676e7af34` |
| Vale release | `VALE_VERSION: "3.25.1"` | `VALE_SHA256: "4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182"` |

The Vale Linux hash was confirmed against the upstream `vale_3.25.1_checksums.txt` with `gh` (`evidence/other/vale-checksum-confirmation.2026-11-23T05-58.md`). The same file records `5f4b5cefee5d0f7ee0621d7cc035886515888fd732c4e8add36d3c922f2adc68` for `vale_3.25.1_Windows_64-bit.zip`, usable for a Windows-hosted live proof only.

### Docs init

`Get-DocsInitTemplate` (in `DocsProfileCommands.psm1`) returns the existing 1021 and 1034 rows unchanged, followed by the 1219 anchor and one row per DocsTonality file. The synopsis names the 1219 anchor. `Invoke-DocsInitCommand` behavior is unchanged: without `-Force`, an existing destination yields `DOCS_INIT_TARGET_EXISTS` and nothing is written.

## Parity and Bundle Obligations

- Every changed or new file under `.claude/lib/docs/` has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`: `DocsPagePlaceholder.psm1`, `DocsLedgerCommands.psm1`, `DocsProfileCommands.psm1`, `templates/_docs-quality.yml`, `templates/page-check/vale.ini`, and the five `templates/page-check/vale/DocsTonality/*.yml` files.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists `DocsPagePlaceholder.psm1` and the five DocsTonality templates.
- `.agents/skills/docs-init/SKILL.md` is edited at the source, copied to `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-init/SKILL.md`, and `scripts/harness-generation/Invoke-HarnessGeneration.ps1` regenerates `.claude/skills/docs-init/SKILL.md` and its bundle copy. Copilot reads the `.agents` source; no `.github/skills/docs-init` copy exists.
- No execution-environment brief fact changes, and no CI job, required check, or change-scope rule of this repository changes.

## Documentation Changes

- docs-init skill `## Linter Configuration`: replaces the sentence beginning "No workflow step runs Vale or markdownlint" with a statement that the workflow runs markdownlint with `docs/documentation-estate/.markdownlint.json` and the pinned Vale with `--config docs/documentation-estate/.vale.ini`; names the `DocsTonality` style; states that an estate initialized earlier receives the new files only through `init -Write -Force` or by copying them.
- `.dev/engineering/documentation-estate/consumer-onboarding.md` `## Linting` and `## Consumer CI`: the same statement change; the claim that PowerShell is the only runtime the workflow uses is removed.
- `.dev/engineering/documentation-estate/command-reference.md` `### coverage`: describes the `placeholders` key, its text lines, and the token.

## Constraints and Risks

- No new Python. Implementation is PowerShell 7.4 in the docs library. No TypeScript change.
- Framework code is domain-neutral; the lint scope comes from the profile at run time.
- `DocsLedgerCommands.psm1` is at 758 logical lines; net growth is limited to 4 lines so the file stays well below the 800-line hard limit while docs-family-gate-and-ia may also edit it. If combined epic growth would exceed 800, `Invoke-DocsCoverageCommand` moves to its own module.
- The overlap with docs-family-gate-and-ia is confined to `Invoke-DocsCoverageCommand` and the sorted result-key assertion in `DocsLedgerCommands.Tests.ps1`; merge resolution is a union of keys.
- The template runs only in consumer CI. Consumer pages may fail default markdownlint rules or error-level tonality rules on the first run; the documentation states this.
- Template pins are refreshed by hand; this repository's Dependabot does not scan `.claude/lib/docs/templates/`.
- Tests use in-memory strings and scriptblocks only; no temporary files. CRLF inputs are built in memory because committed fixtures are normalized to LF.
- Test runs are parallel only (`Invoke-PoshQCParallelTest` through the test-execution launcher); no serial, single-process, shuffled, or reversed runs.
- Evidence is append-only, written under `.dev/active/1219-docs-prose-markdown-lint/evidence/<kind>/`, with clock-derived timestamps and no absolute paths or host names.

## Decisions

Autonomous mode; each decision takes the recommended option.

- D1: Pin Vale 3.25.1 with SHA-256 `4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182`, confirmed against the upstream checksums file.
- D2: Markdown lint uses `DavidAnson/markdownlint-cli2-action` v25.0.0 pinned by commit.
- D3: Pin `actions/checkout` v7.0.1 and `actions/upload-artifact` v7.0.2 by commit. The requirement comes from the issue; `.claude/rules/ci-workflows.md` states no such rule.
- D4: Every run step uses `shell: pwsh`; Vale is verified with `Get-FileHash` and an ordinal comparison before extraction.
- D5: The lint scope comes from `documentation_roots` of the default profile through a pwsh step and step outputs.
- D6: The lint steps follow the documentation steps and run under `if: ${{ !cancelled() }}`.
- D7: The style is named `DocsTonality`; templates go under `page-check/vale/DocsTonality/`; rows go under a new 1219 anchor after the 1034 row.
- D8: `.vale.ini` adds `DocsTonality` and sets `Vale.Spelling = warning`.
- D9: The counter is a new module `DocsPagePlaceholder.psm1`; `DocsCoverageReport.psm1` is not edited; integration is in `Invoke-DocsCoverageCommand`.
- D10: Count in the page body only, excluding front matter, fenced code, inline code spans, and HTML comments; case-sensitive; one line break tolerated between words; pages read through ReadBytes; undecodable pages skipped.
- D11: No schema or TypeScript change. The `run_docs_coverage` description string in `mcp-docs-tool-definitions.ts` is not edited (spec-level decision; the research marked the edit optional, and leaving it keeps the TypeScript surface untouched).
- D12: The token is not added to the DocsBase `Placeholders` Vale rule; the coverage count is its single report channel.
- D13: The docs-init skill and both engineering pages are updated in this item (related finding).
- D14: Existing estates are not migrated; the documentation states the `-Force` re-init route.
- D15 (spec-level): The live Vale proof may run through WSL with the Linux tarball or on Windows with the zip; the downloaded asset is verified against the hash recorded for that asset in the upstream checksums file before it runs.

## Acceptance Criteria

### Workflow template

- [x] A Pester content test of `.claude/lib/docs/templates/_docs-quality.yml` passes and asserts a step that uses `DavidAnson/markdownlint-cli2-action@696eb3f2509270d7b882d2aa68347bc676e7af34 # v25.0.0` with `config: docs/documentation-estate/.markdownlint.json` and `globs: ${{ steps.docs-lint-scope.outputs.globs }}`.
- [x] A Pester content test passes and asserts a lint-scope step with `id: docs-lint-scope` that reads `docs/documentation-estate/docs-profile.json`, writes the `globs` and `roots` outputs to `$env:GITHUB_OUTPUT`, and contains the text `DOCS_LINT_SCOPE_EMPTY`.
- [x] A Pester content test passes and asserts a Vale install step whose `env:` sets `VALE_VERSION: "3.25.1"` and `VALE_SHA256` to `4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182`, whose script downloads from `https://github.com/vale-cli/vale/releases/download/v3.25.1/`, calls `Get-FileHash -Algorithm SHA256`, compares with `-cne`, and contains `throw` with `VALE_SHA256_MISMATCH` at a position before the first `tar` call.
- [x] Recorded evidence under `evidence/other/` shows a run of the install sequence with an altered expected hash that exits non-zero, reports `VALE_SHA256_MISMATCH`, and leaves no extracted `vale` binary.
- [x] A Pester content test passes and asserts a Vale run step whose `env:` sets `DOCS_LINT_ROOTS: ${{ steps.docs-lint-scope.outputs.roots }}` and whose script invokes Vale with `--config docs/documentation-estate/.vale.ini` and ends with `exit $LASTEXITCODE`.
- [x] A Pester content test passes and asserts that every `uses:` line in the template references a 40-character lowercase hexadecimal commit SHA followed by a `# vX.Y.Z` comment, and that the checkout and upload-artifact references equal the commits in the `### Workflow pins` table.
- [x] A Pester content test passes and asserts `permissions:` with `contents: read` at the workflow level and the job level, and no other permission scope.
- [x] A Pester content test passes and asserts that no `run:` block body (including every line of a `run: |` block) contains `${{`.
- [x] A Pester content test passes and asserts that every run step sets `shell: pwsh`, that the lint-scope, Markdown lint, Vale install, and Vale run steps carry `if: ${{ !cancelled() }}` and appear in that order after the documentation-command steps, and that the upload step carries `if: ${{ always() }}`.
- [x] The existing Pester assertions that the template contains none of the tokens `setup-python`, `setup-node`, `python`, `npm`, and `node` pass unchanged.
- [x] Recorded evidence under `evidence/other/` shows `actionlint` 1.7.12 run over the template with exit code 0.

### Tonality style and Vale configuration

- [x] A Pester test passes and asserts that `Invoke-DocsInitCommand -Write` against an in-memory context writes `Certainty.yml`, `Exclamation.yml`, `Filler.yml`, `Hyperbole.yml`, and `Intensifiers.yml` under `docs/documentation-estate/.vale/styles/DocsTonality/` with content equal to the template sources.
- [x] A Pester content test passes for each DocsTonality file and asserts `extends: existence`, `ignorecase: true`, `scope: ~blockquote`, a leading comment naming `.claude/rules/tonality.md`, and no occurrence of `drm-copilot`, `rgf`, or `Rgf`; it asserts `level: error` for Certainty, Exclamation, Filler, and Hyperbole and `level: warning` for Intensifiers.
- [x] A Pester content test passes and asserts that the Hyperbole token list includes `perfect` and `world-class`, and that Exclamation sets `nonword: true` with the tokens `'!\s*$'` and `'!\s+[A-Z]'`.
- [x] A Pester test passes and asserts that `Get-DocsInitTemplate` returns the 1219 anchor rows after the 1034 workflow row, that the 1021 rows and the 1034 row are unchanged, and that the only row with a `.github/workflows/` destination is `.github/workflows/_docs-quality.yml`.
- [x] A Pester content test passes and asserts that the `.vale.ini` template contains the line `BasedOnStyles = Vale, DocsBase, DocsTonality` and the line `Vale.Spelling = warning` under `[*.md]`.
- [x] Recorded evidence under `evidence/other/` shows Vale 3.25.1, verified against the upstream checksum for the asset used, run with `--config` pointing at the init-written `.vale.ini` over a page containing the word `perfect`, with `EXIT_CODE: 1`, `ExpectedExitCode: 1`, and an output summary naming `DocsTonality.Hyperbole` at error level.

### Placeholder counter

- [x] Pester tests in `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1` pass and assert counts of 0, 1, and 3 for pages with zero, one, and three occurrences, and a count of 2 for two occurrences on one line.
- [x] A Pester test passes and asserts that the token wrapped across one line break inside a paragraph counts 1, and that the words separated by a blank line count 0.
- [x] A Pester test passes and asserts that `sme input required` and `SME Input Required` count 0.
- [x] Pester tests pass and assert a count of 0 for the token inside front matter, inside a backtick fenced block, inside a tilde fenced block, inside an inline code span, and inside an HTML comment.
- [x] A Pester test passes and asserts that a page with an unterminated front matter block containing the token counts 1.
- [x] A Pester test passes and asserts that a CRLF page built in memory gives the same count as its LF form.
- [x] Pester tests pass and assert that `Get-DocsPlaceholderReport` skips a non-`.md` page, skips a page whose bytes are not valid UTF-8, sums `total` across pages, omits pages with a count of 0 from `pages`, and orders `pages` ordinally by `page_path`.
- [x] A Pester test passes and asserts that `ConvertTo-DocsPlaceholderReportLine` returns `placeholders: token="SME input required" total=<n> pages=<m>` followed by one `placeholder <page_path> count=<n>` line per listed page in `pages` order.
- [x] A Pester test of `Invoke-DocsCoverageCommand` passes and asserts that the result keys equal the prior key set plus `placeholders`, that the fixture result has `placeholders.total` equal to 0, and that the context members used are `ListFile`, `ReadBytes`, and `TestFile` with no `WriteText` call.
- [x] A Pester test passes and asserts that the coverage command exit code for a fixture whose pages contain the token equals the exit code for the same fixture without the token.
- [x] `git diff` of the branch against its merge base shows no change to `.claude/lib/docs/DocsCoverageReport.psm1`, and `DocsCoverageReport.Tests.ps1` and `DocsCoverageReport.Properties.Tests.ps1` pass unchanged.
- [x] `DocsPagePlaceholder.psm1` reaches at least 85% line coverage in the PowerShell coverage run, recorded under `evidence/qa-gates/`.

### Documentation, parity, and limits

- [x] The docs-init skill on every surface (`.agents`, generated `.claude`, and both bundle copies) and `.dev/engineering/documentation-estate/consumer-onboarding.md` contain no sentence stating that no workflow step runs Vale or markdownlint, and contain the replacement statement; `docs-authoring-roles.Skills.Tests.ps1` and `DocumentationEstateOnboarding.Tests.ps1` pass with the updated token.
- [x] `consumer-onboarding.md` no longer states that PowerShell is the only runtime the workflow uses, and `command-reference.md` `### coverage` names the `placeholders` key and the token `SME input required`.
- [x] Every new or changed file under `.claude/lib/docs/` is byte-identical to its copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, and `core.json` lists `DocsPagePlaceholder.psm1` and the five DocsTonality templates; `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and `test_push_down_codex_and_agents_resource_contracts.py` pass.
- [x] `Invoke-HarnessGeneration.ps1 -Check` exits 0 and `HarnessGeneration.RepoGate.Tests.ps1` passes.
- [x] Recorded evidence shows `DocsLedgerCommands.psm1` at no more than 762 logical lines after the change, and every new or changed production, test, and script file at or below 800 logical lines.
- [x] One parallel Pester gate run (`Invoke-PoshQCParallelTest` through the test-execution launcher) passes with the PoshQC format and analyze stages clean, recorded under `evidence/qa-gates/`.

## Definition of Done

- [x] Every acceptance criterion above is mapped to a test or an evidence artifact in the plan.
- [x] The toolchain loop (format, lint, architecture and contract checks, tests) completes in one clean pass.
- [x] Evidence is recorded append-only under the feature `evidence/` folder.
