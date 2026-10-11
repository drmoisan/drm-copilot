# PowerShell Measurement Run Record, Handoff H1 (Issue #849)

Timestamp: 2026-10-10T14-58
Source: B (CI dispatch of `_poshqc.yml`), the same source used at H0
SourceB-Reason: the orchestrator session has no PowerShell host tool (only the Bash tool), and the operator constraints for this run prohibit sh/bash/pwsh wrapper invocations inside the worktree, so the Source A commands cannot be run. No Source A command was attempted; there is no refusal text to record.
H1-Trigger-Completed: 2026-10-10T14:45:45Z (from `ps-test-mcp.2026-10-09T01-33.md`)
SourceB-LocalHead: 12580b1dc4325eb73a8ca5d5eff6843a7acdfea5
SourceB-Dispatched: 2026-10-10T14:46:32Z
SourceB-RunId: 38060952234
SourceB-HeadSha: 12580b1dc4325eb73a8ca5d5eff6843a7acdfea5
FormatStep: success
AnalyzeStep: success
sanitized: root, absolute-paths, properties, hostname

Freshness: `SourceB-Dispatched:` (2026-10-10T14:46:32Z) is later than `H1-Trigger-Completed:` (2026-10-10T14:45:45Z). `SourceB-HeadSha:` equals `SourceB-LocalHead:`.

Pre-dispatch commits: Phase 6, Phase 7, and P8-T1..P8-T3 evidence committed with explicit pathspecs and pushed without force; HEAD 12580b1dc. The branch includes the second origin/main merge (baf63356b).

## Commands

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: 12580b1dc4325eb73a8ca5d5eff6843a7acdfea5

Command: gh workflow run _poshqc.yml --ref bug/parallel-items-fail-completion-on-promotion-receipts-849
EXIT_CODE: 0
Output Summary: run 38060952234 created; UTC time taken immediately after the command: 2026-10-10T14:46:32Z.

Command: gh run list --workflow=_poshqc.yml --branch bug/parallel-items-fail-completion-on-promotion-receipts-849 --limit 1 --json databaseId,headSha,conclusion
EXIT_CODE: 0
Output Summary: [{"conclusion":"success","databaseId":38060952234,"headSha":"12580b1dc4325eb73a8ca5d5eff6843a7acdfea5"}]

Command: gh run view 38060952234 --json jobs
EXIT_CODE: 0
Output Summary: job "PowerShell QC" success (completed 2026-10-10T14:55:58Z): Format PowerShell=success, Analyze PowerShell=success, Test PowerShell=success, Upload PowerShell test artifacts=success. Job "PowerShell hook suites (Linux)" success.

Command: gh run download 38060952234 -n poshqc-test-results -D <session scratchpad directory outside the worktree>
EXIT_CODE: 0
Output Summary: downloaded pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml outside the worktree; nothing downloaded appears in `git status --porcelain`.

Command: python -S sanitize.py (session scratchpad script, same as H0) applying, in order, root replacement (the GitHub runner workspace prefix that precedes `tests/` or `.claude/`, in both separator forms, case-insensitive, to WORKTREE_ROOT), absolute-path replacement (ABSOLUTE_PATH), `<properties>` block removal, and `hostname` value replacement (HOST)
EXIT_CODE: 0
Output Summary: pester-junit.xml: root 7621, absolute-paths 284, properties 279, hostname 279 replacements; powershell-coverage.xml: root 197, other 0; zero runner host tokens remain in either copy. analyzer-output.txt is not written for Source B; the AnalyzeStep line above stands for zero analyzer findings.
