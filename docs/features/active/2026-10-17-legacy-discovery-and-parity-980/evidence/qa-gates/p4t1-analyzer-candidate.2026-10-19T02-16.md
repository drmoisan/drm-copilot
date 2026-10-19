# P4-T1 frozen analyzer candidate

Timestamp: 2026-10-19T02:16:39.1613509+00:00
Command: Review exact analyzer candidate and its focused ordered toolchain evidence
EXIT_CODE: 0
Output Summary: 238 tests passed; 436/436 executable statements and 112/112 branch destinations covered. Consolidated review and final scoped gates remain pending.

Scope: the exact 26 source/test paths and SHA-256 values are recorded in `p4t1-analyzer-candidate-manifest.2026-10-19T02-14.json`. The package contains eight analyzer modules, four legacy compatibility adapters, four new in-memory test modules, and ten explicitly bound existing test modules (including unchanged `test_models.py`). The separate snapshot-loader prerequisite is owned and reviewed independently. No policy, plan, checkpoint, acceptance checkbox, CLI production module, or successor task was changed by this worker.

The approved plan is P4-T1 in `plan.2026-10-17T22-38.md`. Approved cohesive additions are `analyzer/input_capture.py`, its focused tests, and the docstring-only `analyzer/__init__.py` package marker. The marker provides typed package discovery; public export completion remains P4-T9.

## Behavior and boundaries

- `InventoryInput` retains inspected bytes, excluded-frontier rationale, or unreadable-file rationale. Missing bytes never receive a fabricated content hash. Captured input hashes are cached from the exact retained byte value.
- The analyzer-local input boundary sorts traversal and prunes configured exclusions, artifact roots, and evidence roots before descent. It enforces path identity, link, depth, file-count, per-file, aggregate-byte, and freshness bounds using accepted `PathPolicy` and `SnapshotIO` seams. The ordinary core snapshot loader remains all-or-nothing.
- `RepositoryAnalyzer` recognizes real solution/project files and generic manifests. Its structural components are detected facts; revision verification independently controls confidence. It never infers observable behavior or a product decision from a filename.
- Pure inventory assembly validates the v2 schema, stable identifiers, source references, sorted rows, component relationships, and semantic digests. The semantic digest excludes capture timestamps and capture identity. Every retained included, excluded, or unreadable input remains represented.
- Ledger components are uninspected/unassigned proposals. Publication never edits scope or the coverage ledger and never expands analyst grants.
- Legacy pipeline invocation performs parse/classify/map without emission. Default and dry-run operations write nothing. A legacy direct emitter rejects an unsafe implicit publication request with an actionable error.
- Explicit inventory publication reconstructs the expected result from the accepted immutable snapshot, rejects forged or blocked results, and requests the exact inventory output through `plan_mutation`. Execution remains exclusively in accepted `commit_mutation`.
- `pin_inventory_sources` explicitly captures required local Git objects before first inventory publication. The writer composes the same bounded capture on every freshness read. Subsequent loader replay uses the separately reviewed local-inventory prerequisite. Imported inventories are not resolved against the local repository.
- Registry selection rejects unavailable adapters. Core imports no optional domain adapter; later P4 tasks register further generic analyzers. CLI-specific dispatch completion remains P6-T3.

## Baseline and assertion preservation

The accepted starting revision is `a94c44fa31e66d830d01203ee9cc068fce2deef1`. The single retained baseline passed 192 tests with clean Black/Ruff/Pyright and 180/180 executable lines, 30/30 branch destinations in the four original modules. The executor independently bound those source/test hashes and all accepted predecessor/frozen paths. That baseline was not rerun.

The candidate manifest classifies each canonical callable/class as relocated, changed-existing, or new by comparing its AST to the accepted legacy definition after removing documentation. Per-unit executable ranges and coverage are retained. The old adapters contain only explicit public reexports; complete scoped old/new patches are in `p4t1-analyzer-candidate-diff.2026-10-19T02-14.md`. No generated mirror is changed in P4-T1.

| Existing suite | Preserved guarantee and approved expectation change |
| --- | --- |
| models | Existing value-object and invalid-input assertions are unchanged. |
| inventory / inventory E2E | Sorted tree, configured exclusions, classifications, and read errors remain asserted. Placeholder default project suffixes become real project/manifest markers; automatic emission becomes read-only. |
| pipeline | Parse/classify/map order and propagation remain asserted. Emit is no longer called implicitly; written paths remain empty. |
| emitter | Pure deterministic v1 serialization and schema fields remain asserted. Direct unguarded emission now fails without creating an output directory. |
| dotnet / optional platform | Existing syntax/reference detections, masking, records, and deterministic content remain asserted. Tests serialize and validate records directly after the read-only pipeline instead of expecting automatic file writes. |
| source_text / stack_neutrality | Both suites and their asserting source remain unchanged, and the complete suites run with the candidate. |
| cli / stack_cli | Dispatch, argument errors, output selection, clock propagation, and positive detection counts remain asserted. Successful legacy summaries explicitly report no written paths. |
| domain_neutrality | Consumer and optional-domain identifiers remain prohibited in core; the scan includes the canonical runtime modules as well as legacy adapters. Generic project suffix data is recognized as structural inventory configuration. |

## Focused proof and remaining gates

Black, Ruff, Pyright, and Pytest completed in one ordered pass without changing the measured source/test bytes. The receipt paths and their hashes are in the candidate manifest. The complete analyzer population passed 238 tests in 133.02 seconds. Every canonical production statement and branch is covered; the maximum physical file length is 486. The suite includes first-publication validation, repeated capture, dry-run, idempotency, forged-result rejection, unauthorized-write rejection, stale-source invalidation, early pruning, unreadable inputs, Windows/POSIX roots, Unicode/line endings, and deterministic ordering.

The final scoped sequence will follow consolidated review: format, lint, whole-repository typing, architecture, reversed-order unit/coverage validation, tracked-file contracts after parent staging, and native composition. The exact loader 62-case proof is reusable while its bytes remain unchanged. Whole-feature aggregate gates and Linux/macOS native execution remain later plan obligations. No task check-off or full-feature completion is claimed by this candidate report.
