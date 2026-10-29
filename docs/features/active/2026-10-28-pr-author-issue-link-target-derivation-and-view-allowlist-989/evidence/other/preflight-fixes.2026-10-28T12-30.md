# Preflight Fixes

Timestamp: 2026-10-28T12-30
Plan: docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/plan.2026-10-28T07-38.md

## Fix 1 — [P1-T1]

- Defect class: validator-blind defect class (an existing guard asserts on the file the task creates, and the task did not name it).
- Finding: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` discovers every suite under `tests/scripts/claude-hooks` that loads a hook. Row AC-4 requires an outermost-`BeforeAll` null mock for every read seam in the loaded closure, and row AC-6 requires a suite that complies that way to call `Invoke-EpicStateInterceptionProbe` from inside an It. The new AuthorAsserted suite is discovered by that guard, and the task text listed rows AA-01 to AA-12 only.
- Change: the task now states that the suite keeps the outermost-`BeforeAll` null mocks and the `baseline mock interception probe` It of `enforce-model-routing-receipt.EpicScope.Tests.ps1`, so AC-4 and AC-6 hold. No AA row and no acceptance condition changed.

## Fix 2 — [P1-T2]

- Defect class: validator-blind defect class (same guard as Fix 1).
- Finding: the CurrentBranch suite dot-sources `.claude/hooks/enforce-pr-author-skill.ps1` and is discovered by the same guard. The task named the baseline mocks of the WorktreeResolution suite but not its probe It.
- Change: the task now states that the suite carries the WorktreeResolution suite's `baseline mock interception probe` It, so AC-4 and AC-6 hold. No CB row and no acceptance condition changed.

## Fix 3 — [P1-T5]

- Defect class: literal-formatting defect that does not change what is asserted (expected-pass list follows Fixes 1 and 2).
- Change: the list of rows expected to pass now includes the two `baseline mock interception probe` rows that Fixes 1 and 2 add. The expected-fail split is unchanged.

## Fix 4 — [P4-T5]

- Defect class: literal-formatting defect (search-pattern quoting).
- Finding: read as a regular expression, the token `gh pr edit *` matches every occurrence of `gh pr edit`, because ` *` means zero or more spaces. The intended hits are pr-author tool-list entries of the form `Bash(gh pr edit *)`.
- Change: the search is now stated as a fixed-string search (`git grep -F`) so the `*` is literal. The token and the acceptance condition are unchanged.
