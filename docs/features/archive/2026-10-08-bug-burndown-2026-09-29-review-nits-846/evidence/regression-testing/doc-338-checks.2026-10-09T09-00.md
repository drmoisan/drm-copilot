# Regression: #338 issue.md bundled-mirror references ([P7-T16], AC-25)

Timestamp: 2026-10-09T21-39
Command: git grep -n -i -e "bundled" -- docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md
EXIT_CODE: 0
Output Summary: exactly one line, the [P7-T14] correction note (line 40; the original line numbers 66 and 68 cited by [P7-T11] and [P7-T12] are now 68 and 70 after the two-line insertion):

```
docs/features/active/2026-07-09-potential-entry-ide-launcher-audit-gaps-338/issue.md:40:Correction (#846): no bundled mirror copies of the two Python modules exist (code-review.2026-10-08T07-05.md CR-3).
```

Acceptance (AC-25): exit 0 and exactly one line printed, the correction note. PASS.
