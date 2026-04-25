---
issue: 152
parent: none
owner: drmoisan
last_updated: 2026-04-18T15-13
status: Planned
status_color: blue
version: 1.0
work_mode: full-feature
plan_type: remediation
plan_path: docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/remediation-plan.2026-04-18T15-13.md
---

# Remediation Plan: 2026-04-17-bundle-resolve-atomic-plan-prompt-command-152 (2026-04-18T15-13)

- **Issue:** #152
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-18T15-13
- **Status:** Planned
- **Version:** 1.0
- **Authoritative remediation spec:** `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/remediation-inputs.2026-04-18T15-13.md`
- **Work mode source:** `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/issue.md` (`- Work Mode: full-feature`)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Code Change: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- PR summary context: `artifacts/pr_context.summary.txt`
- PR appendix context: `artifacts/pr_context.appendix.txt`

**All work must comply with these policies; do not duplicate their content here.**

## Remediation Objective

Restore PR readiness by removing the remaining touched-file size policy violations in the TypeScript runtime and test scope while preserving the already-fixed runtime contract, regression fidelity, coverage proof, and acceptance state.

## Requirements Traceability

| Requirement ID | Source | Requirement | Planned Coverage |
|---|---|---|---|
| REQ-1 | `remediation-inputs.2026-04-18T15-13.md` item 1 | Reduce `repo-automation-service.ts` to `<= 500` lines without changing behavior. | Phase 1, Phase 3 |
| REQ-2 | `remediation-inputs.2026-04-18T15-13.md` item 2 | Reduce `mcp-tools.ts` to `<= 500` lines without changing tool behavior. | Phase 1, Phase 3 |
| REQ-3 | `remediation-inputs.2026-04-18T15-13.md` item 3 | Split the touched oversized service test file back under the limit without losing coverage. | Phase 2, Phase 3 |
| REQ-4 | `remediation-inputs.2026-04-18T15-13.md` item 4 | Refresh TypeScript QA evidence and superseding review artifacts after the structural split. | Phase 3 |

## Constraint Register

| Constraint ID | Source | Constraint |
|---|---|---|
| CON-1 | `issue.md` work mode marker | Treat `spec.md` and `user-story.md` as authoritative requirement sources because work mode resolves to `full-feature`. |
| CON-2 | `remediation-inputs.2026-04-18T15-13.md` Do Not Do | Do not widen scope into unrelated command-surface, MCP, or Python-runtime refactors. |
| CON-3 | `remediation-inputs.2026-04-18T15-13.md` Do Not Do | Do not weaken or reinterpret the 500-line repository limit. |
| CON-4 | follow-up review findings | Keep the repaired `--workspace` runtime contract and changed-scope coverage behavior intact. |
| CON-5 | test-policy constraints | Preserve deterministic Jest coverage for the command and service boundary while splitting test files. |

## Atomic Implementation Plan

### Phase 0 — Context and TypeScript Baseline Capture

- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `AGENTS.md`, `issue.md`, `spec.md`, `user-story.md`, `plan.2026-04-17T19-54.md`, `remediation-inputs.2026-04-18T15-13.md`, `policy-audit.2026-04-18T15-13.md`, `code-review.2026-04-18T15-13.md`, and `feature-audit.2026-04-18T15-13.md`, then record the ordered read list in `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/remediation-baseline/phase0-instructions-read.2026-04-18T15-13.md`.
  - Acceptance: The artifact exists with `Timestamp:`, `Policy Order:`, `Resolved Work Mode: full-feature`, and the exact ordered file list.

- [x] [P0-T2] Capture TypeScript baseline QA artifacts under `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/remediation-baseline/typescript/` by running `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` from `extensions/drm-copilot/`, saving one artifact per command with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: All four baseline artifacts exist, and the coverage artifact records numeric headline coverage values.

- [x] [P0-T3] Record the current offending line counts in `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/remediation-baseline/p0-t3.line-counts.2026-04-18T15-13.md` by measuring `extensions/drm-copilot/src/repo-automation-service.ts`, `extensions/drm-copilot/src/mcp-tools.ts`, and `extensions/drm-copilot/test/repo-automation-service.test.ts` with `Get-Content <file> | Measure-Object -Line`.
  - Acceptance: The artifact records the exact baseline line counts and identifies each file above 500 lines.

