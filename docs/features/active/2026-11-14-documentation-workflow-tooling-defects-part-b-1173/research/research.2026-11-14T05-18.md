# Research: Documentation Workflow Tooling Defects, Part B (#1173)

- Timestamp: 2026-11-14T05-18 (UTC, read from an external clock service; the researcher has no shell)
- Issue: #1173 (Part B of #1169; Part A merged in PR #1175)
- Authoritative defect text: issue #1169 body, `### Part B - Defects found in the run` (B1-B13)
- Scope of evidence: the worktree for branch `feature/documentation-workflow-tooling-defects-1173`, read with Read, Grep and Glob only. Line numbers below are current-tree positions at this timestamp; the issue's line numbers are from an older revision.
- Line counts are logical lines counted with a ripgrep `^` line count per file.

## Summary of Recommendations

| Item | Status | Recommendation |
|---|---|---|
| B1 | Root cause confirmed | Check `docs-snapshot` for relative form only (no existence probe); add a root `inventory -Write` step before step 2 of the workflow; update the execution-environment brief (six copies). |
| B2 | Root cause confirmed | New module `DocsLedgerBatch.psm1`: `update-ledger -Operations <path or ->`; per-element partitioned application through the unchanged `Invoke-DocsLedgerOperation`, keyed splice, one sort, one introduced-error comparison, one write. New `bind-page-refs` operation in `DocsLedgerBindRefs.psm1`. MCP `operations` array passed on stdin. |
| B3 | Confirmed by skill text | Document pin-before-accurate ordering; in the batch path accept `claim` on `set-dimension accurate pass` and apply the pin first. |
| B4 | Confirmed | Change all 48 template copies to `audience: ["<audience-id>"]`; add a template-through-checker test. |
| B5 | Confirmed | New module `DocsReferenceSplit.psm1`: split a family page above a byte budget into per-group pages plus an index page; add a `-PathPrefix` element filter; keep `-Snapshot` repository-relative. |
| B6 | Confirmed | `validate-profile` error for a source root with no files; `init` detects `src`, else the pyproject package directory, else `.`. |
| B7 | Confirmed | Filter invalid resolved link paths out of the external-target probe so they become `DOCS_PAGE_LINK_BROKEN` findings; starter documentation root `docs/guide`. |
| B8 | Confirmed | Built-in default exclusion list applied in `Get-DocsInventorySelection` (bytecode caches, VCS and tool directories). |
| B9 | Confirmed | Resolve a function parameter used as an `add_parser` receiver as a subparsers role and bind it across modules, in both the scanner (`DocsPythonCliArgparse.psm1`) and the native recognizer (`cli_argparse.py`). |
| B10 | Refuted at code level | The MCP result carries the envelope unchanged; add a CLI text/JSON diagnostic-count parity test and a TypeScript pass-through test with diagnostics. |
| B11 | Confirmed for artifact hashes; refuted for element digests | Add a line-ending-normalizing artifact hash and use it at every artifact-reference and conflict-check site; no `.gitattributes` write. |
| B12 | Guard not in the repository | Runtime behavior of Claude Code subagents; document the naming restriction in `docs-plan-ia`, `docs-author-page` and the docs-author agent. |
| B13 | Partly addressed by Part A | State the CI workflow in the Steps and Result sections; emit a distinct `ci-workflow <path>` line and a `ci_workflow` result field from `init`. |

Delivery recommendation: an epic with four children (see `## Delivery Shape`).

## Current State and Per-Defect Findings

### B1. docs-architect first-run stop-hook loop

