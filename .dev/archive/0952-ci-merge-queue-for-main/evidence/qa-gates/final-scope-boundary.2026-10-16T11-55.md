# Final Scope Boundary (P8-T13) — FAIL, halted for the caller

Timestamp: 2026-10-16T11-55
Command: git fetch origin; git diff --name-only origin/main...HEAD; git status --porcelain; git diff --quiet f1445b472dfa36e56f1e379b38244cd8da9b525e HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/issue.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/research/research.2026-10-16T01-30.md docs/features/active/2026-10-16-ci-merge-queue-for-main-952/ruleset/protect-main.current.2026-10-16.json; git diff -U0 f1445b472dfa36e56f1e379b38244cd8da9b525e HEAD -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/plan.2026-10-16T00-15.md
EXIT_CODE: 1
Output Summary: SCOPE_BOUNDARY=FAIL. The paths outside the feature folder number 48: the 47 planned paths plus one additional path, docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md. Every other condition holds: PY_PATHS=4, PY_PRODUCTION_FILES=0, the unchanged-inputs check exits 0, and PLAN_NONCHECKBOX_CHANGES=0.

PLAN_BASE_SHA=f1445b472dfa36e56f1e379b38244cd8da9b525e (from P0-T2). No `evidence/other/plan-revision.*.md` artifact exists (search of evidence/other for `plan-revision` returned none), so the plan diff uses PLAN_BASE_SHA.
HEAD at the time of the check: 79784c0fc263e66dbcd40d19345c25a05671de51. origin/main after fetch: 5bdf22d0f4300d2ee3a0f7e88b21fbeb69fb2dea (merge-base unchanged at 04f594f2ad2b891cbd8d1388a2e7fe2c67044d28).

## Command results

1. `git fetch origin`: EXIT_CODE 0.
2. `git diff --name-only origin/main...HEAD`: EXIT_CODE 0. It lists 48 paths outside `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/`. They are the 14 created and 33 modified paths of `## Files Written`, all present, plus:
   - `docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md` (NOT in `## Files Written`)
3. `git status --porcelain`: EXIT_CODE 0. It lists only untracked Phase 8 evidence files under `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/evidence/qa-gates/` (inside the feature folder). No path outside the feature folder appears.
4. `git diff --quiet <PLAN_BASE_SHA> HEAD -- issue.md research/research.2026-10-16T01-30.md ruleset/protect-main.current.2026-10-16.json`: EXIT_CODE 0 (all three are byte-unchanged).
5. `git diff -U0 <PLAN_BASE_SHA> HEAD -- plan.2026-10-16T00-15.md`: 115 removed lines and 115 added lines. Every removed line begins `- [ ] [P`, and each paired added line is identical except that `[ ]` became `[x]` (P0: 18, P1: 7, P2: 8, P3: 21, P4: 9, P5: 11, P6: 34, P7: 7). PLAN_NONCHECKBOX_CHANGES=0.

## Condition checks

| Condition | Result |
|---|---|
| Union of name-only diff and porcelain paths outside the feature folder equals exactly the 47 planned paths | FAIL: 48 paths; the additional path is docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md |
| `.github/workflows/_poshqc.yml` and every `.github/workflows/*.yml` other than `ci.yml` absent | PASS (only `.github/workflows/ci.yml` and `.github/workflows/README.md` listed) |
| No path under `.claude/rules/` or `.github/instructions/` | PASS |
| `.claude/hooks/hook-command-invocation.ps1` and `.codex/hooks/hook-command-invocation.ps1` absent | PASS |
| `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1` absent | PASS |
| `.py` paths are exactly the four test paths (PY_PATHS=4, PY_PRODUCTION_FILES=0) | PASS: tests/scripts/dev_tools/merge_queue_documentation_expectations.py, tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py, tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py, tests/scripts/dev_tools/test_epic_orchestrator_permission_contracts.py |
| Unchanged inputs (`git diff --quiet` exits 0) | PASS |
| Plan diff is checkbox transitions only | PASS (PLAN_NONCHECKBOX_CHANGES=0) |

## Additional path record (per P8-T13: recorded, not reverted or deleted)

Command: git log --oneline origin/main..HEAD -- docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md
Output (verbatim): `bf7b5c694 docs(952): create active feature folder for ci-merge-queue-for-main`

Command: git diff --name-status f1445b472dfa36e56f1e379b38244cd8da9b525e HEAD -- docs/features/potential/promoted/2026-10-16-ci-merge-queue-for-main.md
Output: (empty, EXIT_CODE 0). The file is unchanged since PLAN_BASE_SHA. No executor task wrote it.

Analysis: the file is the promoted lifecycle record of the issue. Commit bf7b5c694 created it during feature-folder creation, before execution began and before PLAN_BASE_SHA. Because the branch adds it relative to the merge-base, the three-dot name-only diff lists it. The plan's 47-path set in `## Files Written` does not include it, so the exact-equality condition cannot hold for this branch as created. No executor action produced the difference.

Disposition: per the P8-T13 task text, the task fails, the path is recorded with `git log --oneline origin/main..HEAD -- <path>`, and execution halts for the caller. The path is not reverted or deleted. The caller resolves the item, for example with a planner delta that adds this pre-existing lifecycle record to the excluded or expected set of P8-T13, and resumes at P8-T13.
