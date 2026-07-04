# Remediation Inputs: pre-claude-session-script (Issue #189)

**Entry timestamp:** 2026-06-16T14-11
**Feature Folder:** `docs/features/active/2026-06-16-pre-claude-session-script-189`
**Base Branch:** `main` (merge-base `93d83d5ea01d40b229e2721f057210d9ef698206`)
**Head:** `drm-copilot-wt-2026-06-16-13-41` (`72e415c389423e7a213bb899970278dff47ce7d5`)

## Source audit artifacts

- `docs/features/active/2026-06-16-pre-claude-session-script-189/policy-audit.2026-06-16T14-11.md` (Section 2.3, Section 8: file-size PARTIAL)
- `docs/features/active/2026-06-16-pre-claude-session-script-189/code-review.2026-06-16T14-11.md` (Findings Table: Minor)
- `docs/features/active/2026-06-16-pre-claude-session-script-189/feature-audit.2026-06-16T14-11.md` (all AC PASS; no AC-driven remediation)

## Severity overview

- **Blocking findings: 0.**
- **Minor findings: 1** (non-blocking; pre-existing condition aggravated by this change).

This remediation-inputs artifact is produced because the policy audit contains a PARTIAL result on the 500-line test-file-size requirement, which the feature-review workflow treats as a remediation trigger. There are zero Blocking findings; the feature itself is PR-ready (Conditional Go). The single item below may be deferred to a separate maintenance change at the orchestrator's discretion.

## Enumerated fix list

### Severity: Minor — Test file exceeds 500-line limit

- **File:** `extensions/drm-copilot/test/extension.workflow-commands.test.ts`
- **Current state:** 957 lines (795 at baseline `93d83d5`; +162 added by this change). Exceeds the 500-line limit that `general-code-change.md` applies to test code.
- **Expected behavior after fix:** The worktree-session command tests are split so that no single test file exceeds 500 lines, with no loss of test coverage and no behavior change. For example, extract the `newClaudeWorktreeSession` ordering/handler tests (including the four new pre-claude tests) into a dedicated file such as `extensions/drm-copilot/test/extension.new-claude-worktree-session.test.ts`, preserving the existing shared harness imports.
- **Constraints:** Production code under test must not change. Test assertions and scenario coverage must be preserved exactly. The new file(s) must remain under `extensions/drm-copilot/test/` (mirroring `src/`), not colocated in the source tree.
- **Verification commands (from `extensions/drm-copilot`):**
  - `wc -l test/*.test.ts` — confirm each test file is <= 500 lines.
  - `npm run format` — EXIT 0.
  - `npm run lint` — EXIT 0.
  - `npm run typecheck` — EXIT 0.
  - `node run-jest.cjs --coverage` — EXIT 0; test count unchanged (357) and coverage unchanged (`claude-worktree-session.ts` 100%; `extension.ts` line >= 98.67% / branch >= 90.91%); no regression on changed lines.
- **Evidence target:** Write QA evidence under `docs/features/active/2026-06-16-pre-claude-session-script-189/evidence/qa-gates/` per the canonical evidence-location convention.

## Do-not-do list

- Do not modify production source (`src/claude-worktree-session.ts`, `src/extension.ts`, `package.json`) to satisfy this finding; the fix is a test-file split only.
- Do not delete, weaken, or merge any test assertions to reduce line count; preserve all 357 tests and their scenarios.
- Do not lower or waive the 500-line limit or any coverage threshold.
- Do not relocate test files into the production source tree (`src/`).
- Do not introduce new runtime dependencies or change the test framework.
- Do not write evidence to non-canonical paths (`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`); use `<FEATURE>/evidence/<kind>/`.

## Recommended disposition

This is a single Minor, pre-existing maintainability item with zero Blocking findings. The orchestrator may either (a) open a remediation cycle scoped solely to the test-file split, or (b) defer it to a separate maintenance change and proceed with the PR, since the feature meets all acceptance criteria and coverage thresholds and carries no Blocking findings.
