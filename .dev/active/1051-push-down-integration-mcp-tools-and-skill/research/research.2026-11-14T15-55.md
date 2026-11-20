# Research: Push-Down Integration MCP Tools and Skill (Issue #1051)

- Issue: #1051 (epic #1018 `shared-agent-harness-layer`, child 10, wave 5, depends on #1049 and #1050)
- Branch: `feature/push-down-integration-mcp-tools-and-skill-1051`
- Mode: preparation, research only; no code changed
- Filename stamp: the task-researcher agent has no clock tool (Read, Grep, Glob, WebFetch, Write only). The stamp in this file name was not read from a clock; the orchestrator renamed the file to its write time, 2026-11-14T15-55 UTC, read from the file-system modification time.
- Orchestrator-confirmed (git, 2026-11-14T15:55Z): #1029, #1049 and #1050 are prepared (plans only) and not executed on `epic/shared-agent-harness-layer-integration`, so their production symbols are absent on this branch; no commit on `origin/main` since 2026-11-13 adds an integration-needed file or detect or validate tools.

## 1. Sources Read

- Requirements: `docs/features/potential/promoted/2026-10-31-push-down-integration-mcp-tools-and-skill.md`; this folder's `issue.md`, `spec.md` (template-level draft, Behavior and Constraints sections only), `user-story.md`, and `plan.2026-11-14T10-43.md` (unfilled template).
- Epic: `docs/features/epics/shared-agent-harness-layer/epic.md` (`## Shared Design`, `## Dependency Rationale`, `## Planning Refresh 2026-11-14`, `### Superseded-work check`) and `resume-note.md`.
- Upstream contracts, cited by feature folder and file:
  - #1029 feature folder `2026-10-30-push-down-consolidation-and-ecosystem-packs-1029`: `spec.md` (`### Destination Manifest`, `### Decision Table`, `### Dry-Run and Apply Report`, `### MCP Result Compatibility`) and `plan.2026-10-30T18-37.md` (module names under `extensions/drm-copilot/src/lib/push-down/`).
  - #1049 feature folder `2026-10-31-pushed-down-vendored-code-coverage-carve-out-1049`: `spec.md` (`## Destination Manifest Schema`, `### Canonical Hash Rule`, `### Status Vocabulary`, `### Downstream Dependencies`), `plan.2026-10-31T14-03.md`, and `evidence/other/preflight-fixes.2026-11-14T14-07.md`.
  - #1050 feature folder `2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050`: `spec.md` (`## Data File Schema`, `## Template Contract`, `### Conflicts`, `## Non-Goals`) and `plan.2026-11-14T09-31.md` (`## Planning Decisions` D1 to D5, `## Pre-Mortem`).
- Code (all under the worktree, cited by file and symbol): `extensions/drm-copilot/src/mcp-server.ts`, `mcp-tools.ts`, `mcp-repo-automation-tool-definitions.ts`, `mcp-tool-definitions.ts`, `mcp-push-down-schema-properties.ts`, `mcp-docs-tool-definitions.ts`, `mcp-handlers/docs-handlers.ts`, `mcp-handlers/render-subagent-tree-handler.ts`, `mcp-tool-inputs-subagent-tree.ts`, `repo-automation-tool-names.ts`, `repo-automation-service-contract.ts`, `repo-automation-service-push-down.ts`, `lib/push-down/push-down-service-call.ts`, `lib/push-down/filesystem-adapter.ts`, `lib/push-down/claude-exclusion-filter.ts`, `lib/push-down/claude-exclusion-manifest.ts`, `lib/push-down/claude-blast-radius-derive-manifests.ts`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/jest.config.cjs`, `packages/mcp-server/package.json`, `packages/mcp-server/esbuild-mcp-server.cjs`, `.codex/config.toml`, `.claude/settings.json`, `.mcp.json`, `.agents/skills/repo-automation-adapter/SKILL.md`, `.claude/hooks/validate-feature-review-coverage-metrics.ps1`, `.claude/hooks/enforce-epic-merge-gate-child-ci.ps1`.
- Tests: `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts`, `test/mcp-parallel-validation-definitions.test.ts`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (`EXPECTED_DRM_COPILOT_TOOLS`, `APPROVED_DRM_COPILOT_TOOLS`, `assert_full_drm_copilot_transport`), `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` (`_BRIEF_COPIES`, `test_brief_copies_are_byte_identical`), `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`.
- Ledger: `docs/engineering/process-reductions/` entries and `patches/0010-early-dependent-starts.patch`.

## 2. Current State

### 2.1 Where the push-down lives on this branch

- The three push-downs are in-process TypeScript. `push_down_copilot_customizations`, `push_down_codex_and_agents_customizations` and `push_down_claude_customizations` dispatch in `dispatchRepoAutomationTool` (`mcp-tools.ts`) to `mcp-handlers/push-down-handlers.ts`, then to `runPushDown*Customizations` in `repo-automation-service-push-down.ts`, then to `pushDown*CustomizationsServiceCall` in `lib/push-down/push-down-service-call.ts`, which call the per-ecosystem `pushDownCustomizations` ports (`copilot-customizations.ts`, `codex-agents-customizations.ts`, `claude-customizations.ts`).
- Conflict and skip reporting today: only the Claude path reports anything beyond the summary. Exclusion conflicts from `.push-down-exclusions` are rendered by `renderExclusionLines` with the prefix `EXCLUSION_CONFLICT_LINE_PREFIX` (`push-down exclusion conflict:`) and returned in `warnings` (`PushDownServiceCallResult.warnings`). Every other path is overwritten; there is no manifest, no hash, and no dry run.
- None of the #1029 or #1049 symbols exist on this branch: a search of the whole worktree for `hashPayloadText`, `DESTINATION_MANIFEST`, `push-down-manifest`, `runPushDownPipeline`, `PUSH_DOWN_CONFLICT_LINE_PREFIX` and `integration-needed` finds matches only in feature documents under `docs/features/`. #1029 and #1049 are planned, not merged (`resume-note.md`; epic `### Authoritative child branches`). #1050 is planned (`plan.2026-11-14T09-31.md`), not executed.
- Planned shape after #1029 and #1050 (from their plans; to be re-confirmed at this item's Phase 0): `PD/push-down-pipeline.ts` (`runPushDownPipeline`), `PD/push-down-apply.ts` (`applyPushDownPlan`), `PD/push-down-report.ts` (`PushDownReport`, `PUSH_DOWN_CONFLICT_LINE_PREFIX` = `push-down conflict:`, `renderPushDownConflictLines` for `conflict`, `unmanaged-conflict`, `deleted-locally`), `PD/push-down-destination-manifest.ts` (`DESTINATION_MANIFEST_RELATIVE_PATH`, `parseDestinationManifest`, `hashPayloadText`), `PD/push-down-harness.ts` (`pushDownHarness`), `PD/push-down-ecosystem-registry.ts` (root-level assertion of the manifest path), and from #1050 `PD/push-down-ci-workflows.ts` and `PD/push-down-ci-layer.ts` (`findCiWorkflowNameCollisions`, which returns `push-down conflict:` lines when another workflow declares `name: CI`). `PD` is `extensions/drm-copilot/src/lib/push-down/`.

