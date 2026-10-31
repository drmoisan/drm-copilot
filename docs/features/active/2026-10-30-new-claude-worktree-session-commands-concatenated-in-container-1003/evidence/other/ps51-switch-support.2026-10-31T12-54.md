# Windows PowerShell 5.1 Switch Support (Issue #1003)

Timestamp: 2026-10-31T12-54
Command: sh SCRATCH/issue-1003-ps51-probe.sh (runs `powershell.exe -NoLogo -NoProfile -EncodedCommand <base64 UTF-16LE of: Write-Output ('ps51-encoded-ok ' + $PSVersionTable.PSVersion.Major)>`, then `powershell.exe -?` filtered for the three switches)
EXIT_CODE: 0
Output Summary: encoded probe printed `ps51-encoded-ok 5` (PROBE_EXIT=0); `powershell.exe -?` usage text lists `-NoLogo`, `-NoExit`, and `-EncodedCommand <Base64EncodedCommand>`. Windows PowerShell 5.1 accepts all three switches.

## Encoded probe output

```
ps51-encoded-ok 5
PROBE_EXIT=0
```

(A CLIXML progress record "Preparing modules for first use." was also written to the redirected stream; it is not part of the probe result.)

## Usage text matches (`powershell.exe -?`)

```
3:    [-NoLogo] [-NoExit] [-Sta] [-Mta] [-NoProfile] [-NonInteractive]
5:    [-WindowStyle <style>] [-EncodedCommand <Base64EncodedCommand>]
22:-NoLogo
25:-NoExit
52:-EncodedCommand
117:    # To use the -EncodedCommand parameter:
121:    powershell.exe -encodedCommand $encodedCommand
```
