# Feature Audit — legacy-discovery-init-templates (#362)

- Timestamp: 2026-07-18T13-00
- Branch: `feature/legacy-discovery-init-templates-362` (HEAD `48d16f6f953c82383d993b0b69b61a2c90800e3a`)
- Base: `epic/legacy-discovery-and-parity-integration`
- Merge-base: `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`

## Scope and Baseline

- Work mode: `full-feature` (marker confirmed in `issue.md`: `- Work Mode: full-feature`).
- AC sources: `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria` (both files carry an identical 9-item list).
- Baseline for the audit is the resolved base branch `epic/legacy-discovery-and-parity-integration` at merge-base `f18c1c16f3eb111f0acef5eb3c46be1fb563aac0`. That merge-base already includes feature #360 (`legacy-discovery-config-contract`, commit `a5209a71`) and feature #359 (`legacy-discovery-schemas`, commit `b69a84e1`) — i.e., the two "upstream, planned-in-parallel" dependencies this feature's spec and plan describe as not-yet-implemented were in fact already merged before this feature's own plan was authored. This materially affects several AC verdicts below.
- The 9 spec.md AC items were all pre-checked `[x]` by the executor. Per this review's independent-verification requirement, each was re-derived from first-party evidence (direct test execution, direct invocation of the already-merged upstream loader/schemas, and a clean detached-worktree checkout of the branch head) rather than accepted on the executor's word. Five items did not survive independent verification and have been reverted to `[ ]` in both `spec.md` and `user-story.md` (see "Acceptance Criteria Check-off" below).

## Acceptance Criteria Inventory

| # | Criterion (spec.md / user-story.md, identical text) |
|---|---|
| 1 | `dev.discovery.init <target-dir>` scaffolds the discovery workspace directory layout at the given target consumer path in a single invocation. |
| 2 | `dev.discovery.init` accepts an explicit target-directory CLI argument and an optional `--template-root` override, consistent with the `new_active_feature_folder`/`new_potential_bug_entry` precedent. |
| 3 | Initialization writes a starter domain-profile config, flat single-level `key: value` YAML with placeholder tokens, of the shape anticipated for feature 9001. |
| 4 | Initialization writes starter instances of each of the seven discovery artifacts from the templates under `docs/discovery/templates/artifacts/`, in the same invocation as the domain profile. |
| 5 | Each artifact template's `$schema` field is a relative, scheme-less path resolvable by `validate_json.py`'s no-scheme `_load_schema` branch, per feature 9002's schema-versioning convention. |
| 6 | Templates and generated artifacts contain no domain-specific identifiers. |
| 7 | `dev.discovery.init` fails fast, before writing any file, for the three named invalid-input conditions. |
| 8 | `dev.discovery.init` is registered and invocable as a Poetry console-script. |
| 9 | Tests satisfy quality-tier policy (line >= 85%, branch >= 75%), use an injected fake `FileSystem` with no real filesystem/temp-file I/O, and include the schema-conformance test tracked as dependent on feature 9002. |

## Acceptance Criteria Evaluation

