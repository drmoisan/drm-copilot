# Remediation Inputs: potential-to-issue-missing-label

**Timestamp:** 2026-04-05T14-19  
**Base Branch:** `development`  
**Feature Folder:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123`  
**Requirements Source:** `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/issue.md`

## Required Fixes

1. **Raise bundled-runtime focused coverage to at least 90%**
   - **Files:**
     - `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py`
     - `tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
   - **Current evidence:**
     - Fresh command `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing`
     - Current result: `6 passed`, but `extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py = 65%`
     - Fresh missing lines: `72-75, 80-89, 92-109, 112-122, 125-134, 137-144, 166, 169, 172, 175, 178-179, 182, 185-186, 197, 221, 223, 230, 236, 240, 250-251, 257-258, 262-276, 287-291, 319, 336-341, 377-400, 404-418`
   - **Expected behavior:**
     - The bundled runtime keeps the current missing-label recovery behavior intact.
     - The bundled-runtime pytest module or equivalent focused coverage path reaches `>= 90%` for the changed bundled runtime module.
   - **Verification commands:**
     - `poetry run black --check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
     - `poetry run ruff check extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
     - `poetry run pyright extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py`
     - `poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q --cov=dev_tools.potential_to_issue --cov-report=term-missing`

2. **Refresh the review evidence after the coverage fix**
   - **Files:**
     - `artifacts/pr_context.summary.txt`
     - `artifacts/pr_context.appendix.txt`
     - `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/policy-audit.<new timestamp>.md`
     - `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/code-review.<new timestamp>.md`
     - `docs/features/active/2026-04-05-potential-to-issue-missing-label-123/feature-audit.<new timestamp>.md`
   - **Expected behavior:**
     - The refreshed audit artifacts cite the passing bundled-runtime coverage result and mark the branch ready for merge if no other failures remain.
   - **Verification commands:**
     - `poetry run python -m scripts.dev_tools.pr_context.collector --base development`
     - Re-run the focused Python QC loop and regenerate the review artifacts.

## Do Not Do

- Do not weaken or bypass the repository coverage requirement.
- Do not broaden scope beyond the bundled runtime coverage gap unless a directly related blocker is discovered.
- Do not change `issue.md` acceptance criteria text.
- Do not add `spec.md` or `user-story.md`; this remains a `minor-audit` workflow.
- Do not silently skip the Black, Ruff, Pyright, or pytest coverage verification steps.

## Acceptance-Criteria Status

All `issue.md` acceptance criteria are currently met.

- AC1: met
- AC2: met
- AC3: met

**Minimum remaining change:** policy-only remediation to raise bundled-runtime focused coverage to the repo threshold and then refresh the audit evidence.
