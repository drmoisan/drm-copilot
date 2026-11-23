# Research: docs-prose-markdown-lint (Issue #1219)

- Issue: #1219
- Epic: #1217 (documentation-estate-families), wave 0, complexity C3
- Branch: feature/docs-prose-markdown-lint-1219
- Mode: preparation (research only; no source change)
- Timestamp: 2026-11-23T05-45 (stamp supplied by the coordinator)

All paths are repository-relative. Citations name files, symbols, headings, and test names; they carry no line numbers. The 40-character hexadecimal values under `## Pins` are external pin values that the workflow template must carry; they are not citations of this repository.

## Scope Summary

1. `.claude/lib/docs/templates/_docs-quality.yml` gains a Markdown lint step and a Vale step; Vale is a pinned release verified against a pinned SHA-256 before use.
2. Docs init writes a new tonality Vale style (five rules) and `.vale.ini` loads it.
3. The placeholder token `SME input required` is counted in page bodies and reported in the `coverage` command output, in its own module and output section.
4. Parity copies, pack manifest entries, skill text, and engineering pages that describe the changed behavior are updated in the same change.

Out of scope: family schema, docs-complete family check, review cadence (other epic children).

## Current State

### Docs init and the template registry

- `Get-DocsInitTemplate` lives in `.claude/lib/docs/DocsProfileCommands.psm1`. It returns `[pscustomobject]@{ Source; Destination }` rows grouped under the comment anchors `# --- 1021: page-check configuration ---` (five rows) and `# --- 1034: docs workflow ---` (one row). Its synopsis reads "rows under the 1021 and 1034 anchors".
- `Invoke-DocsInitCommand` (same module) adds the profile as the first target, then one target per row. It reads each `Source` through `Context.ReadText` and writes each `Destination` through `Context.WriteText`. With `-Write`, any existing destination without `-Force` exits 1 with one `DOCS_INIT_TARGET_EXISTS` per path and writes nothing. The first row whose destination starts with `.github/workflows/` sets `ci_workflow` and the `ci-workflow <path>` line.
- Current 1021 rows (source under `.claude/lib/docs/templates/page-check/`, destination under `docs/documentation-estate/`): `markdownlint.json` to `.markdownlint.json`; `vale.ini` to `.vale.ini`; `vale/DocsBase/HeadingPunctuation.yml` and `vale/DocsBase/Placeholders.yml` to `.vale/styles/DocsBase/`; `vale/Project/accept.txt` (zero bytes) to `.vale/styles/config/vocabularies/Project/accept.txt`.
- The 1034 row maps `.claude/lib/docs/templates/_docs-quality.yml` to `.github/workflows/_docs-quality.yml`. That destination equals `$script:DocsOnlyInitWorkflowPath` in `.claude/hooks/hook-docs-only-diff.ps1`, pinned by `tests/scripts/claude-hooks/hook-docs-only-diff.InitWorkflowParity.Tests.ps1`. This change keeps the destination and the single workflow row.

### Current `.vale.ini` (template `.claude/lib/docs/templates/page-check/vale.ini`)

```ini
StylesPath = .vale/styles
MinAlertLevel = warning
Vocab = Project

[*.md]
BasedOnStyles = Vale, DocsBase
```

Both DocsBase rules are `extends: existence` at level `warning`. Placeholders lists `TODO`, `TBD`, and `FIXME`.

Vale facts verified on docs.vale.sh: `StylesPath` resolves relative to the file that sets it; a rule key `Style.Rule` inside a section sets its level or switches it off (`Vale.Spelling = warning`, `X.Y = NO`); exit code 1 means the run found at least one `error`, warnings and suggestions leave it at 0, and exit code 2 means Vale could not run; `--config` names the configuration file.

### Current workflow template

`.claude/lib/docs/templates/_docs-quality.yml` has `workflow_call` and `workflow_dispatch` (input `base-ref`), top-level and job-level `permissions: contents: read`, one job on `ubuntu-latest`, `actions/checkout@v7` with `fetch-depth: 0`, four `shell: pwsh` run steps (inventory, check, validate docs-complete with `-WriteReceipt`, and surface-delta when `base-ref` is set), and `actions/upload-artifact@v7` under `if: ${{ always() }}`. Actions are pinned by tag, not by commit. Its header comment states that PowerShell 7 is the only runtime.

### Placement in every surface

