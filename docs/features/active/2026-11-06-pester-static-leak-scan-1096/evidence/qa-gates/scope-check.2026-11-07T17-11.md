# QA Gate: Scope, History, and Evidence Check (Remediation Cycle 1)

Timestamp: 2026-11-07T17-11
Command: sh SCRATCH/issue-1096-c1-scope.sh (pwsh SCRATCH/issue-1096-c1-scope.ps1 -Root <item worktree>, after git fetch origin: git diff --name-status --no-renames from the merge base of origin/main and HEAD with git status --porcelain as companion; poshqc-linux-hooks job text against the merge base; reduction-token commits and their added lines outside entry 0001; git merge-base --is-ancestor origin/main HEAD; cycle merge parents; a case-insensitive scan of the feature evidence folder with tokens assembled at run time; exits 1 on any violation)
EXIT_CODE: 1
Output Summary: Two violations. (1) origin/main is not an ancestor of HEAD: origin/main gained two commits after the P0-T2 merge (the 1.1.27 release bump, PR #1111), touching six version files and no file in the branch diff. (2) The P1-T3 reduction commit adds one line outside entry 0001 that holds the scan tokens: the line in its own ledger-fence-replay evidence that states the token check. All other checks pass: no added .py file, no forbidden path, addopts carries no -n, poshqc-linux-hooks unchanged, cycle merge has two parents, exactly one cycle commit carries the reduction token, 70 evidence files with no host path or run citation.

## Scope

- Diff entries from the merge base: 134; porcelain entries: 0.
- No added `.py` file; no path under `.claude/rules/`, `.github/instructions/`, their bundle copies, any `atomic-plan-contract` copy, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.github/workflows/ci.yml`, `pyproject.toml`, or an Epic #1019 folder.
- Other `docs/features/` path: `A docs/features/potential/promoted/2026-11-06-pester-static-leak-scan.md` (this item's promotion record).
- `addopts` carries no `-n` flag.
- `poshqc-linux-hooks` job text equals the merge base: True.

## History

- `git merge-base --is-ancestor origin/main HEAD`: exit 1. FAIL.
  - Commits on origin/main and not in HEAD: `Merge pull request #1111 from drmoisan/release/full-20261107162050`, `release: bump extension to 1.1.27 and mcp-server to 1.1.27`.
  - Paths they change relative to the merge base: `.codex/config.toml`, `extensions/drm-copilot/package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`, `packages/mcp-server/package-lock.json`, `packages/mcp-server/package.json`. None of these paths is in the branch diff; a trial `git merge-tree --write-tree` of HEAD and origin/main reports no conflict.
- Cycle merge commit `Merge origin/main into feature/pester-static-leak-scan-1096`: 2 parents. PASS.
- Reduction-token commits of this cycle (first-parent, after the cycle merge): 1. PASS.
- Reduction-token commits of the branch and lines each adds outside the entry that hold the scan tokens:
  - `docs(process-reductions): reconcile entry 0001 with the main merge (reduction: 0001)`: 104 added lines outside the entry, 1 holding the tokens. FAIL. The line is in `evidence/other/ledger-fence-replay.2026-11-07T16-35.md`, the evidence that P1-T3 wrote in the same commit, and it is the sentence that reports the token check itself.
  - `test(atomic-executor): document the reduction test fakes and correct their fences, reduction: 0001`: 6 added lines, 0 holding the tokens. PASS.
  - `refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001`: 190 added lines, 0 holding the tokens. PASS.

## Evidence

- Evidence files scanned: 70. Host-path findings: 0. Run-citation findings outside failure-row name fields: 0.

## Acceptance Criteria Boxes

The `spec.md` and `user-story.md` boxes for AC-26, AC-28, AC-30, AC-34, and AC-35 were left as they stand (checked): their own evidence (`ledger-fence-replay`, `PRL-REAL-LEDGER-AGREES`, the scope section above, and `coverage-thresholds.2026-11-07T17-09.md`) passes. Both `CI-dependent:` boxes in each file remain unchecked.

## Disposition

Task P3-T6 is left unchecked and execution stops for the orchestrator. Closing violation (1) requires a further merge of origin/main, and closing violation (2) requires a decision on the check, because the P1-T3 commit is pushed and cannot be rewritten; neither is a task of this plan.
