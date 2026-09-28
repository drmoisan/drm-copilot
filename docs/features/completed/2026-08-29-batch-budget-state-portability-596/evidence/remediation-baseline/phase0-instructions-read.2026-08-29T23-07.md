# Phase 0 — Policy instructions read (remediation cycle 1)

Timestamp: 2026-08-30T00-44

Task: [P0-T1]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command: Read tool invocations against the six policy files listed below, in the order listed, each read in full. Executed against the absolute worktree prefix `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/`. The plan states these paths worktree-relative; the absolute prefix above is the form actually used.

EXIT_CODE: 0

Policy Order: the `policy-compliance-order` sequence — standing instructions first, then the cross-language code-change policy, then the cross-language unit-test policy, then the tier system, then the language-specific rules for the languages in scope (PowerShell and TypeScript).

## Files read, in order

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`
5. `.claude/rules/powershell.md`
6. `.claude/rules/typescript.md`

## Output Summary

All six files were read in full, in the order listed. Constraints that bind this remediation:

- 500-line cap on production, test, and reusable script files (`general-code-change.md`, File Size Limit). Binding on both Pester suites this remediation edits.
- Toolchain order format, lint, type-check, test; restart from step 1 on any failure or file rewrite (`general-code-change.md`; `powershell.md` step 3 is not applicable to PowerShell).
- Line coverage floor of 85 percent across all tiers; no branch-coverage gate for PowerShell because Pester does not measure branch coverage; branch floor of 75 percent applies to TypeScript (`general-unit-test.md`, `quality-tiers.md`, `powershell.md` line 64).
- No production file may be excluded from coverage measurement (`general-unit-test.md`, Coverage Exclusion Policy).
- No temporary files in tests (`general-unit-test.md`, External Dependencies).
- Tests mirror production structure under `tests/`; colocation prohibited (`general-unit-test.md`, Test File Location).
- PowerShell change budget: at most 2 production PowerShell files in direct mode, and at most 3 production plus 3 test files per batch (`powershell.md` lines 39-41). This is the constraint the plan's batch-boundary table satisfies.
- PowerShell format and lint run through `mcp__drm-copilot__run_poshqc_format` and `mcp__drm-copilot__run_poshqc_analyze`; VS Code task wrappers must not be substituted (`powershell.md` line 20).
- TypeScript coverage regression on changed lines is a blocking finding (`typescript.md` line 52).

No policy file was modified. Policy files under `.claude/rules/` and `.github/instructions/` are read-only for this remediation.
