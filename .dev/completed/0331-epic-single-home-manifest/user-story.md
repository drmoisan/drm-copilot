# `epic-single-home-manifest` — User Story

- Issue: #331
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/331
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-08
- Work Mode: full-feature

## Story Statement

- As an epic-orchestrate agent, I want a single epic home (`epics/<epic-slug>/epic.md` plus a
  generated `epic-status.md`) with the decomposition stored once, so that I do not have to keep three
  copies of the DAG in sync and cannot introduce drift between them.
- As an epic maintainer, I want the manifest DAG keyed by stable `issue_num` with `feature_folder` as
  a resolvable hint, so that dependency references do not break when a child feature is promoted from
  `active/` to `completed/`.
- As a consumer-repo maintainer (for example TaskMaster), I want the change delivered additively and
  key-gated and then pushed down, so that my existing epic #260 in the legacy layout keeps validating
  unchanged while I can adopt the new layout on my own schedule.
- As an epic author, I want an optional SAFe-style intent block in the manifest frontmatter, so that
  epic intent (type, outcome hypothesis, leading indicators, NFRs) is machine-checkable rather than
  only prose, without being forced to fill it in.

## Problem / Why

The canonical folder structure for a multi-feature epic (defined in drm-copilot and pushed down to
consumer repos such as TaskMaster) has three structural defects, all confirmed against epic #260
(store-lockup-resilience):

1. **The epic lives in two trees** — `docs/features/epics/<epic-slug>/` (`epic-plan.md` manifest +
   `epic-status.md`) and `docs/features/active/<date>-<epic-slug>-<issue>/` (`issue.md` +
   `initiative.md`) — with two different naming schemes for the same entity.
2. **Decomposition is triplicated** across `epic-plan.md`, `initiative.md`, and `epic-status.md`,
   producing real drift (changing one feature's `depends_on` required hand-editing all three).
3. The manifest DAG is keyed by `feature_folder` basename, which embeds a date + issue number and
   changes on `active/ → completed/` promotion (the skill carries a brittle-key workaround).

Two core decisions are correct and must be preserved: a machine-readable manifest, and flat,
independently-lifecycled sibling feature folders (each child keeps its own git branch/worktree and
independent `active/ → completed/` lifecycle). This is corroborated by SAFe (Epic→Feature containment
is a logical/backlog relationship, not a filesystem one) and docs-as-code practice (flat item files +
one index).

## Personas & Scenarios

- **Persona: epic-orchestrate agent.**
  - Who: the automated agent that plans and drives a multi-feature epic through waves.
  - Cares about: a single machine-readable source of truth for the DAG; deterministic wave
    computation; stable dependency keys that survive folder promotion.
  - Constraints: must not break legacy manifests; edits to runtime skill files must be mirrored.
  - Goals/frustrations: today it maintains the decomposition in three places and carries a
    path-drift workaround; it wants one source and stable keys.

- **Scenario: scaffolding a new epic.**
  - Who acts: an operator (or agent) invoking `new_active_feature_folder(type=epic)`.
  - Trigger: a new epic is being started.
  - Steps: invoke the tool with `type=epic` and an epic name; the tool creates
    `docs/features/epics/<epic-slug>/epic.md` and `.../epic-status.md`.
  - Obstacle/decision: the tool must not create the legacy `active/<date>-<epic>-<issue>/` folder or
    `initiative.md`.
  - Expected outcome: exactly the single epic home is created; `epic.md` is the file to edit;
    `epic-status.md` is a generated-only placeholder.

- **Scenario: a child feature is promoted to completed during epic execution.**
  - Who acts: the epic-orchestrate agent resolving dependencies for the next wave.
  - Trigger: a child feature folder moves from `active/` to `completed/`.
  - Steps: the agent resolves each `depends_on` entry by `issue_num` against the union index and
    resolves the concrete path (active or completed) from the checkpoint at emit time.
  - Obstacle/decision: previously the folder-basename key broke on promotion; the skill carried a
    workaround.
  - Expected outcome: dependency resolution is stable; no path-drift workaround is needed; the
    validator accepts the `feature_folder` hint in either `active/` or `completed/`.

## Acceptance Criteria

Carried forward verbatim from `issue.md` (the six canonical acceptance criteria).

- [x] `new_active_feature_folder(type=epic)` scaffolds only `docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`; no `active/` epic folder and no `initiative.md`.
- [x] The epic-orchestrate skill documents the single-home layout, `epic.md` as merged source, DAG keyed by `issue_num`, generated-only `epic-status.md`, and the optional intent block; the active→completed path workaround text is removed.
- [x] `epic_wave_computation.py` and `validate_epic_orchestrator_state.py` resolve the DAG by `issue_num`, accept `feature_folder` in `active/` or `completed/`, validate the intent block only when present, and remain byte-identical on legacy manifests (regression tests prove it).
- [x] New/changed logic has tests; the drm-copilot toolchain (format → lint → type-check → tests) passes in order.
- [x] Push-down tooling updated/run so consumer repos can pick up the change.
- [x] Change description records the deferred per-consumer migration (incl. TaskMaster epic #260).

## Non-Goals

- Migrating existing epics (especially TaskMaster epic #260, store-lockup-resilience) to the new
  layout. That is a deferred, per-consumer-repo follow-up; the legacy layout remains valid.
- The optional epic-status hand-edit guard (requires a net-new deterministic projector and a
  PreToolUse hook; not among the acceptance criteria). Deferred.
- Any change to child feature/bug scaffolding, child folder layout, or the child lifecycle.
