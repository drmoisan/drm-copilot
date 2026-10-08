# PowerShell Format (P8-T2)

Timestamp: 2026-09-29T18-44
Command: sh SCRATCH/file-hashes.sh <C4 files> (before) ; git status --porcelain (before) ; mcp__drm-copilot__run_poshqc_format (workspace_root = repository root, scan_folders = .claude/lib/parallel-drift, tests/scripts/claude-lib/parallel-drift, .claude/hooks, scripts/powershell/PoshQC/settings) ; git status --porcelain (after) ; sh SCRATCH/file-hashes.sh <C4 files> (after) ; sh SCRATCH/run-ps.sh SCRATCH/ps-format-check.ps1 <C4 files>
EXIT_CODE: 0
Output Summary (pass 3, the recorded result, on commit c2b27d80):
- MCP call returned without raising: `{"ok":true,"tool":"run_poshqc_format",...,"summary":"Ran bundled PoshQC format against '<worktree>' with 4 selected scan folder(s)."}`
- Porcelain before and after: byte-identical (`cmp` exit 0).
- Hashes before and after: identical for every C4 file (`cmp` exit 0):
  .claude/lib/parallel-drift/ParallelDriftHalt.psm1 Hash=2c2e0919fe5f73264ace405a97795184d34f6a55
  .claude/lib/parallel-drift/ParallelDrift.psm1 Hash=4d211a6397b0aa4ac1f5639fbe4616260c9d517f
  .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 Hash=f91bf4b6754745de51b351ed8edabc09eaff02f5
  tests/scripts/claude-lib/parallel-drift/ParallelDriftHalt.Tests.ps1 Hash=4c6539c019ed275f593bbda5ed7f80e95151e9a5
  tests/scripts/claude-lib/parallel-drift/ParallelDrift.Tests.ps1 Hash=2a983d2f4150b602040b3f5959f4570c9b02ed4b
  tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1 Hash=312e9484a702cc7da6973642ea2f2ef6d666df6a
  tests/scripts/claude-lib/parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 Hash=f2957f7a6a05465a72308cb289b6805837cd56ea
  tests/scripts/claude-lib/parallel-drift/ParallelDrift.Parity.Tests.ps1 Hash=52c0e78cb7737b23f390630c0588bdb0c617d1dd
  .claude/hooks/enforce-parallel-abandon-gate.ps1 Hash=315fce6adae168c2a39686ab258c59ec0c7d91ac
  scripts/powershell/PoshQC/settings/pester.runsettings.psd1 Hash=f64aff5aabfdc71464ebf375a298cf1fcd4bbb1b
- A6: every file `Changed=False`; `FORMAT-SUMMARY ChangedCount=0`.

## Loop restarts

- Pass 1: the MCP formatter rewrote one path, a C4 member with no bundle mirror,
  `tests/scripts/claude-lib/parallel-drift/ParallelDrift.Manifest.Tests.ps1` (pipeline continuation
  indentation of two lines). No path outside C4 changed. The rewrite was committed (`d73070cc`,
  "style(763): apply PoshQC formatting to the drift manifest suite") and pushed; the loop restarted.
- Pass 2: clean, but the following P8-T3 analyzer run reported 27 diagnostics (see
  qa-gates/powershell-analyze). The fixes and the refreshed bundle mirrors of the three production
  files were committed (`c2b27d80`) and pushed, and the loop restarted at this task.
- Pass 3: clean (above).
