# Extraction floor untouched by the attributed-task-text field addition

Timestamp: 2026-08-26T00-31
Command: `git diff main -- tests/scripts/dev_tools/test_plan_gate_commands.py` and `git status --porcelain -- tests/scripts/dev_tools/test_plan_gate_commands.py`
EXIT_CODE: 0 (both spans)

Output Summary:
The anchored diff removes exactly two lines. Both belong to
`test_extract_plan_commands_returns_exact_record_fields`: its docstring (five
declared fields becoming six) and the inline acceptance string that was hoisted
into a local so the new whole-window assertion can name it. No removed line
belongs to `test_extract_plan_commands_skips_command_without_operand`, which is
the case that pins the two-word extraction floor; that case is untouched by the
diff and passes. `grep -c -F "_MINIMUM_ARGV_LENGTH = 2" scripts/dev_tools/plan_gate_commands.py`
reports 1, so the floor constant itself is unchanged at 2.

The porcelain companion span is present because an anchored diff alone cannot
report an untracked file. It reports ` M tests/scripts/dev_tools/test_plan_gate_commands.py`,
confirming the path is a tracked modification rather than an addition, so the
diff above is the complete change to that path.

## `git status --porcelain -- tests/scripts/dev_tools/test_plan_gate_commands.py`

```text
 M tests/scripts/dev_tools/test_plan_gate_commands.py
```

## `git diff main -- tests/scripts/dev_tools/test_plan_gate_commands.py`

```diff
diff --git a/tests/scripts/dev_tools/test_plan_gate_commands.py b/tests/scripts/dev_tools/test_plan_gate_commands.py
index ef5dcab1..ee8bd220 100644
--- a/tests/scripts/dev_tools/test_plan_gate_commands.py
+++ b/tests/scripts/dev_tools/test_plan_gate_commands.py
@@ -19,13 +19,14 @@ def _plan(*lines: str) -> str:
 
 
 def test_extract_plan_commands_returns_exact_record_fields() -> None:
-    """The extractor reports exactly the five declared record fields."""
+    """The extractor reports exactly the six declared record fields."""
 
     # Arrange
+    acceptance = "  - Acceptance: `grep -F -n 'MIT License' LICENSE` reports one match."
     text = _plan(
         "### Phase 1 — Work",
         _TASK_LINE,
-        "  - Acceptance: `grep -F -n 'MIT License' LICENSE` reports one match.",
+        acceptance,
     )
 
     # Act
@@ -38,6 +39,7 @@ def test_extract_plan_commands_returns_exact_record_fields() -> None:
         "raw_span",
         "source_line",
         "task_id",
+        "task_text",
     ]
     assert len(commands) == 1
     command = commands[0]
@@ -46,6 +48,66 @@ def test_extract_plan_commands_returns_exact_record_fields() -> None:
     assert command.raw_span == "grep -F -n 'MIT License' LICENSE"
     assert command.argv == ("grep", "-F", "-n", "MIT License", "LICENSE")
     assert command.kind == "grep"
+    assert command.task_text == "\n".join([_TASK_LINE, acceptance])
+
+
+def test_extract_plan_commands_populates_task_text_from_the_owning_task() -> None:
+    """Task text is the whole window, not just the line the span sits on."""
+
+    # Arrange
+    text = _plan(
+        "### Phase 1 — Work",
+        "- [ ] [P1-T1] First task",
+        "  - Acceptance: `poetry run pytest -q` reports 0 failed,",
+        "    and the summary line is recorded.",
+        "- [ ] [P1-T2] Second task",
+        "  - Acceptance: `poetry run ruff check scripts` reports 0 findings.",
+    )
+
+    # Act
+    commands = extract_plan_commands(text)
+
+    # Assert
+    assert len(commands) == 2
+    first, second = commands
+    assert first.task_text == "\n".join(
+        [
+            "- [ ] [P1-T1] First task",
+            "  - Acceptance: `poetry run pytest -q` reports 0 failed,",
+            "    and the summary line is recorded.",
+        ]
+    )
+    assert "Second task" not in first.task_text
+    assert second.task_text == "\n".join(
+        [
+            "- [ ] [P1-T2] Second task",
+            "  - Acceptance: `poetry run ruff check scripts` reports 0 findings.",
+        ]
+    )
+
+
+def test_extract_plan_commands_leaves_task_text_empty_outside_any_window() -> None:
+    """A span outside every window is dropped, so no record carries its text."""
+
+    # Arrange
+    text = _plan(
+        "# Plan",
+        "",
+        "Run `poetry run pytest -q` before starting.",
+        "",
+        "### Phase 1 — Work",
+        "",
+        "This phase ends with `poetry run ruff check scripts`.",
+        "",
+        _TASK_LINE,
+    )
+
+    # Act
+    commands = extract_plan_commands(text)
+
+    # Assert
+    assert commands == []
+    assert PlanCommand.__dataclass_fields__["task_text"].default == ""
 
 
 def test_extract_plan_commands_classifies_kind_grep_pytest_cov_and_other() -> None:
```

## Removed-line audit

| Removed line | Owning test | Belongs to the extraction-floor case? |
| --- | --- | --- |
| `"""The extractor reports exactly the five declared record fields."""` | `test_extract_plan_commands_returns_exact_record_fields` | no |
| `        "  - Acceptance: \`grep -F -n 'MIT License' LICENSE\` reports one match.",` | `test_extract_plan_commands_returns_exact_record_fields` | no |

Removed-line count: 2. Removed lines belonging to
`test_extract_plan_commands_skips_command_without_operand`: 0.
