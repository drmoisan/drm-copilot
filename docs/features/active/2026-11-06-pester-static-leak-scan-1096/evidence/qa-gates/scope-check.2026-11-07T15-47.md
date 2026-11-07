# QA Gate: Scope, Reduction Commit, and Evidence Content

Timestamp: 2026-11-07T15-47
Command: pwsh -File SCRATCH/issue-1096-scope.ps1 -Root <item worktree> (git diff --name-status --no-renames from the merge base of origin/main and HEAD with git status --porcelain as companion; addopts and poshqc-linux-hooks checks; git log of reduction: 0001 commits; case-insensitive evidence scan with tokens assembled at run time; baseline commit ordering through git log; exits non-zero on any match)
EXIT_CODE: 0
Output Summary: Third pass, after the Windows PowerShell 5.1 allowlist fix. No added .py file, no path under the Scope exclusions, no .github/workflows/ci.yml, no pyproject.toml, and no new file under docs/engineering/process-reductions/; the only other docs/features/ path is the promoted record under docs/features/potential/promoted/. addopts holds no -n, and the poshqc-linux-hooks job text equals the merge base. Two reduction: 0001 commits (the reduction and the fence correction); neither adds scan text outside the entry. No host path and no run-citation token in the evidence outside the name fields of failure rows. The P0-T3 baseline commit precedes the first commit that changes a path outside docs/features/.

## Step Output

DIFF-ENTRIES=92 PORCELAIN-ENTRIES=10
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/coverage-thresholds.2026-11-07T15-47.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/jest.2026-11-07T15-47.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/leak-scan.2026-11-07T15-38.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pester-parallel.2026-11-07T15-43.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/powershell-analyze.2026-11-07T15-38.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/powershell-format.2026-11-07T15-38.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/pytest-parallel.2026-11-07T15-46.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/python-black.2026-11-07T15-38.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/python-pyright.2026-11-07T15-38.md
PORCELAIN: ?? docs/features/active/2026-11-06-pester-static-leak-scan-1096/evidence/qa-gates/python-ruff.2026-11-07T15-38.md
DOCS-FEATURES-OTHER: A docs/features/potential/promoted/2026-11-06-pester-static-leak-scan.md
ADDOPTS: addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info --strict-markers --strict-config"
LINUX-HOOKS-JOB-UNCHANGED=True LENGTH=1399
REDUCTION-COMMITS=2
REDUCTION-COMMIT: test(atomic-executor): document the reduction test fakes and correct their fences, reduction: 0001 | added lines outside entry 6 | scan-text lines 0
REDUCTION-COMMIT: refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001 | added lines outside entry 190 | scan-text lines 0
EVIDENCE-FILES=45
BASELINE-COMMIT-INDEX=11 FIRST-OUTSIDE-DOCS-FEATURES-INDEX=12
FAILURES=0
