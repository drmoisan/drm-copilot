# legacy-discovery-validators - Plan

- **Issue:** #361
- **Epic:** legacy-discovery-and-parity (child #9003)
- **Owner:** drmoisan
- **Last Updated:** 2026-07-17T14-03
- **Status:** Ready for Preflight
- **Work Mode:** full-feature
- **Version:** 0.2

## Required References

- Repository tone/policy order: `CLAUDE.md`
- General code-change policy: `.claude/rules/general-code-change.md`
- General unit-test policy: `.claude/rules/general-unit-test.md`
- Python toolchain and coding standards: `.claude/rules/python.md`
- Python suppression policy: `.claude/rules/python-suppressions.md`
- Quality tiers / coverage thresholds: `.claude/rules/quality-tiers.md`
- Feature documents: `issue.md`, `spec.md`, `user-story.md`,
  `research/research-input.md` (all in this feature folder)
- Epic documents: `docs/features/epics/legacy-discovery-and-parity/objective-source.md`
  (sections 3-5), `docs/features/epics/legacy-discovery-and-parity/epic.md` (Shared Design)

**All work must comply with these policies; do not duplicate their content here.**

## Evidence Location

All evidence artifacts for this plan are written under
`docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/<kind>/`
(`baseline/`, `regression-testing/`, `qa-gates/`, `other/`) per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No evidence is written
under any `artifacts/` path. Every evidence filename below uses the ISO-8601
timestamp format `yyyy-MM-ddTHH-mm` at the point the command is actually run
(shown as `<TS>` in file paths below).

## Design Decisions (binding on implementation)

These decisions resolve the open questions flagged in `research/research-input.md`
section 9 and are binding for the tasks below; they are not re-litigated per task.

1. **`all` subparser semantics** (resolves research-input.md §9 item 8): `all` takes
   one positional `path` and validates it against every one of the eight
   artifact-type validators, in the fixed order `profile`, `feature-contract`,
   `coverage-ledger`, `runtime-scenario`, `parity-matrix`, `unspecified-behavior`,
   `product-decision`, `evidence-reference`. It returns success (`[]`) on the
   first per-type validator that returns an empty list. If every per-type
   validator returns errors, `all` returns the aggregated errors with each
   message prefixed `f"{artifact_type}: {message}"`. `all` never inspects file
   content or path shape to guess a type; it is a "does this path conform to any
   known type" check, not a directory scan.
2. **Error-message prefixing scheme**: individual `validate_<artifact>_text`
   functions return bare error strings with no artifact-type prefix (matching the
   existing `validate_plan_text`/`validate_policy_audit_text` precedent in
   `validate_orchestration_artifacts.py`, none of which embed their own artifact
   name in error text). The `f"{artifact_type}: {message}"` prefix is added only
   by `all`'s aggregation step. This avoids double-prefixing and matches the exact
   `feature-contract: <error>` example in spec.md's Implementation Strategy.
3. **Shared-extraction scope**: only the schema-resolution logic (`_load_schema`,
   `_cache_path`) is promoted to the new public `scripts/dev_tools/schema_loading.py`
   module. The `Draft202012Validator` error-formatting expression is
   independently re-implemented (not extracted) in
   `scripts/dev_tools/validate_discovery_schema_artifacts.py`, because
   `validate_json.py`'s optional-jsonschema fallback branch
   (`_collect_schema_errors`, used when the `jsonschema` package is absent) has
   no discovery-validator equivalent — `jsonschema` (`^4.25.1`) is a mandatory,
   already-declared dependency for the discovery validators, so there is no
   fallback branch to share and extracting only the formatting expression would
   add a seam with no reuse benefit.
4. **Profile parser scaffold**: `validate_discovery_profile.py` parses profile
   text with `yaml.safe_load` (PyYAML `>=6.0`, already declared in
   `pyproject.toml`, previously unused outside `push_down_claude_filesystem.py`)
   as the provisional parser, pending #9001's final parser decision (PyYAML vs.
   hand-rolled frontmatter regex, per research-input.md §3). The public
   `validate_profile_text(text: str) -> list[str]` contract is stable regardless
   of which parser #9001 ultimately specifies, since callers always pass raw
   text.
5. **Profile required-field placeholder**: pending #9001, the only enforced
   required field is `legacy_source_path` (`_PLACEHOLDER_REQUIRED_FIELDS` in
   `validate_discovery_profile.py`), taken directly from the illustrative error
   example in spec.md's API/CLI Surface section (`Missing required field:
   legacy_source_path.`) and marked `# TODO(#9001)`. This is a single isolated
   seam (`_check_required_profile_fields`) so only that function changes once
   #9001 finalizes the field contract.
6. **Schema-location seam**: per-schema validators resolve their schema solely
   via the artifact's own `$schema` field, through `_extract_schema_uri` (the
   `_resolve_schema_path`-equivalent seam) and the shared `schema_loading.load_schema`
   function, with no hardcoded `schemas/vN` layout or version string. Because the
   pure `validate_<schema>_text(text: str) -> list[str]` functions receive no
   file path (per the canonical pattern), only `$schema` values with an explicit
   scheme (`file://`, `http://`, `https://`) can resolve; a scheme-less `$schema`
   value fails schema resolution and is reported as an error string, not an
   unhandled exception. This constraint is documented in the module docstring.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture & Policy Compliance

