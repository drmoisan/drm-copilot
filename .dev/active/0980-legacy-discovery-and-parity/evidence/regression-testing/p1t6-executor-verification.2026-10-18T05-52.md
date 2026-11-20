# P1-T6 independent executor verification

Timestamp: 2026-10-18T05-52
Command: poetry run python SCRATCH/issue-980-verify-p1t6.py
EXIT_CODE: 0
Output Summary: P1-T6 acceptance verified; seven schema/fixture pairs, 20 independent boundary probes, exact 33-path staged scope, 24 matching packaged resources and 84 unchanged prior-task paths.

## Acceptance decision

The parity-matrix, implementation-record, unspecified-behavior, product-decision, two strict collection envelopes and acceptance-specification schemas satisfy P1-T6. Each schema has exact v2 identity/version, closed core fields and namespaced extension support. The immutable source-contract reference contains the normative repository ID, full revision, artifact path, SHA-256, feature ID and schema version. Populated parity requires source/target pins; empty initial parity can preserve unknown pins. Configured semantic gates determine optional mode obligations rather than universal schema requirements.

Parity, applicability and verification remain separate axes. Positive parity requires target references and evidence; retirement and intentional change require typed decisions. Target implementation claims require verification evidence and a corresponding test outcome. Product decisions retain approval metadata, scope, alternatives, migration behavior, criteria and supersession links. Proposed/rejected criteria remain pending; superseded criteria retain inactive history. Unresolved records distinguish observation-based resolution from target-policy approval. Collection records enforce their nested schema kind.

Acceptance records bind scenario, criterion, feature, client/platform/mode, immutable source and evidence/decision provenance. Pending records require null Then and an explicit reason. Legacy characterization cannot use target approval to manufacture historical behavior. Readiness is not an implementation pass; test code and execution-status fields are rejected.

## Independent checks and completed gates

[Machine-readable verification](p1t6-executor-checks.2026-10-18T05-52.json) records exact Git blobs and byte hashes. All seven schemas pass Draft 2020-12 schema validation; seven valid examples pass and seven invalid fixtures yield actionable pointers. Twenty independent cases cover draft/populated parity pins, optional modes, mutable source rejection, status separation, retirement linkage, evidence, approval, proposed criteria, unresolved behavior, strict collections, null pending expectations and legacy-versus-target semantics.

All 24 resources match canonical bytes, sizes and digests. Exact task scope is 33 staged paths; 84 prior-task paths retain their recorded hashes. Existing test support, production Python, dependencies, earlier schemas and frozen v1 assets are unchanged. Only the existing resource allowlist/generated manifest overlaps prior tasks. Maximum physical file size is 394 lines. Owned files have no unstaged changes; the complete staged diff check passes.

The executor read the actual ordered records and the [specialist handoff](../other/p1t6-target-schemas.2026-10-18T05-51.md). Final Black reports three unchanged files, Ruff reports no findings, full Pyright reports no diagnostics, and focused Pytest passes 1,074 tests. Reversed new modules pass 269 tests. The read-only resource check reports 24 resources and no changed paths. The retained first Ruff run reports 34 E501 findings in test prose, a test name and literal lines; they were corrected without changing assertions, followed by the complete clean ordered pass 2.

Raw coverage confirms the unchanged resource reader/builder remain at 312/312 executable lines and 132/132 branch arcs, with zero delta. There are no new or changed executable production lines in this task. Tests read immutable fixtures into fresh objects, without temporary files, external processes, network calls or shared mutable state. No suppression or policy change was introduced. TypeScript, PowerShell and C# have no task-local changes requiring another loop; final feature QA remains outstanding.

## Semantic boundaries and status

Later graph validation must establish referenced decision approval/owner/scope, supersession consistency, evidence truth and source/target origin, repeated identifier agreement, repository pins, configured dimensions and required acceptance coverage. P2-T8 must reject contradictory duplicate mode classifications between entry.online/offline/mobile and entry.dimensions.<mode>. This obligation is persisted by the coordinator under the existing parity-validation task. Schema-valid authored claims do not establish completion or host authority.

P1-T6 is checked off after verification. Ten of 84 tasks are complete; P1-T7 is next. Control schemas and authoritative validation remain outstanding, so no full-feature acceptance criterion is checked off. The coordinator owns staging, checkpoint persistence and the next specialist release.
