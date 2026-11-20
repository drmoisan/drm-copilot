# P3-T1 report-root prerequisite correction

Timestamp: 2026-10-18T11-33
Command: poetry run python SCRATCH/issue-980-p3t1-report-root-audit.py
EXIT_CODE: 0
Output Summary: 38 affected-module tests and 5 reversed affected-group isolation tests pass; unchanged module/callable coverage is 100%; two exact paths staged; 209 other accepted paths and 24 frozen paths unchanged.

## Scope and authority

Only `packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py` (179 lines) and `tests/discovery_runtime/test_validation_modes.py` (355 lines) changed. The `artifact_graph_report_root_correction` routing receipt authorizes this P3-T1 prerequisite correction. Actual external agent 01a14d8e-6d30-70b1-b8f6-cfb8502f0f28 remains python-typed-engineer-c4, gpt-6-astra/max, profile SHA 0d02ca1f9b97abd4d84120f9443359404ab6ef4d094a1b97d520381fb1f9edd6; routing/provenance/launch were rechecked true. No P3 worker files, prior historical evidence, plan, AC, checkpoint, dependency or suppression changed. Only the coordinator stages.

## Correction and tests

`report_input_digest` now excludes the exact configured reports directory from missing-path identity as well as its descendants. It retains segment-boundary matching, so neighboring paths and genuine missing source inputs remain semantic inputs. The public API and full snapshot hashing are unchanged.

```diff
- report_root = snapshot.profile.artifacts["reports"] + "/"
+ report_root = snapshot.profile.artifacts["reports"]
- if not path.startswith(report_root)
+ if path != report_root and not path.startswith(report_root + "/")
```

The unchanged file filter appends `/` at its use site. The existing recomputation test now covers initialized root, absent root, and absent report descendant, with equality before/after captured report creation, full snapshot inequality, successful recomputation and rejection of a falsified result. A new parameterized test proves missing `src/missing.cs` and a sibling `reports-neighbor/input.json` remain bound. All fixtures are immutable snapshots over fresh in-memory data; no unit test uses temporary files, processes or network.

## Baseline and gates

Accepted P2-T9 baseline: Black/Ruff/full Pyright clean, 107 focused and 107 reverse-order tests; validation_inputs 51/51 lines and 22/22 arcs; report_input_digest 7/7 lines. Historical P2-T9 acceptance is preserved.

Correction pass 1: scoped Black/Ruff and full Pyright pass; 38 focused tests and 5 reversed affected-group tests pass. Current module coverage is 51/51 lines and 22/22 arcs; all 3 measured callable ranges are 100%, including report_input_digest 7/7. Lint/type/failure deltas are zero and module/callable coverage is unchanged at 100%. The two frozen hashes and staged contents are unchanged; all 209 other accepted source/test paths and 24 frozen v1/export paths retain their accepted hashes. Repository-wide final QA remains Phase 11.

Original failing first-report composition is retained in `p3t1-executor-report-root-review.2026-10-18T11-23.{json,md}`; initialized-root positive in `p3t1-executor-report-initialized.2026-10-18T11-24.{json,md}`; unchanged absent-root probe passes on this correction in `p3t1-executor-report-root-corrected.2026-10-18T11-30.{json,md}`. The independent executor owns final integration acceptance.

Source SHA256: `147b363fbf5f1041ce79dc40e3b9c10d1ba3aab41be007a9b06cce8df8b4cda2`.
Test SHA256: `ce23a61febdf5a085a515cd350296ed86b7decef00ffac631d6d381897fdfaed`.
Metrics: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t1-report-root-metrics.2026-10-18T11-33.json`.
Raw coverage: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t1-report-root-coverage.2026-10-18T11-33.json`.
Separate command receipts: `evidence/regression-testing/p3t1-report-root-*.md`.

TASK_READY_FOR_VERIFICATION. No additional implementation is authorized or performed.
