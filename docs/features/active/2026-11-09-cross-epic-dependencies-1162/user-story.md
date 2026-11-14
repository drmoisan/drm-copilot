# `2026-11-09-cross-epic-dependencies` — User Story

- Issue: #1162
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-09T21-50
- Spec: docs/features/active/2026-11-09-cross-epic-dependencies-1162/spec.md

## Story Statement

- As the repository owner running several epics, I want a feature in one epic to declare that it depends on a feature of another epic, so that I can start the dependent epic early without launching features whose prerequisites have not merged.
- As the `epic-orchestrator` agent, I want a deterministic hold-or-release decision computed from `gh` and `git` evidence, so that I never start a held feature and never open an integration-to-main PR ahead of the prerequisite epic.
- As an operator reading `/epic-progress-report`, I want the critical path to include cross-epic prerequisites, so that the predicted finish time reflects waiting on another epic.

## Problem / Why

An epic manifest lists only edges inside the epic and assumes earlier epics have merged. Overlapping epics today would launch features before their prerequisites in the earlier epic are merged, and the dependent epic could reach `main` before the epic it builds on. The progress report would also understate the remaining time because it cannot see the external wait.

## Personas & Scenarios

- Persona: repository owner (coordinator of concurrent epics)
  - Runs several epics through `/epic-run` and expects them to proceed without manual sequencing.
  - Cares that no feature builds on unmerged work and that `main` receives epics in dependency order.
  - Constraint: cannot watch every epic continuously; holds must be bounded and resumable.
  - Goal: overlap epics to shorten total delivery time without adding integration risk.
- Persona: `epic-orchestrator` agent
  - Reads the manifest, schedules waves, launches children, and owns the integration branch.
  - Has `git` and `gh` grants but no `sleep` grant; each Bash call is bounded by the tool timeout.
  - Needs unambiguous decisions and reason codes that can be recorded in the checkpoint and re-derived on resume.
- Persona: operator reading progress reports
  - Uses `/epic-progress-report` to judge when an epic will finish.
  - Needs external waits visible in the critical chain without the report changing for epics that have no cross-epic edges.

- Scenario: early start of a dependent epic
  1. The owner adds `cross_epic_depends_on` to feature 1201 of the consumer epic, naming feature 1188 of the provider epic and the provider's integration branch.
  2. At kickoff, `epic-orchestrator` validates the manifest; a malformed entry stops the kickoff with an `EPIC_CROSS_DEPENDENCY_` code.
  3. Features without cross-epic edges launch as usual. Feature 1201 is evaluated and held with `PREREQ_PR_NOT_FOUND` because 1188 has not merged into the provider integration branch; it receives no worktree.
  4. When every runnable feature is held, the agent waits in bounded CLI calls. When 1188 merges, the decision becomes `merge_required`.
  5. The agent merges the provider integration branch into the consumer integration branch with a direct merge commit, pushes, records the merge, and launches 1201 with an upstream-context line that cites the provider feature's spec, plan, PR, and commits.
  6. If the provider stays unmerged past the wait bound, the run halts with `external_dependency` and resumes on the next `/epic-run` invocation.
- Scenario: holding the integration-to-main PR
  1. All consumer features have merged into the consumer integration branch.
  2. Before opening the integration-to-main PR, the agent runs the main check; the provider's integration-to-main PR has not merged, so the result is `hold` with `MAIN_PREREQ_PR_NOT_MERGED`.
  3. After the provider PR merges, the decision is `release`; the agent syncs `main` into the consumer integration branch, opens the PR, and re-checks immediately before merging.
  4. At completion the checkpoint records `cross_epic_main_gate` as released, which the validator requires.
- Scenario: reading the progress report
  1. The operator runs `/epic-progress-report` on the consumer epic while 1188 is pending.
  2. The critical chain shows the external node for the provider feature ahead of 1201, and the Full report lists the cross-epic edge and its state.
  3. For an epic without cross-epic edges the report is unchanged.

## Acceptance Criteria

- [x] An epic manifest accepts a `cross_epic_depends_on` edge naming another epic's feature and that epic's integration branch; malformed edges are rejected at kickoff with documented `EPIC_CROSS_DEPENDENCY_` codes; the syntax is documented in the epic-orchestrate skills and both epic templates. (Issue AC1)
- [x] A manifest or checkpoint without `cross_epic_depends_on` behaves and validates exactly as before this change, including unchanged wave numbers and an unchanged progress report. (Issue AC1)
- [x] Hold, merge-required, and release decisions for a feature and for the integration-to-main PR come from pure functions covered by unit tests for every row of both decision tables, and the `gh` and `git` checks run only through thin, mocked adapters that fail closed. (Issue AC2)
- [x] A main-sync chore PR into the other integration branch is never accepted as the prerequisite's merged PR, as shown by a dedicated unit test. (Issue AC2)
- [x] A held feature receives no worktree; on release the orchestrator merges the other epic's integration branch into its own with a direct merge commit, pushes, and records it before starting the feature, and the validators flag a feature started while its cross-epic dependency is not integrated. (Issue AC3)
- [x] The epic progress report's critical path includes each cross-epic prerequisite as an external node that delays its dependent while pending and does not consume this epic's parallel cap. (Issue AC4)
- [x] The integration-to-main PR is not opened or merged until the prerequisite epic's integration-to-main PR has merged, and a completed checkpoint for an epic with cross-epic edges fails validation unless the main gate is recorded as released. (Issue AC5)
- [x] The epic-plan, epic-orchestrate, epic-run, and epic-progress-report skills, the epic-planner and epic-orchestrator agents, their Codex variants, bundle copies, and pack manifests are updated, and every mirror and frozen-surface contract test passes. (Issue AC6)

## Non-Goals

- Detecting mutual waiting between epics deeper than one hop; the bounded wait turns it into a resumable halt.
- Enforcing the integration-to-main hold in the merge-gate hooks; the hold is a skill-level control with a validator backstop.
- Adding the prerequisite epic's own integration-to-main time to this epic's predicted finish.
- Scheduling the resume after an `external_dependency` halt automatically.
- A block-style YAML form of the new key, or cross-epic references inside `depends_on`.
