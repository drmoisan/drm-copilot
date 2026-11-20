# Code Review: docs-enforcement-and-ci (#1034)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Feature Folder Selection Rule:** supplied by the caller; matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `e1f4d2e54`, which is the current tip)
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2` at `abb854f53`
**Review Type:** Re-audit after remediation cycle 3

---

## Executive Summary

Cycle 3 closed F4, F5, N12 and N14. Every row of the F4 and F5 tables now denies with the gate enabled and allows with it disabled or absent. The helper reads the raw text for a comment or split word beside a backslash-newline, removes backslashes from the unquoted view, and treats quoted or heredoc text beside an evaluator word as a candidate. The hook header now separates what the hook establishes from what it cannot observe, and it no longer claims that every non-plain merge denies. The epic tip is merged, and the branch has no conflict with it.

One finding remains. It was found by running 95 commands outside the executor's 320-row set through real bash and through the hook:

- **F6:** the header states that the hook denies "the words `gh pr merge` ... in the unquoted text". That is not true when the shared scanner's quote or heredoc state differs from bash. The scanner has no comment state, so an apostrophe or `<<` in a comment changes its reading of the lines that follow. It also reads `<<` in arithmetic as a heredoc, and it does not nest quotes inside `$(...)` inside double quotes. In each case a line that bash runs as an unquoted `gh pr merge 12` is blank in the view, and the command is allowed with the gate enabled and no receipt.

The group that needs attention is the comment case, because it needs no intent to bypass anything:

```text
# Merge once it's green
gh pr merge 12 --merge
# Delete the branch now that it's merged
git status
```

A real hook process with the gate enabled and no receipt returned `allow`, and real bash ran the merge. Earlier reviews accepted a listed limit because the listed forms "need a person or agent to wrap the merge deliberately". This form does not.

F6 is not a regression: the same commands were allowed at `1e8c35e37` and `3007ef346`, and earlier reviews, including this reviewer's, did not probe them.

**What changed in this cycle:** the integration merge, the helper (290 to 334 lines), the hook header (325 to 342 lines), bundle copies, the compound and helper suites, and `spec.md` limit text, plus the orchestrator's one-sentence `## Behavior` correction in `abb854f53`.

**Top 3 risks:**
1. A multi-line Bash call with a comment containing an apostrophe before and after the merge line merges with no receipt (F6, group A).
2. The header's `What it establishes` paragraph overstates the guarantee in those cases, so a reader relies on a denial that does not occur (F6).
3. Mutants K8 and K10 survive, so two parts of the candidate test have no row that needs them (N16).

