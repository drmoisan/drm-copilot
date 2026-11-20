# Parity Verification After [P2-T1] — Pair 1 (`.claude/rules/typescript.md`) (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item; Passed: 1; Failed: 0; Duration: 0.08s
- Verbatim result line: `1 passed in 0.08s`

Edits applied in this task (repo-root file and bundled copy edited identically):

- `.claude/rules/typescript.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md`

| Line | Before | After |
|---|---|---|
| 16 | ``4. **Testing — Vitest**: All TypeScript unit tests must use Vitest. Command: `npm run test` `` | ``4. **Testing — Jest**: All TypeScript unit tests must use Jest. Command: `npm run test:unit` `` |
| 42 | `- Use **Vitest** as the test framework.` | `- Use **Jest** as the test framework.` |
| 47 | ``- Use `vi.spyOn` or `vi.mock` for targeted mocking; reset mocks with `afterEach(() => { vi.resetAllMocks(); })`.`` | ``- Use `jest.spyOn` or `jest.mock` for targeted mocking; reset mocks with `afterEach(() => { jest.resetAllMocks(); })`.`` |
| 51 | ``- Coverage command: `npm run test:coverage` (the script is wired in Prompt B1 alongside the Vitest dependency).`` | ``- Coverage command: `npm run test:unit:coverage` (the root `package.json` script runs `node run-jest.cjs --coverage`).`` |
| 73 | ``- Tests use Vitest fake timers (`vi.useFakeTimers()`).`` | ``- Tests use Jest fake timers (`jest.useFakeTimers()`).`` |

Byte-parity check (in addition to the parity test):
```
diff .claude/rules/typescript.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/typescript.md
```
Exit code 0, no output — the two files are byte-identical after the paired edits.

Rationale for the line-51 replacement clause: the stale text "(the script is wired in Prompt B1 alongside the Vitest dependency)" referred to a Vitest setup that was never adopted. It is replaced with an accurate statement of what the script does, verified against root `package.json` (`"test:unit:coverage": "node run-jest.cjs --coverage"`). The replacement introduces no additional backtick-wrapped `npm run` token beyond `npm run test:unit:coverage`, which resolves.
