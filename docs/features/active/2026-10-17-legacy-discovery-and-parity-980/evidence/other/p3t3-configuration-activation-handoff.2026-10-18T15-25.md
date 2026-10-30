# P3-T3 configuration and activation handoff

Timestamp: 2026-10-18T15-25
Status: TASK_READY_FOR_VERIFICATION; source/test bytes frozen. Independent executor acceptance and coordinator task commit remain required before P3-T4.
Acceptance baseline: `639c37269ed12b0bd4b5d74d66723e2f5ce4dedd`. Checked WIP: `e0f5b74fd0217ea266db2675ec0ec919f73084db`. Bounded binary prerequisite fix: `3b8e3045e980961bab415ddbee92e55fdb436a36`.

## Delivered behavior and interfaces

- `configuration.py` defines inert immutable activation/selection/request/result values, canonical locator bytes and pure `select_configuration(...)`. Accepted profile/parser/path validation rejects ambiguity, selector/locator disagreement, malformed or stale active inputs. A default profile requires explicit activation; an unrelated workspace remains inactive. A protected deactivation tombstone overrides leftover files only for implicit checks.
- `ActivationStore.select(...)` reads the protected record twice, including the inactive fast path, and binds profile/locator/candidate bytes and parent identities. Deleting active configuration cannot silently disable the gate.
- `ActivationStore.configure(ConfigurationRequest(...))` authenticates the injected root context, validates the full proposed configuration, rechecks candidates and physical parents under the shared guard, invalidates prior grants, records the transition, and publishes exact profile/locator outputs. Protected activation intent is written before workspace publication so partial failures retain an active blocking state. Postpublication checks compare candidates with actual projected bytes. Deactivation records the next generation and predecessor digest. Dry-run performs no registry, directory, locator, profile or revocation writes.
- `RegistryLocation.for_host(...)` derives external workspace-specific state from canonical trusted Windows LocalAppData, macOS Application Support or Linux XDG state/home fallback. `NativeRegistry` retains native parent handles, uses exclusive shared guarding and exact-original comparison, and preserves explicit errors. `ActivationStore.local(...)` supplies the accepted local native primitives; requests/profile/locator bytes never provide a registry path, root role, invocation identity or grant authority.
- The authorized prior correction adds `getattr(os, "O_BINARY", 0)` to both `NativeDirectory.read` and `stage`. Eight new memory cases cover exact flags plus LF, CRLF, Ctrl-Z/mixed bytes, including absent-constant fallback. No dependency or schema changed.

The trusted host remains responsible for canonical context, callback authorization, protected grant/receipt invalidation and permitted native routes. The guarantee is cooperative serialization, optimistic freshness, exclusive create and per-file atomic replacement. It does not promise kernel digest-CAS or a multi-file transaction against guard-bypassing writers.

## Exact scope and staged-byte binding

