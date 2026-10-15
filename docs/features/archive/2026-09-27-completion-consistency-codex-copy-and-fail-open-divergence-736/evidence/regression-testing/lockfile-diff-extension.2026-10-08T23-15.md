# lockfile-diff-extension

Timestamp: 2026-10-08T19-13
Command: git diff -U1 05267c2fa2ce2391552ed4e0a38d9bc3154960e0 -- extensions/drm-copilot/package-lock.json ; git status --porcelain -- extensions/drm-copilot/package.json extensions/drm-copilot/package-lock.json
EXIT_CODE: 0
Output Summary: one package version line changed: handlebars 4.7.9 -> 4.7.10 (key line "node_modules/handlebars"). The handlebars dependency range line minimist ^1.2.5 -> ^1.2.8 also changed; it is a range, not a package version line. Porcelain lists extensions/drm-copilot/package-lock.json as modified and does not list extensions/drm-copilot/package.json.

Packages whose version line changed:
- handlebars: 4.7.9 -> 4.7.10

git diff output:

```text
diff --git a/extensions/drm-copilot/package-lock.json b/extensions/drm-copilot/package-lock.json
index 204aadf2..9fd908a0 100644
--- a/extensions/drm-copilot/package-lock.json
+++ b/extensions/drm-copilot/package-lock.json
@@ -4512,5 +4512,5 @@
     "node_modules/handlebars": {
-      "version": "4.7.9",
-      "resolved": "https://registry.npmjs.org/handlebars/-/handlebars-4.7.9.tgz",
-      "integrity": "sha512-4E71E0rpOaQuJR2A3xDZ+GM1HyWYv1clR58tC8emQNeQe3RH7MAzSbat+V0wG78LQBo6m6bzSG/L4pBuCsgnUQ==",
+      "version": "4.7.10",
+      "resolved": "https://registry.npmjs.org/handlebars/-/handlebars-4.7.10.tgz",
+      "integrity": "sha512-P5VJMVM7qgBn6vjXMw8WG9uVI+ncf2pi72j4de4yz5ZULLj2RGqLYaKOYGsgyrViQ0tePOVlN1tDCCXXtFqXKg==",
       "dev": true,
@@ -4518,3 +4518,3 @@
       "dependencies": {
-        "minimist": "^1.2.5",
+        "minimist": "^1.2.8",
         "neo-async": "^2.6.2",
```

git status --porcelain output:

```text
 M extensions/drm-copilot/package-lock.json
```
