# Remediation Inputs — Issue #765, Cycle 1

- Timestamp: 2026-09-29T00-30
- Source: CI failure on PR #766 (head 59aa6255c5c89426aee2e63e045e814fb8ab8d51)
- Base branch: main

## Findings

### F1 — npm audit gate fails in all three npm packages

- Severity: Blocking
- Failing checks:
  - `NPM Audit Gate / npm audit (.)` — https://github.com/drmoisan/drm-copilot/actions/runs/36499707342/job/109187385331
  - `NPM Audit Gate / npm audit (extensions/drm-copilot)` — same run 36499707342
  - `NPM Audit Gate / npm audit (packages/mcp-server)` — same run 36499707342
- Failed-check log excerpt:

```text
ip-address  <=10.5.0
Severity: moderate
ip-address: Address6.isLinkLocal() recognizes fe80::/64 rather than fe80::/10, allowing SSRF and trust-boundary bypass to on-link hosts - https://github.com/advisories/GHSA-rpw4-54j3-4h4q
ip-address: no classifier recognizes the NAT64 local-use range 64:ff9b:1::/48, allowing SSRF and trust-boundary bypass - https://github.com/advisories/GHSA-2vr4-cq9g-pvrc
fix available via `npm audit fix`
node_modules/ip-address
1 moderate severity vulnerability
##[error]Process completed with exit code 1.
```

- Cause: two advisories against `ip-address <=10.5.0` were published after PR #761's audit run passed. `ip-address@10.4.0` is resolved transitively via `@modelcontextprotocol/sdk` -> `express-rate-limit@8.5.2` -> `ip-address`. The same package is already governed by an `overrides` entry `"ip-address": "^10.2.0"` in `package.json`, `extensions/drm-copilot/package.json`, and `packages/mcp-server/package.json`, which admits the vulnerable 10.4.0 already locked.
- Latest published versions: 10.7.0, 10.7.1, 10.7.2.
- Required change: raise the `ip-address` override floor in all three `package.json` files to a patched version (for example `^10.7.2`) and regenerate the three corresponding `package-lock.json` files so that `npm audit --audit-level=moderate` (the gate's level; confirm from the workflow) exits 0 in each of `.`, `extensions/drm-copilot`, and `packages/mcp-server`. Do not use `npm audit fix --force`.
- Unrelated to the #765 test change; it is a newly published advisory that blocks every PR into main, including release PR #761.
