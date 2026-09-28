# checkpoint-folder-reader-lacks-direct-coverage (Issue #696)

- Date captured: 2026-09-19
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/checkpoint-folder-reader-lacks-direct-coverage/ (Issue #696)

- Issue: #696
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/696
- Last Updated: 2026-09-19
## Summary

`Get-PrdFeatureCheckpointFolder` in `.claude/hooks/enforce-prd-feature-before-planner.ps1` has no
direct test coverage of its read, parse, and field-extraction body. Only its absent-file early
return is exercised; every existing suite mocks the function itself.

This matters because PR #695 (issues #673 and #672) **changed that function's contract**: its
`-CheckpointPath` parameter became mandatory, and its input changed from a process-relative literal
to an absolute path resolved by portable identity. The altered contract is therefore unverified by
any direct test.

Raised as Important finding I-2 by the feature review of PR #695.

## Why this is a verification gap, not a coverage ratio

PR #695 recorded an accepted deviation: whole-file coverage fell on two hooks — the prd gate from
90.72% to 90.32%, its helpers from 96.77% to 96.61%. That deviation is benign on its own terms: the
uncovered-line counts are unchanged at 9 and 2, changed-line coverage is 100% on both, the
repository's 85% floor holds, and repo-wide coverage rose from 95.72% to 95.77%.

The review's qualification is the point of this issue. In **both** regressed files the uncovered
lines sit on code paths the change re-pointed:

- six of the gate's nine uncovered lines are this function's body, whose parameter contract the
  change made mandatory and whose input it re-sourced;
- both of the helpers' two uncovered lines are in `ConvertTo-PrdFeatureFolderToken`, which the
  renamed selector now calls with the checkpoint value.

So the work is not ratio repair. It closes a verification gap on a contract that changed.

## Proposed Behavior

Add direct coverage for the three reachable arms, scoped narrowly:

1. a valid checkpoint carrying the `feature-folder` field;
2. a checkpoint whose JSON does not parse;
3. a valid checkpoint with the field absent.

Three committed fixture checkpoints already exist in the repository for exactly these shapes, added
by PR #695, so no new fixture is required and no temporary file is involved.

## Constraints

- **Not in either pinned prd suite.** `enforce-prd-feature-before-planner.Tests.ps1` and
  `.FolderResolution.Tests.ps1` are pinned to exact changed-line and changed-region diffs by
  acceptance conditions PR #695 already satisfies.
- **Not in the identity suite.** Its determinism statement forbids deriving a path from the script
  location, and that statement is itself an acceptance criterion of issue #672.
- A new suite file is therefore the likely home. Keep every file at or under 500 lines.
- No temporary files, no working-directory change, no host-derived absolute path.

## Acceptance Criteria (early draft)

- [ ] The three arms above are covered by named Pester tests that do not mock
      `Get-PrdFeatureCheckpointFolder` itself.
- [ ] Neither pinned prd suite is modified, and the identity suite's determinism statement is
      unchanged.
- [ ] Whole-file coverage for the gate and its helpers is at or above the figures recorded in
      PR #695, and no changed-line regression occurs.
- [ ] The PowerShell toolchain passes: format, analyze at all severities, test.

## Next Step

- [x] Promote to GitHub issue
