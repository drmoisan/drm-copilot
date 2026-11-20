# Code Review: docs-enforcement-and-ci (#1034)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Feature Folder Selection Rule:** supplied by the caller; matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `e3e4aa551`)
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2` at `1e8c35e37`
**Review Type:** Re-audit after remediation cycle 2

---

## Executive Summary

Cycle 2 replaced the extended list of forms with a fail-closed allowlist in a new helper, `enforce-docs-complete-gate-target.ps1`. A merge candidate reaches the lookup only when `Read-DocsCompleteGatePlainCommand` proves the command is one plain `gh pr merge`. The design is the right direction: it is smaller than the code it replaced, and of 153 probe commands, every form of the previous F1 and F3 classes that was tested either binds the selector bash passes or denies. Notes N8, N9, N10 and N11 are closed.

Two gaps remain, both shown below against real bash:

- **F4:** the plain proof runs over normalized text, in which a backslash-newline is already a space. A comment ending in a backslash therefore hides the next line, which bash runs. This defeats the proof itself and is a deny-to-allow regression of this cycle.
- **F5:** three groups of forms are allowed and are not in the residual limits, although the header says every non-plain merge denies.

The executor's request to confirm the story:73 reading is answered in the feature audit: a non-plain merge denying `PR_UNRESOLVED`, rather than a receipt reason, is accepted as the intended design.

**What changed in this cycle:** the hook (500 to 325 lines), the new helper (290 lines), bundle copies, one `core.json` row, the hook suite, two new suites and `spec.md` design text.

**Top 3 risks:**
1. `gh pr merge 34 # note\<newline>gh pr merge 12` merges 12 with no receipt, after a lookup of 34 (F4).
2. `if true; then sh -c 'gh pr merge 12'; fi` is allowed although the same payload denies at top level (F5).
3. The branch conflicts with the current epic tip in `Invoke-DocsCommand.ps1`, so a pull request would receive no CI until that is resolved (N12).

