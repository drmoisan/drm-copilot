Timestamp: 2026-10-07T15-30
Command: git diff origin/main -U0 -- package.json extensions/drm-copilot/package.json packages/mcp-server/package.json
EXIT_CODE: 0
Output Summary: Manifest diff shows only sdk range bumps to ^1.31.0 and proxy-addr ^2.0.8 override additions; no line mentions @types/vscode, @types/node, or typescript-eslint.

```
diff --git a/extensions/drm-copilot/package.json b/extensions/drm-copilot/package.json
index fd074737..520fae1d 100644
--- a/extensions/drm-copilot/package.json
+++ b/extensions/drm-copilot/package.json
@@ -216,0 +217 @@
+    "proxy-addr": "^2.0.8",
@@ -244 +245 @@
-    "@modelcontextprotocol/sdk": "^1.30.1"
+    "@modelcontextprotocol/sdk": "^1.31.0"
diff --git a/package.json b/package.json
index e11fd2af..4a75d7dc 100644
--- a/package.json
+++ b/package.json
@@ -13,0 +14 @@
+    "proxy-addr": "^2.0.8",
@@ -54 +55 @@
-    "@modelcontextprotocol/sdk": "^1.30.1"
+    "@modelcontextprotocol/sdk": "^1.31.0"
diff --git a/packages/mcp-server/package.json b/packages/mcp-server/package.json
index d048e73d..9c24566f 100644
--- a/packages/mcp-server/package.json
+++ b/packages/mcp-server/package.json
@@ -41,0 +42 @@
+    "proxy-addr": "^2.0.8",
@@ -52 +53 @@
-    "@modelcontextprotocol/sdk": "^1.29.0"
+    "@modelcontextprotocol/sdk": "^1.31.0"
```
