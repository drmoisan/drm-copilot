# Remediation Inputs — legacy-discovery-init-templates (#362)

- Timestamp: 2026-07-18T13-00
- Branch: `feature/legacy-discovery-init-templates-362` (HEAD `48d16f6f953c82383d993b0b69b61a2c90800e3a`)
- Base: `epic/legacy-discovery-and-parity-integration`
- Source artifacts:
  - `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/policy-audit.2026-07-18T13-00.md`
  - `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/code-review.2026-07-18T13-00.md`
  - `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/feature-audit.2026-07-18T13-00.md`

Remediation is required: 4 Blocking findings and 4 FAIL acceptance-criteria verdicts (1 additional PARTIAL) were confirmed by independent verification, not merely reported by the executor. This document is the handoff input for remediation plan creation (`remediation-handoff-atomic-planner`); it does not itself create the remediation plan file.

## Blocking Findings (must all be resolved before PR creation)

### R1 — Seven of eight discovery templates are not committed to git

- **Root cause:** `.gitignore:6` is the bare, unanchored token `artifacts`, which git matches against any path component named `artifacts` anywhere in the repository tree, not only a top-level `artifacts/` directory. This silently ignores `docs/discovery/templates/artifacts/**`.
- **Evidence:** `git ls-tree -r HEAD --name-only | grep docs/discovery` returns only `docs/discovery/templates/domain-profile/domain-profile.yaml`. A detached `git worktree add --detach <tmp> 48d16f6f953c82383d993b0b69b61a2c90800e3a` followed by `find <tmp>/docs/discovery -type f` confirms the same: only 1 of the 8 required template files exists in the actual commit.
- **Required fix (either, coordinate with repo owner if the second option touches shared config):**
  1. Move the seven artifact templates to a directory whose path does not contain a component literally named `artifacts` (e.g. `docs/discovery/templates/artifact-instances/`), updating `ARTIFACT_RELATIVE_PATHS`/`EXPECTED_TEMPLATE_RELATIVE_PATHS` in `init_models.py` and the corresponding `$schema` relative-path depth in each template; or
  2. Anchor `.gitignore`'s entry to the repository root (`/artifacts`) so it no longer matches nested path segments, then commit the seven template files as originally located.
- **Verification after fix:** commit the fix, then re-run the clean-checkout check (`git worktree add --detach <tmp> <new-HEAD>`; `find <tmp>/docs/discovery -type f` must list all 8 files) and re-run the full pytest suite from that clean checkout (`test_domain_neutrality_templates_contain_no_disallowed_tokens` must not raise `FileNotFoundError`).

### R2 — Domain-profile template does not parse under the real, already-merged feature-#360 loader

