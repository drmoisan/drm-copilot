# Remediation Inputs - Issue #1034 (feature review 2026-11-07T04-16)

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate

Orchestrator scope note: this cycle also carries the integration merge of `e1f4d2e54` (the conflict in `.claude/lib/docs/Invoke-DocsCommand.ps1` and its bundle copy) and N14. It is the third and last attempt the remediation guard allows.

Mode reason: both fixes fit in `.claude/hooks/enforce-docs-complete-gate-target.ps1`, the hook header, `spec.md` design text, their tests and their bundle copies. No acceptance criterion, public interface or file inventory changes.

- Feature folder: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
- Branch: `feature/docs-enforcement-and-ci-1034-r2` at `1e8c35e37bbd38cb26f081936071e9a2d971f930`
- Base: `origin/epic/documentation-estate-tooling-integration`; merge base `e3e4aa551808a25c436337bf0dbcf298421a34d6`; current tip `e1f4d2e54dd877929f28fd5496231304d3c5308f`
- Source artifacts:
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/policy-audit.2026-11-07T04-16.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/code-review.2026-11-07T04-16.md`
  - `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/feature-audit.2026-11-07T04-16.md`
- Target plan path: `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/remediation-plan.2026-11-07T04-16.md` (to be authored by `atomic-planner`)
- Findings requiring remediation: 2, both autonomous.
- Closed since the previous review: F1 and F3 for every listed form; N8, N9, N10 and N11.

## Remediation-Required Findings

### F4 - A comment ending in a backslash hides a following merge from the plain proof

- Severity: Blocking
- Status: FAIL
- Source: `code-review.2026-11-07T04-16.md` Findings Table row 1 and `### F4 results`; `feature-audit.2026-11-07T04-16.md` spec:516, story:65 and story:73.
- File: `.claude/hooks/enforce-docs-complete-gate-target.ps1`, `Read-DocsCompleteGatePlainCommand` (lines 42, 51-54) and `Test-DocsCompleteGateMergeCandidate` (lines 151-159), and its bundle copy.
- Finding: `ConvertTo-CommandLineNormalizedText` replaces backslash-newline with a space before the reader scans, so the rule that a comment holds no newline cannot see it, and the text after the `#` is dropped as comment. Bash does not continue a comment at a backslash, so the next line runs. With the gate enabled and no receipt, `gh pr merge 34 # x\<newline>gh pr merge 12` looks up 34 and allows, and real bash passed `pr merge 34` and `pr merge 12` to `gh`. The hook at `3007ef346` denied that command, so this form is a regression of cycle 2. `gh pr view 34 # x\<newline>gh pr merge 12` and `gh pr merge --disable-auto # x\<newline>gh pr merge 12` allow with no lookup in a real hook process.
- Remediability: autonomous
- Remediability-Evidence: The defect is in the helper on this branch, the raw command text is available to the reader, and no shared file, owner decision or external party is needed.
- Required action:
  1. Make the reader return not plain when it reaches a comment and the raw command text holds a backslash-newline. Do not edit the shared normalizer.
  2. Confirm that the non-plain path then denies each F4 row, including the `gh pr view` and `--disable-auto` rows that currently skip the unquoted view.
  3. Keep these unchanged: `gh pr merge 12 # note; echo done`, `gh pr merge 12 #99`, `gh pr merge \<newline>12`, `gh pr \<newline>merge 12`.
  4. Correct the helper header sentence "a form the grammar does not model can never lose its selector" if the design no longer guarantees it.
- Expected result: every row of the F4 table denies with the gate enabled and allows with it disabled or absent; the rows in action 3 keep their results.
- Verification: rows in `enforce-docs-complete-gate-target.Tests.ps1` and `enforce-docs-complete-gate-compound.Tests.ps1`, each failing first at head; one real hook process run and one real bash comparison recorded under `evidence/regression-testing/`.
- On completion: re-evaluate spec:516, story:65 and story:73.

### F5 - Three groups of merge forms are allowed and are not in the residual limits

