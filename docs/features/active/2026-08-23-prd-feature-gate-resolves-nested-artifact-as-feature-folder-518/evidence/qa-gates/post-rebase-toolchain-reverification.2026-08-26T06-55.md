# Post-Rebase Toolchain Re-Verification

Timestamp: 2026-08-26T06-55

Author: orchestrator (not a plan task; supplementary evidence)

## Why this artifact exists

The Phase 4 final-QC attestation
(`evidence/qa-gates/qc-consecutive-pass.2026-08-26T06-32.md`) was recorded against a tree based on
`1816b062`. After Phase 4 completed, `origin/main` advanced to `b5a7490b` when sibling parallel item
#526 (`bug/tag-push-can-silently-skip-npm-publish-526`, PR #564) merged. This branch was rebased onto
that new tip.

That merge is not inert with respect to this item's toolchain. #526 modified BOTH copies of
`pester.runsettings.psd1` — `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
`extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — which are the
files that configure Pester discovery and the `CodeCoverage.Path` allow-list this item's coverage
numbers are read from. A Phase 4 attestation taken before that change does not by itself establish
that the toolchain is still clean against the base the pull request will actually merge into.

This artifact records the re-run. It supplements the Phase 4 attestation; it does not replace it and
does not alter any Phase 4 checkbox.

## Rebase

```text
git rebase origin/main
```

EXIT_CODE: 0

Six commits replayed with no conflict. Pre-rebase head `d2765aa0`; post-rebase head `c90d2587`.
Merge base is now `b5a7490b`, the current `origin/main` tip.

## Stage 1 — Format

Command: `mcp__drm-copilot__run_poshqc_format` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`

EXIT_CODE: 0

Output Summary: `ok: true`. No file was reformatted; the working tree remained clean after the run,
so no restart of the loop was triggered.

## Stage 2 — Analyze

Command: `mcp__drm-copilot__run_poshqc_analyze` with the same `workspace_root`

EXIT_CODE: 0

Output Summary: `ok: true`. Zero PSScriptAnalyzer findings.

## Stage 3 — Test with coverage

Command: `mcp__drm-copilot__run_poshqc_test` with the same `workspace_root`

EXIT_CODE: 0

Output Summary: Read from `artifacts/pester/pester-junit.xml`: **3680 tests, 0 failures, 0 errors**.
The total rose from the 3617 recorded in Phase 4 because the #526 merge added test files to `main`;
the failure count is 0 both before and after. Overall line coverage read from
`artifacts/pester/powershell-coverage.xml` is **96.17 percent** (6696 covered, 267 missed, 6963
analyzable), against 96.15 percent at Phase 4 and a 96.14 percent Phase 0 baseline. The figure is
above the 85 percent threshold in `.claude/rules/quality-tiers.md`. No branch-coverage threshold
applies to PowerShell.

## Stage 4 — Bundle parity

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`

EXIT_CODE: 0

Output Summary: **10 passed, 0 failed** in 0.10 seconds, test file unmodified.
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes, confirming the self-hosted
hook and its bundled mirror remain textually identical after the rebase.

## Incidental finding recorded for the reviewer

`.claude/state/` was verified empty immediately before Stage 1 and again immediately after Stage 4.
The three MCP PoshQC runs above did **not** regenerate the gitignored batch-budget counters that
caused the [P0-T6] baseline failure. This narrows the cause: those counters are written by the
`Write`/`Edit` PreToolUse batch-budget hooks, not by a PoshQC invocation. The consequence is that the
Stage 4 result above is reproducible for any run that does not interleave an agent file edit, and the
underlying test defect — `list_scoped_files` enumerating the filesystem without excluding the
gitignored `.claude/state/**` subtree, the way it already excludes `.claude/agent-memory/**` — is
unchanged by this item and is carried to a follow-up issue.

## Verdict

All four stages pass against the post-rebase tree in a single consecutive pass, with no repository
file edited between them. The Phase 4 attestation's conclusions hold against the base the pull
request will merge into.
