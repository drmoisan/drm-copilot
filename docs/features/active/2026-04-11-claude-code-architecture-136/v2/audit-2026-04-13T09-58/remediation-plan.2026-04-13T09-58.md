---
title: "2026-04-11-claude-code-architecture-136-v2-remediation"
issue: 136
owner: "drmoisan"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-13T09-58"
source_of_truth:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T09-58.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T09-58.md"
work_mode_source: "docs/features/active/2026-04-11-claude-code-architecture-136/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
executor_retry_signal: "PREFLIGHT: REVISIONS REQUIRED"
---

# Atomic Remediation Plan — Feature #136 Claude Code architecture v2

## Overview

This remediation plan is limited to the remaining issues identified by the post-remediation re-audit dated `2026-04-13T09-58`: the stale PowerShell test-runner MCP symbol, the runtime tests that codify that stale symbol, and the evidence refresh needed to prove the corrected contract without overstating live Claude-session coverage. The remediation order is red-first: update the scoped runtime regression tests, record the expected failing PowerShell run, correct the runtime contract files, and then refresh the post-fix evidence.

## Deterministic Inputs

- Remediation requirements: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T09-58.md`
- Supporting scope docs:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Work-mode source: `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`
- Review artifacts:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T09-58.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T09-58.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T09-58.md`

## Scope Guardrails

- Do not widen scope beyond the PowerShell test-runner contract mismatch, the affected runtime tests, and the evidence refresh required to prove the correction.
- Do not change the PowerShell format/analyze/autofix tool names unless the authoritative policy files explicitly require it.
- Do not mark live Claude-session criteria PASS without transcript-level runtime evidence.
- Do not create sibling remediation plans outside this `v2` folder.

## Requirements Traceability

| Remediation requirement | Remediation tasks |
|---|---|
| Correct the PowerShell test-runner MCP contract in the Claude runtime | P2-T1, P2-T2, P2-T3, P2-T4 |
| Update the runtime regression tests to assert the active PowerShell policy contract | P1-T1, P1-T2, P1-T3, P1-T4, P1-T5 |
| Refresh post-fix evidence for the corrected PowerShell contract | P0-T3, P0-T4, P0-T5, P0-T6, P0-T7, P0-T8, P4-T1, P4-T2, P4-T3, P4-T4, P4-T5, P4-T6, P4-T7 |
| Keep live Claude-session criteria explicit and honest | P4-T10 |

### Phase 0 — Context & Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T09-58.md`, then record the read order in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/phase0-instructions-read.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Policy Order:`, the resolved work-mode marker `- Work Mode: full-feature`, and each required file in the exact order read.
- [x] [P0-T2] Read `spec.md`, `user-story.md`, the three `2026-04-13T09-58` review artifacts, and the four runtime files named in Required Fix 1, then summarize the allowed scope in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t2.remediation-scope.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and lists the four Required Fixes, the four Do Not Do bullets, the exact runtime files, and the exact runtime test files from the remediation inputs.
- [x] [P0-T3] Capture a baseline symbol inventory in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t3.powershell-test-symbol-baseline.2026-04-13T09-58.md` that records every occurrence of `mcp__drmCopilotExtension__run_poshqc_test` and `mcp_drmcopilotext_run_poshqc_test` in `.claude/`, `docs/engineering/claude-code-architecture.md`, and `tests/scripts/claude-runtime/`.
  - Acceptance: The artifact exists and records exact paths and line locations for both symbol variants.
- [x] [P0-T4] Run `poetry run python -m scripts.dev_tools.format_json .claude/settings.json` and write the baseline result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t4.settings-json-format-baseline.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.format_json .claude/settings.json`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T5] Run `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` and write the baseline result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t5.settings-json-baseline.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T6] Run `mcp_drmcopilotext_run_poshqc_format` with workspace root `c:\Users\DanMoisan\repos\drm-copilot` and scan folders `.claude/hooks`, `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks`, then write the baseline result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t6.poshqc-format-baseline.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_format(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T7] Run `mcp_drmcopilotext_run_poshqc_analyze` with workspace root `c:\Users\DanMoisan\repos\drm-copilot` and scan folders `.claude/hooks`, `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks`, then write the baseline result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t7.poshqc-analyze-baseline.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_analyze(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T8] Run `mcp_drmcopilotext_run_poshqc_test` with workspace root `c:\Users\DanMoisan\repos\drm-copilot` and scan folders `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks`, then write the baseline result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t8.poshqc-test-baseline.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE:`, and `Output Summary:`. The artifact must also record numeric PowerShell coverage values or explicitly include `CoverageNumericValues: unavailable` plus a concrete reason.

### Phase 1 — Runtime Regression Tests (Red)

- [x] [P1-T1] Update `tests/scripts/claude-runtime/claude-settings.Tests.ps1` so the `.claude/settings.json` contract assertion requires `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: `tests/scripts/claude-runtime/claude-settings.Tests.ps1` contains `mcp_drmcopilotext_run_poshqc_test` in the settings-contract assertion and no longer treats `mcp__drmCopilotExtension__run_poshqc_test` as the required test-runner symbol.
- [x] [P1-T2] Update `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` so the `.claude/rules/powershell.md` contract assertion requires `mcp_drmcopilotext_run_poshqc_test` for the test runner while preserving the active format, analyze, and autofix contract.
  - Acceptance: The test scenario for `.claude/rules/powershell.md` checks for `mcp_drmcopilotext_run_poshqc_test` and continues to assert the still-authorized companion symbols from the policy source.
