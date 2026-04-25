# Remediation Inputs: bundle-resolve-atomic-plan-prompt-command (#152)

Timestamp: 2026-04-18T15-13
Feature Folder: `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152`
Base Branch: `origin/development`
Head Branch: `feature/bundle-resolve-atomic-plan-prompt-command-152`
Primary Requirements Source: `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/policy-audit.2026-04-18T15-13.md`

## Scope Summary

This remediation loop addresses the only blocker remaining after the follow-up re-review: the reviewed branch leaves three touched TypeScript files above the repository's 500-line hard limit. The runtime contract, regression fidelity, changed-scope coverage proof, and requirement synchronization blockers are already closed and must remain closed.

Verified blocker summary:
- `extensions/drm-copilot/src/repo-automation-service.ts` is 502 lines after the feature and crossed the 500-line limit from a 485-line merge-base state.
- `extensions/drm-copilot/test/repo-automation-service.test.ts` is 544 lines after the feature and crossed the 500-line limit from a 487-line merge-base state.
- `extensions/drm-copilot/src/mcp-tools.ts` was already oversized at merge-base and was expanded further from 537 to 559 lines.

## Enumerated Fix List

1. **Split `repo-automation-service.ts` back under the 500-line repository limit without changing public behavior.**
   - Files in scope:
     - `extensions/drm-copilot/src/repo-automation-service.ts`
     - one or more new helper modules under `extensions/drm-copilot/src/`
   - Current defect:
     - The touched service file is 502 lines and violates the repository file-size rule.
   - Expected behavior:
     - The service keeps the same exported API and the same `resolveAtomicPlanPrompt` and policy-audit template behavior, but the touched file itself returns to `<= 500` lines.
   - Acceptance criteria:
     - `repo-automation-service.ts` is `<= 500` lines.
     - Public command and MCP behavior stay unchanged.
   - Verification commands:
     - `Get-Content extensions/drm-copilot/src/repo-automation-service.ts | Measure-Object -Line`
     - `Push-Location extensions/drm-copilot; node run-jest.cjs --runTestsByPath test/extension.resolve-atomic-plan-prompt.test.ts test/repo-automation-service.test.ts; Pop-Location`

2. **Split `mcp-tools.ts` so the touched file no longer remains above the 500-line limit.**
   - Files in scope:
     - `extensions/drm-copilot/src/mcp-tools.ts`
     - one or more new helper modules under `extensions/drm-copilot/src/`
   - Current defect:
     - The feature expanded an already oversized touched file from 537 lines to 559 lines.
   - Expected behavior:
     - The tool-surface behavior and exported tool names remain unchanged, but the touched file is reduced to `<= 500` lines.
   - Acceptance criteria:
     - `mcp-tools.ts` is `<= 500` lines.
     - Existing MCP tool behavior remains unchanged.
   - Verification commands:
     - `Get-Content extensions/drm-copilot/src/mcp-tools.ts | Measure-Object -Line`
     - `Push-Location extensions/drm-copilot; npm run test:unit -- --runTestsByPath test/mcp-server.test.ts test/repo-automation-service.test.ts; Pop-Location`

3. **Split `repo-automation-service.test.ts` into maintainable focused suites while preserving runtime-boundary coverage.**
   - Files in scope:
     - `extensions/drm-copilot/test/repo-automation-service.test.ts`
     - one or more new `.test.ts` files under `extensions/drm-copilot/test/`
   - Current defect:
     - The touched test file is 544 lines and violates the repository file-size rule.
   - Expected behavior:
     - The tests remain behavior-focused and deterministic, but no touched test file remains above 500 lines.
   - Acceptance criteria:
     - Every touched `.test.ts` file involved in this remediation is `<= 500` lines.
     - The `resolveAtomicPlanPrompt` service coverage and policy-audit asset coverage remain present.
   - Verification commands:
     - `Get-Content extensions/drm-copilot/test/repo-automation-service.test.ts | Measure-Object -Line`
     - `Push-Location extensions/drm-copilot; node run-jest.cjs --runTestsByPath test/extension.resolve-atomic-plan-prompt.test.ts test/repo-automation-service.test.ts test/mcp-server.test.ts; Pop-Location`

4. **Refresh the TypeScript QA evidence and superseding review artifacts after the structural split.**
   - Files and artifacts in scope:
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/policy-audit.<new timestamp>.md`
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/code-review.<new timestamp>.md`
     - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/feature-audit.<new timestamp>.md`
     - final TypeScript QA artifacts under `evidence/`
   - Current defect:
     - The follow-up review is still `Blocked` because the touched-file size violation remains.
   - Expected behavior:
     - A new review cycle can verify that the structural policy blocker is closed without reopening the earlier runtime and coverage findings.
   - Acceptance criteria:
     - Final TypeScript QA passes after the split.
     - The next review can report no touched-file size blocker.
   - Verification commands:
     - `Push-Location extensions/drm-copilot; npm run format; npm run lint; npm run typecheck; npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary; Pop-Location`

## Verified Open Blockers

- `extensions/drm-copilot/src/repo-automation-service.ts`
- `extensions/drm-copilot/src/mcp-tools.ts`
- `extensions/drm-copilot/test/repo-automation-service.test.ts`
- `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/policy-audit.2026-04-18T15-13.md`
- `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/code-review.2026-04-18T15-13.md`

## Required Context Package

- Original feature plan: `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md`
- Executed remediation plan: `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/remediation-plan.2026-04-18T17-44.md`
- Follow-up review artifacts:
  - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/policy-audit.2026-04-18T15-13.md`
  - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/code-review.2026-04-18T15-13.md`
  - `docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/feature-audit.2026-04-18T15-13.md`
- PR context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`

## Do Not Do

- Do not widen scope into unrelated command-surface, MCP, or Python-runtime refactors.
- Do not weaken or reinterpret the 500-line repository limit.
- Do not reopen the previously closed `--workspace` runtime contract or changed-scope coverage-proof fixes.
- Do not remove regression coverage while splitting files.
- Do not modify repository policy documents.
