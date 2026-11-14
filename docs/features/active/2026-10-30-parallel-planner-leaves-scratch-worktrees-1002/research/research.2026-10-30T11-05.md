# Research: parallel-planner-leaves-scratch-worktrees (Issue #1002)

- Issue: #1002
- Branch: `bug/parallel-planner-leaves-scratch-worktrees-1002`
- Work mode: full-bug
- Timestamp: 2026-10-30T11-05 (UTC). The `task-researcher` agent has no shell; the value was read from the `timeapi.io` UTC clock endpoint through WebFetch immediately before the write.
- Inputs read: `issue.md`, `spec.md`, `plan.2026-10-30T06-59.md` in this feature folder; the #995 feature folder `docs/features/active/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees-995/` (`spec.md`, `plan.2026-10-29T05-58.md`, `research/research.2026-10-29T10-07.md`).
- Facts that need `git` or `gh` (for example whether the scratch registrations still exist) are marked for the orchestrator to confirm.

## Summary of Findings

1. No file in the planning surface instructs the planner to run `git worktree add`. The scratch worktrees are improvised by the planner because `.claude/skills/parallel-plan/SKILL.md` requires two things it gives no worktree-free technique for: committing to `parallel/<slug>-plan`, a branch that is not checked out in the planner's checkout, and reading each item's plan and `spec.md` text, which exist only on the pushed item branches.
2. The removal gates authorize a removal only from a parallel-orchestrator `items[]` record or an epic `features[]` record with `merge_status` in `{merged, worktree_removed}`, or from a fresh `cleanup-merged-worktrees` manifest. They never read `artifacts/orchestration/parallel-planner-state.json`. A planner-created worktree therefore always denies with `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. There is no sanctioned per-path removal route for planner-owned worktrees.
3. Run Closing substep 4 (added by #995) handles scratch worktrees only through the repository-wide `cleanup-merged-worktrees` report and a conditional `--apply`, and otherwise records a deferral. It does not, and per #995 decision D5 should not, gain a hook allow.
4. Recommended fix: candidate (a), a text-only change to the planner surface. The planner authors `parallel/<slug>-plan` in its own session checkout (the `epic-plan` precedent), reads item text by ref with `git show`, and is told explicitly that it creates no worktree. Four files change: the skill, the agent, and their two bundled copies. No hook, rule, validator, `.agents`, `.codex`, or `.github` file changes.

## 1. Where the Planning Surface Creates or Permits Worktrees

### Files in the planning surface

| Surface | Canonical | Bundled copy | `.agents` / `.codex` / `.github` counterpart |
| --- | --- | --- | --- |
| Agent | `.claude/agents/parallel-planner.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` | none |
| Skill | `.claude/skills/parallel-plan/SKILL.md` | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | none |

The Codex runtime deliberately has no parallel surface: `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` asserts that `.agents/skills/parallel-plan/SKILL.md`, `.agents/skills/parallel-orchestrate/SKILL.md`, `.agents/skills/parallel-run/SKILL.md`, `.codex/agents/parallel-planner.toml`, and `.codex/agents/parallel-orchestrator.toml` do not exist. The only `.codex` file naming the planner is `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, which is a hook reference, not a counterpart.

### Worktree-related instructions (complete)

A search for `worktree add` across `.claude/`, `.agents/`, `.codex/`, and `.github/` matches only `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh` (the consolidation-branch step), which is not part of the planning surface. Every `worktree` mention in the two planner files:

