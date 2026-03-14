Timestamp: 2026-03-14T11:48:59.0000000-04:00
Command: npm --prefix extensions/drm-copilot run test:unit
EXIT_CODE: 1
Output Summary: EXPECTED FAIL; the new active-editor auto-resolve, promotion-type quick-pick, and work-mode quick-pick regressions failed before the handler fix while the remaining extension suites still passed.
Failure: reuses the active potential editor path before falling back to the file picker — showOpenDialogMock was called once, proving the handler still opened the picker instead of reusing the active potential markdown file.
Failure: keeps the promotion-type quick pick after active-editor auto-resolution — showQuickPickMock was never called because the command returned before prompting for promotion type.
Failure: keeps the work-mode quick pick after active-editor auto-resolution — showQuickPickMock was never called for the follow-up work-mode selection.
