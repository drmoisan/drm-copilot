---
epic: cleanup-merged-worktrees-hardening
integration_branch: epic/cleanup-merged-worktrees-hardening-integration
created_at: 2026-09-06T21:55:00Z
# LIVE MANIFEST. issue_num values in the 900 range are placeholders for children whose promotion
# has not yet completed (904 for child F, 907 for child J); each is back-filled with the real
# GitHub issue number from its promotion receipt, together with its concrete active-folder
# basename, before the kickoff artifact is written. Every other entry carries a real issue number
# and a resolved feature_folder. Children A (630), E (545), and I (591) were promoted before this
# epic was planned; 631, 632, 633, 634, and 635 were promoted during it. depends_on uses issue_num
# values throughout.
intent:
  epic_type: enabler
  business_outcome_hypothesis: A `/cleanup-merged-worktrees` run on a large checkout can be carried from report through apply, consolidation, and merge without hand-written scripts, manual consolidation commits, or hook workarounds. The 2026-09-06 TaskMaster run classified 45 branches and removed 7 worktrees correctly but left 30 detached worktrees invisible to apply mode, 14 dirty worktrees blocked with no verdict, and roughly 140 untracked lesson files to be consolidated by hand; every remaining manual step in that run is attributable to one of the nine gaps this epic closes.
  leading_indicators:
    - A repeat cleanup run classifies and removes detached-HEAD worktrees under the same allowlist used for branch-backed worktrees, so the count of worktrees invisible to apply mode is zero rather than 30.
    - The skill's own `SAFE_TO_DELETE` removal step completes through a sanctioned path, so no cleanup run requires writing removals to a script file to evade `enforce-epic-worktree-removal-gate.ps1`.
    - Consolidation of untracked `PRESERVE` files runs from the script rather than by hand, carrying `MEMORY.md` index lines and target-file line endings, and refusing host tokens.
    - A gated command word quoted inside `printf` text no longer produces a hook denial.
  nfrs:
    - Line coverage >= 85% for every new or modified bash, PowerShell, and TypeScript module, per `.claude/rules/quality-tiers.md`. Bash and PowerShell are exempt from the branch-coverage threshold only because kcov and Pester do not measure branch coverage.
    - Every new bash library function carries bats coverage per `.claude/rules/shell.md`, driven through the `CLEANUP_WT_GIT_BIN` stub seam against checked-in fixtures under `tests/fixtures/cleanup_worktrees/`, with no temporary files.
    - No production source file exceeds the 500-line cap in `.claude/rules/general-code-change.md`. `scripts/bash/cleanup_worktrees_lib.sh` is at 479 lines and `.claude/hooks/enforce-epic-merge-gate.ps1` at 451; new behavior is added in new or clearly separated files rather than by growing these.
    - Every edit to a `.claude/**` file is mirrored byte-identically into `extensions/drm-copilot/resources/claude-customizations/.claude/**` so the skill, scripts, and hooks push down together.
features:
  - issue_num: 630
    feature_folder: 2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630
    depends_on: []
  - issue_num: 631
    feature_folder: 2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631
    depends_on: [630]
  - issue_num: 632
    feature_folder: 2026-09-06-cleanup-worktrees-dirt-classifier-632
    depends_on: [631]
  - issue_num: 545
    feature_folder: 2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545
    depends_on: []
  - issue_num: 633
    feature_folder: 2026-09-06-collect-pr-context-omits-claude-tree-633
    depends_on: []
  - issue_num: 634
    feature_folder: 2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634
    depends_on: []
  - issue_num: 591
    feature_folder: 2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line
    depends_on: [545]
  - issue_num: 635
    feature_folder: 2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635
    depends_on: []
  - issue_num: 904
    feature_folder: cleanup-worktrees-preserve-file-consolidation
    depends_on: [635]
  - issue_num: 907
    feature_folder: removal-gate-trigger-matches-whole-command-text
    depends_on: [545, 635]
---

# Epic: cleanup-merged-worktrees Hardening

## Goal

Close the nine gaps observed in the 2026-09-06 `/cleanup-merged-worktrees` run so that a cleanup
run can be carried from report through apply, consolidation, and merge without manual routing,
hand-written scripts, or hook workarounds. The verbatim user-supplied observations are the scope
source of truth and are recorded at
`docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/research/2026-09-06-cleanup-run-observations-user-context.md`
on this integration branch.

