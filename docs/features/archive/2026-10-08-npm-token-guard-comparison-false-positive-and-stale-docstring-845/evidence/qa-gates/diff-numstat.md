# Diff Numstat

Timestamp: 2026-10-09T20-58
Command: git fetch origin main ; git diff --numstat origin/main -- tests/scripts/dev_tools/test_workflow_npm_token_guard.py ; git diff --unified=0 origin/main -- tests/scripts/dev_tools/test_workflow_npm_token_guard.py
EXIT_CODE: 0
Output Summary: numstat is exactly 9 added, 4 removed for the test file. No removed line contains pytest.param( (the 4 removed lines are the F1, D1 (2 lines), and D2 "before" lines), so every existing row is preserved.

Numstat output, verbatim (tab-separated):

```text
9	4	tests/scripts/dev_tools/test_workflow_npm_token_guard.py
```

Unified diff (--unified=0) output, verbatim:

```text
diff --git a/tests/scripts/dev_tools/test_workflow_npm_token_guard.py b/tests/scripts/dev_tools/test_workflow_npm_token_guard.py
index f578752ad..dfd726482 100644
--- a/tests/scripts/dev_tools/test_workflow_npm_token_guard.py
+++ b/tests/scripts/dev_tools/test_workflow_npm_token_guard.py
@@ -48 +48 @@ _NPM_TOKEN_ASSIGNMENT = re.compile(
-    r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=", re.IGNORECASE
+    r"(?<![\w.-])[\"']?NPM_TOKEN[\"']?\s*:|\bNPM_TOKEN\s*=(?!=)", re.IGNORECASE
@@ -127,2 +127,3 @@ def find_npm_token_assignments(text: str) -> list[int]:
-    (``secrets.NPM_TOKEN``, ``env.NPM_TOKEN``), a longer or prefixed name, and
-    prose without ``:`` or ``=`` after the name are not reported.
+    (``secrets.NPM_TOKEN``, ``env.NPM_TOKEN``), an ``==`` comparison, a longer
+    or prefixed name, and prose without ``:`` or ``=`` after the name are not
+    reported.
@@ -208 +209 @@ def test_find_npm_token_references_detects_reintroduced_reference(
-    """A reintroduced ``NPM_TOKEN`` secret reference is reported at its line.
+    """A reintroduced ``NPM_TOKEN`` secret or variable reference is reported.
@@ -372,0 +374 @@ def test_find_npm_auth_token_config_references_ignores_non_matching_text(
+        pytest.param("NPM_TOKEN=", [1], id="empty-assignment-end-of-line"),
@@ -396,0 +399,3 @@ def test_find_npm_token_assignments_detects_assignment(
+        pytest.param("if: ${{ env.NPM_TOKEN == '' }}", id="equality-comparison"),
+        pytest.param('[[ $NPM_TOKEN == "" ]]', id="shell-equality-test"),
+        pytest.param("if: ${{ env.NPM_TOKEN != '' }}", id="inequality-comparison"),
```