**PR readiness recommendation:** **Needs Revision** - one blocker, which either a helper change or a text change in the header and `spec.md` closes.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-docs-complete-gate-target.ps1`; `.claude/hooks/enforce-docs-complete-gate.ps1`; `spec.md` | `Get-DocsCompleteGateUnquotedView` lines 130-131; `Test-DocsCompleteGateMergeCandidate` lines 202-211; header lines 40-46; `spec.md` Residual limits paragraph | F6: the view takes `MaskedText` from `Read-CommandLineSegment`, which tracks no comment state and does not nest quotes in a double-quoted substitution. Bash runs an unquoted merge line that the view shows as blank, so the command is not a candidate. The header says this group denies. | Deny groups A and B by adding a form of the command with comments removed to the candidate loop. Deny or name groups C and D. Correct the words "the unquoted text" so they mean what the code reads. | spec:516, story:65 and story:73 are graded on "each form denies or is named". These forms do neither. They do not fall within the limit, because that limit covers "any other way of causing a merge" and these are the first group in the statement. | F6 results. |
| Minor | `spec.md`; `user-story.md` | spec:525, story:74 | N13: unchanged. With the gate enabled, some non-merge mentions and non-integration compound merges deny. The header lists them as accepted false denies. | No code change. | Graded PASS on the tested scenario, as in earlier audits. | Header `Accepted false denies`. |
| Minor | N1 to N5 from `code-review.2026-11-07T01-25.md` | as recorded there | Deferred by the relayed owner directive; none was changed. | Keep them for a later cycle. | They were non-blocking and remain so. | Named files unchanged in this cycle. |
| Minor | `.claude/hooks/enforce-docs-complete-gate.ps1` | header `Known forms` | N15: five forms allow, merged under real bash or would reach the API, and are not named, although they fall within "forms not modelled": `$'g\x68' pr merge 12`, `printf 'pr\nmerge\n12\n' \| xargs gh`, a shell alias holding the merge, `echo <base64> \| base64 -d \| sh`, and `gh api repos/o/r/merges -f base=main -f head=x`, which merges branches with no pull request. | Add them to the list when the header is next edited. | The statement says its list is not complete, and none of these is in the group the hook claims to deny. Accepted under the standard the caller stated. | Probe rows; the last form was not run against GitHub. |
| Minor | `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1` | candidate test rows | N16: K8 (the spelled text keeps its quotes and backslashes) and K10 (the shared predicate call on line 202 removed) survive 496 of 496. No row splits a word inside a payload, such as `sh -c 'g"h" pr merge 12'`, which denies at head. | Add a payload row with a split word. Add a row that only line 202 denies, or remove the call if none exists. | The line coverage of the helper is 100%, and these two behaviors are not pinned. | Mutant table below. |
| Minor | `spec.md` | spec:540 | N17: the criterion says the figures are recorded under `<FEATURE>/evidence/coverage/`. That folder does not exist; the figures are in `evidence/qa-gates/coverage-delta.*`. | Correct the path in the criterion text or move the records. | The figures exist and were re-derived, so the criterion's substance holds. Earlier audits did not raise this. | Folder listing. |
| Minor | `.claude/hooks/enforce-docs-complete-gate-target.ps1` | `Test-DocsCompleteGateMergeText` line 158 | N18: the three `.*` terms scale cubically on text holding many `gh` and `pr` words and no `merge`. Measured on one call: 300 repeats (3.9 KB) 1.3 s; 600 repeats (7.8 KB) 8.7 s. The test runs on every Bash call before the profile is read, including with the gate disabled. | Use a linear scan, or pass a `[regex]` timeout that treats expiry as a candidate. | A command that size with those words is unlikely, so this is not blocking. The cost also falls on repositories that have not enabled the gate. | `perf` probe, 50 to 600 repeats. |
| Minor | `.claude/hooks/hook-command-payload.ps1` (shared, unchanged) | `Add-CommandLinePosixRecord` line 412 | N19: `<<` in arithmetic produces `Cannot bind argument to parameter 'Word' because it is null` on stderr of the hook process, with exit 0. `Invoke-DocsCompleteGateEntryPoint` has no catch, and its help says every anomaly is already a deny decision. `(( 1 << 2 ))<NL>ls` denies `PR_UNRESOLVED` with the gate enabled, and this false deny is not in the accepted list. The cause of that result was not traced. | Handle it with F6 group C, or add the form to the accepted false denies. The shared file stays unchanged. | The disabled and absent states still allow, so spec:516's disabled clause holds. | Real hook process rows. |

Closed since the previous review: F4, F5, N12 (merge commit `4ad00fca2`; merge base now equals the epic tip) and N14 (after-word check removed; `n14-removal.2026-11-07T04-59.md` records 1460 passed before and after). No covered file reaches the 700-line advisory tier; the largest is the hook suite at 669.

### F6 results

Decisions are from `Invoke-DocsCompleteGateDecision` with an enabled profile, no receipt, and a `gh` stand-in: 12 is the integration pull request. "Real bash" is what a stand-in `gh` on `PATH` recorded when the same text ran as a script. Rows marked (P) also ran in a real hook process, `pwsh -NoProfile -File`, with the envelope on standard input: `allow`, exit 0. `<NL>` is a newline.

| Group | Command | Decision | Lookup | Real bash passed to `gh` |
|---|---|---|---|---|
| A. Quote in a comment | `# Merge once it's green<NL>gh pr merge 12 --merge<NL># Delete the branch now that it's merged<NL>git status` (P) | **allow** | none | `pr merge 12 --merge` |
| | `git fetch # it's<NL>gh pr merge 12 --merge<NL>git status # it's` (P) | **allow** | none | `pr merge 12 --merge` |
| | `# it's<NL>gh api -X PUT repos/o/r/pulls/12/merge<NL># it's` (P) | **allow** | none | the `api` call |
| | `# "<NL>gh pr merge 12<NL># "` | **allow** | none | `pr merge 12` |
| | `gh pr view 34 # don't<NL>gh pr merge 12<NL># it's` | **allow** | none | `pr view 34`, then `pr merge 12` |
| B. Heredoc opener in a comment | `# a<<b<NL>gh pr merge 12<NL>b` (P) | **allow** | none | `pr merge 12` |
| | `# cat <<EOF<NL>gh pr merge 12<NL>EOF` (P, first probe set) | **allow** | none | `pr merge 12` |
| | `ls # c<<X<NL>gh pr merge 12<NL>X<NL>ls` | **allow** | none | `pr merge 12` |
| C. Shift in arithmetic | `x=$((1<<4))<NL>gh pr merge 12<NL>4` (P) | **allow**, with the N19 error on stderr | none | `pr merge 12` |
| D. Nested double quotes | `echo "$(echo "a"; gh pr merge 12; echo "b")"` (P, first probe set) | **allow** | none | `pr merge 12` |
| | `echo "$(git log -1 --format="%h"; gh pr merge 12)"` (P) | **allow** | none | `pr merge 12` |
| | `echo "$(echo "a" && gh api -X PUT repos/o/r/pulls/12/merge; echo "b")"` | **allow** | none | the `api` call |

