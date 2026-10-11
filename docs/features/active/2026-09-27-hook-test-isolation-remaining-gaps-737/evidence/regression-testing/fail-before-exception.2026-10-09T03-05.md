# P2-T9 AC-13 fail-before disposition

Timestamp: 2026-10-09T03-05
Command: git grep -c "AC-13 non-compliant" origin/epic/enforcement-hook-precision-integration -- tests/scripts/claude-hooks (run through pwsh -NoProfile -File; printed GIT-GREP-OUTPUT-LINES: 0 and GIT-GREP-EXIT: 1)
EXIT_CODE: 0
Output Summary:
Source artifact: evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md. The seven AC-13 non-compliant rows are dispositioned below; the six PASSED-BEFORE rows have a dossier entry.

DISPOSITION: AC-13 non-compliant no outermost BeforeAll | PASSED-BEFORE
DISPOSITION: AC-13 non-compliant ESR-side import absent with mock present | PASSED-BEFORE
DISPOSITION: AC-13 non-compliant no dot-source at all in the BeforeAll | PASSED-BEFORE
DISPOSITION: AC-13 non-compliant colon-bound -ModuleName form with a wrong module name | PASSED-BEFORE
DISPOSITION: AC-13 non-compliant MockWith body containing a param block | PASSED-BEFORE
DISPOSITION: AC-13 non-compliant non-string module-name element | PASSED-BEFORE
DISPOSITION: AC-13 non-compliant parse error returned as a finding | FAILED-BEFORE

WhyFailingRunImpossible: the unmodified predicate already handles each of the six PASSED-BEFORE fixtures (it returns a finding for each), so a row that asserts that finding passes before any change. This is the plan's PI-3 case. The seventh row fails before for a different reason: Get-EpicStateIsolationTextFinding does not exist in the unmodified helper (CommandNotFoundException), which P2-T15 creates.

Absence-of-test proof: git grep -c "AC-13 non-compliant" origin/epic/enforcement-hook-precision-integration -- tests/scripts/claude-hooks printed nothing and exited 1, so no row for any of these branches exists at the base ref. The literal AC-13 non-compliant is the row-name prefix that P2-T7 creates.

SearchScope: origin/epic/enforcement-hook-precision-integration, path tests/scripts/claude-hooks
SearchPatterns: AC-13 non-compliant
SearchResult: none
