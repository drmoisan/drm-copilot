# Branch and commit baseline (P0-T2)

Timestamp: 2026-10-16T00-17

Command: git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git status --porcelain

EXIT_CODE: 0

Output Summary:

- Branch: bug/host-bootstrap-does-not-install-poetry-930
- HEAD SHA: c8588fc9081f4a1f10a6fd78e334af082cb4dce2
- git status --porcelain output (taken before any Phase 0 artifact was written, as shown in the session-start status snapshot, and re-read after the evidence folders were created):
  - `?? SCRATCH/`
  - `?? docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/` (appears only after the evidence folder was created by this plan)
- Observation: `?? SCRATCH/` was already present at session start, because the launching session created `SCRATCH/issue-930/init_ckpt.py` before this plan began. The task text expects no SCRATCH path at this point. The path is untracked, is never staged, and does not touch any tracked file, so it is recorded as a benign deviation from the task text rather than a scope violation. No tracked file is modified.
- No tracked-file change (no ` M` entry) exists outside the feature folder.
