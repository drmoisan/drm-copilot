# 2026-06-24-harden-orchestrate-skill-232 - Atomic Plan

- **Issue:** #232
- **Feature folder:** `docs/features/active/2026-06-24-harden-orchestrate-skill-232`
- **Plan path:** `docs/features/active/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md`
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T15-45
- **Status:** Draft
- **Version:** 0.2

## Planning Scope

This plan hardens orchestration instruction text for Issue #232. It covers:

- `.agents/skills/orchestrate/SKILL.md`
- `.agents/skills/feature-promotion-lifecycle/SKILL.md`
- `.agents/skills/repo-automation-adapter/SKILL.md`
- `.agents/skills/orchestrator-workflow/SKILL.md`
- active Issue #232 requirement files under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/`

No runtime MCP API, source-code, or test-code change is planned. If execution identifies a required non-Markdown source or test change, stop and request a revised plan before editing that file.

## Required Inputs

- `AGENTS.md`
- `.agents/skills/atomic-plan-contract/SKILL.md`
- `.agents/skills/orchestrator-workflow/SKILL.md`
- `.agents/skills/policy-compliance-order/SKILL.md`
- `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/issue.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/research/20260624-harden-orchestrate-skill-232-research.md`
- `config/orchestration-routing.json`

## Evidence Rules

All execution evidence for this plan must be written under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/<kind>/`.

Each baseline and QA command artifact must include:

- `Timestamp:`
- `Command:`
- `EXIT_CODE:`
- `Output Summary:`

Coverage evidence is not required for this plan because the planned edits are Markdown instruction files only. If execution changes production or test code in any programming language, coverage-bearing baseline and final-QA tasks must be added before implementation continues.

## Preflight Handoff Contract

Before execution, this plan must be handed to `atomic-executor` with the exact directive:

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

The target plan path must remain `docs/features/active/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md` for every revision. Do not create sibling `plan.*.md` files.

### Phase 0 — Policy, Context, and Baseline Evidence

- [x] [P0-T1] Read `AGENTS.md`, `.agents/skills/policy-compliance-order/SKILL.md`, `.agents/skills/atomic-plan-contract/SKILL.md`, `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`, and `.agents/skills/orchestrator-workflow/SKILL.md`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/phase0-instructions-read.md`.
  - Acceptance: The artifact contains `Timestamp:`, `Policy Order:`, and an explicit list of every file read in this task.

- [x] [P0-T2] Read `docs/features/active/2026-06-24-harden-orchestrate-skill-232/issue.md`, `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md`, `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`, and `docs/features/active/2026-06-24-harden-orchestrate-skill-232/research/20260624-harden-orchestrate-skill-232-research.md`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/phase0-requirements-read.md`.
  - Acceptance: The artifact states that Issue #232 is the canonical issue number and summarizes the acceptance criteria source files read.

- [x] [P0-T3] Capture the pre-change git state for `.agents/skills/orchestrate/SKILL.md`, `.agents/skills/feature-promotion-lifecycle/SKILL.md`, `.agents/skills/repo-automation-adapter/SKILL.md`, `.agents/skills/orchestrator-workflow/SKILL.md`, and `docs/features/active/2026-06-24-harden-orchestrate-skill-232/` by running `git status --short --branch -- .agents/skills/orchestrate/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md docs/features/active/2026-06-24-harden-orchestrate-skill-232`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-git-status.md`.
  - Acceptance: The artifact records the exact command, exit code, and output summary for the scoped worktree state.

- [x] [P0-T4] Capture baseline review-delegate naming references by running `rg -n "feature-review" .agents/skills/orchestrate/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md config/orchestration-routing.json`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-review-delegate-naming.md`.
  - Acceptance: The artifact records all current `feature-review` and `feature-reviewer` references needed to prove post-change alignment for Issue #232.

- [x] [P0-T5] Capture baseline lifecycle ordering references by running `rg -n "potential entry|potential_to_issue|issue promotion|branch|new_active_feature_folder|issue-num" .agents/skills/orchestrate/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-lifecycle-order.md`.
  - Acceptance: The artifact records the current branch and lifecycle sequencing text before edits.

- [x] [P0-T6] Capture baseline route-matrix alignment by running `rg -n "\"feature-reviewer\"|\"required_agents\"|\"required_mcp_tools\"" config/orchestration-routing.json`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-route-matrix.md`.
  - Acceptance: The artifact records that `config/orchestration-routing.json` requires `feature-reviewer` for route receipts.