| File | Surface copies | Disposition per `config/harness-parity-matrix.json` |
| --- | --- | --- |
| `.claude/lib/docs/**` (modules, templates) | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/**` | Not listed in the matrix; Claude-only library, hand-mirrored byte-identically (module `.NOTES`: "Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/"). No Codex (`.codex/`) or Copilot (`.github/`) copy exists. |
| `.agents/skills/docs-init/SKILL.md` | source; bundle `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-init/SKILL.md` (hand-copied) | `codex:skill:docs-init` shared |
| `.claude/skills/docs-init/SKILL.md` | bundle `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-init/SKILL.md` | `claude:skill:docs-init` generated from the `.agents` source by `harness-generation/skills`; `HarnessSkillMirror.psm1` writes the target and its bundle copy (`Get-HarnessBundlePath`) |
| `.github/skills/docs-init/SKILL.md` | none | `copilot:skill:docs-init` dropped; Copilot reads `.agents/skills/docs-init` |
| `.dev/engineering/documentation-estate/*.md` | none | engineering pages, no mirror |

Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists every docs module and template, including the five 1021 templates and `.claude/lib/docs/templates/_docs-quality.yml`. New files must be added there (`test_push_down_claude_pack_manifest_completeness.py`). No Codex pack manifest lists `.claude/lib/docs` files.

### Coverage report and its MCP surface

- `.claude/lib/docs/DocsCoverageReport.psm1` exports `Get-DocsCoverageReport` (pure; returns ordered `{totals, undocumented, deferred, precision_limits, stale_pages, parity}`) and `ConvertTo-DocsCoverageReportLine` (one `coverage:` totals line, one line per listed item, one `parity` line per dimension). It reads no page.
- The command is `Invoke-DocsCoverageCommand` in `.claude/lib/docs/DocsLedgerCommands.psm1`. It reads the profile and documents through `Read-DocsLedgerCommandDocumentSet`, which already returns `PagePath`: the ordinal-sorted union of `Context.ListFile` over `documentation_roots[].path` (`Read-DocsLedgerInputSet`). The command passes the report to `New-DocsCommandResult -Result $report -Line (ConvertTo-DocsCoverageReportLine ...)`. Its current context access is ListFile, ReadBytes, and TestFile only.
- Page body helpers: `ConvertFrom-DocsPageFrontMatter` (`DocsPageFrontMatter.psm1`) returns `BodyStartLine` (the line after the terminator, or 1 when there is no terminated block). `Split-DocsPageLine` and `Get-DocsPageLineModel` (`DocsPageMarkdown.psm1`) classify each line (`fence-open`, `fence-body`, `fence-close`, `comment`, `blank`, `text`, `heading`, `setext-underline`) and provide `Masked` (HTML comments and inline code-span contents replaced by spaces; empty for fence and comment lines). `-FirstLineNumber` keeps page line numbers after a skipped front matter block. `Get-DocsLedgerPageReference` (`DocsLedgerBindRefs.psm1`) is the precedent for reading pages from the page-path set through a scriptblock.
- MCP: `run_docs_coverage` is defined in `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` with an input schema only. `extensions/drm-copilot/src/docs-command-envelope.ts` types `result` as `unknown` ("`result` is opaque"). `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` declares `"result": {}`. No typed coverage output shape exists in TypeScript or in the schemas, and `packages/` has no docs tool definition.

### CI facts

- `.github/workflows/_docs-quality.yml` does not exist in this repository; the only docs workflow is `.github/workflows/_docs-validation.yml`. The template is written into consumer repositories by init, so no CI job, required context, or change-scope rule of this repository changes. The execution-environment brief needs no update.
- `.claude/rules/ci-workflows.md` contains the deliberately-failing nested command rule and the epic integration-branch trigger rule only. It has no rule on full-SHA action pins or least-privilege permissions. Those requirements come from the issue text (`## Proposed Behavior`), not from the rule file. The workflows in this repository pin actions by tag (`actions/checkout@v7`).

## Candidate Approaches

### Markdown lint runner

- A. `DavidAnson/markdownlint-cli2-action` pinned to a commit, with the `config` and `globs` inputs. It runs on the runner's action runtime (`runs.using: node24`), needs no install step and no `run:` text, and keeps the template free of the `npm`, `node`, and `setup-node` tokens that `DocsInitTemplate.DocsWorkflow.Tests.ps1` forbids.
- B. `npx markdownlint-cli2@<version>` in a run step. This needs Node on the runner, an npm pin, and the `npx` token in the template, and it adds a second runtime to the run steps.
- Selected: A.

### Vale install

- A. A `shell: pwsh` step: `Invoke-WebRequest`, `Get-FileHash -Algorithm SHA256`, ordinal comparison, `throw` on mismatch, `tar -xzf`. This keeps every run step on PowerShell, matching the template's stated design and the existing `shell: pwsh` test.
- B. The rgf-forecast bash sequence (`curl` and `sha256sum --check --strict`). Equivalent integrity, but it introduces a second shell into a template whose design is pwsh-only.
- Selected: A.

### Placeholder counter location

- A. A new pure module `.claude/lib/docs/DocsPagePlaceholder.psm1`, called from `Invoke-DocsCoverageCommand`, which adds a `placeholders` key to the result and appends its own lines. `DocsCoverageReport.psm1` and its tests are not edited, so the overlap with docs-family-gate-and-ia is confined to `Invoke-DocsCoverageCommand` and one key-list assertion.
- B. A new optional parameter on `Get-DocsCoverageReport`. This edits the function that docs-family-gate-and-ia also edits, along with `DocsCoverageReport.Tests.ps1` key assertions.
- Selected: A.

Rejected alternatives: npx markdownlint (adds Node runtime and forbidden tokens); bash Vale install (second shell); a parameter on `Get-DocsCoverageReport` (same-function overlap with docs-family-gate-and-ia); a new docs subcommand for the lint scope (adds a dispatch row, help, and documentation for a two-line computation).

## Pins

Vale (reuse the rgf-forecast pin):

- Version `3.25.1`, asset `vale_3.25.1_Linux_64-bit.tar.gz`.
- SHA-256 `4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182`.
- Verified twice: (1) the value pinned in rgf-forecast `.github/workflows/_docs-quality.yml` (`VALE_SHA256`); (2) the line for that asset in the upstream release file `vale_3.25.1_checksums.txt`, fetched in this session from the `vale-cli/vale` release download URL. The two values are identical.
- Download URL: `https://github.com/vale-cli/vale/releases/download/v3.25.1/vale_3.25.1_Linux_64-bit.tar.gz`. The GitHub API lists release assets under `vale-cli/vale`, and the rgf-forecast comment records that the `errata-ai/vale` URL redirects there. The pinned hash is the integrity control for either origin.
- Newer releases exist (`v3.28.0` and `v3.28.1`, published 2026-11-19). They were not selected: their hashes were not cross-checked against a second source, and 3.25.1 already passes in rgf-forecast CI.
- Open item for the orchestrator (optional): confirm the hash with `gh release download v3.25.1 -R vale-cli/vale -p vale_3.25.1_checksums.txt` before merge.

Actions (resolved through the GitHub API in this session; annotated tags dereferenced to commits):

| Action | Version | Commit |
| --- | --- | --- |
| `actions/checkout` | v7.0.1 | `3d3c42e5aac5ba805825da76410c181273ba90b1` |
| `actions/upload-artifact` | v7.0.2 | `cf430e030ddbb5b0abf93d22962f4752f3646cd9` |
| `DavidAnson/markdownlint-cli2-action` | v25.0.0 (markdownlint-cli2 v0.24.0) | `696eb3f2509270d7b882d2aa68347bc676e7af34` |

`action.yml` at the markdownlint-cli2-action commit was fetched by commit. It declares the inputs `config`, `configPointer`, `fix`, `globs` (newline-delimited), and `separator`, and `runs.using: node24`. v25.1.0 (published 2026-11-21) exists; v25.0.0 was selected because it has been published longer. rgf-forecast uses PyMarkdown through Poetry, which is not applicable here (no Python). Each `uses:` line carries a trailing `# vX.Y.Z` comment. Dependabot in this repository does not scan `.claude/lib/docs/templates/`, so the template pins are refreshed by hand. A consumer's Dependabot (github-actions ecosystem) updates the written copy.

## Behavior Semantics

### Workflow

Step order after the change:

1. Checkout (SHA pin).
2. Inventory, check, and validate (unchanged).
3. Surface-delta (unchanged).
4. Resolve the lint scope (pwsh, `id: docs-lint-scope`, `if: ${{ !cancelled() }}`).
5. Markdown lint (action, `if: ${{ !cancelled() }}`).
6. Install Vale (pwsh, `if: ${{ !cancelled() }}`).
7. Prose lint with Vale (pwsh, `if: ${{ !cancelled() }}`).
8. Upload the receipt (SHA pin, `if: ${{ always() }}`).

The lint steps run after the docs commands, so the receipt is produced and uploaded even when prose lint fails. `!cancelled()` reports every finding class in one run.

- Lint scope: read `docs/documentation-estate/docs-profile.json` (the same default profile that every other step uses) with `ConvertFrom-Json -AsHashtable`. Take each `documentation_roots[].path`, throw `DOCS_LINT_SCOPE_EMPTY` when there is none, and write the outputs `globs` (`<root>/**/*.md`, newline-separated, through the `$env:GITHUB_OUTPUT` multiline delimiter form) and `roots` (newline-separated). This follows "repository specificity is runtime configuration"; the starter profile root is `docs/guide`.
- Markdown lint: `with: config: docs/documentation-estate/.markdownlint.json` and `globs: ${{ steps.docs-lint-scope.outputs.globs }}`. An expression in `with:` is outside `run:`.
- Vale install: step `env:` holds `VALE_VERSION: "3.25.1"` and `VALE_SHA256: "<hash>"`. The step downloads into `$env:RUNNER_TEMP`, compares `(Get-FileHash -Algorithm SHA256).Hash.ToLowerInvariant()` with `$env:VALE_SHA256` using `-cne`, throws `VALE_SHA256_MISMATCH: expected <x>, got <y>` before extraction on a mismatch, extracts only `vale`, and runs `--version`. A failed download, a mismatch, or a failed extraction fails the step. No deliberately-failing nested command exists, so the `$LASTEXITCODE` reset rule of `ci-workflows.md` does not apply.
- Vale run: `env: DOCS_LINT_ROOTS: ${{ steps.docs-lint-scope.outputs.roots }}`. The step runs `& "$env:RUNNER_TEMP/vale/vale" --config docs/documentation-estate/.vale.ini --output line @($env:DOCS_LINT_ROOTS -split "`n" | Where-Object { $_ })` and then `exit $LASTEXITCODE`. Exit 1 means an error-level alert (for example Hyperbole); warnings do not fail.
- No `${{ }}` appears inside any `run:` block; values arrive through `env:`. Permissions stay `contents: read` at both levels.
- The header comment is reworded: every run step uses PowerShell 7; Markdown lint uses the pinned markdownlint-cli2 action; Vale is a pinned, checksum-verified release binary.

### Tonality style

- Style name `DocsTonality` (parallel to `DocsBase`; domain-neutral). Sources go under `.claude/lib/docs/templates/page-check/vale/DocsTonality/{Certainty,Exclamation,Filler,Hyperbole,Intensifiers}.yml`; destinations under `docs/documentation-estate/.vale/styles/DocsTonality/`.
- Rows go under a new anchor `# --- 1219: tonality styles ---`, placed after the 1034 workflow row. This keeps `Get-TestAnchorRowSource` (rows between the 1021 and 1034 anchors) and the "1034 anchor + 1 is the workflow row" assertion unchanged.
- rgf-forecast structure (`styles/RgfTonality/`): every rule is `extends: existence`, `ignorecase: true`, `scope: ~blockquote`. Certainty, Exclamation, Filler, and Hyperbole are `level: error`; Intensifiers is `level: warning`. Exclamation adds `nonword: true` with tokens `'!\s*$'` and `'!\s+[A-Z]'`. Each file opens with a comment naming the `.claude/rules/tonality.md` section it enforces ("Evidence-First Wording", "Humor and Joking — Prohibited", "Hyperbole — Prohibited"); those headings exist in this repository's `tonality.md`.
- Domain specificity: the token lists are domain-neutral and are copied unchanged. The one rgf-specific element is the Intensifiers comment that cites "the tuning log in docs/README.md". Replace it with a neutral sentence: the words just, very, easy, and easily are absent because technical documentation uses them in technical senses. Do not copy the `RgfForecast` vocabulary; this repository's vocabulary stays `Project`.
- `.vale.ini` becomes:

