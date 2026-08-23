Timestamp: 2026-08-23T05-22
Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-topology.test.ts test/lib/validate/orchestrator-state-codex-model-routing-coverage.test.ts --runInBand`
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: Expected fail-before result. Jest ran `2` suites and `26` tests: `1` suite failed, `1` suite passed, `1` test failed, and `25` tests passed. The only failure was `Codex topology checkpoint receipts > resolves duplicate topology inputs once per validation`: expected one resolver call and received two. The model-routing coverage suite, including all new duplicate-input semantic cases, passed. No file is staged or committed.
Failure: `Expected number of calls: 1; Received number of calls: 2` at `orchestrator-state-codex-topology.test.ts:114`.
