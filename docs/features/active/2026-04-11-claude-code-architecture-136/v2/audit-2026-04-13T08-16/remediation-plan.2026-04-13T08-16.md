---
title: "2026-04-11-claude-code-architecture-136-v2-remediation"
issue: 136
owner: "drmoisan"
work_mode: "full-feature"
status: "Planned"
status_color: "blue"
last_updated: "2026-04-13T08-16"
source_of_truth:
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T08-16.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md"
  - "docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md"
plan_path: "docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-plan.2026-04-13T08-16.md"
work_mode_source: "docs/features/active/2026-04-11-claude-code-architecture-136/issue.md"
work_mode_marker: "- Work Mode: full-feature"
executor_preflight_directive: "DIRECTIVE: PREFLIGHT VALIDATION ONLY"
executor_success_signal: "PREFLIGHT: ALL CLEAR"
executor_retry_signal: "PREFLIGHT: REVISIONS REQUIRED"
---

# Atomic Remediation Plan — Feature #136 Claude Code Architecture v2

## Overview

This remediation plan updates the v2 Claude runtime work only for the four defects enumerated in `remediation-inputs.2026-04-13T08-16.md`. The plan is limited to orchestrator worker delegation, PowerShell MCP naming alignment, version-aware feature-review output guidance, and refreshed post-fix evidence.

## Deterministic Inputs

- Remediation requirements: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/remediation-inputs.2026-04-13T08-16.md`
- Supporting scope docs:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md`
- Work-mode source: `docs/features/active/2026-04-11-claude-code-architecture-136/issue.md`
- Review artifacts:
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T08-16.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T08-16.md`
  - `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T08-16.md`

## Scope Guardrails

- Do not add remediation work outside the four Required Fixes in `remediation-inputs.2026-04-13T08-16.md`.
- Do not weaken documentation to hide a missing runtime capability unless `spec.md` and `user-story.md` support the reduction explicitly.
- Do not mark live Claude runtime criteria PASS without concrete runtime evidence artifacts under the selected `v2` scope.
- Do not create sibling remediation plans or move this plan out of `docs/features/active/2026-04-11-claude-code-architecture-136/v2/`.

## Requirements Traceability

| Remediation requirement | Remediation tasks |
|---|---|
| Expand the orchestrator worker delegation contract | P1-T1, P1-T2, P1-T3, P1-T4, P1-T5, P1-T6, P1-T7 |
| Normalize the PowerShell MCP naming contract across the Claude runtime | P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T7 |
| Make the feature-review runtime instructions version-aware | P3-T1, P3-T2, P3-T3, P3-T4 |
| Refresh live-runtime evidence after contract fixes | P4-T1, P4-T2, P4-T3, P5-T11, P5-T12, P5-T13, P5-T14 |

### Phase 0 — Context & Baseline

- [x] [P0-T1] Read the required policy files in order and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/phase0-instructions-read.*.md`.
  - Acceptance: One matching artifact exists and contains `Timestamp:`, `Policy Order:`, and the exact files read, including `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, and `AGENTS.md`.
- [x] [P0-T2] Read the authoritative remediation inputs, `spec.md`, `user-story.md`, the three v2 review artifacts, and the parent `issue.md`, then write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t2.remediation-scope.*.md`.
  - Acceptance: One matching artifact exists and lists the four Required Fixes, the five Do Not Do constraints, the resolved work mode `full-feature`, and the exact runtime files/tests named by the remediation inputs.
- [x] [P0-T3] Capture baseline JSON validation for `.claude/settings.json` with `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t3.settings-json-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T4] Capture baseline TypeScript format-check state with `npm run format:check` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t4.typescript-format-check-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T5] Capture baseline TypeScript lint state with `npm run lint` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t5.typescript-lint-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T6] Capture baseline TypeScript type-check state with `npm run typecheck` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t6.typescript-typecheck-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T7] Capture baseline TypeScript coverage state with `npm run test:unit:coverage` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t7.typescript-coverage-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:` that records numeric Jest coverage values.
- [x] [P0-T8] Capture baseline PowerShell formatting state with `mcp_drmcopilotext_run_poshqc_format {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t8.poshqc-format-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T9] Capture baseline PowerShell analyzer state with `mcp_drmcopilotext_run_poshqc_analyze {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t9.poshqc-analyze-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P0-T10] Capture baseline PowerShell coverage state with `mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t10.poshqc-test-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}`, `EXIT_CODE:`, and `Output Summary:`. The artifact must either record numeric PowerShell coverage values directly, record the numeric values extracted from the runner-generated coverage artifacts, or explicitly state `CoverageNumericValues: unavailable` plus `CoverageClaimStatus: unresolved` and explain that the PowerShell coverage claim cannot support a PASS outcome.
- [x] [P0-T11] Capture baseline JSON formatting state with `poetry run python -m scripts.dev_tools.format_json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/remediation-baseline/p0-t11.json-format-baseline.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Orchestrator Delegation Contract

- [x] [P1-T1] [expect-fail] Add a regression assertion to `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` that `.claude/agents/orchestrator.md` allows `Agent(prd-feature)`.
  - Acceptance: One matching artifact exists at `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t1.orchestrator-prd-feature.*.md` and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime"]}`, `EXIT_CODE:` with a non-zero value, and `Failure Excerpt:` containing `prd-feature`.