| # | Verdict | Evidence |
|---|---|---|
| 1 | **FAIL** | The scaffolding logic itself is correct against a `FakeFileSystem` (unit-tested), but the concrete deliverable cannot perform a single invocation from a clean checkout: seven of the eight required template files are gitignored and never committed (`.gitignore:6`, bare `artifacts` token). Verified via a detached `git worktree add` at the branch head — `find <worktree>/docs/discovery -type f` returns only `domain-profile.yaml`. A real invocation would raise `FileNotFoundError` from `validate_template_set` before writing anything. |
| 2 | **PASS** | `init_cli.parse_args` requires `target_dir`, defaults `--template-root` to `None`; `test_parse_args_requires_target_dir`, `test_parse_args_parses_template_root_and_force` pass; reviewer confirmed by reading `init_cli.py:20-46`. |
| 3 | **FAIL** | Reviewer ran the real, already-merged feature-#360 loader (`parse_domain_profile_text`) against the template's committed text and obtained `DomainProfileError: 8 profile error(s)` (unknown top-level keys, missing required `profile_version`/`legacy_source`/`target`/`artifacts`, `technology_stack` present as a string rather than the required mapping). The "shape anticipated for feature 9001" does not match the shape feature 9001 actually landed with, and 9001 had already landed at this feature's own merge-base before its plan was written, so this was not an irreducible forward-dependency risk. |
| 4 | **FAIL** | Same untracked-files finding as #1: the seven artifact templates under `docs/discovery/templates/artifacts/` are not part of the committed branch diff (`git ls-tree -r HEAD --name-only` confirms only `domain-profile.yaml` is tracked under `docs/discovery/`). |
| 5 | **FAIL** | The templates' `"$schema"` value resolves, per `validate_json.py`'s documented no-scheme rule, to `docs/discovery/schemas/v1/<name>.schema.json`, which does not exist; the real, already-merged feature-#359 schemas live at repo-root `schemas/discovery/v1/<name>.schema.json`. Independently, `jsonschema.validate` of the template instance against the real schema fails (`additionalProperties` violation on `version`; required fields `schema_version`/`title`/`description`/`status`/`acceptance_criteria` absent). |
| 6 | **PASS** | `test_domain_neutrality_templates_contain_no_disallowed_tokens` and `test_domain_neutrality_rendered_output_contains_no_disallowed_tokens` pass; reviewer grep over the template content (present in the working tree) confirms zero matches for `TaskMaster`/`TMW`/`Outlook`/`VSTO` (case-insensitive). This verdict is scoped to token content only and does not offset the FAIL verdicts above regarding the templates' committed presence and structural correctness. |
| 7 | **PASS** | `validate_template_set`/`validate_target_path` are both called, and complete, before any `fs.write_text` call in `create_discovery_workspace`; unit tests `test_target_path_not_a_directory_raises`, `test_target_parent_missing_raises`, `test_target_non_empty_without_force_raises`, `test_missing_template_root_raises`, `test_partial_template_set_raises` each assert zero writes on the failure path. Reviewer re-ran the full test file: all pass. |
| 8 | **PASS** | `pyproject.toml` contains the exact line `"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"`, inserted alphabetically; `test_console_script_registered_in_pyproject` passes. |
| 9 | **PARTIAL** | Coverage thresholds are met (independently re-verified: package scope 80 passed/1 skipped with 100%/100% line/branch on `init_cli.py`/`init_flow.py`; repo-wide 1704 passed/1 skipped, line 88.16%, branch 78.90%, both above threshold) and the fake-`FileSystem` requirement is met (no real filesystem/temp-file I/O in any new test, grep-verified). However, the compound criterion's final clause — "include the schema-conformance test tracked as dependent on feature 9002" — is not accurately satisfied: `test_schema_conformance_pending_issue_9002`'s skip reason ("no schema files exist in the repository yet") is factually false, since feature 9002's schemas already exist in the repository and did so before this feature's own plan was authored. The test should have been un-skipped and run against the real schemas; doing so manually reproduces the schema-validation failure documented under criterion 5. |

## Summary

- Total AC items evaluated: 9 (identical set in `spec.md` and `user-story.md`)
- PASS: 4 (criteria 2, 6, 7, 8)
- PARTIAL: 1 (criterion 9)
- FAIL: 4 (criteria 1, 3, 4, 5)
- UNVERIFIED: 0

The feature's CLI wiring, pure orchestration logic, fail-fast validation, and console-script registration are correctly implemented and independently verified. The feature's core promise — producing a starter domain-profile config and seven starter artifact instances that are usable against the discovery capability's real upstream contracts — is not currently met: the artifact templates are not committed to git, the domain-profile template does not parse under the real (already-merged) feature-#360 loader, and the artifact templates do not validate against the real (already-merged) feature-#359 schemas. These are independently reproduced, not speculative. Recommendation: **remediation required before PR creation.**

## Acceptance Criteria Check-off

Per the acceptance-criteria-tracking protocol, PASS criteria remain checked and FAIL/PARTIAL criteria have been reverted to unchecked in both AC source files (they had been pre-checked `[x]` by the executor; this review's independent verification disagrees with five of the nine):

- `spec.md`: criteria 1, 3, 4, 5, 9 reverted `[x]` -> `[ ]`; criteria 2, 6, 7, 8 remain `[x]`.
- `user-story.md`: criteria 1, 3, 4, 5, 9 reverted `[x]` -> `[ ]`; criteria 2, 6, 7, 8 remain `[x]`.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/spec.md`, `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/user-story.md`
- Total AC items: 18 (9 spec + 9 user-story, identical content pairs)
- Checked off (delivered): 8 (4 spec + 4 user-story)
- Remaining (unchecked): 10 (5 spec + 5 user-story)
- Items remaining:
  1. `dev.discovery.init <target-dir>` scaffolds the discovery workspace directory layout at the given target consumer path in a single invocation. (both files)
  2. Initialization writes a starter domain-profile config... of the shape anticipated for feature 9001. (both files)
  3. Initialization writes starter instances of each of the seven discovery artifacts... from the templates under `docs/discovery/templates/artifacts/`. (both files)
  4. Each artifact template's `$schema` field is a relative, scheme-less path resolvable by `validate_json.py`'s existing no-scheme `_load_schema` branch, per feature 9002's convention. (both files)
  5. Tests under `tests/scripts/dev_tools/discovery/` ... include the schema-conformance test tracked as dependent on feature 9002. (both files)
