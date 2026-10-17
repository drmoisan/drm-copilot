# Regression: #764 issue status and evidence-stamp note ([P7-T9], AC-22, AC-23)

Merge-base substitution: anchored commands use 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a (recorded by [P0-T4]) in place of the plan literal e7d3779b398604af919678c16c877c8539a86cc0.

Timestamp: 2026-10-09T21-37
Command: git grep -n -F -e "Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/" -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md
EXIT_CODE: 0
Output Summary: one line, line 5:

```
docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md:5:- Status: Promoted -> docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/ (Issue #764)
```

Prior value of line 5 (retained per deviation D-5): `- Status: Promoted -> docs/features/active/feature-review-skill-cites-nonexistent-validator/ (Issue #764)`. [P7-T8] numstat against 311dea054 reported `1	1` (1 added, 1 deleted).

## Block 2

Command: git diff --name-status --diff-filter=DR 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/
EXIT_CODE: 0
Output Summary: nothing printed (no deleted or renamed path).

## Block 3

Command: git status --porcelain --untracked-files=all -- docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/
EXIT_CODE: 0
Output Summary: three entries, all paths this plan writes; no `D` or `R` status:

```
 M docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/issue.md
 M docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/plan.2026-09-30T05-00.md
?? docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.2026-10-09T09-00.md
```

## Block 4

Command: grep -c -F -e "| " docs/features/active/2026-09-28-feature-review-skill-cites-nonexistent-validator-764/evidence/other/evidence-filename-timestamps.2026-10-09T09-00.md
EXIT_CODE: 0
Output Summary: 13 (header, separator, 11 rows).

Acceptance (AC-22, AC-23): every block shows the stated result. PASS.
