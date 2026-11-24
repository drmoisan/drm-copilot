# Task check: P4-T1

Timestamp: 2026-11-24T11-22
Command: see the command list below (each run from the item worktree root)
EXIT_CODE: 0
Output Summary: ledger entry .dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md is complete; Set L passed (89 tests, 0 failures); every block reverts to the merge-base bytes (65 blocks over 28 files); every path of Phases 1 to 3 is listed in `## Files Changed`; every edited non-identical source and every `.claude` copy of an edited byte-identical family has a block.

Content checks:
- `## Summary`: `reduction: 0014`, `Date: 2026-11-24`, `Issue: #1233`, and `Merge commit: pending (PR #1233)`, the canonical issue number as a stand-in, as entries 0004 and 0005 did.
- `## Reason and Evidence`: the owner directive of 2026-11-23, the integration pull request backstop (merge-gate branch 2 unchanged), the residual automatic `CI` run on child pull requests because ci.yml triggers on `epic/**` (decision D1), and the self-declared-key disclosure (policy-level control, decision D10) with its live-base (`baseRefName`), concurrent-review, and evidence-file bounds.
- `## Files Changed` against `git diff --name-only <merge base>...HEAD` together with `git status --porcelain` (SCRATCH/issue-1233-ledger-files-check.sh): 78 paths outside the feature folder; 77 are listed (the 17 corpus files through the `tests/fixtures/orchestrator_state_child_ci/` entry). The remaining path, `.dev/potential/promoted/2026-11-23-epic-child-ci-opt-out.md`, is the feature-promotion record committed before Phase 1, not a file of the reduction, and is not listed.
- `## Prior Text`: 28 block paths — the child-CI helper, both merge gates, the completion helpers, both completion-consistency hooks, the PowerShell module, the Python validator, orchestrator-state-core.ts, jest.config.cjs, both orchestrate, epic-orchestrate, and epic-run copies, both epic-plan copies, the rule source .md and .json, the generated rule, the brief (.claude copy), the template, the pin file, and the four extended test files. The modified paths without a block are the byte-identical twins .codex/hooks/enforce-epic-merge-gate-child-ci.ps1, .codex/hooks/enforce-completion-helpers.ps1, and .agents/skills/execution-environment/SKILL.md (cmp-identical to their .claude copies; re-copied by step 2), the bundle copies under extensions/drm-copilot/resources/ (step 2), and the ledger README index. Each `Current` occurs exactly once (the in-memory revert throws otherwise; SCRATCH/issue-1233-ledger-verify.sh reported problems=0).
- `## Revert Steps`: the six labels in order; step 1 deletes the created files; step 2 re-copies twins and bundles, re-copies the .agents sources to the codex-and-agents bundle, and regenerates the harness outputs with a `-Check` run; step 4 restores the prior epic-orchestrate digest through the pin block, reverted before the 0010 hunk.
- `## Revert Signals`: integration pull request `CI` failures traced to an opted-out child that only child CI would have caught.

Commands and exit codes:
- sh SCRATCH/issue-1233-ledger-assemble.sh <28 paths> -> 0 (65 blocks)
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=65 files=28 problems=0)
- sh SCRATCH/issue-1233-ledger-files-check.sh -> diff paths=78, one unlisted promotion record (explained above)
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1 tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1 -> 0 (89 passed)
