---
title: "Atomic Plan - Feature #136 Claude Code Architecture v2"
feature: "2026-04-11-claude-code-architecture-136"
feature_version: "v2"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md"
spec_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
user_story_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
issue_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/issue.md"
issue_present: false
work_mode: "full-feature"
work_mode_source: "issue.md missing; fail closed to full-feature"
fallback_reason: "issue.md missing; fail closed to full-feature"
owner: "drmoisan"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-12T15-45"
version: "2.1"
preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
required_preflight_signal: "PREFLIGHT: ALL CLEAR"
---
# Atomic Plan - Feature #136 Claude Code Architecture v2

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

## Introduction

- Plan Path: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md`
- Requirement Sources: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Resolved Work Mode: `full-feature`
- Mode Source: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/issue.md` is missing; per contract, fail closed to `full-feature`
- Preflight Directive: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required Final Signal: `PREFLIGHT: ALL CLEAR`

## Requirement Inventory

| ID | Source | Requirement |
|---|---|---|
| REQ-001 | `spec.md` Behavior | Implement the four Claude-native layers under `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/`. |
| REQ-002 | `spec.md` Behavior, API / CLI Surface | Use `.claude/skills/` as the primary direct-use surface for `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, `/review-feature`, `/review-staged`, `/review-epic`, `/update-status`, and feature-doc completion. |
| REQ-003 | `spec.md` Behavior, Inputs / Outputs | Mirror canonical reusable guidance from `.github/skills/*/SKILL.md` into `.claude/skills/*/SKILL.md` without changing `.github` source ownership. |
| REQ-004 | `spec.md` Behavior, Data & State; `user-story.md` Acceptance Criteria | Use a main-thread orchestrator model that reads and updates `artifacts/orchestration/orchestrator-state.json` and does not depend on nested worker-to-worker delegation. |
| REQ-005 | `spec.md` migration maps | Provide repository-canonical worker agents for planner, executor, review, research, feature-doc completion, staged review, epic review, status update, and language engineers while excluding generic personal personas from project scope. |
| REQ-006 | `spec.md` Enforcement layer; `user-story.md` Acceptance Criteria | Implement deny-first permissions plus `PreToolUse`, `SubagentStop`, and documented config-change handling in `.claude/settings.json` and `.claude/hooks/`. |
| REQ-007 | `spec.md` Architecture documentation | Document equivalences, non-equivalences, migration maps, sync strategy, and managed-settings limits in `docs/engineering/claude-code-architecture.md`. |
| REQ-008 | `spec.md` Definition of Done and Seeded Test Conditions | Produce validation evidence for skill invocation, worker routing, permission enforcement, hook enforcement, checkpoint resume, and exclusion of repository-disallowed generic agents. |
| REQ-009 | User directive | Keep the plan self-contained, executor-compatible, machine-readable, and free of placeholder text while updating the provided file in place. |
| REQ-010 | Atomic plan contract | Phase 0 must read mandatory policies in repository order, capture baseline evidence for touched executable languages, and record the fail-closed work-mode decision explicitly. |

## Deterministic Constraints

- CON-001: Do not modify `.github/instructions/*`, `.github/skills/*`, `.github/agents/*`, or `.github/prompts/*`; they remain canonical sources.
- CON-002: Do not introduce new `.claude/commands/*` files for user-invocable workflows.
- CON-003: Do not commit generic beast, mentor, or framework-persona agents under `.claude/agents/`.
- CON-004: Preserve the checkpoint path `artifacts/orchestration/orchestrator-state.json`; do not create sidecar checkpoint files.
- CON-005: Every evidence artifact named in this plan must include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- CON-006: PowerShell executable changes and tests must use the repository MCP toolchain contract: `mcp__drmCopilotExtension__run_poshqc_format`, `mcp__drmCopilotExtension__run_poshqc_analyze`, and `mcp__drmCopilotExtension__run_poshqc_test`.
- CON-007: Final QA must rerun from formatting if any formatting, analyzer, or PowerShell test step changes files or fails.
- CON-008: Live Claude-session validation is fail-closed. Any step that cannot be completed in the execution environment must be recorded as `UNVERIFIED` with explicit blocker evidence.

## Acceptance Criteria Traceability

| Requirement ID | Tasks |
|---|---|
| REQ-001 | P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T7, P2-T8, P2-T9, P3-T1, P3-T2, P3-T3, P3-T4, P3-T5, P3-T6, P3-T7, P3-T8, P3-T9, P3-T10, P3-T11, P3-T12, P3-T13, P3-T14, P3-T15, P3-T16, P3-T17, P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6, P4-T7, P4-T8, P4-T9, P4-T10, P4-T11, P4-T12, P4-T13, P4-T14, P4-T15, P4-T16, P4-T17, P4-T18, P4-T19 |
| REQ-002 | P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T7, P2-T8, P2-T9 |
| REQ-003 | P3-T1, P3-T2, P3-T3, P3-T4, P3-T5, P3-T6, P3-T7, P3-T8, P3-T9, P3-T10, P3-T11, P3-T12, P3-T13, P3-T14, P3-T15, P3-T16, P3-T17 |
| REQ-004 | P1-T1, P2-T1, P4-T1, P4-T14, P4-T18, P5-T4, P5-T6 |
| REQ-005 | P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6, P4-T7, P4-T8, P4-T9, P4-T10, P4-T11, P4-T12, P4-T13, P5-T2, P5-T6 |
| REQ-006 | P4-T14, P4-T15, P4-T19, P5-T5, P5-T6 |
| REQ-007 | P4-T16, P4-T17, P4-T18, P4-T19, P5-T3 |
| REQ-008 | P5-T1, P5-T2, P5-T3, P5-T4, P5-T5, P5-T6, P5-T7, P5-T8, P6-T5 |
| REQ-009 | P0-T1, P6-T5 |
| REQ-010 | P0-T1, P0-T2, P0-T3, P0-T4, P0-T5, P0-T6, P0-T7 |

### Phase 0 — Policy, Mode Resolution, and Baseline Evidence
**Phase Completion Criteria:** Phase 0 is complete only when the policy-read artifact, requirements-resolution artifact, current-runtime inventory artifact, and baseline PowerShell toolchain artifacts exist under `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/` and explicitly record the fail-closed `full-feature` mode decision.

- [ ] [P0-T1] Create `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, and `evidence/other/`.
  - Acceptance: All four directories exist under the `v2/evidence/` root.

- [ ] [P0-T2] Read the mandatory policy and requirement files in this exact order and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/phase0-instructions-read.md`: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`.
  - Acceptance:
    - The artifact exists at the exact path above.
    - The artifact contains `Timestamp:`.
    - The artifact contains `Policy Order:`.
    - The artifact contains the exact ordered list of files read.

- [ ] [P0-T3] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t3.requirements-resolution.*.md` confirming that `docs/features/active/2026-04-11-claude-code-architecture-136/v2/issue.md` is absent, `work_mode` therefore resolves to `full-feature`, and the authoritative deliverable set is the union of the mandatory `spec.md` sections `Behavior`, `Outputs`, `API / CLI Surface`, `Implementation Strategy`, `Definition of Done`, and `Seeded Test Conditions`, plus the acceptance criteria in `user-story.md`.
  - Acceptance:
    - Exactly one artifact matching `p0-t3.requirements-resolution.*.md` exists.
    - The artifact names the missing `issue.md` path exactly.
    - The artifact states `Resolved Work Mode: full-feature`.
    - The artifact names `spec.md` and `user-story.md` as the v2 requirements sources.
    - The artifact lists the exact mandatory `spec.md` sections named in this task and states that `user-story.md` acceptance criteria are included in scope.

- [ ] [P0-T4] Capture the current Claude runtime inventory in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p0-t4.claude-runtime-inventory.*.md` using `rg --files CLAUDE.md .claude docs/engineering/claude-code-architecture.md`.
  - Acceptance: The artifact records all currently committed Claude runtime files and distinguishes existing files from absent required files.

- [ ] [P0-T5] Capture the baseline PowerShell formatting state in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t5.poshqc-format.*.md` using `mcp__drmCopilotExtension__run_poshqc_format`.
  - Acceptance: The artifact contains `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T6] Capture the baseline PowerShell analyzer state in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t6.poshqc-analyze.*.md` using `mcp__drmCopilotExtension__run_poshqc_analyze`.
  - Acceptance: The artifact contains `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T7] Capture the baseline PowerShell test and coverage state in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t7.poshqc-test.*.md` using `mcp__drmCopilotExtension__run_poshqc_test`.
  - Acceptance:
    - Exactly one artifact matching `p0-t7.poshqc-test.*.md` exists.
    - The artifact contains `Command: mcp__drmCopilotExtension__run_poshqc_test`.
    - The artifact contains `EXIT_CODE:`.
    - `Output Summary:` reports total tests, passed tests, failed tests, and numeric baseline coverage headline values when the tool output exposes them.
    - If the tool output does not expose numeric coverage values, the artifact explicitly states `Coverage Evidence: unavailable from tool output` and `Coverage Disposition: remediation required`.

### Phase 1 — Standing Instructions and Path-Scoped Rules
**Phase Completion Criteria:** Phase 1 is complete only when `CLAUDE.md` and the four `.claude/rules/*.md` files reflect the v2 architecture, preserve `.github/*` source ownership, and state that the main-thread orchestrator model replaces nested worker orchestration.

- [ ] [P1-T1] Update `CLAUDE.md` so it summarizes tone policy, policy-compliance order, the four Claude-native layers, the main-thread orchestrator model, and the rule that `.github/*` remains the canonical authored source for mirrored Claude assets.
  - Acceptance: `CLAUDE.md` explicitly names `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/`; states that `.claude/commands/` is not the primary direct-use surface; and states that `artifacts/orchestration/orchestrator-state.json` is the checkpoint file.

- [ ] [P1-T2] Update `.claude/rules/python.md` so its frontmatter remains path-scoped to Python files and its body references the canonical `.github/instructions/python-*.instructions.md` sources instead of restating orchestration logic.
  - Acceptance: `.claude/rules/python.md` contains `paths: ["**/*.py"]` and references the canonical Python code-change and unit-test policies.

