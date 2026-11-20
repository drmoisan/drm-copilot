# QA Gate: Scope, History, and Evidence Check (Remediation Cycle 1, revised P3-T6)

Timestamp: 2026-11-07T17-17
Command: sh SCRATCH/issue-1096-c1-scope.sh (git fetch origin, then pwsh SCRATCH/issue-1096-c1-scope.ps1 -Root <item worktree>: git diff --name-status --no-renames from the merge base of origin/main and HEAD with git status --porcelain as companion; poshqc-linux-hooks job text against the merge base; reduction-token commits and their added lines outside entry 0001 and outside the feature evidence folder, matched case-insensitively; git merge-base --is-ancestor origin/main HEAD; parents and subjects of every cycle merge commit; reduction-token count of the cycle; a case-insensitive scan of the feature evidence folder with tokens assembled at run time; exits 1 on any violation)
EXIT_CODE: 0
Output Summary: All checks pass, 0 violations. origin/main is an ancestor of HEAD after the fetch; both cycle merge commits have two parents and neither carries the reduction token; exactly one cycle commit carries it; each of the 3 reduction-token commits of the branch adds 0 scan-text lines outside entry 0001 and the feature evidence folder; no added .py file, no forbidden path, poshqc-linux-hooks unchanged; 71 evidence files with no host path or run citation.

## Scope

- Diff entries from the merge base: 135; porcelain entries: 0.
- No added `.py` file; no path under `.claude/rules/`, `.github/instructions/`, their bundle copies, any `atomic-plan-contract` copy, `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.github/workflows/ci.yml`, `pyproject.toml`, or an Epic #1019 folder.
- Other `docs/features/` path: `A docs/features/potential/promoted/2026-11-06-pester-static-leak-scan.md` (this item's promotion record).
- `addopts` carries no `-n` flag.
- `poshqc-linux-hooks` job text equals the merge base: True.
- Baseline ordering (AC-34): the commit adding the baseline gate records precedes the first commit that changes a path outside `docs/features/` (index 11 before index 12).

## History

- `git fetch origin`, then `git merge-base --is-ancestor origin/main HEAD`: exit 0. PASS.
- Cycle merge commits (first-parent, after the commit that adds this remediation plan): 2.
  - `Merge origin/main into feature/pester-static-leak-scan-1096` (P0-T2): 2 parents, no reduction token. PASS.
  - `Merge origin/main into feature/pester-static-leak-scan-1096` (orchestrator merge of the 1.1.27 release): 2 parents, no reduction token. PASS. It changes `.codex/config.toml`, the two `package.json` and two `package-lock.json` files of the extension and the MCP server, and the bundled `.codex/config.toml`; none of these paths is in the branch diff, so the Phase 3 loop does not restart.
- Reduction-token commits of this cycle: 1. PASS.

## Scan-Text Rule (AC-29)

Per reduction-token commit of the branch, by subject:

| Commit subject | Added lines outside the entry | Excluded under `<FEATURE>/evidence/` | Lines holding the tokens in the remaining paths | Result |
|---|---|---|---|---|
| `docs(process-reductions): reconcile entry 0001 with the main merge (reduction: 0001)` | 104 | 68 | 0 | PASS |
| `test(atomic-executor): document the reduction test fakes and correct their fences, reduction: 0001` | 6 | 0 | 0 | PASS |
| `refactor(qc): move the deferred serial test commands to the parallel gates, reduction: 0001` | 190 | 0 | 0 | PASS |

The one token-bearing line that the previous run reported lies in the `ledger-fence-replay` evidence of the first commit and is among the excluded evidence lines.

## Evidence

- Evidence files scanned: 71. Host-path findings: 0. Run-citation findings outside failure-row name fields: 0.

## Acceptance Criteria Boxes

The `spec.md` and `user-story.md` boxes for AC-26, AC-28, AC-29, AC-30, AC-34, and AC-35 stay checked: AC-26 and AC-28 by `ledger-fence-replay` and `PRL-REAL-LEDGER-AGREES`, AC-29 by the scan-text table above, AC-30 by the scope section above, and AC-34 and AC-35 by the baseline ordering above and `coverage-thresholds.2026-11-07T17-09.md`. Both `CI-dependent:` boxes in each file remain unchecked.
