Timestamp: 2026-03-14T11:43:49.2729416-04:00
Constrained Target: extensions/drm-copilot/src/extension.ts
Constrained Target: extensions/drm-copilot/test/extension.potential-to-issue.test.ts
Reason: "The live handler in `extensions/drm-copilot/src/extension.ts` currently calls `showOpenDialog()` unconditionally for `drmCopilotExtension.potentialToIssue`, so it has no active-editor auto-resolve path. The focused Jest coverage in `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` also only verifies the file-picker flow today."
Reason: "- [x] Unit coverage areas — add Jest coverage for active-editor auto-resolve, fallback behavior, and retention of the promotion/work-mode quick picks."
Reason: "- [x] Integration scenario to retest — run the extension command in a destination workspace with an active `docs/features/potential/*.md` file and verify the bundled script argv."
Reason: "- [x] Manual verification notes — confirm the command still falls back cleanly when there is no valid active potential file."
