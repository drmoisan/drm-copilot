# P11-T4 PowerShell analyze gate

Timestamp: 2026-10-23T03-17
Command: Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCAnalyze -Root <worktree> (the `poshqc / PowerShell QC static` job shape with scripts/powershell/PoshQC/settings/pssa.settings.psd1, run through a SCRATCH launcher)
EXIT_CODE: 1 (pass 1), 0 (pass 2), 0 (pass 3)
Output Summary: Pass 1 reported one finding over the full population: PSProvideCommentHelp (Information) on `Test-FixtureDiscoveryAuthority` in `tests/fixtures/codex_native_converter/native_surfaces/.claude/lib/discovery-validation/DiscoveryValidation.psm1`, a branch-added converter fixture that the earlier scoped MCP analyzer runs never scanned. Repair: a comment-based help block on the fixture function; the converter suites that consume the fixture (79 tests) still pass and the fixture's `function Test-FixtureDiscoveryAuthority` and import-rewrite assertions are unchanged. Passes 2 and 3 (after the test repairs) printed "PSScriptAnalyzer passed: no findings under <worktree>".
