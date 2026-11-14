Timestamp: 2026-11-05T06-14
Started: 2026-11-05T06:14:20.0027869Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH/issue-1082-launch-hidden-merge-probe.sh
EXIT_CODE: 1
Output Summary:

```text
Physical stdin redirected=False

Running tests from 1 files.
[-] enforce-epic-merge-gate entry point (issue #786).exits 0 without a deny for a command that is not a merge 124ms
 at (($stdout | ForEach-Object { [string]$_ }) -join "`n") | Should -Not -Match '"permissionDecision":"deny"', REPO\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1:43
 Expected regular expression '"permissionDecision":"deny"' to not match '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"EPIC_MERGE_GATE_BLOCKED: payload anomaly - the hook received an empty payload on stdin and on both environment-variable fallbacks. The gate fails closed on an envelope it cannot read."}}', but it did match.
Tests completed in 1.51s
Tests Passed: 1, Failed: 1, Skipped: 0, Inconclusive: 0, NotRun: 0
Input probe: discovered=2; passed=1; failed=1; skipped=0
```

Raw output: SCRATCH/issue-1082-pester6-merge-input-hidden-reproduction.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
