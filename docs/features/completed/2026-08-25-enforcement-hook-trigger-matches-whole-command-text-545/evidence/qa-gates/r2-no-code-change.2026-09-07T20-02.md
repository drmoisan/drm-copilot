# R-2 — No Code Change, No Frozen Literal Deleted ([P3-T2])

Timestamp: 2026-09-07T20-02
Task: [P3-T2]
Anchor used: **feature-wide anchor** `6dff80ed4596bec088d548b23013e6077e32c484` (epic base)

The feature-wide anchor is the only correct base for the question "was any frozen literal deleted
anywhere in this feature". A literal deleted earlier in the #545 work does not appear as a removed
line against the cycle-scope anchor `783e4b7436498fb9dba5d11df7711bd541ef28ad`, so that check would
pass vacuously if re-anchored there.

## Command-form note

The plan quotes the pipeline as
`git diff 6dff80ed4596bec088d548b23013e6077e32c484 -- '*.ps1' | grep "^-" | grep -F -c "<literal>"`.
Executed verbatim behind a `cd` into the worktree, the worktree-isolation guard refused it with
`Forbidden Bash pattern: 'cd ... && grep'`. The pipeline was therefore run in its equivalent
absolute-path form, `git -C <worktree-abs-path> diff ... | grep "^-" | grep -F -c "<literal>"`,
which is the same three-stage pipeline over the same diff with no `cd` and no intermediate file.
Each of the nine ran as its own separate `Bash` tool call: no shell loop, and no redirection of the
diff to a file.

## The nine frozen literals

Every invocation printed `0`, so no frozen literal appears on a removed line anywhere in the
PowerShell diff against the feature-wide anchor.

| # | Literal asserted (trailing space significant where shown) | Printed | Exit | ExpectedExitCode |
|---|---|---|---|---|
| 1 | `'rm -rf',` | 0 | 1 | 1 |
| 2 | `'git push --force',` | 0 | 1 | 1 |
| 3 | `'git push origin --force',` | 0 | 1 | 1 |
| 4 | `'Remove-Item -Recurse -Force',` | 0 | 1 | 1 |
| 5 | `'git reset --hard',` | 0 | 1 | 1 |
| 6 | `'git push -f',` | 0 | 1 | 1 |
| 7 | `$script:CdChainedReadCommandPattern = ` | 0 | 1 | 1 |
| 8 | `$script:AbandonDispositionToken = ` | 0 | 1 | 1 |
| 9 | `$ghApiIssuesPostPattern = ` | 0 | 1 | 1 |

ExpectedExitCode: 1

`1` is the exit code GNU `grep -F -c` returns when it matches nothing, so a printed `0` and an exit
of `1` are the same observation seen two ways.

Literals 7 through 9 are asserted in declaration form — identifier, space, `=`, space — with the
trailing space typed as part of the literal. The bare-identifier form cannot pass: the D12 call-site
rewrite deliberately removed the *use sites* of all three, so a bare-token search over removed lines
returns non-zero by design and unrelated to any deletion of frozen text. The declaration form
isolates the line that rule R2 actually protects, and the trailing space prevents the search from
also matching a comparison or an interpolation. All three declaration lines are present in the tree
now and at the feature-wide anchor, so deleting any of them would produce a `-` line and a non-zero
count; the condition can fail for all nine literals equally.

## `git status --porcelain` at this task — full capture

Command: `git status --porcelain`
EXIT_CODE: 0

```
 M .claude/hooks/validate-bash.ps1
 M .codex/hooks/validate-bash.ps1
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
 M tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
 M tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-budget-reset.2026-09-07T19-38.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-pair-parity.2026-09-07T19-43.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-toolchain.2026-09-07T19-47.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-budget-reset.2026-09-07T19-48.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-pair-parity.2026-09-07T19-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-toolchain.2026-09-07T19-59.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-codex.2026-09-07T19-51.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-claude.2026-09-07T19-44.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-codex.2026-09-07T19-55.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

Path count: 19.

## (i) The `[P2-T7]` post-stage-1 capture, reproduced

Source: `evidence/qa-gates/batch-b-toolchain.2026-09-07T19-59.md`, section "Post-stage-1
`git status --porcelain` — the `[P3-T2]` comparison baseline".

```
 M .claude/hooks/validate-bash.ps1
 M .codex/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
 M tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
 M tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-budget-reset.2026-09-07T19-38.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-pair-parity.2026-09-07T19-43.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-a-toolchain.2026-09-07T19-47.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-budget-reset.2026-09-07T19-48.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/qa-gates/batch-b-pair-parity.2026-09-07T19-52.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/fail-before-r1-codex.2026-09-07T19-51.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-claude.2026-09-07T19-44.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/pass-after-r1-codex.2026-09-07T19-55.md
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/remediation-baseline/
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

Path count: 17.

