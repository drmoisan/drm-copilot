# Code Review: Concurrent Review, Stage C Re-review (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `278bb7047db986bbb0a8652ca323656ce85f8a08`)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `197f3122a3352aa4ee57832f3f39f5746698d334`
**Review Type:** Re-review of PR C after the remediation of F1 (prior head `0a09dacd3`)

---

## Executive Summary

The branch adds a review guard at merge for `review_mode: "concurrent"`, relaxes PR readiness under that key only, adds a `require_complete` rule in three validators, and documents the run sequence in the skill, rule, and agent copies. This cycle adds a shape rule to the guard, which closes the prior Blocker.

The shape rule changes the guard from reading the commands the gate already matched to rejecting anything it cannot bind. Under the key, text that could be a merge must be one plain `gh pr merge` of one number. Anything else is denied before any process starts, and before the out-of-scope allow of both gates. The bound form is an allowlist, so an unknown flag, a redirection, and a second selector fail by absence.

The prior review's five commands now deny on both gates in a real process. Without the key, 56 command forms gave the same decision at this head and at the merge base.

No Blocker remains. Four items follow, and none blocks: two Minor, one Nit group, and one carried Minor.

**What changed well:**
The allowlist inverts the failure direction, so a scanner blind spot now costs a denial rather than an allow. The rule keeps the no-key path unchanged, which was the hard constraint of the fix. The best-effort read keeps a key it has already read: a failed item read still denies on a session key. The disclosure in the rule and D10 is specific enough to test against.

**Top 3 risks:**
1. R1: brace-expansion and interpreter argv forms still reach `allow` under the key. They are graded as inside the D10 limit, and that grading is a judgment the owner can overturn.
2. The guard is at 696 logical lines, 4 below the advisory tier, and stage D onward may add to the same area.
3. Under the key, fail-closed denial applies to every Bash command of the run, including executor commits. The trade is disclosed and recoverable, but its real cost is unmeasured until a concurrent run happens.

