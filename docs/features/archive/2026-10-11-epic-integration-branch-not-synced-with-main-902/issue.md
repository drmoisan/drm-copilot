# 2026-10-11-epic-integration-branch-not-synced-with-main

- Work Mode: minor-audit
- Issue: #902
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/902
- Promotion type: bug
- Lifecycle record: `docs/features/potential/promoted/2026-10-11-epic-integration-branch-not-synced-with-main.md` on ref `origin/docs/followups-2026-10-11` (not on this branch; cited by ref)

## Problem / Why

The epic-orchestrate skill branches the epic integration branch from `origin/main` once and never merges `origin/main` back in while child waves run. `.claude/skills/epic-orchestrate/SKILL.md` section "Epic Integration Branch Lifecycle" (step 1 branches from `origin/main`; step 2 fetches only `origin epic/<epic-slug>-integration` before each wave; step 5 opens the final integration PR) contains no main-sync step.

During epic #852 the integration branch fell 278 commits behind `origin/main` between 2026-10-09 and 2026-10-11. The coordinator's direct merge attempt was denied by `PREIMPLEMENTATION_GATE_BLOCKED`, and an extra planned wave (`epic-852-main-sync`, PR #882) was required to merge main before the integration PR. A stale integration base increases conflict risk and causes child CI runs to test against an old main.

## Implementation Intent

Operator decision (A), recorded by the parallel planner for run `bug-burndown-2026-10-11`:

- Add a step to the "Epic Integration Branch Lifecycle" section of the epic-orchestrate skill that, before each wave, checks whether `origin/main` has commits the integration branch lacks (`git rev-list --count <integration>..origin/main`).
- When the count is non-zero, the main-sync runs as a dedicated chore child item before the wave launches, following the PR #882 `epic-852-main-sync` pattern: a child branch created from the integration branch merges `origin/main` and opens a PR into the integration branch.
- No hook change.
- Keep the edit inside the integration-branch lifecycle section (a concurrent item, #900, may edit other orchestration skill text).
- Update every surface that must stay at parity with `.claude/skills/epic-orchestrate/SKILL.md`: the bundled mirror, the epic-orchestrator persona where it restates the lifecycle, and any Codex counterpart (for example `.agents/skills/epic-orchestrate/SKILL.md`) that the research identifies.
- Add contract tests that pin the new step.

## Acceptance Criteria

- [x] AC-1: `.claude/skills/epic-orchestrate/SKILL.md` "Epic Integration Branch Lifecycle" contains a pre-wave main-sync step that runs `git rev-list --count <integration>..origin/main` after fetching `origin/main` and before each wave launches.
- [x] AC-2: The new step states that a non-zero count causes the main-sync to run as a dedicated chore child item (a child branch created from the integration branch that merges `origin/main` and opens a PR into the integration branch, per the `epic-852-main-sync` / PR #882 pattern) that must merge before the wave launches, and that a zero count proceeds directly to the wave.
- [x] AC-3: Every parity surface the research identifies (bundled mirror, epic-orchestrator persona where it restates the lifecycle, Codex counterpart skill) carries the same step, and the existing parity or bundle-sync checks for those surfaces pass.
- [x] AC-4: New contract tests pin the presence of the pre-wave main-sync step (the `rev-list --count` check and the chore-child route) in the canonical skill and in each parity surface, and fail when the step is removed.
- [x] AC-5: No hook file under `.claude/hooks/` or `.codex/hooks/` and no policy document under `.claude/rules/` or `.github/instructions/` is modified.
- [x] AC-6: The final QC loop for every language touched by the change (formatter, linter, type checker where applicable, tests with coverage) passes, with evidence recorded under the feature folder's `evidence/` tree.

## Dependencies / Risks

- Parity surfaces: the bundled extension copy and the Codex `.agents/` copy may be governed by byte-parity or sync tests; the research must identify the authoritative sync route so the plan does not hand-edit a generated copy.
- Concurrent item #900 may edit other orchestration skill text; the edit must stay inside the integration-branch lifecycle section to avoid merge conflicts.
- PowerShell and bats verification is restricted to PoshQC MCP tools plus CI evidence (operator constraint).

## Verification Steps

- Run the new contract tests and the existing parity tests for the edited surfaces.
- Run the toolchain loop for each touched language with coverage.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
