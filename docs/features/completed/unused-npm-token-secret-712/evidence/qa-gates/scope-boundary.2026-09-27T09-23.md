# Scope Boundary Check (P6-T11)

Timestamp: 2026-09-27T09-23
Scope: local evidence only (origin/main fetched at 91cffc3b; branch head 1e573760 at run time)

Command: git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary:
```
 M docs/features/active/unused-npm-token-secret-712/plan.2026-09-27T00-23.md
 M docs/features/active/unused-npm-token-secret-712/spec.md
?? docs/features/active/unused-npm-token-secret-712/evidence/baseline/ac1-github-npm-token-grep.2026-09-27T09-22.md
?? docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ac1-github-unmodified.2026-09-27T09-22.md
?? docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ac2-verification.2026-09-27T09-22.md
?? docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ac3-runbook-single-line.2026-09-27T09-23.md
?? docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ac3-unchanged-files.2026-09-27T09-23.md
?? docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ac4-verification.2026-09-27T09-23.md
```
(This artifact itself was written after the command ran and is also an evidence path.)

Command 2: git fetch origin main
EXIT_CODE 2: 0

Command 3: git diff --name-only origin/main...HEAD
EXIT_CODE 3: 0
Output Summary 3 (36 paths, classified):
- Plan-declared source files:
  - `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`
  - `docs/engineering/npm-token-rotation.runbook.md`
  - `docs/features/active/unused-npm-token-secret-712/spec.md`
  - `docs/features/active/unused-npm-token-secret-712/plan.2026-09-27T00-23.md`
- Evidence paths under `docs/features/active/unused-npm-token-secret-712/evidence/`: 29 files (11 under `baseline/`, 6 under `other/`, 8 under `qa-gates/`, 4 under `regression-testing/`)
- Pre-existing (already on the branch before this plan ran):
  - `docs/features/active/unused-npm-token-secret-712/issue.md`
  - `docs/features/active/unused-npm-token-secret-712/research/research.2026-09-27T00-30.md`
  - `docs/features/active/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md`
  - `spec.md` and the plan file were also authored before execution; this plan changed only their checkbox state.

No listed path begins with `.github/` or `docs/features/parallel/`. `README.md` and `docs/research/2026-05-04-publish-mcp-server-to-npm-research.md` are absent from both outputs.

Result: acceptance met.
