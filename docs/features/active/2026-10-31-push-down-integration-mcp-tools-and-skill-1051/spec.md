# 2026-10-31-push-down-integration-mcp-tools-and-skill — Spec

- **Issue:** #1051
- **Parent (optional):** epic #1018 (`shared-agent-harness-layer`), child 10
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature (AC sources: this file and `user-story.md`)
- **Design basis:** `research/research.2026-11-14T15-55.md`, sections 4 to 14

## Overview

A push-down into a destination that already has workflows, a different version matrix, existing hooks or a different layout requires integration decisions. The push-down is a deterministic TypeScript extension command; it should not make those decisions, and it should not call a language model itself. A model call inside the extension bypasses the repository's hooks, the model-routing and preimplementation gates and the review step; it needs credentials and quota that the coordinator cannot see; it fails wherever no model is signed in; and it leaves no transcript or receipt.

The integration judgment belongs in an agent session, where the model is already governed and visible. The session needs structured facts to work from and a deterministic check that the result is correct.

This feature delivers:

1. A push-down writer that records each decision the push-down cannot make mechanically in `.push-down-integration-needed.json` at the destination root.
2. A read-only MCP tool `detect_push_down_integration` that reports ecosystems, workflows and structured conflicts.
3. A read-only MCP tool `validate_push_down_integration` that returns a deterministic verdict over rules V1 to V5 and a fixed `not_checked` list.
4. A shared skill `push-down-integration` that tells an agent session how to read, resolve and validate, and when to stop.

No component calls a language model or uses MCP sampling.

## Behavior (owner text)

