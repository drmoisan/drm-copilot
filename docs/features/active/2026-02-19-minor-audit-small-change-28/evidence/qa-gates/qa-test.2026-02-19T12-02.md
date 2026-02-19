Timestamp: 2026-02-19T12-02
Command: poetry run pytest --cov=src/lexile_corpus_tuner --cov=scripts/dev_tools --cov-report=term-missing
EXIT_CODE: 0
Output Summary: ============================= test session starts ==============================

============================= test session starts ==============================
platform linux -- Python 3.13.8, pytest-9.0.2, pluggy-1.6.0
rootdir: /workspace/drm-copilot
configfile: pyproject.toml
testpaths: tests
plugins: cov-7.0.0
collected 786 items

tests/scripts/dev_tools/atomic_executor/test_cli.py .................... [  2%]
................................                                         [  6%]
tests/scripts/dev_tools/atomic_executor/test_copilot_backoff.py ...      [  6%]
tests/scripts/dev_tools/atomic_executor/test_copilot_rate_limiter.py ..  [  7%]
tests/scripts/dev_tools/atomic_executor/test_copilot_throttling_classifier.py . [  7%]
...........                                                              [  8%]
tests/scripts/dev_tools/atomic_executor/test_executor_throttle_bounded_retries.py . [  8%]
                                                                         [  8%]
tests/scripts/dev_tools/atomic_executor/test_executor_throttle_ordering.py . [  9%]
                                                                         [  9%]
tests/scripts/dev_tools/atomic_executor/test_executor_throttle_retry_regression.py . [  9%]
                                                                         [  9%]
tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py ....... [ 10%]
........                                                                 [ 11%]
tests/scripts/dev_tools/atomic_executor/test_plan_discovery.py ......... [ 12%]
                                                                         [ 12%]
tests/scripts/dev_tools/atomic_executor/test_plan_parser.py ............ [ 13%]
.........................                                                [ 16%]
tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py ......... [ 18%]
........                                                                 [ 19%]
tests/scripts/dev_tools/atomic_executor/test_pytest_expectations.py .... [ 19%]
.........                                                                [ 20%]
tests/scripts/dev_tools/atomic_executor/test_qc_runner.py .............. [ 22%]
..........                                                               [ 23%]
tests/scripts/dev_tools/atomic_executor/test_unicode_integration.py ..   [ 24%]
tests/scripts/dev_tools/test_agentic_sync.py ..........                  [ 25%]
tests/scripts/dev_tools/test_atomic_executor_cli.py ...............      [ 27%]
tests/scripts/dev_tools/test_clean_devcontainer.py ....                  [ 27%]
tests/scripts/dev_tools/test_collect_commit_context.py ................. [ 29%]
........                                                                 [ 30%]
tests/scripts/dev_tools/test_collect_pr_context.py ..................... [ 33%]
..........                                                               [ 34%]
tests/scripts/dev_tools/test_copy_research_to_issue.py ..........        [ 36%]
tests/scripts/dev_tools/test_feature_docs.py ........................... [ 39%]
.....                                                                    [ 40%]
tests/scripts/dev_tools/test_fix_all.py .............................    [ 43%]
tests/scripts/dev_tools/test_format_json.py .....................        [ 46%]
tests/scripts/dev_tools/test_git.py .......................              [ 49%]
tests/scripts/dev_tools/test_github.py ................................. [ 53%]
..........                                                               [ 54%]
tests/scripts/dev_tools/test_json_config.py ...............              [ 56%]
tests/scripts/dev_tools/test_markdown_label_formatter.py ............... [ 58%]
...............                                                          [ 60%]
tests/scripts/dev_tools/test_new_active_feature_folder.py .............. [ 62%]
...........................                                              [ 65%]
tests/scripts/dev_tools/test_new_active_feature_folder_bug_template_preserved.py . [ 66%]
                                                                         [ 66%]
tests/scripts/dev_tools/test_new_potential_bug_entry.py .............    [ 67%]
tests/scripts/dev_tools/test_plan_progress_report.py ..............      [ 69%]
tests/scripts/dev_tools/test_potential_to_issue.py ..................... [ 72%]
                                                                         [ 72%]
tests/scripts/dev_tools/test_pr_context_integration.py ....              [ 72%]
tests/scripts/dev_tools/test_render.py ................................. [ 76%]
.........................                                                [ 80%]
tests/scripts/dev_tools/test_render_helpers.py ......................... [ 83%]
...                                                                      [ 83%]
tests/scripts/dev_tools/test_resolve_execute_plan_prompt.py ............ [ 85%]
...............................                                          [ 89%]
tests/scripts/dev_tools/test_resolve_file_prompt.py ...............      [ 90%]
tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py ............... [ 92%]
.                                                                        [ 93%]
tests/scripts/dev_tools/test_shell_qc.py ............................    [ 96%]
tests/scripts/dev_tools/test_validate_json.py .......................... [ 99%]
./workspace/drm-copilot/.venv/lib/python3.13/site-packages/coverage/inorout.py:495: CoverageWarning: Module src/lexile_corpus_tuner was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
                                                                        [100%]

================================ tests coverage ================================
_______________ coverage: platform linux, python 3.13.8-final-0 ________________

