# P4-T1 snapshot loader prerequisite assessment

Timestamp: 2026-10-19T01-52 UTC; this is the byte-binding/publication command start, following the bounded source inspection.
Command: `poetry run python SCRATCH/issue-980-p4t1-loader-assessment.py`
EXIT_CODE: 0
Output Summary: The static interface path confirms a missing local documentation Git capture request. No behavioral regression, test suite or implementation change was performed by this verifier. Exact inspected source hashes are recorded in [p4t1-executor-loader-prerequisite.2026-10-19T01-52.json](p4t1-executor-loader-prerequisite.2026-10-19T01-52.json).

`coverage_scope_rules._inventory` includes captured source, test and documentation paths in complete inventory accounting and compares inspected rows to captured working bytes. `revision_rules._source_bytes` separately requires immutable bytes for inspected inventory files and each component, finding and relationship source. `snapshot_loading._read` adds only source/test categories to selected pinned requests; `_git` therefore lacks a local documentation object without a separate explicit request. `mutation_plan.project_snapshot` reloads through the same loader using `_PinnedReader`, so a documentation object manually present in the original snapshot is omitted from the projected result unless the loader requests it again.

The smallest appropriate correction is source-request extraction for schema-valid **local inventory records**, bounded to already captured configured local inputs. Imported inventory rows use transported payloads and must never request local Git. Do not pin every file classified as documentation: ordinary unreferenced documentation and generated report/acceptance Markdown can be untracked, and existing tests deliberately permit that state. Preserve configured repository/pin checks and the distinction between working and immutable bytes.

The original snapshot must explicitly precapture the exact needed documentation Git objects before first publication. Projection remains pure replay: `_PinnedReader` must continue rejecting an object that was not captured, instead of starting new Git or filesystem work. No coverage, revision, mutation-authority, schema or imported-transport rule should be relaxed.

Composition constraint confirmed by subsequent bounded inspection: `DiscoverySnapshot.sha256` includes every retained repository object, and `mutation_io._same_state` compares that digest before publication. Therefore the analyzer's explicit capture adapter must supply the same selected documentation objects on every fresh writer capture. Otherwise the existing `MUTATION_STALE` failure is correct. Once the persisted inventory causes the loader to capture those objects itself, the adapter must coalesce exact identities and reject conflicting bytes; duplicate repository objects remain invalid. The mutation freshness rules remain unchanged.

The loader is already 486 physical lines. A cohesive source-request helper with a small loader call and dedicated tests is appropriate if the correction cannot stay within 500 lines. Existing `test_snapshot_loading.py` is 423 lines. Parent scope authorization and separate specialist ownership are required before changing these accepted predecessor files.

Required focused verification:

- A local documentation path used by inspected files, components, findings and relationships requests its exact local repository, full pin and path once, and retains the immutable bytes.
- Unreferenced/unpinned documentation, runtime payloads, malformed records, imported records, foreign repository claims and uncaptured/out-of-scope paths create no unauthorized extra local Git requests.
- `project_snapshot` retains the explicitly captured documentation object and validated inventory references; missing objects still fail with the existing reload requirement.
- A composed first inventory `plan_mutation` succeeds with explicit correct pre-capture, while absent objects, wrong pins and mismatched hashes remain rejected. Existing source/test/evidence behavior and no-runtime-Git guarantees remain covered.

This is a prerequisite finding within P4-T1, not task acceptance or a new execution phase. The parent owns its authorization and the final comparison must distinguish this approved predecessor change from unaffected preserved files.
