# Phase 6 — Push-Down Byte-Parity Gate for the Bundled Skill Copies

Timestamp: 2026-08-28T12-47

Task: [P6-T2]

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` (working directory: repository root)

EXIT_CODE: 1

ExpectedExitCode: 1

The recorded exit code is the exit code of the pytest run itself, captured directly and not from
a pipeline tail.

## Output Summary

### Counts

```
======================== 1 failed, 18 passed in 0.26s =========================
```

- Passed: **18**
- Failed: **1**

### Node ID of every failed test

```
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

### Assertion message of every failed test

```
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

## Bounded exemption invoked

The task passes under the bounded exemption stated at the head of the plan. All three of its
conditions are satisfied by this run, each checked against the run's own output:

1. The failing node ID is exactly
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
   which is the node ID anchored in the `[P0-T12]` baseline **before any task of this plan edited
   a source file**.
2. The run reports exactly one failed test.
3. The assertion message names a path under `.claude/state/`, in the backslash rendering
   `.claude\state\python-batch-budget.default.json`.

The failure is unrelated to this change. The test enumerates every file under the repository
`.claude` tree by filesystem walk and requires a bundled counterpart, excluding only
`settings.local.json` and the `agent-memory` subtree; it does not consult `.gitignore`. The file it
names is written by the `PreToolUse` hook `.claude/hooks/enforce-python-batch-budget.ps1`,
`.gitignore` excludes `.claude/state/`, and no bundled `.claude/state/` directory exists. The
failure is local to a developer workspace and is green in CI.

## The parity work this task performed did pass

The three bundled skill copies were made byte-identical to their self-hosted counterparts, and
that is verified directly rather than inferred from the test result:

```
diff .claude/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md  -> claude pair identical
diff .github/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md        -> github pair identical
diff .agents/skills/pr-context-artifacts/SKILL.md extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md -> agents pair identical
```

All three `diff` invocations produced empty output and exited 0.

Correspondingly, no assertion in either test file names a `pr-context-artifacts` path. The
`.agents` parity test file passed in full, and the only failure in the `.claude` parity file is
the pre-existing one recorded above.
