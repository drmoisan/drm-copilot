# FR-614-005 Public Contract Red Test

Timestamp: 2026-09-03T00-58:00-04:00
Command: node run-jest.cjs --runInBand --runTestsByPath test/mcp-repo-automation-tool-definitions.test.ts test/mcp-handlers/orchestration-handoff-handlers.test.ts test/repo-automation-orchestration-validation.test.ts test/mcp-server.test.ts
Working Directory: `extensions/drm-copilot`
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: The expected red run failed 4/4 targeted suites. Of 92 tests, 71 passed and 21 failed. Every failure is attributable to the absent independent request schema, parsing, validation, or forwarding contract. The run modified no production file.

Expected failure signatures:

- Tool definition schemas omit all ten independent-context properties and required entries.
- Handler parsing accepts omitted and malformed independent-context values instead of rejecting them by field name.
- Topology and routing handlers drop all ten independent-context fields before service invocation.
- Transition dispatch drops all ten independent-context fields before service invocation through both direct and MCP-server paths.

Observed representative signatures:

```text
Expected  - 10
Received  +  0
portable handoff MCP definitions > defines the exact read-only request

Expected substring: "expected_repository_id must be a non-empty string."
Received message: "Cannot read properties of undefined (reading 'status')"

Expected: ObjectContaining {"allowedHeadRelationship": "equal_or_descendant", ...}
Received: {"destinationProvider": "codex", "expectedHandoffEnvelopeSha256": "...", ...}

Test Suites: 4 failed, 4 total
Tests:       21 failed, 71 passed, 92 total
Snapshots:   0 total
Time:        0.817 s
```

Changed-path boundary:

```text
UNSTAGED PRODUCTION PATHS
(none)
UNSTAGED TEST PATHS
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts
extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts
extensions/drm-copilot/test/mcp-server.test.ts
extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts
```

## Independent re-verification

Timestamp: 2026-09-03T01-14
Command: node run-jest.cjs --runInBand --runTestsByPath test/mcp-repo-automation-tool-definitions.test.ts test/mcp-handlers/orchestration-handoff-handlers.test.ts test/repo-automation-orchestration-validation.test.ts test/mcp-server.test.ts
Working Directory: `extensions/drm-copilot`
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: Re-ran the exact P1-T1 command in the resumed executor session. Result reproduced identically: `Test Suites: 4 failed, 4 total` and `Tests: 21 failed, 71 passed, 92 total`. Failures remain confined to the absent independent request schema, parsing, and forwarding contract. `git status --porcelain=v1 --untracked-files=all -- extensions/drm-copilot/src` returned no rows, proving no production file was modified by the red run.

In-task correction applied before re-verification: `extensions/drm-copilot/test/mcp-server.test.ts` had lost five explanatory comments (the terminal-spy rationale, the fail-closed resolver note, and the Arrange/Act/Assert markers on the `run_poshqc_test` terminal case). Those comments are unrelated to the FR-614-005 contract and their removal conflicted with the Arrange-Act-Assert documentation rule, so they were restored. The file's diff against HEAD is now 33 insertions and 2 deletions, with the two deletions confined to the transition-dispatch assertion the task requires.