### Phase 1 — Harden `orchestrate` Entry and Implementation Gates

- [x] [P1-T1] Update `.agents/skills/orchestrate/SKILL.md` to add an entry-point contract that defines the already-active main session as the canonical orchestrator runtime.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` states that optional orchestrator profiles are configuration aids and do not replace the active main-session orchestration contract.

- [x] [P1-T2] Update `.agents/skills/orchestrate/SKILL.md` to add a read-only intake and route-selection gate before lifecycle MCP calls.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` requires policy reads, checkpoint reads, route config reads, scope assessment, language/file assessment, route selection, and route metadata persistence before `new_potential_entry`, `new_potential_bug_entry`, `potential_to_issue`, or `new_active_feature_folder`.

- [x] [P1-T3] Update `.agents/skills/orchestrate/SKILL.md` to derive and persist `work-mode` from the selected route before lifecycle automation.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` maps small route to `minor-audit`, large feature route to `full-feature`, and large bug route to `full-bug`, with route metadata persisted in `artifacts/orchestration/orchestrator-state.json`.

- [x] [P1-T4] Update `.agents/skills/orchestrate/SKILL.md` to require pre-issue branch creation before potential-entry creation.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` requires a slug-only pre-issue branch derived from `${promotion-type}` and `${short-name}` before calling `new_potential_entry` or `new_potential_bug_entry`.

- [x] [P1-T5] Update `.agents/skills/orchestrate/SKILL.md` to require branch rename after promotion and before active feature folder creation.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` requires `potential_to_issue` to return numeric `${issue-num}` before renaming to `${promotion-type}/${short-name}-${issue-num}` and before calling `new_active_feature_folder`.

- [x] [P1-T6] Update `.agents/skills/orchestrate/SKILL.md` to add a pre-implementation gate before edits, formatters, tests, staging, commits, and implementation delegation.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` blocks implementation actions until checkpoint route metadata, selected work mode, lifecycle readiness, branch state, and required MCP receipts are present.