- Severity: Blocking
- Status: FAIL
- Source: `code-review.2026-11-07T04-16.md` Findings Table row 2 and `### F5 results`; `feature-audit.2026-11-07T04-16.md` spec:516, story:65 and story:73.
- File: `.claude/hooks/enforce-docs-complete-gate-target.ps1` (`Get-DocsCompleteGateUnquotedView`, `Test-DocsCompleteGateMergeCandidate`), the `Residual limits` paragraph of `.claude/hooks/enforce-docs-complete-gate.ps1`, `spec.md` lines 265-267, and their bundle copies.
- Finding: with the gate enabled and no receipt these commands allow, and real bash passed `pr merge 12` to `gh`: a quoted payload under a leading word that is not a transparent wrapper (`if true; then sh -c 'gh pr merge 12'; fi`, `! sh -c ...`, `exec sh -c ...`, `nice sh -c ...`, `for n in 12; do sh -c "gh pr merge $n"; done`, `if true; then eval 'gh pr merge 12'; fi`, `find . -maxdepth 0 -exec sh -c '...' \;`, a heredoc to `bash` inside `if`); quoted text piped into a shell (`echo 'gh pr merge 12' | sh`); and a backslash in a command word (`g\h pr merge 12`, `gh pr mer\ge 12`, `gh p\r merge 12`). The header states that a merge in any form other than one plain `gh pr merge` denies, and action 4 of F3 in `remediation-inputs.2026-11-07T02-24.md` required any unhandled form to be listed. The same payloads deny at top level. These forms were allowed at `3007ef346`, so this is not a regression.
- Remediability: autonomous
- Remediability-Evidence: Each group can be denied in the helper or named in the residual limits on this branch; either route needs no shared file, owner decision or external party.
- Required action:
  1. For each group, either deny it or list it. Preferred: remove backslashes from the unquoted view, and treat a command as a candidate when its quoted text holds the words `gh`, `pr`, `merge` in order and the view holds an unquoted evaluator word (`sh`, `bash`, `zsh`, `dash`, `eval`, `source`).
  2. Keep allowed: `git commit -m 'gh pr merge 12'`, `echo "gh pr merge 12"`, `git log --grep='gh pr merge'`.
  3. List every form that stays allowed, by name, in the hook header and in `spec.md`. Include `python -c`, `node -e` and `curl`, which are unlisted today, and correct the sentence "a merge in any form other than one plain gh pr merge denies".
  4. Keep every `spec.md` edit above `## Acceptance Criteria` line-count neutral, so criterion positions stay valid.
- Expected result: each F5 row denies or is named in the residual limits; the controls in action 2 are unchanged.
- Verification: rows for each denied form in `enforce-docs-complete-gate-compound.Tests.ps1`, failing first at head, in enabled, disabled and absent states; a text check that each listed form appears in the hook header and `spec.md`.
- On completion: re-evaluate spec:516, story:65 and story:73.

## Constraints for the Plan

- Merge `origin/epic/documentation-estate-tooling-integration` (now `e1f4d2e54`) early in the cycle, before the final gates. `git merge-tree` reports content conflicts in `.claude/lib/docs/Invoke-DocsCommand.ps1` and its bundle copy. Keep the two copies byte-identical and re-check spec:533 after the merge.
- The shared files stay unchanged: `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-payload.ps1`, `enforce-epic-merge-gate-command.ps1`.
- The hook, the helper and their bundle copies stay byte-identical.
- The parallel-only directive applies: one `Invoke-PoshQCParallelTest` run and one `pytest -n auto` run as the final gates.
- Before the final gates, compare the fixed hook with real bash across multi-line commands and quoted payloads, not only the rows listed here. Each of the last three reviews found forms outside the list it was given.

## Non-Blocking Notes

These do not affect the verdict. Details are in the code review Findings Table.

- N1 to N5: deferred by the relayed owner directive; unchanged.
- N12: the epic merge above.
- N13: with the gate enabled, some non-merge mentions and non-integration compound merges deny. This is the accepted design; spec:525 and story:74 are graded on their tested scenarios.
- N14: the after-word check in the plain reader, lines 98-102, is redundant.

## Pending, Not a Finding

spec:544 is CI-dependent and is owned by the S9 CI green gate after the pull request exists.
