---
title: "2026-04-11-claude-code-architecture-136-v2"
issue: 136
owner: "drmoisan"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-12T15-57"
source_of_truth:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
research_inputs:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md"
work_mode_source: "docs/features/active/2026-04-11-claude-code-architecture-136/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
executor_retry_signal: "PREFLIGHT: REVISIONS REQUIRED"
---

# Atomic Plan — Feature #136 Claude Code Architecture v2

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

## Overview

This plan delivers the Claude Code runtime architecture described in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`, using the file-by-file migration rules and runtime constraints documented in `docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md`. The selected work mode is resolved from the parent feature issue file `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`, which contains the marker `- Work Mode: full-feature`.

## Deterministic Inputs

- Plan path: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md`
- Primary requirements sources:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Research source:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md`
- Work-mode resolution:
  - Authoritative issue file: `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`
  - Recorded marker: `- Work Mode: full-feature`
  - Resolved work mode: `full-feature`
  - Resolution rule: use the parent feature `issue.md` marker before any fallback logic
- Existing Claude runtime files already present in scope:
  - `CLAUDE.md`
  - `.claude/settings.json`
  - `.claude/hooks/validate-bash.ps1`
  - `.claude/rules/csharp.md`
  - `.claude/rules/powershell.md`
  - `.claude/rules/python.md`
  - `.claude/rules/typescript.md`
  - `.claude/skills/commit-message/SKILL.md`
  - `.claude/skills/orchestrate/SKILL.md`
  - `.claude/skills/pr-author/SKILL.md`
  - `.claude/skills/research-issue/SKILL.md`
  - `.claude/agents/atomic-executor.md`
  - `.claude/agents/atomic-planner.md`
  - `.claude/agents/feature-review.md`
  - `.claude/agents/orchestrator.md`
  - `.claude/agents/task-researcher.md`
  - `docs/engineering/claude-code-architecture.md`
- Existing test coverage already present in scope:
  - `tests/scripts/claude-hooks/validate-bash.Tests.ps1`

## Target Implementation Files

- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/hooks/validate-bash.ps1`
- `.claude/rules/csharp.md`
- `.claude/rules/powershell.md`
- `.claude/rules/python.md`
- `.claude/rules/typescript.md`
- `.claude/skills/orchestrate/SKILL.md`
- `.claude/skills/commit-message/SKILL.md`
- `.claude/skills/pr-author/SKILL.md`
- `.claude/skills/research-issue/SKILL.md`
- `.claude/skills/review-feature/SKILL.md`
- `.claude/skills/review-staged/SKILL.md`
- `.claude/skills/review-epic/SKILL.md`
- `.claude/skills/update-status/SKILL.md`
- `.claude/skills/fill-feature-docs/SKILL.md`
- `.claude/skills/acceptance-criteria-tracking/SKILL.md`
- `.claude/skills/atomic-plan-contract/SKILL.md`
- `.claude/skills/csharp-change-budget-router/SKILL.md`
- `.claude/skills/csharp-orchestration-state-machine/SKILL.md`
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- `.claude/skills/feature-promotion-lifecycle/SKILL.md`
- `.claude/skills/feature-review-workflow/SKILL.md`
- `.claude/skills/make-skill-template/SKILL.md`
- `.claude/skills/policy-audit-template-usage/SKILL.md`
- `.claude/skills/policy-compliance-order/SKILL.md`
- `.claude/skills/powershell-change-budget-router/SKILL.md`
- `.claude/skills/powershell-orchestration-state-machine/SKILL.md`
- `.claude/skills/pr-base-branch-merge-base/SKILL.md`
- `.claude/skills/pr-context-artifacts/SKILL.md`
- `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`
- `.claude/skills/skill-canonical-location-audit/SKILL.md`
- `.claude/agents/orchestrator.md`
- `.claude/agents/atomic-planner.md`
- `.claude/agents/atomic-executor.md`
- `.claude/agents/feature-review.md`
- `.claude/agents/task-researcher.md`
- `.claude/agents/prd-feature.md`
- `.claude/agents/staged-review.md`
- `.claude/agents/epic-review.md`
- `.claude/agents/status-updater.md`
- `.claude/agents/python-typed-engineer.md`
- `.claude/agents/powershell-typed-engineer.md`
- `.claude/agents/csharp-typed-engineer.md`
- `.claude/agents/typescript-engineer.md`
- `docs/engineering/claude-code-architecture.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
- `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`

## Target Regression And Validation Test Files

- `tests/scripts/claude-hooks/validate-bash.Tests.ps1`
- `tests/scripts/claude-runtime/claude-settings.Tests.ps1`
- `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`
- `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`

## Requirement Inventory

| ID | Source | Requirement |
|---|---|---|
| REQ-001 | `spec.md` Behavior | Implement the four Claude-native layers across `CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/settings.json`, and `.claude/hooks/`. |
| REQ-002 | `spec.md` Behavior, API / CLI Surface | Use `.claude/skills/` as the primary direct-use surface for `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, `/review-feature`, `/review-staged`, `/review-epic`, `/update-status`, and feature-doc completion. |
| REQ-003 | `spec.md` Inputs / Outputs | Keep `.github/skills/*/SKILL.md` as canonical authored sources and mirror the required runtime contracts into `.claude/skills/*/SKILL.md`. |
| REQ-004 | `spec.md` Data & State; `user-story.md` Acceptance Criteria | Use a main-thread orchestrator model that reads and updates `artifacts/orchestration/orchestrator-state.json` and does not rely on nested worker-to-worker delegation. |
| REQ-005 | `spec.md` Behavior; migration research | Commit only repository-canonical bounded workers under `.claude/agents/` and exclude generic beast, mentor, and framework personas from project-scoped routing. |
| REQ-006 | `spec.md` Enforcement layer; `user-story.md` Acceptance Criteria | Implement deny-first permissions plus `PreToolUse`, `SubagentStop`, and config-change handling boundaries in `.claude/settings.json` and `.claude/hooks/`. |
| REQ-007 | `spec.md` Architecture documentation | Document equivalences, non-equivalences, migration maps, sync strategy, and managed-settings limits in `docs/engineering/claude-code-architecture.md`. |
| REQ-008 | `spec.md` Definition of Done and Seeded Test Conditions | Produce validation evidence for skill invocation, worker routing, permission enforcement, hook enforcement, checkpoint resume behavior, and excluded-agent handling. |
| REQ-009 | `user-story.md` Acceptance Criteria | `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue` must remain callable by name through Claude skills and route to the correct runtime surface. |
| REQ-010 | `user-story.md` Acceptance Criteria | The migration documentation must contain a file-by-file mapping for canonical `.github/skills/*/SKILL.md`, `.github/agents/*.agent.md`, and direct-use `.github/prompts/*.prompt.md` sources. |
| REQ-011 | migration research | The orchestrator must run in the main thread because Claude subagents cannot spawn other subagents. |
| REQ-012 | migration research | `.github/skills/README.md` remains documentation-only and must not produce a `.claude/skills/README.md` runtime mirror. |
| REQ-013 | migration research | Direct-use `.github/prompts/*.prompt.md` entry points become `.claude/skills/*/SKILL.md`; `.claude/commands/` is backward-compatibility only. |
| REQ-014 | migration research | Only repository-canonical worker agents belong in `.claude/agents/`; personal and experimental personas stay out of project scope. |
| REQ-015 | user directive | Update the provided plan file in place, keep the plan machine-readable, and complete the executor preflight loop until `PREFLIGHT: ALL CLEAR` is returned. |
| REQ-016 | atomic-plan contract | Phase 0 must read mandatory policies in order, capture baseline evidence for in-scope executable languages, and record the issue-driven work-mode decision explicitly. |
| REQ-017 | `issue.md` acceptance criteria | `commit-message`, `pr-author`, and `research-issue` must declare exact direct-use tool restrictions and explicit input/output surfaces. |
| REQ-018 | `issue.md` enforcement acceptance criteria | `.claude/settings.json` must include the exact `permissions.allow` literals `Bash(git *)`, `Bash(poetry run *)`, `Bash(pwsh *)`, `Read`, `Edit(/docs/**)`, `Write(/docs/**)`, `Write(/artifacts/**)`, `mcp__drmCopilotExtension__.*`, `Skill(orchestrate *)`, `Skill(commit-message *)`, `Skill(pr-author *)`, and `Skill(research-issue *)`, plus explicit deny coverage for `.env` and secrets paths. |

