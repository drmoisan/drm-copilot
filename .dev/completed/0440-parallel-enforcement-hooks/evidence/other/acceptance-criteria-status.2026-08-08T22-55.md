# Acceptance-Criteria Status Summary — Issue #440

Timestamp: 2026-08-08T22-55

Task: [P6-T8]

Branch: `feature/parallel-enforcement-hooks-440`

Work mode: `full-feature` — per the `acceptance-criteria-tracking` skill, the AC sources are therefore **both** `spec.md` **and** `user-story.md`, each carrying the identical 16-item `## Acceptance Criteria` section. Both files were tracked independently.

Command (verification of final checkbox state):

```
pwsh -NoProfile -Command 'foreach ($f in @("spec.md","user-story.md")) { ... count - [x] and - [ ] items inside the ## Acceptance Criteria section ... }'
```

EXIT_CODE: 0

Observed:

```
spec.md: total=16 checked=16 unchecked=0
user-story.md: total=16 checked=16 unchecked=0
```

Text-preservation verification: `git diff --numstat` reports `16  16` for each file — exactly 16 lines changed per file, one per criterion, each change being only `- [ ]` to `- [x]`. No criterion text was modified and no criterion was added or removed.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-enforcement-hooks-440/spec.md and docs/features/active/2026-08-07-parallel-enforcement-hooks-440/user-story.md
- Total AC items: 16 per file (16 in spec.md, 16 in user-story.md; identical sections)
- Checked off (delivered): 16 per file (16 in spec.md, 16 in user-story.md)
- Remaining (unchecked): 0 per file (0 in spec.md, 0 in user-story.md)
- Items remaining: none
```

## Per-Criterion Evidence Map

| # | Criterion (abbreviated) | Plan task | Evidence | Status |
| --- | --- | --- | --- | --- |
| 1 | Layer 1 denies conflicting prior-cohort neighbor with non-terminal `merge_status`, exact literal `PARALLEL_COHORT_BARRIER_BLOCKED` | P6-T1 | `evidence/regression-testing/phase1-powershell-tests.2026-08-08T21-37.md`; `evidence/qa-gates/powershell-tests-coverage.2026-08-08T22-42.md` (cohort-barrier suite 56 tests, 0 failures); test context `deny PARALLEL_COHORT_BARRIER_BLOCKED when a conflicting prior-cohort neighbor is not terminal` | PASS |
| 2 | Layer 1 allows when every conflicting prior-cohort neighbor is terminal, and allows with no conflicting prior-cohort neighbors | P6-T1 | Same; test context `allow when every conflicting prior-cohort neighbor is merged or worktree_removed` (includes `allows a target that has no conflict edges at all`) | PASS |
| 3 | Layer 1 allows a prompt lacking `Parallel mode: true` | P6-T1 | Same; `allows an orchestrator delegation whose prompt lacks the Parallel mode: true marker` | PASS |
| 4 | Layer 1 allows a non-`orchestrator` `subagent_type` | P6-T1 | Same; `allows a non-orchestrator subagent delegation` | PASS |
| 5 | Layer 1 fails closed on missing or malformed checkpoint | P6-T1 | Same; `denies when the parallel checkpoint file is absent`, `denies when the parallel checkpoint content is malformed JSON` | PASS |
| 6 | Layer 1 fails closed on unresolvable target (no folder token, no `items[]` record, no current-generation cohort) | P6-T1 | Same; `denies when the prompt carries no feature-folder token`, `denies when no items[] record matches the resolved feature folder`, `denies when the target has no current-generation cohort assignment` | PASS |
| 7 | `ci_green` does not satisfy the barrier | P6-T1 | Same; `denies when the conflicting prior-cohort neighbor has merge_status ci_green`, plus the read-seam pair proving the identical payload flips on the seam value alone | PASS |
| 8 | Layer 2 exactly one message per violated edge in the exact literal form, covering structural and temporal readings | P6-T2 | `evidence/regression-testing/phase3-python-tests.2026-08-08T22-11.md`; `evidence/qa-gates/python-tests-coverage.2026-08-08T22-48.md` (3038 passed, 0 failed); tests `test_same_cohort_conflicting_pair_reports_one_structural_violation`, `test_merge_confirmed_after_later_start_reports_a_temporal_violation`, `test_violation_message_matches_the_exact_literal_form`, `test_multiple_violated_edges_each_report_exactly_one_message` | PASS |
| 9 | Layer 2 key-gated backward compatibility; clean multi-cohort checkpoint yields zero barrier errors | P6-T2 | Same; `test_checkpoint_without_a_gating_key_emits_no_violation`, `test_clean_multi_cohort_checkpoint_yields_no_barrier_errors` | PASS |
| 10 | Worktree removal gate denies non-terminal `merge_status`; fails closed on unreadable checkpoint or unmatched path; `PARALLEL_WORKTREE_REMOVAL_BLOCKED` prefix | P6-T3 | `evidence/qa-gates/powershell-tests-coverage.2026-08-08T22-42.md` (worktree-gate suite 40 tests, 0 failures); contexts `deny PARALLEL_WORKTREE_REMOVAL_BLOCKED for every non-terminal merge_status` (7 cases incl. `pr_open`, `ci_green`) and `deny fail-closed on an unusable checkpoint or an unmatched path` | PASS |
| 11 | Worktree removal gate allows `merged` / `worktree_removed`; allows non-`git worktree remove` commands unconditionally | P6-T3 | Same; contexts `allow when the matched item merge_status is terminal` and `commands outside scope are allowed unconditionally` | PASS |
| 12 | Extended invocation-origin hook denies `Agent(parallel-orchestrator)` and `Agent(parallel-planner)` from caller `agent_type` `orchestrator`; allows from main thread and non-orchestrator agents | P6-T4 | `evidence/regression-testing/phase2-powershell-tests.2026-08-08T21-56.md`; `evidence/qa-gates/powershell-tests-coverage.2026-08-08T22-42.md` (invocation-origin suite 27 tests, 0 failures); contexts `deny PARALLEL_INVOCATION_ORIGIN_BLOCKED for orchestrator-originated parallel invocations` and `allow when a parallel agent is invoked outside an orchestrator context` | PASS |
| 13 | Epic behavior byte-identical (exact-string assertion) and all pre-existing tests pass unmodified | P6-T4 | Same; context `epic behavior is byte-identical after the parallel extension` (two byte-for-byte deny-reason assertions); `git diff --numstat` on the test file is `154  0` — appended lines only, zero deletions, so all 13 pre-existing tests are unmodified and pass | PASS |
| 14 | `.claude/settings.json` registrations, including the Phase 0-conditioned `SubagentStop` matcher | P6-T5 | `evidence/other/phase4-settings-registrations.2026-08-08T22-24.md`, `evidence/other/subagentstop-registration-decision.2026-08-08T22-24.md`, `evidence/other/settings-json-validity.2026-08-08T22-24.md`; parsed verification confirms `PreToolUse matcher=Agent -> enforce-parallel-cohort-barrier.ps1`, `PreToolUse matcher=Bash -> enforce-parallel-worktree-removal-gate.ps1`, and `SubagentStop matcher=parallel-orchestrator` invoking `validate-orchestrator-output.ps1 -CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state` | PASS |
| 15 | Line coverage >= 85%, branch coverage >= 75%, no regression on changed lines | P6-T6 | `evidence/qa-gates/coverage-comparison.2026-08-08T22-50.md`. Per-file PowerShell: cohort barrier **95.98%** (174/167), worktree gate **90.79%** (76/69), invocation origin **89.86%** (69/62), all >= 85%. Python line **91.88%** (>= 85%, +0.06 pp vs baseline), branch **83.96%** (>= 75%, +0.16 pp). New helper module 99%; edited validator 97% with both added statements covered. BRANCH not emitted by PoshQC/Pester coverage output (explicit absence note recorded). | PASS |
| 16 | All test files mirrored under `tests/`, mocked read seams instead of temp files, deterministic | P6-T7 | Four files confirmed present at `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`, `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1`, `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`. Mocked read seams used 21 and 20 times respectively; the Python suite uses inline JSON fixture strings. A scan for `TestDrive`, `New-TemporaryFile`, `GetTempPath`, `tempfile`, `tmp_path`, `Start-Sleep`, `Get-Date`, `Get-Random`, `datetime.now`, `random.`, `time.sleep` across all four files returned zero matches (grep exit 1). The two "real read seam" cases mock `Test-Path` and `Get-Content` and write no file. | PASS |

## Gaps

None. Every criterion's cited evidence exists and passed, so no criterion was left unchecked and there is no documented gap.

Output Summary: All 16 acceptance criteria are checked off in BOTH AC source files — `spec.md` 16/16 and `user-story.md` 16/16, 0 unchecked in each. `git diff --numstat` shows exactly 16 changed lines per file, each a `- [ ]` to `- [x]` flip with criterion text preserved. Every criterion maps to existing, passing evidence: Pester suites 56/40/27 tests with 0 failures, pytest 3038 passed with 0 failures, per-file PowerShell coverage 95.98% / 90.79% / 89.86% (all >= 85%), Python line 91.88% (>= 85%) and branch 83.96% (>= 75%), and parsed confirmation of all three `.claude/settings.json` registrations. No gap and no unchecked item remains.
