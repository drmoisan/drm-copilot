Timestamp: 2026-07-03T09-14
Command: python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
Output Summary: Evidence-location validation passed. Initial run failed because the supplied ignored research artifact lived under `artifacts/research/`; the artifact was moved to `docs/features/active/2026-07-03-codex-worktree-session-regression-281/research/`, and the rerun exited 0 with no diagnostics.

Initial Diagnostic:
```text
VIOLATION: artifacts\research\2026-07-03T09-17-issue-281-codex-worktree-session-regression-research.md - use docs/features/active/<feature>/research/ or docs/research/ instead
```

Rerun Output:
```text
<no output>
```
