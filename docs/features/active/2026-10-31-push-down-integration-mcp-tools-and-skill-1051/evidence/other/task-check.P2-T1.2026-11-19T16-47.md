Timestamp: 2026-11-19T16-47
Task: [P2-T1]
Changed files:
- extensions/drm-copilot/src/lib/push-down/push-down-integration-needed.ts (new)
- extensions/drm-copilot/src/lib/push-down/push-down-harness.ts (one call site; result report type widened to carry integration_needed)
- extensions/drm-copilot/src/lib/push-down/push-down-ecosystem-registry.ts (INTEGRATION_NEEDED_RELATIVE_PATH added to the root-level assertion through RESERVED_ROOT_LEVEL_PATHS)
- extensions/drm-copilot/test/lib/push-down/push-down-integration-needed.test.ts (new)
- ITEM tests updated (each now asserts the integration item its fixture yields; S12 and S14): push-down-harness.ci-workflows.test.ts (withholds the caller when another workflow is named CI, including in a dry run; writes the data file exactly in reference, copy, and withheld-caller runs; reports unmanaged-conflict at a CI path even with overwriteUnmanaged true (%s); keeps an edited managed caller as conflict), push-down-harness.real-bundle.test.ts (keeps a local edit and reports conflict; first run without a manifest adopts and reports unmanaged-conflict), push-down-service-call.test.ts (routes conflict, unmanaged-conflict and deleted-locally lines to warnings and log), push-down-wrapper-compatibility.test.ts (forwards overwrite_unmanaged to the harness (%s)). None of them pinned the whole write set or deep-equalled push_down_report, so the update adds assertions rather than replacing expected sets.
- ROOT-LIST test updated: push-down-ecosystem-registry.test.ts (rejects a layer root or root-file destination that captures a reserved root-level path (%s)) gains two cases for the integration-needed file and a regex that accepts its name.
- NO-ITEM tests unchanged.
- push-down-apply.ts not edited.
Selection: every Jest test path matching `push-down` (the mirrored tests of the three production files and every test that imports the harness, registry, service calls or the new writer); rule: atomic-plan-contract Test Cadence task check.
Commands and exit codes (from extensions/drm-copilot through the SCRATCH task-check script):
- npx prettier --write, then npx prettier --check <changed files>: EXIT_CODE 0
- npx eslint <changed files>: EXIT_CODE 0
- npx tsc -p ./ --noEmit && npx tsc -p tsconfig.jest.json --noEmit: EXIT_CODE 0
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension push-down: EXIT_CODE 0 (Test Suites: 71 passed, 71 total; Tests: 984 passed, 984 total)
Rule tokens present in push-down-integration-needed.test.ts: S1, S7, S10, S11, S12, S13, S14 (positive and negative).
Physical lines: push-down-harness.ts 301, push-down-ecosystem-registry.ts 162, push-down-integration-needed.ts 284.
EXIT_CODE: 0
Output Summary: task check passed.
