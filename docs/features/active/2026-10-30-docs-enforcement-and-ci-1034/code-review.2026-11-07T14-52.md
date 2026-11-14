# Code Review: docs-enforcement-and-ci (#1034)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Feature Folder Selection Rule:** supplied by the caller; matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `e1f4d2e54`, which is the current tip)
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2` at `709dcf95b`
**Review Type:** Re-audit after remediation cycle 4

---

## Executive Summary

Cycle 4 closed F6 by text, as the owner chose. No hook logic changed. The `What it establishes` and `Outside what it can observe` paragraphs of the hook header, its byte-identical bundle copy, and the residual-limits bullet of `spec.md` now:

- say the hook denies the merge words "in the text the shared scanner reads as unquoted", replacing "in the unquoted text";
- state the three scanner behaviours behind the F6 allows: no comment state, `<<` read as a heredoc opener, and no nesting of double quotes inside a command substitution inside double quotes;
- name the four F6 groups (a quote in a `#` comment before and after the merge line, `<<` in a `#` comment, a shift in arithmetic, nested double quotes) and the five N15 forms.

This review checked each claim against `Read-CommandLineSegment`, `Get-DocsCompleteGateUnquotedView` and `Test-DocsCompleteGateMergeCandidate`, and ran the candidate predicate at head on the F6 rows, the controls and adjacent forms. The text matches the code. One clause is broader than the code (N20, Minor): the scanner reads `<<` as an opener only outside quotes and treats `<<<` as a here-string. That widens the stated limit and does not claim a denial that does not occur.

Under the owner review standard (a form the hook does not model is non-blocking when the limit text names it), F6 is closed. No blocker remains.

**What changed in this cycle:** hook help text (342 to 353 lines) and its bundle copy; two `spec.md` limit lines and the spec:540 path; check-offs in `spec.md` and `user-story.md`; plan and evidence. The helper and the shared scanner files are unchanged.

**Top 3 risks:**
1. Merges in the named F6 forms still proceed with no receipt when the gate is enabled. This is now a stated limit of a policy-level control, accepted by the owner.
2. The same scanner behaviours affect the epic merge gate, which shares the scanner and was not assessed here.
3. Mutants K8 and K10 still survive (N16), so two parts of the candidate test have no pinning row.

**PR readiness recommendation:** **Ready** - no blocker; spec:544 is pending CI at S9.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-docs-complete-gate.ps1`; `spec.md` | header `What it establishes`; spec residual-limits bullet | N20: "reads << as a heredoc opener wherever it appears" is broader than the code. `Read-CommandLineSegment` reaches its `<<` branch only outside single and double quotes, and treats `<<<` as a here-string with no body. `echo "a<<b"; gh pr merge 12` and `cat <<< x; gh pr merge 12` are candidates at head. | Say "outside quotes" and exclude `<<<` when the header is next edited. | The overstatement widens the stated limit; it does not claim a denial that does not occur, so a reader is not led to rely on the gate. Non-blocking. | Scanner lines 275-326; probe rows Q1 and Q2. |
| Minor | `spec.md`; `user-story.md` | spec:525, story:74 | N13: unchanged accepted false denies. | No change. | As in earlier audits. | Header `Accepted false denies`. |
| Minor | N1 to N5 from `code-review.2026-11-07T01-25.md` | as recorded there | Deferred by owner directive; unchanged. | Keep for a later cycle. | Non-blocking, as before. | Named files unchanged in this cycle. |
| Minor | `tests/scripts/claude-hooks/enforce-docs-complete-gate-compound.Tests.ps1` | candidate test rows | N16: K8 and K10 survive; unchanged. | Add a split-word payload row and a row for line 202. | No test changed this cycle. | Previous mutant table. |
| Minor | `.claude/hooks/enforce-docs-complete-gate-target.ps1` | `Test-DocsCompleteGateMergeText` line 158 | N18: cubic scaling on many `gh` and `pr` words; unchanged. | Linear scan or a regex timeout that treats expiry as a candidate. | Unlikely input size; non-blocking. | Previous `perf` probe. |
| Minor | `.claude/hooks/hook-command-payload.ps1` (shared, unchanged) | `Add-CommandLinePosixRecord` | N19: `<<` in arithmetic writes a parameter-binding error to stderr; unchanged. The named-form driver recorded it twice on row R3. | Handle when the shared file is next changed. | The disabled and absent states still allow. | `named-form-decisions.2026-11-07T14-25.md` row R3. |

Closed since the previous review: F6 (limit text), N15 (five forms named) and N17 (spec:540 now names `evidence/qa-gates/`, a canonical evidence kind where `coverage-delta.*` records the figures).

No covered file reaches the 700-line advisory tier: the hook is 353 logical lines and the helper 334. No covered file above 800 lines, and `config/file-size-baseline.json` is not in the diff.

### Limit text against the code

| Claim in the text | Code | Result |
|---|---|---|
| The view is "the text the shared scanner reads as unquoted" | `Get-DocsCompleteGateUnquotedView` joins `MaskedText` of every `Read-CommandLineSegment` record and removes backslashes | accurate |
| The scanner "keeps no comment state" | `Read-CommandLineSegment` has no `#` handling; a quote in a comment opens a span | accurate |
| It "reads << as a heredoc opener wherever it appears" | the `<<` branch is reached only outside quotes, and `<<<` is excluded | broader than the code (N20) |
| It "does not nest double quotes inside a command substitution inside double quotes" | in the double-quoted branch, `$(` only sets `hasLiveSubstitution`, and the next `"` closes the span | accurate |
| A merge line bash runs "can read as quoted or heredoc text and allow" | the evaluator path still denies when an evaluator word is in the view; "can" covers that | accurate |