- [x] [P0-T1] Read `CLAUDE.md` in full.
  - Acceptance: file contents reviewed; no edits made to the file.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` in full.
  - Acceptance: file contents reviewed; no edits made to the file.
- [x] [P0-T3] Read `.claude/rules/general-unit-test.md` in full.
  - Acceptance: file contents reviewed; no edits made to the file.
- [x] [P0-T4] Read `.claude/rules/python.md` in full.
  - Acceptance: file contents reviewed; no edits made to the file.
- [x] [P0-T5] Read `.claude/rules/python-suppressions.md` in full.
  - Acceptance: file contents reviewed; no edits made to the file.
- [x] [P0-T6] Write
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/other/phase0-instructions-read.md`
  containing `Timestamp:`, `Policy Order:` (listing CLAUDE.md,
  general-code-change.md, general-unit-test.md, python.md,
  python-suppressions.md in that order), and the explicit list of files read in
  P0-T1..P0-T5.
  - Acceptance: file exists with all four required fields populated (no
    placeholder text).
- [x] [P0-T7] Run `poetry run black --check .` at current HEAD and record the
  result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-black.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: artifact exists with all four fields populated; `EXIT_CODE` is
    the literal integer the command returned (no `SKIPPED`).
- [x] [P0-T8] Run `poetry run ruff check .` at current HEAD and record the
  result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-ruff.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (including
  the reported violation count).
  - Acceptance: artifact exists with all four fields populated; no `SKIPPED`.
- [x] [P0-T9] Run `poetry run pyright` at current HEAD and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-pyright.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` (including
  the reported error/warning counts).
  - Acceptance: artifact exists with all four fields populated; no `SKIPPED`.
- [x] [P0-T10] Run
  `poetry run pytest --cov --cov-branch --cov-report=term-missing` at current
  HEAD and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/baseline/baseline-pytest.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` that
  includes the numeric baseline total line-coverage percentage and total
  branch-coverage percentage.
  - Acceptance: artifact exists with all four fields populated, `Output
    Summary:` contains two explicit numeric percentages (line and branch); no
    `SKIPPED`.

### Phase 1 — Shared Schema-Loading Extraction (modifies `validate_json.py`)

- [x] [P1-T1] Create `scripts/dev_tools/schema_loading.py` with a module
  docstring citing the epic Shared Design's schema-loading reuse requirement
  (`docs/features/epics/legacy-discovery-and-parity/epic.md`), importing
  `hashlib`, `json`, `urllib.request`, `Path` from `pathlib`, `Any` from
  `typing`, and `urlparse` from `urllib.parse`.
  - Acceptance: file exists, imports resolve, module has no other content yet.
- [x] [P1-T2] Implement public `cache_path(cache_dir: Path, uri: str) -> Path`
  in `scripts/dev_tools/schema_loading.py`, moving the SHA-256-keyed
  cache-filename logic currently in `scripts/dev_tools/validate_json.py::_cache_path`
  verbatim (no behavior change).
  - Acceptance: `cache_path(cache_dir, uri)` returns
    `cache_dir / f"{hashlib.sha256(uri.encode('utf-8')).hexdigest()}.json"` for
    any `uri`.
- [x] [P1-T3] Implement public
  `load_schema(uri: str, cache_dir: Path, base_path: Path | None = None) -> dict[str, Any]`
  in `scripts/dev_tools/schema_loading.py`, moving the scheme-resolution logic
  currently in `scripts/dev_tools/validate_json.py::_load_schema` verbatim (no
  behavior change), calling the new `cache_path` function for the `http(s)://`
  branch.
  - Acceptance: function signature and scheme-branch behavior (no-scheme
    relative to `base_path.parent`, `file://` absolute, `http(s)://` fetched and
    cached, else `ValueError`) match the moved-from logic exactly.
- [x] [P1-T4] Modify `scripts/dev_tools/validate_json.py`: add
  `from scripts.dev_tools.schema_loading import cache_path, load_schema` and
  replace the body of `_cache_path` with `return cache_path(cache_dir, uri)`,
  preserving the private `_cache_path` name and signature as a thin wrapper.
  - Acceptance: `validate_json.py` still exposes a callable `_cache_path` with
    the same signature; `grep -n "def _cache_path" scripts/dev_tools/validate_json.py`
    returns exactly one match.
- [x] [P1-T5] Modify `scripts/dev_tools/validate_json.py`: replace the body of
  `_load_schema` with `return load_schema(uri, cache_dir, base_path)`, preserving
  the private `_load_schema` name and signature as a thin wrapper.
  - Acceptance: `validate_json.py` still exposes a callable `_load_schema` with
    the same signature; `grep -n "def _load_schema" scripts/dev_tools/validate_json.py`
    returns exactly one match.