- `.claude/skills/parallel-plan/SKILL.md` `## Preparation Fan-Out`: preparation children are launched as `Agent` calls with `isolation: "worktree"` and `run_in_background: true`, and "Create each preparation worktree's branch from `origin/main`." These are runtime-managed worktrees, not planner-created ones.
- The same section, kickoff-line properties: the push instruction exists "so each item's prepared work is durable before its worktree is removed."
- `## Artifact Home`, **Per-item artifacts**: the item branch is "pushed to `origin` before its worktree is removed"; record `branch_name` and `worktree_path` per item.
- `## Artifact Home`, **Run-level artifacts**: the manifest and durable kickoff "live on the planner-owned branch `parallel/<slug>-plan`, created off `origin/main` and pushed." The skill does not say where or how the planner commits to that branch.
- `## Artifact Home`, **Read access**: "Readers — validators and the future `parallel-orchestrator` — reach both artifact classes by ref: `git fetch origin <branch>` followed by `git show <ref>:<path>`, without checking the ref out." The planner itself is not named as a reader.
- `## Checkpoint Persistence`, per-item `worktree_path`; and **Cache doctrine**, which re-derives state from `git worktree list --porcelain` on resume.
- `.claude/agents/parallel-planner.md` `## Startup Protocol` step 4 (`git worktree list --porcelain` on resume) and `## Checkpoint Persistence` (`worktree_path` per item).

### Which instruction produces which scratch worktree

No instruction names `wtplan` or `wt<issue>`. The #995 research (`research/research.2026-10-29T10-07.md`, `## 3. Planner Scratch Worktrees`) recorded that all three registrations were detached and pointed into the session scratchpad, that `wtplan`'s `HEAD` was the kickoff commit on the unmerged planning branch, and that `wt989`'s `HEAD` was a separate commit. Mapping those observations onto the skill's requirements:

- **`wtplan`** corresponds to the run-level obligations: `## Manifest Authoring` ("Commit it to `parallel/<slug>-plan` in fully resolved form"), `## Kickoff Artifact` ("commit a byte-identical durable copy to `docs/features/parallel/<slug>/parallel-kickoff.md` on `parallel/<slug>-plan`"), and `## Artifact Home` ("created off `origin/main` and pushed"). The skill gives no technique for committing to a branch the planner's checkout does not have checked out, so the planner checked the branch tip out in a detached scratch worktree, committed, and pushed.
- **`wt989` and `wt990`** correspond to the per-item reads: `### Planner procedure` step 1 ("read the approved plan text and the feature `spec.md` text"), which `derive_blast_radius` and `Get-BlastRadius` consume as document text, plus the **Git integrity is F4-owned** check. Those documents exist only on each pushed item branch. The **Read access** paragraph prescribes `git show <ref>:<path>` only for validators and the parallel orchestrator, so the planner had no stated technique and checked each item branch out in a scratch worktree so the Read tool could open the files.
- These attributions are inferred from the observed `HEAD`s and the skill text; the planner's transcript was not available. They are recorded as likely, not verified.

### Tool allowlist and checkout context

- `.claude/agents/parallel-planner.md` `tools:` grants `Bash(git *)`, which admits `git worktree add`, `git checkout`, and `git worktree remove` alike. It grants no PowerShell tool and no `Bash(pwsh*)` entry although the skill states `pwsh` is mandatory for the blast-radius facade; how the planner ran that facade is unknown and outside this issue.
- `.claude/skills/parallel-plan/SKILL.md` frontmatter is `context: fork` with `agent: parallel-planner`, and the agent declares no `isolation`. The Claude Code subagent documentation (`https://code.claude.com/docs/en/sub-agents`, Working directory) states: "A subagent starts in the main conversation's current working directory." The planner therefore runs in the operator's session checkout.
- The `epic-plan` precedent (`.claude/skills/epic-plan/SKILL.md` `## Integration Branch Lifecycle`, step 1) has its planner run `git checkout -b epic/<epic-slug>-integration origin/main` in that same session checkout. The parallel skill has no equivalent step.

### Preparation children: runtime-managed, not planner-created

- Preparation children are spawned with `isolation: "worktree"`. The Claude Code worktree documentation (`https://code.claude.com/docs/en/worktrees`, `## Isolate subagents with worktrees` and `### Clean up subagent and background-session worktrees`) states that such a worktree is removed automatically when the subagent finishes without changes, that a worktree with changes stays until a periodic sweep can remove it without losing work (the sweep keeps worktrees with changed or untracked files or unpushed commits), and that the sweep keeps any worktree "You created yourself with `git worktree add`."
- **Who removes the preparation worktree in "Artifact Home".** The skill names no remover. The removal is performed by the Claude Code runtime: immediately when the child leaves no changes, otherwise by the periodic sweep once the child's commits are pushed and its tree is clean. The planner's push instruction exists so that the sweep's "unpushed commits" condition does not hold. The planner is not instructed to remove these worktrees, and the removal gate would deny it if it tried, because the planner checkpoint is not an authorization source.
- This asymmetry explains the issue: runtime-managed preparation worktrees are reclaimed, while worktrees created by the planner with `git worktree add` are never swept and never authorized for removal. The issue observed only the three planner-created registrations left behind.

