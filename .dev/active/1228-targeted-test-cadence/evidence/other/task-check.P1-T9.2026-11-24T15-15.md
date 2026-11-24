# Task Check - [P1-T9] - Issue #1228, remediation cycle 2

Timestamp: 2026-11-24T15-15
Plan: remediation-plan.2026-11-24T10-50.md
Kind: task check (not a gate; no coverage measured; not coverage evidence)
Command: Edit-tool edits of `.dev/active/1228-targeted-test-cadence/spec.md`; `pwsh -NoProfile -Command` count of the `RSCOPE-READ`, `RSCOPE-HOOK`, `RSCOPE-CONTRACT`, `RSCOPE-CODEX`, `RSCOPE-LAUNCH`, and `RSCOPE-DOC` test cases and their status in the [P1-T8] JUnit copy (SCRATCH/issue-1228-c2gate-c2g2-junit.xml); `grep -c "^- \[x\] AC-"` and `grep -c "^- \[ \] AC-"` of the spec; `git diff -U0 -- .dev/active/1228-targeted-test-cadence/spec.md` filtered to removed checkbox lines
EXIT_CODE: 0
Output Summary:
- Changed file: `.dev/active/1228-targeted-test-cadence/spec.md`. `AC-20` and `AC-21` changed from `- [ ]` to `- [x]` per the `acceptance-criteria-tracking` skill; the criterion text is unchanged, and each item gains one indented `Evidence:` line naming `evidence/qa-gates/remediation-gate.2026-11-24T15-14.md` and its verifying rows.
- Verifying rows in the [P1-T8] run (all passed): `RSCOPE-READ` 46, `RSCOPE-HOOK` 8, `RSCOPE-CONTRACT` 1, `RSCOPE-CODEX` 3 (AC-20); `RSCOPE-LAUNCH` 43, `RSCOPE-DOC` 8 (AC-21); 0 not passed.
- Checkbox state: 21 checked `AC-` items, 0 unchecked; the diff removes no checkbox line, so no other checkbox changed (the four `## Definition of Done` items are unchanged).
- Selection and rule: no test reads `spec.md` (`git grep -l "targeted-test-cadence/spec.md" -- tests` returns no file); no suite runs.
- Result: PASS.
