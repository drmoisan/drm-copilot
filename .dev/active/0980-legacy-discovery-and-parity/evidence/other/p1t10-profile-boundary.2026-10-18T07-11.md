# P1-T10 profile boundary handoff

Timestamp: 2026-10-18T07-11
Command: poetry run python SCRATCH/issue-980-p1t10-task-audit.py
EXIT_CODE: 0
Output Summary: 9 exact staged paths; broad 1008 passed, final affected-caller 578 passed, reversed changed modules 123 passed; 571/572 lines and 143/144 branch arcs; no baseline regression.

## Exact scope

- packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py
- packages/discovery-runtime/src/drm_copilot_discovery/profile_models.py
- packages/discovery-runtime/src/drm_copilot_discovery/activation_models.py
- packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py
- scripts/dev_tools/validate_discovery_profile.py
- tests/discovery_runtime/test_profile_v2.py
- tests/discovery_runtime/test_profile_dimensions.py
- tests/scripts/dev_tools/test_validate_discovery_profile.py
- tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py

No source/test split, schema/resource edit, dependency addition, policy edit, plan/AC change or checkpoint mutation was needed. The coordinator owns staging; the executor owns acceptance.

## Delivered configuration boundary

ProfileV2/parse_profile_v2 validate exact v2 identity through the installed or injected offline catalog before exposing deeply immutable typed sections. Every configured field remains represented: system and repository identity, source/target references, clients, input/output roots, dimensions, runtime capability, analyzer options, exclusions, gates, approvers, extensions and finite limits. Direct public view construction requires a validated profile and a valid fixed-section index.

Local IDs must be unique. Clients bind to declared target repositories or a local target/combined repository; repository client links must agree with target ownership. Separate source and target pins remain distinct. Drafts preserve null revisions and absent roots/clients, and require_configured rejects them without claiming that configured state itself establishes completion. Runtime capability none does not remove declared characterization obligations.

requirements() forms sorted independent unions of global, selected-client and feature obligations. Required identifiers match the core grammar, and dimensions use its closed vocabulary. Offline/mobile are absent unless explicitly required. Applicability defaults cannot remove an inherited obligation. GatePolicy retains all eight configurable booleans and the planning prerequisite while exposing fixed mandatory claim-validity, evidence, exclusion-rationale and path-safety rules.

Configured extension declarations must match the exact namespace/path/SHA-256 of trusted caller-supplied catalog entries. Missing, mismatched and undeclared entries fail. The existing catalog validates the payload against the pinned schema. This pure parser does not load consumer extension files; the later root-controlled snapshot loader must obtain and validate declarations, load authorized pinned bytes, and construct the final catalog/profile before operations. No reduced validator or unchecked profile is exposed.

JSON Schema accepts integral numeric values such as 8.0 as integers. The four typed profile limits and analyzer max_file_bytes normalize only those schema-validated integer fields to Python int; original immutable document values remain unchanged. Fractional values and values beyond the finite ceilings fail before publication. Direct ProfileLimits construction still requires actual integer arguments.

ActivationLocator represents only the exact four-key closed locator. It rejects disabled/augmented/wrong-version documents and explicit profile-path disagreement. It grants no native authority. Filesystem containment/collision checks, candidate discovery, protected activation, graph evidence, completion and planning enforcement remain in their separately approved later tasks.

## Compatibility disposition

domain_profile retains the original exported objects and default v1 behavior. New schema_version='2.0.0' overloads dispatch lazily to the authoritative parser; unrecognized versions never trigger probing or fallback. The import remains lazy to preserve fresh package initialization and nonparticipant behavior. Four contract-documented overload declarations preserve static result types.

The placeholder validate_profile_text check is replaced with authoritative v2 parsing, with trusted explicit schema_version='1.0.0' compatibility. The named Set B profile tests now exercise actual required fields and complete profiles. Dispatcher changes are limited to its three obsolete profile-dependent assertions; its later all/workspace dispatch redesign is untouched. The advanced v2 parser accepts a pinned catalog for extension-bearing profiles.

Frozen v1 schemas, examples, invalid fixtures and the existing export asserting test remain unchanged from HEAD (24 paths). The v1 profile asserting test retains its accepted P1-T1 hash, including that earlier import-only relocation. Of the prior accepted task paths, only the approved domain_profile.py and profile-related dispatcher test changed. All 151 other accepted paths retain their recorded SHA-256.

## Verification

Phase 0 remains 7,336 passed, six existing skips, zero failures, with repository line coverage 94.111715% and branch coverage 88.783742%. Final repository-wide QA remains assigned to the final feature phase.

