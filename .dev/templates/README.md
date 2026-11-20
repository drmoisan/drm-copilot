# Feature Folder Templates

Use these templates to keep planning consistent.

- Copy the `feature` folder to `docs/features/active/<feature-name>/`.
- Keep the folder name kebab-case and include the GitHub issue number if known (for example `speakerless-auto-detection-42`).
- Fill in the work-mode-specific requirement docs before coding:
	- `full-feature`: `user-story.md`, `spec.md`, and `plan.md`
	- `full-bug`: `spec.md` and `plan.md`
	- `minor-audit`: `issue.md` and `plan.md` (with `spec.md`/`user-story.md` optional by design), and `issue.md` must contain an explicit `## Acceptance Criteria` section
- When the feature ships, move the folder to `docs/features/archive/<YYYY-MM-DD>-<feature-name>/` to keep a clean working set.
- For refactors (no user-facing change), use `refactor/spec.md` and `refactor/plan.md` to capture intent, invariants, and execution steps.
- For epics/initiatives (tracking multiple child features/workstreams), use `epic/initiative.md` to record goals, decomposition, milestones, and validation across children.
