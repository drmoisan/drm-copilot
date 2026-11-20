# AC-18 Branch-Diff Scope (P6-T3)

Timestamp: 2026-10-09T03-55
Task: [P6-T3]
Working directory: worktree root
Command: git diff --name-status origin/main; git status --porcelain --untracked-files=all; git diff --quiet origin/main -- extensions/drm-copilot/test/subagent-tree-command.test.ts extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts extensions/drm-copilot/CHANGELOG.md extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/package.json; git ls-files -- CHANGELOG.md
EXIT_CODE: 0 (each of the four commands exited 0)

## 1. git diff --name-status origin/main

Paths outside the feature folder:

    M	docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md
    M	docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/user-story.md
    A	docs/features/potential/promoted/2026-10-08-handoff-failure-cause-fallback-and-name-gaps.md
    M	extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts
    M	extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts
    M	extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts
    M	extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts
    A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-binding.test.ts
    A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service-test-support.ts
    M	extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts
    M	extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts
    A	extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts
    M	extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts

All remaining entries (35) are under `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/` (issue.md, spec.md, plan, research, and evidence artifacts).

## 2. git status --porcelain --untracked-files=all

    ?? docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/evidence/qa-gates/ac13-line-counts.2026-10-09T03-53.md
    ?? docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/evidence/qa-gates/ac6-catch-site-inventory.2026-10-09T03-52.md

Both entries are Phase 6 evidence under the feature folder.

## 3. Out-of-scope files unchanged

Command: git diff --quiet origin/main -- extensions/drm-copilot/test/subagent-tree-command.test.ts extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts extensions/drm-copilot/CHANGELOG.md extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/package.json
EXIT_CODE: 0

## 4. Root changelog

Command: git ls-files -- CHANGELOG.md
EXIT_CODE: 0
Output: (empty; no root changelog is tracked)

## Promoted lifecycle record

`docs/features/potential/promoted/2026-10-08-handoff-failure-cause-fallback-and-name-gaps.md` is pre-existing: it was added by commit 742f6775 (`docs(844): prepare feature folder, research, spec, and preflight-cleared plan`), which was the branch HEAD before execution began. It does not appear in the P0-T2 porcelain capture because it was already committed at that point; it appears here in the name-status list for the same reason. It was not written by this execution. This is recorded as a plan deviation (the plan's exemption is phrased against the P0-T2 porcelain capture).

Command: git log --format="%h %s" origin/main..742f6775 -- docs/features/potential/promoted/2026-10-08-handoff-failure-cause-fallback-and-name-gaps.md (plus the feature-folder planning files)
Output: `742f6775 docs(844): prepare feature folder, research, spec, and preflight-cleared plan`

## Result

- Union of name-status and porcelain entries: the 12 non-evidence Blast Radius paths, paths under the feature folder, and the pre-existing promoted lifecycle record. No other path.
- No added path under `extensions/drm-copilot/src/` (all four src entries are `M`), so no new coverageThreshold entry is required.
- Out-of-scope diff exits 0; `git ls-files -- CHANGELOG.md` exits 0 and prints nothing.

Output Summary: Pass (branch-diff half of AC-18). The branch changes only the planned files, the feature folder, and the pre-existing promoted lifecycle record from the pre-execution commit 742f6775. The PR-body half is verified in P7-T18.
