# Fail-Before — `test_epic_bounded_child_return_contract.py` (Issue #559)

Timestamp: 2026-08-25T23-50
Task: [P1-T4] `[expect-fail]`

## Command:

```
poetry run pytest tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 1
ExpectedExitCode: 1

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask the observed result.

## Why a Failing Run Is the Expected Outcome

Phase 1 authors the regression tests only. None of the F1 or F6 edits has been applied: the
`## Startup Protocol` section still carries the two read instructions, the `## Prerequisites`
block still exists in the epic skill, and neither bounded-return section has been written. All
seven tests must fail, which is exactly the `[P1-T4]` acceptance condition.

## Result

7 failed, 0 passed, out of 7 collected.

## Failing Tests (all seven, in reported order)

| # | Test | Observed assertion message |
|---|---|---|
| 1 | `test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions` | `Startup protocol ordinals must be ['1', '2', '3'], observed ['1', '2', '3', '4', '5']` |
| 2 | `test_epic_orchestrate_skill_has_no_prerequisites_heading` | ``` `## Prerequisites` must be removed from .claude/skills/epic-orchestrate/SKILL.md ``` |
| 3 | `test_epic_skill_documents_bounded_child_return_contract_section` | ``` `## Bounded Child Return Contract` is absent from .claude/skills/epic-orchestrate/SKILL.md ``` |
| 4 | `test_bounded_return_shape_names_every_required_field` | ``` `## Bounded Child Return Contract` is absent from .claude/skills/epic-orchestrate/SKILL.md ``` |
| 5 | `test_bounded_return_section_states_discard_and_rederivation` | ``` `## Bounded Child Return Contract` is absent from .claude/skills/epic-orchestrate/SKILL.md ``` |
| 6 | `test_epic_mode_kickoff_line_carries_child_facing_constraint` | `The epic-mode kickoff line must require the child's final report to be the bounded return shape` |
| 7 | `test_orchestrate_skill_carries_matching_child_side_statement` | ``` `## Epic Mode Bounded Return` is absent from .claude/skills/orchestrate/SKILL.md ``` |

## Assertion Falsifiability

Test 6 is the one assertion in this module that searches an existing line rather than reporting
an absent heading, so its ability to fail is worth recording explicitly. The reported diff shows
the test located the real epic-mode kickoff blockquote and searched its normalized text:

```
assert 'bounded return shape' in '`epic mode: true. epic_feature_folder: <epic-slug>.
integration_branch: epic/<epic-slug>-integration. epic_checkpoint...-state.json. pr base
branch must be <integration_branch>, not main; pass --base <integration_branch> to gh pr
create.`'
```

The haystack is the current directive, not an empty string, so the failure is a real
negative result and not a search that found nothing to search.

## Wrap-Tolerance Requirement

Every prose assertion in this module normalizes whitespace across adjacent lines before
searching. `normalize_whitespace` joins the whole extracted region with `" ".join(text.split())`,
so a phrase that later wraps across two lines is still found. A line-oriented search would
silently become a zero-match no-op on the first reflow of a target file, which would make the
assertion unfalsifiable. The blockquote extractor `blockquote_block` collects the whole
contiguous quoted run for the same reason, so the kickoff assertion survives the directive being
wrapped across several quoted lines.

## Post-Format Re-run

`[P1-T5]` reformatted this module with Black and added one `# noqa: E501` on the wrapped `def`
line of `test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions`. The
test name is fixed by `[P1-T2]` and Black's own wrapped form of that signature is 90 characters,
two over the configured 88-character limit, so the line cannot be shortened without renaming the
test. The suppression follows the established form already used for the same situation in
`tests/scripts/dev_tools/test_blast_radius_config_parity.py`,
`tests/scripts/dev_tools/test_potential_to_issue_content.py`,
`tests/scripts/dev_tools/codex_native_converter/test_section_intent.py`, and
`tests/scripts/dev_tools/codex_native_converter/test_intermediate_state.py`. It is recorded here
because `E501` is not on the pre-authorized list in `.claude/rules/python-suppressions.md`. The
command above was re-run after that change and produced an identical result — exit code 1, all
seven tests failing, same names. The file is 429 lines, inside the 500-line limit.

## Collection Count

`poetry run pytest tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py --collect-only`
collected exactly **7** items, satisfying the `[P1-T2]` acceptance condition.

Output Summary: EXPECTED FAILURE OBSERVED. Exit code 1, matching `ExpectedExitCode: 1`. 7 failed,
0 passed of 7 collected — all seven, as the `[P1-T4]` acceptance condition requires. The failing
tests are `test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions`,
`test_epic_orchestrate_skill_has_no_prerequisites_heading`,
`test_epic_skill_documents_bounded_child_return_contract_section`,
`test_bounded_return_shape_names_every_required_field`,
`test_bounded_return_section_states_discard_and_rederivation`,
`test_epic_mode_kickoff_line_carries_child_facing_constraint`, and
`test_orchestrate_skill_carries_matching_child_side_statement`. Causes are the unmodified
five-step startup protocol, the surviving `## Prerequisites` block, the two absent bounded-return
sections, and a kickoff directive that carries no child-facing constraint.
