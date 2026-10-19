# P3-T8 independent acceptance audit

Timestamp: 2026-10-19T01-37 UTC, captured when the final verification command began.
Write timestamp: 2026-10-19T01-38 UTC.
Command: `poetry run python SCRATCH/issue-980-p3t8-final-bindings.py`
EXIT_CODE: 0
Output Summary: PASS. All 1,040 independent source/index, predecessor, receipt-order, raw-result and coverage checks pass with zero findings. The retained consolidated review and bounded repair confirmation remain bound to the exact final working bytes. No successful behavioral suite or accepted predecessor implementation was replayed by this verifier.

TASK_STATUS: PASS
TASK: P3-T8

Raw verification and post-checkoff status: [p3t8-executor-final-bindings.2026-10-19T01-38.json](p3t8-executor-final-bindings.2026-10-19T01-38.json). Worker source/raw/script index: [final manifest](p3t8-final-manifest.2026-10-19T01-34.json). Worker output contract: [handoff](p3t8-worker-handoff.2026-10-19T01-34.md).

## Authority and scoped ownership

The accepted baseline remains `e04136458147cdf24069b6bde563231f3c38c709`; checked WIP `7ae74faa52dc3f5ec9790502e9564d2489793deb` preserves reviewed work and does not replace that baseline. Fresh `atomic_execution_p3t8_after_wip` authority and native SubagentStart provenance agree on `atomic-executor-c4`, `gpt-6-astra`, `max`, profile SHA-256 `ac681ebf70607a2d00c76e29d142df0a05751c0c375f0ee878cec30b29c044b9`. Routing, launch authority and provenance are valid.

The approved scope is two new production modules (`source_read_models.py`, `source_reads.py`) and three new test modules (`test_source_reads.py`, `test_source_read_limits.py`, `test_source_read_snapshot_scope.py`). The parent approved the immutable-value helper and cohesive snapshot-test split. Final physical sizes are 423, 481, 364, 415 and 283 lines. No predecessor production, schema, policy or host source changed. This verifier changed only canonical evidence and the single P3-T8 plan checkbox; the parent owns orchestration state and Git.

## Delivered behavior and retained review

SourceReader requires a configured profile, a trusted catalog, separate host-supplied read selection, and accepted local metadata/byte seams. Closed list/read/literal-search operations intersect selected paths with configured roots and ancestor exclusions. Exact file/project grants cannot expand to siblings or directories. Snapshot membership takes precedence over broad documentation-root selection; all declared integrity inputs must pass profile scope and hash validation before requested provenance/content is released. A selected manifest grants integrity reads separately from returned-content grants.

Independent finite bounds cover metadata enumeration, queued paths, depth, per-file and aggregate input bytes, decoded lines, individual line bytes, match count, query size and serialized output. Freshness checks reread captured bytes and metadata; revalidation bytes count against input limits. Deterministic complete-row pages bind continuation to content, profile, selection, operation and limits. Text reads require UTF-8, preserve original byte hashes, and return one-based line/end-exclusive Unicode column spans; literal matches are case-sensitive and nonoverlapping. Binary files can be listed by metadata/hash. Working bytes carry no unproved configured revision. Validated imported members retain original repository/path/pinned revision and manifest digest; envelope metadata remains locally identified.

The reader exposes no shell, process, network or mutation operation. Unit tests use fresh in-memory stores and immutable shared configuration/catalog data, with committed resource reads only. The [single consolidated review](p3t8-executor-candidate-review.2026-10-19T01-21.md) found one exclusion bypass and two incomplete nested-helper docstrings plus a grant-label correction. The original failed two-case proof is preserved. [Bounded repair confirmation](p3t8-executor-repair-confirmation.2026-10-19T01-28.md) proves both excluded header/member cases now fail before excluded or requested payload reads, preserves all 34 prior top-level test/fixture/helper definitions and all 14 original comment tokens, and permits only the two reviewed predicate changes plus exact diagnostic renaming. It also confirms the policy fixes. The 125 original cases remain, with two added exclusion regressions. All definitions have docstrings and explicit loops retain intent comments. Final acceptance reuses those reviewed bytes rather than performing another broad review.

## Final ordered quality evidence

All seven required stages completed in one clean sequence on the same five repaired working-byte hashes. Every before/after source manifest matches the final source manifest, raw receipt hashes match, required receipt fields are present, and each command finished before the next command began.

