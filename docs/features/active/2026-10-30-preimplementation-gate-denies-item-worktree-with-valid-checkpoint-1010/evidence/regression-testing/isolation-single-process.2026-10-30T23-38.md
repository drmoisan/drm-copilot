# Isolation: Fresh Single-Process Pester Run Over tests/scripts (Issue #1010, remediation cycle 1, P3-T10)

Timestamp: 2026-10-30T23-38
Command: sh SCRATCH/issue-1010-full.sh (Invoke-PoshQCTest in one PowerShell 7 process over the scan folder tests/scripts, coverage off, Run.Exit off; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: Run 2 (2026-10-30T23-07 to 23-32): 13437 tests, 13427 passed, 0 failed, 0 errors, 10 skipped. Run 1 (22-33 to 22-56) reported 2 failures, both caused by this cycle's new tests and fixed before run 2.

## Run 1 Failures and Fixes

1. `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, row `AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1 complies with the baseline isolation form for every closure seam`. The guard counts every `hooks/<name>.ps1` string literal as a loaded hook. The F1 suite only reads the two `-epic-scope` files as text, but its path literals put both files, and their closures, into the census. Fix: each path is now built with `Join-Path` from its segments, and a comment states that the files are read, not loaded. The suite still dot-sources nothing.
2. `test-name-uniqueness.Tests.ps1`, row `reports zero folded adapter-ID collisions across all tests/**/*.Tests.ps1`. The B10 cases `-C HEAD` and `-c HEAD` produce names that differ only by case, in both TargetWorktree suites. Fix: the two labels are now `-C HEAD (reuse-message)` and `-c HEAD (reedit-message)`. A separate `Option` value carries the command text, so the commands are unchanged.

After the fixes, both guard suites passed on their own (423 tests, 0 failed). The QA loop was restarted from P3-T2, and run 2 above is clean.
