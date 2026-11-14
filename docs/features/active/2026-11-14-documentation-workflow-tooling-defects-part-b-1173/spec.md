# 2026-11-14-documentation-workflow-tooling-defects-part-b — Spec

- **Issue:** #1173
- **Parent (optional):** #1169 (Part A merged in PR #1175; Part B is this item)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Approved for planning
- **Version:** 1.0

## Overview

This feature fixes the thirteen Part B defects (B1-B13) that the first consumer run of `/documentation-workflow` exposed in the documentation tooling, hooks, templates, skills, MCP wrapper, and Python CLI analyzer. The authoritative defect text is the body of issue #1169, section `### Part B - Defects found in the run`. Root causes, selected options, mirror sets and file sizes come from `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/research/research.2026-11-14T05-18.md`.

- Target users: the root session that runs `/documentation-workflow` (consumer), the `docs-reconciler` role and its operator (reconciler), and the `docs-author` and `docs-architect` roles and the operator who plans pages (author).
- Success measures:
  - A first inventory run completes without a stop-hook loop.
  - Reconciling an estate the size of the consumer run (about 3,000 elements) completes in minutes through the supported `update-ledger` path.
  - Templates, generated reference pages, starter profiles, and inventory output pass `check` and `validate-profile` without manual edits.
  - Estate hashes are stable under a CRLF checkout.

### Delivery Decision D1 (binding)

B1-B13 are delivered as one feature with one spec, one plan, and one pull request. The research recommendation of an epic with four children is declined for three reasons: an item orchestrator cannot launch an epic; autonomous mode forbids halting for re-routing; and serial staged pull requests would conflict on shared files (`Invoke-DocsCommand.ps1`, `mcp-tool-inputs-docs.ts`, the skill mirror sets). The research grouping (ledger batch; reference split; estate defaults, integrity and role contract; Python CLI analyzer) may be used as plan phases.

### Out of Scope

- Part A (A1-A5), merged in PR #1175.
- Any change to the Claude Code runtime guard behind B12 (outside the repository).
- Any behavior change for B10 beyond the parity tests that its verdict supports.
- A profile schema change: no grouping key in `diataxis_policy` (B5) and no root-level exclusion list (B7).
- Writing `.gitattributes` from docs-init (B11).

## Mirror and Parity Obligations

Every change lands in all copies of its mirror set in the same commit. Named sets used below:

| Set | Members |
|---|---|
| M-LIB | `.claude/lib/docs/<file>` and the byte-identical bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/<file>`. Applies to `.psm1`, `.ps1`, and the native Python files under `.claude/lib/docs/python/docs_python_native/`. |
| M-HOOK | `.claude/hooks/<file>` and the byte-identical bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<file>`. No Codex twin exists for the docs role hooks. |
| M-SKILL | `.claude/skills/<skill>/`, `.agents/skills/<skill>/`, `.github/skills/<skill>/`, and the bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`, and `extensions/drm-copilot/resources/customizations/.github/skills/`. Host copies keep their existing host-specific differences (for example, omission of `.claude/` text) as enforced by `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` and `docs-authoring-roles.Mirrors.Tests.ps1`. |
| M-AGENT | `.claude/agents/<agent>.md`, `.codex/agents/<agent>.toml`, `.github/agents/<agent>.agent.md`, and their bundle copies under the three `extensions/drm-copilot/resources/` roots. Codex copies are regenerated through the Codex generator and pass its `--check` mode. |
| M-BRIEF | `execution-environment/SKILL.md` in the M-SKILL roots; these copies are byte-identical and change together whenever a stated fact changes. |
| M-MANIFEST | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: every new `.claude/lib/docs` module is listed, and its `$PSScriptRoot` dependencies satisfy the dependency-closure test. |
| M-TS | TypeScript under `extensions/drm-copilot/src/`; a new file receives its own entry in `extensions/drm-copilot/jest.docs-coverage.json` (lines 85, branches 75) in the task that creates it. |

Parity checks that must pass: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, the pack-manifest completeness and dependency-closure tests, the Codex generator `--check`, and `tests/scripts/claude-runtime/docs-authoring-roles.Mirrors.Tests.ps1`.

## Behavior

### B1. docs-architect first inventory run completes without a stop-hook loop

- Root cause: `.claude/hooks/docs-role-contract.ps1`, `Get-DocsRoleSpecificFinding`, `docs-architect` branch, passes `docs-snapshot` to `Get-DocsRolePathFinding`, which requires the path to exist for every `docs-result` value. The role holds no write tool and `run_docs_inventory` never writes, so on a first run the snapshot cannot exist and the repairable finding repeats.
- Selected option (research recommendation; consistent with #1169): relative-form-only check for `docs-snapshot` plus a root `inventory -Write` step.
- Required behavior:
  1. `Get-DocsRolePathFinding` gains a switch (for example `-SkipExistence`). The `docs-architect` branch uses it for `docs-snapshot` only.
  2. `docs-snapshot` still fails when the value is not a repository-relative path (unchanged rule and message).
  3. `docs-profile` and `docs-pages-written` keep the existence probe unchanged.
  4. A `docs-architect` report with a valid profile, a relative snapshot path that does not exist, and `docs-result: PASS` is accepted (`Ok = $true`).
  5. `.claude/skills/documentation-workflow/SKILL.md` `## Dispatch Order` gains a root step between step 1 and step 2: the root runs `inventory -Write` and persists the snapshot before delegating the inventory role. `docs-inventory-surface/SKILL.md` states that the root persists the snapshot before delegation.
