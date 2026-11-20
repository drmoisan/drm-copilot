# Baseline — Git State (Issue #422)

Timestamp: 2026-07-26T00-50

Command:
```
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
git status --porcelain
```

EXIT_CODE: 0 (all three commands exited 0)

Output Summary:

- Branch: `bug/claude-rules-typescript-vitest-jest-divergence`
- Commit SHA (HEAD): `564987e6b452b01f7a29decd670737f2794f6332`
- Working tree state: effectively clean with respect to tracked files. `git status --porcelain` reported exactly one entry:
  - `?? docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/` — the untracked evidence directory created by this plan's Phase 0 (`[P0-T6]`). No tracked file is modified, added, or deleted at baseline.
- The declared base `origin/main` is `fb483b84`; the branch head `564987e6` carries the already-committed feature-folder documents (`issue.md`, `spec.md`, `plan.2026-07-25T21-44.md`, `research/`).