Controls that deny at head: `# don't<NL>gh pr merge 12` (one apostrophe, so the span is unbalanced), `# cat <<EOF<NL>gh pr merge 12` (no terminator line), `echo "it's"<NL>gh pr merge 12<NL>echo "it's"`, ``# see `x<NL>gh pr merge 12<NL># ` ``, `# don't<NL>sh -c 'gh pr merge 12'<NL># it's`, `echo "$(date +"%F") $(gh pr merge 12)"`, `echo "$(gh pr merge 12)"`, `result="$(gh pr merge 12)"`.

With the gate disabled or the profile absent, each (P) row allows, as spec:516 requires.

History: groups A, B and D were allowed at `1e8c35e37` and at `3007ef346`. Group C raised the same error at both heads under the driver's `$ErrorActionPreference = 'Stop'`.

Why this is a finding under the stated standard: the limit statement has two parts. The first says the hook denies a group, starting with "the words `gh pr merge` ... in the unquoted text, including a compound command". The second says "any other way of causing a merge is not visible". The line `gh pr merge 12 --merge` in the first F6 row is unquoted to bash, so it is in the first part and is not an "other way". The sentence "the class is every form the text tests do not recognize" cannot also cover it without emptying the first part, and any command the hook misses would then pass by definition. The helper's own description of its view does not help, because these spans are not quoted spans and the first line is not a heredoc.

Forms probed and found correct, for the record: `gh pr -R o/r merge 12`, `gh pr --repo=o/r merge 12` and `gh -R o/r pr merge 12` look up 12 with `--repo o/r`; `'sh' -c '...'` and `"bash" -c '...'` deny; `$'gh' pr merge 12` and `echo $'\'' ; gh pr merge 12 ; echo $'\''` deny; `gh api` with `{owner}` placeholders, `-XPUT`, `--method=PUT` and quoted graphql text deny; `set -- pr merge 12; gh "$@"` and `gh $(echo pr merge 12)` deny; each heredoc delimiter spelling followed by a merge denies; a real double backslash before a newline denies. `gh pr -- merge 12` and `gh -- pr merge 12` allow, and real `gh` 2.103.3 rejects both as unknown commands, so neither merges.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `Read-DocsCompleteGatePlainCommand` now reads the raw text for the two cases the normalizer hides, and the rule is in its help. K1 and K2 confirm both are pinned.
- Removing backslashes from the view closes the command-word spellings with one `Replace` call. K3 is killed by 7 rows.
- The evaluator test is the fail-closed route for quoted payloads under any leading word. K4 is killed by 22 rows.
- The header now states the limit rather than a universal claim, and its accepted false denies match the probes, apart from N19.
- The `git commit -m 'gh pr merge 12'`, `echo "gh pr merge 12"` and `git log --grep='gh pr merge'` controls still allow.

