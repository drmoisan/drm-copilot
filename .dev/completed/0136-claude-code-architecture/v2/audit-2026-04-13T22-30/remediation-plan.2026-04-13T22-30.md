---
title: "2026-04-11-claude-code-architecture-136-v2-remediation-loop-6"
issue: 136
owner: "drmoisan"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-13T22-30"
source_of_truth:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T22-30.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T22-30.md"
work_mode_source: "docs/features/active/2026-04-11-claude-code-architecture-136/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
executor_retry_signal: "PREFLIGHT: REVISIONS REQUIRED"
---

# Atomic Remediation Plan - Feature #136 Claude Code architecture v2 loop 6

## Overview

This remediation loop is focused on one repo-controlled defect plus the still-open review gates. The repaired multi-folder `ScanFoldersJson` wrapper transport must remain closed. The current working tree must be brought back into file-structure compliance, changed-scope coverage evidence must be made reviewable, and the remaining live Claude runtime criteria must be validated in a real Claude Code session if one is available.

## Deterministic Inputs

- Remediation requirements: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T22-30.md`
- Supporting scope docs:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Work-mode source: `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`
- Review artifacts:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T22-30.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T22-30.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T22-30.md`
- PR-context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
- Checkpoint artifact:
  - `artifacts/orchestration/orchestrator-state.json`

## Scope Guardrails

- Do not reopen the repaired `ScanFoldersJson` wrapper transport unless new regression evidence proves it is broken.
- Do not widen the public API of `RepoAutomationService` while splitting implementation or test files.
- Do not mark any live Claude-session criterion PASS without transcript-level runtime evidence.
- Do not treat the current changed-scope coverage exception dossier as a PASS substitute without additional evidence or an explicit policy decision.
- Do not skip the repository 500-line file limit for the three touched files identified by the review.

## Requirements Traceability

| Remediation requirement | Remediation tasks |
|---|---|
| Restore file-structure compliance for touched files | P1-T1, P1-T2, P1-T3, P1-T4, P2-T5 |
| Preserve the repaired wrapper contract after file splits | P1-T2, P1-T3, P1-T4, P2-T1, P2-T2, P2-T3, P2-T4 |
| Resolve changed-scope coverage accounting | P2-T6, P2-T7 |
| Refresh the live Claude runtime evidence package | P3-T1 |
| Hand the branch back for review with current context | P3-T2 |

### Phase 0 — Context and Baseline

- [ ] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T22-30.md`, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/phase0-instructions-read.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, `Policy Order:`, the resolved work-mode marker `- Work Mode: full-feature`, and the exact ordered file list.

### Phase 1 — File-Structure Remediation

- [ ] [P1-T1] Record the current line-count baseline for the three touched oversize files and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p1-t1.file-size-baseline.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact line-count command, and the current counts for `repo-automation-service.ts`, `repo-automation-service.test.ts`, and `PoshQC.Tests.ps1`.

- [ ] [P1-T2] Refactor `extensions/drm-copilot/src/repo-automation-service.ts` into focused implementation units so the touched files remain under 500 lines while preserving the current wrapper command contract and public API behavior.
  - Acceptance: No touched implementation file exceeds 500 lines after the refactor, and the `ScanFoldersJson` transport still works exactly as reviewed.

- [ ] [P1-T3] Split `extensions/drm-copilot/test/repo-automation-service.test.ts` into focused test files or suites so every touched TypeScript test file remains under 500 lines while preserving the current regression coverage.
  - Acceptance: The touched TypeScript test files are each under 500 lines and still protect the wrapper transport boundary.

- [ ] [P1-T4] Split `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` into focused PowerShell test files or support files so every touched PowerShell test file remains under 500 lines while preserving the current `Invoke-PoshQCTest` and Koverage regression coverage.
  - Acceptance: The touched PowerShell test files are each under 500 lines and still protect the reviewed scan-folder and coverage-path behavior.

### Phase 2 — Final QA and Coverage Evidence

Restart this phase from [P2-T1] if any command in [P2-T1] through [P2-T7] changes files or fails.

- [ ] [P2-T1] Run `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` in `extensions/drm-copilot` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t1.typescript-format-check.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T2] Run `npm run lint` in `extensions/drm-copilot` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t2.typescript-lint.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T3] Run `npm run typecheck` in `extensions/drm-copilot` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t3.typescript-typecheck.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P2-T4] Run `npx jest extensions/drm-copilot/test/repo-automation-service.test.ts --runInBand` and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path 'tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1','tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1' -Output Detailed"`, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t4.wrapper-regression-tests.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, both exact commands, `EXIT_CODE: 0`, and `Output Summary:` covering passing Jest and Pester counts.

- [ ] [P2-T5] Record the post-remediation line counts for the touched implementation and test files and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t5.file-size-policy-green.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact line-count command, and evidence that every touched file in scope is below 500 lines.

- [ ] [P2-T6] Generate changed-scope TypeScript coverage evidence for `extensions/drm-copilot/src/repo-automation-service.ts` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t6.typescript-coverage-accounting.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact coverage command, and file-level or changed-scope coverage results for the repaired TypeScript service path.

- [ ] [P2-T7] Generate changed-scope PowerShell coverage evidence for the repaired wrapper/runtime files and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t7.powershell-coverage-accounting.2026-04-13T22-30.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact coverage command, and file-level or changed-scope coverage results for the repaired PowerShell wrapper/runtime scope.

### Phase 3 — Live Runtime Validation and Review Handoff

- [ ] [P3-T1] In a real Claude Code session, capture transcript-backed evidence for `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, the live allowlist probe, checkpoint resume, and `SubagentStop`, then write current evidence artifacts under `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/`.
  - Acceptance: The refreshed live-runtime evidence package exists and records transcript-backed PASS or current blocker evidence for all seven remaining runtime criteria.

- [ ] [P3-T2] Refresh PR context against `origin/development`, verify that the Phase 2 and Phase 3 evidence package exists on disk, and hand the branch back for feature review without changing acceptance checkboxes unless the corresponding criteria are fully verified.
  - Acceptance: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are current, the refreshed evidence package exists, and the branch is ready for a new feature-review pass.

## Verification Commands

- `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- `npm run lint`
- `npm run typecheck`
- `npx jest extensions/drm-copilot/test/repo-automation-service.test.ts --runInBand`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path 'tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1','tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1' -Output Detailed"`
- Exact line-count commands for the touched implementation and test files
- Coverage commands that report changed-scope TypeScript and PowerShell results for the repaired files
- `mcp__drmCopilotExtension__collect_pr_context(base='origin/development', workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot')`

## Preflight Handoff Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required retry signal: `PREFLIGHT: REVISIONS REQUIRED`
- Required success signal: `PREFLIGHT: ALL CLEAR`
