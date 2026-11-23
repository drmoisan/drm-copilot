# docs-epic-scale-routing (Issue #1223)

- Date captured: 2026-11-23
- Author: Dan Moisan
- Status: Promoted -> .dev/active/1223-docs-epic-scale-routing/ (Issue #1223)
- Epic: #1217 (documentation-estate-families), wave 2, complexity C2

- Issue: #1223
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1223
- Last Updated: 2026-11-23
## Problem / Why

The `documentation-workflow` skill assumes one run, one pull request, and docs-only paths. A first full documentation estate, or an estate large enough that one run cannot author and review it in a single pass, has no documented route. The reference estate in `rgf-forecast` (`docs/features/epics/comprehensive-documentation/epic.md`) needed an epic with four dependency waves of documentation families, which the workflow does not describe.

## Proposed Behavior

- `documentation-workflow` states when a documentation run routes through `epic-plan` instead of a single run: a first full estate, or an estate whose planned page count exceeds a stated default page threshold.
- It states a default family-wave decomposition over the family ids of the epic Shared Design (owned by docs-family-profile-model): wave 0 foundation; wave 1 architecture, reference, and product; wave 2 guides, administration, and security; wave 3 operations and service management.
- Each epic child runs the documentation-workflow dispatch order for its families only.
- The docs-complete receipt (family semantics owned by docs-family-gate-and-ia) is written on the integration branch, not on a child branch.
- A Pester contract test reads the skill text for the threshold and the wave order.
- The Codex `.agents` skill, the Copilot surface, and the bundle copies stay in parity per `config/harness-parity-matrix.json`.

## Acceptance Criteria (early draft)

- [ ] The skill states the epic routing condition and a concrete default page threshold.
- [ ] The skill states the four-wave family decomposition in order.
- [ ] The skill states that each child runs the dispatch order for its families and that the docs-complete receipt is written on the integration branch.
- [ ] A parallel Pester contract test pins the threshold and the wave order in every copy.
- [ ] All surface and bundle copies are in parity and the harness generator check passes.

## Constraints & Risks

- No new Python. Skill text only, plus a Pester contract test.
- Must cite the family ids and docs-complete family semantics by their Shared Design names and not re-implement them.
- Generated surfaces must be changed through `scripts/harness-generation/Invoke-HarnessGeneration.ps1`.

## Test Conditions to Consider

- [ ] Contract test over the four copies of the skill
- [ ] Harness generation repo gate
- [ ] Push-down bundle contract tests

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `.dev/active/docs-epic-scale-routing/` folder from the template
