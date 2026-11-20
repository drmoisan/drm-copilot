# Remediation Inputs: npm audit gate advisory exception (#1204)

Review-Verdict: AWAITING_CI
Remediation-Path: full

Artifacts:
- docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/policy-audit.2026-11-18T06-01.md
- docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/code-review.2026-11-18T06-01.md
- docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/feature-audit.2026-11-18T06-01.md

## F1: repo-wide PowerShell line coverage not verifiable locally

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: the canonical coverage file was overwritten by a later two-suite run and reads 0.82%; the full-run figure of 96.05% exists only in the evidence record, and the poshqc CI shard coverage on the PR head is the authoritative source that closes it.
Finding-Scope: contained

Per-file figures for both new production files were recovered from untouched shard files (161/161 and 50/55 lines) and equal the evidence record. No code change is required; wait for the poshqc checks on the PR head, then confirm the merged coverage.
