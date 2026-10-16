# R3 EV-1 Correction (P3-T6)

Timestamp: 2026-10-16T15-16
Corrects: FEATURE/evidence/qa-gates/r2-cov-blocked.2026-10-16T10-52.md (not edited)
COV-1-TRIGGER-LOCATION: inside the Write Set (cycle-2 unit U4; nine guard files under tests/scripts/claude-hooks)
COV-1-MECHANISM-LOCATION: outside the Write Set (suspected Pester 5 breakpoint binding and PowerShell script-block cache behaviour; not experimentally verified in cycle 2)

The cycle-2 phrase "root cause outside the write set" in `r2-cov-blocked.2026-10-16T10-52.md` described the suspected mechanism only, while the trigger unit U4 that the same record named lies inside the Write Set. The cycle-3 record that states the trigger and the mechanism on separate lines is `FEATURE/evidence/qa-gates/r3-cov-status.2026-10-16T15-15.md` (lines `COV-1-TRIGGER:` and `COV-1-MECHANISM:`); at the merged head that record reports the trigger as not localised (`T-U4-NO-LONGER`), because the U4 revert no longer restores the attribution after the merge of `origin/main`.