## 2. How the Removal Gates Decide

### `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

Registered in `.claude/settings.json` on the `Bash` `PreToolUse` matcher. Decision flow (`Invoke-ParallelWorktreeRemovalGateDecision`, `Get-ParallelWorktreeRemovalTargetDenial`):

1. A dependency-load failure, or an unreadable envelope, denies (fail closed).
2. A command that is not structurally a `git worktree remove` invocation (`Test-CommandLineInvocation`) allows. `git worktree add` is therefore never gated (pinned by the test `allows git worktree add` in `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1`).
3. Targets are derived with `Resolve-CommandLineInvocationTarget`; an underivable target denies with `TARGET_WORKTREE_NOT_DERIVABLE`.
4. Per target, `Read-ParallelWorktreeGateRunCheckpoint` resolves, through `Resolve-WorktreeRunTargetByRecord` (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, `-Kind` limited to `epic` and `parallel`), the live worktree whose run checkpoint records the target under `worktree_path`, and reads `artifacts/orchestration/parallel-orchestrator-state.json` (kind `parallel`) and the epic checkpoint (kind `epic`) beneath it. An `Ambiguous` resolution denies.
5. Allow when `Find-ParallelWorktreeItemRecord` finds an `items[]` record (parallel) whose `worktree_path` matches the target through `Test-WorktreeRunRecordedPathMatchesTarget` and `Test-ParallelWorktreeRemovalAllowed` sees `merge_status` in `{merged, worktree_removed}`.
6. Otherwise allow when the epic checkpoint's `features[]` record satisfies the same predicate (issue #688).
7. Otherwise allow when the target is not covered by any parallel `items[]` record (`Test-CleanupManifestCheckpointCoversPath`) and `Test-CleanupWorktreeManifestAuthorizesRemoval` (`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`) accepts a fresh `artifacts/orchestration/cleanup-worktrees-manifest.json` entry. The #995 research recorded that this manifest route accepts only `SAFE_TO_DELETE` dispositions with dirty-worktree triage verdicts, so it does not serve clean scratch checkouts.
8. Otherwise deny with `PARALLEL_WORKTREE_REMOVAL_BLOCKED: ... requires a matching parallel checkpoint items[] record with merge_status in {merged, worktree_removed}`, prefixed with the resolution reason when neither kind resolved.

A planner scratch worktree reaches step 8: no run checkpoint records its path, so resolution yields `NoTarget` for both kinds, no record matches, and the manifest route does not apply. Fields read: `items[].worktree_path` and `items[].merge_status` (parallel-orchestrator checkpoint), `features[].worktree_path` and `features[].merge_status` (epic checkpoint), and the cleanup manifest. `parallel-planner-state.json` and the run manifest `docs/features/parallel/<slug>/parallel.md` are not read.

### Sibling gate and the Codex runtime

- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (with `enforce-epic-worktree-removal-gate-resolution.ps1`) is registered on the same matcher and denies independently with `EPIC_WORKTREE_REMOVAL_BLOCKED`. `.claude/skills/parallel-orchestrate/SKILL.md` `## Worktree Cleanup` records that `PreToolUse` denials are conjunctive, so any new allow source would have to be added to both gates.
- `.codex/config.toml` registers only `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`; there is no Codex copy of the parallel gate, consistent with the Codex runtime having no parallel surface.
- There is no `.claude/lib/bash/remove-parallel-item.sh`. The only scripted removal route is `bash .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh --apply`, whose inner `git worktree remove` is not visible to the hook because the hook sees only the outer command. That route is repository-wide.

### Sanctioned removal path for planner-owned worktrees

None exists. The only removal that succeeds for an unrecorded worktree is the repository-wide `cleanup-merged-worktrees` apply mode, which the issue identifies as risky and which classifies a detached `wtplan` as merged only after the planning branch reaches `main`.

