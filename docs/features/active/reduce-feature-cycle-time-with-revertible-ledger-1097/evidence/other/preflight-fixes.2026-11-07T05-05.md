# Preflight Fixes: Stage C Plan

Timestamp: 2026-11-07T05-05
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-06T23-29.md

Each fix below is in task text or plan prose. No task was added, removed, or reordered.

1. [P0-T3] and [P3-T3], validator-blind environment fact: named `PYTHONPATH` set to the worktree's `packages/discovery-runtime/src` in both Python gate tasks, as the caller directed, because the editable discovery package otherwise points at the main checkout.
2. [P1-T3], stale anchor: `Invoke-CodexEpicMergeDecision` assigns `$prNumber` after the child branch, so the Placement point had no PR number to pass. The task now states that the pure assignment moves above that point.
3. [P1-T4] and `## Test Plan`, wrong citation: `hook-dependency-failure.Codex.Tests.ps1` has no row table, because its B1 rows derive from the AST at discovery. The task now records that suite and `hook-dependency-failure.Claude.Tests.ps1` as unchanged, and `## Test Plan` no longer lists the Codex suite as gaining rows.
4. [P1-T1], missing disposition: named `enforcement-hooks-no-python-invocation.Tests.ps1`, which scans every hook file and reports `&` applied to a variable.
5. `## Design` Key paragraph, clarification of the stated exact-string rule: a PowerShell reader tests `-is [string]` first, because `-ceq` on an array filters rather than compares. The Python comparison already behaves this way.
6. [P1-T2] and the `CI-only behavior` Pre-Mortem bullet, literal formatting: the `feature-folder-backslash` value is composed with `[char]92`, so the Linux hook suites hold no backslash literal. The tested value is unchanged.
7. [P2-T6], literal formatting: the acceptance reads `git log --reverse --format=%s`, because plain `git log` lists newest first and the assertion names oldest-first order.
