Timestamp: 2026-10-07T10-13
Command: (cd C:/Users/DanMoisan/repos/drm-copilot-wt/2026-10-07-npm-audit-sdk-proxy-addr) npx --yes npm@11 audit --audit-level=moderate
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 2 vulnerabilities (1 high, 1 critical)

## Output
```
# npm audit report

@modelcontextprotocol/sdk  1.12.0 - 1.30.1
Severity: high
MCP TypeScript SDK: OAuth client could send credentials to an authorization server chosen by the MCP server - https://github.com/advisories/GHSA-6qxp-vccf-f47h
fix available via `npm audit fix`
node_modules/@modelcontextprotocol/sdk

proxy-addr  1.1.0 - 2.0.7
Severity: critical
proxy-addr vulnerable to IP spoofing via IPv4-mapped IPv6 trust subnet - https://github.com/advisories/GHSA-jqcg-44mw-7w3h
fix available via `npm audit fix`
node_modules/proxy-addr

2 vulnerabilities (1 high, 1 critical)

To address all issues, run:
  npm audit fix
```
