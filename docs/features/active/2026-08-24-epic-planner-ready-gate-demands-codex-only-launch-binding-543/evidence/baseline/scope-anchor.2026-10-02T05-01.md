# Scope anchor (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T3
Command: `git fetch origin main` ; `git merge-base origin/main HEAD` ; `git status --porcelain` (three separate invocations from the worktree root)
EXIT_CODE: 0
Route: native (D3)

Output Summary:
- `git fetch origin main`: `* branch main -> FETCH_HEAD` (exit 0).
- Merge base (40 characters): `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`. This matches the D2 anchor supplied by the orchestrator; every plan reference to `(git merge-base origin/main HEAD)` uses this literal SHA.
- `git status --porcelain` output:
  - ` M docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/plan.2026-09-29T16-06.md` (P0-T1 check-off)
  - `?? docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/baseline/` (Phase 0 artifacts)
- No path outside the feature folder is listed; Phase 1 may proceed.
- Exit-code note: the Bash tool refuses `git ...; echo EXIT=$?` chains in this worktree; each git command ran alone and the tool reported success (a non-zero exit is reported by the tool as an error).
