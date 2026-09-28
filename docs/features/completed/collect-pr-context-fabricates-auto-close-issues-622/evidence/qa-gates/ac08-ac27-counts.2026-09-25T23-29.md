# AC 8 and AC 27 Documentation Counts (P10-T4)

Timestamp: 2026-09-26T20-31
Branch: N588

Command: grep -c -F -e "bare-number" scripts/dev_tools/pr_context/feature_docs.py
EXIT_CODE: 0
Output Summary: Printed `1`.

Command: grep -c -F -e "bare-number" scripts/dev_tools/pr_context/render_pr_helpers.py
EXIT_CODE: 0
Output Summary: Printed `1`.

Command: grep -c -F -e "bare-number" scripts/dev_tools/pr_context/render_feature_excerpts.py
EXIT_CODE: 0
Output Summary: Printed `1`.

Command: grep -c -F -e "bare-number" extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts
EXIT_CODE: 0
Output Summary: Printed `1`.

Command: grep -c -F -e "bare-number" extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts
EXIT_CODE: 0
Output Summary: Printed `1`.

Command: grep -c -F -e "bare-number" extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts
EXIT_CODE: 0
Output Summary: Printed `1`.

Command: grep -c -F -e "pending_primary_excluded" scripts/dev_tools/pr_context/render_pr_helpers.py
EXIT_CODE: 0
Output Summary: Printed `3` (at least 3 required).

Command: grep -c -F -e "pendingPrimaryExcluded" extensions/drm-copilot/src/lib/pr-context/autoclose.ts
EXIT_CODE: 0
Output Summary: Printed `4` (at least 3 required).

Overall: each of the six `bare-number` counts is at least 1 and both parameter counts are at least 3.
