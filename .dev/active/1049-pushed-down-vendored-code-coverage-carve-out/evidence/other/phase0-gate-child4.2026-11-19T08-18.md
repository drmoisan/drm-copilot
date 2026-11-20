# Phase 0 Gate (a) - Child 4 (#1029) - [P0-T1]

Timestamp: 2026-11-19T08-18
Command: git fetch origin epic/shared-agent-harness-layer-integration; git rev-parse HEAD origin/epic/shared-agent-harness-layer-integration; Grep `^export ` over extensions/drm-copilot/src/lib/push-down/push-down-{destination-manifest,apply,pipeline}.ts; Read of push-down-destination-manifest.ts, push-down-pipeline.ts, push-down-apply.test.ts; Grep of headings in docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md
EXIT_CODE: 0
Output Summary: HEAD and origin/epic/shared-agent-harness-layer-integration resolve to the same commit, so each check below holds for both refs. One symbol ABSENT (DestinationManifestEntry); every other symbol and heading PRESENT; both behavior checks CONFORMS. Result: MISMATCH (1).

## Refs

- HEAD: integration branch tip (same commit as origin/epic/shared-agent-harness-layer-integration).
- BASE (merge base of origin/epic/shared-agent-harness-layer-integration and HEAD): equal to HEAD.

## Symbols (both refs; identical commit)

| File | Symbol | HEAD | integration |
| --- | --- | --- | --- |
| PD/push-down-destination-manifest.ts | DESTINATION_MANIFEST_RELATIVE_PATH | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | DESTINATION_MANIFEST_SCHEMA_VERSION | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | DestinationManifest | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | DestinationManifestEntry | ABSENT | ABSENT |
| PD/push-down-destination-manifest.ts | hashPayloadText | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | parseDestinationManifest | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | readDestinationManifest | PRESENT | PRESENT |
| PD/push-down-destination-manifest.ts | renderDestinationManifest | PRESENT | PRESENT |
| PD/push-down-apply.ts | applyPushDownPlan | PRESENT | PRESENT |
| PD/push-down-pipeline.ts | runPushDownPipeline | PRESENT | PRESENT |
| PDT/push-down-apply.test.ts | (file) | PRESENT | PRESENT |
| child 4 spec | `### Destination Manifest` | PRESENT | PRESENT |
| child 4 spec | `### Decision Table` | PRESENT | PRESENT |

Observation for DestinationManifestEntry: the module exports the per-file entry interface under the name `DestinationManifestFileEntry` (fields `layer`, `pack`, `sha256`). No export named `DestinationManifestEntry` exists. Per the [P0-T1] acceptance, an ABSENT symbol is a mismatch; no substitute was adopted.

Child 4 spec location: `docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/spec.md`.

## Behavior checks

- hashPayloadText: CONFORMS. `normalizeLineEndings` replaces CRLF with LF, then lone CR with LF; the hash is SHA-256 of the UTF-8 encoding (`update(text, "utf8")`); no BOM stripping (U+FEFF is encoded as EF BB BF).
- parseDestinationManifest: CONFORMS. `parseSchemaVersion` rejects a non-semver value and a major other than 1; `describeInvalidRelativePath` rejects a leading `/` (covers `//` UNC), a drive letter, any backslash (covers `\\` UNC), and a `..` segment. Unknown top-level and per-file keys are not rejected (they are ignored and not carried into the returned object). The parser also requires `payload_version` (non-empty string), `selection` (object keyed by ecosystem name) and per-file `layer` and `pack`.

## Helpers and call shape

- In-memory helpers (`PDT/push-down.test-helpers.ts`): `buildInMemoryFileSystem(files, dirs?)`, `fixedClock(iso)`, type `InMemoryPushDownFileSystem` (with `writtenPaths`, `readTextFile`, `isFile`).
- Layer helpers (`PDT/push-down-pipeline.test-helpers.ts`): `makeTestLayer(base, "codex")`, `LineUnionFileSystem`.
- Seed pattern in `push-down-apply.test.ts`: `decisionTableFs()` seeds `/src/codex/.x/*` payloads, `/dest/.x/*` destination files and `/dest/.push-down-manifest.json` rendered by `previous(files, selection)`.
- Call shape: `runPushDownPipeline({ repoRoot: "/src", destinationRoot: "/dest", fs, buildLayers: () => layers(fs), overwriteUnmanaged, clock })` returns a plan only (it writes nothing); then `applyPushDownPlan(planned, { payloadVersion, artifactRoot: "/dest", clock })` performs the writes. The plan's [P1-T3] parenthetical that the pipeline applies unless `dryRun` does not match: `runPushDownPipeline` never applies; the apply step is the separate `applyPushDownPlan` call.
