# Feature Audit: F7 Parallel Enforcement Hooks (Issue #440)

**Audit Date:** 2026-08-08
**Auditor:** feature-review agent
**Feature folder:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440`
**Issue:** #440 — https://github.com/drmoisan/drm-copilot/issues/440
**Epic:** `parallel-orchestration`, child F7, wave 4

## Scope and Baseline

**Resolved base branch:** `epic/parallel-orchestration-integration`
**Merge base SHA:** `c939b5b80c8c297db49febaebdd35dda2c869a3f`
**Feature branch HEAD:** `c939b5b80c8c297db49febaebdd35dda2c869a3f`

The base branch was supplied explicitly by the caller directive and was used as given, per step 1 of `feature-review-workflow`. No candidate resolution was necessary. The epic branch is one commit ahead of the merge base (`5fd90827 docs(epic): record wave 3 complete and wave 4 concurrent launch`), which does not affect this feature's diff.

**Baseline anomaly.** The feature branch HEAD is identical to the merge base: the branch carries **zero commits**, and all 26 changed paths exist only as uncommitted working-tree state. The authoritative diff for this audit is therefore `git diff HEAD` plus `git ls-files --others --exclude-standard`, which is a strict superset of what a commit-range diff would show. This does not narrow scope, but it does mean no pull request can be opened until the work is committed. Recorded as Required Action R-1 in the policy audit.

**PR context artifacts.** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were absent. They were **not** regenerated, because the repository collector diffs `merge_base..head_sha` and those are the same commit, so regeneration would have produced an empty artifact and actively misleading evidence. The working-tree diff was substituted as the primary evidence source. This deviation from the `pr-context-artifacts` refresh rule is recorded explicitly here and in the policy audit.

**Work mode:** `full-feature`, read from the persisted marker `- Work Mode: full-feature` at `issue.md` line 12. Per `acceptance-criteria-tracking`, the authoritative AC sources are therefore **both** `spec.md` and `user-story.md`.

**Changed-file inventory by language:** PowerShell 5 production + 3 test; Python 2 production + 4 test; JSON 3; PSD1 2; Markdown 2 + feature docs; 50 evidence artifacts. Zero TypeScript files and zero C# files changed — the zero TypeScript count is itself the subject of Blocking finding B-1 in the policy audit.

**Reviewer-executed verification:** `black --check` (clean, 376 files), `ruff check` (clean), `pyright` (0 errors), targeted `pytest` over 6 files (202 passed), `validate_evidence_locations.py --root .` (exit 0), independent lcov and JaCoCo coverage parsing, and sha256 comparison of the epic deny-reason line and all six repo/bundle mirror pairs.

## Acceptance Criteria Inventory

Both AC source files carry an identical 16-item `## Acceptance Criteria` section. Reviewer verified identity by diffing the extracted sections: the only difference is the heading that follows the section (`## Definition of Done` in `spec.md`, `## Non-Goals` in `user-story.md`). Both files show 16 of 16 items already checked `[x]`.