- [x] [P1-T6] Run
  `poetry run pytest tests/scripts/dev_tools/test_validate_json.py -q` and
  record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/regression-testing/validate-json-regression.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` confirming
  every pre-existing test in that file still passes unchanged (no test file
  edits made in this task).
  - Acceptance: `EXIT_CODE: 0` recorded; `Output Summary:` states the passed
    test count with zero failures.
- [x] [P1-T7] Create `tests/scripts/dev_tools/test_schema_loading.py` with
  `test_cache_path_generates_deterministic_hash`, asserting
  `schema_loading.cache_path(cache_dir, uri)` returns the same `Path` for two
  calls with the same `uri` and that the result's parent is `cache_dir` and
  suffix is `.json`.
  - Acceptance: test passes via `poetry run pytest tests/scripts/dev_tools/test_schema_loading.py::test_cache_path_generates_deterministic_hash -q`.
- [x] [P1-T8] Add `test_load_schema_from_cache` to
  `tests/scripts/dev_tools/test_schema_loading.py`, using the `mem_fs_path`
  fixture to write a cached schema file at the path returned by `cache_path`
  and asserting `schema_loading.load_schema(uri, cache_dir)` returns the parsed
  cached content without a network call.
  - Acceptance: test passes; no temporary files created on real disk.
- [x] [P1-T9] Add `test_load_schema_unsupported_scheme` to
  `tests/scripts/dev_tools/test_schema_loading.py`, asserting
  `schema_loading.load_schema("ftp://example.com/schema.json", cache_dir)`
  raises `ValueError` matching `"Unsupported schema URI scheme"`.
  - Acceptance: test passes.
- [x] [P1-T10] Add `test_load_schema_relative_path` to
  `tests/scripts/dev_tools/test_schema_loading.py`, using the `mem_fs_path`
  fixture to write a schema file and asserting
  `schema_loading.load_schema("./schema.json", cache_dir, source_path)`
  resolves the schema relative to `source_path.parent` and returns its parsed
  content.
  - Acceptance: test passes; no temporary files created on real disk.
- [x] [P1-T11] Add `test_load_schema_missing_scheme` to
  `tests/scripts/dev_tools/test_schema_loading.py`, asserting
  `schema_loading.load_schema("no-scheme-here", cache_dir)` (no `base_path`
  supplied) raises `ValueError` matching `"Unsupported schema URI scheme"`.
  - Acceptance: test passes.

### Phase 2 — Domain-Profile Validator (#9001 seam)

- [x] [P2-T1] Create `scripts/dev_tools/validate_discovery_profile.py` with a
  module docstring citing #9001 (`legacy-discovery-config-contract`) as the
  upstream contract this validator checks against, and define
  `_PLACEHOLDER_REQUIRED_FIELDS: tuple[str, ...] = ("legacy_source_path",)`
  with an adjacent `# TODO(#9001): replace with the finalized field contract
  once #9001 ships.` comment.
  - Acceptance: file exists; `_PLACEHOLDER_REQUIRED_FIELDS` is defined with
    exactly one element, `"legacy_source_path"`.
- [x] [P2-T2] Implement
  `_parse_profile_mapping(text: str) -> tuple[dict[str, Any] | None, list[str]]`
  in `scripts/dev_tools/validate_discovery_profile.py`, calling
  `yaml.safe_load(text)` inside `try/except yaml.YAMLError` (importing `yaml`
  from PyYAML per Design Decision 4), returning `(None, [<one error string>])`
  on a parse failure, `(None, ["Profile document root must be a mapping."])`
  when the parsed value is not a `dict`, and `(mapping, [])` on success.
  - Acceptance: function exists with the documented signature and three
    documented return branches.
- [x] [P2-T3] Implement
  `_check_required_profile_fields(mapping: dict[str, Any]) -> list[str]` in
  `scripts/dev_tools/validate_discovery_profile.py`, appending
  `f"Missing required field: {field}."` for each field in
  `_PLACEHOLDER_REQUIRED_FIELDS` absent from `mapping`, with an adjacent
  `# TODO(#9001)` comment.
  - Acceptance: function returns `[]` when `mapping` contains
    `legacy_source_path` and `["Missing required field: legacy_source_path."]`
    when it does not.
- [x] [P2-T4] Implement `validate_profile_text(text: str) -> list[str]` in
  `scripts/dev_tools/validate_discovery_profile.py`, returning
  `["Profile document is empty."]` for empty/whitespace-only `text`,
  otherwise composing `_parse_profile_mapping` and, only when parsing succeeds,
  `_check_required_profile_fields`.
  - Acceptance: function exists with the documented signature and
    short-circuit behavior (field checks skipped when parsing fails).
- [x] [P2-T5] Create `tests/scripts/dev_tools/test_validate_discovery_profile.py`
  with `test_validate_profile_text_rejects_empty_document`, asserting
  `validate_profile_text("")` returns `["Profile document is empty."]`.
  - Acceptance: test passes.
- [x] [P2-T6] Add `test_validate_profile_text_rejects_malformed_yaml` to
  `tests/scripts/dev_tools/test_validate_discovery_profile.py`, asserting
  `validate_profile_text("key: [unterminated")` returns a list with exactly one
  error string and raises no exception.
  - Acceptance: test passes.
- [x] [P2-T7] Add `test_validate_profile_text_rejects_non_mapping_root` to
  `tests/scripts/dev_tools/test_validate_discovery_profile.py`, asserting
  `validate_profile_text("- one\n- two\n")` returns
  `["Profile document root must be a mapping."]`.
  - Acceptance: test passes.
