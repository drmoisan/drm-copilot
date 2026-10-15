# PowerShell Formatter Baseline (P0-T17)

Timestamp: 2026-09-30T13-56
Task: [P0-T17]
Location: worktree root

## Porcelain before (2026-09-30T13:56:50Z)

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (verbatim):

```
 M docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/
```

## Formatter

Command: mcp__drm-copilot__run_poshqc_format with `workspace_root` = worktree root (no `scan_folders`)
EXIT_CODE: 0
MCP-Status: success (result field `"ok": true`; summary `Ran bundled PoshQC format against '<worktree root>'.`)
Output Summary: the MCP result carries no output or counts; the porcelain listings below are the observation of what the formatter changed.

## Porcelain after (2026-09-30T13:57:09Z)

Command: git status --porcelain
EXIT_CODE: 0
Output Summary (verbatim):

```
 M docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md
?? docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/
```

Result: the two listings are identical (both entries are this execution's own Phase 0 evidence writes). Rewritten files: none. Revert: none required.

P0-T17 completion time (UTC, `date -u +%Y-%m-%dT%H:%M:%SZ`): 2026-09-30T13:57:15Z

This is the H0 freshness reference: the H0 `SourceA-Start:` value must be later than 2026-09-30T13:57:15Z.

## Observation for the orchestrator (no action taken by the executor)

Before this task completed, the folder `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/` already contained `pester-junit.xml` and `powershell-coverage.xml` (modified 2026-09-30T13:53:46 UTC) and `run-record.md` (modified 2026-09-30T13:54:26 UTC). The executor did not create or modify these files. Their modification times precede the completion time above, so a Source A run recorded in them cannot satisfy the freshness rule (`SourceA-Start:` later than the P0-T17 completion time), and P0-T19 would fail on them. H0 needs to be run after 2026-09-30T13:57:15Z, and the copies replaced.