- [ ] [P1-T3] Update `.claude/rules/powershell.md` so it references the hook-test TDD requirement, the PoshQC MCP toolchain contract, and PowerShell test expectations sourced from `.github/instructions/powershell-*.instructions.md`.
  - Acceptance: `.claude/rules/powershell.md` contains `paths: ["**/*.ps1", "**/*.psm1", "**/*.psd1"]` and names `mcp__drmCopilotExtension__run_poshqc_format`, `mcp__drmCopilotExtension__run_poshqc_analyze`, and `mcp__drmCopilotExtension__run_poshqc_test`.

- [ ] [P1-T4] Update `.claude/rules/typescript.md` so it keeps TypeScript guidance scoped to TypeScript files and explicitly states that direct-use skill authoring belongs in Markdown under `.claude/skills/`, not in `.claude/commands/*`.
  - Acceptance: `.claude/rules/typescript.md` contains `paths: ["**/*.ts"]` and documents `.claude/skills/` rather than `.claude/commands/*` as the new direct-use surface.

- [ ] [P1-T5] Update `.claude/rules/csharp.md` so it preserves C# policy references for future language-engineer worker definitions and keeps analyzer and nullable requirements sourced from `.github/instructions/csharp-*.instructions.md`.
  - Acceptance: `.claude/rules/csharp.md` contains `paths: ["**/*.cs", "**/*.csproj"]` and references `csharpier`, analyzer enforcement, and nullable/type-safety requirements.

