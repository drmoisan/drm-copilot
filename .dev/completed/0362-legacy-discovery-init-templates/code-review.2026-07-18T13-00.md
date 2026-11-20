# Code Review — legacy-discovery-init-templates (#362)

- Timestamp: 2026-07-18T13-00
- Branch: `feature/legacy-discovery-init-templates-362` (HEAD `48d16f6f953c82383d993b0b69b61a2c90800e3a`)
- Base: `epic/legacy-discovery-and-parity-integration`
- Reviewer: feature-review agent
- Scope reviewed: full branch diff (`git diff f18c1c16f3eb111f0acef5eb3c46be1fb563aac0..HEAD`)

## Executive Summary

The `dev.discovery.init` CLI, its pure orchestration layer, and its `FileSystem` abstraction are well-structured, fully typed, thoroughly unit-tested against fakes, and pass the full toolchain loop (format, lint, type-check, tests, coverage). However, the feature's actual deliverable is materially broken in three independently verified ways that make it unsuitable to merge as-is: (1) seven of the eight required template files are not committed to git because of a `.gitignore` path-segment collision, so a clean checkout cannot run the command end-to-end; (2) the committed/working-tree template content does not conform to the already-merged upstream contracts (#360 domain-profile loader, #359 JSON schemas) it is supposed to target; (3) the package's pre-existing public re-export surface was silently removed, reversing an acceptance criterion of sibling feature #360. All three are Blocking. See `policy-audit.2026-07-18T13-00.md` for full evidence and `remediation-inputs.2026-07-18T13-00.md` for the required fixes.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking | `.gitignore` / `docs/discovery/templates/artifacts/*.template.json` | `.gitignore:6` (`artifacts`, unanchored) | The seven artifact templates are gitignored and were never committed; only `domain-profile.yaml` is in the tree at HEAD. | Anchor `.gitignore`'s `artifacts` entry to the repo root (e.g. `/artifacts`), or move the templates out of a path segment literally named `artifacts` (e.g. `docs/discovery/templates/instances/`), then commit the seven files and re-run the full test suite from a clean checkout. | A repo-relative bare token in `.gitignore` matches any path component with that name anywhere in the tree, not just the top-level directory. | `git ls-tree -r HEAD --name-only \| grep docs/discovery` returns only `domain-profile.yaml`; confirmed via a detached `git worktree add` at the branch head showing the same. |
| Blocking | `docs/discovery/templates/domain-profile/domain-profile.yaml` | whole file | The flat `key: value` template (`legacy_source_path`, `target_path`, `technology_stack`, `artifact_output_dir`) does not parse under the real, already-merged feature-#360 loader (`scripts/dev_tools/discovery/domain_profile.py`), which requires a nested `profile_version`/`legacy_source`/`target`/`technology_stack`/`artifacts` structure and rejects unknown top-level keys. | Rewrite the template to the real nested shape accepted by `parse_domain_profile_text`, or coordinate a contract change with #360 if the flat shape is intentionally preferred; verify with `parse_domain_profile_text` directly, not only with the feature's own fake-`FileSystem` tests. | The upstream contract this template claims to anticipate already exists in the repository (merged at this feature's own merge-base) and has a concrete, inspectable shape; the template does not match it. | Reviewer ran `parse_domain_profile_text` against the template text: `DomainProfileError: 8 profile error(s)` (unknown keys, missing required sections, wrong type for `technology_stack`). |
| Blocking | `docs/discovery/templates/artifacts/*.template.json` | all seven files | Each template's `"$schema"` value resolves (per `validate_json.py`'s no-scheme `_load_schema` rule) to `docs/discovery/schemas/v1/<name>.schema.json`, which does not exist anywhere in the repository; the real schemas (already merged, feature #359) live at `schemas/discovery/v1/<name>.schema.json`. Even disregarding the path, the instance content (`$schema`, `version`, `id`) fails `jsonschema.validate` against the real schema (`additionalProperties: false` rejects `version`; `schema_version`, `title`, `description`, `status`, `acceptance_criteria` are required and absent). | Point `$schema` at the real schema location (or the convention #359 actually established) and populate every field the real schema requires. Un-skip `test_schema_conformance_pending_issue_9002` and run it against the real schema files instead of treating them as not-yet-existing. | The dependency this feature defers as "pending 9002" already landed before this feature's own plan was written. | Reviewer ran `jsonschema.validate(instance, schema)` for `feature-contract.template.json` against `schemas/discovery/v1/feature-contract.schema.json`: `Additional properties are not allowed ('version' was unexpected)`. |
| Blocking | `scripts/dev_tools/discovery/__init__.py` | whole file | This diff replaces the pre-existing package `__init__.py` (added by #360, re-exporting `DomainProfile`, `DomainProfileError`, `load_domain_profile`, `parse_domain_profile_text`, `DEFAULT_PROFILE_FILENAME`, etc.) with a bare one-line docstring, removing the entire re-export surface with no caller update and no note in this feature's spec/plan/commit message. | Restore the prior re-exports (append the namespace docstring rather than replacing the module), or explicitly document the breaking change, update `docs/features/active/2026-07-17-legacy-discovery-config-contract-360`'s own acceptance criterion, and add a regression test for the package-level import surface. | Violates `.claude/rules/general-code-change.md` "Public APIs and Compatibility" (breaking changes must be called out and callers updated); reverses an acceptance criterion feature #360 declared for itself, with zero test coverage of the regression. | `poetry run python -c "from scripts.dev_tools.discovery import DomainProfile"` raises `ImportError: cannot import name 'DomainProfile' from 'scripts.dev_tools.discovery'`. |
| Non-blocking | `tests/scripts/dev_tools/discovery/test_init_flow.py:216-242` | `test_schema_conformance_pending_issue_9002` | The skip reason ("no schema files exist in the repository yet") is factually incorrect; the schemas already exist. | Re-word the skip reason if it must remain skipped for other reasons (e.g. template rework pending), or un-skip and fix per the Blocking finding above. | A stale/incorrect skip reason can mask a real, currently-reproducible failure from future readers of the test output. | Confirmed schemas exist at `schemas/discovery/v1/*.schema.json` (added by #359, merged before this feature's merge-base). |
| Non-blocking | `docs/discovery/templates/artifacts/*.template.json` | all seven files | Field name `"version"` does not match the real schema's `"schema_version"` field, independent of the missing-required-fields issue above. | Rename to `schema_version` and set a value matching the schema's `^1\.\d+\.\d+$` pattern. | Naming drift compounds the schema-conformance defect. | `schemas/discovery/v1/feature-contract.schema.json` `required` array and `properties.schema_version.pattern`. |

## Toolchain Verification (independently re-run, check-only)

| Stage | Command | Result |
|---|---|---|
| Format | `poetry run black --check scripts/dev_tools/discovery tests/scripts/dev_tools/discovery` | PASS — 14 files unchanged |
| Lint | `poetry run ruff check scripts/dev_tools/discovery tests/scripts/dev_tools/discovery` | PASS — "All checks passed!" |
| Type check | `poetry run pyright scripts/dev_tools/discovery tests/scripts/dev_tools/discovery` | PASS — 0 errors, 0 warnings, 0 informations |
| Tests (package) | `poetry run pytest tests/scripts/dev_tools/discovery --cov=scripts/dev_tools/discovery --cov-branch` | PASS — 80 passed, 1 skipped |
| Tests (repo-wide) | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | PASS — 1704 passed, 1 skipped; line 88.16%, branch 78.90% |

## General Code Change Policy (`.claude/rules/general-code-change.md`)

| Check | Verdict | Evidence |
|---|---|---|
| Simplicity first | PASS | `init_flow.py`'s two validation functions plus one orchestration function are flat and easy to follow; no unnecessary indirection. |
| Reusability | PASS | `substitute_placeholders` is a small, reusable, pure helper; `EXPECTED_TEMPLATE_RELATIVE_PATHS`/`OUTPUT_RELATIVE_PATHS` are the single source of truth for the file set, used by both production code and tests. |
| Extensibility | PASS | `--template-root` override and keyword-only `force` on `create_discovery_workspace` follow the existing scaffolding-tool precedent; `tokens: Mapping[str, str] | None = None` is a clean extension point for future placeholder substitution. |
| Separation of concerns | PASS | `init_flow.py` performs no `argparse`/`print`/I/O side effects beyond the injected `FileSystem`; `init_cli.py` is thin wiring only. |
| Classes vs functions | PASS | `RealFileSystem` as a dataclass implementing a `Protocol`; pure standalone functions for validation/substitution/orchestration. |
| File size <= 500 lines | PASS | Largest new file is `test_init_flow.py` at 243 lines. |
| Error handling — fail fast, specific | PASS | `validate_template_set`/`validate_target_path` raise specific exception types (`FileNotFoundError`, `NotADirectoryError`, `FileExistsError`) before any write; `init_cli.main` catches exactly the four expected types, no bare `except Exception`. |
| Naming | PASS | `snake_case` functions/locals, `PascalCase` classes/Protocol, `CONSTANT_CASE` module constants. |
| Public APIs and Compatibility | **FAIL — Blocking** | See Findings Table: `discovery/__init__.py` re-export removal is an undocumented breaking change. |
| Dependencies | PASS | No new dependency. |
| I/O boundaries | PASS | All disk access confined to `RealFileSystem`; `create_discovery_workspace` is testable purely against the `FileSystem` protocol. |

## Python Rules (`.claude/rules/python.md`)

| Check | Verdict | Evidence |
|---|---|---|
| Full type hints on public surface | PASS | All new functions annotated; Pyright clean. |
| Absolute imports | PASS | `from scripts.dev_tools.discovery import init_flow, init_models`. |
| Assertions only for internal checks | PASS | No `assert` in production code. |
| Console-script convention | PASS | `main(argv=None) -> None` with `SystemExit(1)` on the four fail-fast exception types, consistent with repository precedent. |

## Suppressions

PASS. Zero `# noqa`, `# type: ignore`, `# pragma: no cover`, or `# pyright: ignore` directives in any file added by this branch.

## Self-Explanatory Code and Commenting

PASS. Module and function docstrings are concise and accurate for what the code as-written does (the docstrings do not themselves claim upstream-contract conformance beyond what the "Design Notes" section of the plan already qualifies).

## Findings Summary

- FAIL findings: 4 (all Blocking — see table above)
- Blocking PARTIAL findings: 0
- Non-blocking observations: 2