## Deterministic Constraints

- CON-001: Do not modify `.github/instructions/*`, `.github/skills/*`, `.github/agents/*`, or `.github/prompts/*`; they remain canonical sources.
- CON-002: Do not create new `.claude/commands/*` files for this feature.
- CON-003: Preserve `artifacts/orchestration/orchestrator-state.json` as the only checkpoint path; do not introduce alternate checkpoint files.
- CON-004: Use `tests/scripts/claude-runtime/*.Tests.ps1` and `tests/scripts/claude-hooks/validate-bash.Tests.ps1` for deterministic PowerShell validation of the Claude runtime.
- CON-005: Any evidence artifact named in this plan must include `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- CON-006: PowerShell QA tasks must use `mcp_drmcopilotext_run_poshqc_format`, `mcp_drmcopilotext_run_poshqc_analyze`, and `mcp_drmcopilotext_run_poshqc_test`.
- CON-007: If any final QA command changes files or fails, restart the PowerShell QA loop from formatting.
- CON-008: Any live Claude-session validation that cannot be executed in the current environment must be recorded as `UNVERIFIED` with explicit blocker evidence instead of being omitted.
- CON-009: No task may rely on undocumented human judgment; every acceptance criterion must be checkable by file existence, exact string presence, validator success, or command exit code.

## Requirements Traceability

| Requirement ID | Tasks |
|---|---|
| REQ-001 | P2-T1, P2-T3, P2-T23, P3-T2, P3-T15, P3-T16 |
| REQ-002 | P1-T2, P2-T23, P2-T24, P2-T25, P2-T26, P2-T27, P2-T28, P2-T29, P2-T30, P2-T31 |
| REQ-003 | P2-T6, P2-T10, P2-T15, P2-T19 |
| REQ-004 | P1-T1, P2-T23, P3-T2, P5-T5 |
| REQ-005 | P1-T4, P3-T7, P3-T10, P3-T14, P5-T6 |
| REQ-006 | P1-T3, P1-T6, P3-T15, P3-T16, P5-T3, P5-T4, P7-T4, P7-T6, P7-T7 |
| REQ-007 | P1-T5, P1-T7, P6-T1, P6-T2, P6-T3, P6-T4, P6-T5 |
| REQ-008 | P4-T1, P4-T2, P4-T3, P5-T1, P5-T2, P5-T3, P5-T4, P5-T5, P5-T6, P7-T5 |
| REQ-009 | P2-T23, P2-T24, P2-T25, P2-T26, P5-T4 |
| REQ-010 | P6-T3, P6-T4 |
| REQ-011 | P1-T1, P2-T23, P6-T1 |
| REQ-012 | P1-T7, P2-T22, P6-T3 |
| REQ-013 | P1-T2, P2-T27, P2-T28, P2-T29, P2-T30, P2-T31, P6-T4 |
| REQ-014 | P1-T4, P3-T7, P3-T8, P3-T9, P3-T10, P3-T11, P3-T12, P3-T13, P3-T14, P5-T6 |
| REQ-015 | P0-T1, P0-T2, P0-T3, P7-T9 |
| REQ-016 | P0-T2, P0-T3, P0-T8, P0-T9, P0-T10 |
| REQ-017 | P2-T24, P2-T25, P2-T26 |
| REQ-018 | P3-T15, P5-T2, P7-T4 |

### Phase 0 — Context And Baseline Evidence

**Phase Completion Criteria:** Phase 0 is complete only when the policy-read artifact, work-mode artifact, runtime inventory artifact, baseline settings inspection artifact, baseline JSON-format artifact, baseline JSON-validation artifact, and three baseline PowerShell toolchain artifacts exist under `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/` and all required files read are listed explicitly.

**Evidence Schema Requirement:** Every evidence artifact produced by `P0-T2` through `P0-T10` must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T1] Create `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/`.
  - Acceptance: All four directories exist at the exact paths named in this task.

- [x] [P0-T2] Read the required policy and requirement files in this exact order and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/phase0-instructions-read.md`: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Timestamp:`.
    - The artifact contains `Policy Order:`.
    - The artifact contains each required file path in the exact order listed in this task.

- [x] [P0-T3] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t3.work-mode-resolution.2026-04-12T15-57.md` recording that `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md` exists, contains the marker `- Work Mode: full-feature`, and therefore authoritatively resolves the v2 work mode to `full-feature`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Resolved Work Mode: full-feature`.
    - The artifact contains the exact parent `issue.md` path named in this task.
    - The artifact contains the exact marker `- Work Mode: full-feature`.
    - The artifact contains the exact three authoritative input paths `docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`.

- [x] [P0-T4] Capture the pre-edit Claude runtime inventory in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p0-t4.runtime-inventory.2026-04-12T15-57.md` by inspecting `CLAUDE.md`, `.claude/`, `docs/engineering/claude-code-architecture.md`, `tests/scripts/claude-hooks/`, and `tests/scripts/claude-runtime/` with workspace file-discovery tools.
  - Acceptance:
    - The artifact contains `Command: inspect CLAUDE.md, .claude/, docs/engineering/claude-code-architecture.md, tests/scripts/claude-hooks/, and tests/scripts/claude-runtime/ via workspace discovery tools`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` distinguishes existing files from missing required runtime files.

- [x] [P0-T5] Capture the baseline settings structure in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t5.settings-json-baseline.2026-04-12T15-57.md` by reading `.claude/settings.json` and recording the presence or absence of top-level `agent`, `permissions.allow`, `permissions.deny`, `hooks.PreToolUse`, and `hooks.SubagentStop`.
  - Acceptance:
    - The artifact contains `Command: inspect .claude/settings.json top-level runtime keys via workspace read tool`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` records `present` or `absent` for each key named in this task.

- [x] [P0-T6] Capture the baseline PowerShell formatting state in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t6.poshqc-format.2026-04-12T15-57.md` using `mcp_drmcopilotext_run_poshqc_format` for the in-scope PowerShell paths `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`.
  - Acceptance: The artifact contains `Command: mcp_drmcopilotext_run_poshqc_format`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T7] Capture the baseline PowerShell analyzer state in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t7.poshqc-analyze.2026-04-12T15-57.md` using `mcp_drmcopilotext_run_poshqc_analyze` for the in-scope PowerShell paths `.claude/hooks`, `tests/scripts/claude-hooks`, and `tests/scripts/claude-runtime`.
  - Acceptance: The artifact contains `Command: mcp_drmcopilotext_run_poshqc_analyze`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P0-T8] Capture the baseline PowerShell test state in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t8.poshqc-test.2026-04-12T15-57.md` using `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: mcp_drmcopilotext_run_poshqc_test`.
    - The artifact contains `EXIT_CODE:`.
    - `Output Summary:` reports total tests, passed tests, failed tests, and a numeric `Coverage Total:` value.

