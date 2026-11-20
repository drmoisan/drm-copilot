# github-promotion-lifecycle-issue-adoption-path (Potential)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Draft
- Origin: follow-up recorded by issue #509 (epic #771, orchestrator-state-contract-correctness)

## Problem / Why

Issue #509 added an `issue_adoption` checkpoint object that lets the completion gate accept recorded evidence of a pre-existing GitHub issue in place of a `potential_to_issue` receipt, and documented it in the Claude and Codex/agents surfaces. The Copilot-native surface was deferred by #509: `.github/skills/feature-promotion-lifecycle/SKILL.md` and its bundled copy under `extensions/drm-copilot/resources/customizations/` still describe only the promote-a-potential-entry path.

## Proposed Behavior

Add the pre-existing-issue (`issue_adoption`) path to the Copilot-surface feature-promotion-lifecycle skill and its bundled copy, matching the wording and contract in `.claude/skills/feature-promotion-lifecycle/SKILL.md` and `.claude/rules/orchestrator-state.md`.

## Acceptance Criteria (early draft)

- [ ] `.github/skills/feature-promotion-lifecycle/SKILL.md` documents the `issue_adoption` object, its required fields, and the waivable tools.
- [ ] The bundled copy under `extensions/drm-copilot/resources/customizations/` is byte-identical to the source.

## Constraints & Risks

Documentation-only; must stay consistent with the three runtime validators introduced by #509.

## Test Conditions to Consider

- [ ] Bundle parity test covers the edited file.

## Next Step

- [ ] Promote to GitHub issue
