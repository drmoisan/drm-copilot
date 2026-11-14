# Code Review: docs-enforcement-and-ci (#1034)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034`
**Feature Folder Selection Rule:** supplied by the caller; matches the issue number in the branch name.
**Base Branch:** `origin/epic/documentation-estate-tooling-integration` (merge base `e3e4aa551`)
**Head Branch:** `feature/docs-enforcement-and-ci-1034-r2` at `3007ef346`
**Review Type:** Re-audit after remediation cycle 1

---

## Executive Summary

Cycle 1 replaced the number-only lookup with a target binder (`Get-DocsCompleteGateMergeTarget` and two readers) and made a read failure distinct from an absent file. The new code is well structured, the 58 new rows failed before the fix, and 26 of 28 mutants were killed.

**F2 is closed.** In real processes, a locked profile denies `PROFILE_UNREADABLE`, a locked receipt denies `RECEIPT_UNREADABLE`, an empty profile and a directory at the profile path deny, and an absent profile allows.

**The six commands in the previous F1 probe table now give the required result.** F1 is still open, because the same defect remains for forms outside that table, and one of those forms is a regression introduced by this cycle. A related fail-open in scope admission is recorded as F3. Both are shown below with results from real bash and real hook processes.

**What changed in this cycle:** the hook and its bundle copy (271 changed lines each) and the hook suite (252 changed lines). No other production file changed.

**Top 3 risks:**
1. A natural command form, `if gh pr checks 12; then gh pr merge 12 --merge; fi`, merges an integration pull request with no receipt and no lookup (F3).
2. A selector placed after a redirection that contains `&` is lost, and the current branch is looked up instead (F1).
3. The hook is at the 500-line limit of spec:541, so the next fix cannot be added to the file as it stands.

