# Feature Audit — legacy-discovery-acceptance-scenarios (#364)

- Timestamp: 2026-07-18T11-52
- Reviewer: feature-review agent
- Branch: `feature/legacy-discovery-acceptance-scenarios-364` (head `688c99dd`) vs `origin/epic/legacy-discovery-and-parity-integration` (merge base `f18c1c16`)
- Work mode: `full-feature` (`issue.md` line 12: `- Work Mode: full-feature`)
- AC sources: `spec.md` (12 items) and `user-story.md` (8 items)
- Verification methods: direct code reading, branch-diff inspection, re-execution of the feature test file (`poetry run pytest tests/scripts/dev_tools/test_generate_acceptance_scenarios.py -q` → 34 passed), LCOV parse of `artifacts/python/lcov.info`, and feature evidence artifacts under `evidence/`.

## spec.md Acceptance Criteria

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| S1 | Module `scripts/dev_tools/generate_acceptance_scenarios.py` generates scenarios from the three inputs | PASS | Module present in diff (492 lines); `build_document` (line 328) consumes feature-contract, parity-matrix, and runtime-characterization documents; `test_positive_generation_maps_given_when_then` passes. |
| S2 | Output document has top-level `$schema`, `schema_version`, `generator`, `source_digest`, `scenarios`; scenario objects carry `id`, `title`, `feature_ref`, `parity_ref`, `characterization_ref`, `given`, `when`, `then`, `evidence_refs` | PASS | `build_document` return dict (lines 349–357) and `assemble_scenarios` scenario dict (lines 293–307) contain exactly these keys; `test_positive_generation_top_level_fields` asserts the exact top-level key set. |
| S3 | Given/When/Then emitted as structured string arrays, not Gherkin text | PASS | `given`/`when`/`then` are `list[str]` built from tuple projections (lines 282–304); `test_positive_generation_maps_given_when_then` asserts list-of-strings content. No Gherkin serializer exists in the module. |
| S4 | Canonical serialization `json.dumps(sort_keys=True, indent=2, ensure_ascii=False) + "\n"`; byte-identical for identical inputs | PASS | `format_document` (line 362) is the exact idiom; `test_determinism_byte_identical_repeat` asserts equal bytes across two generations and a single trailing newline. |
| S5 | Output invariant to input ordering; `scenarios` sorted by stable total-order key; input paths sorted before processing | PASS | Sort key `(feature_ref, parity_ref, characterization_ref, id)` (lines 235–242, 345–348); `collect_input_paths` sorts by POSIX form (line 371); `test_determinism_invariant_to_input_ordering` and `test_cli_collect_input_paths_sorted` pass. |
| S6 | No seeded RNG, no injected clock; `source_digest` is SHA-256 over canonicalized inputs; no wall-clock value in output | PASS | No `random`/`datetime`/`time` import in the module (verified by reading lines 10–21); `compute_source_digest` (lines 311–325) is SHA-256 over canonical JSON; `test_determinism_source_digest_stable` asserts 64-char lowercase hex, stability, and content-sensitivity. |
| S7 | Each input read through a named projection/adapter; #9002 field-name change touches only the adapter | PASS | `project_feature_contract` (line 142), `project_parity_matrix` (line 159), `project_runtime_characterization` (line 185) are the only field-name readers; generation logic consumes typed projections only; `test_projection_adapters_ignore_unknown_fields` verifies unknown-field tolerance. |
| S8 | Single `resolve_discovery_schema(schema_name, *, root, version=None) -> Path` seam; clear error naming `schemas/vN/` pre-#9002; generator runs against caller-supplied paths in the interim | PASS | Seam at lines 36–60 with the exact signature; error message names `schemas/v<version>/<schema_name>.schema.json`; `test_seam_raises_naming_convention_when_tree_absent`, `test_seam_keyword_only_parameters`, `test_seam_returns_path_when_schema_present` pass; CLI success tests run without any schema tree present (`test_cli_main_success_stdout`). |
| S9 | Poetry console-script `dev.discovery.generate-acceptance-scenarios` → `scripts.dev_tools.generate_acceptance_scenarios:main`; module exposes `def main(argv=None) -> int` with own argparse parser | PASS | `pyproject.toml` diff adds exactly `"dev.discovery.generate-acceptance-scenarios" = "scripts.dev_tools.generate_acceptance_scenarios:main"` in `[tool.poetry.scripts]`; `main(argv: Sequence[str] | None = None) -> int` (line 467) and `parse_args` building its own `ArgumentParser` (lines 414–447). |
| S10 | `0`/`1` exit-code convention: 0 success, 1 any failure incl. missing/malformed input and `--check` mismatch | PASS | `main` returns 0/1 only; four negative-input parametrized cases plus `--check` mismatch/requires-output/target-absent all assert exit code 1 with a message (`test_negative_inputs_return_one_with_message`, `test_cli_check_*`); success paths assert 0. Argparse usage errors exit 2 per standard argparse semantics — matches the reference modules; recorded as non-blocking observation CR-2 in the code review. |
| S11 | No TaskMaster/TMW/Outlook/VSTO/email/task-management identifiers in the generator | PASS | `grep -i` over the module during this review: zero matches; self-enforcing test `test_domain_neutrality_module_source_and_output_fields` scans module source and output field names on every run. |
| S12 | Tests cover positive, determinism, negative/malformed, seam, and CLI; no temp files (use `mem_fs_path`); line >= 85% and branch >= 75% | PASS | All five categories present (see test-file section groupings); no `tmp_path`/`tempfile` usage — all path tests use `mem_fs_path`; module coverage 100% line (186/186) and 100% branch (42/42) parsed from `artifacts/python/lcov.info`; repo-wide Python 88.27% line / 79.08% branch (strict LCOV) — both above thresholds. 34 tests re-executed during this review: all pass. |

