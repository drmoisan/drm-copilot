# Expect-Fail — TypeScript (bug, minor-audit) regression (Issue #401)

Timestamp: 2026-07-22T15-53

Command: npm run test -- --testMatch 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4396e634050c686d/extensions/drm-copilot/test/**/*.test.ts' --testPathPatterns 'lib/potential-to-issue/promotion.test.ts' (from extensions/drm-copilot/, via pwsh)

EXIT_CODE: 1

Output Summary:
- Failing test (expected): "promotePotential — bug promotion in minor-audit mode (AC-1) > routes a populated bug potential to the bug body under minor-audit with the minor-audit marker".
- Result: 1 failed, 14 passed, 15 total (Test Suites: 1 failed, 1 total).
- Failure detail: against the unfixed code the (bug, minor-audit) cell routes to buildMinorAuditBody, so the body renders "## Problem / Why", "## Implementation Intent", etc. with "(not provided in potential file)" placeholders instead of the populated bug sections. The assertion `expect(body).toContain("## Summary\nsummary details")` failed. This is the expected fail-before state for AC-1; the Phase 2 branch reorder makes it pass.
