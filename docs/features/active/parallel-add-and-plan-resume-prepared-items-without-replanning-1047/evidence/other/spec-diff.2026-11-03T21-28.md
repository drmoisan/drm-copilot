# Spec Diff (remediation cycle 2)

Timestamp: 2026-11-03T21-28
Task: [P2-T1]
Command: git diff --no-renames 17193681c -- <FEATURE>/spec.md; git diff --numstat 17193681c -- <FEATURE>/spec.md (anchored to the branch head recorded in remediation-baseline/scope-baseline.2026-11-03T21-25.md)
EXIT_CODE: 0
Output Summary: numstat `1 1` (one line added, one removed). The single hunk sits under `## Implementation Strategy` (hunk header context; the changed line is the first bullet under "Implementation scope (what changes, not sequencing):"). The added line contains `ParallelAdmissionJson.psm1` with the description "(JSON parse and serialize helpers)". No line under `## Acceptance Criteria` changed.

## Changed line

- Removed: the first implementation-scope bullet naming `ParallelAdmission.psm1`, `ParallelAdmissionPrecedence.psm1`, and `Invoke-ParallelAdmission.ps1`.
- Added: the same bullet with `` `.claude/lib/parallel-admission/ParallelAdmissionJson.psm1` (JSON parse and serialize helpers), `` inserted before `` and `.claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1` ``.