Name                                                       Stmts   Miss  Cover   Missing
----------------------------------------------------------------------------------------
scripts/dev_tools/__init__.py                                  0      0   100%
scripts/dev_tools/agentic_sync.py                            169     30    82%   58, 62, 66, 70, 74, 78, 82, 119-127, 148, 169, 191-192, 213, 235, 256, 390, 465, 613, 617, 620, 768, 770, 775, 777
scripts/dev_tools/atomic_executor/__init__.py                  6      0   100%
scripts/dev_tools/atomic_executor/cli.py                     920    292    68%   104-109, 360, 396, 431, 438-440, 443, 499-500, 513, 524-525, 577, 599, 627-639, 665, 758, 838, 846, 850-851, 908-911, 920-926, 987, 997, 1011-1012, 1057, 1070-1073, 1093-1095, 1118-1126, 1181, 1200-1210, 1234-1245, 1320, 1329-1330, 1348, 1382-1386, 1396-1400, 1463, 1498-1500, 1520, 1560-1563, 1581, 1601-1664, 1718, 1797-1948, 1985-2120, 2219, 2221, 2250-2251, 2286-2287, 2318-2326, 2330, 2483, 2554, 2558-2560, 2607, 2614-2615, 2669, 2679-2684
scripts/dev_tools/atomic_executor/copilot_runner.py            6      0   100%
scripts/dev_tools/atomic_executor/copilot_throttling.py       90     10    89%   42, 67, 136, 138, 214, 216, 227, 229, 327, 340
scripts/dev_tools/atomic_executor/feature_resolver.py         61      1    98%   144
scripts/dev_tools/atomic_executor/plan_discovery.py           38      0   100%
scripts/dev_tools/atomic_executor/plan_parser.py             225     14    94%   346, 405, 416, 443, 527, 534, 547, 556, 571, 592, 632, 637, 654-655
scripts/dev_tools/atomic_executor/prompt_builder.py          128     36    72%   49, 53, 57, 61, 81, 89, 205, 212, 244-246, 256-257, 275, 328, 379, 383, 388-390, 411-434
scripts/dev_tools/atomic_executor/pytest_expectations.py     156     41    74%   57, 85, 193, 246-247, 284, 297-298, 304-307, 332-348, 361-384
scripts/dev_tools/atomic_executor/qc_runner.py               312    116    63%   140, 183, 209-210, 226, 230, 240-241, 280-318, 345-398, 422-423, 446-467, 517-528, 534, 549, 562, 571, 587, 604, 674, 714, 717, 741, 747-748, 783, 833, 837, 949-969, 1052-1056, 1066-1070
scripts/dev_tools/atomic_executor/qc_toolchain.py             15      0   100%
scripts/dev_tools/clean_devcontainer.py                       36      2    94%   165, 179
scripts/dev_tools/collect_commit_context.py                  123      1    99%   33
scripts/dev_tools/copy_research_to_issue.py                   80     41    49%   49, 52-53, 56, 78, 82, 159-165, 186-189, 217-231, 244-256, 276-314
scripts/dev_tools/fix_all.py                                 364     64    82%   59, 121, 123, 149, 153, 159, 187, 243, 270-293, 353, 409, 623, 649-651, 656-658, 689-691, 722-724, 746-748, 777-784, 820, 930-932, 959-961, 988-990, 1028, 1034, 1041-1042, 1122-1123
scripts/dev_tools/format_json.py                              67      0   100%
scripts/dev_tools/json_config.py                              20      2    90%   47, 49
scripts/dev_tools/markdown_label_formatter.py                 65      0   100%
scripts/dev_tools/new_active_feature_folder.py               406     42    90%   66, 69, 72-73, 76-81, 84-86, 89, 92-93, 96-100, 104, 135, 143, 215, 219, 253, 567-568, 869, 873, 877, 888, 1109-1123
scripts/dev_tools/new_potential_bug_entry.py                  91      8    91%   22, 37-44, 61, 140-146
scripts/dev_tools/plan_progress_report.py                     99     25    75%   147-148, 152, 176-179, 213, 299-305, 322-325, 338-359, 375-382
scripts/dev_tools/potential_to_issue.py                      276     18    93%   83, 95, 156, 165-166, 246, 255, 285, 292-293, 297, 301-302, 310, 384, 401, 411-412
scripts/dev_tools/pr_context/__init__.py                       2      0   100%
scripts/dev_tools/pr_context/collector.py                    191     15    92%   194, 201, 226, 253-254, 280-283, 296, 309, 351, 384, 440, 462
scripts/dev_tools/pr_context/feature_docs.py                 129      9    93%   108, 123, 131-132, 181-185
scripts/dev_tools/pr_context/git.py                           61      0   100%
scripts/dev_tools/pr_context/github.py                       350     23    93%   81, 89, 97, 104, 130, 139-140, 152, 162, 167, 176, 189, 196, 231-233, 301, 423, 446, 501, 512, 518, 545
scripts/dev_tools/pr_context/models.py                       121      1    99%   152
scripts/dev_tools/pr_context/render.py                       348     32    91%   74, 98-100, 110, 138, 321, 335, 343-344, 505, 515-516, 555, 559-565, 589, 624-636
scripts/dev_tools/pr_context/summary_helpers.py              154     14    91%   80, 239, 242, 273, 278, 283-284, 332-345
scripts/dev_tools/resolve_execute_plan_prompt.py             159      8    95%   149-150, 373, 416-417, 525-527
scripts/dev_tools/resolve_file_prompt.py                     148     10    93%   51, 105-114, 125, 225, 385, 395
scripts/dev_tools/resolve_hard_lock_prompt.py                 65      3    95%   79-80, 83
scripts/dev_tools/shell_qc.py                                209     31    85%   48, 52-53, 56, 62, 64, 76-77, 100, 155-156, 180-181, 201-202, 239-249, 263, 300-301, 370-372, 399, 450
scripts/dev_tools/tk_dialog_helpers.py                        99     57    42%   39-40, 64-67, 85-117, 133-159, 170-171, 184, 191, 236, 238, 245-260
scripts/dev_tools/validate_json.py                           123     25    80%   21, 105-127, 141, 146-150, 206-208
----------------------------------------------------------------------------------------
TOTAL                                                       5912    971    84%
============================= 786 passed in 4.85s ==============================