- [x] [P2-T8] Add `test_validate_profile_text_reports_missing_legacy_source_path`
  to `tests/scripts/dev_tools/test_validate_discovery_profile.py`, asserting
  `validate_profile_text("some_other_key: value\n")` returns
  `["Missing required field: legacy_source_path."]`.
  - Acceptance: test passes.
- [x] [P2-T9] Add
  `test_validate_profile_text_accepts_conforming_minimal_profile` to
  `tests/scripts/dev_tools/test_validate_discovery_profile.py`, asserting
  `validate_profile_text("legacy_source_path: /path/to/legacy\n")` returns `[]`.
  - Acceptance: test passes.

### Phase 3 — Discovery Schema Validators (#9002 seam)

- [x] [P3-T1] Create `scripts/dev_tools/validate_discovery_schema_artifacts.py`
  with a module docstring citing #9002 (`legacy-discovery-schemas`) as the
  upstream schema/versioning contract and documenting the schema-location
  constraint from Design Decision 6; import `json`, `Path` from `pathlib`,
  `Any` and `Mapping` from `typing`/`collections.abc`, `Draft202012Validator`
  from `jsonschema`, and `load_schema` from `scripts.dev_tools.schema_loading`;
  define `_DEFAULT_CACHE_DIR: Path = Path(".cache/schemas")`.
  - Acceptance: file exists, imports resolve, `_DEFAULT_CACHE_DIR` is defined.
- [x] [P3-T2] Implement `_extract_schema_uri(data: Mapping[str, Any]) -> str` in
  `scripts/dev_tools/validate_discovery_schema_artifacts.py` — the
  `_resolve_schema_path`-equivalent seam cited in spec.md's Constraints &
  Risks — raising `ValueError("missing $schema")` when `data.get("$schema")` is
  absent or not a non-empty string, otherwise returning it.
  - Acceptance: `_extract_schema_uri({})` raises `ValueError`;
    `_extract_schema_uri({"$schema": "https://x/y.json"})` returns
    `"https://x/y.json"`.
- [x] [P3-T3] Implement
  `_validate_against_schema(text: str, artifact_type: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR) -> list[str]`
  in `scripts/dev_tools/validate_discovery_schema_artifacts.py`: parse `text`
  as JSON inside `try/except json.JSONDecodeError` returning
  `[f"invalid JSON ({exc})"]`; reject a non-`dict` root with
  `["JSON root must be an object for validation"]`; resolve the schema via
  `_extract_schema_uri` and `load_schema` inside
  `try/except (ValueError, FileNotFoundError, OSError, json.JSONDecodeError)`
  returning `[f"schema resolution failed ({exc})"]`; otherwise run
  `Draft202012Validator(schema).iter_errors(data)`, sort by `e.path`, and
  format each as `f"{list(err.path)}: {err.message}"` (mirroring
  `validate_json.py:213-221`, per Design Decision 2 with no artifact-type
  prefix).
  - Acceptance: function exists with the documented signature and all four
    documented branches; no branch raises an uncaught exception.
- [x] [P3-T4] Implement
  `validate_feature_contract_text(text: str, *, cache_dir: Path = _DEFAULT_CACHE_DIR) -> list[str]`
  in `scripts/dev_tools/validate_discovery_schema_artifacts.py` as
  `return _validate_against_schema(text, "feature-contract", cache_dir=cache_dir)`.
  - Acceptance: function exists and delegates with `artifact_type="feature-contract"`.
- [x] [P3-T5] Implement `validate_coverage_ledger_text(...)` in the same file,
  delegating to `_validate_against_schema` with `artifact_type="coverage-ledger"`.
  - Acceptance: function exists and delegates with `artifact_type="coverage-ledger"`.
- [x] [P3-T6] Implement `validate_runtime_scenario_text(...)` in the same file,
  delegating to `_validate_against_schema` with `artifact_type="runtime-scenario"`.
  - Acceptance: function exists and delegates with `artifact_type="runtime-scenario"`.
- [x] [P3-T7] Implement `validate_parity_matrix_text(...)` in the same file,
  delegating to `_validate_against_schema` with `artifact_type="parity-matrix"`.
  - Acceptance: function exists and delegates with `artifact_type="parity-matrix"`.
- [x] [P3-T8] Implement `validate_unspecified_behavior_text(...)` in the same
  file, delegating to `_validate_against_schema` with
  `artifact_type="unspecified-behavior"`.
  - Acceptance: function exists and delegates with
    `artifact_type="unspecified-behavior"`.
- [x] [P3-T9] Implement `validate_product_decision_text(...)` in the same file,
  delegating to `_validate_against_schema` with `artifact_type="product-decision"`.
  - Acceptance: function exists and delegates with `artifact_type="product-decision"`.
- [x] [P3-T10] Implement `validate_evidence_reference_text(...)` in the same
  file, delegating to `_validate_against_schema` with
  `artifact_type="evidence-reference"`.
  - Acceptance: function exists and delegates with `artifact_type="evidence-reference"`.
