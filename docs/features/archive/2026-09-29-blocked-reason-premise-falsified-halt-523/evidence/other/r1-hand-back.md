# Remediation Cycle 1 — Hand-Back to the Main Plan (P3-T1)

Timestamp: 2026-09-30T15-41

RESUME: P8-T1 of plan.2026-09-29T15-52.md

- The main plan's restart rule applies (its Phase 8 preamble: "If any step in Phases 8 through 10 fails or changes a file, fix it in the owning batch, commit, and restart from P8-T1"). P8-T1 through P12-T4 therefore run again in order, and their artifacts from the last clean iteration replace the earlier ones.
- The final QA evidence (format, lint, type-check, architecture, unit tests with coverage, contract, integration for Python, TypeScript, and PowerShell) is produced by those main-plan tasks and not by this remediation plan.
- P10-T4 is expected to observe the #523 cap row (`the orchestrator-state module stays within the 500-line file cap`) passing, so its failing set is expected to be a subset of the P0-T26 set.
- The P12-T4 `## Implementation Notes` should record this amendment (citing `evidence/other/change-set-amendment-p7-t14.md`) under "any count or key that differed from this plan's stated expectation".

Remediation commits: R1_FIX `df9bddd52b3475e67a13fda29feb86857e26d2e7` (test edit and Phase 0-1 evidence); `d033ee68ed7bb35836bf3ea6b15741ed720c044e` (P7-T14 change-set amendment).