### Predicate probe at head

`Test-DocsCompleteGateMergeCandidate` with the four shared files and the helper dot-sourced. `<NL>` is a newline. A candidate goes on to the lookup and receipt checks; with the gate enabled and no receipt, a non-candidate allows.

| Row | Command | Candidate | Expected from the text |
|---|---|---|---|
| R1 | `# Merge once it's green<NL>gh pr merge 12 --merge<NL># Delete the branch now that it's merged<NL>git status` | no | named, allows |
| R1b | `git fetch # it's<NL>gh pr merge 12 --merge<NL>git status # it's` | no | named, allows |
| R1c | `# it's<NL>gh api -X PUT repos/o/r/pulls/12/merge<NL># it's` | no | named, allows |
| R1d | a double quote in a comment before and after the merge line | no | named ("a quote character"), allows |
| R2 | `# a<<b<NL>gh pr merge 12<NL>b` | no | named, allows |
| R3 | `x=$((1<<4))<NL>gh pr merge 12<NL>4` | no | named, allows |
| R4 | `echo "$(git log -1 --format="%h"; gh pr merge 12)"` | no | named, allows |
| Q1 | `echo "a<<b"; gh pr merge 12` | yes | denies (N20) |
| Q2 | `cat <<< x; gh pr merge 12` | yes | denies (N20) |
| Q3 | `# it's<NL>gh pr merge 12` (one quote only) | yes | denies; the text says "before and after" |
| Q4 | a backtick substitution with nested double quotes holding the merge | yes | denies |
| C1 | `git commit -m 'gh pr merge 12'` | no | control, allows |
| C2 | `echo "gh pr merge 12"` | no | control, allows |
| C3 | `git log --grep='gh pr merge'` | no | control, allows |
| C4 | `gh pr merge 12 # note` | yes | plain lookup row |
| C5 | `gh pr merge 34 # it's` | yes | plain lookup row |
| C6 | `git fetch && gh pr merge 12` | yes | compound, denies |

The executor's named-form driver (`named-form-decisions.2026-11-07T14-25.md`) ran R1 to R9 and C1 to C5 through `Invoke-DocsCompleteGateDecision` with an enabled profile and no receipt and recorded the same outcomes, including one lookup each for C4 and C5. Its preflight run against the pre-edit hook gave identical decisions, which is expected for a help-only change. No newly found form allows outside the named classes.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The limit statement now describes the scanner's view rather than bash's, so the group the hook claims to deny matches what the code reads.
- Each F6 group and each N15 form is named with an example, and the token check (`limit-text-check.2026-11-07T14-25.md`) failed on the unedited tree with 24 rows and passed after the edit, so it can detect a missing token.
- The hook and its bundle copy share blob `8a3715abe`. The helper (`31e2736e9`) and the four shared scanner files are unchanged in every tree.
- `spec.md` stays at 560 lines with `## Acceptance Criteria` at line 512, at both `abb854f53` and head; the edits replace existing lines.

#### API and safety notes

- The change is text only. Analyzer 0 findings and formatter 0 differences on the hook and its copy, re-run in this review.
- The epic merge gate shares the scanner. It was not assessed.

#### Error handling and logging

Unchanged. N19 remains non-blocking.

---

## Test Quality Audit

### Reviewed test and QA artifacts

`evidence/regression-testing/limit-text-check.2026-11-07T14-25.md`, `named-form-decisions.2026-11-07T14-25.md`, `pester-parallel.2026-11-07T14-35.md`; `evidence/baseline/pester-parallel.2026-11-07T14-15.md`, `pytest-parallel.2026-11-07T14-22.md`; `evidence/qa-gates/*.2026-11-07T14-*`; `evidence/other/criteria-reevaluation.2026-11-07T14-41.md`, `hook-limit-text-edit.2026-11-07T14-24.md`, `spec-limit-text-edit.2026-11-07T14-25.md`, `n17-coverage-path.2026-11-07T14-26.md`.

### Quality assessment prompts

No test file changed. The parallel Pester gate (17177 tests, 0 failures) and the `pytest -n auto` gate (16350 passed, 0 failures) match their baselines with an empty failure set. Single-process and ordering runs are waived by owner directive and were not required. The coverage file was written at 14:35Z, after the last production commit.

---

## Security / Correctness Checks

- Command injection: unchanged; the selector passes to `gh` as one argument without a shell.
- Lookup failure: unchanged; a thrown or failed `gh` call denies.
- Authorization: the named forms allow by design under the owner standard. The hook is a policy-level control, not a security boundary, as its header states.

---

## Research Log

- `.claude/hooks/hook-command-scanner.ps1`, `Read-CommandLineSegment` lines 260-340: single-quote, double-quote, backslash, `<<` and `<<<` branches.
- `.claude/hooks/enforce-docs-complete-gate-target.ps1` lines 112-213.
- `git diff abb854f53 HEAD` outside the evidence folders; `git hash-object` on every copy of the hook, helper and shared files.

---

## Verdict

**Ready.** No Blocker. Minor rows N20 (new), N13, N1 to N5 (grouped), N16, N18 and N19. F6, N15 and N17 are closed.
