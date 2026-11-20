# Parity Verification After [P2-T5] — Pair 5 (`.agents/skills/general-unit-test/SKILL.md`) (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item; Passed: 1; Failed: 0; Duration: 0.09s
- Verbatim result line: `1 passed in 0.09s`

Edits applied in this task (repo-root file and bundled copy edited identically):

- `.agents/skills/general-unit-test/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md`

| Line | Before | After |
|---|---|---|
| 45 | ``- Config files that are not production code: `vitest.config.ts`, `eslint.config.mjs`, `.dependency-cruiser.cjs`, `webpack.config.js`.`` | ``- Config files that are not production code: `jest.config.cjs`, `eslint.config.mjs`, `.dependency-cruiser.cjs`, `webpack.config.js`.`` |
| 110 | ``... async tests must use the framework's fake-timer facility (`vi.useFakeTimers()` for Vitest, `FakeTimeProvider` for .NET) ...`` | ``... async tests must use the framework's fake-timer facility (`jest.useFakeTimers()` for Jest, `FakeTimeProvider` for .NET) ...`` |

These are the same two corrections applied to `.claude/rules/general-unit-test.md` in `[P2-T2]`, kept in lockstep across the two runtime families.

Byte-parity check (in addition to the parity test):
```
diff .agents/skills/general-unit-test/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-unit-test/SKILL.md
```
Exit code 0, no output — the two files are byte-identical after the paired edits.
