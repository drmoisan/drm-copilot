# Green Workflow-Dispatch Runs — Issue #393

- Date (UTC): 2026-07-21T23:35
- Purpose: Satisfy the `modified-workflow-needs-green-run` policy rule and verify the native
  bash toolchain (bats + kcov) on the CI runner class (`ubuntu-latest`) before feature review.
- Trigger: `workflow_dispatch` against the branch head (a green `workflow_dispatch` run against
  the branch head satisfies the rule per `.claude/skills/feature-review-workflow/SKILL.md`).

## Branch head

- Branch: `drm-copilot-wt-2026-07-21T17-20`
- Head SHA: `145dae538d732a908d6e1e0e8eb3d5a053e8a7d5`

## Runs (both conclusion = success, headSha matches branch head)

| Workflow | Modified path | Run | Conclusion |
|---|---|---|---|
| Shell Coverage (reusable) | `.github/workflows/_shell-coverage.yml` | https://github.com/drmoisan/drm-copilot/actions/runs/29877012724 | success |
| Build Check (reusable) | `.github/workflows/_build-check.yml` | https://github.com/drmoisan/drm-copilot/actions/runs/29877013754 | success |

## Verified by these runs

- **AC3 / AC8**: 44 bats tests passed, 0 failures (existing suites plus the two new suites
  `test_shell_qc_discovery.bats` and `test_shell_qc_commands.bats`), executed by
  `bash scripts/bash/shell-qc.sh test --coverage`.
- **AC2**: `_shell-coverage.yml` ran bats under kcov and its `actions/upload-artifact` step
  (`if-no-files-found: error`) succeeded, confirming `cov.xml` was emitted under
  `artifacts/pester/kcov`.
- **AC6**: `_shell-coverage.yml` and `_build-check.yml` executed the native bash wrapper with
  no Poetry install and no `poetry run`; both concluded success.
- **AC9**: Green CI runs exist against the current branch head for both modified workflows.
- The kcov build-from-source step was `skipped` (cache hit `kcov-v43-ubuntu-latest`); all other
  steps concluded success.

## Note

These `workflow_dispatch` runs verify the reusable workflows standalone. The S9 CI green gate
re-verifies the required checks in PR context against the live PR head SHA after PR creation.
