# Code Review: Concurrent Review, Stage C (#1097)

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main` (merge base `278bb7047db986bbb0a8652ca323656ce85f8a08`)
**Head Branch:** `feature/reduce-feature-cycle-time` @ `0a09dacd33e01be591869a949ff373b5f83fbb88`
**Review Type:** First review of PR C

---

## Executive Summary

The branch adds a review guard at merge for `review_mode: "concurrent"`, relaxes PR readiness under that key only, adds a `require_complete` rule in three validators, and documents the run sequence in the skill, rule, and agent copies.

The design is sound. The guard is one byte-identical file for both runtimes, it is inert without the key, and it fails closed on every process failure. Real-process runs confirmed the decisions the mocked tests assert. They also confirmed that real `git diff -z` output survives the bounded seam, and that the sequence the skill describes passes the validators.

One Blocker remains. The guard runs after the gate's scope filter and reads one selector, so a merge wrapped in `if`, `exec`, or `!`, or placed second in a chain, is never evaluated. Under the key this produced `allow` with a pending review. Five smaller items follow; none blocks.

**What changed well:**
The verdict check runs before any process starts, so a failed review costs no `gh` call. The `\A` and `\z` anchors match Python `fullmatch`, and the `-is [string]` test comes before `-ceq`, which avoids array filtering. The merge of `origin/main` left all 24 ledger blocks applicable.

**Top 3 risks:**
1. F1: the review control has a fail-open path that the spec does not disclose.
2. `spec.md` D10 is a closed list of limits. Owner condition 3 is written against that list, so an unlisted limit weakens the condition.
3. A `CI Required Gate` pass does not exercise F1: CI run 42351876419 at this head concluded `success` on all 23 jobs, and no test drives the shapes in F1.

**PR readiness recommendation:** **Not ready.** Resolve F1, then re-review.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-review.ps1` | Scope return at lines 356 and 157; guard header lines 8 and 9 | F1. Under `review_mode: "concurrent"`, a merge with a pending review receives `allow` for `if gh pr checks N; then gh pr merge N --merge; fi`, `exec gh pr merge N --merge`, and `! gh pr merge N --merge`, because the scope filter finds no structural match and the gate allows before the guard runs. In a chain only the first selector is read, so `gh pr merge 1101 --merge; gh pr merge --merge` and `gh pr merge 1101 --merge && gh pr merge 1100 --merge` are allowed on the epic-child path after the first number passes. | Add a key-gated check in both gates so a command that names `gh`, `pr`, and `merge` but has no structural match denies when the session checkpoint carries the key. Under the key, deny a command with more than one merge invocation. Add rows for both gates. Then correct the header claim and add any residual limit to D10, the rule, and the entry's `Current` block. | The guard is the only merge-time review control, and D10 does not list this limit. A gate-wide fix would add denials for sequential runs, which criterion [C] forbids, so the fix must stay under the key. The gap predates the branch, but the branch gives it a new role. | Real gate process in a scratch clone with a checkpoint that has the key and no `review_outcomes`: the three wrapper forms returned `allow`, while `git status && gh pr merge 1101 --merge` and `sh -c` returned `REVIEW_GATE_NOT_PASSED`. `enforce-epic-merge-gate-command.ps1` is byte-identical in both runtimes. No case-table row uses a wrapper or a chain. |
| Minor | `docs/engineering/process-reductions/0002-concurrent-review.md` | `## Summary` | F2. The reduction commit `ee44aaa86` and follow-up `759600565` carry `reduction: 0001`, while the entry is `0002`. A log search for `reduction: 0002` finds only the merge commit, and `reduction: 0001` will name two reductions on `main`. | Accept as disclosed; the entry already names the subject to search for. Ratify at owner level. | The standing rule expects the token in the reduction commit's subject. A forward fix is not possible without a forced push, which the repository denies. | `git log --grep='reduction: 000'` over the range and over `origin/main`. |
| Minor | `.claude/skills/orchestrate/SKILL.md` and `.agents/skills/orchestrate/SKILL.md` | Concurrent section, items 3 and 7 | F3. A ledger entry's `pending (PR #N)` number is known only after the pull request opens, and the file lies outside `feature-folder`. Item 3 starts the review as soon as the pull request opens, and item 7 says back-fills land before the review. A run that follows item 3 and then corrects the number gets `REVIEW_GATE_HEAD_STALE` and a second review. Entry `0002` itself says the number is replaced right after PR creation. | State in item 3 that the entry's PR number is committed after the pull request opens and before `head_sha` is read. Apply to all copies and update the entry's `Current` blocks. | The failure is closed, so the cost is one wasted review, not a skipped one. Stages D onward each carry an entry and meet this. | `spec.md` K8; item 7 of the section; entry `0002` `## Summary`. |
| Minor | `.claude/lib/orchestrator-state/OrchestratorState.psm1` | Readiness loop, line 324 | F4. `Get-OrchestratorStateField` matches names with case-insensitive `-contains`, so a `Review_Mode` key relaxes PowerShell readiness, while the guard and Python treat it as sequential. Readiness relaxes and no guard applies. | Read the key with an ordinal name check, or reuse the guard's predicate shape, and add a row. | The rule says the key is exact. A checkpoint with this key is unlikely, and it is a three-runtime parity gap. | Reviewer probe: with `Review_Mode`, only the `step8_status` error returned; with no key, both errors returned. `Test-EpicMergeGateReviewModeConcurrent` returned false. |
| Minor | `.agents/skills/orchestrator-state/SKILL.md` | Lines 81 to 83 | F5. This Codex-side copy describes the `review_outcomes` entry shape without `head_sha` and has no `review_mode` text. | Add the key and `head_sha` when the skills are next edited. | The orchestrate skill states the rule, so a Codex run is not left without it. The criterion on all mirrored copies is tagged [I]. | A search for `review_mode` in that file returned 0 lines. |
| Nit | `.claude/hooks/enforce-epic-merge-gate-review.ps1` | `.NOTES` | F6. The note lists two run-time dependencies, but the file also calls `ConvertFrom-DocsOnlyNameList`. | Name the third function when the header is next edited. | A reader checking load order relies on this list. | `Get-EpicMergeGateReviewHeadState`. |