## 3. Run Closing and Planner Worktrees

`.claude/skills/parallel-orchestrate/SKILL.md` `### Run Closing` (issue #995):

- Substep 1 removes item worktrees only (records with `merge_status: merged`), using `git worktree list --porcelain` paths.
- Substep 4 **Scratch worktrees** runs the `cleanup-merged-worktrees` report after the run-document pull request merges, and runs `--apply` only when every delete-eligible row is an item worktree or "a planner scratch worktree named in the run's manifest, kickoff, or checkpoint"; otherwise it applies nothing and reports each scratch worktree as a deferral. It states "Add no hook allow for scratch worktrees."
- Substep 5 reports each scratch worktree left in place as a deferral.

Does it remove planner-created worktrees? Only conditionally, through the repository-wide tool, and never through a gated `git worktree remove`. The issue's run shows the conditional path left all three in place.

Should it? No further change is recommended. #995 recorded decision D5 (`spec.md` decisions list; `plan.2026-10-29T05-58.md` Design Decision 7): no hook allow, and fix at the source if the planner can avoid creating them. A closing-time removal also cannot satisfy "Planning leaves no worktree behind": a planned run that is never executed, or is executed in another session, would still leak. Substep 4 stays as written; once the planner creates no worktrees it finds none for new runs and remains useful for runs planned before the fix.

## 4. Candidate Fixes

### (a) Planner creates no worktree (recommended)

Description:

- **Plan-home branch in the planner's own checkout.** In `## Artifact Home`, add a plan-home checkout step modelled on `epic-plan` step 1: after every preparation child (including any V1/V2 re-plan delegation) has terminated and before `## Manifest Authoring`, run `git fetch origin main` and `git checkout -b parallel/<slug>-plan origin/main`, or `git checkout parallel/<slug>-plan` when the branch already exists on resume. On a refused checkout, stop and report; do not stash, force, or reset. Write the run folder in place (the agent's `Write(docs/features/parallel/**)` grant already targets the session checkout), commit through the existing `### Integration Commit Form (issue #539)` pathspec-bearing forms, and push with `git push -u origin parallel/<slug>-plan`. The checkout stays on that branch.
- **Reads by ref.** Extend **Read access** so the planner itself is a named reader: it reads each item's approved plan and `spec.md` text for `### Planner procedure` and performs the git-integrity check with `git fetch origin <branch>` and `git show origin/<branch>:<path>` / `git cat-file -e`, never by checking the branch out. In the PowerShell facade the text is captured from `git show` and joined with LF before it is passed to `Get-BlastRadius` and `Test-BlastRadius`.
- **Explicit prohibition.** Add a **No planner worktrees.** paragraph: the planner runs no `git worktree add` for any step; the only worktrees created during planning are the preparation children's `isolation: "worktree"` worktrees, which the Claude Code runtime creates and removes; and a planner-created worktree is outside every record the removal gates read and outside the runtime sweep. The same paragraph names the runtime as the remover of preparation worktrees, which answers the open question in **Per-item artifacts**.
- **Agent.** Add a sentence to `## Delegation Model` pointing to the prohibition, and a new item 8 under `## Completion Requirements`: the planner created no worktree (it ran no `git worktree add`), and `parallel/<slug>-plan` is checked out in its own session checkout and pushed.

Why the checkout location is consistent with the rest of the surface:

- `.claude/skills/parallel-run/SKILL.md` `## Procedure` step 2 resolves the kickoff by "a single local path lookup in the invoking worktree" and states that the durable copy "is reachable from the checkout that invokes this skill". That holds when the session checkout is on `parallel/<slug>-plan`.
- `### Run Closing` substep 3 commits `parallel-status.md` on the coordinator's current branch, requires `git diff --name-only origin/main...HEAD` to list only `docs/` paths, and lands that branch as the run-document pull request. The #995 research found that in the failing run the session branch carried code, so this precondition stopped the closing step. With the plan branch checked out in the session checkout, the precondition holds by construction. This is a consequence of the fix, not an added requirement.

