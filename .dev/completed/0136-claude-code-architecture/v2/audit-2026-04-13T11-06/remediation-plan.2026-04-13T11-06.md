---
title: "2026-04-11-claude-code-architecture-136-v2-remediation-loop-3"
issue: 136
owner: "drmoisan"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-13T11-06"
source_of_truth:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-06.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T11-06.md"
work_mode_source: "docs/features/active/2026-04-11-claude-code-architecture-136/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
executor_retry_signal: "PREFLIGHT: REVISIONS REQUIRED"
---

# Atomic Remediation Plan — Feature #136 Claude Code architecture v2 loop 3

## Overview

This remediation plan is limited to the blockers confirmed by the 2026-04-13T11-06 re-review: the schema-invalid PowerShell test-runner permission entry in `.claude/settings.json`, the failing canonical multi-folder `mcp__drmCopilotExtension__run_poshqc_test` wrapper, and the missing numeric PowerShell coverage evidence. The stale PowerShell symbol correction is already complete and must remain intact.

## Deterministic Inputs

- Remediation requirements: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-06.md`
- Supporting scope docs:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Work-mode source: `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`
- Review artifacts:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T11-06.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T11-06.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T11-06.md`
- PR-context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`

## Scope Guardrails

- Do not reopen the cleared stale-symbol finding unless the repo diff reintroduces it.
- Do not broaden scope beyond the settings/schema contract, the canonical multi-folder PowerShell MCP test wrapper, and numeric PowerShell coverage evidence generation.
- Do not skip `validate_json` or replace the planned final MCP test command with an undocumented fallback in the final QA phase.
- Do not mark live Claude-session criteria PASS without transcript-level runtime evidence.

## Requirements Traceability

| Remediation requirement | Remediation tasks |
|---|---|
| Restore a schema-valid and policy-consistent PowerShell settings contract | P0-T2, P1-T1, P1-T2, P1-T3, P3-T1, P3-T2 |
| Restore the canonical multi-folder PowerShell MCP test wrapper | P0-T3, P2-T1, P2-T2, P3-T3 |
| Produce numeric PowerShell coverage evidence | P0-T4, P2-T3, P2-T4, P3-T4 |
| Return review-ready evidence without overstating live-session proof | P3-T5, P3-T6 |

### Phase 0 — Context and Baseline

- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `AGENTS.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`, and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T11-06.md`, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/phase0-instructions-read.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists with `Timestamp:`, `Policy Order:`, the resolved work-mode marker `- Work Mode: full-feature`, and the exact ordered file list.

- [x] [P0-T2] Capture the current settings/schema contract mismatch in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t2.settings-contract-baseline.2026-04-13T11-06.md` by recording the relevant lines from `.claude/settings.json`, the runtime tests, and the failing `validate_json` output.
  - Acceptance: The artifact exists and includes `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`, `EXIT_CODE: 1`, the failing schema excerpt, and exact path-plus-line anchors for the runtime/test references.

- [x] [P0-T3] Reproduce the canonical multi-folder MCP wrapper failure and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t3.poshqc-test-wrapper-baseline.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists with `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`, `EXIT_CODE:` non-zero, and `Failure Excerpt:` containing `ScanFolders`.

- [x] [P0-T4] Capture the current coverage-output failure in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t4.powershell-coverage-baseline.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists and records `Timestamp:`, `Command: Get-Item artifacts/pester/powershell-coverage.koverage.xml`, the current file size, and the fact that numeric coverage values are unavailable.

### Phase 1 — Settings Contract Repair

- [x] [P1-T1] Determine the authoritative repo-controlled contract for the PowerShell test-runner permission entry by reconciling `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.claude/settings.json`, and the schemastore regex enforced by `validate_json`, then summarize the decision in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p1-t1.settings-contract-decision.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists and explicitly states the chosen schema-valid contract to implement, plus the files that must match it.

- [x] [P1-T2] Update `.claude/settings.json`, `.claude/rules/powershell.md`, `.claude/agents/atomic-executor.md`, `docs/engineering/claude-code-architecture.md`, `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, and `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` so the PowerShell test-runner contract matches the `P1-T1` decision while preserving the cleared stale-symbol status.
  - Acceptance: All six files match the chosen contract, and no reviewed file reintroduces `mcp__drmCopilotExtension__run_poshqc_test` unless `P1-T1` explicitly requires that exact token as the schema-valid contract.

