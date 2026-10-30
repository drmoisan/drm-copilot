# P3-T2 initialization handoff

Timestamp: 2026-10-18T14-14
Command: staged-byte task audit and ordered-gate receipt reconciliation
EXIT_CODE: 0
Output Summary: Only P3-T2 is offered for independent verification; no later task is implemented or released.

## Scope and baseline

Acceptance baseline remains a74cb240a7698c1454a8e6018ac23862cd91dab0, across projection WIP cba0ee0870018c1a2a57556be877ec1d7475ae08 and bootstrap WIP 667cb753aa512b518cd0625750dadaf1e11d89b4.
Exact source, test, template and generated paths with SHA-256, Git blobs and physical lines are recorded in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-final-inventory.2026-10-18T14-14.json.
Baseline Set C: 27 passing tests, legacy flow 36/36 lines (100%). The current thin adapter remains 100%; the relocated authoritative behavior is measured separately.
Accepted prior-path union: 218 paths; 215 outside the three explicitly owned prior overlaps are unchanged. All 24 frozen v1/export paths are unchanged. No new suppression or dependency was introduced; inherited ARG001 fixture suppressions are unchanged.

## Implementation and compatibility

InitializationRequest supplies explicit consumer identity, role, roots or explicit draft configuration. InitializationTemplates loads the six declared production resources with typed slots. plan_initialization constructs and structurally validates the complete immutable proposed graph with the accepted validator/mutation engine before effects.

InitializationCapture keeps physical absence, identities and bytes separate from the virtual proposal. InitializationIO performs root-only profile/bootstrap directory publication through the accepted native provider and retains opened identities through postcapture. Ordinary artifacts use exact existing mutation grants and guarded creation. commit_initialization requires exact physical bootstrap capture equality before the ordinary mutation stage.

InitializationConflict is a ValueError-compatible typed conflict carrying exact paths, statuses and findings. Partial failures preserve known effects and uncertainty and invalidate authority. force preserves valid existing bytes and never permits overwrite. Dry run performs no directory, artifact, activation, receipt or invalidation writes.

The legacy module remains a thin alias adapter. Existing helper, import, template diagnostic and CLI flag contracts are retained. Calls lacking explicit v2 identity/configuration and trusted I/O fail with actionable migration guidance; unchecked legacy FileSystem writes do not grant authority. Set C dispositions and the full scoped patch are in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t2-scoped-patch.2026-10-18T14-14.md.

The guarantee is cooperative serialization, optimistic complete-input freshness, exclusive creation and atomic individual publication. It is not kernel digest CAS or a multi-file transaction. Trusted host context, canonical external locks and native permitted-route authorization remain separate service integration responsibilities.

## Validation

The final ordered sequence is pass 14: formatting, scoped Ruff, full-repository Pyright, architecture, task unit/isolation tests, package/resource/schema compatibility, then real Windows integration. Exact per-command receipts remain under evidence/regression-testing; raw coverage and callable/class ranges are in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t2-coverage-audit-final.2026-10-18T14-12.json.

Forward: 92 passed in 738.59s (0:12:18). Reversed module order in one process: 92 passed in 298.48s (0:04:58).

| Module | Lines | Branch arcs | Line coverage | Branch coverage |
|---|---:|---:|---:|---:|
| packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py | 134/136 | 34/36 | 98.53% | 94.44% |
| packages/discovery-runtime/src/drm_copilot_discovery/init_io.py | 137/140 | 47/50 | 97.86% | 94.00% |
| packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py | 178/178 | 60/60 | 100.00% | 100.00% |
| scripts/dev_tools/discovery/init_flow.py | 2/2 | 0/0 | 100.00% | 100.00% |

Every measured new callable/class is at least 94.44% across 42 ranges. Maximum owned Python file length is 481 physical lines.
Role tests use actual planning and full structural/completion validation for source, target and combined. They assert exact five/six-file sets, null role pins, configured directories, structural pass and completion failure. Full writer tests cover real combined parity publication and source partial/repeat recovery. Narrow injected seams isolate error conditions without replacing the required full behavior cases.

Final native integration uses only a session-unique SCRATCH workspace. Eight real provider checks passed: dry-run absence, combined creation including parity/empty directories, honest null pin, structural success, completion failure, repeat/force preservation, typed prewrite conflict, and released handle/lock/stage cleanup. Per-operation timings are retained in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t2-windows-initialization.2026-10-18T14-11.json; this is scoped operational proof, not the later installed CLI/host proof.

## Retained failures and limitations

All failed and interrupted attempts remain evidence. The original four-case imported-old-source diagnostic is historical only; pass 10 passed 87 cases but failed two callable floors. Pass 12 was explicitly interrupted after 34 passing markers and supplies no final coverage. The narrow fixture failure and its correction remain separate receipts. Diagnostic statement mapping was never substituted for final current-byte coverage.

The inherited baseline command wrote the ignored pre-existing artifacts/python/lcov.info; its prior bytes were unknown and were not deleted or restored. Every later pytest command overrides addopts and uses explicit output paths.

Covered end-to-end initialization cases take multiple minutes. Final unit duration output and the uninstrumented required native smoke record this as a concrete test/runtime review limitation. No unrelated optimization or production cache was introduced. Repository-wide aggregate coverage and the installed host/CLI proof remain later plan-level gates.
Measured runtime: the covered forward suite took 738.59 seconds and the uninstrumented reversed suite 298.48 seconds. Partial/repeat recovery took 228.03 seconds with coverage and 92.88 seconds without it. First combined publication took 175.66 seconds with coverage, 74.80 seconds in memory without coverage, and 74.481 seconds through the real Windows provider. Native dry run took 10.565 seconds and repeat/force preservation took 46.038 seconds. The native evidence therefore establishes material ordinary runtime cost as well as instrumentation overhead; these observations are not a controlled benchmark.
The approved P11-T5 task owns the exhaustive deterministic property-test inventory for every new T2 pure function and the mutation trend; this task does not mark those feature-wide obligations N/A.

## Verification barrier

Source/test/resource bytes are frozen at this handoff. The coordinator owns exact staging of evidence, executor checkoff, and the required accepted-task commit. P3-T3 remains unreleased.