### Phase 2 — Direct-Use Claude Skill Surface
**Phase Completion Criteria:** Phase 2 is complete only when every required user-invocable workflow is represented under `.claude/skills/` with deterministic frontmatter and no dependence on `.claude/commands/*` for new work.

- [ ] [P2-T1] Update `.claude/skills/orchestrate/SKILL.md` so it frames work for the already-active main-thread orchestrator, requires checkpoint reads from `artifacts/orchestration/orchestrator-state.json`, and forbids a forked `orchestrator` worker model.
  - Acceptance:
    - `.claude/skills/orchestrate/SKILL.md` does not contain `context: fork`.
    - `.claude/skills/orchestrate/SKILL.md` does not contain `agent: orchestrator`.
    - The skill body states that the already-active main session is the orchestrator runtime.
    - The skill body states that `artifacts/orchestration/orchestrator-state.json` is read before bounded worker delegation.

- [ ] [P2-T2] Update `.claude/skills/commit-message/SKILL.md` so it cites its canonical `.github` source, uses the v2 workflow wording, and remains bounded to staged-diff inspection and commit-message output only.
  - Acceptance: `.claude/skills/commit-message/SKILL.md` references its canonical `.github` source and keeps a read-only allowed-tool surface for git inspection.

- [ ] [P2-T3] Update `.claude/skills/pr-author/SKILL.md` so it cites its canonical `.github` source, uses the v2 PR-context path expectations, and remains a manual wrapper skill rather than an autonomous worker.
  - Acceptance: `.claude/skills/pr-author/SKILL.md` references its canonical `.github` source and cites `pr_context.summary.txt` and `pr_context.appendix.txt`.

