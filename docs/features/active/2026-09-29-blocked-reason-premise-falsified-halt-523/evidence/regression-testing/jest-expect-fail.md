# P2-T10 Jest partition and parity suites before the fix (expect-fail)

Timestamp: 2026-09-30T10-41
Command: (from extensions/drm-copilot) npm run test:unit -- test/lib/validate/orchestrator-state-blocked-reason.test.ts test/lib/validate/orchestrator-state-blocked-reason-parity.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `Test Suites: 2 failed, 2 total`
- `Tests:       7 failed, 42 passed, 49 total`
- `orchestrator-state-blocked-reason.test.ts`: `Test suite failed to run` with `Cannot find module '../../../src/lib/validate/orchestrator-state-blocked-reason'`.
- `orchestrator-state-blocked-reason-parity.test.ts`: 7 failures, all on new-member cases: plain-error equality for `accepts_awaiting_ci`, `accepts_external_dependency`, `accepts_human_decision_required_without_human_interaction`, `accepts_policy_hold`, `accepts_premise_falsified`, `completion_blocks_premise_falsified`, and completion-error equality for `completion_blocks_premise_falsified`.
- Result: expected failure observed.
