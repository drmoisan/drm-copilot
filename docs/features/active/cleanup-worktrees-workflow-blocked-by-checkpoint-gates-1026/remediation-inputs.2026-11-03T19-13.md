# Remediation Inputs — Issue #1026, Cycle 1

Timestamp: 2026-11-03T19-13
Remediation-Mode: proportionate
Source review: policy-audit.2026-11-03T19-05.md, code-review.2026-11-03T19-05.md, feature-audit.2026-11-03T19-05.md (verdict PASS, 0 blocking findings)
Opened by: owner standing rule that related non-blocking review findings are fixed inside the item before merge
Branch: bug/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026
Merge base: 01706c697f3ad4a53b4a771d99d851afc7417ea9 (git merge-base origin/main HEAD)

All findings below are non-blocking in the review and are carried into this cycle as related hardening. Each is `autonomous` and confined to files already in the branch diff plus their tests and bundle mirrors; no spec acceptance criterion and no public interface changes.

## Finding R1-1 (code-review Minor): K6 evaluates local HEAD, not the published remote branch

- Severity: Minor (non-blocking in review; addressed in this cycle)
- Remediability: autonomous
- File: `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`, function `Get-PrAuthorCleanupExemptionFailure` (K6 leg), and its bundle mirror under `extensions/drm-copilot/resources/claude-customizations/`.
- Observed: K6 diffs `origin/main...HEAD` in the resolved consolidation worktree. `gh pr create --head documentationandmemories` publishes the remote branch, which the exemption never compares with the local `HEAD`.
- Required change: the exemption also requires `refs/remotes/origin/documentationandmemories` to resolve to the same commit as the consolidation worktree `HEAD`; when the ref is missing or differs, the exemption does not apply and the existing `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` reason carries a new cleanup sub-code naming that condition. The ref resolution goes through an injectable seam (no live git in unit tests), registered in `EpicStateIsolation.Baseline.Helpers.ps1` and in any suite whose Discovery guard requires a baseline mock for it.
- Tests: `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` gains a deny test for a missing remote ref and for a remote ref at a different commit, each asserting the new sub-code, and the existing allow test supplies an equal remote ref. Every existing test that asserts the allow path or the K-check sub-codes is updated only to supply the equal remote ref.
- Skill text: `.claude/skills/cleanup-merged-worktrees/SKILL.md` step 4 states that the push precedes `gh pr create` and that the PR-author gate requires the pushed remote branch to equal the consolidation worktree HEAD; mirror into the bundle copy.

## Finding R1-2 (code-review Info): cleanup-leg denial in the preimplementation gate has no sub-code

- Severity: Info (addressed in this cycle; the spec permits the sub-code)
- Remediability: autonomous
- Files: `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` (`Test-OrchestrationCleanupContextAllowed`), their bundle mirrors, and the callers that compose the deny reason.
- Observed: a failed cleanup leg is reported only through `Write-Debug`; the operator sees the unchanged `PREIMPLEMENTATION_GATE_BLOCKED` text.
- Required change: when, and only when, the target is the consolidation worktree, append a cleanup sub-code naming the first failed condition to the existing reason. Deny text for every non-consolidation target stays byte-identical (spec `Deny wording`, AC13). Claude and Codex legs stay in parity. The Codex gate stays within its 500-line cap and `enforce-pr-author-skill-helpers.ps1` within 500.
- Tests: the Claude and Codex cleanup suites gain a test asserting the appended sub-code for a consolidation-target denial and keep their exact-string assertions for non-consolidation targets.

## Finding R1-3 (code-review Nit): issue.md Status line omits the -1026 folder suffix

- Severity: Nit
- Remediability: autonomous
- File: `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/issue.md`, `Status:` metadata line.
- Required change: name `docs/features/active/cleanup-worktrees-workflow-blocked-by-checkpoint-gates-1026/`.

## Review items with no change (reason recorded)

- Chained `git add && git commit` denied on an empty pre-add index: the skill already directs separate calls; behavior is fail-closed by design.
- Scratch-write rule applies to every session: spec decision D3.
- Codex cleanup file coverage 90.14%: above the 85% line floor; the lower figure follows from the Codex suite mocking both seams.
- P9-T7 concurrent-shard Pester leg: 89 pre-existing Linux-host fixture failures outside the diff, identical at the merge base; closed by the CI `poshqc / PowerShell QC` shard jobs on `windows-latest` at S9.

## Constraints

- No new Python file; hooks stay PowerShell with no Python leg; no hook bypass.
- Mirror every production change into `extensions/drm-copilot/resources/` and re-run the contract and parity tests named in the execution-environment brief.
- Tests create no temporary files, mock all git and clock seams, and pass serially, in a seeded shuffled file order (three seeds), and in a concurrent-shard run for the touched suites.
- The full PowerShell toolchain loop (format, analyze, Pester with coverage) re-runs and new or changed production files stay at or above 85% line coverage.
- Final task: self-review against the three templates with no FAIL row.
