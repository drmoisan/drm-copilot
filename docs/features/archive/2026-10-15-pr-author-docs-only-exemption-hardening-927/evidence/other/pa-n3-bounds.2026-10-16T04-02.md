# P5-T3 PA-N3 Timestamp Bounds (issue #927, AC-13)

Timestamp: 2026-10-16T04-02
Command: Derivation per plan decision D6 from pa-n3-commit-confirmation
EXIT_CODE: 0
Output Summary: 13 rows derived from Appendix P and the confirmed committer minutes C1 = 2026-10-13T11-17 and C2 = 2026-10-13T11-34 (pa-n3-commit-confirmation.2026-10-16T04-02.md). Every commit-dependent HI equals its confirmed minute. Every original value of a commit-dependent row lies outside its bounds, so every row's ACTION is EDIT; the three rows without a commit dependency (P2, P4, P10) apply the spec table as written, which edits them.

Derivation rule (D6): a commit-dependent HI is the confirmed committer time of the named commit in UTC, truncated to the minute. A commit-dependent file is UNCHANGED only when ORIGINAL is neither earlier than LO nor later than HI. Rows without a commit dependency apply the spec table as written.

| FILE | ORIGINAL | LO | HI | COMMIT_DEPENDENCY | CONTRADICTED | ACTION |
|---|---|---|---|---|---|---|
| P1 p1-pester-junit.2026-10-12T19-50.md | 2026-10-13T00-00 | 2026-10-13T10-51 | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (earlier than LO) | EDIT |
| P2 p1-poshqc-test-invocation.2026-10-12T19-50.md | 2026-10-13T00-00 | UNRECORDED | 2026-10-13T10-51 | none | n/a (spec table applies) | EDIT |
| P3 p1-xml-regenerated.2026-10-12T19-50.md | 2026-10-13T00-00 | 2026-10-13T10-51 | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (earlier than LO) | EDIT |
| P4 p1-poshqc-direct-run.2026-10-12T19-50.md | 2026-10-13T11-30 | 2026-10-13T10-51 | 2026-10-13T11-14 | none | n/a (spec table applies; later than HI) | EDIT |
| P5 p1-direct-xml-regenerated.2026-10-12T19-50.md | 2026-10-13T11-32 | 2026-10-13T11-14 | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (later than HI) | EDIT |
| P6 p1-pester-junit-direct.2026-10-12T19-50.md | 2026-10-13T11-34 | 2026-10-13T11-14 | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (later than HI) | EDIT |
| P7 local-powershell-coverage-direct.2026-10-12T19-50.md | 2026-10-13T11-36 | 2026-10-13T11-14 | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (later than HI) | EDIT |
| P8 p2-ac-state.2026-10-12T19-50.md | 2026-10-13T11-38 | UNRECORDED | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (later than HI) | EDIT |
| P9 p2-scope-before-stage.2026-10-12T19-50.md | 2026-10-13T11-39 | UNRECORDED | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (later than HI) | EDIT |
| P10 p1-poshqc-direct-run-rerun.2026-10-12T19-50.md | 2026-10-13T11-32 | 2026-10-13T11-14 | 2026-10-13T11-28 | none | n/a (spec table applies; later than HI) | EDIT |
| P11 p1-pester-junit-direct-rerun.2026-10-12T19-50.md | 2026-10-13T11-36 | 2026-10-13T11-28 | 2026-10-13T11-34 | 70e58ca84 (C2) | yes (later than HI) | EDIT |
| P12 local-powershell-coverage-direct-rerun.2026-10-12T19-50.md | 2026-10-13T11-37 | 2026-10-13T11-28 | 2026-10-13T11-34 | 70e58ca84 (C2) | yes (later than HI) | EDIT |
| P13 local-powershell-coverage.2026-10-12T19-50.md | 2026-10-13T06-55 | 2026-10-13T10-51 | 2026-10-13T11-17 | ff1b7cbd4 (C1) | yes (earlier than LO) | EDIT |

ROW_COUNT: 13
EDIT_COUNT: 13
UNCHANGED_COUNT: 0
