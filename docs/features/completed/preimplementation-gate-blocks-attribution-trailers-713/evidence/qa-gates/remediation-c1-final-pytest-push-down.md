# Remediation Cycle 1 - Final Push-Down and Skill-Document pytest ([P4-T7])

Timestamp: 2026-09-27T05-27

Pass: 1

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q (R-PYTEST; run with `poetry -C <WORKSPACE_ROOT>` and the same five files given as `<WORKSPACE_ROOT>/`-prefixed paths)

EXIT_CODE: 1

ExpectedExitCode: 1

KNOWN_ISSUE_510

Output Summary: `1 failed, 54 passed in 0.35s`. The only failed node is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`; its AssertionError line names `.claude\state\powershell-batch-budget.worktree-agent-aa847d52820826acc-860ba870.json`, which the status output lists with the `!!` prefix (gitignored, written by the batch-budget hook). This is the known local-only issue #510, not a regression. Local byte-identity evidence for the skill documents and hooks: [P3-T6] `SKILL_PAIR_IDENTICAL: parallel-plan True` and `SKILL_PAIR_IDENTICAL: epic-plan True` (`evidence/qa-gates/remediation-c1-mirror-parity-sha256.md`) and the [P3-T7] pass (`evidence/qa-gates/remediation-c1-parity-and-legacy-contracts.md`, including `keeps the canonical hooks byte-identical to their bundled copies`). All four skill-document suites passed. Result: PASS under the KNOWN_ISSUE_510 branch.

## Status output

Command: `git status --porcelain --ignored --untracked-files=all -- .claude/state`

```text
!! .claude/state/powershell-batch-budget.worktree-agent-aa847d52820826acc-860ba870.json
```

## Summary line

```text
1 failed, 54 passed in 0.35s
```

## Failed nodes

```text
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

AssertionError line:

```text
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-aa847d52820826acc-860ba870.json
```

The path, read with `\` as `/`, is `.claude/state/powershell-batch-budget.worktree-agent-aa847d52820826acc-860ba870.json`, which matches the `!!` status line.
