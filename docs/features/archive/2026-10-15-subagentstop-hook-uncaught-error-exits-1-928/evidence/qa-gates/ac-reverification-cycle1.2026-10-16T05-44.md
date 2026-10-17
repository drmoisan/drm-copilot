# AC Re-verification (remediation cycle 1, P5-T1)

Timestamp: 2026-10-16T05-44
Command: grep -c -F -e "- [x] AC" docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md
EXIT_CODE: 0
Output Summary: 14 checked, 2 unchecked (AC14 and AC15, awaiting CI at S9); every AC touched by this cycle remains TRUE. Artifacts are under FEATURE/evidence/qa-gates/ unless noted.

- AC4: TRUE - limited-diff.2026-10-16T05-41.md: helper hunk `@@ -12,2 +12,3 @@` inside the help block (closing `#>` at line 19); the whitespace-normalized CYCLE_BASE and current texts are identical for the helper (lines 12-13 vs 12-14) and the test (lines 9-10 vs 9-11). The line-12 reference in AC4 and AC9 denotes the citation's starting line.
- AC5: TRUE - poshqc-test.2026-10-16T05-39.md: the nine U1 rows pass; the two U1-ST rows are additional rows with the same constraints (test-file-constraints.2026-10-16T05-22.md: banned-token count 0).
- AC6: TRUE - poshqc-test.2026-10-16T05-39.md: U2 passes; the U2 table (`$script:ValidatorRows` / `$script:TableHooks`) is unchanged, since U1-ST rows live in `$script:StatementTerminatingRows`.
- AC8: TRUE - mirror-hashes.2026-10-16T05-40.md (14 pairs IDENTICAL) and pytest-bundle-parity.2026-10-16T05-40.md (14 passed, EXIT_CODE 0).
- AC9: TRUE - citation-width.2026-10-16T05-41.md: counts 1, 0, 1 in the helper, its mirror, and the test; the archive path starts at helper line 12, mirror line 12, test line 9.
- AC10: TRUE - architecture-doc-tokens.2026-10-16T05-26.md: "exits with code 1 and blocks" 0, "exits with code 2, which blocks" 1, "raises an unhandled error" 1.
- AC11: TRUE - limited-diff.2026-10-16T05-41.md (wave-barrier `@@ -34,2 +34,2 @@`, epic-orchestrator.md single hunk at 133) and mirror-hashes.2026-10-16T05-40.md (all corrected files and mirrors identical and unchanged this cycle).
- AC13: TRUE - poshqc-test.2026-10-16T05-39.md: hook-dependency-guard-completeness 598/0, hook-dependency-failure.Claude 148/0, claude-settings 9/0 (MATCHED/FAILED).
- AC16: TRUE - line-counts.2026-10-16T05-41.md: 159, 279, 192, 192 (all at most 500).

AC checkbox counts in spec.md:
- `grep -c -F -e "- [x] AC"` -> 14 (unchanged)
- `grep -c -F -e "- [ ] AC"` -> 2 (AC14, AC15)
