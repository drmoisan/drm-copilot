# Code Review — legacy-discovery-config-contract (#360)

- Timestamp: 2026-07-18T10-49
- Branch: `feature/legacy-discovery-config-contract-360` (HEAD `a5209a71`)
- Base: `epic/legacy-discovery-and-parity-integration`
- Reviewer: feature-review agent
- Scope reviewed: full branch diff (`git diff epic/legacy-discovery-and-parity-integration...HEAD`)

## Files Reviewed

Production:
- `scripts/dev_tools/discovery/__init__.py` (37 lines)
- `scripts/dev_tools/discovery/domain_profile.py` (408 lines)
- `scripts/dev_tools/discovery/domain_profile_models.py` (152 lines)
- `scripts/dev_tools/discovery/profile_cli.py` (154 lines)
- `pyproject.toml` (one added `[tool.poetry.scripts]` line)

Tests:
- `tests/scripts/dev_tools/discovery/__init__.py` (0 lines)
- `tests/scripts/dev_tools/discovery/test_domain_profile.py` (452 lines)
- `tests/scripts/dev_tools/discovery/test_profile_cli.py` (180 lines)

Docs/evidence: feature-folder plan, spec, user-story, and evidence files (not production code).

## Toolchain Verification (independently re-run, check-only)

| Stage | Command | Result |
|---|---|---|
| Format | `poetry run black --check scripts/dev_tools/discovery tests/scripts/dev_tools/discovery` | PASS — 7 files unchanged |
| Lint | `poetry run ruff check scripts/dev_tools/discovery tests/scripts/dev_tools/discovery` | PASS — "All checks passed!" |
| Type check | `poetry run pyright scripts/dev_tools/discovery tests/scripts/dev_tools/discovery` | PASS — 0 errors, 0 warnings, 0 informations (exit 0) |
| Tests | `poetry run pytest tests/scripts/dev_tools/discovery/ --cov=scripts/dev_tools/discovery --cov-branch` | PASS — 55 passed; package coverage 99% combined |

## General Code Change Policy (`.claude/rules/general-code-change.md`)

| Check | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | Flat helper functions (`_require_str`, `_str_list`, etc.); no deep indirection; single-purpose modules. |
| Reusability | PASS | Extraction helpers are shared across all four section parsers; no copy-paste duplication. |
| Extensibility | PASS | `profile_version` gates evolution; keyword-style dataclass fields with defaults; `parse_domain_profile_text(text, source=...)` provides the text-in seam for sibling feature #9003. |
| Separation of concerns | PASS | Pure parse layer (`parse_domain_profile_text` and helpers) performs no I/O; filesystem access confined to `load_domain_profile`; rendering and process-boundary concerns confined to `profile_cli.py`. |
| Classes vs functions | PASS | Frozen dataclasses for value objects with invariants (`__post_init__`); pure standalone functions for stateless transforms. |
| File size <= 500 lines | PASS | Largest production file `domain_profile.py` = 408; largest test file = 452. All files under 500. |
| Error handling — fail fast, specific | PASS | Single specific `DomainProfileError(ValueError)`; collect-then-raise enumerates all defects with dotted paths; no broad `except Exception`; CLI catches only `DomainProfileError` (`profile_cli.py:145`). `FileNotFoundError`/`OSError` are wrapped with context and `from exc` chaining (`domain_profile.py:400-407`). |
| Logging | PASS | No logging by design (CLI communicates via stdout/stderr/exit codes, per spec `## Implementation Strategy`); `print` in `main` is the CLI output boundary, not ad-hoc debug output. |
| Naming | PASS | `snake_case` functions, `PascalCase` classes, `CONSTANT_CASE` module constants (`DEFAULT_PROFILE_FILENAME`, `_TOP_LEVEL_KEYS`); internal helpers `_`-prefixed. |
| Dependencies | PASS | No new dependency. PyYAML>=6.0 was already declared in Poetry; this feature adds the repository's first `import yaml`, matching the spec's recorded decision. `types-PyYAML` was correctly NOT added (bundled typeshed stubs sufficed; `evidence/other/pyyaml-stub-decision.md`). |
| I/O boundaries | PASS | All filesystem access in `load_domain_profile` and the CLI; parse layer testable with inline strings. |

## Python Rules (`.claude/rules/python.md`)

| Check | Verdict | Evidence |
|---|---|---|
| Full type hints on public surface | PASS | Every public and private function annotated; Pyright strict clean. |
| `Any` isolation | PASS | The `yaml.safe_load` `Any` boundary is isolated in `_load_yaml_mapping`; downstream helpers take `object` and narrow with `isinstance`. |
| Frozen dataclasses with `__post_init__` invariants | PASS | All five dataclasses `frozen=True`; each re-asserts local invariants (defense-in-depth layer). |
| Absolute imports | PASS | All imports absolute (`scripts.dev_tools.discovery.*`). |
| Assertions only for internal checks | PASS | No `assert` in production code. |
| Console-script convention | PASS | `main(argv=None) -> int`, argparse, `if __name__ == "__main__": raise SystemExit(main())` (`profile_cli.py:153-154`), matching the existing `dev.*` precedent. |

## Suppressions (`.claude/rules/python-suppressions.md`)

PASS. Zero `# noqa`, `# type: ignore`, `# pragma: no cover`, or `# pyright: ignore` directives in any new production or test file (verified by grep over `scripts/dev_tools/discovery/` and `tests/scripts/dev_tools/discovery/`).

## Self-Explanatory Code and Commenting

PASS. Module docstrings follow the repository's Purpose/Responsibilities/Invariants/Side-Effects structure. Function docstrings document args, returns, and raises. Inline comments are sparse and explain non-obvious rationale only (e.g., the `_MISSING` sentinel, the bool-before-int check in `_require_profile_version` at `domain_profile.py:229`, the ordered-pairs immutability rationale in `ArtifactsConfig`). No redundant narration comments.

## Observations (non-blocking)

1. **`typing.cast` at narrowing sites vs spec wording.** The spec's Pyright-strict tactic states "no `cast` chains, no `# type: ignore`". The implementation uses single localized `typing.cast("dict[object, object]", ...)` / `cast("list[object]", ...)` calls immediately after `isinstance` narrowing (`domain_profile.py:112,133,185,206`). These are not cast chains; they follow the repository's established strict-mode pattern for dynamic-load results and are documented in `evidence/qa-gates/final-pyright.md`. No `# type: ignore` is used. Not a violation.
2. **One uncovered defensive line.** `domain_profile.py:75` (`_type_name(_MISSING)` returning `"missing value"`) is unreachable in the parse flow because missing keys short-circuit to "required field is missing" before `_type_name` is called. Retained as a safety default; documented in `evidence/qa-gates/final-pytest-coverage.md`. Package coverage remains 99.5% line / 98.7% branch on that module. Not blocking. An alternative would be to delete the branch, but keeping a total function for a sentinel-aware formatter is a defensible defensive choice.
3. **`_optional_str` accepts empty strings for optional fields** (e.g., `profile_name: ""` parses to `""`, and `description: ""` likewise). The contract specifies non-empty only for required strings and convention keys/values, so this matches the documented contract. Noted for awareness only.

## Findings Summary

- FAIL findings: 0
- Blocking PARTIAL findings: 0
- Non-blocking observations: 3 (above)
