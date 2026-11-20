# gh Dependency Search before the R1-F5 edit (P1-T1)

Timestamp: 2026-11-04T15-46
Command: sh SCRATCH/issue-1067-gh-search.sh (git grep -n -F for each fixed pattern over tests/; git grep -n -E for Get-Command filters and parameter filters naming gh)
EXIT_CODE: 0

## Results by pattern

| Pattern | Matches | Path(s) | Classification |
|---|---|---|---|
| `global:gh` | 1 | `tests/scripts/dev-tools/link-feature-docs.Tests.ps1` (`Describe "link-feature-docs.ps1"` `BeforeAll`) | definition |
| `Mock gh` | 1 | `tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1` (purity-rule fixture content `'Mock gh'`) | fixture text |
| `CommandName gh` | 0 | none | - |
| `Get-Command gh` | 0 | none | - |
| Get-Command filters naming `gh` (regex) | 22 | see below | see below |

Regex matches for Get-Command filters on the name `gh`:

- `tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1`, `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1`, `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` (17 matches): calls to `Get-CommandLineFlagValue`, `Get-CommandLineOperand`, and `Get-CommandLineGlobalOption` with the string argument `-CommandWord 'gh'`. These parse command text and never resolve or call `gh`. Classification: fixture text.
- `tests/scripts/dev-tools/HostVerification.Tests.ps1` (1 match): `Mock -CommandName Get-Command -ModuleName HostVerification ... -ParameterFilter { $Name -eq 'gh' }`. The suite supplies its own `Get-Command` result and does not call a `gh` function. Classification: self-contained mock, not a dependence.
- `tests/scripts/dev-tools/link-feature-docs.Tests.ps1` (1 match): `Context "Invoke-LinkFeatureDocument"` mock of `Get-Command` for `gh`, inside the defining suite. Classification: part of the definition's own suite.
- `tests/scripts/dev-tools/link-parent-child.Tests.ps1` (2 matches): `Describe "link-parent-child.ps1 - Test-GhCli"` mocks `Get-Command` for `gh`. The suite supplies its own result; the P0-T4 baseline run of this suite alone passed 22 of 22 with `PROBE GH-FUNCTION=absent`, so it does not need the leaked function. Classification: self-contained mock, not a dependence.

The only `global:gh` match is `tests/scripts/dev-tools/link-feature-docs.Tests.ps1`. No match calls or mocks `gh` without defining it.

Output Summary: one definition, fixture-text and self-contained-mock matches only; no dependence on the leaked function.

GH-DEPENDENTS=0