| # | Criterion (abbreviated) | Source |
|---|---|---|
| AC1 | Layer 1 denies conflicting strictly-prior-cohort item with non-terminal `merge_status`, exact literal `PARALLEL_COHORT_BARRIER_BLOCKED` | spec.md + user-story.md |
| AC2 | Layer 1 allows when every conflicting prior-cohort item is `merged`/`worktree_removed`, and allows an item with no conflicting prior-cohort neighbors | both |
| AC3 | Layer 1 allows a prompt lacking the literal marker `Parallel mode: true` | both |
| AC4 | Layer 1 allows a `subagent_type` that is not `orchestrator` | both |
| AC5 | Layer 1 fails closed on missing or malformed checkpoint JSON | both |
| AC6 | Layer 1 fails closed on unresolvable target (no folder token, no `items[]` record, no current-generation cohort assignment) | both |
| AC7 | A `ci_green` prior-cohort item does not satisfy the barrier; only `merged` and `worktree_removed` do | both |
| AC8 | Layer 2, through `validate_parallel_orchestrator_state_text`, appends exactly one exact-form message per violated edge, covering structural and temporal readings | both |
| AC9 | Layer 2 is key-gated: checkpoint lacking `conflict_edges`/`cohorts` validates with zero new errors; clean multi-cohort checkpoint yields zero barrier errors | both |
| AC10 | Worktree removal gate denies non-terminal `merge_status`, fails closed on unreadable checkpoint or unmatched path, prefix `PARALLEL_WORKTREE_REMOVAL_BLOCKED` | both |
| AC11 | Worktree removal gate allows `merged`/`worktree_removed`, and allows non-`git worktree remove` commands unconditionally | both |
| AC12 | Extended invocation-origin hook denies both parallel personas from caller `agent_type` `orchestrator`; allows from main thread and non-orchestrator agents | both |
| AC13 | Epic invocation-origin behavior preserved: `EPIC_INVOCATION_ORIGIN_BLOCKED` byte-identical (exact-string assertion) and all pre-existing tests pass unmodified | both |
| AC14 | `.claude/settings.json` registers both new hooks and (unless F5 already did) a `SubagentStop` matcher `parallel-orchestrator` | both |
| AC15 | Line coverage >= 85% and branch coverage >= 75% for all new and changed code, no regression on changed lines | both |
| AC16 | All test files mirrored under `tests/`, use mocked read seams instead of temp files, and are deterministic | both |

## Acceptance Criteria Evaluation

