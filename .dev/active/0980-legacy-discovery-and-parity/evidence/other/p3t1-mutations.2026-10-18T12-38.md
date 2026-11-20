# P3-T1 mutation planning and guarded commit handoff

Timestamp: 2026-10-18T12-38
Status: TASK_READY_FOR_VERIFICATION; independent executor acceptance and coordinator commit remain required.
Plan: `../../plan.2026-10-17T22-38.md`, P3-T1 only. P3-T2 is not released.

## Scope

The four original paths and three coordinator-authorized size splits implement one mutation component. The provider and its tests were approved before creation; shared test support adds no production ownership. Every file remains below 500 physical lines.

- `packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py` — 436 physical lines; SHA-256 `db2aca8bf68f64333b509ca12cbe8445d1a0dadc0532064d93581acb1afb422c`; Git blob `198a767936b5a960505b80e74f93c860fc644642`.
- `packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py` — 418 physical lines; SHA-256 `7a0cc867f3ff62760bab97c290207e11744f50f37e9ae9c41bfd5115bb3b9015`; Git blob `0ca4ad457491f0cdb6896a8fa7f46a5677f37fbf`.
- `packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py` — 386 physical lines; SHA-256 `f0b02a3f2d685fbf69681e37e89786ec8e1a1991ee10a8447bd25a60ca6efc1c`; Git blob `9f4f634cc22444edd28ac23256c59a547fe30088`.
- `tests/discovery_runtime/mutation_test_support.py` — 294 physical lines; SHA-256 `cb930ce0a8ce731a475dedc2e79b6e16a390f61cb28225984af836c6f9f828b2`; Git blob `322118bba523350bccd006ae46e66acc756bb14e`.
- `tests/discovery_runtime/test_mutation_commit.py` — 332 physical lines; SHA-256 `31c0dff2382bbbf563f1b63c96a24e505b6cc9cd2e33c379a5034b82a1249c42`; Git blob `39c6aa14c2e4ee08cab40ebb25d927688f2c21ad`.
- `tests/discovery_runtime/test_mutation_filesystem.py` — 426 physical lines; SHA-256 `5f57206cb69c35e39cff7a0c5f4b57f71b200c1a66ed678df4a3a69dad12f5ba`; Git blob `ccb5aaa1b633b10091469019f74ca5cf86535ef7`.
- `tests/discovery_runtime/test_mutation_plan.py` — 453 physical lines; SHA-256 `c168c8ce947dbd34b04e02b96fe73dfd043351d92cd376646c29fc9c8ddc3fbd`; Git blob `b160f59fd8188db6f5df81b1468666405b1a9b4e`.

The source and tests are frozen. Exact staged scope is relative to task-entry commit `58e5001c5907d74ee24f205690d891b4352fda23` so the user-requested intermediate WIP commits do not hide any task-owned change. The coordinator owns staging, task checkoff and commits.

## Baseline

Phase 0 recorded zero Ruff and Pyright diagnostics, 7,336 passed and six existing skips, 94.111715% line coverage and 88.783742% branch coverage. See `../baseline/python-lint.2026-10-18T03-49.md`, `python-types.2026-10-18T03-49.md`, `python-tests.2026-10-18T03-51.md`, and `python-coverage-metrics.2026-10-18T03-51.json` in the same baseline directory. The three new production modules had zero baseline statements. Full repository final test/coverage QA remains Phase 11; this handoff reports the approved atomic-task checks without claiming that broader gate has run.

The exact prior-path audit preserves 209 accepted paths and all 24 frozen v1/export paths. Two explicit accepted prerequisite corrections are bound separately by `../regression-testing/p3t1-executor-report-root-checks.2026-10-18T11-37.json`: `validation_inputs.py` SHA `147b363fbf5f1041ce79dc40e3b9c10d1ba3aab41be007a9b06cce8df8b4cda2`, and `test_validation_modes.py` SHA `ce23a61febdf5a085a515cd350296ed86b7decef00ffac631d6d381897fdfaed`. They exclude the exact absent reports root from the report-input digest and do not expand this worker's ownership.

