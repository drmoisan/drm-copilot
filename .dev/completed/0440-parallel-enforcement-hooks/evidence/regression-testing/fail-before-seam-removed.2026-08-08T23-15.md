# P2-T7 [expect-fail] — Fail-Before with the F7 Seam Line Removed

Timestamp: 2026-08-09T00-53

Command: `npm run test:unit -- parallel-cohort-barrier-parity` (run from `extensions/drm-copilot/`) with the single line `errors.push(...validateCohortBarrierOrdering(state));` temporarily deleted from the F7 seam in `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`; the import statement was left in place.

EXIT_CODE: 1

The non-zero exit code is the EXPECTED outcome of this `[expect-fail]` task. It
reproduces exactly the defect B-1 reported: an empty TypeScript parity seam whose
Python counterpart is fully implemented. With the seam emptied, the TypeScript
surface reports a cohort-ordering violation as CLEAN while the Python surface
rejects the same document.

## Output Summary

- Test Suites: 1 failed, 1 total.
- Tests: 8 failed, 25 passed, 33 total.
- Failing corpus cases: 8 — exactly the eight corpus documents whose
  `expected_barrier_errors` block is non-empty. Every one reported `Array []`
  where the corpus expects at least one barrier message:
  1. `cross-cohort-later-start-earlier-pr-open`
  2. `earlier-ci-green-does-not-satisfy-barrier`
  3. `earlier-cohort-endpoint-named-first`
  4. `feature-folder-hint-cohort-membership`
  5. `merge-confirmed-after-later-start`
  6. `same-cohort-conflicting-pair`
  7. `start-timestamp-alone-evidences-start`
  8. `three-conflicting-items-one-cohort`
- The 22 barrier-satisfying corpus cases plus the 3 corpus guard tests continued
  to pass, which is correct: a clean document produces no barrier message whether
  or not the seam is filled. That asymmetry is precisely why the corpus must
  carry violating documents, and why the guard tests assert a non-empty violating
  subset exists.

### Quoted expected-versus-received pair (case `same-cohort-conflicting-pair`)

```
    expect(received).toEqual(expected) // deep equality

    - Expected  - 3
    + Received  + 1

    - Array [
    -   "PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445",
    - ]
    + Array []

      at test/lib/validate/parallel-cohort-barrier-parity.test.ts:289:24
```

## Seam Restored:

The seam line was re-inserted IMMEDIATELY after the failing run completed and
BEFORE this artifact was written, so no task boundary left the repository in the
defective state. Verbatim `git diff -U0 -- extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`
output taken AFTER re-insertion:

```
diff --git a/extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts b/extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts
index 86eab2a7..1cc5d8b9 100644
--- a/extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts
+++ b/extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts
@@ -35,0 +36 @@
+import { validateCohortBarrierOrdering } from "./parallel-orchestrator-state-cohort-barrier";
@@ -313,0 +315 @@ export function validateParallelOrchestratorStateText(
+  errors.push(...validateCohortBarrierOrdering(state));
```

The diff shows exactly the two added lines and zero removed lines specified in
P1-T2. The post-restore blob hash `1cc5d8b9` is byte-identical to the hash
recorded before the temporary removal, so the restoration is exact rather than
merely equivalent. The file is 322 lines, matching the P1-T2 acceptance figure.

## Disposition

The shared corpus detects the exact defect B-1 reported. The parity binding is
therefore non-vacuous: an empty TypeScript seam cannot pass the corpus, and the
Python suite asserting the same files cannot diverge from it without one of the
two suites failing.