- [x] [P1-T3] Update `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` so the `.claude/agents/atomic-executor.md` contract assertion requires `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: The test scenario for `.claude/agents/atomic-executor.md` checks for `mcp_drmcopilotext_run_poshqc_test` and no longer expects the retired test-runner symbol.
- [x] [P1-T4] Update `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` so the `docs/engineering/claude-code-architecture.md` contract assertion requires `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: The test scenario for `docs/engineering/claude-code-architecture.md` checks for `mcp_drmcopilotext_run_poshqc_test` and no longer expects the retired test-runner symbol.
- [x] [P1-T5] [expect-fail] Run `mcp_drmcopilotext_run_poshqc_test` with workspace root `c:\Users\DanMoisan\repos\drm-copilot` and scan folders `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks` after [P1-T1] through [P1-T4], then write the expected failing result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t5.powershell-runtime-contract-red.2026-04-13T09-58.md`.
  - Acceptance: The MCP test run is expected to fail, and the artifact exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE:` set to a non-zero value, `Output Summary:`, and `Failure Excerpt:` containing `mcp__drmCopilotExtension__run_poshqc_test`.

### Phase 2 — Runtime Contract Correction

- [x] [P2-T1] Update `.claude/settings.json` so the PowerShell test-runner permission entry uses `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: `.claude/settings.json` contains `mcp_drmcopilotext_run_poshqc_test` and no longer contains `mcp__drmCopilotExtension__run_poshqc_test`.
- [x] [P2-T2] Update `.claude/rules/powershell.md` so the testing command reference uses `mcp_drmcopilotext_run_poshqc_test` while leaving any still-authorized format/analyze/autofix symbols aligned with the policy source.
  - Acceptance: The testing bullet matches the authoritative PowerShell policy files.
- [x] [P2-T3] Update `.claude/agents/atomic-executor.md` so the PowerShell test-runner guidance uses `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: The tool list and narrative both use the corrected test symbol.
- [x] [P2-T4] Update `docs/engineering/claude-code-architecture.md` so the PowerShell test-runner reference uses `mcp_drmcopilotext_run_poshqc_test`.
  - Acceptance: The architecture walkthrough no longer references the stale PowerShell test symbol.

### Phase 4 — Final QA & Acceptance Reconciliation

Restart this phase from [P4-T1] if any command in [P4-T1] through [P4-T5] changes files or fails.

