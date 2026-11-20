Timestamp: 2026-11-14T08-52
Plan: docs/features/active/2026-11-14-prettier-format-check-fails-on-docs-fixtures-1179/plan.2026-11-14T03-36.md

1. P0-T1 | missing precondition | The worktree has no node_modules, so the root format:check cannot run. Added a one-time `npm --prefix <abs worktree> ci` precondition to the task text. No assertion changes.
2. P0-T4 | missing precondition | A fresh worktree has an empty .venv. Added the `env -u VIRTUAL_ENV poetry -C <abs worktree> install` precondition and the run form to the task text. No assertion changes.
