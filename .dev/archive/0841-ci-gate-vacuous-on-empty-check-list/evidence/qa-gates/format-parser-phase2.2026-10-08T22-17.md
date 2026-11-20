# PowerShell Format Gate After Parser Fix (#841, P2-T6)

Timestamp: 2026-10-10T09-21
Command: mcp__drm-copilot__run_poshqc_format workspace_root=<worktree> scan_folders=[".claude/lib/ci-gate","tests/scripts/claude-lib/ci-gate"]; bracketed by git hash-object (before and after) over the three files in the scan folders; then git status --porcelain -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate and git diff --stat
EXIT_CODE: 0
Output Summary: FORMAT-SUMMARY ChangedCount=0. MCP call returned normally (ok=true). The formatter modified no file: the object hashes of all three files are identical before and after the call. The status output names only `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` (modified by P2-T1 through P2-T5, not by the formatter).

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 <2 files>` was replaced by the A6 substitute: the MCP format call with a before/after tree observation; ChangedCount = number of files the call modified. Before/after `git hash-object` comparison was added as the per-file observation because the parser was already modified (uncommitted) before the call, so `git status` alone cannot distinguish a formatter change.

## Tree observation

- `git hash-object` before the call:
  - `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` 7c81ef17c6d627676472ca6311c8c1f4fdecdc5d
  - `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` dd1af292861a1c949e2b4e7246707a566671e25b
  - `tests/scripts/claude-lib/ci-gate/CiGate.Manifest.Tests.ps1` d1d4b656af40b6b23a59b84dfc4a3acc5fd04a24
- MCP result: `{"ok":true,"tool":"run_poshqc_format",...,"summary":"Ran bundled PoshQC format against '<worktree>' with 2 selected scan folder(s)."}`
- `git hash-object` after the call: identical to the three values above.
- `git status --porcelain -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate` after: ` M .claude/lib/ci-gate/Invoke-CiGateParser.ps1`
- `git diff --stat` after: `.claude/lib/ci-gate/Invoke-CiGateParser.ps1 | 86` and the plan file (checklist updates); no other path.

ChangedCount=0