- Location: `.claude/hooks/docs-role-contract.ps1`, `Get-DocsRoleSpecificFinding`, `docs-architect` branch, the loop `foreach ($token in 'docs-profile', 'docs-snapshot')` calls `Get-DocsRolePathFinding`, which returns `"$Token path '$Path' does not exist"` when the injected `-TestFile` probe is false. The probe runs for every `docs-result` value.
- Caller: `.claude/hooks/validate-docs-role-output.ps1` probes `docs-profile`, `docs-snapshot` and `docs-pages-written` beneath the item worktree resolved by `Resolve-SubagentStopTargetWorktree` (#1163).
- Root cause: `docs-architect` holds no write tool (`.claude/agents/docs-architect.md` frontmatter: Read, Grep, Glob and three docs MCP tools), `run_docs_inventory` never writes (`DocsInventory.psm1` writes only with `-Write`, which the MCP table does not expose), and `.claude/skills/documentation-workflow/SKILL.md` `## Dispatch Order` has no root `inventory -Write` before step 2. On a first run the snapshot cannot exist, and the finding is marked repairable, so the role repeats its report.
- Change (selected): combine two of the issue's options.
  1. Hook: `Get-DocsRolePathFinding` gains a switch (for example `-SkipExistence`) used for `docs-snapshot` only; the token keeps the relative-path rule. `docs-profile` and `docs-pages-written` keep the existence probe. Existence of the snapshot is enforced later by `update-ledger`, `coverage` and `validate` (`DOCS_INPUT_UNREADABLE` in `Read-DocsLedgerCommandDocumentSet`).
  2. Workflow: add a root step "run `inventory -Write`" between step 1 and step 2 of `## Dispatch Order` in the six `documentation-workflow` copies, and state in `docs-inventory-surface` that the root persists the snapshot before delegation.
- Rejected: exempting `BLOCKED`/`FAIL` alone (a `PASS` first run still loops); a `docs-snapshot-persisted: false` token (adds contract surface and still needs the root step).
- Mirrors: `.claude/hooks/docs-role-contract.ps1` and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/docs-role-contract.ps1` (byte-identical, stated in the file's `.NOTES`). Claude only; no Codex twin exists (Glob `**/*docs-role*` returned only `.claude/hooks/` files, their bundle copies and tests). Workflow skill: `.claude/skills/documentation-workflow/SKILL.md`, `.agents/skills/...`, `.github/skills/...` and the three bundle copies under `extensions/drm-copilot/resources/{claude-customizations,codex-and-agents-customizations,customizations}/`. Agent text in `.claude/agents/docs-architect.md`, `.codex/agents/docs-architect.toml`, `.github/agents/docs-architect.agent.md` and bundles may be aligned (optional; the token contract is unchanged).
- Brief impact: `.claude/skills/execution-environment/SKILL.md` (`## Hook Execution Context`, agent target resolution item) states that `validate-docs-role-output.ps1` "probes the `docs-profile`, `docs-snapshot`, and `docs-pages-written` values". That fact changes, so the brief must be updated in all six byte-identical copies in the same change.
- Tests asserting current behavior:
  - `tests/scripts/claude-hooks/validate-docs-role-output.TargetWorktree.Tests.ps1`: the `docs-architect` row expects two probes including `.../docs/documentation-estate/inventory.json`; it must be updated to expect only the profile probe (disposition: updated, reason: snapshot existence no longer probed).
  - `tests/scripts/claude-hooks/docs-role-contract.Tests.ps1` (relative-path row for `docs-snapshot`) and `tests/scripts/claude-hooks/validate-docs-role-output.Tests.ps1`: unaffected for the relative-path rule.
  - `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` (`lists the seven skills in dispatch order`): searches `[<skill>](../<skill>/SKILL.md)` positions; a non-link root step line does not affect it.
- New regression test: `tests/scripts/claude-hooks/docs-role-contract.Tests.ps1`, a first-run case (profile present, snapshot absent, `docs-result: PASS`) that returns `Ok = $true`; a `validate-docs-role-output.Tests.ps1` case with the same envelope.
- File sizes: `docs-role-contract.ps1` 273 lines; `validate-docs-role-output.ps1` not changed.

### B2. update-ledger batch path and bind page refs

- Locations (current tree):
  - `.claude/lib/docs/DocsLedger.psm1`, `Merge-DocsLedgerEntry`: `Copy-DocsLedgerValue` of the whole ledger, a `Where-Object` scan of all entries, and `Get-DocsLedgerSortedEntry` (which copies every entry again) per call.
  - `.claude/lib/docs/DocsParity.psm1`, `Merge-DocsParityDimension`: `Copy-DocsParityValue`, `Get-DocsSortedParityRow`, two `Where-Object` scans.
  - `.claude/lib/docs/DocsEvidencePins.psm1`, `Merge-DocsEvidencePin`: copy, scan, `Get-DocsSortedPin`.
  - `.claude/lib/docs/DocsLedgerCommands.psm1`, `Invoke-DocsLedgerOperation`: a full `Where-Object` scan of `entries` for `$current`, and for `set-dimension`/`unpin` a full scan of `pins`.
  - `Invoke-DocsUpdateLedgerCommand`: per call, schema composition, profile read, `Read-DocsLedgerCommandDocumentSet` (reads and schema-validates snapshot, ledger, matrix, pins and lists every page), two to three full rule evaluations (`Get-DocsLedgerCommandRuleFinding`) and canonical JSON comparisons. This is the per-call fixed cost the issue measured at about 39 s.
- Root cause: one operation per process, and the merge helpers are copy-scan-sort per operation, so N operations in one process cost O(N x M).
- Design (selected):
  - New module `.claude/lib/docs/DocsLedgerBatch.psm1` exporting `Invoke-DocsLedgerBatch` (pure, over loaded documents) and `ConvertFrom-DocsLedgerOperationText` (parses and validates the operations document).
  - Operations document: `{ "operations": [ { "operation": "...", "element": "...", "limit": "...", "disposition": "...", "pages": [...], "rationale": "...", "owner": "...", "target": "...", "dimension": "...", "state": "...", "claim": "..." } ] }`, field names equal to the MCP field names. Each item is mapped to the existing argument-map names and validated by the unchanged `Test-DocsUpdateLedgerArgument` (with the batch's `ActorKind`, `ActorId` and `Profile`), so the single-operation grammar is the only grammar. `sync-refs` is rejected inside a batch (it rewrites every entry); it remains a separate call.
  - Application: partition operations by target key (element id, or the precision-limit diagnostic id for `-Limit` operations) preserving input order within a partition. For each partition, build reduced documents that contain only that key's ledger entry, matrix rows and pins, run each operation through the unchanged `Invoke-DocsLedgerOperation`, and splice the resulting entries, rows and pins into ordinal dictionaries (ledger keyed by `element_id`, matrix rows by `element_id` + NUL + `page_path`, pins by `pin_id`). Operations on different keys touch disjoint records, so the result equals sequential application; this is the verified workaround of the issue (byte-identical on a 120-element / 560-operation sample, 15,305 operations in about 3 min).
  - After all partitions: sort each collection once with the existing sort helpers, run the unchanged introduced-error comparison once (before = loaded documents, after = batch result), and call `Invoke-DocsArtifactWrite` once. The batch is all-or-nothing: an introduced error or a `DOCS_UPDATE_TARGET_INVALID` on any operation rejects the batch and writes nothing; the finding names the operation index (pointer `/operations/<i>`).
  - CLI: `Invoke-DocsCommand.ps1` `Get-DocsCommandTable` row `update-ledger` gains `Operations = 'value'`. `-Operations` and `-Operation` are mutually exclusive (exit 2). The value is a repository-relative path read through `Context.ReadText`, or `-`, read through a new context member `ReadStdin` added in `New-DocsCommandContext` (`[Console]::In.ReadToEnd()` in production, an in-memory string in tests). `Invoke-DocsUpdateLedgerCommand` dispatches to the batch module when `Operations` is present.
  - Bind page refs: new operation `bind-page-refs` (target `none`, valid alone and as a batch item) in `.claude/lib/docs/DocsLedgerBindRefs.psm1`. It reads every page in the profile's documentation roots (the page-path set is already listed by `Read-DocsLedgerInputSet`), parses front-matter `surface_refs` with the existing front-matter parser (`DocsPageFrontMatter.psm1`), and for each referenced element in the snapshot sets disposition `documented` with page bindings equal to the union of existing bindings and referencing pages. An id absent from the snapshot yields a warning finding; no binding is removed. `sync-refs` stays as it is, and the skill text distinguishes the two.
  - MCP: `update_docs_ledger` gains an `operations` field (array of objects). The TypeScript resolver validates the shape (array, each item an object whose `operation` is one of the ledger operations other than `sync-refs`, no unknown keys, string grammars reused from `matchesDocsGrammar`), makes `operation` and `operations` mutually exclusive, serializes `{ "operations": [...] }` and emits `-Operations -` with that text as stdin. Inline transfer is required because `docs-reconciler` holds no Write tool (`.claude/agents/docs-reconciler.md` frontmatter), so it cannot write an operations file; stdin also avoids the Windows command-line length limit for thousands of operations.
- TypeScript files that change:
  - `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts` (492 lines; at the 500 guidance limit): add the table row and the `operation` requiredness change only; put the batch item validation and serialization in a new sibling `extensions/drm-copilot/src/mcp-tool-inputs-docs-ledger-batch.ts`.
  - `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` (135 lines): `fieldSchema` gains a case for the new spec type (array of objects with an `operation` enum), and a description for `operations`.
  - `extensions/drm-copilot/src/repo-automation-execute-docs.ts` (185 lines): `DocsCommandRequest` gains optional `stdin`; `invokeDocsCommand` passes it to `launcher.launch` instead of `""`.
  - `ResolvedDocsToolInput` (in `mcp-tool-inputs-docs.ts`) gains optional `stdin`; `extensions/drm-copilot/src/mcp-handlers/docs-handlers.ts` (55 lines) passes it through unchanged (`service.runDocsCommand(input)` already forwards the object).
  - Coverage: `extensions/drm-copilot/jest.docs-coverage.json` (spread into `jest.config.cjs` `coverageThreshold`) needs a new entry `"./src/mcp-tool-inputs-docs-ledger-batch.ts": { "lines": 85, "branches": 75 }`.
- TypeScript tests: `extensions/drm-copilot/test/mcp-tool-inputs-docs.test.ts`, `test/mcp-docs-tool-definitions.test.ts`, `test/repo-automation-execute-docs.test.ts`, `test/mcp-handlers/docs-handlers.test.ts`, `test/mcp-server.docs.test.ts`; new `test/mcp-tool-inputs-docs-ledger-batch.test.ts`. Any test asserting that `operation` is required for `update_docs_ledger` or that stdin is `""` must be updated with that reason.
- PowerShell tests asserting current behavior: `tests/scripts/claude-lib/docs/DocsLedgerCommands.UpdateLedger.Tests.ps1` (651 lines) and `DocsLedgerCommands.Tests.ps1` (553 lines) assert `'The -Operation option is required.'` and the per-operation option sets; `tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1` (499 lines) asserts `-Help` usage text; `tests/scripts/claude-runtime/docs-authoring-roles.Skills.Tests.ps1` checks that every `-Command <name> -<Option>` in a skill is a dispatch-table option. New tests: `tests/scripts/claude-lib/docs/DocsLedgerBatch.Tests.ps1` (batch-versus-sequential equivalence over a generated sample, all-or-nothing rejection, `sync-refs` rejection, stdin source), `DocsLedgerBatch.Properties.Tests.ps1` (order-within-partition and partition-permutation invariance), `DocsLedgerBindRefs.Tests.ps1`. Existing test files near 650 lines receive no new cases.
- Performance evidence: the "minutes for about 3,000 elements" acceptance item is an integration scenario; a unit test must not time anything. Record a measured run as evidence under `<FEATURE>/evidence/other/`.
- File sizes: `DocsLedgerCommands.psm1` 707 lines (above the 700 advisory tier): only the dispatch branch and the export list may change there; all batch logic goes in the new modules. `DocsLedger.psm1` 533, `DocsParity.psm1` 545, `DocsEvidencePins.psm1` 285 (not changed). `Invoke-DocsCommand.ps1` 621 lines (above 500): limited to the table row and the `ReadStdin` context member.
- Skills and agents: `docs-reconcile-behavior` (six copies) and `docs-reconciler` (`.claude/agents/docs-reconciler.md`, `.codex/agents/docs-reconciler.toml`, `.github/agents/docs-reconciler.agent.md`, bundle copies) document `operations`, `bind-page-refs`, and the all-or-nothing rule.
- Pack manifest: new `.claude/lib/docs/*.psm1` files must be listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (where `DocsLedgerCommands.psm1` is listed) and bundled byte-identically; `test_push_down_pack_manifest_dependency_closure.py` checks `$PSScriptRoot` dependencies.
- Installed-extension caveat: the TypeScript wrapper is the installed extension, so the MCP `operations` field is usable only after a release that carries it; the CLI path works from the branch immediately.

### B3. Pin before `accurate = pass`

- Location: `Invoke-DocsLedgerOperation`, `set-dimension` branch: it collects only existing pins for the element and page (`$pinIds`) and passes them to `Merge-DocsParityDimension`; the matrix rule then reports `DOCS_MATRIX_ACCURACY_UNPINNED` as an introduced error. `.claude/skills/docs-reconcile-behavior/SKILL.md` step 2 lists `pin` and `set-dimension` without an ordering rule.
- Change: state in `docs-reconcile-behavior` (six copies) and `docs-reconciler` (agent copies) that `pin` for the same element and page must precede `set-dimension` with `dimension: accurate` and `state: pass`. In the batch path only, accept `claim` on a `set-dimension accurate pass` item: the batch applies a `pin` with that claim first, then the dimension. The single-operation CLI grammar is unchanged.
- Test: in `DocsLedgerBatch.Tests.ps1`, an `accurate pass` item with `claim` produces a pin and no introduced error; without `claim` and without a prior pin, the batch is rejected with `DOCS_MATRIX_ACCURACY_UNPINNED`. A skill-text test in `tests/scripts/claude-runtime/` asserts the ordering sentence in the six copies.

### B4. Template `audience` is a string

- Location: line 4 of every `docs-author-page/templates/*.md` reads `audience: "<audience-id>"`. The checker (`.claude/lib/docs/DocsPageMetadata.psm1`, code `DOCS_PAGE_AUDIENCE_INVALID`, next action "Set audience to a non-empty list of distinct audience identifiers matching ^[a-z0-9][a-z0-9-]*$.") requires a list.
- Change: `audience: ["<audience-id>"]` in all 48 copies (see `## Numeric Derivation Evidence`). The six skill roots: `.claude/skills`, `.agents/skills`, `.github/skills`, and the three bundle roots.
- Tests asserting current behavior: `tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1` parses each value as JSON and checks the five keys; a list value still parses (unaffected). `docs-authoring-roles.Mirrors.Tests.ps1` compares hashes across copies (passes when all copies change together).
- New test: in `docs-authoring-roles.Templates.Tests.ps1`, for each template row, substitute the placeholders (`<owner-id>`, `<yyyy-mm-dd>`, `<audience-id>`, `<element-id>`) with valid values and run the front matter through the page checker's front-matter function (`Test-DocsPageFrontMatter` in `DocsPageFrontMatter.psm1`), expecting no `DOCS_PAGE_AUDIENCE_INVALID`. The test reads the template text in memory; no file is written.

### B5. generate-reference exceeds the 1 MiB page bound

- Location: `.claude/lib/docs/DocsReferencePlan.psm1`, `Get-DocsReferenceFamily` (four fixed pages: `api-reference.md`, `cli-reference.md`, `config-reference.md`, `http-reference.md`) and `Get-DocsReferencePagePlan` (one page per family under `OutputDirectory`). `.claude/lib/docs/DocsPageCheck.psm1` rejects a page above 1,048,576 bytes with `DOCS_PAGE_TOO_LARGE`. `DocsReferenceWriter.psm1`, `Invoke-DocsGenerateReferenceCommand`, rejects a non-relative `-Snapshot` ("is not a repository-relative path").
- Change (selected):
  - Automatic split in a new module `.claude/lib/docs/DocsReferenceSplit.psm1`: after a family page is rendered, when its UTF-8 size exceeds a budget below the check bound (for example 900 KiB), the family is planned as an index page at the family path plus group pages `<OutputDirectory>/<family-stem>/<group>.md`. The group key is the first path segment of the element `path` beneath the longest matching `surface_selection.source_roots` entry; a group still above the budget is split into ordinal parts `<group>-<n>.md`. The order is ordinal and deterministic. `Get-DocsReferenceCandidatePagePath` must also list existing pages under each `<family-stem>/` directory (through `Context.ListFile`) so that existing split pages are updated rather than recreated; a split page whose group no longer exists is reported with a warning finding and is not deleted.
  - Element filter: `generate-reference -PathPrefix <prefix>` (multi) selects elements whose `path` starts with a prefix, so no filtered snapshot copy is needed. `-Snapshot` stays repository-relative (containment is kept). MCP `generate_docs_reference` gains `path_prefixes` (array of relative paths).
- Rejected: a profile `diataxis_policy` grouping key (schema change in three schema copies: `.claude/lib/docs/schemas/v1/docs-profile.schema.json`, its bundle copy, and `schemas/docs/v1/docs-profile.schema.json`); allowing `-Snapshot` outside the repository (breaks the context path rule in `Get-DocsContextFullPath`).
- Tests asserting current behavior: `tests/scripts/claude-lib/docs/DocsReferencePlan.Tests.ps1` (412 lines), `DocsReferencePlan.Properties.Tests.ps1`, `DocsReferenceWriter.Tests.ps1`, `DocsReferenceWriter.Errors.Tests.ps1`, `DocsReferenceWriter.Properties.Tests.ps1` (fixed four-path candidate set). New: `DocsReferenceSplit.Tests.ps1` (below budget gives one page; above budget gives index plus groups; oversize group gives parts; determinism).
- File sizes: `DocsReferencePlan.psm1` 411, `DocsReferenceWriter.psm1` 377, `DocsReferenceRender.psm1` 184; split logic goes in the new module.

### B6. docs-init defaults `source_roots` to `src`

- Location: `.claude/lib/docs/DocsProfile.psm1`, `New-DocsStarterProfile`: `source_roots = @('src')`. `Invoke-DocsInitCommand` (`DocsProfileCommands.psm1`) and `Invoke-DocsValidateProfileCommand` never test a source root. `Test-DocsProfileSemantic` is pure and has no I/O.
- Change:
  - `validate-profile` (and `init` after building the profile) reports an error `DOCS_PROFILE_SOURCE_ROOT_MISSING` at `/surface_selection/source_roots/<i>` when `Context.ListFile` returns no file for the root (the existing `Get-DocsContextFileList` returns an empty array for a missing directory).
  - `init` detection in a new module `DocsProfileSourceRoot.psm1`: `src` when it lists files; otherwise the package directory named by `pyproject.toml` (`[tool.poetry].packages[].include`, else `[project].name` or `[tool.poetry].name` with `-` mapped to `_`) when that directory lists files (TOML keys read with the existing `DocsTomlKeys.psm1`); otherwise `.`. `New-DocsStarterProfile` gains `-SourceRoot` with default `@('src')`, so every existing caller and test is unchanged.
- Tests: `tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1` (`New-DocsStarterProfile` cases, unaffected by the default), `DocsProfileCommands.Tests.ps1` (294 lines); new `DocsProfileSourceRoot.Tests.ps1`.

### B7. `check` crashes on a link target containing `|`

- Root cause: `.claude/lib/docs/DocsPageLinks.psm1`, `Get-DocsPageExternalTarget`, returns every resolved path that is not a page, including paths that fail `Test-DocsRelativePath` (for example a target containing `|`). `DocsPageCheck.psm1`, `Invoke-DocsCheckCommand`, calls `Context.TestFile` on each; `Get-DocsContextFullPath` in `Invoke-DocsCommand.ps1` throws `DOCS_CONTEXT_PATH_INVALID`, and the entry boundary reports exit 3.
- Change (part 1): in `Get-DocsPageExternalTarget`, skip a resolved path that fails `Test-DocsRelativePath`. `Get-DocsPageLinkFinding` then reports `DOCS_PAGE_LINK_BROKEN` for it (the path is neither a page nor in `ExistingPath`), and the existing `DocsPageUnrelatablePathPattern` already drops it from `related_paths`. One pure change; no I/O module changes.
- Change (part 2, selected option): the starter profile documentation root becomes `docs/guide` (id `guide`) instead of `docs`. This is a pure change in `New-DocsStarterProfile` (a `-DocumentationRoot` parameter with the new default). The A1/A3 legs of Part A take roots from the profile and are unaffected. Rejected: a root-level exclusion list (schema change in three schema copies).
- Tests asserting current behavior: tests that build profiles with `path = 'docs'` construct their own profile values (for example `DocsPageCheck.Tests.ps1`, `DocsLedger.TestSupport.psm1`, which overrides `documentation_roots` after `New-DocsStarterProfile`) and are unaffected. Tests that call `New-DocsStarterProfile` and rely on its root must be searched by the planner (`DocsInventorySnapshot.Tests.ps1`, `DocsInventoryProperties.Tests.ps1`, `DocsInventory.Tests.ps1`, `DocsInventory.PythonNative.Tests.ps1` call it; they override `source_roots`, and their reliance on `documentation_roots` was not verified). New tests: `DocsPageLinks.Tests.ps1` (314 lines) gains a malformed-target case; `DocsPageCheck.Tests.ps1` is 696 lines, so the command-level case (exit 1 with a finding, not exit 3) goes in a new `DocsPageCheck.MalformedLink.Tests.ps1`.

### B8. Inventory reads `__pycache__`

- Location: `Invoke-DocsInventoryCommand` lists files with `Context.ListFile` (`Get-DocsContextFileList`: `Directory.EnumerateFiles` with `AllDirectories`, no ignore rules) and selects with `Get-DocsInventorySelection` (`DocsInventorySnapshot.psm1`), which applies only the profile `exclusions`. `New-DocsCapturedInput` (`DocsAnalyzerRegistry.psm1`) emits `DOCS_INPUT_NOT_UTF8` per undecodable file.
- Change (selected): a built-in default exclusion applied in `Get-DocsInventorySelection` before the profile exclusions: any path segment equal to `__pycache__`, `.git`, `node_modules`, `.venv`, `venv`, `.mypy_cache`, `.pytest_cache`, `.ruff_cache`, `.tox`, `dist`, `build`, and files ending in `.pyc` or `.pyo`. A default-excluded path is not read and yields no diagnostic. Rejected: honoring `.gitignore` (needs a git process in the selection path, which is pure today, and a new context member).
- Tests: `tests/scripts/claude-lib/docs/DocsInventorySnapshot.Tests.ps1` (312 lines) gains the default-exclusion cases; `DocsInventory.Tests.ps1` asserts exact input lists (`src/app.py`, `config/...`), which contain no excluded segment (unaffected).

### B9. Cross-module argparse registration

- Locations: scanner `.claude/lib/docs/DocsPythonCliArgparse.psm1` (243 lines); native `.claude/lib/docs/python/docs_python_native/cli_argparse.py` (354 lines; its docstring says it reproduces the scanner), `call_sites.py` (`UNBOUND = "CLI_UNBOUND_REGISTRATION"`). The registry selects the native row under `-AnalysisMethod auto` when the helper is available (`DocsAnalyzerPythonNative.psm1`, `Invoke-DocsPythonNativeInventory`), otherwise the scanner row.
- Root cause (native, verified in `recognize_argparse` and `_resolve`): a call `subparsers.add_parser(...)` inside `def register(subparsers): ...` has a receiver that is a function parameter, not an entry of `tables.receivers`; `_resolve` returns `None`, `_tracked_other` returns `False`, and the call is recorded as `CLI_UNBOUND_REGISTRATION`. The scanner follows the same receiver-table rule (not traced line by line; marked for the planner to confirm).
- Change: within a module, seed a parameter that is the receiver of `add_parser` as a provisional `subparsers` role whose parent is unresolved; across modules, bind it when a resolved `subparsers` receiver is passed as an argument to that function at a call site in another module (resolved through the existing import tables in `imports.py` and the scanner's binding tables). Commands registered through an unbound parameter with no resolvable caller keep the diagnostic. Both implementations change together, with one shared fixture layout (`cli.py` creating `add_subparsers` and calling `cli_daily.register(subparsers)`) added to `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` and `python-native-corpus.json`.
- Python constraint: this edits existing Python under `.claude/lib/docs/python/`; no new Python file is proposed. The native recognizer is per file, so the cross-module link belongs in the native collector that already sees all modules (the planner must locate it; `cli.py` in `docs_python_native` is the likely site, 271 lines, not traced).
- Tests: `tests/scripts/claude-lib/docs/DocsPythonCliArgparse.Tests.ps1` (193 lines), `tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_argparse.py`, `test_docs_python_native_cli.py`, corpus-driven tests.

### B10. MCP versus CLI diagnostic counts

- Trace:
  1. `extensions/drm-copilot/src/mcp-tool-inputs-docs.ts`, table `run_docs_inventory`: options `Profile`, `Analyzer`, `Revision` only (no `Write`, no `AnalysisMethod`; the CLI default for `AnalysisMethod` is `auto`, the same as an omitted MCP option).
  2. `repo-automation-execute-docs.ts`, `invokeDocsCommand`: runs the workspace `.claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Json` with the workspace root as working directory and returns `parseDocsEnvelope(stdout)`.
  3. `docs-command-envelope.ts`, `toEnvelope`: validates the five keys and returns `result: document["result"]` unchanged; no field of `result` is read or filtered.
  4. `mcp-handlers/docs-handlers.ts`, `handleDocsTool`: returns `docs: envelope` unchanged. `extensions/drm-copilot/test/mcp-handlers/docs-handlers.test.ts` already asserts `docs: outcome` equality.
  5. PowerShell: the CLI text report and the `-Json` envelope are built from the same `New-DocsCommandResult` (`ConvertTo-DocsReportText` / `ConvertTo-DocsEnvelopeText` in `DocsFinding.psm1`). `DOCS_INPUT_NOT_UTF8` is attached at capture (`New-DocsCapturedInput`) and every capture diagnostic is kept by `New-DocsInventorySnapshot` before analyzer selection, so the native/scanner choice does not affect it.
  6. `discovery-runtime.ts` collects stdout chunks without truncation (no size limit found).
  7. `packages/mcp-server` is not present in this tree (Glob `packages/*/*` returned nothing).
- Conclusion: refuted at code level. The MCP result cannot omit `DOCS_INPUT_NOT_UTF8` diagnostics. The likely causes are the role's summary (the MCP `summary` line counts findings, not snapshot diagnostics) or a working-tree difference between the two runs (for example `__pycache__` files created between them). The empirical cause was not reproduced.
- Test: a Pester parity test in a new `tests/scripts/claude-lib/docs/Invoke-DocsCommand.InventoryParity.Tests.ps1`: one in-memory context with a non-UTF-8 input, run `Invoke-DocsCommandCli -Command inventory` with and without `-Json`, and assert that `diagnostics=<n>` in the text line equals the diagnostic count in `result.snapshot.diagnostics` and includes the `DOCS_INPUT_NOT_UTF8` entry. A Jest case in `docs-handlers.test.ts` asserts that an envelope whose `result.snapshot.diagnostics` holds a `DOCS_INPUT_NOT_UTF8` entry is returned with that entry.

### B11. Line endings and estate hashes

- Evidence:
  - Writers normalize to LF: `ConvertTo-DocsJsonText` (`DocsJson.psm1`) replaces CRLF with LF.
  - Artifact reference hashes are raw-byte: `Get-DocsBytesSha256Hex` (delegates to `Get-DiscoveryBytesSha256Hex`) is used in `DocsLedgerCommands.psm1` (`ConvertFrom-DocsLedgerCommandArtifact`), `DocsValidation.psm1`, `DocsReceipt.psm1` (artifact pin in the receipt), `DocsLedgerMutation.psm1` (write conflict check), `DocsValidateCommands.psm1`, `DocsReferenceWriter.psm1` (page hashes) and `DocsSurfaceDeltaCommands.psm1` (input staleness against snapshot `inputs[].sha256`), and capture hashes in `DocsAnalyzerRegistry.psm1` `New-DocsCapturedInput`.
  - Element digests are normalized: `DocsSurface.psm1` replaces CRLF and CR with LF before computing the declaration digest, so `source_sha256` (used by `DocsStaleness.psm1` and pins) is line-ending stable.
- Conclusion: confirmed for artifact references (ledger `snapshot_ref`, matrix ledger and snapshot refs, receipt artifact hashes) and for snapshot input hashes; refuted for element `source_sha256`. A CRLF checkout of LF-written JSON changes the raw bytes, so a recomputed raw hash no longer matches the stored one.
- Change (selected): add `Get-DocsTextSha256Hex -Bytes` to `DocsJson.psm1` (323 lines) that maps CRLF and lone CR to LF at byte level and hashes the result; use it at every site listed above, including capture input hashes and `DocsSurfaceDeltaCommands.psm1`. For LF content the value equals the raw hash, so committed LF estates keep their hashes. `Get-DiscoveryBytesSha256Hex` (shared with the discovery library) is not changed.
- Rejected: docs-init writing `.gitattributes` (a non-`docs/` path that the Part A docs-only allowlists do not admit; a repository may already own that file).
- Test: `tests/scripts/claude-lib/docs/DocsJson.Tests.ps1` (293 lines): LF and CRLF byte forms of one JSON text give equal hashes, and LF content gives the raw-byte hash. A command-level test: `update-ledger` over a CRLF-encoded ledger in the in-memory context reports no snapshot or ledger reference drift.

### B12. "Subagents should return findings as text, not write report files"

- Search: SearchScope = the worktree (all files); SearchPatterns = `return findings as text`, `not write report files`, `report files` (case-insensitive), and `(?i)report.*\.md|summary.*\.md|findings.*\.md` in `.claude/hooks`; `report|subagent` in `.claude/settings.json`. SearchResult: no hook, settings entry, or agent frontmatter produces this text. Matches were in unrelated files (`PoshQC.Parallel.psm1`, `codex_native_converter/reporting.py`, feature documents). `.claude/hooks/enforce-docs-role-write-scope.ps1` denies only with `DOCS_ROLE_WRITE_SCOPE_BLOCKED:` reasons.
- Conclusion: the guard is Claude Code runtime behavior for subagents, outside the repository (the agent runtime instructs subagents not to write report, summary, findings or analysis `.md` files). It cannot be exempted from the repository.
- Change: document the restriction. In `docs-plan-ia` (plan page file names without the words `report`, `summary`, `findings` or `analysis`, or assign such pages to a root step) and `docs-author-page` (state that such a write may be refused by the runtime and must then be written by the root), in all six copies of each skill, and in the docs-author agent copies. A skill-text test asserts the sentence in each copy.

### B13. docs-init adds a CI workflow

- Current state: Part A added a `## Linter Configuration` paragraph that names `.github/workflows/_docs-quality.yml`, but `## Steps` and `## Result` of `.claude/skills/docs-init/SKILL.md` do not state that init adds a CI workflow. `Invoke-DocsInitCommand` emits one `<action> <path>` line per target, so the workflow appears as an ordinary `create .github/workflows/_docs-quality.yml` line.
- Change: Steps and Result sentences in all six `docs-init` copies; `Invoke-DocsInitCommand` adds a line `ci-workflow <path>` for the template row whose destination starts with `.github/workflows/`, and a result field `ci_workflow` (path or `null`).
- Tests asserting current behavior: `tests/scripts/claude-lib/docs/DocsInitTemplate.DocsWorkflow.Tests.ps1` and `DocsPageTemplates.Tests.ps1` assert `planned_writes` only (no line assertions found); `docs-authoring-roles.Skills.Tests.ps1` asserts Part A's docs-init tokens (unaffected by added sentences). New cases go in `DocsInitTemplate.DocsWorkflow.Tests.ps1` and a skill-text test.

## Rejected Alternatives (brief)

- B2 dictionary re-implementation of all operation semantics: rejected in favor of per-partition reuse of `Invoke-DocsLedgerOperation`, which keeps one implementation of each operation.
- B2 MCP operations as a file path only: rejected; `docs-reconciler` cannot write files.
- B5 profile grouping key and out-of-repository snapshots: see B5.
- B7 root exclusion schema field: see B7.
- B11 `.gitattributes` from init: see B11.

## Requirements Mapping and Delivery Shape

### Production files per language (estimate)

- PowerShell (each also has a byte-identical bundle copy that counts against the batch budget): new `DocsLedgerBatch.psm1`, `DocsLedgerBindRefs.psm1`, `DocsReferenceSplit.psm1`, `DocsProfileSourceRoot.psm1`; changed `DocsLedgerCommands.psm1`, `Invoke-DocsCommand.ps1`, `DocsReferencePlan.psm1`, `DocsReferenceWriter.psm1`, `DocsProfile.psm1`, `DocsProfileCommands.psm1`, `DocsPageLinks.psm1`, `DocsInventorySnapshot.psm1`, `DocsPythonCliArgparse.psm1`, `DocsJson.psm1` plus the hash call sites (`DocsValidation.psm1`, `DocsReceipt.psm1`, `DocsLedgerMutation.psm1`, `DocsValidateCommands.psm1`, `DocsSurfaceDeltaCommands.psm1`, `DocsAnalyzerRegistry.psm1`), and `.claude/hooks/docs-role-contract.ps1`. About 22 source files, 44 with bundles.
- Python (existing files only): `cli_argparse.py` and the native collector, with bundle copies.
- TypeScript: `mcp-tool-inputs-docs.ts`, new `mcp-tool-inputs-docs-ledger-batch.ts`, `mcp-docs-tool-definitions.ts`, `repo-automation-execute-docs.ts`, `jest.docs-coverage.json`.
- Markdown: skills `documentation-workflow`, `docs-inventory-surface`, `docs-reconcile-behavior`, `docs-plan-ia`, `docs-author-page` (and 48 templates), `docs-init` (six copies each); agents `docs-reconciler`, `docs-author` (and optionally `docs-architect`) in their Claude, Codex, Copilot and bundle copies; the execution-environment brief (six copies).
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (four new modules).

### Delivery Shape

Recommendation: an epic with four children, planned through `epic-plan`. One feature would exceed the 20-task and 250-line plan guideline several times over, and the items share few files.

| Child | Items | Main surfaces |
|---|---|---|
| 1. Ledger batch | B2, B3 | `DocsLedgerBatch.psm1`, `DocsLedgerBindRefs.psm1`, `DocsLedgerCommands.psm1`, `Invoke-DocsCommand.ps1`, TypeScript MCP files, reconcile skill and agent |
| 2. Reference split | B5 | `DocsReferenceSplit.psm1`, `DocsReferencePlan.psm1`, `DocsReferenceWriter.psm1`, `Invoke-DocsCommand.ps1` table row, `generate_docs_reference` input table |
| 3. Estate defaults, integrity and role contract | B1, B4, B6, B7, B8, B10, B11, B12, B13 | `docs-role-contract.ps1`, profile and init modules, `DocsPageLinks.psm1`, `DocsInventorySnapshot.psm1`, `DocsJson.psm1` and hash sites, templates, skills, brief |
| 4. Python CLI analyzer | B9 | `DocsPythonCliArgparse.psm1`, `cli_argparse.py`, native collector, corpora |

Overlaps: children 1 and 2 both edit `Invoke-DocsCommand.ps1` (different table rows) and both edit `mcp-tool-inputs-docs.ts` (different tables); child 1 owns `ReadStdin`. Under the cost-benefit rule for parallel conflicts, these are tolerable non-logic overlaps; serialize children 1 and 2 only if the planner finds a same-logic edit. Child 3 owns the brief update. Every child runs on the orchestrated large path, because each touches more than three production PowerShell files once bundle copies are counted.

## Testing Implications

- Pester is the test framework for the library and hook; Jest for the TypeScript wrapper; pytest for the native recognizer. All tests use in-memory contexts (`New-DocsTestContext` style seams already used by `DocsInventory.Tests.ps1`); no temporary files.
- Gates run in parallel only: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run, Jest through its normal workers. No serial, single-process, shuffled or reversed runs. Integration and golden suites run in CI, not locally. A focused run of one file is debugging only.
- Test-order dependence is a violation: a leak is fixed in both the leaking and the affected suite.
- Evidence is append-only, stamped with clock-read UTC times, and records no absolute path.
- New TypeScript file needs its own `coverageThreshold` entry (in `jest.docs-coverage.json`).
- Coverage: 85% line per changed PowerShell file; 85% line and 75% branch per changed TypeScript and Python file.

## Numeric Derivation Evidence

### Claim N1: 48 template files carry `audience: "<audience-id>"` and must change (B4)

- Complete Family: every `docs-author-page` page template in every skill root that ships the skill (Claude, Codex/agents, Copilot, and their three bundle roots).
- Exhaustive Search Scope: the whole worktree, glob `**/docs-author-page/templates/*.md`.
- Inclusion Rules: a Markdown file directly under a `docs-author-page/templates/` directory.
- Exclusion Rules: feature documents under `docs/features/` that quote the template line (not templates).
- Primary Search Strategy or Query Expression: Glob `**/docs-author-page/templates/*.md`.
- Primary Member Set: the eight names `api-reference`, `architecture-overview`, `cli-reference`, `config-reference`, `explanation`, `how-to`, `http-reference`, `tutorial` under each of `.claude/skills`, `.agents/skills`, `.github/skills`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills`, `extensions/drm-copilot/resources/customizations/.github/skills`.
- Primary Count: 48.
- Cross-check Search Strategy or Query Expression: Grep count mode, pattern `^audience: "<audience-id>"$`, glob `**/docs-author-page/templates/*.md`.
- Cross-check Member Set: one match in each of the same 48 paths (the eight names under the same six roots).
- Cross-check Count: 48 (48 files, one occurrence each).
- Member-set Comparison: the normalized path sets are identical (six roots by eight names in both); no file appears in one set only, and no file has more than one match. The existing assertion `covers 48 template files` in `tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1` agrees.

No other numeric acceptance criterion is proposed. The file counts in `## Requirements Mapping and Delivery Shape` are planning estimates, not acceptance criteria.

## Pre-Mortem

- Review checklists: a reviewer could find the batch path re-implementing operation semantics, or the hook change leaving the brief stale. Mitigation: the plan reuses `Invoke-DocsLedgerOperation` per partition, and child 3 carries an explicit brief-update task naming all six copies.
- Coverage: new modules (`DocsLedgerBatch.psm1`, `DocsLedgerBindRefs.psm1`, `DocsReferenceSplit.psm1`, `DocsProfileSourceRoot.psm1`) and the new TypeScript sibling could fall below 85% line (TypeScript also 75% branch), or the TypeScript file could be measured with no threshold. Mitigation: each new module gets its own test file; `jest.docs-coverage.json` gains the new entry in the same task that creates the file; per-file figures are read from the single gate run and compared with the Phase 0 baseline.
- Mirror parity: every `.claude/lib/docs` and `.claude/hooks` edit has a byte-identical bundle copy; skills have six copies (the host copies differ from the `.claude` copy because they omit `.claude/` text, per `docs-authoring-roles.Skills.Tests.ps1`); agents have Claude, Codex, Copilot and bundle copies; new modules must enter `claude-customizations/pack-manifests/core.json`; the brief has six byte-identical copies. Mitigation: each task lists its mirror set, and the plan runs `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, the pack-manifest completeness and dependency-closure tests, the Codex generator `--check`, and `docs-authoring-roles.Mirrors.Tests.ps1`.
- File size: `DocsLedgerCommands.psm1` is 707 lines (above the 700 advisory tier), `Invoke-DocsCommand.ps1` 621, `mcp-tool-inputs-docs.ts` 492, `DocsPageCheck.Tests.ps1` 696, `DocsLedgerCommands.UpdateLedger.Tests.ps1` 651. Mitigation: new logic goes into new modules and new test files; these files receive only dispatch rows, export entries, or no change.
- Test isolation: the batch and stdin seams could tempt tests to read real stdin or write operations files. Mitigation: `ReadStdin` is a context member supplied in memory; operations documents are strings; no temporary files; any module-scope state in the new modules is avoided, and the leak scan covers new helpers.
- CI-only behavior: CRLF fixtures committed as text become LF under `* text=auto eol=lf`, so the B11 test must build CRLF bytes in memory; the B9 Python tests run on Python 3.11 to 3.13 in CI; Linux hook suites run `tests/scripts/claude-hooks` case-sensitively (B1 test paths use forward slashes and exact case). Mitigation: in-memory byte construction, no drive-letter paths, version-neutral Python.
- Evidence: the "minutes for about 3,000 elements" item needs a measured run, which must not be a unit test. Mitigation: record one measured CLI batch run under `<FEATURE>/evidence/other/` with `Timestamp`, `Command`, `EXIT_CODE` and `Output Summary`, append-only and stamped from the clock; B10 records the code-trace conclusion and the parity tests, not an unreproduced field observation.

## Facts Not Verified (need git, gh, or a runtime)

- The exact content and merge commit of PR #1175 (Part A) and whether `origin/main` has moved since this worktree was created.
- Whether the consumer run used the native or the scanner Python CLI analyzer (depends on Python availability there).
- The empirical cause of the 509 versus 819 diagnostic counts (B10); only the code path was traced.
- The Claude Code runtime version and the exact rule behind the B12 refusal (outside the repository).
- Whether `DocsPythonCliArgparse.psm1` follows the same receiver rule as `cli_argparse.py` line by line, and which native module links modules (B9).
- Whether tests calling `New-DocsStarterProfile` depend on its `documentation_roots` value (B7 part 2).
- Measured runtime of the proposed batch path on a 3,000-element estate.