**PR readiness recommendation:** **Needs Revision** - both blockers have small fixes in the helper, its tests, and the residual-limit text.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-docs-complete-gate-target.ps1` | `Read-DocsCompleteGatePlainCommand`, lines 42 and 51-54; `Test-DocsCompleteGateMergeCandidate`, lines 151-159 | F4: the reader works on `ConvertTo-CommandLineNormalizedText`, which replaces backslash-newline with a space before it scans, so the rule that a comment "must hold no newline" cannot see this newline. Bash does not continue a comment at a backslash, so the following line runs. Lines 152-159 then skip the unquoted view for a plain `gh`-led command. | Make such a command not plain: when the raw text holds a backslash-newline and the reader reaches a comment, return not plain, so the existing view and `Get-DocsCompleteGateMergeTarget` deny. Correct the helper header sentence. | spec:516 and story:73. The cycle's central claim is that only a whole command proven plain reaches the lookup. The hook at `3007ef346` denied the first row below. | F4 table. |
| Blocker | `.claude/hooks/enforce-docs-complete-gate-target.ps1`; `.claude/hooks/enforce-docs-complete-gate.ps1`; `spec.md` | `Get-DocsCompleteGateUnquotedView`, lines 126-127; header `Residual limits`; `spec.md` lines 265-267 | F5: `Test-EpicMergeGateCommandInScope` reads a quoted payload only when its wrapper is the command word of a segment, and the unquoted view blanks quotes, so these forms are not candidates. Backslash stays in the view, so `g\h` and `mer\ge` do not match the whole-word test. None of the groups is listed, and the header states that any non-plain merge denies. | Deny them or list them. Deny: remove backslashes in the view, and make a command a candidate when its quoted text holds the merge words and the view holds an unquoted evaluator word (`sh`, `bash`, `zsh`, `dash`, `eval`, `source`). Keep the `git commit -m` and `echo` controls allowed. Any group that stays allowed is named in the header and `spec.md`, and the "any form" sentence is corrected. | F3 required action 4 of `remediation-inputs.2026-11-07T02-24.md`: a form that stays unhandled goes in the residual limits. These are integration merges allowed with no receipt, contrary to spec:516 and story:73 as graded in the previous review. | F5 table. |
| Minor | branch | merge with `origin/epic/documentation-estate-tooling-integration` | N12: pull request #1099 moved the epic tip to `e1f4d2e54` during this cycle. `git merge-tree` reports content conflicts in `.claude/lib/docs/Invoke-DocsCommand.ps1` and its bundle copy. The epic also changed `core.json` and `enforcement-hooks-no-python-invocation.Tests.ps1`. | Merge the epic tip in the next cycle, before its final gates, and keep the bundle copy byte-identical. | A conflicted pull request receives no CI, so S9 cannot complete. Sibling changes can also break suites that pin lists. | `git merge-tree --write-tree --name-only`. The review scope stays the supplied merge base. |
| Minor | `spec.md`; `user-story.md` | spec:525, story:74 | N13: the criteria say the hook allows non-merge commands and non-integration merges. With the gate enabled, `gh pr view 12 \| grep merge` and `gh pr checks 12 && git merge main` deny, and so do a compound or `gh api` merge of a non-integration pull request. The residual limits record this as accepted, and the caller states it is intended. | No code change. Leave the criterion text as written, or have the owner adjust it. | Graded PASS on the tested scenario, as earlier audits graded this kind of text. The documented merge form, `gh pr merge <PR> --merge`, is plain and unaffected. | Probe rows 132, 134, 135. |
| Minor | N1 to N5 from `code-review.2026-11-07T01-25.md` | as recorded there | Deferred by the relayed owner directive; none was changed. | Keep them for a later cycle or fold them into the next one. | They were non-blocking and remain so. | Named files unchanged in this cycle. |
| Info | `.claude/hooks/enforce-docs-complete-gate-target.ps1` | lines 98-102 | N14: the after-word check is redundant. Removing it (H6) passes 335 of 335, because any character it refuses also fails at the start of the next word. | Remove it when the file is next edited. | Less code in the proof makes the proof easier to check. | H6 below. |

Closed since the previous review: N8 (`spec.md` carries the final lookup, helper and limits, with the line count preserved), N9 (the listed context changes are not plain and deny, and the earlier-call case is in the residual limits), N10 (A17 killed) and N11 (hook 325 lines). No file reaches the 700-line advisory tier. The helper has no suppression attribute.

### F4 results

Decisions are from `Invoke-DocsCompleteGateDecision` with an enabled profile, no receipt, and a `gh` stand-in: 12 is the integration pull request and every other selector is `feature/current` into `development`. "Real bash" is what a stand-in `gh` on `PATH` recorded. `\<NL>` is a backslash followed by a newline.

| Command | Hook at head | Lookup | Hook at `3007ef346` | Real bash passed to `gh` |
|---|---|---|---|---|
| `gh pr merge 34 # x\<NL>gh pr merge 12` | **allow** | `pr view 34` | deny `PR_UNRESOLVED` | `pr merge 34`, then `pr merge 12` |
| `gh pr merge 34 # first line \<NL>gh pr merge 12 # second` | **allow** | `pr view 34` | deny `PR_UNRESOLVED` | `pr merge 34`, then `pr merge 12` |
| `gh pr merge 34 \<NL># x\<NL>gh pr merge 12` | **allow** | `pr view 34` | deny `PR_UNRESOLVED` | `pr merge 34`, then `pr merge 12` |
| `gh pr view 34 # x\<NL>gh pr merge 12` | **allow** | none | allow | `pr view 34`, then `pr merge 12` |
| `gh pr merge --disable-auto # x\<NL>gh pr merge 12` | **allow** | none | allow | `pr merge --disable-auto`, then `pr merge 12` |
| `gh pr view 34 --json title # x\<NL>gh api -X PUT repos/o/r/pulls/12/merge` | **allow** | none | allow | `pr view 34 --json title`, then the `api` call |

The fourth and fifth rows also ran in a real hook process, in a scratch consumer with the gate enabled and no receipt: `permissionDecision: allow`, exit 0.

