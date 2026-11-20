# Remediation Inputs - Issue #1034 (feature review 2026-11-07T02-24)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: design

Mode reason: `.claude/hooks/enforce-docs-complete-gate.ps1` is exactly 500 logical lines, the limit of spec:541, so a fix needs a new helper file or a change to the shared invocation reader. Either changes the file inventory beyond the branch diff.

- Feature folder: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
- Branch: `feature/docs-enforcement-and-ci-1034-r2` at `3007ef3467256e04c4a66483f72127b9b18ed5e1`
- Base: `origin/epic/documentation-estate-tooling-integration`; merge base `e3e4aa551808a25c436337bf0dbcf298421a34d6`
- Source artifacts:
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T02-24.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/code-review.2026-11-07T02-24.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/feature-audit.2026-11-07T02-24.md`
- Target plan path: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T02-24.md` (to be authored by `atomic-planner`)
- Findings requiring remediation: 2, both autonomous.
- Closed since the previous review: F2 and N6.

## Remediation-Required Findings

### F1 - The merge gate still loses or misreads some selectors (remaining forms)

- Severity: Blocking
- Status: FAIL
- Source: `code-review.2026-11-07T02-24.md` Findings Table row 1 and `### F1 remaining forms`; `feature-audit.2026-11-07T02-24.md` spec:516, story:65 and story:73.
- File: `.claude/hooks/enforce-docs-complete-gate.ps1`, `Read-DocsCompleteGateMergeOperand` (lines 185-228) and `Get-DocsCompleteGateMergeTarget` (lines 325-339), and its bundle copy.
- Finding: the scanner ends a segment at `&` and `{`, so a selector after `2>&1`, `&>log`, `>&2` or a brace is in a later record. The reader accepts the dangling segment, the selector is null, and the lookup resolves the current branch. These commands allow with the gate enabled and no receipt, from a checkout whose branch has a different pull request: `gh pr merge 2>&1 12`, `gh pr merge --merge 2>&1 epic/x-integration`, `gh pr merge >log 2>&1 12`, `gh pr merge &>log 12`, `gh pr merge >&2 12`, `gh pr merge {12..12}`. `gh pr merge 1{2..2}` looks up number 1. On an integration checkout, `gh pr merge #99` looks up 99 and allows, although bash treats `#99` as a comment and merges the current branch; the hook at `48892dc05` denied that command, so this form is a regression of cycle 1.
- Remediability: autonomous
- Remediability-Evidence: The defect is in code on this branch, the reason code exists, and the scanner already exposes each record's delimiter, so no owner decision or external party is needed.
- Required action:
  1. Treat a gated record that ends in a redirection operator, or whose delimiter is `&` or `{` in the middle of a word or redirection, as incomplete. Read the operands of the following record, or deny `PR_UNRESOLVED` when that record holds more than the file descriptor.
  2. Keep these allowed to reach their normal lookup: `gh pr merge 12 --merge 2>&1`, `gh pr merge 12 >/dev/null 2>&1`, `gh pr merge --squash 2>&1`.
  3. Treat an unquoted word beginning with `#` as the end of the operands. Keep a quoted `"#12"` as a selector.
- Expected result: each command above denies or looks up the selector that bash passes to `gh`; the commands in action 2 and the rows of the current suite are unchanged.
- Verification: new rows in `enforce-docs-complete-gate.Tests.ps1` with the per-selector stand-in, each failing first against head. Add a row where no selector resolves the integration pull request, for the comment form. Compare against real bash with a stand-in `gh` that prints its arguments.
- On completion: re-evaluate spec:516, story:65 and story:73.

### F3 - A merge inside a shell compound command is not admitted to scope

- Severity: Blocking
- Status: FAIL
- Source: `code-review.2026-11-07T02-24.md` Findings Table row 2 and `### F3 results`; `feature-audit.2026-11-07T02-24.md` spec:516, story:65 and story:73.
- File: `.claude/hooks/enforce-docs-complete-gate.ps1` line 419, through `Test-EpicMergeGateCommandInScope` in `.claude/hooks/enforce-epic-merge-gate-command.ps1`.
- Finding: `gh` is not the command word of a segment led by `if`, `then`, `elif`, `else`, `while`, `until`, `do`, `!`, `exec`, `sudo`, `nice` or `coproc`, or of a `find -exec` argument. No invocation match exists, so the hook allows with no profile read and no lookup. A real hook process with the gate enabled and no receipt returned `allow`, exit 0, for `if gh pr checks 12; then gh pr merge 12 --merge; fi`, `for n in 12; do gh pr merge "$n" --merge; done`, `! gh pr merge 12` and `exec gh pr merge 12`. Real bash passed `pr merge 12` to `gh` for all four, with `if true` in place of the `gh pr checks` test. The hook header's residual limits do not list this case. It was present before cycle 1.
- Remediability: autonomous
- Remediability-Evidence: A check local to this hook or a helper it owns can deny these forms without any change to shared files, and no owner decision or external party is needed.
- Required action:
  1. Deny `PR_UNRESOLVED` when a segment led by one of these words holds a `gh pr merge` invocation or a merge `gh api` invocation. Apply the gate-enabled check first, so a disabled or absent profile still allows with no `gh` call.
  2. Do not deny text that only mentions a merge, such as `git commit -m 'gh pr merge 12'` or `echo "gh pr merge 12"`.
  3. Alternative: correct the shared invocation reader, keeping `.claude/hooks` and `.codex/hooks` byte-identical. That would also close the same gap in the epic merge gate, but it changes a file every gate uses, so the plan must list the suites of each caller.
  4. Any form that stays unhandled goes in the header's residual limits and in `spec.md`.
- Expected result: each command in the code review F3 table denies when the gate is enabled and allows when it is disabled; the listed controls are unchanged.
- Verification: new rows in `enforce-docs-complete-gate.Tests.ps1`, failing first against head, and one real hook process run recorded under `evidence/regression-testing/`.
- On completion: re-evaluate spec:516, story:65 and story:73.

## Constraints for the Plan

- The hook is at 500 logical lines, and spec:541 allows no more. Moving the target readers to a helper file needs a `core.json` row, a bundle copy and a dependency-closure entry, and it stays within spec:539.
- The hook and its bundle copy stay byte-identical.
- Run P2-T5 of `remediation-plan.2026-11-07T01-25.md` with this change (N8), so `spec.md` records the final lookup and residual limits once. It edits design text only, not criterion text.
- Probe beyond the rows listed here. Both findings were outside the list the previous review gave, and the fix for one form does not establish the others.

## Non-Blocking Notes

These do not affect the verdict. Details are in the code review Findings Table.

- N1 to N5: deferred by the relayed owner directive; unchanged.
- N8: `spec.md` design text trails the hook.
- N9: context changes not detected, including `env --chdir=../other` and `builtin cd`.
- N10: the unknown-flag row does not discriminate (A17).

## Pending, Not a Finding

spec:544 is CI-dependent and is owned by the S9 CI green gate after the pull request exists.
