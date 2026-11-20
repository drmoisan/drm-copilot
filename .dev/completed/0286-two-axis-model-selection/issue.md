# two-axis-model-selection (Issue #286)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/two-axis-model-selection/ (Issue #286)

- Issue: #286
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/286
- Last Updated: 2026-07-03
- Work Mode: full-feature

## Problem / Why

The orchestration runtime selects a workflow `route` (small, large, remediation, epic) deterministically by file count. File count is a size measure, not a complexity measure: a one-file classifier-logic change can be harder than a fifteen-file rename. The runtime currently has no mechanism to select the delegation model tier as a function of judged task complexity, so model tier is either fixed by frontmatter pins or coupled implicitly to size. In addition, two low-complexity skill invocations (`commit-message` and `human-exception-runbook`) currently run inline on the orchestrator's model, which is more capable and costly than those situational tasks require.

## Proposed Behavior

Introduce a two-axis model-selection mechanism that keeps `route` (workflow governance) strictly separate from a new judgment-based `complexity_band` (model-tier governance):

1. Add a `model_policy` block to `config/orchestration-routing.json` (a `complexity` sub-block with scale text, a signal catalog with `[floor]` flags, and anchors; a `tier_order`; a `complexity_to_model` table; and a `preferred_overlay`), plus a session `model_budget.fable_policy` kickoff switch (three-way enum, default `disabled`). Provide two canonical, tested Python reference implementations (`compute_complexity_floor`, `resolve_delegation_model`), extend the checkpoint with `complexity_assessments[]` and `model_routing_receipts[]`, add validators wired into `validate_orchestration_artifacts`, and document the mechanism in the `orchestrate` and `epic-orchestrate` skills.
2. Add a read-only `commit-message` agent (`model: haiku`) and route the two commit-message invocations through it.
3. Add a `human-exception-runbook` agent (`model: sonnet`) and route the exception-path runbook emission through it.

## Acceptance Criteria (early draft)

- [x] `route` is not a model-selection input anywhere; `complexity_band` is the sole feature-level input to model tier.
- [x] Both reference implementations are deterministic given identical inputs; the assessed band is always `>= floor`, and C4 is never floor-forced.
- [x] The resolved model equals the `complexity_to_model` table lookup for the active band under the active `fable_policy`; in `disabled` mode no receipt's model is `fable` and any fable cell records a clamp to `opus`; in `preferred` mode the reasoning nodes' C3 resolves to `fable` while `atomic-executor`/`pr-author` are unchanged.
- [x] Validators pass on well-formed receipts and fail closed on band/floor/rationale/enum/budget violations with literal, checkpoint-context messages; routes and checkpoints lacking the new fields validate unchanged.
- [x] `commit-message` and `human-exception-runbook` agents are present, valid, and authorized in the orchestrator allowlist; the two commit steps delegate message text while the commit stays on the orchestrator; runbook authoring is delegated while the orchestrator still records `runbook_path`.
- [x] All new fields are additive and optional; existing routes and checkpoints validate unchanged.
- [x] Bundle sync is complete; pytest and Pester are green.

## Constraints & Risks

- All new fields must be additive and optional; existing routes and checkpoints must validate unchanged. Validators fail closed only on present-but-malformed data.
- Determinism boundary: floors and the table lookup are code; the band assessment is judgment; validators police shape, floors, and budget, never the band's merit.
- Bundle sync is mandatory: repo-root `.claude/` is the source of truth and bundled mirrors must be updated in lockstep.
- Tone policy (CLAUDE.md, `.claude/rules/tonality.md`) applies to all authored text.
- Touches JSON, Markdown, Python (reference impls/validators/tests), and PowerShell (bundle-sync contract tests).

## Test Conditions to Consider

- [x] Unit coverage for `compute_complexity_floor` (each floor guard contributes C3; floor is max triggered band; floors never exceed C3) and `resolve_delegation_model` (base table, preferred overlay, disabled clamp).
- [x] Validator tests: complexity assessment (band enum, band >= floor, floor == compute, non-empty rationale) and model-routing (model == resolve; disabled clamp records `clamped_from: fable`, `model: opus`).
- [x] Backward-compatibility: routes and checkpoints without the new fields validate unchanged.
- [x] Bundle-sync Pester contract tests for the two new agent files and the edited skills.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/two-axis-model-selection/` folder from the template
