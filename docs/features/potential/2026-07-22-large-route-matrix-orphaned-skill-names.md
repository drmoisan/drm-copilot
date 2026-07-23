# large-route-matrix-orphaned-skill-names (Potential)

- Date captured: 2026-07-22
- Author: Dan Moisan
- Status: Draft

## Problem / Why

`config/orchestration-routing.json`'s `large` route lists `required_skills` including `"orchestrator-workflow"` and `"repo-automation-adapter"`. Neither name corresponds to any file under `.claude/skills/` (confirmed via directory listing and full-history `git log -S` search — these strings only ever appear inside `config/orchestration-routing.json` itself). The completion-gate validator (`scripts/dev_tools/_orchestrator_state_routing.py::validate_routing_contract`, invoked via `validate_orchestration_artifacts.py orchestrator-state ... --require-complete`) requires a truthful `skill_receipts[]` entry — `{skill, required: true, evidence}` — for every `required_skills` entry before a checkpoint on the `large` route can pass `--require-complete`. Because no skill file exists to read for these two names, no orchestrator can ever produce a truthful receipt for them, so **every** feature routed through `large` is structurally unable to reach a clean `--require-complete` pass. This mirrors the precedent already fixed once for the promotion-tool gap in issue #399 (commit `fbfef347`) — same defect class (routing-matrix entry referencing something that does not resolve), different field.

Discovered while completing issue #396 (cleanup-merged-worktrees skill): the feature itself was fully delivered (PR #400, CI green, zero blocking findings after a 3-cycle remediation loop), but the orchestrator-state checkpoint could not be marked `next_step: "complete"` under `--require-complete` because of this pre-existing, unrelated gap.

## Proposed Behavior

Either:
1. Remove `"orchestrator-workflow"` and `"repo-automation-adapter"` from the `large` route's `required_skills` list in `config/orchestration-routing.json` if they are stale/renamed references with no current equivalent, or
2. Create the corresponding `.claude/skills/orchestrator-workflow/SKILL.md` and `.claude/skills/repo-automation-adapter/SKILL.md` files if they represent real, intended-but-never-authored skill content, and update the routing matrix's config-parity tests accordingly.

Whichever direction is chosen, add or update a static test (mirroring the existing config-parity tests for the model-routing tables) that asserts every `required_skills` entry across every route in `config/orchestration-routing.json` resolves to an actual `.claude/skills/<name>/SKILL.md` file, so this defect class cannot silently reappear for a different route or skill name.

## Acceptance Criteria (early draft)

- [ ] Every `required_skills` entry for every route in `config/orchestration-routing.json` resolves to an existing `.claude/skills/<name>/SKILL.md` file.
- [ ] A new orchestrator-checkpoint validated on the `large` route can reach `next_step: "complete"` under `--require-complete --require-model-routing` without any skill-receipt gap, given a checkpoint that otherwise did the real work.
- [ ] A regression test asserts routing-matrix `required_skills` referential integrity across all routes (small, large, remediation, preparation, epic).

## Constraints & Risks

- Do not silently drop `orchestrator-workflow`/`repo-automation-adapter` without confirming with a repo maintainer whether they represent real, still-desired skill content versus dead references — removing coverage for something that was meant to exist would be worse than the current gap.
- This is a shared, cross-cutting config file; a fix here affects every future `large`-route orchestration run, so it should go through its own properly-scoped feature rather than being folded into an unrelated feature's branch.

## Test Conditions to Consider

- [ ] Unit coverage: a parametrized test over every route in the routing matrix asserting `required_skills` referential integrity against `.claude/skills/`.
- [ ] Integration scenario: a synthetic `large`-route checkpoint with all other completion fields satisfied reaches a clean `--require-complete` pass once this is fixed.
- [ ] CLI/API example: `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <fixture> --require-complete` exits 0.

## Related Finding (same investigation)

Separately, invoking `python scripts/dev_tools/validate_orchestration_artifacts.py ...` as a direct script path (rather than `python -m scripts.dev_tools.validate_orchestration_artifacts ...`) can silently resolve its own `from scripts.dev_tools... import ...` statements against a different, possibly stale, installed copy of the `scripts` package elsewhere on `sys.path`, rather than this worktree's source — because running a script directly puts the script's own directory (not the repo root) at `sys.path[0]`. Observed concretely: the direct-script invocation reported the coarser, pre-existing "Checkpoint required_skills must match routing matrix for route large." message, while `python -m scripts.dev_tools.validate_orchestration_artifacts ...` (repo root correctly on `sys.path[0]`) reported the accurate, granular per-skill missing-receipt messages against current source. Worth a follow-up: document `python -m` as the canonical invocation in agent-facing tooling instructions, or make the direct-script form robust to this (e.g. an explicit `sys.path` bootstrap at the top of the CLI script).

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/large-route-matrix-orphaned-skill-names/` folder from the template