```ini
StylesPath = .vale/styles
MinAlertLevel = warning
Vocab = Project

[*.md]
BasedOnStyles = Vale, DocsBase, DocsTonality
Vale.Spelling = warning
```

`Vale.Spelling` is error-level in the built-in style. With an empty `Project` vocabulary it would block a consumer's first run on technical terms, which only became a blocking risk now that the workflow runs Vale. Lowering it to a warning keeps it reported without blocking.

### Placeholder counter

- Token: the literal `SME input required`, case-sensitive and ordinal. The words may be separated by spaces or tabs, or by one line break with surrounding spaces or tabs, so a token wrapped across lines inside a paragraph counts. Pattern: `SME(?:[ \t]+|[ \t]*\n[ \t]*)input(?:[ \t]+|[ \t]*\n[ \t]*)required`.
- Counted region: the page body after front matter (`BodyStartLine` of `ConvertFrom-DocsPageFrontMatter`). The text searched is the `Masked` text of `Get-DocsPageLineModel` lines joined with `\n`, so fenced code bodies and fence lines, HTML comments, and inline code-span contents are excluded.
- Code fences decision: exclude them. A page that documents the token (an authoring guide or example) shows it in code. Rendered prose is where an unfinished section is visible to a reader, and Vale and markdownlint also treat code as non-prose.
- Front matter decision: exclude it, per the epic contract ("in a page body"). rgf-forecast puts the phrase in an `owner:` front matter value; that use is not counted, and the front matter checker governs metadata values.
- An unterminated front matter block gives `BodyStartLine` 1, so the whole page is searched; `check` reports the parse error separately. Only `.md` pages of the page-path set are read. Pages are read through `Context.ReadBytes` and decoded strictly as UTF-8. A page that fails to decode contributes nothing; `check` reports `DOCS_PAGE_ENCODING_INVALID` for it. Reading through ReadBytes keeps the coverage command's context member set at ListFile, ReadBytes, and TestFile.
- Output: new top-level result key `placeholders`, placed after `parity`: `[ordered]@{ token = 'SME input required'; total = [long]; pages = @( [ordered]@{ page_path; count } ) }`. `pages` lists only pages with count above zero, sorted ordinally. Text lines are appended after the existing report lines: `placeholders: token="SME input required" total=<n> pages=<m>`, then `placeholder <page_path> count=<n>` per page. The coverage exit code is unchanged (the count is reported, not gated).
- Schema and TypeScript: no change. The envelope `result` is unconstrained (`{}`) and the TypeScript envelope type treats it as opaque. Optionally, the `run_docs_coverage` description string may mention the placeholder count; no test pins that string (`mcp-docs-tool-definitions.test.ts` checks names and required fields).