**PR readiness recommendation:** **Needs Revision** - the gate still allows integration merges with no receipt in the forms below.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-docs-complete-gate.ps1` | `Read-DocsCompleteGateMergeOperand`, lines 185-228; `Get-DocsCompleteGateMergeTarget`, lines 325-339 | F1, remaining forms: the reader works on one scanner segment, and `&` and `{` are segment delimiters, so `2>&1 12` ends the segment at `2>` and the selector goes to the next record. The dangling `2>` is accepted, the selector is `$null`, and the lookup is bare. Separately, a `#`-led token is taken as a selector, although bash treats it as a comment. | Do not treat a record that ends in a redirection operator, or whose delimiter is `{`, as complete: read the operands of the following record, or deny `PR_UNRESOLVED` when that record holds more than a file descriptor. Treat an unquoted `#`-led token as the end of the operands. | F1 required action 2: deny `PR_UNRESOLVED` for an in-scope target the hook cannot resolve. A null selector reaching a bare lookup is the defect F1 described. | F1 tables below. |
| Blocker | `.claude/hooks/enforce-docs-complete-gate.ps1`; `.claude/hooks/enforce-epic-merge-gate-command.ps1` | decision line 419; `Test-EpicMergeGateCommandInScope` | F3: `gh` is not the command word of a segment that starts with `if`, `then`, `elif`, `else`, `while`, `until`, `do`, `!`, `exec`, `sudo`, `nice` or `coproc`, or of a `find -exec` argument, so no match exists and the hook allows with no profile read and no lookup. | Admit these forms before the scope decision: a hook-local check that denies `PR_UNRESOLVED` when such a segment holds a `gh pr merge` or a merge `gh api`, or a change to the shared invocation reader in both hook trees. | The merge is allowed with the gate enabled and no receipt, contrary to spec:516 and story:73. The header's residual limits list three scope gaps, and this is not one of them. | F3 table below. |
| Minor | `docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md` | lines 233, 254-255, 265-267 | N8: the design text still states `gh pr view [<N>]`, the earlier residual limits, and a `RECEIPT_UNREADABLE` definition without the read failure. F1 required action 4 asked for the accepted remainder in `spec.md`. P2-T5 was waived. | Run P2-T5 with the next hook change, so `spec.md` records the final limits once. | Later children read this file as a contract. | `git diff 678f8c571 HEAD -- spec.md` is empty. |
| Minor | `.claude/hooks/enforce-docs-complete-gate.ps1` | `Test-DocsCompleteGateContextChange`, lines 286-292 | N9: these context changes are not detected: `env --chdir=../other`, `builtin cd`, `! cd`, `GIT_DIR=`, and an exported variable whose assignment is not in one token (`read GH_REPO`, bare `export GH_REPO`). | Add the forms, or list them in the residual limits. | Effect needs the same number to be a non-integration pull request locally and the integration pull request elsewhere, so the risk is small. | Probe: each gave `allow` after a local lookup. `env -C ../other` and `env --chdir ../other` deny. |
| Minor | `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | `gh pr merge 12 --unknown` row | N10: removing the unknown-flag check (A17) passes 111 of 111, because the row's flag is the last token and fails on the missing value instead. | Add a row with a following token, such as `gh pr merge 12 --unknown x`. | The check has no effective test. Behavior at head is correct: both forms deny by direct probe. | A17 survived. |
| Minor | N1 to N5 from `code-review.2026-11-07T01-25.md` | as recorded there | Deferred by the relayed owner directive; none was changed in this cycle. | Keep them for a later cycle or fold them into the next one. | They were non-blocking and remain so. | `git diff 678f8c571 HEAD` holds no change to the named files other than the hook and suite. |
| Info | `.claude/hooks/enforce-docs-complete-gate.ps1` | whole file | N11: the file is exactly 500 logical lines, and several statements are long single lines (for example lines 316 and 335). | Move the target readers to a helper file when F1 and F3 are fixed. Update the manifest, bundle and dependency closure with it. | spec:541 allows no more than 500 lines for a new production file. | `@(Get-Content).Count` returned 500. |

N6 from the previous review is closed: the uppercase `headRefOid` row exists and A21 was killed. No file reaches the 700-line advisory tier. This cycle added one suppression attribute, with a justification, on the Pester helper `Set-TestTargetSeam`, and none in the hook.

### F1 remaining forms

Decisions are from `Invoke-DocsCompleteGateDecision` with an enabled profile, no receipt, and a `gh` stand-in: 12 and the integration branch are the integration pull request, and no selector returns `feature/current` into `development`. "Real bash" is what a stand-in `gh` on `PATH` received when bash ran the same text. Rows 1 to 5 were also run in a separate process with only the `gh` seam replaced, with the same results.

| Command | Lookup issued | Decision | Real bash passed to `gh` |
|---|---|---|---|
| `gh pr merge 2>&1 12` | `pr view` | **allow** | `pr merge 12` |
| `gh pr merge --merge 2>&1 epic/x-integration` | `pr view` | **allow** | not run; same form as row 1 |
| `gh pr merge >log 2>&1 12` | `pr view` | **allow** | `pr merge 12` |
| `gh pr merge &>log 12` | `pr view` | **allow** | `pr merge 12` |
| `gh pr merge {12..12}` | `pr view` | **allow** | `pr merge 12` |
| `gh pr merge >&2 12` | `pr view` | **allow** | `pr merge 12` |
| `gh pr merge 1{2..2}` | `pr view 1` | wrong pull request looked up | not run; same expansion as the `{12..12}` row |

Controls that behave correctly: `gh pr merge 2>/dev/null 12`, `gh pr merge > 99 12`, `gh pr merge 12 --merge 2>&1`, `gh pr merge 12>x` (bare, as bash reads it).

Comment form, with the stand-in changed so that no selector returns the integration pull request (a checkout of the integration branch) and 99 is an unrelated pull request:

| Command | Hook at head | Hook at `48892dc05` | Real bash passed to `gh` |
|---|---|---|---|
| `gh pr merge --merge` | deny `RECEIPT_ABSENT` | deny `RECEIPT_ABSENT` | not run; control |
| `gh pr merge #99` | **allow**, lookup `pr view #99` | deny `RECEIPT_ABSENT`, lookup `pr view` | `pr merge` with no selector |

This comment row is a deny-to-allow regression of cycle 1. The other F1 rows gave the same result at `48892dc05`. Lookups of `#99` assume `gh` reads a `#`-prefixed number; the stand-in models that, and real `gh` was not exercised here.

### F3 results

The first four rows ran in a real hook process in a scratch consumer with the gate enabled and no receipt: each returned `permissionDecision: allow`, exit 0, no standard error. Real bash passed `pr merge 12` to `gh` for all four, with `if true` in place of the `gh pr checks` test in the first row. The other rows ran through the decision function.

| Command | Decision | Lookup |
|---|---|---|
| `if gh pr checks 12; then gh pr merge 12 --merge; fi` | **allow** | none |
| `for n in 12; do gh pr merge "$n" --merge; done` | **allow** | none |
| `! gh pr merge 12` | **allow** | none |
| `exec gh pr merge 12` | **allow** | none |
| `while true; do gh pr merge 12 --merge; break; done` | **allow** | none |
| `if false; then echo x; else gh pr merge 12; fi` | **allow** | none |
| `until gh pr merge 12; do sleep 1; done` | **allow** | none |
| `sudo gh pr merge 12`, `nice gh pr merge 12`, `coproc gh pr merge 12` | **allow** | none |
| `find . -maxdepth 0 -exec gh pr merge 12 \;` | **allow** | none |

Controls that deny: `gh pr checks 12 && gh pr merge 12 --merge`, `case x in x) gh pr merge 12;; esac`, `f() { gh pr merge 12; }; f`, `time gh pr merge 12`, `nohup gh pr merge 12`.

All rows gave the same result at `48892dc05`, so F3 was present before this cycle and was not in the previous probe list. `Test-EpicMergeGateCommandInScope` is shared, so from reading the code the epic merge gate has the same gap; that gate was not run for this review.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Commands holding a second merge deny across `;`, `||`, `&`, `|`, newline, `sh -c`, `$(...)`, backticks, `eval`, heredocs, subshells and groups.
- Selector, repository and head pin are read in one closed-table pass, including short clusters, equals forms and `--` handling.
- `--repo` values from global and local positions are merged, and a conflict denies with no `gh` call.
- A GraphQL mutation, `--hostname`, an absolute URL endpoint and non-literal operands deny with no `gh` call.
- The binder also closed `a=gh; $a pr merge 12` and `gh pr merge $'12'`, which allowed at `48892dc05`.

#### API and safety notes

- `enforce-epic-merge-gate-command.ps1` is unchanged and identical in `.claude/hooks`, `.codex/hooks` and the merge base.
- Fail-closed behavior increases denials for an enabled gate: a `cd` in the same command as a numeric merge now denies. The message states the remedy, and the plan accepted this.

#### Error handling and logging

F2 is resolved. `Get-DocsCompleteGateFileText` catches only `FileNotFoundException` and `DirectoryNotFoundException`, and both callers map any other failure to a named deny. The exception type name is included in the message, with no path.

---

## Test Quality Audit

### Reviewed test and QA artifacts

The hook suite; `evidence/regression-testing/fail-before.2026-11-07T01-51.md`, `gate-rows`, `locked-file-run` and `pester-parallel`; `evidence/qa-gates/*.2026-11-07T01-55.md`; `evidence/other/owner-waiver.2026-11-07T01-51.md`.

### Quality assessment prompts

Mutants were applied to a scratch copy of the hook, one at a time. The worktree was not modified. Control: 111 of 111 passed.

| Mutant | Result |
|---|---|
| A1 gated count only lower bound | killed |
| A2 injected check removed | killed |
| A3 structural check removed | survived; direct probe of Indeterminate forms still denies, so this is likely equivalent |
| A4 two repositories accepted | killed |
| A5 repository shape unchecked | killed |
| A6 URL exemption removed | killed |
| A7 context check removed | killed |
| A8 GH_ assignment unchecked | killed |
| A9 repository not forwarded | killed |
| A10 selector not forwarded | killed |
| A11 absent parent treated as failure | killed |
| A12 absent file treated as failure | killed |
| A13 redirection not skipped | killed |
| A14 detached redirect target kept | killed |
| A15 two selectors accepted | killed |
| A16 non-literal selector accepted | killed |
| A17 unknown flag accepted | survived (N10) |
| A18 two endpoints accepted | killed |
| A19 graphql check removed | killed |
| A20 hostname check removed | killed |
| A21 head case-insensitive | killed (closes N6) |
| A22 receipt read reason wrong | killed |
| A23 lookup throw not caught | killed |
| A24 disable-auto sibling counted | killed |
| A25 only `cd` recognized | killed |
| A26 `-R` not read | killed |
| A27 cluster equals kept | killed |
| A28 profile read failure ignored | killed |

---

## Security / Correctness Checks

- Command injection: the selector passes to `gh` as one argument without a shell, and a dash-led selector is refused.
- Lookup failure: a thrown or failed `gh` call denies. A separate process with the real seam and a locked receipt denied `RECEIPT_UNREADABLE`.
- Authorization: F1 and F3 are the remaining correctness failures of this control.

---

## Research Log

- `.claude/hooks/hook-command-scanner.ps1`, for the segment delimiters (`&`, `{`, `(`) and tokenization.
- `.claude/hooks/hook-command-invocation.ps1`, for the transparent wrapper list (`command`, `env`, `nohup`, `time`, `timeout`).
- `.claude/hooks/enforce-epic-merge-gate-command.ps1`, for the scope predicate and flag table.
- A `git archive` of `48892dc05` for base-versus-head decisions on the same probe list.

---

## Verdict

**Needs Revision.** Two Blockers (F1 remaining forms, F3), four Minor rows (N1 to N5 grouped, N8, N9, N10) and one Info row. F2 and N6 are closed.