- [ ] [P2-T4] Update `.claude/skills/research-issue/SKILL.md` so it cites its canonical `.github` source, writes research output under `artifacts/research/`, and keeps research execution bounded to the repository-canonical researcher workflow.
  - Acceptance: `.claude/skills/research-issue/SKILL.md` references its canonical `.github` source and names `artifacts/research/<timestamp>-<short-name>-research.md` as the required output path.

- [ ] [P2-T5] Create `.claude/skills/review-feature/SKILL.md` as the direct-use wrapper skill for the feature-review worker.
  - Acceptance: The file exists with valid YAML frontmatter and names the `feature-review` worker plus expected review artifact outputs under the active feature folder.

- [ ] [P2-T6] Create `.claude/skills/review-staged/SKILL.md` as the direct-use wrapper skill for the staged-review worker.
  - Acceptance: The file exists with valid YAML frontmatter and names the `staged-review` worker plus expected review artifact outputs.

- [ ] [P2-T7] Create `.claude/skills/review-epic/SKILL.md` as the direct-use wrapper skill for the epic-review worker.
  - Acceptance: The file exists with valid YAML frontmatter and names the `epic-review` worker plus expected epic audit artifact outputs.

- [ ] [P2-T8] Create `.claude/skills/update-status/SKILL.md` as the direct-use wrapper skill for the status-updater worker.
  - Acceptance: The file exists with valid YAML frontmatter and names the `status-updater` worker plus expected status reconciliation outputs.

- [ ] [P2-T9] Create `.claude/skills/fill-feature-docs/SKILL.md` as the direct-use wrapper skill for the `prd-feature` worker.
  - Acceptance: The file exists with valid YAML frontmatter and names the `prd-feature` worker plus expected feature-document output paths.

### Phase 3 — Reusable Skill Mirrors
**Phase Completion Criteria:** Phase 3 is complete only when the required reusable workflow contracts from `.github/skills/*/SKILL.md` exist as `.claude/skills/*/SKILL.md` runtime mirrors and every per-source disposition task is resolved explicitly in the plan.

- [ ] [P3-T1] Mirror `.github/skills/acceptance-criteria-tracking/SKILL.md` into `.claude/skills/acceptance-criteria-tracking/SKILL.md`.
  - Acceptance: The runtime mirror exists and states that `.github/skills/acceptance-criteria-tracking/SKILL.md` remains the canonical authored source.

- [ ] [P3-T2] Mirror `.github/skills/atomic-plan-contract/SKILL.md` into `.claude/skills/atomic-plan-contract/SKILL.md`.
  - Acceptance: The runtime mirror exists and states that `.github/skills/atomic-plan-contract/SKILL.md` remains the canonical authored source.