- **Root cause:** the template (`docs/discovery/templates/domain-profile/domain-profile.yaml`) was authored as a flat `key: value` document based on the plan's premise that feature 9001's parser decision was "unresolved." Feature 9001 (#360) had already been merged into this feature's own merge-base with a concrete, nested, nested-dataclass loader (`scripts/dev_tools/discovery/domain_profile.py`) before this feature's plan was authored.
- **Evidence:** `parse_domain_profile_text` against the template's text raises `DomainProfileError: 8 profile error(s)` — unknown top-level keys `legacy_source_path`/`target_path`/`artifact_output_dir`; missing required `profile_version`/`legacy_source`/`target`/`artifacts`; `technology_stack` present as a string where the loader requires a mapping with a `legacy` list.
- **Required fix:** rewrite the template to the real nested shape:
  ```yaml
  profile_version: 1
  legacy_source:
    root: "<legacy-source-path>"
  target:
    root: "<target-path>"
  technology_stack:
    legacy:
      - "<technology-stack>"
  artifacts:
    root: "<artifact-output-dir>"
  ```
  (illustrative; confirm exact optional fields against `domain_profile_models.py` before finalizing). Add a unit test that calls the real `parse_domain_profile_text` against the rendered template output and asserts it succeeds — this closes the gap that let the divergence go undetected (no existing test exercises the real loader against this feature's template).
- **Verification after fix:** `poetry run python -c "from scripts.dev_tools.discovery.domain_profile import parse_domain_profile_text; from pathlib import Path; parse_domain_profile_text(Path('docs/discovery/templates/domain-profile/domain-profile.yaml').read_text())"` must not raise.

### R3 — Artifact templates do not resolve or validate against the real, already-merged feature-#359 schemas

- **Root cause:** the templates' `"$schema"` values (e.g. `"../../schemas/v1/feature-contract.schema.json"`) resolve, per `validate_json.py`'s `_load_schema` no-scheme rule (`base_path.parent / uri`), to `docs/discovery/schemas/v1/<name>.schema.json`, which does not exist. The real schemas (merged before this feature's plan was authored) live at repo-root `schemas/discovery/v1/<name>.schema.json`. Independent of the path, the instance field set (`$schema`, `version`, `id`) fails `jsonschema.validate` against the real schema: `additionalProperties: false` rejects `version`; the schema requires `schema_version` (not `version`), `title`, `description`, `status`, and a non-empty `acceptance_criteria` array, none of which the template provides.
- **Evidence:** reviewer ran `jsonschema.validate` for `feature-contract.template.json` against `schemas/discovery/v1/feature-contract.schema.json`: `Additional properties are not allowed ('version' was unexpected)`.
- **Required fix:** for all seven templates:
  1. Correct the `$schema` relative path so it resolves to the real `schemas/discovery/v1/<name>.schema.json` location (recompute the `../` depth from the templates' final committed location, especially if R1's fix relocates them).
  2. Replace `"version"` with `"schema_version"` using a value matching `^1\.\d+\.\d+$` (e.g. `"1.0.0"`).
  3. Add every field each schema's `required` array lists (per-schema: consult `schemas/discovery/v1/*.schema.json` directly; at minimum `title`, `description`, `status` (one of the schema's enum values, e.g. `draft`), and a non-empty `acceptance_criteria`/equivalent array for schemas that require one).
  4. Un-skip `test_schema_conformance_pending_issue_9002` (`tests/scripts/dev_tools/discovery/test_init_flow.py`) and implement its assertion body against the real schema files, since the "pending 9002" premise no longer holds.
- **Verification after fix:** the un-skipped schema-conformance test must pass for all seven generated artifact instances against their real schema files.

### R4 — Breaking removal of the `scripts/dev_tools/discovery/__init__.py` public re-export surface

- **Root cause:** this feature's Phase 1 task (`P1-T1`) replaced the pre-existing `__init__.py` (added by feature #360, re-exporting `DomainProfile`, `DomainProfileError`, `load_domain_profile`, `parse_domain_profile_text`, `DEFAULT_PROFILE_FILENAME`, etc.) with a bare one-line docstring, apparently on the mistaken assumption that the package did not yet have production content.
- **Evidence:** `poetry run python -c "from scripts.dev_tools.discovery import DomainProfile"` raises `ImportError`. Feature #360's own plan declares this import as an explicit acceptance criterion (`docs/features/active/2026-07-17-legacy-discovery-config-contract-360/plan.2026-07-17T14-03.md:81`).
- **Required fix:** restore the prior re-export block in `__init__.py` (append the new `dev.discovery.*` namespace docstring to it, or merge both into one docstring), so `from scripts.dev_tools.discovery import DomainProfile, DomainProfileError, load_domain_profile, parse_domain_profile_text, DEFAULT_PROFILE_FILENAME` succeeds again. Add a regression test for the package-level import surface so this cannot silently regress again.
- **Verification after fix:** the import statement above must succeed with exit 0.

## Non-Blocking Follow-ups (do not block PR creation, but should be tracked)

- `test_schema_conformance_pending_issue_9002`'s skip reason should be corrected regardless of R3's disposition, since its current wording is factually inaccurate about schema existence.

## Re-Verification Checklist for the Remediation Plan

1. Fix R1–R4 above.
2. From a clean `git worktree add --detach` checkout of the remediated branch head, confirm all 8 template files are present under `docs/discovery/templates/`.
3. Re-run the full toolchain loop (`poetry run black --check .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`) and capture fresh evidence under `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/qa-gates/`.
4. Re-run `parse_domain_profile_text` against the rendered domain-profile output and `jsonschema.validate` against each rendered artifact instance and its real schema; both must succeed.
5. Re-run `poetry run python -c "from scripts.dev_tools.discovery import DomainProfile"`; must succeed.
6. Re-request feature-review of the remediated branch; do not proceed to PR creation until a subsequent policy-audit/code-review/feature-audit cycle reports zero Blocking findings.
