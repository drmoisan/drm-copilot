# AC-4 package.json diff (#647)

Timestamp: 2026-10-01T23-18
Command: git diff --numstat 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/package.json ; git diff -U0 1b1e349f1d0fb8b00eb69a809ef380fcc6eb35b9 -- extensions/drm-copilot/package.json
EXIT_CODE: 0

numstat: `2	1	extensions/drm-copilot/package.json`

-U0 diff:
```
@@ -209 +209,2 @@
-    "typecheck": "tsc -p ./ --noEmit",
+    "typecheck": "tsc -p ./ --noEmit && npm run typecheck:test",
+    "typecheck:test": "tsc -p tsconfig.jest.json --noEmit",
```

Output Summary: the only removed line is the old `typecheck` script; the two added lines are exactly the P8-T4 lines. `compile`, `build`, `test`, `test:unit`, and `test:coverage` are byte-identical to BASE_SHA. The test `compile and build do not reference tsconfig.jest.json` passed in P8-T6.
