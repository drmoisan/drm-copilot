# Final Analyzer Gate (issue #673)

Timestamp: 2026-09-19T19-18

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-analyze.ps1` (route `a`), running `Invoke-PoshQCAnalyze -Root $root` from `scripts/powershell/PoshQC/PoshQC.psd1`, the command `.github/workflows/_poshqc.yml:36` runs. `Invoke-ScriptAnalyzer` with a severity filter is never used, so the run covers Error, Warning, and Information severities.

EXIT_CODE: 0

Pass number: **2**.

Output:

```
PSScriptAnalyzer passed: no findings under <WORKSPACE_ROOT>
```

The output contains `PSScriptAnalyzer passed: no findings under`, which is the acceptance condition, and it does not contain `No PowerShell files found under`, so the analyzer did enumerate files.

## Pass 1, recorded rather than discarded

Pass 1 of this gate **failed** with `PSScriptAnalyzer reported 15 issue(s).` and exit code 1. All fifteen were Warning-severity findings in files this plan authored, in two classes:

- **Eleven `PSUseShouldProcessForStateChangingFunctions`** on test-local factory and mock-registration helpers named with a `New-` or `Set-` verb. These change no system state. The repository already carries this exact suppression with a justification on two pre-existing helpers in `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, so the same attribute and the same style of justification were applied to the eleven.
- **Four `PSReviewUnusedParameter`** on mock-body parameters that were declared but never read. Pester binds a mock body's parameters by name, so a body need only declare what it reads; the unused declarations were removed rather than suppressed.

Each was fixed at its cause. One follow-up correction was needed: the first insertion placed a suppression attribute ahead of a comment-based-help block in `WorktreeResolutionFixture.Helpers.ps1`, which would have stopped that block being read as help. The attribute was moved to sit after the help block and before `[CmdletBinding()]`, and `Get-Help` was then confirmed to return a non-empty synopsis for the function.

The loop restarted from `[P11-T1]` as the plan requires, and pass 2 is the clean pass.

One earlier analyzer finding, outside this loop, is recorded for completeness: during `[P2-T2]` the same rule flagged a private constructor in the new module named with a `New-` verb. It was renamed to a `ConvertTo-` verb, matching the naming its sibling library module already uses for a private constructor, rather than suppressed — a module export surface is a narrower place to add a suppression than a test file.

Output Summary: Zero PSScriptAnalyzer findings across the whole tree at Error, Warning, and Information severity. The baseline was also clean, so this gate attributes any finding to this change set; pass 1 did exactly that, reporting fifteen findings in the new test files, and all fifteen were fixed at their cause before pass 2 returned clean.