| # | Verdict | Evidence (reviewer-verified) |
|---|---|---|
| AC1 | **PASS** | `enforce-parallel-cohort-barrier.Tests.ps1` `Context` at line 129 contains seven deny cases: `pr_open` (130), `ci_green` (143), `not_started` (156), `blocked_drift` (169), absent `merge_status` key (182), absent `items[]` record (195), and edge-endpoint-`a` orientation (207). Production deny reason at hook line 482 carries the exact literal prefix. |
| AC2 | **PASS** | `Context` at line 53: allows for `merged` (54) and `worktree_removed` (66); allows a cohort-0 target whose only conflicting neighbor sits in a later cohort (78); allows a target with no conflict edges at all (90); allows a non-terminal same-cohort neighbor as out of Layer 1 scope (102). |
| AC3 | **PASS** | `It 'allows an orchestrator delegation whose prompt lacks the Parallel mode: true marker'` (line 36), plus empty-prompt case (42). Production gate at hook line 458 uses `-notlike "*$script:ParallelModeMarker*"`. |
| AC4 | **PASS** | `It 'allows a non-orchestrator subagent delegation'` (line 30). Production gate at hook line 453. Additionally proven by the `-Times 0 -Exactly` seam assertion at line 310, which shows no checkpoint read occurs. |
| AC5 | **PASS** | `It 'denies when the parallel checkpoint file is absent'` (223) and `'...content is malformed JSON'` (231). Production converts an unparseable checkpoint to `$null` at hook lines 470-474, and a null checkpoint denies via `Test-ParallelCohortBarrierClear`. |
| AC6 | **PASS** | Four cases in the `Context` at line 222: no feature-folder token (239), no matching `items[]` record (246), no current-generation cohort assignment (258), target record without `issue_num` (270). |
| AC7 | **PASS** | `It 'denies when the conflicting prior-cohort neighbor has merge_status ci_green'` (143), reinforced by the seam-binding pair at 284/297 where a byte-identical payload flips allow→deny purely on `merged` vs `ci_green`. Production reads `MERGED_MERGE_STATUSES` via `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')`; `ci_green` is absent from that set by construction. |
| AC8 | **PASS** | The test file imports **only** `validate_parallel_orchestrator_state_text` (line 28); reviewer grep for the helper name returned zero matches, so the invariant is genuinely exercised through the public entry point. Structural reading: `test_same_cohort_conflicting_pair_reports_one_structural_violation` (214). Temporal readings: `test_cross_cohort_start_before_terminal_merge_reports_a_violation` (228), `test_merge_confirmed_after_later_start_reports_a_temporal_violation` (285). Exact form: `test_violation_message_matches_the_exact_literal_form` (220). One-per-edge: `test_multiple_violated_edges_each_report_exactly_one_message` (336). Endpoint ordering: `test_earlier_cohort_endpoint_is_named_first` (356). |
| AC9 | **PASS** | `test_checkpoint_without_a_gating_key_emits_no_violation` (199, parametrized over both keys) and `test_clean_multi_cohort_checkpoint_yields_no_barrier_errors` (190). Production key gate at helper lines 348-349 returns `[]` when either gating key is absent, so a pre-existing checkpoint validates byte-identically. |
| AC10 | **PASS** | `Context 'deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status'` (85) and `Context 'deny fail-closed on an unusable checkpoint or an unmatched path'` (157). Production deny reason at gate line 227 carries the exact prefix. |
| AC11 | **PASS** | `Context 'allow when the matched item merge_status is terminal'` (56) and `Context 'commands outside scope are allowed unconditionally'` (24), the latter reinforced by the `-Times 0 -Exactly` seam assertion at line 217. |
| AC12 | **PASS** | Appended `Context` at `enforce-epic-invocation-origin.Tests.ps1` covering both personas denied from an `orchestrator` caller, both allowed from the main thread (absent `agent_type`), both allowed when `agent_type` is blank, and both allowed from a non-orchestrator agent — plus a payload-`tool_input`-fallback deny case and a test asserting the epic prefix is **not** used for a parallel target. |
| AC13 | **PASS** | **Independently verified, not accepted on report.** Reviewer-computed sha256 of the epic reason line is `851971c5a1dc830f2cb861a7947e143bf0b4b3e7304ed77df4add4e3db7054c6` in **both** `git show HEAD:` and the working-tree file. `git diff --numstat` on the test file is `154  0` — 154 insertions, **zero deletions** — in a single hunk `@@ -105,4 +105,158 @@`, growing the file 108→262 lines, so every pre-existing test is untouched. Two appended tests assert the full epic literal with exact `Should -Be`. |
| AC14 | **PASS** | Reviewer-read diff of `.claude/settings.json`: `enforce-parallel-worktree-removal-gate.ps1` appended to `PreToolUse`/`Bash`; `enforce-parallel-cohort-barrier.ps1` appended to `PreToolUse`/`Agent`; new `SubagentStop` matcher `parallel-orchestrator` invoking `validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state`. `git show HEAD:` confirms no such `SubagentStop` matcher pre-existed, so P4-T3's *add* branch was correctly taken rather than its authorized skip branch. No existing entry modified or reordered. JSON parseability confirmed by P4-T5 evidence. |
| AC15 | **PASS** | Reviewer-derived from raw artifacts. Python: repo-wide line **91.88%** (12541/13649), branch **83.96%** (4245/5056); new helper line **99.07%**, branch **98.21%**; modified validator line **97.62%**, branch **94.12%**. PowerShell per-file: cohort-barrier **95.98%** instruction / 96.38% line; worktree-gate **90.79%** / 91.80%; invocation-origin **89.86%** / 91.67%. All above the 85% line and 75% branch thresholds. No regression: Python line +0.06 pp and branch +0.16 pp versus baseline; the validator's statement count rose 82→84 with missed count unchanged at 2, so both added statements are covered. **PowerShell branch coverage is not emitted by the toolchain** — reviewer enumerated the JaCoCo `counter` element types and found exactly `INSTRUCTION`, `LINE`, `METHOD`, `CLASS`, confirming this is a genuine tool capability limit and that the explicit absence note is a factual record, not a placeholder. |
| AC16 | **PASS** | Locations mirror source: `.claude/hooks/X.ps1` → `tests/scripts/claude-hooks/X.Tests.ps1`; `scripts/dev_tools/X.py` → `tests/scripts/dev_tools/test_X.py`. No colocation in any production tree. Mocked seams: 21 mocks of `Get-ParallelCohortBarrierCheckpointContent`, 20 of `Get-ParallelWorktreeRemovalGateCheckpointContent`. **Zero temp files** — reviewer grep for `tmp_path`, `tempfile`, `TestDrive`, `NamedTemporary`, `mkdtemp`, `New-TemporaryFile` across all new and modified test files returned no matches. Deterministic: no clock, RNG, sleep, retry, or network dependency; all input is inline literal JSON. |

