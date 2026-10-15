Timestamp: 2026-09-28T20-05
Command: git diff -U0 main -- package-lock.json extensions/drm-copilot/package-lock.json packages/mcp-server/package-lock.json | grep -E "^(diff|@@|[-+])"; git status --porcelain -- package-lock.json extensions/drm-copilot/package-lock.json packages/mcp-server/package-lock.json
EXIT_CODE: 0
Output Summary: (last 25 lines of output below)
```text
-      ],
@@ -2451,3 +2423,0 @@
-      "libc": [
-        "musl"
-      ],
@@ -4734,3 +4704,3 @@
-      "version": "10.4.0",
-      "resolved": "https://registry.npmjs.org/ip-address/-/ip-address-10.4.0.tgz",
-      "integrity": "sha512-oSK96Grm3aP6OrS263xVxbNDGVL7rzBtYdpGqlDG8iQdoenDoTs/nkki+DflYbAEE8Xl6o5YxhxlrKvI3nqKXQ==",
+      "version": "10.7.2",
+      "resolved": "https://registry.npmjs.org/ip-address/-/ip-address-10.7.2.tgz",
+      "integrity": "sha512-7H/2gFSIitxc0hG3nOI1glS8QLo/EHBFFLk8vEUjXY/xu0AdL8jZ9U1IzO2PUm0d2D/ofQcAifb0g6OBkt8U7w==",
diff --git a/packages/mcp-server/package-lock.json b/packages/mcp-server/package-lock.json
--- a/packages/mcp-server/package-lock.json
+++ b/packages/mcp-server/package-lock.json
@@ -1129,3 +1129,3 @@
-      "version": "10.4.0",
-      "resolved": "https://registry.npmjs.org/ip-address/-/ip-address-10.4.0.tgz",
-      "integrity": "sha512-oSK96Grm3aP6OrS263xVxbNDGVL7rzBtYdpGqlDG8iQdoenDoTs/nkki+DflYbAEE8Xl6o5YxhxlrKvI3nqKXQ==",
+      "version": "10.7.2",
+      "resolved": "https://registry.npmjs.org/ip-address/-/ip-address-10.7.2.tgz",
+      "integrity": "sha512-7H/2gFSIitxc0hG3nOI1glS8QLo/EHBFFLk8vEUjXY/xu0AdL8jZ9U1IzO2PUm0d2D/ofQcAifb0g6OBkt8U7w==",
 M extensions/drm-copilot/package-lock.json
 M package-lock.json
 M packages/mcp-server/package-lock.json
```

Note: the artifact block above shows only the last 25 lines; the complete classification follows.
Porcelain output: ` M package-lock.json`, ` M extensions/drm-copilot/package-lock.json`, ` M packages/mcp-server/package-lock.json` (all three modified).

Classification of every changed line:
- node_modules/ip-address entry (all three lockfiles): version 10.4.0 -> 10.7.2, resolved URL ip-address-10.7.2.tgz, integrity sha512-7H/2gFSIitxc0hG3nOI1glS8QLo/EHBFFLk8vEUjXY/xu0AdL8jZ9U1IzO2PUm0d2D/ofQcAifb0g6OBkt8U7w==. Intended change.
- sdk change: none. @modelcontextprotocol/sdk version lines unchanged (see P2-T5).
- Other transitive change (package-lock.json and extensions/drm-copilot/package-lock.json only; not in packages/mcp-server): removal of the `"libc": [ "glibc" | "musl" ]` metadata arrays (3 lines each, 10 hunks per lockfile, 30 lines removed per lockfile) from ten optional native-binding entries, with no version change: @unrs/resolver-binding-linux-arm64-gnu, -arm64-musl, -loong64-gnu, -loong64-musl, -ppc64-gnu, -riscv64-gnu, -riscv64-musl, -s390x-gnu, -x64-gnu, -x64-musl (version unchanged in every case). Cause: npm 11.9.0 run on win32 does not re-emit the `libc` field for these platform-filtered optional packages. No package name/version pair changed other than ip-address 10.4.0 -> 10.7.2.