- Mirrors: M-HOOK (`docs-role-contract.ps1`); M-SKILL (`documentation-workflow`, `docs-inventory-surface`); M-BRIEF: `## Hook Execution Context` currently states that `validate-docs-role-output.ps1` probes the `docs-profile`, `docs-snapshot`, and `docs-pages-written` values; that sentence is corrected to state that `docs-snapshot` is checked for relative form only. Optional: align `docs-architect` text in M-AGENT (token contract unchanged).
- Tests:
  - Updated: `tests/scripts/claude-hooks/validate-docs-role-output.TargetWorktree.Tests.ps1`, `docs-architect` row now expects only the profile probe (reason: snapshot existence is no longer probed).
  - New: first-run case in `tests/scripts/claude-hooks/docs-role-contract.Tests.ps1` (profile present, snapshot absent, `PASS`, accepted) and a relative-path rejection case for `docs-snapshot`; a matching envelope case in `tests/scripts/claude-hooks/validate-docs-role-output.Tests.ps1`.
  - New: skill-text test asserting the root `inventory -Write` step in every M-SKILL copy of `documentation-workflow`, and the corrected brief sentence in every M-BRIEF copy.
  - Hook test paths use forward slashes and exact case (Linux CI is case-sensitive).

### B2. update-ledger batch operation and bulk page-reference binding

- Root cause: one operation per process with a fixed per-call cost (schema composition, document set read and validation, rule evaluations; about 39 s), and copy-scan-sort merge helpers (`Merge-DocsLedgerEntry` in `DocsLedger.psm1`, `Merge-DocsParityDimension` in `DocsParity.psm1`, `Merge-DocsEvidencePin` in `DocsEvidencePins.psm1`, full scans in `Invoke-DocsLedgerOperation`), so N operations in one process cost O(N x M).
- Selected design (research recommendation):

#### B2.1 Operations document

- Shape: `{ "operations": [ { "operation": "...", ... } ] }`. Item fields use the MCP field names: `operation`, `element`, `limit`, `disposition`, `pages`, `rationale`, `owner`, `target`, `dimension`, `state`, `claim`. Item fields map through the existing `update_docs_ledger` field table, so the page of a `pin`, `unpin` or `set-dimension` item is given in `pages`, and `target` is the `set-disposition` target text (premise correction PC-2).
- Parsing and validation live in a new module `.claude/lib/docs/DocsLedgerBatch.psm1`, function `ConvertFrom-DocsLedgerOperationText`.
- Each item is mapped to the existing argument-map names and validated by the unchanged `Test-DocsUpdateLedgerArgument` with the batch's actor kind, actor id and profile. The single-operation grammar remains the only grammar.
- Rejected inputs (exit 2, finding pointer `/operations/<i>` for item errors): text that is not JSON; a root without an `operations` array; an empty array; an item that is not an object; an unknown key; an item whose `operation` is `sync-refs` (it rewrites every entry and remains a separate call); an item that fails `Test-DocsUpdateLedgerArgument`.

#### B2.2 Batch application

- `Invoke-DocsLedgerBatch` is pure over loaded documents.
- Operations are partitioned by target key: the element id, or the precision-limit diagnostic id for `-Limit` operations. Input order is preserved within a partition.
- For each partition, reduced documents containing only that key's ledger entry, matrix rows and pins are built; each operation runs through the unchanged `Invoke-DocsLedgerOperation`; results are spliced into ordinal dictionaries keyed by `element_id` (ledger), `element_id` + NUL + `page_path` (matrix rows), and `pin_id` (pins).
- After all partitions: each collection is sorted once with the existing sort helpers; the unchanged introduced-error comparison runs once (before = loaded documents, after = batch result); `Invoke-DocsArtifactWrite` is called once.
- Equivalence invariant: for any valid operations list, the written bytes of the ledger, matrix and pins equal the bytes produced by applying the same operations one at a time, in input order, through the single-operation path.
- All-or-nothing: an introduced error or a `DOCS_UPDATE_TARGET_INVALID` on any item rejects the whole batch, writes nothing, and the finding names the item index.
- The documents are loaded and validated once per batch invocation.

#### B2.3 CLI

- `Invoke-DocsCommand.ps1`, `Get-DocsCommandTable`, row `update-ledger` gains `Operations = 'value'`.
- `-Operations <value>`: a repository-relative path read through `Context.ReadText`, or `-`, read through a new context member `ReadStdin` added in `New-DocsCommandContext` (`[Console]::In.ReadToEnd()` in production; an in-memory string in tests).
- `-Operations` and `-Operation` are mutually exclusive; supplying both, or a per-operation option together with `-Operations`, exits 2.
- `Invoke-DocsUpdateLedgerCommand` dispatches to `Invoke-DocsLedgerBatch` when `Operations` is present. `-Help` usage text lists `-Operations`.

#### B2.4 bind-page-refs operation

- New operation `bind-page-refs` in `.claude/lib/docs/DocsLedgerBindRefs.psm1`; target `none`; valid as a single CLI operation and as a batch item.
- Behavior: read every page in the profile's documentation roots (page list from `Read-DocsLedgerInputSet`), parse front-matter `surface_refs` with the existing parser in `DocsPageFrontMatter.psm1`, and for each referenced element present in the snapshot set disposition `documented` with page bindings equal to the union of existing bindings and referencing pages.
- An id absent from the snapshot yields a warning finding and no change. No existing binding is removed. Running it twice produces identical bytes (idempotent).
- `sync-refs` is unchanged. The skill text states the difference: `sync-refs` refreshes snapshot and ledger pins; `bind-page-refs` creates `documented` dispositions and page bindings from `surface_refs`.

#### B2.5 MCP

