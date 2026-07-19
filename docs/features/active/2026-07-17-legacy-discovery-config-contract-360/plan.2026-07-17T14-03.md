# legacy-discovery-config-contract - Plan

- **Issue:** #360
- **Parent (optional):** Epic `legacy-discovery-and-parity` (child feature #9001, Wave 0, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-03
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature (resolved from `issue.md` metadata marker `- Work Mode: full-feature`)

## Required References

- Repository tone/communication policy: `.github/copilot-instructions.md`
- Baseline code-change policy: `.claude/rules/general-code-change.md`
- Baseline unit-test policy: `.claude/rules/general-unit-test.md`
- Python toolchain/coding standards: `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`
- Module rigor tiers / coverage thresholds: `.claude/rules/quality-tiers.md`
- Feature spec (contract, loader contract, CLI contract, testing requirements, acceptance criteria): `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/spec.md`
- Feature user story: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/user-story.md`
- Resolved design (follow it): `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/research/2026-07-17T10-40-config-contract-research.md`
- Epic shared design (domain-neutrality invariant, quality gates): `docs/features/epics/legacy-discovery-and-parity/epic.md`

**All work must comply with these policies; do not duplicate their content here.**

## Requirements Sources (full-feature)

- Requirements are drawn from BOTH `spec.md` (authoritative contract + `## Acceptance Criteria`) AND `user-story.md`.
- Full Python QA loop obligations apply (format -> lint -> type-check -> test with coverage).
- The MINIMAL-AUDIT directive does NOT apply to this plan.

## Evidence Location Invariant

All evidence artifacts produced by this plan MUST be written under
`docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/<kind>/`.
Baseline command artifacts use `evidence/baseline/`; final-QC command artifacts use
`evidence/qa-gates/`; decision/risk records use `evidence/other/`. Any `artifacts/`
evidence path (for example `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`)
is a policy violation and fails preflight.

## Scope Boundaries

- In scope (Python only): the `scripts/dev_tools/discovery/` package (`__init__.py`,
  `domain_profile.py`, `profile_cli.py`), one `[tool.poetry.scripts]` line, and mirrored
  tests under `tests/scripts/dev_tools/discovery/`.
- Out of scope (owned by sibling features; do NOT implement): JSON schema files (#9002),
  standalone `validate_*_text` validators (#9003), path-existence/reachability checks.

### Phase 0 — Baseline Capture and Policy Reads

- [x] [P0-T1] Read the policy files in the mandated order and record the read evidence: `.github/copilot-instructions.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/quality-tiers.md`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/baseline/phase0-instructions-read.md` exists and contains `Timestamp:`, `Policy Order:`, and the explicit list of files read.
- [x] [P0-T2] Verify the `scripts/dev_tools/discovery/` package namespace and the `dev.discovery.profile` console-script name are free (no existing files, no existing script alias).
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/baseline/namespace-free.md` records the search commands (glob for `scripts/dev_tools/discovery/**`, grep for `dev.discovery` in `pyproject.toml`), `EXIT_CODE:`, and `Output Summary:` confirming zero matches.
- [x] [P0-T3] Capture the baseline Black formatting state: run `poetry run black --check .`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/baseline/baseline-black.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail plus files-would-reformat count).
- [x] [P0-T4] Capture the baseline Ruff lint state: run `poetry run ruff check .`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/baseline/baseline-ruff.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (pass/fail plus error count).
- [x] [P0-T5] Capture the baseline Pyright type-check state: run `poetry run pyright`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/baseline/baseline-pyright.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (error/warning counts).
- [x] [P0-T6] Capture the baseline test-and-coverage state: run `poetry run pytest --cov --cov-branch --cov-report=term-missing`.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/baseline/baseline-pytest-coverage.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` recording numeric baseline line-coverage percent and branch-coverage percent (not placeholders) and pass/fail count.

### Phase 1 — Package Scaffolding

- [x] [P1-T1] Create the package directory file `scripts/dev_tools/discovery/__init__.py` with a module docstring and no re-exports yet (re-exports are finalized in P2-T6 after `domain_profile.py` exists).
  - Acceptance: `scripts/dev_tools/discovery/__init__.py` exists, is importable, is under 500 lines, and contains no domain-specific identifiers.

### Phase 2 — Typed Loader (`domain_profile.py`)

- [x] [P2-T1] Create `scripts/dev_tools/discovery/domain_profile.py` with the module docstring, the `DEFAULT_PROFILE_FILENAME = "discovery-profile.yaml"` constant, and `class DomainProfileError(ValueError)`.
  - Acceptance: File imports cleanly; `DomainProfileError` subclasses `ValueError`; `DEFAULT_PROFILE_FILENAME` equals `"discovery-profile.yaml"`.
- [x] [P2-T2] Add the five frozen dataclasses (`LegacySourceConfig`, `TargetConfig`, `TechnologyStackConfig`, `ArtifactsConfig`, `DomainProfile`) with `frozen=True`, tuple-normalized list fields, the `ArtifactsConfig.conventions_map` property, and `__post_init__` invariants (non-empty `root`, non-empty `legacy` tuple, `profile_version == 1`, non-empty convention keys/values) raising `DomainProfileError`.
  - Acceptance: Each dataclass is frozen; a direct constructor call with an invalid value raises `DomainProfileError`; `conventions_map` returns `dict[str, str]`; field names are exactly as in `spec.md` `## Loader Contract`.
- [x] [P2-T3] Add the isolated untyped seam `_load_yaml_mapping(text: str, source: str) -> dict[str, object]` (calls `yaml.safe_load`, wraps `yaml.YAMLError` into `DomainProfileError` with source label and mark, rejects non-mapping documents) and the private typed extraction helpers (`_require_str`, `_optional_str`, `_str_list`, `_require_mapping`) that narrow `object` with `isinstance`.
  - Acceptance: `import yaml` and `yaml.safe_load` appear only inside `_load_yaml_mapping`; no `cast` chains and no `# type: ignore` for the YAML boundary; non-mapping YAML input raises `DomainProfileError`.
- [x] [P2-T4] Add `parse_domain_profile_text(text: str, source: str = "<string>") -> DomainProfile` that walks the mapping section-by-section, collects ALL field errors (missing required, wrong type, empty string, empty list, unknown key at top level and inside each section, unsupported `profile_version`) into a list with dotted field paths, and raises a single `DomainProfileError` enumerating every collected error.
  - Acceptance: A valid full profile parses to a `DomainProfile`; an invalid profile with three defects raises one `DomainProfileError` whose message lists all three dotted paths (e.g. `legacy_source.root: expected non-empty string, got int`).
- [x] [P2-T5] Add `load_domain_profile(path: Path) -> DomainProfile` as a thin I/O wrapper that reads `path.read_text(encoding="utf-8")`, delegates to `parse_domain_profile_text`, and wraps `FileNotFoundError`/`OSError` into `DomainProfileError` with the path in the message.
  - Acceptance: `load_domain_profile` performs the only filesystem read in the module; a missing path raises `DomainProfileError` naming the path; the parse layer remains I/O-free.
- [x] [P2-T6] Update `scripts/dev_tools/discovery/__init__.py` to re-export the public loader surface (`DomainProfile`, the four sub-config dataclasses, `DomainProfileError`, `parse_domain_profile_text`, `load_domain_profile`, `DEFAULT_PROFILE_FILENAME`).
  - Acceptance: `from scripts.dev_tools.discovery import DomainProfile, DomainProfileError, load_domain_profile, parse_domain_profile_text, DEFAULT_PROFILE_FILENAME` succeeds; `__init__.py` stays under 500 lines.
- [x] [P2-T7] Confirm `scripts/dev_tools/discovery/domain_profile.py` stays under 500 lines; if the docstring-heavy house style pushes it over, extract the dataclasses into `scripts/dev_tools/discovery/domain_profile_models.py` and re-import them.
  - Acceptance: `domain_profile.py` (and `domain_profile_models.py` if created) are each under 500 lines; public import surface is unchanged.

### Phase 3 — CLI and pyproject Script Line

- [x] [P3-T1] Create `scripts/dev_tools/discovery/profile_cli.py` with `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace`: a flat parser with a positional `profile_path` (`nargs="?"`, default `DEFAULT_PROFILE_FILENAME`) and a `--json` flag.
  - Acceptance: `parse_args([])` yields `profile_path == "discovery-profile.yaml"` and `json is False`; `parse_args(["p.yaml", "--json"])` yields the explicit path and `json is True`.
- [x] [P3-T2] Add the resolved-profile rendering (aligned `key: value` text of declared values plus applied defaults; JSON via `dataclasses.asdict` + `json.dumps(sort_keys=True)`) and `main(argv: Sequence[str] | None = None) -> int` that returns `0` on success (printing to stdout), catches only `DomainProfileError` and returns `1` (printing the full multi-error message to stderr), and ends with `if __name__ == "__main__": raise SystemExit(main())`.
  - Acceptance: `main` returns `0` for a valid profile and prints resolved text; returns `1` for a missing/malformed profile with the message on stderr; only `DomainProfileError` is caught (no broad `except Exception`); file is under 500 lines.
- [x] [P3-T3] Add exactly one line to the `[tool.poetry.scripts]` block in root `pyproject.toml`, placed alphabetically after `"dev.collect-commit-context"`: `"dev.discovery.profile" = "scripts.dev_tools.discovery.profile_cli:main"`.
  - Acceptance: `pyproject.toml` contains the exact line; no other script lines are changed; no new dependency is added (PyYAML is already declared).

### Phase 4 — Tests (mirrored under `tests/scripts/dev_tools/discovery/`)

- [x] [P4-T1] Create `tests/scripts/dev_tools/discovery/test_domain_profile.py` with positive parse tests: a full profile with every optional field present, and a minimal profile asserting each applied default (`profile_name` None, descriptions None, empty include/exclude/target/conventions).
  - Acceptance: Both tests pass using inline-YAML strings fed to `parse_domain_profile_text` with no filesystem access; each default value is explicitly asserted.
- [x] [P4-T2] Add a `pytest.mark.parametrize` negative matrix to `test_domain_profile.py` covering: each of the five required fields missing (dotted path asserted), type mismatches (string-where-list, list-where-string, string `profile_version`, non-mapping section), empty-string roots, empty `legacy` list, unsupported `profile_version: 2`, unknown top-level key, unknown key in each section, malformed YAML syntax (source label asserted), non-mapping document, and one profile with three defects reported in a single raise.
  - Acceptance: Every parametrized case raises `DomainProfileError`; each asserts its expected dotted path or source label; the multi-defect case asserts all three paths in one message.
- [x] [P4-T3] Add direct-construction invariant tests to `test_domain_profile.py`: constructing each dataclass with an invalid value raises `DomainProfileError` (exercising every `__post_init__` branch).
  - Acceptance: One passing test per dataclass invariant branch (non-empty `root`, non-empty `legacy`, `profile_version == 1`, non-empty convention keys/values).
- [x] [P4-T4] Add `load_domain_profile` tests to `test_domain_profile.py` using the `mem_fs_path` fixture (`tests/conftest.py`): happy path (write profile text to `mem_fs_path / "discovery-profile.yaml"`, load, assert `DomainProfile`) and missing-file path (assert `DomainProfileError` names the path). Do not use `tmp_path` or any runtime temp file.
  - Acceptance: Both tests pass via `mem_fs_path`; no `tmp_path` and no runtime temp file appear in the test module.
- [x] [P4-T5] Add a domain-neutrality contract test to `test_domain_profile.py` that reads the production source of `scripts/dev_tools/discovery/domain_profile.py` and `scripts/dev_tools/discovery/profile_cli.py` (and `domain_profile_models.py` if it exists) and asserts none of the banned substrings (`taskmaster`, `tmw`, `outlook`, `vsto`, `email`, `task-management`) appears, case-insensitively.
  - Acceptance: The test fails if any banned substring is present in a production module source and passes for the neutral implementation.
- [x] [P4-T6] Create `tests/scripts/dev_tools/discovery/test_profile_cli.py` covering `parse_args` (default path, explicit path, `--json`) and `main` via `capsys` and `mem_fs_path`: success text output (exit 0), `--json` output round-tripping through `json.loads` (exit 0), missing file (exit 1, stderr message), malformed profile (exit 1, all field errors on stderr), and default-filename resolution.
  - Acceptance: All CLI tests pass using `capsys` and `mem_fs_path`; exit codes 0 and 1 are asserted; the JSON case round-trips expected keys; both test files stay under 500 lines (split into a `_part2` module if either approaches the limit).

### Phase 5 — Final QC Loop and Coverage Verification

- [x] [P5-T1] Run the Black formatting stage: `poetry run black .`. If it reformats any file, restart the QC loop from this task after re-verifying earlier stages.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-black.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` confirming no files require reformatting on the clean pass.
- [x] [P5-T2] Run the Ruff lint stage: `poetry run ruff check .`. If it reports or auto-fixes anything, correct and restart the loop from P5-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-ruff.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` recording zero lint errors (S506 not triggered because `yaml.safe_load` is used).
- [x] [P5-T3] Run the Pyright type-check stage: `poetry run pyright`. If it fails, correct and restart the loop from P5-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pyright.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` recording zero errors over `scripts`, `src`, `tests`.
- [x] [P5-T4] Record the PyYAML stub resolution decision/risk: if P5-T3 surfaces a missing-stub diagnostic for `yaml`, do NOT silently add a dependency; record that adding `types-PyYAML` to the dev group is a new dev dependency requiring explicit approval, and prefer the bundled typeshed third-party stubs first.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/other/pyyaml-stub-decision.md` records whether the bundled typeshed stubs resolved `yaml` (expected) or whether `types-PyYAML` approval is required, with `Timestamp:` and the Pyright diagnostic quoted if present.
- [x] [P5-T5] Run the Pytest coverage stage: `poetry run pytest --cov --cov-branch --cov-report=term-missing`. If any test fails or any earlier stage changed files, restart the loop from P5-T1.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/final-pytest-coverage.md` contains `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` recording numeric post-change total line-coverage percent, branch-coverage percent, and the per-module coverage percents for `scripts/dev_tools/discovery/domain_profile.py` and `scripts/dev_tools/discovery/profile_cli.py`.
- [x] [P5-T6] Verify the coverage thresholds and delta: compare baseline coverage (P0-T6) against post-change coverage (P5-T5) and confirm the new package meets policy (line >= 85%, branch >= 75%) with no regression on changed lines.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/coverage-delta.md` records baseline coverage, post-change coverage, and new/changed-code (targeted-module) coverage as numeric values, and states PASS only if line >= 85% and branch >= 75% for the new modules with no changed-line regression; otherwise the outcome is remediation-required.
- [x] [P5-T7] Verify every acceptance criterion in `spec.md` `## Acceptance Criteria` and each user-story scenario (A and B) is mapped to a passing test or demonstrated CLI behavior, and confirm every production and test file is under 500 lines.
  - Acceptance: `docs/features/active/2026-07-17-legacy-discovery-config-contract-360/evidence/qa-gates/acceptance-traceability.md` maps each `spec.md` acceptance criterion and user-story scenario to a specific test name or CLI evidence, and lists the line count of every added file confirming each is under 500.

## Test Plan

- Unit (pure): `parse_domain_profile_text` positive/negative matrix via inline-YAML strings (`test_domain_profile.py`), plus direct-construction `__post_init__` invariants and the domain-neutrality contract test.
- Unit (I/O boundary): `load_domain_profile` happy/missing-file paths via the `mem_fs_path` in-memory filesystem fixture; no runtime temp files.
- CLI: `parse_args` defaults/flags and `main` success/`--json`/missing/malformed behavior via `capsys` and `mem_fs_path` (`test_profile_cli.py`), asserting exit codes 0/1.
- Coverage evidence:
  - Baseline: `evidence/baseline/baseline-pytest-coverage.md` (numeric line and branch percent).
  - Post-change: `evidence/qa-gates/final-pytest-coverage.md` (numeric total and per-module percent).
  - Comparison: `evidence/qa-gates/coverage-delta.md` (baseline vs post-change vs new-code, threshold verdict).

## Open Questions / Notes

- PyYAML is an already-declared but currently-unused Poetry dependency; this feature introduces the repository's first `import yaml`. No new runtime dependency is added.
- `types-PyYAML` would be a new dev dependency requiring explicit approval; it is only introduced if Pyright's bundled typeshed stubs are insufficient (see P5-T4). Prefer bundled stubs first.
- Convention keys under `artifacts.conventions` are unvalidated by design; the artifact-kind vocabulary is owned by #9002/#9005 and must not be read as a gap.
