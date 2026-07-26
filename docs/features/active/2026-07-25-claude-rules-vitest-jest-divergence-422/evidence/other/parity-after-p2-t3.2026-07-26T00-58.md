# Parity Verification After [P2-T3] — Pair 3 (`.claude/rules/general-code-change.md`) (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item; Passed: 1; Failed: 0; Duration: 0.07s
- Verbatim result line: `1 passed in 0.07s`

Edits applied in this task (repo-root file and bundled copy edited identically):

- `.claude/rules/general-code-change.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md`

| Line | Before | After |
|---|---|---|
| 39 | ``5. **Unit tests** (e.g., Pytest, Vitest, MSTest, Pester) including property-based tests where applicable per `quality-tiers.md` `` | ``5. **Unit tests** (e.g., Pytest, Jest, MSTest, Pester) including property-based tests where applicable per `quality-tiers.md` `` |

Byte-parity check (in addition to the parity test):
```
diff .claude/rules/general-code-change.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md
```
Exit code 0, no output — the two files are byte-identical after the paired edits.

Rationale: the list enumerates this repository's actual per-language unit-test runners. Pytest (Python), MSTest (C#), and Pester (PowerShell) are correct; the TypeScript slot must name Jest, which is the declared root devDependency (`"jest": "^30.4.2"`) and the runner behind `npm run test:unit`.
