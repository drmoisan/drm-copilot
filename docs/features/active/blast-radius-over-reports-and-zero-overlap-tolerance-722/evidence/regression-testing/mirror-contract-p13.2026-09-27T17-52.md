# Mirror Contract and Rule-file Tokens, Phase 13 (P13-T2)

Timestamp: 2026-09-27T17-52
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files
EXIT_CODE: 0
Output Summary: A10 printed "COPIED .claude/rules/parallel-orchestration.md" and the two A5 Hash values are equal (3EE4D1358C08DF792A3CA98D786DDB589D9CA812512B11E2C0BC9D27DD6AA867). The first B27 node exits 0 with one PASSED line. The B43 Python run exits 0 with 92 passed and no FAILED node (so every FAILED node is trivially in the P0-T18 baseline set). The B43 TypeScript run exits 0 with 3 suites and 57 tests passed and no line beginning "FAIL " (so every FAIL line is trivially in the P0-T31 baseline set). Every Part B token of block B26 has a worktree count greater than its BASE_SHA count: "Write-intent extraction" 3 > 0, "Known false negatives" 1 > 0, write_intent_extraction 4 > 0, path_roots 6 > 0, copilot-instructions.md 2 > 0. The second B27 node (run alone) is recorded in bundle-payload-p13.2026-09-27T17-52.md as KL-510: STATE-ONLY.

The artifact's EXIT_CODE refers to the first B27 node run; the exit code of every other command is recorded below. Each CMD-GIT-GREP-COUNT-BASE run exits 1 with no output, which is a count of zero.

## Commands and exit codes

| Step | Command | EXIT_CODE | Result |
| --- | --- | --- | --- |
| A10 | sh SCRATCH/run-ps.sh SCRATCH/copy-file.ps1 -Source .claude/rules/parallel-orchestration.md -Destination extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md | 0 | COPIED .claude/rules/parallel-orchestration.md |
| A5 | sh SCRATCH/run-ps.sh SCRATCH/file-hashes.ps1 .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md | 0 | both Hash=3EE4D1358C08DF792A3CA98D786DDB589D9CA812512B11E2C0BC9D27DD6AA867 |
| B27 first node | poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files | 0 | 1 passed (one PASSED line) |
| B43 Python | poetry run pytest -v (the eight B43 Python files) | 0 | 92 passed, 0 failed |
| B43 TypeScript | npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/validate/parallel-kickoff-template-seam.test.ts test/lib/validate/parallel-cohort-barrier-parity.test.ts | 0 | Test Suites: 3 passed, 3 total; Tests: 57 passed, 57 total |
| B27 second node (alone) | poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts | 1 | KL-510 case (b); see bundle-payload-p13.2026-09-27T17-52.md |

## Part B token counts (block B26) against .claude/rules/parallel-orchestration.md

| Token | CMD-GIT-GREP-COUNT (worktree) | exit | CMD-GIT-GREP-COUNT-BASE (BASE_SHA beae3f021674e64fa6662097fe48a332d8da62b8) | exit | Worktree greater |
| --- | --- | --- | --- | --- | --- |
| Write-intent extraction | 3 | 0 | 0 (no output) | 1 | yes |
| Known false negatives | 1 | 0 | 0 (no output) | 1 | yes |
| write_intent_extraction | 4 | 0 | 0 (no output) | 1 | yes |
| path_roots | 6 | 0 | 0 (no output) | 1 | yes |
| copilot-instructions.md | 2 | 0 | 0 (no output) | 1 | yes |

The ten git grep commands were run as literal git invocations through SCRATCH/p13-token-counts.py, which prints each command's argv, output, and exit code, because the Bash tool does not display the exit status of a command that prints nothing.

SCRATCH denotes the executor session scratchpad directory (outside the repository).

## Raw outputs

### Token-count commands (p13-token-counts.py output)