- [x] [P3-T11] Create
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py` with
  `test_extract_schema_uri_raises_for_missing_schema_field`, asserting
  `_extract_schema_uri({})` raises `ValueError`.
  - Acceptance: test passes.
- [x] [P3-T12] Add `test_validate_against_schema_rejects_malformed_json` to
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py`,
  asserting `_validate_against_schema("{not json", "feature-contract")` returns
  a single-element list containing the substring `"invalid JSON"`, without
  raising.
  - Acceptance: test passes.
- [x] [P3-T13] Add
  `test_validate_against_schema_reports_missing_schema_field_as_error_string`
  to `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py`,
  asserting `_validate_against_schema(json.dumps({"acceptance_criteria": []}), "feature-contract")`
  returns a single-element list containing the substring
  `"schema resolution failed"`, without raising.
  - Acceptance: test passes.
- [x] [P3-T14] Add
  `test_validate_feature_contract_text_accepts_conforming_fixture` to
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py`,
  monkeypatching
  `validate_discovery_schema_artifacts.load_schema` to return the inline
  literal schema `{"type": "object", "required": ["acceptance_criteria"], "properties": {"acceptance_criteria": {"type": "array"}}}`,
  and asserting
  `validate_feature_contract_text(json.dumps({"$schema": "https://example.test/feature-contract.schema.json", "acceptance_criteria": []}))`
  returns `[]`.
  - Acceptance: test passes; no real network or disk schema fetch occurs.
- [x] [P3-T15] Add
  `test_validate_feature_contract_text_rejects_non_conforming_fixture` to
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py` (same
  monkeypatch as P3-T14), asserting
  `validate_feature_contract_text(json.dumps({"$schema": "https://example.test/feature-contract.schema.json"}))`
  returns a list whose sole element contains the substring
  `"['acceptance_criteria']"`.
  - Acceptance: test passes.
- [x] [P3-T16] Add a parametrized test
  `test_first_three_remaining_schema_validators_accept_conforming_fixtures` to
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py`,
  covering `validate_coverage_ledger_text`, `validate_runtime_scenario_text`,
  and `validate_parity_matrix_text`, monkeypatching `load_schema` per case to
  an inline literal permissive schema (`{"type": "object"}`), asserting each
  returns `[]` for a conforming inline-literal artifact carrying a `$schema`
  key.
  - Acceptance: test passes for all three parametrized cases.
- [x] [P3-T17] Create
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py`
  with a parametrized test
  `test_final_three_schema_validators_accept_and_reject_fixtures` covering
  `validate_unspecified_behavior_text`, `validate_product_decision_text`, and
  `validate_evidence_reference_text`, monkeypatching `load_schema` per case to
  the inline literal schema
  `{"type": "object", "required": ["decision_id"], "properties": {"decision_id": {"type": "string"}}}`,
  asserting each returns `[]` for a conforming fixture and a non-empty list
  containing `"decision_id"` for a fixture missing that field.
  - Acceptance: test passes for all three parametrized cases, both branches.

### Phase 4 — CLI Umbrella & `all` Semantics

- [ ] [P4-T1] Create `scripts/dev_tools/validate_discovery_artifacts.py` with a
  module docstring describing the umbrella CLI's role per spec.md's API/CLI
  Surface section, importing `argparse`, `sys`, `Path` from `pathlib`,
  `validate_profile_text` from `scripts.dev_tools.validate_discovery_profile`,
  and the seven `validate_<schema>_text` functions plus `load_schema` from
  `scripts.dev_tools.validate_discovery_schema_artifacts`.
  - Acceptance: file exists, all imports resolve.
- [ ] [P4-T2] Implement `_read_text(path: Path) -> str` in
  `scripts/dev_tools/validate_discovery_artifacts.py` as
  `return path.read_text(encoding="utf-8")`, mirroring
  `validate_orchestration_artifacts.py::_read_text`.
  - Acceptance: function exists with the documented signature and body.
- [ ] [P4-T3] Implement `build_parser() -> argparse.ArgumentParser` in
  `scripts/dev_tools/validate_discovery_artifacts.py`, adding one subparser per
  artifact type (`profile`, `feature-contract`, `coverage-ledger`,
  `runtime-scenario`, `parity-matrix`, `unspecified-behavior`,
  `product-decision`, `evidence-reference`, `all`) via
  `parser.add_subparsers(dest="artifact_type", required=True)`, each subparser
  taking exactly one positional `path` argument (including `all`, per Design
  Decision 1).
  - Acceptance: `build_parser().parse_args(["feature-contract", "x.json"])` and
    `build_parser().parse_args(["all", "x.json"])` both succeed and populate
    `args.path`.
- [ ] [P4-T4] Implement module-level
  `_ARTIFACT_VALIDATORS: tuple[tuple[str, Callable[[str], list[str]]], ...]` in
  `scripts/dev_tools/validate_discovery_artifacts.py` in the fixed order from
  Design Decision 1, and implement
  `_validate_all_text(text: str) -> list[str]` iterating
  `_ARTIFACT_VALIDATORS`, returning `[]` on the first empty per-type result,
  otherwise returning the aggregated `f"{artifact_type}: {message}"` list.
  - Acceptance: `_validate_all_text` returns `[]` when any one entry's
    validator returns `[]`, and returns a non-empty aggregated, prefixed list
    only when every entry's validator returns errors.
