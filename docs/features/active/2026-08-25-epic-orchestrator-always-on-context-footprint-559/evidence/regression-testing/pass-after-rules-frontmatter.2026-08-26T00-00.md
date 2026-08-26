# Pass-After — Claude Rules Frontmatter Regression Tests (Issue #559)

Timestamp: 2026-08-26T01-02
Task: [P6-T10]
Pairs with: `evidence/regression-testing/fail-before-rules-frontmatter.2026-08-26T00-00.md` (`[P1-T3]`)

## Command:

```
poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Observed output

```
collected 8 items

tests\scripts\dev_tools\test_claude_rules_frontmatter.py ........        [100%]

============================== 8 passed in 0.13s ==============================
```

## Fail-before / pass-after pairing

The `[P1-T3]` fail-before artifact recorded `EXIT_CODE: 1` against `ExpectedExitCode: 1`, with 7
failed and 1 passed of 8 collected. This run records 8 passed and 0 failed. The pairing is therefore
complete and every one of the seven pre-change failures is now resolved.

| # | Test node | Before (`[P1-T3]`) | After (`[P6-T10]`) | Delivered by |
|---|---|---|---|---|
| 1 | `test_every_claude_rule_carries_parseable_paths_and_description` | FAIL | **PASS** | `[P2-T1]` .. `[P2-T5]` |
| 2 | `test_unconditional_rule_set_is_exactly_the_four_deliberate_files` | FAIL | **PASS** | `[P2-T1]` .. `[P2-T5]` |
| 3 | `test_orchestrator_state_rule_paths_reach_every_checkpoint_writer` | FAIL | **PASS** | `[P2-T4]` |
| 4 | `test_plan_acceptance_gates_rule_paths_cover_both_dispatchers` | FAIL | **PASS** | `[P2-T3]` |
| 5 | `test_parallel_orchestration_rule_paths_cover_blast_radius_config` | FAIL | **PASS** | `[P2-T5]` |
| 6 | `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` | PASS | **PASS** | pre-existing invariant, held throughout |
| 7 | `test_epic_orchestrator_preloads_exactly_three_skills` | FAIL | **PASS** | `[P3-T4]` |
| 8 | `test_no_unqualified_spec_section_citation_under_claude` | FAIL | **PASS** | `[P3-T1]`, `[P3-T2]`, `[P3-T6]` |

Test 6 is the one test that passed on both sides. That is the correct and expected behaviour: it
asserts that every `skills:` entry of every agent file resolves to an existing skill file, which was
already true before the change. `[P3-T4]` removed three preload entries from
`.claude/agents/epic-orchestrator.md`; removing entries cannot break a resolution invariant, so the
test guards against a regression rather than driving the fix. Its steady PASS confirms that the
three removals did not leave a dangling reference.

The unconditional-set test (row 2) is the one whose definition `[P1-T1]` had to state explicitly: a
rules file carrying **no** YAML frontmatter block at all counts as unconditional, because a file with
no `paths:` scoping loads on every turn and is therefore unconditional in effect. Under that
definition the pre-change unconditional set had nine members (five unscoped files plus four
deliberate ones) and the test failed; after `[P2-T1]` through `[P2-T5]` scoped the five, the set is
exactly the four deliberate files and the test passes. Without that definition the test would have
passed before the fix and the `[expect-fail]` acceptance of `[P1-T3]` would have been wrong.

## Collected-count check

The module collects exactly 8 test items, matching the `[P1-T1]` acceptance condition and the
`[P6-T10]` expectation of eight passed. All eight node IDs were enumerated by
`--collect-only -q` and are listed in the table above; no test was added, removed, renamed, or
skipped between the fail-before and pass-after runs, so the two artifacts compare the same set.

Output Summary: PASS. `poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py`
exited 0 with **8 passed**, 0 failed, 0 skipped, from 8 collected items. This pairs with the
`[P1-T3]` fail-before artifact, which recorded exit code 1 with 7 failed and 1 passed against
`ExpectedExitCode: 1`. All seven pre-change failures are resolved; the single test that passed on
both sides (`test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`) is a
non-regression guard that was already satisfied and confirms `[P3-T4]`'s three preload removals left
no dangling skill reference.