### 2.2 Where the `integration-needed` writer plugs in

The natural seam is after the plan is computed and before or beside the manifest write:

- Input data already exists in structured form once #1029 and #1050 land: `PushDownReport.files[]` entries with action `conflict`, `unmanaged-conflict`, `deleted-locally`; #1050 collision results from `findCiWorkflowNameCollisions` and its withheld-caller decision.
- Recommended placement: a new pure module builds the item list; one call site in `PD/push-down-harness.ts` (which both #1029 and #1050 already route through) writes it through `WriteIfChangedFileSystem` over the raw file system in apply mode, and returns it in the result in both modes. `push-down-apply.ts` is not edited, because #1029 caps it at 800 lines and it already carries manifest, summary and exclusion writes.
- The file path must be added to the root-level assertion in `PD/push-down-ecosystem-registry.ts` (the same `assertManifestPathIsRootLevel` guard from `claude-exclusion-manifest.ts` that #1029 applies to `.push-down-manifest.json`), so it is never enumerated as payload or classified `unmanaged-conflict`.

## 3. Candidate Approaches

### Approach A (recommended): shared integration-facts core in the extension, two read-only MCP tools, push-down writes the facts it can see

- One pure TypeScript core under a new directory `extensions/drm-copilot/src/lib/push-down-integration/` reads a destination through a read-only subset of `PushDownFileSystem` (`listFiles`, `isFile`, `readTextFile`) and produces facts (ecosystems, workflows, conflicts) and a verdict (validate rules).
- The push-down builds its `integration-needed` items from the same item model, so the file, the detect conflicts and the validate failures share one vocabulary.
- Workflow YAML is read by an owned, pure subset reader (section 5.2); no new runtime dependency.
- Advantages: one item vocabulary; no dependency change; matches the docs-tool pattern of a dedicated definitions module and handler; testable with in-memory fakes; no process spawn.
- Limitations: the YAML reader is a subset reader, so validate must state what it does not parse; the coverage-path rule is textual.

### Rejected alternatives

- Add a YAML library (for example the `yaml` package) as a runtime dependency: the TypeScript rule forbids new runtime dependencies without explicit approval, #1050 `## Non-Goals` already records "No YAML parser dependency", and a new dependency enters the `NPM Audit Gate` for `extensions/drm-copilot`. `js-yaml` appears only in the `overrides` block of `extensions/drm-copilot/package.json` (a transitive development dependency), so it is not usable at run time. Kept as an owner question (OQ-2).
- Run actionlint from the tools: actionlint is a host development pin (execution-environment `## Development Toolchain Baseline`), not present in destinations; it needs a child process from an MCP tool; and #1050's plan stopped because actionlint rejects `job.workflow_repository` and `job.workflow_sha`, which the #1050 template relies on.
- Put the tools in `packages/mcp-server`: that package has no TypeScript source. `esbuild-mcp-server.cjs` bundles `extensions/drm-copilot/src/mcp-server.ts`; every tool is defined in the extension and reaches both hosts through that bundle.
- Have the push-down call a model or MCP sampling: excluded by the requirement and by section 8.

## 4. MCP Tool Conventions (Question 2)

- Registration: `mcp-server.ts` `createRepoAutomationMcpServer` declares `capabilities: { tools: {} }`, answers `ListToolsRequestSchema` with `listRepoAutomationTools()` (which returns `REPO_AUTOMATION_TOOL_DEFINITIONS`), and routes `CallToolRequestSchema` through `isRepoAutomationToolName` and `dispatchRepoAutomationTool`. The result is returned as JSON text plus `structuredContent`, with `isError: !result.ok` (`toCallToolResult`).
- A new tool needs: its name in `REPO_AUTOMATION_TOOLS` (`repo-automation-tool-names.ts`); a definition in `REPO_AUTOMATION_TOOL_DEFINITIONS` and, for cross-surface parity, in `toolDefinitions` (`mcp-tool-definitions.ts`; that list is read only by tests today, and `declares the same input-schema properties and required arrays on both tool-definition surfaces` compares shared names); a `case` in `dispatchRepoAutomationTool`. The test `defines one schema entry for every advertised repo automation tool` requires the definition order to equal `REPO_AUTOMATION_TOOLS`.
- Input schema: `workspace_root: workspaceRootProperty` (`mcp-push-down-schema-properties.ts`), listed in `required`, with `additionalProperties: false`. Inputs are resolved with `asToolArgumentObject` and `normalizeWorkspaceRoot` (pattern: `resolveRenderSubagentTreeToolInput` in `mcp-tool-inputs-subagent-tree.ts`).
- Annotations (#1036): `ToolDefinition.annotations` with `readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`; the docs tools set `{ readOnlyHint: true, openWorldHint: false }` for read-only tools (`mcp-docs-tool-definitions.ts`).
- Structured results: `RepoAutomationMcpToolResult` (`mcp-tools.ts`) carries `ok`, `tool`, `workspace_root`, `summary`, optional `warnings`, and domain envelopes such as `docs`. The docs handler (`handleDocsTool`) builds the MCP result directly and adds the `docs` envelope, without extending `RepoAutomationExecutionResult` or `toMcpToolResult`. That is the model to follow: add one optional field `integration` to `RepoAutomationMcpToolResult`.
- Model tool: the read-only docs tools (`run_docs_inventory`, `run_docs_check`) for definitions, annotations and the handler shape; `render_subagent_tree` for the minimal input resolver. Neither touches the destination tree for writing.
- File-system seam: `PushDownFileSystem` (`filesystem-adapter.ts`) with `RealPushDownFileSystem` in production; existing push-down tests use in-memory fakes (#1029 plans `buildInMemoryFileSystem` in `PDT/push-down.test-helpers.ts`). The service exposes it to push-down code through `PushDownServiceDeps` (`fs`, `extensionRoot`, `log`) in `repo-automation-service-push-down.ts`. The docs tools reach their runtime through an optional service method (`runDocsCommand?`), so a host without it throws a coded error; the same optional-method pattern avoids editing the test service stub `test/mcp-server-test-service.ts`.
- File sizes (physical line counts read with a multiline newline count): `mcp-tools.ts` 473, `mcp-repo-automation-tool-definitions.ts` 434, `mcp-tool-definitions.ts` 471, `repo-automation-service.ts` 476, `repo-automation-service-contract.ts` 307, `jest.config.cjs` 596. Each edit to these files must be small; new logic goes into new modules.
- Jest: `jest.config.cjs` has per-file `coverageThreshold` entries and no `global` key, so every new production file needs its own `{ lines: 85, branches: 75 }` entry; tests run through `node run-jest.cjs` in `extensions/drm-copilot/`.
- Bundle and pack implications: the tools add no file under `extensions/drm-copilot/resources/`; `packages/mcp-server/prepack.cjs` copies resources only; `@danmoisan/drm-copilot-mcp` picks the tools up on its next build. No pack manifest lists TypeScript.
- Host exposure: `.codex/config.toml` `[mcp_servers.drm-copilot]` has an `enabled_tools` allowlist (pinned by `EXPECTED_DRM_COPILOT_TOOLS` in `test_push_down_codex_and_agents_resource_contracts.py`, together with `APPROVED_DRM_COPILOT_TOOLS` for per-tool `approval_mode`). Codex does not expose a tool missing from that list. `.mcp.json` lists no tools. `.claude/settings.json` lists pre-approved `mcp__drm-copilot__*` tools; an unlisted tool prompts.

## 5. Detect Tool (Question 3)

### 5.1 Ecosystems present

- Harness ecosystems (`claude`, `codex`, `copilot`): from the destination manifest `selection` keys (#1029 `### Destination Manifest`) and, when the manifest is absent, from root evidence (`.claude/`, `.codex/` or `AGENTS.md`, `.github/copilot-instructions.md`).
- Language packs (`python`, `powershell`, `typescript`, `csharp-modern` or `csharp-legacy`): two facts per pack, `selected` (union of `selection.<ecosystem>.packs` in the manifest) and `present` (file evidence). Reuse from main: `MANIFEST_FILENAMES`, `NON_MODULE_MANIFEST_SUFFIXES` and `isExcludedDirectoryName` in `lib/push-down/claude-blast-radius-derive-manifests.ts` (directory pruning and manifest vocabulary). A new pure mapping adds the language association (`pyproject.toml` or `setup.py` to python; `package.json` with `tsconfig.json` to typescript; `.csproj`, `.sln`, `.slnx` to csharp; `.ps1`, `.psm1`, `.psd1` outside pushed-down roots to powershell). No ecosystem detection exists in #1029 or #1050 beyond selection records; #1050 `D4` maps packs to CI job stems and is reusable for the pack-to-job mapping once merged.

### 5.2 Workflows and job names

- Enumerate `.github/workflows/*.yml` and `*.yaml` with `listFiles` (sorted by `compareCodePoint`).
- YAML library: none is a runtime dependency of the extension or the MCP package (`dependencies` lists only `@modelcontextprotocol/sdk` in both `package.json` files). Existing TypeScript parses YAML-like frontmatter by hand (`lib/codex-native-converter/parser.ts`, "no YAML library"). #1050's tests read workflow text with line-based checks.
- Recommended reader: a pure `workflow-yaml-reader.ts` supporting the block-style subset GitHub workflows use (block mappings and sequences by indentation, comments, plain, single-quoted and double-quoted scalars, block scalars `|` and `>` with chomping indicators, flow sequences and flow mappings of scalars such as `branches: [main]`, `${{ }}` expressions kept as opaque strings). Tabs used for indentation, anchors, aliases, tags, multiple documents and complex keys produce a `yaml-unsupported` finding with the line, not a silent pass. It extracts the top-level `name`, `on` (string, sequence or mapping), and `jobs.<id>` with `name`, `uses`, `needs`, `if`, `strategy.matrix` and step `with` version keys.

### 5.3 Structured conflicts

Detect returns `integration.conflicts[]` in the same item model as the `integration-needed` file (section 6), computed from the current destination, plus `integration.workflows[]` (`path`, `name`, `triggers`, `jobs[]` with `id`, `name`, `uses`, `needs`, and `parse` status `ok`, `error` or `unsupported`) and `integration.ecosystems`. It also reports whether `.push-down-integration-needed.json` exists and how many items it lists, without interpreting it. Detect writes nothing; a test asserts the fake records no write.

## 6. The `integration-needed` File

- Format: JSON (recommended). Reasons: the manifest and the #1050 data file are JSON; the tools and the push-down share one parser; sorted-key rendering through the existing `stringifySorted` (`copilot-customizations-engine.ts`) gives stable bytes. Markdown would need a second, prose-shaped parser for detect and validate.
- Path: `.push-down-integration-needed.json` at the destination root, beside `.push-down-manifest.json`, guarded root-level like the manifest.
- Write rule: written in apply mode through write-if-changed; never in a dry run (the dry-run result carries the items instead). When no item exists and the file exists, it is rewritten with an empty `items` array (the `PushDownFileSystem` seam has no delete operation, and #1029 deletes nothing).
- Forbidden content (as the manifest): timestamps, absolute paths, host or user names.
- Schema:

```json
{
  "items": [
    {
      "detail": { "existing_name": "CI" },
      "id": "workflow-name-collision:.github/workflows/build.yml",
      "kind": "workflow-name-collision",
      "path": ".github/workflows/build.yml",
      "resolution_options": ["rename-existing-workflow", "merge-into-existing-workflow"],
      "source": "push-down"
    }
  ],
  "payload_version": "<extension version>",
  "schema_version": "1.0.0"
}
```

- `items` sorted by `id` (code-point order); `id` is `<kind>:<path>` plus `#<discriminator>` when one path yields several items of one kind; `resolution_options` is a fixed vocabulary per kind (data, not judgment).
- Item kinds:

| Kind | Raised by | Condition |
| --- | --- | --- |
| `workflow-name-collision` | push-down (#1050 collision) and detect | another workflow declares top-level `name: CI`, so the caller was withheld |
| `existing-ci-workflow` | push-down and detect | `.github/workflows/ci.yml` or `ci.yaml` exists and is not the pushed caller |
| `job-name-overlap` | detect | an existing job id or `name` equals a pushed job id or name (`ci-required-gate`, `CI Required Gate`, pack job ids) |
| `missing-required-check` | push-down and detect | a `required_contexts` entry of `.github/drm-copilot/ci-required-checks.json` is produced by no job of the workflow the data file names |
| `version-matrix-difference` | push-down and detect | an existing workflow's `node-version`, `python-version`, `dotnet-version` or Poetry pin differs from the value in the bundled harness workflow for that pack |
| `destination-edited-file` | push-down (#1029 `conflict`) | a managed file's hash differs from its manifest entry and from the payload; `detail.is_hook` is true under `.claude/hooks/`, `.codex/hooks/` or `.github/hooks/` |
| `unmanaged-conflict` | push-down (#1029) | a differing file with no manifest entry was not written |
| `deleted-locally` | push-down (#1029) | a managed file was deleted in the destination |
| `yaml-unsupported` | detect | a workflow uses a construct outside the reader subset |

## 7. Validate Tool (Question 4)

Verdict shape: `integration: { verdict: "pass" | "fail", rules: [{ rule, status: "pass" | "fail" | "not-applicable", failures: [{ path, message }] }], not_checked: [<fixed strings>] }`. The result `ok` is `true` whenever the tool ran, so a `fail` verdict is not reported as an MCP error (`isError`); input or host failures give `ok: false` through `toFailureToolResult` (OQ-4).

| Rule | Check | Source of truth |
| --- | --- | --- |
| V1 workflow-read | every `.github/workflows/*.yml`/`*.yaml` is read by the subset reader without `error` or `unsupported` | section 5.2 |
| V2 data-file | `.github/drm-copilot/ci-required-checks.json` parses, has `schema_version` major `1`, and `workflow`, `workflow_file`, `required_contexts`; not-applicable when absent (CI not delivered) | #1050 `## Data File Schema` |
| V3 required-check | exactly one workflow has top-level `name` equal to the data file `workflow`; it triggers on `pull_request`; each `required_contexts` entry equals some job's `name` (or id when no name); the job named by the first entry `needs` every other job id of that workflow and has `if: always()` | #1050 `## Template Contract`; merge-gate literal `CI` in `enforce-epic-merge-gate-child-ci.ps1` |
| V4 coverage-artifact-path | for each selected language pack, the workflow named `CI` either calls the harness workflow for that pack (`drmoisan/drm-copilot/.github/workflows/harness-<stem>.yml@...` or `./.github/workflows/drm-copilot-<stem>.yml`) or a workflow it reaches names the artifact path literally: TypeScript `coverage/lcov.info`, Python `artifacts/python/lcov.info`, PowerShell `artifacts/pester/powershell-coverage.xml`, C# `artifacts/csharp/coverage.xml` | `Get-LcovRepoCoverage`, `Get-JacocoRepoCoverage` call sites in `.claude/hooks/validate-feature-review-coverage-metrics.ps1`; #1050 `## Template Contract` |
| V5 manifest-hash | `.push-down-manifest.json` parses per `parseDestinationManifest` (unknown major, absolute, drive-letter, UNC or `..` keys fail); each entry's status per #1049 `### Status Vocabulary` using `hashPayloadText` over the text read; `modified` and `missing` fail unless the path is listed in `.push-down-exclusions` (then reported as destination-owned, not a failure); an absent manifest fails | #1049 `## Destination Manifest Schema`; #1029 `### Destination Manifest` and O-8 |

What validate does not check (the `not_checked` list and the skill both state it): whether CI runs or passes; GitHub expression syntax and context names; action versions and their availability; secrets and permissions; runner labels; the ruleset or branch protection (needs `gh`; out of scope); YAML outside the reader subset; coverage values and thresholds; whether hooks behave correctly; symlinks and reparse points (the `PushDownFileSystem` seam follows links through `statSync`, so #1049's symlink-is-`modified` rule is not enforced by this tool unless a link-status seam is added, OQ-6); files the manifest does not list; and integration choices that are correct but unusual.

Hash note: #1049's canonical hash is over raw bytes with CR LF and lone CR mapped to LF; `readTextFile` decodes UTF-8 and keeps a byte-order mark as U+FEFF, so re-encoding yields the same bytes for valid UTF-8. Invalid UTF-8 decodes to replacement characters, which changes the hash and therefore fails closed, matching #1049's rule.

## 8. Skill (Question 5)

- Locations: shared skills live in `.agents/skills/<name>/SKILL.md` (epic `## Shared Design`: `.agents/skills` is the source for shared skills), with the Claude copy at `.claude/skills/<name>/SKILL.md`, a Copilot copy at `.github/skills/<name>/SKILL.md` while that tree exists (#1032 retires it), and bundle copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/`, `resources/claude-customizations/.claude/skills/` and `resources/customizations/.github/skills/`. Precedent: `owner-directives` exists in all six locations.
- Manifests: today `resources/claude-customizations/pack-manifests/core.json` and `resources/codex-and-agents-customizations/pack-manifests/core.json`. After #1029, a skill whose parity-matrix disposition is `shared` belongs in the new `shared.json`, and #1029 plans a real-tree test that `shared.json` `paths` equal the set derived from `config/harness-parity-matrix.json`; so a shared skill also needs a #1025 parity-matrix entry. After #1028, `.claude/skills` copies are generated from `.agents/skills`, so the skill is authored once and regenerated (`--check` must pass).
- Contract tests that pin the skill (execution-environment `## Contract Tests That Pin Mirrored Files`): `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_issue_824_follow_ups.py` (no consuming-product names in pushed skills), the Codex generator `--check`, and `test_claude_rules_frontmatter.py` only if an agent preloads it.
- Helper: none needed. The loop is read file, edit, call validate; every step is an MCP call or an ordinary edit. If a helper becomes necessary it is PowerShell or bash, never Python.
- Proposed name: `push-down-integration`, pack `core` (every destination that receives a push-down can need it). Content: read `.push-down-integration-needed.json`; call `detect_push_down_integration`; resolve each item by kind with ordinary edits under the destination's hooks and review; for a destination-owned edit, list the path in `.push-down-exclusions`; call `validate_push_down_integration`; stop only on `verdict: pass`; quote the `not_checked` list in the hand-off; re-run the push-down afterwards so the file's `items` becomes empty.
- Codex reachability: add both tool names to `.agents/skills/repo-automation-adapter/SKILL.md` `## Published MCP Tool Surface` (and its bundle copy) and to `.codex/config.toml` `enabled_tools` (and its bundle copy), updating `EXPECTED_DRM_COPILOT_TOOLS` in place. After #1028, `.codex/config.toml`'s `[mcp_servers]` table is generated, so the edit goes to the generator source.

## 9. No Model Call and No MCP Sampling (Question 6)

- Verified: a case-sensitive search of `extensions/drm-copilot/src` for `sampling`, `createMessage`, `getClientCapabilities`, `elicit`, `languageModel` and `LanguageModelChat` finds no match; `vscode.lm` appears only as `vscode.lm.registerMcpServerDefinitionProvider` in `mcp-provider.ts` (server registration, not a model call). The server declares only `capabilities: { tools: {} }`.
- Test strategy: (a) an MCP-server test that connects an in-memory client with `capabilities: {}` (the existing pattern in `test/mcp-server.test.ts` and `test/mcp-server.docs.test.ts`), calls both tools, and receives results; a sampling request would have no client support. (b) A Jest text test over the new modules asserting no import of `child_process`, `node:http`, `node:https`, `node:net`, no `fetch(` and no `createMessage`, `sampling` or `vscode` token, and that `createRepoAutomationMcpServer` still declares only the `tools` capability. (c) A text test over the push-down integration-needed module with the same token set.

## 10. Overlap and Supersession (Question 7)

- Main-merged code: no `integration-needed` writer, no detect or validate tool, no destination workflow reader (section 2.1 search). The epic's coordinator pass recorded the same result (`### Superseded-work check`, row 1051).
- Active features: #1050 explicitly excludes the file and both tools (`## Non-Goals`) and leaves name-collision resolution to #1051 (`## Resolved Open Questions`, row Name collision). #1029 provides conflict reporting in `warnings` and `push_down_report` but no consolidated file. #1049 provides the status vocabulary and a PowerShell status function for PoshQC, not an MCP tool. #1036 docs tools and `validate_orchestration_artifacts` validate other artifact families.
- Partial reuse, not supersession: #1050's `findCiWorkflowNameCollisions` and #1029's report actions become inputs.

SUPERSEDED: none

Marked for the orchestrator to confirm with `gh` or `git`: that no pull request merged after the 2026-11-14 epic refresh adds an integration-needed file or detect/validate tools.

## 11. Requirements Mapping (draft for the spec)

- R1 (issue AC 1): apply runs write `.push-down-integration-needed.json` with the items of section 6 that the push-down can observe; dry runs return them without writing; a text test shows the writer module has no model, network or process import.
- R2 (AC 2): `detect_push_down_integration` returns `integration.ecosystems`, `integration.workflows`, `integration.conflicts`; an in-memory fake records no write.
- R3 (AC 3): `validate_push_down_integration` has one failing and one passing fixture per rule V1 to V5 and a full passing integration fixture built from #1050's rendered caller and data file.
- R4 (AC 4): the skill names both tools, the read, resolve, validate loop, the stop condition, and the `not_checked` list.
- R5 (AC 5): both tools use `workspaceRootProperty` as required input, `additionalProperties: false`, read-only annotations, the `integration` result field, and in-memory file-system seams.
- R6 (AC 6): branch diff adds no `.py` file; new production code is TypeScript (tools, writer) and Markdown (skill).
- Proposed new files (each TypeScript production file gets a `coverageThreshold` entry): `src/lib/push-down-integration/workflow-yaml-reader.ts`, `integration-ecosystems.ts`, `integration-items.ts` (item model, ids, rendering), `integration-detect.ts`, `integration-validate.ts` (split by rule if it nears 500 lines), `src/lib/push-down/push-down-integration-needed.ts` (writer seam for the harness), `src/mcp-push-down-integration-tool-definitions.ts`, `src/mcp-tool-inputs-push-down-integration.ts`, `src/mcp-handlers/push-down-integration-handlers.ts`, `src/repo-automation-service-push-down-integration.ts`; tests mirrored under `extensions/drm-copilot/test/`.
- Proposed edits: `repo-automation-tool-names.ts`, `mcp-repo-automation-tool-definitions.ts`, `mcp-tool-definitions.ts`, `mcp-tools.ts` (two cases, one field), `repo-automation-service-contract.ts` and `repo-automation-service.ts` (two optional methods), `PD/push-down-harness.ts` (one call), `PD/push-down-ecosystem-registry.ts` (root-level guard), `jest.config.cjs`, skill files and manifests per section 8, `.codex/config.toml` and its bundle copy, `test_push_down_codex_and_agents_resource_contracts.py` (in place), `extensions/drm-copilot/README.md`, `CHANGELOG.md`, and the brief per section 12.

## 12. Risks for Planning (Question 8)

- Process-reduction ledger region: `ProcessReductionChain.Ledger.Tests.ps1` (`PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-SUBCHAIN-HOLDS`, `PRC-LEDGER-NO-EXCEPTIONS`) reverts every entry under `docs/engineering/process-reductions/` against the live tree. Stored patch `0010-early-dependent-starts.patch` has hunks in `extensions/drm-copilot/jest.config.cjs` (around the `epic-orchestrator-state-wave-barrier.ts` entry) and in both `pack-manifests/core.json` files (around the `enforce-epic-*` hook entries). Ledger entries 0001, 0002, 0003, 0006 and 0011 quote brief text; the `## MCP Surfaces Run the Installed Extension` bullets for concurrent checkpoints and light remediation are quoted in entries 0002 and 0003, while the docs-tools bullet is not quoted. Mitigation: append `coverageThreshold` entries after the final map entry, add skill paths in the `.claude/skills/` and `.agents/skills/` regions of the manifests, add any brief bullet after the docs-tools bullet, and have Phase 0 confirm every insertion point lies outside each `Current` fence and each patch hunk with its context, as #1050's `P0-T2` does.
- Spec rules without a failing test: every V-rule and item kind needs a named failing fixture; the "no model call" rule needs the text and capability tests of section 9; the "modifies nothing" rule needs a write-recording fake; the `not_checked` list needs a test that the skill and the tool emit the same strings.
- Acceptance conditions made unsatisfiable by earlier tasks: V3 and V4 depend on #1050's rendered caller; if #1050 changes the gate job name or the caller path, the passing fixture fails. Build the passing fixture from #1050's renderer output at test time, not from a copied string. The `integration-needed` writer depends on #1029's harness call order; Phase 0 confirms `pushDownHarness`, `PushDownReport` and `findCiWorkflowNameCollisions` by name and shape.
- Tool behavior rejecting syntax: the subset reader must accept everything in #1050's caller template (quoted `"epic/**"`, `${{ toJSON(needs) }}`, `run: |` blocks, `if: always()`); a test parses the real rendered caller. Do not use actionlint as a gate for destination fixtures, since actionlint rejects `job.workflow_repository` and `job.workflow_sha` (#1050 halt).
- Execution-environment brief: adding two MCP tools does not contradict any stated brief fact, but the brief's `## MCP Surfaces Run the Installed Extension` states which surfaces run the installed extension, and the validate rules reach destinations only after an extension release. Recommended: one bullet after the docs-tools bullet in every byte-identical brief copy (through the #1028 generator when present), naming both tools and the release lag. The preflight class "plan that alters a fact this brief states" then requires the brief task and a `Mirror parity` Pre-Mortem bullet naming it.
- Codex config pin: `.codex/config.toml` is pinned by `assert_full_drm_copilot_transport` (exact `enabled_tools` tuple and approved set) and becomes generator-owned after #1028; the change must go through the generator and the Python test is edited in place only.
- Shared-skill trap: under #1029, a shared skill needs a #1025 parity-matrix entry, or #1029's `shared.json` equality test fails.
- File size: `mcp-tools.ts` (473), `repo-automation-service.ts` (476) and `jest.config.cjs` (596, before #1029's and #1050's additions) are near the guidance tier; Phase 0 measures them after the upstream merges.
- Activation latency: MCP tools run the installed extension; destinations get both tools only after an extension and MCP package release (brief `## MCP Surfaces Run the Installed Extension`).
- Concurrency with siblings: #1050 edits `PD/push-down-harness.ts`, `mcp-push-down-schema-properties.ts` and the brief; this item runs in wave 5 after #1050 merges into the integration branch.

## 13. Testing Implications

- Jest only for new code, through normal parallel workers; no serial, single-process, shuffled or reversed runs; no local integration or golden suite. A focused run of one file is debugging only.
- Unit: subset reader (accept and reject cases, block scalars, flow sequences, comments, `${{ }}` opaque); ecosystem detection over in-memory listings; each item kind with a raising and a non-raising fixture; each V-rule with a pass and a fail fixture; item ordering and id stability; JSON rendering without timestamps or absolute paths; dry-run returns items without a write.
- Contract (read-only real tree): the rendered #1050 caller passes V1 and V3; the hook artifact paths in `validate-feature-review-coverage-metrics.ps1` equal V4's table; the tool-definition parity tests and `EXPECTED_DRM_COPILOT_TOOLS` agree with `REPO_AUTOMATION_TOOLS`.
- Fixtures: POSIX in-memory roots (no drive letters), CRLF built in code, no temporary files.
- Coverage: per new TypeScript file, line at least 85 and branch at least 75, from `extensions/drm-copilot/coverage/lcov.info`, compared with the `Phase 0 baseline` Jest run.
- The seeded integration scenario (push to a scratch destination with an existing `ci.yml`, run detect, resolve, validate) is CI-dependent or orchestrator-owned; locally it is represented by an in-memory end-to-end Jest case.

## 14. Open Questions with Recommended Defaults

- OQ-1 File format and location: JSON at `.push-down-integration-needed.json` in the destination root, committed like the manifest. Default: adopt.
- OQ-2 YAML parsing: owned subset reader with an explicit `yaml-unsupported` finding, no new dependency. Alternative needing owner approval: the `yaml` package. Default: subset reader.
- OQ-3 Tool names: `detect_push_down_integration` and `validate_push_down_integration`. Default: adopt.
- OQ-4 `ok` semantics: `ok: true` for any completed run, with `integration.verdict`; `ok: false` only for input or host errors. Default: adopt.
- OQ-5 Destination-owned modified files: a `modified` or `missing` manifest entry listed in `.push-down-exclusions` is reported as destination-owned and does not fail V5. Default: adopt.
- OQ-6 Symlink detection: not checked by validate (listed in `not_checked`); no new link-status seam. Default: adopt; revisit with #1049 OQ-7.
- OQ-7 Codex and Claude exposure: add both tools to `.codex/config.toml` `enabled_tools` with prompt approval (not added to the approved set) and to `repo-automation-adapter`; do not add them to `.claude/settings.json`. Default: adopt.
- OQ-8 Extension commands: no VS Code command for either tool (docs-tool precedent). Default: adopt.
- OQ-9 Skill placement: shared skill `push-down-integration` in pack `core`, with a parity-matrix entry. Default: adopt.
- OQ-10 Empty-item behavior: rewrite the file with `items: []` rather than delete. Default: adopt.
- OQ-11 Version-matrix reference values: read from the bundled `harness-<stem>.yml` copies (#1050 `CIB/workflows/`). Default: adopt; when #1050 is absent, the kind is not raised.

## 15. Facts Marked for the Orchestrator

- Merge state of #1029, #1049 and #1050 into `epic/shared-agent-harness-layer-integration` (`gh pr list`, `git merge-base --is-ancestor`).
- Whether any pull request merged after the 2026-11-14 refresh touches detect, validate or an integration file.
- The research file name stamp (header note).

## Pre-Mortem

- Review checklists: a reviewer could flag a tool without a failing test per rule, an untested "modifies nothing" claim, or an AC narrowed without record. Mitigation: the plan maps every item kind and V-rule to a named failing and passing Jest case, uses a write-recording fake, and records any narrowing in the spec.
- Coverage: a new TypeScript module without its own `coverageThreshold` entry is ungated because the map has no `global` key, and blanket mocks would make the per-file floor meaningless. Mitigation: one entry per new production file appended after the final map entry, in-memory fakes instead of module mocks, and a per-file comparison with the `Phase 0 baseline` Jest run.
- Mirror parity: the skill in every skill tree and bundle, both pack manifests (or `shared.json` plus the parity-matrix entry), the Codex config and its bundle copy, and the brief bullet in every byte-identical brief copy must move together. Mitigation: a dedicated brief-update task named here, the contract tests of the brief's `## Contract Tests That Pin Mirrored Files`, `test_brief_copies_are_byte_identical`, the Codex generator `--check`, and `ProcessReductionChain.Ledger.Tests.ps1` in the phase gate.
- File size: `mcp-tools.ts`, `repo-automation-service.ts` and `jest.config.cjs` are near the 500-line guidance tier and grow with #1029 and #1050. Mitigation: Phase 0 measures physical lines after the upstream merges, new logic goes into new modules, and edits to these files are limited to registration lines.
- Test isolation: shared module state or real-disk reads would break parallel Jest workers. Mitigation: pure modules with no module-level mutable state, a fresh in-memory fake per test, no temporary files, and gates run as one Jest run through its normal workers, re-run only after a fix.
- CI-only behavior: drive-letter fixture roots fail on Linux runners, committed CRLF fixtures are normalized by `* text=auto eol=lf`, and a real-tree read of a gitignored path passes only locally. Mitigation: POSIX roots such as `/dest`, CRLF built in code, and contract tests that read tracked files only.
- Evidence: counts taken from MCP summaries, absolute paths, or composed timestamps would fail review. Mitigation: Jest counts and per-file coverage from the run output and `lcov.info`, clock-read stamps, append-only artifacts under `<FEATURE>/evidence/<kind>/`, and scratch recorded as `SCRATCH`.
