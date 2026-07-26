# Baseline — Git State

Timestamp: 2026-07-26T00-54

Task: [P0-T2]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423

Command: `git rev-parse --abbrev-ref HEAD && git rev-parse HEAD && git rev-parse fb483b84 && git status --porcelain --untracked-files=all`
EXIT_CODE: 0

## Branch and Commits

- Branch: `bug/jest-no-tests-found-dot-directory-worktree`
- HEAD SHA: `8da72e98bfa64e1e50f8c8a70131be5b4a53bd67` (short `8da72e98`)
- Base SHA: `fb483b8468204e4385b5583c3b3ec4c0a987eede` (short `fb483b84`)
  - Base subject: `Merge pull request #420 from drmoisan/bug/format-check-invalid-json-fixtures`
- Worktree path: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`
  (contains the dot-prefixed directory segment `\.claude\` that triggers the defect under test)

## git status --porcelain --untracked-files=all

```
 M docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/plan.2026-07-25T21-48.md
?? docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/baseline/phase0-instructions-read.md
```

Both entries are feature-folder artifacts produced by [P0-T1] (plan checkbox update and the Phase 0
policy-read evidence file). Excepting feature-folder files, the tree is clean: no source, config, or
test file is modified at baseline. The tree was verified fully clean (zero entries) immediately
before [P0-T1] executed.

## In-Scope Files at Baseline (unmodified)

1. `jest.config.cjs` (root)
2. `run-jest.cjs` (root)
3. `extensions/drm-copilot/jest.config.cjs`
4. `extensions/drm-copilot/run-jest.cjs`
5. `tests/unit/jest-config-resolution.test.ts` (does not yet exist)
6. `extensions/drm-copilot/test/jest-config-resolution.test.ts` (does not yet exist)

Output Summary: Branch is `bug/jest-no-tests-found-dot-directory-worktree` at HEAD `8da72e98`, base
`fb483b84`. Working tree clean apart from two feature-folder artifacts created by [P0-T1]. No
in-scope source/config/test file modified at baseline. Exit code 0.
