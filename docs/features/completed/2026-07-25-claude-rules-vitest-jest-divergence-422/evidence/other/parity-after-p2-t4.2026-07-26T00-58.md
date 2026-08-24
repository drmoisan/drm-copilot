# Parity Verification After [P2-T4] — Pair 4 (`.claude/agents/atomic-executor.md`) (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"
```

EXIT_CODE: 0

Output Summary:

- Collected: 1 item; Passed: 1; Failed: 0; Duration: 0.12s
- Verbatim result line: `1 passed in 0.12s`

This is the last `.claude/**` mirror edit in Phase 2, so this run is the authoritative post-change `.claude`-family parity evidence referenced by `[P4-T9]` / AC 9.

Edits applied in this task (repo-root file and bundled copy edited identically):

- `.claude/agents/atomic-executor.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md`

| Line | Before | After |
|---|---|---|
| 18 | `  - "Bash(npx vitest *)"` | `  - "Bash(npx jest *)"` |
| 79 | ``- **TypeScript**: `npx prettier`, `npx eslint`, `npx tsc`, `npx vitest` `` | ``- **TypeScript**: `npx prettier`, `npx eslint`, `npx tsc`, `npx jest` `` |

Byte-parity check (in addition to the parity test):
```
diff .claude/agents/atomic-executor.md extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md
```
Exit code 0, no output — the two files are byte-identical after the paired edits.

Precedent for the `npx jest` command form:
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:67` recognizes the command family `npx (prettier|eslint|tsc|jest)`, so the corrected allowlist entry matches the command family the hook already expects.
- The canonical `.github/agents/typescript-engineer.agent.md` names the Jest toolchain.

Runtime significance: line 18 is a tool allowlist entry, so this correction changes the executor's permitted Bash invocations, not just documentation text. The previously allowlisted `npx vitest` had no resolvable binary in this repository.
