# Feature Audit: potential-to-issue-missing-label

## Scope and Baseline

- **Base branch:** `development`
- **Feature folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`
- **Requirements source of truth:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`
- **Work mode:** `minor-audit`
- **PR context summary artifact:** `artifacts/pr_context.summary.txt`
- **PR context appendix artifact:** `artifacts/pr_context.appendix.txt`
- **Supplemental baseline evidence:** reviewer working-tree diff against `origin/development`, because the refreshed PR-context artifacts report an empty committed range while the implementation remains uncommitted in the working tree.

## Acceptance Criteria Inventory

Authoritative criteria extracted only from `issue.md` under the explicit `## Acceptance Criteria` heading:

1. `Promoting a potential entry as feature succeeds when the repository does not already contain a feature label.`
2. `The promotion workflow continues to pass through the selected promotion label when the label already exists.`
3. `Focused regression coverage proves the missing-label scenario fails before the fix and passes after the fix.`

## Acceptance Criteria Evaluation

| Criterion | Status | Evidence | Verification command(s) | Notes |
|---|---|---|---|---|
| Promoting a potential entry as `feature` succeeds when the repository does not already contain a `feature` label. | FAIL | Root evidence: `scripts/dev_tools/potential_to_issue.py` now retries after `ensure_label`; root green evidence exists in `evidence/regression-testing/p1-t5.green-pytest.2026-04-05T13-58.md`. Runtime-path evidence: `extensions/drm-copilot/src/repo-automation-service.ts` still launches `resources/templates/potential_to_issue.py`, which imports `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`; that bundled script still exits immediately on `create_result.exit_code != 0` and contains no `ensure_label` path. | `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`; repository code inspection of the extension service, wrapper, and bundled runtime script | The actual command named in `issue.md` is still broken on the missing-label path because the fix was applied only to the root module, not to the bundled runtime implementation. |
| The promotion workflow continues to pass through the selected promotion label when the label already exists. | PASS | Root regression `test_promote_potential_feature_existing_label_uses_single_issue_create_attempt` proves the root implementation retains the `feature` label on the existing-label path. The bundled runtime script still passes `promotion_type` directly to `issue_create`, so the selected label remains unchanged on that path. | `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`; repository code inspection of the bundled runtime `issue_create` call | This criterion remains satisfied, and its checkbox remains checked in `issue.md`. |
| Focused regression coverage proves the missing-label scenario fails before the fix and passes after the fix. | PARTIAL | Red-run evidence exists in `evidence/regression-testing/p1-t3.red-pytest.2026-04-05T13-57.md`. Green-run evidence exists in `evidence/regression-testing/p1-t5.green-pytest.2026-04-05T13-58.md` and the final QC artifact `evidence/qa-gates/p2-t4.pytest-coverage.2026-04-05T14-01.md`. However, that proof covers only the root Python module and does not prove the bundled extension runtime path has passed after the fix. | `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q -k "feature_missing_label or existing_label_uses_single_issue_create_attempt" --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing`; `poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py -q --cov=scripts.dev_tools.potential_to_issue --cov-report=term-missing` | Fail-before proof is present, but pass-after proof is incomplete for the actual extension path described in `issue.md`. |

## Summary

**Overall feature readiness:** BLOCKED

### Top gaps preventing PASS

1. The extension command still executes a bundled Python implementation that lacks the missing-label recovery logic.
2. The regression coverage proves only the root helper path, not the actual extension-bundled runtime path.
3. The acceptance checklist had been over-checked relative to the evidence and had to be corrected during review.

### Recommended follow-up verification steps

1. Update the bundled runtime script at `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py` to match the required missing-label recovery behavior.
2. Add focused verification for the bundled runtime path or the extension command path.
3. Rerun the red/green targeted regression pair and the final QC loop after the runtime-path fix.

## Acceptance Criteria Check-off

The review reconciled `issue.md` to match the verified evidence:

- Criterion 1 changed from checked to unchecked.
- Criterion 2 remained checked.
- Criterion 3 changed from checked to unchecked.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`
- Total AC items: 3
- Checked off (delivered): 1
- Remaining (unchecked): 2
- Items remaining:
  - `Promoting a potential entry as feature succeeds when the repository does not already contain a feature label.`
  - `Focused regression coverage proves the missing-label scenario fails before the fix and passes after the fix.`
