Timestamp: 2026-02-18T00-34
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/bootstrap-host.Tests.ps1 -Output Detailed"
EXIT_CODE: 1
Failure:
- CommandNotFoundException: The term 'Resolve-DependencyCatalog' is not recognized as a name of a cmdlet, function, script file, or executable program.
- CommandNotFoundException: The term 'Test-DependencyPresence' is not recognized as a name of a cmdlet, function, script file, or executable program.
- CommandNotFoundException: The term 'Invoke-BootstrapVerify' is not recognized as a name of a cmdlet, function, script file, or executable program.
Attribution:
- Failures are attributable to missing production implementation file/functions for `scripts/dev-tools/bootstrap-host.ps1`.
