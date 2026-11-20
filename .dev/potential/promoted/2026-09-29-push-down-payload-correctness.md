# push-down-payload-correctness (Issue #770)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/push-down-payload-correctness/ (Issue #770)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub issue template.

- Issue: #770
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/770
- Last Updated: 2026-09-29
## Problem / Why

The Claude push-down is implemented twice: in Python (`scripts/dev_tools/push_down_claude_customizations.py`) and in TypeScript (`extensions/drm-copilot/src/lib/push-down/*`). The payload those two paths deliver is inconsistent, is not self-sufficient in a consumer repository, and ignores state the destination repository already holds:

- The Python path publishes `.claude` only, while the TypeScript path publishes `.claude` and `config` (#507, which also absorbs #764 part 2).
- The `parallel-orchestrate` and `parallel-remove` skills invoke Python CLIs under `scripts/dev_tools/` that the bundle does not ship (#763).
- `config/blast-radius.json` is overwritten on every push, which erases contention surfaces a destination added locally (#508).
- A push reintroduces governance content that a destination deliberately excluded in an earlier sync (#621).

## Proposed Behavior

Deliver the Claude push-down as one epic with four child features, executed in three dependency waves:

- Wave 1: #507 (Python and TypeScript root-folder parity plus a parity test) and #763 (bundle or port the two parallel-skill CLIs, then remove the `KnownUnbundledReference` exceptions in `scripts/dev_tools/skill_bundle_contract.py`).
- Wave 2: #508 (merge the destination's existing blast-radius file instead of overwriting it; builds on #507).
- Wave 3: #621 (a destination-side exclusion manifest the push-down consults before writing; builds on #507 and #508).

The epic manifest and narrative live at `docs/features/epics/push-down-payload-correctness/epic.md`.

## Acceptance Criteria (early draft)

- [ ] Both push-down implementations publish the same root folders, and a parity test fails if they diverge.
- [ ] Every script a pushed-down skill invokes ships in the bundle, and no `KnownUnbundledReference` exception remains for the parallel skills.
- [ ] A destination's local additions to `config/blast-radius.json` survive a push-down.
- [ ] A destination can record paths excluded from push-down, and both implementations honor that record.
- [ ] All four child features merge into `epic/push-down-payload-correctness-integration`, and the integration branch merges into `main`.

## Constraints & Risks

- Issue #769 is being orchestrated in another session; its files (`.claude/hooks/enforce-powershell-batch-budget.ps1` and related tests) are out of scope.
- Pushed-down enforcement hooks must not gain Python legs.
- The Python and TypeScript implementations must stay behaviorally equivalent after each child merges.

## Test Conditions to Consider

- Python/TypeScript parity test over the published root-folder sets and merge-path sets.
- Bundle-contract guard with the parallel-skill exceptions removed.
- Merge tests for a destination blast-radius file carrying local additions.
- Exclusion-manifest tests in both implementations, including the absent-manifest case.
