# Criteria Re-Evaluation - Issue 1034 Remediation Cycle 4 (P2-T8)

Timestamp: 2026-11-07T14-41
Command: read of FEATURE/spec.md, FEATURE/user-story.md, the HOOK help block, feature-audit.2026-11-07T05-55.md and the evidence named in each row
EXIT_CODE: 0
Output Summary: PASS for all three criteria under the review standard of the cycle 4 plan: a shell form the hook does not model is non-blocking when the limit text names it. The only gap the 05-55 feature audit recorded for these criteria was F6: the limit statement placed the F6 forms in the group it says denies. Both limit texts now describe the scanner's view and name each F6 group and each N15 form, and every named form allows as the text states (named-form-decisions). The criterion E1 in SPEC, E1 in STORY, and U2 in STORY are checked off. The physical line counts of SPEC (560) and STORY (97) are unchanged.

Evidence keys: LTC = regression-testing/limit-text-check.2026-11-07T14-25.md; NFD = regression-testing/named-form-decisions.2026-11-07T14-25.md; PAR = regression-testing/pester-parallel.2026-11-07T14-35.md; cycle 3: FAILB = regression-testing/fail-before.2026-11-07T04-56.md, GATE = regression-testing/gate-rows.2026-11-07T04-58.md, BASHCMP = regression-testing/bash-comparison.2026-11-07T05-18.md, HOOKPROC = regression-testing/f4-f5-hook-process.2026-11-07T05-21.md.

| Criterion | Result | Evidence | Basis |
|---|---|---|---|
| E1 in `SPEC` (first epic criterion under `## Acceptance Criteria`): gate disabled allows every call; enabled denies an absent, failing or other-revision receipt and names the reason | PASS | LTC, NFD, PAR, FAILB, GATE, BASHCMP, HOOKPROC | The disabled clause and the enabled receipt reasons hold as the 05-55 audit recorded (FAILB, GATE, HOOKPROC; PAR shows 0 failures with the decision code unchanged). The audit's PARTIAL rested only on F6: the limit statement said the words `gh pr merge` "in the unquoted text" deny, and the F6 forms allowed. The limit text now reads "in the text the shared scanner reads as unquoted", states that the scanner keeps no comment state, reads `<<` as a heredoc opener wherever it appears and does not nest double quotes in a substitution inside double quotes, and names each F6 group (table below) (LTC). NFD shows each named form allows, as the text now states. The N15 forms are named as well. Under the review standard, each form that allows is named in the limit text. |
| E1 in `STORY` (first epic criterion under `## Acceptance Criteria`, same text) | PASS | as E1 in `SPEC` | As E1 in `SPEC`. |
| U2 in `STORY` (second story criterion): with the gate enabled an integration-to-`main` merge is denied with a receipt reason code, and allowed when the receipt passes and its revision equals `headRefOid` | PASS | GATE, BASHCMP, HOOKPROC, NFD, LTC, PAR | The 05-55 audit accepted reading 2: the receipt reasons and the passing-receipt allow are verified for the plain form, and a merge the hook reads in a non-plain form denies `PR_UNRESOLVED`. The only remaining gap was that the F6 forms allowed while the limit text placed them in the group the hook reads. Those forms are now named outside that group (LTC), and NFD confirms they allow as stated. The plain controls `gh pr merge 12 # note` and `gh pr merge 34 # it's` still reach one lookup each (NFD). |

## F6 Groups and N15 Forms Against the Limit Text

Each phrase is present in both the `HOOK` help block and `SPEC` after backtick removal and whitespace collapse (LTC). Each form allows with zero lookups in NFD.

| Form | Source | Limit-text phrase | NFD row |
|---|---|---|---|
| A quote character in a comment, before and after the merge line, including the `gh api` form | F6 group A | "a quote character in a # comment before and after the merge line (# it's)" | R1 |
| A heredoc opener in a comment | F6 group B | "a heredoc opener << in a # comment (# a<<b)" | R2 |
| A shift in arithmetic | F6 group C | "a shift in arithmetic (x=$((1<<4)))" | R3 |
| Double quotes nested in a command substitution inside double quotes | F6 group D | "double quotes nested in a command substitution inside double quotes (echo "$(git log -1 --format="%h"; gh pr merge 12)")" | R4 |
| ANSI-C quoted command word | N15 | "an ANSI-C quoted command word ($'g\x68' pr merge 12)" | R5 |
| Arguments piped to `gh` through `xargs` | N15 | "arguments piped to gh through xargs gh (printf 'pr\nmerge\n12\n' \| xargs gh)" | R6 |
| Shell alias holding the merge | N15 | "a shell alias holding the merge (alias m='gh pr merge 12', then m)" | R7 |
| Encoded payload decoded and piped to `sh` | N15 | "an encoded payload decoded with base64 -d and piped to sh" | R8 |
| Branch merge through the merges endpoint | N15 | "a branch merge through gh api repos/o/r/merges, which merges branches with no pull request" | R9 |

The scanner-level statement that covers groups A to D is "The shared scanner keeps no comment state, reads << as a heredoc opener wherever it appears, and does not nest double quotes inside a command substitution inside double quotes, so a merge line that bash runs can read as quoted or heredoc text and allow."

## Line Counts

| File | Before check-off | After check-off |
|---|---|---|
| `SPEC` | 560 | 560 |
| `STORY` | 97 | 97 |

Each checkbox edit changes only the bracket character of its line. The CI-dependent criterion of `SPEC` stays unchecked for the S9 CI gate.
