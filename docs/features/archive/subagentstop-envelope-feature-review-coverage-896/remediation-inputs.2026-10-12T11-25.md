# Remediation Inputs: subagentstop-envelope-feature-review-coverage (Issue #896)

- Timestamp: 2026-10-12T11-25
- Producer: feature-review agent
- Branch: `bug/subagentstop-envelope-feature-review-coverage-exec-896` (HEAD `f1dc01c3c`)
- Base: `origin/epic/subagentstop-envelope-integration` @ `486e8c06e`
- Review verdict: REMEDIATION_REQUIRED (1 Blocking finding, Remediability `autonomous`)

## Source Audit Artifacts

- policy-audit: `docs/features/active/subagentstop-envelope-feature-review-coverage-896/policy-audit.2026-10-12T11-25.md` (finding PA-1, sections 1.2, 1.2.2, 8)
- code-review: `docs/features/active/subagentstop-envelope-feature-review-coverage-896/code-review.2026-10-12T11-25.md` (no Blocking finding)
- feature-audit: `docs/features/active/subagentstop-envelope-feature-review-coverage-896/feature-audit.2026-10-12T11-25.md` (30 PASS, AC-29 UNVERIFIED pending PR)

## Remediation-Required Findings

### R-1 (PA-1): Python coverage artifact absent for a language with changed files

- Severity: Blocking (FAIL)
- Remediability: autonomous
- Finding: the branch changes one Python file, `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` (test-only; no Python production file changed). `artifacts/python/lcov.info` does not exist in the worktree, and no Python coverage measurement (baseline or post-change) is recorded under `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/`. The coverage rule requires an explicit PASS or FAIL backed by a coverage artifact for every language with changed files.
- Expected result after remediation:
  1. A Python coverage run on the branch head produces `artifacts/python/lcov.info` through the repository configuration (`poetry run pytest --cov`).
  2. An evidence file `docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/qa-gates/python-coverage.<timestamp>.md` records the command, exit code, repo-wide Python line and branch percentages, and the pass/fail counts.
  3. A baseline Python figure is recorded for comparison: either a run on `origin/epic/subagentstop-envelope-integration` production files recorded under `evidence/baseline/python-coverage.<timestamp>.md`, or a statement with `git diff --name-only origin/epic/subagentstop-envelope-integration...HEAD -- '*.py'` output showing that only the test file changed, so the production denominator is unchanged.
  4. Repo-wide Python line coverage is >= 85% and branch coverage is >= 75%; any figure below a threshold is reported as FAIL, not suppressed.
- Verification commands:
  - `poetry run pytest --cov` (full suite; repository coverage configuration writes `artifacts/python/lcov.info`).
  - Parse LF/LH and BRF/BRH totals from `artifacts/python/lcov.info` and record the percentages.
  - `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` (exit 0).
- Files expected to change: evidence files only, under the feature folder's `evidence/`. No production or test code change is required.

## Do Not Do

- Do not change production or test code to address R-1; it is a verification-evidence gap.
- Do not write evidence under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`.
- Do not mark Python coverage `N/A`, "informational only", or "out of scope"; the language has a changed file on the branch.
- Do not edit `.claude/rules/`, `.github/instructions/`, or coverage configuration to exclude paths.
- Do not address the non-blocking code-review items (Minor 2, Nit 2, Info 4) in this cycle unless the orchestrator decides to; they are candidates for follow-up issues.
- Do not check off AC-29 until the PR body is recorded under `evidence/issue-updates/`.

## Notes for the Orchestrator

- Non-blocking follow-up candidates from the code review: mixed re-entry message wording (Claude entry line 191); Codex `Test-LanguageCoverageRow` lacks the corpus narrowing exemptions; `-LiteralPath` in the Codex `CLAUDE.md` read (line 280); `Get-ChangedLanguageSet` reads only the truncated changed-files overview of the PR-context summary.
- Layout note: the review artifacts follow the flat `<stem>.<timestamp>.md` layout requested by the caller and the feature-review agent contract. `.claude/skills/remediation-handoff-atomic-planner/SKILL.md:69-82` describes `audit/<ts>/` and `remediation/<ts>/` folders for remediation cycles; the orchestrator owns the cycle-entry `remediation/<entry-ts>/remediation-inputs.md` if it opens a cycle.
- This review launched no agent and created no remediation plan file, consistent with the operator usage limit propagated in the caller prompt.
