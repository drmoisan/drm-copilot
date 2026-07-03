# P1-T4 Fail-Before Regression Proof (Issue #279)

- Timestamp: 2026-07-03T14-30
- Command: `git stash push -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (temporary local revert, not committed), then `npm test -- --testPathPatterns claude-pack-manifest-completeness` (run from `extensions/drm-copilot/`), then `git stash pop` (restore)
- EXIT_CODE: 1 (failing run, captured before restore)

## Procedure

1. Confirmed the working-tree diff for `core.json` prior to revert consisted solely of the six additive insertions from P1-T1 (no deletions, no reordering) via `git diff -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
2. Ran `git stash push -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` to temporarily revert `core.json` to its pre-fix (HEAD) state. Confirmed via `git diff --stat` that the file showed no diff after the stash (i.e., matched the pre-fix committed state).
3. Ran `npm test -- --testPathPatterns claude-pack-manifest-completeness` from `extensions/drm-copilot/` against the reverted `core.json`.
4. Ran `git stash pop` to restore the working-tree edit.
5. During restoration, discovered that the pre-existing working-tree edit (prior to this execution session) had applied only 5 of the 6 required P1-T1 insertions -- the `.claude/skills/epic-orchestrate/SKILL.md` insertion (required immediately before `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`) was missing. Corrected this by inserting the missing path at the specified location, per the P1-T1 task text, then re-verified the full six-path diff and re-ran the test to confirm a clean pass (see Post-Restore Verification below).

## Failing Run Output (step 3, against fully-reverted core.json)

```
FAIL test/lib/push-down/claude-pack-manifest-completeness.test.ts
  * claude pack manifest completeness (real filesystem) > lists every bundled .claude agent, skill, and hook file in some pack manifest

    expect(received).toEqual(expected) // deep equality

    - Expected  - 1
    + Received  + 8

    - Array []
    + Array [
    +   ".claude/agents/epic-orchestrator.md",
    +   ".claude/hooks/enforce-epic-merge-gate.ps1",
    +   ".claude/hooks/enforce-epic-wave-barrier.ps1",
    +   ".claude/hooks/enforce-epic-worktree-removal-gate.ps1",
    +   ".claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1",
    +   ".claude/skills/epic-orchestrate/SKILL.md",
    + ]

  * claude pack manifest completeness (real filesystem) > issue #279 AC1: .claude/agents/epic-orchestrator.md is present in the union of pack-manifest paths
  * claude pack manifest completeness (real filesystem) > issue #279 AC1: .claude/skills/epic-orchestrate/SKILL.md is present in the union of pack-manifest paths
  * claude pack manifest completeness (real filesystem) > issue #279 AC1: .claude/hooks/enforce-epic-merge-gate.ps1 is present in the union of pack-manifest paths
  * claude pack manifest completeness (real filesystem) > issue #279 AC1: .claude/hooks/enforce-epic-wave-barrier.ps1 is present in the union of pack-manifest paths
  * claude pack manifest completeness (real filesystem) > issue #279 AC1: .claude/hooks/enforce-epic-worktree-removal-gate.ps1 is present in the union of pack-manifest paths
  * claude pack manifest completeness (real filesystem) > issue #279 AC1: .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 is present in the union of pack-manifest paths

Test Suites: 1 failed, 1 total
Tests:       7 failed, 7 total
Snapshots:   0 total
Time:        0.266 s, estimated 1 s
```

## Output Summary

Against the reverted (pre-fix) `core.json`, all 7 tests in `claude-pack-manifest-completeness.test.ts` failed (EXIT_CODE 1). The generic completeness assertion listed all six issue-#279 paths as missing (`.claude/agents/epic-orchestrator.md`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, `.claude/skills/epic-orchestrate/SKILL.md`), and each of the six per-path `it.each` assertions failed individually. This confirms the new test would fail against the pre-fix manifest (AC4).

## Post-Restore Verification

- Restored `core.json` diff (`git diff -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`) confirmed to contain exactly the six additive insertions in the positions specified by P1-T1, with no other changes.
- Re-ran `npm test -- --testPathPatterns claude-pack-manifest-completeness` from `extensions/drm-copilot/` against the fully-restored (and corrected) `core.json`.
- Result: `Test Suites: 1 passed, 1 total`; `Tests: 7 passed, 7 total`; `EXIT_CODE: 0`.