**Result: 16 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED.**

## Findings Outside the Acceptance Criteria

The AC set is fully satisfied, but the audit identified one Blocking issue that no criterion covers.

**B-1 (Blocking) — the TypeScript F7 parity seam was left empty.** `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` lines 307-314 still contain the empty, comment-delimited seam that F3 constructed specifically for this feature. The Layer 2 invariant therefore exists only in the Python validator, while `orchestration-artifacts.ts:263` dispatches `artifact_type: "parallel-orchestrator-state"` to the TypeScript core. An operator validating through the MCP tool receives a clean result on a checkpoint the `SubagentStop` hook would reject, and no test detects the divergence.

Neither `spec.md` nor `plan.2026-08-07T11-10.md` contains the string "TypeScript" or "parity" anywhere, and the spec's Non-Goals do not exclude it, so this is a scope-completeness gap against the standing rule `.claude/rules/parallel-orchestration.md` — which states enforcement is "Python validator logic, plus the TypeScript parity port, plus this prose file" — and against F3's recorded expectation, rather than a failure to deliver a stated requirement. That is why the AC table remains 16/16 PASS while the overall recommendation is CHANGES REQUESTED. Full rationale and resolution options are in `policy-audit.2026-08-08T23-10.md` section 3, finding B-1, and in `code-review.2026-08-08T23-10.md`.

Seven advisory findings are recorded in the code review; none affects correctness or any acceptance criterion.

## Adjudication Positions

| Directive point | Position |
|---|---|
| 1. Epic-hook behavioral preservation | **VERIFIED CLEAN**, independently. Reason sha256 identical; test diff 154/0 appended; main-thread, blank-`agent_type`, and non-orchestrator-caller allow paths unmodified and positioned before the new branch; non-gated targets still not parsed. |
| 2. P2-T1 "exactly two changes" vs four prose comment updates | **WITHIN SPIRIT — not a Blocking deviation.** The stale comments had become factually false once the parallel members joined the gated list; `self-explanatory-code-commenting.md` mandates comment accuracy, which is higher-precedence than a task-level edit-count constraint. All of P2-T1's operative behavioral guarantees are verified intact. The `$script:ParallelSubagentTypes` constant is recorded as the selector mechanism of change (2), not a third change. |
| 3. Absorption A (F3-owned fixture) | **CONCUR with the adjudication.** No assertion weakened, deleted, or loosened; no skip/xfail; invariant-15 tests pass (9/9 in a targeted run); invariants 13 and 14 satisfied by the amended fixture (indices 0 and 1 unique in generation 0, each item in exactly one current-generation cohort, `current_cohort` 0 <= max index 1); F7's helper structural reading at line 306 is unnarrowed. |
| 4. Absorption B (five bundle mirrors) | **VERIFIED.** All five pairs byte-identical by sha256, plus the PSD1 pair. Bundled and repo `--numstat` match line-for-line (23/11, 17/0, 49/1), and no other bundled file changed, so no unrelated drift was absorbed. `test_push_down_claude_resource_contracts.py` passes. |
| 5a. `LANDED_WAVE_FOUR_FEATURES` and the `continue` | **MINIMAL AND CORRECT.** `RESERVED_HEADINGS` untouched; the heading order/uniqueness pin and the 16-heading/first-13-layout pin are both absent from the diff and still fully active; the body pin remains in force for F6 and F8 because the frozenset contains only `"F7"`. One advisory on the eventual dead-test cleanup. |
| 5b. Two pack-manifest entries | **MINIMAL AND CORRECT.** Exactly two entries for the two genuinely new files, in correct alphabetical position; the three modified files were already listed at HEAD. |
| 6. Concurrent-feature boundary (F6/F8) | **VERIFIED CLEAN.** All 16 `##` headings survive in identical order in both the repo copy and the bundled mirror. F6's heading is unmoved at line 435; F8's shifted from 443 to 491 solely as a consequence of F7's own section growing, with its text untouched as diff context. The `SKILL.md` diff is a single hunk confined to F7's reserved section. The validator edit is four lines strictly inside the F7 delimiter. No F6- or F8-owned surface was touched. |
| 7. Producer/consumer seam binding | **GENUINELY PROVEN.** Layer 2 tests import only `validate_parallel_orchestrator_state_text` and never the helper. Both hooks define their seam once and call it once. Both test files carry a dedicated binding context that flips allow→deny on a **byte-identical payload** by varying only the mocked seam value, with `Should -Invoke -Times 1 -Exactly` and a `-Times 0 -Exactly` out-of-scope case. This construction cannot pass unless the production code consumes the seam, so the defect the two earlier children shipped is not repeated. |
| 8. Test isolation | **VERIFIED CLEAN.** No new test creates a temp file or reads the live gitignored checkpoint. Both entrypoint contexts short-circuit before any checkpoint read, and `parallel-orchestrator-state.json` does not exist on disk. The single Pester failure is the pre-existing `enforce-pr-author-skill.Tests.ps1` coupling, which is not in the branch diff and is correctly excluded from this feature's findings while still being recorded. |

