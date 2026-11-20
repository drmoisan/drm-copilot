---
title: "2026-04-11-claude-code-architecture-136-v2-remediation-loop-4"
issue: 136
owner: "drmoisan"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-13T11-49"
source_of_truth:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-49.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T11-49.md"
work_mode_source: "docs/features/active/2026-04-11-claude-code-architecture-136/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
executor_retry_signal: "PREFLIGHT: REVISIONS REQUIRED"
---

# Atomic Remediation Plan — Feature #136 Claude Code architecture v2 loop 4

## Overview

This remediation plan is limited to the remaining repo-controlled wrapper defect confirmed by the 2026-04-13T11-49 re-review: the multi-folder `scan_folders` contract is still broken across the bundled PoshQC MCP wrappers. The resolved settings/schema, coverage-output, and stale-token findings must remain closed.

## Deterministic Inputs

- Remediation requirements: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-49.md`
- Supporting scope docs:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Work-mode source: `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`
- Review artifacts:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T11-49.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T11-49.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T11-49.md`
- PR-context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`

## Scope Guardrails

- Do not reopen the resolved settings/schema finding.
- Do not reopen the resolved coverage-output-path finding.
- Do not reopen the resolved stale-token finding.
- Do not broaden scope beyond the multi-folder PoshQC MCP wrapper transport contract and its regression coverage.
- Do not mark any live Claude-session criterion PASS without transcript-level runtime evidence.
- Do not replace the approved live MCP verification commands with undocumented fallback commands in the final QA phase.

## Requirements Traceability

| Remediation requirement | Remediation tasks |
|---|---|
| Restore a single working multi-folder `scan_folders` contract across the bundled PoshQC wrappers | P0-T2, P0-T3, P0-T4, P1-T1, P1-T2, P2-T5, P2-T6, P2-T7 |
| Lock the live wrapper boundary with regression coverage | P1-T3, P1-T4, P2-T4 |

### Phase 0 — Context and Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-49.md`, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/phase0-instructions-read.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, `Policy Order:`, the resolved work-mode marker `- Work Mode: full-feature`, and the exact ordered file list.

- [x] [P0-T2] Reproduce the current multi-folder format-wrapper failure and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t2.poshqc-format-wrapper-baseline.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact `mcp__drmCopilotExtension__run_poshqc_format(...)` command, `EXIT_CODE:` non-zero, and `Failure Excerpt:` containing duplicate `ScanFolders` binding.

- [x] [P0-T3] Reproduce the current multi-folder analyze-wrapper failure and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t3.poshqc-analyze-wrapper-baseline.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact `mcp__drmCopilotExtension__run_poshqc_analyze(...)` command, `EXIT_CODE:` non-zero, and `Failure Excerpt:` containing duplicate `ScanFolders` binding.

- [x] [P0-T4] Reproduce the current multi-folder test-wrapper failure and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t4.poshqc-test-wrapper-baseline.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact `mcp__drmCopilotExtension__run_poshqc_test(...)` command, `EXIT_CODE:` non-zero, and `Failure Excerpt:` containing the combined comma-delimited path failure.

### Phase 1 — Wrapper Contract Repair

- [x] [P1-T1] Define one end-to-end transport contract for multi-folder `scan_folders` that is shared by `extensions/drm-copilot/src/repo-automation-service.ts` and all three bundled PoshQC wrapper scripts, then record the contract decision in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p1-t1.wrapper-contract-decision.2026-04-13T11-49.md`.
  - Acceptance: The artifact explicitly states the chosen encoding/decoding rule for multiple scan roots and names every file that must honor it.

- [x] [P1-T2] Update `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/resources/templates/run-poshqc-format.ps1`, `extensions/drm-copilot/resources/templates/run-poshqc-analyze.ps1`, and `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` to implement the `P1-T1` contract consistently for live multi-folder execution.
  - Acceptance: The four files agree on one multi-folder transport contract, and no wrapper relies on incompatible repeated-parameter or combined-path behavior.

- [x] [P1-T3] Update `extensions/drm-copilot/test/repo-automation-service.test.ts` so the TypeScript regression suite fails before the fix and passes after the fix for the chosen multi-folder contract.
  - Acceptance: The affected Jest tests explicitly protect the wrapper contract implemented in `P1-T2`.

- [x] [P1-T4] Add or update PowerShell regression coverage so the bundled wrapper boundary fails before the fix and passes after the fix for multi-folder transport.
  - Acceptance: The affected PowerShell regression test proves the wrapper side consumes the chosen multi-folder contract correctly.

### Phase 2 — Final QA and Review Handoff

Restart this phase from [P2-T1] if any command in [P2-T1] through [P2-T8] changes files or fails.

- [x] [P2-T1] Run `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` in `extensions/drm-copilot` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t1.typescript-format-check.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T2] Run `npm run lint` in `extensions/drm-copilot` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t2.typescript-lint.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T3] Run `npm run typecheck` in `extensions/drm-copilot` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t3.typescript-typecheck.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P2-T4] Run `npx jest extensions/drm-copilot/test/repo-automation-service.test.ts --runInBand` and `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path 'tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1','tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1' -Output Detailed"`, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t4.wrapper-regression-tests.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, both exact commands, `EXIT_CODE: 0`, and `Output Summary:` covering passing Jest and Pester counts.

- [x] [P2-T5] Run `mcp__drmCopilotExtension__run_poshqc_format(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t5.poshqc-format-wrapper-green.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact MCP command, `EXIT_CODE: 0`, and `Output Summary:` reporting successful formatter execution for all requested folders.

- [x] [P2-T6] Run `mcp__drmCopilotExtension__run_poshqc_analyze(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t6.poshqc-analyze-wrapper-green.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact MCP command, `EXIT_CODE: 0`, and `Output Summary:` reporting analyzer success for all requested folders.

- [x] [P2-T7] Run `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t7.poshqc-test-wrapper-green.2026-04-13T11-49.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact MCP command, `EXIT_CODE: 0`, and `Output Summary:` reporting successful Pester execution for both requested folders.

- [x] [P2-T8] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p2-t8.remediation-summary.2026-04-13T11-49.md` summarizing the fixed wrapper contract, the preserved closed findings, and the remaining environment-only `UNVERIFIED` live Claude-session criteria, then hand the branch back for feature review without changing acceptance checkboxes.
  - Acceptance: The artifact exists and explicitly states that the wrapper defect is closed while the live Claude-session criteria remain `UNVERIFIED` pending transcript-level runtime evidence.

## Verification Commands

- `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
- `npm run lint`
- `npm run typecheck`
- `npx jest extensions/drm-copilot/test/repo-automation-service.test.ts --runInBand`
- `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path 'tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1','tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1' -Output Detailed"`
- `mcp__drmCopilotExtension__run_poshqc_format(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])`
- `mcp__drmCopilotExtension__run_poshqc_analyze(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['scripts/powershell/PoshQC','tests/scripts/powershell/PoshQC','tests/scripts/claude-runtime'])`
- `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`

## Preflight Handoff Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required retry signal: `PREFLIGHT: REVISIONS REQUIRED`
- Required success signal: `PREFLIGHT: ALL CLEAR`