| Path | Working-byte SHA-256 | Physical lines |
| --- | --- | --- |
| `packages/discovery-runtime/src/drm_copilot_discovery/configuration.py` | `0193463923026c5c06d4154b6854a9445682e3a05f372a81f2859b422494d3d2` | 310 |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py` | `dff3a775e99185523bfcae2de63d5eae70a1f397d221899944f28f87789c2bfa` | 453 |
| `packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py` | `e597f46b02e938afe9de51bab42081a66d9b1d277b4458f8ff22ece7bd3f0746` | 179 |
| `packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py` | `790613abf92e1355d14332d52cae3d125a5d139e093cfea0d25cae04eb36b164` | 436 |
| `tests/discovery_runtime/test_configuration.py` | `e4d9c7549e8868e209c3df8df9e35fa77bc92a3330ec3f9c44be9a02f3acf425` | 330 |
| `tests/discovery_runtime/test_activation_store.py` | `8cc5f600177fa2ae5d3e51c3250e265780d41074bd521b9250f7f9a698ab58cd` | 465 |
| `tests/discovery_runtime/test_activation_filesystem.py` | `3d1ade9a26bba3755b7399922937c8ec7f35c06b46e033be1636fe2379f7a134` | 313 |
| `tests/discovery_runtime/test_mutation_filesystem.py` | `582a880ea65afadaa103c147da82b4bc0e6ab9f2f79d44e71152583b31ce9e29` | 484 |

`docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-final-audit.2026-10-18T15-24.json` contains index blob/SHA identities and permitted checkout newline normalization. All eight scoped paths match the index. All 238 unaffected accepted prior paths and 24 frozen v1/export paths are unchanged. Only the two explicitly authorized provider paths differ from the 240-path prior union. No new suppressions or missing intent docstrings were found. The zero-context staged review patch is `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t3-scoped-patch.2026-10-18T15-25.md`.

## Baseline and final checks

Baseline Ruff and full Pyright were clean; 51 profile-dimension tests passed. Existing activation models measured 28/28 lines and 4/4 arcs. The three new task modules were absent at the task baseline. The provider's accepted baseline was 207/209 lines and 51/54 arcs. The baseline receipt index is `evidence/baseline/p3t3-baseline-index.2026-10-18T14-48.json`.

The final stable pass completed formatting, Ruff, full Pyright, current-module architecture inspection plus six existing architecture cases, 134 forward unit cases, 134 reversed cases, 385 compatibility/contracts, and native integration in that order. Forward elapsed 42.93 seconds; reverse 20.21 seconds; contracts 30.73 seconds. No lint/type/test regression occurred. The provider retains its exact accepted numeric coverage; every changed read/stage line is exercised. No unit test creates temporary files or invokes processes/network.

| Module | Covered executable lines | Covered branch arcs |
| --- | --- | --- |
| `activation_filesystem.py` | 102/102 | 30/30 |
| `activation_store.py` | 162/162 | 58/58 |
| `configuration.py` | 123/123 | 48/48 |
| `mutation_filesystem.py` | 207/209 | 51/54 |

Total: 594/596 executable lines and 187/190 arcs. All 35 new callable/class ranges are 100%; all 65 measured ranges are at least 94.117647%. Raw current coverage: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-final-raw-coverage.2026-10-18T15-24.json`. Exact AST ranges: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-pass2-coverage-audit.2026-10-18T15-16.json`. Forward/reverse before/after hashes: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-final-test-bindings.2026-10-18T15-24.json`. Numeric provider coverage delta is zero.

Ordered command receipts, including retained exact commands/exits/output:

- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-architecture.2026-10-18T15-15.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-contracts.2026-10-18T15-18.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-coverage-check.2026-10-18T15-16.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-format.2026-10-18T15-15.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-integration-activation.2026-10-18T15-18.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-integration-initialization.2026-10-18T15-23.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-lint.2026-10-18T15-15.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-reverse.2026-10-18T15-17.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-tests.2026-10-18T15-16.md`
- `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-pass2-types.2026-10-18T15-15.md`

## Native byte fidelity and preserved failures

The initial Windows activation operation returned success while the physical file gained a CRLF byte. A separate read-only diagnosis proved CRT text translation on both descriptor routes. Those failed receipts remain retained; the original Windows mutation/initialization exact-byte claims are historical and are not retroactively treated as passing evidence.

The corrected provider's independent physical binary-read proof passed 17 checks in 0.077 seconds: exact bytes/SHA after exclusive creation and digest replacement for LF, CRLF, Ctrl-Z and mixed content, stale/collision preservation and cleanup. `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-windows-binary-prerequisite.2026-10-18T15-14.json` records the binding; this was the required narrow pre-gate diagnostic, not an additional full task run.

Final Windows activation integration passed 12 checks, including registry persistence across services, root-only transitions, missing locator repair, dry-run no effects, exact physical profile replacement, stale/concurrent rejection and handle cleanup. First activation was 0.324 seconds; replacement was 0.330 seconds. Evidence: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-windows-activation.2026-10-18T15-18.json`.

The bounded combined initialization reproof passed five checks and independently compared all six projected files, including parity, with physical rb bytes and returned output SHA-256 values. It also checked configured directories, revocation and handle cleanup. Evidence: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t3-windows-initialization-byte-reproof.2026-10-18T15-23.json`. Uninstrumented plan time was 5.058 seconds and commit time 70.772 seconds, total 75.837 seconds. This normal initialization latency remains a review limitation; no optimization or repeated covered initialization run was added.

Two reviewed race defects (tombstone reread and in-guard candidate freshness) and the direct postpublication candidate regression are corrected. The retained final independent eight-case proof is `evidence/regression-testing/p3t3-executor-boundaries-final.2026-10-18T15-03.json`; its three task-production hashes remain unchanged. Historical failed/incomplete receipts remain included in the evidence inventory.

## Remaining integration obligations

No later task is implemented or released. P6 owns trusted service/context wiring; native host permitted-route enforcement and the full installed CLI/host proof remain later integration work. P11 retains the exhaustive property/mutation inventory. Actual OS proof here is Windows; platform-location and injected native-seam cases cover the other supported path models without claiming a Linux/macOS native run.
