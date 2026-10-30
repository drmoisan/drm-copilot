# 2026-10-30-parallel-planner-leaves-scratch-worktrees (Spec)

- **Issue:** #1002
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T11-05
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Research:** `research/research.2026-10-30T11-05.md` (adopted Recommendation: candidate (a))

## Problem Statement

A `/parallel-plan` run over two items left three planner-created scratch worktrees (`wt989`, `wt990`, `wtplan`) registered after the run closed. The worktree-removal gates deny their removal with `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. The only route that removes them is the repository-wide `cleanup-merged-worktrees` apply mode, which operates on every worktree and is risky to run for this purpose.

Impact / Severity: Low.

Environment: Windows 11, PowerShell 7; `/parallel-plan` followed by `/parallel-run` for #989 and #990; run `pr-author-and-file-size`.

## Root Cause

As stated in the research:

- No file in the planning surface instructs the planner to run `git worktree add`. The issue's suspected cause (preparation delegations create unrecorded worktrees) is not supported: preparation children use `isolation: "worktree"`, and the Claude Code runtime creates and removes those worktrees.
- The scratch worktrees are improvised by the planner because `.claude/skills/parallel-plan/SKILL.md` requires two things without giving a worktree-free technique: committing to `parallel/<slug>-plan`, which is not checked out in the planner's session checkout, and reading each item's plan and `spec.md` text, which exist only on the pushed item branches.
- Likely attribution (inferred from the observed `HEAD`s recorded in the #995 research and from the skill text; the planner transcript was not available): `wtplan` was used to commit the manifest and kickoff to `parallel/<slug>-plan`; `wt989` and `wt990` were used to read the item branches' files.
- The removal gates authorize removal only from a parallel-orchestrator `items[]` record or an epic `features[]` record with `merge_status` in `{merged, worktree_removed}`, or from a fresh cleanup manifest. They never read the planner checkpoint, so a planner-created worktree always denies. This is existing, intended gate behavior and is not changed.
- Run Closing substep 4 (added by #995) handles scratch worktrees only conditionally through `cleanup-merged-worktrees`, and #995 decision D5 forbids a hook allow for them.

## Scope

In scope: a text-only change to the planner surface so that the planner creates no worktree. The planner authors `parallel/<slug>-plan` in its own session checkout, reads item text by ref, and is told explicitly that it creates no worktree.

Exact file set:

| File | Change |
| --- | --- |
| `.claude/skills/parallel-plan/SKILL.md` | `## Artifact Home`: plan-home checkout paragraph, extended **Read access**, and a **No planner worktrees.** paragraph |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md` | byte-identical bundled copy |
| `.claude/agents/parallel-planner.md` | `## Delegation Model` pointer sentence; new `## Completion Requirements` item 8; `tools:` unchanged |
| `extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md` | byte-identical bundled copy |
| `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` | new contract test module |

## Out of Scope