- [x] [P1-T7] Update `.agents/skills/orchestrate/SKILL.md` to add violation handling for implementation actions attempted before required orchestration gates.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` requires blocked checkpoint state, the violated gate name, attempted action, known mutated files, corrective next step, and no continued implementation after a violation.

- [x] [P1-T8] Update `.agents/skills/orchestrate/SKILL.md` so orchestration-facing review delegation uses `feature-reviewer` for agent receipts.
  - Acceptance: `.agents/skills/orchestrate/SKILL.md` uses `feature-reviewer` for delegated review agent naming and reserves `feature-review` only for the review skill or workflow name when that distinction is explicit.

### Phase 2 — Reconcile Lifecycle Companion Skills

- [x] [P2-T1] Update `.agents/skills/feature-promotion-lifecycle/SKILL.md` to add canonical branch variables for `${pre-issue-branch}` and `${final-branch}`.
  - Acceptance: `.agents/skills/feature-promotion-lifecycle/SKILL.md` defines `${pre-issue-branch}` as derived from `${promotion-type}` and `${short-name}` before issue creation, and `${final-branch}` as `${promotion-type}/${short-name}-${issue-num}` after promotion.

- [x] [P2-T2] Update `.agents/skills/feature-promotion-lifecycle/SKILL.md` to replace promotion-before-branch wording with the Issue #232 lifecycle order.
  - Acceptance: `.agents/skills/feature-promotion-lifecycle/SKILL.md` orders lifecycle setup as route metadata readiness, pre-issue branch creation, potential entry creation, `potential_to_issue`, numeric issue capture, post-promotion branch rename, and `new_active_feature_folder`.

- [x] [P2-T3] Update `.agents/skills/feature-promotion-lifecycle/SKILL.md` to keep MCP-only requirements limited to the MCP-backed lifecycle operations.
  - Acceptance: `.agents/skills/feature-promotion-lifecycle/SKILL.md` states that potential entry creation, issue promotion, and active folder creation must use MCP receipts, while branch creation and branch rename are recorded as branch/checkpoint evidence rather than `surface: "mcp"` lifecycle operations unless a future MCP tool exists.

- [x] [P2-T4] Update `.agents/skills/repo-automation-adapter/SKILL.md` to replace the old feature-promotion ordered chain with the Issue #232 order.
  - Acceptance: `.agents/skills/repo-automation-adapter/SKILL.md` requires pre-issue branch setup before `new_potential_entry` or `new_potential_bug_entry`, requires numeric issue capture before final branch rename, and requires final branch rename before `new_active_feature_folder`.

- [x] [P2-T5] Update `.agents/skills/orchestrator-workflow/SKILL.md` small-path lifecycle preconditions to remove contradictory promotion-before-branch guidance.
  - Acceptance: The small-path section of `.agents/skills/orchestrator-workflow/SKILL.md` requires route metadata persistence and pre-issue branch setup before potential-entry creation, while keeping numeric `${issue-num}` required before `new_active_feature_folder`.

- [x] [P2-T6] Update `.agents/skills/orchestrator-workflow/SKILL.md` large-path lifecycle preconditions to remove contradictory promotion-before-branch guidance.
  - Acceptance: The large-path section of `.agents/skills/orchestrator-workflow/SKILL.md` requires route metadata persistence and pre-issue branch setup before potential-entry creation, while keeping numeric `${issue-num}` required before `new_active_feature_folder`.

- [x] [P2-T7] Update `.agents/skills/orchestrator-workflow/SKILL.md` checkpoint schema to record branch sequencing and pre-implementation violation state.
  - Acceptance: `.agents/skills/orchestrator-workflow/SKILL.md` includes checkpoint fields for pre-issue branch, final branch, branch rename status, and a blocked reason suitable for pre-implementation gate violations.

- [x] [P2-T8] Update `.agents/skills/orchestrator-workflow/SKILL.md` hard constraints and completion gates to enforce the hardened branch and implementation order.
  - Acceptance: `.agents/skills/orchestrator-workflow/SKILL.md` no longer states that issue promotion must complete before initial branch creation and explicitly blocks implementation when route metadata, branch state, lifecycle receipts, or folder readiness are missing.

### Phase 3 — Acceptance Criteria Traceability

- [x] [P3-T1] Write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.<timestamp>.md` before acceptance-criteria check-off tasks.
  - Acceptance: The artifact includes `Timestamp:`, `Issue: #232`, completed task mappings, acceptance-criteria mappings for `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md` and `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`, and evidence paths under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/`.

- [x] [P3-T2] Update `docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md` acceptance criteria and Definition of Done only after corresponding implementation and validation evidence exists.
  - Acceptance: Each checked item in `spec.md` maps to at least one completed task in this plan and one evidence artifact under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/`, with traceability recorded in `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.<timestamp>.md`.

- [x] [P3-T3] Update `docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md` acceptance criteria only after corresponding implementation and validation evidence exists.
  - Acceptance: Each checked item in `user-story.md` maps to at least one completed task in this plan and one evidence artifact under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/`, with traceability recorded in `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.<timestamp>.md`.

### Phase 4 — Final QC and Validation

- [x] [P4-T1] Run whitespace validation with `git diff --check -- .agents/skills/orchestrate/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md docs/features/active/2026-06-24-harden-orchestrate-skill-232/issue.md docs/features/active/2026-06-24-harden-orchestrate-skill-232/spec.md docs/features/active/2026-06-24-harden-orchestrate-skill-232/user-story.md`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-git-diff-check.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0` and an output summary showing no whitespace errors.

- [x] [P4-T2] Run review-delegate naming validation with `pwsh -NoProfile -Command '$matches = rg -n "feature-review subagent|feature-review delegation|delegate to feature-review|delegating to feature-review|latest feature-review" .agents/skills/orchestrate/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md; if ($LASTEXITCODE -eq 0) { $matches; exit 1 } elseif ($LASTEXITCODE -eq 1) { "No stale feature-review delegate references found."; exit 0 } else { exit $LASTEXITCODE }'`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-review-delegate-naming.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0` and confirms orchestration-facing review delegation uses `feature-reviewer`.

- [x] [P4-T3] Run lifecycle-order validation with `pwsh -NoProfile -Command '$matches = rg -n "issue promotion must complete before branch|Create the potential entry\.|Promote with potential_to_issue\.|Create or check out .*issue-num" .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md; if ($LASTEXITCODE -eq 0) { $matches; exit 1 } elseif ($LASTEXITCODE -eq 1) { "No stale promotion-before-branch sequence found."; exit 0 } else { exit $LASTEXITCODE }'`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-lifecycle-order.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0` and confirms no stale lifecycle sequence places issue promotion before the initial branch.

