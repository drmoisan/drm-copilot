# P1-T8 — correction to the stated rationale, and the measured assertion state

Timestamp: 2026-09-08T05-55

Task: [P1-T8] of `remediation-plan.2026-09-08T05-00.md`

This artifact records a correction to two imprecisions in P1-T8's stated rationale for
asserting over the form `wsl -d Ubuntu` rather than the bare token `wsl`. The correction was
raised as a non-blocking advisory during preflight round 3. The plan text is not changed and
the acceptance condition is not changed; only the reasoning is corrected here.

## The two imprecisions

1. **The citation `spec.md:453` is self-referential.** P1-T8's rationale cites `spec.md:453`
   as evidence that a surviving mention of WSL exists in
   `## Assumptions, Constraints, Dependencies`. Line 453, as the file stood before P1-T8 ran,
   was the first line of the very assumption bullet that P1-T8 replaces. It could not serve
   as evidence of a mention that survives the task, because the task removes it.

2. **The surviving mention at `spec.md:17` would not match a bare-token search anyway.**
   Line 17 reads `- OS/version: Windows 11 Pro 10.0.26200, bash toolchain under WSL Ubuntu`.
   The token there is uppercase `WSL`, so a case-sensitive search for the lowercase bare
   token `wsl` would not match it. The line therefore does not establish that a bare-token
   assertion would be unsatisfiable.

## Why the conclusion is nevertheless correct

The replacement bullet P1-T8 writes retains the sentence
"The operator runs the tool through WSL Ubuntu against a Windows checkout", so
`## Assumptions, Constraints, Dependencies` does still describe the operator running the tool
through WSL after this task. That mention, like line 17, is uppercase. The substantive point
stands on its own terms: neither mention is a command form, both survive this plan, and
neither should be removed. Asserting over the command form `wsl -d Ubuntu` targets exactly
the four command lines and three criterion texts this plan replaces, and leaves the two
prose mentions of the operating environment intact.

A bare lowercase-`wsl` assertion would in fact be satisfiable at this commit, because no
lowercase `wsl` survives. It is still the wrong assertion: it would break the next time
anyone writes the environment name in lowercase prose, and it does not describe what the
plan set out to remove.

## Measured assertion state

The asserted form is `wsl -d Ubuntu`.

| Point | Occurrences of `wsl -d Ubuntu` in `spec.md` |
|---|---|
| Before Phase 1 | 7 |
| After P1-T5 | 5 |
| After P1-T7 | 1 |
| After P1-T8 (target) | 0 |

All seven pre-state occurrences are accounted for: two in AC-31 and AC-32, removed by P1-T5;
four in the `## Test Strategy` fenced command block, removed by P1-T7; and one in the
`## Assumptions, Constraints, Dependencies` bullet, removed by P1-T8.

The companion literal `agent-a3944b95a7d58e712` went from 4 occurrences to 0, all four having
been inside the `## Test Strategy` fenced block removed by P1-T7.

The positive half of the P1-T8 assertion, `natively`, went from 0 to 1, and the single
occurrence is inside the replaced assumption bullet at `spec.md:455`.

Output Summary: The advisory is recorded and the rationale corrected. The acceptance
condition was unaffected and was verified as written: `natively` is at exactly 1,
`wsl -d Ubuntu` at 0, and `agent-a3944b95a7d58e712` at 0.