```text
COMMAND git grep -c -F -e 'Write-intent extraction' -- .claude/rules/parallel-orchestration.md
OUTPUT .claude/rules/parallel-orchestration.md:3
EXIT_CODE=0
COMMAND git grep -c -F -e 'Write-intent extraction' beae3f021674e64fa6662097fe48a332d8da62b8 -- .claude/rules/parallel-orchestration.md
OUTPUT (none)
EXIT_CODE=1
TOKEN 'Write-intent extraction' worktree=3 base=0 greater=True
COMMAND git grep -c -F -e 'Known false negatives' -- .claude/rules/parallel-orchestration.md
OUTPUT .claude/rules/parallel-orchestration.md:1
EXIT_CODE=0
COMMAND git grep -c -F -e 'Known false negatives' beae3f021674e64fa6662097fe48a332d8da62b8 -- .claude/rules/parallel-orchestration.md
OUTPUT (none)
EXIT_CODE=1
TOKEN 'Known false negatives' worktree=1 base=0 greater=True
COMMAND git grep -c -F -e write_intent_extraction -- .claude/rules/parallel-orchestration.md
OUTPUT .claude/rules/parallel-orchestration.md:4
EXIT_CODE=0
COMMAND git grep -c -F -e write_intent_extraction beae3f021674e64fa6662097fe48a332d8da62b8 -- .claude/rules/parallel-orchestration.md
OUTPUT (none)
EXIT_CODE=1
TOKEN 'write_intent_extraction' worktree=4 base=0 greater=True
COMMAND git grep -c -F -e path_roots -- .claude/rules/parallel-orchestration.md
OUTPUT .claude/rules/parallel-orchestration.md:6
EXIT_CODE=0
COMMAND git grep -c -F -e path_roots beae3f021674e64fa6662097fe48a332d8da62b8 -- .claude/rules/parallel-orchestration.md
OUTPUT (none)
EXIT_CODE=1
TOKEN 'path_roots' worktree=6 base=0 greater=True
COMMAND git grep -c -F -e copilot-instructions.md -- .claude/rules/parallel-orchestration.md
OUTPUT .claude/rules/parallel-orchestration.md:2
EXIT_CODE=0
COMMAND git grep -c -F -e copilot-instructions.md beae3f021674e64fa6662097fe48a332d8da62b8 -- .claude/rules/parallel-orchestration.md
OUTPUT (none)
EXIT_CODE=1
TOKEN 'copilot-instructions.md' worktree=2 base=0 greater=True
```

### B43 Python result lines