- [x] [P4-T4] Run pre-implementation gate validation with `pwsh -NoProfile -Command '$required = @("read-only scope assessment","route metadata","pre-implementation gate","edits, formatters, tests, staging, commits","implementation delegation","blocked checkpoint state"); $text = Get-Content -Raw ".agents/skills/orchestrate/SKILL.md"; $missing = $required | Where-Object { $text -notmatch [regex]::Escape($_) }; if ($missing) { $missing; exit 1 } "Required pre-implementation gate phrases found."; exit 0'`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-pre-implementation-gate.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0` and confirms the hardened gate text is present in `.agents/skills/orchestrate/SKILL.md`.

- [x] [P4-T5] Run branch-sequencing validation with `pwsh -NoProfile -Command '$required = @("pre-issue branch","potential entry creation","potential_to_issue","numeric issue","branch rename","new_active_feature_folder"); $paths = @(".agents/skills/orchestrate/SKILL.md",".agents/skills/feature-promotion-lifecycle/SKILL.md",".agents/skills/repo-automation-adapter/SKILL.md",".agents/skills/orchestrator-workflow/SKILL.md"); $text = ($paths | ForEach-Object { Get-Content -Raw $_ }) -join [Environment]::NewLine; $missing = $required | Where-Object { $text -notmatch [regex]::Escape($_) }; if ($missing) { $missing; exit 1 } "Required branch sequencing phrases found."; exit 0'`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-branch-sequencing.md`.
  - Acceptance: The artifact records `EXIT_CODE: 0` and confirms the companion skill files contain the Issue #232 branch sequence.

- [x] [P4-T6] Validate this plan file with MCP tool `mcp__drm-copilot__validate_orchestration_artifacts` using `artifact_type: "plan"` and `artifact_path: "docs/features/active/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md"`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-plan-validator.md`.
  - Acceptance: The artifact records validator success for the exact plan path and `EXIT_CODE: 0` or the MCP success equivalent.

- [x] [P4-T7] Run final scoped git status with `git status --short --branch -- .agents/skills/orchestrate/SKILL.md .agents/skills/feature-promotion-lifecycle/SKILL.md .agents/skills/repo-automation-adapter/SKILL.md .agents/skills/orchestrator-workflow/SKILL.md docs/features/active/2026-06-24-harden-orchestrate-skill-232`, then write `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-git-status.md`.
  - Acceptance: The artifact records the final changed files for Issue #232 and does not include unrelated file modifications as plan-owned work.

## Acceptance Criteria Traceability

- Entry-point contract: P1-T1, P3-T1, P3-T2, P3-T3, P4-T4.
- Read-only scope assessment and route selection before lifecycle MCP tools: P1-T2, P1-T3, P3-T1, P3-T2, P3-T3, P4-T4.
- Pre-issue branch creation and post-promotion branch rename: P1-T4, P1-T5, P2-T1, P2-T2, P2-T4, P3-T1, P3-T2, P3-T3, P4-T3, P4-T5.
- Pre-implementation gate before edits, formatters, tests, staging, commits, or implementation delegation: P1-T6, P1-T7, P2-T7, P2-T8, P3-T1, P3-T2, P3-T3, P4-T4.
- Ordered lifecycle MCP usage and derived work mode: P1-T3, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P3-T1, P3-T2, P3-T3, P4-T3, P4-T5.
- Violation handling for premature implementation work: P1-T7, P2-T7, P2-T8, P3-T1, P3-T2, P3-T3, P4-T4.
- Review delegation naming aligned to `feature-reviewer`: P1-T8, P3-T1, P3-T2, P3-T3, P4-T2.
- Companion lifecycle skill update: P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T8, P3-T1, P3-T2, P3-T3.

## Stop Conditions

- Stop if any required input file for Issue #232 is missing.
- Stop if any implementation requires non-Markdown source or test changes before this plan is revised.
- Stop if any evidence path would be written outside `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/<kind>/`.
- Stop if `atomic-executor` preflight does not return `PREFLIGHT: ALL CLEAR`.
- Stop if MCP plan validation fails for `docs/features/active/2026-06-24-harden-orchestrate-skill-232/plan.2026-06-24T15-45.md`.
