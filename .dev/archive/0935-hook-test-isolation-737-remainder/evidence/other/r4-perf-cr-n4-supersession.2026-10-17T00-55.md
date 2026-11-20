# R4 PERF-3 Supersession of the CR-N4 Disposition (P4-T2, issue #935)

Timestamp: 2026-10-17T00-55
Command: grep -n -F -e 'CR-N4: NO-CHANGE.' FEATURE/evidence/other/r1-dispositions.2026-10-16T05-13.md; grep -n -F -e 'sharing no state with the' FEATURE/plan.2026-10-15T17-44.md; grep -n -F -e 'unparseable suite rows keep passing;' FEATURE/spec.md (FEATURE = docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935)
EXIT_CODE: 0

Output Summary:
- `r1-dispositions.2026-10-16T05-13.md`: one line, line 8 (`CR-N4: NO-CHANGE. The AC-5b ... and F-3 non-vacuity ... rows keep separate collection ...`).
- `plan.2026-10-15T17-44.md`: one line, line 172 (main-plan P5-T2, which requires the non-vacuity row to share no state with the AC-5b row).
- `spec.md`: one line, line 178 (`- Error handling and logging verification: missing and unparseable suite rows keep passing; `AC-5b` never fails.`).

SUPERSEDED-DISPOSITION: evidence/other/r1-dispositions.2026-10-16T05-13.md line 8 (CR-N4: NO-CHANGE); the disposition file is not edited.
SUPERSEDED-REQUIREMENT: plan.2026-10-15T17-44.md line 172 (main-plan P5-T2: the F-3 non-vacuity row shares no state with the AC-5b row); the main plan is not edited for this.
OPERATOR-DIRECTION: the AC-5b and F-3 non-vacuity rows read one report built once in the Describe-level BeforeAll of the Discovery suite; each row only reads it, so neither row depends on the other having run (issue #935, PERF-3).
FAILURE-SEMANTICS: spec.md line 178 (AC-5b never fails) still holds for every entry; a throw while building the report fails the Describe BeforeAll and therefore every row of that Describe, where before it failed only the AC-5b and F-3 rows that collected the lines.
