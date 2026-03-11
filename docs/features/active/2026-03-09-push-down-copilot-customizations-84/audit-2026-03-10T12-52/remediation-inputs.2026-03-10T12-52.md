# Remediation Inputs: push-down-copilot-customizations (#84)

**Timestamp:** 2026-03-10T12-52  
**Authoritative review artifacts:**
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/policy-audit.2026-03-10T12-52.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/code-review.2026-03-10T12-52.md`
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/feature-audit.2026-03-10T12-52.md`

## Required Fixes

1. **Split the oversized publisher module into cohesive files**
   - **Files:** `scripts/dev_tools/push_down_copilot_customizations.py` and any new helper modules created alongside it.
   - **Current problem:** Reviewer measurement shows `scripts/dev_tools/push_down_copilot_customizations.py` at `510` lines, above the repo’s `500`-line limit.
   - **Expected behavior:** Preserve the existing CLI/module contract (`scripts.dev_tools.push_down_copilot_customizations`, `parse_args`, `main`, `push_down_customizations`) while reducing each production file to `<=500` lines.
   - **Minimum acceptable change:** Extract at least one cohesive concern (for example: filesystem adapter(s), rewrite catalog/renderer, or summary artifact helpers) into a separate module.
   - **Acceptance criteria:** Policy compliance for module size; no behavior regressions in copy/rewrite/placeholder flows.
   - **Verification commands:**
     - `poetry run black --check .`
     - `poetry run ruff check`
     - `poetry run pyright`
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
     - reviewer-style line count check for the resulting production files

2. **Raise new-module Python coverage from 89% to at least 90%**
   - **Files:** `scripts/dev_tools/push_down_copilot_customizations.py`; `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`; optionally new targeted test modules if needed.
   - **Current problem:** Reviewer rerun measured `scripts/dev_tools/push_down_copilot_customizations.py` at `194 stmts / 22 miss / 89%`.
   - **Expected behavior:** Reviewer reruns must show the new module at `>=90%` coverage.
   - **Minimum acceptable change:** Add targeted tests and/or refactor uncovered executable stubs/branches so the module clears the threshold without weakening typing or policy settings.
   - **Known uncovered areas from reviewer output:** protocol/real-FS/CLI lines around `72`, `76`, `80`, `84`, `88`, `92`, `119-127`, `131`, `135`, `139`, `143-144`, `148`, `442`, and `610-611`.
   - **Acceptance criteria:** Policy compliance for new-module coverage.
   - **Verification commands:**
     - `poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing`
     - `poetry run pyright`

3. **Reconcile the stale plan state and missing fail-before evidence for `P1-T10`**
   - **Files:** `docs/features/active/2026-03-09-push-down-copilot-customizations-84/plan.2026-03-09T23-14.md`; `docs/features/active/2026-03-09-push-down-copilot-customizations-84/evidence/regression-testing/p1-t10-placeholder-error.2026-03-09T23-14.md` (or an explicit replacement/waiver note if policy allows).
   - **Current problem:** `P1-T10` remains unchecked while `P4-T10` is checked and the green-path Jest test exists; the required fail-before evidence artifact is absent.
   - **Expected behavior:** The plan and regression evidence should accurately represent what was executed during the feature implementation.
   - **Minimum acceptable change:** Mark `P1-T10` correctly and add the missing fail-before evidence artifact or a clear, auditable explanation for why it cannot exist.
   - **Acceptance criteria:** Supporting documents accurately reflect implementation and verification history.
   - **Verification commands:**
     - confirm `P1-T10` status in the plan file
     - confirm the expected evidence artifact exists (or a replacement rationale file exists)

## Do Not Do

- Do **not** weaken repo policy to accept the current 510-line module or 89% new-module coverage.
- Do **not** remove existing functional tests just to improve coverage percentages.
- Do **not** broaden scope into unrelated extension or prompt customizations.
- Do **not** silently skip the fail-before evidence gap; either restore it or document it explicitly.

## Acceptance Criteria Still Not Fully Met

1. **AC9 is only functionally satisfied, not policy-complete for merge readiness**
   - **Why:** Automated tests exist, but the new Python module still measures `89%`, below the repo’s `>=90%` target for new modules.
   - **Minimum change to clear:** Add targeted tests/refactor coverage-affecting executable lines until reviewer reruns show `>=90%` coverage for `scripts/dev_tools/push_down_copilot_customizations.py`.

2. **Merge-readiness policy gate outside explicit AC wording**
   - **Why:** The new production Python file exceeds the repo’s `500`-line limit.
   - **Minimum change to clear:** Split the publisher into smaller cohesive modules while preserving behavior and public entry points.

3. **Documentation / evidence accuracy gap**
   - **Why:** `P1-T10` is stale in the plan and its expected fail-before evidence file is missing.
   - **Minimum change to clear:** Update the plan state and add or explicitly reconcile the missing evidence.
