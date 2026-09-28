# Epic Kickoff: cleanup-merged-worktrees-hardening

Planned by epic-planner on 2026-09-07T10:30:00Z. All child features are prepared: issues
promoted, active folders created, research complete, spec/user-story written, atomic plans
approved, preflight ALL CLEAR. Planning state: artifacts/orchestration/epic-planner-state.json
(branch: epic/cleanup-merged-worktrees-hardening-integration).

## Invocation Prompt

Run `/epic-run cleanup-merged-worktrees-hardening` to execute this epic, or paste the prompt below.

Use the epic-orchestrator subagent to execute the prepared epic at docs/features/epics/cleanup-merged-worktrees-hardening/epic.md.
The integration branch epic/cleanup-merged-worktrees-hardening-integration already contains
every prepared feature folder and approved atomic plan.
Every child resumes at atomic execution from its committed plan-path rather than re-planning.
Execute per the
epic-orchestrate skill: wave-scheduled child orchestrator runs in isolated worktrees,
merge-on-green fan-in to the integration branch, and the final integration-to-main PR.
Read the Execution Amendments section of this artifact before launching wave 0; EA-1 and
EA-2 are binding on named children and are not carried in any child's cleared plan.

## Feature Summary

| issue_num | feature_folder | wave | complexity | plan-path |
| --- | --- | --- | --- | --- |
| 630 | docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630 | 0 | C3 | docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/plan.2026-09-06T17-12.md |
| 631 | docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631 | 1 | C2 | docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md |
| 632 | docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632 | 2 | C3 | docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/plan.2026-09-06T23-05.md |
| 545 | docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545 | 0 | C3 | docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md |
| 633 | docs/features/active/2026-09-06-collect-pr-context-omits-claude-tree-633 | 0 | C2 | docs/features/active/2026-09-06-collect-pr-context-omits-claude-tree-633/plan.2026-09-06T23-05.md |
| 635 | docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635 | 1 | C3 | docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md |
| 634 | docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634 | 0 | C2 | docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/plan.2026-09-06T23-08.md |
| 637 | docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637 | 2 | C3 | docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/plan.2026-09-07T01-26.md |

## Integrity

planning_commit: 73b451c09bf39a706bb71245a0dde5ae0fbc4660

| plan-path | plan-hash |
| --- | --- |
| docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/plan.2026-09-06T17-12.md | 911110aba1caf1e6769e02e255e1d21ac040a637 |
| docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/plan.2026-09-06T23-03.md | 2eb2ad80a2bd3179989bf90388b46a01c8ffa95e |
| docs/features/active/2026-09-06-cleanup-worktrees-dirt-classifier-632/plan.2026-09-06T23-05.md | 298878cd2ef01ade6e124f3fc95995a037cb3f13 |
| docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/plan.2026-08-25T08-13.md | efd24c7d0942706e404a0a4f8407e3b3d846052c |
| docs/features/active/2026-09-06-collect-pr-context-omits-claude-tree-633/plan.2026-09-06T23-05.md | 4e75eed13ba09abc10cd6b5bd43a941c762fb098 |
| docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/plan.2026-09-06T23-09.md | ae5599f3bf23570db0dc4ea82e32e54474dd13d6 |
| docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/plan.2026-09-06T23-08.md | e27a607beb634131055e8d87d1ed14004aa89535 |
| docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/plan.2026-09-07T01-26.md | 58cf6dc77f276dceb7211e36b1fa577e3472638b |

## Execution Order

Waves are recomputed by longest-path layering over the manifest DAG and were verified against
`scripts/dev_tools/epic_wave_computation.py` at planning time:

| wave | features | width |
| --- | --- | --- |
| 0 | 545 (E), 630 (A), 633 (H), 634 (G) | 4 |
| 1 | 631 (B), 635 (D) | 2 |
| 2 | 632 (C), 637 (F) | 2 |

Maximum wave width is 4, matching `max_parallel_features`. Four of the five dependency edges
are file-contention edges rather than contract edges, and the manifest records which is which.
631 depends on 630 and 632 depends on 631 because all three add call sites inside `run_report`
in `scripts/bash/cleanup_worktrees_lib.sh`, measured at 479 of the 500-line cap. 635 depends on
545 because 545's decision D11 rewrites the trigger scope filter and operand extractor in the
same two removal-gate files that 635 adds acceptance policy to, in a separable region above it.
637 depends on 635 as a genuine contract edge: it consumes 635's cleanup-manifest record shape.

## Execution Amendments

These are binding additions to prepared plans, established during planning but after the
affected child's preflight cleared. They are recorded here rather than by reopening a cleared
plan, because amending a plan after clearance would invalidate the clearance measured against
it. Hand each amendment to the named child in its delegation prompt. The same text is carried
in the Execution Amendments section of the epic manifest.

### EA-1 (binding) - bash toolchain runs through the pwsh-wrapped form, never bare `wsl`

Applies to children 630, 631, 632, and 637.

A bare `wsl` invocation matches no `atomic-executor` Bash grant and is denied wherever it runs,
including from a worktree-isolated agent. Child 630 lost its entire baseline capture to this and
reported the cause as an isolation guard; that diagnosis is wrong. The verified form is:

```
pwsh -NoProfile -Command "wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<path> && bash scripts/bash/shell-qc.sh <check|format|test --coverage>'"
```

Pipe output through `tr -d '\0'` in Git Bash. Fallback when the wrapped form is refused:
dispatch `.github/workflows/_shell-coverage.yml` with `gh workflow run --ref <branch>` and
read the uploaded `cov.xml`; CI is canonical when local and CI disagree.