- [ ] [P4-T5] Implement `_validate_from_args(args: argparse.Namespace) -> list[str]`
  in `scripts/dev_tools/validate_discovery_artifacts.py`, reading the target
  file once via `_read_text(Path(args.path))`, dispatching to the matching
  `validate_<artifact>_text` function for each of the eight non-`all` artifact
  types, dispatching to `_validate_all_text` for `"all"`, and returning
  `[f"Unsupported artifact type: {args.artifact_type}"]` for any other value.
  - Acceptance: dispatch covers all nine recognized `artifact_type` values plus
    the unsupported-type fallback.
- [ ] [P4-T6] Implement `main(argv: list[str] | None = None) -> int` in
  `scripts/dev_tools/validate_discovery_artifacts.py` per the canonical
  contract: parse args via `build_parser()`, call `_validate_from_args`, print
  each error to `stderr` and return `1` when errors is non-empty, otherwise
  print `f"{args.artifact_type} validation passed: {args.path}"` to `stdout`
  and return `0`; add the `if __name__ == "__main__": raise SystemExit(main())`
  guard.
  - Acceptance: `main(["profile", "<conforming path>"])`-style invocation (with
    `_read_text` stubbed in tests) returns `0` on success and `1` on failure,
    matching the documented stdout/stderr contract.
- [ ] [P4-T7] Implement eight thin wrapper functions in
  `scripts/dev_tools/validate_discovery_artifacts.py` — `main_profile`,
  `main_feature_contract`, `main_coverage_ledger`, `main_runtime_scenario`,
  `main_parity_matrix`, `main_unspecified_behavior`, `main_product_decision`,
  `main_evidence_reference` — each returning
  `main(["<artifact-type>", *sys.argv[1:]])` with its literal artifact-type
  string.
  - Acceptance: all eight functions exist with the documented one-line bodies.
- [ ] [P4-T8] Create
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py` with
  a local `_stub_read_text(text: str) -> Callable[[Path], str]` helper
  (mirroring the `build_read_text_stub` pattern in
  `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`) that
  returns a callable ignoring its `path` argument and returning `text`.
  - Acceptance: helper exists and is used by at least one test in the same
    file (verified by the tasks below).
- [ ] [P4-T9] Add `test_validate_from_args_returns_unsupported_artifact_type`
  to `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`,
  asserting `_validate_from_args(argparse.Namespace(path="ignored", artifact_type="bogus"))`
  returns `["Unsupported artifact type: bogus"]`.
  - Acceptance: test passes.
- [ ] [P4-T10] Add `test_main_profile_returns_zero_for_conforming_fixture` to
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`,
  monkeypatching `_read_text` via `_stub_read_text("legacy_source_path: /x\n")`,
  asserting `main(["profile", "ignored.yaml"])` returns `0` and `capsys`
  captures exactly one stdout line matching
  `"profile validation passed: ignored.yaml"`.
  - Acceptance: test passes.
- [ ] [P4-T11] Add
  `test_main_profile_returns_one_for_missing_legacy_source_path` to
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`,
  monkeypatching `_read_text` via `_stub_read_text("other_key: value\n")`,
  asserting `main(["profile", "ignored.yaml"])` returns `1` and `capsys`
  captures a stderr line containing `"legacy_source_path"`.
  - Acceptance: test passes.
- [ ] [P4-T12] Add
  `test_main_feature_contract_returns_zero_for_conforming_fixture` to
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`,
  monkeypatching `_read_text` and monkeypatching
  `validate_discovery_artifacts.load_schema` to return the inline literal
  schema `{"type": "object", "required": ["acceptance_criteria"]}`, asserting
  `main(["feature-contract", "ignored.json"])` returns `0`.
  - Acceptance: test passes; no real schema fetch occurs.
- [ ] [P4-T13] Add
  `test_main_feature_contract_returns_one_for_non_conforming_fixture` to
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py` (same
  monkeypatch as P4-T12, with the fixture missing `acceptance_criteria`),
  asserting `main(["feature-contract", "ignored.json"])` returns `1` and
  `capsys` captures a stderr line containing `"acceptance_criteria"`.
  - Acceptance: test passes.
- [ ] [P4-T14] Add
  `test_main_all_returns_zero_when_path_conforms_to_at_least_one_type` to
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`,
  monkeypatching `_read_text` via `_stub_read_text("legacy_source_path: /x\n")`
  (conforms to `profile`, the first entry in `_ARTIFACT_VALIDATORS`), asserting
  `main(["all", "ignored.yaml"])` returns `0`.
  - Acceptance: test passes.
- [ ] [P4-T15] Add
  `test_main_all_returns_one_with_aggregated_per_type_errors_when_path_conforms_to_none`
  to `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`,
  monkeypatching `_read_text` via `_stub_read_text("")` (empty text fails every
  type), asserting `main(["all", "ignored.yaml"])` returns `1` and `capsys`
  captures stderr containing both a `"profile: "`-prefixed line and a
  `"feature-contract: "`-prefixed line.
  - Acceptance: test passes.
