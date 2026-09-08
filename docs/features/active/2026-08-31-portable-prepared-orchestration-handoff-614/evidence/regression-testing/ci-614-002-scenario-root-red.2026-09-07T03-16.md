# Scenario Workspace-Root Derivation — Red Run — [P1-T2] `[expect-fail]`

Timestamp: 2026-09-07T11-17
Task: [P1-T2]

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runInBand --runTestsByPath test/lib/validate/orchestration-handoff-materializer-production.test.ts`
EXIT_CODE: 1
ExpectedExitCode: 1

## Change made

A named import of `VIRTUAL_WORKSPACE_ROOT`, `archivePathFor`, `candidatePathFor`, and `createScenario` from `./orchestration-handoff-materializer-test-support` was added after the existing `createProductionHandoffMaterializer` import, and a final `describe("portable handoff scenario workspace-root derivation", ...)` block was appended carrying one test named `registers only paths under the derived absolute workspace root`. The file already imports `path` at line 2, so no further import was needed. No other line of the file was changed by this task; the seven drive-letter literals remain and are replaced by [P1-T5].

## Observed failure (verbatim)

```
FAIL test/lib/validate/orchestration-handoff-materializer-production.test.ts
  ● portable handoff scenario workspace-root derivation › registers only paths under the derived absolute workspace root

    expect(received).toBe(expected) // Object.is equality

    Expected: "C:/Users/DanMoisan/repos/drm-copilot-wt/2026-08-31T07-29/extensions/drm-copilot/virtual-workspace"
    Received: "C:/workspace"

    > 409 |     expect(scenario.request.workspaceRoot).toBe(VIRTUAL_WORKSPACE_ROOT);

      at Object.<anonymous> (test/lib/validate/orchestration-handoff-materializer-production.test.ts:409:44)

Test Suites: 1 failed, 1 total
Tests:       1 failed, 17 passed, 18 total
```

Output Summary: The run exited 1, which is the expected outcome for this `[expect-fail]` task. The failure output names the test `registers only paths under the derived absolute workspace root` and shows the received value for `scenario.request.workspaceRoot` as the drive-letter literal `"C:/workspace"`, against the derived absolute root `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-08-31T07-29/extensions/drm-copilot/virtual-workspace`. Jest resolves the relative virtual name against the `extensions/drm-copilot` project directory, which is the working directory of the runner. The preceding two assertions passed, confirming the derived root is absolute and equals `path.resolve("virtual-workspace")` with separators normalized. Every other test in the file passed: `Tests: 1 failed, 17 passed, 18 total`, so the single failure is the intended one and no pre-existing case regressed. The file grew from 371 to 420 lines, within the 500-line limit.
