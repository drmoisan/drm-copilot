# R3 Atomic-Replace Recovery — Red Run — Issue #614 Remediation

Timestamp: 2026-09-07T02-14
Cycle: 2026-09-06T23-30
Task: [P3-T3] `[expect-fail]`
Command: `node run-jest.cjs --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer.test.ts` run from `extensions/drm-copilot`
ExpectedExitCode: 1
EXIT_CODE: 1

## 1. Test added

`discards the candidate and names it when the atomic replace fails`, driven by
`replaceFailure: true` on a `materialize` scenario. It asserts that the result carries
`HANDOFF_VALIDATOR_UNAVAILABLE`, that `affectedPaths` equals
`[candidatePathFor(scenario.envelopeSha256)]`, that the scenario's `removeFile` mock was
called once with that same candidate path, and that the source checkpoint bytes are
unchanged.

## 2. Run output

```
FAIL test/lib/validate/orchestration-handoff-materializer.test.ts
  ● orchestration handoff materializer › discards the candidate and names it when the atomic replace fails

    expect(received).toEqual(expected) // deep equality

    - Expected  - 1
    + Received  + 1

      Array [
    -   "C:/workspace/artifacts/orchestration/orchestrator-state.handoff-candidate-61124fa2eaba55694b909b0b0835d583e50c3716af4e66e2152de9bc8bb81dcf.json",
    +   "C:/workspace/artifacts/orchestration/orchestrator-state.json",
      ]

      414 |     // Assert
      415 |     expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    > 416 |     expect(result.affectedPaths).toEqual([candidatePath]);
          |                                  ^
      417 |     expect(scenario.removeFile).toHaveBeenCalledTimes(1);
      418 |     expect(scenario.removeFile).toHaveBeenCalledWith(candidatePath);
      419 |     expect(scenario.files.get(scenario.sourcePath)).toEqual(

      at Object.<anonymous> (test/lib/validate/orchestration-handoff-materializer.test.ts:416:34)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 40 passed, 41 total
Snapshots:   0 total
Time:        0.533 s, estimated 1 s
```

## 3. Received values

**Received `affectedPaths`:**

```
["C:/workspace/artifacts/orchestration/orchestrator-state.json"]
```

That is the destination path, where the candidate path
`C:/workspace/artifacts/orchestration/orchestrator-state.handoff-candidate-61124fa2eaba55694b909b0b0835d583e50c3716af4e66e2152de9bc8bb81dcf.json`
was expected. This is the first of the two failure signatures the task's acceptance allows.

**Received `removeFile` call count:** not printed by this run. Jest reports the first
failing assertion of a test and stops, and the first failing assertion is the
`affectedPaths` comparison at line 416, so the `toHaveBeenCalledTimes(1)` assertion at line
417 did not execute and no received count was emitted. The count implied by the production
module at `a7b80f2d` is 0: the atomic-replace failure path at lines 430-436 of
`extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` returns a
blocked result without any cleanup call, and the preceding candidate re-validation block
completed without entering its catch. That figure is a reading of the production code, not
a value this run printed, and is labeled as such.

## 4. Failure scope

Exactly one test failed, and it is the newly added one. The other 40 tests, which are the
34 recorded in P3-T1 plus the six added in P3-T2, all passed.

Output Summary: The seventh test fails as designed with exit code 1. The materializer
currently reports the destination path on the atomic-replace failure path and performs no
candidate cleanup there, which is the defect P3-T4 corrects.
