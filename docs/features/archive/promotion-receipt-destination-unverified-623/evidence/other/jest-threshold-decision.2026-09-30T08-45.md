# Jest Coverage Threshold Decision for promotion.ts (#623)

Timestamp: 2026-09-30T08-45
Command: grep -c -F -e "./src/lib/potential-to-issue/promotion.ts" extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary: DECISION: ADDED. P6-T1 measured promotion.ts at line 98.89% (445/450) and branch 83.82% (57/68), meeting the 85/75 rule. The entry was inserted immediately after the "./src/lib/potential-to-issue/potential-to-issue-service-call.ts" entry (located by entry text, now near line 334 after the origin/main merge); the grep count is 1.

DECISION: ADDED

- P6-T1 promotion.ts line percent: 98.89
- P6-T1 promotion.ts branch percent: 83.82
- Inserted text: the comment `// Issue #623: promotion.ts gained the post-move destination check, so it sits behind the same per-file gate as the rest of this cluster.` followed by the `"./src/lib/potential-to-issue/promotion.ts"` entry with `lines: 85` and `branches: 75`, in the same multi-line form as the neighboring entries.
