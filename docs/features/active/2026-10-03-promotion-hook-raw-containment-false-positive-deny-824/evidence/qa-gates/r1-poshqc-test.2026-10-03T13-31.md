# r1 P8-T3 — PowerShell tests with coverage (MCP route step bracketed by TREE-DIGEST, then the direct full Pester run)

Timestamp: 2026-10-03T13-31
Command: (1) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t3.ps1 -Worktree WORKTREE (A0 and TREE-DIGEST); (2) MCP tool mcp__drm-copilot__run_poshqc_test with workspace_root WORKTREE and scan_folders tests/scripts/claude-hooks and tests/scripts/codex-hooks; (3) pwsh -NoProfile -File SCRATCH/steps/r1-p8-t3-after.ps1 -Worktree WORKTREE (A0, TREE-DIGEST, `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path' *> "$Scratch/r1-pester-final.log"; $testExit = $LASTEXITCODE; "PESTER-EXIT=$testExit"`, the coverage copy to SCRATCH/r1-final-coverage.xml, the JUnit totals, and VERDICT(`$treeDigest -eq RECORDED(step (1) TREE-DIGEST) -and $testExit -eq 0 -and $failures -eq 0 -and $errors -eq 0 -and $tests -ge 6626 + 127`))
EXIT_CODE: 0
Output Summary:
- Step (1), TS=2026-10-03T13-31, exit 0: TREE-DIGEST=5E-5C-25-5D-2D-5A-89-1A-DB-37-32-33-32-F8-56-75-F1-81-FC-4B-11-A6-96-E6-D0-A3-A9-CB-14-9D-9F-93
- Step (2): MCP_ROUTE: CALLED; returned `{"ok":true,"tool":"run_poshqc_test","workspace_root":"WORKTREE","summary":"Ran bundled PoshQC test against 'WORKTREE' with 2 selected scan folder(s)."}`
- Step (3), TS=2026-10-03T13-34, exit 0: TREE-DIGEST=5E-5C-25-5D-2D-5A-89-1A-DB-37-32-33-32-F8-56-75-F1-81-FC-4B-11-A6-96-E6-D0-A3-A9-CB-14-9D-9F-93 (equal; the MCP call changed no file in scope); PESTER-EXIT=0; `tests=6753 failures=0 errors=0` (P0-T13 tests=6626, plus 127 new tests: 73 expect-fail rows, 47 new pass-before rows, 7 U3 rows); no FAILED line.
- artifacts/pester holds the direct run's output (the direct run ran last). Top-level EXIT_CODE is step (3)'s exit code: 0.
