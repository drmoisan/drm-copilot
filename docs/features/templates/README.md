# Feature Folder Templates

Use these templates to keep planning consistent.

- Copy the `feature` folder to `docs/features/active/<feature-name>/`.
- Keep the folder name kebab-case and include the GitHub issue number if known (for example `speakerless-auto-detection-42`).
- Fill in `user-story.md`, `spec.md`, and `plan.md` before coding.
- When the feature ships, move the folder to `docs/features/archive/<YYYY-MM-DD>-<feature-name>/` to keep a clean working set.
- For refactors (no user-facing change), use `refactor/spec.md` and `refactor/plan.md` to capture intent, invariants, and execution steps.
- For epics/initiatives (tracking multiple child features/workstreams), use `epic/initiative.md` to record goals, decomposition, milestones, and validation across children.


- Decision tree paths:
  - `minor-audit`: use for bootstrapped/pre-cooked work or <=3 production files with low integration risk.
  - `feature`: use for standard user-facing feature development requiring full docs.
  - `refactor`: use for non-user-facing structural/code-quality work.

Minor-audit does not require broad regression or extended design docs by default; add them only when risk warrants.

Marker-driven branch criteria (deterministic):
- Persist work mode in `issue.md` using exactly one marker line directly above the first `##` heading:
  - `- Work Mode: minor-audit`
  - `- Work Mode: full`
- Review/audit automation must branch from this persisted marker (not inferred intent):
  - `minor-audit` => `issue.md` is the acceptance-criteria source of truth.
  - `full` => `spec.md` and `user-story.md` are required acceptance-criteria sources.
- If marker is missing or malformed, fail closed to `full` behavior.

Minor-audit artifact expectations:
- Required: `issue.md` with persisted work-mode marker.
- Optional by design: `spec.md` and `user-story.md` may be absent when marker is `minor-audit`.
