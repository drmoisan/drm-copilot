# P2-T9 validation composition handoff

Timestamp: 2026-10-18T10-57
Command: poetry run python SCRATCH/issue-980-p2t9-handoff.py
EXIT_CODE: 0
Output Summary: Eight staged task paths; 107 focused and 107 reversed tests; 33 measured unit ranges at or above 96.774194%; 203 prior paths and 24 frozen paths unchanged.

## Exact scope and routing

- packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py: 411 physical lines
- packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py: 255 physical lines
- packages/discovery-runtime/src/drm_copilot_discovery/validation.py: 392 physical lines
- packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py: 179 physical lines
- tests/discovery_runtime/test_agent_output.py: 461 physical lines
- tests/discovery_runtime/test_completion_rules.py: 353 physical lines
- tests/discovery_runtime/test_validation_modes.py: 327 physical lines
- tests/discovery_runtime/validation_test_support.py: 324 physical lines

Only P2-T9 is implemented. Approved plan line 28 permits the recorded same-component splits: validation_inputs.py separates complete raw/profile/schema validation and report input hashing after formatted validation.py reached 514 lines; validation_test_support.py shares fresh in-memory fixtures while keeping both prescribed composition/output test modules below 500 lines. No prior accepted production/test/schema file, dependency, suppression, coverage threshold, plan/AC or checkpoint was changed. Only the coordinator staged these paths.

The existing Phase 2 external SubagentStart receipt remains the actual authority: agent 01a14d8e-6d30-70b1-b8f6-cfb8502f0f28, python-typed-engineer-c4, gpt-6-astra/max, profile SHA 0d02ca1f9b97abd4d84120f9443359404ab6ef4d094a1b97d520381fb1f9edd6, routing/provenance/launch all valid. No new delegation or native authority is synthesized by this task.

## Public result and mode contract

validate_snapshot(snapshot, *, mode, invocation=None) is pure and deterministic. The required mode is structural, agent-output, discovery-complete, parity-complete or planning. Missing snapshots/profile bytes fail closed. All retained structured files, including unreferenced files, use their trusted expected kind, exact v2 schema and the captured catalog; parsed values must match raw bytes and profile role pins. Unsupported API modes raise ValueError. The one resolved index and accepted evidence, revision, claim, decision, dimension, coverage, acceptance and parity families are reused; no alternative validation engine or catalog cache was added.

SnapshotValidation retains mode, bounded sorted findings, full input_sha256, validation_result and optional output_valid, role, invocation_id and required_outputs_sha256. Its ok property means output_valid for agent-output and validation_result=pass for root modes. A valid failed reviewer has output_valid=true, validation_result=fail, and the actual recomputed error findings. Such a result can finish the review output obligation but cannot authorize completion or planning. A role invocation supplied to a root mode fails with VALIDATION_CONTEXT. Workspace receipt/control data never selects a principal or satisfies a gate.

Structural mode accepts honest initialized drafts while enforcing mandatory schema/reference/evidence/truth rules. Discovery completion adds configured source pins, per-source scope/inventory/ledger prerequisites, required feature evidence, declared runtime characterization, required dimensions and ready acceptance tuples, and configured unresolved/deviation rules. Parity completion includes source discovery plus independently justified required target parity. Target-local draft accounting does not replace or obstruct separately pinned source accounting. Planning follows exactly the configured none/discovery-complete/parity-complete prerequisite; none cannot disable core validity or evidence integrity.

Approved target policy remains separate from legacy observation. A resolved target-policy question and a distinct linked open legacy-observation question are valid records; when unresolved required behavior blocks completion, that remaining open observation still blocks it. Disabling that configurable completion gate does not rewrite source observations or disable mandatory claim consistency. Historical source pins remain valid when retained bytes match, irrespective of documentation HEAD advancement.

## Exact role-output contract

InvocationContext is a frozen, separately supplied caller value: baseline snapshot, role, invocation_id, immutable workspace binding, immutable required_outputs manifest, selected_ids and optional review_mode. Native code must authenticate this context independently. Pure validation does not grant writes, attest a host, invoke tools, create protected receipts or commit mutations.