- [ ] [P3-T3] Mirror `.github/skills/evidence-and-timestamp-conventions/SKILL.md` into `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Acceptance: The runtime mirror exists and states that `.github/skills/evidence-and-timestamp-conventions/SKILL.md` remains the canonical authored source.

- [ ] [P3-T4] Mirror `.github/skills/policy-compliance-order/SKILL.md` into `.claude/skills/policy-compliance-order/SKILL.md`.
  - Acceptance: The runtime mirror exists and states that `.github/skills/policy-compliance-order/SKILL.md` remains the canonical authored source.

- [ ] [P3-T5] Mirror `.github/skills/feature-promotion-lifecycle/SKILL.md` into `.claude/skills/feature-promotion-lifecycle/SKILL.md`.
  - Acceptance: The runtime mirror exists and preserves the deterministic workflow contract of the canonical source.

- [ ] [P3-T6] Mirror `.github/skills/feature-review-workflow/SKILL.md` into `.claude/skills/feature-review-workflow/SKILL.md`.
  - Acceptance: The runtime mirror exists and preserves the deterministic workflow contract of the canonical source.

- [ ] [P3-T7] Mirror `.github/skills/pr-base-branch-merge-base/SKILL.md` into `.claude/skills/pr-base-branch-merge-base/SKILL.md`.
  - Acceptance: The runtime mirror exists and preserves the deterministic workflow contract of the canonical source.

- [ ] [P3-T8] Mirror `.github/skills/pr-context-artifacts/SKILL.md` into `.claude/skills/pr-context-artifacts/SKILL.md`.
  - Acceptance: The runtime mirror exists and preserves the deterministic workflow contract of the canonical source.

- [ ] [P3-T9] Mirror `.github/skills/remediation-handoff-atomic-planner/SKILL.md` into `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`.
  - Acceptance: The runtime mirror exists and preserves the deterministic workflow contract of the canonical source.

- [ ] [P3-T10] Mirror `.github/skills/csharp-change-budget-router/SKILL.md` into `.claude/skills/csharp-change-budget-router/SKILL.md`.
  - Acceptance: The runtime mirror exists and is preloadable from worker `skills:` frontmatter.

- [ ] [P3-T11] Mirror `.github/skills/csharp-orchestration-state-machine/SKILL.md` into `.claude/skills/csharp-orchestration-state-machine/SKILL.md`.
  - Acceptance: The runtime mirror exists and is preloadable from worker `skills:` frontmatter.

- [ ] [P3-T12] Mirror `.github/skills/powershell-change-budget-router/SKILL.md` into `.claude/skills/powershell-change-budget-router/SKILL.md`.
  - Acceptance: The runtime mirror exists and is preloadable from worker `skills:` frontmatter.

- [ ] [P3-T13] Mirror `.github/skills/powershell-orchestration-state-machine/SKILL.md` into `.claude/skills/powershell-orchestration-state-machine/SKILL.md`.
  - Acceptance: The runtime mirror exists and is preloadable from worker `skills:` frontmatter.

- [ ] [P3-T14] Mirror `.github/skills/policy-audit-template-usage/SKILL.md` into `.claude/skills/policy-audit-template-usage/SKILL.md`.
  - Acceptance: The runtime mirror exists and is preloadable from worker `skills:` frontmatter.

- [ ] [P3-T15] Record the explicit disposition for `.github/skills/README.md` in `docs/engineering/claude-code-architecture.md` as `documentation-only; no `.claude/skills/README.md` runtime mirror is created`.
  - Acceptance: The migration map later names `.github/skills/README.md` as documentation-only and no `.claude/skills/README.md` file is created.

- [ ] [P3-T16] Mirror `.github/skills/make-skill-template/SKILL.md` into `.claude/skills/make-skill-template/SKILL.md` as a maintenance-only project skill.
  - Acceptance: The runtime mirror exists and the migration map later names it as a maintenance-only skill rather than a primary workflow entrypoint.

- [ ] [P3-T17] Mirror `.github/skills/skill-canonical-location-audit/SKILL.md` into `.claude/skills/skill-canonical-location-audit/SKILL.md` as a maintenance-only project skill.
  - Acceptance: The runtime mirror exists and the migration map later names it as a maintenance-only skill rather than a primary workflow entrypoint.

### Phase 4 — Worker Agents and Enforcement Layer
**Phase Completion Criteria:** Phase 4 is complete only when all repository-canonical worker agents required by v2 exist under `.claude/agents/`, `.claude/settings.json` reflects the main-thread orchestrator and deny-first worker surface, and hook/documentation updates cover the enforcement layer and migration maps.

- [ ] [P4-T1] Update `.claude/agents/orchestrator.md` so its frontmatter and body align with the v2 main-thread orchestrator model and direct bounded-worker delegation.
  - Acceptance: `.claude/agents/orchestrator.md` documents main-thread orchestration, direct delegation to repository-canonical workers, and checkpoint reads/writes against `artifacts/orchestration/orchestrator-state.json`.

- [ ] [P4-T2] Update `.claude/agents/atomic-planner.md` so its frontmatter and body align with the mirrored reusable skills and the v2 planner completion contract.
  - Acceptance: `.claude/agents/atomic-planner.md` preloads the mirrored plan-contract skill and does not claim nested worker delegation.

- [ ] [P4-T3] Update `.claude/agents/atomic-executor.md` so its frontmatter and body align with the mirrored reusable skills and the v2 executor completion contract.
  - Acceptance: `.claude/agents/atomic-executor.md` preloads the mirrored foundational skills and does not claim nested worker delegation.

- [ ] [P4-T4] Update `.claude/agents/feature-review.md` so its frontmatter and body align with the v2 review-worker surface and expected artifact outputs.
  - Acceptance: `.claude/agents/feature-review.md` returns artifact paths instead of spawning downstream workers and keeps a bounded review tool surface.

- [ ] [P4-T5] Update `.claude/agents/task-researcher.md` so its frontmatter and body align with the v2 researcher surface and expected research artifact outputs.
  - Acceptance: `.claude/agents/task-researcher.md` returns research artifact paths instead of spawning downstream workers and keeps a bounded research tool surface.

- [ ] [P4-T6] Create `.claude/agents/prd-feature.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T7] Create `.claude/agents/staged-review.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T8] Create `.claude/agents/epic-review.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T9] Create `.claude/agents/status-updater.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T10] Create `.claude/agents/python-typed-engineer.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T11] Create `.claude/agents/powershell-typed-engineer.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T12] Create `.claude/agents/csharp-typed-engineer.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T13] Create `.claude/agents/typescript-engineer.md`.
  - Acceptance: The file exists with YAML frontmatter that includes `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [ ] [P4-T14] Update `.claude/settings.json` to preserve or add top-level `agent: "orchestrator"`, expanded deny-first `permissions.allow` and `permissions.deny`, explicit `hooks.PreToolUse` and `hooks.SubagentStop` entries, `PreToolUse` registration that invokes `.claude/hooks/validate-bash.ps1`, `SubagentStop` completion-gate coverage for the repository-canonical workers named by this plan, and an explicit config-change-handling disposition aligned with `P4-T19`.
  - Acceptance: `.claude/settings.json` contains top-level `agent: "orchestrator"`, expanded deny-first `permissions.allow` and `permissions.deny`, explicit `hooks.PreToolUse` and `hooks.SubagentStop` entries, `PreToolUse` registration that invokes `.claude/hooks/validate-bash.ps1`, `SubagentStop` completion-gate coverage for the repository-canonical workers named by this plan, and an explicit config-change-handling disposition aligned with `P4-T19`.

- [ ] [P4-T15] Update `.claude/hooks/validate-bash.ps1` only as needed to preserve the required blocked-pattern enforcement and align its documented behavior with the v2 settings and validation expectations.
  - Acceptance: The hook still blocks `rm -rf`, `git push --force`, `git push origin --force`, `Remove-Item -Recurse -Force`, `git reset --hard`, and `git push -f`.

- [ ] [P4-T16] Update `docs/engineering/claude-code-architecture.md` so it explicitly states that the `20260412-claude-code-github-skills-agents-migration-research.md` research is sufficient and that the repository uses a main-thread orchestrator model.
  - Acceptance: Both statements appear explicitly in the document.

- [ ] [P4-T17] Update `docs/engineering/claude-code-architecture.md` so it contains the complete file-by-file `.github/skills` migration table, including the documentation-only and maintenance-only dispositions required by Phase 3.
  - Acceptance: The document contains a row for every canonical `.github/skills/*/SKILL.md` source and the `.github/skills/README.md` source.

- [ ] [P4-T18] Update `docs/engineering/claude-code-architecture.md` so it contains the complete file-by-file `.github/agents` disposition table and direct-use `.github/prompts` migration table, and states that `.claude/commands/` is backward-compatibility only.
  - Acceptance: The document contains a row for every `.github/agents/*.agent.md` source and every direct-use `.github/prompts/*.prompt.md` source named in v2, and explicitly states that `.claude/commands/` is backward-compatibility only.

- [ ] [P4-T19] Update `docs/engineering/claude-code-architecture.md` so it distinguishes repository-enforceable controls from managed-settings-only controls and documents the expected `PreToolUse`, `SubagentStop`, and config-change handling boundaries.
  - Acceptance: The document names repository-enforceable controls and managed-settings-only controls separately and documents the expected hook enforcement boundaries.

### Phase 5 — Runtime Validation and Requirement Closure
**Phase Completion Criteria:** Phase 5 is complete only when the runtime-structure artifact, permissions/routing artifact, documentation-validation artifact, and live Claude-session validation artifacts exist, and all unresolved live-session items are explicitly recorded as `UNVERIFIED` with blocker evidence rather than omitted.

- [ ] [P5-T1] Validate the final Claude runtime file inventory and frontmatter structure and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t1.runtime-structure-validation.*.md`.
  - Acceptance: The artifact records `PASS` or `FAIL` for `CLAUDE.md`, `.claude/settings.json`, all required `.claude/skills/` files, all required `.claude/agents/` files, and YAML frontmatter coverage across `.claude/**/*.md`.

- [ ] [P5-T2] Validate `.claude/settings.json` permissions, hook coverage, and excluded-agent inventory and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.permissions-and-routing-validation.*.md`.
  - Acceptance: The artifact records `PASS`, `FAIL`, or `UNVERIFIED` for `agent: "orchestrator"`, required `Skill(...)` entries, required `Agent(...)` coverage, `hooks.PreToolUse`, `hooks.SubagentStop`, registration of `.claude/hooks/validate-bash.ps1`, the config-change-handling disposition, and absence of excluded personal personas from `.claude/agents/`.

