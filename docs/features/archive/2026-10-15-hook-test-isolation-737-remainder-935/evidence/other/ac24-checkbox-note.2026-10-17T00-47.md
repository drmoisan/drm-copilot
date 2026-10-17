# AC-24 Checkbox Note (P3-T3, AC-CHK-1 and EV-3, issue #935)

Timestamp: 2026-10-17T00-47
Command: grep -n -F -e 'the checkbox is marked with that qualification' FEATURE/evidence/other/cov1-decision-option1.2026-10-16T20-38.md; grep -n -F -e 'Local repository-scope line coverage is 94.33%' FEATURE/evidence/other/cov1-decision-option1.2026-10-16T20-38.md; grep -n -F -e 'covered=11602 missed=697 total=12299 pct=94.33' FEATURE/evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md (FEATURE = docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935)
EXIT_CODE: 0

Output Summary:
- `20:- AC-24's criterion text in `spec.md` is unchanged. An amendment line beneath it records acceptance under this decision, and the checkbox is marked with that qualification. AC-24 is not reported as met as written.`
- `15:- Local repository-scope line coverage is 94.33% (`evidence/qa-gates/` cycle 3 final repo-scope run: covered 11602, missed 697).`
- `14:- D-COV-READ (root LINE counter; local repo-scope population; not compared with CI): counter count `1`; `covered=11602 missed=697 total=12299 pct=94.33``

CHANGE: spec.md AC-24 checkbox changed from [x] to [ ] with the criterion text unchanged; the amendment line now states that AC-24 stays unchecked under acceptance-criteria-tracking rule 4 until S9, where P7-T10 records ACCEPTED-OPTION-1 when P7-T6 confirms the 85% floor and no exclusion on the final head, or PASS when P7-T6 also records BASELINE-CLAUSE: MET.
SUPERSEDED-INSTRUCTION: evidence/other/cov1-decision-option1.2026-10-16T20-38.md line 20 ("the checkbox is marked with that qualification"); the decision record is not edited.
FINDING-LINE-NOTE: the review finding cites decision-record line 19; the instruction text is on the line recorded above.
EV-3-SOURCE: the 94.33% figure on decision-record line 15 comes from evidence/qa-gates/r3-ps-test-repo.2026-10-16T15-50.md line 14 (covered=11602 missed=697 total=12299 pct=94.33; local repo-scope population).
RULE: acceptance-criteria-tracking rule 4 and ### CI-Dependent Criteria (check-off of a CI-dependent criterion at S9 only).