Exact file set:

| File | Change |
| --- | --- |
| `.claude/skills/parallel-plan/SKILL.md` | `## Artifact Home`: plan-home checkout paragraph, **Read access** extended to the planner, **No planner worktrees.** paragraph |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | byte-identical copy |
| `.claude/agents/parallel-planner.md` | `## Delegation Model` sentence; `## Completion Requirements` item 8. `tools:` unchanged |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` | byte-identical copy |
| `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` (new) | contract tests below |

Not changed: any hook, `.claude/settings.json`, any `.claude/rules/` file, any `.github/instructions/` file, `quality-tiers.yml`, the planner-state validators (`scripts/dev_tools/validate_parallel_planner_state.py`, `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts`), pack manifests (no file is added to the bundle), `.claude/skills/parallel-orchestrate/SKILL.md`, and the execution-environment brief (it states no fact this fix changes).

Tests that prove it (new file, text-fragment convention of `test_parallel_planner_surface_contracts.py`):

- `## Artifact Home` contains the prohibition fragment (for example "runs no `git worktree add`") and the plan-home checkout command `git checkout -b parallel/<slug>-plan origin/main`.
- **Read access** names the planner as a reader and names `git show`.
- Every occurrence of `git worktree add` in the skill and agent sits in the prohibition sentence (occurrence count of `git worktree add` equals occurrence count of the exact prohibition fragment), so no later edit can add a creating instruction without failing the test.
- The agent `## Completion Requirements` section contains the no-worktree item.
- The new positive assertions fail on the current text, which satisfies the plan's `[expect-fail]` Phase 2 regression requirement. Bundle parity is proven by the existing push-down resource contract test.

Risks:

- Switching the session checkout to the plan branch changes the files the session sees, including `.claude/hooks/` scripts, to `origin/main`'s copies for the rest of the session. The `epic-plan` precedent carries the same property. Mitigation: perform the checkout after the last preparation child terminates, and stop on a refused checkout rather than forcing.
- Uncommitted operator changes in the checkout carry across `git checkout -b` when they do not conflict. The pathspec-bearing commit forms already prevent them from being committed to the plan branch.
- The prohibition is instruction-level; `Bash(git *)` still admits `git worktree add`. A mechanical guard would be a new hook (see Rejected alternatives). The contract tests prevent the instruction from regressing; they cannot prevent a model from disobeying it.
- Wording constraints from existing tests (section 5) must be respected, notably no occurrence of the word "pinned" in the skill.

### (b) Planner records and removes its worktrees; gate allows planner-recorded paths (rejected)

Would change `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` and its bundled copy, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and `enforce-epic-worktree-removal-gate-resolution.ps1` with bundled copies (denials are conjunctive), `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` (`-Kind` gains a planner kind) and its bundled copy, the Codex epic gate `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` and its Codex bundle copy, `.claude/rules/parallel-orchestration.md` (planner checkpoint schema), both planner-state validators if the new field is validated, the skill and agent with bundled copies, and new cases in the six `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate*.Tests.ps1` suites plus the epic gate suites (Linux hook-suite job). It adds an allow source with no merge-state predicate (a detached `wtplan` is unmerged until the run-document pull request merges), which #995 D5 rejected. A variant that removes the worktrees through a new bash helper hides the inner `git worktree remove` from the hook, which is a hook bypass. Largest blast radius, a rule-file change, and a weakened safety gate.

### (c) Run Closing removes planner worktrees (rejected)

Already present as substep 4 in its safe form. Making it unconditional requires either the hook allow rejected in (b) or an unconditional repository-wide `--apply`, which can delete a concurrent session's clean worktree. It also leaves worktrees behind for every planned run that is not closed in the same checkout, so it does not satisfy "Planning leaves no worktree behind". File set would be `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, bundled copies, and the #995 Run Closing contract tests.

### Rejected technique for (a): git plumbing

Committing to `parallel/<slug>-plan` without any checkout (temporary index through `GIT_INDEX_FILE`, `git mktree`, `git commit-tree`, `git push <sha>:refs/heads/...`) needs an environment-variable prefix or stdin pipes that `Bash(git *)` does not admit and nested tree construction for `docs/features/parallel/<slug>/`. Rejected for complexity and fragility.

