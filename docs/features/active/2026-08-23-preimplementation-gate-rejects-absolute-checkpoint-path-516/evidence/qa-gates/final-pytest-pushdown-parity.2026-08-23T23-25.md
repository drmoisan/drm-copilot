# Final QA Gate 5 — Push-Down Claude Resource Parity (issue #516)

Timestamp: 2026-08-24T16-34
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
EXIT_CODE: 0

## Result

```text
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e
configfile: pyproject.toml
collected 10 items

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py ..........  [100%]

============================= 10 passed in 0.20s ==============================
```

**Passed: 10. Failed: 0. EXIT_CODE 0.** Identical to the [P0-T12] baseline count of 10 passed, so the Claude root-to-bundle content-equality contract is preserved across this change.

This command matches an implementation-command pattern in the very gate this item repairs and therefore required a ready `artifacts/orchestration/orchestrator-state.json` at execution time. That checkpoint was present and the command was allowed.

## Preparatory Step Recorded

Immediately before this invocation, the gitignored transient file `.claude/state/powershell-batch-budget.default.json` was removed. The batch-budget hook recreates it on every governed PowerShell write, and `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates every on-disk `.claude/**` file and requires a bundled counterpart, so the transient file breaks the suite purely by existing. Full diagnosis and the in-scope justification are recorded in `evidence/baseline/baseline-pytest-pushdown-parity.2026-08-23T23-25.md`. The removal touches no tracked file; `git check-ignore -v` confirms `.gitignore:68` covers `.claude/state/`.

## Agreement With the Direct Hash Comparison

This test is the parity gate for the Claude family. Its verdict agrees with the direct `Get-FileHash` comparison recorded at [P2-T3] and re-confirmed at [P4-T9]:

```text
658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207  .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
658C50A98FB14EA06CC6705A384CF46ECE11A5793DE0E8E854CDF18C34FE6207  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
```

Two independent mechanisms — a content-equality test over the whole `.claude` payload and a SHA256 comparison of the specific pair — both report the Claude root and bundle copies identical.

Output Summary: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes 10 of 10 with EXIT_CODE 0, matching the baseline exactly and confirming Claude root-to-bundle content equality after the change. The result agrees with the independent SHA256 comparison of the Claude hook pair. The run-only test file was executed without modification.
