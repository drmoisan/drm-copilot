# CiWorkflow Before (P1-T2, expect-fail)

Timestamp: 2026-10-16T10-42
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/workflows]
EXIT_CODE: 1
ExpectedExitCode: 1
Disposition: RAISED
Output Summary: Command exited with code 1.
Baseline (P0-T10 t-workflows): GREEN

Error text (verbatim): {"ok": false, "tool": "run_poshqc_test", "workspace_root": "WORKTREE_ROOT", "summary": "Command exited with code 1."}

RowAttribution:
- `declares merge_group with types checks_requested and no branch or path filter` (tests/scripts/workflows/CiWorkflow.Tests.ps1) — expected pre-change outcome: FAIL. Reason: `.github/workflows/ci.yml:3-8` declares no `merge_group` key, so the merge_group index is not found.
- `reads no pull-request event field and declares no path filter anywhere in the ci.yml call graph` (tests/scripts/workflows/CiWorkflow.Tests.ps1) — expected pre-change outcome: PASS. Reason: per Appendix A pre-change note, the patterns match only files outside the ci.yml call graph (npm-audit-gate.yml, publish-mcp-npm.yml, publish-extension.yml, verify-published-releases.yml); the call graph is ci.yml and the nine reusable workflows of ci.yml:12-39.
- The two pre-existing rows (`lists main, development, and epic/** in the pull_request branch filter`, `keeps the push branch filter exactly main and development`) are unchanged and expected to pass.

CI job relied on: poshqc / PowerShell QC.