- [ ] [P4-T16] Add a parametrized test
  `test_main_artifact_wrappers_dispatch_with_correct_argv_prefix` to
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`
  covering all eight `main_<artifact>()` wrappers, monkeypatching `sys.argv`
  and the module-level `main` function, asserting each wrapper calls `main`
  with its documented artifact-type string as the first argv element.
  - Acceptance: test passes for all eight parametrized cases.

### Phase 5 — Poetry Console-Script Entries

- [ ] [P5-T1] Add the nine `dev.discovery.validate-*` console-script entries
  to `[tool.poetry.scripts]` in `pyproject.toml`, exactly as enumerated in
  spec.md's API/CLI Surface section: `dev.discovery.validate-profile`,
  `dev.discovery.validate-feature-contract`,
  `dev.discovery.validate-coverage-ledger`,
  `dev.discovery.validate-runtime-scenario`,
  `dev.discovery.validate-parity-matrix`,
  `dev.discovery.validate-unspecified-behavior`,
  `dev.discovery.validate-product-decision`,
  `dev.discovery.validate-evidence-reference` (each targeting its matching
  `main_<artifact>` wrapper in `scripts.dev_tools.validate_discovery_artifacts`),
  and `dev.discovery.validate-all` (targeting
  `scripts.dev_tools.validate_discovery_artifacts:main`).
  - Acceptance: all nine dotted keys are present in `pyproject.toml` under
    `[tool.poetry.scripts]` with the exact target strings from spec.md.
- [ ] [P5-T2] Verify `pyproject.toml` remains syntactically valid TOML after
  the P5-T1 edit by running
  `python -c "import tomllib, pathlib; tomllib.loads(pathlib.Path('pyproject.toml').read_text())"`
  and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/other/pyproject-toml-syntax-check.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: `EXIT_CODE: 0` recorded.

### Phase 6 — Domain-Neutrality Verification

- [ ] [P6-T1] Run
  `rg -i -l "TaskMaster|TMW|Outlook|VSTO|task-management" scripts/dev_tools/schema_loading.py scripts/dev_tools/validate_discovery_profile.py scripts/dev_tools/validate_discovery_schema_artifacts.py scripts/dev_tools/validate_discovery_artifacts.py scripts/dev_tools/validate_json.py tests/scripts/dev_tools/test_schema_loading.py tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`
  and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/domain-neutrality-grep.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:` (documenting explicitly that
  `EXIT_CODE: 1` under ripgrep's convention means "no matches found" and is the
  passing signal for this specific gate, distinct from a toolchain failure),
  and `Output Summary:`.
  - Acceptance: recorded `EXIT_CODE` is `1` (no matches) and `Output Summary:`
    states zero domain-specific identifiers were found across all listed
    files; if any match is found, this task is not complete and the matching
    file(s) must be corrected before proceeding.

### Phase 7 — Final QA Loop (Full Python Toolchain)

- [ ] [P7-T1] Run `poetry run black --check .` and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-black.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If this
  command reports reformatting or exits non-zero, run `poetry run black .` and
  restart the loop from this task.
  - Acceptance: artifact recorded with `EXIT_CODE: 0` on the final run; no
    `SKIPPED`.
- [ ] [P7-T2] Run `poetry run ruff check .` and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-ruff.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If this
  command reports violations or auto-fixes files, restart the loop from P7-T1.
  - Acceptance: artifact recorded with `EXIT_CODE: 0` on the final run; no
    `SKIPPED`.
- [ ] [P7-T3] Run `poetry run pyright` and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pyright.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If this
  command reports errors, restart the loop from P7-T1 after fixing them.
  - Acceptance: artifact recorded with `EXIT_CODE: 0` on the final run; no
    `SKIPPED`.
- [ ] [P7-T4] Run
  `poetry run pytest --cov --cov-branch --cov-report=term-missing` and record
  the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pytest.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including
  the numeric aggregate post-change total line-coverage percentage and total
  branch-coverage percentage. If any test fails, restart the loop from P7-T1
  after fixing the regression.
  - Acceptance: artifact recorded with `EXIT_CODE: 0` and two explicit numeric
    percentages in `Output Summary:`; no `SKIPPED`.
- [ ] [P7-T5] Run
  `poetry run pytest --cov=scripts.dev_tools.schema_loading --cov=scripts.dev_tools.validate_discovery_profile --cov=scripts.dev_tools.validate_discovery_schema_artifacts --cov=scripts.dev_tools.validate_discovery_artifacts --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_schema_loading.py tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`
  and record the result at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pytest-new-code.<TS>.md`
  with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including
  the numeric new-code line-coverage percentage and branch-coverage percentage
  scoped to exactly these four new modules.
  - Acceptance: artifact recorded with `EXIT_CODE: 0` and two explicit numeric
    percentages in `Output Summary:`; no `SKIPPED`.
- [ ] [P7-T6] Record the Phase 7 rerun-loop outcome at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-rerun-log.<TS>.md`
  with `Timestamp:` and an `Output Summary:` stating either that P7-T1 through
  P7-T5 completed in one uninterrupted clean pass with no restart, or
  enumerating each restart cycle (which stage failed/auto-fixed, and the
  timestamp of the corrected re-run) until the final clean pass.
  - Acceptance: artifact exists and its `Output Summary:` matches the actual
    sequence of P7-T1..P7-T5 executions (verifiable against their individual
    `EXIT_CODE` and `Timestamp` fields).
