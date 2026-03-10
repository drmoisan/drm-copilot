# Feature Audit: push-down-copilot-customizations (#84)

## Scope and baseline

- **Base branch:** `development`
- **Head / working tree reviewed:** `feature/push-down-copilot-customizations-84` @ `518872fbc33d37f634f242fc7cff06a9d8d67afd` plus the current unstaged working-tree delta validated on 2026-03-10T17-10
- **Evidence sources:**
  - Primary: refreshed `artifacts/pr_context.summary.txt`
  - Secondary: refreshed `artifacts/pr_context.appendix.txt`
  - Supporting: feature docs and feature evidence under `docs/features/active/2026-03-09-push-down-copilot-customizations-84/`
- **Feature folder used:** `docs/features/active/2026-03-09-push-down-copilot-customizations-84`
- **Work mode source:** `issue.md` -> `Work Mode: full`

This rerun explicitly ignored stale prior conclusions and revalidated the **current working tree**. I refreshed PR context first because the prior summary was stale and incorrectly reported no diff relative to `development`.

## Acceptance criteria inventory (authoritative)

Authoritative criteria were collected from the refreshed PR context summary plus the active full-mode scoping docs (`spec.md` and `user-story.md`):

1. A Python entry point can push down all files from `.github/agents/`, `.github/instructions/`, `.github/prompts/`, and `.github/skills/` into a destination workspace while preserving each file's relative path under `.github/`.
2. When the destination workspace already contains a file at the same relative path, the push-down run overwrites that file with the source-repo version instead of skipping or merging it.
3. Copied files that reference already-exposed tooling are rewritten from repo-local script paths to packaged extension command references that match the extension's bundled execution model.
4. Copied files that reference tooling not yet exposed by the extension are rewritten to stable placeholder command references, and invoking those placeholders surfaces a clear not-implemented failure rather than a missing-file/path error.
5. The implementation introduces a dedicated one-way Python entry point for push-down behavior, leaving the current bidirectional `scripts/dev_tools/agentic_sync.py` contract unchanged unless small shared helpers are extracted without altering sync semantics.
6. Rewrites normalize both `scripts/dev_tools/...` and `scripts/dev-tools/...` references to the same catalog entry so mixed slash styles on Windows or cross-platform docs resolve to the same extension-command target.
7. If a text file contains a script-like reference that is outside the initial verified command catalog, the file content remains unchanged and the run summary reports that unmatched reference explicitly.
8. Invalid destination input fails before partial copy begins, with a deterministic error that explains why the destination workspace root is unusable.
9. Automated coverage includes Python tests for enumeration/copy/overwrite/rewrite/unmatched-reference reporting behavior and extension tests for command contribution, packaged-path execution, and placeholder-command failure paths.

## Acceptance criteria evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|-----------|--------|----------|--------------------------|-------|
| 1. Python entry point pushes all scoped `.github` trees while preserving relative paths. | PASS | `scripts/dev_tools/push_down_copilot_customizations.py` enumerates `ROOT_FOLDERS`; `test_push_down_copies_scoped_github_trees_to_empty_destination` verifies copy into all four roots. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Verified dynamically in the current rerun. |
| 2. Existing destination files are overwritten. | PASS | `test_push_down_overwrites_existing_destination_file` asserts same-path destination overwrite behavior. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Current run passed. |
| 3. Known exposed tooling references are rewritten to packaged extension commands. | PASS | `test_rewrite_known_pr_context_reference_to_collect_pr_context_command`; rewrite catalog maps PR-context collector to `scaffoldExtension.collectPrContext`; `README.md` documents the command. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Static + dynamic evidence aligns. |
| 4. Unknown-yet-exposed tooling is rewritten to stable placeholders that fail deterministically. | PASS | `test_rewrite_new_active_feature_folder_reference_to_placeholder_command`; `extensions/drm-copilot/test/extension.placeholder-commands.test.ts` verifies registration and deterministic `Not implemented:` failure. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`; `npm --prefix extensions/drm-copilot run test:unit` | Placeholder failure behavior was revalidated in the current Jest run. |
| 5. Dedicated one-way Python entry point leaves `agentic_sync.py` behavior intact. | PASS | New module entry point exists at `scripts/dev_tools/push_down_copilot_customizations.py`; `tests/scripts/dev_tools/test_agentic_sync.py::test_sync_repos_ignores_files_missing_on_one_side` protects the existing sync semantics. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | No regression observed in the current full Python suite. |
| 6. Slash variants normalize to one catalog target. | PASS | `test_rewrite_normalizes_dev_tools_slash_variants` exercises both `scripts/dev_tools/...` and `scripts/dev-tools/...` forms. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Windows-path normalization requirement is covered directly. |
| 7. Unknown script-like references remain unchanged and are reported. | PASS | `test_push_down_reports_unmatched_script_references_without_rewrite` asserts pass-through text plus ordered unmatched-reference reporting. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Behavior remains explicit and non-heuristic. |
| 8. Invalid destination input fails before partial copy. | PASS | `validate_destination()` raises clear `ValueError`; `test_main_rejects_invalid_destination_before_copy` and `test_push_down_customizations_rejects_repo_root_destination` verify both failure paths. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Deterministic message contract confirmed in tests. |
| 9. Automated coverage includes Python behavior tests and extension tests for placeholder-command behavior. | PASS | Current Pytest run passed `821` tests and reported `100%` coverage for the three push-down Python modules; current Jest run passed `4` suites / `39` tests including the placeholder-command suite. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`; `npm --prefix extensions/drm-copilot run test:unit` | The rerun confirms the remediation claim that the extracted push-down modules are fully covered. |

## Summary

**Overall feature readiness:** **PASS**

The feature satisfies all current acceptance criteria relative to `development`, and the refreshed review confirms the just-remediated working tree rather than the stale earlier snapshot. The toolchain is green across both Python and TypeScript, overall Python coverage improved from `81%` to `82%`, and each extracted push-down Python module is now at `100%` coverage.

**Top gaps preventing PASS:** None.

**Recommended follow-up verification steps:**
- Commit the current validated working-tree delta so the branch/PR state matches the green state reviewed here.
- Keep future command-surface additions synchronized between `push_down_copilot_customizations_rewrites.py` and `extensions/drm-copilot/src/extension.ts`.
