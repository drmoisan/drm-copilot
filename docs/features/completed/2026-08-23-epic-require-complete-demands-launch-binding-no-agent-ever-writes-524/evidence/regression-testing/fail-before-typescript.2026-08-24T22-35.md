# Fail-Before — TypeScript Regression Test [P2-T4] [expect-fail]

Timestamp: 2026-08-24T22-35

Task: [P2-T4]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586\extensions\drm-copilot`
Test added in [P2-T3]: `skips launch binding for a feature with no launch paths under requireComplete` in `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding.test.ts` (line 126, inside the `epic child launch binding` describe block)

Command: `node run-jest.cjs test/lib/validate/epic-orchestrator-state-launch-binding.test.ts -t "skips launch binding for a feature with no launch paths under requireComplete"`

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:

- **1 failed, 0 passed** for the named test. 23 skipped (deselected by the `-t` name filter), 24 total.
- Test Suites: 1 failed, 1 total.
- Failing test: `epic child launch binding > skips launch binding for a feature with no launch paths under requireComplete`.
- Failure mode: `expect(received).toEqual(expected)` deep-equality failure at `test/lib/validate/epic-orchestrator-state-launch-binding.test.ts:147:20`.
- The unfixed validator returned **4 launch-binding errors** where the test asserts an empty array. All four are launch-binding errors and none is a completion error.
- Snapshots: 0. Wall time: 0.498 s.

The four launch-binding errors the unfixed TypeScript validator returned, listed in order:

1. `Epic checkpoint feature 'child-a' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.`
2. `Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.`
3. `Epic checkpoint feature 'child-a' launch binding.delegation_receipt must be an object.`
4. `Epic checkpoint feature 'child-a' launch binding.model_routing_receipt must be an object.`

These four strings are byte-identical to the four returned by the Python validator in [P2-T2], which confirms the parity relation holds at the fail-before boundary as well as after the fix.

Failure output, verbatim:

```
FAIL test/lib/validate/epic-orchestrator-state-launch-binding.test.ts
  ● epic child launch binding › skips launch binding for a feature with no launch paths under requireComplete

    expect(received).toEqual(expected) // deep equality

    - Expected  - 1
    + Received  + 6

    - Array []
    + Array [
    +   "Epic checkpoint feature 'child-a' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.",
    +   "Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.",
    +   "Epic checkpoint feature 'child-a' launch binding.delegation_receipt must be an object.",
    +   "Epic checkpoint feature 'child-a' launch binding.model_routing_receipt must be an object.",
    + ]

     146 |     // Assert: a complete epic with no launch evidence satisfies the gate.
    >147 |     expect(errors).toEqual([]);
         |                    ^
     148 |   });

      at Object.<anonymous> (test/lib/validate/epic-orchestrator-state-launch-binding.test.ts:147:20)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 23 skipped, 24 total
Snapshots:   0 total
Time:        0.498 s, estimated 1 s
Ran all test suites matching test/lib/validate/epic-orchestrator-state-launch-binding.test.ts with tests matching "skips launch binding for a feature with no launch paths under requireComplete".
```

Note on the diff header: Jest reports `+ Received + 6` because the received value renders as six lines (the `Array [` opening line, four error strings, and the closing `]`). The error count is four, as enumerated above.

Expect-fail rationale: a failing test is the correct and required outcome for this task. It establishes fail-before evidence for the Phase 3 parity change. The matching pass-after run is the acceptance condition of [P3-T4].
