# Remediation Acceptance Criteria Reopen Evidence

Timestamp: 2026-09-02T21-24
Command: `git diff --unified=0 -- docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/spec.md docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md`; `rg -n "^- \\[ \\] (AC3:|AC10:|Dry-run transition|Unsupported schema versions)" <spec-and-user-story-paths>`
EXIT_CODE: 0

## Reopened source locations

1. `spec.md:338` — `AC3: Plan validation accepts only the pinned normalized repository-relative path and raw-byte`
2. `spec.md:360` — `AC10: Materialization repeats validation, performs a read-only clean-worktree preflight, writes`
3. `user-story.md:109` — criterion 8, `Dry-run transition changes no canonical checkpoint or user file. Materialization validates a`
4. `user-story.md:115` — criterion 10, `Unsupported schema versions, tampered source or history, wrong repository/workspace/branch/`

Output Summary: Each required marker was changed individually from `[x]` to `[ ]`. The zero-context diff contains exactly four removed marker lines and four corresponding added marker lines. Criterion text is unchanged, and all other acceptance markers remain unchanged.
