# Remediation Inputs — Issue 1165

Timestamp: 2026-11-10T01-15
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: light
Source review artifacts:
- `docs/features/active/cd-chained-command-recurring-deny-1165/policy-audit.2026-11-10T01-15.md`
- `docs/features/active/cd-chained-command-recurring-deny-1165/code-review.2026-11-10T01-15.md`
- `docs/features/active/cd-chained-command-recurring-deny-1165/feature-audit.2026-11-10T01-15.md`
Head reviewed: `eaf42f48d8792c7099ef5c411025d43413f0dca2` (merge base `ff9d8afc0a61ac723cd449b0c0658ea42680cd2e`)
Prior cycle: none (first review).

## Findings requiring remediation

### PA-1 — Python coverage artifact absent for a branch with changed Python test files

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The artifact is produced by one local pytest coverage run in the item worktree; no external party, owner decision, or CI result is needed, and no source file changes.
Finding-Scope: contained

- Files: `artifacts/python/lcov.info` (item worktree, gitignored); new append-only record `docs/features/active/cd-chained-command-recurring-deny-1165/evidence/qa-gates/pytest-coverage.<timestamp>.md`.
- Problem: the branch modifies `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` and adds `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py`. The review contract requires a coverage artifact for every language with changed files; `artifacts/python/lcov.info` does not exist in the item worktree, and `evidence/qa-gates/pytest-gate.2026-11-10T00-56.md` records a run without `--cov`.
- Required change: from the item worktree root run one `env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch` over the repository test tree so that `artifacts/python/lcov.info` is written; record the command, `EXIT_CODE`, pass and fail counts, and the repo-wide line and branch percentages in the new evidence file. Do not edit any source, test, or spec file.
- Verification required: `artifacts/python/lcov.info` exists with a write time after this review; repo-wide line coverage at or above 85% and branch coverage at or above 75%; 0 test failures.

### PA-2 — PowerShell coverage artifact predates the head commit

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: One local parallel Pester coverage run in the item worktree rewrites the artifact after the commit; no external party, owner decision, or CI result is needed, and no source file changes.
Finding-Scope: contained

- Files: `artifacts/pester/powershell-coverage.xml` (item worktree, gitignored); new append-only record `docs/features/active/cd-chained-command-recurring-deny-1165/evidence/qa-gates/pester-coverage.<timestamp>.md`.
- Problem: the Stop hook `validate-feature-review-coverage` rejects the artifact as stale. It was written at 2026-11-10T00:52:23Z, before the only commit touching PowerShell files (2026-11-10T01:07:06Z). The reviewer confirmed that every changed `.ps1` file was last modified before the coverage write, so the figures are correct. The gate still blocks the review and any re-review until the artifact is newer than the commit.
- Required change: from the item worktree root, run one `Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>`. Record the exit code, test counts, the repo-wide line figure, and the per-file figures for `.claude/hooks/bash-command-shape-guidance.ps1` and `.claude/hooks/validate-bash.ps1` in the new evidence file. Do not edit any source, test, or spec file.
- Verification required: the artifact's write time is after 2026-11-10T01:07:06Z, ExitCode 0, repo-wide line coverage at or above 85%, the helper at or above 85%, and no changed-line regression in `validate-bash.ps1`.

## Light Fix Tasks

- [ ] [P0-T1] `artifacts/python/lcov.info` and `evidence/qa-gates/pytest-coverage.<timestamp>.md` (PA-1): run one `env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch` in the item worktree, and record the command, exit code, counts, and repo-wide line and branch figures append-only under `evidence/qa-gates/`.
- [ ] [P0-T2] `artifacts/pester/powershell-coverage.xml` and `evidence/qa-gates/pester-coverage.<timestamp>.md` (PA-2): run one `Invoke-PoshQCParallelTest -Root <item worktree root>` in the item worktree, and record the exit code, counts, and repo-wide and per-file line figures append-only under `evidence/qa-gates/`.

## Non-remediation items (record only)

- CR-Minor: `Get-CdChainedCommandIntent` does not detect a tool behind `sudo` or invoked by absolute path; such commands get the plain-read guidance. Decision unaffected.
- CR-Info: the Codex surface is an on-demand skill; Codex has no cd-chained deny.
- CR-Info: `reset --keep` keeps uncommitted changes where `--hard` discarded them; no impact expected after a failed check.
- CR-Info: `bash -c "cd /x && git log ... head"` is allowed at base and head; decision changes are a non-goal.
- CI on the PR head is pending-CI and owned by the orchestrator at S9; no PR exists yet. It is not a finding.

## Constraints

- Tests run in parallel only: one `pytest -n auto` run and one `Invoke-PoshQCParallelTest` run.
- Evidence is append-only; do not edit or delete existing evidence files.
- Edit no source, test, or spec file.
- Any commit makes this review stale, so a re-review follows.
