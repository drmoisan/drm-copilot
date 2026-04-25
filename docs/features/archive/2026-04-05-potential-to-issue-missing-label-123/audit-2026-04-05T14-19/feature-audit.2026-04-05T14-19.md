# Feature Audit: potential-to-issue-missing-label

## Scope and Baseline

- **Base branch:** `development`
- **Feature folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`
- **Requirements source of truth:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`
- **Work mode:** `minor-audit`
- **Authoritative acceptance-criteria source:** `issue.md` under the explicit `## Acceptance Criteria` heading only
- **PR context summary artifact:** `artifacts/pr_context.summary.txt`
- **PR context appendix artifact:** `artifacts/pr_context.appendix.txt`
- **Supplemental evidence:** live working-tree verification and the feature-folder remediation evidence, because the refreshed PR-context range is still empty while the branch changes remain uncommitted
- **Required absence rechecked:** `spec.md` absent; `user-story.md` absent

## Acceptance Criteria Inventory

Authoritative criteria extracted only from `issue.md` under `## Acceptance Criteria`:

1. `Promoting a potential entry as feature succeeds when the repository does not already contain a feature label.`
2. `The promotion workflow continues to pass through the selected promotion label when the label already exists.`
3. `Focused regression coverage proves the missing-label scenario fails before the fix and passes after the fix.`

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| Promoting a potential entry as `feature` succeeds when the repository does not already contain a `feature` label. | PASS | Saved remediation evidence shows the bundled runtime red/green pair, and the current bundled runtime module contains the recovery logic mirrored from the root implementation. | `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing`; code inspection of `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/resources/templates/potential_to_issue.py`, and `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` | Fresh rerun stayed green and the actual shipped path now includes `ensure_label` plus the single retry branch. |
| The promotion workflow continues to pass through the selected promotion label when the label already exists. | PASS | Saved green remediation artifact and the fresh bundled-runtime rerun both cover the existing-label single-create path. | `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing` | The bundled runtime keeps the selected `feature` label and avoids the retry path when the label already exists. |
| Focused regression coverage proves the missing-label scenario fails before the fix and passes after the fix. | PASS | The feature folder now contains direct bundled-runtime fail-before and pass-after artifacts: `evidence/regression-testing/remediation.red-bundled-runtime-pytest.2026-04-05T14-15.md` and `evidence/regression-testing/remediation.green-bundled-runtime-pytest.2026-04-05T14-15.md`. The fresh bundled-runtime rerun stayed green. | Saved red/green remediation commands in those artifacts; fresh command `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing` | The acceptance criterion requires fail-before and pass-after proof, and that proof now exists on the actual bundled runtime path used by the extension. |

## Summary

**Overall feature readiness:** PASS

The `issue.md` requirements are now satisfied. The bundled runtime path used by `drmCopilotExtension.potentialToIssue` has direct fail-before and pass-after evidence, and the explicit `minor-audit` acceptance criteria are all supported by the latest evidence.

### Remaining note outside acceptance criteria

The branch is still **not ready to merge** because the policy audit found a separate repo-compliance gap: focused bundled-runtime coverage is only 65%, below the required threshold for modified code. That is a merge-readiness problem, not an acceptance-criteria problem.

## Acceptance Criteria Check-off

No source-file change was required during this re-audit because all three criteria were already correctly checked in `issue.md` and the latest bundled-runtime evidence now supports them.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`
- Total AC items: 3
- Checked off (delivered): 3
- Remaining (unchecked): 0
- Items remaining: none
