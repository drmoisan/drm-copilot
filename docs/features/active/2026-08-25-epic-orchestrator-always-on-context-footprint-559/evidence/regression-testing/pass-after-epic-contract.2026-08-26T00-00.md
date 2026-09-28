# Pass-After — Epic Bounded Child Return Contract Regression Tests (Issue #559)

Timestamp: 2026-08-26T01-04
Task: [P6-T11]
Pairs with: `evidence/regression-testing/fail-before-epic-contract.2026-08-26T00-00.md` (`[P1-T4]`)

## Command:

```
poetry run pytest tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 0

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream
process status could mask a failure.

## Observed output

```
collected 7 items

tests\scripts\dev_tools\test_epic_bounded_child_return_contract.py ..... [ 71%]
..                                                                       [100%]

============================== 7 passed in 0.05s ==============================
```

## Fail-before / pass-after pairing

The `[P1-T4]` fail-before artifact recorded `EXIT_CODE: 1` against `ExpectedExitCode: 1`, with all
seven tests failing, because none of the F1 or F6 edits had been applied at that point. This run
records 7 passed and 0 failed. The pairing is complete: every one of the seven is resolved, and the
before-state was a clean sweep of failures rather than a partial one.

| # | Test node | Before (`[P1-T4]`) | After (`[P6-T11]`) | Delivered by | Feature |
|---|---|---|---|---|---|
| 1 | `test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions` | FAIL | **PASS** | `[P3-T3]` | F1 |
| 2 | `test_epic_orchestrate_skill_has_no_prerequisites_heading` | FAIL | **PASS** | `[P3-T9]` | F1 |
| 3 | `test_epic_skill_documents_bounded_child_return_contract_section` | FAIL | **PASS** | `[P3-T7]` | F6 |
| 4 | `test_bounded_return_shape_names_every_required_field` | FAIL | **PASS** | `[P3-T7]` | F6 |
| 5 | `test_bounded_return_section_states_discard_and_rederivation` | FAIL | **PASS** | `[P3-T7]` | F6 |
| 6 | `test_epic_mode_kickoff_line_carries_child_facing_constraint` | FAIL | **PASS** | `[P3-T8]` | F6 |
| 7 | `test_orchestrate_skill_carries_matching_child_side_statement` | FAIL | **PASS** | `[P3-T10]` | F6 |

Rows 1 and 2 are the F1 context-reduction deletions: removing the two `## Startup Protocol` read
instructions from `.claude/agents/epic-orchestrator.md` and removing the `## Prerequisites` re-read
block from `.claude/skills/epic-orchestrate/SKILL.md`. Rows 3 through 7 are the F6 bounded-return
contract, spanning both sides of the parent/child boundary: rows 3 through 6 on the parent side in
`.claude/skills/epic-orchestrate/SKILL.md`, and row 7 on the child side in
`.claude/skills/orchestrate/SKILL.md`.

Row 4 asserts all eight fields of the fixed return shape chosen by Decision 3 — `issue_num`,
`feature_folder`, `merge_status`, `pr_number`, `merge_commit_sha`, `blocked_reason`, `branch_name`,
`worktree_path`. Row 5 asserts the two statements that make the shape safe to bound: that content
beyond the fixed shape is discarded, and that authoritative state is re-derived regardless from
`git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid`,
per the cache doctrine in `.claude/rules/parallel-orchestration.md`.

## Wrap-tolerance of the prose assertions

`[P1-T2]` required each prose assertion in this module to normalize whitespace across adjacent lines
before searching, so that a reflow of the target file cannot silently turn the assertion into a
zero-match no-op. That requirement is what makes this pass-after result meaningful rather than
incidental: a line-oriented search for a multi-word phrase is exactly the unfalsifiable-gate class
that rule G6 of `.claude/rules/plan-acceptance-gates.md` reports, and it would return zero matches —
and could be mistaken for either outcome — once the target Markdown wrapped differently. The seven
PASS results therefore reflect the content actually being present, not a search that could not fail.

## Collected-count check

The module collects exactly 7 test items, matching the `[P1-T2]` acceptance condition and the
`[P6-T11]` expectation of seven passed. All seven node IDs were enumerated by `--collect-only -q`
and are listed in the table above; no test was added, removed, renamed, or skipped between the
fail-before and pass-after runs, so the two artifacts compare the same set.

Output Summary: PASS. `poetry run pytest
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` exited 0 with **7 passed**, 0
failed, 0 skipped, from 7 collected items. This pairs with the `[P1-T4]` fail-before artifact, which
recorded exit code 1 with all seven failing against `ExpectedExitCode: 1`. Two tests cover the F1
context-reduction deletions (`[P3-T3]`, `[P3-T9]`) and five cover the F6 bounded child return
contract across both the parent skill (`[P3-T7]`, `[P3-T8]`) and the child skill (`[P3-T10]`),
including the eight-field shape of Decision 3 and the discard-and-re-derive statements.
