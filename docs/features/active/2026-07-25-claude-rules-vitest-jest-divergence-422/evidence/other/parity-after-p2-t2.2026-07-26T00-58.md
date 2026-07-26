# Parity Verification After [P2-T2] — Pair 2 (`.claude/rules/general-unit-test.md`) (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item; Passed: 1; Failed: 0; Duration: 0.11s
- Verbatim result line: `1 passed in 0.11s`

Edits applied in this task (repo-root file and bundled copy edited identically):

- `.claude/rules/general-unit-test.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md`

| Line | Before | After |
|---|---|---|
| 40 | ``- Config files that are not production code: `vitest.config.ts`, `eslint.config.mjs`, `.dependency-cruiser.cjs`, `webpack.config.js`.`` | ``- Config files that are not production code: `jest.config.cjs`, `eslint.config.mjs`, `.dependency-cruiser.cjs`, `webpack.config.js`.`` |
| 105 | ``... async tests must use the framework's fake-timer facility (`vi.useFakeTimers()` for Vitest, `FakeTimeProvider` for .NET) ...`` | ``... async tests must use the framework's fake-timer facility (`jest.useFakeTimers()` for Jest, `FakeTimeProvider` for .NET) ...`` |

Byte-parity check (in addition to the parity test):
```
diff .claude/rules/general-unit-test.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-unit-test.md
```
Exit code 0, no output — the two files are byte-identical after the paired edits.

Scope note: the `.dependency-cruiser.cjs` entry on line 40 was left unchanged. It is a separate, report-only finding (see `[P3-T4]`) and is out of scope for this feature.