Every fix ships in `drm-copilot` so the next push-down carries it. Consumer-repository copies are
not patched. The skill, the bash scripts, and the PowerShell hooks push down together.

## Scope

The epic spans four surfaces:

- **bash** — `scripts/bash/cleanup_worktrees_lib.sh`, `cleanup_worktrees_actions_lib.sh`,
  `cleanup_worktrees_enumerate_lib.sh`, `cleanup-worktrees.sh`, and new sibling libraries.
- **PowerShell** — `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`,
  `.claude/hooks/enforce-epic-merge-gate.ps1`, and the preimplementation gate's command classifier.
- **TypeScript** — the `collect_pr_context` changed-files overview in the extension surface.
- **skill text** — `.claude/skills/cleanup-merged-worktrees/SKILL.md`.

## Non-goals

- Patching the consumer-repository copies of the skill, scripts, or hooks directly. All fixes land
  in `drm-copilot` and reach consumers through the existing push-down mechanism.
- Deleting orphan directories or stale refs automatically. Gap 7 adds reporting only; deletion
  stays manual and confirmed per item.
- Changing default apply-mode behavior for dirty worktrees. Gap 2's clearing behavior is opt-in
  behind a new flag; `UNIQUE` dirt continues to block.
- Establishing the cause of the mid-run worktree deregistration observed in gap 9d. That child adds
  a `WARN|registration-lost|<path>` detection line, not a root-cause fix.

## Decomposition Rationale

Children are grouped so that each stays on one language surface, which keeps each child's
toolchain loop, policy reading order, and typed-engineer routing single-valued. The one exception
is child D, which changes a PowerShell hook and the skill text that documents it, because the hook
contract and its documented usage cannot be split without shipping a skill that describes a hook
that does not yet accept the manifest.

| id | issue_num | gaps | surface | wave |
| --- | --- | --- | --- | --- |
| A | 630 | 1, 6 | bash (apply-mode safety) | 0 |
| B | 631 | 7, 9c, 9d | bash (report-mode records) | 1 |
| C | 632 | 2 | bash (dirt classifier, `--clear-disposable`) | 2 |
| E | 545 | 8 (preimplementation-gate half) | PowerShell (shared command scanner) | 0 |
| H | 633 | 9b | TypeScript (`collect_pr_context`) | 0 |
| G | 634 | 4 | skill text (consolidation merge is human-performed) | 0 |
| I | 591 | 8 (merge-gate half) | PowerShell hook (merge gate) | 1 |
| J | 907 | 8 (removal-gate half) | PowerShell hooks (removal gates) | 1 |
| D | 635 | 3, 9a | PowerShell hooks + skill text (removal manifest) | 0 |
| F | 904 | 5 | bash + skill text (`PRESERVE` consolidation) | 1 |

### Gap 8 is three children, not one — a corrected decomposition

The first authoring of this manifest assigned gap 8 entirely to issue #545 and asserted that the
merge-gate instance sat in an unpromoted potential entry. Child G's preparation established that
both claims were wrong, and the record was corrected on 2026-09-07.

Issue #545's committed `spec.md` names `enforce-epic-merge-gate.ps1`,
`enforce-epic-worktree-removal-gate.ps1`, `enforce-parallel-worktree-removal-gate.ps1`,
`enforce-parallel-abandon-gate.ps1`, and `validate-bash.ps1` under "Out of scope / non-goals" as
"the remaining hook-family members, to be filed as a single follow-up candidate", and it carries
an acceptance criterion requiring every one of those files to carry no diff. Extending #545 to the
gate hooks would have required overriding an explicit, reasoned non-goal in an already-approved
specification.

That follow-up was already filed: issue #591, OPEN, promoted, with its lifecycle record committed
at `docs/features/potential/promoted/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md`.
Gap 8 is therefore split along the boundary #545 itself drew, with every hook file owned by exactly
one child:

- **Child E (#545)** builds the shared `hook-command-scanner.ps1` helper and applies it to the
  orchestration preimplementation gate, `enforce-promotion-mcp-only.ps1`, and
  `enforce-pr-author-skill-helpers.ps1`. Its scope is unchanged from its approved specification.
- **Child I (#591)** is the merge-gate half of #545's own follow-up AC. It consumes the helper and
  fixes both defects in `Get-EpicMergeGateCommandPrNumber`: the trigger over-match that gap 8
  observed, and the whole-line PR-number extraction that #591 records.
- **Child J (#907)** is the removal-gate half. It consumes the same helper and replaces substring
  trigger evaluation in `enforce-epic-worktree-removal-gate.ps1` and
  `enforce-parallel-worktree-removal-gate.ps1`.

Child J was added on 2026-09-07, after child D's preparation showed that nobody owned the
removal-gate trigger. The first correction assigned that half to child D on the reasoning that D
edits those two files anyway. D's approved `spec.md` shows why that does not work: its
manifest-acceptance branch deliberately sits **below** the detection call site and it records the
trigger guards as preserved untouched. Acceptance policy and trigger detection are separable
concerns in the same file, and D scoped itself to the first. Splitting them across two children
keeps each change reviewable and matches the boundary D itself drew.

The removal-gate instance is not hypothetical. During its own preparation, child D's first commit
attempt was denied with `EPIC_WORKTREE_REMOVAL_BLOCKED` because the hook's substring matcher found
the gated command words inside the commit-message heredoc body. That is gap 8's failure mode,
reproduced against the exact hooks child J fixes.

### Children A, E, and I are already promoted

Child A is GitHub issue #630, promoted on 2026-09-06 during the superseded small-path run that was
rerouted to this epic. Its promotion outputs are committed on this integration branch at
`3947b7a197c5493e9dd522efa640c2f3fb394fa9`: `issue.md` (work mode `full-bug`), the canonical plan
path `plan.2026-09-06T17-12.md` authored under the superseded minor-audit route, and the run
observations research file.

Child E is GitHub issue #545, filed on 2026-08-25 as the follow-up "R2" deliberately left unfiled
by issue #539. Its prepared feature folder — `issue.md` (work mode `full-bug`), an 886-line
`spec.md`, research, an atomic plan, and Phase 0 baseline evidence — was committed on the unmerged
branch `bug/enforcement-hook-trigger-matches-whole-command-text-545`, with no production change
ever made on it, and is merged into this integration branch. Its 2026-08-25 citations are twelve
days stale and are re-derived during preparation.

Child I is GitHub issue #591, filed on 2026-08-29. Its issue and promoted lifecycle record exist;
its active feature folder does not, so its preparation creates the folder from the promoted record
without creating a second issue.

None of the three re-runs issue promotion.

## Dependency Edges

Three edges are recorded, each derived from a real upstream contract, not from stylistic ordering
and not from a file collision that a scope boundary already prevents.

- **I depends on E, and J depends on E.** Both consume the shared `hook-command-scanner.ps1` helper
  that child E introduces: the quote- and heredoc-aware per-segment scanner whose trigger evaluation
  replaces raw-substring matching. Child I applies it to `enforce-epic-merge-gate.ps1` and child J
  to the two removal gates. Neither can author its trigger fix before the helper's API exists. These
  are contract edges, not collision edges — child E's own acceptance criteria require all three of
  those hook files to carry no diff in its change, so there is no overlap to serialize.
- **F depends on D.** Child F consumes the cleanup manifest that child D defines: the
  `preserved_files[]` records F stages are read from the manifest record shape D establishes. F
  cannot author its staging contract before that record shape exists.
- **J depends on D.** Both edit the two removal gates. D's acceptance branch sits below the
  detection call site and J replaces that call site, so the concerns are separable — but they are
  separable regions of the same two files, and D consumes part of the epic hook's 81 lines of
  headroom. D lands first so J re-measures against the file as D leaves it.

**Two edges recorded at authoring time have been withdrawn.** Child G was given `depends_on: [545]`
on the assumption that it would add a fourth checkpoint shape to `enforce-epic-merge-gate.ps1`. Its
preparation chose the other option gap 4 offers — documenting the consolidation merge as
human-performed — so it touches no hook and no file any other child owns. Child D was given the same
edge on the assumption that it would consume child E's scanner. Its preparation established that its
acceptance logic sits below the detection call site and consumes no part of the scanner's API, and D
reported the edge as not load-bearing. In both cases the edge's entire basis was an assumption that
preparation falsified, so both children are wave 0.

**Two edges were added after preparation, on measured file contention rather than on contract.**
The authoring-time decision to leave A, B, and C unordered rested on the assumption that placing
each child's new function group in a separate file would keep their fan-in clean. Preparation showed
that assumption to be only half right. Each of the three does put its new functions in its own
sibling library — `cleanup_worktrees_detached_lib.sh`, `cleanup_worktrees_report_records_lib.sh`,
and `cleanup_worktrees_dirt_lib.sh` — but each must also add call sites inside `run_report` in
`scripts/bash/cleanup_worktrees_lib.sh`, which is measured at 479 lines against the 500-line cap in
`.claude/rules/general-code-change.md`. Child C's preparation projected the file to 483 lines from
its change alone, leaving 17 lines of headroom for two further children.

Three children editing one function in a file with 21 lines of headroom produces both a textual
three-way conflict and a collective cap breach. Neither is the incidental conflict that the
`epic-orchestrate` merge-conflict remediation loop exists to absorb, and that loop blocks a child
after three passes. So `631 depends_on 630` and `632 depends_on 631` are recorded as
file-contention edges. They are the only edges in this manifest not derived from an upstream
contract, and they are named as such so a later reader does not mistake them for one.

The order is A, then B, then C. A goes first because it introduces the `WORKTREE|<path>|DETACHED|`
record that B's `WARN|registration-lost|` sits beside, and because it is the only one of the three
that also changes apply mode. Each child's plan carries a re-measure-at-execution-time task, so each
observes the file as its predecessor left it rather than as it stood at planning time; child C's
plan additionally carries an extraction contingency for the cap, which is the likely outcome once A
and B have landed.

No edge is recorded among A, B, C, and F for their shared use of the
`scripts/bash/cleanup_worktrees_*_lib.sh` family. `cleanup_worktrees_lib.sh` is at 479 of the
500-line cap, so each of those children adds its new function group in a new or clearly separated
file. That separation, not a dependency edge, is what keeps their fan-in conflict-free, and it
preserves four-way parallelism across the bash surface.

## Wave Assignment

Computed by longest-path layering over the dependency DAG per the `epic-orchestrate` skill
(`wave(f) = 0` when `depends_on(f)` is empty, otherwise `1 + max(wave(d))`):

| wave | features | width |
| --- | --- | --- |
| 0 | 630 (A), 545 (E), 633 (H), 634 (G), 635 (D) | 5 |
| 1 | 631 (B), 591 (I), 904 (F), 907 (J) | 4 |
| 2 | 632 (C) | 1 |

`wave(630) = wave(545) = wave(633) = wave(634) = wave(635) = 0` (empty `depends_on`);
`wave(631) = 1 + wave(630) = 1`; `wave(591) = 1 + wave(545) = 1`;
`wave(904) = 1 + wave(635) = 1`; `wave(907) = 1 + max(wave(545), wave(635)) = 1`;
`wave(632) = 1 + wave(631) = 2`. The graph is cycle-free and every `depends_on` entry resolves.
Verified against `scripts/dev_tools/epic_wave_computation.py`, the canonical implementation of the
longest-path layering formula.

Wave 0 is five features wide against a `max_parallel_features` of four, so `epic-orchestrator`
schedules that wave in two batches. The cap is a concurrency limit, not a wave-width constraint, and
splitting a wave into batches is ordinary scheduling rather than a manifest defect.

## Complexity Assessment

Bands are assessed against the `model_policy` scale and signals in
`config/orchestration-routing.json`. Each band is a reviewed starting assessment for the child
orchestrator's own model-selection step, not a substitute for it.

| id | band | rationale |
| --- | --- | --- |
| A | C3 | Introduces a new classification path for detached worktrees and a new apply-mode removal branch, and changes the delete-eligibility invariant for the consolidation branch. The `concurrency_or_ordering` floor signal applies: gap 6 is an ordering hazard on a branch that is delete-eligible during a window. |
| B | C2 | Three additive report-mode record types on an existing emission path. The `CHILD_OF` short-circuit changes classification cost, not classification outcome. Localized to report mode with no apply-mode effect. |
| C | C3 | A six-verdict deterministic classifier over dirty worktree state plus a destructive opt-in apply flag (`git reset --hard` and `git clean -fd`). The destructive path and the requirement that default behavior stay byte-identical make this cross-cutting within the tool. |
| E | C3 | The `cross_module_contract_change` floor signal applies: it introduces the shared command scanner that children I and D both consume, and reworks the classification decision in three hooks, in both the false-positive and the latent-bypass direction. |
| H | C2 | A filtering change in one TypeScript module's changed-files overview, with a matching test. Localized, with no contract consumed outside the PR-context bundle. |
| G | C2 | Reassessed downward from C3 after preparation. The chosen option documents the consolidation merge as human-performed, so the change is confined to skill text and adds no enforcement surface. No floor signal applies to a documentation-only change. |
| I | C3 | The `cross_module_contract_change` floor signal applies: it changes the trigger contract of a merge gate consumed across the epic and parallel orchestration surfaces, and corrects a fail-closed parse defect that denies correct commands. |
| D | C3 | The `cross_module_contract_change` floor signal applies: this child defines the cleanup manifest record shape that the hooks, the skill text, and child F all read. The hooks must keep denying unmanifested epic/parallel removals, so the change widens an enforcement allow-side without widening it further than intended. |
| J | C3 | The `cross_module_contract_change` floor signal applies: it changes the trigger contract of the two worktree-removal gates, which govern every epic and parallel run, in both the false-positive and the latent-bypass direction. |
| F | C3 | Stages never-committed files into a commit under three simultaneous constraints — `MEMORY.md` index-line carriage, per-file line-ending normalization, and host-token refusal. The `cross_module_contract_change` signal applies through its consumption of child D's manifest record shape. |

## Open Epic-Owner Decisions

These surfaced during preparation and are recorded rather than resolved. None blocks kickoff.

1. **Does gap 4 require an unattended merge?** Child G read the business-outcome hypothesis above,
   which names "merge" explicitly, as satisfied by a documented human merge: a human merge is not a
   hand-written script, a manual consolidation commit, or a hook workaround, and no leading
   indicator names an unattended merge. That is an interpretive reading of the objective's wording.
   If an unattended merge is intended, gap 4 must be re-scoped to the checkpoint route, which
   additionally requires adding the merge command to the skill's `allowed-tools` and granting a
   project permission for agent merge authority over `main`. Child G verified that the merge command
   is absent from all three of those places today, so the checkpoint shape alone would not have
   removed the human step.

2. **Two adjacent weaknesses are recorded but unfiled.** Child G established that the merge gate's
   existing accept path 1 (`Test-ChildCheckpointAllowsEpicMerge`) takes no PR-number parameter, so a
   checkpoint with `epic_mode: true` and `step9_status: "passed"` authorizes merging any pull
   request. It also recorded the #545 scope question this manifest has since resolved. Both are
   written into child G's `spec.md`; neither has a GitHub issue.

3. **Child H left the Python parity module untouched.** `scripts/dev_tools/pr_context/collector.py`
   carries the identical bucketing defect that child H fixes in TypeScript, and child H's research
   established that no CI job, test, or policy binds the two implementations. After this epic
   merges, the two PR-context implementations diverge. Recorded in child H's `spec.md` as a known
   limitation with a follow-up recommendation.

4. **Gap 9b's literal request is not satisfiable as worded.** `collect_pr_context` reads
   `git diff --name-status`, which never surfaces untracked content, and no path under
   `.claude/agent-memory/**` is tracked today. Including that tree in the overview therefore changes
   nothing unless files there are force-added. Child H's general fix does close the far larger drop
   the gap's wording understated.

## Shared Design Constraints

These apply to every child and are repeated in each child's preparation prompt.

1. **Deliver in `drm-copilot`.** No consumer-repository copy is patched. Every `.claude/**` edit is
   mirrored byte-identically into
   `extensions/drm-copilot/resources/claude-customizations/.claude/**`.
2. **File-size cap.** `scripts/bash/cleanup_worktrees_lib.sh` is at 479 lines,
   `.claude/hooks/enforce-epic-merge-gate.ps1` at 451, and
   `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` at 418, against a 500-line cap. New
   behavior goes in new or clearly separated files.
3. **bash test contract.** bats suites drive the `CLEANUP_WT_GIT_BIN` stub seam against checked-in
   fixtures under `tests/fixtures/cleanup_worktrees/`. No temporary files, per
   `.claude/rules/general-unit-test.md`.
4. **bash toolchain.** `bats` 1.13.0, `kcov` 43, `shfmt`, and `shellcheck` run under WSL Ubuntu via
   `wsl -d Ubuntu -- bash -lc 'cd /mnt/c/<worktree> && bash scripts/bash/shell-qc.sh <format|check|test --coverage>'`.
   `shfmt` and `shellcheck` are also on the Windows PATH.
5. **Default behavior is preserved.** Gap 2's clearing is opt-in; gap 7's orphan and stale-ref
   output is report-only; gap 3 keeps the hook denying unmanifested epic/parallel removals.