- No hook change (including `enforce-parallel-worktree-removal-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, their resolution libraries, and `.claude/settings.json`).
- No `.claude/rules/` file, no `.github/instructions/` file, and no `quality-tiers.yml` is edited.
- No planner-state validator change (`scripts/dev_tools/validate_parallel_planner_state.py`, `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts`).
- No `.agents`, `.codex`, or `.github` file change; the Codex runtime has no parallel surface and none is added.
- No change to Run Closing in `.claude/skills/parallel-orchestrate/SKILL.md`; substep 4 remains useful for runs planned before the fix.
- Existing leftover scratch registrations are not reclaimed by this change.
- No pack manifest change; no file is added to the bundle.
- A mechanical guard against `git worktree add` (a new hook) is rejected; the prohibition is instruction-level, protected from regression by contract tests.

## Required Behavior

1. Plan-home branch in the session checkout. After the last preparation child (including any V1/V2 re-plan delegation) has terminated and before `## Manifest Authoring`, the planner runs `git fetch origin main` and `git checkout -b parallel/<slug>-plan origin/main`. When the branch already exists (resume), the planner runs `git checkout parallel/<slug>-plan` instead of recreating it. On a refused checkout the planner stops and reports; it does not stash, force, or reset. The run folder is written in place, committed through the existing integration commit forms, and pushed with `git push -u origin parallel/<slug>-plan`. The checkout remains on that branch.
2. Reads by ref. The planner is a named reader in **Read access**. It reads each item's approved plan and `spec.md` text and performs the git-integrity check with `git fetch origin <branch>` and `git show origin/<branch>:<path>` (and `git cat-file -e`), never by checking the item branch out.
3. No planner worktrees. A **No planner worktrees.** paragraph states that the planner runs no `git worktree add` for any step; that the only worktrees created during planning are the preparation children's `isolation: "worktree"` worktrees; that the Claude Code runtime creates those and removes them (immediately when a child leaves no changes, otherwise by its periodic sweep once commits are pushed and the tree is clean); and that a planner-created worktree is outside every record the removal gates read and outside the runtime sweep.
4. Agent surface. `.claude/agents/parallel-planner.md` `## Delegation Model` gains a sentence pointing to the prohibition, and `## Completion Requirements` gains item 8: the planner created no worktree (it ran no `git worktree add`), and `parallel/<slug>-plan` is checked out in its own session checkout and pushed.

Success semantics: after `/parallel-plan` completes, `git worktree list --porcelain` holds no registration the planner created. The plan-home branch carries only `docs/features/parallel/<slug>/**` commits on top of `origin/main` and is pushed.

## Wording Constraints

The new text must respect existing contract tests:

- The word "pinned" must not appear in any case in the skill.
- None of these fragments may appear: "integration branch is created", "create the integration branch", "Create the integration branch", "epic/<epic-slug>-integration", "integration_branch:", "depends_on:" (asserted absent by `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`).
- Required sentences stay intact, including "explicitly not an integration branch", "There is no fan-in merge step", "**Git integrity is F4-owned.**", "Per-branch git-integrity requirement — F4-owned", "against each per-item", "Create each preparation worktree's branch from `origin/main`.", and the `(P10)` text of `## Completion Requirements` item 2.
- `## Preparation Fan-Out`, `## Item Intake`, and `## Kickoff Artifact` are not edited.
- New git commands are inline code and reference no script, so `test_skill_bundle_contract_repo.py` is unaffected.

## Risks and Mitigations

- Switching the session checkout to the plan branch exposes `origin/main`'s copies of files (including `.claude/hooks/`) for the rest of the session; the `epic-plan` `## Integration Branch Lifecycle` precedent has the same property. Mitigation: perform the checkout only after the last preparation child terminates, and stop on a refused checkout rather than forcing.
- Uncommitted operator changes may carry across `git checkout -b`. Mitigation: the existing pathspec-bearing commit forms prevent committing them to the plan branch.
- The prohibition is instruction-level because `Bash(git *)` still admits `git worktree add`. Mitigation: contract tests prevent the instruction from regressing; they cannot prevent a model from disobeying it.
- New tests must be CI-stable: resolve the repository root from the test file location, use forward-slash relative paths, tolerate LF-only text, and read no gitignored `artifacts/` state.

## Test Strategy

- New module `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` using the text-fragment convention of `test_parallel_planner_surface_contracts.py`.
- Regression run (expect-fail) of the new module before the text change, recorded under `evidence/regression-testing/` with `ExpectedExitCode: 1`; post-fix run recorded in the same folder.
- Existing suites that must keep passing: `test_parallel_planner_surface_contracts.py`, `test_parallel_planner_surface_contracts_landed.py`, `test_parallel_issue_adoption_skill_contracts.py`, `test_parallel_complexity_routing_contracts.py`, `test_parallel_kickoff_template_seam.py`, `test_skill_bundle_contract_repo.py`, `test_claude_rules_frontmatter.py`, `test_push_down_claude_resource_contracts.py`, and `test_push_down_codex_and_agents_customizations.py`.
- No Pester change is required. The existing `denies when no items[] record has a matching worktree_path` case continues to cover gate behavior for unrecorded worktrees.
- Coverage: only Markdown and a test module change; no production module is added or modified, so no production coverage threshold is affected.
- Manual verification note (not an acceptance gate): run a live `/parallel-plan` over two items and confirm `git worktree list --porcelain` shows no planner-created registration after planning.

## Acceptance Criteria

- [ ] `tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` exists and, before any text change to the planner-surface files, its positive assertions fail (expect-fail regression run recorded under `evidence/regression-testing/` with a non-zero expected exit code).
- [ ] Test `test_skill_artifact_home_states_planner_runs_no_worktree_add` passes: `## Artifact Home` in `.claude/skills/parallel-plan/SKILL.md` contains the prohibition fragment "runs no `git worktree add`" within a paragraph headed **No planner worktrees.**.
- [ ] Test `test_skill_no_planner_worktrees_names_runtime_as_remover` passes: the **No planner worktrees.** paragraph states that the preparation children's `isolation: "worktree"` worktrees are created and removed by the Claude Code runtime, and that a planner-created worktree is outside the removal-gate records and the runtime sweep.
- [ ] Test `test_skill_artifact_home_contains_plan_home_checkout_command` passes: `## Artifact Home` contains `git checkout -b parallel/<slug>-plan origin/main`, the resume form `git checkout parallel/<slug>-plan`, and `git push -u origin parallel/<slug>-plan`.
- [ ] Test `test_skill_plan_home_checkout_is_ordered_after_preparation_children` passes: the plan-home paragraph states the checkout occurs after the last preparation child terminates and before manifest authoring.
- [ ] Test `test_skill_plan_home_checkout_stops_on_refusal_without_stash_force_or_reset` passes: the plan-home paragraph states that a refused checkout stops planning and that no stash, force, or reset is used.
- [ ] Test `test_skill_read_access_names_planner_and_git_show` passes: the **Read access** paragraph names the planner as a reader and contains `git fetch origin <branch>` and `git show origin/<branch>:<path>`.
- [ ] Test `test_every_git_worktree_add_occurrence_is_inside_prohibition_sentence` passes for both `.claude/skills/parallel-plan/SKILL.md` and `.claude/agents/parallel-planner.md`: the count of `git worktree add` occurrences equals the count of occurrences of the exact prohibition fragment, so no creating instruction exists.
- [ ] Test `test_agent_delegation_model_points_to_no_worktree_prohibition` passes: `.claude/agents/parallel-planner.md` `## Delegation Model` contains the pointer sentence to the **No planner worktrees.** paragraph.
- [ ] Test `test_agent_completion_requirements_new_item_requires_no_worktree_and_pushed_plan_branch` passes: `## Completion Requirements` contains a new final item stating the planner created no worktree and `parallel/<slug>-plan` is checked out in its own session checkout and pushed, and the existing readiness item still contains `(P10)` and `model_routing_receipt`.
- [ ] Test `test_skill_contains_no_pinned_word_and_no_forbidden_fragments` passes: the skill contains no case-insensitive "pinned" and none of the forbidden fragments listed under Wording Constraints.
- [ ] Test `test_edited_sections_exclude_preparation_fan_out_item_intake_and_kickoff_artifact_changes` passes: the `## Preparation Fan-Out`, `## Item Intake`, and `## Kickoff Artifact` sections each retain their required existing fragments (kickoff line, adoption statement, kickoff template markers).
- [ ] `.claude/skills/parallel-plan/SKILL.md` and `.claude/agents/parallel-planner.md` are byte-identical to their bundled copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`, verified by a passing run of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.
- [ ] The existing planner surface contract suites pass unchanged: `test_parallel_planner_surface_contracts.py`, `test_parallel_planner_surface_contracts_landed.py`, `test_parallel_issue_adoption_skill_contracts.py`, `test_parallel_complexity_routing_contracts.py`, `test_parallel_kickoff_template_seam.py`, `test_skill_bundle_contract_repo.py`, `test_claude_rules_frontmatter.py`, and `test_push_down_codex_and_agents_customizations.py`.
- [ ] The change set contains only the files listed under Scope and edits no `.claude/rules/` file, no `.github/instructions/` file, no `quality-tiers.yml`, no hook, no planner-state validator, no `.agents`/`.codex`/`.github` file, and not the Run Closing section of `.claude/skills/parallel-orchestrate/SKILL.md`, verified by `git diff --name-only origin/main...HEAD` limited to those files plus the feature folder under `docs/features/active/`.
- [ ] The full Python toolchain (format, lint, type-check, test) passes in a single pass for the new test module, with the post-fix Pytest run recorded under `evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.
- [ ] The new test module reads only repository files located relative to the test file, creates no temporary files, reads no gitignored `artifacts/` state, and passes when the new and touched Python test modules are run in reversed order in one process.

## Rollout and Follow-up

- Rollout: merge the change; no migration is required. New planning runs create no planner worktree.
- Follow-up: scratch registrations left by runs planned before the fix are handled by Run Closing substep 4 or manual operator action; this change does not reclaim them.
- Links: issue #1002; related fix #995.
