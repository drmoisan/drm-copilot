Timestamp: 2026-11-05T05-37
Started: 2026-11-05T05:37:11.6872448Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH\issue-1082-diagnose-attestation.sh
EXIT_CODE: 1
Output Summary:

```text
      22 |  … ($null -eq (Get-Variable -Name HookDependencyFailures -Scope Script - …
         |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         | Cannot find a variable with the name 'HookDependencyFailures'., but got 2.
Filter 'FullName' set to ('*transcript-keyed attestation*').
Filters selected 2 tests to run.

Running tests from 'SCRATCH\issue-1082-diagnostic-enforce-epic-root-invocation.Coverage.Tests.ps1'
Describing Codex enforce-epic-root-invocation coverage (issue #786)
 Context entry point
   [-] reads the transcript-keyed attestation and allows valid provenance 45ms
    at $result.ExitCode | Should -Be 0 -Because ($result.Stderr + [Environment]::NewLine + (($Error | Select-Object -First 3 | Out-String))), SCRATCH\issue-1082-diagnostic-enforce-epic-root-invocation.Coverage.Tests.ps1:88
    Expected 0, because No mock for command 'Test-Path' matched the call: none of the parameter filters matched, and there is no default mock to fall back to. Add a default mock (e.g. `Mock Test-Path { ... }`) or adjust an existing -ParameterFilter.
    The following parameter filters were evaluated and did not match:
        { ([string]$LiteralPath) -like '*codex-routing-attestation.*' }  bound parameters: PSPath = USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786, LP = USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786, LiteralPath = USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786
        { ([string]$LiteralPath).Replace('\', '/') -match '/\.codex/.*\.ps[dm]?1$' -or
                    ([string]$Path).Replace('\', '/') -match '/\.codex/.*\.ps[dm]?1$' }  bound parameters: PSPath = USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786, LP = USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786, LiteralPath = USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786
    Exception: No mock for command 'Test-Path' matched the call: none of the parameter filters matched, and there is no default mock
    to fall back to. Add a default mock (e.g. `Mock Test-Path { ... }`) or adjust an existing -ParameterFilter.  The
    following parameter filters were evaluated and did not match:     { ([string]$LiteralPath) -like
    '*codex-routing-attestation.*' }  bound parameters: PSPath =
    USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786,
    LP =
    USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786,
    LiteralPath =
    USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786
    { ([string]$LiteralPath).Replace('\', '/') -match '/\.codex/.*\.ps[dm]?1$' -or
    ([string]$Path).Replace('\', '/') -match '/\.codex/.*\.ps[dm]?1$' }  bound parameters: PSPath =
    USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786,
    LP =
    USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786,
    LiteralPath =
    USERPROFILE\.codex\authority\epic-entry\343738e13aadb46562b1783b0be2d7dd80ad9ebbd11aadcc6dfa1e4dca3eb9cf\s-786
    Get-Variable: REPO\.codex\hooks\hook-dependency-guard.ps1:22:16
    Line |
      22 |  … ($null -eq (Get-Variable -Name HookDependencyFailures -Scope Script - …
         |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         | Cannot find a variable with the name 'HookDependencyFailures'.
    Get-Variable: REPO\.codex\hooks\hook-dependency-guard.ps1:22:16
    Line |
      22 |  … ($null -eq (Get-Variable -Name HookDependencyFailures -Scope Script - …
         |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         | Cannot find a variable with the name 'HookDependencyFailures'., but got 2.
Tests completed in 1.03s
Tests Passed: 0, Failed: 2, Skipped: 0, Inconclusive: 0, NotRun: 25
Diagnostic selected=2; passed=0; failed=2
```

Raw output: SCRATCH/issue-1082-pester6-attestation-stderr-diagnostic.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
