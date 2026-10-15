# Baseline Targeted Jest (P0-T16)

Timestamp: 2026-10-10T08-04
Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts test/lib/push-down/claude-gitignore-merge.test.ts test/lib/push-down/claude-gitignore-delivery.test.ts
EXIT_CODE: 0
Output Summary:
- `Test Suites: 3 passed, 3 total`
- `Tests:       35 passed, 35 total`
- Adapter suite count: 23 tests (matches planning-time 23). The default (non-verbose) reporter prints no per-suite count, so the count was derived from two supplementary micro-actions: `npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-filesystem-adapter.test.ts` (EXIT 0, `Tests: 23 passed, 23 total`) and `git grep --no-index -c -E "^  it\(" -- extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts` (printed 23).
- Remaining two suites (gitignore-merge, gitignore-delivery): 12 tests combined.
- Execution note: a first invocation of the targeted command was run with an added `--verbose` flag (EXIT 0, same 35 passed); it was discarded and the exact plan command above was rerun for this record.
