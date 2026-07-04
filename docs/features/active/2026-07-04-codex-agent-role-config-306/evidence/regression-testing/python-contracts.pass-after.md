Timestamp: 2026-07-04T14-25
Command: poetry run pytest tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Pytest completed successfully.
- Test summary: ============================= 11 passed in 1.32s ==============================
- Numeric coverage: TOTAL                                                               9179   9172     1%

Raw Output:
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot-wt-2026-07-04-13-40
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 11 items

tests\scripts\dev_tools\test_codex_agent_wrapper_contracts.py ......     [ 54%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_resource_contracts.py . [ 63%]
....                                                                     [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                               Stmts   Miss  Cover   Missing
------------------------------------------------------------------------------------------------
scripts\dev_tools\__init__.py                                          0      0   100%
scripts\dev_tools\_orchestrator_state_complexity.py                   45     45     0%   32-207
scripts\dev_tools\_orchestrator_state_human_interaction.py            32     32     0%   28-127
scripts\dev_tools\_orchestrator_state_model_routing.py                45     45     0%   32-216
scripts\dev_tools\_orchestrator_state_pr_creation_readiness.py        18     18     0%   30-118
scripts\dev_tools\_orchestrator_state_routing.py                     196    196     0%   3-477
scripts\dev_tools\agentic_sync.py                                    187    187     0%   11-815
scripts\dev_tools\atomic_executor\__init__.py                          6      6     0%   15-21
scripts\dev_tools\atomic_executor\cli.py                             182    182     0%   8-455
scripts\dev_tools\atomic_executor\cli_copilot_runtime.py             235    235     0%   3-439
scripts\dev_tools\atomic_executor\cli_execute_one_task.py            133    133     0%   3-308
scripts\dev_tools\atomic_executor\cli_preflight.py                   153    153     0%   3-394
scripts\dev_tools\atomic_executor\cli_task_runtime.py                169    169     0%   3-407
scripts\dev_tools\atomic_executor\cli_workspace.py                   122    122     0%   3-312
scripts\dev_tools\atomic_executor\copilot_runner.py                    6      6     0%   16-38
scripts\dev_tools\atomic_executor\copilot_throttling.py               90     90     0%   22-340
scripts\dev_tools\atomic_executor\feature_resolver.py                 61     61     0%   8-207
scripts\dev_tools\atomic_executor\plan_discovery.py                   38     38     0%   12-122
scripts\dev_tools\atomic_executor\plan_parser.py                     225    225     0%   8-669
scripts\dev_tools\atomic_executor\prompt_builder.py                  128    128     0%   8-434
scripts\dev_tools\atomic_executor\pytest_expectations.py             156    156     0%   5-384
scripts\dev_tools\atomic_executor\qc_runner.py                       103    103     0%   8-565
scripts\dev_tools\atomic_executor\qc_runner_expectations.py           85     85     0%   3-184
scripts\dev_tools\atomic_executor\qc_runner_loop.py                  110    110     0%   3-287
scripts\dev_tools\atomic_executor\qc_runner_process.py                31     31     0%   3-89
scripts\dev_tools\atomic_executor\qc_toolchain.py                     15     15     0%   8-75
scripts\dev_tools\clean_devcontainer.py                               36     36     0%   23-179
scripts\dev_tools\codex_native_converter\__init__.py                   2      2     0%   22-24
scripts\dev_tools\codex_native_converter\__main__.py                   1      1     0%   20
scripts\dev_tools\codex_native_converter\_pipeline_traces.py          24     24     0%   20-130
scripts\dev_tools\codex_native_converter\_reporting_topology.py       57     57     0%   23-175
scripts\dev_tools\codex_native_converter\classifier.py                85     85     0%   25-484
scripts\dev_tools\codex_native_converter\cli.py                       45     45     0%   24-308
scripts\dev_tools\codex_native_converter\engine.py                   101    101     0%   26-499
scripts\dev_tools\codex_native_converter\intermediate_state.py        30     30     0%   27-266
scripts\dev_tools\codex_native_converter\inventory.py                 45     45     0%   25-217
scripts\dev_tools\codex_native_converter\mapping.py                   48     48     0%   24-224
scripts\dev_tools\codex_native_converter\models.py                    80     80     0%   24-443
scripts\dev_tools\codex_native_converter\models_intermediate.py       66     66     0%   31-226
scripts\dev_tools\codex_native_converter\parser.py                    88     88     0%   26-285
scripts\dev_tools\codex_native_converter\pipeline.py                  92     92     0%   25-457
scripts\dev_tools\codex_native_converter\reporting.py                 64     64     0%   25-433
scripts\dev_tools\codex_native_converter\rewrites.py                  46     46     0%   26-485
scripts\dev_tools\codex_native_converter\section_intent.py            41     41     0%   25-243
scripts\dev_tools\codex_native_converter\validation.py                59     59     0%   25-409
scripts\dev_tools\collect_commit_context.py                          123    123     0%   7-208
scripts\dev_tools\compute_complexity_floor.py                         14     14     0%   42-108
scripts\dev_tools\copy_research_to_issue.py                           80     80     0%   15-314
scripts\dev_tools\epic_wave_computation.py                            26     26     0%   25-153
scripts\dev_tools\fix_all.py                                         184    184     0%   3-619
scripts\dev_tools\fix_all_branches.py                                 82     82     0%   34-375
scripts\dev_tools\fix_all_branches_extra.py                           85     78     8%   71-190, 213, 243-359
scripts\dev_tools\fix_all_runtime.py                                  79     79     0%   3-183
scripts\dev_tools\format_json.py                                      64     64     0%   1-155
scripts\dev_tools\json_config.py                                      20     20     0%   1-51
scripts\dev_tools\markdown_label_formatter.py                         65     65     0%   3-136
scripts\dev_tools\new_active_feature_folder.py                         7      7     0%   3-45
scripts\dev_tools\new_active_feature_folder_docs.py                   80     80     0%   3-268
scripts\dev_tools\new_active_feature_folder_flow.py                  132    132     0%   3-366
scripts\dev_tools\new_active_feature_folder_io.py                    105    105     0%   3-305
scripts\dev_tools\new_active_feature_folder_markdown.py               99     99     0%   3-252
scripts\dev_tools\new_active_feature_folder_models.py                 73     73     0%   3-133
scripts\dev_tools\new_potential_bug_entry.py                         111    111     0%   3-461
scripts\dev_tools\plan_progress_report.py                            101    101     0%   23-392
scripts\dev_tools\potential_to_issue.py                              200    200     0%   3-630
scripts\dev_tools\potential_to_issue_content.py                       95     95     0%   3-212
scripts\dev_tools\pr_context\__init__.py                               2      2     0%   3-5
scripts\dev_tools\pr_context\collector.py                            223    223     0%   3-607
scripts\dev_tools\pr_context\feature_docs.py                         168    168     0%   1-349
scripts\dev_tools\pr_context\git.py                                   61     61     0%   3-153
scripts\dev_tools\pr_context\github.py                               350    350     0%   3-549
scripts\dev_tools\pr_context\models.py                               123    123     0%   3-198
scripts\dev_tools\pr_context\render.py                               135    135     0%   3-328
scripts\dev_tools\pr_context\render_feature_excerpts.py              144    144     0%   3-256
scripts\dev_tools\pr_context\render_pr_helpers.py                    127    127     0%   3-291
scripts\dev_tools\pr_context\summary_helpers.py                      154    154     0%   3-386
scripts\dev_tools\pr_context\verification_evidence.py                 47     47     0%   14-167
scripts\dev_tools\prompt_mode_contract.py                             44     44     0%   12-157
scripts\dev_tools\push_down_claude_customizations.py                  66     66     0%   18-399
scripts\dev_tools\push_down_claude_filesystem.py                     107    107     0%   32-472
scripts\dev_tools\push_down_claude_pack_selection.py                  74     74     0%   39-398
scripts\dev_tools\push_down_codex_and_agents_customizations.py        70     70     0%   9-278
scripts\dev_tools\push_down_codex_filesystem.py                       43     43     0%   3-105
scripts\dev_tools\push_down_codex_pack_selection.py                   99     99     0%   3-210
scripts\dev_tools\push_down_copilot_customizations.py                130    130     0%   9-500
scripts\dev_tools\push_down_copilot_customizations_filesystem.py      29     29     0%   9-217
scripts\dev_tools\push_down_copilot_customizations_rewrites.py        57     57     0%   9-293
scripts\dev_tools\resolve_delegation_model.py                         19     19     0%   45-135
scripts\dev_tools\resolve_execute_plan_prompt.py                     172    172     0%   19-582
scripts\dev_tools\resolve_file_prompt.py                             183    183     0%   19-615
scripts\dev_tools\resolve_hard_lock_prompt.py                        126    126     0%   17-475
scripts\dev_tools\shell_qc.py                                        222    222     0%   3-491
scripts\dev_tools\tk_dialog_helpers.py                                99     99     0%   14-260
scripts\dev_tools\validate_epic_orchestrator_state.py                158    158     0%   29-488
scripts\dev_tools\validate_evidence_locations.py                      28     28     0%   16-105
scripts\dev_tools\validate_json.py                                   123    123     0%   1-274
scripts\dev_tools\validate_orchestration_artifacts.py                 92     92     0%   9-268
scripts\dev_tools\validate_orchestration_review_artifacts.py          20     20     0%   27-107
scripts\dev_tools\validate_orchestrator_state.py                     153    153     0%   24-495
scripts\dev_tools\validate_policy_audit_artifact.py                  125    125     0%   31-472
------------------------------------------------------------------------------------------------
TOTAL                                                               9179   9172     1%
Coverage LCOV written to file artifacts/python/lcov.info
============================= 11 passed in 1.32s ==============================
