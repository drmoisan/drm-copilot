# [P0-T3] Git Baseline Capture

- **Timestamp:** 2026-07-22T12-15
- **Command:** `git status --porcelain && git rev-parse HEAD && git diff --stat -- package.json package-lock.json` (run at repo root)
- **EXIT_CODE:** 0

## Output Summary

- **Branch:** `bug/npm-audit-vulnerabilities-ci-gate-397` (matches expected branch; confirmed via `git branch --show-current`).
- **HEAD SHA:** `b2351cbc3fb3916f516d77567a1c9e40457c8981`.
- **`git status --porcelain`:** only two untracked entries, both new feature-folder documentation, not tracked source/manifest files:
  - `?? docs/features/active/2026-07-22-npm-audit-vulnerabilities-ci-gate-397/`
  - `?? docs/features/potential/promoted/2026-07-22-npm-audit-vulnerabilities-ci-gate.md`
- **`git diff --stat -- package.json package-lock.json` (root):** empty output — `package.json`/`package-lock.json` at the repo root are clean/unmodified prior to Phase 1.
- All 3 manifests (`.`, `extensions/drm-copilot/`, `packages/mcp-server/`) are confirmed clean/unmodified prior to Phase 1 (no entries for any of the 6 in-scope files appear in `git status --porcelain`).
- Note: a separate local branch `chore/npm-upgrade` exists with modified `package.json`/`package-lock.json` at its tip. That branch is stale and unrelated to this fix per the plan's explicit instruction; it is not merged with or reverted onto this branch, and this baseline capture was taken entirely on `bug/npm-audit-vulnerabilities-ci-gate-397`.
