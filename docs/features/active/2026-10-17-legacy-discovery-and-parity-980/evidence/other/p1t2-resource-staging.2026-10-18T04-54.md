# P1-T2 resource staging handoff

Timestamp: 2026-10-18T04-54
Command: poetry run python SCRATCH/issue-980-p1t2-task-audit.py
EXIT_CODE: 0
Output Summary: Ready for independent P1-T2 verification; 14 exact staged paths, 245 focused tests and 96 reversed-order tests passed, both new production modules have 100% line/branch coverage, and independent installed-resource smoke passed.

## Scope and implementation

Approved task P1-T2 only in plan.2026-10-17T22-38.md. The coordinator explicitly released this task after P1-T1 verification and retained the same validated specialist profile. No P1-T1 implementation, canonical policy, checkpoint, plan checkbox, or consuming repository was modified.

The canonical allowlist initially names seven existing v1 schemas. The builder rejects missing/extra canonical inputs, invalid roots, unresolved offline schema references, absent local imports, undeclared dependency imports, and extra generated files. Staging writes deterministic bytes plus a sorted SHA-256 manifest; --check writes nothing. Runtime resource loading uses importlib.resources and verifies version, closed manifest fields, path, size, and digest. The installed package has no checkout-resource lookup.

The I/O/CLI tests are split into test_build_discovery_runtime_io.py within the approved component to preserve the 500-line limit. Tests use in-memory readers/writers, mem_fs_path, and mocked process results; none creates temporary files or starts external processes.

## Exact changed paths

- `packages/discovery-runtime/resource-manifest.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/manifest.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/coverage-ledger.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/evidence-reference.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/feature-contract.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/parity-matrix.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/product-decision-record.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/runtime-characterization-scenario.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/_resources/schemas/discovery/v1/unspecified-behavior-record.schema.json`
- `packages/discovery-runtime/src/drm_copilot_discovery/resources.py`
- `scripts/dev_tools/build_discovery_runtime.py`
- `tests/discovery_runtime/test_resources.py`
- `tests/scripts/dev_tools/test_build_discovery_runtime.py`
- `tests/scripts/dev_tools/test_build_discovery_runtime_io.py`

## Ordered focused gates and operational proof

All command records are under evidence/regression-testing/. The final clean ordered pass is:

| Step | Actual result | Record |
| --- | --- | --- |
| Black --check | Exit 0; five files unchanged | p1t2-format-pass4.2026-10-18T04-50.md |
| Ruff | Exit 0; zero findings | p1t2-lint-pass4.2026-10-18T04-50.md |
| Full Pyright | Exit 0; zero errors/warnings | p1t2-types-pass4.2026-10-18T04-50.md |
| Focused Pytest | Exit 0; 245 passed | p1t2-tests-pass4.2026-10-18T04-50.md |
| Reversed new modules | Exit 0; 96 passed | p1t2-reversed-python-modules.2026-10-18T04-53.md |
| Tracked classification | Exit 0; 26 entries/26 projects | p1t2-tracked-classification.2026-10-18T04-53.md |
| Stage / check / wheel build | All exit 0 | p1t2-{stage,stage-check,wheel-build}.2026-10-18T04-51.md |
| Independent wheel install | Exit 0 | p1t2-wheel-install.2026-10-18T04-52.md |
| Isolated installed smoke | Exit 0 | p1t2-installed-smoke.2026-10-18T04-52.md |

The smoke used Python -I -S from an unrelated SCRATCH directory, excluded source/editable paths, and imported every current runtime module from the independent wheel installation. It read and verified all seven schema resources. The wheel contains exactly those seven files plus their generated manifest and includes py.typed. Its dependency metadata lists only PyYAML, jsonschema, referencing, and lxml.

The wheel is `drm_copilot_discovery-2.0.0-py3-none-any.whl`, SHA-256 `d24139d8de67ad5ae4aa81487e4fc79b66be3741e6f3171790c2f6e309de380e`, under SCRATCH/issue-980-p1t2-dist. The generated resource-manifest SHA-256 is `329dcc48c2bc145b4ecb61f62cefa348d81bbae39ca163eed7c0fef5a3316605`; stage/check/build reported the same digest and subsequent runs had no changed resources.

## Coverage, baseline, and change classification

The Phase 0 Python baseline remains the accepted zero-failure reference. Both production modules are newly authored, so there is no pre-existing per-file denominator. resources.py covers 103/103 lines and 34/34 branches; build_discovery_runtime.py covers 209/209 lines and 98/98 branches. All 312 new executable lines and 132 branch arcs are covered, including error paths. New functions/classes therefore have 100% measured coverage. No changed existing implementation or relocated implementation is part of P1-T2.

Six files are authored (two production modules, one allowlist, three test modules); eight files are generated (seven byte-identical frozen schemas plus the manifest). Generated copies are counted separately and not treated as new authored schema logic. All source/schema files remain within 500 physical lines; actual counts and the exact manifest are in the metrics JSON. No coverage threshold or exclusion changed. The pre-authorized S603 pattern is used only after shutil.which validates the active interpreter, with the exact policy-required comment.

Raw numerical coverage: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t2-coverage.2026-10-18T04-54.json`.

Coverage/path/line-count metrics: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t2-coverage-metrics.2026-10-18T04-54.json`.

## Corrections and environment

Initial formatting and seven long-string lint findings were corrected. Strict type checking identified entry-validation typing, mapping narrowing, referencing generic types, and untyped test callbacks; these were corrected without type suppression. A formatting-failed iteration was not accepted as a gate; the final complete pass restarted with Black. All failed command records remain available.

The project environment lacked the already-declared build backend. With coordinator authorization, `poetry-core>=1.9.0` was installed as an operational build prerequisite; actual version 2.5.0 is recorded in p1t2-build-prerequisite.2026-10-18T04-45.md. Runtime dependency declarations and the lockfile were not changed by this task. Build/install temporary outputs remain under SCRATCH.

One attempted test-file patch was rejected before mutation by the unit-test purity hook because it imported subprocess.CompletedProcess for a fake result. No separate rejection code was emitted. Message, with the absolute workspace prefix removed as required for evidence: `Python unit test purity violations in 'tests/scripts/dev_tools/test_build_discovery_runtime_io.py': subprocess execution forbidden in unit tests. Replace with pure code paths, dependency-injection seams, or in-memory fakes per .agents/skills/python/SKILL.md.` Zero files were mutated by that rejected call. Replacing the imported result with a local immutable fake retained the mocked process boundary; the compliant patch then passed without bypass or hook changes. An unrelated patch-context mismatch also mutated zero files and was corrected against the actual formatted source.

## Handoff boundary

TASK_READY_FOR_VERIFICATION applies only to P1-T2. The executor owns checkoff and the coordinator owns staging/checkpoints. No P1-T3 mutation begins before explicit release. Later schema/template tasks extend this same allowlist; this task does not claim the final v2/template closure, full operation surface, cross-platform operational smoke, or final repository-wide QA.
