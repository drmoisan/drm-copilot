# P2-T4 independent executor verification

Timestamp: 2026-10-18T08-55
Command: poetry run python SCRATCH/issue-980-verify-p2t4.py 2026-10-18T08-54 34
EXIT_CODE: 0
Output Summary: P2-T4 accepted; 34 schema-valid independent cases bind to final production bytes; four staged paths, 182 prior accepted paths and 24 frozen compatibility paths verified; all 20 measured new callable/class ranges exceed 90% line coverage.

The [machine receipt](p2t4-executor-checks.2026-10-18T08-54.json) records the individual cases, exact staged Git blobs, SHA-256 hashes, file lengths and independently recomputed raw coverage. The approved same-component split stays within the plan's 500-line provision: `claim_rules.py`, `runtime_claim_rules.py`, `test_observation_claims.py` and `test_runtime_claims.py` are the complete task scope.

## Acceptance proof

`poetry run python SCRATCH/issue-980-probe-p2t4.py` exits 0 with 34/34 schema-valid cases. Source hashes remain unchanged throughout that run and match the final staged files. Verified observations require usable pinned evidence; uncertainty links same-feature/dimension open records; confidence labels neither replace evidence nor promote state. Feature-wide unresolved backlinks block a verified summary, and valid source proof cannot mask source-only data listed as runtime evidence. Intentionally unspecified behavior depends on scoped declared approval and rationale; proposed or wrong-dimension decisions do not satisfy it. Full decision authority and conflict validation remain P2-T5.

The P1-T4 scenario/run carry-forward is verified. An executed summary matches a recorded run on status, expected result, core environment identity and observed pre/post states. Every executed run independently requires runtime evidence and captures. Status, expectation, environment and state contradictions fail; failed-to-passed and first-observation-to-known histories remain valid. Known source expectations need an evidenced ready criterion or a verified evidenced dimension present in the observation plan. An unrelated known trigger or decision-only criterion cannot justify an unknown planned legacy expectation.

Prior-runtime basis requires a separate evidenced `observed` run with null expected result and matching environment. A current pass alone is insufficient. This is supporting provenance, not a chronological-order or latest-run claim; both array orders pass. Arbitrary prose equivalence is not inferred. Unknown expectations remain observations, and legitimate not-run, blocked and not-applicable plans retain their unexecuted state. Missing or replaced runtime payloads and source code presented as execution proof fail.

## Quality evidence

The [aggregate command receipt](p2t4-gates.2026-10-18T08-44.md) records clean ordered pass 5: `poetry run black --check`, `poetry run ruff check`, full `poetry run pyright` and focused `poetry run pytest` all exit 0. Formatting leaves four files unchanged; linting and typing report no diagnostics. Focused tests pass 98 cases, and reversed module order passes 98. The [specialist handoff](../other/p2t4-observation-claims.2026-10-18T08-54.md), [metrics](p2t4-coverage-metrics.2026-10-18T08-54.json) and [raw coverage](p2t4-coverage.2026-10-18T08-54.json) preserve the results.

| Production module | Lines | Branch arcs |
| --- | --- | --- |
| claim_rules.py | 127/128 | 70/72 |
| runtime_claim_rules.py | 90/92 | 55/60 |
| Total | 217/220 | 125/132 |

All 20 measured new callable/class ranges meet the required 90% line threshold; the minimum is 90.909091%. Maximum file length is 484 lines. Independent checks confirm all 182 prior accepted hashes and 24 frozen v1/export paths remain unchanged. The four working files match staged bytes, staged whitespace is clean, and tracked contracts pass for 33 packaged schemas and 26/26 tier classifications. Tests use fresh in-memory collaborators and create no temporary files or external processes.

Python task gates pass. This task changes no TypeScript, PowerShell or C# files. Feature-wide QA, native enforcement, publishing and review remain pending their assigned phases.

## Retained review and preparation results

The [initial consolidated review](p2t4-executor-review.2026-10-18T08-45.md) records four schema-valid graphs that incorrectly produced no findings, after twenty earlier cases passed. Its diagnostic command exited 0 to record actual outcomes; the artifact explicitly withheld acceptance. The minimum prior-runtime interpretation was resolved through the coordinator using existing fields. All four corrections and the relevant-dimension refinement now have passing independent cases and repository regressions.

Earlier ordered attempts stopped on required-dimension and dynamic-test typing, or comment/docstring width findings. Explicit narrowing and fixture overrides corrected them without suppressions. The aggregate receipt retains those failures. No Pytest failure is claimed or omitted: the final focused and reversed populations both pass.

## Task and criteria state

P2-T4 is verified and checked off. Plan progress is 19/84. Feature criteria remain 4/66 in each source; no broader hook or completion criterion is newly complete. AC-13 remains pending cyclic-supersession proof in P2-T5. Required-dimension union, full decision validation and aggregate completion remain their later tasks.

Current phase: Phase 2. Next tasks: P2-T5, P2-T6, P2-T7, P2-T8 and P2-T9. The coordinator owns the next specialist release.


## Command-receipt format correction — 2026-10-18T09-02

The retained aggregate command log was normalized into individual write-time-stamped receipts without rerunning commands or changing their recorded results. Original capture/start timestamps, commands, exit codes and output are preserved. See the [verified extraction index](p2-command-receipt-normalization-verification.2026-10-18T09-02.md) for the one-to-one mapping and unchanged aggregate hashes. This note corrects evidence format only; the task acceptance and production-byte verification above are unchanged.
