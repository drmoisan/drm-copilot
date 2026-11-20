# Remediation Inputs: #527 feature review pass 1

- Timestamp: 2026-10-02T05-08
- Branch: `bug/poshqc-coverage-denominator-not-reproducible-527` at `70ab599d`
- Base: `origin/main`, merge base `71f8dcb4`
- Verdict: REMEDIATION_REQUIRED (one blocking finding, remediability `autonomous`)

## Source audit artifacts

- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/policy-audit.2026-10-02T05-08.md` (1 blocking: PA-B1)
- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/code-review.2026-10-02T05-08.md` (0 blocking)
- `docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/feature-audit.2026-10-02T05-08.md` (0 blocking)
- PR context: `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (head `70ab599d`)

## Remediation-required findings

### PA-B1 — Python coverage artifact absent

- Severity: Blocking
- Remediability: autonomous
- File/location: `artifacts/python/lcov.info` (absent in the worktree)
- Rule: feature-review coverage verification requires a coverage artifact for every language with changed files; Python has one changed file (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`). `.claude/rules/general-unit-test.md` Coverage Requirements.
- Fix:
  1. From the worktree root, run `poetry run pytest --cov --cov-report=lcov:artifacts/python/lcov.info` (repository-configured coverage sources).
  2. Record the repo-wide Python line and branch percentages, the command, and `EXIT_CODE` in `<FEATURE>/evidence/qa-gates/python-coverage.<ts>.md` (local clock timestamp).
  3. Record that no Python production file changed on the branch (`git diff --name-only origin/main...HEAD -- '*.py'` lists only the test module), so no changed-line regression is possible.
- Verification: the artifact exists; the evidence file carries numeric line and branch percentages; the next policy audit records an explicit Python coverage PASS or FAIL against the 85% line and 75% branch thresholds.

## Non-blocking items (no remediation cycle; carry into the PR or a follow-up)

- PA-N1 / PA-N2: file the follow-up issue for PowerShell aggregate coverage 84.67% and `scripts/powershell/PoshQC/PoshQC.psm1` 66.67% (operator-accepted on 2026-09-30; list in `evidence/qa-gates/coverage-aggregate.2026-10-02T08-45.md`).
- PA-N3: AC-01, AC-11, AC-12, AC-13 await operator-run commands (operator decision 2026-10-01); PR wording "Partially addresses #527".
- PA-N4 and code-review Info: evidence timestamps follow UTC and two postdate their commit; use local clock time in new evidence.
- Code review Major: add an extension CHANGELOG `[Unreleased]` entry for the consumer-visible coverage behavior change (may be deferred to the release).
- Code review Minor/Nit items: prefix-mismatch exclusion edge case, error messages without offending value, four untested boundary branches, broad `*src*` mock, README run-path and "root-relative" wording.

## Do not do

- Do not modify production PowerShell, tests, or policy documents to address PA-B1; it requires only generating and recording the Python coverage artifact.
- Do not lower thresholds, exclude files from coverage, or narrow `config/poshqc-coverage.json` roots.
- Do not route around the worktree isolation guard to run `pwsh`; the four deferred acceptance criteria remain operator-run.
- Do not check off AC-01, AC-11, AC-12, or AC-13 without the operator-run evidence.
- Write evidence only under `<FEATURE>/evidence/<kind>/`.