## Requirements Mapping and File Changes

New module `DocsPagePlaceholder.psm1` (pure; no filesystem access; imports `DocsJson`, `DocsPageMarkdown`, `DocsPageFrontMatter`). Exports:

- `Get-DocsPlaceholderToken` returns the literal.
- `Measure-DocsPagePlaceholder -Text -PagePath` returns `[long]`.
- `Get-DocsPlaceholderReport -PagePath [string[]] -ReadBytes [scriptblock]` returns the ordered section.
- `ConvertTo-DocsPlaceholderReportLine -Report` returns `[string[]]`.

| File | Change |
| --- | --- |
| `.claude/lib/docs/templates/_docs-quality.yml` | SHA pins; four new steps; header comment |
| `.claude/lib/docs/templates/page-check/vale.ini` | `DocsTonality` in `BasedOnStyles`; `Vale.Spelling = warning` |
| `.claude/lib/docs/templates/page-check/vale/DocsTonality/*.yml` (5 new) | tonality rules |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 1219 anchor and five rows after the 1034 row; synopsis names the 1219 anchor |
| `.claude/lib/docs/DocsPagePlaceholder.psm1` (new) | counter and section |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | import the new module; in `Invoke-DocsCoverageCommand`, add `$report['placeholders'] = Get-DocsPlaceholderReport -PagePath $documents.PagePath -ReadBytes $Context.ReadBytes` and append `ConvertTo-DocsPlaceholderReportLine` to the lines; update the description. Net growth at most 4 lines |
| Bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` | byte-identical copies of every file above |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add `DocsPagePlaceholder.psm1` and the five `DocsTonality` templates |
| `.agents/skills/docs-init/SKILL.md` and its codex-and-agents bundle copy; then run `Invoke-HarnessGeneration.ps1` for `.claude/skills/docs-init/SKILL.md` and its bundle | `## Linter Configuration`: replace "No workflow step runs Vale or markdownlint ..." with the new statement (the workflow runs markdownlint with that configuration and the pinned Vale with `--config docs/documentation-estate/.vale.ini`); name the `DocsTonality` style; state that an estate initialized earlier gets the new files only through `init -Write -Force` or by copying them |
| `.dev/engineering/documentation-estate/consumer-onboarding.md` | `## Linting` and `## Consumer CI`: same statement change; drop "PowerShell is the only runtime" |
| `.dev/engineering/documentation-estate/command-reference.md` | `### coverage`: describe the `placeholders` section and the token |

