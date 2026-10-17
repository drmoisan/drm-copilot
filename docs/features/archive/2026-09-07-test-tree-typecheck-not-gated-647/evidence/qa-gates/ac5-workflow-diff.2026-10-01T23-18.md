# AC-5 workflow diff (#647)

Timestamp: 2026-10-01T23-18
Command: git diff --numstat 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- .github/workflows/_drm-copilot-extension-tests.yml ; git diff -U0 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- .github/workflows/_drm-copilot-extension-tests.yml ; actionlint .github/workflows/_drm-copilot-extension-tests.yml; echo "EXIT=$?"
EXIT_CODE: 0

numstat: `3	0	.github/workflows/_drm-copilot-extension-tests.yml`

-U0 diff:
```
@@ -28,0 +29,3 @@ jobs:
+      - name: Type-check extension source and test tree
+        run: npm --prefix extensions/drm-copilot run typecheck
+
```

actionlint output: `EXIT=0` (exactly; P8-T10 run on the same file content)

Output Summary: three added lines (name, run, blank), none removed; the step sits after `Install extension dependencies` and before `Run extension unit/integration tests`; actionlint clean. The test `extension tests workflow runs the typecheck script before tests` passed in P8-T6.