- [x] [P1-T2] [expect-fail] Add a regression assertion to `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` that `.claude/agents/orchestrator.md` allows `Agent(staged-review)`, `Agent(epic-review)`, and `Agent(status-updater)`.
  - Acceptance: One matching artifact exists at `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t2.orchestrator-review-status-workers.*.md` and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime"]}`, `EXIT_CODE:` with a non-zero value, and `Failure Excerpt:` containing at least one of `staged-review`, `epic-review`, or `status-updater`.
- [x] [P1-T3] [expect-fail] Add a regression assertion to `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1` that `.claude/agents/orchestrator.md` allows `Agent(python-typed-engineer)`, `Agent(powershell-typed-engineer)`, `Agent(csharp-typed-engineer)`, and `Agent(typescript-engineer)`.
  - Acceptance: One matching artifact exists at `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p1-t3.orchestrator-language-engineers.*.md` and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime"]}`, `EXIT_CODE:` with a non-zero value, and `Failure Excerpt:` containing at least one of `python-typed-engineer`, `powershell-typed-engineer`, `csharp-typed-engineer`, or `typescript-engineer`.
- [x] [P1-T4] Update `.claude/agents/orchestrator.md` so the tool allowlist includes `Agent(prd-feature)`.
  - Acceptance: `.claude/agents/orchestrator.md` contains `Agent(prd-feature)` exactly once in the orchestrator tool allowlist block.
- [x] [P1-T5] Update `.claude/agents/orchestrator.md` so the tool allowlist includes `Agent(staged-review)`, `Agent(epic-review)`, and `Agent(status-updater)`.
  - Acceptance: `.claude/agents/orchestrator.md` contains each of those three `Agent(...)` entries in the orchestrator tool allowlist block.
- [x] [P1-T6] Update `.claude/agents/orchestrator.md` so the tool allowlist includes the committed language-engineer workers `Agent(python-typed-engineer)`, `Agent(powershell-typed-engineer)`, `Agent(csharp-typed-engineer)`, and `Agent(typescript-engineer)`.
  - Acceptance: `.claude/agents/orchestrator.md` contains each of those four `Agent(...)` entries in the orchestrator tool allowlist block.
- [x] [P1-T7] Update `docs/engineering/claude-code-architecture.md` so the documented main-thread worker inventory matches the final allowlist in `.claude/agents/orchestrator.md`.
  - Acceptance: The worker-inventory section in `docs/engineering/claude-code-architecture.md` names `prd-feature`, `staged-review`, `epic-review`, `status-updater`, `python-typed-engineer`, `powershell-typed-engineer`, `csharp-typed-engineer`, and `typescript-engineer`.

### Phase 2 — PowerShell MCP Naming Contract Alignment

- [x] [P2-T1] [expect-fail] Add a regression assertion to `tests/scripts/claude-runtime/claude-settings.Tests.ps1` that `.claude/settings.json` uses the canonical `mcp_drmcopilotext_run_poshqc_` naming family for the PowerShell tool allowlist.
  - Acceptance: One matching artifact exists at `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p2-t1.settings-powershell-mcp-contract.*.md` and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime"]}`, `EXIT_CODE:` with a non-zero value, and `Failure Excerpt:` containing `mcp_drmcopilotext_run_poshqc_`.
- [x] [P2-T2] [expect-fail] Add a regression assertion to `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` that `.claude/rules/powershell.md`, `.claude/agents/atomic-executor.md`, and `docs/engineering/claude-code-architecture.md` reference the same canonical PowerShell MCP naming family.
  - Acceptance: One matching artifact exists at `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p2-t2.runtime-doc-powershell-mcp-contract.*.md` and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime"]}`, `EXIT_CODE:` with a non-zero value, and `Failure Excerpt:` containing at least one obsolete PowerShell MCP name.
- [x] [P2-T3] Update `.claude/settings.json` so its permission allowlist uses the single canonical PowerShell MCP naming family.
  - Acceptance: `.claude/settings.json` contains the canonical PowerShell MCP pattern and no longer contains the retired PowerShell tool-name family for `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`, or `run_poshqc_analyze_autofix`.
