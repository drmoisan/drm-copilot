Timestamp: 2026-09-28T20-02
Command: npm audit --audit-level=moderate --prefix .
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: (last 25 lines of output below)
```text
# npm audit report

ip-address  <=10.5.0
Severity: moderate
ip-address: Address6.isLinkLocal() recognizes fe80::/64 rather than fe80::/10, allowing SSRF and trust-boundary bypass to on-link hosts - https://github.com/advisories/GHSA-rpw4-54j3-4h4q
ip-address: no classifier recognizes the NAT64 local-use range 64:ff9b:1::/48, allowing SSRF and trust-boundary bypass - https://github.com/advisories/GHSA-2vr4-cq9g-pvrc
fix available via `npm audit fix`
node_modules/ip-address

1 moderate severity vulnerability

To address all issues, run:
  npm audit fix
```
Note: advisory package ip-address (<=10.5.0, moderate) reported; EXIT_CODE 1 as expected.