## (ii) Untracked evidence paths excluded from both sides, enumerated

Every untracked path under
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/`
is excluded from both sides of the set difference. Enumerated by path:

| # | Excluded untracked evidence path | In `[P2-T7]` capture | In `[P3-T2]` capture |
|---|---|---|---|
| 1 | `.../evidence/qa-gates/batch-a-budget-reset.2026-09-07T19-38.md` | yes | yes |
| 2 | `.../evidence/qa-gates/batch-a-pair-parity.2026-09-07T19-43.md` | yes | yes |
| 3 | `.../evidence/qa-gates/batch-a-toolchain.2026-09-07T19-47.md` | yes | yes |
| 4 | `.../evidence/qa-gates/batch-b-budget-reset.2026-09-07T19-48.md` | yes | yes |
| 5 | `.../evidence/qa-gates/batch-b-pair-parity.2026-09-07T19-52.md` | yes | yes |
| 6 | `.../evidence/qa-gates/batch-b-toolchain.2026-09-07T19-59.md` | no | yes |
| 7 | `.../evidence/regression-testing/fail-before-r1-claude.2026-09-07T19-41.md` | yes | yes |
| 8 | `.../evidence/regression-testing/fail-before-r1-codex.2026-09-07T19-51.md` | yes | yes |
| 9 | `.../evidence/regression-testing/pass-after-r1-claude.2026-09-07T19-44.md` | yes | yes |
| 10 | `.../evidence/regression-testing/pass-after-r1-codex.2026-09-07T19-55.md` | yes | yes |
| 11 | `.../evidence/remediation-baseline/` (untracked directory) | yes | yes |

Entry 6 is the only difference among them and is this plan's own `[P2-T7]` artifact, written after
that task's capture was taken. All eleven are excluded from both sides.

### Sets after exclusion

`[P2-T7]` remaining (7 paths):

```
 M .claude/hooks/validate-bash.ps1
 M .codex/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1
 M tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1
 M tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1
?? docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-plan.2026-09-07T17-44.md
```

`[P3-T2]` remaining (8 paths): the same seven plus

```
 M docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
```

## (iii) Present now and absent in the `[P2-T7]` capture

Exactly **one** entry, and it names
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`.

Condition (iii) SATISFIED.

## (iv) Absent now and present in the `[P2-T7]` capture

**Empty.** No path present in the `[P2-T7]` capture is missing from the capture at this task.

Condition (iv) SATISFIED.

## (v) Confirmation that the `[P2-T7]` capture does not list `spec.md`

The `[P2-T7]` capture reproduced under (i) carries no line naming
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`.
The `[P2-T7]` artifact itself records the same answer explicitly ("NO"). No blocking discrepancy.

Condition (v) SATISFIED.

## Why the set difference is the falsifiable form

Porcelain cannot express "modified since". Nothing is committed at any point in this plan, so the
raw listing at this task still carries the six PowerShell files changed in Phases 1 and 2, the
untracked plan file, and every untracked evidence artifact written so far. A condition reading
"porcelain shows `spec.md` as the only file modified since `[P2-T7]`" would be false on every
possible executor action. The set difference against the earlier recorded capture is what makes
"R-2 changed no code" falsifiable, and it is satisfied: the single path R-2 added to the changed
set is `spec.md`, and no PowerShell path entered or left the set.

## Inline acceptance conditions carried from `[P3-T1]`

`[P3-T1]` deliberately names no artifact path; its conditions are recorded here.

| Command | Expected | Observed | Exit | Result |
|---|---|---|---|---|
| `grep -F -c "trigger-literals-byte-unchanged.2026-09-07T15-50.md" <spec.md>` | 1 | 1 | 0 | PASS |
| `grep -F -c "ghApiIssuesPostPattern" <spec.md>` | 1 | 1 | 0 | PASS |
| `grep -F -c -e "- [ ] The five trigger pattern strings" <spec.md>` | 1 | 1 | 0 | PASS |

Both of the first two literals returned zero matches against `spec.md` before `[P3-T1]` ran, so each
condition is falsifiable and `[P3-T1]` is what placed them there. The third confirms the criterion's
checkbox is still `- [ ]`; it is checked off by `[P4-T8]`, which is outside this delegation's scope.
The `-e` is load-bearing in the third: without it GNU grep would parse the leading `-` as an option
bundle and exit 2 whatever the executor did.

Output Summary: All nine frozen-literal invocations printed `0` and exited `1`, so no frozen literal
appears on a removed line anywhere in the PowerShell diff against the feature-wide anchor. The
porcelain set difference against the `[P2-T7]` capture, after excluding the eleven untracked
evidence paths enumerated above, contains exactly one added entry — `spec.md` — and zero removed
entries, and the `[P2-T7]` capture is confirmed not to list `spec.md`. R-2 changed documentation
only. All three `[P3-T1]` inline grep conditions pass.
