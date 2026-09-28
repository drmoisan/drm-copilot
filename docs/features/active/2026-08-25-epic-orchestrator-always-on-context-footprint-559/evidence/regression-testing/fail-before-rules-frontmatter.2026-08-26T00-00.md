# Fail-Before — `test_claude_rules_frontmatter.py` (Issue #559)

Timestamp: 2026-08-25T23-49
Task: [P1-T3] `[expect-fail]`

## Command:

```
poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 1
ExpectedExitCode: 1

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask the observed result.

## Why a Failing Run Is the Expected Outcome

Phase 1 authors the regression tests only. None of the F2, F3, or F4 production edits has been
applied: the five unscoped rules files still carry no frontmatter block, `epic-orchestrator`
still preloads six skills, and the three unqualified `spec.md` section citations are still
present. A passing run at this point would mean the tests assert nothing.

## Result

7 failed, 1 passed, out of 8 collected.

## Failing Tests (all seven, in reported order)

| # | Test | Observed defect |
|---|---|---|
| 1 | `test_every_claude_rule_carries_parseable_paths_and_description` | 5 rules files carry no parseable YAML frontmatter block: `benchmark-baselines.md`, `ci-workflows.md`, `orchestrator-state.md`, `parallel-orchestration.md`, `plan-acceptance-gates.md` |
| 2 | `test_unconditional_rule_set_is_exactly_the_four_deliberate_files` | 5 files load unconditionally that must be scoped: the same five |
| 3 | `test_orchestrator_state_rule_paths_reach_every_checkpoint_writer` | declared `paths:` is empty, so all 10 checkpoint-writer surfaces are unreached |
| 4 | `test_plan_acceptance_gates_rule_paths_cover_both_dispatchers` | declared `paths:` is empty, so neither dispatcher is reached |
| 5 | `test_parallel_orchestration_rule_paths_cover_blast_radius_config` | declared `paths:` is empty, so neither blast-radius truth table is reached |
| 6 | `test_epic_orchestrator_preloads_exactly_three_skills` | observed `skills:` is `['policy-compliance-order', 'epic-orchestrate', 'feature-promotion-lifecycle', 'atomic-plan-contract', 'acceptance-criteria-tracking', 'evidence-and-timestamp-conventions']` (6 entries, expected 3) |
| 7 | `test_no_unqualified_spec_section_citation_under_claude` | citations remain in `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` |

## Passing Test (one)

`test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file` passes at baseline. Every
`skills:` entry of every `.claude/agents/*.md` file resolves to an existing
`.claude/skills/<name>/SKILL.md`. This is the intended pre-change state: the test is the guard
that makes the `[P3-T4]` preload removal safe, and it must hold both before and after.

## Acceptance Condition

`[P1-T3]` requires at least these four to fail:

| Required failing test | Observed |
|---|---|
| `test_every_claude_rule_carries_parseable_paths_and_description` | FAILED |
| `test_unconditional_rule_set_is_exactly_the_four_deliberate_files` | FAILED |
| `test_epic_orchestrator_preloads_exactly_three_skills` | FAILED |
| `test_no_unqualified_spec_section_citation_under_claude` | FAILED |

All four failed. The three additional failures (tests 3, 4, and 5 above) are the path-coverage
assertions against the same five unscoped files; they are permitted by the "at least" wording and
are resolved by `[P2-T3]`, `[P2-T4]`, and `[P2-T5]`.

## Post-Format Re-run

`[P1-T5]` reformatted this module with Black and condensed its prose to satisfy the 500-line
file-size limit in `.claude/rules/general-code-change.md` (the first draft was 518 lines; the
committed file is 499). The three scope-coverage tests were refactored onto a shared
`assert_rule_paths_reach` helper; no assertion was weakened, added, or removed. The command above
was re-run after that work and produced an identical result — exit code 1, 7 failed, 1 passed,
with the same seven test names. Formatting therefore did not alter the recorded outcome.

## Collection Count

`poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py --collect-only`
collected exactly **8** items, satisfying the `[P1-T1]` acceptance condition.

Output Summary: EXPECTED FAILURE OBSERVED. Exit code 1, matching `ExpectedExitCode: 1`. 7 failed,
1 passed of 8 collected. The failing tests are
`test_every_claude_rule_carries_parseable_paths_and_description`,
`test_unconditional_rule_set_is_exactly_the_four_deliberate_files`,
`test_orchestrator_state_rule_paths_reach_every_checkpoint_writer`,
`test_plan_acceptance_gates_rule_paths_cover_both_dispatchers`,
`test_parallel_orchestration_rule_paths_cover_blast_radius_config`,
`test_epic_orchestrator_preloads_exactly_three_skills`, and
`test_no_unqualified_spec_section_citation_under_claude`. All four tests named in the `[P1-T3]`
acceptance condition are among them. `test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file`
passes, which is the correct pre-change state for that guard.
