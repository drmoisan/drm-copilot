# Research Input — legacy-discovery-validators (#361)

Durable research-input material for the atomic-planner and epic-orchestrator execution phase. Prepared 2026-07-17 for the legacy-discovery-and-parity epic (child #9003). Design against the planned upstream contracts (#9001, #9002); cite them.

## 1. Canonical validator pattern (scripts/dev_tools/validate_orchestration_artifacts.py, 356 lines)

- Pure function: `validate_<artifact>_text(text: str, ...) -> list[str]`. Empty list = pass; each element is a human-readable error string (e.g. `f"Line {n}: <problem>."`). No printing, no mutation, no disk I/O inside the pure function. Gate variants use keyword-only booleans (`validate_orchestrator_state_text(text, require_complete=..., require_model_routing=...)`, lines 289-299). Extra inputs (schema, companion file) are passed as parameters; disk I/O belongs to the CLI layer (`_read_text`, lines 39-59).
- CLI: `build_parser() -> argparse.ArgumentParser` (line 144); `subparsers = parser.add_subparsers(dest="artifact_type", required=True)` (line 168); simple types take positional `path` (170-179); gate variants add `--require-*` `action="store_true"` flags (180-221). Dispatch: single `_validate_from_args(args) -> list[str]` (255-320) reads file once via `_read_text`, branches on `args.artifact_type`, returns `[f"Unsupported artifact type: {args.artifact_type}"]` for unknown (line 320).
- I/O + exit: `main(argv: list[str] | None = None) -> int` (323-356). On errors: print each to stderr, return 1. On success: one stdout line `f"{args.artifact_type} validation passed: {args.path}"`, return 0. Guard: `if __name__ == "__main__": raise SystemExit(main())`.
- Per-artifact `validate_<artifact>_text` functions live in helper modules imported by the umbrella (mirrors imports at lines 16-31).

## 2. Schema loading / jsonschema (scripts/dev_tools/validate_json.py 279 lines, json_config.py 52 lines)

- Governed-glob (`json_config.py`): `GOVERNED_GLOBS` (12-16), `EXCLUDE_GLOBS` (19-29), `iter_governed_files(root)` (32-52); used by `validate_json.py:244-254` only when no explicit paths. Relevant half for #9003 is schema-resolution, not directory scan (discovery validators validate one in-memory `text` at a time).
- `$schema` resolution: `_load_schema(uri, cache_dir, base_path=None)` (130-164) — no scheme → relative to `base_path.parent`; `file://` → absolute path; `http(s)://` → fetched, SHA-256-keyed cache; else `ValueError`. `validate_file(path, cache_dir)` (167-225) requires a string `$schema` on the root (197-200); with jsonschema present (`^4.25.1`, pyproject.toml:43) uses `Draft202012Validator(schema).iter_errors(data)`, sorts by `e.path`, formats each as `f"{list(err.path)}: {err.message}"` joined with `"; "` (213-221). Fallback `_collect_schema_errors` (82-127) when jsonschema unavailable.
- REUSE (epic Shared Design): extract `_load_schema` (+ optionally the error-formatting expression) into a public shared module (public function in `json_config.py` or new `scripts/dev_tools/schema_loading.py`) imported by both `validate_json.py` and the discovery per-schema module — satisfies "reuse machinery, do not reintroduce schema-loading code" literally. Importing the private `_load_schema` across modules violates the `_prefixed`-is-internal convention (`.claude/rules/python.md:39`). This modifies `validate_json.py` (outside the primary new-file set) — call it out in the plan file-change list. Consider `best_match` if #9002 schemas use top-level `oneOf`/`anyOf` (open).

## 3. Upstream planned contracts (unfinalized; design-against)

Neither `legacy-discovery-config-contract` nor `legacy-discovery-schemas` active folder exists yet. Provisional, from objective-source.md 3-4 and epic.md Shared Design.

- #9001 domain-profile config (objective-source.md:65-69, 140-141): declares legacy source, target, tech stack, artifact conventions. OPEN parser decision: PyYAML (`>=6.0`, pyproject.toml:19, only consumer today is `scripts/dev_tools/push_down_claude_filesystem.py`) vs hand-rolled frontmatter regex (as in `validate_orchestration_artifacts.py` PLAN_PHASE_RE/PLAN_TASK_RE, 33-36). Profile validator public contract `validate_profile_text(text: str) -> list[str]` must independently re-check structure; if it reuses #9001's typed loader, wrap the call in a narrow `try/except <declared loader exception>` converting to one error string (no bare `except`, no exception-only failure signal). Finalize field checks once #9001 ships.
- #9002 seven versioned JSON schemas + versioning convention (objective-source.md:70-79, 143; epic.md:107-110): no existing versioning layout; sketched `schemas/vN/`, version field, `$schema` self-reference reusing validate_json.py machinery. Validators must LOCATE schemas generically — no hardcoded layout. Isolate location behind one `_resolve_schema_path(artifact_type)` seam. Safe design assumption: resolve solely via each artifact instance's own `$schema` field through the shared loader (the mechanism validate_json.py already uses, 197-200); never encode "v1". #9002 produces conforming/non-conforming fixtures the tests consume; likely `tests/fixtures/<#9002-dir>/<artifact-type>/`, read via `Path.read_text()` (committed files, not temp files). Until #9002 lands, exercise pure functions with inline literals; add fixture-based tests once #9002 ships.

## 4. Poetry console-scripts (pyproject.toml:47-69)

- `[tool.poetry.scripts]` uses quoted dotted keys `"dev.<name>" = "scripts.dev_tools.<module>:<fn>"` (e.g. `"dev.validate-json" = "scripts.dev_tools.validate_json:main"`, line 69). No `dev.discovery.*` exists yet.
- Recommended entries (one verb per artifact type + `all`), targeting `scripts.dev_tools.validate_discovery_artifacts`:
  `dev.discovery.validate-profile:main_profile`, `...validate-feature-contract:main_feature_contract`, `...validate-coverage-ledger:main_coverage_ledger`, `...validate-runtime-scenario:main_runtime_scenario`, `...validate-parity-matrix:main_parity_matrix`, `...validate-unspecified-behavior:main_unspecified_behavior`, `...validate-product-decision:main_product_decision`, `...validate-evidence-reference:main_evidence_reference`, `dev.discovery.validate-all:main`.
- Each `main_<artifact>()` is a thin wrapper: `return main(["<artifact-type>", *sys.argv[1:]])`, preserving a single dispatcher/exit-code path. Single-generic-entry vs per-verb is a plan-level decision (per-verb matches the issue's plural "entry points" more directly).

## 5. Quality-tier + test conventions

- `quality-tiers.yml` does NOT exist at repo root (tracked gap, issue #336, promoted potential 2026-07-09). Coverage thresholds are uniform across T1-T4 (line >= 85%, branch >= 75%) per `.claude/rules/quality-tiers.md`, so the missing file does not change the coverage bar. Treat `scripts/dev_tools` as T2-equivalent by analogy; do not block on #336.
- Test location mirrors source, no colocation: `tests/scripts/dev_tools/test_validate_*.py`. Split large files by concern (precedent: `test_validate_orchestration_artifacts.py` + `..._dispatch.py`, `..._model_routing.py`, `..._pr_creation_readiness.py`, `..._codex_topology_cli.py`, each citing the 500-line cap).
- No-temp-file: use `build_read_text_stub(text)` (tests/scripts/dev_tools/test_validate_orchestration_artifacts.py:140-146) to monkeypatch `_read_text` for CLI-dispatch tests; `mem_fs_path` fixture (tests/conftest.py:145+) for path/glob tests. Pure `validate_<artifact>_text` functions test directly with inline literals.
- 500-line hard cap constrains decomposition (see Section 8).

## 6. Domain-neutrality invariant

No TaskMaster/TMW/Outlook/VSTO/email/task-management identifiers in source, docstrings, error messages, or comments. No special-casing of consumer repo name/path/tech token. Domain specificity enters only via the domain profile (#9001) at runtime. Feature-authored fixtures use generic synthetic values (e.g. `"feature_id": "F-001"`). Self-verify with case-insensitive grep gate (`TaskMaster|TMW|Outlook|VSTO|task-management`) over new files.

## 7. Naming-collision check

No collision with `code-modernization` plugin agent/command names (its `legacy-analyst`, `business-rules-extractor`, `architecture-critic`, `scaffolder`, `security-auditor`, `test-engineer`, `version-delta-analyst`, `/modernize-*`). Only repo hits are the epic's own exclusion note and an unrelated `.codex/agents/powershell-di-unit-test-engineer.toml` (substring only). No `*discovery*` / `validate_discovery*` / `dev.discovery.*` exists in scripts/dev_tools.

## 8. Recommended module/file decomposition

- `scripts/dev_tools/validate_discovery_artifacts.py` — thin umbrella: `build_parser`, `_read_text`, `_validate_from_args`, `main`, per-verb `main_<artifact>()` wrappers. No validation logic here.
- `scripts/dev_tools/validate_discovery_profile.py` — `validate_profile_text(text) -> list[str]` + profile helpers. Placeholder field checks flagged `# TODO(#9001)` until #9001 finalizes.
- `scripts/dev_tools/validate_discovery_schema_artifacts.py` — seven `validate_<schema>_text` thin wrappers over one `_validate_against_schema(text, artifact_type) -> list[str]` helper (parse JSON, resolve schema via artifact `$schema` through shared loader, `Draft202012Validator.iter_errors`, format like validate_json.py:213-221).
- Shared schema-loading extraction: promote `_load_schema` into public shared module imported by both `validate_json.py` and the discovery module (cross-cutting; name explicitly in plan).
- `pyproject.toml` — add `dev.discovery.validate-*` entries.
- Tests: `test_validate_discovery_profile.py`, `test_validate_discovery_schema_artifacts.py` (split per schema if >500 lines), `test_validate_discovery_artifacts_dispatch.py` (CLI dispatch + exit codes via `build_read_text_stub`).

## 9. Open questions / dependencies

1. #9001 profile field contract + loader exception surface undefined (blocks final profile required-field checks).
2. #9001 parser decision (PyYAML vs regex) open (affects profile syntax-validity step; public `text: str` contract stable regardless).
3. #9002 versioning convention open; design resolves via artifact `$schema` through shared loader to stay valid regardless; `_resolve_schema_path` seam isolates change.
4. #9002 fixture location undetermined; fixture-integration is a follow-up once #9002 ships, not an initial blocker.
5. `best_match` need depends on whether #9002 schemas use top-level `oneOf`/`anyOf`.
6. `quality-tiers.yml` missing (#336); not blocking (uniform thresholds); tier-dependent gates default to T2-equivalent.
7. Poetry-verb design (single vs per-verb) is a plan-level decision.
8. `all` subparser semantics undefined by any precedent — the plan MUST specify what `all` means (validate one path against each type until match, directory scan with type inference, or other). Genuine design gap.
