# Upstream Contracts — Issue #1051 [P0-T1]

Timestamp: 2026-11-19T15-34
Command: Read and Grep over `extensions/drm-copilot/src/lib/push-down/`, `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/jest.push-down-coverage.json`, `extensions/drm-copilot/resources/`, `extensions/drm-copilot/test/`, `config/harness-parity-matrix.json`, `scripts/harness-generation/`
EXIT_CODE: 0
Output Summary: every required upstream symbol is present with the expected shape; Result: CONFIRMED.

Branch: `feature/push-down-integration-mcp-tools-and-skill-1051`, reset to `origin/epic/shared-agent-harness-layer-integration` (holds #1029, #1049, #1050).

## #1029 (spec and plan)

| Symbol | Defining file | Exported signature / shape | Status |
|---|---|---|---|
| `pushDownHarness` | `src/lib/push-down/push-down-harness.ts` | `pushDownHarness(options: PushDownHarnessOptions): PushDownHarnessResult`; result `{ report, summary, exclusions?, warnings }`; options include `extensionRoot`, `destinationRoot`, `fs`, `ecosystems`, `dryRun?`, `ciWorkflows?` | CONFIRMED |
| `PushDownReport` | `src/lib/push-down/push-down-report.ts` | `{ mode, ecosystems, files: PushDownReportFile[], counts }`; `files[].action: PushDownAction`; `CONFLICT_ACTIONS` = `conflict`, `unmanaged-conflict`, `deleted-locally` | CONFIRMED |
| `payload_version` (D6) | `src/lib/push-down/push-down-harness.ts` | `resolvePayloadVersion(fs, extensionRoot): string`; `UNKNOWN_PAYLOAD_VERSION` = `0.0.0` in `push-down-apply.ts` | CONFIRMED |
| `WriteIfChangedFileSystem` | `src/lib/push-down/push-down-write-if-changed.ts` | `class WriteIfChangedFileSystem implements PushDownFileSystem`; `constructor(inner, options?)`; `writtenPaths`, `skippedPaths` | CONFIRMED |
| Root-level path assertion | `src/lib/push-down/push-down-ecosystem-registry.ts` | `assertDestinationManifestOutsideLayers(layers)` calls `assertManifestPathIsRootLevel(DESTINATION_MANIFEST_RELATIVE_PATH, rootFolders)` and rejects a root file at that path; runs at module load and in the harness | CONFIRMED |
| MCP-result compatibility tests | `test/push-down-wrapper-compatibility.test.ts`, `test/lib/push-down/push-down-service-call.test.ts`, `test/mcp-tool-inputs.push-down-ci-workflows.test.ts` | assert `push_down_report` members (`mode`, `files`, `ecosystems`) rather than deep-equal of the whole report | CONFIRMED |
| MCP result mapping | `src/mcp-tools.ts` (`push_down_report: result.pushDownReport`) and `src/lib/push-down/push-down-service-call.ts` (`pushDownReport: result.report`) | the report object is passed through whole; no key enumeration | CONFIRMED |
| `coverageThreshold` entries | `jest.push-down-coverage.json` (spread into `jest.config.cjs`) | `./src/lib/push-down/push-down-harness.ts` and `./src/lib/push-down/push-down-ecosystem-registry.ts`, each `{ lines: 85, branches: 75 }` | CONFIRMED |
| Copilot manifests | `resources/customizations/pack-manifests/` | `core.json` (COPILOT-CORE), `csharp.json`, `powershell.json`, `python.json`, `typescript.json` | CONFIRMED |
| Jest full-bundle completeness test | `test/lib/push-down/push-down-bundle-manifest-completeness.test.ts` | present | CONFIRMED |
| Shared-layer test | `test/lib/push-down/push-down-shared-layer.test.ts` | present | CONFIRMED |

## #1049 (spec)

| Symbol | Defining file | Exported signature | Status |
|---|---|---|---|
| `DESTINATION_MANIFEST_RELATIVE_PATH` | `src/lib/push-down/push-down-destination-manifest.ts` | `= ".push-down-manifest.json"` | CONFIRMED |
| `parseDestinationManifest` | same | `parseDestinationManifest(text: string): DestinationManifest`; throws `DestinationManifestError` | CONFIRMED |
| `hashPayloadText` | same | `hashPayloadText(text: string): string` (SHA-256 of LF-normalized UTF-8) | CONFIRMED |

## #1050 (spec and plan)

| Symbol | Defining file | Exported signature / shape | Status |
|---|---|---|---|
| `findCiWorkflowNameCollisions` | `src/lib/push-down/push-down-ci-layer.ts` | `findCiWorkflowNameCollisions(fs, destinationRoot): string[]`, one `push-down conflict: workflow-name <relative path> (layer shared, pack core): ...` line per colliding file, as the #1050 plan task P2-T2 states; the relative path is the fourth space-separated token of each line | CONFIRMED |
| Caller renderer | `src/lib/push-down/push-down-ci-workflows.ts` | `renderCiCaller(input: CiCallerRenderInput): string`, modes `reference` and `copy`; template `ci-workflows/caller/drm-copilot-ci.template.yml`, fragments `ci-workflows/caller/jobs/<stem>.yml` | CONFIRMED |
| Data file | `resources/ci-workflows/ci-required-checks.json`, destination `CI_DATA_FILE_RELATIVE_PATH` = `.github/drm-copilot/ci-required-checks.json` | fields `schema_version` (`1.0.0`), `workflow` (`CI`), `workflow_file` (`.github/workflows/drm-copilot-ci.yml`), `required_contexts` (`["CI Required Gate"]`) | CONFIRMED |
| Bundled workflows | `resources/ci-workflows/workflows/harness-<stem>.yml` | stems `python`, `powershell`, `typescript`, `dotnet` (`CI_STEMS`); `ciWorkflowSource(stem)` | CONFIRMED |
| Pack-to-stem mapping (D4) | `src/lib/push-down/push-down-ci-workflows.ts` | `resolveCiPackJobs(selectionRecords): CiPackJob[]` maps `python`, `powershell`, `typescript` to their stems and `csharp`, `csharp-modern`, `csharp-legacy` to `dotnet`; `ciJobPackName(job)` in `push-down-ci-layer.ts` | CONFIRMED |

## #1025

| Item | File | Status |
|---|---|---|
| Parity matrix | `config/harness-parity-matrix.json` (`features[]` with `disposition` values including `shared`) and `config/harness-parity-matrix.schema.json` | CONFIRMED |

## PRESENT or ABSENT records

- #1029 `shared.json`: PRESENT (`extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/shared.json`).
- #1028 shared-source generator: PRESENT (`scripts/harness-generation/Invoke-HarnessGeneration.ps1`; its skill mirror `HarnessSkillMirror.psm1` renders only matrix entries of disposition `generated`, owner_child 3, whose `generated_from` lies under `.agents/skills/`).

Result: CONFIRMED
