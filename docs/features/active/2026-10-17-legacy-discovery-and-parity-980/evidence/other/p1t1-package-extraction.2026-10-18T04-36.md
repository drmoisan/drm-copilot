# P1-T1 package extraction handoff

Timestamp: 2026-10-18T04-36
Command: Review approved P1-T1 implementation, staged diff, and recorded focused gates
EXIT_CODE: 0
Output Summary: Ready for independent task verification; 26 owned implementation/test/configuration paths staged, 532 focused tests passed, 268 reversed-order tests passed, no per-file coverage regression, and tracked classification passed. This does not mark the task or feature complete.

## Scope and authority

Plan: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md`, task P1-T1 only. Work Mode is full-feature. The coordinator released this task after all Phase 0 baselines were verified and staged the exact 26 paths below before the tracked classification command. No commit, plan checkbox, acceptance-criteria checkbox, canonical policy, orchestration checkpoint, or consuming repository was changed by this worker.

The actual SubagentStart attestation was verified before mutation: agent `01a14d2e-b666-71c3-a32b-7ba9e2a934e0`, profile `.codex/agents/python-typed-engineer-c4.toml`, SHA256 `0d02ca1f9b97abd4d84120f9443359404ab6ef4d094a1b97d520381fb1f9edd6`, expected/actual model `gpt-6-astra`, reasoning `max`, routing/launch/provenance valid. The coordinator persisted the `runtime_foundation_execute` routing receipt for the same exact profile.

## Implementation and compatibility

`packages/discovery-runtime` now defines the installable `drm-copilot-discovery` 2.0.0 package with Python `>=3.10,<4.0` and the approved PyYAML, jsonschema, referencing, and lxml runtime dependencies. Root development tooling installs this package and includes its source in type and coverage checks. The `py.typed` marker is present. Existing dependency versions remain unchanged; schema-validation dependencies are included in the runtime dependency closure.

The existing v1 profile parser, frozen value models, filesystem interface, artifact I/O, and deterministic rendering were relocated once into `drm_copilot_discovery`. The six old modules are thin direct-import adapters. Compatibility tests prove object identity for all package exports and module adapter exports and reject duplicated public implementations. Explicit public re-exports preserve strict typed-package compatibility. The rendering signature preserves caller row types without explicit `Any` in the T2 package.

`resolve_default_template_root` deliberately remains in the old `scripts/dev_tools/discovery/init_models.py` adapter. Its existing `__file__.parents[3]` anchor is valid only in that checkout location; copying it into the installed package would change its observable result. A strengthened test proves its exact repository-relative result `docs/discovery/templates`. Canonical runtime modules do not import repository tooling. Installed schema/template resource lookup remains P1-T2, and the replacement initializer remains P3-T2.

The existing quality-tier discovery rule now recognizes tracked `pyproject.toml` manifests alongside package.json and project/module manifests. Root/nested/duplicate-order/near-name cases and all existing exclusion classes are tested. All 25 previous manifest rows and their rationales are unchanged; the sole addition is `packages/discovery-runtime` at T2. The live staged check found 26 entries and 26 projects with no QT007/QT008 finding.

## Exact owned changed paths

The staged diff for these paths is the reviewable implementation patch. The machine-readable path inventory is also preserved in `evidence/regression-testing/p1t1-coverage-metrics.2026-10-18T04-34.json`.

- `packages/discovery-runtime/pyproject.toml`
- `packages/discovery-runtime/README.md`
- `packages/discovery-runtime/src/drm_copilot_discovery/__init__.py`
- `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py`
- `packages/discovery-runtime/src/drm_copilot_discovery/domain_profile_models.py`
- `packages/discovery-runtime/src/drm_copilot_discovery/init_models.py`
- `packages/discovery-runtime/src/drm_copilot_discovery/io.py`
- `packages/discovery-runtime/src/drm_copilot_discovery/rendering.py`
- `packages/discovery-runtime/src/drm_copilot_discovery/py.typed`
- `tests/discovery_runtime/test_package_contract.py`
- `pyproject.toml`
- `poetry.lock`
- `quality-tiers.yml`
- `scripts/dev_tools/quality_tiers_contract.py`
- `scripts/dev_tools/discovery/__init__.py`
- `scripts/dev_tools/discovery/domain_profile.py`
- `scripts/dev_tools/discovery/domain_profile_models.py`
- `scripts/dev_tools/discovery/init_models.py`
- `scripts/dev_tools/discovery/io.py`
- `scripts/dev_tools/discovery/rendering.py`
- `tests/scripts/dev_tools/test_quality_tiers_contract.py`
- `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py`
- `tests/scripts/dev_tools/discovery/test_domain_profile.py`
- `tests/scripts/dev_tools/discovery/test_init_models.py`
- `tests/scripts/dev_tools/discovery/test_io.py`
- `tests/scripts/dev_tools/discovery/test_rendering.py`

## Existing assertion dispositions

Set A profile, I/O, rendering, and initializer-model tests now exercise canonical imports while preserving invalid-input, default, v1 value, deterministic output, and failure-propagation assertions. `test_package_exports.py`, `test_profile_cli.py`, and `test_domain_neutrality.py` remain unchanged and passed. The full existing discovery test directory also ran, covering initializer-flow, CLI, reports, and analyzer callers of the relocated modules. Frozen v1 schemas, examples, fixtures, and schema tests are unchanged. The new package contracts test export identity, absence of duplicate models or repository imports, approved metadata, and deterministic mapping/row/input properties. No temporary-file or subprocess unit tests were added; operational helpers and coverage outputs use SCRATCH.

## Baseline and clean ordered gate

Phase 0 records are `evidence/baseline/python-{format,lint,types}.2026-10-18T03-49.md`, `python-tests.2026-10-18T03-51.md`, and the matching coverage JSON/metrics. The full baseline passed 7,336 tests with six existing skips; repository line coverage was 94.111715% and branch coverage 88.783742%. Baseline per-file coverage is the comparison source for this task.

The final focused pass was run in the required order without changes or failure between its steps:

| Step | Actual result | Evidence under `evidence/regression-testing/` |
| --- | --- | --- |
| Black --check on all touched Python source/tests | Exit 0; 20 files unchanged | `p1t1-format-pass4.2026-10-18T04-31.md` |
| Ruff check on all touched Python source/tests | Exit 0; zero findings | `p1t1-lint-pass4.2026-10-18T04-31.md` |
| Full repository Pyright | Exit 0; zero errors/warnings | `p1t1-types-pass4.2026-10-18T04-31.md` |
| Focused Pytest with line/branch coverage | Exit 0; 532 passed, zero failures/skips | `p1t1-tests-pass4.2026-10-18T04-32.md` |
| Reversed changed Python module order | Exit 0; 268 passed | `p1t1-reversed-python-modules.2026-10-18T04-33.md` |
| Tracked quality-tier classification | Exit 0; 26 entries/26 discovered projects | `p1t1-tracked-classification.2026-10-18T04-32.md` |
| Dependency lock validation | Exit 0; existing Poetry metadata deprecation warnings | `p1t1-lock-integrity.2026-10-18T04-32.md` |
| Scope/coverage/lock/tier/frozen-fixture audit | Exit 0; zero findings | `p1t1-task-audit.2026-10-18T04-34.md` |

`poetry lock` and `poetry install --no-root` both passed; the latter installed the local runtime without updating or removing another package. Their records are `p1t1-dependency-lock.2026-10-18T04-27.md` and `p1t1-package-install.2026-10-18T04-27.md`. No dependency upgrade or Poetry metadata modernization was introduced.

## Numerical coverage and change classification

Detailed numerical proof, raw coverage, and metrics are `evidence/regression-testing/p1t1-coverage-proof.2026-10-18T04-34.md`, `p1t1-coverage.2026-10-18T04-34.json`, and `p1t1-coverage-metrics.2026-10-18T04-34.json`.

- Relocated canonical profile parser: 189/190 executable lines, 99.473684%; 77/78 branches, 98.717949%. Original baseline: 188/189 lines, 99.470899%; 77/78 branches, 98.717949%. The one unexecuted existing parser error path is unchanged.
- Other canonical modules: 100% measured lines and branches where branches exist. Relocated implementations are compared against their original module paths, not treated as entirely new authored logic.
- Six compatibility adapters: 100% measured lines. Their export identity and absence of copied semantics are separately asserted.
- Changed existing quality-tier core: 191/191 lines and 78/78 branches, both 100%, equal to baseline. Both outcomes of the changed manifest condition are covered.
- Insertion/replacement executable lines across the compared source: 31/31 covered, 100%; changed branch arcs: 2/2 covered, 100%. This count includes import/export and typed-boundary edits and excludes unchanged relocated lines.
- No new semantic runtime class or function was introduced; the package metadata, compatibility import declarations, and package contract/property tests are newly authored. Generated code/resource copies: zero at this task boundary.
- All 13 changed production files exceed the applicable line/branch floors, all per-file deltas are nonnegative, and runtime explicit-Any count is zero. The maximum physical source/test length is 452 lines.

The initializer protocol's documented ellipsis stubs now match the existing coverage exclusion rules, changing its non-executable stub branch denominator from 12 to zero. Executable filesystem methods remain fully covered; no exclusion or threshold was changed. Final repository-wide totals and the complete multi-language QA gate remain mandatory in the later final-validation phase; this task makes no claim that those final gates have run.

## Corrections and rejected operations

The initial Black run formatted two files. Ruff then reported an unquoted cast type, one overlong test assertion, and two import-order findings. Those were corrected; a subsequent Black check requested the assertion layout adjustment. Full Pyright then reported ten owned-file diagnostics: seven missing explicit public re-export declarations, two empty-collection typing diagnostics, and one injected callback parameter-name mismatch. Explicit exports and test typing/signature corrections resolved them. The loop restarted at Black after each correction; all failed-step records remain in `evidence/regression-testing/`.

An earlier shell attempt to write the approved legacy adapter files was rejected before execution. Code: `PROMOTION_MCP_ONLY_BLOCKED`. The registered rejection text matching the returned reason is:

> PROMOTION_MCP_ONLY_BLOCKED: Direct GitHub issue creation via `gh` bypasses the approved drm-copilot MCP promotion path (`mcp__drm-copilot__new_potential_entry` -> `mcp__drm-copilot__potential_to_issue` -> `mcp__drm-copilot__new_active_feature_folder`). Use those MCP tools instead.

The intended action was an adapter-file write, not issue creation; the command's embedded apostrophe quoting was unsuitable. Zero files were mutated by that rejected call. The coordinator recorded the incident, no hook was modified, and no bypass was used. Structured `apply_patch` performed the authorized edits. One delete/add-same-path patch was also rejected as an invalid multiple-operation patch before mutation; a valid update patch was then used.

The first operational lock-command helper could not write its evidence because the canonical regression-testing directory did not yet exist. The command itself completed, but that attempt did not supply acceptable proof. After creating the canonical directory, the lock command was rerun successfully and its proper write-time evidence retained. No failed or missing evidence was treated as a passing gate.

## Handoff boundary

TASK_READY_FOR_VERIFICATION applies only to P1-T1. The coordinator and atomic executor receive this evidence and the exact path inventory. The executor owns checkoff; the worker waits for its verification and the coordinator's explicit P1-T2 release before any next-task mutation. Resource staging, v2 contracts, security corrections, schemas, later CLI/host wrappers, and final feature review are not claimed complete here.
