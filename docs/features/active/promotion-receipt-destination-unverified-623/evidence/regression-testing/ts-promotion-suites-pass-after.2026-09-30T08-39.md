# TypeScript Existing Promotion Suites Pass-After (#623)

Timestamp: 2026-09-30T08-39
Command: npm --prefix extensions/drm-copilot test -- test/lib/potential-to-issue/promotion test/lib/promotion-lifecycle-sequence --verbose
EXIT_CODE: 0
Output Summary: `Test Suites: 5 passed, 5 total`; `Tests:       36 passed, 36 total`; 0 failed. The five suites are promotion.test.ts, promotion.matrix.test.ts, promotion.missing-label.test.ts, promotion.move-verification.test.ts, and promotion-lifecycle-sequence.test.ts; the title `creates the issue, updates metadata, and moves the file` passed.

## Jest output (verbatim)

```
> drm-copilot@1.1.17 test
> node run-jest.cjs test/lib/potential-to-issue/promotion test/lib/promotion-lifecycle-sequence --verbose

Test Suites: 5 passed, 5 total
Tests:       36 passed, 36 total
Snapshots:   0 total
Time:        0.339 s, estimated 1 s
Ran all test suites matching test/lib/potential-to-issue/promotion|test/lib/promotion-lifecycle-sequence.
```

## Planning-assumption deviation and supplementary run

The plan states that `--verbose` makes Jest print per-test titles for a multi-file run. In this environment the run above printed only the summary block (no PASS lines and no titles), both on the terminal and when redirected to a file. To name the suites and titles, the same selection plus the service-call suite was re-run with `--json --outputFile=<scratch path>`, and the JSON was read with `node`:

Supplementary command: npm --prefix extensions/drm-copilot test -- test/lib/potential-to-issue/promotion test/lib/promotion-lifecycle-sequence potential-to-issue-service-call.test --json --outputFile=<scratch path outside the repository>
Supplementary EXIT_CODE: 0 (`Test Suites: 6 passed, 6 total`; `Tests:       48 passed, 48 total`; 48 = 36 from the planned selection + 12 service-call tests)

```
SUITE passed test/lib/potential-to-issue/potential-to-issue-service-call.test.ts  (12 passed; listed in ts-service-call-pass-after)
SUITE passed test/lib/promotion-lifecycle-sequence.test.ts
  passed :: promotion lifecycle sequence retains the promoted record across potential_to_issue then new_active_feature_folder
SUITE passed test/lib/potential-to-issue/promotion.test.ts
  passed :: promotePotential — input validation throws a PromotionError for an invalid promotion type
  passed :: promotePotential — input validation throws a PromotionError for an invalid work mode
  passed :: promotePotential — input validation throws the auth error when gh is not authenticated
  passed :: promotePotential — input validation throws not-found using the original path argument
  passed :: promotePotential — input validation throws empty using the resolved path
  passed :: promotePotential — feature promotion success creates the issue, updates metadata, and moves the file
  passed :: promotePotential — failure path returns the create exit code and does not move on a non-zero, non-label failure
  passed :: promotePotential — failure path emits a synthetic line when create output is empty
  passed :: promotePotential — bug promotion routes through the bug-section body
  passed :: promotePotential — bug promotion fills missing bug sections with placeholders
  passed :: promotePotential — minor-audit routing routes through the minor-audit body with the default Evidence Checklist
  passed :: promotePotential — minor-audit routing persists the minor-audit work-mode marker above the first section
  passed :: promotePotential — bug promotion in minor-audit mode (AC-1) routes a populated bug potential to the bug body under minor-audit with the minor-audit marker
  passed :: promotePotential — work-mode normalization normalizes the legacy full alias to full-feature for feature work
  passed :: promotePotential — work-mode normalization re-wraps an incompatible work-mode/type combination as a PromotionError
SUITE passed test/lib/potential-to-issue/promotion.matrix.test.ts
  passed :: buildIssueBody routing matrix (AC-2) routes (feature, minor-audit) to the minor-audit body
  passed :: buildIssueBody routing matrix (AC-2) routes (refactor, minor-audit) to the minor-audit body
  passed :: buildIssueBody routing matrix (AC-2) routes (epic, minor-audit) to the minor-audit body
  passed :: buildIssueBody routing matrix (AC-2) routes (bug, full-bug) to the bug body
  passed :: buildIssueBody routing matrix (AC-2) routes (bug, full) to the bug body
  passed :: buildIssueBody routing matrix (AC-2) routes (feature, full-feature) to the full-feature body
  passed :: buildIssueBody routing matrix (AC-2) routes (feature, full) to the full-feature body
  passed :: buildIssueBody routing matrix (AC-2) throws for (bug, full-feature) before building a body
  passed :: buildIssueBody routing matrix (AC-2) throws for (feature, full-bug) before building a body
  passed :: buildIssueBody bug minor-audit partial sections (AC-1 edge) emits placeholders only for empty bug sections while populated ones carry content
SUITE passed test/lib/potential-to-issue/promotion.missing-label.test.ts
  passed :: promotePotential — missing-label recovery recovers from a missing-label create failure and moves the file
  passed :: promotePotential — missing-label recovery does not retry when ensureLabel returns a non-zero exit
  passed :: promotePotential — missing-label recovery existing label uses a single create attempt with no ensureLabel
  passed :: promotePotential — smart punctuation and emitted lines normalizes smart punctuation in the title and body
  passed :: promotePotential — smart punctuation and emitted lines emits the expected lines in order on the success path
  passed :: isMissingLabelFailure matches case-insensitively for the specific label fragment
  passed :: isMissingLabelFailure does not match a different label
  passed :: isMissingLabelFailure does not match unrelated output
SUITE passed test/lib/potential-to-issue/promotion.move-verification.test.ts
  passed :: promotePotential — post-move destination verification returns exit code 1 without a destination when the promoted file is missing after the move
  passed :: promotePotential — post-move destination verification returns exit code 0 with the destination when the promoted file exists after the move
```

Per-suite counts for the planned selection: lifecycle 1 + promotion 15 + matrix 10 + missing-label 8 + move-verification 2 = 36, matching the planned run's `Tests:` line.
