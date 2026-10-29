Timestamp: 2026-10-29T18-15
Command: Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1 (single file, post-fix hook)
EXIT_CODE: 0
Output Summary: pester-junit.xml tests=33 failures=0, including both --admin rows and the --squash/--rebase rows. Deviation note: the plan predicted the --admin decline ends in the generic final deny text; the observed existing deny is the standalone-authorization text (STANDALONE_MERGE_AUTHORIZATION_ABSENT), because the checkpoint carries no authorization record and the silent decline falls through to that unchanged branch. The test asserts that existing deny, a deny without any GREEN_CI suffix, and no live-head call. No deny text was changed by the hook edit.
