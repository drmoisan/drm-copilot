# Baseline Issue-Adoption Corpus Count (Issue #849)

Timestamp: 2026-10-10T09-50
Task: P0-T3
Command: Method 1: Glob tool, pattern `*.json`, path tests/fixtures/orchestrator_state_issue_adoption (non-recursive). Method 2: Grep tool, regex `^  "name": `, content mode, path tests/fixtures/orchestrator_state_issue_adoption (also run in count mode with no file filter).
EXIT_CODE: 0

## Method 1 member set (Glob `*.json`, `.json` stripped) — 29 members

A Glob of `*` over the same directory returned the same 29 files, so the directory holds no non-JSON file.

1. absent-key-large-missing-receipt
2. adoption-error-precedes-local-execution-overrides
3. blank-evidence
4. blank-verified-at
5. bug-waives-feature-entry-tool
6. case-variant-tool-name
7. declared-list-omits-potential-to-issue
8. duplicate-waived-tool
9. empty-waived-tools
10. integer-issue-num
11. invalid-potential-record
12. issue-num-mismatch
13. issue-url-mismatch
14. leading-zero-issue-num
15. multiple-field-errors-in-rule-order
16. non-list-waived-tools
17. non-object-adoption-string
18. null-adoption
19. remediation-route-adoption
20. unknown-origin
21. unknown-verified-via
22. valid-bug-large-waives-bug-entry-tool-with-record
23. valid-large-waives-feature-entry-tool-with-record
24. valid-large-waives-potential-to-issue
25. valid-preparation-waives-potential-to-issue
26. waived-tools-omits-potential-to-issue
27. waives-new-active-feature-folder
28. waives-tool-with-successful-receipt
29. waives-validate-orchestration-artifacts

## Method 2 member set (Grep `^  "name": `, top-level `name` values, sorted) — 29 members

Count mode reported "Found 29 total occurrences across 29 files." Each match is on line 2 of its file, and each `name` value equals its file stem.

1. absent-key-large-missing-receipt
2. adoption-error-precedes-local-execution-overrides
3. blank-evidence
4. blank-verified-at
5. bug-waives-feature-entry-tool
6. case-variant-tool-name
7. declared-list-omits-potential-to-issue
8. duplicate-waived-tool
9. empty-waived-tools
10. integer-issue-num
11. invalid-potential-record
12. issue-num-mismatch
13. issue-url-mismatch
14. leading-zero-issue-num
15. multiple-field-errors-in-rule-order
16. non-list-waived-tools
17. non-object-adoption-string
18. null-adoption
19. remediation-route-adoption
20. unknown-origin
21. unknown-verified-via
22. valid-bug-large-waives-bug-entry-tool-with-record
23. valid-large-waives-feature-entry-tool-with-record
24. valid-large-waives-potential-to-issue
25. valid-preparation-waives-potential-to-issue
26. waived-tools-omits-potential-to-issue
27. waives-new-active-feature-folder
28. waives-tool-with-successful-receipt
29. waives-validate-orchestration-artifacts

## Comparison

Method 1 count: 29. Method 2 count: 29. After stripping `.json`, the two member sets are identical: no member is missing from either side and neither set contains a duplicate.

Output Summary: Baseline corpus count = 29 by both methods; member sets identical. No BLOCKED condition.
