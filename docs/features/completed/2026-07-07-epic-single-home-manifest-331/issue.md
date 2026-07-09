# epic-single-home-manifest (Issue #331)

- Date captured: 2026-07-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-single-home-manifest/ (Issue #331)

- Issue: #331
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/331
- Last Updated: 2026-07-08
- Work Mode: full-feature

## Problem / Why

The canonical folder structure for a multi-feature epic (defined in drm-copilot and pushed down
to consumer repos such as TaskMaster) has two structural defects:

1. **The epic lives in two trees** — `docs/features/epics/<epic-slug>/` (epic-plan.md manifest +
   epic-status.md) and `docs/features/active/<date>-<epic-slug>-<issue>/` (issue.md + initiative.md)
   — with two different naming schemes for the same entity.
2. **Decomposition is triplicated** across `epic-plan.md`, `initiative.md`, and `epic-status.md`,
   producing real drift (changing one feature's `depends_on` required hand-editing all three).
3. The manifest DAG is keyed by `feature_folder` basename, which embeds a date + issue number and
   changes on `active/ → completed/` promotion (the skill carries a brittle-key workaround).

Two core decisions are correct and must be preserved: a machine-readable manifest, and flat,
independently-lifecycled sibling feature folders (each child keeps its own git branch/worktree and
independent `active/ → completed/` lifecycle). This is corroborated by SAFe (Epic→Feature
containment is a logical/backlog relationship, not a filesystem one) and docs-as-code practice
(flat item files + one index).

## Proposed Behavior

Target = "single epic home + flat feature siblings + one manifest":

1. **Single epic home** under `docs/features/epics/<epic-slug>/`:
   - `epic.md` — merges today's epic `issue.md` + `epic-plan.md` manifest + `initiative.md`
     decomposition into ONE file: YAML frontmatter (manifest DAG + optional intent block) followed
     by the narrative. Also the source the epic GitHub issue body is generated from.
   - `epic-status.md` — GENERATED projection of the epic checkpoint only; never hand-authored.
   - Stop creating a separate `active/<date>-<epic-slug>-<issue>/` epic folder; retire
     `initiative.md` as a distinct artifact.
2. **`new_active_feature_folder` MCP tool**: when `type=epic`, scaffold only
   `docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`. Child feature/bug scaffolding is
   unchanged.
3. **Key the manifest DAG by stable `issue_num`** (primary); treat `feature_folder` as a resolvable
   hint that may point into `active/` or `completed/`; remove the path-drift workaround from the
   skill text.
4. **Optional additive SAFe-style intent block** in the manifest frontmatter (not hard-required):
   `epic_type: business | enabler`, `business_outcome_hypothesis`, `leading_indicators[]`, `nfrs[]`.
5. **Keep child feature folders exactly as they are.**

## Acceptance Criteria (early draft)

- [ ] `new_active_feature_folder(type=epic)` scaffolds only
      `docs/features/epics/<epic-slug>/{epic.md, epic-status.md}`; no `active/` epic folder and no
      `initiative.md`.
- [ ] The epic-orchestrate skill documents the single-home layout, `epic.md` as merged source, DAG
      keyed by `issue_num`, generated-only `epic-status.md`, and the optional intent block; the
      active→completed path workaround text is removed.
- [ ] `epic_wave_computation.py` and `validate_epic_orchestrator_state.py` resolve the DAG by
      `issue_num`, accept `feature_folder` in `active/` or `completed/`, validate the intent block
      only when present, and remain byte-identical on legacy manifests (regression tests prove it).
- [ ] New/changed logic has tests; the drm-copilot toolchain (format → lint → type-check → tests)
      passes in order.
- [ ] Push-down tooling updated/run so consumer repos can pick up the change.
- [ ] Change description records the deferred per-consumer migration (incl. TaskMaster epic #260).

## Constraints & Risks

- **Backward compatibility (hard requirement):** validators/wave computation must still accept the
  legacy two-tree layout and folder-basename keys (key-gated / additive changes only). TaskMaster
  epic #260 (store-lockup-resilience) already exists in the old layout. Do NOT break existing
  manifests.
- Migration of existing epics to the new layout is a separate, per-consumer-repo follow-up (out of
  scope here); note it in the change description.
- Bundled mirrors under `.claude`/`.codex`/`.agents`/extension resources are enforced by contract
  tests; every runtime edit needs its mirror synced.
- Prefer additive, key-gated changes over breaking ones. No temporary files in tests; deterministic
  tests only.

## Test Conditions to Consider

- [ ] `new_active_feature_folder(type=epic)` scaffolding: correct files created, no legacy folder.
- [ ] Wave computation and validator: `issue_num` keying, `active/`+`completed/` resolution.
- [ ] Intent-block validation present/absent (byte-identical when absent).
- [ ] Legacy two-tree / folder-basename regression fixtures unchanged.
- [ ] Optional epic-status.md hand-edit guard.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create active feature folder from the template
