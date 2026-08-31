# Baseline — PowerShell No-Python-Invocation Regression Suite

Timestamp: 2026-08-30T06-22
Task: [P0-T13]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -CI"` (run from the worktree root)

EXIT_CODE: 0

Output Summary: All 27 tests passed; **failed count 0**. The Pester run summary, reproduced
verbatim with the ANSI colour escape sequences stripped:

```
Starting discovery in 1 files.
Discovery found 27 tests in 369ms.
Running tests.
[+] C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab2cbeea5d3050501\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1 4.51s (3.53s|716ms)
Tests completed in 4.55s
Tests Passed: 27, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

The raw stream carried ANSI colour escapes (for example `ESC[32m` before the passed count). They
are removed above for readability; no other alteration was made to the text.

## What the Zero Failed Count Certifies

The acceptance for this task is the summary plus the exit code, not the presence of individual case
names, because Pester's default verbosity prints per-case names for failures only. A run with no
failures therefore prints the file-level `[+]` line and the counts, which is what is recorded above.

The two cases the plan names as the substantive content of this suite were verified to exist at the
cited lines this pass:

- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:102` —
  `It 'ships an empty allowlist' {`
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:473` —
  `It 'reports no Python invocation beyond the allowlist across the guarded tree' {`

Both citations are correct as written in the plan. The file is 500 lines, at the file-size cap set
by `.claude/rules/general-code-change.md` but not over it.

A failed count of 0 across 27 cases is what certifies that the guarded tree currently carries no
Python invocation beyond the allowlist, and that the allowlist ships empty. This is the pre-change
state the feature must preserve.

## Scope Note

No PowerShell production or test file is added or modified by this feature, so the PoshQC
format and lint loop does not run in this plan. This suite is executed as a regression check only.
