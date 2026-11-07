# Feature Audit: Light Remediation, Stage D (#1097)

**Audit Date:** 2026-11-07
**Feature Folder:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
**Base Branch:** `main`
**Head Branch:** `feature/reduce-feature-cycle-time`
**Work Mode:** `full-feature`
**Audit Type:** First review of PR D (stages A, B, and C merged; stage C as PR #1103)

---

## Scope and Baseline

- **Base branch:** `main` (commit `72e57cc7dfd4ba78579a2c86887aa0c77d5d9cef`, equal to `origin/main` after a fetch; the merge commit of PR #1103)
- **Head branch/commit:** `feature/reduce-feature-cycle-time` (commit `d42515cf7ecf53842908d88bf1c9adf6e0b5c440`)
- **Merge base:** `72e57cc7dfd4ba78579a2c86887aa0c77d5d9cef`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`, generated 2026-11-07 10:30:22 UTC for this head
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/evidence/` (stage D files)
  - Additional evidence: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml`, `artifacts/python/lcov.info`, `extensions/drm-copilot/coverage/lcov.info`, the reviewer's gate runs at this head, the reviewer's three-runtime probe set, and the reviewer's replay of entry `0003`
- **Feature folder used:** `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` states `- Work Mode: full-feature`.
- **Scope note:** the audit covers the full branch diff, 105 files over 14 commits. Under `spec.md` `## Delivery Stages`, a PR owes the criteria tagged with its stage and all earlier ones. This PR therefore owes the six `[A]`, two `[B]`, seven `[C]`, and four `[D]` criteria, 19 in all. Criteria tagged `[E]` to `[I]` belong to later stages and are listed as not owed.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` — primary
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md` — secondary; its 40 criteria are identical to `spec.md`, including checkbox state

### Acceptance criteria

1. [A] `docs/engineering/process-reductions/` exists with a `README.md` index, and a test fails when the index and the entries disagree.
2. [A] A test fails if a ledger entry lacks a required section, covering a complete entry, a missing section, an empty section, and missing prior text, and it also iterates the real entries read-only.
3. [A] The structure test accepts a pending merge commit only in the exact form `Merge commit: pending (PR #N)`.
4. [A] `Invoke-ProcessReductionRevert` restores `Prior` text in memory, normalizes line endings before comparing, and throws when `Current` is absent.
5. [A] The review skill and all its mirrored copies state the standing rule, conditional on the ledger folder existing, and state that one-off waivers are not entries.
6. [A] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures, under the Testing Rule, at each stage.
7. [B] Stage timing is recorded in the checkpoint and in committed evidence, and is reported per stage by `Get-StageTimingReport.ps1`.
8. [B] A test proves that `stage_timing` passes each validator and survives portable handoff.
9. [C] The merge guard commit precedes the readiness relaxation commit on the branch.
10. [C] Under `review_mode: "concurrent"`, merge is denied with review passed and CI pending, and with CI green and review pending, on each guarded path.
11. [C] The guard denies a stale head, a git failure, an unresolved head, and a bare command under the key, and allows a feature-folder-only predecessor.
12. [C] The Claude guard and its Codex twin behave the same on these cases.
13. [C] A checkpoint without the key makes no `gh` call, receives no new denial, and receives no readiness relaxation.
14. [C] `step7_status: pending` stops blocking PR readiness only under the key, and `require_complete` under the key requires the same `PASS` record in three validators.
15. [C] The orchestrate skill defaults new runs to concurrent and requires a `CI full run` at the join; the parallel step does not record `ci_green` while the review is unresolved; the concurrent reduction is its own commit with its entry.
16. [D] A light remediation cycle validates truthfully in the Python, TypeScript, and PowerShell validators with byte-identical strings, and all three land in one commit.
17. [D] A cycle with a design-level finding or no `scope` fails on the light path and still requires the full chain, and a full-path cycle with no preflight fails invariant 2.
18. [D] Invariant 8 also rejects a light cycle with findings above the threshold, a consecutive light cycle, and a light cycle carrying a `preflight` object.
19. [D] The reviewer's `Remediation-Path` choice can be moved only heavier, the skills state the threshold and the Python CLI route of D9, and the light reduction lands as its own commit with its entry.
20. to 40. The six `[E]`, three `[F]`, three `[G]`, two `[H]`, and seven `[I]` criteria, as written in `spec.md` `## Acceptance Criteria`.

---

## Acceptance Criteria Evaluation

| # | Criterion (short) | Status | Evidence |
|---|---|---|---|
| 1 | Ledger index and index test | PASS | Delivered in stage A. At this head, run by the reviewer: `Test-ProcessReductionLedger` returns `IsValid` true, 0 errors, 3 rows. |
| 2 | Entry structure test | PASS | Delivered in stage A. The three real entries are valid. |
| 3 | Pending merge commit form | PASS | Delivered in stage A. Entry `0003` uses the exact form `Merge commit: pending (PR #1097)`, and entry `0002` now carries the 40-character merge commit `72e57cc7d...` of PR #1103. |
| 4 | Revert in memory | PASS | Delivered in stage A. The reviewer applied the 37 blocks of entry `0003` at this head with `Invoke-ProcessReductionRevert`. All 17 paths equal their text at `86639cc5e`, the parent of the reduction commit, with 0 differing. Every `Current` fence of entries `0001` (4) and `0002` (25) occurs exactly once in its working file. |
| 5 | Review skill standing rule | PASS | Delivered in stage A. The text is present in all review-workflow copies at head. |
| 6 | Gates pass at each stage | PASS | Reviewer runs at this head, one of each. `Invoke-PoshQCParallelTest` returned `ExitCode` 0 with 8 workers in 293.04 s; `artifacts/pester/pester-junit.xml` reports 15553 tests, 0 failures, 0 errors, and 10 disabled. `pytest -n auto` reported 16179 passed, 6 skipped, and 0 failed. Jest reported 330 suites and 5339 tests passed. These equal the executor's recorded stage D gates. |
| 7 | Stage timing report | PASS | Delivered in stage B; not changed in this diff. |
| 8 | `stage_timing` tolerated | PASS | Delivered in stage B; not changed in this diff. |
| 9 | Guard precedes relaxation | PASS | Delivered in stage C; history unchanged. |
| 10 | Merge denied on each guarded path | PASS | Delivered in stage C. Stage D changes only the candidate read of the shape rule. The shared `RG-` and `RGC-` rows (216 each) and the `RGP-` path rows pass in the reviewer's Pester run at this head. |
| 11 | Stale, failure, bare, predecessor | PASS | Delivered in stage C. The rows pass at this head. `RG-DIRECT-CALL-NO-NUMBER-DENIES` and `RGC-DIRECT-CALL-NO-NUMBER-DENIES` are added for the direct-call path that stage C's R3 noted. |
| 12 | Claude and Codex behave the same | PASS | The four guard copies are byte-identical (`cmp`). The same rows run through both gates, and `RGC-SHAPE-CANDIDATE-CAP-BOUNDS-READS` covers the cap on Codex. |
| 13 | No key: no `gh`, no denial, no relaxation | PASS | `RG-SHAPE-CANDIDATE-CAP-NOKEY-KEEPS-DECISION` shows that the capped read leaves the decision without the key unchanged. The cap only removes reads. |
| 14 | Readiness and `require_complete` | PASS | Delivered in stage C. The readiness and completion modules are not in this diff. |
| 15 | Skill default, join, parallel step, own commit | PASS | Delivered in stage C. The R2 and R3 follow-ups landed in two `reduction: 0002` commits (`3fc7418f8`, `86639cc5e`), each updating entry `0002` (K3). |
| 16 | Light cycle valid in three validators, one commit | PASS | Corpus rows `light_valid_accepted` and `light_three_findings_accepted` give no remediation error in all three parity suites. `test_light_messages_equal_the_spec_strings` and the rule text pin the seven strings. Reviewer probes: 15 of 18 probes gave identical lists in the three runtimes, and the 3 that differ are N1 and N2, both outside the criterion (see note). `git show --name-only 33b80bd19` lists the Python module, the TypeScript module, and both PowerShell modules, with entry `0003` and its index row. |
| 17 | Design or absent scope fails; full without preflight fails invariant 2 | PASS | Rows `light_design_scope`, `light_absent_scope`, and `full_no_preflight_fails_invariant_2` in the three runtimes. The full chain is required: the orchestrate skill falls back to `remediation_path: "full"` and R1 on any invariant 8 error or an executor stop, pinned by `LRS-ORCHESTRATE-STATES-FALLBACK-AND-REUSE` and `VEL-LIGHT-STOP-BEFORE-FIRST-TASK-ALLOWED`. |
| 18 | Above threshold, consecutive, preflight present | PASS | Rows `light_four_findings`, `light_consecutive_light`, and `light_preflight_present`. Through the repository Python CLI the reviewer saw exit 1 with the rule 2 and rule 7 messages, and exit 0 for `light_valid_accepted`. |
| 19 | Heavier only; threshold and D9 route stated; own commit with entry | PASS | The Claude, Codex, and Copilot review copies and the Claude and Codex orchestrate copies state the five threshold conditions and the heavier-only rule. The Claude orchestrate skill and the rule name the Python CLI route. The Codex copies state that the path is unavailable until a release. All are pinned by the 74 `LRS-` cases. Reduction `0003` is `33b80bd19`, with two later `reduction: 0003` fixes that update the entry in the same commit (K3). The orchestrator moves a cycle heavier only by rewriting the mode line. No validator reads the reviewer's line, so this part is a skill-level control, as the criterion states it. |
| 20-40 | `[E]` to `[I]` criteria | UNVERIFIED | Not owed by PR D under `## Delivery Stages`; later stages deliver them. |

**Note on item 16.** The criterion asks for truthful validation with byte-identical strings, and that holds for every checkpoint the orchestrator writes. The reviewer's probes found two places where the runtimes disagree. Neither was introduced by this branch:

- **N1.** The PowerShell helper `Get-CheckpointObjectMember`, which this branch does not change, reads keys without regard to case. A mis-cased `Remediation_Path` or `Scope` key is therefore honored by PowerShell and ignored by Python and TypeScript.
- **N2.** The R11 predicate accepts `0.0` on TypeScript and PowerShell, because the parsed JSON cannot tell it from `0`.

Both are recorded as Minor in `code-review.2026-11-07T10-50.md`.

---

## Summary

- **Owed criteria:** 19
- **PASS:** 19
- **PARTIAL:** 0
- **FAIL:** 0
- **UNVERIFIED:** 0 of the owed criteria; the 21 `[E]` to `[I]` criteria are not owed by this PR
- **CI note:** CI run 42364201139, dispatched on head `d42515cf7`, was `in_progress` when this audit was written. S9 owns `ci_gate.conclusion` at the final head. No criterion owed by this PR depends on CI alone.

Owner condition check:

1. Revertibility: met. Entry `0003` replays to the reduction commit's parent with 0 differing paths. Its revert steps name the generator `--check`, which exits 0 at this head, and the three corpus floors.
2. Baselines: met. No removed line outside the feature folder and the ledger mentions a baseline, coverage, or `no pre-change run`.
3. Merge control: met within the limit stated in D10. Stage D adds the 4-number cap, and D10 discloses it.
4. Older checkpoints: met. A cycle without `remediation_path` reaches no new rule. No existing fixture changed (`--diff-filter=M` over `tests/fixtures` lists nothing), and no Epic #1019 folder is in the diff.

---

## Acceptance Criteria Check-off

No criterion was newly checked by this review. The four `[D]` criteria were checked by the executor in `9051025ba`, in both `spec.md` and `user-story.md`. This review evaluated each of them PASS, so the check-offs stand. The `[A]`, `[B]`, and `[C]` items were already checked and were evaluated PASS. No criterion text changed.

### AC Status Summary

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md`, `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 40 in each file
- Checked off (delivered): 19
- Remaining (unchecked): 21
- Items remaining: the 21 items tagged `[E]` to `[I]`, which later stages owe.

---

**Audit Completed By:** feature-review agent
