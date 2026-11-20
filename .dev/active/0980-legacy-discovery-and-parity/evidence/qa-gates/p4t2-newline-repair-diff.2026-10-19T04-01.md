# P4-T2 bounded newline repair diff

Timestamp: 2026-10-19T04-01
Command: Compare reviewed and corrected solution parser bytes
EXIT_CODE: 0
Output Summary: Only the authorized two source/test paths changed.

```diff
--- packages/discovery-runtime/src/drm_copilot_discovery/analyzer/solution_input.py (reviewed)
+++ packages/discovery-runtime/src/drm_copilot_discovery/analyzer/solution_input.py (repaired)
@@ -93,7 +93,8 @@
         raise SolutionInputError(
             "solution-encoding", "Solution encoding is unsupported."
         ) from exc
-    lines = text.splitlines()
+    # Solution records use physical CR/LF boundaries; other Unicode stays literal.
+    lines = re.split(r"\r\n|\r|\n", text)
     # Require a supported header before any project declaration can become a fact.
     if not any(
         line.startswith("Microsoft Visual Studio Solution File, Format Version ")
--- tests/discovery_runtime/analyzer/test_solution_input.py (reviewed)
+++ tests/discovery_runtime/analyzer/test_solution_input.py (repaired)
@@ -205,3 +205,44 @@
     literal = "root/" + path
     content = solution(literal).encode()
     assert parse(content, max_bytes=len(content), max_entries=1)[0].path == literal
+
+
+@pytest.mark.parametrize("newline", ["\n", "\r\n", "\r"])
+@pytest.mark.parametrize(
+    "separator", ["\v", "\f", "\x1c", "\x1d", "\x1e", "\x85", "\u2028", "\u2029"]
+)
+def test_unicode_comment_separators_preserve_physical_anchor(
+    separator: str, newline: str
+) -> None:
+    """Keep separator (str) inside a comment on one physical newline (str) record.
+
+    Returns None; assertions detect shifted source anchors. No I/O or mutation.
+    """
+    text = (
+        HEADER
+        + "# inert comment"
+        + separator
+        + "still the same comment\n"
+        + solution().removeprefix(HEADER)
+    )
+    entries = parse(text.replace("\n", newline).encode())
+    assert len(entries) == 1
+    assert entries[0].line == 3
+
+
+@pytest.mark.parametrize("newline", ["\n", "\r\n", "\r"])
+@pytest.mark.parametrize(
+    "separator", ["\v", "\f", "\x1c", "\x1d", "\x1e", "\x85", "\u2028", "\u2029"]
+)
+def test_unicode_separators_in_quoted_path_remain_literal(
+    separator: str, newline: str
+) -> None:
+    """Round-trip separator (str) in a quoted path with physical newline (str).
+
+    Returns None; assertions detect text loss or false line breaks. No I/O.
+    """
+    literal = "src/App" + separator + "Name.csproj"
+    entries = parse(solution(literal).replace("\n", newline).encode())
+    assert len(entries) == 1
+    assert entries[0].path == literal
+    assert entries[0].line == 2
```
