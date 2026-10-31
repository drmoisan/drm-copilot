# Feature Audit: Parallel planner leaves scratch worktrees (#1002)

---

**Audit Date:** 2026-10-31
**Feature Folder:** `docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002`
**Base Branch:** `main`
**Head Branch:** `bug/parallel-planner-leaves-scratch-worktrees-1002`
**Work Mode:** `full-bug`
**Audit Type:** Initial audit

---

## Scope and Baseline

- **Base branch:** `main` (merge base `c7b2850fda58ef2c80624952e582738b76a546f4`)
- **Head branch/commit:** `bug/parallel-planner-leaves-scratch-worktrees-1002` (`589fef537`)
- **Merge base:** `c7b2850fda58ef2c80624952e582738b76a546f4`
- **Evidence sources:**
  - Primary: `git diff c7b2850fd..HEAD` (31 files). `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in this worktree; the diff against the resolved merge base is the authoritative scope.
  - Feature evidence: `docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002/evidence/**`
  - Additional evidence: reviewer runs of the new module (14 passed), ten named contract modules (116 passed), Black, Ruff, Pyright, and the evidence-location validator.
- **Feature folder used:** `docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002`
- **Requirements source:** `spec.md` `## Acceptance Criteria` (authoritative for `full-bug`)
- **Work mode resolution note:** `issue.md` carries the `full-bug` marker; `spec.md` is the only AC source and no `user-story.md` applies.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002/spec.md`: only authoritative source (full-bug); 17 checkbox items, numbered AC-1 to AC-17 in list order

### From spec.md

1. AC-1: The new test module exists and its positive assertions fail before any text change (expect-fail run with a non-zero expected exit code).
2. AC-2: `test_skill_artifact_home_states_planner_runs_no_worktree_add` passes.
3. AC-3: `test_skill_no_planner_worktrees_names_runtime_as_remover` passes.
4. AC-4: `test_skill_artifact_home_contains_plan_home_checkout_command` passes.
5. AC-5: `test_skill_plan_home_checkout_is_ordered_after_preparation_children` passes.
6. AC-6: `test_skill_plan_home_checkout_stops_on_refusal_without_stash_force_or_reset` passes.
7. AC-7: `test_skill_read_access_names_planner_and_git_show` passes.
8. AC-8: `test_every_git_worktree_add_occurrence_is_inside_prohibition_sentence` passes for the skill and the agent.
9. AC-9: `test_agent_delegation_model_points_to_no_worktree_prohibition` passes.
10. AC-10: `test_agent_completion_requirements_new_item_requires_no_worktree_and_pushed_plan_branch` passes; item 2 keeps `(P10)` and `model_routing_receipt`.
11. AC-11: `test_skill_contains_no_pinned_word_and_no_forbidden_fragments` passes.
12. AC-12: `test_edited_sections_exclude_preparation_fan_out_item_intake_and_kickoff_artifact_changes` passes.
13. AC-13: Skill and agent are byte-identical to their bundled copies, verified by `test_push_down_claude_resource_contracts.py`.
14. AC-14: The existing planner surface contract suites pass unchanged.
15. AC-15: The change set contains only the Scope files plus the feature folder.
16. AC-16: The full Python toolchain passes in a single pass for the new module, with the post-fix run recorded.
17. AC-17: The new module reads only repository files relative to the test file, creates no temporary files, reads no gitignored `artifacts/` state, and passes in reversed order.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1: module exists; expect-fail recorded | PASS | `evidence/regression-testing/expect-fail.2026-10-31T12-53.md`: `ExpectedExitCode: 1`, `EXIT_CODE: 1`, 10 failed and 4 passed before the text change (the four passes are regression guards that hold before and after, per the evidence). The module exists at the specified path. | read of the evidence file | Commit order matches: test commit `40cccd749` precedes the text commits `8ebc1b814` and `74dd6cf11`. |
| 2 | AC-2: prohibition fragment in the **No planner worktrees.** paragraph | PASS | Skill `## Artifact Home` paragraph reads "The planner runs no `git worktree add` for any step of planning". | `poetry run python -m pytest tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py` (14 passed) | - |
| 3 | AC-3: runtime named as creator and remover; outside gate records and sweep | PASS | Paragraph states the `isolation: "worktree"` worktrees are created and removed by the runtime, and that a planner-created worktree is "outside every record the removal gates read and outside the runtime sweep". | same run; reviewer read of the diff | - |
| 4 | AC-4: checkout, resume, and push commands | PASS | `git checkout -b parallel/<slug>-plan origin/main`, `git checkout parallel/<slug>-plan`, `git push -u origin parallel/<slug>-plan`, and `git fetch origin main` are all present in **Plan-home checkout.** | same run | - |
| 5 | AC-5: ordering after the last preparation child, before manifest authoring | PASS | Paragraph begins "After the last preparation child has terminated" and names `## Manifest Authoring`; V1/V2 re-plan delegations are counted as preparation children. | same run | - |
| 6 | AC-6: refusal stops planning; no stash, force, or reset | PASS | "If the checkout is refused, stop planning and report the refusal; do not stash, force, or reset." | same run | - |
| 7 | AC-7: Read access names the planner and by-ref commands | PASS | Paragraph lists "the planner itself" and `git fetch origin <branch>` / `git show origin/<branch>:<path>`; states the planner never checks an item branch out. | same run | - |
| 8 | AC-8: every `git worktree add` occurrence is inside the prohibition | PASS | Skill: one occurrence, one prohibition. Agent: two occurrences (Delegation Model and item 8), two prohibitions. `grep -n worktree` shows no creating instruction. | same run (two parametrized cases) | - |
| 9 | AC-9: agent Delegation Model pointer | PASS | `.claude/agents/parallel-planner.md` Delegation Model gains a **No planner worktrees.** paragraph that points to the skill paragraph. | same run | - |
| 10 | AC-10: Completion Requirements item 8 | PASS | Item 8: "The planner created no worktree: it runs no `git worktree add` for any step, and `parallel/<slug>-plan` is checked out in its own session checkout and pushed." Item 2 still carries `(P10)` and `model_routing_receipt`. | same run | - |
| 11 | AC-11: no `pinned`, no forbidden fragments | PASS | Test passes; the forbidden tuple covers the spec's list and adds further fragments. | same run | - |
| 12 | AC-12: untouched sections keep required fragments | PASS | Preparation Fan-Out, Item Intake, and Kickoff Artifact are not in the diff hunks (the diff touches only `## Artifact Home`); test passes. | `git diff c7b2850fd..HEAD -- .claude/skills/parallel-plan/SKILL.md`; same run | - |
| 13 | AC-13: bundled copies byte-identical | PASS | `test_push_down_claude_resource_contracts.py` passes; the new module's byte-identity cases pass; both bundled files appear in the diff with the same line counts. | reviewer pytest run of the ten named modules (116 passed) | - |
| 14 | AC-14: existing suites pass unchanged | PASS | The eight named existing modules pass (116 passed with the new module); none of those test files is in the diff. | `poetry run python -m pytest <ten named modules> -q -p no:cacheprovider` | - |
| 15 | AC-15: change set limited to Scope files plus the feature folder | PASS | `git diff --name-only c7b2850fd HEAD` lists 2 canonical files, 2 bundled copies, 1 test module, and 26 feature-folder files; no rule, instruction, hook, validator, `.agents`/`.codex`/`.github`, `quality-tiers.yml`, or Run Closing path. | `git diff --name-only c7b2850fd HEAD` | Spec text states `origin/main...HEAD`; the merge base is identical for the three-dot form. |
| 16 | AC-16: toolchain single pass; post-fix evidence recorded | PASS | Evidence files `python-black`, `python-ruff`, `python-pyright`, `python-contracts` at 13-01; `post-fix.2026-10-31T13-01.md` with Timestamp, Command, EXIT_CODE, Output Summary. Reviewer re-ran Black, Ruff, Pyright (clean) and pytest (passed). | reviewer runs | - |
| 17 | AC-17: hermetic and order independent | PASS | Reviewer read of the module: no write, temp file, or `artifacts/` read; paths resolve through the shared `REPO_ROOT`. `isolation.2026-10-31T13-01.md` records the reversed-order run (136 passed) and zero token matches. | read of the module; evidence file | - |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 17 criteria (AC-1 to AC-17)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None for the acceptance criteria. The policy audit records a separate mandatory-verification item (Python coverage artifact), which is not an acceptance criterion.

**Recommended follow-up verification steps:**

1. Run a live `/parallel-plan` over two items and confirm `git worktree list --porcelain` shows no planner-created registration afterwards (manual note in the spec, not an acceptance gate).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-parallel-planner-leaves-scratch-worktrees-1002/spec.md`
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 17 | 17 | 0 | All 17 were already checked and each evaluated PASS. No box was unchecked; no source-file change was made in this review. |
