# PowerShell Analyzer Baseline (P0-T18)

Timestamp: 2026-09-30T14-07
Task: [P0-T18]
Location: worktree root
Target module: `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1`
Source used at H0: B (per `evidence/baseline/poshqc-local/run-record.md`)

## Copied analyzer run (H0, Source B)

Timestamp: 2026-09-30T14-10 (quoted from `run-record.md`)
Command: gh workflow run _poshqc.yml --ref bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 (quoted from `run-record.md`; step conclusions read with `gh run view 36725543249 --json jobs`)
EXIT_CODE: 0 (quoted from `run-record.md`, dispatch and `gh run view` commands)
SourceB-Dispatched: 2026-09-30T13:58:06Z (after P0-T17 completion 2026-09-30T13:57:15Z; supersedes an earlier dispatch at 13:44:19Z, run 36723840493, whose copies were replaced)
Output Summary:
- Source B was used; the orchestrator recorded the verbatim Source A refusal text in `run-record.md`.
- Per plan limit (d), the Source B summary quotes the `AnalyzeStep:` line instead of the per-file `path count` lines:
  `AnalyzeStep: success`
- An `AnalyzeStep: success` line stands for zero analyzer findings (the `_poshqc.yml` analyze step throws on any finding).
- `analyzer-output.txt` is not written for Source B; its absence does not fail this task under the Source B branch.
- Run 36725543249, headSha 127635e94f51e855c7b82f21c87d575bf5acfdad; `git rev-parse HEAD` at 2026-09-30T14:07:52Z = 127635e94f51e855c7b82f21c87d575bf5acfdad (equal).

## MCP analyzer invocation

Timestamp: 2026-09-30T14:07:52Z
Command: mcp__drm-copilot__run_poshqc_analyze with `workspace_root` = worktree root (no `scan_folders`)
EXIT_CODE: 0
MCP-Status: success (result field `"ok": true`; summary `Ran bundled PoshQC analyze against '<worktree root>'.`)
Output Summary: the MCP run reported status success; diagnostic counts are not carried by the MCP result.
