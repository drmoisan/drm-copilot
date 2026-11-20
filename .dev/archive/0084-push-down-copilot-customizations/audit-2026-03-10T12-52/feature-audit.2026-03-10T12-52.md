# Feature Audit: push-down-copilot-customizations (#84)

## Scope and Baseline

- **Base branch:** `development`
- **Feature folder:** `docs/features/active/2026-03-09-push-down-copilot-customizations-84`
- **Primary evidence sources:**
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
  - `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md`
  - `docs/features/active/2026-03-09-push-down-copilot-customizations-84/spec.md`
  - `docs/features/active/2026-03-09-push-down-copilot-customizations-84/user-story.md`
  - current code/tests in the working tree

**Baseline note:** After refresh, the canonical PR context reported no committed diff between `development` and `feature/push-down-copilot-customizations-84`. This feature audit therefore evaluates the current working tree relative to `origin/development`, not only committed branch history.

## Acceptance Criteria Inventory (authoritative)

This audit uses the acceptance criteria listed in `user-story.md` as the primary checklist because the feature is in **Work Mode: full** and both `spec.md` and `user-story.md` are present.

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| 1. A Python entry point can push down all files from the four scoped `.github` roots while preserving relative path. | PASS | `scripts/dev_tools/push_down_copilot_customizations.py`; `test_push_down_copies_scoped_github_trees_to_empty_destination`; `ROOT_FOLDERS` reuse from `agentic_sync.py`. | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing` | Unit tests prove one file per scoped root and static review confirms deterministic root-based enumeration. |
| 2. Existing destination files are overwritten rather than skipped/merged. | PASS | `test_push_down_overwrites_existing_destination_file`; `PushDownFileResult.destination_status`; overwrite accounting in `push_down_customizations()`. | same Pytest coverage command as above | The overwrite path is directly asserted in focused unit tests. |
| 3. Known exposed tooling references are rewritten to packaged extension command references. | PASS | `test_rewrite_known_pr_context_reference_to_collect_pr_context_command`; rewrite catalog maps `scripts.dev_tools.pr_context.collector` to `drmCopilotExtension.collectPrContext`; README documents the packaged command. | same Pytest coverage command as above | This is statically and dynamically verified for the PR-context command. |
| 4. Uncovered tooling references are rewritten to placeholders and invoking them yields a deterministic not-implemented failure. | PASS | `extension.placeholder-commands.test.ts`; `registerPlaceholderCommands()`; placeholder IDs added to `package.json`; Python rewrite test for `new_active_feature_folder`. | `npm --prefix extensions/drm-copilot run test:unit`; Python coverage command | Verified at both rewrite and runtime-error layers. |
| 5. A dedicated one-way entry point is introduced without regressing the existing `agentic_sync.py` two-way contract. | PASS | New module `scripts/dev_tools/push_down_copilot_customizations.py`; regression test `test_sync_repos_ignores_files_missing_on_one_side`. | Python coverage command | The implementation adds a new entry point and explicitly reuses `ROOT_FOLDERS` instead of mutating sync behavior. |
| 6. Slash variants (`scripts/dev_tools` and `scripts/dev-tools`) normalize to the same catalog target. | PASS | `test_rewrite_normalizes_dev_tools_slash_variants`; `normalize_reference_for_lookup()`. | Python coverage command | Covered with both Python and PowerShell placeholder targets. |
| 7. Unknown references remain unchanged and are reported explicitly. | PASS | `test_push_down_reports_unmatched_script_references_without_rewrite`; unmatched references are stored on the summary object. | Python coverage command | This criterion is directly asserted. |
| 8. Invalid destination input fails before partial copy begins with a deterministic error. | PASS | `test_main_rejects_invalid_destination_before_copy`; `validate_destination()` raises `ValueError` before file processing. | Python coverage command | The behavior is deterministic, though CLI-facing presentation could still be polished later. |
| 9. Automated coverage includes Python tests for push-down behavior and extension tests for command contribution, packaged-path execution, and placeholder failures. | PASS | New Pytest module for push-down scenarios; new Jest placeholder-command tests; reviewer reruns passed (`809` Pytest tests, `39` Jest tests). | `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`; `npm --prefix extensions/drm-copilot run test:unit` | Functional test coverage is present. Merge readiness is still blocked by the separate policy requirement that new Python modules reach `>=90%` coverage. |

## Summary

### Overall feature readiness: NEEDS REVISION

The feature behavior itself is largely complete and the acceptance criteria above are satisfied based on current code/tests. However, the branch is **not ready to merge** because the policy audit found two explicit compliance failures:

1. `scripts/dev_tools/push_down_copilot_customizations.py` is `510` lines, above the repo’s `500`-line cap.
2. The new Python module measures **89%** coverage on the reviewer rerun, below the repo requirement of `>=90%` for new modules.

### Top gaps preventing PASS

- Split the oversized Python publisher into smaller cohesive modules.
- Add targeted tests/refactoring so reviewer-measured coverage for the new Python module reaches `>=90%`.
- Reconcile the stale `P1-T10` plan state and missing fail-before evidence artifact.

### Recommended follow-up verification

After remediation, rerun:
- `npm --prefix extensions/drm-copilot exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- `npm --prefix extensions/drm-copilot run lint`
- `npm --prefix extensions/drm-copilot run typecheck`
- `npm --prefix extensions/drm-copilot run test:unit`
- `poetry run black --check .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
