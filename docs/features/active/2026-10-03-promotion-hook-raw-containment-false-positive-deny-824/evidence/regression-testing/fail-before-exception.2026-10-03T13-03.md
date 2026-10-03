# Fail-before exception dossier — remediation cycle 1 pass-before rows (issue #824)

Timestamp: 2026-10-03T13-03
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p1-t12.ps1 -Worktree WORKTREE (runs the WHY-COUNT check after this dossier was written)
EXIT_CODE: 0
Output Summary: the dossier carries exactly one line that begins with the WhyFailingRunImpossible key (WHY-COUNT=1; the key is assembled at run time and anchored at a line start).

WhyFailingRunImpossible: The prior cycle already replaced R2 with the token-aware matcher (plan D1), so the AC-30 reproduction is allowed by both worktree-removal gates at BASE_SHA 079ebb9fad8fab1ee24e137e5bc605fc1df1948a and A824-WT3 cannot fail on the current tree. The AC-31 deny rows (A824-WT4-1 to -5), the structural allow rows (A824-WT5-1 to -3), A824-WT7, R824-N8, F824-2, and the coverage-support rows (F824-4 to F824-9, F824-V1 to F824-V8) are preservation pins of behaviour that already holds.

Alternative proof:

- A824-WT3 asserts, in the same It, that `Test-CommandLineRawContainment` returns `$true` for the reproduction. Restoring containment-based R2 would classify the reproduction and the gate would deny it, so the test would fail; this is the AC-32 negative control.
- The P1-T10 run, FEATURE/evidence/regression-testing/r1-expect-fail-pester.2026-10-03T13-01.md, lists these rows as `PASSED:` against the unfixed tree: A824-WT3, A824-WT4-1 to A824-WT4-5, A824-WT5-1 to A824-WT5-3, and A824-WT7 in each of S6, S7, and S8; R824-N8 in U1 and U2; F824-2, F824-4 to F824-9, and F824-V1 to F824-V8 in NT1.

SearchScope: FEATURE/evidence/regression-testing/
SearchPatterns: `r1-expect-fail-*.md`, `fail-before-exception.*.md`
SearchResult: FEATURE/evidence/regression-testing/r1-expect-fail-pester.2026-10-03T13-01.md; FEATURE/evidence/regression-testing/r1-expect-fail-pytest.2026-10-03T13-02.md