**PR readiness recommendation:** **Ready.** No code change is required before the pull request. CI run 42356449380 at this head concluded `success` on all 23 jobs.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/enforce-epic-merge-gate-review.ps1` and its three copies | `$script:EpicMergeGateReviewMergePattern`, `$script:EpicMergeGateReviewDynamicPattern` | R1. The trigger needs `pr`, then whitespace, then `merge`, `$`, a backtick, or `(`. It misses brace expansion (`gh {pr,merge} N --merge`, `gh pr {merge,} N --merge`, `gh {pr,} merge N --merge`, `{gh,pr,merge} N --merge`) and an argv list in an inline interpreter (`python -c` with `subprocess.run` over the separate words; `node -e` with `execFileSync`). All return `allow` from Claude and no decision from Codex, with the key and no review. | Under the key only, add `{` to the dynamic trigger and accept a comma with optional spaces between `pr` and `merge`. Add rows. Name the remaining forms in D10, the rule, and the entry's `Current` block. | D10 names "encoded or run-time composed text". In these forms the phrase is not in the text, because the shell or interpreter assembles it, so they are graded as inside that limit. Each must be written deliberately, unlike the F1 shapes. Because the change is under the key, it cannot affect criterion [C] on no new denial. Remediability class if the owner reads D10 more strictly: `autonomous`. | Real gate process, both runtimes, key with no review. Real bash with a stand-in `gh` showed the four brace forms reaching `gh` as `pr merge N --merge`. The argv forms ran through the gate only. |
| Minor | `.claude/hooks/enforce-epic-merge-gate-review.ps1` | `Get-EpicMergeGateReviewShapeDecision`, `Read-EpicMergeGateReviewItemCheckpoint`; header lines 13 to 15 | R2. Without the key, an unbound command that names the phrase pays one `Resolve-EpicMergeGateItemTarget` per digit run in its text, with no cap. The resolver enumerates worktrees for each call. Header lines 13 to 15 state that without the key the guard "starts no process", which holds on Codex but not for this Claude read. | Enumerate the worktrees once per decision or cap the candidate count, and correct the header sentence for Claude. | The decision is unchanged and no `gh` call starts, so criterion [C] holds. The cost lands on runs without the key, which the design otherwise leaves untouched. Remediability class: `autonomous`. | From the main checkout with 100 worktrees: 0.6 s with no number, 1.5 s with 1, 7.4 s with 10, and 37.3 s with 60. A command without the phrase took 0.6 s. `.claude/settings.json` sets no timeout on this hook. |
| Minor | `docs/engineering/process-reductions/0002-concurrent-review.md` | `## Summary` | F2, carried. `ee44aaa86` and `759600565` carry `reduction: 0001`, while the entry is `0002`. | Accept as disclosed. Ratify at owner level. | A forward fix is not possible without a forced push, which the repository denies. Remediability class: `human_decision_required`, for ratification only; it does not block. | `git log` over the range. |
| Nit | `.claude/hooks/enforce-epic-merge-gate-review.ps1` | Bound check; `Get-EpicMergeGateReviewDecision` line 346; header step 2 | R3. (a) A plain merge with a trailing line feed or `;` is denied, and the message tells the caller to issue the command as its own call, which it already is. (b) The dynamic trigger also denies prose such as `pr (#12)` and `pr $HOME`, while D10 names only `pr merge`, and the message says to remove "the phrase". (c) Under the gates the shape rule reaches a bare command first, so line 346 and step 2 of the header run only through a direct call. | Trim the text before the bound check, name the wider trigger in D10 or the deny message, and note in the header that step 2 is reached only directly. | All three fail closed and are recoverable. Remediability class: `autonomous`. | Real gate process, both runtimes; coverage file reports line 346 not run, and the self-review states why it stays. |

No covered file reaches the 700-line advisory tier (largest 696), so no `Warning` row applies. No entry in `config/file-size-baseline.json` changed.

### Prior findings

| Finding | Status | Evidence |
|---|---|---|
| F1 Merge commands the gate does not read | Closed | All five commands deny on both gates in a real process; see Test Quality. |
| F3 Entry number before the head read | Closed | Item 3 of the concurrent section, in all four copies; `CRS-SKILL-COMMITS-ENTRY-NUMBER-BEFORE-HEAD-READ`. |
| F4 Ordinal key name | Closed | Reviewer probe: with `Review_Mode`, both step errors return; with `review_mode` and `step8_status: in_progress`, none does. |
| F5 Key in the orchestrator-state skill | Closed | New section in `.agents/skills/orchestrator-state/SKILL.md` and its bundled copy. |
| F6 `.NOTES` names its run-time calls | Closed | `ConvertFrom-DocsOnlyNameList` and the scanner functions are listed. |

### Candidates tested and closed

These looked like gaps and were shown not to be merges. They are recorded so a later reviewer need not repeat them.

| Form | Result |
|---|---|
| `pulls/N//merge`, `pulls/N/./merge` | Not read by the REST pattern. The equivalent read-only route (`pulls/1101//commits`, `pulls/1101/./commits`) returned 404, so GitHub does not normalize these paths. |
| `gh pr mer?e N`, `gh pr m[e]rge N` | Reached `gh` unchanged under the stand-in, so they fail unless a file of that name exists in the working directory. |
| `gh api ... pulls/N/{merge,}` | Expands to two endpoint arguments, which `gh api` does not accept. |
| A literal `query` field with an attached `-Fquery=@file` | The read-only proof does not read the attached flag, but `gh` itself rejected the command: "unexpected override existing field". |
| A selector that the gate and the bound check read differently | Both use the same value flags, and all bound value flags are in the gate's list. |
| A locked checkpoint | The plain form still denies. A wrapped form returns `allow`, which is the best-effort read that D10 states. |
| A 100019-character command against the option-gap pattern | 3.7 s with no key, so no pathological backtracking was seen. |

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed in this cycle. The prior assessment stands: a small pure module with one public function, called last in the `require_complete` block.

#### Typing and API notes

- Full annotations. `cast` narrows parsed JSON without a suppression.

#### Error handling and logging

- Errors are returned as strings by the validator contract. Nothing is caught.

### PowerShell implementation audit

#### What changed well

- `Get-EpicMergeGateReviewBoundTokenNumber` requires the first three tokens to equal `gh`, `pr`, and `merge`, so an environment prefix, a path to `gh`, and a case variant all fail to bind and deny.
- `Get-EpicMergeGateReviewBoundPrNumber` requires one top-level record that spans the whole text and one occurrence in both scan forms, so a comment or heredoc cannot hide a second command behind a bound one. Probes with comment quotes, a comment line continuation, and a CRLF chain all denied.
- `Test-EpicMergeGateReviewGraphqlReadOnly` keeps a read-only poll loop allowed, and every occurrence must be proven.
- `$stateNames -ccontains 'review_mode'` closes F4 with the smallest change, in both modules.

#### Design notes

- Codex passes no reader, so its unbound decision sees only the root checkpoint. The header and D10 state this.
- `Get-EpicMergeGateReviewDecision` and every scanner file are unchanged, which kept the stage C head-state evidence valid. The reviewer re-ran the head-state cases with real `git` at this head and got the same results.

#### API and safety notes

- The command text is never executed by the hook.
- The Claude gate is at 497 logical lines, so future logic belongs in the sibling, which itself is near the advisory tier.

### TypeScript implementation audit

#### What changed well

- No TypeScript file changed in this cycle. The prior assessment stands: `unknown` is narrowed through one helper, with no suppression, and the new file has its own `coverageThreshold` entry.

### C# implementation audit

N/A. No C# file is in the diff.

### Skills and documentation

- Item 3 and item 9 of the concurrent section state the entry number and the own-call merge, in all four copies.
- The skills issue `gh pr merge --merge <PR>` and `gh pr merge <PR> --merge`, and both forms bind. Under the key a bare `gh pr merge --merge` is denied, and the orchestrate step that runs under the key names the number.
- D10 in `spec.md`, the rule, and the guard header agree on the listed limits, including the three tools the gates do not cover. The Codex statement matches `Invoke-CodexEpicMergeDecision`, which returns for any tool name other than `Bash`.

---

## Test Quality

- The shared table drives 204 rows through both gates, each with `pending-` and `nokey-` forms, so the twin criterion remains a direct comparison. The JUnit file reports 201 `wrapper-`, 64 `chain-`, 24 `split-`, 80 `api-`, and 42 `flag-` cases, 0 failing.
- The prior gap is closed. Those rows run through the real scope filter, and `evidence/regression-testing/real-process-merge-gate.2026-11-07T08-28.md` records 218 rows with no mocked seam.
- The reviewer repeated the core forms in an independent harness. Results agreed: the if, exec, and bang forms and both chains deny, and the legitimate forms stay allowed.
- Gap: no row covers R1. Add brace and argv rows with the trigger change.
- No temporary file, clock, or sleep appears in a test file of this branch. No test suite was run by the reviewer.

---

## Validation Performed

Black, Ruff, Pyright, Prettier, ESLint, `tsc`, PSScriptAnalyzer, and `Invoke-Formatter` were run by the reviewer at this head; all were clean for the changed files. ESLint also reports one `no-require-imports` error on `jest.config.cjs` line 5, which is identical at the merge base and is not a branch finding. The Codex generator `--check` exits 0, and all source and bundle pairs are byte-identical. Full test suites were not re-run, under the owner's rule of one parallel run per gate; the recorded totals match `artifacts/pester/pester-junit.xml` and the three coverage files. Reviewer probes are listed in Appendix B of `policy-audit.2026-11-07T08-55.md`.

---

**Review Completed By:** feature-review agent
