# Regression: promotion module exit-code docstring and move-verification comment ([P6-T9], AC-20)

Timestamp: 2026-10-09T21-30
Command: git diff --numstat 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: `6	1	scripts/dev_tools/potential_to_issue.py` (6 added, 1 deleted). Merge-base substitution: 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a used in place of e7d3779b398604af919678c16c877c8539a86cc0 as recorded in [P0-T4].

## Block 2

Command: git diff -U0 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: every `+` and `-` content line is a docstring line (hunk at line 94, inside the PromotionOutcome docstring) or a `#` comment line (hunk after line 347, in promote_potential). No executable line changed.

```
@@ -94 +94,3 @@ class PromotionOutcome:
-        exit_code (int): Final process-style exit code.
+        exit_code (int): Final process-style exit code: 0 on success; the gh
+            create exit code when issue creation fails; 1 when the promoted
+            file is missing after the move.
@@ -347,0 +350,3 @@ def promote_potential(
+    # Verify the move produced the destination before reporting success. A
+    # missing destination is a non-zero outcome (not a raised error) so the
+    # caller still receives every emitted line, including the created issue URL.
```

The comment matches extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts lines 440-442 except "raised" in place of "thrown".

## Block 3

Command: poetry run black --check "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: `1 file would be left unchanged.`

## Block 4

Command: poetry run ruff check "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: `All checks passed!`

## Block 5

Command: poetry run pyright "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: `0 errors, 0 warnings, 0 informations` (plus a newer-version notice v1.1.409 -> v1.1.414, not a diagnostic).

## Block 6

Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" -q
EXIT_CODE: 0
Output Summary: 3 passed in 0.06s.

Acceptance (AC-20): every block shows the stated result. PASS.
