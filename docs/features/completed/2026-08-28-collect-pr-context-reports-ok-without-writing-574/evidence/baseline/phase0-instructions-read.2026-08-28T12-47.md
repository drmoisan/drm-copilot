# Phase 0 — Policy Instructions Read

Timestamp: 2026-08-28T12-47

Task: [P0-T1]

Policy Order: the canonical order stated by `[P0-T1]` of `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/plan.2026-08-28T09-31.md`, which is the repository policy-compliance reading order (`CLAUDE.md`, cross-language code-change policy, cross-language unit-test policy, tier policy, then the language-specific rules for the two languages in scope, then the plan-acceptance-gate rules).

## Files read, in order, as repo-relative paths

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/typescript.md`
6. `.claude/rules/typescript-suppressions.md`
7. `.claude/rules/python.md`
8. `.claude/rules/python-suppressions.md`
9. `.claude/rules/plan-acceptance-gates.md`

Nine files. Each was read in full through the file-read tool against this worktree
(`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a1e08b3ce279bb4f8`), not from a
sibling checkout.

Command: `date "+%Y-%m-%dT%H-%M" && wc -l .claude/rules/general-code-change.md .claude/rules/general-unit-test.md .claude/rules/quality-tiers.md .claude/rules/plan-acceptance-gates.md`

EXIT_CODE: 0

Output Summary: the four rule files whose text is also injected into the session standing
context were confirmed present in this worktree and read from it, at 80, 105, 51, and 257 lines
respectively. All nine files above were read. Constraints carried forward into execution: the
500-line limit on every production, test, and reusable script file (Markdown documentation is
exempt); uniform coverage thresholds of at least 85 percent line and at least 75 percent branch
across T1 through T4; the prohibition on excluding a production file from coverage measurement;
the prohibition on temporary files in tests; the ordered toolchain loop restarting from step 1 on
any failure or any file rewrite; injected-clock determinism for TypeScript; and the suppression
authorization policy for both runtimes. The policy documents under `.claude/rules/` and
`.github/instructions/` are not modified by this change.
