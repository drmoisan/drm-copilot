# Code Quality Review — legacy-discovery-acceptance-scenarios (#364)

- Timestamp: 2026-07-18T11-52
- Reviewer: feature-review agent
- Branch: `feature/legacy-discovery-acceptance-scenarios-364` (head `688c99dd`) vs `origin/epic/legacy-discovery-and-parity-integration`
- Files reviewed:
  - `scripts/dev_tools/generate_acceptance_scenarios.py` (new, 492 lines)
  - `tests/scripts/dev_tools/test_generate_acceptance_scenarios.py` (new, 488 lines)
  - `pyproject.toml` (+1 additive `[tool.poetry.scripts]` line)

## Overall Assessment

The module is a well-structured pure transform with a thin CLI wrapper. Design follows the repository reference modules (`validate_json.py`, `format_json.py`) as the spec requires. No blocking code-quality findings. Four non-blocking observations are recorded below.

## Design and Structure

- **Separation of concerns**: pure logic (projections, `assemble_scenarios`, `build_document`, `derive_scenario_id`, `compute_source_digest`, `format_document`) is fully separated from I/O (`_load_json_document`, `_generate_from_args`, `_run_check`, `main`). The transform is testable without the filesystem, and the tests exercise it that way (`build_document` called directly with in-memory dicts).
- **Value objects**: the four read surfaces are `@dataclass(frozen=True)` with tuple-typed fields (lines 77–121), preventing accidental mutation and making projections hashable/comparable. Appropriate class-vs-function split per `.claude/rules/python.md`.
- **Seam quality**: `resolve_discovery_schema` (line 36) is the single schema-location authority; `resolve_schema_self_ref` (line 63) routes `$schema` through it with a documented pre-#9002 fallback to the convention constant. The test `test_seam_downstream_calls_resolver` monkeypatches the seam at the import location used by the unit under test, proving downstream code depends on the seam and not a literal path.
- **Adapter isolation**: each projection function reads only the documented fields and ignores unknown keys (verified by `test_projection_adapters_ignore_unknown_fields`), so a #9002 field-name change touches only the adapter.
- **Public surface**: small and explicit; internal helpers are `_`-prefixed (`_require_str`, `_string_tuple`, `_scenario_sort_key`, `_load_json_document`, `_generate_from_args`, `_run_check`).

## Error Handling

- Single specific exception (`GenerationError`) for expected failures; `FileNotFoundError` for the seam, with a message that names the expected convention and the resolved candidate path plus a corrective action. This satisfies fail-fast-with-specific-errors.
- The only broad-boundary catch is `except GenerationError` in `main` (line 474) — narrow, at the CLI boundary, translated to exit code 1 with a message. `except FileNotFoundError` in `resolve_schema_self_ref` (line 72) is an intentional documented fallback branch, covered by `test_seam_falls_back_to_convention_when_absent`.
- Diagnostics carry context (`f"{context}: required field '{key}' ..."`, row/scenario indexes), giving actionable failure messages.

## Determinism

- No `random`, `datetime`, or `time` import anywhere in the module (verified by reading the import block).
- `source_digest` is SHA-256 over `json.dumps(..., sort_keys=True)` canonicalizations (lines 311–325); scenario `id` is SHA-256-derived from input references only (lines 220–232).
- The `scenarios` array is sorted by the total-order key `(feature_ref, parity_ref, characterization_ref, id)` (lines 235–242, 345–348); parity rows and characterization scenarios are sorted before combination (lines 258–269); the internal `set` for `evidence_refs` is converted via `sorted(set(...))` before serialization (line 305) — a set is never serialized directly.
- Serialization uses the canonical repository idiom `json.dumps(sort_keys=True, indent=2, ensure_ascii=False) + "\n"` (line 362).
- Verified behaviorally: determinism tests assert byte-identical repeat and ordering invariance; full test file re-run during this review: 34 passed.

## Domain Neutrality

- `grep -i "taskmaster|tmw|outlook|vsto|email|task-management"` over the module: zero matches (verified during this review, exit 1 = no match).
- The self-enforcing test `test_domain_neutrality_module_source_and_output_fields` re-checks both the module source and every generated output field name on every run, which keeps the invariant durable.

## File Size, Naming, Typing

- 492 / 488 lines — both under the 500-line limit (verified with the working tree; matches `evidence/other/file-size-check.2026-07-17T14-37.md`).
- PEP 8 naming throughout; constants in `CONSTANT_CASE`.
- Full annotations on all public functions; `Any` confined to JSON-boundary `dict[str, Any]` with `cast()` isolation; pyright-final evidence records 0 errors/warnings.

## Public-API Compatibility

- All additions are new symbols; no existing module, function signature, or console-script is modified. The `pyproject.toml` change is one additive quoted-dotted-key line in `[tool.poetry.scripts]`, inserted in alphabetical order alongside `dev.discovery.profile`, matching the established `dev.<name> = "scripts.dev_tools.<module>:main"` form. No breaking-change surface.

## Observations (all Non-blocking)

| # | Severity | Observation | Location |
|---|---|---|---|
| CR-1 | Non-blocking | `main(argv or sys.argv[1:])` (line 469): an explicitly passed empty list is falsy and falls back to `sys.argv[1:]`. Benign here because all three input arguments are `required=True` (argparse would reject an empty argv anyway), and the pattern is mandated verbatim by spec.md "API / CLI Surface". Consider `argv if argv is not None else sys.argv[1:]` if the spec pattern is ever revised. | `generate_acceptance_scenarios.py:469` |
| CR-2 | Non-blocking | Argparse usage errors (missing required arguments) exit with code 2 via `SystemExit`, technically outside the documented `0`/`1` convention. This matches the reference modules' behavior and is standard argparse semantics; the `0`/`1` convention governs the module's own failure paths, all of which return 1. | `generate_acceptance_scenarios.py:414–447` |
| CR-3 | Non-blocking | `collect_input_paths` sorting is used only for the missing-file diagnostic ordering (`_generate_from_args`, lines 398–403); the three artifacts are then loaded in fixed positional roles. This is deterministic (fixed roles cannot vary with filesystem order), so the spec's intent is met; the sorted view exists to keep the diagnostic message stable. A docstring already states this. | `generate_acceptance_scenarios.py:391–411` |
| CR-4 | Non-blocking | `assemble_scenarios` emits the Cartesian product of matching parity rows × characterization scenarios per feature (lines 274–307). For large matrices output size grows multiplicatively. Acceptable for the documented discovery-artifact scale and consistent with spec.md ("one scenario per applicable combination"); worth revisiting if inputs grow. | `generate_acceptance_scenarios.py:245–308` |

## Test Quality

- 34 tests (28 functions, 6 additional parametrized cases), Arrange–Act–Assert, one behavior per test, parametrized boundary matrices for structural errors and negative CLI paths.
- Mocking is minimal (`monkeypatch.setattr` once, at the correct import location); everything else exercises real pure code paths.
- No temp files, no sleeps, no network, no wall-clock reads. In-memory `mem_fs_path` fixture used for all path-based tests.
- Assertions are behavioral (exit codes, emitted content, field values) rather than implementation-detail checks, with the deliberate exception of the domain-neutrality source scan, which is invariant enforcement by design.
- Coverage of the module is 100% line / 100% branch (from `artifacts/python/lcov.info`, `LF=186 LH=186 BRF=42 BRH=42`).

## Findings Register

Blocking findings: 0. Non-blocking observations: 4 (CR-1 through CR-4). No remediation required from this artifact.
