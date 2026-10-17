# P4-T1 Whole validate directory re-run after the fix

Timestamp: 2026-09-30T07-38
Command: npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate
EXIT_CODE: 0
Output Summary:
- `Test Suites: 62 passed, 62 total`; `Tests:       1165 passed, 1165 total`; zero failed.
- Derivation: BASELINE_DIR_PASSED (P0-T9) 1123 + 15 (corpus reader) + 4 (routing-contract regression) + RESOLVER_PASSED (P3-T5) 23 = 1165. Observed 1165 equals derived 1165.
- No pre-existing test file in the directory was edited, so equality shows every existing checkpoint validates as before.
