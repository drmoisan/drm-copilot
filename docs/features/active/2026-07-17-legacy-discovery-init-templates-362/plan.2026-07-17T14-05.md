# legacy-discovery-init-templates - Plan

- **Issue:** #362
- **Parent (epic):** legacy-discovery-and-parity (epic manifest placeholder issue 9005)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-05
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-feature
- **Complexity Band:** C2

## Required References

- `CLAUDE.md` — repository standing instructions, tone policy, policy-compliance reading order.
- `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, mandatory toolchain loop, file-size limit).
- `.claude/rules/general-unit-test.md` — cross-language unit test policy (coverage thresholds, no-temp-files rule, test file location).
- `.claude/rules/python.md` — Python toolchain (Black, Ruff, Pyright, Pytest) and coding standards.
- `.claude/rules/quality-tiers.md` — uniform coverage gates (line >= 85%, branch >= 75%) applicable to this T4-classified package regardless of tier.
- `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/spec.md` — authoritative acceptance criteria (together with `user-story.md`).
- `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/user-story.md`
- `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/research/research.2026-07-17T14-15.md` — authoritative design input.
- `docs/features/epics/legacy-discovery-and-parity/objective-source.md` (sections 3, 4, 7) and `epic.md` — shared-design constraints (domain neutrality, schema-versioning convention, CLI-before-MCP-before-VS-Code).

**All work must comply with these policies; do not duplicate their content here.**

## Design Notes Carried Into Implementation (not resolved by this feature)

- **Upstream contract 9001 (config contract):** the starter domain-profile template is authored as a flat, single-level `key: value` YAML document (no nested maps/lists), because feature 9001 has not resolved PyYAML-vs-hand-rolled-parser. If 9001's final contract requires nested structure, the template needs a follow-up edit; this plan does not guess 9001's final schema.
- **Upstream contract 9002 (schemas):** each artifact template's `$schema` field is a relative, scheme-less path (e.g. `../../schemas/v1/feature-contract.schema.json`), resolved by `validate_json.py`'s existing no-scheme `_load_schema` branch. **Open cross-repository question, owned by 9002, not resolved by this feature:** a `$schema` value that is a relative path computed against the `drm-copilot`-local schema location will not resolve from inside an external consumer repository's discovery workspace unless the consumer vendors a copy of the schemas or 9002 instead mandates an absolute/versioned URI. This feature's templates copy whatever relative-path convention 9002 establishes verbatim and do not invent a second convention.
- **Schema-conformance test dependency:** the test asserting each generated starter artifact validates against its schema has a hard dependency on feature 9002's schema files existing (none exist in the repository as of this plan). It is authored against 9002's planned schema shape and marked `@pytest.mark.skip` with a reason citing issue 9002, per spec's "must not be silently skipped or removed from the plan" instruction. This is a single, individually-marked test skip documented by design; it does not affect the Final Phase's pytest command exit code (skipped tests do not fail a pytest run by default) and is distinct from the "no SKIPPED command tasks" rule, which governs whole toolchain command invocations, not an individual documented-pending test case.
- **Rendering mechanism:** literal `str.replace`-based placeholder substitution (matching `set_header_placeholder`/`render_content` precedent), not a templating engine — no new dependency.
- **Directory layout decision (this feature's own design choice, not an upstream contract):** the scaffolded target directory layout is:
  ```
  <target-dir>/
    domain-profile.yaml
    artifacts/
      feature-contract.json
      coverage-ledger.json
      runtime-characterization-scenario.json
      parity-matrix.json
      unspecified-behavior-record.json
      product-decision-record.json
      evidence-reference.json
  ```
  copied 1:1 from the template root's `domain-profile/domain-profile.yaml` and `artifacts/*.template.json` files.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline and Policy Reads

- [ ] [P0-T1] Read `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, and `.claude/rules/python.md` in that order, then write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/phase0-instructions-read.md` containing `Timestamp:`, `Policy Order:` (the four-file list in the order read), and an explicit bullet list of the four file paths read.
  - Acceptance: the evidence file exists and contains all four required fields with the four file paths listed verbatim.

- [ ] [P0-T2] Run `poetry run black --check .` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/phase0-black-baseline.md` with `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:` (pass/fail status and count of files that would reformat, if any).
  - Acceptance: evidence file exists with all four required fields populated from the actual command run.

- [ ] [P0-T3] Run `poetry run ruff check .` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/phase0-ruff-baseline.md` with `Timestamp:`, `Command: poetry run ruff check .`, `EXIT_CODE:`, and `Output Summary:` (pass/fail status and error count).
  - Acceptance: evidence file exists with all four required fields populated from the actual command run.

- [ ] [P0-T4] Run `poetry run pyright` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/phase0-pyright-baseline.md` with `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:` (pass/fail status and error/warning count).
  - Acceptance: evidence file exists with all four required fields populated from the actual command run.

- [ ] [P0-T5] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/phase0-pytest-baseline.md` with `Timestamp:`, `Command: poetry run pytest --cov --cov-branch --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` recording the numeric baseline line-coverage percent and branch-coverage percent from the run's summary output.
  - Acceptance: evidence file exists with all four required fields, and `Output Summary:` contains two explicit numeric percentages (line and branch).

### Phase 1 — Package scaffolding and `init_models.py`

- [ ] [P1-T1] Create `scripts/dev_tools/discovery/__init__.py` as an empty package-marker file containing only a one-line module docstring identifying it as the `dev.discovery.*` command namespace package.
  - Acceptance: file exists, contains no executable statements beyond the docstring, imports without error.

- [ ] [P1-T2] Create `tests/scripts/dev_tools/discovery/__init__.py` as an empty test-package marker file mirroring `scripts/dev_tools/discovery/`.
  - Acceptance: file exists and `pytest --collect-only tests/scripts/dev_tools/discovery/` discovers the package without import error.

- [ ] [P1-T3] Implement the `FileSystem` `typing.Protocol` in `scripts/dev_tools/discovery/init_models.py` with methods `exists(path: Path) -> bool`, `is_dir(path: Path) -> bool`, `list_dir(path: Path) -> list[Path]`, `ensure_dir(path: Path) -> None`, `read_text(path: Path) -> str`, `write_text(path: Path, content: str) -> None`.
  - Acceptance: `scripts/dev_tools/discovery/init_models.py` defines `FileSystem` as a `Protocol` with exactly these six method signatures and full type hints; `poetry run pyright scripts/dev_tools/discovery/init_models.py` reports zero errors on this definition.

- [ ] [P1-T4] Implement the `RealFileSystem` dataclass in `scripts/dev_tools/discovery/init_models.py` implementing `FileSystem` via `pathlib.Path` (`Path.exists`, `Path.is_dir`, `Path.iterdir`, `Path.mkdir(parents=True, exist_ok=True)`, `Path.read_text(encoding="utf-8")`, `Path.write_text(..., encoding="utf-8")` with parent-directory creation on write).
  - Acceptance: `RealFileSystem` implements all six `FileSystem` methods; `poetry run pyright` reports zero errors for the class.

- [ ] [P1-T5] Define the constants `DOMAIN_PROFILE_RELATIVE_PATH`, `ARTIFACT_RELATIVE_PATHS` (a 7-tuple of the seven `artifacts/*.template.json` relative paths), and `EXPECTED_TEMPLATE_RELATIVE_PATHS` (the 8-tuple union: domain profile plus the seven artifact templates) in `scripts/dev_tools/discovery/init_models.py`.
  - Acceptance: `EXPECTED_TEMPLATE_RELATIVE_PATHS` has exactly 8 entries and `ARTIFACT_RELATIVE_PATHS` has exactly 7 entries, verified by the unit test in P1-T9.

- [ ] [P1-T6] Define the constant `OUTPUT_RELATIVE_PATHS` in `scripts/dev_tools/discovery/init_models.py` as an 8-tuple, index-aligned with `EXPECTED_TEMPLATE_RELATIVE_PATHS`, describing the scaffolded target-directory layout (`domain-profile.yaml` plus `artifacts/*.json` x7, per the "Design Notes" directory layout above).
  - Acceptance: `OUTPUT_RELATIVE_PATHS` has exactly 8 entries in the same order as `EXPECTED_TEMPLATE_RELATIVE_PATHS`, verified by the unit test in P1-T9.

- [ ] [P1-T7] Implement `resolve_default_template_root() -> Path` in `scripts/dev_tools/discovery/init_models.py` returning `Path(__file__).resolve().parents[3] / "docs" / "discovery" / "templates"`.
  - Acceptance: calling the function returns a path whose final two components are `discovery` and `templates` under `docs`, verified by the unit test in P1-T10.

- [ ] [P1-T8] Write unit test `test_real_file_system_delegates_to_pathlib` in `tests/scripts/dev_tools/discovery/test_init_models.py`, monkeypatching `Path.mkdir`, `Path.read_text`, `Path.write_text`, and `Path.iterdir` (per the `RealFileSystem` test precedent in `tests/scripts/dev_tools/test_new_potential_bug_entry.py:214-233`), asserting each of the six `RealFileSystem` methods delegates to the monkeypatched call without performing real disk I/O.
  - Acceptance: test passes; test contains no `tmp_path` fixture and creates no real file or directory.

- [ ] [P1-T9] Write unit test `test_expected_template_relative_paths_has_eight_entries` in `tests/scripts/dev_tools/discovery/test_init_models.py` asserting `len(EXPECTED_TEMPLATE_RELATIVE_PATHS) == 8`, `len(ARTIFACT_RELATIVE_PATHS) == 7`, `len(OUTPUT_RELATIVE_PATHS) == 8`, and that `EXPECTED_TEMPLATE_RELATIVE_PATHS` and `OUTPUT_RELATIVE_PATHS` are index-aligned (same count, first entry maps domain profile to domain profile, remaining entries map artifact templates to artifact outputs in order).
  - Acceptance: test passes against the constants defined in P1-T5/P1-T6.

- [ ] [P1-T10] Write unit test `test_resolve_default_template_root_returns_expected_path` in `tests/scripts/dev_tools/discovery/test_init_models.py` asserting `resolve_default_template_root()` returns a path ending in `docs/discovery/templates` (platform-appropriate separator).
  - Acceptance: test passes against the function defined in P1-T7.

### Phase 2 — `init_flow.py` pure orchestration and fail-fast validation

- [ ] [P2-T1] Implement `validate_template_set(template_root: Path, fs: FileSystem) -> None` in `scripts/dev_tools/discovery/init_flow.py`, raising `FileNotFoundError` naming every missing path (template root itself missing, or one/more of the 8 `EXPECTED_TEMPLATE_RELATIVE_PATHS` missing under it) — a partial template set fails the same way as a fully-missing template root.
  - Acceptance: function raises `FileNotFoundError` with a message listing each missing relative path when any of the 8 expected files (or the root) is absent from `fs`; returns `None` when all 8 are present. Verified by P2-T12 and P2-T13.

- [ ] [P2-T2] Implement `validate_target_path(target_dir: Path, fs: FileSystem, *, force: bool) -> None` in `scripts/dev_tools/discovery/init_flow.py`, raising `FileNotFoundError` when `target_dir.parent` does not exist in `fs`, `NotADirectoryError` when `target_dir` exists in `fs` and is not a directory, and `FileExistsError` when `target_dir` exists, is a directory, is non-empty (per `fs.list_dir`), and `force` is `False`.
  - Acceptance: each of the three raise conditions is exercised and asserted by a dedicated unit test in P2-T8, P2-T9, P2-T10; the function returns `None` for an empty or non-existent target with an existing parent, and for a non-empty target when `force=True` (P2-T11).

- [ ] [P2-T3] Implement `substitute_placeholders(text: str, tokens: Mapping[str, str] | None = None) -> str` in `scripts/dev_tools/discovery/init_flow.py`, performing literal `str.replace` over the supplied token mapping (default empty mapping, so domain-value placeholder tokens such as `<legacy-source-path>` remain intact in scaffolded output for the consumer to edit afterward).
  - Acceptance: with `tokens=None` the function returns the input text unchanged; with a non-empty mapping every occurrence of each key is replaced by its value. Verified by a unit test added in this task's own commit within `tests/scripts/dev_tools/discovery/test_init_flow.py`.

- [ ] [P2-T4] Implement `create_discovery_workspace(target_dir: Path, template_root: Path, fs: FileSystem, *, force: bool = False) -> None` in `scripts/dev_tools/discovery/init_flow.py`: calls `validate_template_set(template_root, fs)` then `validate_target_path(target_dir, fs, force=force)` (both complete with no write before either check passes), then `fs.ensure_dir(target_dir)` and `fs.ensure_dir(target_dir / "artifacts")`, then for each index-aligned pair in `EXPECTED_TEMPLATE_RELATIVE_PATHS`/`OUTPUT_RELATIVE_PATHS` reads the template text via `fs.read_text`, applies `substitute_placeholders`, and writes the result via `fs.write_text` at the corresponding output path under `target_dir`.
  - Acceptance: no `argparse` or `print` call appears anywhere in `init_flow.py`; the function raises before any `fs.write_text` call when either validation step fails (verified by P2-T8–P2-T13 asserting zero writes on the failure path); on success writes exactly 8 files (verified by P2-T6).

- [ ] [P2-T5] Write the `FakeFileSystem` test double in `tests/scripts/dev_tools/discovery/test_init_flow.py`, implementing `FileSystem` over an in-memory `dict[Path, str]` of files and a `set[Path]` of directories, mirroring `FakeFileSystem` in `tests/scripts/dev_tools/test_new_potential_bug_entry.py:17-34`.
  - Acceptance: `FakeFileSystem` implements all six `FileSystem` methods with no real filesystem/temp-file I/O.

- [ ] [P2-T6] Write unit test `test_create_discovery_workspace_success_full_layout` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding a `FakeFileSystem` with all 8 expected template files under a fake template root and an empty target directory, asserting `create_discovery_workspace(...)` writes exactly the 8 expected output files (per `OUTPUT_RELATIVE_PATHS`) with the (unsubstituted, per P2-T3 default) template content.
  - Acceptance: test passes; asserts both the file count and each output path's content.

- [ ] [P2-T7] Write unit test `test_create_discovery_workspace_template_root_override` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding a second, distinct fake template root path in the same `FakeFileSystem` with a complete 8-file set, asserting `create_discovery_workspace(target_dir, alternate_template_root, fs)` succeeds and reads from the alternate root rather than the default.
  - Acceptance: test passes; asserts the output content matches the alternate root's template content, not any default-root content.

- [ ] [P2-T8] Write unit test `test_target_path_not_a_directory_raises` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding a `FakeFileSystem` where `target_dir` exists as a file (not a directory), asserting `create_discovery_workspace(...)` raises `NotADirectoryError` and that `fs.files` contains no output-path keys beyond the pre-seeded file.
  - Acceptance: test passes; asserts both the exception type and zero additional writes.

- [ ] [P2-T9] Write unit test `test_target_parent_missing_raises` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding a `FakeFileSystem` where `target_dir.parent` is absent, asserting `create_discovery_workspace(...)` raises `FileNotFoundError` and that no output files were written.
  - Acceptance: test passes; asserts both the exception type and zero writes.

- [ ] [P2-T10] Write unit test `test_target_non_empty_without_force_raises` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding a `FakeFileSystem` where `target_dir` already contains one file and `force` defaults to `False`, asserting `create_discovery_workspace(...)` raises `FileExistsError` and that no additional output files were written.
  - Acceptance: test passes; asserts both the exception type and that only the pre-seeded file remains.

- [ ] [P2-T11] Write unit test `test_target_non_empty_with_force_succeeds` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding the same non-empty-target `FakeFileSystem` as P2-T10 but calling `create_discovery_workspace(..., force=True)`, asserting the call succeeds and writes the full 8-file expected output set alongside the pre-existing file.
  - Acceptance: test passes; asserts all 8 expected output paths are present after the call.

- [ ] [P2-T12] Write unit test `test_missing_template_root_raises` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding a `FakeFileSystem` where `template_root` has no entries at all, asserting `create_discovery_workspace(...)` raises `FileNotFoundError` and writes no output files.
  - Acceptance: test passes; asserts both the exception type and zero writes.

- [ ] [P2-T13] Write unit test `test_partial_template_set_raises` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, seeding a `FakeFileSystem` where `template_root` has 7 of the 8 expected files (one artifact template missing), asserting `create_discovery_workspace(...)` raises `FileNotFoundError` naming the specific missing relative path and writes no output files (a partial template set must not produce a partial scaffold).
  - Acceptance: test passes; asserts the exception message contains the specific missing relative path and that zero output files were written.

### Phase 3 — `init_cli.py` CLI wiring

- [ ] [P3-T1] Implement `parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace` in `scripts/dev_tools/discovery/init_cli.py` with a required positional `target_dir: Path` argument, an optional `--template-root` argument of type `Path` defaulting to `None`, and an optional `--force` flag using `action="store_true"`.
  - Acceptance: `parse_args(["x"])` returns a namespace with `target_dir == Path("x")`, `template_root is None`, `force is False`; `parse_args([])` raises `SystemExit` (missing required positional).

- [ ] [P3-T2] Implement `main(argv: Sequence[str] | None = None) -> None` in `scripts/dev_tools/discovery/init_cli.py`: calls `parse_args(argv)`, resolves the effective template root as `args.template_root` if supplied else `init_models.resolve_default_template_root()`, calls `init_flow.create_discovery_workspace(args.target_dir, effective_template_root, init_models.RealFileSystem(), force=args.force)`, and on `(ValueError, FileExistsError, FileNotFoundError, NotADirectoryError)` performs `print(str(exc), file=sys.stderr); raise SystemExit(1) from exc`, with no bare `except Exception`.
  - Acceptance: `main()` contains exactly one `except` clause naming the four listed exception types (no bare `except Exception`), and prints to `sys.stderr` before raising `SystemExit(1)`.

- [ ] [P3-T3] Write unit test `test_parse_args_requires_target_dir` in `tests/scripts/dev_tools/discovery/test_init_cli.py` asserting `parse_args([])` raises `SystemExit`.
  - Acceptance: test passes.

- [ ] [P3-T4] Write unit test `test_parse_args_parses_template_root_and_force` in `tests/scripts/dev_tools/discovery/test_init_cli.py` asserting `parse_args(["x", "--template-root", "y", "--force"])` returns a namespace with `target_dir == Path("x")`, `template_root == Path("y")`, `force is True`.
  - Acceptance: test passes.

- [ ] [P3-T5] Write unit test `test_main_success_path_invokes_create_discovery_workspace` in `tests/scripts/dev_tools/discovery/test_init_cli.py`, monkeypatching `sys.argv` and `init_flow.create_discovery_workspace` (patched at the `init_cli` import location) to a no-op stub, asserting `main()` returns without raising `SystemExit`.
  - Acceptance: test passes; the stub records that it was called with the resolved target directory and template root.

- [ ] [P3-T6] Write unit test `test_main_exits_1_on_fail_fast_exception` in `tests/scripts/dev_tools/discovery/test_init_cli.py`, parametrized over `FileExistsError`, `FileNotFoundError`, `NotADirectoryError`, and `ValueError`, monkeypatching `init_flow.create_discovery_workspace` to raise each in turn, asserting `main()` raises `SystemExit(1)` and that a message was printed for each case.
  - Acceptance: all four parametrized cases pass.

### Phase 4 — Domain-neutral templates

- [ ] [P4-T1] Create `docs/discovery/templates/domain-profile/domain-profile.yaml` as a flat, single-level `key: value` YAML document with exactly the keys `legacy_source_path`, `target_path`, `technology_stack`, `artifact_output_dir`, each assigned a placeholder token value (`"<legacy-source-path>"`, `"<target-path>"`, `"<technology-stack>"`, `"<artifact-output-dir>"`), containing no nested maps and no lists.
  - Acceptance: the file parses successfully under both `yaml.safe_load` and a flat `key: value`-only parser (no line contains a nested map or a `-` list item); contains no domain-specific identifier.

- [ ] [P4-T2] Create `docs/discovery/templates/artifacts/feature-contract.template.json` as a minimal JSON object with a top-level `"$schema"` field set to the relative, scheme-less path `"../../schemas/v1/feature-contract.schema.json"`, a `"version"` placeholder field, and placeholder-token field values for the artifact's identifying content (e.g. `"id": "<feature-contract-id>"`).
  - Acceptance: file is valid JSON; `"$schema"` is present, is a string, and contains no URI scheme (`://`); no field value contains a domain-specific identifier.

- [ ] [P4-T3] Create `docs/discovery/templates/artifacts/coverage-ledger.template.json` with the same structure as P4-T2, `"$schema": "../../schemas/v1/coverage-ledger.schema.json"`.
  - Acceptance: same as P4-T2, for this file.

- [ ] [P4-T4] Create `docs/discovery/templates/artifacts/runtime-characterization-scenario.template.json` with the same structure as P4-T2, `"$schema": "../../schemas/v1/runtime-characterization-scenario.schema.json"`.
  - Acceptance: same as P4-T2, for this file.

- [ ] [P4-T5] Create `docs/discovery/templates/artifacts/parity-matrix.template.json` with the same structure as P4-T2, `"$schema": "../../schemas/v1/parity-matrix.schema.json"`.
  - Acceptance: same as P4-T2, for this file.

- [ ] [P4-T6] Create `docs/discovery/templates/artifacts/unspecified-behavior-record.template.json` with the same structure as P4-T2, `"$schema": "../../schemas/v1/unspecified-behavior-record.schema.json"`.
  - Acceptance: same as P4-T2, for this file.

- [ ] [P4-T7] Create `docs/discovery/templates/artifacts/product-decision-record.template.json` with the same structure as P4-T2, `"$schema": "../../schemas/v1/product-decision-record.schema.json"`.
  - Acceptance: same as P4-T2, for this file.

- [ ] [P4-T8] Create `docs/discovery/templates/artifacts/evidence-reference.template.json` with the same structure as P4-T2, `"$schema": "../../schemas/v1/evidence-reference.schema.json"`.
  - Acceptance: same as P4-T2, for this file.

- [ ] [P4-T9] Write unit test `test_domain_neutrality_templates_contain_no_disallowed_tokens` in `tests/scripts/dev_tools/discovery/test_domain_neutrality.py`, reading every file under `docs/discovery/templates/` (the 8 files created in P4-T1–P4-T8) from the in-repo checkout via `pathlib.Path.read_text`, and asserting a compiled case-insensitive regex over the disallowed-token list (`TaskMaster`, `TMW`, `Outlook`, `VSTO`) finds zero matches across all 8 files.
  - Acceptance: test passes against the 8 template files; test reads only in-repo files already present at collection time (no temp files created).

- [ ] [P4-T10] Write unit test `test_domain_neutrality_rendered_output_contains_no_disallowed_tokens` in `tests/scripts/dev_tools/discovery/test_domain_neutrality.py`, seeding a `FakeFileSystem` (per P2-T5) from the real `docs/discovery/templates/` file contents (read via `pathlib.Path.read_text`, then loaded into the fake), invoking `create_discovery_workspace(...)` against an in-memory target, and asserting the same disallowed-token regex finds zero matches in every one of the 8 captured output files.
  - Acceptance: test passes; no real target directory is created on disk.

- [ ] [P4-T11] Write unit test `test_schema_conformance_pending_issue_9002` in `tests/scripts/dev_tools/discovery/test_init_flow.py`, decorated with `@pytest.mark.skip(reason="blocked pending legacy-discovery-schemas issue 9002: no schema files exist in the repository yet")`, containing the intended assertion body (validating each of the 8 generated starter artifacts against its planned schema file once 9002 lands) written against 9002's planned schema-versioning shape, with an inline comment citing issue 9002.
  - Acceptance: the test is collected by pytest and reported as `skipped` (not `failed`, not silently removed); the skip reason string contains "9002".

### Phase 5 — Poetry console-script registration

- [ ] [P5-T1] Add the line `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"` to root `pyproject.toml`'s `[tool.poetry.scripts]` `# Dev Tools Aliases` block, inserted alphabetically between the existing `"dev.collect-commit-context"` line and the existing `"dev.fix-all"` line.
  - Acceptance: `pyproject.toml` contains the exact literal line; the line appears strictly between the two named existing lines when the file is viewed in order.

- [ ] [P5-T2] Write unit test `test_console_script_registered_in_pyproject` in `tests/scripts/dev_tools/discovery/test_init_cli.py`, reading `pyproject.toml` text via `pathlib.Path.read_text` and asserting the literal string `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"` is present.
  - Acceptance: test passes after P5-T1 is complete; test reads only the in-repo `pyproject.toml` file (no temp files).

### Phase 6 — Full QC Loop

- [ ] [P6-T1] Run `poetry run black --check .` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/phase6-black.md` with `Timestamp:`, `Command: poetry run black --check .`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: evidence file exists with `EXIT_CODE: 0` and all four fields populated from the actual command run; command executes unconditionally (no `SKIPPED` outcome).

- [ ] [P6-T2] Run `poetry run ruff check .` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/phase6-ruff.md` with `Timestamp:`, `Command: poetry run ruff check .`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: evidence file exists with `EXIT_CODE: 0` and all four fields populated from the actual command run; command executes unconditionally.

- [ ] [P6-T3] Run `poetry run pyright` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/phase6-pyright.md` with `Timestamp:`, `Command: poetry run pyright`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: evidence file exists with `EXIT_CODE: 0` and all four fields populated from the actual command run; command executes unconditionally.

- [ ] [P6-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/phase6-pytest.md` with `Timestamp:`, `Command: poetry run pytest --cov --cov-branch --cov-report=term-missing`, `EXIT_CODE:`, and `Output Summary:` recording the numeric post-change line-coverage percent and branch-coverage percent, plus pass/fail counts (including the one expected `skipped` test from P4-T11).
  - Acceptance: evidence file exists with `EXIT_CODE: 0`, `Output Summary:` contains two explicit numeric coverage percentages meeting line >= 85% and branch >= 75%; command executes unconditionally.

- [ ] [P6-T5] Compare the P0-T5 baseline coverage against the P6-T4 post-change coverage and write `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/phase6-coverage-delta.md` recording `Baseline Line Coverage:`, `Baseline Branch Coverage:`, `Post-Change Line Coverage:`, `Post-Change Branch Coverage:`, `New-Code Coverage (scripts/dev_tools/discovery/):`, and a `PASS`/`FAIL` verdict against the line >= 85% / branch >= 75% thresholds and the no-regression-on-changed-lines rule.
  - Acceptance: evidence file exists with all six fields populated with numeric values (no `UNVERIFIED` placeholders) and an explicit `PASS` verdict; a `FAIL` verdict blocks Final Phase completion and requires remediation before the plan can be reported complete.

- [ ] [P6-T6] If any of P6-T1–P6-T4 reports a non-zero `EXIT_CODE` or an auto-fixer (Black/Ruff `--fix`) modifies any file, restart the loop from P6-T1 and re-capture all four evidence artifacts (P6-T1–P6-T4) until a single pass completes with all four `EXIT_CODE: 0` values recorded within the same iteration; re-run P6-T5 against the final passing iteration's coverage numbers.
  - Acceptance: the final P6-T1–P6-T4 evidence artifacts all show `EXIT_CODE: 0` with `Timestamp:` values from the same iteration, and P6-T5 reflects that same iteration's coverage numbers.

## Test Plan

- **Unit tests:** `tests/scripts/dev_tools/discovery/test_init_models.py` (Phase 1), `tests/scripts/dev_tools/discovery/test_init_flow.py` (Phase 2, Phase 4 schema-conformance placeholder), `tests/scripts/dev_tools/discovery/test_init_cli.py` (Phase 3, Phase 5 registration check), `tests/scripts/dev_tools/discovery/test_domain_neutrality.py` (Phase 4).
- **Integration:** none — this feature is a one-shot scaffolding CLI with no external-service or cross-process integration surface; the fake-`FileSystem`-backed unit tests in Phase 2 are the full behavioral verification, consistent with research section "Testing Implications".
- **Manual/CLI:** `poetry run dev.discovery.init <target-dir>` and `poetry run dev.discovery.init <target-dir> --template-root <path> --force` are exercised only through the automated CLI-level tests in Phase 3 (`monkeypatch`-injected `sys.argv`), not as a separate manual step.
- **Coverage evidence:**
  - Baseline: `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/baseline/phase0-pytest-baseline.md`
  - Post-change: `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/phase6-pytest.md`
  - Delta/threshold verification: `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/phase6-coverage-delta.md`

## Open Questions / Notes

- **Owned by feature 9002 (not resolved by this feature):** whether `$schema` in a generated artifact instance, scaffolded outside `drm-copilot` into a consumer repository's workspace, should remain a relative path (requiring the consumer to vendor a copy of the schemas) or become an absolute/versioned URI. This plan's templates copy 9002's eventual convention verbatim; no second convention is introduced here.
- **Owned by feature 9001 (not resolved by this feature):** whether the domain-profile config contract ultimately requires nested structure (e.g. a list of stack identifiers), which would require a follow-up edit to `docs/discovery/templates/domain-profile/domain-profile.yaml` once 9001's contract is finalized.
- **Schema-conformance test (P4-T11):** intentionally implemented as a single `@pytest.mark.skip`-marked test citing issue 9002, per spec's instruction that this dependency "must not be silently skipped or removed from the plan." This is distinct from the Final Phase's "no SKIPPED command tasks" rule, which governs whole toolchain command invocations (Phase 6's Black/Ruff/Pyright/Pytest commands all execute unconditionally and must report `EXIT_CODE: 0`); a single documented-pending pytest test case marked `skip` does not change the pytest command's own exit code.
