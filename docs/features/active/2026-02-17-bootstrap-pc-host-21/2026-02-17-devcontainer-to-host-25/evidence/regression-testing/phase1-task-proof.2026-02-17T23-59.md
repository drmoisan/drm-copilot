Timestamp: 2026-02-18T08-07
Command: $file='tests/scripts/dev-tools/bootstrap-host.Tests.ps1'; $checks=@(@{Id='P1-T1';Pattern='Resolve-DependencyCatalog scenario A returns catalog including git, python, poetry, pwsh, node, and npm'},@{Id='P1-T2';Pattern='Resolve-DependencyCatalog scenario B returns deterministic error when devcontainer input parse fails'},@{Id='P1-T3';Pattern='Test-DependencyPresence scenario C returns missing status and remediation hint when command is not found'},@{Id='P1-T4';Pattern='Test-DependencyPresence scenario D returns missing status with detected and required version guidance'},@{Id='P1-T5';Pattern='Test-DependencyPresence scenario E returns present status when version is compatible'},@{Id='P1-T6';Pattern='Resolve-InstallStrategy scenario F returns deterministic install action metadata on supported Windows'},@{Id='P1-T7';Pattern='Resolve-InstallStrategy scenario G returns unsupported classification for unsupported operating system'},@{Id='P1-T8';Pattern='Invoke-BootstrapVerify scenario H returns non-zero exit code when required dependency is missing'},@{Id='P1-T9';Pattern='Invoke-BootstrapVerify scenario I returns deterministic validation message for unknown dependency filter'},@{Id='P1-T10';Pattern='Invoke-BootstrapInstall scenario J performs no install calls in dry-run mode'},@{Id='P1-T11';Pattern='Invoke-BootstrapInstall scenario K emits skipped on second run for already-present dependency'},@{Id='P1-T12';Pattern='Invoke-BootstrapInstall scenario L returns aggregate non-zero behavior and continues processing after first dependency fails'},@{Id='P1-T13';Pattern='Format-BootstrapReport scenario M outputs JSON rows containing required schema keys'}); $allFound=$true; foreach($c in $checks){$m=Select-String -Path $file -SimpleMatch -Pattern $c.Pattern; if($m){Write-Output ("$($c.Id)|FOUND|LINE=$($m.LineNumber)")}else{Write-Output ("$($c.Id)|MISSING|LINE=-"); $allFound=$false}}; if($allFound){Write-Output 'EXIT_CODE=0'}else{Write-Output 'EXIT_CODE=1'}
EXIT_CODE: 0
Output Summary:
- P1-T1|FOUND|LINE=14
- P1-T2|FOUND|LINE=26
- P1-T3|FOUND|LINE=42
- P1-T4|FOUND|LINE=51
- P1-T5|FOUND|LINE=64
- P1-T6|FOUND|LINE=83
- P1-T7|FOUND|LINE=94
- P1-T8|FOUND|LINE=113
- P1-T9|FOUND|LINE=122
- P1-T10|FOUND|LINE=136
- P1-T11|FOUND|LINE=151
- P1-T12|FOUND|LINE=174
- P1-T13|FOUND|LINE=205
Acceptance Mapping:
- P1-T1 through P1-T13 scenario test names are present in the phase test file with deterministic line anchors.
- P1-T14 expect-fail execution evidence is captured in evidence/regression-testing/bootstrap-host-red-suite.2026-02-17T23-59.md.
