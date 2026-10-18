# P2-T3 independent executor verification

Timestamp: 2026-10-18T08-36
Command: poetry run python SCRATCH/issue-980-verify-p2t3.py 2026-10-18T08-35
EXIT_CODE: 0
Output Summary: P2-T3 accepted; 52 independent cases pass against final production hashes; four staged paths, 178 prior accepted paths and 24 frozen compatibility paths verified; all 25 measured new callable/class ranges exceed 90% line coverage.

The [machine receipt](p2t3-executor-checks.2026-10-18T08-36.json) binds every independent case, staged Git blob, source SHA-256, raw coverage range and file length. It verifies the exact task scope: `evidence_rules.py`, `revision_rules.py`, `test_evidence_rules.py` and `test_revision_rules.py`.

## Acceptance proof

The final bounded probe, `poetry run python SCRATCH/issue-980-probe-p2t3.py`, exits 0 with 52/52 cases. It verifies one-based inclusive spans, integer-valued JSON numbers, bounded findings for enormous integer endpoints, accepted RFC3339 timestamps, explicit authorship/environment/capture method, exact local payload checksums, pinned source/test bytes, repository-role separation and immutable artifact/transport hashes. Changed bytes, missing immutable objects and mismatched configured pins fail. URI-only documentation remains descriptive and cannot supply local completion proof.

The P1-T4 carry-forward for `runtime_artifact.path` is verified: a distinct capture path must independently resolve to bytes matching the declared checksum. Identical captures pass; replaced or missing captures fail. Runtime evidence does not require a newly recorded capture to exist at the application's Git commit. Documentation-only HEAD advancement preserves matching historical source bytes, and remote freshness remains explicitly `unknown`.

These rules establish local integrity and declared revision identity. Observed truth, approved decisions, required completion and target parity claims remain assigned to later tasks. Transport entry hashes and sizes are checked here; canonical source-manifest generation and importer-state digest verification remain P3-T6.

## Quality evidence

The [aggregate command receipt](p2t3-gates.2026-10-18T08-27.md) records clean ordered pass 8: `poetry run black --check` leaves all four files unchanged, `poetry run ruff check` reports no findings, full `poetry run pyright` reports zero diagnostics, and focused `poetry run pytest` passes 90 tests in 17.59 seconds. Reversed module order passes 90 tests in 7.46 seconds. The [specialist handoff](../other/p2t3-evidence-revisions.2026-10-18T08-35.md) and [final metrics](p2t3-coverage-metrics.2026-10-18T08-35.json) preserve the exact commands, scope and contracts.

| Production module | Lines | Branch arcs |
| --- | --- | --- |
| evidence_rules.py | 110/110 | 42/42 |
| revision_rules.py | 186/187 | 106/108 |
| Total | 296/297 | 148/150 |

Independent recomputation from the [raw final coverage](p2t3-coverage.2026-10-18T08-35.json) confirms all 25 measured callable/class ranges meet the 90% line threshold; the minimum is 93.333333%. Maximum file length is 483 lines. All 178 previously accepted path hashes and 24 frozen v1/export paths remain unchanged. The four working files match their staged bytes, and staged whitespace checks pass. The specialist's tracked contracts verify all 33 schema resources and 26/26 tier classifications. Tests use in-memory collaborators and create no temporary files or external processes.

Python task gates pass. This task adds no TypeScript, PowerShell or C# files. Full feature-wide language gates, native hosts, publication and feature review remain pending their planned phases.

## Retained failures and corrections

The [initial executor review](p2t3-executor-review.2026-10-18T08-22.md) retains twelve cases with eight passes and four failures. Both identified defects are corrected: authoritative timestamp semantics replace redundant parsing, and integer endpoints avoid float coercion. All affected cases pass against final source hashes.

Earlier Ruff width findings, numeric-predicate and empty-set typing errors are retained in the aggregate receipt and corrected without suppressions. Pass 5's 66 passes and 22 fixture failures are retained, with [failed-run coverage](p2t3-coverage-pass5.2026-10-18T08-30.json); an explicit required target client corrects that setup. Pass 6's 88 passing tests did not satisfy the callable gate: `_references` covered 17/19 lines, or 89.473684%. The [08-32 failed audit](p2t3-coverage-metrics.2026-10-18T08-32.json) and the executor check's rejection remain identified. Two targeted transport-link tests cover inherited identity and unresolved targets; clean pass 8 satisfies every callable threshold without changing production bytes.

A result-presentation wrapper raised after a successful audit command while handling its long JSON output. The persisted receipt was read, and the final bounded audit was rerun successfully with sufficient output capacity. This was an operational presentation error, not a source or test failure; no failed command was treated as acceptance.

## Task and criteria state

P2-T3 is verified and checked off. Plan progress is 18/84. Feature acceptance criteria remain 4/66 in each source; no broader criterion is newly complete. AC-13 remains pending cyclic-supersession proof in P2-T5.

Current phase: Phase 2. Next tasks: P2-T4, P2-T5, P2-T6, P2-T7 and P2-T8. The coordinator owns the next specialist release.


## Command-receipt format correction — 2026-10-18T09-02

The retained aggregate command log was normalized into individual write-time-stamped receipts without rerunning commands or changing their recorded results. Original capture/start timestamps, commands, exit codes and output are preserved. See the [verified extraction index](p2-command-receipt-normalization-verification.2026-10-18T09-02.md) for the one-to-one mapping and unchanged aggregate hashes. This note corrects evidence format only; the task acceptance and production-byte verification above are unchanged.
