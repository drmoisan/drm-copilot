# Preflight Fixes - Issue #1234

Timestamp: 2026-11-24T04-29
Plan: .dev/active/1234-merge-gate-release-exemption/plan.2026-11-23T22-54.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan .dev/active/1234-merge-gate-release-exemption/plan.2026-11-23T22-54.md
EXIT_CODE: 0
Output Summary: Single-pass preflight. Eight trivial defects fixed in place in task text and preamble; no task added, removed, or reordered. The branch-current Python validator and the installed MCP validator pass after the fixes with no warning.

## Fixes

1. `## Conventions` (batch budget) | executor-protocol conflict | The clause instructing the executor to stop `BLOCKED at [P1-T1]` during execution was replaced with the preflight observation that the item checkpoint records `route_id` `large` with a non-terminal `next_step`. Blocking is permitted only at preflight, and the condition was verified at preflight.
2. `[P0-T1]` | count with no source (PoshQC MCP results carry no output) | The formatter changed-file count is now read from the `Formatted: ` lines of a direct `Invoke-PoshQCFormat` run through the `sh` launcher route (success literal `Already formatted: `), cross-checked by the `git status --porcelain` delta.
3. `[P0-T3]` | coverage command that prints no coverage | The project `addopts` value carries no `--cov` and only an LCOV reporter, so the launcher run now adds `--cov-report=term-missing --cov` in that order (G9 reporter; the bare `--cov` last so validator rule G4 has nothing to bind). The asserted coverage headline is unchanged.
4. `[P1-T2]` | ambiguous naming literal | "helpers prefixed `EpicMergeGateRelease`" now reads "helpers whose noun begins with `EpicMergeGateRelease`", because every function name begins with its verb.
5. `[P3-T3]` | ambiguous naming literal | The same wording correction as fix 4 for the function-name row.
6. `[P2-T1]` and `[P2-T3]` | unstated fixture value | The `--match-head-commit` value is stated to equal the mocked docs-only `headRefOid`; otherwise the docs-only branch denies at its head check before any `git` call and the asserted three `Invoke-DocsOnlyGitExe` calls cannot occur.
7. `[P2-T2]` (AC-25 row) | blanket mock of the function under test | The row mocked `Get-EpicMergeGateReviewDecision` to return a pass, which makes the "guard starts no process" assertion vacuous. The row now runs the three review-guard functions unmocked; the asserted zero-call counts are unchanged.
8. `[P4-T1]` and `[P4-T5]` | count source and stale registration path | P4-T1 reads the formatter count as in fix 2. P4-T5 now checks both the diff from `MB` and `git status --porcelain` (the executor does not commit, so `MB...HEAD` alone omits uncommitted work), and the excluded list adds `.claude/hooks/pretooluse-dispatch.json` and `.codex/hooks/pretooluse-dispatch.json`, which hold PreToolUse registrations since #1159.
