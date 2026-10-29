Timestamp: 2026-10-29T18-05
Command: Invoke-PoshQCTest -ScanFolders tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1 (single file, pre-fix hook)
EXIT_CODE: 2
Output Summary: expect-fail. pester-junit.xml: tests=33 failures=2. Failed: "command-shape declines.declines a non-structural merge command --admin" (decision was allow, expected deny) and "declines --admin combined with a valid green checkpoint and falls through to the final deny text (issue #997)" (reason empty, expected final deny text). Passed: "still allows --squash ..." and "still allows --rebase ...". Failure is for the intended reason: the hook allows --admin on a green checkpoint.
