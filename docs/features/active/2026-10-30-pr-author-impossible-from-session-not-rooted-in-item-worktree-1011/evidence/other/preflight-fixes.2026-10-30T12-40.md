# Preflight Fixes (issue #1011)

Timestamp: 2026-10-30T12-40
Plan: docs/features/active/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree-1011/plan.2026-10-30T08-09.md

All fixes are in task text only. No task was added, removed, or reordered.

## Fix 1 - [P4-T1] stale heading anchor

- Defect class: stale anchor (trivial).
- Finding: the task cites the heading `## Required --head on gh pr create (issue #687)`. The heading in `.claude/agents/pr-author.md` carries code spans around `--head` and `gh pr create`.
- Change: the anchor now reads ``## Required `--head` on `gh pr create` (issue #687)``. The insertion point is unchanged.

## Fix 2 - [P4-T2] stale heading anchor

- Defect class: stale anchor (trivial).
- Finding: the same heading spelling defect, for `.claude/skills/pr-author/SKILL.md`.
- Change: same correction as Fix 1.

## Fix 3 - [P6-T4] evidence location for the full Pester run

- Defect class: evidence filename and location (trivial).
- Finding: spec AC-17 and the execution-environment brief (`## Test Isolation Checks`) require the fresh single-process Pester run over `tests/scripts` to be recorded under `<FEATURE>/evidence/regression-testing/`. The task wrote `FEATURE/evidence/qa-gates/pester-full.<timestamp>.md`.
- Change: the artifact path is now `FEATURE/evidence/regression-testing/pester-full.<timestamp>.md`. The asserted content is unchanged. The coverage-comparison artifact stays under `qa-gates`.

## Fix 4 - [P6-T7] combined file-list acceptance

- Defect class: validator-blind unsatisfiable literal whose correction keeps the assertion's meaning (trivial).
- Finding: the acceptance required `git diff --name-only MERGE_BASE` with `git status --porcelain` to list only the write-set files and evidence under `FEATURE`. The branch also carries the feature-folder documents (`plan.2026-10-30T08-09.md`, whose checkboxes the executor edits, `issue.md`, and `research/research.2026-10-30T12-20.md`) and the staged promoted potential record `docs/features/potential/promoted/2026-10-30-pr-author-impossible-from-session-not-rooted-in-item-worktree.md`. Those files would make the condition fail on every run.
- Change: the permitted list now names those feature-folder documents and the promoted potential record explicitly. The scope assertion over production, test, customization, and bundle files is unchanged.
