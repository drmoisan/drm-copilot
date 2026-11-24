# Preflight Fixes - Issue #1234 (round 2)

Timestamp: 2026-11-24T04-41
Plan: .dev/active/1234-merge-gate-release-exemption/plan.2026-11-23T22-54.md
Command: env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan .dev/active/1234-merge-gate-release-exemption/plan.2026-11-23T22-54.md
EXIT_CODE: 0
Output Summary: Single-pass preflight, round 2. The four round-1 substantive defects are resolved in the plan text ([P1-T3] AC-06 `-ceq` detail rows, [P1-T3] AC-12 `changedFiles` 100 boundary row, [P1-T4] 64-character allow row, [P2-T4] Codex epic-child row). Three trivial defects were fixed in place in task text; no task was added, removed, or reordered. The branch-current Python validator and the installed MCP validator pass after the fixes.

## Fixes

1. `[P1-T5]` (inherited by `[P2-T5]` and `[P3-T4]`) | count with no source (PoshQC MCP results carry no output) | The phase-gate acceptance did not say where the format changed-file count and the analyzer finding count come from. It now reads them as P0-T1 and P4-T1 do: the `Formatted: ` lines of a direct `Invoke-PoshQCFormat` run through the `sh` launcher route, cross-checked by the `git status --porcelain` delta, and the direct analyzer run. The asserted outcome (one clean pass, zero failures) is unchanged.
2. `[P4-T4]` | final-gate coverage comparison without a coverage-mode command | P0-T3 records a repo-wide pytest coverage headline, but the final pytest gate ran without a coverage reporter, so no figure could be compared with it. P4-T4 now passes the same `--cov-report=term-missing --cov` arguments as P0-T3 and records the headline with no drop against the baseline. No test assertion changes.
3. `[P4-T5]` | incomplete citation list for AC-25 | The unchanged-file list omitted the review guard files that AC-25 and the spec Non-Goals name as unchanged. `enforce-epic-merge-gate-review.ps1` and `enforce-epic-merge-gate-regeneration.ps1` were added to the list. No test assertion changes.
