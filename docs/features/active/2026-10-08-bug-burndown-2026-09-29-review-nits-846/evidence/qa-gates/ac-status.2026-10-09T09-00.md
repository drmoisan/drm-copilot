# Final QC: acceptance-criteria status ([P13-T11])

Timestamp: 2026-10-09T22-05
Command: grep -c -e "^- \[x\] AC-" docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
EXIT_CODE: 0
Output Summary: `36`. Pending list (Conventions) under A7-CI with no PRE-EXISTING-FAILURE-ONLY outcome: AC-30, AC-31, AC-34, AC-38 (K = 4); 40 - 4 = 36, which matches.

Command: grep -n -e "^- \[ \] AC-" docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md
EXIT_CODE: 0
Output Summary: exactly four lines, at lines 342 (AC-30), 343 (AC-31), 349 (AC-34), and 353 (AC-38); these are exactly the pending-list criteria.

### Acceptance Criteria Status

- Source: docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/spec.md (full-bug; spec.md is the sole AC source)
- Total AC items: 40
- Checked off (delivered): 36
- Remaining (unchecked): 4
- Items remaining:
  - AC-30 (pending-CI): the new poll-step `It` block passes Pester. Local Pester is unavailable (A7-CI, `Outcome: LOCAL-PESTER-UNAVAILABLE`); the CI job poshqc / PowerShell QC on the PR head is authoritative and the item's orchestrator checks this off at S9.
  - AC-31 (pending-CI): the tightened `exit 1` assertions; the text half is verified in doc-723-exit1-checks, and the Pester half depends on the CI job poshqc / PowerShell QC on the PR head, checked off at S9 by the item's orchestrator.
  - AC-34 (pending-CI): the closure-dispositions record is written with 27 rows and every cited path exists ([P13-T5]); its #338 A1 row depends on the PR CI "Enforce Python coverage thresholds" step result, which the executing orchestrator appends and then checks AC-34 off at S9.
  - AC-38 (pending-CI): PowerShell formatter and analyzer on the test file. Local run unavailable (A7-CI); the CI job poshqc / PowerShell QC on the PR head is authoritative, checked off at S9 by the item's orchestrator.
- Pre-existing-failure criteria: none. No `Outcome: PRE-EXISTING-FAILURE-ONLY` row was recorded in [P10-T12] or [P11-T8].
- Verification tasks left unchecked under the pre-existing-failure rule: none.
- Plan tasks left open: [P8-T10] (AC-30), [P8-T11] (AC-31), [P12-T5] (AC-38), [P13-T8] (AC-34).