Controls that behave correctly: `gh pr merge 34<NL>gh pr merge 12` and `ls # x\<NL>gh pr merge 12` deny; `gh pr merge 12 #99` and `gh pr merge 12 # note; echo done` look up 12.

### F5 results

Same stand-in. Rows marked (P) also ran in a real hook process with `allow`, exit 0. All rows gave the same result at `3007ef346` and were not in the previous table.

| Group | Command | Decision | Real bash passed to `gh` |
|---|---|---|---|
| Quoted payload under a leading word | `if true; then sh -c 'gh pr merge 12'; fi` (P) | **allow** | `pr merge 12` |
| | `if true; then bash -c "gh pr merge 12"; fi` | **allow** | `pr merge 12` |
| | `! sh -c 'gh pr merge 12'` (P) | **allow** | `pr merge 12` |
| | `exec sh -c 'gh pr merge 12'` (P) | **allow** | `pr merge 12` |
| | `for n in 12; do sh -c "gh pr merge $n"; done` | **allow** | `pr merge 12` |
| | `if true; then eval 'gh pr merge 12'; fi`, `! eval 'gh pr merge 12'` | **allow** | `pr merge 12` |
| | `nice sh -c 'gh pr merge 12'`, `find . -maxdepth 0 -exec sh -c 'gh pr merge 12' \;` | **allow** | `pr merge 12` |
| | `sudo sh -c 'gh pr merge 12'` | **allow** | not observed; no `sudo` on this host |
| | `if true; then bash <<EOF<NL>gh pr merge 12<NL>EOF<NL>fi` | **allow** | `pr merge 12` |
| Quoted text piped into a shell | `echo 'gh pr merge 12' \| sh` (P), `printf 'gh pr merge 12' \| bash` | **allow** | `pr merge 12` |
| Backslash in a command word | `g\h pr merge 12` (P), `gh pr mer\ge 12` (P), `gh p\r merge 12`, `true; g\h pr merge 12` | **allow** | `pr merge 12` |

Top-level controls that deny: `sh -c 'gh pr merge 12'`, `bash -c "gh pr merge 12"`, `eval 'gh pr merge 12'`, `env sh -c '...'`, `sh <<< '...'`, `bash <<EOF`, `pwsh -NoProfile -Command '...'`, `\gh pr merge 12`, `gh pr \merge 12`.

These forms need a person or agent to wrap the merge deliberately, and the header calls the hook a policy-level control, so listing them is an acceptable outcome. The finding is that they are neither denied nor listed. "Quoted command word" and "`eval` over assembled text" do not describe a literal payload.

Related text gaps to close in the same edit: `python -c` and `node -e` carrying the merge, and `curl -X PUT .../pulls/12/merge`, are allowed and unlisted. The header names only `git push` as outside `gh` scope.

Allowed forms that the residual limits do list, confirmed here: `if true; then "gh" pr merge 12; fi`, `! gh pr 'merge' 12`, `exec gh 'pr' merge 12`, `gh pr me${x}rge 12`, `gh api graphql -F query=@f.graphql`, `gh api graphql --input f`, `gh api -X PUT repos/o/r/pulls/$n/merge`, `gh alias set m 'pr merge 12'; gh m`.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- A redirection, brace, `&` or `#` form now denies or binds correctly: `gh pr merge 2>&1 12` denies, `gh pr merge 12 2>&1` looks up 12, `gh pr merge 12>log` is a bare lookup as bash reads it, and `gh pr merge 12&>log` looks up 12.
- The operand reader handles `--disable-auto` more accurately than before: `gh pr merge --disable-auto --body -m 12` now allows, because `-m` is the body value, and real bash passed it that way.
- Case and path spellings are candidates and deny: `GH`, `gh.exe`, `/usr/bin/gh`, `./gh`.
- All quoted spellings of a `gh api` merge endpoint deny at top level, including `pulls/'12'/merge` and `mer"ge"`.
- Removing `Read-DocsCompleteGateApiTarget` and `Test-DocsCompleteGateContextChange` reduced the code.

#### API and safety notes