1. **The push-down stays mechanical.** It copies files, writes the content-hash manifest (issue #1049) and writes new workflows beside existing ones. When it meets a decision it cannot make mechanically (an existing `ci.yml`, a different version matrix, a missing required check, a destination-edited hook), it records the item in an `integration-needed` file in the destination and does not guess.
2. **MCP tool: detect.** Reports the ecosystems present in the destination, the existing workflows and their job names, and a structured list of conflicts with the pushed content (for example, an existing job whose name overlaps a pushed job). Deterministic and read-only.
3. **MCP tool: validate.** Checks the integrated result: workflow YAML parses, the required check names exist, the coverage artifact paths match the toolchain rules, and manifest hashes are consistent. Returns a pass or a list of failures. Deterministic.
4. **Skill.** Tells an agent session how to integrate: read the `integration-needed` file, resolve each conflict, run the validate tool, and stop only when it passes. Resolution happens through ordinary edits under the destination's hooks and review.
5. **No model call in MCP tools.** MCP sampling is not used: client support is uneven, and it would reintroduce a hidden model inside a tool.

## Upstream Contracts and Execution Preconditions

This spec is written against the upstream specs, not against merged code. Execution runs after #1029, #1049 and #1050 merge into the epic integration branch. Plan Phase 0 confirms every upstream symbol below by name and shape; a mismatch stops the plan.

| Upstream | Contract used | Not depended on |
|---|---|---|
| #1029 `spec.md` (`### Destination Manifest`, `### Decision Table`, `### Dry-Run and Apply Report`, `### MCP Result Compatibility`) and its plan (module names) | `pushDownHarness`, `PushDownReport` (`files[].action` values `conflict`, `unmanaged-conflict`, `deleted-locally`), the planned write set, `payload_version` (D6), `WriteIfChangedFileSystem`, the root-level assertion in `push-down-ecosystem-registry.ts` | The internal layout of `push-down-apply.ts` (not edited) |
| #1049 `spec.md` (`## Destination Manifest Schema`, `### Canonical Hash Rule`, `### Path Rules`, `### Status Vocabulary`) | `DESTINATION_MANIFEST_RELATIVE_PATH`, `parseDestinationManifest` (unknown major rejected; absolute, drive-letter, UNC and `..` keys rejected), `hashPayloadText`, status vocabulary `exempt`, `modified`, `missing` | #1049's schema minor-version handling; no rule here asserts minor-version behavior |
| #1050 `spec.md` (`## Data File Schema`, `## Template Contract`, `### Conflicts`, `## Non-Goals`) | Data file `.github/drm-copilot/ci-required-checks.json` fields `schema_version`, `workflow`, `workflow_file`, `required_contexts`; caller name `CI`, gate job id `ci-required-gate`, name `CI Required Gate`, `needs`, `if: always()`; `findCiWorkflowNameCollisions`; the caller renderer; bundled `harness-<stem>.yml` workflows and the pack-to-stem mapping (D4); per-pack artifact paths | The rendered caller's `job.workflow_*` expression contexts, which #1050 will change |

Existing code on this branch reused as is: `workspaceRootProperty` (`mcp-push-down-schema-properties.ts`), `asToolArgumentObject` (`mcp-tool-inputs.ts`), `normalizeWorkspaceRoot` (`workflow-command-arguments.ts`), `toFailureToolResult` (`mcp-tools.ts`), `compareCodePoint` (`lib/string-ordering.ts`), `stringifySorted` (`lib/push-down/copilot-customizations-engine.ts`), `PushDownFileSystem` (`lib/push-down/filesystem-adapter.ts`), `parseExclusionManifest`, `matchesExclusionEntry` and `assertManifestPathIsRootLevel` (`lib/push-down/claude-exclusion-manifest.ts`), and `MANIFEST_FILENAMES` and `isExcludedDirectoryName` (`lib/push-down/claude-blast-radius-derive-manifests.ts`).

## Rules

Every rule below is observable through a Jest unit or contract test in `extensions/drm-copilot/test/` (or, where stated, an existing contract test edited in place). For each rule the plan must name one implementing task and at least one test with a passing fixture and a failing fixture (a fixture that would make the test fail if the rule were broken). Fixtures use in-memory file systems with POSIX roots (for example `/dest`), CR LF built in code, and no temporary files.

### A. Integration-Needed File and Push-Down Writer

- **S1 Path and root-level guard.** The file path is the constant `INTEGRATION_NEEDED_RELATIVE_PATH` = `.push-down-integration-needed.json`, relative to the destination root. The path is added to the root-level assertion in `push-down-ecosystem-registry.ts`, so a pipeline run against a destination that already contains the file plans no action for that path (it is never enumerated as payload and never classified `unmanaged-conflict`). Fail fixture: a pipeline fake whose destination holds the file and whose report lists the path.
- **S2 Top-level fields.** The rendered object has exactly the keys `items`, `payload_version` and `schema_version`. `schema_version` is `1.0.0`. `payload_version` equals the run's `payload_version` (#1029 D6).
- **S3 Item fields.** Each item has exactly the keys `detail` (object, possibly empty, with the per-kind keys of S4), `id`, `kind`, `path`, `resolution_options` and `source`. `source` is `push-down` in the file and `detect` in detect results. `path` is a POSIX path relative to the destination root.
- **S4 Kind vocabulary.** `kind` is one of the values in the table below; `resolution_options` for an item equals the table's list for its kind, in the listed order; `detail` carries exactly the listed keys. The vocabulary and option lists are exported constants shared by the writer, detect and the skill test (S53).

| Kind | Raised by | `detail` keys | `resolution_options` |
|---|---|---|---|
| `workflow-name-collision` | push-down, detect | `existing_name` | `rename-existing-workflow`, `retire-existing-workflow` |
| `existing-ci-workflow` | push-down, detect | none | `keep-both-workflows`, `retire-existing-workflow` |
| `job-name-overlap` | detect | `job_id`, `matched` | `rename-existing-job`, `keep-overlapping-job` |
| `missing-required-check` | push-down, detect | `context`, `workflow_file` | `add-producing-job`, `restore-pushed-caller` |
| `version-matrix-difference` | push-down, detect | `job_id`, `key`, `found`, `expected` | `align-to-harness-version`, `keep-destination-version` |
| `destination-edited-file` | push-down | `is_hook` | `revert-to-payload`, `declare-destination-owned` |
| `unmanaged-conflict` | push-down | none | `adopt-payload`, `declare-destination-owned` |
| `deleted-locally` | push-down | none | `restore-from-payload`, `declare-destination-owned` |
| `yaml-unsupported` | detect | `line`, `construct` | `rewrite-in-supported-subset` |

- **S5 Id format.** `id` is `<kind>:<path>`, followed by `#<discriminator>` for kinds that can yield more than one item per path: `job-name-overlap` uses the job id; `missing-required-check` uses the context; `version-matrix-difference` uses `<job id>.<key>`; `yaml-unsupported` uses `L<line>`. Other kinds have no discriminator.
- **S6 Ordering and uniqueness.** `items` is sorted by `id` in code-point order (`compareCodePoint`). Ids are unique: when two sources in one run produce the same id (for example #1050's collision result and the shared conflict core), one item is kept.
- **S7 Id stability and persistence.** For the same destination content and payload, the rendered file is byte-identical across runs and independent of the order in which the file system lists entries (fail fixture: a fake that returns `listFiles` in reverse order). An item is raised on every run while its condition holds and is absent from the next run once the condition no longer holds. A decision that keeps a condition in place (for example `keep-both-workflows`) leaves the item in the file; the stop condition of the integration loop is the validate verdict (S52), not an empty file.
- **S8 Rendering.** The file is rendered with `stringifySorted` (sorted keys), two-space indentation, LF line endings and one trailing LF.
- **S9 Forbidden content.** The file contains no timestamp field and no ISO 8601 date-time value, no absolute path (no leading `/`, no drive letter, no UNC prefix, no `..` segment in any `path` or `detail` string), and no part of the destination root path. Fail fixture: a fixture root `/dest/user-x` whose rendered text is searched for `/dest` and `user-x`.
- **S10 Push-down item sources.** The push-down raises items as follows; each row needs a raising and a non-raising fixture.

| Kind | Source in the push-down run |
|---|---|
| `destination-edited-file` | a #1029 report entry with action `conflict`; `detail.is_hook` is `true` exactly when the path starts with `.claude/hooks/`, `.codex/hooks/` or `.github/hooks/` |
| `unmanaged-conflict` | a #1029 report entry with action `unmanaged-conflict` |
| `deleted-locally` | a #1029 report entry with action `deleted-locally` |
| `workflow-name-collision` | each path returned by #1050's `findCiWorkflowNameCollisions`; `detail.existing_name` is the declared name |
| `existing-ci-workflow`, `missing-required-check`, `version-matrix-difference` | the shared conflict core (S26, S28, S29) evaluated over the post-run view (S11) |

- **S11 Post-run view and mode equality.** The shared conflict core evaluates the destination as it is after the run's writes: in apply mode, the destination after writing; in dry-run mode, a read-only overlay of the planned write set over the destination, with no write. For identical inputs the `items` of a dry run equal the `items` of the following apply run.
- **S12 Write rule.** In apply mode the file is written through `WriteIfChangedFileSystem` when `items` is non-empty, or when `items` is empty and the file already exists (it is rewritten with `items: []`; the seam has no delete operation). In apply mode with no items and no existing file, nothing is written. In dry-run mode the file is never written. A second identical apply run performs no write to the file. The writer is one call site in `pushDownHarness`; `push-down-apply.ts` is not edited.
- **S13 Not a manifest entry.** The file is never recorded in `.push-down-manifest.json` `files`.
- **S14 Push-down result.** The items are returned in `push_down_report.integration_needed` as `{ path, items, written }` in both modes, present only when `items` is non-empty or the file was written; `written` is `true` only when the run wrote the file. The presence of items does not change the push-down result's `ok`. A call on a destination that yields no item and has no file returns a `push_down_report` without the key, so #1029's `### MCP Result Compatibility` holds for such calls.

### B. Workflow Subset Reader

- **S15 Supported subset.** `workflow-yaml-reader.ts` returns parse status `ok` for text using only: block mappings and block sequences by space indentation; comments (full-line and trailing); plain, single-quoted and double-quoted scalars; block scalars `|` and `>` with chomping indicators `-` and `+`; flow sequences and flow mappings of scalars (for example `branches: [main, "epic/**"]`); one optional leading `---`; and `${{ ... }}` expressions, kept as opaque strings.
- **S16 Unsupported constructs.** Text containing any of tab indentation, an anchor (`&name`), an alias (`*name`), a tag (`!tag`), a second document (a `---` or `...` after content) or a complex key (`? `) returns status `unsupported` with a finding `{ line, construct }`, where `line` is 1-based and `construct` is one of `tab-indentation`, `anchor`, `alias`, `tag`, `multiple-documents`, `complex-key`. The first such construct is reported. It never returns `ok` for these inputs.
- **S17 Malformed input.** Inconsistent indentation, an unterminated quoted scalar, an unterminated flow collection, or a duplicate key in one mapping returns status `error` with a 1-based `line` and a message.
- **S18 Extraction.** For status `ok` the reader returns the top-level `name` (string or `null`); `triggers`, the trigger names of `on` normalized from string, sequence or mapping form and sorted; and `jobs`, a list sorted by job id of `{ id, name, uses, needs, if, matrix, with_versions }`, where `needs` is normalized to a list, `matrix` holds the `strategy.matrix` values, and `with_versions` holds step `with` values for the keys `node-version`, `python-version`, `dotnet-version` and `poetry-version`. Absent values are `null` or empty lists.
- **S19 Purity.** The reader takes text and returns data; it performs no I/O and holds no module-level mutable state. LF and CR LF forms of the same text return equal results.
- **S20 Real-template contract.** The reader returns `ok` for #1050's caller rendered at test time by #1050's renderer in reference mode and copy mode (including quoted `"epic/**"`, `${{ toJSON(needs) }}`, `run: |` blocks and `if: always()`), with `name` `CI` and a job `ci-required-gate` named `CI Required Gate` whose `if` is `always()`. The test asserts no value of any `job.workflow_*` expression. The reader also returns `ok` for each bundled `harness-<stem>.yml`.

### C. Ecosystem Detection

- **S21 Harness ecosystems.** `integration.ecosystems.harness` lists `claude`, `codex`, `copilot`, each as `{ name, selected, present }`. `selected` is `true` when the destination manifest's `selection` has that key. `present` is `true` from root evidence: `claude` when any file exists under `.claude/`; `codex` when any file exists under `.codex/` or `AGENTS.md` exists; `copilot` when `.github/copilot-instructions.md` exists. When the manifest is absent or fails to parse, every `selected` is `false`.
- **S22 Language packs.** `integration.ecosystems.packs` lists `python`, `powershell`, `typescript` and the C# entry as `{ name, selected, present }`, sorted by name. `selected` is membership in the union of `selection.<ecosystem>.packs`. The C# entry is named by the selected variant (`csharp-modern` or `csharp-legacy`), or `csharp` when no variant is selected. `present` uses file evidence outside `.claude/`, `.codex/`, `.agents/` and `.github/`, pruning directories with `isExcludedDirectoryName`: `python` for `pyproject.toml` or `setup.py`; `typescript` for `package.json` together with `tsconfig.json` in the same directory; C# for `.csproj`, `.sln` or `.slnx`; `powershell` for `.ps1`, `.psm1` or `.psd1`.

### D. Detect Tool (`detect_push_down_integration`)

- **S23 Input.** The input schema is `{ workspace_root }` with `workspace_root: workspaceRootProperty`, `required: ["workspace_root"]` and `additionalProperties: false`.
- **S24 Result shape.** A completed run returns `ok: true`, `tool`, `workspace_root`, `summary`, and `integration: { ecosystems, workflows, conflicts, integration_needed }`. `workflows` lists every `.yml` and `.yaml` file directly under `.github/workflows/`, sorted by path, as `{ path, name, triggers, parse, findings, jobs }` with `parse` one of `ok`, `error`, `unsupported` and `jobs` as `{ id, name, uses, needs }`. `conflicts` uses the item model of S3 to S6 with `source: detect`.
- **S25 `workflow-name-collision`.** Raised for each workflow other than the data file's `workflow_file` whose top-level `name` equals the data file's `workflow`. Not raised when the data file is absent or fails V2's checks.
- **S26 `existing-ci-workflow`.** Raised when `.github/workflows/ci.yml` or `.github/workflows/ci.yaml` exists and is not the data file's `workflow_file`. Not raised when the data file is absent.
- **S27 `job-name-overlap`.** With the data file present, the pushed set is the job ids and names of the workflow at `workflow_file`, or, when that file is absent, the `required_contexts` entries. Raised for each job in any other workflow whose id or `name` is in the pushed set; `detail.matched` is the matched value.
- **S28 `missing-required-check`.** With a parsable data file, raised for each `required_contexts` entry that equals no job `name` (or job id, for a job without `name`) in the workflow at `workflow_file`; when that file is absent, raised for every entry.
- **S29 `version-matrix-difference`.** For each workflow other than the caller and `drm-copilot-*.yml` copies, for each job and each key of S18's version keys whose value is a literal (not a `${{ }}` expression): raised when the reference value for that key is not among the literal values. Reference values are read from the bundled `harness-<stem>.yml` workflows of the selected packs in the extension's resources. When no reference value exists for a key, the kind is not raised for that key.
- **S30 `yaml-unsupported`.** Raised for each workflow whose parse status is `unsupported`, with `detail.line` and `detail.construct` from S16.
- **S31 Integration-needed summary.** `integration.integration_needed` is `{ present, item_count, parse }`, where `parse` is `absent`, `ok` or `error`, and `item_count` is the length of `items` when `parse` is `ok` and `null` otherwise. Detect does not interpret item contents.
- **S32 Read-only.** Across every detect fixture, a write-recording file-system fake records no write call. The tool definition carries `annotations: { readOnlyHint: true, openWorldHint: false }`.
- **S33 Determinism.** Two calls on the same fake return deep-equal results; a fake that lists entries in reverse order returns the same result.

### E. Validate Tool (`validate_push_down_integration`)

- **S34 Input.** Same schema as S23.
- **S35 Verdict shape.** A completed run returns `ok: true` and `integration: { verdict, rules, not_checked }`. `rules` holds, in this order, entries with `rule` ids `V1-workflow-read`, `V2-data-file`, `V3-required-check`, `V4-coverage-artifact-path`, `V5-manifest-hash`; each entry is `{ rule, status, failures }` with `status` one of `pass`, `fail`, `not-applicable` and `failures` a list of `{ path, message }` sorted by `path` then `message`. A `fail` entry has at least one failure; a `pass` or `not-applicable` entry has none. `verdict` is `fail` when any entry is `fail`, otherwise `pass`.
- **S36 V1 workflow-read.** `pass` when every `.yml` and `.yaml` file directly under `.github/workflows/` has parse status `ok`; `fail` with one failure per file whose status is `error` or `unsupported`, naming the line. `not-applicable` when the directory holds no such file.
- **S37 V2 data-file.** `not-applicable` when `.github/drm-copilot/ci-required-checks.json` is absent. `fail` when it does not parse as JSON, when `schema_version` major is not `1`, or when `workflow` or `workflow_file` is not a non-empty string or `required_contexts` is not a non-empty list of non-empty strings. Otherwise `pass`.
- **S38 V3 required-check.** `not-applicable` when V2 is not `pass`. Otherwise `pass` only when all of these hold, with one failure per violated condition: exactly one workflow has top-level `name` equal to `workflow`; that workflow's triggers include `pull_request`; each `required_contexts` entry equals some job's `name` (or id, for a job without `name`) in that workflow; and the job producing the first entry has `if` equal to `always()` or `${{ always() }}` (trimmed) and `needs` every other job id of that workflow.
- **S39 V4 coverage-artifact-path.** `not-applicable` when V3 is not `pass` or the manifest selection holds no language pack. Otherwise, for each selected language pack, `pass` for that pack when the workflow found by V3 has a job whose `uses` is `drmoisan/drm-copilot/.github/workflows/harness-<stem>.yml@<ref>` or `./.github/workflows/drm-copilot-<stem>.yml` (stem per #1050 D4), or when the raw text of that workflow, or of a local workflow it reaches through `uses: ./.github/workflows/<file>` (followed transitively, each file once), contains the pack's artifact path literally: TypeScript `coverage/lcov.info`; Python `artifacts/python/lcov.info`; PowerShell `artifacts/pester/powershell-coverage.xml`; `csharp-modern` and `csharp-legacy` `artifacts/csharp/coverage.xml`. One failure per pack that passes neither test. A contract test asserts that each artifact path in this table appears literally in `.claude/hooks/validate-feature-review-coverage-metrics.ps1` or in #1050's bundled harness workflow for that pack.
- **S40 V5 manifest-hash.** `fail` when `.push-down-manifest.json` is absent, or when `parseDestinationManifest` rejects it (the failure carries the parser's message). Otherwise each entry is classified with `hashPayloadText` over the text read: equal hash is `exempt`; a differing hash is `modified`; an absent file is `missing`. A `modified` or `missing` entry is a failure unless `matchesExclusionEntry` matches its path against `.push-down-exclusions` (read with `parseExclusionManifest`); such a path is listed in the rule entry's `destination_owned` (sorted) and is not a failure. `pass` when no failure remains.
- **S41 `not_checked` list.** `not_checked` equals the exported constant `VALIDATE_NOT_CHECKED`, in this order, on every completed run:
  1. `whether CI runs or passes`
  2. `GitHub expression syntax and context names`
  3. `action versions and their availability`
  4. `secrets and permissions`
  5. `runner labels`
  6. `rulesets and branch protection`
  7. `YAML outside the reader subset`
  8. `coverage values and thresholds`
  9. `hook behavior`
  10. `symlinks and reparse points`
  11. `files the manifest does not list`
  12. `integration choices that are correct but unusual`
- **S42 `ok` semantics (both tools).** A run that completes returns `ok: true` and the MCP result has `isError: false`, including a validate run whose `verdict` is `fail`. Input and host errors return `ok: false` through `toFailureToolResult`: a missing, non-string or empty `workspace_root`; an extra input property; a `workspace_root` that is not a directory; and a host service that lacks the tool's optional method (a coded error).
- **S43 Validate read-only and determinism.** Across every validate fixture, a write-recording fake records no write call; two calls on the same fake return deep-equal results. The tool definition carries `annotations: { readOnlyHint: true, openWorldHint: false }`.
- **S44 In-memory end-to-end.** One Jest case runs, over one in-memory destination holding `.github/workflows/ci.yml` with `name: CI`: a CI-enabled push-down apply run (the file lists `workflow-name-collision` and `existing-ci-workflow`); detect (the same ids, `source: detect`); validate (`verdict: fail`, V3 `fail`); a scripted resolution edit that renames the existing workflow (decision `keep-both-workflows`) followed by a second apply run that writes the caller; validate again (`verdict: pass`); and the second run's file no longer lists `workflow-name-collision` or `missing-required-check` and still lists `existing-ci-workflow` (S7). A companion case on a destination with no prior workflow shows the file rewritten with `items: []` after its only item's condition is removed.

### F. MCP Tool Conventions

- **S45 Registration.** Both names are in `REPO_AUTOMATION_TOOLS` (`repo-automation-tool-names.ts`), have definitions in `REPO_AUTOMATION_TOOL_DEFINITIONS` and in `toolDefinitions` (`mcp-tool-definitions.ts`) in the same relative order, and have a `case` in `dispatchRepoAutomationTool`. The existing tests `defines one schema entry for every advertised repo automation tool` and `declares the same input-schema properties and required arrays on both tool-definition surfaces` pass with the new names.
- **S46 Definition parity.** The input schemas and annotations of each tool are identical on both definition surfaces.
- **S47 Result envelope.** `RepoAutomationMcpToolResult` gains one optional field `integration`; the handler builds the MCP result directly (docs-handler pattern) and returns JSON text plus `structuredContent`, with `isError` equal to `!ok`. No other existing tool's result changes.
- **S48 File-system seam.** Detect and validate reach the destination only through an injected read-only subset of `PushDownFileSystem` (`listFiles`, `isFile`, `readTextFile`) supplied through optional service methods; the bundled reference workflows are read through the same seam from the injected `extensionRoot`. Tests use in-memory fakes; no test mocks the `fs` module or reads a temporary file.

### G. No Model Call and No Sampling

- **S49 Forbidden tokens.** A Jest text test over every new production module (the `lib/push-down-integration/` modules, the push-down writer module, the tool definitions, input resolver, handler and service modules) fails if any contains an import of `child_process`, `node:child_process`, `http`, `node:http`, `https`, `node:https`, `net` or `node:net`, an import of `vscode`, or any of the tokens `fetch(`, `createMessage`, `sampling`, `getClientCapabilities`, `elicit`, `languageModel` or `LanguageModelChat`.
- **S50 Capability.** `createRepoAutomationMcpServer` declares exactly the capability key `tools`. An in-memory MCP client connected with `capabilities: {}` calls both tools and receives completed results, and the server issues no request to the client during either call.

### H. Skill (`push-down-integration`)

- **S51 Locations and packaging.** The skill source is `.agents/skills/push-down-integration/SKILL.md`, with copies at `.claude/skills/push-down-integration/SKILL.md`, `.github/skills/push-down-integration/SKILL.md` (while that tree exists) and the bundle copies under `extensions/drm-copilot/resources/` for the Codex-and-agents, Claude and Copilot customization trees; every copy is byte-identical (generated from the `.agents` source when #1028's generator is present, and its `--check` passes). The skill is in pack `core`, recorded in the pack manifests that #1029 defines for shared skills (`shared.json` when present, otherwise both `pack-manifests/core.json` files), with a `shared` entry in `config/harness-parity-matrix.json`. The existing pinned contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py`) pass.
- **S52 Loop.** A Jest contract test over the bundled Claude copy asserts that the skill names `detect_push_down_integration`, `validate_push_down_integration` and `.push-down-integration-needed.json`, and states these steps in this order: read the integration-needed file; call `detect_push_down_integration`; resolve each item by kind with ordinary edits under the destination's hooks and review; call `validate_push_down_integration`; on `verdict: fail` return to resolving; stop only when `integration.verdict` is `pass`; quote the `not_checked` list in the hand-off; re-run the push-down and report each item that remains in the file with the decision taken for it. It also states that a destination-owned path is listed in `.push-down-exclusions`.
- **S53 Per-kind guidance.** The skill's per-kind table names every kind in the S4 vocabulary constant and, for each, every option in that kind's `resolution_options` constant. Fail fixture: removing a kind from the skill text.
- **S54 Same `not_checked` list.** The skill section `## What Validate Does Not Check` holds one bullet per entry, equal to `VALIDATE_NOT_CHECKED` in order.

### I. Host Exposure and Brief

- **S55 Codex and Claude exposure.** Both names are added to `.codex/config.toml` `[mcp_servers.drm-copilot]` `enabled_tools` and to its bundle copy (through the #1028 generator source when present), and are not added to the approved set. `EXPECTED_DRM_COPILOT_TOOLS` in `test_push_down_codex_and_agents_resource_contracts.py` is updated in place and `assert_full_drm_copilot_transport` passes. Both names are listed in `.agents/skills/repo-automation-adapter/SKILL.md` `## Published MCP Tool Surface` and its bundle copy. `.claude/settings.json` is not edited.
- **S56 Brief bullet.** One bullet is added to `## MCP Surfaces Run the Installed Extension` of the execution-environment brief, immediately after the docs-tools bullet (currently the last bullet of the section), in every copy listed in `_BRIEF_COPIES` (`test_execution_environment_brief_contracts.py`), through the #1028 generator source when present. The bullet names both tools and states that a destination receives them, and their validate rules, only after an extension and MCP package release is installed. `test_brief_copies_are_byte_identical` passes, and a Jest contract test over the bundled Claude copy asserts the bullet's position and both tool names.

## Delivery Constraints (verified by branch diff or gate, not by a unit test)

- **C1** The branch adds no `.py` file. Existing Python contract tests named in S51, S55 and S56 are edited in place only where stated.
- **C2** No helper script is added. If one becomes necessary it is PowerShell or bash; no hook invokes Python.
- **C3** Each new TypeScript production file has its own `coverageThreshold` entry `{ lines: 85, branches: 75 }` in `extensions/drm-copilot/jest.config.cjs`, appended after the final map entry.
- **C4** No runtime dependency is added to `extensions/drm-copilot/package.json` or `packages/mcp-server/package.json`.
- **C5** No VS Code command is contributed for either tool.
- **C6** Edits to `mcp-tools.ts`, `repo-automation-service.ts`, `repo-automation-service-contract.ts`, the two definition modules and `jest.config.cjs` are limited to registration lines; new logic goes into new modules. Phase 0 measures their physical line counts after the upstream merges.

## Verified in CI or by the Integration Scenario (not rules)

- The seeded integration scenario (push to a scratch destination that has an existing `ci.yml`, run detect, resolve, and confirm validate passes) runs against a real destination; it is CI-dependent or orchestrator-owned. Locally it is represented by S44.
- That a destination's CI runs, that the required check is enforced by a ruleset, and that hooks behave correctly after resolution are observable only in a destination and are listed in `not_checked`.
- Availability of both tools in installed hosts follows the next extension and MCP package release.

## Data Flow

1. Push-down (apply or dry run): #1029 plan and report, #1050 collision results, and the shared conflict core over the post-run view (S11) produce items; apply writes the file (S12); both modes return the items (S14).
2. Agent session: reads the file, calls detect for current facts, edits the destination, calls validate, repeats until `pass` (S52).
3. Re-run push-down: unresolved items reappear; resolved items are gone; an empty list rewrites the file with `items: []`.

## Language Classification

| Artifact | Language |
|---|---|
| `extensions/drm-copilot/src/lib/push-down-integration/` (`workflow-yaml-reader.ts`, `integration-ecosystems.ts`, `integration-items.ts`, `integration-detect.ts`, `integration-validate.ts`, split by rule if it nears 500 lines) | TypeScript (MCP and extension code) |
| `extensions/drm-copilot/src/lib/push-down/push-down-integration-needed.ts` (writer and post-run overlay) | TypeScript |
| `src/mcp-push-down-integration-tool-definitions.ts`, `src/mcp-tool-inputs-push-down-integration.ts`, `src/mcp-handlers/push-down-integration-handlers.ts`, `src/repo-automation-service-push-down-integration.ts`, and registration edits in existing modules | TypeScript |
| Jest unit and contract tests under `extensions/drm-copilot/test/` | TypeScript |
| `jest.config.cjs` threshold entries | JavaScript (configuration) |
| `push-down-integration` skill and every copy, brief bullet, `repo-automation-adapter` edit, README, CHANGELOG | Markdown |
| Pack manifests, `config/harness-parity-matrix.json`, integration-needed file format | JSON |
| `.codex/config.toml` and its bundle copy | TOML |
| `test_push_down_codex_and_agents_resource_contracts.py` (in-place edit of an existing file only) | Python (existing) |

No new Python file. No helper script; the research recommends none, and any future helper is PowerShell or bash.

## Resolved Open Questions

Each decision below was taken by the orchestrator under autonomous mode (OD-1, relayed by the coordinator) by adopting the research default.

| ID | Decision | Rationale |
|---|---|---|
| OQ-1 | JSON file `.push-down-integration-needed.json` at the destination root, beside the manifest, committed like the manifest (S1 to S14). | The manifest and #1050's data file are JSON; one parser serves the writer and both tools; sorted-key rendering gives stable bytes. |
| OQ-2 | Owned YAML subset reader with a `yaml-unsupported` finding; no new dependency (S15 to S20, C4). | The TypeScript rule forbids new runtime dependencies without approval; #1050 records "No YAML parser dependency"; a dependency enters the NPM audit gate. |
| OQ-3 | Tool names `detect_push_down_integration` and `validate_push_down_integration` (S45). | Follows the existing `push_down_*` naming family. |
| OQ-4 | `ok: true` with `integration.verdict` for any completed run; `ok: false` only for input or host errors (S42). | A failing verdict is a result, not an MCP error. |
| OQ-5 | A `modified` or `missing` manifest entry listed in `.push-down-exclusions` is destination-owned and does not fail V5 (S40). | A destination edit returns the file to destination ownership (owner constraint). |
| OQ-6 | Symlinks and reparse points are not checked; listed in `not_checked` (S41). | The `PushDownFileSystem` seam follows links; no link-status seam is added. Revisit with #1049 OQ-7. |
| OQ-7 | Both tools added to Codex `enabled_tools` with prompt approval and to `repo-automation-adapter`; `.claude/settings.json` not edited (S55). | Codex does not expose an unlisted tool; an unlisted Claude tool prompts, which is acceptable. |
| OQ-8 | No VS Code command for either tool (C5). | Docs-tool precedent. |
| OQ-9 | Shared skill `push-down-integration` in pack `core`, with a parity-matrix entry (S51). | Every destination that receives a push-down can need it; #1029's shared-layer equality test requires the matrix entry. |
| OQ-10 | An empty item list rewrites the file with `items: []` (S12). | The file-system seam has no delete; #1029 deletes nothing. |
| OQ-11 | Version-matrix reference values are read from #1050's bundled harness workflows; the kind is not raised when a reference is absent (S29). | Keeps one source of truth for pins. |
| EX-1 | The plan is written against the upstream specs; execution runs after #1029, #1049 and #1050 merge, and Phase 0 confirms upstream symbols by name. | Both #1049 and #1050 plans stopped at the preflight limit on local defects; their stated contracts are the stable dependency. |

Assumptions made by this spec (not in the research): the `resolution_options` vocabulary (the research example listed `merge-into-existing-workflow`; it is omitted because the data file's `workflow_file` is managed content, so a merge would leave the collision condition in place on every run), the persistence rule in S7 (validate, not an empty file, is the stop condition), the per-kind `detail` keys, the `construct` values, the `poetry-version` key name, the `push_down_report.integration_needed` field name and presence rule, the post-run overlay for dry runs (S11), and the `not_checked` wording. Each is a data choice the planner may refine only by revising this spec.

## Risks for Planning

These risk classes halted sibling children; the plan must address each.

- **Process-reduction ledger regions.** `ProcessReductionChain.Ledger.Tests.ps1` reverts every entry under `docs/engineering/process-reductions/` against the live tree. Stored patch `0010-early-dependent-starts.patch` has hunks in `extensions/drm-copilot/jest.config.cjs` (around the `epic-orchestrator-state-wave-barrier.ts` entry) and in both `pack-manifests/core.json` files (around the `enforce-epic-*` hook entries). Ledger entries quote brief bullets of `## MCP Surfaces Run the Installed Extension` (concurrent checkpoints and light remediation); the docs-tools bullet is not quoted. Mitigation: append threshold entries after the final map entry, add skill paths in the `.claude/skills/` and `.agents/skills/` regions of the manifests, add the brief bullet after the docs-tools bullet, and have Phase 0 confirm each insertion point lies outside every `Current` fence and patch hunk with its context.
- **Rules with no failing test.** Each S rule needs a named failing fixture; S32 and S43 need a write-recording fake; S49 and S50 need the text and capability tests; S54 needs the skill-to-constant equality test.
- **Acceptance conditions made unsatisfiable by earlier tasks.** S20, S38, S39 and S44 depend on #1050's renderer; the passing fixture is built from the renderer output at test time, never from a copied string. S10 to S12 depend on #1029's harness call order and report shape. S14 must not break #1029's compatibility tests that deep-equal `push_down_report`; Phase 0 checks which #1029 tests do so.
- **Tool behavior rejecting syntax.** actionlint must not gate destination fixtures, since it rejects `job.workflow_repository` and `job.workflow_sha` (the #1050 halt). The subset reader must accept every construct in #1050's caller template and bundled harness workflows (S20); a bundled workflow outside the subset makes S29 references unavailable and fails S20.
- **V1 strictness.** S36 fails destinations whose workflows use anchors or other unsupported constructs; the only resolution option for `yaml-unsupported` is a rewrite. This is the research default and is recorded here so the planner does not relax it silently.
- **Mirror parity.** The skill copies, pack manifests and parity-matrix entry, the Codex config and its bundle copy, the adapter skill and the brief bullet must move together; the brief task needs a `Mirror parity` Pre-Mortem bullet.
- **Test isolation.** Pure modules with no module-level mutable state, a fresh fake per test, no temporary files; tests run parallel-only through normal Jest workers (no serial, single-process, shuffled or reversed runs; no local integration or golden suites). Test-order dependence is a defect to fix, not to work around.
- **Evidence.** Counts and coverage come from Jest output and `lcov.info`, timestamps are read from the clock, evidence is append-only under `<FEATURE>/evidence/<kind>/`, and no artifact encodes an absolute path.

## Acceptance Criteria

- [x] AC1 (draft 1): An apply-mode push-down writes `.push-down-integration-needed.json` listing each unresolved decision it observes, with the schema, kind vocabulary, id, ordering, rendering and forbidden-content rules of S1 to S9, the sources of S10, the post-run view of S11, the write rule of S12, no manifest entry (S13) and the result field of S14; a dry run returns the same items without writing; and the writer module passes the no-model-call text test of S49.
- [x] AC2 (draft 2): `detect_push_down_integration` returns `integration.ecosystems`, `integration.workflows` and `integration.conflicts` per S21 to S31, using the workflow reader of S15 to S20, and a write-recording fake records no write (S32, S33).
- [x] AC3 (draft 3): `validate_push_down_integration` fails on unparsable or unsupported YAML (V1, S36), a malformed data file (V2, S37), missing required check names (V3, S38), mismatched coverage artifact paths (V4, S39) and inconsistent manifest hashes (V5, S40), each shown by a failing fixture; passes on a correct integration shown by a passing fixture per rule and by the end-to-end case of S44; and returns the verdict shape and `not_checked` list of S35 and S41 with read-only, deterministic behavior (S43).
- [x] AC4 (draft 4): The `push-down-integration` skill documents the read, resolve, validate loop and stop condition, names `detect_push_down_integration` and `validate_push_down_integration`, covers every item kind and resolution option, and states the same not-checked list as the tool (S51 to S54).
- [x] AC5 (draft 5): `detect_push_down_integration` and `validate_push_down_integration` follow the existing MCP tool conventions (explicit required `workspace_root`, `additionalProperties: false`, read-only annotations, structured `integration` result, `ok` semantics) and have unit tests with injected in-memory file-system seams (S23, S34, S42, S45 to S48).
- [ ] AC6 (draft 6): No new Python file is added; the tools and writer are TypeScript and no helper script is added (C1, C2, Language Classification).
- [x] AC7 (owner behavior 5): No new module calls a model or uses MCP sampling, shown by the text test of S49 and the capability and in-memory client test of S50.
- [ ] AC8: Both tools are reachable from Codex through `enabled_tools` and the `repo-automation-adapter` skill without a `.claude/settings.json` edit (S55), and the execution-environment brief bullet is present after the docs-tools bullet in every `_BRIEF_COPIES` copy with byte identity preserved (S56).

## Issue-to-Spec Mapping

| Draft criterion (issue.md) | Spec AC | Rules |
|---|---|---|
| Push-down writes an `integration-needed` file and makes no model call | AC1, AC7 | S1 to S14, S49 |
| Detect returns ecosystems, workflows, conflicts; modifies nothing | AC2 | S15 to S33 |
| Validate fails on each class and passes on a correct integration | AC3 | S35 to S44 |
| Skill documents the loop and names both tools | AC4 | S51 to S54 |
| MCP tool conventions and injected file-system seams | AC5 | S23, S34, S42, S45 to S48 |
| No new Python; TypeScript tools; helpers PowerShell or bash | AC6 | C1, C2 |

## Non-Goals

- No model call and no MCP sampling anywhere in the extension or the tools.
- No automatic resolution of any item; the tools report facts and verdicts only.
- No YAML library dependency and no actionlint invocation.
- No check of ruleset or branch protection (needs `gh`), of CI execution, or of coverage values.
- No symlink or reparse-point detection.
- No VS Code command and no `.claude/settings.json` change.
- No edit to `push-down-apply.ts`, to any hook, or to canonical policy files.
- No change to the manifest schema or #1050's data file schema.

## Definition of Done

- [ ] Every S rule mapped to one implementing task and at least one passing and one failing Jest case (or the named existing contract test).
- [ ] Every acceptance criterion in this file and in `user-story.md` verified and checked off.
- [ ] Full toolchain loop passes for `extensions/drm-copilot`; per-file coverage of each new TypeScript file at or above 85% line and 75% branch.
- [ ] Mirror-parity contract tests, `test_brief_copies_are_byte_identical` and `ProcessReductionChain.Ledger.Tests.ps1` pass.
- [ ] README and CHANGELOG updated.

## Seeded Test Conditions (from potential)

- [x] Unit coverage areas: conflict detection from fixture file lists; each validation rule with a passing and a failing fixture; `integration-needed` file generation.
- [x] Integration scenarios: push to a scratch destination that has an existing `ci.yml`, run detect, resolve, and confirm validate passes.
- [ ] CLI/API examples
