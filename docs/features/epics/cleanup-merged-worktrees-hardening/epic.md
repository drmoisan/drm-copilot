---
epic: cleanup-merged-worktrees-hardening
integration_branch: epic/cleanup-merged-worktrees-hardening-integration
created_at: 2026-09-06T21:55:00Z
# AUTHORING-TIME MANIFEST. issue_num values 901 through 906 are placeholders for children whose
# promotion has not yet run; they are back-filled with the real GitHub issue numbers returned by
# each child's promotion receipt before the kickoff artifact is written. Children A (630) and E
# (545) carry real issue numbers because both were promoted before this epic was planned.
# feature_folder values for placeholder children are planned basename hints and are replaced with
# the concrete active-folder basenames at fan-in. depends_on uses issue_num values.
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
  - issue_num: 901
    feature_folder: cleanup-worktrees-report-mode-visibility-gaps
    depends_on: []
  - issue_num: 902
    feature_folder: cleanup-worktrees-dirt-classifier-and-clear-disposable
    depends_on: []
  - issue_num: 545
    feature_folder: 2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545
    depends_on: []
  - issue_num: 906
    feature_folder: collect-pr-context-omits-claude-tree-from-overview
    depends_on: []
  - issue_num: 903
    feature_folder: cleanup-worktrees-sanctioned-removal-manifest
    depends_on: [545]
  - issue_num: 905
    feature_folder: cleanup-worktrees-consolidation-pr-merge-gate
    depends_on: [545]
  - issue_num: 904
    feature_folder: cleanup-worktrees-preserve-file-consolidation
    depends_on: [903]
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
| B | 901 | 7, 9c, 9d | bash (report-mode records) | 0 |
| C | 902 | 2 | bash (dirt classifier, `--clear-disposable`) | 0 |
| E | 545 | 8 | PowerShell (command-word matching) | 0 |
| H | 906 | 9b | TypeScript (`collect_pr_context`) | 0 |
| D | 903 | 3, 9a | PowerShell hook + skill text (removal manifest) | 1 |
| G | 905 | 4 | PowerShell hook + skill text (consolidation merge gate) | 1 |
| F | 904 | 5 | bash + skill text (`PRESERVE` consolidation) | 2 |

### Children A and E are already promoted

Child A is GitHub issue #630, promoted on 2026-09-06 during the superseded small-path run that was
rerouted to this epic. Its promotion outputs are committed on this integration branch at
`3947b7a197c5493e9dd522efa640c2f3fb394fa9`: `issue.md` (work mode `full-bug`), the canonical plan
path `plan.2026-09-06T17-12.md` authored under the superseded minor-audit route, and the run
observations research file.

Child E is GitHub issue #545, filed on 2026-08-25 as the follow-up "R2" deliberately left unfiled
by issue #539. Its prepared feature folder — `issue.md` (work mode `full-bug`), `spec.md`,
research, an atomic plan, and Phase 0 baseline evidence — was committed on the unmerged branch
`bug/enforcement-hook-trigger-matches-whole-command-text-545` and is merged into this integration
branch. Its recorded scope is the preimplementation gate's `Test-ImplementationCommand`; the
2026-09-06 run observed the same defect class in `enforce-epic-merge-gate.ps1`, which is the
instance recorded in the unpromoted potential entry
`docs/features/potential/2026-08-29-epic-merge-gate-parses-pr-number-from-whole-command-line.md`.
Child E extends #545 to cover the gate-hook instances rather than opening a second issue for the
same defect class.

Neither child re-runs promotion. Both proceed from research.

## Dependency Edges

Three edges are recorded, each derived from a real contract or a direct file collision, not from
stylistic ordering.

- **D depends on E, and G depends on E.** Child E rewrites how the gate hooks decide whether a
  Bash command names a gated command word. Child D adds manifest acceptance to
  `enforce-epic-worktree-removal-gate.ps1` and child G adds a consolidation-PR checkpoint shape to
  `enforce-epic-merge-gate.ps1`. Both hooks are files E edits, and both children's new acceptance
  logic must sit alongside E's matcher rather than beside the substring match it replaces. Running
  them concurrently produces a direct fan-in conflict in two files and leaves each child asserting
  against a matcher that the other has replaced.
- **F depends on D.** Child F consumes the cleanup manifest that child D defines: the `PRESERVE`
  verdicts F stages are read from the manifest record shape D establishes. F cannot author its
  staging contract before that record shape exists.

No edge is recorded among A, B, C, and F for their shared use of the
`scripts/bash/cleanup_worktrees_*_lib.sh` family. `cleanup_worktrees_lib.sh` is at 479 of the
500-line cap, so each of those children adds its new function group in a new or clearly separated
file. That separation, not a dependency edge, is what keeps their fan-in conflict-free, and it
preserves four-way parallelism across the bash surface.

## Wave Assignment

Computed by longest-path layering over the dependency DAG per the `epic-orchestrate` skill
(`wave(f) = 0` when `depends_on(f)` is empty, otherwise `1 + max(wave(d))`):

| wave | features |
| --- | --- |
| 0 | 630 (A), 901 (B), 902 (C), 545 (E), 906 (H) |
| 1 | 903 (D), 905 (G) |
| 2 | 904 (F) |

`wave(630) = wave(901) = wave(902) = wave(545) = wave(906) = 0` (empty `depends_on`);
`wave(903) = 1 + wave(545) = 1`; `wave(905) = 1 + wave(545) = 1`;
`wave(904) = 1 + wave(903) = 2`. The graph is cycle-free and every `depends_on` entry resolves.

## Complexity Assessment

Bands are assessed against the `model_policy` scale and signals in
`config/orchestration-routing.json`. Each band is a reviewed starting assessment for the child
orchestrator's own model-selection step, not a substitute for it.

| id | band | rationale |
| --- | --- | --- |
| A | C3 | Introduces a new classification path for detached worktrees and a new apply-mode removal branch, and changes the delete-eligibility invariant for the consolidation branch. The `concurrency_or_ordering` floor signal applies: gap 6 is an ordering hazard on a branch that is delete-eligible during a window. |
| B | C2 | Three additive report-mode record types on an existing emission path. The `CHILD_OF` short-circuit changes classification cost, not classification outcome. Localized to report mode with no apply-mode effect. |
| C | C3 | A six-verdict deterministic classifier over dirty worktree state plus a destructive opt-in apply flag (`git reset --hard` and `git clean -fd`). The destructive path and the requirement that default behavior stay byte-identical make this cross-cutting within the tool. |
| E | C3 | The `cross_module_contract_change` floor signal applies: the command-classification decision is consumed by every gate hook, so changing it alters a contract across the whole enforcement surface, in both the false-positive and the latent-bypass direction. |
| H | C2 | A filtering change in one TypeScript module's changed-files overview, with a matching test. Localized, with no contract consumed outside the PR-context bundle. |
| D | C3 | The `cross_module_contract_change` floor signal applies: this child defines the cleanup manifest record shape that the hook, the skill text, and child F all read. The hook must keep denying unmanifested epic/parallel removals, so the change widens an enforcement allow-side without widening it further than intended. |
| G | C3 | Adds a fourth checkpoint shape recognized by a merge gate, or documents the merge as human-only. Either outcome changes an enforcement contract; the checkpoint route additionally introduces a CI-conclusion-bearing record that the gate trusts. |
| F | C3 | Stages never-committed files into a commit under three simultaneous constraints — `MEMORY.md` index-line carriage, per-file line-ending normalization, and host-token refusal. The `cross_module_contract_change` signal applies through its consumption of child D's manifest record shape. |

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
