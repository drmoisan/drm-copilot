# Plan trivial fixes (issue #962)

Timestamp: 2026-10-16T23-15
Command: Edit tool on docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/plan.2026-10-16T10-27.md (one edit per entry below)
EXIT_CODE: 0
Output Summary: Trivial plan defects found during execution after the origin/main merge (4e82b3a3c, which brought in #953) were corrected in place under the coordinator instruction. Each entry records the task, the old text, the new text, and the reason.

## Fix 1

- Task: P0-T2
- Old text: `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/` (the untracked evidence folder, which exists because P0-T1 wrote its artifact first)
- New text: `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/` or `?? docs/features/active/2026-10-16-ci-skip-evidence-only-commits-962/evidence/baseline/` (the untracked evidence folder or, when `evidence/other/` is already tracked, its untracked `baseline/` subfolder, which exists because P0-T1 wrote its artifact first)
- Reason: the pre-mortem commit bc67ae0fc tracks `evidence/other/pre-mortem.2026-10-16T23-12.md`, so git reports the untracked `evidence/baseline/` subfolder rather than the whole `evidence/` folder.
