# AC 2 Extractors Use the Shared Pattern (P10-T2)

Timestamp: 2026-09-26T20-29
Branch: N588

Command: grep -c -F -e "ISSUE_REFERENCE_PATTERN" scripts/dev_tools/pr_context/feature_docs.py
EXIT_CODE: 0
Output Summary: Printed `2` (import plus use).

Command: grep -c -F -e "ISSUE_REFERENCE_PATTERN" scripts/dev_tools/pr_context/render_pr_helpers.py
EXIT_CODE: 0
Output Summary: Printed `2`.

Command: grep -c -F -e "ISSUE_REFERENCE_PATTERN" scripts/dev_tools/pr_context/render_feature_excerpts.py
EXIT_CODE: 0
Output Summary: Printed `2`.

Command: grep -c -F -e "ISSUE_REFERENCE_PATTERN" extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts
EXIT_CODE: 0
Output Summary: Printed `2`.

Command: grep -c -F -e "ISSUE_REFERENCE_PATTERN" extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts
EXIT_CODE: 0
Output Summary: Printed `2`.

Command: grep -c -F -e "ISSUE_REFERENCE_PATTERN" extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts
EXIT_CODE: 0
Output Summary: Printed `2`.

Command: grep -c -F -e '"extract_issue_references",' scripts/dev_tools/pr_context/collector.py
EXIT_CODE: 0
Output Summary: Printed `1`. The Python extractor name remains in the collector export list.

Command: grep -c -F -e "extractIssueReferences," extensions/drm-copilot/src/lib/pr-context/index.ts
EXIT_CODE: 0
Output Summary: Printed `1`. The TypeScript extractor name remains in the barrel export.

Overall: each of the six counts is at least 2 and both export counts are 1. Extractor names and signatures are exercised by the passing [P6-T13] run (`evidence/regression-testing/py-unit-tests.2026-09-25T23-29.md`, EXIT_CODE 0, `276 passed`) and [P7-T6] run (`evidence/regression-testing/ts-unit-tests.2026-09-25T23-29.md`, EXIT_CODE 0, `197 passed, 197 total`).