- [ ] [P7-T7] Produce the coverage delta/threshold verification artifact at
  `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/coverage-delta-verification.<TS>.md`
  reporting three numeric pairs — baseline line/branch % (from P0-T10's
  artifact), post-change aggregate line/branch % (from P7-T4's artifact), and
  new-code line/branch % (from P7-T5's artifact) — and stating explicitly
  whether post-change coverage regresses against baseline and whether new-code
  coverage meets the uniform thresholds (line >= 85%, branch >= 75%).
  - Acceptance: artifact records all three numeric pairs verbatim from their
    source artifacts and states a PASS/FAIL determination for both the
    no-regression check and the new-code threshold check; if either check
    fails, this task's outcome is FAIL and the plan's overall completion
    status must not be reported as PASS until remediated.

## Test Plan

- **Unit:** `tests/scripts/dev_tools/test_schema_loading.py`,
  `tests/scripts/dev_tools/test_validate_discovery_profile.py`,
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts.py`,
  `tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py`,
  `tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py`
  (all new); `tests/scripts/dev_tools/test_validate_json.py` (existing,
  unchanged, re-run for regression per P1-T6).
- **Integration:** CLI dispatch tests in
  `test_validate_discovery_artifacts_dispatch.py` exercise `main()` and the
  eight `main_<artifact>()` wrappers end-to-end (argv -> dispatch -> exit code
  -> stdout/stderr) with `_read_text` and `load_schema` monkeypatched; no real
  file I/O or network calls.
- **Manual/CLI:** none required; all CLI behavior is covered by the automated
  dispatch tests above using in-memory stubs, per the no-temp-file policy.
- **Fixture note:** #9002 has not shipped conforming/non-conforming fixtures
  as of this plan. All schema-validator tests use inline literal JSON schemas
  and inline literal artifact text (per research-input.md §3, §9 item 4).
  Fixture-based tests wired to #9002's committed fixture set are follow-up
  work once #9002 ships and are out of scope for this plan.
- **Coverage evidence:** baseline —
  `evidence/baseline/baseline-pytest.<TS>.md` (P0-T10); post-change aggregate —
  `evidence/qa-gates/final-qc-pytest.<TS>.md` (P7-T4); new-code —
  `evidence/qa-gates/final-qc-pytest-new-code.<TS>.md` (P7-T5); delta/threshold
  verification — `evidence/qa-gates/coverage-delta-verification.<TS>.md`
  (P7-T7).

## Acceptance-Criteria Traceability

| spec.md / user-story.md AC | Satisfied by |
|---|---|
| Pure `validate_<artifact>_text` function per artifact type (config + 7 schemas), returning `list[str]` | Phase 2 (P2-T4), Phase 3 (P3-T4..P3-T10) |
| Single argparse CLI, one subparser per type plus `all`, canonical stdout/stderr/exit-code contract | Phase 4 (P4-T3, P4-T5, P4-T6) |
| `dev.discovery.validate-*` Poetry console-script entries registered | Phase 5 (P5-T1) |
| Each validator accepts conforming and rejects non-conforming fixtures with human-readable errors | Phase 2 (P2-T5..P2-T9), Phase 3 (P3-T11..P3-T17), Phase 4 (P4-T10..P4-T13) |
| Per-schema validators locate schemas via #9002's convention (via `$schema`, no hardcoded layout) | Design Decision 6; Phase 3 (P3-T2, P3-T3) |
| No domain-specific identifier in validator source | Phase 6 (P6-T1) |
| Tests satisfy quality-tier policy (line >= 85%, branch >= 75%), mirrored `tests/` tree | Phase 7 (P7-T4, P7-T5, P7-T7); all test files under `tests/scripts/dev_tools/` |
| `all` subcommand: succeeds on >=1 conforming type; reports per-type-prefixed errors when none conform | Design Decision 1; Phase 4 (P4-T4, P4-T14, P4-T15) |
| Malformed input surfaced as error string, not an uncaught exception | Phase 2 (P2-T6), Phase 3 (P3-T12, P3-T13) |
| `validate_json.py`'s existing tests still pass unchanged (shared-extraction, no behavior change) | Phase 1 (P1-T4, P1-T5, P1-T6) |

## Open Questions / Notes

- #9001 (`legacy-discovery-config-contract`) and #9002 (`legacy-discovery-schemas`)
  are wave-0 features not yet present in this worktree. The two upstream seams
  (`_check_required_profile_fields` for #9001's field contract;
  `_extract_schema_uri` for #9002's versioning convention) are isolated per
  Design Decisions 5 and 6 so that integrating the finalized contracts touches
  only those two functions.
- `best_match`-style schema error consolidation (for schemas using top-level
  `oneOf`/`anyOf`) is not implemented in this plan because #9002's schemas do
  not yet exist to confirm the need (research-input.md §9 item 5). If #9002
  ships schemas using `oneOf`/`anyOf` at the root, a follow-up task should add
  `jsonschema.exceptions.best_match` handling to `_validate_against_schema`.
- `quality-tiers.yml` does not exist at repo root (tracked gap, issue #336).
  Coverage thresholds are uniform across tiers regardless, so this plan is not
  blocked by that gap.
