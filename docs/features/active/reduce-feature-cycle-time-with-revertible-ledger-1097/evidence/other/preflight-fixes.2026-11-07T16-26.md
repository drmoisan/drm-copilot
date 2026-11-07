# Preflight Fixes — Stage F1 Remediation Plan (Issue 1097)

Timestamp: 2026-11-07T16-26
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T16-16.md

Preflight method: the whole plan was read in one pass against the tree; `origin/main` was fetched and a trial merge (`git merge-tree --write-tree`) of `HEAD` and `origin/main` listed exactly the ten conflicted paths the plan names; the conflict hunks of the trial tree were read for every region.

## Fixes (task text and preamble only; no task added, removed, or reordered)

1. [P1-T1] acceptance — unsatisfiable literal scope. The pre-merge tree already carries seven-character conflict markers in 21 `tests/fixtures/project_file_merge` fixtures and two archived documents, so "a search of the tree returns no match" could not pass. Changed to: no path beyond those already carrying markers at the pre-merge `HEAD`, and no match in any conflicted path or bundle copy. The intent (no unresolved marker from this merge) is unchanged.
2. [P0-T1] Output Summary — citation correction. The five stage E2 baseline sources record repo-wide totals and suite counts but no per-file coverage figure. The task now records the absence with `SearchScope:`, `SearchPatterns:`, and `SearchResult:` lines instead of requiring a copy of a figure that does not exist, and states that the branch's changed production files are PowerShell only.
3. [P2-T2] Pester acceptance — follows fix 2: the no-drop comparison applies wherever the recorded baseline carries the figure; per-file figures are judged against the 85% threshold where it does not. Repo-wide no-drop comparison is unchanged.
4. [P2-T1] changed-file set — the branch's PowerShell modules are `.psm1` files; the extension list now includes `.psm1`, matching the stage E2 format-lint artifact.
5. Region table — the `.github/agents/Powershell DI Unit Test Engineer.agent.md` conflict hunk also contains the adjacent `argument-hint` line, which only this branch changed; a row records that the E2 text is kept there.
