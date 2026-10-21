# P8 transport preparation delta

Status: PREPARATION_READY, retaining the required upstream authority-schema correction. Read-only successor preparation; no P6-T1 acceptance, P8 implementation release, task checkoff, or host-limit claim.

Authority: persisted delegation `rendering_review_p8_transport_preparation_20261021T060200`, phase `S5_P8_transport_preparation_delta`, exact Atomic C3-elevated profile. Existing native launch authority rechecked (routing/launch/provenance true), SHA256 `f4016ebdabcd36d1e5aac5c6dde6e1ebdb558bec770792f5c188710d8c621bf5`; no new SubagentStart is claimed. Reused checkpoint `execution_progress.phase8_preparation`, plan P8-T1/T3/T6/T7/T8 and original runtime-publishing research. This delta adds only the remaining transport propagation detail.

## Exact available and missing routes

| Boundary | Verified current route | P8 handoff |
| --- | --- | --- |
| Incoming MCP request | Installed SDK 1.32.1 `shared/protocol.d.ts:173-207,389` supplies handler `extra.signal`, metadata and `sendNotification`. `protocol.js:342-358,399-424` creates the signal, invokes the handler and suppresses responses/notifications after cancellation. | P8-T6 must accept the second handler argument at `mcp-server.ts:91` and carry trusted execution context separately from caller JSON and authorization identity. |
| Cancellation and disconnect | `protocol.js:177-183` handles `notifications/cancelled`; `265-270` aborts all handlers on connection close. Neither terminates an application child. The exact pinned cancellation code returns for falsy request IDs, including numeric 0; do not claim notification cancellation for every legal ID. | Exercise ordinary request cancellation and disconnect through the real in-memory SDK seam; retain a numeric-zero request-ID control. Qualify that pinned-SDK edge before claiming universal cancellation; no SDK change is authorized here. |
| Dispatch and service | `mcp-tools.ts:174-178,306-343` carries only tool/input/service. Discovery handlers `15-68` forward only resolved input. Service contract `192-212` and implementation `443-484` have no execution-context argument; constructor options `90-105` offer output/filesystem/runner seams but no signal. | P8-T1/T6 owners agree one optional internal context in planned `discovery-service-types.ts`, propagated per request through discovery handlers/service extraction/adapters. Avoid global mutable cancellation state or serializing signals/functions into the fixed Python request. |
| Child lifetime | Retained finding: `command-runtime.ts:206-267` ignores stdin and aggregates output, with no timer/signal/termination cleanup; `repo-automation-execute-discovery.ts:222-258` cannot pass context. `DiscoveryServiceCallRequest:41-50` also lacks it. | P8-T1 owns the planned fixed installed-module runner in `discovery-runtime.ts`, JSON stdin and authoritative result parser. Add cancellation/deadline at that boundary with injected spawn and timer seams; preserve unrelated command-runner behavior. |
| Progress | SDK `protocol.js:675-684` adds a progress token when the outgoing caller requests progress. Incoming metadata is exposed as `extra._meta`; `types.js:608-636` defines `notifications/progress` with the caller token, numeric progress, optional total/message. Current `mcp-server.ts:105-112` uses a buffered output sink only. | P8-T6 may adapt typed runtime lifecycle events to `extra.sendNotification` only when a token exists (including token 0). Preserve token value; stop/clean up on completion, abort and send failure. Use observed stages, not invented percent completion or parsing human stdout. The single final structured result remains authoritative. |
| Extension and standalone | Both build entry points target this same `mcp-server.ts` (extension build line 28; standalone line 29). There is no separate standalone request handler to repair. | One shared request-context integration, with both bundle paths retaining the same implementation. Build scripts need no transport fork. |
| Direct VS Code commands | `discovery-command-registration.ts:26-39,105-143` can return when an input prompt is dismissed. Once the service call starts, no token or progress API is passed. | P8-T7 owns a VS Code cancellation-token-to-AbortSignal adapter and progress UI using the same internal context; dispose token subscriptions. Preserve noninteractive structured arguments and prompt cancellation, with no terminal creation. |