## Plan and interfaces

`capture_workspace(...)` uses the accepted complete snapshot loader with injected metadata/bytes/repository readers. It normalizes child ordering and captures stable identities. `MutationChange` binds immutable whole-document bytes, exact kind/ID/path and the original `expected_sha256`; null requires absence. `plan_mutation(baseline, changes, *, grants, invocation=None)` validates exact grants, original preconditions and a complete prospective graph before returning an immutable `MutationPlan`. It reuses the accepted `PathPolicy`, catalog, snapshot loader and validator. Parsed structured identity remains authoritative even if the request claims opaque payload; report Markdown shares its JSON peer's exact identity.

Root/local planning uses structural mode. Authenticated role output uses the accepted `agent-output` mode and `InvocationContext`; the latter never grants native authority. `output_valid` stays distinct from `validation_result`, so an honestly failing review may be valid output. Full snapshot digests remain distinct from report/control-excluding report-input digests. Resolved target policy does not close a separately open legacy observation.

`commit_mutation(plan, *, writer, dry_run=False)` reconstructs the plan, rechecks all input hashes/pins/identities and applies deterministic writes. Repeated dry runs and unchanged bytes do not mutate the workspace or revoke authority. Unauthorized or invalid prospective content raises before mutation. On an operational race or partial error, prior successful outputs remain explicit, the attempted output and possible new parents are reported as uncertain, and completion authority is invalidated (or the invalidation failure is reported). No rollback overwrites concurrent work, and no successful result mints completion authority.

`GuardedMutationWriter` owns full-state checking, path revalidation, exclusive-create/digest-replacement selection and postcapture checks inside one guard. `LocalMutationPrimitives(workspace_root=..., lock_path=..., document_bytes=...)` supplies the actual platform operations; the service only wires it. All authorized writers must receive the same trusted canonical external lock path whose parent root has provisioned. Capture uses this provider's metadata/read functions for matching native identities, and the configured profile's document-byte bound must be passed (supported finite maximum 64 MiB). Native host policy separately authenticates exact grants/invocation and denies unauthorized alternate mutation routes; client data cannot choose a primitive provider or lock path.

Linux uses retained directory descriptors and non-following component operations. Windows pins each checked path with `CreateFileW` access `0x81` (read/list plus attributes), share `3` (no delete sharing), `OPEN_EXISTING`, `BACKUP_SEMANTICS` and `OPEN_REPARSE_POINT`, and compares the opened handle identity with the expected stamp. Root and parent anchors remain held through postcapture. Staging is exclusive; short/zero writes, fsync failures, owned-stage cleanup and foreign collisions are explicit. New files publish exclusively; replacement compares original bytes under the cooperative guard before atomic individual replacement.

The guarantee is cooperative serialization, optimistic complete-state freshness, retained verified parents, exclusive creation and per-file atomic replacement. It is not kernel digest-CAS or a multi-file transaction against processes that bypass the authorized guard. Detected unrelated changes fail. Stale external locks fail closed rather than being stolen. Linux CI and full installed host/CLI proof remain later integration responsibilities; this Windows host proof is bounded operational evidence for the concrete provider.

## Diffs

The complete seven-path task patch is [p3t1-scoped-diff.2026-10-18T12-38.patch](p3t1-scoped-diff.2026-10-18T12-38.patch). No plan, acceptance criterion, checkpoint, prior production module or unrelated test was edited by this worker. Set C initialization assertion dispositions remain P3-T2 ownership.

## QA Gate Results

The accepted single pass preserves format, lint, types, architecture, unit/property, contract/schema and integration order. Formatting leaves all seven files unchanged; scoped Ruff has zero findings; full Pyright has zero errors/warnings. The existing six-case package architecture harness passes; it covers the extraction boundaries and is not represented as a new architecture harness for all three mutation modules. Unit tests use fresh in-memory stores and injected native seams, with no temporary files, processes or network.