required_output_digest(manifest) hashes canonical JSON excluding only manifest_sha256; array order remains bound. Each output's expected_sha256 is the baseline precondition, with null meaning absent. Current output kind/ID/path/format and parsed bytes are checked separately. The stored manifest must equal the caller-required manifest and include its own exact output row. Missing, duplicate, substituted, wrong-role or extra changed paths fail. Shared collection changes remain restricted to selected identities; existing approved/rejected/superseded decision facts are preserved, while selected proposed decisions can be updated. Runtime payload/view outputs are inert nonempty bytes in their configured roots.

The four role sets are explicit: legacy-parity-analyst produces inventory, coverage, feature/evidence and unresolved records; runtime-characterization-analyst produces scenarios, supplied evidence/payload registrations and unresolved records; requirements-reconciler produces parity, unresolved records, proposed decisions and acceptance specifications/views; migration-coverage-reviewer produces derived reports. Each set includes its exact required-output manifest. Profile, implementation source, activation and host-control writes are not granted by these roles.

## Report and prospective mutation interface for Phase 3

report_projection(snapshot, *, kind, identifier, mode) returns recomputed structured report fields; rendering remains Phase 5. Fields are schema_version, artifact_kind, id, mode, input_sha256, validation_result, kind counts and findings. report_input_digest excludes report/control output bytes and report-output absence, preventing self-hash recursion; the main validation result still binds the complete snapshot SHA including those bytes. Current requested reports must exactly match recomputation. During agent-output only, unchanged unrequested baseline reports are preserved as historical views and cannot authorize a current gate. Root report checks remain explicit and current.

Phase 3 can construct a complete prospective immutable DiscoverySnapshot from accepted captured inputs and exact proposed bytes, then call validate_snapshot in the chosen mode with authenticated InvocationContext for role outputs. The accepted snapshot manifest retains all path/category/byte/hash data, missing paths, source/target pins, captured Git objects and checkout/exclusion identity needed for freshness checks. Expected output hashes refer to the baseline, never the proposed result. Native mutation code must still enforce exact grants, recheck parent metadata and all relevant input identities, perform compare-and-swap/exclusive creation, and handle races or partial failures. This handoff does not implement those operations or release Phase 3.

## Verification and retained corrections

Clean ordered pass 7: Black and Ruff pass all eight paths; full repository Pyright has zero diagnostics; 107 focused tests pass, followed by 107 reversed-order tests. Each command has a separate timestamped receipt. Static checks cover the 500-line limit, required docstrings, whitespace, absence of suppressions and isolated tests. Mutable graphs and payload stores are fresh; only immutable installed catalogs are shared. No unit test creates temporary files, processes or network traffic. Tracked quality-tier and package-resource contracts pass.

- packages/discovery-runtime/src/drm_copilot_discovery/agent_output.py: 139/140 lines (99.285714%); 67/68 branch arcs (98.529412%).
- packages/discovery-runtime/src/drm_copilot_discovery/completion_rules.py: 72/72 lines (100.000000%); 46/46 branch arcs (100.000000%).
- packages/discovery-runtime/src/drm_copilot_discovery/validation.py: 133/133 lines (100.000000%); 42/42 branch arcs (100.000000%).
- packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py: 51/51 lines (100.000000%); 22/22 branch arcs (100.000000%).

All 33 measured module/class/method ranges meet the 90% new-unit floor. Phase 0 remains zero Ruff/Pyright diagnostics, 7,336 passed with six existing skips, 94.111715% lines and 88.783742% branches. New modules have zero baseline statements; lint/type/failure deltas are zero. The unchanged accepted-path union preserves prior changed-line evidence. Repository-wide final test/coverage QA remains Phase 11.

Retained failures include initial formatting/import/annotation corrections; pass 5's 104 passed/one invalid source-only fixture retaining a target client; its raw 393/396 lines and 175/178 arcs; and its evaluate callable at 11/13 lines (84.615385%). Direct tests now cover cached prerequisite reuse and unsupported report modes. Pass 6's typed empty-list fixture diagnostics were corrected before restarting. The independent consolidated review found one current-task defect: an unchanged old report blocked a permitted selected ledger update. Its original graph and stable-byte correction proof remain executor-owned. The final independent case set is bound to frozen production hashes and remains a separate acceptance gate.

Metrics and exact hashes: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t9-coverage-metrics.2026-10-18T10-57.json
Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t9-coverage.2026-10-18T10-57.json
Command receipts: evidence/regression-testing/p2t9-pass7-*.md.

TASK_READY_FOR_VERIFICATION. Independent executor acceptance and any Phase 3 release remain coordinator-owned.
