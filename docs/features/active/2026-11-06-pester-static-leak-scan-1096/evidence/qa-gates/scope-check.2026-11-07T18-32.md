# QA Gate: Scope, History, Scan-Text, and Evidence Check (Remediation Cycle 2, Phase 2 restart)

Timestamp: 2026-11-07T18-32
Command: sh SCRATCH/issue-1096-c2r-scope.sh (git fetch origin through -C, then pwsh SCRATCH/issue-1096-c2-scope.ps1 -Root <item worktree>: git diff --name-status --no-renames from the merge base of origin/main and HEAD with git status --porcelain as companion; the poshqc-linux-hooks job text against the merge base; the reduction-commit scan-text rule; the host-path and run-citation scan of <FEATURE>/evidence/; git merge-base --is-ancestor origin/main HEAD; the cycle 2 merge-commit and reduction-token rules; exits 1 on any violation)
EXIT_CODE: 0
Output Summary: Every rule passed after the orchestrator's conflict-free merge of origin/main (PR #1113, issue #1105) and the Phase 2 restart. `git merge-base --is-ancestor origin/main HEAD` exits 0 after `git fetch origin`. No added `.py` file and no forbidden path; `poshqc-linux-hooks` job text equal to the merge base; 3 `reduction: 0001` commits on the branch, each with 0 scan-text lines outside the entry and `<FEATURE>/evidence/`; 105 evidence files with no host path and no run citation; both cycle 2 merge commits have 2 parents and no reduction token; 0 cycle 2 commits carry the reduction token. FAILURES=0.

## Scope

- DIFF-ENTRIES=175, PORCELAIN-ENTRIES=0
- No added `.py` file; no path under `.claude/rules/`, `.github/instructions/`, an `atomic-plan-contract` copy, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, ledger entries 0002 to 0006, an Epic #1019 folder, `.github/workflows/ci.yml`, or `pyproject.toml`
- The one `docs/features/` path outside this item's folder is the promoted record `docs/features/potential/promoted/2026-11-06-pester-static-leak-scan.md` (status A)
- `addopts` carries no `-n`
- `poshqc-linux-hooks` job text equal to the merge base: True

## Scan-Text Rule (spec AC-29)

| `reduction: 0001` commit (subject) | Added lines outside the entry | Excluded under `<FEATURE>/evidence/` | Scan-text lines in remaining paths |
|---|---|---|---|
| docs(process-reductions): reconcile entry 0001 with the main merge (reduction: 0001) | 104 | 68 | 0 |
| test(atomic-executor): document the reduction test fakes and correct their fences, reduction: 0001 | 6 | 0 | 0 |
| refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001 | 190 | 0 | 0 |

## Evidence

- 105 files under `<FEATURE>/evidence/` scanned case-insensitively with tokens assembled at run time: 0 host paths, 0 run citations outside the name fields of failure rows.

## History

- `git merge-base --is-ancestor origin/main HEAD`: EXIT 0 (PASS)
- Cycle 2 merge commits (first-parent, after the commit that added this plan): 2 — the P0-T1 merge and the orchestrator's merge of PR #1113; each has 2 parents and no reduction token
- Cycle 2 commits carrying `reduction: 0001`: 0 (P1-T2 changed no fence, so it carried no token; the `reconcile entry 0001` commit above belongs to remediation cycle 1)
- Phase 2 restart: the PR #1113 merge changed the six `execution-environment` brief copies, which are in the branch diff, so P2-T1 to P2-T5 were re-run before this task (artifacts stamped 2026-11-07T18-20 to 2026-11-07T18-31)

## Acceptance Criteria Boxes

Read under `## Acceptance Criteria` of `spec.md` and `user-story.md`, by bullet ordinal:

| AC | spec.md | user-story.md | Evidence |
|---|---|---|---|
| AC-9 | checked | checked | qa-gates/leak-scan.2026-11-07T18-20.md (0 failures) |
| AC-24 | checked | checked | qa-gates/leak-scan.2026-11-07T18-20.md (pre-restart brief check), `test_brief_test_isolation_states_parallel_gates` in qa-gates/pytest-parallel.2026-11-07T18-30.md |
| AC-25 | checked | checked | `test_brief_passages_state_parallel_gate_facts`, `test_brief_ci_section_names_jobs_and_required_contexts`, `test_brief_copies_are_byte_identical` in qa-gates/pytest-parallel.2026-11-07T18-30.md |
| AC-26 | checked | checked | other/ledger-fence-replay.2026-11-07T17-51.md; `PRL-REAL-LEDGER-AGREES` in qa-gates/pester-parallel.2026-11-07T18-26.md |
| AC-28 | checked | checked | `PRL-REAL-LEDGER-AGREES` and `ProcessReductionLedger.Replay.Tests.ps1` in qa-gates/pester-parallel.2026-11-07T18-26.md |
| AC-29 | checked | checked | Scan-text rule above |
| AC-30 | checked | checked | Scope above |
| AC-31 | checked | checked | qa-gates/pester-parallel.2026-11-07T18-26.md, qa-gates/pytest-parallel.2026-11-07T18-30.md |
| AC-32 | checked | checked | qa-gates/jest.2026-11-07T18-30.md |
| AC-34 | checked | checked | qa-gates/coverage-thresholds.2026-11-07T18-31.md |
| AC-35 | checked | checked | qa-gates/coverage-thresholds.2026-11-07T18-31.md (`NEW-FAILURE: NONE`) |
| CI-dependent (2 boxes) | unchecked | unchecked | Pending CI on the PR head; left for the orchestrator |
