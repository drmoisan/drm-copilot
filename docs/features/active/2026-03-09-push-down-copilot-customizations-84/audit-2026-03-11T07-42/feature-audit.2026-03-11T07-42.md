# Feature Audit — push-down-copilot-customizations (#84)

## Scope and Baseline

- **Base branch:** `development`
- **Head branch / reviewed state:** `feature/push-down-copilot-customizations-84` @ `351d8c1b1dd98c250788996dc836f1607caf756a` plus the current working-tree delta refreshed on 2026-03-11T07-42
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary: `artifacts/pr_context.appendix.txt`
  - Supporting: `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md`, `v2/user-story.md`, `issue.md`, and `v2/evidence/**`
- **Feature folder used:** `docs/features/active/2026-03-09-push-down-copilot-customizations-84`
- **Active scoping-doc selection rule:** `issue.md` resolves the work mode to `full`, so `v2/spec.md` and `v2/user-story.md` are authoritative. `v2/` was selected because refreshed PR context lists those files as the material scoping-doc changes.

## Acceptance Criteria Inventory (authoritative)

Authoritative AC sources for this run:
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/spec.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/v2/user-story.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md`
- Refreshed AC blocks in `artifacts/pr_context.summary.txt`

Consolidated criteria for the active `v2` scope:
1. A Python entry point can push down all files from `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` into a destination workspace while preserving each file's relative path under `.github/`.
2. The `drm-copilot` extension contributes and registers a dedicated non-placeholder push-down command whose handler launches a bundled copy of `scripts.dev_tools.push_down_copilot_customizations` using the same packaged runtime/script execution model already used for PR-context collection.
3. When the destination workspace already contains a file at the same relative path, the push-down run overwrites that file with the source-repo version instead of skipping or merging it.
4. Copied files that reference already-exposed tooling are rewritten from repo-local script paths to packaged extension command references that match the extension's bundled execution model, including a real bundled extension command for `scripts.dev_tools.push_down_copilot_customizations` and the existing bundled PR-context command.
5. Copied files that reference tooling not yet exposed by the extension are rewritten to stable placeholder command references, and invoking those placeholders surfaces a clear not-implemented failure rather than a missing-file/path error.
6. The implementation introduces a dedicated one-way Python entry point for push-down behavior, leaving the current bidirectional `scripts/dev_tools/agentic_sync.py` contract unchanged unless small shared helpers are extracted without altering sync semantics.
7. Rewrites normalize both `scripts/dev_tools/...` and `scripts/dev-tools/...` references to the same catalog entry so mixed slash styles on Windows or cross-platform docs resolve to the same extension-command target.
8. If a text file contains a script-like reference that is outside the initial verified command catalog, the file content remains unchanged and the run summary reports that unmatched reference explicitly.
9. Invalid destination input fails before partial copy begins, with a deterministic error that explains why the destination workspace root is unusable.
10. Automated coverage includes Python tests for enumeration/copy/overwrite/rewrite/unmatched-reference reporting behavior and extension tests for push-down command contribution, packaged-path execution of the bundled push-down resource, continued packaged-path execution of PR-context collection, and placeholder-command failure paths.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. Python entry point pushes all scoped `.github` trees while preserving relative paths. | PASS | `scripts/dev_tools/push_down_copilot_customizations.py` enumerates `ROOT_FOLDERS`; `test_push_down_copies_scoped_github_trees_to_empty_destination` covers copy into all four scoped roots. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Verified in the live 2026-03-11 rerun. |
| 2. Extension contributes and registers a real push-down command that launches the bundled publisher. | PASS | `extensions/drm-copilot/package.json` contributes `drmCopilotExtension.pushDownCopilotCustomizations`; `extensions/drm-copilot/src/extension.ts` registers the real handler; Jest covers registration and bundled wrapper execution. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` | Live run passed `42` tests. |
| 3. Existing destination files are overwritten. | PASS | `test_push_down_overwrites_existing_destination_file` asserts overwrite behavior. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Current Pytest rerun passed. |
| 4. Known exposed tooling references rewrite to real packaged extension commands. | PASS | `scripts/dev_tools/push_down_copilot_customizations_rewrites.py` maps both `scripts.dev_tools.pr_context.collector` and `scripts.dev_tools.push_down_copilot_customizations` to real command IDs; tests cover both PR-context and push-down rewrites. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Real-command rewrite path is directly exercised by `test_rewrite_known_push_down_reference_to_real_command`. |
| 5. Uncovered tooling references rewrite to deterministic placeholders. | PASS | Placeholder mappings exist for feature-folder/potential-entry tools; `extension.placeholder-commands.test.ts` verifies deterministic `Not implemented:` failure behavior. | `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` | Live Jest rerun passed placeholder behavior coverage. |
| 6. One-way entry point leaves `agentic_sync.py` semantics intact. | PASS | Dedicated publisher module exists; `tests/scripts/dev_tools/test_agentic_sync.py::test_sync_repos_ignores_files_missing_on_one_side` guards the bidirectional sync path. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | No regression observed in the live full suite. |
| 7. Slash variants normalize to one command-catalog target. | PASS | `test_rewrite_normalizes_dev_tools_slash_variants` asserts normalization across `scripts/dev_tools` and `scripts/dev-tools`. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Explicit Windows/cross-platform path risk is covered. |
| 8. Unknown references stay unchanged and are reported. | PASS | `test_push_down_reports_unmatched_script_references_without_rewrite` asserts exact pass-through text and unmatched-reference reporting. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Safe non-heuristic behavior confirmed. |
| 9. Invalid destination input fails before partial copy. | PASS | `validate_destination()` raises clear `ValueError`; Python tests cover missing destination and source-repo destination failure paths. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Deterministic failure message contract is covered. |
| 10. Automated coverage includes Python push-down tests and extension command-path tests. | PASS | Live Pytest run passed `824` tests and reports `100%` coverage for source push-down modules; live Jest run passed registration, bundled wrapper, `--destination`, PR-context bundled path, and placeholder failure suites. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`; `npm --prefix extensions/drm-copilot run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=text` | AC satisfied with both static and dynamic evidence. |

## Summary

**Overall feature readiness:** **PASS**

All acceptance criteria for the active `v2` scope are satisfied relative to `development`. The live rerun on 2026-03-11 confirms that the feature behavior is complete, the bundled push-down command path works, rewrite coverage is present for both real and placeholder command references, and the automated coverage story is strong.

**Top gaps preventing PASS:** None for feature acceptance itself.

**Follow-up note:** Separate policy/code-review follow-ups still exist (`extension.ts` size, wrapper `Any`, README drift), but those are **not acceptance-criteria failures**. They are tracked in `policy-audit.2026-03-11T07-42.md`, `code-review.2026-03-11T07-42.md`, and the remediation artifacts below.

**Recommended follow-up verification steps:** After remediation, rerun the same TypeScript and Python QA commands to confirm the policy/doc fixes do not disturb accepted behavior.
