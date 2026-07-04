Timestamp: 2026-07-04T14:32
Command: poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- poetry run pytest completed successfully.
- Test summary: ============================ 1280 passed in 7.13s =============================
- Numeric coverage: TOTAL                                                               9179   1242    86%

Raw Output:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-04-13-40
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.12.1, cov-7.0.0
collected 1280 items

tests\scripts\dev_tools\atomic_executor\test_cli.py ...................  [  1%]
tests\scripts\dev_tools\atomic_executor\test_cli_part2.py ........       [  2%]
tests\scripts\dev_tools\atomic_executor\test_cli_part2_part2.py .        [  2%]
tests\scripts\dev_tools\atomic_executor\test_cli_part3.py .............  [  3%]
tests\scripts\dev_tools\atomic_executor\test_cli_part4.py .......        [  3%]
tests\scripts\dev_tools\atomic_executor\test_cli_part4_part2.py ....     [  4%]
tests\scripts\dev_tools\atomic_executor\test_copilot_backoff.py ...      [  4%]
tests\scripts\dev_tools\atomic_executor\test_copilot_rate_limiter.py ..  [  4%]
tests\scripts\dev_tools\atomic_executor\test_copilot_throttling_classifier.py . [  4%]
...........                                                              [  5%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_bounded_retries.py . [  5%]
                                                                         [  5%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_ordering.py . [  5%]
                                                                         [  5%]
tests\scripts\dev_tools\atomic_executor\test_executor_throttle_retry_regression.py . [  5%]
                                                                         [  5%]
tests\scripts\dev_tools\atomic_executor\test_feature_resolver.py ....... [  6%]
........                                                                 [  6%]
tests\scripts\dev_tools\atomic_executor\test_plan_discovery.py ......... [  7%]
                                                                         [  7%]
tests\scripts\dev_tools\atomic_executor\test_plan_parser.py ............ [  8%]
.........................                                                [ 10%]
tests\scripts\dev_tools\atomic_executor\test_prompt_builder.py ......... [ 11%]
........                                                                 [ 11%]
tests\scripts\dev_tools\atomic_executor\test_pytest_expectations.py .... [ 12%]
.........                                                                [ 12%]
tests\scripts\dev_tools\atomic_executor\test_qc_runner.py .............. [ 13%]
..........                                                               [ 14%]
tests\scripts\dev_tools\atomic_executor\test_unicode_integration.py ..   [ 14%]
tests\scripts\dev_tools\codex_native_converter\test_classifier.py ...... [ 15%]
.                                                                        [ 15%]
tests\scripts\dev_tools\codex_native_converter\test_cli_apply.py .       [ 15%]
tests\scripts\dev_tools\codex_native_converter\test_cli_entrypoints.py . [ 15%]
.......                                                                  [ 16%]
tests\scripts\dev_tools\codex_native_converter\test_cli_review.py .      [ 16%]
tests\scripts\dev_tools\codex_native_converter\test_end_to_end.py ...    [ 16%]
tests\scripts\dev_tools\codex_native_converter\test_intermediate_state.py . [ 16%]
..                                                                       [ 16%]
tests\scripts\dev_tools\codex_native_converter\test_inventory.py ..      [ 16%]
tests\scripts\dev_tools\codex_native_converter\test_mapping.py .....     [ 17%]
tests\scripts\dev_tools\codex_native_converter\test_parser.py ...        [ 17%]
tests\scripts\dev_tools\codex_native_converter\test_prompt_decomposition_end_to_end.py . [ 17%]
..                                                                       [ 17%]
tests\scripts\dev_tools\codex_native_converter\test_reporting.py .       [ 17%]
tests\scripts\dev_tools\codex_native_converter\test_reporting_topology_end_to_end.py . [ 17%]
                                                                         [ 17%]
tests\scripts\dev_tools\codex_native_converter\test_rewrites.py ........ [ 18%]
...                                                                      [ 18%]
tests\scripts\dev_tools\codex_native_converter\test_section_classifier.py . [ 18%]
                                                                         [ 18%]
tests\scripts\dev_tools\codex_native_converter\test_section_intent.py .. [ 18%]
........                                                                 [ 19%]
tests\scripts\dev_tools\codex_native_converter\test_validation.py .....  [ 19%]
tests\scripts\dev_tools\test_agentic_sync.py ...........                 [ 20%]
tests\scripts\dev_tools\test_atomic_executor_cli.py ...............      [ 21%]
tests\scripts\dev_tools\test_clean_devcontainer.py ....                  [ 22%]
tests\scripts\dev_tools\test_codex_agent_wrapper_contracts.py ......     [ 22%]
tests\scripts\dev_tools\test_codex_full_migration_inventory.py ...       [ 22%]
tests\scripts\dev_tools\test_codex_handoff_contract_parity.py .....      [ 23%]
tests\scripts\dev_tools\test_codex_orchestration_contracts.py ...        [ 23%]
tests\scripts\dev_tools\test_collect_commit_context.py ................. [ 24%]
........                                                                 [ 25%]
tests\scripts\dev_tools\test_collect_pr_context.py ..................... [ 27%]
                                                                         [ 27%]
tests\scripts\dev_tools\test_collect_pr_context_part2.py .........       [ 27%]
tests\scripts\dev_tools\test_collect_pr_context_part3.py ..              [ 27%]
tests\scripts\dev_tools\test_collect_pr_context_part4.py .....           [ 28%]
tests\scripts\dev_tools\test_compute_complexity_floor.py .........       [ 29%]
tests\scripts\dev_tools\test_copy_research_to_issue.py ..........        [ 29%]
tests\scripts\dev_tools\test_csharp_orchestration_contracts.py ......    [ 30%]
tests\scripts\dev_tools\test_epic_wave_computation.py ........           [ 30%]
tests\scripts\dev_tools\test_feature_docs.py ........................... [ 33%]
........                                                                 [ 33%]
tests\scripts\dev_tools\test_fix_all.py ................                 [ 34%]
tests\scripts\dev_tools\test_fix_all_branches.py .....................   [ 36%]
tests\scripts\dev_tools\test_fix_all_failure_paths.py ............       [ 37%]
tests\scripts\dev_tools\test_format_json.py ....................         [ 39%]
tests\scripts\dev_tools\test_git.py .......................              [ 40%]
tests\scripts\dev_tools\test_github.py ........................          [ 42%]
tests\scripts\dev_tools\test_github_part2.py .............               [ 43%]
tests\scripts\dev_tools\test_github_part3.py ......                      [ 44%]
tests\scripts\dev_tools\test_json_config.py ...............              [ 45%]
tests\scripts\dev_tools\test_markdown_label_formatter.py ............... [ 46%]
...............                                                          [ 47%]
tests\scripts\dev_tools\test_minor_audit_acceptance_criteria_contracts.py . [ 47%]
..                                                                       [ 47%]
tests\scripts\dev_tools\test_new_active_feature_folder.py .............. [ 49%]
.                                                                        [ 49%]
tests\scripts\dev_tools\test_new_active_feature_folder_bug_template_preserved.py . [ 49%]
                                                                         [ 49%]
tests\scripts\dev_tools\test_new_active_feature_folder_markdown_escape.py . [ 49%]
.                                                                        [ 49%]
tests\scripts\dev_tools\test_new_active_feature_folder_models_coverage.py . [ 49%]
.........                                                                [ 50%]
tests\scripts\dev_tools\test_new_active_feature_folder_part2.py ........ [ 50%]
......                                                                   [ 51%]
tests\scripts\dev_tools\test_new_active_feature_folder_part3.py ........ [ 51%]
..........                                                               [ 52%]
tests\scripts\dev_tools\test_new_active_feature_folder_part4.py ........ [ 53%]
..                                                                       [ 53%]
tests\scripts\dev_tools\test_new_potential_bug_entry.py ................ [ 54%]
                                                                         [ 54%]
tests\scripts\dev_tools\test_orchestration_guardrail_contracts.py ...... [ 55%]
....                                                                     [ 55%]
tests\scripts\dev_tools\test_orchestration_routing_config_parity.py .    [ 55%]
tests\scripts\dev_tools\test_orchestrator_direct_command_contracts.py .. [ 55%]
..                                                                       [ 55%]
tests\scripts\dev_tools\test_plan_progress_report.py ..............      [ 56%]
tests\scripts\dev_tools\test_poshqc_bundled_parity.py .                  [ 57%]
tests\scripts\dev_tools\test_potential_to_issue.py ..................... [ 58%]
.......                                                                  [ 59%]
tests\scripts\dev_tools\test_potential_to_issue_content.py ........      [ 59%]
tests\scripts\dev_tools\test_potential_to_issue_missing_label_regression.py . [ 59%]
                                                                         [ 59%]
tests\scripts\dev_tools\test_pr_context_integration.py .....             [ 60%]
tests\scripts\dev_tools\test_prompt_mode_contract.py ..............      [ 61%]
tests\scripts\dev_tools\test_push_down_claude_customizations.py ........ [ 62%]
                                                                         [ 62%]
tests\scripts\dev_tools\test_push_down_claude_memory_scope.py .......... [ 62%]
..                                                                       [ 62%]
tests\scripts\dev_tools\test_push_down_claude_pack_end_to_end.py .....   [ 63%]
tests\scripts\dev_tools\test_push_down_claude_pack_memory_modes.py ....  [ 63%]
tests\scripts\dev_tools\test_push_down_claude_pack_selection.py ........ [ 64%]
........                                                                 [ 64%]
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .... [ 65%]
...                                                                      [ 65%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_customizations.py . [ 65%]
......                                                                   [ 66%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_resource_contracts.py . [ 66%]
....                                                                     [ 66%]
tests\scripts\dev_tools\test_push_down_codex_pack_selection.py ......... [ 67%]
...........                                                              [ 67%]
tests\scripts\dev_tools\test_push_down_copilot_customizations.py ...     [ 68%]
tests\scripts\dev_tools\test_push_down_copilot_customizations_helpers.py . [ 68%]
...............                                                          [ 69%]
tests\scripts\dev_tools\test_push_down_copilot_customizations_rewrites.py . [ 69%]
.....                                                                    [ 69%]
tests\scripts\dev_tools\test_pyright_config_alignment.py ..              [ 70%]
tests\scripts\dev_tools\test_render.py ................................. [ 72%]
.........................                                                [ 74%]
tests\scripts\dev_tools\test_render_helpers.py ......................... [ 76%]
...                                                                      [ 76%]
tests\scripts\dev_tools\test_resolve_delegation_model.py ............... [ 77%]
.....                                                                    [ 78%]
tests\scripts\dev_tools\test_resolve_execute_plan_prompt.py ............ [ 79%]
..............                                                           [ 80%]
tests\scripts\dev_tools\test_resolve_execute_plan_prompt_part2.py ...... [ 80%]
.............                                                            [ 81%]
tests\scripts\dev_tools\test_resolve_execute_plan_prompt_part3.py ..     [ 82%]
tests\scripts\dev_tools\test_resolve_file_prompt.py .................... [ 83%]
.                                                                        [ 83%]
tests\scripts\dev_tools\test_resolve_hard_lock_prompt.py ............... [ 84%]
...                                                                      [ 85%]
tests\scripts\dev_tools\test_resolve_hard_lock_prompt_output.py ........ [ 85%]
.                                                                        [ 85%]
tests\scripts\dev_tools\test_resolve_hard_lock_prompt_part2.py ......    [ 86%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state.py ....... [ 86%]
................                                                         [ 88%]
tests\scripts\dev_tools\test_validate_evidence_locations.py .......      [ 88%]
tests\scripts\dev_tools\test_validate_json.py .......................... [ 90%]
.                                                                        [ 90%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts.py ....... [ 91%]
.                                                                        [ 91%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_dispatch.py . [ 91%]
........                                                                 [ 92%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_pr_creation_readiness.py . [ 92%]
.                                                                        [ 92%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_state_shape.py . [ 92%]
.......                                                                  [ 92%]
tests\scripts\dev_tools\test_validate_orchestrator_state.py ............ [ 93%]
.....                                                                    [ 94%]
tests\scripts\dev_tools\test_validate_orchestrator_state_complexity.py . [ 94%]
............                                                             [ 95%]
tests\scripts\dev_tools\test_validate_orchestrator_state_human_interaction.py . [ 95%]
.......                                                                  [ 95%]
tests\scripts\dev_tools\test_validate_orchestrator_state_model_routing.py . [ 95%]
..........                                                               [ 96%]
tests\scripts\dev_tools\test_validate_orchestrator_state_pr_creation_readiness.py . [ 96%]
........                                                                 [ 97%]
tests\scripts\dev_tools\test_validate_orchestrator_state_remediation_loop.py . [ 97%]
.........                                                                [ 98%]
tests\scripts\dev_tools\test_validate_orchestrator_state_routing_contract.py . [ 98%]
...........                                                              [ 99%]
tests\scripts\dev_tools\test_validate_policy_audit_artifact.py ......... [ 99%]
                                                                         [ 99%]
tests\scripts\dev_tools\test_vscode_workspace_settings.py ..             [ 99%]
tests\test_pytest_collection.py .                                        [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                               Stmts   Miss  Cover   Missing
------------------------------------------------------------------------------------------------
scripts\dev_tools\__init__.py                                          0      0   100%
scripts\dev_tools\_orchestrator_state_complexity.py                   45      0   100%
scripts\dev_tools\_orchestrator_state_human_interaction.py            32      0   100%
scripts\dev_tools\_orchestrator_state_model_routing.py                45      0   100%
scripts\dev_tools\_orchestrator_state_pr_creation_readiness.py        18      0   100%
scripts\dev_tools\_orchestrator_state_routing.py                     196     17    91%   84, 89, 94, 134, 183, 232, 275, 289, 317, 344, 369, 403, 407-410, 427, 432, 435
scripts\dev_tools\agentic_sync.py                                    187     30    84%   84, 88, 92, 96, 100, 104, 108, 145-153, 174, 195, 217-218, 239, 261, 282, 416, 491, 639, 643, 646, 794, 796, 801, 803
scripts\dev_tools\atomic_executor\__init__.py                          6      0   100%
scripts\dev_tools\atomic_executor\cli.py                             182     20    89%   88-90, 130-135, 229, 300, 304-306, 354, 361-362, 420, 430-435
scripts\dev_tools\atomic_executor\cli_copilot_runtime.py             235     41    83%   55, 61, 84-94, 100, 177, 239, 247, 251-252, 273-276, 284-289, 322, 329, 337-338, 375, 387-390, 407-409, 423-427
scripts\dev_tools\atomic_executor\cli_execute_one_task.py            133     14    89%   76-80, 101, 103, 131-132, 161-162, 192-200, 204
scripts\dev_tools\atomic_executor\cli_preflight.py                   153     54    65%   61, 70-71, 77, 93-97, 102-106, 155, 190-192, 212, 251-254, 270, 290-353, 392
scripts\dev_tools\atomic_executor\cli_task_runtime.py                169    151    11%   59-66, 76-84, 124-263, 290-407
scripts\dev_tools\atomic_executor\cli_workspace.py                   122     12    90%   167, 197, 222, 244, 249-250, 255, 288-289, 300, 311-312
scripts\dev_tools\atomic_executor\copilot_runner.py                    6      0   100%
scripts\dev_tools\atomic_executor\copilot_throttling.py               90     10    89%   42, 67, 136, 138, 214, 216, 227, 229, 327, 340
scripts\dev_tools\atomic_executor\feature_resolver.py                 61      1    98%   144
scripts\dev_tools\atomic_executor\plan_discovery.py                   38      0   100%
scripts\dev_tools\atomic_executor\plan_parser.py                     225     14    94%   346, 405, 416, 443, 527, 534, 547, 556, 571, 592, 632, 637, 654-655
scripts\dev_tools\atomic_executor\prompt_builder.py                  128     36    72%   49, 53, 57, 61, 81, 89, 205, 212, 244-246, 256-257, 275, 328, 379, 383, 388-390, 411-434
scripts\dev_tools\atomic_executor\pytest_expectations.py             156     41    74%   57, 85, 193, 246-247, 284, 297-298, 304-307, 332-348, 361-384
scripts\dev_tools\atomic_executor\qc_runner.py                       103      7    93%   152, 195, 300-301, 478, 510, 565
scripts\dev_tools\atomic_executor\qc_runner_expectations.py           85     48    44%   30-34, 39-43, 69-70, 86, 90, 97-98, 128-184
scripts\dev_tools\atomic_executor\qc_runner_loop.py                  110     30    73%   49, 54-55, 80, 83, 109, 126-145, 186-197, 202, 217, 233, 242, 259, 277
scripts\dev_tools\atomic_executor\qc_runner_process.py                31     12    61%   28-47, 52, 56
scripts\dev_tools\atomic_executor\qc_toolchain.py                     15      0   100%
scripts\dev_tools\clean_devcontainer.py                               36      2    94%   165, 179
scripts\dev_tools\codex_native_converter\__init__.py                   2      0   100%
scripts\dev_tools\codex_native_converter\__main__.py                   1      0   100%
scripts\dev_tools\codex_native_converter\_pipeline_traces.py          24      1    96%   110
scripts\dev_tools\codex_native_converter\_reporting_topology.py       57      0   100%
scripts\dev_tools\codex_native_converter\classifier.py                85      6    93%   85-86, 189, 256, 378, 447
scripts\dev_tools\codex_native_converter\cli.py                       45      0   100%
scripts\dev_tools\codex_native_converter\engine.py                   101      3    97%   187, 195, 239
scripts\dev_tools\codex_native_converter\intermediate_state.py        30      0   100%
scripts\dev_tools\codex_native_converter\inventory.py                 45      2    96%   156, 215
scripts\dev_tools\codex_native_converter\mapping.py                   48      3    94%   164-165, 189
scripts\dev_tools\codex_native_converter\models.py                    80      2    98%   348, 424
scripts\dev_tools\codex_native_converter\models_intermediate.py       66      0   100%
scripts\dev_tools\codex_native_converter\parser.py                    88      8    91%   89, 141-142, 174-175, 257-259
scripts\dev_tools\codex_native_converter\pipeline.py                  92      5    95%   140, 149, 270, 284, 447
scripts\dev_tools\codex_native_converter\reporting.py                 64      5    92%   117, 139-140, 325-333
scripts\dev_tools\codex_native_converter\rewrites.py                  46      4    91%   75, 81-83
scripts\dev_tools\codex_native_converter\section_intent.py            41      0   100%
scripts\dev_tools\codex_native_converter\validation.py                59      2    97%   176, 247
scripts\dev_tools\collect_commit_context.py                          123      1    99%   33
scripts\dev_tools\compute_complexity_floor.py                         14      0   100%
scripts\dev_tools\copy_research_to_issue.py                           80     41    49%   49, 52-53, 56, 78, 82, 159-165, 186-189, 217-231, 244-256, 276-314
scripts\dev_tools\epic_wave_computation.py                            26      0   100%
scripts\dev_tools\fix_all.py                                         184     18    90%   60, 122, 124, 150, 154, 160, 188, 244, 279, 284, 291-294, 354, 410, 618-619
scripts\dev_tools\fix_all_branches.py                                 82      3    96%   103-105
scripts\dev_tools\fix_all_branches_extra.py                           85      0   100%
scripts\dev_tools\fix_all_runtime.py                                  79      1    99%   77
scripts\dev_tools\format_json.py                                      64      0   100%
scripts\dev_tools\json_config.py                                      20      2    90%   47, 49
scripts\dev_tools\markdown_label_formatter.py                         65      0   100%
scripts\dev_tools\new_active_feature_folder.py                         7      0   100%
scripts\dev_tools\new_active_feature_folder_docs.py                   80      1    99%   263
scripts\dev_tools\new_active_feature_folder_flow.py                  132     12    91%   94, 272, 349-366
scripts\dev_tools\new_active_feature_folder_io.py                    105      3    97%   114-116
scripts\dev_tools\new_active_feature_folder_markdown.py               99      7    93%   56-59, 88, 92, 114
scripts\dev_tools\new_active_feature_folder_models.py                 73      1    99%   91
scripts\dev_tools\new_potential_bug_entry.py                         111      9    92%   28, 82-89, 147, 416-427
scripts\dev_tools\plan_progress_report.py                            101     27    73%   147-148, 152, 176-179, 213, 299-305, 322-325, 338-368, 384-392
scripts\dev_tools\potential_to_issue.py                              200     18    91%   128, 140, 255, 258, 261, 264, 267-268, 271, 274-275, 398, 415, 425-426, 432-433, 495
scripts\dev_tools\potential_to_issue_content.py                       95      4    96%   111, 114, 145, 172
scripts\dev_tools\pr_context\__init__.py                               2      0   100%
scripts\dev_tools\pr_context\collector.py                            223     17    92%   143-144, 260, 285, 300, 335-336, 362-365, 378, 391, 437, 470, 531, 553
scripts\dev_tools\pr_context\feature_docs.py                         168     11    93%   158, 162, 216, 240, 248-249, 305-309
scripts\dev_tools\pr_context\git.py                                   61      0   100%
scripts\dev_tools\pr_context\github.py                               350     23    93%   81, 89, 97, 104, 130, 139-140, 152, 162, 167, 176, 189, 196, 231-233, 301, 423, 446, 501, 512, 518, 545
scripts\dev_tools\pr_context\models.py                               123      1    99%   154
scripts\dev_tools\pr_context\render.py                               135     22    84%   157, 167-168, 207, 211-217, 241, 276-287
scripts\dev_tools\pr_context\render_feature_excerpts.py              144     24    83%   28, 33-35, 65-82, 204, 218, 226-227
scripts\dev_tools\pr_context\render_pr_helpers.py                    127      7    94%   65, 90-92, 103, 133, 266
scripts\dev_tools\pr_context\summary_helpers.py                      154     14    91%   80, 239, 242, 273, 278, 283-284, 332-345
scripts\dev_tools\pr_context\verification_evidence.py                 47      3    94%   104, 126-127
scripts\dev_tools\prompt_mode_contract.py                             44      1    98%   41
scripts\dev_tools\push_down_claude_customizations.py                  66      5    92%   86-95
scripts\dev_tools\push_down_claude_filesystem.py                     107     10    91%   139, 176-177, 289-290, 309, 340-342, 378, 393
scripts\dev_tools\push_down_claude_pack_selection.py                  74      5    93%   214, 229, 240, 256, 314
scripts\dev_tools\push_down_codex_and_agents_customizations.py        70      1    99%   250
scripts\dev_tools\push_down_codex_filesystem.py                       43      3    93%   54-55, 64
scripts\dev_tools\push_down_codex_pack_selection.py                   99      1    99%   94
scripts\dev_tools\push_down_copilot_customizations.py                130      7    95%   29-37, 331
scripts\dev_tools\push_down_copilot_customizations_filesystem.py      29      0   100%
scripts\dev_tools\push_down_copilot_customizations_rewrites.py        57      1    98%   248
scripts\dev_tools\resolve_delegation_model.py                         19      0   100%
scripts\dev_tools\resolve_execute_plan_prompt.py                     172      8    95%   154-155, 409, 452-453, 564-566
scripts\dev_tools\resolve_file_prompt.py                             183     13    93%   56, 110-119, 130, 230, 402, 477-478, 497, 507
scripts\dev_tools\resolve_hard_lock_prompt.py                        126      3    98%   145-146, 149
scripts\dev_tools\shell_qc.py                                        222    222     0%   3-491
scripts\dev_tools\tk_dialog_helpers.py                                99     57    42%   39-40, 64-67, 85-117, 133-159, 170-171, 184, 191, 236, 238, 245-260
scripts\dev_tools\validate_epic_orchestrator_state.py                158      6    96%   178, 185, 222, 320, 370, 375
scripts\dev_tools\validate_evidence_locations.py                      28      0   100%
scripts\dev_tools\validate_json.py                                   123     25    80%   21, 105-127, 141, 146-150, 206-208
scripts\dev_tools\validate_orchestration_artifacts.py                 92      7    92%   54, 105-109, 120, 135, 223, 225
scripts\dev_tools\validate_orchestration_review_artifacts.py          20      0   100%
scripts\dev_tools\validate_orchestrator_state.py                     153      4    97%   193, 220, 234, 334
scripts\dev_tools\validate_policy_audit_artifact.py                  125     12    90%   156, 340, 372, 376, 382, 386-389, 392, 398, 414, 420, 430
------------------------------------------------------------------------------------------------
TOTAL                                                               9179   1242    86%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 1280 passed in 7.13s =============================