## 5. Existing Tests Asserting Files the Recommended Fix Changes

Search scope: `tests/` for `parallel-plan/SKILL`, `parallel-planner.md`, `parallel-plan`, `parallel-planner`, and the asserted fragments in each match.

| Test | What it asserts about the changed files | Disposition |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` | Frontmatter grants and skills; `context: fork`; kickoff markers; "Create each preparation worktree's branch from `origin/main`."; checkpoint, manifest, and kickoff paths; no epic docs scope; forbidden fragments ("integration branch is created", "create the integration branch", "Create the integration branch", "integration_branch:", "epic/<epic-slug>-integration", "depends_on:"); required "explicitly not an integration branch" and "There is no fan-in merge step"; epic-plan and epic-planner content guards | Unchanged. New text must not contain any forbidden fragment and must leave the required sentences intact; the plan-home paragraph must not cite the epic integration-branch command literally |
| `tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py` | Skill contains `conflicts(a, b, config)` and not `conflicts(a, b)`; no `python -m` invocation; `compute_cohorts(item_keys, conflict_edges)` and no case-insensitive "pinned"; derivation, parity, F4 git-integrity, kickoff-contract, and P5 fragments | Unchanged. New text must not contain the word "pinned" in any case, and must keep "**Git integrity is F4-owned.**", "Per-branch git-integrity requirement — F4-owned", and "against each per-item" |
| `tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py` | `## Item Intake` adoption statement; byte-exact kickoff line and exactly one adoption line in `## Preparation Fan-Out` | Unchanged; the fix does not edit `## Preparation Fan-Out` or `## Item Intake` |
| `tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py` | Skill `## Complexity Assessment`, `(P10)` in the **Readiness contract.** paragraph, no `logical_agent`; agent `## Checkpoint Persistence` names `complexity_assessment`, agent `## Completion Requirements` contains `(P10)` and `model_routing_receipt` | Unchanged; the new completion item is appended and must not remove item 2's `(P10)` text |
| `tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py` | Kickoff template inside `## Kickoff Artifact` | Unchanged; section not edited |
| `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` | Script references extracted from skill text, including the `compute-cohorts.sh` bash fence | Unchanged; new git commands are inline code and reference no script |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` | Both files are in `CHECKPOINT_WRITER_SURFACES` reached by the `orchestrator-state` rule `paths:` | Unchanged; paths not renamed |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Every distributable `.claude` file exists in the bundle with equal text | Must pass; updated by editing both bundled copies byte-identically |
| `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` | Bundle files listed in a pack manifest; hook and dependency closure | Unchanged; no file added, no hook named |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | Codex parallel surface paths do not exist | Unchanged; no Codex copy is added |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`PINNED_FROZEN_SURFACE_HASHES`) | Byte hashes of `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` only; `RUN_PROCEDURE_FRAGMENTS` and `NON_PARENT_ACTOR_MARKERS` read other files | Unchanged; neither pinned file is edited |
| Codex generator `--check` (`scripts/dev_tools/generate_codex_agent_variants.py`) | Generated Codex variants and bundle | Unaffected; no Codex parallel agent exists |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate*.Tests.ps1` (six suites) | Gate behavior, including `allows git worktree add` and `denies when no items[] record has a matching worktree_path` | Unchanged. The latter case is the existing proof for the issue's "removal gate behavior for unrecorded planner worktrees" coverage area: an unrecorded worktree denies, and the fix keeps that behavior |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `enforce-epic-invocation-origin.Tests.ps1`, `enforce-parallel-cohort-barrier.Tests.ps1`, `enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1` | Use `parallel-planner` as an agent-type or prompt value, not the file text | Unchanged |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | Agent tool names in the architecture document | Unchanged; `tools:` is not edited |
| `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` | Fixture data naming the planner | Unchanged |

## 6. Policy Files

The recommended fix touches no `.claude/rules/` file, no `.github/instructions/` file, and no `quality-tiers.yml`. Candidate (b) would require a change to `.claude/rules/parallel-orchestration.md`; that is one reason it is rejected.