The existing SDK outgoing default 60 seconds, override and progress-reset-default-false findings remain qualified: `protocol.js:741-746` applies them to requests made by that SDK client, not a repository-owned incoming server deadline. Progress delivery alone does not extend a caller deadline; client configuration and any maximum total timeout still govern it. Actual VS Code, Codex and Claude host deadlines remain unverified.

Cancellation must not be reported as validation success or as proof of rollback. A child may have committed effects before termination. P8-T1 must settle exactly once, clean listeners/timers and prevent late child success from minting a successful result after abort. Bind the explicit operational timeout/termination policy at implementation; these observations do not select a numeric limit or authorize detached jobs.

## Minimal deterministic tests and ownership

- **P8-T1 runtime owner:** use the planned `test/discovery-runtime.test.ts` and `discovery-result.test.ts`; reuse the child-process mock pattern in `repo-automation-execute-discovery.test.ts:39-81` and `runtime-test-helpers.ts:15,115-147`. Add in-memory stdin, kill and event controls plus fake/injected timers. Cover pre-aborted input with zero spawn, abort/deadline after spawn, error/close/abort races, one settlement, cleanup after success/failure, retained stderr and no success from malformed/late output. Existing fixed-module/stdin/result-exit tests remain required.
- **P8-T6 MCP/service owner:** extend `mcp-server.discovery.test.ts:58-78` (injected service and linked `InMemoryTransport`, already closed after each test). Capture the exact request context in a deferred service stub; cancel a pending `client.callTool` with its request option signal, disconnect, and verify downstream abortion. Test progress absent/present/token 0, request isolation, no post-completion notifications and notification failure handling. Use fake clocks for client-timeout/child-deadline ordering; no wall-clock assertions. Include the numeric-zero cancellation limitation in the finite pinned-SDK qualification rather than hiding it behind a mocked handler.
- **P8-T7 VS Code owner:** extend the existing `extension.discovery-commands.test.ts` command mock seam with fake `withProgress`/token callbacks and disposables; verify prompt-dismissal causes no service call, in-flight cancellation reaches the shared context, and direct invocation remains noninteractive.
- **Coordinator:** register `mcp-server.ts` and `mcp-server.discovery.test.ts` as the exact supplemental P8-T6 integration callers before implementation; retain the already recorded `mcp-server.test.ts:104` discovery-tool enumeration. Keep runtime, MCP/service and VS Code ownership disjoint. No added phase or independent outcome is proposed.

## Timing observations only

Pinned continuation receipt: `evidence/qa-gates/p6t1-installed-native-report-continuation.2026-10-21T05-49.json`, SHA256 `81b554702d3e9c754dc13114f042cc17182a3148fe8486529acb876ae00f629a`.

| Operation | Observed seconds | Qualification |
| --- | ---: | --- |
| init-real | 91.947 | Earlier package setup, retained historical carry; not rerun on the continuation package. |
| parity refresh | 97.461 | Same-package continuation `result.results` / `parity-refresh`. |
| completion publish | 97.357 | Same-package continuation `report-publish`. |
| report dry-run | 29.110 | Same-package continuation `report-dry`. |
| report repeat | 45.979 | Same-package continuation `report-repeat`. |

These individual native-operation observations are separate from previously reported coverage-instrumented 160–240 second workloads, aggregate harness durations and unknown actual host deadlines. No timing-only replay or performance acceptance is implied.

## Retained prerequisite and finite release boundary

Before P8-T3 acceptance, the upstream schema owner must preserve the strict analyst branch while adding authenticated native-root request identity, exact tool/operation binding and honest absent-profile bootstrap binding. Existing tool authorization requires specialist invocation/start context; service-request requires an existing profile hash. Missing authorization cannot become a root fallback; fabricated invocation/hash values cannot represent first initialization. Retain exact fixtures/tests/generated catalog-resource correction and independent verification. This is the previously agreed implementation prerequisite, not new schema-edit authorization.

Preparation is complete. Implementation remains unreleased; actual-host probing belongs to P8-T8 after required generated assets exist. No tests, builds, network requests, process/host probes, source/config/checkpoint/index edits or staging occurred. Read-only command diagnostics (PowerShell brace expansion and default-console Unicode output) were corrected by explicit literal paths and UTF-8 output; they are not product failures.

## Pinned working-byte references

