# P4-T1 architecture checker correction

The first architecture assertion rejected retained pure lexical path operations. Only the temporary checker changed; all 26 frozen source/test hashes remain exact. The failed command receipt is retained, and the final sequence restarted at formatting.

The original checker is reconstructed from the exact recorded patch; its digest was not captured before editing. The corrected checker and reconstruction are retained as text alongside this receipt.

```diff
--- before/checker.py
+++ after/checker.py
@@ -20,7 +20,15 @@
                 imports.append(node.module)
             elif isinstance(node, ast.Import):
                 imports.extend(alias.name for alias in node.names)
-        assert not any(value.startswith(('scripts', 'subprocess', 'socket', 'requests', 'http', 'urllib', 'os')) for value in imports), path
+        assert not any(value.startswith(('scripts', 'subprocess', 'socket', 'requests', 'http', 'urllib')) for value in imports), path
+        # Retained lexical path operations are pure; reject any other os access.
+        for node in ast.walk(source):
+            if isinstance(node, ast.Attribute):
+                expression = ast.unparse(node)
+                if expression.startswith('os.'):
+                    assert expression in ('os.path', 'os.path.relpath', 'os.sep'), (path, expression)
+            elif isinstance(node, ast.ImportFrom) and node.module == 'os':
+                raise AssertionError((path, 'Unreviewed direct os import'))
         assert not any('vsto' in value or 'office' in value or 'lxml' in value for value in imports), path
         if path.stem != 'pipeline':
             assert not any(value.endswith(('mutation_filesystem', 'init_io')) for value in imports), path

```
