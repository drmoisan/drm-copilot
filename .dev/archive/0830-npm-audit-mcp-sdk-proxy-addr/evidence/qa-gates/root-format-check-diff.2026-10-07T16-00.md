Timestamp: 2026-10-07T16-00
Command: git diff --no-index <P0-T10 root-format-check artifact> <P2-T2 root-format-check artifact>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Differences limited to Timestamp lines (and Command-path-independent header lines); body warn/error lines identical to baseline.

```
diff --git a/C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr/docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/baseline/root-format-check.2026-10-07T15-00.md b/C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr/docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/qa-gates/root-format-check.2026-10-07T16-00.md
index 6ded7e49..9182532d 100644
--- a/C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr/docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/baseline/root-format-check.2026-10-07T15-00.md
+++ b/C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr/docs/features/active/2026-10-07-npm-audit-mcp-sdk-proxy-addr-830/evidence/qa-gates/root-format-check.2026-10-07T16-00.md
@@ -1,4 +1,4 @@
-Timestamp: 2026-10-07T10-14
+Timestamp: 2026-10-07T10-17
 Command: (cd C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr) npx --yes npm@11 run format:check
 EXIT_CODE: 2
 ExpectedExitCode: 2
```
