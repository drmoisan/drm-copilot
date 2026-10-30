# P11-T5 T2 rigor: property tests, contract versioning, E2E, determinism and mutation trend

Timestamp: 2026-10-23T04-16
Command: poetry run python SCRATCH/issue-980-property-inventory.py SCRATCH/logs/p11t5-property-inventory.md; poetry run python SCRATCH/issue-980-mutation-trend.py 8 "path_policy:...;claim_rules:...;completion_rules:...;acceptance_rules:..." (staged copy of packages/discovery-runtime/src under SCRATCH/mutation-stage, owning test modules run against it through PYTHONPATH)
EXIT_CODE: 0 (inventory), 0 (mutation trend)
Output Summary: Property density: 690 of 700 pure public functions across 123 of 126 runtime modules are mapped to at least one deterministic property-style test; the three unmapped modules hold I/O boundary entries only (`evidence/other/t2-property-inventory.2026-10-23T04-16.md`). Mutation trend over the four staged rule modules with 8 deterministic mutants each (comparison-operator, boolean-operator and boolean-constant rewrites selected by fixed stride over the AST site list): path_policy 7 killed / 1 survived / 0 equivalent (87.5%), claim_rules 7 / 1 / 0 (87.5%), completion_rules 6 / 2 / 0 (75.0%), acceptance_rules 7 / 1 / 0 (87.5%); every module meets the T1 75% floor that T2 reports as trend only (`evidence/other/mutation-trend.2026-10-23T04-16.json` names each surviving site). Determinism retry rate 0.00%: no run in this task used a retry, rerun-on-failure or flaky-test mechanism, and every suite passed on its first execution in the loop that accepted it.

## Property tests (T2 obligation: at least one per pure function)

- Inventory method: `scripts`-free AST scan of `packages/discovery-runtime/src/drm_copilot_discovery`; a public function is pure when its body makes no file, process, environment, socket or clock call; a test is property-style when its name or docstring states an invariant class (property, permutation, idempotence, round trip, invariant, determinism, commutativity, associativity, monotonicity, reorder, shuffle) or it is parametrized over generated inputs, and it lives in a test module that imports the function's module.
- Gap closed in this task: `tests/discovery_runtime/test_t2_properties.py` adds digest-driven (seed-reproducible, no `random` module) property tests for `reference_links.string_value`, `runtime_claim_rules.has_text` and `environment_identity`, `validation_inputs.input_problem` and `service_request_rules.check_combinations`, which were the pure helpers with example tests only; 25 cases over five seeds pass.
- Remaining unmapped modules are I/O boundaries by construction (`init_models` filesystem protocol and real adapter, `service_bootstrap.bootstrap`, `service_inspection.inspect_request` and its bounded `read`), which are covered by the boundary and workflow suites rather than by properties.

## Contract-major obligation

- The v2 artifact schemas carry `schema_version` 2.0.0 and the frozen v1 schemas remain byte-identical; no schema in `schemas/discovery/v2` changed its `$id`, required set or enum after the P10-T3 wheel freeze, and the service-result contract is pinned by `tests/discovery_runtime/test_service_result_limits.py` and the P11-T1 result fixtures (`test_result_fixtures_follow_the_installed_result_schema`). `git log` from the P10-T3 wheel-freeze commit to HEAD lists no change under `schemas/discovery` or the staged `_resources/schemas`, so no breaking contract change exists after the freeze and no major bump is due; the wheel version is 2.0.0 as the P10-T3 record states.

## Core-path E2E

- The core paths run end to end in `tests/discovery_runtime/test_public_source_workflow.py` (14), `test_public_target_workflow.py` (7), `test_public_combined_workflow.py` (10) and `extensions/drm-copilot/test/discovery-public-workflow.test.ts` (8) through the real service rules and the real installed catalog, recorded in `evidence/regression-testing/discovery-public-workflows.2026-10-22T22-01.md`; the full populations re-ran in P11-T2 and P11-T3 and again in this task after the focused test additions (`coverage-comparison.<timestamp>.md`).

## Determinism (retry rate)

- Retry rate 0 of 15449 Python, 5013 root and 4996 extension Jest, and 12137 Pester executions: no retry or rerun plugin is configured (`pytest` has no rerun plugin, `run-jest.cjs` rejects `--passWithNoTests` and carries no retry, Pester runs with `Run.Exit` and no retry), and every accepted run passed on its first execution. The T2 threshold is a retry rate below 1%.

## Mutation trend (bounded, deterministic)

| Module | AST sites | Mutants run | Killed | Survived | Equivalent | Score | Surviving sites |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `path_policy` | 63 | 8 | 7 | 1 | 0 | 87.5% | `const:243:75` |
| `claim_rules` | 61 | 8 | 7 | 1 | 0 | 87.5% | `const:43:18` |
| `completion_rules` | 27 | 8 | 6 | 2 | 0 | 75.0% | `const:29:18`, `bool:75` |
| `acceptance_rules` | 90 | 8 | 7 | 1 | 0 | 87.5% | `const:65:18` |

- Mutants are applied one at a time to a staged copy of the package under SCRATCH (the tracked source is never modified); a mutant is equivalent when the rewritten tree is structurally identical to the original (no site rewritten), killed when the owning test modules fail, survived when they pass. The first run with a bytecode-equality equivalence check classified every `path_policy` mutant as equivalent because module bytecode does not include function bodies; the check was corrected to a structural tree comparison and the run repeated. The surviving `const:*:18` sites are the `frozen=True` flag of a `@dataclass` declaration in each module (immutability of the value object is not asserted by the owning tests, so the flipped flag changes no tested behavior); `path_policy` `const:243:75` is the `strict=True` argument of a root containment check and `completion_rules` `bool:75` is the `parity and (...)` conjunction of the parity gate, both of which the owning example tests do not distinguish. They are recorded as trend, not as a gate.