### EA-2 (binding) - child 545 must pin the false-allow direction of the merge-gate defect

Applies to child 545.

The merge gate's whole-line PR-number extraction is not only a fail-closed defect. With parallel
items 501 at `ci_green` and 777 at `pr_open`, the command `cd /wt/501 && gh pr merge --merge 777`
extracts 501, matches the authorized item, and merges PR 777 - an unauthorized merge, not a
blocked one. Child 545's AT-2 corrects exactly that extraction, so its code change closes both
directions, but AT-2's test case uses a `cd` path component that matches no item and therefore
exercises the fail-closed direction only. Add at least one Pester case in the false-allow shape:
an extracted number that matches a different authorized item, asserting the merge is denied.
Without it the epic ships a fix whose more dangerous direction is untested. The full analysis is
retrievable from `bug/epic-merge-gate-parses-pr-number-from-whole-command-line-591` at commit
`3f6cdf46`, pushed to origin and deliberately not merged into this integration branch.

### EA-3 (not binding) - two confirmed weaknesses are deferred, not fixed

Neither is in any child's scope and both are confirmed rather than suspected. File them as
follow-ups; do not expand a child's scope to absorb them mid-execution.

- `Test-ChildCheckpointAllowsEpicMerge` in `enforce-epic-merge-gate.ps1` declares only
  `$Checkpoint`, its call site passes no PR number, and it is consulted first, ahead of
  both number-aware branches. A checkpoint with `epic_mode: true` and `step9_status:
  "passed"` therefore authorizes merging any pull request. Correcting the extraction does
  not touch that path.
- The `.codex` hook copies carry the same trigger defect that child 545 fixes Claude-side.

### EA-4 (binding) - the bash toolchain is denied to a delegated executor, and that can halt
Phase 0

Applies to children 630, 631, 632, and 637. This qualifies EA-1; it does not replace it. It is
the single largest risk to the execution run.

EA-1's wrapped form is correct and was re-run from the epic-planner context at planning close,
returning `WSL_OK` and `Bats 1.13.0`. What EA-1 did not establish is that a *delegated* agent
can run it. Child 637's round-3 preflight reviewer probed the same form from inside an
`atomic-executor` delegation in an isolated worktree and the harness guard denied it before
execution. The two observations are consistent: the constraint is the delegate's grant surface,
not the WSL path or the worktree location.

Verified at planning close:

- The CI fallback is genuinely dispatchable. `.github/workflows/_shell-coverage.yml` declares
  both `workflow_call` and `workflow_dispatch`, and runs `shell-qc check` and `shell-qc test
  --coverage` on `ubuntu-latest`.
- The CI fallback is aggregate-only. Its `upload-artifact` step publishes
  `artifacts/pester/kcov/**` and nothing else, so there is no per-test TAP artifact. A gate
  asserting a named bats test's pass count must be read from the workflow run log, not from a
  downloaded artifact. Child 637 counted roughly 30 targeted bats gates in this position.
- Child 637's `[P0-T2]` handles the local denial fail-closed, so a denied run halts rather than
  recording a false baseline.

Preference order: run the bash toolchain from the child `orchestrator`'s own context rather
than delegating it to `atomic-executor`, since the grant surface differs between them; if that
is also denied, dispatch the workflow and read the run log; treat CI as canonical when local
and CI disagree. Do not let a child record a baseline it could not actually capture.

## Withdrawn Children and Open Issues

The epic is eight children. Two further children were prepared during planning and then
withdrawn before fan-in, after child 545's decision D11 reversed a three-way split of gap 8 and
absorbed the whole enforcement-hook family into 545's own scope. Neither withdrawn child is in
the manifest, and neither branch is merged into this integration branch.

- Issue #591 (withdrawn child I, merge gate) is OPEN and must stay open through execution. It
  is closed as superseded by #545 when this epic merges; child 545's `issue.md` and `spec.md`
  record that supersession and its acceptance criteria require it. Its prepared branch
  `bug/epic-merge-gate-parses-pr-number-from-whole-command-line-591` at `3f6cdf46` is pushed to
  origin and retained for its 996-line spec and research artifact.
- Issue #636 (withdrawn child J, removal gates) was CLOSED as superseded by #545 during
  planning, with a comment recording the supersession. No action is required during execution.
  Its branch `bug/removal-gate-trigger-matches-whole-command-text-636` must not be merged.

## Execution Preconditions

- Every child resumes at atomic execution from its committed plan-path. No child re-runs
  promotion, research, feature documents, or atomic planning; each plan has already cleared
  preflight against the tree as it stands on this integration branch.
- Child PR base branch is the integration branch, not `main`. Pass `--base epic/cleanup-merged-worktrees-hardening-integration` to `gh pr create`.
- The manifest was validated at planning time: 8 features, cycle-free, every `depends_on`
  resolves, no duplicate `issue_num` or `feature_folder`, and no placeholder `issue_num`
  remains.
- Two production files this epic touches sit near the 500-line cap in
  `.claude/rules/general-code-change.md`: `scripts/bash/cleanup_worktrees_lib.sh` at 479 and
  `.claude/hooks/enforce-epic-merge-gate.ps1` at 451. Each child adds behavior in new or
  clearly separated files rather than by growing these.
- Every edit to a `.claude/**` file must be mirrored byte-identically into
  `extensions/drm-copilot/resources/claude-customizations/.claude/**` so the skill, scripts,
  and hooks push down together.