#### API and safety notes

- The shared files are unchanged against the merge base: `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `hook-command-payload.ps1` and `enforce-epic-merge-gate-command.ps1`. F6 therefore also applies to the epic merge gate through the shared scanner. That gate was not assessed in this review.
- The orchestrator's sentence in `abb854f53` is accurate: `Invoke-DocsCompleteGateDecision` denies on a failed import and on an envelope anomaly before the candidate test. It matches the hook header, keeps the line count, and leaves the criterion text alone. spec:516's "allows every call" stays unqualified, which is how earlier audits read it.

#### Error handling and logging

N19 is the one change from earlier audits. Otherwise a malformed command denies, and a failed lookup denies.

---

## Test Quality Audit

### Reviewed test and QA artifacts

The three gate suites; `evidence/regression-testing/fail-before.2026-11-07T04-56.md`, `gate-rows.2026-11-07T04-58.md`, `n14-removal.2026-11-07T04-59.md`, `bash-comparison.2026-11-07T05-18.md`, `f4-f5-hook-process.2026-11-07T05-21.md`, `pester-parallel.2026-11-07T05-35.md`; `evidence/qa-gates/*.2026-11-07T05-*`; `evidence/other/criteria-reevaluation.2026-11-07T05-38.md` and `integration-merge.2026-11-07T04-53.md`.

### Quality assessment prompts

The comparison artifact is sound for what it covers: 320 rows, 29 escapes and 24 false denies by count, and the escape classes are all named. Its `ML` rows use comments with no quote or `<<`, so they could not show F6. No suite row holds an apostrophe in a comment.

Mutants of the cycle 3 lines were applied one at a time to a scratch copy of the helper and run against the three gate suites. The worktree was not modified. Control: 496 of 496 passed. 8 of 10 were killed.

| Mutant | Result |
|---|---|
| K1 split-word check on raw text removed | killed, 6 rows |
| K2 comment check on raw text disabled | killed, 3 rows |
| K3 backslash removal in the view removed | killed, 7 rows |
| K4 evaluator test removed | killed, 22 rows |
| K5 joined form of the command removed | killed, 6 rows |
| K6 raw form of the command removed | killed, 1 row |
| K7 `pwsh` and `powershell` removed from the evaluator words | killed, 1 row |
| K8 spelled text keeps quotes and backslashes | survived (N16) |
| K9 plain non-match returns not a candidate | killed, 14 rows |
| K10 shared predicate call for a non-plain command removed | survived (N16) |

Fail-first evidence is credible: 52 rows failed at the merged head and equal the derived set.

---

## Security / Correctness Checks

- Command injection: the selector passes to `gh` as one argument without a shell, and a dash-led selector is refused.
- Lookup failure: a thrown or failed `gh` call denies.
- Authorization: F6 is the remaining correctness failure of this control. In every probe that reached a lookup, the selector equaled the one bash passed.

---

## Research Log

- `.claude/hooks/hook-command-scanner.ps1`, `Read-CommandLineSegment`: no comment state; `<<` handling; double-quote span handling.
- `.claude/hooks/hook-command-payload.ps1`: `ConvertTo-CommandLineNormalizedText`, `Add-CommandLinePosixRecord`.
- `.claude/hooks/enforce-epic-merge-gate-command.ps1`: the scope predicate.
- `git archive` of `1e8c35e37` and `3007ef346` for the history rows.
- `gh` 2.103.3 outside any repository for the `--` rows.

---

## Verdict

**Needs Revision.** One Blocker (F6), and Minor rows N13, N1 to N5 (grouped), N15, N16, N17, N18 and N19. F4, F5, N12 and N14 are closed.
