# Distribution Negative Control: Bundled-Resource Parity (issue #491, [P5-T1], [expect-fail])

Timestamp: 2026-08-20T11-12

This is an `[expect-fail]` task. A failing run is the expected and required outcome: it proves the
parity gate is capable of failing for this change, so the green run recorded at [P5-T11] is
evidence rather than a vacuous pass.

Precondition: `.claude/state/` is absent, verified immediately before the run
(`ls .claude/state` reports the directory does not exist). The parity suite walks repo `.claude/**`
via `rglob` without reading `.gitignore`, so a session-scoped budget state file would otherwise
produce an unrelated `Repo file missing from bundle` failure and confuse the control.

State at the time of the run: the repo `.claude` files of this feature exist (hook, four library
modules, rule, SKILL.md, nine references, and the modified `settings.json`), and NO mirror under
`extensions/drm-copilot/resources/claude-customizations/.claude/` has been created yet.

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
EXIT_CODE: 1
Output Summary: `1 failed, 9 passed in 0.16s`. The failing test is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, at
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:120`, with the assertion
message:

```text
AssertionError: Repo file missing from bundle: .claude\hooks\enforce-mermaid-validation.ps1
```

Exactly one path is named because pytest aborts at the first failed assertion inside the loop over
`repo_runtime_files`, and `.claude/hooks/enforce-mermaid-validation.ps1` is first in the sorted
order of this feature's new files. The remaining unmirrored files of this change would be reported
one per subsequent run; naming one is sufficient to establish that the gate fires.

Verdict: the parity gate is shown capable of failing. AC-21 partial.