- [x] [P0-T9] Capture the baseline JSON formatting check for `.claude/settings.json` in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t9.settings-json-format.2026-04-12T15-57.md` using the exact command `poetry run dev.format-json --check .claude/settings.json`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: poetry run dev.format-json --check .claude/settings.json`.
    - The artifact contains `EXIT_CODE:`.
    - The artifact contains `Output Summary:`.

- [x] [P0-T10] Capture the baseline JSON validation for `.claude/settings.json` in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/baseline/p0-t10.settings-json-validate.2026-04-12T15-57.md` using the exact command `poetry run dev.validate-json .claude/settings.json`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: poetry run dev.validate-json .claude/settings.json`.
    - The artifact contains `EXIT_CODE:`.
    - The artifact contains `Output Summary:`.

### Phase 1 — TDD Red Validation Coverage

**Phase Completion Criteria:** Phase 1 is complete only when the new or updated Pester tests fail for the intended pre-implementation reasons and each expect-fail run is recorded under `evidence/regression-testing/`.

**Evidence Schema Requirement:** Every evidence artifact produced by `P1-T1` through `P1-T5` must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P1-T1] [expect-fail] Add a Pester scenario to `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` that asserts `.claude/skills/orchestrate/SKILL.md` does not contain `context: fork` and does not contain `agent: orchestrator`.
  - Acceptance:
    - The test file contains a scenario that checks both forbidden strings in `.claude/skills/orchestrate/SKILL.md`.
    - Running `mcp_drmcopilotext_run_poshqc_test` is expected to fail because the current file still contains the forbidden strings.
    - Evidence artifact `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t1.orchestrate-main-thread-red.2026-04-12T15-57.md` exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and a failure excerpt tied to this scenario.

- [x] [P1-T2] [expect-fail] Add a Pester scenario to `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` that asserts the wrapper skills `review-feature`, `review-staged`, `review-epic`, `update-status`, and `fill-feature-docs` exist under `.claude/skills/`.
  - Acceptance:
    - The test file contains one scenario that checks for the exact five missing skill paths.
    - Running `mcp_drmcopilotext_run_poshqc_test` is expected to fail because the current files are absent.
    - Evidence artifact `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t2.wrapper-skills-red.2026-04-12T15-57.md` exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and a failure excerpt tied to this scenario.

- [x] [P1-T3] [expect-fail] Add a Pester scenario to `tests/scripts/claude-runtime/claude-settings.Tests.ps1` that asserts `.claude/settings.json` contains top-level `agent: "orchestrator"` plus `PreToolUse` and `SubagentStop` coverage for the repository-canonical workers `atomic-planner`, `atomic-executor`, `feature-review`, `task-researcher`, `prd-feature`, `staged-review`, `epic-review`, and `status-updater`.
  - Acceptance:
    - The test file contains one scenario that parses `.claude/settings.json` and checks the exact keys and worker names listed in this task.
    - Running `mcp_drmcopilotext_run_poshqc_test` is expected to fail because the current settings file lacks the required top-level agent and worker coverage.
    - Evidence artifact `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t3.settings-routing-red.2026-04-12T15-57.md` exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and a failure excerpt tied to this scenario.

- [x] [P1-T4] [expect-fail] Add a Pester scenario to `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` that asserts `.claude/agents/` contains the bounded worker files `prd-feature.md`, `staged-review.md`, `epic-review.md`, `status-updater.md`, `python-typed-engineer.md`, `powershell-typed-engineer.md`, `csharp-typed-engineer.md`, and `typescript-engineer.md`, and does not contain repository-disallowed persona files derived from `mentor`, `api-architect`, `hlbpa`, `5.1-Beast-adjusted`, `5.1-Thinking-Beast-Mode-adjusted`, `gpt-5-beast-mode`, or `voidbeast-gpt41enhanced`.
  - Acceptance:
    - The test file contains one scenario that checks for the exact required files and exact excluded persona filenames named in this task.
    - Running `mcp_drmcopilotext_run_poshqc_test` is expected to fail because the required worker files are currently absent.
    - Evidence artifact `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t4.agent-inventory-red.2026-04-12T15-57.md` exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and a failure excerpt tied to this scenario.

