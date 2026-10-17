# Remediation Inputs: Host bootstrap installs poetry (Issue #930), cycle 1

Review-Verdict: REMEDIATION_REQUIRED

Source: coordinator decision D6, related finding (evidence-schema completeness).

## Blocking Findings

### Finding 1: Three evidence files lack the machine-checkable schema fields

Remediability: autonomous
Remediability-Evidence: The fix is a documentation edit inside the feature folder; no external dependency or policy hold applies.

The following files under docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/ do not carry all of the fields Timestamp, Command, EXIT_CODE, and Output Summary required by the evidence-and-timestamp-conventions skill:

- baseline/phase0-instructions-read.2026-10-16T00-17.md (has Timestamp and Output Summary; lacks Command and EXIT_CODE)
- other/phase1-handoff.2026-10-16T02-45.md (has Timestamp only; lacks Command, EXIT_CODE, Output Summary)
- other/reduced-audit-handoff.2026-10-16T03-22.md (has Timestamp only; lacks Command, EXIT_CODE, Output Summary)

Action: add the missing fields. Where no command was run, record the observation that was made (what was read or written, and how it was checked). Timestamps are read from the host clock at write time with date -u +%Y-%m-%dT%H-%M; never estimated. Existing file names are not renamed.
