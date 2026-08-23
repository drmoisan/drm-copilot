# Python regression, fail-before (Issue #500)

Timestamp: 2026-08-21T23:08:30Z
Issue: #500
Tasks: [P1-T1], [P1-T2], [P1-T3] — tagged `[expect-fail]`; a failing test is the expected outcome
for these tasks only.

Command:
```
poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py
```
(working directory: worktree root)

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary: `2 failed in 0.10s`. Exactly **2** tests failed and **0** passed, which is the
expected fail-before state for both regression directions. The observed exit code equals the
declared `ExpectedExitCode`.

## Failure 1 — fail-closed direction

Test: `test_unrelated_claude_citations_do_not_contend_under_the_bundled_table`

Assertion message:
```
AssertionError: Two items citing unrelated .claude files must not contend under the published truth table; observed reasons (('module_overlap', 'claude-runtime'),).
```

The assertion error names the `module_overlap` reason with detail `claude-runtime`, which is the
acceptance condition for [P1-T1]. Two items citing `.claude/hooks/enforce-mermaid-validation.ps1`
and `.claude/skills/parallel-add/SKILL.md` both match the bundled `claude-runtime` umbrella module
`.claude/**` and are forced to contend.

## Failure 2 — fail-open direction

Test: `test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table`

Assertion message:
```
AssertionError: Two items editing the same separator-free root surface must contend under the published truth table; observed reasons ().
```

The reason collection is empty and `ConflictResult(conflict=False, reasons=())` is returned. The
bundled table declares no separator-free shared surface, so the path-token classifier discards the
token `package-lock.json` entirely and two items that both rewrite the lockfile are scheduled
concurrently. This is the acceptance condition for [P1-T2].