No covered file reaches the 700-line advisory tier (largest 564), so no `Warning` row applies. No entry in `config/file-size-baseline.json` changed.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- A small pure module with one public function, called last in the `require_complete` block.
- The readiness exception compares all three conditions and leaves `blocked` and every other step unchanged.

#### Typing and API notes

- Full annotations. `cast` narrows parsed JSON without a suppression. Pyright exits 0.

#### Error handling and logging

- Errors are returned as strings by the validator contract. Nothing is caught.

### PowerShell implementation audit

#### What changed well

- The guard reuses the bounded seams, which never throw, and maps each failure to a named code.
- `Test-EpicMergeGateReviewFeatureFolder` rejects dot segments, backslashes, and trailing slashes before any path comparison.
- The prefix test carries the separator, so a sibling folder does not match.

#### Design notes

- The Codex gate now computes the PR number before reading the child checkpoint. This has no effect on an allow decision, because the selector function returns `$null` rather than throwing.
- Evaluation order is F1's root: the guard depends on the scope filter having matched.

### TypeScript implementation audit

#### What changed well

- `unknown` is narrowed through one helper, with no suppression. The regular expression has no `m` flag, so a trailing line feed is rejected, as in Python and PowerShell.
- The new file has its own `coverageThreshold` entry.

### C# implementation audit

N/A. No C# file is in the diff.

### Skills and documentation

- Item 10 of the skill section was checked against `enforce-checkpoint-monotonic.ps1` and `enforce-completion-consistency.ps1`: the monotonic hook needs only canonical order and steps S3 and S4, and the consistency hook reads `completed` in `step8_status`. The described sequence is accepted.
- `CI full run` exists as a job name in `.github/workflows/ci.yml`.
- A simulated checkpoint with the key, `step7_status: pending`, and `step8_status: in_progress` passed `--require-pr-creation-ready` in the Python CLI, both with no `remediation_loop` and with a loop holding only `review_outcomes`.

---

## Test Quality

- The shared case table drives the same rows through both gates, which makes the twin criterion a direct comparison.
- `-Times 0 -Exactly` assertions on the seams prove the no-key rows start no process.
- Mocks replace every process seam, and that is why the F1 shapes never appear: the rows assert decisions for commands the scanner already reads. Add wrapper and chain rows that run through the real scope filter.
- No temporary file, clock, or sleep appears in a new test.

---

## Validation Performed

Black, Ruff, Pyright, Prettier, ESLint, `tsc`, and PSScriptAnalyzer were run by the reviewer at this head; all were clean. The Codex generator `--check` exits 0, and all source and bundle pairs are byte-identical. Full test suites were not re-run, under the owner's rule of one parallel run per gate; the recorded totals match `artifacts/pester/pester-junit.xml` and the three coverage files. Reviewer probes are listed in Appendix B of `policy-audit.2026-11-07T07-47.md`.

---

**Review Completed By:** feature-review agent
