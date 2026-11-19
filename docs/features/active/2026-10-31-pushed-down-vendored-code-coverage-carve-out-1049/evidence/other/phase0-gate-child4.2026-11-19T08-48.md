# Phase 0 Gate (a) - Child 4 (#1029) - [P0-T1] (re-run, plan revision 2.1)

Timestamp: 2026-11-19T08-48
Command: git fetch origin epic/shared-agent-harness-layer-integration; git rev-parse HEAD origin/epic/shared-agent-harness-layer-integration; git diff --stat origin/epic/shared-agent-harness-layer-integration HEAD; Grep `^export ` over extensions/drm-copilot/src/lib/push-down/push-down-{destination-manifest,apply,pipeline}.ts; Read of push-down-destination-manifest.ts (normalizeLineEndings, hashPayloadText, describeInvalidRelativePath, parseDestinationManifest); Grep of exported helpers under extensions/drm-copilot/test/lib/push-down/*helpers.ts; Grep of headings in the child 4 spec
EXIT_CODE: 0
Output Summary: Every symbol and heading PRESENT on both refs; both behavior checks CONFORMS; no mismatch.

## Refs

- HEAD is the integration tip plus three plan and evidence commits; `git diff --stat origin/epic/shared-agent-harness-layer-integration HEAD` lists only files under this feature folder, so every source and test file checked below is identical on both refs.

## Symbols

| File | Symbol | HEAD | integration |
| --- | --- | --- | --- |
| PD/push-down-destination-manifest.ts | DESTINATION_MANIFEST_RELATIVE_PATH | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | DESTINATION_MANIFEST_SCHEMA_VERSION | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | DestinationManifest | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | DestinationManifestFileEntry | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | hashPayloadText | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | parseDestinationManifest | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | readDestinationManifest | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | renderDestinationManifest | PRESENT | PRESENT |
| PD/push-down-apply.ts | applyPushDownPlan | PRESENT | PRESENT |
| PD/push-down-pipeline.ts | runPushDownPipeline | PRESENT | PRESENT |
| PDT/push-down-apply.test.ts | (file) | PRESENT | PRESENT |
| child 4 spec | `### Destination Manifest` | PRESENT | PRESENT |
| child 4 spec | `### Decision Table` | PRESENT | PRESENT |

## Behavior checks

- hashPayloadText: CONFORMS. `normalizeLineEndings` replaces CRLF with LF, then lone CR with LF; SHA-256 over `update(text, "utf8")`; no BOM stripping.
- parseDestinationManifest: CONFORMS. `parseSchemaVersion` rejects a non-semver value and a major other than 1; `describeInvalidRelativePath` rejects a leading `/` (covers `//` UNC), a drive letter, any backslash (covers `\\` UNC) and a `..` segment; unknown top-level and per-file keys are ignored (not rejected, not carried).

## Helpers and call shape

- `PDT/push-down.test-helpers.ts`: `buildInMemoryFileSystem`, `fixedClock`, class `InMemoryPushDownFileSystem`.
- `PDT/push-down-pipeline.test-helpers.ts`: `makeTestLayer`, `LineUnionFileSystem`, `seedSharedLayerManifest`, `seedThreeBundles`, `snapshotTree`.
- Call shape: `runPushDownPipeline({ repoRoot, destinationRoot, fs, buildLayers, overwriteUnmanaged, clock })` plans only; `applyPushDownPlan(planned, { payloadVersion, artifactRoot, clock })` performs the writes, including `.push-down-manifest.json`.

Result: no mismatch.
