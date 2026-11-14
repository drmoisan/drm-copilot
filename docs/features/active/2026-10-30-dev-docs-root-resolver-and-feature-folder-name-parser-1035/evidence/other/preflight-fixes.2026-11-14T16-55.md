# Preflight Fixes

Timestamp: 2026-11-14T16-55
Plan: docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/plan.2026-10-30T17-11.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan path> (re-run after the fixes)
EXIT_CODE: 0
Output Summary: plan validation passed; three trivial defects fixed in task text; substantive defects are returned to the planner and are not fixed here.

## Fix 1: [P4-T2] stale test paths

- Defect class: stale anchor (path).
- Change: `test_feature_docs.py` and `test_collect_pr_context.py` were written as if they were under `tests/scripts/dev_tools/pr_context/`. Both modules are under `tests/scripts/dev_tools/`. The task now gives each module its full repository-relative path. The assertion is unchanged.

## Fix 2: [P9-T1] residual search could miss files the plan creates

- Defect class: validator-blind (`git grep` does not search untracked files the plan creates).
- Change: the task now states that the search includes untracked files, through a plain recursive search or `git grep --untracked`. The search tokens, roots and allowlist are unchanged.

## Fix 3: [P5-T5] fail-closed behavior not stated in the implementing task

- Defect class: missing behavior statement (spec `### Resolution semantics`, "Hooks surface a resolver error through their existing fail-closed dependency pattern with a clear reason").
- Change: the drift-gate routing clause now states that a failed resolution denies through the hook's existing fail-closed dependency path, with a reason that carries the resolver `Reason`. P5-T8 asserts this behavior. No P5-T8 assertion changed.
