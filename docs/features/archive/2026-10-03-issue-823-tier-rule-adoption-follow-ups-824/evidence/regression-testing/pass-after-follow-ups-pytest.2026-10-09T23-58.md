# P8-T1 Pass-After: Follow-Ups Pytest Module

Timestamp: 2026-10-09T23-58
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
EXIT_CODE: 1
SupersededBy: pass-after-follow-ups-pytest.2026-10-10T00-09.md
Output Summary:
- Summary: "1 failed, 42 passed". Acceptance requires 43 passed and no failed: NOT MET.
- Failing node: tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py::test_pushed_rule_and_skill_files_name_no_consuming_product
- Assertion: "pushed files naming a product: ['.claude/rules/parallel-orchestration.md', 'extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md']".
- Offending text: `.claude/rules/parallel-orchestration.md` line 411 contains "`src/TaskMaster.Domain`" (an example in the "Accepted residuals" paragraph); its CB mirror carries the same text.
- Origin: commit b94dbc303 ("docs(797): phase 5 document file-shape recognition and sync bundled mirrors"). `git merge-base --is-ancestor b94dbc303 <RESEARCH_BASE>` exit 1; `git merge-base --is-ancestor b94dbc303 <BASE_SHA>` exit 0; `git grep -c TaskMaster` on the file: BASE_SHA 1, RESEARCH_BASE 0, WIP_REF 0. `git log BASE_SHA..HEAD -- .claude/rules/parallel-orchestration.md` prints nothing (this plan did not touch the file). The offender is therefore pre-existing at BASE_SHA and was not anticipated by the PD5 exception set (typescript.md, csharp.md and their CB copies).
- Remediation route blocked within plan authority: the fix rule permits correcting only edited production or mirror files. `.claude/rules/parallel-orchestration.md` is not in the P0-T7 write set, and PD1 states "No other policy file is edited." Editing the test module is prohibited. No edit was made.
- Decision required (orchestrator/planner): either (a) authorize a neutral-name edit of `.claude/rules/parallel-orchestration.md` line 411 plus a `cp` re-sync of its CB mirror (adds two paths to the write set and one policy file to PD1), or (b) authorize adding the two parallel-orchestration paths to the pre-existing exception set in the test (a test edit, which requires explicit plan revision).
- The other 42 tests pass, including all six test_listed_copy_names_no_consuming_product cases, the 14 test_surface_does_not_hard_code_solution_file cases, test_pushed_roots_carry_no_hard_coded_solution_file, both test_review_workflow_step_eight_uses_governing_thresholds cases, the 14 test_precedence_copy_states_per_metric_fallback cases, test_name_exceptions_still_name_a_consuming_product, and test_pushed_rule_and_skill_scan_covers_the_listed_copies.
- Result: FAIL (task left unchecked).