Focused units: 89 passed. Reversed file order: 89 passed. New module/class/callable line coverage minimum: 93.75%. No task test failure or lint/type regression remains. Numeric ranges and the exact source/staged bindings are in [p3t1-coverage-metrics.2026-10-18T12-38.json](../regression-testing/p3t1-coverage-metrics.2026-10-18T12-38.json). Raw coverage is `../regression-testing/p3t1-coverage.2026-10-18T12-38.json`.

| Production module | Lines | Branch arcs |
| --- | --- | --- |
| mutation_filesystem.py | 207/209 (99.04%) | 51/54 (94.44%) |
| mutation_io.py | 130/131 (99.24%) | 31/32 (96.88%) |
| mutation_plan.py | 147/149 (98.66%) | 53/56 (94.64%) |

Ordered command receipts (each retains its own actual command, exit and output):

1. [p3t1-format-pass13.2026-10-18T12-26](../regression-testing/p3t1-format-pass13.2026-10-18T12-26.md)
2. [p3t1-lint-pass13.2026-10-18T12-26](../regression-testing/p3t1-lint-pass13.2026-10-18T12-26.md)
3. [p3t1-types-pass13.2026-10-18T12-26](../regression-testing/p3t1-types-pass13.2026-10-18T12-26.md)
4. [p3t1-architecture-pass13.2026-10-18T12-27](../regression-testing/p3t1-architecture-pass13.2026-10-18T12-27.md)
5. [p3t1-tests-pass13.2026-10-18T12-36](../regression-testing/p3t1-tests-pass13.2026-10-18T12-36.md)
6. [p3t1-reverse-pass13.2026-10-18T12-32](../regression-testing/p3t1-reverse-pass13.2026-10-18T12-32.md)
7. [p3t1-contract-pass13.2026-10-18T12-37](../regression-testing/p3t1-contract-pass13.2026-10-18T12-37.md)
8. [p3t1-windows-final-pass13.2026-10-18T12-37](../regression-testing/p3t1-windows-final-pass13.2026-10-18T12-37.md)

Final Windows operational proof: [p3t1-windows-provider-smoke.2026-10-18T12-37.json](../regression-testing/p3t1-windows-provider-smoke.2026-10-18T12-37.json), six checks passed: exclusive create/retained parent, digest replacement, stale rejection, collision rejection, authorized concurrent exclusion, and final handle/stage cleanup. It writes only a session-unique operational SCRATCH subdirectory; it is not a unit test or the broader installed CLI proof.

## Preserved review and failure history

Initial exact-grant/child-order/report-view/provider ownership findings remain in `p3t1-executor-review.2026-10-18T11-13.json`; stage ownership, opened-parent identity and configured-read-bound probes remain in `p3t1-executor-provider-probes.2026-10-18T11-20.json`. The stable 42-case plan/I/O proof was completed before the Windows correction and retained with that provenance; the executor separately bound corrected-provider probes. This handoff does not relabel pre-correction results as current native proof.

The original real Windows smoke failure at `p3t1-windows-provider-smoke.2026-10-18T11-39.json` remains. The attrs-only `0x80` access mask allowed parent relocation; the isolated `0x81` correction makes read/list access participate in Windows sharing checks. Pause cleanup and the native access A/B investigation are retained in `p3t1-resume-provenance.2026-10-18T12-11.json`. Pass 9 was intentionally stopped by the user's pause after 49 passing markers and has no final coverage: it remains incomplete. Pass 11's native-stat fixture failure and stopped forward run remain explicit; only the fixture was corrected before this clean pass. Earlier failed/incomplete gate receipts have not been removed.

Pass 12 completed all 89 tests in both orders, but its callable audit found `CapturedWorkspace.inspect` at 87.5%. The coordinator committed that honest WIP state as `99e88cd08c9539f2972366a413cf7072ea725089`. One test-fixture line then made the existing explicit-missing-ancestor assertion reach its intended branch. The two-case diagnostic measured 15/16 lines (93.75%); the subsequent complete ordered pass supplies the final coverage above. Production was unchanged by that fixture correction.

No required current-task work is delegated to an unowned provider implementation. The independent executor must verify this frozen boundary before task checkoff; the coordinator then commits the accepted atomic task before releasing subsequent work.
