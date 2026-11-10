# Preflight Fixes, Round 2 (Issue #1165)

Timestamp: 2026-11-10T00-04
Plan: docs/features/active/cd-chained-command-recurring-deny-1165/plan.2026-11-09T17-40.md

Each fix edits task text or Pre-Mortem text only. No task was added, removed, or reordered, and no asserted token was changed. A copy of the plan taken before this round is kept as SCRATCH/issue-1165-plan-round2-start.md. The round-1 record `preflight-fixes.2026-11-09T23-41.md` is not edited.

Round-1 defects re-checked against the tree: AC-12 (`test_rule_states_command_shape_rule_and_isolated_refusal`), AC-14 (`test_codex_skill_frontmatter_source_and_claude_only_statement`), AC-15 (`test_copilot_instruction_frontmatter_is_always_loaded`), AC-19 (`test_brief_command_text_restrictions_states_preferred_forms`; all nine asserted tokens are absent from all six brief copies, and the negative token is present in them), and AC-22 (`test_parallel_orchestrate_step_c_uses_keep_and_references_brief_table`; each copy holds one `- (c) On` marker, one `- (d) On success` marker, and one `reset --hard HEAD~1`, and neither copy contains `Command-Text Restrictions`). Each is resolved.

## Fixes

1. [P0-T1] | literal clarification | The item worktree has no `.claude/state/` directory, because batch-budget state is kept under the session root. The listing now names the session root's `.claude/state/`, as research section 6 does.
2. [P2-T1] | literal clarification | `test_command_shape_forms_are_consistent_across_surfaces` ([P3-T1]) asserts the lowercase `sibling worktree` and the other consistency tokens in the rule. The table header is capitalized and Python `in` is case-sensitive. The task text now states that the prose writes the lowercase phrase and that the body carries every token the test asserts.
3. [P2-T2] | literal clarification | Same clarification for the Codex skill and the Copilot instruction, which the same test reads.
4. [P3-T1] | literal clarification | The brief edit listed rows that omitted three tokens its own consistency test asserts in `## Command-Text Restrictions`: `--directory`, `npm --prefix <abs> run <script>`, and the lowercase `sibling worktree`. The row list now names them. Before the edit, all three are absent from every brief copy.
5. [P3-T1] | disposition citation | `docs/engineering/process-reductions/` now holds entries 0001 to 0010, not 0001 to 0006. Entries 0007 to 0010 record no region of the brief. Stored patches 0008, 0009, and 0010 do not touch the brief, and the 0001 and 0006 brief hunks lie in other sections. `ProcessReductionChain.psm1` matches hunks by content, not by line number. The disposition (unchanged) stands, and only the entry range is corrected.
6. [P4-T5] | literal formatting (assertion can fail) | `git diff MB HEAD` compares only commits. If the changes are uncommitted when the task runs, its hunk-location checks pass with an empty diff. The task now uses `git diff MB`, which compares the working tree with `MB` and so sees committed and uncommitted tracked changes. `git status --porcelain` still covers untracked files. The asserted conditions are unchanged.
7. [P4-T6] and Pre-Mortem `Review checklists` | literal formatting | For the same reason, the self-review diff is now the working tree against `MB` plus untracked files, replacing `MB..HEAD`.

Validation after the fixes: the branch-current Python CLI (`validate_orchestration_artifacts` in module form, `plan` subcommand) and the installed MCP validator both pass. The plan has 20 tasks and 65 physical lines.