```text
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_cites_three_argument_contention_signature PASSED [  1%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_uses_import_only_upstream_invocation PASSED [  2%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_cites_two_parameter_cohort_seeding_signature PASSED [  3%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_cites_derivation_over_document_text PASSED [  4%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_documents_the_cohort_recomputation_parity_obligation PASSED [  5%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_attributes_git_integrity_verification_to_f4 PASSED [  6%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_claims_the_kickoff_contract_as_delivered_by_this_feature PASSED [  7%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py::test_skill_cites_planner_invariant_p5_as_the_parity_basis PASSED [  8%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_parallel_planner_surface_files_exist PASSED [  9%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_parallel_intake_requires_consolidation_before_execution PASSED [ 10%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_agent_frontmatter_declares_required_tool_allowlist PASSED [ 11%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_agent_frontmatter_declares_name_and_preloaded_skills PASSED [ 13%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_frontmatter_routes_to_the_parallel_planner_agent PASSED [ 14%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_carries_the_preparation_mode_kickoff_markers PASSED [ 15%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_branches_preparation_worktrees_from_origin_main PASSED [ 16%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_names_the_planner_checkpoint_and_manifest_paths PASSED [ 17%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_names_both_kickoff_artifact_paths PASSED [ 18%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_agent_frontmatter_declares_no_epic_docs_scope PASSED [ 19%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_preparation_kickoff_line_carries_neither_mode_marker PASSED [ 20%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_omission_of_mode_markers_is_stated_deliberately PASSED [ 21%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_contains_no_dependency_authoring_instruction PASSED [ 22%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_contains_no_integration_branch_creation_instruction PASSED [ 23%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_skill_contains_no_worthiness_gate PASSED [ 25%]
tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py::test_protected_surfaces_retain_their_identifying_content PASSED [ 26%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_extracted_template_is_the_documented_kickoff_block PASSED [ 27%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_rendered_template_with_integrity_validates_clean PASSED [ 28%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_rendered_template_without_integrity_validates_clean PASSED [ 29%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_rendered_template_captures_planning_commit PASSED [ 30%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_resume_boundary_accepts_each_documented_alternant[Every item-resumes] PASSED [ 31%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_resume_boundary_accepts_each_documented_alternant[Each item-resumes] PASSED [ 32%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_resume_boundary_accepts_each_documented_alternant[items-resume] PASSED [ 33%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_resume_boundary_rejects_an_undocumented_subject PASSED [ 34%]
tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py::test_committed_fixture_and_template_agree_on_the_resume_clause PASSED [ 35%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_meets_the_documented_minimum_size PASSED [ 36%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_discovered_corpus_count_equals_the_json_file_count PASSED [ 38%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_exercises_both_verdicts PASSED [ 39%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[both-timestamps-absent] PASSED [ 40%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[clean-ordered-two-cohort-pair] PASSED [ 41%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[cohorts-as-index-only-objects] PASSED [ 42%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[cohorts-as-object] PASSED [ 43%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[cohorts-as-string-list] PASSED [ 44%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[conflict-edges-as-object] PASSED [ 45%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[conflict-edges-as-string-list] PASSED [ 46%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[conflict-edges-with-null-entry] PASSED [ 47%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[cross-cohort-later-start-earlier-pr-open] PASSED [ 48%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[earlier-ci-green-does-not-satisfy-barrier] PASSED [ 50%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[earlier-cohort-endpoint-named-first] PASSED [ 51%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[endpoint-outside-current-coloring] PASSED [ 52%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[feature-folder-hint-cohort-membership] PASSED [ 53%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[gating-key-absent-cohorts] PASSED [ 54%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[gating-key-absent-conflict-edges] PASSED [ 55%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[gating-keys-absent-both] PASSED [ 56%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[items-as-object] PASSED [ 57%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[later-item-absent-merge-status-and-start] PASSED [ 58%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[merge-confirmed-after-later-start] PASSED [ 59%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[merge-confirmed-before-later-start] PASSED [ 60%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[merged-at-absent-start-present] PASSED [ 61%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[merged-at-present-start-absent] PASSED [ 63%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[non-integer-recolor-generation] PASSED [ 64%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[non-string-timestamps-both-endpoints] PASSED [ 65%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[same-cohort-conflicting-pair] PASSED [ 66%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[self-edge] PASSED [ 67%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[start-timestamp-alone-evidences-start] PASSED [ 68%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[superseded-generation-cohorts-ignored] PASSED [ 69%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[three-conflicting-items-one-cohort] PASSED [ 70%]
tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py::test_corpus_document_reproduces_the_expected_barrier_errors[unresolved-edge-endpoint] PASSED [ 71%]
tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py::test_item_carrying_mergeable_conflicts_resolved_yields_no_errors PASSED [ 72%]
tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py::test_item_omitting_mergeable_conflicts_resolved_yields_no_errors PASSED [ 73%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_every_claude_rule_carries_parseable_paths_and_description PASSED [ 75%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_unconditional_rule_set_is_exactly_the_four_deliberate_files PASSED [ 76%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_orchestrator_state_rule_paths_reach_every_checkpoint_writer PASSED [ 77%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_plan_acceptance_gates_rule_paths_cover_both_dispatchers PASSED [ 78%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_parallel_orchestration_rule_paths_cover_blast_radius_config PASSED [ 79%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_every_agent_preloaded_skill_resolves_to_an_existing_skill_file PASSED [ 80%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_epic_orchestrator_preloads_exactly_three_skills PASSED [ 81%]
tests/scripts/dev_tools/test_claude_rules_frontmatter.py::test_no_unqualified_spec_section_citation_under_claude PASSED [ 82%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_push_down_customizations_copies_codex_and_agents_paths PASSED [ 83%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_push_down_customizations_excludes_ephemeral_codex_state PASSED [ 84%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_no_argument_push_down_publishes_full_tree_and_artifact_path PASSED [ 85%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_push_down_customizations_writes_codex_and_agents_artifact PASSED [ 86%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_main_prints_summary_artifact_path_for_codex_and_agents_scope PASSED [ 88%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity PASSED [ 89%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_every_selected_pack_generates_identical_handoff_runtime_files PASSED [ 90%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged PASSED [ 91%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_codex_guidance_requires_independent_expected_context PASSED [ 92%]
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_startup_protocol_has_three_contiguous_steps_without_read_instructions PASSED [ 93%]
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_orchestrate_skill_has_no_prerequisites_heading PASSED [ 94%]
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_skill_documents_bounded_child_return_contract_section PASSED [ 95%]
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_bounded_return_shape_names_every_required_field PASSED [ 96%]
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_bounded_return_section_states_discard_and_rederivation PASSED [ 97%]
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_epic_mode_kickoff_line_carries_child_facing_constraint PASSED [ 98%]
tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py::test_orchestrate_skill_carries_matching_child_side_statement PASSED [100%]
============================= 92 passed in 0.36s ==============================
```