- [x] [P2-T4] Update `.claude/rules/powershell.md` so every instructed PowerShell MCP tool name matches `.claude/settings.json`.
  - Acceptance: `.claude/rules/powershell.md` contains the same canonical PowerShell tool names that appear in `.claude/settings.json`.
- [x] [P2-T5] Update `.claude/agents/atomic-executor.md` so its PowerShell execution guidance names the same canonical PowerShell MCP tools.
  - Acceptance: `.claude/agents/atomic-executor.md` contains the same canonical PowerShell tool names that appear in `.claude/settings.json`.
- [x] [P2-T6] Update `docs/engineering/claude-code-architecture.md` so the architecture walkthrough and enforcement narrative use the same canonical PowerShell MCP naming family.
  - Acceptance: `docs/engineering/claude-code-architecture.md` contains the canonical PowerShell tool-name family and does not contain the retired PowerShell tool-name family for the PoshQC runner names.
- [x] [P2-T7] Revalidate `.claude/settings.json` with `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p2-t7.settings-json-green.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:` confirming JSON validation success.

### Phase 3 — Version-Aware Review Output Paths

- [x] [P3-T1] [expect-fail] Add a regression assertion to `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` that `.claude/agents/feature-review.md` explicitly supports writing review artifacts into the selected version folder `docs/features/active/2026-04-11-claude-code-architecture-136/v2/`.
  - Acceptance: One matching artifact exists at `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/regression-testing/p3-t1.feature-review-version-scope.*.md` and contains `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime"]}`, `EXIT_CODE:` with a non-zero value, and `Failure Excerpt:` containing `v2` or `selected version folder`.
- [x] [P3-T2] Update `.claude/agents/feature-review.md` so its artifact-output instructions target the selected version folder when a versioned feature scope is in use.
  - Acceptance: `.claude/agents/feature-review.md` contains wording that directs output into the selected version folder and no longer states review artifacts always belong in the parent feature root.
- [x] [P3-T3] Inspect `.claude/skills/review-feature/SKILL.md` for a feature-root-only output-path assumption; if present, update it to reference the selected version folder, and if absent, write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p3-t3.review-feature-skill-no-change.*.md` documenting the no-change result.
  - Acceptance: Either `.claude/skills/review-feature/SKILL.md` contains selected-version-folder wording, or one matching no-change artifact exists with `Timestamp:`, `SearchScope: .claude/skills/review-feature/SKILL.md`, `SearchPatterns: feature root only; parent feature root; selected version folder`, `SearchResult: no feature-root-only assumption found`, and `Output Summary:`.
- [x] [P3-T4] Inspect `docs/engineering/claude-code-architecture.md` for a feature-root-only review-path assumption; if present, update it to reference the selected version folder, and if absent, write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/other/p3-t4.architecture-doc-review-path-no-change.*.md` documenting the no-change result.
  - Acceptance: Either `docs/engineering/claude-code-architecture.md` contains selected-version-folder wording for review artifacts, or one matching no-change artifact exists with `Timestamp:`, `SearchScope: docs/engineering/claude-code-architecture.md`, `SearchPatterns: feature root only; parent feature root; selected version folder`, `SearchResult: no feature-root-only assumption found`, and `Output Summary:`.

### Phase 4 — Runtime Evidence Refresh

- [x] [P4-T1] Refresh `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` with `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/development` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t1.pr-context-refresh.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:` that names both refreshed PR-context artifact paths.
- [x] [P4-T2] Resolve the live entry-point evidence branch and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.live-entrypoints.*.md`.
  - Acceptance: One matching artifact exists and contains either `LiveSessionAvailable: yes` plus transcript excerpts for `/orchestrate`, `/commit-message`, `/pr-author`, and `/research-issue`, or `LiveSessionAvailable: no` plus blocker text naming the unavailable Claude runtime surface.
