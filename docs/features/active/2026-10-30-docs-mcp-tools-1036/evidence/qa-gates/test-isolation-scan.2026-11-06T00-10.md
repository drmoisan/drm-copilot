# Test Isolation Token Scan ([P8-T8])

Timestamp: 2026-11-06T00-10
Command: grep -nF <token> over the seven new test files (`test/docs-command-envelope.test.ts`, `test/mcp-tool-inputs-docs.test.ts`, `test/mcp-tool-inputs-docs.ledger.test.ts`, `test/repo-automation-execute-docs.test.ts`, `test/mcp-docs-tool-definitions.test.ts`, `test/mcp-handlers/docs-handlers.test.ts`, `test/mcp-server.docs.test.ts`) and the four edited test files (`test/mcp-server.test.ts`, `test/mcp-discovery-authority-tool-definitions.test.ts`, `test/mcp-server-test-service.ts`, `test/repo-automation-service.test.ts`), all under extensions/drm-copilot; tokens `tmpdir`, `mkdtemp`, `writeFileSync`, `child_process`, `createNodeProcessLauncher`, `"pwsh"`
EXIT_CODE: 0
Output Summary:

| Token | Count | Hits |
|---|---|---|
| `tmpdir` | 0 | none |
| `mkdtemp` | 0 | none |
| `writeFileSync` | 0 | none |
| `child_process` | 1 | `test/repo-automation-service.test.ts`: the pre-existing module mock `jest.mock("node:child_process", () => ({ spawn: jest.fn() }))`, present at EPIC-BASE; it replaces the module with a stub and starts no process. No new or edited test imports or calls `child_process`. |
| `createNodeProcessLauncher` | 0 | none |
| `"pwsh"` | 3 | all in `test/repo-automation-execute-docs.test.ts`: two in the stub `pwsh` resolver of the test harness (records the call order label `"pwsh"` and returns a fake path, used by every `invokeDocsCommand` test), and one argv/order assertion in `checks workspace root, entry script and pwsh in that order`. None launches `pwsh`. |

- No test creates a temporary file or launches a process; every process launch goes to an injected recording fake.
