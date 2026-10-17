# QA Gate: Scope Check (Issue #973)

Timestamp: 2026-10-17T13-57
Command: git diff --name-only MB HEAD; git status --porcelain --untracked-files=all
EXIT_CODE: 0

`MB` is the merge base of `origin/main` and `HEAD` recorded in `FEATURE/evidence/baseline/execution-context.2026-10-17T13-04.md`. `FEATURE` is `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973`.

## Committed changes since MB (`git diff --name-only MB HEAD`)

- `FEATURE/evidence/other/preflight-fixes.2026-10-17T12-53.md`
- `FEATURE/issue.md`
- `FEATURE/plan.2026-10-17T08-16.md`
- `FEATURE/research/research.2026-10-17T12-25.md`
- `FEATURE/spec.md`
- `docs/features/potential/promoted/2026-10-17-ci-docs-only-pr-runs-full-ci.md`

The last entry is the promotion lifecycle record written by the orchestrator's promotion commit before execution began (commit subject `docs(973): add active feature folder for ci-docs-only-pr-runs-full-ci`). It is not a file this plan writes, it is not a production, test, workflow, or configuration file, and it is part of the standard promotion of every item; it is recorded here as a pre-execution orchestrator change, not as executor scope drift.

## Working-tree changes (`git status --porcelain --untracked-files=all`)

Modified:

- `.agents/skills/execution-environment/SKILL.md`
- `.claude/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `.github/workflows/README.md`
- `.github/workflows/ci.yml`
- `config/ci-docs-only-paths.json`
- `FEATURE/plan.2026-10-17T08-16.md`
- `FEATURE/spec.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `scripts/ci/CiChangeScope.psm1`
- `scripts/ci/Invoke-CiChangeScope.ps1`
- `tests/scripts/ci/CiChangeScope.Tests.ps1`
- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`
- `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
- `tests/scripts/workflows/CiWorkflow.Tests.ps1`

Untracked:

- `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`
- 22 evidence files under `FEATURE/evidence/baseline/`, `FEATURE/evidence/other/`, `FEATURE/evidence/qa-gates/`, and `FEATURE/evidence/regression-testing/`

## Checks

- Every working-tree path outside `FEATURE/` is listed in the plan's `## Files Written`: yes (16 of 16: four production, configuration, and workflow files; five test files; seven documentation files).
- `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` is absent from both listings: yes.
- `tools/` is absent (actionlint resolved from PATH); no other untracked entry exists outside `FEATURE/` except the planned new test file.

Output Summary: all executor changes outside `FEATURE/` are in `## Files Written`; `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1` is unchanged; no `tools/` or other stray entry. One committed path outside `FEATURE/` (the promotion lifecycle record under `docs/features/potential/promoted/`) predates execution and belongs to the orchestrator's promotion commit.
