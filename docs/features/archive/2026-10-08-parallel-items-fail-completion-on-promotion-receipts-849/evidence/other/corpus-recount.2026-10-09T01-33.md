# Issue-Adoption Corpus Recount (P1-T6, Issue #849)

Timestamp: 2026-10-10T10-16
Command: Method 1: Glob tool, pattern `*.json`, path `tests/fixtures/orchestrator_state_issue_adoption` (non-recursive). Method 2: Grep tool, content mode, regex `^  "name": `, same path.
EXIT_CODE: 0

## Method 1 (file-name enumeration, `.json` stripped), 34 members

1. absent-key-large-missing-receipt
2. adoption-error-precedes-local-execution-overrides
3. blank-evidence
4. blank-verified-at
5. bug-waives-feature-entry-tool
6. case-variant-tool-name
7. declared-list-omits-potential-to-issue
8. duplicate-waived-tool
9. empty-waived-tools
10. epic-decomposition-waives-entry-tool-without-record
11. filed-before-orchestration-invalid-present-record
12. integer-issue-num
13. invalid-potential-record
14. issue-num-mismatch
15. issue-url-mismatch
16. leading-zero-issue-num
17. multiple-field-errors-in-rule-order
18. non-list-waived-tools
19. non-object-adoption-string
20. null-adoption
21. remediation-route-adoption
22. unknown-origin
23. unknown-verified-via
24. valid-bug-large-filed-before-orchestration-without-record
25. valid-bug-large-waives-bug-entry-tool-with-record
26. valid-bug-preparation-filed-before-orchestration-without-record
27. valid-large-transferred-waives-feature-entry-tool-without-record
28. valid-large-waives-feature-entry-tool-with-record
29. valid-large-waives-potential-to-issue
30. valid-preparation-waives-potential-to-issue
31. waived-tools-omits-potential-to-issue
32. waives-new-active-feature-folder
33. waives-tool-with-successful-receipt
34. waives-validate-orchestration-artifacts

## Method 2 (top-level `name` values), 34 members

Grep returned 34 matching lines, one per file. Each `name` value equals its file's stem, and the sorted set of values is identical to the Method 1 list above (items 1-34).

## Comparison

- Method 1 count: 34. Method 2 count: 34.
- Set difference (Method 1 minus Method 2): none. Set difference (Method 2 minus Method 1): none.
- The 34 members are the 29 baseline members from `evidence/baseline/corpus-count.2026-10-09T01-33.md` plus the five P1 stems: valid-bug-preparation-filed-before-orchestration-without-record, valid-bug-large-filed-before-orchestration-without-record, valid-large-transferred-waives-feature-entry-tool-without-record, epic-decomposition-waives-entry-tool-without-record, filed-before-orchestration-invalid-present-record.

Output Summary: Corpus recount 34 by both methods; member sets identical; 29 baseline plus 5 new stems. No BLOCKED condition.
