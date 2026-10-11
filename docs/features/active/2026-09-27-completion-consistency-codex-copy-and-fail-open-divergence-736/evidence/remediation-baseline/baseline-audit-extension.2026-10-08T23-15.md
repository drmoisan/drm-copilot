# baseline-audit-extension

Timestamp: 2026-10-08T18-57
Command: npm audit --audit-level=moderate --prefix extensions/drm-copilot
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: (last 25 lines of combined stdout/stderr; total lines 14)

```text
# npm audit report

handlebars  4.0.0 - 4.7.9
Severity: critical
Handlebars: JavaScript Injection via Unsafe Inline Embedding of Precompiled Templates - https://github.com/advisories/GHSA-xw65-4hp5-5hc7
Handlebars: JavaScript Injection via AST Type Confusion in compile (bypass of CVE-2026-33937) - https://github.com/advisories/GHSA-8r5x-fm3f-whwj
Handlebars: JavaScript Injection via Own Property Check Bypass - https://github.com/advisories/GHSA-p8wg-vrv2-v86f
fix available via `npm audit fix`
node_modules/handlebars

1 critical severity vulnerability

To address all issues, run:
  npm audit fix
```
