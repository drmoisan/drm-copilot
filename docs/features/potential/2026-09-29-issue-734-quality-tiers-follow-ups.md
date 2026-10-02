# Potential: follow-ups surfaced by issue #734

- Date captured: 2026-09-29
- Author: atomic-executor (issue #734, `quality-tiers-yml-missing-and-unenforced`)
- Source: the "Rollout & Follow-up" section of `docs/features/active/2026-09-27-quality-tiers-yml-missing-and-unenforced-734/spec.md`, together with the out-of-scope items in its "Scope & Non-Goals" section.
- Status: Draft. Not promoted. Each entry below can be promoted on its own.

---

## FU-734-1: Broken `.agents/skills/quality-tiers.md` citation (potential bug)

Three lines cite `.agents/skills/quality-tiers.md`, which does not exist:

- `.agents/skills/general-code-change/SKILL.md` line 32
- `.agents/skills/general-unit-test/SKILL.md` lines 29 and 92

The bundled copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/` carry the same lines. The correct target is `.agents/skills/quality-tiers/SKILL.md`. #734 left these lines unchanged because the operator limited the #511 scope to the `docs/ci.research.md` citation. Correct the repository copies and the bundled copies in the same commit so that the bundled-payload parity tests continue to pass.

## FU-734-2: Deferred T1/T2 elevation candidates (decision)

#734 assigned only T3 and T4. The following projects are candidates for elevation:

- `.claude/lib/cleanup-manifest` and `.claude/lib/worktree-resolution` (T1 candidates). Removing a worktree can lose uncommitted work, which fits the T1 harm model.
- The `extensions/drm-copilot` push-down (T2 candidate). It writes into consumer workspaces.

Elevation adds property-test density and mutation-score obligations under the `.claude/rules/quality-tiers.md` gate matrix. The repository has no approved property-test or mutation tooling, so any elevation must be decided together with that tooling decision.

## FU-734-3: The github-actions instructions describe a CI `actionlint` job that does not exist (candidate)

`.github/instructions/github-actions.instructions.md` (line 15) states that CI runs an `actionlint` job in `.github/workflows/ci.yml`. No such job exists. Either add the job or correct the instruction.

## FU-734-4: The pushed-down rule's CI-enforcement statement in consumer workspaces (candidate)

The pushed-down copy of `.claude/rules/quality-tiers.md` tells consumer workspaces that adding an unclassified project fails CI. Those workspaces receive neither `quality-tiers.yml` nor `scripts/dev_tools/check_quality_tiers.py`, so the statement does not hold there. #734 left this wording unchanged because of its citation-only constraint.

---

## Suggested promotion grouping

- **Promote first:** FU-734-1. It is a broken citation in shipped skill files.
- **Promote together:** FU-734-3 and FU-734-4. Both are policy text that describes enforcement which does not exist.
- **Decision required before promotion:** FU-734-2.
