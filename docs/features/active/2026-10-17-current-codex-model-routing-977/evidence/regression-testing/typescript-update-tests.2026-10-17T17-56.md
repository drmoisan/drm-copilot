Timestamp: 2026-10-17T17:56:15.229336+00:00
Command: node run-jest.cjs --runTestsByPath test/lib/validate/codex-deployment.test.ts test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/validate/epic-planner-state-launch-binding.test.ts test/lib/validate/epic-planner-state-feature-receipts.test.ts test/lib/validate/epic-planner-state-core.test.ts test/lib/validate/epic-planner-readiness-integrity.test.ts test/lib/validate/epic-planner-launch-evidence.test.ts test/lib/push-down/codex-bundle-publish.integration.test.ts
EXIT_CODE: 1
Output Summary:

- a file is near or would exceed the 500-line limit,
    - any QA gate delta is non-zero after self-correction,
    - the toolchain cannot be executed in the current environment (mark the change **unverified**),
    - orchestrator handoff mode is requested but the required context package is incomplete,
    - policy instructions conflict.·
    ## Evidence Location Invariant·
    All evidence artifacts this agent produces (baselines, QA gates, regression results, coverage) MUST be written to `<FEATURE>/evidence/<kind>/` as defined in `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`.·
    Writing to `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical path is a policy violation and will be caught by the `enforce-evidence-locations.ps1` PreToolUse hook.·
    If a delegation prompt, plan, or caller instruction specifies a non-canonical evidence path (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/`), this agent ignores that instruction, writes to the canonical `<FEATURE>/evidence/<kind>/` path, and records the override as `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
    '''
    "

      118 |       "/dest/.codex/agents/csharp-typed-engineer.toml",
      119 |     );
    > 120 |     expect(roleText).toContain('model = "gpt-6.1-sol"');
          |                      ^
      121 |     expect(roleText).not.toMatch(/^variant\s*=/m);
      122 |   });
      123 | });

      at Object.<anonymous> (test/lib/push-down/codex-bundle-publish.integration.test.ts:120:22)


Test Suites: 1 failed, 8 passed, 9 total
Tests:       1 failed, 151 passed, 152 total
Snapshots:   0 total
Time:        1.017 s, estimated 3 s
Ran all test suites within paths "test/lib/validate/codex-deployment.test.ts", "test/lib/validate/orchestrator-state-codex-model-routing.test.ts", "test/lib/validate/orchestrator-state-codex-topology.test.ts", "test/lib/validate/epic-planner-state-launch-binding.test.ts", "test/lib/validate/epic-planner-state-feature-receipts.test.ts", "test/lib/validate/epic-planner-state-core.test.ts", "test/lib/validate/epic-planner-readiness-integrity.test.ts", "test/lib/validate/epic-planner-launch-evidence.test.ts", "test/lib/push-down/codex-bundle-publish.integration.test.ts".

Full sanitized output: SCRATCH/issue-977-regression-testing-typescript-update-tests.log
