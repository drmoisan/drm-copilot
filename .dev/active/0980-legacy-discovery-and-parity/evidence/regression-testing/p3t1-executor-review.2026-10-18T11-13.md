# P3-T1 consolidated mutation boundary review

Timestamp: 2026-10-18 11:13:33 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-initial-probes.py 'Opaque payload grant cannot create a structured evidence record' 'Directory enumeration order is semantically irrelevant'`

EXIT_CODE: 1

## Output Summary

Both retained negative cases reproduce against stable source hashes. The [structured result](p3t1-executor-review.2026-10-18T11-13.json) binds the actual behavior to mutation_plan.py SHA-256 `4f22c6fe6e755d5033b0cdab0967fe03ecc7dc1a024543369089b4aaff7bf12e` and mutation_io.py SHA-256 `a5f2d3b0a4162ccda77fb5671c45eded1a2c19f5619ae9f490f0069fc70f4bca`.

## Consolidated findings

1. **Exact grant identity bypass.** A new path granted as evidence-payload ID granted-payload can contain a schema-valid evidence-reference ID actual-evidence. The loader resolves its real structured kind, but plan_mutation skips its proposed kind/ID check for every opaque grant. The resulting plan validates successfully. Opaque grants must require genuinely opaque captured outputs; they cannot bypass the trusted loader's structured identity.
2. **Enumeration-order false failure.** capture_workspace records raw directory children before the accepted SnapshotIO normalization. Reordering the same complete child list between inspections raises an I/O error. Normalize and collision-check directory child names before both capture consistency and persisted metadata comparisons, preserving actual namespace/identity changes as failures.
3. **Supported Markdown report output rejected.** The separate [stable report-pair probe](p3t1-executor-report-view.2026-10-18T11-12.md) creates a valid recomputed coverage-report JSON plus its Markdown view under exact grants. The view is correctly classified as documentation by the accepted loader, but the planner requires a parsed artifact and rejects it. Honor the existing inert report-view output contract with exact kind/path/ID linkage, without broad opaque exemptions.
4. **Concrete commit provider absent.** Initial mutation_io contains only a MutationWriter protocol whose atomic_write contract delegates complete-state guarding, exclusive creation and digest-matched replacement. The specialist confirmed no real provider exists. The coordinator retained this as a P3-T1 acceptance gap: implement the concrete guarded orchestration and actual platform provider within the current component, with injected OS seams for tests, or identify an exact already-approved provider owner. A generic later service reference or default unavailable result does not satisfy concrete mutation delivery.

The two initial positive cases—new exact collection creation and unchanged-byte skipping—passed. Their provisional run retained a source-change caveat in [initial evidence](p3t1-executor-review-initial.2026-10-18T11-12.md). The stable repeats above establish the negative findings independently. Final acceptance remains pending corrections, complete task tests and the full final source/coverage audit. No prior accepted production file or policy was changed by the verifier.
