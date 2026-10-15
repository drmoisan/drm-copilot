# QA gate: AC-4 shared comparator unit tests (P4-T10, pass 2)

Timestamp: 2026-10-09T23-21
Command: cd extensions/drm-copilot && npm test -- --runTestsByPath test/lib/string-ordering.test.ts
EXIT_CODE: 0
Output Summary:
- Test Suites: 1 passed, 1 total
- Tests:       23 passed, 23 total
- AC-4 clause to named test (all 12 titles confirmed present in test/lib/string-ordering.test.ts by a fixed-string search that returned 12 lines):
  - Equal strings: "returns 0 for identical strings"
  - Empty and proper prefix: "treats the empty string as less than a non-empty string", "orders a prefix before its longer extension"
  - BMP-only ordering: "returns -1 when left sorts before right"
  - Supplementary versus U+E000 and U+FFFF: "D1 orders U+FFFF before U+1F600 in both argument orders", "D2 orders U+E000 before U+10000"
  - Results restricted to -1, 0, 1: "returns only -1, 0, or 1 for every ordered pair in the domain"
  - Antisymmetry and enumerative checks: "is reflexive for every value in the domain", "is antisymmetric for every ordered pair in the domain", "is transitive for every ordered triple in the domain" - over the 15-value domain containing a lone high surrogate (U+D800), a lone low surrogate (U+DC00), U+D800 followed by U+E000, U+E000, U+FFFF, and supplementary characters (U+1F600, U+10000)
  - Research triple: "issue #796 orders the research triple without a cycle" (the domain also contains all three triple members, and the transitivity test passes on it)
  - Well-formed equivalence: "matches code-point-sequence order for every well-formed pair in the domain"
- Fail-before counterpart: evidence/regression-testing/fail-before-string-ordering.2026-10-09T21-50.md.
- Result: PASS.