| Stage / check | Exit code | Bound receipt |
| --- | ---: | --- |
| 1 / format | 0 | [p3t8-final-format.2026-10-19T01-31.json](../regression-testing/p3t8-final-format.2026-10-19T01-31.json) |
| 2 / lint | 0 | [p3t8-final-lint.2026-10-19T01-31.json](../regression-testing/p3t8-final-lint.2026-10-19T01-31.json) |
| 3 / types | 0 | [p3t8-final-types.2026-10-19T01-31.json](../regression-testing/p3t8-final-types.2026-10-19T01-31.json) |
| 4 / architecture | 0 | [p3t8-final-architecture.2026-10-19T01-31.json](../regression-testing/p3t8-final-architecture.2026-10-19T01-31.json) |
| 5 / unit | 0 | [p3t8-final-unit.2026-10-19T01-32.json](../regression-testing/p3t8-final-unit.2026-10-19T01-32.json) |
| 5 / coverage-audit | 0 | [p3t8-final-coverage-audit.2026-10-19T01-33.json](../regression-testing/p3t8-final-coverage-audit.2026-10-19T01-33.json) |
| 5 / reverse | 0 | [p3t8-final-reverse.2026-10-19T01-33.json](../regression-testing/p3t8-final-reverse.2026-10-19T01-33.json) |
| 6 / contracts | 0 | [p3t8-final-contracts.2026-10-19T01-34.json](../regression-testing/p3t8-final-contracts.2026-10-19T01-34.json) |
| 7 / native | 0 | [p3t8-final-native.2026-10-19T01-34.json](../regression-testing/p3t8-final-native.2026-10-19T01-34.json) |

Black reports five files unchanged; Ruff reports no findings; full-repository Pyright reports zero errors, warnings or informational diagnostics. The Pyright version-availability notice is retained in raw output and is not a code diagnostic. Architecture verification passes six package-contract cases plus explicit read-only/import/size and in-memory test boundaries. Pytest passes the same 127 unique cases forward in 47.35 seconds and exact reverse order in 18.97 seconds. Frozen-schema/resource contracts pass 339 cases in 5.69 seconds. No scoped failures or new diagnostics remain.

| New module | Executable lines | Branches | Measured class/callable ranges |
| --- | ---: | ---: | --- |
| source_read_models.py | 200/200 | 72/72 | 27 at 100% |
| source_reads.py | 209/209 | 104/104 | 16 at 100% |

Independent calculation from the raw coverage JSON and actual AST/decorator/lambda ranges confirms 409/409 executable lines, 176/176 branches and all 43 measured ranges at 100%. Both production paths are absent from the accepted baseline, so every new executable line is covered and there are no changed predecessor lines to regress. Coverage excludes tests; no task suppression or coverage exclusion was introduced. The task does not claim a new repository-wide aggregate coverage result. TypeScript, PowerShell and C# source were not touched; feature-wide gates remain later obligations.

All 266 accepted predecessor working-byte hashes and accepted/current-index Git blobs are preserved. All 24 frozen compatibility paths retain their captured working hashes and canonical Git identities. Their original manifests are retained in the [activation baseline](../baseline/p3t8-executor-prior-manifest.2026-10-19T00-54.json).

The five task files were reviewed and executed as CRLF working bytes. Actual Git attributes are `text=auto` and `eol=lf`; current index and WIP-committed bytes are identical LF payloads. Each working payload becomes that exact Git payload by replacing CRLF with LF only. Raw working SHA-256, index SHA-256, committed SHA-256, line-ending counts and actual attributes are separately recorded in the final bindings. No claim of raw byte equality is made, and no normalization or re-execution was performed by this verifier.

## Native composition and remaining boundaries

The bound native script/result passes 14 Windows service-composition assertions using real bounded metadata/byte adapters in external SCRATCH. It verifies sorted pagination, original hashes/Unicode CRLF spans, working-versus-imported provenance, exact project input, denied reads, finite byte limits, stale continuation rejection, complete imported transport integrity and unchanged native artifacts without activation or mutation locks. All native opens receive positive finite limits. The native body took 1.906 seconds; the enclosing recorded command took 3.258 seconds. These are whole multi-case durations, not per-API latency measurements.

ReadSelection remains trusted host input; constructing it does not authenticate caller authority. P6/P8 must expose the internal API through thin service/CLI/MCP boundaries and explicitly resolve the existing service schema's pagination/match-limit gap. P11 owns coding-agent host enforcement proof and feature-wide QA. Linux/macOS native execution was not performed here; accepted lower-layer platform proofs remain unchanged. No domain-specific behavior, product approval, runtime execution or feature-discovery completeness is inferred from this task.

## Task and acceptance reconciliation

Only P3-T8 is newly checked in the canonical plan. Status is **32/84 tasks**. Authoritative spec/user-story acceptance criteria remain **11/66**; no additional broad criterion is fully established by this internal reader alone, particularly public-surface path safety, role enforcement and complete Python/feature QA. No source/test/checkpoint/Git mutation was made by this verifier. The parent may commit acceptance before releasing P4-T1.

Next planned tasks: P4-T1 repository inventory/pipeline; P4-T2 .NET solution/project inventory; P4-T3 C# lexical/event candidates; P4-T4 configuration keys; P4-T5 filesystem/registry/COM constructs. No successor implementation has started in this verifier.
