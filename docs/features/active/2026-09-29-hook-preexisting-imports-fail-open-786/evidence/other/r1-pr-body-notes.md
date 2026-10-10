# Remediation Cycle 1 PR-Body Notes

Timestamp: 2026-10-10T09-02

PR-BODY-NOTE: AC-6 was amended on 2026-10-10 as a consequence of the 2026-10-09 operator decision. The named-exemption edges of H1, H4, H5, and H6 (the feature-folder-resolution.ps1 edge of enforce-feature-folder-order.ps1, enforce-epic-wave-barrier.ps1, enforce-parallel-drift-gate.ps1, and enforce-parallel-cohort-barrier.ps1) acquire the payload before their retained handler denies, so they are excepted from AC-6; their deny is the fail-closed handler recorded in exemption-decisions.md and proven by fail-closed-proof.H1.md, fail-closed-proof.H4.md, fail-closed-proof.H5.md, and fail-closed-proof.H6.md. Every other Claude PreToolUse edge meets AC-6 as written. AC-17 is unchanged.
