# PowerShell Analyze (P8-T3)

Timestamp: 2026-09-29T18-44
Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root = repository root, scan_folders = .claude/lib/parallel-drift, tests/scripts/claude-lib/parallel-drift, .claude/hooks, scripts/powershell/PoshQC/settings) ; sh SCRATCH/run-ps.sh SCRATCH/pssa-count.ps1 <C4 files>
EXIT_CODE: 0
Output Summary (loop pass 3, the recorded result, on commit c2b27d80):
- MCP call returned without raising: `{"ok":true,"tool":"run_poshqc_analyze",...,"summary":"Ran bundled PoshQC analyze against '<worktree>' with 4 selected scan folder(s)."}`
- A9: `PSSA-SUMMARY DiagnosticCount=0`

## Loop pass 2 (findings fixed)

The first analyzer run returned `{"ok":false,...,"summary":"Command exited with code 1.","stderr_excerpt":"... PSScriptAnalyzer reported 27 issue(s)."}`
and A9 reported `PSSA-SUMMARY DiagnosticCount=27`:
- 13 x PSUseOutputTypeCorrectly (Information) in the three production files: functions that return
  with the unary comma or return several types. Fixed by declaring both the array type and
  System.Object[] (the Resolve-MergeableConflict.ps1 precedent) and by declaring every returned type
  of the two JSON converters.
- 6 x PSUseLiteralInitializerForHashtable (Warning), one in the entry script and five in tests. A
  probe showed the rule flags every case-sensitive hashtable construction ([hashtable]::new with an
  Ordinal comparer, with a capacity, via a variable, via the full type name, or via New-Object) and
  exempts only an IgnoreCase comparer. D1/B21 require case-sensitive JSON object keys, so the entry
  script's converter carries one localized SuppressMessageAttribute with a justification (strictly
  necessary, per .claude/rules/powershell.md), as does the single ordinal-table helper of
  ParallelDrift.Tests.ps1 (B15 requires ordinal test records). The other test sites were rewritten to
  use the script's own JSON reader or a literal @{} where case sensitivity is not under test.
- 7 x PSUseShouldProcessForStateChangingFunctions (Warning) on New-* test helpers; renamed to Get-*.
- 1 x PSUseDeclaredVarsMoreThanAssignments (Warning) on the BeforeDiscovery fixture list of the
  parity suite; made script-scoped.
The five drift suites were rerun after the fixes (all passing except the byte-identity manifest case
until the three bundle mirrors were refreshed with cp and confirmed by A5 `same=3`). The fixes and
mirrors were committed as `c2b27d80` and the loop restarted at P8-T2.