- [x] [P4-T3] Resolve the live enforcement evidence branch and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t3.live-enforcement.*.md`.
  - Acceptance: One matching artifact exists and contains either `LiveSessionAvailable: yes` plus checkpoint-resume, permission-probe, and stop-gate transcript excerpts, or `LiveSessionAvailable: no` plus blocker text naming the unavailable Claude runtime surface.

### Phase 5 — Final QA & Acceptance Reconciliation

Restart this phase from [P5-T1] if any command in [P5-T1] through [P5-T9] changes files or fails.

- [x] [P5-T1] Run PowerShell formatting with `mcp_drmcopilotext_run_poshqc_format {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t1.poshqc-format.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE:`, and `Output Summary:`.
- [x] [P5-T2] Run PowerShell analysis with `mcp_drmcopilotext_run_poshqc_analyze {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.poshqc-analyze.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T3] Run TypeScript formatting with `npm run format` if the remediation changed any npm-managed files, or write a no-change artifact at `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.typescript-format-no-change.*.md` if no npm-managed files changed.
  - Acceptance: Either one matching format-run artifact exists with `Timestamp:`, `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary:`, or one matching no-change artifact exists with `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary: No npm-managed files changed in remediation scope.`
- [x] [P5-T4] Run TypeScript lint with `npm run lint` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.typescript-lint.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T5] Run TypeScript type-check with `npm run typecheck` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.typescript-typecheck.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T6] Run TypeScript coverage validation with `npm run test:unit:coverage` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t6.typescript-coverage.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:` that records numeric Jest coverage values.
- [x] [P5-T7] Run PowerShell coverage validation with `mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t7.poshqc-test.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, `Command: mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}`, `EXIT_CODE: 0`, and `Output Summary:`. The artifact must either record numeric PowerShell coverage values directly, record the numeric values extracted from the runner-generated coverage artifacts, or explicitly state `CoverageNumericValues: unavailable` plus `CoverageClaimStatus: unresolved` and explain that the PowerShell coverage claim cannot support a PASS outcome.
- [x] [P5-T8] Run JSON formatting with `poetry run python -m scripts.dev_tools.format_json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t8.json-format.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T9] Revalidate `.claude/settings.json` with `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json` and write `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t9.settings-json-validation.*.md`.
  - Acceptance: One matching artifact exists with `Timestamp:`, the exact command, `EXIT_CODE: 0`, and `Output Summary:`.
- [x] [P5-T10] Compare baseline and final coverage in `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t10.coverage-comparison.*.md`.
  - Acceptance: One matching artifact exists and records `TypeScriptBaselineCoverage:` and `TypeScriptFinalCoverage:` from [P0-T7] and [P5-T6] when applicable, `PowerShellBaselineCoverage:` and `PowerShellFinalCoverage:` from [P0-T10] and [P5-T7] when applicable, and changed/new-code coverage values for each applicable language when available. The artifact must explicitly state whether repository-wide coverage remains at or above the required threshold, whether changed-code coverage and no-regression claims are satisfied, and, when changed/new-code coverage cannot be produced, record `ChangedNewCodeCoverage: unavailable` plus `AcceptanceClaimStatus: unresolved/remediation-required` for the affected coverage claim.
- [x] [P5-T11] Update `docs/features/active/2026-04-11-claude-code-architecture-136/v2/policy-audit.2026-04-13T08-16.md` to replace the resolved contract findings with citations to the new remediation evidence.
  - Acceptance: The updated policy audit cites the P1-P5 evidence artifacts for the three contract fixes and does not report a resolved item as open.
- [x] [P5-T12] Update `docs/features/active/2026-04-11-claude-code-architecture-136/v2/code-review.2026-04-13T08-16.md` to close or narrow the three remediation findings based on the new runtime evidence.
  - Acceptance: The updated code review cites the P1-P5 evidence artifacts and leaves only findings that are still supported by current evidence.
- [x] [P5-T13] Update `docs/features/active/2026-04-11-claude-code-architecture-136/v2/feature-audit.2026-04-13T08-16.md` so live-runtime criteria remain `UNVERIFIED` unless [P4-T2] and [P4-T3] captured real runtime transcripts.
  - Acceptance: The updated feature audit cites [P4-T2] and [P4-T3] exactly and does not mark a live-runtime criterion `PASS` without a matching runtime artifact.
- [x] [P5-T14] Update `docs/features/active/2026-04-11-claude-code-architecture-136/v2/spec.md` and `docs/features/active/2026-04-11-claude-code-architecture-136/v2/user-story.md` checkbox states only for criteria backed by current evidence.
  - Acceptance: Every checkbox state change in `spec.md` or `user-story.md` is supported by at least one cited artifact from [P1-T1] through [P5-T13], and any criterion that still depends on unavailable live-runtime evidence remains unchecked.

## Verification Commands

- `poetry run python -m scripts.dev_tools.validate_json .claude/settings.json`
- `npm run format:check`
- `npm run lint`
- `npm run typecheck`
- `npm run test:unit:coverage`
- `poetry run python -m scripts.dev_tools.format_json`
- `mcp_drmcopilotext_run_poshqc_format {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}`
- `mcp_drmcopilotext_run_poshqc_analyze {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}`
- `mcp_drmcopilotext_run_poshqc_test {"workspace_root":"c:\\Users\\DanMoisan\\repos\\drm-copilot","scan_folders":["tests/scripts/claude-runtime","tests/scripts/claude-hooks"]}`
- `poetry run python -m scripts.dev_tools.pr_context.collector --base origin/development`

## Preflight Handoff Contract

- Directive to send to the executor: `DIRECTIVE: PREFLIGHT VALIDATION ONLY`
- Required retry signal: `PREFLIGHT: REVISIONS REQUIRED`
- Required success signal: `PREFLIGHT: ALL CLEAR`
