# Remediation: github-instructions-not-migrated-to-claude (#151) — Feature-vs-Base Findings

- **Issue:** #151
- **Parent (optional):** N/A
- **Owner:** atomic_planner
- **Last Updated:** 2026-04-18T18-50
- **Status:** scaffold (pending atomic_planner delegation)
- **Version:** 1.0
- **Work Mode:** full-bug (feature-review remediation, not a new feature)

## Overview

Address blocking and high-severity findings from the feature-vs-base audit completed at 2026-04-18T18-50. The originating feature-review artifacts are:

- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/policy-audit.2026-04-18T18-50.md`
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/code-review.2026-04-18T18-50.md`
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/feature-audit.2026-04-18T18-50.md`
- `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-inputs.2026-04-18T18-50.md` (authoritative fix list)

All 13 acceptance criteria from `spec.md` are PASS. This remediation does NOT reopen AC work. It addresses feature-vs-base findings that the `feature-review-workflow` SKILL Scope Invariant requires the reviewer to audit.

## Required References

- General Code Change Policy: `.github/instructions/general-code-change.instructions.md`
- General Unit Test Policy: `.github/instructions/general-unit-test.instructions.md`
- PowerShell Policies: `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`
- TypeScript Policies: `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`
- Python Policies: `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`
- Tonality Policy: `.github/instructions/tonality.instructions.md`
- Remediation Inputs (authoritative fix list): `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-inputs.2026-04-18T18-50.md`

**All work must comply with these policies; do not duplicate their content here.**

## Constraints

- Do NOT modify `.github/instructions/*.md` policy files.
- Do NOT weaken coverage thresholds in `.claude/rules/`.
- Do NOT reintroduce plan-scope narrowing in any audit artifact.
- Do NOT create temporary files in tests; Pester additions must avoid `New-TemporaryFile` and filesystem-touching fixtures.
- All added/modified source and test files must remain under 500 lines.
- Do NOT combine remediation with new feature work.
- Do NOT merge the PR until R-1/R-2 (coverage), R-3, R-4, R-5 are green or explicitly deferred with a documented follow-up issue.

## Scope of Remediation (from remediation-inputs.2026-04-18T18-50.md)

| Ref | Severity | Summary |
|---|---|---|
| R-1 | Blocker | Pester tests for two new `.claude/hooks/*.ps1` files; regenerate Pester coverage artifact to reflect HEAD |
| R-2 | Blocker (alternative) | Scope PowerShell coverage measurement via Pester config to exclude bootstrap/wrapper scripts |
| R-3 | High | Refactor `extensions/drm-copilot/src/mcp-tools.ts` to <= 500 lines |
| R-4 | High | Refactor `extensions/drm-copilot/src/repo-automation-service.ts` to <= 500 lines |
| R-5 | High | Resolve Python mirror-coverage verification gap (Option A: combined lcov, Option B: parity tests + documentation) |
| R-6 | Medium | Split `extensions/drm-copilot/test/repo-automation-service.test.ts` |
| R-7 | Medium | Regenerate stale/missing toolchain evidence artifacts (TS + PowerShell) |
| R-8 | Medium | Tighten MCP dispatch invariant message and extract default output constant |

## Suggested Phase Skeleton

The atomic_planner is the authoritative author of the final plan. The scaffold below reflects the suggested structure from remediation-inputs.

### Phase 0 — Baseline Capture

- [ ] [P0-T1] Read all policy files listed in Required References; capture policy-reading evidence.
- [ ] [P0-T2] Record baseline coverage state at HEAD `b749258`: TypeScript (`coverage/lcov.info`), Python (`artifacts/python/lcov.info`), PowerShell (`artifacts/pester/powershell-coverage.xml` — note stale).
- [ ] [P0-T3] Record baseline file line counts for `mcp-tools.ts`, `repo-automation-service.ts`, `repo-automation-service.test.ts`.
- [ ] [P0-T4] Enumerate the two new PS1 hook files and the existing Pester test layout used by `validate-bash.ps1` tests.

### Phase 1 — PowerShell Coverage (R-1, optional R-2)

- [ ] [P1-T1] Create Pester test file for `.claude/hooks/check-python-test-purity.ps1` covering all forbidden-pattern categories and envelope cases from remediation-inputs R-1.
- [ ] [P1-T2] Create Pester test file for `.claude/hooks/enforce-python-batch-budget.ps1` covering budget enforcement, session counter, and envelope cases from remediation-inputs R-1.
- [ ] [P1-T3] If required, update Pester coverage-scoping configuration per remediation-inputs R-2 with inline rationale for each exclusion.
- [ ] [P1-T4] Regenerate `artifacts/pester/powershell-coverage.xml` at HEAD via `mcp__drmCopilotExtension__run_poshqc_test`.
- [ ] [P1-T5] Verify: repo-wide PowerShell LINE coverage >= 80% and both new hook files >= 90%.

### Phase 2 — TypeScript File-Size (R-3, R-4)

- [ ] [P2-T1] Extract dispatcher cases from `extensions/drm-copilot/src/mcp-tools.ts` into new handler modules under `extensions/drm-copilot/src/mcp-handlers/`. Confirm `wc -l` <= 500.
- [ ] [P2-T2] Extract argument-assembly helpers from `extensions/drm-copilot/src/repo-automation-service.ts` into `extensions/drm-copilot/src/repo-automation-args.ts`. Confirm `wc -l` <= 500.
- [ ] [P2-T3] Run `npm run format:check && npm run lint && npm run type-check && npm run test:unit:coverage`. All must pass. Record results in `artifacts/evidence/post-change/<ts>/post-change-{prettier,eslint,tsc,jest}.md`.

### Phase 3 — Python Mirror Coverage (R-5)

- [ ] [P3-T1] Choose option A or B per remediation-inputs. If A: extend coverage-source paths in `pyproject.toml` or `.coveragerc`. If B: add parity tests + document the sync-and-parity model.
- [ ] [P3-T2] Regenerate `artifacts/python/lcov.info` (Option A) or land parity tests (Option B).
- [ ] [P3-T3] Verify mirror per-file coverage >= 80% (Option A) or parity-test suite passes (Option B).

### Phase 4 — Test-File Split (R-6)

- [ ] [P4-T1] Split `extensions/drm-copilot/test/repo-automation-service.test.ts` into smaller per-behavior test files. Each <= 500 lines.
- [ ] [P4-T2] Run `npm run test:unit:coverage` and confirm coverage >= baseline.

### Phase 5 — Evidence Capture (R-7)

- [ ] [P5-T1] Run full TypeScript toolchain and persist result files to `artifacts/evidence/post-change/<ts>/`.
- [ ] [P5-T2] Run PSScriptAnalyzer and Invoke-Formatter over PS1 hook files; persist results.
- [ ] [P5-T3] Re-generate `artifacts/pester/powershell-coverage.xml` at HEAD.

### Phase 6 — MCP Dispatch Polish (R-8)

- [ ] [P6-T1] Update `resolveExecuteHardLockPrompt` thrown error message to reference MCP tool name.
- [ ] [P6-T2] Extract `"artifacts/hard_lock_prompt.txt"` into module-top named constant; update case to use it.
- [ ] [P6-T3] Update or add TS tests that assert the error message contents and constant usage.

### Phase 7 — Final Verification

- [ ] [P7-T1] Run all language toolchains end-to-end. All pass.
- [ ] [P7-T2] Re-run the feature-review workflow to produce a fresh set of review artifacts. Confirm policy-audit reports no FAIL verdicts.
- [ ] [P7-T3] Update plan checkboxes to `[x]` and mark `Status: delivered`.

## Handoff Instructions

This file is a scaffold. The orchestrator or reviewer must delegate plan authorship to the `atomic_planner` subagent via the `remediation-handoff-atomic-planner` skill, passing:

- `${spec}` → `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-inputs.2026-04-18T18-50.md`
- `${file}` → `docs/features/active/2026-04-17-github-instructions-not-migrated-to-claude-151/remediation-plan.2026-04-18T18-50.md` (this file)
- Context package: the three audit artifacts at the 2026-04-18T18-50 timestamp.

The `atomic_planner` is expected to replace this scaffold with deterministic, atomic tasks that carry `[P#-T#]` IDs and per-task acceptance statements, per the `atomic-plan-contract` SKILL.

## Status

- Scaffold created: 2026-04-18T18-50 by feature-review-workflow (remediation trigger).
- Awaiting atomic_planner authorship.
- Do not execute the plan until the atomic_planner has replaced this scaffold with atomic tasks and marked Status as `approved`.
