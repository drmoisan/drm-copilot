# P5-T7 Push-Down and Skill-Document Contract Suites

Timestamp: 2026-09-27T03-56
Pass: 1
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 54 passed, 1 failed. The only failed node is test_bundled_claude_payload_contains_all_repo_runtime_contracts, whose AssertionError names the gitignored batch-budget state file under .claude/state, which the status output lists with the `!!` prefix. This is KNOWN_ISSUE_510 (local-only; the batch-budget hook writes that file at the first .ps1 Write). All four skill-document suites pass.

KNOWN_ISSUE_510

Other commands:

- `git status --porcelain --ignored --untracked-files=all -- .claude/state`: EXIT_CODE 0

## Status output

```text
!! .claude/state/powershell-batch-budget.worktree-agent-aa847d52820826acc-860ba870.json
```

## Final summary line (verbatim)

```text
1 failed, 54 passed in 0.33s
```

## Failed node IDs and AssertionError lines

```text
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-aa847d52820826acc-860ba870.json
```

The AssertionError path, with `\` read as `/`, is `.claude/state/powershell-batch-budget.worktree-agent-aa847d52820826acc-860ba870.json`, which the status output lists with the `!!` prefix.

## Local byte-identity evidence (cited per the task text)

- `evidence/qa-gates/mirror-parity-sha256.md`: `SKILL_PAIR_IDENTICAL: parallel-plan True` and `SKILL_PAIR_IDENTICAL: epic-plan True`; `BYTE_IDENTICAL: True` for the four helpers copies.
- `evidence/qa-gates/parity-and-legacy-contracts.md`: 45 passed, 0 failed, including `keeps the canonical hooks byte-identical to their bundled copies`.