Paths are repository-relative. SDK paths identify the locally installed 1.32.1 dependency, not a tracked source change. The standalone installed CJS protocol bytes equal the extension copy.

| Path | SHA256 |
| --- | --- |
| `extensions/drm-copilot/src/mcp-server.ts` | `1cd89097776209a4de65b1874a94bd8b7417145b3e537c5a4c022b58bb3b9638` |
| `extensions/drm-copilot/src/mcp-tools.ts` | `70035960ca1503cd842dfaa8ce3e31050e614ad91fd584672c36c0e6f02077c6` |
| `extensions/drm-copilot/src/mcp-handlers/discovery-handlers.ts` | `2835b726faaa6aa1d63e9c6ca996d86afb3a0f3e93dd02b2b6b797be562b7725` |
| `extensions/drm-copilot/src/repo-automation-service.ts` | `8caaebfe95250645ac989f50f87564c94506f83a67ab9626983a1cc80a38838e` |
| `extensions/drm-copilot/src/repo-automation-service-contract.ts` | `d2dbb00214bb305962d3f4a623ab83e20707988efa805bdb1edc2a9a4e4bea8d` |
| `extensions/drm-copilot/src/command-runtime.ts` | `195679cec172409f20cbc51b7b399d1f7f045fcb19edc47f3d6fe2e747c78831` |
| `extensions/drm-copilot/src/repo-automation-execute-discovery.ts` | `e57e4da3e214ad9ff79559be10a55469b6391fe61c6d2fff493011442af34034` |
| `extensions/drm-copilot/src/discovery-command-registration.ts` | `f67b7587483027cbf40b7b60e839dd591233823d27bfcd9e8a4ef38aeb5d7a39` |
| `extensions/drm-copilot/test/runtime-test-helpers.ts` | `fe214785ead1c71d7a2afe826d1fd8e3143766505c1d09eb7987341d985a3e69` |
| `extensions/drm-copilot/test/repo-automation-execute-discovery.test.ts` | `5d083e7093fc0d24708f7eb0db7a214f18fba76efc6a322ee9169591e5b8cccb` |
| `extensions/drm-copilot/test/mcp-server.discovery.test.ts` | `4b451d2d4d6d32b405fe7ed4eb182e79aceb69dacae9345c8729df445ec72ded` |
| `extensions/drm-copilot/test/extension.discovery-commands.test.ts` | `de4ad04fbc8c199aa2a8f94912b4ca82bfe7eb2d7c037105d613c03541a54a43` |
| `extensions/drm-copilot/esbuild-mcp-server.cjs` | `839a35880d08c4b7812d5ce47cf6949732b876b6f7616d963af906523596e56b` |
| `packages/mcp-server/esbuild-mcp-server.cjs` | `296f29cf983951e602f07ad4e9667434e689136ed19a53632dffefdcd68f8b34` |
| `extensions/drm-copilot/package-lock.json` | `2eedd089e1fa61d2d4a731fea74322184f654c29835348004e5e578b06112c94` |
| `packages/mcp-server/package-lock.json` | `7f362be7ed2367755d68baff6f4accd7b968dd67cb930f7487188cf2c0a97a4d` |
| `extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/dist/cjs/shared/protocol.js` | `15da6abd6aa14b1b4a3334a6c50f63445fd840ab35fede19a69698040cb85e35` |
| `extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/dist/cjs/shared/protocol.d.ts` | `96b4b92af72b0c0b617bfe6fe18bd0016bf28c3363bf6113d69719d48ded6d50` |
| `extensions/drm-copilot/node_modules/@modelcontextprotocol/sdk/dist/cjs/types.js` | `2995d96aaf118ae001a6c673ff386bb7edb97b2ed7f3214549ba005b4a6c99be` |
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md` | `af8e7eac89a20d084d954a9fdc3bd6d2296a97f2b5f1af2c2cfc06b5aff69b85` |
| `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/research/2026-10-18T02-40-runtime-publishing-research.md` | `885ae26b069800182958d91061d96ec685d7b30f572d2055dd5e86992f3eae2c` |

Current preparation phase: P8. Upcoming planned tasks: P8-T1, P8-T2, P8-T3, P8-T4, P8-T5; all remain unchecked.
