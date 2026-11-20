# Feature Audit: orchestrator-stop-hook-validates-wrong-worktree-checkpoint (issue #1145)

## Scope and Baseline

- Branch: `bug/orchestrator-stop-hook-target-worktree`; head `ee88894af970ed6c6455aac6df826fed2872a553`.
- Base: merge base of `origin/main` and `HEAD`, `70e66be7566f4c7259acce97449c769f7ff3854a`; the full branch diff (39 files) was audited.
- Work mode: `full-bug` (marker `- Work Mode: full-bug` in `issue.md`); AC source: `spec.md` `## Acceptance Criteria` (9 items).
- Baseline behavior: for the `orchestrator-state` kind, `Resolve-OrchestratorOutputCheckpointPath` resolved the session worktree from the hook cwd and never read the delegation prompt, so the hook validated the checkpoint of the session or isolation worktree rather than the item worktree.
- Evidence sources: `artifacts/pr_context.summary.txt`, the feature folder `evidence/` tree, `artifacts/pester/powershell-coverage.xml`, and reviewer probes (mutant probe on a `git archive` copy, parity checks, resolver path trace).

## Acceptance Criteria Inventory

| ID | Criterion (abridged) |
|---|---|
| AC-1 | Hook resolves the item worktree through `Resolve-SubagentStopTargetWorktree` from the delegation prompt and validates that worktree's checkpoint; routing-contract, runbook, and feature-folder checks use the same root. |
| AC-2 | Hook-level Pester tests fail before and pass after: session invalid and item valid allows; session valid and item invalid blocks; fail-before evidence recorded. |
| AC-3 | With no identifiable target, falls back to the session worktree and says so (block message and stderr on allow). |
| AC-4 | NoTarget or Ambiguous blocks with `ORCHESTRATOR_CHECKPOINT_UNRESOLVED` and reads no checkpoint. |
| AC-5 | Gate intent unchanged: existing tests pass unchanged; epic and parallel kinds behave as before. |
| AC-6 | New logic in a separate dot-sourced sibling, minimal main edit, bundle mirror and pack manifest updated, push-down contract tests pass. |
| AC-7 | Orchestrate skill and the brief `## Hook Execution Context` updated in all copies; six brief copies byte-identical. |
| AC-8 | No new Python; new file line coverage >= 90%; no per-file drop; parallel Pester gate and `pytest -n auto` green. |
| AC-9 | No absolute paths in committed artifacts. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC-1 | PASS | `Resolve-OrchestratorOutputItemTarget` calls `Resolve-SubagentStopTargetWorktree` with the parsed envelope; the resolution sibling routes the item kind through `Resolve-OrchestratorOutputItemOperandTarget`. H1 asserts only the item path is read and routed; H7 covers the issue-line-only prompt; H12 asserts the feature-folder probe and runbook check run beneath the item root. |
| AC-2 | PASS | H1 (allow, item path only) and H2 (block naming the item path, session path never read). Fail-before: `evidence/regression-testing/fail-before.2026-11-08T22-05.md` (16 failures, all in the new suite). Pass-after: `evidence/regression-testing/pass-after.2026-11-08T22-44.md`. Reviewer mutant probe: H1 and H2 fail behaviorally when the call site is disabled. |
| AC-3 | PASS | H3 (no transcript: block carries `ORCHESTRATOR_CHECKPOINT_FALLBACK:`; allow carries the note), H4 (no identity), H8 (resolver exception with detail), H13 (entry script exits 0 and writes the note to stderr). |
| AC-4 | PASS | H5 (branch in no worktree; issue recorded by no worktree) and H6 (two issue lines; branch in two worktrees) assert the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED: orchestrator-state: NoTarget/Ambiguous` text with zero checkpoint reads and zero routing calls. Reviewer trace of `Resolve-HookTargetWorktree` confirmed every identity-bearing path returns a root or one of the two reason codes. |
| AC-5 | PASS | No existing `validate-orchestrator-output*.Tests.ps1` file is modified; 292 rows across those suites pass. H10 asserts no transcript read for `epic-orchestrator-state` and `parallel-orchestrator-state`; epic and parallel branches of the resolution sibling are untouched in the diff. |
| AC-6 | PASS | New sibling `.claude/hooks/validate-orchestrator-output-target.ps1`; main hook diff 27 lines. Reviewer `cmp` confirmed byte-identical bundle copies of the three hooks; `core.json` lists the new sibling; push-down contract and dependency-closure tests pass (`pytest-parallel.2026-11-08T22-49.md`). |
| AC-7 | PASS | Orchestrate skill step 7 added (root and bundle copies identical). Reviewer `md5sum` of the six brief copies returned one hash, `23bc16fc9cf3b43b4e4e6a4534e11383`; `test_brief_copies_are_byte_identical` passes. |
| AC-8 | PASS | No `.py` file in the diff. New file 100% (38/38) line coverage, re-parsed by the reviewer from `artifacts/pester/powershell-coverage.xml`; main hook 99.19% to 99.30%; resolution sibling 98.94% to 98.95%; repo-wide 95.67% to 95.71%. Pester parallel gate exit 0 (20872 testcases, 0 failed); `pytest -n auto` exit 0 (16590 passed). |
| AC-9 | PASS | Reviewer scan of added diff lines for drive-letter roots, user-profile paths, and scratchpad paths found only the regex text inside the scope-check evidence; tests use `/synthetic-worktrees/...` roots. |

## Summary

All 9 acceptance criteria are PASS. The fix resolves the item worktree from the delegation prompt, blocks before any read when the identity names no worktree or more than one, falls back to the session worktree only without a usable identity (announced by a note), and leaves the epic and parallel kinds unchanged. Coverage rose for every touched file. Remote CI is pending because no pull request exists yet; no acceptance criterion depends on CI. No blocking finding; verdict PASS. Non-blocking observations are recorded in `code-review.2026-11-08T23-06.md`.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-08-orchestrator-stop-hook-validates-wrong-worktree-checkpoint-1145/spec.md`
- Total AC items: 9
- Checked off (delivered): 9
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

All nine items were already checked `[x]` by the executor in commit `cbc691f29` (P4-T7). The reviewer evaluated each as PASS above, so no checkbox was changed and no item was reverted.