### B43 TypeScript output

```text

> drm-copilot@1.1.12 test
> node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/validate/parallel-kickoff-template-seam.test.ts test/lib/validate/parallel-cohort-barrier-parity.test.ts


Test Suites: 3 passed, 3 total
Tests:       57 passed, 57 total
Snapshots:   0 total
Time:        0.311 s, estimated 1 s
Ran all test suites matching test/lib/push-down/claude-pack-manifest-completeness.test.ts|test/lib/validate/parallel-kickoff-template-seam.test.ts|test/lib/validate/parallel-cohort-barrier-parity.test.ts.
```

### p13-token-counts.py

```python
"""Run CMD-GIT-GREP-COUNT and CMD-GIT-GREP-COUNT-BASE for each Part B token of block B26.

Prints each command, its output, its exit code, and the parsed count (an exit of 1 with no output is
a count of zero), then a GREATER verdict per token.
"""

import shutil
import subprocess

git = shutil.which("git")
if git is None:
    raise SystemExit("git executable not found")

BASE_SHA = "beae3f021674e64fa6662097fe48a332d8da62b8"
RULE = ".claude/rules/parallel-orchestration.md"
TOKENS = (
    "Write-intent extraction",
    "Known false negatives",
    "write_intent_extraction",
    "path_roots",
    "copilot-instructions.md",
)


def count(argv: list[str]) -> int:
    """Run one git grep -c command, print its record, and return the parsed count."""
    completed = subprocess.run([git, *argv], capture_output=True, text=True, encoding="utf-8", check=False)
    output = completed.stdout.strip()
    print(f"COMMAND git {' '.join(repr(a) if ' ' in a else a for a in argv)}")
    print(f"OUTPUT {output if output else '(none)'}")
    print(f"EXIT_CODE={completed.returncode}")
    # Exit 1 with no output is a zero count; exit 0 prints path:count (or base:path:count).
    if completed.returncode == 1 and not output:
        return 0
    if completed.returncode != 0:
        raise SystemExit(f"unexpected exit {completed.returncode}: {completed.stderr}")
    return int(output.rsplit(":", 1)[1])


# Compare each token's worktree count with its BASE_SHA count.
for token in TOKENS:
    worktree = count(["grep", "-c", "-F", "-e", token, "--", RULE])
    base = count(["grep", "-c", "-F", "-e", token, BASE_SHA, "--", RULE])
    print(f"TOKEN {token!r} worktree={worktree} base={base} greater={worktree > base}")
```