- [x] [P1-T5] [expect-fail] Add a Pester scenario to `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` that asserts `docs/engineering/claude-code-architecture.md` contains the research sufficiency statement, the main-thread orchestrator statement, the full `.github/skills` file-by-file migration table, the full `.github/agents` disposition table, and the direct-use `.github/prompts` migration table.
  - Acceptance:
    - The test file contains one scenario that checks for the exact section obligations named in this task.
    - Running `mcp_drmcopilotext_run_poshqc_test` is expected to fail because the current architecture document is missing part of this coverage.
    - Evidence artifact `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t5.architecture-doc-red.2026-04-12T15-57.md` exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test`, `EXIT_CODE:`, and a failure excerpt tied to this scenario.

- [x] [P1-T6] Add a Pester scenario to `tests/scripts/claude-hooks/validate-bash.Tests.ps1` that asserts the hook still blocks `git push --force`, `git push origin --force`, `git push -f`, `git reset --hard`, `rm -rf`, and `Remove-Item -Recurse -Force` after the settings and runtime updates in this feature.
  - Acceptance: The updated test file contains an explicit regression scenario naming each blocked pattern listed in this task.

- [x] [P1-T7] Add a Pester scenario to `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` that asserts `docs/engineering/claude-code-architecture.md` declares `.github/skills/README.md` as documentation-only and does not require `.claude/skills/README.md`.
  - Acceptance: The test file contains one scenario that checks for the exact documentation-only disposition named in this task.

### Phase 2 — Standing Instructions And Skills Implementation

**Phase Completion Criteria:** Phase 2 is complete only when the standing instructions, path-scoped rules, reusable skill mirrors, and direct-use skills satisfy the Phase 1 red tests without relying on `.claude/commands/`.

**Evidence Schema Requirement:** Every evidence artifact produced by `P2-T22` must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P2-T1] Update `CLAUDE.md` so it names the four-layer Claude runtime, summarizes the policy-compliance order, states that `.github/*` remains the canonical authored source, and identifies `artifacts/orchestration/orchestrator-state.json` as the checkpoint path.
  - Acceptance: `CLAUDE.md` contains each exact path family named in this task and the checkpoint-file statement.

- [x] [P2-T2] Update `.claude/rules/python.md` so it preserves Python path scoping and references the canonical `.github/instructions/python-code-change.instructions.md` and `.github/instructions/python-unit-test.instructions.md` sources.
  - Acceptance: `.claude/rules/python.md` contains Python `paths:` frontmatter and the two exact canonical source paths named in this task.

- [x] [P2-T3] Update `.claude/rules/powershell.md` so it preserves PowerShell path scoping and names `mcp_drmcopilotext_run_poshqc_format`, `mcp_drmcopilotext_run_poshqc_analyze`, and `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: `.claude/rules/powershell.md` contains PowerShell `paths:` frontmatter and the three exact MCP function names named in this task.

- [x] [P2-T4] Update `.claude/rules/typescript.md` so it preserves TypeScript path scoping and states that new user-invocable workflows belong under `.claude/skills/` rather than `.claude/commands/`.
  - Acceptance: `.claude/rules/typescript.md` contains TypeScript `paths:` frontmatter and the exact `.claude/skills/` versus `.claude/commands/` statement named in this task.

- [x] [P2-T5] Update `.claude/rules/csharp.md` so it preserves C# path scoping and references the canonical `.github/instructions/csharp-code-change.instructions.md` and `.github/instructions/csharp-unit-test.instructions.md` sources.
  - Acceptance: `.claude/rules/csharp.md` contains C# `paths:` frontmatter and the two exact canonical source paths named in this task.

- [x] [P2-T6] Create `.claude/skills/acceptance-criteria-tracking/SKILL.md` as the runtime mirror for `.github/skills/acceptance-criteria-tracking/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/acceptance-criteria-tracking/SKILL.md` remains the canonical authored source.

- [x] [P2-T7] Create `.claude/skills/atomic-plan-contract/SKILL.md` as the runtime mirror for `.github/skills/atomic-plan-contract/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/atomic-plan-contract/SKILL.md` remains the canonical authored source.

- [x] [P2-T8] Create `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` as the runtime mirror for `.github/skills/evidence-and-timestamp-conventions/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/evidence-and-timestamp-conventions/SKILL.md` remains the canonical authored source.

- [x] [P2-T9] Create `.claude/skills/policy-compliance-order/SKILL.md` as the runtime mirror for `.github/skills/policy-compliance-order/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/policy-compliance-order/SKILL.md` remains the canonical authored source.

- [x] [P2-T10] Create `.claude/skills/feature-promotion-lifecycle/SKILL.md` as the runtime mirror for `.github/skills/feature-promotion-lifecycle/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/feature-promotion-lifecycle/SKILL.md` remains the canonical authored source.

- [x] [P2-T11] Create `.claude/skills/feature-review-workflow/SKILL.md` as the runtime mirror for `.github/skills/feature-review-workflow/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/feature-review-workflow/SKILL.md` remains the canonical authored source.

- [x] [P2-T12] Create `.claude/skills/pr-base-branch-merge-base/SKILL.md` as the runtime mirror for `.github/skills/pr-base-branch-merge-base/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/pr-base-branch-merge-base/SKILL.md` remains the canonical authored source.

- [x] [P2-T13] Create `.claude/skills/pr-context-artifacts/SKILL.md` as the runtime mirror for `.github/skills/pr-context-artifacts/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/pr-context-artifacts/SKILL.md` remains the canonical authored source.

- [x] [P2-T14] Create `.claude/skills/remediation-handoff-atomic-planner/SKILL.md` as the runtime mirror for `.github/skills/remediation-handoff-atomic-planner/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/remediation-handoff-atomic-planner/SKILL.md` remains the canonical authored source.

- [x] [P2-T15] Create `.claude/skills/csharp-change-budget-router/SKILL.md` as the runtime mirror for `.github/skills/csharp-change-budget-router/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/csharp-change-budget-router/SKILL.md` remains the canonical authored source.

- [x] [P2-T16] Create `.claude/skills/csharp-orchestration-state-machine/SKILL.md` as the runtime mirror for `.github/skills/csharp-orchestration-state-machine/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/csharp-orchestration-state-machine/SKILL.md` remains the canonical authored source.

- [x] [P2-T17] Create `.claude/skills/powershell-change-budget-router/SKILL.md` as the runtime mirror for `.github/skills/powershell-change-budget-router/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/powershell-change-budget-router/SKILL.md` remains the canonical authored source.

- [x] [P2-T18] Create `.claude/skills/powershell-orchestration-state-machine/SKILL.md` as the runtime mirror for `.github/skills/powershell-orchestration-state-machine/SKILL.md`.
  - Acceptance: The file exists and states that `.github/skills/powershell-orchestration-state-machine/SKILL.md` remains the canonical authored source.

- [x] [P2-T19] Create `.claude/skills/make-skill-template/SKILL.md` as the maintenance-only runtime mirror for `.github/skills/make-skill-template/SKILL.md`.
  - Acceptance: The file exists and states that it is maintenance-only and that `.github/skills/make-skill-template/SKILL.md` remains the canonical authored source.

- [x] [P2-T20] Create `.claude/skills/policy-audit-template-usage/SKILL.md` as the maintenance-only runtime mirror for `.github/skills/policy-audit-template-usage/SKILL.md`.
  - Acceptance: The file exists and states that it is maintenance-only and that `.github/skills/policy-audit-template-usage/SKILL.md` remains the canonical authored source.

- [x] [P2-T21] Create `.claude/skills/skill-canonical-location-audit/SKILL.md` as the maintenance-only runtime mirror for `.github/skills/skill-canonical-location-audit/SKILL.md`.
  - Acceptance: The file exists and states that it is maintenance-only and that `.github/skills/skill-canonical-location-audit/SKILL.md` remains the canonical authored source.

- [x] [P2-T22] Verify that `.claude/skills/README.md` does not exist and record that result in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p2-t22.skills-readme-absence.2026-04-12T15-57.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: inspect .claude/skills/README.md absence`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` states `absent` for `.claude/skills/README.md`.

- [x] [P2-T23] Update `.claude/skills/orchestrate/SKILL.md` so it treats the current main session as the orchestrator runtime, does not contain `context: fork`, and does not contain `agent: orchestrator`.
  - Acceptance:
    - `.claude/skills/orchestrate/SKILL.md` does not contain `context: fork`.
    - `.claude/skills/orchestrate/SKILL.md` does not contain `agent: orchestrator`.
    - The file states that the main session reads `artifacts/orchestration/orchestrator-state.json` before worker delegation.

- [x] [P2-T24] Update `.claude/skills/commit-message/SKILL.md` so it remains a direct-use skill bounded to staged-diff inspection and canonical commit-message output only.
  - Acceptance:
    - `.claude/skills/commit-message/SKILL.md` contains `allowed-tools:` entries `Read`, `Bash(git log *)`, and `Bash(git diff *)`.
    - `.claude/skills/commit-message/SKILL.md` references its canonical source.
    - `.claude/skills/commit-message/SKILL.md` does not claim downstream worker orchestration.

- [x] [P2-T25] Update `.claude/skills/pr-author/SKILL.md` so it remains a direct-use skill bounded to `pr_context.summary.txt` and `pr_context.appendix.txt` consumption and PR-body output.
  - Acceptance:
    - `.claude/skills/pr-author/SKILL.md` contains `allowed-tools:` entries `Read` and `Bash(git log *)`.
    - `.claude/skills/pr-author/SKILL.md` references `pr_context.summary.txt` and `pr_context.appendix.txt` explicitly.
    - `.claude/skills/pr-author/SKILL.md` states that its output is a PR body artifact or PR-ready body text only.

- [x] [P2-T26] Update `.claude/skills/research-issue/SKILL.md` so it remains a direct-use skill that writes research output under `artifacts/research/` and does not claim nested worker delegation.
  - Acceptance:
    - `.claude/skills/research-issue/SKILL.md` contains `allowed-tools:` entries `Read`, `Grep`, `Glob`, and `WebFetch`.
    - `.claude/skills/research-issue/SKILL.md` names `artifacts/research/<timestamp>-<short-name>-research.md` as the output path.
    - `.claude/skills/research-issue/SKILL.md` does not claim nested worker delegation.

- [x] [P2-T27] Create `.claude/skills/review-feature/SKILL.md` as the direct-use wrapper for the `feature-review` worker.
  - Acceptance: The file exists and names `feature-review` plus feature-audit output paths.

- [x] [P2-T28] Create `.claude/skills/review-staged/SKILL.md` as the direct-use wrapper for the `staged-review` worker.
  - Acceptance: The file exists and names `staged-review` plus staged-review artifact output paths.

- [x] [P2-T29] Create `.claude/skills/review-epic/SKILL.md` as the direct-use wrapper for the `epic-review` worker.
  - Acceptance: The file exists and names `epic-review` plus epic-audit artifact output paths.

- [x] [P2-T30] Create `.claude/skills/update-status/SKILL.md` as the direct-use wrapper for the `status-updater` worker.
  - Acceptance: The file exists and names `status-updater` plus status-sync output paths.

- [x] [P2-T31] Create `.claude/skills/fill-feature-docs/SKILL.md` as the direct-use wrapper for the `prd-feature` worker.
  - Acceptance: The file exists and names `prd-feature` plus feature-document output paths.

### Phase 3 — Agents, Settings, And Hook Implementation

**Phase Completion Criteria:** Phase 3 is complete only when the bounded worker inventory, settings file, and hook script satisfy the Phase 1 red tests and the baseline settings gaps recorded in `P0-T5` are resolved.

**Evidence Schema Requirement:** Every evidence artifact produced by `P3-T1` must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P3-T1] Verify that `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`, and `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` contain the Phase 1 scenarios, and record the result in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p3-t1.test-scenario-inventory.2026-04-12T15-57.md`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: inspect Claude runtime test files for Phase 1 scenarios`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` cites the three exact test file paths and states whether each Phase 1 scenario is present.

- [x] [P3-T2] Update `.claude/agents/orchestrator.md` so it states that delegation happens from the main thread, preloads the mirrored foundational skills, and references `artifacts/orchestration/orchestrator-state.json` explicitly.
  - Acceptance: `.claude/agents/orchestrator.md` contains the main-thread delegation statement, the checkpoint path, and mirrored skill references.

- [x] [P3-T3] Update `.claude/agents/atomic-planner.md` so it preloads the mirrored plan-contract skills and does not claim nested worker delegation.
  - Acceptance: `.claude/agents/atomic-planner.md` references `atomic-plan-contract` and does not claim nested worker delegation.

- [x] [P3-T4] Update `.claude/agents/atomic-executor.md` so it preloads the mirrored plan-contract skills and names the PowerShell MCP toolchain with `mcp_drmcopilotext_run_poshqc_format`, `mcp_drmcopilotext_run_poshqc_analyze`, and `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: `.claude/agents/atomic-executor.md` contains the three exact MCP function names named in this task.

- [x] [P3-T5] Update `.claude/agents/feature-review.md` so it returns review artifact paths instead of claiming nested remediation worker launches.
  - Acceptance: `.claude/agents/feature-review.md` names artifact outputs and does not claim nested remediation launches.

- [x] [P3-T6] Update `.claude/agents/task-researcher.md` so it writes under `artifacts/research/` and does not claim nested worker delegation.
  - Acceptance: `.claude/agents/task-researcher.md` names `artifacts/research/` and does not claim nested worker delegation.

- [x] [P3-T7] Create `.claude/agents/prd-feature.md` with project-scoped worker frontmatter and feature-doc output expectations.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T8] Create `.claude/agents/staged-review.md` with project-scoped worker frontmatter and staged-review artifact expectations.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T9] Create `.claude/agents/epic-review.md` with project-scoped worker frontmatter and epic-audit artifact expectations.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T10] Create `.claude/agents/status-updater.md` with project-scoped worker frontmatter and status-sync artifact expectations.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T11] Create `.claude/agents/python-typed-engineer.md` with project-scoped worker frontmatter and Python implementation boundaries.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T12] Create `.claude/agents/powershell-typed-engineer.md` with project-scoped worker frontmatter and PowerShell implementation boundaries.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T13] Create `.claude/agents/csharp-typed-engineer.md` with project-scoped worker frontmatter and C# implementation boundaries.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T14] Create `.claude/agents/typescript-engineer.md` with project-scoped worker frontmatter and TypeScript implementation boundaries.
  - Acceptance: The file exists and contains YAML frontmatter with `name`, `description`, `tools`, `model`, `skills`, and `memory: project`.

- [x] [P3-T15] Update `.claude/settings.json` so it contains top-level `agent: "orchestrator"`, the exact `permissions.allow` literals `Bash(git *)`, `Bash(poetry run *)`, `Bash(pwsh *)`, `Read`, `Edit(/docs/**)`, `Write(/docs/**)`, `Write(/artifacts/**)`, and `mcp__drmCopilotExtension__.*`, the exact `permissions.deny` literals `Read(./.env)`, `Read(./.env.*)`, `Read(./secrets/**)`, `Edit(./secrets/**)`, and `Write(./secrets/**)`, the exact `Agent(...)` entries `Agent(atomic-planner)`, `Agent(atomic-executor)`, `Agent(feature-review)`, `Agent(task-researcher)`, `Agent(prd-feature)`, `Agent(staged-review)`, `Agent(epic-review)`, `Agent(status-updater)`, `Agent(python-typed-engineer)`, `Agent(powershell-typed-engineer)`, `Agent(csharp-typed-engineer)`, and `Agent(typescript-engineer)`, the exact `Skill(...)` entries `Skill(orchestrate *)`, `Skill(commit-message *)`, `Skill(pr-author *)`, `Skill(research-issue *)`, `Skill(review-feature *)`, `Skill(review-staged *)`, `Skill(review-epic *)`, `Skill(update-status *)`, and `Skill(fill-feature-docs *)`, plus `hooks.PreToolUse` and `hooks.SubagentStop` coverage for `atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater`.
  - Acceptance:
    - `.claude/settings.json` contains top-level `agent: "orchestrator"`.
    - `.claude/settings.json` contains each exact `permissions.allow` literal named in this task.
    - `.claude/settings.json` contains each exact `permissions.deny` literal named in this task.
    - `.claude/settings.json` contains each exact `Agent(...)` entry named in this task.
    - `.claude/settings.json` contains each exact `Skill(...)` entry named in this task.
    - `.claude/settings.json` contains `hooks.PreToolUse` and the exact `SubagentStop` matcher named in this task.

- [x] [P3-T16] Update `.claude/hooks/validate-bash.ps1` only as needed so it remains aligned with the settings file and still blocks `git push --force`, `git push origin --force`, `git push -f`, `git reset --hard`, `rm -rf`, and `Remove-Item -Recurse -Force`.
  - Acceptance: The script still blocks each exact dangerous pattern named in this task.

### Phase 4 — Green Validation Of Red Tests

**Phase Completion Criteria:** Phase 4 is complete only when every Phase 1 regression task has a corresponding green result recorded under `evidence/qa-gates/` and the regression-testing failures are no longer reproducible.

**Evidence Schema Requirement:** Every evidence artifact produced by `P4-T1` through `P4-T3` must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P4-T1] Run `mcp_drmcopilotext_run_poshqc_test` after the Phase 2 and Phase 3 edits and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t1.claude-runtime-green.2026-04-12T15-57.md` covering the scenarios introduced in `P1-T1`, `P1-T2`, `P1-T3`, and `P1-T4`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: mcp_drmcopilotext_run_poshqc_test`.
    - `EXIT_CODE: 0` is recorded.
    - `Output Summary:` states that the orchestrate-skill, wrapper-skill, settings-routing, and agent-inventory scenarios pass.

- [x] [P4-T2] Run `mcp_drmcopilotext_run_poshqc_test` after the Phase 2 and Phase 3 edits and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md` covering the scenarios introduced in `P1-T5` and `P1-T7`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: mcp_drmcopilotext_run_poshqc_test`.
    - `EXIT_CODE: 0` is recorded.
    - `Output Summary:` states that the architecture-document migration-table and documentation-only-skill scenarios pass.

- [x] [P4-T3] Run `mcp_drmcopilotext_run_poshqc_test` after the Phase 2 and Phase 3 edits and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t3.validate-bash-green.2026-04-12T15-57.md` covering the blocked-command regression scenario introduced in `P1-T6`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: mcp_drmcopilotext_run_poshqc_test`.
    - `EXIT_CODE: 0` is recorded.
    - `Output Summary:` states that all blocked-command scenarios still pass.

### Phase 5 — Runtime Validation Evidence

**Phase Completion Criteria:** Phase 5 is complete only when deterministic evidence exists for structure, settings, documentation, live-session entrypoints, enforcement, and checkpoint resume behavior.

**Evidence Schema Requirement:** Every evidence artifact produced by `P5-T1` through `P5-T6` must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P5-T1] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t1.runtime-structure-validation.2026-04-12T15-57.md` by verifying every exact path named in `Target Implementation Files` and `Target Regression And Validation Test Files`.
  - Acceptance:
    - The artifact contains `PASS` or `FAIL` for each exact path named in `Target Implementation Files` and `Target Regression And Validation Test Files`.
    - The artifact cites the exact file paths inspected.

- [x] [P5-T2] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md` by verifying `.claude/settings.json` entries against the exact literal list `Bash(git *)`, `Bash(poetry run *)`, `Bash(pwsh *)`, `Read`, `Edit(/docs/**)`, `Write(/docs/**)`, `Write(/artifacts/**)`, `mcp__drmCopilotExtension__.*`, `Read(./.env)`, `Read(./.env.*)`, `Read(./secrets/**)`, `Edit(./secrets/**)`, `Write(./secrets/**)`, `Agent(atomic-planner)`, `Agent(atomic-executor)`, `Agent(feature-review)`, `Agent(task-researcher)`, `Agent(prd-feature)`, `Agent(staged-review)`, `Agent(epic-review)`, `Agent(status-updater)`, `Agent(python-typed-engineer)`, `Agent(powershell-typed-engineer)`, `Agent(csharp-typed-engineer)`, `Agent(typescript-engineer)`, `Skill(orchestrate *)`, `Skill(commit-message *)`, `Skill(pr-author *)`, `Skill(research-issue *)`, `Skill(review-feature *)`, `Skill(review-staged *)`, `Skill(review-epic *)`, `Skill(update-status *)`, and `Skill(fill-feature-docs *)`.
  - Acceptance:
    - The artifact records `PASS`, `FAIL`, or `UNVERIFIED` for each exact literal entry named in this task.
    - No `PASS` entry is allowed without citing the exact JSON key path or line text that proves the literal entry exists.

- [x] [P5-T3] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.hook-enforcement-validation.2026-04-12T15-57.md` by verifying `PreToolUse`, `SubagentStop`, and config-change handling boundaries against `.claude/settings.json` and `.claude/hooks/validate-bash.ps1`.
  - Acceptance:
    - The artifact records `PASS`, `FAIL`, or `UNVERIFIED` for each hook boundary named in this task.
    - Any `UNVERIFIED` entry includes blocker evidence.

- [x] [P5-T4] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md` by validating `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, `/review-feature`, `/review-staged`, `/review-epic`, and `/update-status` in a Claude session when the environment allows it.
  - Acceptance:
    - The artifact records each skill as `PASS`, `FAIL`, or `UNVERIFIED`.
    - Any `PASS` entry cites transcript output or captured session text.
    - Any `UNVERIFIED` entry includes blocker evidence.

- [x] [P5-T5] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md` by validating that the main-thread orchestrator reads `artifacts/orchestration/orchestrator-state.json` and resumes from recorded `next_step` when a valid checkpoint exists.
  - Acceptance:
    - The artifact records `PASS`, `FAIL`, or `UNVERIFIED`.
    - Any `PASS` entry cites the checkpoint path and the observed resume behavior.
    - Any `UNVERIFIED` entry includes blocker evidence.

- [x] [P5-T6] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t6.disallowed-agent-validation.2026-04-12T15-57.md` by validating that repository-disallowed personas `mentor`, `api-architect`, `hlbpa`, `5.1-Beast-adjusted`, `5.1-Thinking-Beast-Mode-adjusted`, `gpt-5-beast-mode`, and `voidbeast-gpt41enhanced` are not available through project-scoped automatic routing.
  - Acceptance:
    - The artifact records `PASS`, `FAIL`, or `UNVERIFIED` for each exact excluded persona named in this task.
    - Any `UNVERIFIED` entry includes blocker evidence.

### Phase 6 — Documentation, Migration Maps, And Requirement Closure

**Phase Completion Criteria:** Phase 6 is complete only when `docs/engineering/claude-code-architecture.md`, `v2/spec.md`, and `v2/user-story.md` align with the implemented runtime and the evidence artifacts created in Phases 0–5.

- [x] [P6-T1] Update `docs/engineering/claude-code-architecture.md` so it explicitly states that the migration research file `docs/features/active/2026-04-11-claude-code-architecture-136/20260412-claude-code-github-skills-agents-migration-research.md` is sufficient and that the repository uses a main-thread orchestrator model because Claude subagents cannot spawn subagents.
  - Acceptance: The document contains both exact points named in this task.

- [x] [P6-T2] Update `docs/engineering/claude-code-architecture.md` so it distinguishes repository-canonical bounded workers from excluded personal personas and states that the excluded personas remain out of project-scoped routing.
  - Acceptance: The document contains an explicit excluded-persona statement covering `mentor`, `api-architect`, `hlbpa`, `5.1-Beast-adjusted`, `5.1-Thinking-Beast-Mode-adjusted`, `gpt-5-beast-mode`, and `voidbeast-gpt41enhanced`.

- [x] [P6-T3] Update `docs/engineering/claude-code-architecture.md` so it contains a complete file-by-file `.github/skills` migration table, including explicit rows for `acceptance-criteria-tracking`, `atomic-plan-contract`, `csharp-change-budget-router`, `csharp-orchestration-state-machine`, `evidence-and-timestamp-conventions`, `feature-promotion-lifecycle`, `feature-review-workflow`, `make-skill-template`, `policy-audit-template-usage`, `policy-compliance-order`, `powershell-change-budget-router`, `powershell-orchestration-state-machine`, `pr-base-branch-merge-base`, `pr-context-artifacts`, `remediation-handoff-atomic-planner`, `skill-canonical-location-audit`, and the documentation-only `README.md` row.
  - Acceptance: The table contains one explicit row for each `.github/skills` source named in this task.

- [x] [P6-T4] Update `docs/engineering/claude-code-architecture.md` so it contains a complete file-by-file `.github/agents` disposition table and a direct-use `.github/prompts` migration table aligned with the migration research.
  - Acceptance:
    - The `.github/agents` disposition table contains one explicit row for each of these source files: `5.1-Beast-adjusted.agent.md`, `5.1-Thinking-Beast-Mode-adjusted.agent.md`, `api-architect.agent.md`, `atomic_executor.agent.md`, `atomic_planning.agent.md`, `commentary-remediation.agent.md`, `commit-steward.agent.md`, `csharp-atomic-executor.agent.md`, `csharp-atomic-planning.agent.md`, `csharp-orchestrator.agent.md`, `csharp-typed-engineer.agent.md`, `epic-review.agent.md`, `expert-nextjs-developer.agent.md`, `expert-react-frontend-engineer.agent.md`, `feature-review.agent.md`, `gpt-5-beast-mode.agent.md`, `hlbpa.agent.md`, `mentor.agent.md`, `orchestrator.agent.md`, `Powershell DI Unit Test Engineer.agent.md`, `powershell-atomic-executor.agent.md`, `powershell-atomic-planning.agent.md`, `powershell-orchestrator.agent.md`, `powershell-typed-engineer.agent.md`, `pr-author.agent.md`, `prd-feature.agent.md`, `prd.agent.md`, `pytest-unit-test-coding.agent.md`, `python-atomic-executor.agent.md`, `python-atomic-planning.agent.md`, `python-execution-only-typed.agent.md`, `python-orchestrator.agent.md`, `python-typed-engineer.agent.md`, `staged-review.agent.md`, `status_updater.agent.md`, `task-researcher.agent.md`, `tdd-green.agent.md`, `tdd-red.agent.md`, `tdd-refactor.agent.md`, `typescript-engineer.agent.md`, and `voidbeast-gpt41enhanced.agent.md`.
    - The direct-use `.github/prompts` migration table contains one explicit row for each of these prompt files: `add-educational-comments.prompt.md`, `breakdown-bug-prd.prompt.md`, `breakdown-epic-arch.prompt.md`, `breakdown-epic-pm.prompt.md`, `breakdown-feature-implementation.prompt.md`, `breakdown-feature-prd.prompt.md`, `code-exemplars-blueprint-generator.prompt.md`, `export-chat.prompt.md`, `fillout-prd-feature.prompt.md`, `generate-atomic-plan.prompt.md`, `generate-commit-message-repo.prompt.md`, `generate-pr.prompt.md`, `javascript-typescript-jest.prompt.md`, `orchestrate-csharp-work.prompt.md`, `orchestrate-powershell-work.prompt.md`, `orchestrate-python-work.prompt.md`, `orchestrate-work.prompt.md`, `remediate-comments.prompt.md`, `research-issue.prompt.md`, `review-epic.prompt.md`, `review-feature.prompt.md`, `review-staged.prompt.md`, and `update_status.prompt.md`.

- [x] [P6-T5] Update `docs/engineering/claude-code-architecture.md` so it documents repository-enforceable controls versus managed-settings-only controls and names the `PreToolUse`, `SubagentStop`, and config-change handling boundaries used by this feature.
  - Acceptance: The document contains separate repository-enforceable and managed-settings-only sections and names the three hook/control boundaries exactly.

- [x] [P6-T6] Update only `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` so each checked requirement is backed by at least one named artifact path under `v2/evidence/`, and unresolved live-session items remain unchecked with blocker notes.
  - Acceptance:
    - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` is updated in place.
    - Each checked item corresponds to at least one named artifact path under `v2/evidence/`.
    - Any unresolved live-session validation remains unchecked and includes a blocker note.

- [x] [P6-T7] Update only `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` so each checked requirement is backed by at least one named artifact path under `v2/evidence/`, and unresolved live-session items remain unchecked with blocker notes.
  - Acceptance:
    - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` is updated in place.
    - Each checked item corresponds to at least one named artifact path under `v2/evidence/`.
    - Any unresolved live-session validation remains unchecked and includes a blocker note.

### Phase 7 — Final QA Loop And Preflight Readiness

**Phase Completion Criteria:** Phase 7 is complete only when the PowerShell format, analyze, and test artifacts exist, the final settings inspection artifact exists, the coverage-comparison artifact exists, the final JSON-format artifact exists, the final JSON-validation artifact exists, any reruns are documented, the plan validates structurally, and the executor preflight loop can run against this exact file path.

**Evidence Schema Requirement:** Every evidence artifact produced by `P7-T1` through `P7-T9` must contain `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [x] [P7-T1] Run the final PowerShell formatting pass with `mcp_drmcopilotext_run_poshqc_format` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t1.poshqc-format.2026-04-12T15-57.md`.
  - Acceptance: The artifact contains `Command: mcp_drmcopilotext_run_poshqc_format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P7-T2] Run the final PowerShell analyzer pass with `mcp_drmcopilotext_run_poshqc_analyze` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t2.poshqc-analyze.2026-04-12T15-57.md`.
  - Acceptance: The artifact contains `Command: mcp_drmcopilotext_run_poshqc_analyze`, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P7-T3] Run the final PowerShell test pass with `mcp_drmcopilotext_run_poshqc_test` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t3.poshqc-test.2026-04-12T15-57.md`.
  - Acceptance:
    - The artifact contains `Command: mcp_drmcopilotext_run_poshqc_test`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` reports pass and fail counts and a numeric `Coverage Total:` value.

- [x] [P7-T4] Capture the final settings structure in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t4.settings-json-final.2026-04-12T15-57.md` by reading `.claude/settings.json` and recording the final presence of top-level `agent`, `permissions.allow`, `permissions.deny`, `hooks.PreToolUse`, and `hooks.SubagentStop`.
  - Acceptance:
    - The artifact contains `Command: inspect .claude/settings.json top-level runtime keys via workspace read tool`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` records `present` for top-level `agent`, `permissions.allow`, `permissions.deny`, `hooks.PreToolUse`, and `hooks.SubagentStop`, and cites the exact `permissions.allow` and `permissions.deny` literals required by `P3-T15`.

- [x] [P7-T5] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t5.coverage-comparison.2026-04-12T15-57.md` comparing the numeric baseline coverage from `P0-T8` to the numeric post-change coverage from `P7-T3`, and recording changed/new-code coverage when the test tool exposes it.
  - Acceptance:
    - The artifact contains `Baseline Coverage Total:` with a numeric value copied from `P0-T8`.
    - The artifact contains `Post-Change Coverage Total:` with a numeric value copied from `P7-T3`.
    - The artifact contains `Changed/New-Code Coverage:` with a numeric value or `not available from tool output; remediation required`.
    - The artifact contains `Coverage Disposition:`.

- [x] [P7-T6] Run the final JSON formatting pass for `.claude/settings.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t6.settings-json-format.2026-04-12T15-57.md` using the exact command `poetry run dev.format-json .claude/settings.json`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: poetry run dev.format-json .claude/settings.json`.
    - The artifact contains `EXIT_CODE: 0`.
    - The artifact contains `Output Summary:`.

- [x] [P7-T7] Run the final JSON validation pass for `.claude/settings.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t7.settings-json-validate.2026-04-12T15-57.md` using the exact command `poetry run dev.validate-json .claude/settings.json`.
  - Acceptance:
    - The artifact exists at the exact path named in this task.
    - The artifact contains `Command: poetry run dev.validate-json .claude/settings.json`.
    - The artifact contains `EXIT_CODE: 0`.
    - The artifact contains `Output Summary:`.

- [x] [P7-T8] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t8.qa-rerun-summary.2026-04-12T15-57.md` summarizing the final `P7-T1` through `P7-T7` QA sequence.
  - Acceptance:
    - The artifact contains `Rerun Count: 0` when the first `P7-T1` through `P7-T7` sequence passes cleanly, or a positive rerun count when any step had to be rerun.
    - The artifact contains the final clean `P7-T1` through `P7-T7` sequence.
    - When reruns occurred, `Output Summary:` names each changed or failed step before the final clean loop.

- [x] [P7-T9] Run `validate_orchestration_artifacts` for this exact file path and record the result in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p7-t9.plan-validator.2026-04-12T15-57.md` before handing the plan to `atomic_executor` for preflight-only validation.
  - Acceptance:
    - The artifact contains `Command: validate_orchestration_artifacts(plan, docs/features/active/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md)`.
    - The artifact contains `EXIT_CODE: 0`.
    - `Output Summary:` contains the exact success string `Validated plan artifact at 'docs/features/active/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md'.`.

## Test Plan

- Unit:
  - `tests/scripts/claude-hooks/validate-bash.Tests.ps1`
  - `tests/scripts/claude-runtime/claude-settings.Tests.ps1`
  - `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`
  - `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`
- Integration:
  - Validate the final `.claude/settings.json`, `.claude/skills/`, `.claude/agents/`, and `docs/engineering/claude-code-architecture.md` structure via the Phase 5 and Phase 6 evidence tasks.
- Live-session validation:
  - Record `PASS`, `FAIL`, or `UNVERIFIED` evidence for the skill-entrypoint, enforcement, and checkpoint-resume scenarios in `P5-T4`, `P5-T5`, and `P5-T6`.

## Preflight Handoff Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required retry signal: `PREFLIGHT: REVISIONS REQUIRED`
- Required success signal: `PREFLIGHT: ALL CLEAR`
- Plan-path continuity rule: always reuse `docs/features/active/2026-04-11-claude-code-architecture-136/v2/plan.2026-04-12T15-57.md` for every preflight revision iteration.
