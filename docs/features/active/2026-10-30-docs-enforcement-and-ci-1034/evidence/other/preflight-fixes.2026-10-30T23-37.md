# Preflight Fixes

Timestamp: 2026-10-30T23-37
Plan: docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/plan.2026-10-30T18-40.md

## Fixes (trivial, task text only; no task added, removed or reordered)

1. [P3-T4] Literal formatting of the diff assertion. `git diff MERGE_BASE HEAD -- .claude/lib/docs/Invoke-DocsCommand.ps1` compares two commits, so an added line that is not yet committed is invisible and the "exactly one added line" condition fails when the executor has not committed. Changed to `git diff MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1` (merge base against the working tree), which shows the line in both the committed and the uncommitted state. The asserted value (one added line directly after the anchor, no removed line) is unchanged.
2. [P4-T2] Same correction for `.claude/lib/docs/DocsProfileCommands.psm1`. The asserted value is unchanged.
3. [P7-T8] Ambiguous suite set. "the eight new or edited suites" did not name the suites, and two of the edits are conditional on P0-T3, so the set could hold six files. The eight touched suites are now named: `DocsCompleteGate.Tests.ps1`, `DocsSurfaceDelta.Tests.ps1`, `DocsSurfaceDeltaCommands.Tests.ps1`, `DocsInitTemplate.DocsWorkflow.Tests.ps1`, `enforce-docs-complete-gate.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `Invoke-DocsCommand.Tests.ps1` and `DocsProfileCommands.Tests.ps1`. The count of eight and the three-seed requirement are unchanged.
4. [P1-T1], [P3-T1], [P3-T3] Missing design pointer. P6-T4 asserts zero failures in `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, which requires the help-block token, the strict-mode and stop-preference pair, and `-ErrorAction Stop` on every column-0 import. The three module-creation tasks did not reference those conventions. Each task now states that the module follows 1020 spec `### Module conventions (all files under .claude/lib/docs/)`. No acceptance condition changed.
