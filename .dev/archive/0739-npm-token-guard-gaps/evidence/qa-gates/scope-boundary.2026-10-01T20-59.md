# Scope boundary check (P2-T15)

Timestamp: 2026-10-01T20-59

Command: git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output (14 untracked Phase 2 evidence files, all under the feature `evidence/qa-gates/` folder):

    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/ac-node-listing.2026-10-01T20-58.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/ac10-github-unmodified.2026-10-01T20-59.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/ac11-line-count.2026-10-01T20-59.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/ac8-docstring-check.2026-10-01T20-59.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/ac9-runbook-check.2026-10-01T20-59.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/coverage-comparison.2026-10-01T20-58.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-black.2026-10-01T20-55.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-coverage-percentages.2026-10-01T20-57.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-coverage-thresholds.2026-10-01T20-57.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-loop-single-pass.2026-10-01T20-58.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-pyright.2026-10-01T20-55.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-pytest-coverage.2026-10-01T20-57.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-pytest-guard.2026-10-01T20-55.md
    ?? docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-ruff.2026-10-01T20-55.md

Command2: git fetch origin main
Output2: `From https://github.com/drmoisan/drm-copilot` / ` * branch              main       -> FETCH_HEAD` (origin/main resolves to 12fd3c26)

Command3: git diff --name-only origin/main...HEAD
ExitCode3: 0
Output3 (classified):

- Plan-written, allowed explicitly:
  - tests/scripts/dev_tools/test_workflow_npm_token_guard.py
  - docs/features/completed/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md
  - docs/features/active/2026-09-27-npm-token-guard-gaps-739/plan.2026-09-29T21-55.md
  - docs/features/active/2026-09-27-npm-token-guard-gaps-739/issue.md (also present on the branch before this plan ran as a promotion file)
- Plan-written evidence under `docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/`:
  - evidence/baseline/ (13 files: phase0-instructions-read.md and the twelve `baseline-*.2026-10-01T20-49.md` artifacts)
  - evidence/other/phase1-handoff.2026-10-01T20-53.md
  - evidence/other/runbook-step2-check.2026-10-01T20-57.md
  - evidence/regression-testing/fail-before-exception.2026-10-01T20-58.md
  - evidence/regression-testing/guard-constraint-scan.2026-10-01T20-56.md
  - evidence/regression-testing/guard-detection.2026-10-01T20-54.md
  - evidence/regression-testing/guard-line-count.2026-10-01T20-56.md
- Pre-existing on the branch before this plan ran (recorded, not written by this plan):
  - docs/features/active/2026-09-27-npm-token-guard-gaps-739/research/research.2026-09-29T22-05.md
  - docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/other/preflight.2026-09-29T22-40.md
  - docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/other/preflight.2026-09-29T22-55.md

Output Summary: every listed path is an allowed plan path, a path under the feature `evidence/` folder, or a pre-existing branch file; no path begins with `.github/` or `docs/features/parallel/`.
