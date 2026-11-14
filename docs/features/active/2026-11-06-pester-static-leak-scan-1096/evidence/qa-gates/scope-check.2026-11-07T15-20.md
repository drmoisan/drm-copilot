# QA Gate: Scope, Reduction Commit, and Evidence Content

Timestamp: 2026-11-07T15-20
Command: pwsh -File SCRATCH/issue-1096-scope.ps1 -Root <item worktree> (git diff --name-status --no-renames from the merge base of origin/main and HEAD with git status --porcelain as companion; addopts and poshqc-linux-hooks checks; git log of reduction: 0001 commits; case-insensitive evidence scan with tokens assembled at run time; baseline commit ordering through git log; exits non-zero on any match)
EXIT_CODE: 0
Output Summary: 81 changed paths from the merge base and an empty porcelain status. No added .py file, no path under the Scope exclusions, no .github/workflows/ci.yml, no pyproject.toml, and no new file under docs/engineering/process-reductions/; the only other docs/features/ path is the promoted record under docs/features/potential/promoted/. addopts holds no -n, and the poshqc-linux-hooks job text equals the merge base. One reduction: 0001 commit; its 190 added lines outside the entry hold no scan text. 24 evidence files scanned: no host path and no run-citation token outside the name fields of failure rows. The P0-T3 baseline commit (index 11) precedes the first commit that changes a path outside docs/features/ (index 12).

## Step Output

DIFF-ENTRIES=81 PORCELAIN-ENTRIES=0
DOCS-FEATURES-OTHER: A docs/features/potential/promoted/2026-11-06-pester-static-leak-scan.md
ADDOPTS: addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config"
LINUX-HOOKS-JOB-UNCHANGED=True LENGTH=1399
REDUCTION-COMMITS=1
REDUCTION-COMMIT: refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001 | added lines outside entry 190 | scan-text lines 0
EVIDENCE-FILES=24
BASELINE-COMMIT-INDEX=11 FIRST-OUTSIDE-DOCS-FEATURES-INDEX=12
FAILURES=0
