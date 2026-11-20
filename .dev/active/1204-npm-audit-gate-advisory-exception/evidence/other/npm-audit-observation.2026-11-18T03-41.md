# Real npm audit observation (P0-T3)

Timestamp: 2026-11-18T03-41
Command: `npm audit --omit=dev --json` and `npm audit --json` in each of `.`, `extensions/drm-copilot`, `packages/mcp-server`, run by a `sh` helper under SCRATCH (each call in its own subshell directory; raw JSON and stderr kept in SCRATCH). Tool versions: npm 11.20.0, Node v26.13.0.
EXIT_CODE: 0 (helper); per-call exit codes are recorded below.
Output Summary: six result blocks; `OMIT_DEV_HONORED: yes`.

## Result blocks

1. manifest `.`, `npm audit --omit=dev --json`: exit 0; `vulnerabilities` empty (total 0); prod 96 / dev 453 dependencies counted; stderr empty; GHSA-fc5q-39xc-vjpf absent.
2. manifest `.`, `npm audit --json`: exit 1; total 42 (high 42); one advisory object, id GHSA-fc5q-39xc-vjpf (source 1247710, package picomatch, severity high, range `<=4.0.7`); GHSA-fc5q-39xc-vjpf present; stderr empty.
3. manifest `extensions/drm-copilot`, `npm audit --omit=dev --json`: exit 0; `vulnerabilities` empty (total 0); stderr empty; GHSA-fc5q-39xc-vjpf absent.
4. manifest `extensions/drm-copilot`, `npm audit --json`: exit 1; total 42 (high 42); one advisory object, GHSA-fc5q-39xc-vjpf (package picomatch, severity high); present; stderr empty.
5. manifest `packages/mcp-server`, `npm audit --omit=dev --json`: exit 0; total 0; stderr empty; advisory absent.
6. manifest `packages/mcp-server`, `npm audit --json`: exit 0; total 0; stderr empty; advisory absent.

## Shape facts used by the module fixtures

- Top level: `auditReportVersion` 2, `vulnerabilities` (object keyed by package name), `metadata`.
- Each `vulnerabilities` entry has `name`, `severity`, `via`, `effects`, `range`, `nodes`, `fixAvailable`.
- `via` elements are either strings (a transitive package name, 41 of the 42 entries) or objects. The one object element has `source` (number), `name`, `dependency`, `title`, `url` (`https://github.com/advisories/GHSA-fc5q-39xc-vjpf`), `severity`, `cwe`, `cvss`, `range`. The GHSA id is therefore extractable from `url`, with numeric `source` as the fallback.
- npm printed no warnings to stderr in any of the six calls.

OMIT_DEV_HONORED: yes