Pass 8 ran all discovery-runtime tests, existing discovery callers and both named adapter/dispatcher suites: 1008 passed. Its source remained unchanged for the full run. After adding only the four overload docstrings, clean pass 10 ran Black, Ruff, full Pyright and all changed profile/compatibility tests, package-identity tests and existing discovery callers: 578 passed, no failures. All four changed test modules then passed in reversed module order: 123 cases.

| Production file | Covered lines | Covered branch arcs | Prior line percent |
| --- | --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/activation_models.py | 28/28 | 4/4 | new |
| packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py | 202/203 | 81/82 | 99.47368421052632 |
| packages/discovery-runtime/src/drm_copilot_discovery/profile_models.py | 173/173 | 20/20 | new |
| packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py | 150/150 | 32/32 | new |
| scripts/dev_tools/validate_discovery_profile.py | 18/18 | 6/6 | 100.0 |

All three new modules and the replacement adapter have 100% line/branch coverage. The existing v1 parser retains its one pre-existing uncovered missing-sentinel helper path; its line and branch percentages improve. Every new or changed callable/class reaches at least 90%, with actual ranges in the numerical artifact; unchanged legacy helpers retain their baseline obligations. The existing standalone-ellipsis coverage convention applies to the documented typing overload stubs; no suppression/configuration change was introduced.

Resource closure passes for all 33 resources; tracked classification passes all 26 projects. Staged bytes match the exact nine-path inventory, staged whitespace is clean, required production docstrings exist, and maximum owned size is 475 physical lines. Numerical evidence includes final file SHA-256 values.

Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t10-coverage.2026-10-18T07-11.json
Scope, baseline, per-file/per-unit coverage and hashes: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t10-coverage-metrics.2026-10-18T07-11.json

## Corrections and retained failures

The executor's bounded review found a fresh-import cycle, overly broad feature-requirement vocabulary, and schema-valid integral numbers that caused delayed typed-property errors. Lazy compatibility imports, exact identifier/dimension validation and normalized integer projections fixed these within the approved files. Tests cover all cases. The verifier independently reported nine focused corrections and then 93 public-boundary probes passing before final task acceptance.

Initial Black formatting was retained in evidence. Ruff found TC001, B010 and E501 diagnostics; imports, dynamic mutation-test attribute names and concise text resolved them without suppressions. Full Pyright found one partially unknown malformed-activation list value; an explicitly typed object table corrected it. One pytest command named a nonexistent helper-test path and exited 4 with zero tests collected; the corrected command used the actual scoped paths. The final overload-docstring edit required Black formatting, then the full ordered pass restarted. The first final audit incorrectly compared the already-retargeted P1-T1 profile asserting test to HEAD; the corrected audit uses its accepted prior-task hash. No source/test change or rerun resulted from that audit correction. All failed attempts remain below.

Canonical per-command records:
- p1t10-black-docstrings.2026-10-18T07-06.md
- p1t10-black-pass1.2026-10-18T06-56.md
- p1t10-black-pass10.2026-10-18T07-06.md
- p1t10-black-pass2.2026-10-18T06-57.md
- p1t10-black-pass3.2026-10-18T06-58.md
- p1t10-black-pass4.2026-10-18T06-58.md
- p1t10-black-pass5.2026-10-18T06-59.md
- p1t10-black-pass6.2026-10-18T06-59.md
- p1t10-black-pass7.2026-10-18T06-59.md
- p1t10-black-pass8.2026-10-18T07-00.md
- p1t10-black-pass9.2026-10-18T07-06.md
- p1t10-pyright-pass10.2026-10-18T07-07.md
- p1t10-pyright-pass6.2026-10-18T06-59.md
- p1t10-pyright-pass7.2026-10-18T06-59.md
- p1t10-pyright-pass8.2026-10-18T07-00.md
- p1t10-resources.2026-10-18T07-07.md
- p1t10-ruff-pass10.2026-10-18T07-06.md
- p1t10-ruff-pass3.2026-10-18T06-58.md
- p1t10-ruff-pass4.2026-10-18T06-58.md
- p1t10-ruff-pass5.2026-10-18T06-59.md
- p1t10-ruff-pass6.2026-10-18T06-59.md
- p1t10-ruff-pass7.2026-10-18T06-59.md
- p1t10-ruff-pass8.2026-10-18T07-00.md
- p1t10-task-audit.2026-10-18T07-11.md
- p1t10-tests-pass10.2026-10-18T07-09.md
- p1t10-tests-pass7.2026-10-18T07-00.md
- p1t10-tests-pass8.2026-10-18T07-05.md
- p1t10-tests-reversed.2026-10-18T07-10.md
- p1t10-tracked-tiers.2026-10-18T07-07.md

No P1-T11 implementation has begun. Task completion remains subject to executor verification and coordinator release.