## Summary

All sixteen acceptance criteria are satisfied and independently verified. The two-layer cohort barrier is delivered as designed, with neither layer collapsed into the other. The worktree-removal gate and the additive invocation-origin extension behave as specified, and the live epic hook's contract is preserved byte-for-byte with a new regression pin protecting it.

Quality gates pass on every language with changed files. Python coverage improved on both metrics (line 91.82%→91.88%, branch 83.80%→83.96%); the three changed PowerShell production files measure 95.98%, 90.79%, and 89.86%, each individually above threshold. PowerShell branch coverage is not producible by the repository's tooling, which the reviewer confirmed directly by enumerating the emitted JaCoCo counter types rather than accepting the assertion. No test was deleted, skipped, or weakened anywhere in the diff.

The concurrent-feature boundary with F6 and F8 was respected precisely, which matters because both are executing against the same integration branch right now. Two orchestrator-authorized absorptions and two consequential repairs were each verified as minimal, correct, and non-weakening; the reviewer concurs with both adjudications.

The single Blocking issue is an undisclosed parity gap: the TypeScript F7 seam that upstream built for this feature was left empty, so two enforcement surfaces now disagree and no test catches it. It requires either a port with parity tests or an explicit recorded deferral decision. Combined with the merge-mechanics precondition that the branch has zero commits, the overall signal is **CHANGES REQUESTED**.

## Acceptance Criteria Check-off

Per `acceptance-criteria-tracking`, criteria evaluated PASS are checked off in every authoritative source file. All 16 items in **both** `spec.md` and `user-story.md` were already marked `[x]` by the executor before this review, and all 16 evaluate to PASS, so every existing check-off is **confirmed correct and none was reverted**. No newly-checked items were required, and no criterion text was modified.

No phantom criteria were added. No criterion was left unchecked, because none evaluated to PARTIAL, FAIL, or UNVERIFIED.

### Acceptance Criteria Status

```
- Source: docs/features/active/2026-08-07-parallel-enforcement-hooks-440/spec.md
          docs/features/active/2026-08-07-parallel-enforcement-hooks-440/user-story.md
- Total AC items: 16 (identical in both files)
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: none
```

Note that `## Definition of Done` in `spec.md` remains entirely unchecked (7 items). That section is a separate lifecycle checklist, not part of the `## Acceptance Criteria` section this work mode designates as authoritative, so it is outside this audit's check-off scope and is recorded here only to prevent a later reader mistaking it for missed AC.
