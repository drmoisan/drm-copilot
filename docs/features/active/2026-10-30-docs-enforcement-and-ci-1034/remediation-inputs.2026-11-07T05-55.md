# Remediation Inputs - Issue #1034 (feature review 2026-11-07T05-55)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Orchestrator note: `remediation-inputs.2026-11-07T04-16.md` called cycle 3 the last attempt the remediation guard allows. Whether a further cycle may run is for the orchestrator and the owner. The classification below describes the finding, not that limit.

Mode reason: the fix fits in `.claude/hooks/enforce-docs-complete-gate-target.ps1`, the hook header, `spec.md` design text, their tests and their bundle copies. No acceptance criterion, public interface or file inventory changes.

- Feature folder: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
- Branch: `feature/docs-enforcement-and-ci-1034-r2` at `abb854f5346caa1d1c4054e508c90ba840bbe70e`
- Base: `origin/epic/documentation-estate-tooling-integration`; merge base and current tip `e1f4d2e54dd877929f28fd5496231304d3c5308f`
- Source artifacts:
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T05-55.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/code-review.2026-11-07T05-55.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/feature-audit.2026-11-07T05-55.md`
- Target plan path: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T05-55.md` (to be authored by `atomic-planner`)
- Findings requiring remediation: 1, autonomous.
- Closed since the previous review: F4, F5, N12 and N14.

## Remediation-Required Findings

### F6 - A merge line the shared scanner reads as quoted is allowed, and the limit statement says it denies

- Severity: Blocking
- Status: FAIL
- Source: `code-review.2026-11-07T05-55.md` Findings Table row 1 and `### F6 results`; `feature-audit.2026-11-07T05-55.md` spec:516, story:65 and story:73.
- File: `.claude/hooks/enforce-docs-complete-gate-target.ps1` (`Get-DocsCompleteGateUnquotedView`, `Test-DocsCompleteGateMergeCandidate`), the `What it establishes` paragraph of `.claude/hooks/enforce-docs-complete-gate.ps1`, the `Residual limits` paragraph of `spec.md`, and their bundle copies.
- Finding: the view comes from `MaskedText` of `Read-CommandLineSegment`, which tracks no comment state and does not nest quotes inside a double-quoted substitution. With the gate enabled and no receipt these commands allow, and real bash passed the merge to `gh`: a quote in a comment (`# Merge once it's green<NL>gh pr merge 12 --merge<NL># Delete the branch now that it's merged<NL>git status`, `git fetch # it's<NL>gh pr merge 12 --merge<NL>git status # it's`, and the `gh api` form); a heredoc opener in a comment (`# a<<b<NL>gh pr merge 12<NL>b`); a shift in arithmetic (`x=$((1<<4))<NL>gh pr merge 12<NL>4`); and nested double quotes (`echo "$(git log -1 --format="%h"; gh pr merge 12)"`). The limit statement says the words `gh pr merge` in the unquoted text deny, so these forms are not "any other way of causing a merge". The comment forms need no intent to bypass the gate. They were allowed at `1e8c35e37` and `3007ef346`, so this is not a regression.
- Remediability: autonomous
- Remediability-Evidence: Each group can be denied in the helper or named in the limit text on this branch; either route needs no shared file, owner decision or external party.
- Required action:
  1. Comment groups: add to the form loop of `Test-DocsCompleteGateMergeCandidate` a form of the command with comments removed, where a comment runs from a `#` at the start of a word to the end of the line. A `#` inside a quoted span may unbalance that form; confirm that this can only add denials.
  2. Arithmetic and nested-quote groups: deny them or name them in the hook header and `spec.md`.
  3. Replace "the unquoted text" in both limit texts with wording that matches the code, such as the text the shared scanner reads as unquoted, and name every group that stays allowed. A text-only change that does this for all four groups also closes the finding; the comment groups are preferred in code because they need no intent.
  4. Keep allowed: `git commit -m 'gh pr merge 12'`, `echo "gh pr merge 12"`, `git log --grep='gh pr merge'`. Keep the plain lookup rows unchanged, including `gh pr merge 12 # note` and `gh pr merge 34 # it's`.
  5. Keep every `spec.md` edit above `## Acceptance Criteria` line-count neutral.
- Expected result: each F6 row denies or is named; the controls in action 4 are unchanged; the disabled and absent states still allow.
- Verification: rows in `enforce-docs-complete-gate-compound.Tests.ps1` for each denied form, failing first at head, in enabled, disabled and absent states; one real hook process run and one real bash comparison under `evidence/regression-testing/`, which includes comments holding quotes and `<<`; a text check for each named form.
- On completion: re-evaluate spec:516, story:65 and story:73.

## Constraints for the Plan

- The shared files stay unchanged: `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-payload.ps1`, `enforce-epic-merge-gate-command.ps1`.
- The hook, the helper and their bundle copies stay byte-identical.
- The parallel-only directive applies: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run as the final gates.

## Non-Blocking Notes

These do not affect the verdict. Details are in the code review Findings Table.

- N1 to N5: deferred by the relayed owner directive; unchanged.
- N13: accepted false denies; unchanged.
- N15: five forms that fall within "forms not modelled" and are not named; name them in the same header edit.
- N16: mutants K8 and K10 survive; add a split-word payload row and a row for line 202.
- N17: spec:540 names `evidence/coverage/`, which does not exist.
- N18: `Test-DocsCompleteGateMergeText` scales cubically on many `gh` and `pr` words; 8.7 s at 7.8 KB.
- N19: `<<` in arithmetic prints a parameter-binding error from shared code, and `(( 1 << 2 ))<NL>ls` denies with the gate enabled.

## Pending, Not a Finding

spec:544 is CI-dependent and is owned by the S9 CI green gate after the pull request exists.
