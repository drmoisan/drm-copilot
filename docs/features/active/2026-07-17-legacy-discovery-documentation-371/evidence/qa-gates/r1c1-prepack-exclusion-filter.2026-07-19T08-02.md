# Phase 2 — prepack.cjs Exclusion Filter Re-Verification (Remediation Cycle 1)

Timestamp: 2026-07-19T08-02
Command: grep -n -E "\.py|scripts" packages/mcp-server/prepack.cjs
EXIT_CODE: 0

Output Summary:

`shouldCopy()` (packages/mcp-server/prepack.cjs, lines 33-49) copies from a single fixed
source directory, `extensions/drm-copilot/resources/` (lines 13-20), into the package's
`resources/` output directory, applying exactly two exclusion rules and no allow-list:

```
38:  if (normalized.endsWith(".py")) {
44:  if (/(^|\/)scripts(\/|$)/.test(normalized)) {
```

- Rule 1 (line 38): excludes any path ending in `.py`.
- Rule 2 (line 44): excludes any path containing a `scripts/` path segment (regex
  `/(^|\/)scripts(\/|$)/`).
- All other paths under the fixed source directory are copied (`return true`, line 48).

There is no allow-list entry, special case, or additional source directory in this file
that copies `schemas/discovery/v1/` or `docs/discovery/templates/`. Because `cpSync`'s
`SOURCE_DIR` is hard-coded to `extensions/drm-copilot/resources/` (repository-relative
`../../extensions/drm-copilot/resources` from `packages/mcp-server/`), this script cannot
copy either asset tree unless that tree is first mirrored into
`extensions/drm-copilot/resources/` by a separate process — confirmed absent by `P2-T3`.
The `.py`-suffix exclusion and the `scripts/`-segment exclusion are the only filters in the
file.