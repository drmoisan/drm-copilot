# PowerShell Measurement Run Record, Handoff H0 (Issue #849)

Timestamp: 2026-10-10T14-12
Source: B (CI dispatch of `_poshqc.yml`)
SourceB-Reason: the orchestrator session has no PowerShell host tool (only the Bash tool), and the operator constraints for this run prohibit sh/bash/pwsh wrapper invocations inside the worktree, so the Source A commands cannot be run. No Source A command was attempted; there is no refusal text to record.
H0-Trigger-Completed: 2026-10-10T13:58:21Z (from `ps-analyze.2026-10-09T01-33.md`)
SourceB-LocalHead: fd229cd7535be526cf7860367745cd1d4f4703f2
SourceB-Dispatched: 2026-10-10T14:00:04Z
SourceB-RunId: 38057875117
SourceB-HeadSha: fd229cd7535be526cf7860367745cd1d4f4703f2
FormatStep: success
AnalyzeStep: success
sanitized: root, absolute-paths, properties, hostname

Freshness: `SourceB-Dispatched:` (2026-10-10T14:00:04Z) is later than `H0-Trigger-Completed:` (2026-10-10T13:58:21Z). `SourceB-HeadSha:` equals `SourceB-LocalHead:`.

Pre-dispatch commit: Phase 0 evidence (P0-T1..P0-T17) committed with explicit pathspecs and pushed without force as fd229cd75.

## Commands

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: fd229cd7535be526cf7860367745cd1d4f4703f2

Command: gh workflow run _poshqc.yml --ref bug/parallel-items-fail-completion-on-promotion-receipts-849
EXIT_CODE: 0
Output Summary: run 38057875117 created; UTC time taken immediately after the command: 2026-10-10T14:00:04Z.

Command: gh run list --workflow=_poshqc.yml --branch bug/parallel-items-fail-completion-on-promotion-receipts-849 --limit 1 --json databaseId,headSha,conclusion
EXIT_CODE: 0
Output Summary: [{"conclusion":"success","databaseId":38057875117,"headSha":"fd229cd7535be526cf7860367745cd1d4f4703f2"}]

Command: gh run view 38057875117 --json jobs
EXIT_CODE: 0
Output Summary: job "PowerShell QC" success (completed 2026-10-10T14:09:36Z): Format PowerShell=success, Analyze PowerShell=success, Test PowerShell=success, Upload PowerShell test artifacts=success. Job "PowerShell hook suites (Linux)" success.

Command: gh run download 38057875117 -n poshqc-test-results -D <session scratchpad directory outside the worktree>
EXIT_CODE: 0
Output Summary: downloaded pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml outside the worktree; nothing downloaded appears in `git status --porcelain`.

Command: python -S sanitize.py (session scratchpad script) applying, in order, root replacement (the GitHub runner workspace prefix that precedes `tests/` or `.claude/`, in both separator forms, case-insensitive, to WORKTREE_ROOT), absolute-path replacement (ABSOLUTE_PATH), `<properties>` block removal, and `hostname` value replacement (HOST)
EXIT_CODE: 0
Output Summary: pester-junit.xml: root 7591, absolute-paths 284, properties 279, hostname 279 replacements; powershell-coverage.xml: root 197, other 0; zero runner host tokens remain in either copy. analyzer-output.txt is not written for Source B; the AnalyzeStep line above stands for zero analyzer findings.
