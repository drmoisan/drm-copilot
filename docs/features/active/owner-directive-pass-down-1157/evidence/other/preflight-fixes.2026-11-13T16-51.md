# Preflight Fixes - Issue 1157, Cycle 2 Remediation Plan (confirming preflight)

Timestamp: 2026-11-13T16-51
Plan: docs/features/active/owner-directive-pass-down-1157/remediation-plan.2026-11-13T16-30.md
Inputs: docs/features/active/owner-directive-pass-down-1157/remediation-inputs.2026-11-13T16-30.md
Validator: Python CLI `plan` subcommand exit 0 and installed MCP validator ok, before and after the fix.

## Fixes (task text only; no task added, removed, or reordered)

1. P2-T6 acceptance | internal contradiction in a contingent branch | P1-T1 to P1-T3 and `## Premise and Scope Notes` keep a `package.json` that `npm audit fix` rewrites, and npm records that file's dependency ranges in the lockfile `packages` root entry, so "an unchanged `packages` root entry" could not hold in that permitted case. The condition now admits, for that manifest only, a root entry whose only changes are the ones the recorded rewrite made. The default case (no rewrite, root entry unchanged) is unchanged.

## Prior defects verified resolved

- P1-T6 and P2-T1 root `format:check`: both now pass on exit 0 or on exit 1 with the reported files equal to the P0-T3 set (`## Baseline-Dependent Acceptance`); P0-T3 records that set and stops on any other file.

## Observations recorded (no plan change)

- Root Prettier 3.9.10 run from the worktree root reports exactly `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, and `python-surface-corpus.json`.
- Root `tsc -p ./ --noEmit` exits 0 and root ESLint exits 0 with no output from the worktree root.
- The extension Prettier check over the `format` globs prints `All matched files use Prettier code style!`.
- The root Jest config has no `coverageThreshold` and uses the default reporters (the `text` table carries the `All files` row); the extension `test:coverage` script passes `text-summary`.
- `hono` and `@hono/node-server` are transitive in all three manifests (direct dependency is `@modelcontextprotocol/sdk` only), so a `package.json` rewrite by `npm audit fix` is not expected.
- `origin/main` equals the merge base; the three lockfiles show no difference between them.
- No test under `tests/` or `extensions/drm-copilot/test/` reads the content of a tracked lockfile.