- [ ] [P5-T3] Validate the architecture documentation and migration maps and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.documentation-validation.*.md`.
  - Acceptance: The artifact records `PASS`, `FAIL`, or `UNVERIFIED` for research sufficiency statement, non-equivalence documentation, file-by-file migration maps, sync strategy, and managed-settings distinction.

- [ ] [P5-T4] Validate the live Claude-session entrypoint behaviors for `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.*.md`.
  - Acceptance:
    - The artifact records each validation item as `PASS`, `FAIL`, or `UNVERIFIED`.
    - No `PASS` is allowed without cited transcript summary or captured output text.
    - Any `UNVERIFIED` result includes explicit blocker evidence describing why the Claude Code session step could not be completed in the execution environment.

- [ ] [P5-T5] Validate live-session enforcement of bounded worker routing and `PreToolUse` blocking and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.live-enforcement-validation.*.md`.
  - Acceptance:
    - The artifact records each validation item as `PASS`, `FAIL`, or `UNVERIFIED`.
    - No `PASS` is allowed without cited transcript summary or captured output text.
    - Any `UNVERIFIED` result includes explicit blocker evidence describing why the Claude Code session step could not be completed in the execution environment.

- [ ] [P5-T6] Validate live-session `SubagentStop` blocking, checkpoint resume behavior, and exclusion of repository-disallowed generic agents from project-scoped routing and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t6.live-stopgate-validation.*.md`.
  - Acceptance:
    - The artifact records each validation item as `PASS`, `FAIL`, or `UNVERIFIED`.
    - No `PASS` is allowed without cited transcript summary or captured output text.
    - Any `UNVERIFIED` result includes explicit blocker evidence describing why the Claude Code session step could not be completed in the execution environment.

- [ ] [P5-T7] Update `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` so each requirement checkbox is marked `[x]` only when supported by produced evidence artifacts; leave unsupported items unchecked and add a short blocker or evidence note immediately below any unresolved group.
  - Acceptance:
    - `spec.md` is updated in place.
    - Checked items correspond to named evidence artifacts.
    - Unresolved live-session-dependent items remain unchecked with blocker notes.

- [ ] [P5-T8] Update `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` so each requirement checkbox is marked `[x]` only when supported by produced evidence artifacts; leave unsupported items unchecked and add a short blocker or evidence note immediately below any unresolved group.
  - Acceptance:
    - `user-story.md` is updated in place.
    - Checked items correspond to named evidence artifacts.
    - Unresolved live-session-dependent items remain unchecked with blocker notes.

### Phase 6 — Final QA Loop
**Phase Completion Criteria:** Phase 6 is complete only when the final PowerShell format, analyze, and test artifacts exist, any reruns are documented, and the end-state summary reports the coverage disposition fail-closed.

- [ ] [P6-T1] Run the final PowerShell formatting pass and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p6-t1.poshqc-format.*.md` using `mcp__drmCopilotExtension__run_poshqc_format`.
  - Acceptance: The artifact contains `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P6-T2] Run the final PowerShell analyzer pass and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p6-t2.poshqc-analyze.*.md` using `mcp__drmCopilotExtension__run_poshqc_analyze`.
  - Acceptance: The artifact contains `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P6-T3] Run the final PowerShell test and coverage pass and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p6-t3.poshqc-test.*.md` using `mcp__drmCopilotExtension__run_poshqc_test`.
  - Acceptance:
    - Exactly one artifact matching `p6-t3.poshqc-test.*.md` exists.
    - The artifact contains `Command: mcp__drmCopilotExtension__run_poshqc_test`.
    - `EXIT_CODE:` is recorded exactly as returned.
    - `Output Summary:` reports final pass/fail counts and numeric post-change coverage headline values when the tool output exposes them.
    - If the tool output does not expose numeric coverage values, the artifact explicitly states `Coverage Evidence: unavailable from tool output` and `Coverage Disposition: remediation required`.

