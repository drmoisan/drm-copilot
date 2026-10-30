# P4-T2 consolidated candidate review

Timestamp: 2026-10-19T04-00 UTC

Command: `poetry run python SCRATCH/issue-980-p4t2-candidate-review.py`

EXIT_CODE: 0

Output Summary: Evidence reconciliation completed. Candidate result is **REVISIONS_REQUIRED**, with one blocking finding. P4-T2 and all acceptance criteria remain unchecked by this review.

## Complete finding set

**R1 (P2): solution_input.py:96 uses Unicode-aware `str.splitlines()` for physical source lines.** The two retained in-memory probes show that U+2028 inside an inert comment changes the reported project anchor from physical line 3 to line 4, and U+2028 inside a quoted literal path is rejected as `solution-project`. Split CRLF, CR and LF only, preserve other Unicode text, and add focused comment-anchor and quoted-path regressions. The required repair is limited to `solution_input.py` and `test_solution_input.py`.

No additional semantic, security, policy, size or test-isolation finding was identified across the three modules, three tests and six synthetic fixtures. The consolidated review is closed; subsequent review is limited to this repair and final evidence reconciliation.

## Retained proof

- All 12 reviewed-byte hashes match the frozen candidate manifest and exact copies captured by the 03:53 probe; all 26 accepted predecessor paths remain unchanged. The ten unaffected current candidate paths remain identical.
- Four ordered focused command receipts and their raw stdout/stderr hashes are bound to all 12 identical before/after source and fixture hashes: Black, Ruff, targeted Pyright and 150 tests passed. The suite was not rerun for review.
- Raw coverage verifies 290/290 executable lines and 116/116 branches. All 22 executable callables and 6 concrete class bodies have 100% measured coverage. Eight protocol method stubs and 3 protocol classes have no measured executable body statements and are N/A.
- Both parser modules have independently confirmed documentation/comment-only semantic AST changes from checked WIP `3ff78f81e6c507643f1df8dcd35a8c9b7ceb6148`; both parser tests remain byte-identical to that commit.
- Fixed parser security options, fail-closed malformed/DTD/entity inputs, independent resource bounds, declared-only build semantics, literal duplicate/condition handling, immutable provenance, deferred registry activation, typed contracts, intent comments, unit isolation and all six fixtures were reviewed. Maximum Python file size is 472 lines.
- The source-anchor defect was established with only two in-memory probes. Their command completed successfully while reproducing the defect; its exit status is not a candidate pass.

## Bound artifacts and limits

- Full findings, file hashes, per-callable coverage, gate bindings and accepted limitations: [p4t2-executor-candidate-review.2026-10-19T04-00.json](p4t2-executor-candidate-review.2026-10-19T04-00.json).
- Frozen candidate: [p4t2-candidate-manifest.2026-10-19T03-49.json](p4t2-candidate-manifest.2026-10-19T03-49.json).
- Failed behavior reproduction: [p4t2-executor-candidate-probe.2026-10-19T03-53.json](p4t2-executor-candidate-probe.2026-10-19T03-53.json).

This review does not claim final task acceptance. XML locations remain parser-reported element anchors, declarations do not evaluate MSBuild/imports/SDKs, and registry/public exposure remains P4-T9. The required final ordered gate sequence is pending the R1 correction. No source, test, checkpoint, Git, plan or acceptance-criterion mutation was performed.

The parent released the two-path correction while this historical receipt was being finalized. An initial checker assertion against current `solution_input.py` therefore failed. The checker now binds the original candidate to its previously captured exact copies and separately verifies the ten unaffected current paths. This bookkeeping correction preserves the initial failure and does not claim the changed repair bytes were already reviewed.

Current phase: P4. Current task: P4-T2. Next tasks: P4-T3, P4-T4, P4-T5, P4-T6, P4-T7.
