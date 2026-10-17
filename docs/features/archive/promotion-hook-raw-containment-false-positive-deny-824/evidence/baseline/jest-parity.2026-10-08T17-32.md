# Baseline: Jest Parity and Manifest-Completeness Tests

Timestamp: 2026-10-08T17-32

## Step 1

Command: npm --prefix extensions/drm-copilot ci
EXIT_CODE: 0
Output Summary: added 452 packages, audited 453 packages; npm reported 1 critical severity vulnerability in the dependency tree (pre-existing, out of scope for this plan).

## Step 2

Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/push-down/claude-customizations.test.ts test/lib/push-down/codex-agents-customizations.test.ts
EXIT_CODE: 0
Output Summary:
Test Suites: 3 passed, 3 total
Tests:       42 passed, 42 total
B_JS (failing test names): (empty set)