- `update_docs_ledger` gains an `operations` field: an array of objects.
- The TypeScript resolver validates: the value is an array; each item is an object; `operation` is a ledger operation other than `sync-refs`; no unknown keys; string fields reuse the `matchesDocsGrammar` grammars. `operation` and `operations` are mutually exclusive; exactly one is required.
- The resolver serializes `{ "operations": [...] }`, emits `-Operations -`, and passes the text as standard input. Inline transfer is required because `docs-reconciler` holds no Write tool; standard input also avoids the Windows command-line length limit.
- Files: batch validation and serialization in a new `extensions/drm-copilot/src/mcp-tool-inputs-docs-ledger-batch.ts`; `mcp-tool-inputs-docs.ts` (492 lines) receives only the table row, the `operation` requiredness change, and an optional `stdin` on `ResolvedDocsToolInput`; `mcp-docs-tool-definitions.ts` `fieldSchema` gains the array-of-objects case and an `operations` description; `repo-automation-execute-docs.ts` `DocsCommandRequest` gains optional `stdin`, and `invokeDocsCommand` passes it to `launcher.launch` (empty string when absent); `mcp-handlers/docs-handlers.ts` passes the object through unchanged.
- The MCP `operations` field is usable only after a release of the extension that carries it; the CLI path works from the branch immediately.

#### B2.6 Skills and agents

- `docs-reconcile-behavior` (M-SKILL) and `docs-reconciler` (M-AGENT) document `operations`, `bind-page-refs`, the all-or-nothing rule, and that `sync-refs` is not a batch item.

#### B2.7 Performance evidence

- A measured CLI run of `update-ledger -Operations <path>` on an estate of at least 3,000 snapshot elements with at least 15,000 operations (about five per element: disposition, exists, owner assignment, accurate with claim, and a pin or binding) is recorded as evidence under `docs/features/active/2026-11-14-documentation-workflow-tooling-defects-part-b-1173/evidence/other/`.
- The evidence records `Timestamp` (read from the clock), `Command`, `EXIT_CODE`, element count, operation count, elapsed wall-clock time, and `Output Summary`, with no absolute path. The run must exit 0 and complete in at most 10 minutes.
- The estate may be synthetic and generated by a throwaway PowerShell script in the issue scratch directory; it is not committed. This measurement is evidence, not a unit test; no unit test measures time.

- File-size constraints: `DocsLedgerCommands.psm1` (707 lines) receives only the dispatch branch and export-list changes; `Invoke-DocsCommand.ps1` (621 lines) receives only the table row and `ReadStdin`; `DocsLedgerCommands.UpdateLedger.Tests.ps1` and `DocsLedgerCommands.Tests.ps1` receive no new cases except updates required by the changed usage text.
- Mirrors: M-LIB (new and changed modules), M-MANIFEST (both new modules), M-TS, M-SKILL, M-AGENT.
- Tests:
  - New `tests/scripts/claude-lib/docs/DocsLedgerBatch.Tests.ps1`: batch-versus-sequential byte equivalence over a generated in-memory sample covering every batchable operation; all-or-nothing rejection with item index; `sync-refs` rejection; each B2.1 rejection; stdin source through the in-memory `ReadStdin`; mutual exclusion of `-Operation` and `-Operations`; single write call.
  - New `DocsLedgerBatch.Properties.Tests.ps1`: order within a partition is preserved; permuting partitions does not change output.
  - New `DocsLedgerBindRefs.Tests.ps1`: binding from `surface_refs`, union with existing bindings, unknown-id warning, no removal, idempotence, batch-item use.
  - Jest: new `extensions/drm-copilot/test/mcp-tool-inputs-docs-ledger-batch.test.ts`; updates to `mcp-tool-inputs-docs.test.ts`, `mcp-docs-tool-definitions.test.ts`, `repo-automation-execute-docs.test.ts` (stdin forwarded), `mcp-handlers/docs-handlers.test.ts`, `mcp-server.docs.test.ts`. A test asserting that `operation` is always required or that stdin is always `""` is updated with that reason.
  - Skill-text test: every `-Command update-ledger -Operations` reference in a skill is a dispatch-table option (existing check in `docs-authoring-roles.Skills.Tests.ps1`).

### B3. Pin before `accurate = pass`

- Root cause: `Invoke-DocsLedgerOperation`, `set-dimension` branch, attaches only existing pins; without a prior `pin`, the matrix rule reports `DOCS_MATRIX_ACCURACY_UNPINNED` as an introduced error. The skill states no ordering.
- Required behavior:
  1. `docs-reconcile-behavior` (M-SKILL) and `docs-reconciler` (M-AGENT) state: `pin` for the same element and page must precede `set-dimension` with `dimension: accurate` and `state: pass`.
  2. In the batch path only, a `set-dimension` item with `dimension: accurate`, `state: pass`, and a non-empty `claim` is applied as a `pin` with that claim for the same element and page, followed by the dimension. The pin uses the single-operation `pin` semantics unchanged.
  3. `claim` on any other batch item is rejected (exit 2, item index).
  4. The single-operation CLI grammar is unchanged: `-Operation set-dimension` does not accept a claim.
- Tests (in `DocsLedgerBatch.Tests.ps1`): an accurate-pass item with `claim` yields a pin and no introduced error; the same item without `claim` and without a prior pin rejects the batch with `DOCS_MATRIX_ACCURACY_UNPINNED`; `claim` on a non-accurate item is rejected. Skill-text test asserting the ordering sentence in every M-SKILL copy of `docs-reconcile-behavior`.

### B4. Page templates write `audience` as a list