- [x] [P4-T1] Run `mcp_drmcopilotext_run_poshqc_format` with workspace root `c:\Users\DanMoisan\repos\drm-copilot` and scan folders `.claude/hooks`, `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks`, then write the result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t1.poshqc-format.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_format(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P4-T2] Run `poetry run python -m scripts.dev_tools.format_json .claude/settings.json` and write the result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.settings-json-format.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.format_json .claude/settings.json`, `EXIT_CODE: 0`, and `Output Summary:`.
- [ ] [P4-T3] Run `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` and write the result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t3.settings-json-validation.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P4-T4] Run `mcp_drmcopilotext_run_poshqc_analyze` with workspace root `c:\Users\DanMoisan\repos\drm-copilot` and scan folders `.claude/hooks`, `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks`, then write the result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t4.poshqc-analyze.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_analyze(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE: 0`, and `Output Summary:` confirming no targeted analyzer findings remain.
- [x] [P4-T5] Run `mcp_drmcopilotext_run_poshqc_test` with workspace root `c:\Users\DanMoisan\repos\drm-copilot` and scan folders `tests/scripts/claude-runtime`, `tests/scripts/claude-hooks`, then write the result to `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t5.poshqc-test.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE: 0`, and `Output Summary:` with the targeted pass/fail totals. The artifact must also record numeric PowerShell coverage values or explicitly include `CoverageNumericValues: unavailable` plus a concrete reason. If `CoverageNumericValues: unavailable` is recorded, the artifact must also include `CoverageGateStatus: BLOCKED`.
- [x] [P4-T6] Capture the post-fix symbol inventory in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t6.powershell-test-symbol-green.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and records exact paths and line locations showing `mcp_drmcopilotext_run_poshqc_test` in `.claude/settings.json`, `.claude/rules/powershell.md`, `.claude/agents/atomic-executor.md`, `docs/engineering/claude-code-architecture.md`, and the two runtime test files, and it records zero stale-symbol matches in those six files.
- [x] [P4-T7] Compare the baseline and final PowerShell contract evidence in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t7.powershell-coverage-comparison.2026-04-13T09-58.md`.
  - Acceptance: The artifact exists and records `PowerShellBaselineCoverage:` from [P0-T8], `PowerShellFinalCoverage:` from [P4-T5], `ChangedNewCodeCoverage:`, and `CoverageGateStatus: PASS|BLOCKED`. If any required numeric value is unavailable, the artifact must include `CoverageGateStatus: BLOCKED`, set each unavailable value explicitly to `unavailable`, and record a concrete `CoverageBlockReason:`. If all required numeric values are present, the artifact must include `CoverageGateStatus: PASS`.
- [x] [P4-T8] Create a superseding `policy-audit.*.md` artifact in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/` that cites the refreshed QA evidence for the corrected PowerShell test-runner contract.
  - Acceptance: A `policy-audit.*.md` file newer than `policy-audit.2026-04-13T09-58.md` exists in the `v2` folder, cites [P4-T1] through [P4-T7], does not report `mcp__drmCopilotExtension__run_poshqc_test` as an open finding, and when [P4-T7] records `CoverageGateStatus: BLOCKED`, carries the coverage gap forward as an open finding or `UNVERIFIED` with a concrete reason.
- [x] [P4-T9] Create a superseding `code-review.*.md` artifact in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/` that cites the refreshed QA evidence for the corrected PowerShell test-runner contract.
  - Acceptance: A `code-review.*.md` file newer than `code-review.2026-04-13T09-58.md` exists in the `v2` folder, cites [P4-T1] through [P4-T7], does not report `mcp__drmCopilotExtension__run_poshqc_test` as an open finding, and when [P4-T7] records `CoverageGateStatus: BLOCKED`, carries the coverage gap forward as an open finding or `UNVERIFIED` with a concrete reason.
- [x] [P4-T10] Create a superseding `feature-audit.*.md` artifact in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/` that cites the refreshed QA evidence without overstating live Claude-session coverage.
  - Acceptance: A `feature-audit.*.md` file newer than `feature-audit.2026-04-13T09-58.md` exists in the `v2` folder, cites [P4-T1] through [P4-T7], leaves any criterion covering `/orchestrate`, `/commit-message`, `/pr-author`, `/research-issue`, checkpoint-resume, allowlist-probe, or `SubagentStop` as `UNVERIFIED` unless the same file cites runtime transcript evidence under `evidence/qa-gates/`, and when [P4-T7] records `CoverageGateStatus: BLOCKED`, carries the coverage gap forward as an open finding or `UNVERIFIED` with a concrete reason.

## Verification Commands

- `poetry run python -m scripts.dev_tools.format_json .claude/settings.json`
- `mcp_drmcopilotext_run_poshqc_format(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`
- `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
- `mcp_drmcopilotext_run_poshqc_analyze(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['.claude/hooks','tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`
- `mcp_drmcopilotext_run_poshqc_test(workspace_root='c:\Users\DanMoisan\repos\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`

## Preflight Handoff Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required retry signal: `PREFLIGHT: REVISIONS REQUIRED`
- Required success signal: `PREFLIGHT: ALL CLEAR`