## user-story.md Acceptance Criteria

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| U1 | Module generates scenarios from the three inputs | PASS | Same evidence as S1. |
| U2 | Single JSON document with the five top-level fields; scenarios carry structured `given`/`when`/`then` string arrays | PASS | Same evidence as S2 + S3. |
| U3 | Deterministic: byte-identical for identical inputs; invariant to input ordering | PASS | Same evidence as S4 + S5. |
| U4 | Output format defined in spec.md and domain-neutral | PASS | spec.md "Output Scenario Format" defines the document and scenario field tables; domain-neutrality per S11. |
| U5 | Console-script exposes generator with `def main(argv=None) -> int`, own argparse parser, `0`/`1` convention | PASS | Same evidence as S9 + S10. |
| U6 | Schema-location seam behind single `resolve_discovery_schema(...)`; clear error naming `schemas/vN/` pre-#9002 | PASS | Same evidence as S8. |
| U7 | Each input schema read through a named projection/adapter | PASS | Same evidence as S7. |
| U8 | Tests cover positive/determinism/negative/seam/CLI; no temp files; line >= 85%, branch >= 75% | PASS | Same evidence as S12. |

## Check-Off Reconciliation

All 12 spec.md AC items and all 8 user-story.md AC items were already checked `[x]` by the executor. This audit independently re-verified each item and confirms every check-off; no item required unchecking, and no new check-offs were needed. The criterion texts are unmodified between the base and head (diff inspection of `spec.md`/`user-story.md` shows checkbox-state and content updates consistent with the delivered work).

Note: `issue.md` retains an unchecked "Acceptance Criteria (early draft)" section. Under `full-feature` work mode, `issue.md` is not an AC source; the authoritative sources are `spec.md` and `user-story.md`. The draft-section state is informational only and not a finding.

## Baseline-Relative Assessment

- The branch is purely additive relative to `origin/epic/legacy-discovery-and-parity-integration`: no pre-existing production or test file is modified; the only shared-file change is one additive `pyproject.toml` console-script line.
- Baseline toolchain state (all EXIT_CODE 0) recorded in `evidence/baseline/`; final state (all EXIT_CODE 0, 1679 → 1713 tests) recorded in `evidence/qa-gates/`. Total line coverage rose 88.07% → 88.27%; no changed-line regression is possible on unmodified files.
- Fail-before basis: `evidence/regression-testing/fail-before-exception.2026-07-17T14-37.md` documents the absence-of-module proof (new module and test file did not exist pre-implementation), which is the accepted exception form for net-new modules.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-acceptance-scenarios-364/user-story.md`
- Total AC items: 20 (12 spec + 8 user-story)
- Checked off (delivered): 20
- Remaining (unchecked): 0
- Items remaining: none

## Verdict

All 20 acceptance criteria: PASS. Blocking findings in this artifact: 0.
