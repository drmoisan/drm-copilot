# parallel-add-and-plan-resume-prepared-items-without-replanning (Issue #1047)

- Date captured: 2026-10-31
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning/ (Issue #1047)

- Issue: #1047
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1047
- Last Updated: 2026-10-31
## Problem / Why

`/parallel-add` and `/parallel-plan` send every item through a preparation-mode child orchestrator (promotion, research, spec, plan, preflight), even when some or all of that work already exists on the item's pushed branch. Re-seeding a run from prepared items, or adding an item whose plan was cleared earlier, repeats finished work and costs hours and quota. A re-seed dry run on 2026-10-30 showed that the validators accept a manifest built from prepared items, but the skill has no documented path for it, no way to state precedence between items, and no durable edges.

Facts established on 2026-10-30 and 2026-10-31:

- In `parallel-add`, only step 2 delegates the preparation child. Steps 3 to 7 (edges, admission decision, recolor, add-entry, validation) need only its output: a declared blast radius and a complexity band.
- The admission engine (`mutate-parallel-run.sh admit`) takes only edges and key lists. It never reads a plan, a spec or a radius.
- The declared radius is derived from the plan text, the spec text and the feature folder, all of which live on the item branch. No preparation receipt is an input.
- Execution does not read the preparation checkpoint; an item admitted by `parallel-add` already runs with no model-routing receipt, no topology receipt, no kickoff row and no plan hash.
- The closed-versus-open check exists only as prose in the skill, not in code. A closed run refused two adds even though the code would have admitted them.
- Nothing verifies a plan hash for the parallel surface; the kickoff contract checks only the format.
- Measured cost of the plan-reconcile step on a stale plan: about 50 minutes for one item (#1010). Items whose cited files were unchanged skipped it with a mechanical check (#1001, #1006, #1002, #1003).
- Every item so far has needed a second orchestrator turn after the PR opened, to run its CI gate and check off CI-dependent acceptance criteria, because the first turn ends when the PR is created.

## Proposed Behavior

All decisions below were made by the owner on 2026-10-30 (Q1 to Q14 of the scoping discussion).

1. **Resumable preparation (Q1, Q12).** "Fully prepared" is a range: research done, spec done, plan written, or preflight cleared. The run checkpoint tracks the stage; `parallel-add` and `parallel-plan` never repeat a completed stage. When any stage is missing, admission delegates the same preparation-mode child with a prompt that names the stage and the existing artifact paths, so it resumes at the first incomplete stage. No second preparation mechanism.
2. **Stage record (Q11).** Each item carries `preparation_status` of `none`, `research`, `spec`, `plan` or `cleared` in the run checkpoint. Preparation also writes a small receipt in the feature folder with the plan hash and the base commit. For items prepared before this feature, the stage is inferred from the files on the branch.
3. **Staleness check on whatever exists (Q2, Q3, Q10).** Admission re-checks the existing artifacts against current `main`. If none of the files the plan cites or writes changed since the recorded base commit, the preflight is skipped (a mechanical file-diff check, no agent). Otherwise it follows the single-pass preflight contract: trivial defects are fixed in place, substantive defects go back for one planner revision, and a stage is discarded and redone only when its premise is falsified (a cited file removed or its contract changed). A second failed round halts with the defect list. Work that never cleared preflight, or only reached research, is checked the same way. An admission does not fail automatically on a finding; it chooses remediation or replan, whichever is faster.
4. **Superseded artifacts (Q13).** An obsolete artifact is superseded by a new timestamped file and kept in the feature folder; nothing is deleted.
5. **Both commands (Q4).** The shared logic is used by `/parallel-add` (into an open run) and by `/parallel-plan` initial intake (to seed a new run from prepared items).
6. **Closed runs stay closed (Q5).** Closed runs still refuse additions. The closed-versus-open check becomes code in the admission helper, with a clear error (Q9), not prose.
7. **Complexity band (Q7).** The band comes from the caller (`--band`), then from the planner checkpoint, and otherwise from a fresh assessment of the plan with a written rationale using the same floor rules as preparation.
8. **Plan hash (Q8).** Admission computes the plan's git blob hash at the branch head, records it on the item, and the execution child checks that it still matches before starting.
9. **Language (Q6).** The helper is PowerShell (bash allowed), reusing existing Python only by calling it. Only an MCP command or extension command is TypeScript.

Related items this design must account for:

- Precedence: a tolerance rule can say "may overlap" but cannot say "A must come after B". A prerequisite gate (for example 1013 after 1006) has no way to be expressed in the scheduler; the re-seed dry run showed that at tolerance 1600 the coloring put the later item before its prerequisite. The design should propose a directed precedence input or have the orchestrator honor each item's Phase 0 gates.
- Durable edges: conflict edges live only in the gitignored checkpoint, so a re-seed from another checkout cannot recover them.
- Orchestrator turn gap: the item orchestrator should finish its CI-dependent step before reporting done, or the parent should treat "PR open, step 9 pending" as not done.

## Acceptance Criteria (early draft)

- [ ] An item with research, spec, a plan or a cleared preflight on its branch is admitted without repeating a completed stage; the run checkpoint records its `preparation_status`.
- [ ] When no file the plan cites or writes changed on `main` since the recorded base, no preflight or replan runs.
- [ ] When cited files changed, only the affected sections are revised, and a stage is discarded only when its premise is falsified.
- [ ] Preparation writes a receipt with the plan hash and base commit, and the execution child verifies the hash before starting.
- [ ] A closed run rejects an add with a clear error from code, not only from prose.
- [ ] `/parallel-plan` can seed a new run from prepared items without preparation children, and the validators accept the result.
- [ ] A directed precedence input (or Phase 0 gate honoring) makes an ordering constraint expressible, and a cohort table that violates it is rejected.
- [ ] Conflict edges are recorded durably so a re-seed from another checkout can recover them.
- [ ] No new Python; the helper is PowerShell or bash; mirrors, bundles and contract tests pass.

## Constraints & Risks

- Edits `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-plan/SKILL.md`, `.claude/rules/parallel-orchestration.md` and the admission helper, which #1012 and #1013 also changed. It starts after those have merged (done by 2026-10-31).
- Must not change gate intent: closed runs stay closed, preflight requirements stay as strict as today, and the at-most-one-return rule stays.
- A tolerated overlap means the later merger rebases and re-runs CI; the design does not remove that cost.
- The isolation guard refuses `pwsh -Command` and similar text in worktree-isolated planners; a PowerShell helper must be callable through a route the guard accepts.

## Test Conditions to Consider

- [x] Unit coverage areas: stage inference from branch files; staleness check with and without overlap; plan hash recording and verification; mechanical closed-run guard; precedence input; durable edge record.
- [x] Integration scenarios: seed a run from prepared items and confirm the cohort table honors a stated precedence; add a half-prepared item and confirm it resumes at the first incomplete stage; add to a closed run and confirm the error.
- [ ] CLI/API examples

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/parallel-add-and-plan-resume-prepared-items-without-replanning/` folder from the template