## Behavior Semantics

- Success: after `/parallel-plan` completes, `git worktree list --porcelain` holds no registration that the planner created. Registrations created during planning are limited to the preparation children's runtime-managed worktrees under `.claude/worktrees/`, which the runtime removes or sweeps.
- The plan-home branch is checked out in the session checkout, carries only `docs/features/parallel/<slug>/**` commits on top of `origin/main`, and is pushed.
- Ordering: the checkout happens after the last preparation child terminates and before the manifest is first written, so no preparation child is spawned while the session checkout is on the plan branch (subagent worktrees branch from the default branch regardless, because `.claude/settings.json` sets no `worktree.baseRef`).
- Failure: a refused `git checkout` stops planning with a report; nothing is stashed, forced, or reset.
- Resume: when `parallel/<slug>-plan` exists locally or on `origin`, the planner checks it out rather than recreating it, consistent with the **Cache doctrine**.
- Edge case: a scratch worktree left by a run planned before the fix is still handled only by Run Closing substep 4 or a manual operator action; the fix does not reclaim existing registrations.

## Numeric Derivation Evidence

No numeric acceptance criterion is proposed for `spec.md`. The two counts used in this research are recorded here so a planner can reuse them.

### Claim N1: the planner surface has four files to change (two canonical, two bundled) and no `.agents`, `.codex`, or `.github` counterpart

- Complete Family: every customization file that carries the `parallel-plan` skill or the `parallel-planner` agent, in every runtime and every bundle.
- Exhaustive Search Scope: the whole worktree, including `extensions/drm-copilot/resources/`.
- Inclusion Rules: a Markdown or TOML customization file whose path names `parallel-plan` (skill folder) or `parallel-planner` (agent file).
- Exclusion Rules: feature documents and evidence under `docs/`, validator sources and tests under `extensions/drm-copilot/src/` and `extensions/drm-copilot/test/`, and the promoted lifecycle record.
- Primary Search Strategy or Query Expression: Glob `**/parallel-plan*/**` and Glob `**/*parallel-planner*`, filtered by the inclusion and exclusion rules.
- Primary Member Set: `.claude/skills/parallel-plan/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`; `.claude/agents/parallel-planner.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md`.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: content Grep for `parallel-plan|parallel-planner` over `.agents/**`, `.codex/**`, `.github/**`, and the Codex and agents bundle roots, combined with the absence assertion in `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` and the one-to-one bundle rule of `test_push_down_claude_resource_contracts.py` applied to the two canonical paths listed in `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` `CHECKPOINT_WRITER_SURFACES`.
- Cross-check Member Set: canonical `.claude/agents/parallel-planner.md` and `.claude/skills/parallel-plan/SKILL.md`, each with exactly one bundled copy under `extensions/drm-copilot/resources/claude-customizations/`; the content Grep matched only `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, a hook reference that is not a counterpart; the five Codex parallel paths are asserted absent.
- Cross-check Count: 4.
- Member-set Comparison: both sets normalize to the same four paths; agreement.

### Claim N2: zero planning-surface instructions create a worktree

- Complete Family: every instruction in the planning surface (the four files of N1) that creates a git worktree.
- Exhaustive Search Scope: `.claude/`, `.agents/`, `.codex/`, `.github/`.
- Inclusion Rules: any `git worktree add` text, or any instruction to create a worktree by hand.
- Exclusion Rules: `isolation: "worktree"` spawn parameters, which the runtime fulfils.
- Primary Search Strategy or Query Expression: Grep `worktree add` over the four runtime roots.
- Primary Member Set: `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_actions_lib.sh` only, which is outside the planning surface; planning-surface members: none.
- Primary Count: 0.
- Cross-check Search Strategy or Query Expression: case-insensitive Grep `worktree` over `.claude/agents/parallel-planner.md` and `.claude/skills/parallel-plan/SKILL.md`, then manual classification of each matching line.
- Cross-check Member Set: the lines enumerated in section 1 (`isolation: "worktree"` spawn, preparation branch base, two "before its worktree is removed" sentences, `worktree_path` fields, `git worktree list --porcelain` resume reads); none creates a worktree.
- Cross-check Count: 0.
- Member-set Comparison: both sets are empty for the planning surface; agreement.

## Testing Implications

- Regression (Phase 2, expect-fail): new `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` with the assertions listed under candidate (a); run with Pytest and confirm the positive assertions fail before the text change.
- Post-fix: the new module plus every test listed in section 5 under `tests/scripts/dev_tools/`, the push-down contract tests, and `scripts/dev_tools/generate_codex_agent_variants.py --check` in module form.
- Coverage: the change edits Markdown only; the new test module reads files and has no production module to measure. Python line and branch thresholds apply to no changed production file.
- No Pester change is required; the gate suites are re-run only as an unchanged-behavior confirmation if the plan chooses to.
- The issue's integration scenario (a live `/parallel-plan` leaving no planner worktree) cannot be unit tested; it is a live-run check recorded as manual verification.

## Pre-Mortem

- Review checklists: a reviewer could flag the change as instruction-only with no mechanical guard, or flag new wording that contradicts the epic precedent. Mitigation: the plan states the rejected hook alternative and its reasons (section 4 (b)), and the new paragraph cites the `epic-plan` `## Integration Branch Lifecycle` precedent and the `parallel-run` kickoff-discovery contract.
- Coverage: not applicable to production coverage, because only Markdown files change and the new file is a test module; the plan records that no Python, TypeScript, or PowerShell production file changes so no per-file coverage artifact is due, and still captures a baseline and final Pytest run as evidence.
- Mirror parity: the two bundled copies under `extensions/drm-copilot/resources/claude-customizations/` must be byte-identical to the canonical files, or `test_push_down_claude_resource_contracts.py` fails. Mitigation: one task edits each canonical file and its copy together and runs that test; no `.agents`, `.codex`, or `.github` copy is created, which `test_push_down_codex_and_agents_customizations.py` requires; the execution-environment brief is not changed because no fact it states changes.
- File size: not applicable as a gate for the edited files, because Markdown is exempt; the new test module stays well under 500 lines.
- Test isolation: the new tests read repository files and create none; the plan runs the new and touched Python modules in reversed order in one process and records it under `evidence/regression-testing/`. No Jest or Pester suite is touched, so the seeded Jest and shuffled Pester runs are recorded as not applicable with that reason.
- CI-only behavior: the new tests must use `Path(__file__).resolve().parents[3]` and forward-slash relative paths and must not read gitignored `artifacts/` state or diff against `origin/main`. Any assertion that compares text must tolerate LF only, because `.gitattributes` normalizes line endings in CI.
- Evidence: the fail-before run of the new contract tests and the post-fix run must be written under `<FEATURE>/evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`; the expect-fail run records `ExpectedExitCode: 1` in its own artifact so it normalizes to pass.