- Root cause: every `docs-author-page/templates/*.md` front matter has `audience: "<audience-id>"`; `DocsPageMetadata.psm1` requires a list (`DOCS_PAGE_AUDIENCE_INVALID`).
- Required behavior: every template copy in every M-SKILL root reads `audience: ["<audience-id>"]`. The research numeric derivation (N1) enumerates eight template names under each skill root; the existing assertion `covers 48 template files` in `docs-authoring-roles.Templates.Tests.ps1` remains the count check.
- Tests: new case in `tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1` that, for each template row, substitutes valid values for `<owner-id>`, `<yyyy-mm-dd>`, `<audience-id>` and `<element-id>` in memory and runs the front matter through `Test-DocsPageFrontMatter` (`DocsPageFrontMatter.psm1`), expecting no finding with code `DOCS_PAGE_AUDIENCE_INVALID`. No file is written. `docs-authoring-roles.Mirrors.Tests.ps1` passes.

### B5. Generated reference pages stay below the page bound

- Root cause: `DocsReferencePlan.psm1` plans one page per family (`api-reference.md`, `cli-reference.md`, `config-reference.md`, `http-reference.md`); `DocsPageCheck.psm1` rejects a page above 1,048,576 bytes with `DOCS_PAGE_TOO_LARGE`.
- Selected option (research recommendation; #1169 permits splitting or grouping and permits an element filter instead of out-of-repository snapshots): automatic split plus a `-PathPrefix` element filter. `-Snapshot` stays repository-relative.
- Required behavior:
  1. New module `.claude/lib/docs/DocsReferenceSplit.psm1`. After a family page is rendered, when its UTF-8 byte size exceeds the split budget of 921,600 bytes (900 KiB), the family is planned as an index page at the family path plus group pages `<OutputDirectory>/<family-stem>/<group>.md`.
  2. Group key: the first path segment of the element `path` beneath the longest matching `surface_selection.source_roots` entry. An element whose path has no segment beneath its root is grouped under the reserved key `_root`.
  3. A group page still above the budget is split into ordinal parts `<group>-<n>.md`, `n` starting at 1, filled in element order.
  4. Group order and element order are ordinal and deterministic; the same snapshot yields the same page set and bytes.
  5. The index page links every group or part page and carries the family's front matter. Every emitted page is at or below the budget.
  6. A family at or below the budget is emitted as a single page exactly as today (bytes unchanged).
  7. `Get-DocsReferenceCandidatePagePath` also lists existing pages under each `<family-stem>/` directory through `Context.ListFile`, so existing split pages are updated rather than recreated. A split page whose group no longer exists yields a warning finding and is not deleted.
  8. `generate-reference -PathPrefix <prefix>` (repeatable) selects elements whose `path` starts with one of the prefixes (ordinal). Each prefix must be a repository-relative path, else exit 2. With no prefix, all elements are selected.
  9. MCP `generate_docs_reference` gains `path_prefixes` (array of repository-relative strings) mapped to `-PathPrefix`.
- Mirrors: M-LIB (new module, `DocsReferencePlan.psm1`, `DocsReferenceWriter.psm1`, `Invoke-DocsCommand.ps1` table row), M-MANIFEST, M-TS, and the `docs-generate-reference` skill text if it documents options (M-SKILL).
- Tests: new `tests/scripts/claude-lib/docs/DocsReferenceSplit.Tests.ps1` (below budget gives one page with unchanged bytes; above budget gives index plus group pages; oversize group gives parts; `_root` grouping; determinism; every page at or below budget; stale group page warning without deletion); `-PathPrefix` selection and invalid-prefix cases; Jest case for `path_prefixes`. Existing `DocsReferenceWriter*.Tests.ps1` candidate-set assertions are updated with the reason that split directories are now listed.

### B6. Source roots are detected and validated

- Root cause: `New-DocsStarterProfile` (`DocsProfile.psm1`) hard-codes `source_roots = @('src')`; neither `init` nor `validate-profile` tests a source root.
- Required behavior:
  1. `validate-profile`, and `init` after building the profile, report an error `DOCS_PROFILE_SOURCE_ROOT_MISSING` at `/surface_selection/source_roots/<i>` for each source root for which `Context.ListFile` returns no file. The command exits 1 when such a finding exists. `Test-DocsProfileSemantic` stays pure; the check lives in the command layer.
  2. New module `.claude/lib/docs/DocsProfileSourceRoot.psm1` detects the init default in this order: `src` when it lists files; otherwise the package directory from `pyproject.toml` (`[tool.poetry].packages[].include`, else `[project].name`, else `[tool.poetry].name`, with `-` mapped to `_`) when that directory lists files, read with `DocsTomlKeys.psm1`; when neither lists files, `src` is retained, and `init` and `validate-profile` then report `DOCS_PROFILE_SOURCE_ROOT_MISSING` for it (premise correction PC-1: a `.` source root is not a valid repository-relative path, because the common schema `relative-path` pattern and `Test-DocsRelativePath` reject a `.` segment and `Get-DocsContextFileList` throws `DOCS_CONTEXT_PATH_INVALID` for it).
  3. `New-DocsStarterProfile` gains `-SourceRoot` with default `@('src')`, so existing callers are unchanged.
- Detection of `package.json` and `.csproj` package roots is not added; `src` or the `pyproject.toml` package directory covers those layouts, and the `validate-profile` error reports any mismatch so the operator can edit the profile.
- Mirrors: M-LIB, M-MANIFEST; `docs-init` skill text (M-SKILL) if it states the default.
- Tests: new `tests/scripts/claude-lib/docs/DocsProfileSourceRoot.Tests.ps1` (each detection branch, `-` to `_` mapping, the retained `src` fallback when neither candidate lists files); `validate-profile` missing-root error and existing-root pass.

### B7. Malformed link targets are findings, and the starter root avoids planning trees

- Root cause: `Get-DocsPageExternalTarget` (`DocsPageLinks.psm1`) returns resolved paths that fail `Test-DocsRelativePath` (for example a target containing `|`); `Invoke-DocsCheckCommand` passes them to `Context.TestFile`, and `Get-DocsContextFullPath` throws `DOCS_CONTEXT_PATH_INVALID`, ending the command with exit 3.
- Required behavior:
  1. `Get-DocsPageExternalTarget` skips a resolved path that fails `Test-DocsRelativePath`. `Get-DocsPageLinkFinding` reports `DOCS_PAGE_LINK_BROKEN` for it. `check` on such a page exits 1 with that finding and never exits 3 for this cause.
  2. `New-DocsStarterProfile` gains `-DocumentationRoot` whose default is `docs/guide` (root id `guide`) instead of `docs`. A starter profile therefore never contains `docs/features/`.
- Rejected: a profile root-level exclusion list (schema change in three schema copies).
- Mirrors: M-LIB; `docs-init` skill text (M-SKILL) where it names the default root.
- Tests: `DocsPageLinks.Tests.ps1` gains a malformed-target case; new `tests/scripts/claude-lib/docs/DocsPageCheck.MalformedLink.Tests.ps1` (command-level exit 1 with `DOCS_PAGE_LINK_BROKEN`, not exit 3), because `DocsPageCheck.Tests.ps1` is 696 lines; starter-profile default-root case. Tests that call `New-DocsStarterProfile` and depend on its root are located and updated with that reason.

### B8. Inventory excludes bytecode caches and tool directories by default

- Root cause: `Get-DocsContextFileList` enumerates every file; `Get-DocsInventorySelection` (`DocsInventorySnapshot.psm1`) applies only profile `exclusions`; `New-DocsCapturedInput` emits `DOCS_INPUT_NOT_UTF8` per undecodable file.
- Selected option: a built-in default exclusion list (honoring `.gitignore` is rejected because it needs a git process in a selection path that is pure today).
- Required behavior: `Get-DocsInventorySelection` excludes, before profile exclusions, any path with a segment equal (ordinal) to `__pycache__`, `.git`, `node_modules`, `.venv`, `venv`, `.mypy_cache`, `.pytest_cache`, `.ruff_cache`, `.tox`, `dist`, or `build`, and any file ending in `.pyc` or `.pyo`. A default-excluded path is not read and yields no diagnostic. Profile exclusions still apply after the default list. The list is a single exported constant.
- Mirrors: M-LIB; `docs-inventory-surface` skill text (M-SKILL) states the default exclusions.
- Tests: `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` gains cases for each segment, each extension, a near-miss segment (for example `builds`) that is not excluded, and absence of `DOCS_INPUT_NOT_UTF8` for an excluded `.pyc` input.

### B9. Python CLI analyzer resolves cross-module subparser registration

- Root cause: a call `subparsers.add_parser(...)` inside `def register(subparsers): ...` has a receiver that is a function parameter, not a tracked receiver; both the native recognizer (`.claude/lib/docs/python/docs_python_native/cli_argparse.py`, `recognize_argparse` and `_resolve`) and the scanner (`.claude/lib/docs/DocsPythonCliArgparse.psm1`) record `CLI_UNBOUND_REGISTRATION`.
- Required behavior:
  1. Within a module, a function parameter that is the receiver of `add_parser` is seeded as a provisional `subparsers` role with an unresolved parent.
  2. Across modules, the provisional role is bound when a resolved `subparsers` receiver is passed as an argument to that function at a call site in another module, resolved through the existing import tables (`imports.py` for the native path; the scanner's binding tables).
  3. Commands and options registered through a bound parameter are emitted as `cli-command` and `cli-option` elements under the parent command, with the same element identity rules as same-module registration.
  4. A registration through a parameter with no resolvable caller keeps `CLI_UNBOUND_REGISTRATION`.
  5. The native and scanner paths produce the same elements for the shared fixture.
- Constraint: only existing Python files change (the recognizer and the native collector that sees all modules, located by the planner); no new Python file.
- Mirrors: M-LIB (Python and PowerShell).
- Tests: one shared fixture layout (`cli.py` creates `add_subparsers` and calls `cli_daily.register(subparsers)`; `cli_daily.py` defines `register(subparsers)` with `add_parser` and `add_argument`) added to `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` and `python-native-corpus.json`; cases in `DocsPythonCliArgparse.Tests.ps1`, `tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_argparse.py`, and `test_docs_python_native_cli.py`, including the unresolvable-caller case.

### B10. MCP and CLI diagnostics (verdict: refuted at code level)

- Verdict: refuted. The MCP path (`mcp-tool-inputs-docs.ts` table, `invokeDocsCommand` in `repo-automation-execute-docs.ts`, `toEnvelope` in `docs-command-envelope.ts`, `handleDocsTool` in `mcp-handlers/docs-handlers.ts`) returns the `-Json` envelope's `result` unchanged; the CLI text report and the JSON envelope are built from the same `New-DocsCommandResult`; `DOCS_INPUT_NOT_UTF8` is attached at capture before analyzer selection. The observed 509 versus 819 difference is attributed to the role's summary or to a working-tree difference between runs; it was not reproduced.
- Required behavior: none beyond the parity tests below. No production change is made for B10.
- Tests that prove the verdict:
  1. New `tests/scripts/claude-lib/docs/Invoke-DocsCommand.InventoryParity.Tests.ps1`: one in-memory context with a non-UTF-8 input; run `Invoke-DocsCommandCli -Command inventory` with and without `-Json`; assert that `diagnostics=<n>` in the text output equals the count of `result.snapshot.diagnostics` in the envelope and that the envelope includes a `DOCS_INPUT_NOT_UTF8` entry. The input path must not be default-excluded by B8.
  2. Jest case in `extensions/drm-copilot/test/mcp-handlers/docs-handlers.test.ts`: an envelope whose `result.snapshot.diagnostics` holds a `DOCS_INPUT_NOT_UTF8` entry is returned by the handler with that entry and an unchanged diagnostic count.

### B11. Estate artifact hashes are line-ending stable (verdict: confirmed for artifact hashes, refuted for element digests)

- Verdict: confirmed for artifact reference hashes (ledger `snapshot_ref`, matrix ledger and snapshot references, receipt artifact hashes, write conflict checks, snapshot input hashes), which hash raw bytes through `Get-DocsBytesSha256Hex`; a CRLF checkout of LF-written JSON changes them. Refuted for element `source_sha256`, which `DocsSurface.psm1` already computes over LF-normalized text.
- Selected option: hash normalization (#1169 permits either); no `.gitattributes` write, because that path is outside the docs-only allowlists and a repository may already own the file.
- Required behavior:
  1. `DocsJson.psm1` gains `Get-DocsTextSha256Hex -Bytes`, which maps CRLF and lone CR to LF at byte level and returns the SHA-256 hex of the result.
  2. For LF-only content its value equals `Get-DocsBytesSha256Hex`, so committed LF estates keep their stored hashes.
  3. It replaces `Get-DocsBytesSha256Hex` at every artifact-reference and conflict-check site: `DocsLedgerCommands.psm1` (`ConvertFrom-DocsLedgerCommandArtifact`), `DocsValidation.psm1`, `DocsReceipt.psm1`, `DocsLedgerMutation.psm1`, `DocsValidateCommands.psm1`, `DocsReferenceWriter.psm1` (page hashes), `DocsSurfaceDeltaCommands.psm1`, and capture input hashes in `DocsAnalyzerRegistry.psm1` `New-DocsCapturedInput`.
  4. `Get-DiscoveryBytesSha256Hex` (shared with the discovery library) is not changed. Element digest computation is not changed.
- Mirrors: M-LIB.
- Tests: `tests/scripts/claude-lib/docs/DocsJson.Tests.ps1`: LF, CRLF and lone-CR byte forms of one text give equal hashes; LF content equals the raw-byte hash. Command-level case: `update-ledger` over a ledger and snapshot whose bytes are CRLF-encoded in the in-memory context reports no snapshot or ledger reference drift. CRLF bytes are built in memory, because committed text fixtures are normalized to LF.

### B12. Page names refused by the runtime report-file guard

- Verdict: the refusal text "Subagents should return findings as text, not write report files" is not produced by any file in the repository (search of the whole worktree; `.claude/hooks/enforce-docs-role-write-scope.ps1` denies only with `DOCS_ROLE_WRITE_SCOPE_BLOCKED:` reasons). It is Claude Code runtime behavior for subagents and cannot be exempted from the repository.
- Selected option: document the naming restriction.
- Required behavior:
  1. `docs-plan-ia` (M-SKILL) states: plan page file names that do not contain the words `report`, `summary`, `findings` or `analysis`, or assign such pages to a root authoring step.
  2. `docs-author-page` (M-SKILL) and `docs-author` (M-AGENT) state: a subagent write of a Markdown page whose name contains one of those words may be refused by the runtime; the author reports the page as unwritten and the root writes it.
- Tests: skill-text test in `tests/scripts/claude-runtime/` asserting the restriction sentence in every M-SKILL copy of `docs-plan-ia` and `docs-author-page` and in every M-AGENT copy of `docs-author`.

### B13. docs-init reports the CI workflow it adds

- Current state: Part A added a `## Linter Configuration` paragraph naming `.github/workflows/_docs-quality.yml`; `## Steps` and `## Result` do not state that init adds a CI workflow; `Invoke-DocsInitCommand` emits an ordinary `<action> <path>` line for it.
- Required behavior:
  1. `docs-init` (M-SKILL) `## Steps` and `## Result` each state that init adds the CI workflow `.github/workflows/_docs-quality.yml`.
  2. `Invoke-DocsInitCommand` emits, in addition to the existing action line, a distinct line `ci-workflow <path>` for the template row whose destination starts with `.github/workflows/`, in both dry-run and `-Write` modes.
  3. The command result gains a field `ci_workflow`: the workflow path, or `null` when no template row targets `.github/workflows/`.
- Mirrors: M-LIB (`DocsProfileCommands.psm1`), M-SKILL.
- Tests: `DocsInitTemplate.DocsWorkflow.Tests.ps1` gains cases for the `ci-workflow` line and the `ci_workflow` field (dry run and write) and the `null` case; skill-text test for the Steps and Result sentences in every M-SKILL copy.

## Inputs / Outputs

- New inputs: `update-ledger -Operations <path|->`; operations document JSON; standard input through `ReadStdin`; `generate-reference -PathPrefix <prefix>`; MCP `update_docs_ledger.operations`; MCP `generate_docs_reference.path_prefixes`.
- New outputs: `bind-page-refs` ledger writes; split reference pages and index pages; `DOCS_PROFILE_SOURCE_ROOT_MISSING` findings; `ci-workflow <path>` line and `ci_workflow` result field; B2.7 performance evidence.
- Defaults changed: starter profile `documentation_roots` default `docs/guide`; starter `source_roots` detected (B6); inventory default exclusions (B8).
- Compatibility: the single-operation `update-ledger` grammar is unchanged; existing LF estates keep their hashes; a family page at or below the split budget is byte-identical to today; `New-DocsStarterProfile` callers that pass no new parameter keep `source_roots = src`.

## API / CLI Surface

```text
Invoke-DocsCommand.ps1 -Command update-ledger -Operations docs/documentation-estate/ops.json
Invoke-DocsCommand.ps1 -Command update-ledger -Operations -          # operations JSON on stdin
Invoke-DocsCommand.ps1 -Command update-ledger -Operation bind-page-refs
Invoke-DocsCommand.ps1 -Command generate-reference -PathPrefix pkg/core -PathPrefix pkg/io -Write
```

```json
{ "operations": [
  { "operation": "set-disposition", "element": "<id>", "disposition": "documented", "pages": ["docs/guide/api.md"] },
  { "operation": "set-dimension", "element": "<id>", "pages": ["docs/guide/api.md"], "dimension": "accurate", "state": "pass", "claim": "<claim text>" },
  { "operation": "bind-page-refs" }
] }
```

Exit codes follow the existing contract: 0 success, 1 findings, 2 argument or input-document error, 3 runtime failure.

## Data & State

- Ledger, matrix and pins: batch output is byte-identical to sequential application; writes occur once per batch; a rejected batch writes nothing.
- Hashes: artifact reference hashes are computed over LF-normalized bytes; stored values for LF estates do not change, so no migration is needed.
- Reference pages: split pages live under `<OutputDirectory>/<family-stem>/`; stale split pages are reported, not deleted.

## Constraints & Risks

- Languages: no new Python file; existing Python changes only for B9. Hooks stay PowerShell or bash and never invoke Python. TypeScript only for MCP and extension code.
- File-size tiers: new logic goes into new modules when a file is near or above 500, 700, or 800 lines. Named limits: `DocsLedgerCommands.psm1` (707) dispatch and exports only; `Invoke-DocsCommand.ps1` (621) table rows and `ReadStdin` only; `mcp-tool-inputs-docs.ts` (492) table rows and requiredness only; `DocsPageCheck.Tests.ps1` (696) and `DocsLedgerCommands.UpdateLedger.Tests.ps1` (651) receive no new cases. No file may exceed 800 lines.
- Tests: in `tests/` mirroring the source layout (Jest tests under `extensions/drm-copilot/test/`); no temporary files; in-memory seams (`New-DocsTestContext` style contexts, in-memory `ReadStdin`, in-memory CRLF bytes); no test measures time.
- Coverage: at least 85% line per changed PowerShell file; at least 85% line and 75% branch per changed TypeScript and Python file; no regression on changed lines.
- Test runs: parallel only (one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, Jest with its normal workers); no serial, single-process, shuffled or reversed runs; one suite at a time; integration and golden suites run in CI, not locally. A focused run of one file is for debugging only.
- Test-order dependence is a violation: a leak is fixed in both the leaking and the affected suite; no ordering or sharding workaround.
- Evidence is append-only; every timestamp is read from the clock; no absolute path is recorded.
- Cadence: a task check after each task; the full seven-stage toolchain loop at each phase gate and in the final QA loop.
- Pre-mortem and self-review before every push.
- Related findings discovered during delivery are fixed inside this item through remediation cycles; new issues are filed only for unrelated findings.
- Risk: the MCP `operations` field reaches consumers only after an extension release; the CLI path is available immediately.
- Risk: the B2 equivalence depends on operations on different keys touching disjoint records; the property tests guard it.
- Risk: B7 changes the starter root, so tests that relied on `docs` as the default are updated, not worked around.

## Implementation Strategy

- New PowerShell modules: `DocsLedgerBatch.psm1` (`ConvertFrom-DocsLedgerOperationText`, `Invoke-DocsLedgerBatch`), `DocsLedgerBindRefs.psm1`, `DocsReferenceSplit.psm1`, `DocsProfileSourceRoot.psm1`; each listed in M-MANIFEST.
- Changed PowerShell: `DocsLedgerCommands.psm1`, `Invoke-DocsCommand.ps1`, `DocsReferencePlan.psm1`, `DocsReferenceWriter.psm1`, `DocsProfile.psm1`, `DocsProfileCommands.psm1`, `DocsPageLinks.psm1`, `DocsInventorySnapshot.psm1`, `DocsPythonCliArgparse.psm1`, `DocsJson.psm1` and the B11 hash call sites, `.claude/hooks/docs-role-contract.ps1`.
- Changed Python: `cli_argparse.py` and the native collector.
- TypeScript: new `mcp-tool-inputs-docs-ledger-batch.ts`; changed `mcp-tool-inputs-docs.ts`, `mcp-docs-tool-definitions.ts`, `repo-automation-execute-docs.ts`, `jest.docs-coverage.json`.
- Markdown: skills `documentation-workflow`, `docs-inventory-surface`, `docs-reconcile-behavior`, `docs-plan-ia`, `docs-author-page` (and its templates), `docs-init`, `execution-environment` brief; agents `docs-reconciler`, `docs-author`.
- No dependency changes. Rollout: one pull request; the work is on the orchestrated large path.

## Acceptance Criteria

- [x] B1: `docs-role-contract.ps1` accepts a `docs-architect` report with a valid profile, a repository-relative `docs-snapshot` path that does not exist, and `docs-result: PASS`, and still rejects a non-relative `docs-snapshot` value; a first-run regression test covers both cases.
- [x] B1: every M-SKILL copy of `documentation-workflow` contains a root `inventory -Write` step before the inventory role is delegated, and every M-BRIEF copy states that `docs-snapshot` is checked for relative form only; skill-text tests assert both.
- [x] B2: `update-ledger -Operations <path>` and `update-ledger -Operations -` (standard input) apply an operations document with one load, one introduced-error comparison and one write, and the written ledger, matrix and pins are byte-identical to sequential single-operation application of the same operations; an equivalence test and a partition property test pass.
- [x] B2: a batch containing an item with an introduced error, an invalid target, an unknown key, or a `sync-refs` operation writes nothing and reports the item index; supplying `-Operation` with `-Operations` exits 2.
- [x] B2: `bind-page-refs` sets `documented` and the union of page bindings for every snapshot element referenced in page `surface_refs`, warns on unknown ids, removes no binding, and is idempotent; tests cover each rule.
- [x] B2: MCP `update_docs_ledger` accepts an `operations` array, rejects it together with `operation`, validates each item, and forwards the serialized document as standard input with `-Operations -`; Jest tests cover the new module at 85% line and 75% branch, and its `jest.docs-coverage.json` entry exists.
- [x] B2: a measured CLI run of `update-ledger -Operations` on an estate of at least 3,000 elements with at least 15,000 operations exits 0 in at most 10 minutes, recorded under the feature `evidence/other/` folder with a clock-read timestamp, command, exit code, counts and elapsed time.
- [x] B2: every M-SKILL copy of `docs-reconcile-behavior` and every M-AGENT copy of `docs-reconciler` document `-Operations`, `bind-page-refs`, the all-or-nothing rule, and that `sync-refs` is not a batch item.
- [x] B3: every M-SKILL copy of `docs-reconcile-behavior` and every M-AGENT copy of `docs-reconciler` state that `pin` must precede `set-dimension accurate pass` for the same element and page; a skill-text test asserts it.
- [x] B3: a batch `set-dimension accurate pass` item with a `claim` produces a pin and no introduced error; without a claim or prior pin the batch is rejected with `DOCS_MATRIX_ACCURACY_UNPINNED`; a claim on any other item is rejected.
- [x] B4: every `docs-author-page` template copy in every M-SKILL root declares `audience: ["<audience-id>"]`, and a test running each template's substituted front matter through `Test-DocsPageFrontMatter` reports no `DOCS_PAGE_AUDIENCE_INVALID`.
- [x] B5: `generate-reference` splits a family page whose rendered size exceeds the split budget into an index page and group pages (and ordinal parts for an oversize group), every emitted page is at or below the budget, output is deterministic, and a family at or below the budget is byte-identical to the current output; `DocsReferenceSplit.Tests.ps1` covers each rule.
- [x] B5: `generate-reference -PathPrefix` and MCP `path_prefixes` restrict elements by ordinal path prefix without a filtered snapshot copy, and a non-relative prefix exits 2.
- [x] B6: `validate-profile` and `init` report `DOCS_PROFILE_SOURCE_ROOT_MISSING` for a source root that lists no files, and `init` selects `src`, else the `pyproject.toml` package directory, else retains `src` (which then reports `DOCS_PROFILE_SOURCE_ROOT_MISSING`); tests cover each branch.
- [x] B7: `check` on a page whose link target is not a repository-relative path exits 1 with `DOCS_PAGE_LINK_BROKEN` instead of exiting 3, and the starter profile documentation root defaults to `docs/guide`; tests cover both.
- [x] B8: inventory skips paths with a default-excluded segment or a `.pyc` or `.pyo` extension without reading them or emitting a diagnostic, and still includes a near-miss path; tests cover each list entry.
- [ ] B9: the native recognizer and the scanner emit `cli-command` and `cli-option` elements for subcommands registered through a `subparsers` parameter in another module, emit identical elements for the shared fixture, and keep `CLI_UNBOUND_REGISTRATION` for an unresolvable caller.
- [x] B10: the refuted verdict is recorded, no production change is made for it, and a Pester parity test (text versus JSON diagnostic count including `DOCS_INPUT_NOT_UTF8`) and a Jest pass-through test pass.
- [x] B11: `Get-DocsTextSha256Hex` returns equal values for LF, CRLF and lone-CR forms of a text and the raw-byte value for LF content, every listed artifact-reference and conflict-check site uses it, and `update-ledger` over CRLF-encoded estate bytes reports no reference drift.
- [x] B12: every M-SKILL copy of `docs-plan-ia` and `docs-author-page` and every M-AGENT copy of `docs-author` document the runtime naming restriction and the root fallback; a skill-text test asserts it.
- [x] B13: `init` emits a distinct `ci-workflow <path>` line and a `ci_workflow` result field in dry-run and write modes, and every M-SKILL copy of `docs-init` states in Steps and Result that init adds the CI workflow; tests cover the line, the field, the `null` case and the skill text.
- [ ] Every new `.claude/lib/docs` module is listed in `core.json` and bundled byte-identically, and the mirror, push-down contract, pack-manifest and Codex generator parity checks pass.
- [ ] Every item B1-B13 has at least one regression test that fails before the change and passes after it (for B10, the parity tests that prove the verdict).
- [ ] Each changed PowerShell file has at least 85% line coverage and each changed TypeScript or Python file has at least 85% line and 75% branch coverage, with no regression on changed lines.
- [ ] The full seven-stage toolchain loop passes in a single pass with parallel-only test runs and no test-order dependence.
- [ ] CI is green on the final pull request head.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (skills, agents, brief, and their mirrors)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)
