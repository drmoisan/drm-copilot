# Baseline — TypeScript Toolchain Install — [P0-T9]

Timestamp: 2026-08-23T00-47

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T9]
State captured: PRE-CHANGE baseline

Command: `npm ci` with `extensions/drm-copilot` as the working directory.

EXIT_CODE: 0

## Why this step is required

The dependency tree was absent from this worktree before the command ran: `extensions/drm-copilot/node_modules`
did not exist. The three TypeScript tasks in this plan ([P0-T10], [P4-T6], [P8-T10]) cannot execute
without it. `extensions/drm-copilot/package-lock.json` is present, so `npm ci` reproduces the
locked tree exactly rather than resolving fresh versions.

## Installed package count

```text
added 457 packages, and audited 458 packages in 6s

103 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

| Metric | Value |
| --- | --- |
| packages added | 457 |
| packages audited | 458 |
| vulnerabilities found | 0 |

One deprecation warning was printed, for `glob@10.5.0`. It is a transitive dependency pinned by
the lock file; this item does not change any dependency and therefore does not address it.

## Restart note

Per the Phase 8 restart clause, this install is a one-time setup step and is not repeated when the
Phase 8 loop restarts. It is re-run only if `extensions/drm-copilot/node_modules` is removed.

## Output Summary

`npm ci` exited 0 and installed 457 packages (458 audited) from the lock file, with 0
vulnerabilities. The TypeScript toolchain is available for the three TypeScript tasks in this
plan.