- [x] [P1-T3] Add or update regression coverage so the runtime tests fail on the pre-fix settings/schema contract and pass on the post-fix contract.
  - Acceptance: The affected runtime tests explicitly protect the chosen settings/test-runner contract and continue to reject the retired stale-symbol state.

### Phase 2 — Canonical MCP Test Wrapper and Coverage Repair

- [ ] [P2-T1] Update the repo-controlled wrapper path for `mcp__drmCopilotExtension__run_poshqc_test` so a multi-folder `scan_folders` array is marshalled to PowerShell without duplicate `ScanFolders` binding.
  - Acceptance: The canonical MCP test command reaches Pester execution successfully when given both `tests/scripts/claude-runtime` and `tests/scripts/claude-hooks`.

- [x] [P2-T2] Add or update regression coverage for the multi-folder MCP test wrapper path so the duplicate-`ScanFolders` binding defect is caught by repository tests.
  - Acceptance: A repo-controlled automated test fails before the fix and passes after the fix for the wrapper argument-marshalling case.

- [x] [P2-T3] Repair the PowerShell coverage output path so a passing targeted run emits extractable numeric coverage values in the repo-controlled artifact path.
  - Acceptance: The final targeted PowerShell run produces a non-empty coverage artifact with numeric values that can be cited in an evidence file.

- [x] [P2-T4] Add or update regression coverage for the coverage-output path if any repo-controlled runner or helper logic is changed.
  - Acceptance: The added or updated test fails before the fix and passes after the fix for the coverage-output regression.

### Phase 3 — Final QA and Audit Handoff

Restart this phase from [P3-T1] if any command in [P3-T1] through [P3-T5] changes files or fails.

- [x] [P3-T1] Run `poetry run python -m scripts.dev_tools.format_json .claude/settings.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p3-t1.settings-json-format.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [x] [P3-T2] Run `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p3-t2.settings-json-validation.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P3-T3] Run `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p3-t3.poshqc-test-wrapper-green.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists with `Timestamp:`, the exact MCP command, `EXIT_CODE: 0`, `Output Summary:` reporting passing test counts, and no wrapper fallback note.

- [x] [P3-T4] Capture the final numeric PowerShell coverage state in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p3-t4.powershell-coverage-green.2026-04-13T11-06.md`.
  - Acceptance: The artifact exists and records numeric baseline/post-change/new-code coverage values or explicitly records a concrete repository-approved extraction method that yields those values from the final run.

- [x] [P3-T5] Write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p3-t5.remediation-summary.2026-04-13T11-06.md` summarizing the final command results, the preserved stale-symbol closure, and any remaining live-session verification limits.
  - Acceptance: The artifact exists and clearly states whether the remediation loop is review-ready without claiming live-session criteria PASS.

- [ ] [P3-T6] Hand the updated branch state back for feature review using the new evidence set without creating new acceptance check-offs unless the evidence supports them.
  - Acceptance: The remediation output explicitly references the evidence files produced in [P3-T1] through [P3-T5] and states whether another review is required.

## Verification Commands

- `poetry run python -m scripts.dev_tools.format_json .claude/settings.json`
- `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
- `mcp__drmCopilotExtension__run_poshqc_test(workspace_root='c:\\Users\\DanMoisan\\repos\\drm-copilot', scan_folders=['tests/scripts/claude-runtime','tests/scripts/claude-hooks'])`
- `Get-Item artifacts/pester/powershell-coverage.koverage.xml`

## Preflight Handoff Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required retry signal: `PREFLIGHT: REVISIONS REQUIRED`
- Required success signal: `PREFLIGHT: ALL CLEAR`