- [ ] [P6-T4] If `P6-T1`, `P6-T2`, or `P6-T3` changes files or fails, correct the cause and rerun Phase 6 from `P6-T1` until format, analyze, and test pass in one clean sequence; if `P6-T1`, `P6-T2`, or `P6-T3` changes any repository file, rerun the impacted Phase 5 validation tasks and refresh `P5-T7` and `P5-T8` against the final post-QA state before closing Phase 6.
  - Acceptance: The final clean sequence reported in the end-state summary includes `format -> analyze -> test` plus any required post-QA Phase 5 validation reruns and `P5-T7` and `P5-T8` requirements-refresh reruns triggered by Phase 6 file changes.

- [ ] [P6-T5] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p6-t5.end-state-summary.*.md` as the final end-state and PowerShell coverage-disposition summary for the v2 delta outcome.
  - Acceptance:
    - The artifact identifies the final post-QA versions of the Phase 5 validation artifacts and the final artifact paths from `P6-T1` through `P6-T3`.
    - The artifact states whether `spec.md` and `user-story.md` were refreshed after any Phase 6 reruns and does not treat pre-QA `P5-T7` and `P5-T8` outputs as final if Phase 6 changed files.
    - The artifact compares baseline versus final PoshQC test counts from `P0-T7` and `P6-T3`.
    - The artifact records the baseline coverage value from `P0-T7`, the post-change coverage value from `P6-T3`, and an explicit coverage disposition; if numeric coverage or changed/new-code coverage cannot be determined deterministically, it states `remediation required`.
    - The artifact reports any remaining `UNVERIFIED` or `remediation required` items instead of claiming complete delivery.

## Preflight Checklist

- [x] The plan updates the exact provided path in place.
- [x] YAML frontmatter is present and contains `status` and `status_color`.
- [x] The introduction includes a Planned status badge.
- [x] The missing `issue.md` and fail-closed `full-feature` mode decision are explicit.
- [x] Phase order is canonical: Phase 0, Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6.
- [x] `P2-T1` enforces the main-thread orchestrator contract and does not require `agent: orchestrator`.
- [x] Every previously bucketed multi-file task has been split into one task per file or explicit disposition decision.
- [x] Requirement-closure tasks exist before the final QA phase.
- [x] Live Claude-session validation tasks are fail-closed and allow `UNVERIFIED` with blocker evidence.
- [x] Final QA includes explicit coverage-disposition handling when tool output lacks numeric coverage data.
- [x] No placeholder text remains.

## Test Plan

- Unit: Existing Pester coverage for `.claude/hooks/validate-bash.ps1` must remain green under `mcp__drmCopilotExtension__run_poshqc_test`.
- Integration: Validate `.claude/settings.json`, `.claude/skills/`, `.claude/agents/`, and architecture documentation structure through the Phase 5 artifacts.
- Manual/Claude Session: Execute the live validation artifacts in `P5-T4`, `P5-T5`, and `P5-T6` and record `PASS`, `FAIL`, or `UNVERIFIED` with blocker evidence.
