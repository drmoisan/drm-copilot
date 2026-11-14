# Stage E Ledger Check

Timestamp: 2026-11-07T11-20
Command: sh SCRATCH/issue-1097-e-run.sh issue-1097-e-p0t3.ps1 (run before and after the 0003 back-fill)
EXIT_CODE: 0
Output Summary:
  Run before the back-fill:
    ledger-valid=True rows=3
    0001 patch-exists=True
    0001 merge-commit-ancestor-of-HEAD=True
    0001 revert-blocks=4
    0001 block 1 .claude/skills/execution-environment/SKILL.md current-at-merge=1 prior-at-first-parent=True
    0001 block 2 .claude/skills/atomic-plan-contract/SKILL.md current-at-merge=1 prior-at-first-parent=True
    0001 block 3 .agents/skills/atomic-plan-contract/SKILL.md current-at-merge=1 prior-at-first-parent=True
    0001 block 4 .github/skills/atomic-plan-contract/SKILL.md current-at-merge=1 prior-at-first-parent=True
      apply: error: patch failed: extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md:132
      apply: error: extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md: patch does not apply
      apply: error: patch failed: .github/skills/feature-review-workflow/SKILL.md:132
      apply: error: .github/skills/feature-review-workflow/SKILL.md: patch does not apply
    0001 patch-reverse-check-exit=1 (recorded only)
    0002 merge-commit-ancestor-of-HEAD=True
    0003 step1 adding-commits=1
    0003 step1 reduction-commit=33b80bd196f42c453162c76c93e6a49233182b4c
    0003 step2 merged-prs=#1104=bad886e304990d26af56d6bcabc9d543518492e9, #1103=72e57cc7dfd4ba78579a2c86887aa0c77d5d9cef, #1101=51e11487f2c01b35ce3933f34ca58fae2c6ed965, #1100=51d3886485956df68a68a38e920c7c3687ec4462
    0003 step3 candidates-holding-reduction=#1104
    0003 step3 merge-commit=bad886e304990d26af56d6bcabc9d543518492e9 (PR #1104)
    0003 step4 ancestor-of-HEAD=True
    0003 oid-form-ok=True
    failures=0
    exit=0
  Run after the back-fill:
    ledger-valid=True rows=3
    0001 patch-exists=True
    0001 merge-commit-ancestor-of-HEAD=True
    0001 revert-blocks=4
    0001 block 1 .claude/skills/execution-environment/SKILL.md current-at-merge=1 prior-at-first-parent=True
    0001 block 2 .claude/skills/atomic-plan-contract/SKILL.md current-at-merge=1 prior-at-first-parent=True
    0001 block 3 .agents/skills/atomic-plan-contract/SKILL.md current-at-merge=1 prior-at-first-parent=True
    0001 block 4 .github/skills/atomic-plan-contract/SKILL.md current-at-merge=1 prior-at-first-parent=True
      apply: error: patch failed: extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md:132
      apply: error: extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md: patch does not apply
      apply: error: patch failed: .github/skills/feature-review-workflow/SKILL.md:132
      apply: error: .github/skills/feature-review-workflow/SKILL.md: patch does not apply
    0001 patch-reverse-check-exit=1 (recorded only)
    0002 merge-commit-ancestor-of-HEAD=True
    0003 step1 adding-commits=1
    0003 step1 reduction-commit=33b80bd196f42c453162c76c93e6a49233182b4c
    0003 step2 merged-prs=#1104=bad886e304990d26af56d6bcabc9d543518492e9, #1103=72e57cc7dfd4ba78579a2c86887aa0c77d5d9cef, #1101=51e11487f2c01b35ce3933f34ca58fae2c6ed965, #1100=51d3886485956df68a68a38e920c7c3687ec4462
    0003 step3 candidates-holding-reduction=#1104
    0003 step3 merge-commit=bad886e304990d26af56d6bcabc9d543518492e9 (PR #1104)
    0003 step4 ancestor-of-HEAD=True
    0003 oid-form-ok=True
    failures=0
    exit=0

#1094 check (no new entry): the ledger is valid; `patches/0001-parallel-only-test-gates.patch` exists; the `0001` merge commit is an ancestor of `HEAD`; for each of the four `0001` revert blocks, `Current` occurs once at the merge commit and `Prior` occurs at its first parent. All hold.

Reverse-patch reference: `git apply -R --check` of `patches/0001-parallel-only-test-gates.patch` on the working tree fails at this reference point (exit 1), on `.github/skills/feature-review-workflow/SKILL.md` and its bundle `extensions/drm-copilot/resources/customizations/.github/skills/feature-review-workflow/SKILL.md`, whose hunks the stage D edits moved. Entry `0001` therefore reverts through its `Prior Text` blocks. Later ledger replays compare their failing-file set with this one; a file that joins the set is named.

`0002`: its merge commit is an ancestor of `HEAD`; not edited.

`0003` derivation (D1, K8):
1. Reduction commit: the single commit that added `0003-light-remediation.md` (git log --diff-filter=A).
2. Candidates: the four merged pull requests of head `feature/reduce-feature-cycle-time` (#1104, #1103, #1101, #1100).
3. Only #1104's merge commit has the reduction commit as an ancestor, so it is the oldest merge holding stage D.
4. That merge commit is an ancestor of `HEAD`, and is the full 40-character lowercase `mergeCommit.oid`.

Back-fill written: `Merge commit:` now holds the PR #1104 merge commit, and the `## Summary` stand-in sentence is reworded as in `0002`. No `Current` fence moved; no file was added under `docs/engineering/process-reductions/`; `Test-ProcessReductionLedger` returns `IsValid` true after the back-fill.
