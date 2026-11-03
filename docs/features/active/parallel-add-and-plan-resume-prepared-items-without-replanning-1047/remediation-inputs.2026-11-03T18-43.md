# Remediation Inputs - Issue #1047 (feature review 2026-11-03T18-43)

Review-Verdict: REMEDIATION_REQUIRED

Remediation-Mode: proportionate

- Feature folder: `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047`
- Branch: `feature/parallel-add-and-plan-resume-prepared-items-1047` @ `793096c82`
- Base: `origin/main` @ `01706c697f3ad4a53b4a771d99d851afc7417ea9` (merge base)
- Source artifacts:
  - `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/policy-audit.2026-11-03T18-43.md`
  - `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/code-review.2026-11-03T18-43.md`
  - `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning-1047/feature-audit.2026-11-03T18-43.md`
- Blocking findings: 2 (both autonomous). No code or test change is required; both findings are cleared by producing the canonical coverage artifacts at the branch head in the item worktree.

## Blocking Findings

### R1 - PowerShell coverage artifact absent

- Status: FAIL
- Source: `policy-audit.2026-11-03T18-43.md` section 1.2.1 (PowerShell) and section 1.2 rows "No Coverage Regression" and "New Code Coverage"; `code-review.2026-11-03T18-43.md` Findings Table row 1.
- Finding: `artifacts/pester/powershell-coverage.xml` does not exist in the item worktree. The evidence records `evidence/qa-gates/pester-coverage.2026-11-03T13-52.md` and `evidence/regression-testing/pester-full.2026-11-03T14-20.md` quote per-file figures (100.00%, 100.00%, 96.15%, helpers file 100.00%) from that file, and no evidence file records a repo-wide PowerShell line figure.
- Remediability: autonomous
- Remediability-Evidence: The artifact is produced by a repository-defined test command that runs in this Codespace; the review re-ran the touched Pester suites on Linux at HEAD with 242 of 242 passing, so no external party or owner decision is involved.
- Required action: run the PowerShell suite with coverage at HEAD in `/workspaces/drm-copilot-wt/prepared-admission-1047`, through `mcp__drm-copilot__run_poshqc_test` or `Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -ScanFolders tests/scripts` with the module-default settings `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, so that `artifacts/pester/powershell-coverage.xml` exists and its population (from `config/poshqc-coverage.json`) includes `.claude/lib/parallel-admission/ParallelAdmission.psm1`, `.claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1`, `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1`, and `.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1`.
- Expected result: each of the three new files at or above 85% line coverage, the helpers file at or above its 100.00% baseline, and repo-wide PowerShell line coverage at or above 85%. Record the per-file and repo-wide figures in a new `evidence/qa-gates/pester-coverage.<timestamp>.md`.
- Verification: `ls artifacts/pester/powershell-coverage.xml`; the per-file and repo-wide line-rate values read from that file.

### R2 - Python coverage artifact absent

- Status: FAIL
- Source: `policy-audit.2026-11-03T18-43.md` section 1.2.1 (Python) and section 4A.1 "Coverage expectation"; `code-review.2026-11-03T18-43.md` Findings Table row 2.
- Finding: `artifacts/python/lcov.info` does not exist in the item worktree. The project addopts set `--cov-report=lcov:artifacts/python/lcov.info` without `--cov`, so the recorded `poetry run pytest -n auto -q -p no:cacheprovider` run (`evidence/regression-testing/pytest-strict-markers-nauto.2026-11-03T18-42.md`) measured no coverage.
- Remediability: autonomous
- Remediability-Evidence: The artifact is produced by `poetry run pytest --cov -n auto` in this Codespace; the same suite already completed with 16063 passed and 6 skipped at a86154da3, so the run is expected to complete without external input.
- Required action: run `poetry run pytest --cov -n auto -q -p no:cacheprovider` at HEAD in `/workspaces/drm-copilot-wt/prepared-admission-1047` so that `artifacts/python/lcov.info` exists. The only changed Python file is a test-support module under `tests/`, which `[tool.coverage.run] omit` excludes; the figures required are the repo-wide Python line and branch percentages.
- Expected result: repo-wide Python line coverage at or above 85% and branch coverage at or above 75%. Record both figures in a new `evidence/qa-gates/python-coverage.<timestamp>.md`.
- Verification: `ls artifacts/python/lcov.info`; LF and LH (lines) and BRF and BRH (branches) totals summed from that file.

## Do Not Do

- Do not edit production code, tests, skills, rules, agents, settings, or bundle copies for these findings; they concern artifacts only.
- Do not commit anything under `artifacts/` (gitignored), and do not write evidence outside `<FEATURE>/evidence/<kind>/`.
- Do not change coverage configuration, thresholds, `config/poshqc-coverage.json`, or `pyproject.toml`.
- Do not rewrite earlier evidence records; add new timestamped files.
- Do not uncheck or edit acceptance-criteria text in `spec.md` or `user-story.md`.

## Non-Blocking Items (for information; not remediation triggers)

- Spec criterion "Precedence rejection and barrier" stays unchecked pending the CI job `poshqc / PowerShell hook suites (Linux)`; the item orchestrator checks it off at S9.
- Three Minor code-review findings (unexposed `Get-ParallelAdmissionRecordedEdge`, header wording about `git fetch`, discarded git stderr) may be addressed in this item at the orchestrator's discretion; none blocks the PR.
