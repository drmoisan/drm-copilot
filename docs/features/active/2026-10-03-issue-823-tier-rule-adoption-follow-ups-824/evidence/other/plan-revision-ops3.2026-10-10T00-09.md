# Plan Revision OPS-3: Exception-Set Extension for P8-T1

Timestamp: 2026-10-10T00-09
Command: git diff -- tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
EXIT_CODE: 0
Output Summary:
- Decision: orchestrator decision OPS-3 (recorded in artifacts/orchestration/orchestrator-state.json) authorizes adding the two `parallel-orchestration.md` paths to `PRE_EXISTING_NAME_EXCEPTIONS` as a plan revision. Editing `.claude/rules/parallel-orchestration.md` is a policy edit and is not authorized.
- Trigger: P8-T1 run at 2026-10-09T23-58 failed 1 of 43 (test_pushed_rule_and_skill_files_name_no_consuming_product) on `.claude/rules/parallel-orchestration.md` line 411 ("src/TaskMaster.Domain") and its claude bundle copy, introduced by commit b94dbc303 (#797), present at BASE_SHA, outside the write set.
- AC-5 basis: spec.md AC-5 reads "a test fails if TaskMaster or No-COM reappears in pushed rule or skill files ... with any pre-existing out-of-scope occurrences held in an explicit exception set guarded against staleness." The #797 occurrence is pre-existing and out of scope, so it belongs in that exception set. The edit extends plan-authored exception data and does not weaken any assertion; the staleness guard (test_name_exceptions_still_name_a_consuming_product) continues to fail if either new entry stops naming a product.
- P2-T1 unaffected: the recorded 38 passed / 5 failed expect-fail split predates this edit. The added entries only exclude files that the BASE_SHA tree already contained, so they do not change which tests P2-T1 recorded as failing for the planned reasons.
- Post-edit checks: `grep -c -F "parallel-orchestration.md"` = 2; `grep -c -F "PRE_EXISTING_NAME_EXCEPTIONS"` = 4; `wc -l` = 356 (limit 500).
- Follow-up: the product name in `.claude/rules/parallel-orchestration.md` (and its bundle copy) remains to be neutralized outside #824.

## Exact diff

```diff
diff --git a/tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py b/tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
index 1a89840bd..5f60241d3 100644
--- a/tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
+++ b/tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
@@ -113,6 +113,9 @@ PRE_EXISTING_NAME_EXCEPTIONS: frozenset[str] = frozenset(
         ".claude/rules/csharp.md",
         CLAUDE_BUNDLE + ".claude/rules/typescript.md",
         CLAUDE_BUNDLE + ".claude/rules/csharp.md",
+        # Added by #797 after #824 planning; out of scope for #824 (follow-up).
+        ".claude/rules/parallel-orchestration.md",
+        CLAUDE_BUNDLE + ".claude/rules/parallel-orchestration.md",
     }
 )
```
