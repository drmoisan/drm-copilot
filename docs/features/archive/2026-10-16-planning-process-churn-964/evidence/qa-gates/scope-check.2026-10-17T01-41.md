# QA Gate — Scope and Self-Application Check

Timestamp: 2026-10-17T01-41
Task: [P6-T11]
Command: poetry run python SCRATCH/issue-964-scope.py (git fetch origin main; git merge-base origin/main HEAD; git diff --name-only <merge base>; git status --porcelain --untracked-files=all; comparison with the `## Files Written` list and its executor note); poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-16-planning-process-churn-964/plan.2026-10-16T18-10.md; PYTHONPATH=. poetry run python SCRATCH/issue-964-docgates.py <plan path>
EXIT_CODE: 0
Output Summary:
- Merge base derivation: `git merge-base origin/main HEAD` after `git fetch origin main`; after the merge of `origin/main` (PR #965) the merge base equals the `origin/main` tip.
- Changed paths (diff from the merge base plus porcelain status): 192. Out-of-list paths: 0 (every path is in `## Files Written`, its related-findings executor note, or `FEATURE/evidence/`).
- Not-touched files of `## Conventions for This Plan` changed: 0.
- Changed non-Markdown files over 500 physical lines: 0.
- Branch-current plan validator on this plan: "plan validation passed", exit 0; G11, G12, and G13 findings on this plan: 0 (the plan carries a non-empty `## Size Justification`).