The skill and page edits correct a related finding inside this item: both currently state that no workflow step runs the linters, which becomes false.

## Existing Tests and Dispositions

| Test | Assertion affected | Disposition |
| --- | --- | --- |
| `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` | `sets shell: pwsh on every run step` (count 4) | Update the count to 7 (four docs steps plus scope, Vale install, Vale run) |
| same | `invokes Invoke-DocsCommand.ps1 with PowerShell 7 in every run step` | Restrict to the four documentation-command steps (select by `-Command`) |
| same | `passes the revision through env: and uses no inline expression inside run:` | Keep; strengthen to check the whole `run:` block body, because the new steps use `run: |` |
| same | `checks out ... uses: actions/checkout@v7` | Update to the SHA pin with the version comment |
| same | `contains no <_> token` (`setup-python`, `setup-node`, `python`, `npm`, `node`) | Unchanged; the design keeps these tokens absent |
| same | `contains no linter step` | Replace with positive tests: a markdownlint step with the pinned action and `config: docs/documentation-estate/.markdownlint.json`; a Vale install step with `VALE_VERSION`, a 64-hex `VALE_SHA256`, `Get-FileHash`, and a mismatch `throw` ahead of `tar`; a Vale run with `--config docs/documentation-estate/.vale.ini`; every `uses:` pinned to 40 hex characters |
| same | `places the row directly under the 1034 docs workflow anchor`; the init plan and write cases | Unchanged |
| `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` | `$script:TemplateFile.Count | Should -Be $script:Expected.Count` | Update to 1021 rows plus 1219 rows |
| same | `uses no substitution or spelling rule in any Vale style` (`$styles.Count | Should -Be 2`) | Update the count to 7; the `extends: existence` assertion holds for the new files |
| same | `configures Vale ... BasedOnStyles = Vale, DocsBase$` | Update to the new line; add a `Vale.Spelling = warning` assertion |
| same | `places one row per template under the 1021 anchor`; `contains no framework repository name`; `lists TODO, TBD and FIXME`; init cases | Unchanged (the 1219 rows sit after the 1034 anchor); add a Describe for the 1219 rows |
| `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` | `carries the 1021 and 1034 anchors in order`; `returns only rows whose Source is ... under .claude/lib/docs/templates/` | Unchanged; add the 1219 anchor order check |
| `tests/scripts/claude-hooks/hook-docs-only-diff.InitWorkflowParity.Tests.ps1` | exactly one `.github/workflows/*` row equal to `$script:DocsOnlyInitWorkflowPath` | Unchanged; the design adds no workflow row |
| `tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1` | `$script:InitOutputs` names four init outputs | Unchanged (membership list) |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | coverage `returns totals ...` sorted key list | Update to add `placeholders`; assert `total` 0 for the fixture page `# Cli` |
| same | `makes zero WriteText calls` (member set `ListFile`, `ReadBytes`, `TestFile`) | Unchanged because pages are read through ReadBytes |
| same | `prints finding lines and the summary line without Json`; `produces byte-identical Json stdout` | Unchanged (first and last lines and determinism hold) |
| `tests/scripts/claude-lib/docs/DocsCoverageReport.Tests.ps1` and `DocsCoverageReport.Properties.Tests.ps1` | exact report keys; line count 6 plus listed items | Unchanged; `DocsCoverageReport.psm1` is not edited |
| `tests/scripts/claude-lib/docs/DocsWriteBoundary.Tests.ps1` | no write primitive outside the allowlist | Unchanged; the new module writes nothing |
| `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | docs-init copies contain `No workflow step runs Vale or markdownlint` | Update the token to the new statement in all docs-init copies |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | `## Linting` of `consumer-onboarding.md` contains the same token | Update the token |
| Remove-Module lists in `DocsLedgerCommands*.Tests.ps1`, `DocsValidateCommands.Tests.ps1`, `DocsHashLineEnding.Tests.ps1`, `DocsCompleteIntegration.Tests.ps1` | modules imported transitively | Add `DocsPagePlaceholder`, `DocsPageFrontMatter`, `DocsPageMarkdown`, and `DocsPageMetadata` where the list does not already remove them |
| `extensions/drm-copilot/test/*docs*.test.ts` | envelope and handler shapes | Unchanged (`result` is opaque) |

