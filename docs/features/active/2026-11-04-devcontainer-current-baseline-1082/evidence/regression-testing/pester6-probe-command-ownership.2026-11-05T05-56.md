Timestamp: 2026-11-05T05-56
Started: 2026-11-05T05:56:57.6876916Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH/issue-1082-diagnose-probe-command.sh
EXIT_CODE: 0
Output Summary:

```text

Running tests from 2 files.
[+] REPO\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 695ms (7 tests)
[-] Discovery in SCRATCH\issue-1082-diagnostic-probe-command.Tests.ps1 failed with:
System.Management.Automation.DriveNotFoundException: Cannot find drive. A drive with the name ''C' does not exist.
   at System.Management.Automation.SessionStateInternal.GetDrive(String name, Boolean automount)
   at System.Management.Automation.SessionStateInternal.GetDrive(String name, Boolean automount)
   at System.Management.Automation.LocationGlobber.GetDriveRootRelativePathFromPSPath(String path, CmdletProviderContext context, Boolean escapeCurrentLocation, PSDriveInfo& workingDriveForPath, CmdletProvider& providerInstance)
   at System.Management.Automation.LocationGlobber.ResolveDriveQualifiedPath(String path, CmdletProviderContext context, Boolean allowNonexistingPaths, CmdletProvider& providerInstance)
   at System.Management.Automation.LocationGlobber.GetGlobbedMonadPathsFromMonadPath(String path, Boolean allowNonexistingPaths, CmdletProviderContext context, CmdletProvider& providerInstance)
   at System.Management.Automation.PathIntrinsics.GetResolvedPSPathFromPSPath(String path, CmdletProviderContext context)
   at Microsoft.PowerShell.Commands.ResolvePathCommand.ProcessRecord()
at <ScriptBlock>, SCRATCH\issue-1082-diagnostic-probe-command.Tests.ps1: line 21
at BeforeDiscovery, USERPROFILE\OneDrive\Documents\PowerShell\Modules\Pester\6.2.0\Pester.psm1: line 6042
at <ScriptBlock>, SCRATCH\issue-1082-diagnostic-probe-command.Tests.ps1: line 18
at <ScriptBlock>, USERPROFILE\OneDrive\Documents\PowerShell\Modules\Pester\6.2.0\Pester.psm1: line 3412
at Invoke-File, USERPROFILE\OneDrive\Documents\PowerShell\Modules\Pester\6.2.0\Pester.psm1: line 3421
at Invoke-BlockContainer, USERPROFILE\OneDrive\Documents\PowerShell\Modules\Pester\6.2.0\Pester.psm1: line 3336
at Invoke-ContainerDiscovery, USERPROFILE\OneDrive\Documents\PowerShell\Modules\Pester\6.2.0\Pester.psm1: line 1544
at Invoke-Test, USERPROFILE\OneDrive\Documents\PowerShell\Modules\Pester\6.2.0\Pester.psm1: line 2745
at Invoke-Pester<End>, USERPROFILE\OneDrive\Documents\PowerShell\Modules\Pester\6.2.0\Pester.psm1: line 5632
at <ScriptBlock>, SCRATCH\issue-1082-diagnose-probe-command.ps1: line 23
Tests completed in 866ms
Tests Passed: 7, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
Container failed: 1
  - SCRATCH\issue-1082-diagnostic-probe-command.Tests.ps1
Diagnostic tests=7; passed=7; failed=0
```

Raw output: SCRATCH/issue-1082-pester6-probe-command-ownership.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