## Automation Feasibility

The fix requires no human interaction to implement or verify at the unit level: it edits four Markdown files and adds one Pytest module, all runnable by the executor through the existing Python toolchain. The only check that needs a live run is the end-to-end scenario (a real `/parallel-plan` invocation leaving no planner worktree), which consumes operator-initiated planning and is recorded as a manual verification note, not a gate. Removing the three registrations left by the original run (if they still exist) is outside the fix; whether they still exist must be confirmed by the orchestrator with `git worktree list --porcelain`.

## Recommendation

Adopt candidate (a). Change `.claude/skills/parallel-plan/SKILL.md` (`## Artifact Home`: plan-home checkout in the session checkout, planner reads by ref, explicit no-worktree paragraph naming the runtime as the remover of preparation worktrees) and `.claude/agents/parallel-planner.md` (`## Delegation Model` sentence, `## Completion Requirements` item 8), copy both byte-identically to their bundled locations, and add `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py`. Leave every hook, rule, validator, and the Run Closing substep unchanged.

Rejected alternatives: (b) planner checkpoint as a gate authorization source, rejected for its multi-hook and rule-file blast radius and for adding an allow with no merge-state predicate; (c) Run Closing removal, rejected because it needs the same allow or a repository-wide apply and cannot cover runs that are planned but not closed; git plumbing commits, rejected for complexity and allowlist mismatch.
