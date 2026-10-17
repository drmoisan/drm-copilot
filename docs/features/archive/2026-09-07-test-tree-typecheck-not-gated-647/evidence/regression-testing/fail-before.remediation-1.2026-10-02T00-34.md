# Fail-Before — Explicit-Undefined Arrange Guard (issue #647, remediation cycle 1, F1)

Timestamp: 2026-10-02T00-34
Command: npm --prefix extensions/drm-copilot run test -- test/lib/validate/build-validate-orchestration-service-call-input.test.ts > <SCRATCH>/jest-fail-before.txt 2>&1; echo "EXIT=$?"; grep -E '^(Test Suites|Tests):' <SCRATCH>/jest-fail-before.txt; grep -n 'explicitly undefined' <SCRATCH>/jest-fail-before.txt; grep -ciE 'arraycontaining' <SCRATCH>/jest-fail-before.txt
EXIT_CODE: 1
ExpectedExitCode: 1
State: after P1-T1, before P1-T3 (key-less arrangement plus the new arrange guard; no `Object.defineProperty` loop).
Output Summary:
- Test Suites: 1 failed, 1 total
- Tests:       1 failed, 4 passed, 5 total
- `grep -n 'explicitly undefined'` output:
  - `6:  ● buildValidateOrchestrationServiceCallInput › omits an optional key when its value is explicitly undefined`
- Case-insensitive `arraycontaining` count: 2 (at least 1 required; pass).
- Failure report (excerpt): `expect(received).toEqual(expected) // deep equality`; `Expected: ArrayContaining [["requireComplete", undefined], ["requireModelRouting", undefined], ["requireCodexModelRouting", undefined], ["requireCodexTopology", undefined], ["requireReadyForExecution", undefined]]`; `Received: [["workspaceRoot", "C:/workspace"], ["artifactType", "orchestrator-state"], ["artifactPath", "docs/state.json"]]`. The value `C:/workspace` is a test-input string, not a host path.
- The failure is the guard assertion, not a TypeScript diagnostic (no `TSnnnn` code in the output). The other four tests are unmodified and passed at [P0-T15]; they pass here as well. The guard discriminates the key-less arrangement.