- The shared command file is unchanged in both hook trees, so the epic merge gate keeps its behavior, including the gaps recorded earlier.
- The documented merge forms in the skills, `gh pr merge <PR> --merge` and `gh pr merge --merge <PR>`, are plain. A form with a shell variable, such as `--match-head-commit "$sha"`, denies with the gate enabled; the deny message states the remedy.

#### Error handling and logging

Unchanged since the previous audit. A malformed command (unbalanced quotes) denies, and no probe threw.

---

## Test Quality Audit

### Reviewed test and QA artifacts

The three gate suites; `evidence/regression-testing/fail-before.2026-11-07T03-32.md`, `gate-rows`, `bash-exact-after`, `f3-hook-process-after`, `mutant-a17` and `pester-parallel.2026-11-07T03-57.md`; `evidence/qa-gates/*.2026-11-07T03-*` and `*T04-*`; `evidence/other/criteria-reevaluation.2026-11-07T04-00.md`.

### Quality assessment prompts

Mutants were applied to a scratch copy of the helper, one at a time, and run against the three gate suites. The worktree was not modified. Control: 335 of 335 passed. 25 of 29 were killed.

| Mutant | Result |
|---|---|
| H1 comment newline check removed | killed (real newline only; F4 is the continuation form) |
| H2 comment after redirection check removed | survived; equivalent, line 105 denies the same input |
| H3 word after redirection accepted | killed |
| H4 dangling redirection accepted | killed |
| H5 expansion in double quotes accepted | killed |
| H6 after-word check removed | survived; equivalent (N14) |
| H7 invalid `>&` target accepted | survived; every form but a bare trailing `>&`, a bash syntax error, still denies |
| H9 `--disable-auto` exemption removed | killed |
| H10 walk miss treated as no merge | killed |
| H11 scope predicate removed | killed |
| H12 view merge test removed | killed |
| H13 view API test removed | killed |
| H14 command word case-insensitive | killed |
| H15 walk check removed from the target | survived; likely equivalent, the operand read from index 0 finds three positionals |
| H16 unreadable operands accepted | killed |
| H17 repository shape unchecked | killed |
| H18 `--merge=1` read as a selector | killed |
| H19 `--disable-auto=value` ignored | killed |
| H20 action flag ignored | killed |
| H21 two selectors accepted | killed |
| H22 selector shape unchecked | killed |
| H23 cluster action letter ignored | killed |
| H24 absent flag value accepted | killed |
| H25 `&>` not read | killed |
| H26 repository not read | killed |
| H27 head pin not read | killed |
| H28 unknown cluster letter accepted | killed |
| H29 two repositories accepted | killed |
| A17 unknown flag accepted | killed (closes N10) |

Fail-first evidence is credible: the executor's rows failed at the unmodified head and pass now, and the mutants above confirm the rows discriminate the behaviors they name. The gap is in the probe set, not in the strength of the rows.

---

## Security / Correctness Checks

- Command injection: the selector passes to `gh` as one argument without a shell, and a dash-led selector is refused.
- Lookup failure: a thrown or failed `gh` call denies.
- Authorization: F4 and F5 are the remaining correctness failures of this control.

---

## Research Log

- `.claude/hooks/hook-command-payload.ps1`, for `ConvertTo-CommandLineNormalizedText` (backslash-newline to a space).
- `.claude/hooks/hook-command-scanner.ps1` and `hook-command-invocation.ps1`, for segments and the structural walk.
- `.claude/hooks/enforce-epic-merge-gate-command.ps1`, for the scope predicate.
- `.claude/skills/orchestrate/SKILL.md`, `parallel-orchestrate/SKILL.md` and `epic-orchestrate/SKILL.md`, for the merge forms in use.
- A `git archive` of `3007ef346` for base-versus-head decisions on the first probe list.

---

## Verdict

**Needs Revision.** Two Blockers (F4, F5), three Minor rows (N12, N13, N1 to N5 grouped) and one Info row (N14). F1 and F3 are closed for every listed form; N8, N9, N10 and N11 are closed.
