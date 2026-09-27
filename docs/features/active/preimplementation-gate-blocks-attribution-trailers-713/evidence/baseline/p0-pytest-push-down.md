# P0-T13 Push-Down Contract Baseline

Timestamp: 2026-09-27T03-33
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q
EXIT_CODE: 0
Output Summary: 55 passed, 0 failed, 0 errors. No failed node in the push-down suite or in the four skill-document suites.

Other commands:

- `git status --porcelain --ignored -- .claude/state`: EXIT_CODE 0, printed nothing (no ignored or untracked file under `.claude/state` at baseline).

## Status output

```text
(empty)
```

## Final summary line (verbatim)

```text
55 passed in 0.36s
```

## Failed or errored node IDs

none
