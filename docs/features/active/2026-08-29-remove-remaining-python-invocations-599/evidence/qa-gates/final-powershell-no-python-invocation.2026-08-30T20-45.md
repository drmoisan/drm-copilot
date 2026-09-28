# P6-T13 — PowerShell regression check

Timestamp: 2026-08-30T20-45

Command (from the worktree root):

```
pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 -CI"
```

EXIT_CODE: 0

Output Summary:

```
Starting discovery in 1 files.
Discovery found 27 tests in 176ms.
Running tests.
[+] tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1 2.21s (1.4s|668ms)
Tests completed in 2.25s
Tests Passed: 27, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

## Acceptance

Satisfied. `EXIT_CODE: 0` with `Failed: 0` in the run summary.

The acceptance is stated over the summary rather than over a per-case name because Pester's
default verbosity prints case names for failures only. `Failed: 0` across all 27 discovered
tests certifies every case in the file, including `ships an empty allowlist` (line 102).

## Scope note

No PowerShell file was added or modified by this feature, so this task is a regression check
rather than a gate on new code. The suite deliberately excludes `.claude/lib/bash/**` from its
scan (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:65-66`), so
the two bash files this feature adds are outside its guarded tree and cannot have influenced the
result in either direction.

The P6-T5 remediation added `tests/shell/report_lane_assertion_dispatch.bats`, which is likewise
outside the guarded tree for the same reason. The baseline
`evidence/baseline/powershell-no-python-invocation.2026-08-30T06-22.md` recorded the same
`Failed: 0` outcome, so there is no regression.

kcov and Pester emit no branch-coverage counter, and `.claude/rules/quality-tiers.md` applies no
branch-coverage gate to PowerShell for that reason. This task measures no coverage; it is a
pass/fail regression assertion only.