### Phase 1 — Split Oversized TypeScript Production Files

- [x] [P1-T1] Extract helper logic from `extensions/drm-copilot/src/repo-automation-service.ts` into one or more new focused modules under `extensions/drm-copilot/src/` so the touched service file is `<= 500` lines while preserving its exported API and the repaired `resolveAtomicPlanPrompt` runtime behavior.
  - Acceptance: `repo-automation-service.ts` is `<= 500` lines, and the `resolveAtomicPlanPrompt` service contract remains unchanged.

- [x] [P1-T2] Extract tool-family or registration helper logic from `extensions/drm-copilot/src/mcp-tools.ts` into one or more new focused modules under `extensions/drm-copilot/src/` so the touched `mcp-tools.ts` file is `<= 500` lines without changing exported tool behavior.
  - Acceptance: `mcp-tools.ts` is `<= 500` lines, and existing tool registration and dispatch tests still pass.

- [x] [P1-T3] Add or update TypeScript unit tests as needed so the extracted helper logic remains covered without relaxing the current command and tool behavior assertions.
  - Acceptance: The split does not reduce deterministic coverage for the reviewed changed source scope.

### Phase 2 — Split Oversized TypeScript Test Files

- [x] [P2-T1] Move `resolveAtomicPlanPrompt`-specific service tests from `extensions/drm-copilot/test/repo-automation-service.test.ts` into one or more new dedicated `.test.ts` files under `extensions/drm-copilot/test/` so every touched test file in this remediation is `<= 500` lines.
  - Acceptance: `repo-automation-service.test.ts` and all new sibling test files created for this remediation are `<= 500` lines.

- [x] [P2-T2] Preserve or improve diagnostic clarity in the split test files so failures still identify argv, stderr, or tool-registration regressions directly.
  - Acceptance: The split suites still cover `resolveAtomicPlanPrompt` argv forwarding, bundled stderr propagation, and the relevant MCP or template-asset behavior.

- [x] [P2-T3] Run focused Jest regressions from `extensions/drm-copilot/` with `node run-jest.cjs --runTestsByPath test/extension.resolve-atomic-plan-prompt.test.ts test/repo-automation-service.test.ts test/mcp-server.test.ts` and record the result in `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/regression-testing/ts-oversize-remediation.2026-04-18T15-13.md`.
  - Acceptance: The artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` with the passing suite and test totals.

### Phase 3 — Final TypeScript QA and Review Handoff

- [x] [P3-T1] Run the TypeScript toolchain from `extensions/drm-copilot/` in this exact order: `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, saving one final-QA artifact per command under `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/final-qa/typescript/` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
  - Acceptance: All four commands pass in one final clean loop, and the coverage artifact records numeric headline coverage values.

- [x] [P3-T2] Record the post-remediation line counts in `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/evidence/qa-gates/ts-line-count-summary.2026-04-18T15-13.md` and prove that every touched TypeScript file involved in this remediation is `<= 500` lines.
  - Acceptance: The artifact lists each touched file and its final line count, with no remaining value above 500.

- [x] [P3-T3] Produce superseding review artifacts after implementation by creating `policy-audit.<new timestamp>.md`, `code-review.<new timestamp>.md`, and `feature-audit.<new timestamp>.md` in the feature folder.
  - Acceptance: The next review can verify that the touched-file size blocker is closed without reopening the previously resolved runtime and acceptance findings.

## Test Plan

- Focused Jest command and service regressions under `extensions/drm-copilot/test/`
- Full TypeScript QA loop with coverage enabled
- Explicit line-count verification for each touched TypeScript file involved in the remediation

## Open Questions / Notes

- Automatic atomic-planner preflight delegation was not available through the tools exposed in this review session. This fallback remediation plan was drafted directly so the review workflow can still hand off a concrete next-step artifact.
- This plan must still pass schema validation before it is treated as ready for execution.
