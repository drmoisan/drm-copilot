# Expect-Fail — TypeScript Defect A regressions (Issue #401)

Timestamp: 2026-07-22T15-53

Command: npm run test -- --testMatch 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4396e634050c686d/extensions/drm-copilot/test/**/*.test.ts' --testPathPatterns 'mcp-tool-inputs.workspace-root.test.ts|mcp-repo-automation-tool-definitions.test.ts' (from extensions/drm-copilot/, via pwsh)

EXIT_CODE: 1

Output Summary:
- Result: 2 suites failed, 4 tests failed, 34 passed, 38 total.
- Failing tests (expected fail-before):
  1. "resolveNewPotentialBugEntryToolInput — fail-closed workspace_root (AC-4) > throws an actionable error naming workspace_root when omitted with no fallback" — received function did not throw (current code silently returns process.cwd()). This is the P1-T5 expect-fail.
  2. "resolvePotentialToIssueToolInput — workspace-relative potential_path (AC-6) > resolves a workspace-relative potential_path against workspace_root" — received "docs/potential/entry.md" (unresolved) vs expected "C:/ws/docs/potential/entry.md". This is the P1-T6 expect-fail.
  3. "workspace_root required contract (AC-5) > lists workspace_root in inputSchema.required for every repo automation tool (all 28)" — received required array [] (workspace_root absent). This is the P1-T7 expect-fail (required arrays).
  4. "workspace_root required contract (AC-5) > does not advertise a process.cwd() default in the workspace_root description" — received "Target workspace root. Defaults to process.cwd() when omitted." This is the P1-T7 expect-fail (description).
- Passing companion cases (explicit-fallback returns fallback; absolute potential_path preserved) confirm only the fail-before assertions fail. Phase 3 fixes make all four pass.

Note: P1-T5 and P1-T6 were placed in the new sibling suite test/mcp-tool-inputs.workspace-root.test.ts (rather than test/mcp-tool-inputs.test.ts, which is at 495 lines) to keep both files under the 500-line policy limit (AC-14). The tests are discovered and run by the same test glob.
