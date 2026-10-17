# COV-1 / AC-24 Decision — Option 1, Accepted Attribution Loss (issue #935)

Timestamp: 2026-10-16T20-38
Supersedes: the option 2 decision in `evidence/other/cov1-decision.2026-10-16T15-56.md` (including its 16-06 amendment) and the `external_dependency` halt recorded after the cycle 3 re-audit (`remediation-inputs.2026-10-16T16-02.md`).

## Decision

Option 1 of the cycle 3 decision options (`evidence/qa-gates/r3-cov-status.2026-10-16T15-15.md`): accept the PowerShell line-coverage attribution loss against AC-24. #935 is decoupled from issue #953 / PR #959.

## Authorizing basis

Directive from the parallel-run coordinator (parallel_slug `bug-burndown-2026-10-15`), received by the #935 item orchestrator on 2026-10-16, replacing the earlier COV-1 directive. Stated basis:

- The loss is a Pester breakpoint-binding attribution artifact, not untested code. Evidence: the claude-lib-only local run credits all 30 affected `WorktreeResolution.psm1` lines (`evidence/other/r3-cov-bisection.2026-10-16T14-13.md`, node N0, 142/144); main's own CI now also credits that file with 112/144; at an equal 18437-line population the PR's remaining gap against main lies in production files the branch does not change (`.claude/lib/orchestrator-state/`, `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`) per `feature-audit.2026-10-16T16-02.md`.
- Local repository-scope line coverage is 94.33% (`evidence/qa-gates/` cycle 3 final repo-scope run: covered 11602, missed 697).
- #953 (Pester profiler mode) is expected to restore the attribution after it merges; the coordinator will verify that then.

## Effect on AC-24

- AC-24's criterion text in `spec.md` is unchanged. An amendment line beneath it records acceptance under this decision, and the checkbox is marked with that qualification. AC-24 is not reported as met as written.
- The PR CI coverage on the final head is still recorded under `evidence/qa-gates/` (plan task P7-T6) for reference, together with the AC-24 floor of 85%.
- No production file is excluded from coverage and no coverage configuration is changed by #935.
- Follow-up (unrelated to #935, owned by #953 / coordinator): verify after #953 merges that profiler mode restores the attribution for `WorktreeResolution.psm1`, `.claude/lib/orchestrator-state/` and `EpicScopeResolution.psm1`.
