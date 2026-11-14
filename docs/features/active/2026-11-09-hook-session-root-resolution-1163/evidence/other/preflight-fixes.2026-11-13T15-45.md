# Preflight Fixes — Issue 1163, Remediation Cycle 2

Timestamp: 2026-11-13T15-45
Plan: docs/features/active/2026-11-09-hook-session-root-resolution-1163/remediation-plan.2026-11-13T15-36.md

## Fixes

1. P2-T8 | literal-formatting (scope wording) | The clause "no file under `src/`, ... `tests/` changes, and no `.py` file is added or modified" now reads "in the cycle's own diff, no file under ...". The sentence's subject is already the cycle's changes; the merge-base diff necessarily lists the feature's own `.claude/` and `tests/` changes from earlier phases, so the clarification keeps the assertion's meaning and prevents a reading that is unsatisfiable.

## Checks Performed (no defect)

- Plan validator: Python CLI `plan` subcommand exit 0; installed MCP validator ok.
- Workflow `_npm-audit-gate.yml`: `npm ci` then `npm audit --audit-level="$AUDIT_LEVEL"` with default `moderate`, Node 26.13.0; local Node v26.13.0, npm 11.20.0.
- `overrides` objects exist in all three `package.json` files with `hono` and `@hono/node-server` caret entries; no `deepmerge` entry.
- Script names cited by P0-T2 exist (`format:check`, `lint`, `typecheck` at root; `format`, `lint`, `typecheck`, `build` in the extension; `build` in `packages/mcp-server`, which has no test script).
- All nine P2-T5 test files and the four named test functions and the Pester `Describe` block exist.
- Tests that mention `package-lock` use in-memory strings or path tokens only; none reads lockfile content.
- Root Prettier corpus-fixture failure recorded in executor memory does not reproduce for the three `tests/scripts/claude-lib/docs/fixtures/*-corpus.json` files in this worktree (Prettier check exit 0).
- Design check against finding C1: audit exit 0 per manifest (P1-T1..P1-T3, verified by P2-T1); narrow change set (P2-T8); TypeScript toolchain with no coverage drop (P2-T2..P2-T4); push-down contracts and Codex generator check (P2-T5, P2-T6); self-review without FAIL (P2-T9). No gap.