Contract tests that must stay green: `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (the new `$PSScriptRoot` imports of `DocsLedgerCommands.psm1` must be in core), `test_push_down_codex_and_agents_resource_contracts.py`, and `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`.

## Testing Implications

- New `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1` (Pester 6, in-memory strings and scriptblocks only, no temporary files). Cases:
  - zero, one, and several occurrences;
  - two occurrences on one line;
  - a token wrapped across one line break;
  - a token split by a blank line (not counted);
  - wrong case (not counted);
  - inside a fenced block (backtick and tilde), an inline code span, and an HTML comment (not counted);
  - inside front matter (not counted);
  - unterminated front matter (counted);
  - a non-`.md` page skipped;
  - an invalid UTF-8 page skipped;
  - sorting, and zero-count pages omitted;
  - the line rendering;
  - the CRLF form built in memory (the `eol=lf` attribute normalizes committed fixtures).
- `.claude/lib/docs` is tier T3 in `quality-tiers.yml`, so property tests are optional. A small property case (count is invariant under adding fenced or commented copies) follows the repository precedent of `DocsCoverageReport.Properties.Tests.ps1`.
- Template content tests as listed above, plus a Pester content test for each DocsTonality file: `extends: existence`; levels (error for four, warning for Intensifiers); the Hyperbole tokens include `perfect` and `world-class`; the comment names `.claude/rules/tonality.md`; and the text contains no `drm-copilot`, `rgf`, or `Rgf`.
- The issue AC "a page containing a hyperbole term produces a Vale error" needs a live Vale run; Pester cannot run an external executable. Evidence: an orchestrator-owned `sh` script under `SCRATCH`. It downloads the pinned tarball, verifies the hash, runs init into an in-memory context (or copies the committed templates into `SCRATCH`), writes a sample page containing `perfect`, and records exit code 1 and the `DocsTonality.Hyperbole` alert. A second run with an altered expected hash records the mismatch failure. Both are recorded under `evidence/other/` with `ExpectedExitCode` as needed. The Linux binary runs through WSL inside the `sh` script; the Windows zip hash was not collected (see Open Items).
- `actionlint` (pinned 1.7.12) over `.claude/lib/docs/templates/_docs-quality.yml`, run through a `sh` script, is evidence of workflow syntax; it is not a substitute for a runner execution.
- Gates: one `Invoke-PoshQCParallelTest` run through `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester`; task checks use `pester -TestPath <files>`; pytest contract tests through the launcher `pytest` suite. No serial, shuffled, or reversed runs.

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: the default style set written by docs init contains the 5 tonality rules.
- Complete Family: Certainty, Exclamation, Filler, Hyperbole, Intensifiers
- Exhaustive Search Scope: all files of the entire rgf-forecast reference tree under styles/ and the complete issue.md of this worktree tree
- Inclusion Rules: a Vale rule file (YAML with an extends key) under the tonality style folder, or a rule name listed in the issue Proposed Behavior tonality bullet
- Exclusion Rules: vocabulary files under styles/config/, and the DocsBase rules HeadingPunctuation and Placeholders
- Primary Search Strategy or Query Expression: Glob styles/**/* in the rgf-forecast tree, yielding RgfTonality/Certainty.yml, RgfTonality/Exclamation.yml, RgfTonality/Filler.yml, RgfTonality/Hyperbole.yml, RgfTonality/Intensifiers.yml and one vocabulary file
- Primary Member Set: Certainty, Exclamation, Filler, Hyperbole, Intensifiers
- Primary Count: 5
- Cross-check Search Strategy or Query Expression: Read of issue.md Proposed Behavior, parsing the parenthesised list (Certainty, Exclamation, Filler, Hyperbole, Intensifiers)
- Cross-check Member Set: Certainty, Exclamation, Filler, Hyperbole, Intensifiers
- Cross-check Count: 5
- Member-set Comparison: the normalized primary and cross-check member sets are identical

## Decisions

Autonomous mode; each decision takes the recommended option.

- D1: Pin Vale 3.25.1 with SHA-256 `4bf5c517...d4962182`, reused from rgf-forecast and cross-checked against the upstream checksums file.
- D2: Markdown lint uses `DavidAnson/markdownlint-cli2-action` v25.0.0 pinned by commit.
- D3: Pin `actions/checkout` (v7.0.1) and `actions/upload-artifact` (v7.0.2) by commit in the template, as the issue requires. The rule file `ci-workflows.md` states no such rule.
- D4: Every run step uses `shell: pwsh`; Vale is verified with `Get-FileHash` and an ordinal comparison before extraction.
- D5: The lint scope comes from `documentation_roots` of the default profile through a pwsh step and step outputs.
- D6: The lint steps follow the documentation steps and run under `if: ${{ !cancelled() }}`.
- D7: The style is named `DocsTonality` and its templates go under `page-check/vale/DocsTonality/`; the rows go under a new 1219 anchor after the 1034 row.
- D8: `.vale.ini` adds `DocsTonality` and sets `Vale.Spelling = warning`.
- D9: The counter is a new module `DocsPagePlaceholder.psm1`; `DocsCoverageReport.psm1` is not edited; integration is in `Invoke-DocsCoverageCommand`.
- D10: Count in the page body only, excluding front matter, fenced code, inline code spans, and HTML comments; case-sensitive, tolerating one line break between the words; pages read through ReadBytes; undecodable pages skipped.
- D11: No schema or TypeScript change.
- D12: The token is not added to the DocsBase Placeholders Vale rule; the coverage count is its single report channel.
- D13: Update the docs-init skill and both engineering pages in this item (related finding).
- D14: Existing estates are not migrated; the documentation states the `-Force` re-init route.

## Open Items

- Optional: confirm the Vale 3.25.1 Linux hash with `gh release download` (orchestrator; the researcher has no `gh`).
- If the live Vale proof is run on Windows rather than through WSL, the Windows zip hash must first be read from the same checksums file; it was not collected in this session.
- The epic overlap remains in `Invoke-DocsCoverageCommand` and the `DocsLedgerCommands.Tests.ps1` sorted key-list assertion; merge resolution is a union of keys.

## File Sizes (logical lines)

| File | Now | After (estimate) | Tier |
| --- | --- | --- | --- |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | 758 | about 762 | advisory (at or above 700); 38 lines of headroom below the hard limit |
| `.claude/lib/docs/DocsProfileCommands.psm1` | 270 | about 278 | below guidance |
| `.claude/lib/docs/DocsCoverageReport.psm1` | 163 | unchanged | below guidance |
| `.claude/lib/docs/DocsPagePlaceholder.psm1` (new) | 0 | about 150 | below guidance |
| `.claude/lib/docs/DocsPageMarkdown.psm1` / `DocsPageFrontMatter.psm1` | 263 / 426 | unchanged | below guidance |
| `.claude/lib/docs/templates/_docs-quality.yml` | 65 | about 125 | below guidance |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | 553 | about 556 | guidance; new cases go to the new test file |
| `tests/scripts/claude-lib/docs/DocsProfileCommands.Tests.ps1` | 351 | about 362 | below guidance |
| `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` | 216 | about 270 | below guidance |
| `tests/scripts/claude-lib/docs/DocsPageTemplates.Tests.ps1` | 181 | about 225 | below guidance |
| `tests/scripts/claude-lib/docs/DocsCoverageReport.Tests.ps1` | 154 | unchanged | below guidance |
| `tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1` | 305 | token edit | below guidance |
| `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` | 116 | token edit | below guidance |
| `tests/scripts/claude-lib/docs/DocsPagePlaceholder.Tests.ps1` (new) | 0 | about 220 | below guidance |

Counts were taken with a Grep count of `^` per file, which matches each physical line. Markdown is exempt.

## Automation Feasibility

Every step can run without a human:

- file edits and byte-identical bundle copies;
- the generator run (`scripts/harness-generation/Invoke-HarnessGeneration.ps1`, then `-Check`);
- the PoshQC format and analyze stages;
- the Pester gate and task checks through the test-execution launcher;
- the pytest contract tests through the launcher;
- actionlint and the live Vale proof through `sh` scripts under `SCRATCH`.

The live Vale proof needs network access to `github.com` release downloads and a Linux execution route (WSL inside the `sh` script, or a CI runner). Hash confirmation with `gh` is orchestrator-owned and optional. No step needs an owner decision; the decisions above were taken under autonomous mode.

## Pre-Mortem

- Review checklists: a reviewer flags the tag-pinned `actions/checkout@v7` left in the template, or `${{ }}` inside a `run: |` body. Mitigation: SHA-pin every `uses:` with a version comment, route all values through `env:`, and strengthen the inline-expression test to scan the whole run block.
- Coverage: `DocsPagePlaceholder.psm1` is a new production file in the PowerShell coverage population (folder `.claude/lib` in `config/poshqc-coverage.json`) and needs at least 85% line coverage. Mitigation: unit cases for every branch (front matter, fence kinds, comment, code span, wrap, decode failure, non-Markdown skip, empty set). The `Invoke-DocsCoverageCommand` change is exercised by the updated coverage command test.
- Mirror parity: the bundle copies of the two modules, the new module, `vale.ini`, the workflow, and the five style files; the `core.json` entries; the `.agents` docs-init bundle copy; and the generated `.claude` docs-init plus its bundle. Any one of these can be missed. Mitigation: one task copies all bundle files and updates `core.json`; run `Invoke-HarnessGeneration.ps1` and then `-Check`; run the push-down resource, manifest-completeness, and dependency-closure contract tests and `HarnessGeneration.RepoGate.Tests.ps1`. No execution-environment brief fact changes, so no brief task is needed; the plan's Mirror parity bullet should say so.
- File size: `DocsLedgerCommands.psm1` is at 758 lines (advisory tier), and docs-family-gate-and-ia may add lines to it as well. Mitigation: keep net growth at or below 4 lines by putting all logic in the new module, and record the post-edit count as evidence. If the combined epic growth would pass 800, move `Invoke-DocsCoverageCommand` into its own module.
- Test isolation: new tests use in-memory strings and scriptblocks only, with no temporary files. They remove `DocsPagePlaceholder` and its transitively imported modules in AfterAll, and they add no global variables or functions that `Invoke-PoshQCLeakScan` would flag. CRLF cases are built in memory, because the `eol=lf` attribute normalizes committed fixtures.
- CI-only behavior: the template runs only in consumer CI, which this repository's CI never executes. Consumer pages may fail default markdownlint rules or the error-level tonality rules on the first run. Mitigation: actionlint evidence, the live Vale proof through `sh`/WSL, and documentation of the blocking behavior and the `-Force` re-init route. Linux hook-suite constraints (forward-slash relative paths, exact case) apply if any test is added under `tests/scripts/claude-hooks`; none is planned.
- Evidence: the hyperbole-error AC cannot be proven by Pester. If the live Vale run is skipped, the AC is unmet. Mitigation: a planned orchestrator-owned `sh` evidence task records `Timestamp`, `Command`, `EXIT_CODE` (1, with `ExpectedExitCode: 1`), and an `Output Summary` naming `DocsTonality.Hyperbole` under `evidence/other/`, plus a mismatch-hash run. Evidence is append-only, and no artifact records absolute paths or host names.

Owner directives: none received. The delegation carried no `Owner directives:` block; the coordinator directives are task direction and are recorded under `## Decisions`.
