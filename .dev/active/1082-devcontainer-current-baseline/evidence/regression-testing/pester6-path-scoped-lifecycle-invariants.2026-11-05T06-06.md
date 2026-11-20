Timestamp: 2026-11-05T06-06
Started: 2026-11-05T06:06:14.0881979Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH/issue-1082-prove-module-lifecycle.sh
EXIT_CODE: 1
Output Summary:

```text
What if: Performing the operation "Remove stale fixture module binding" on target "REPO\.claude\lib\worktree-resolution\EpicScopeResolution.psm1".
Exception: SCRATCH\issue-1082-prove-module-lifecycle.ps1:16:81
Line |
  16 |  … ved[0],$scope)){throw 'Cleanup removed an unrelated module instance'}
     |                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Cleanup removed an unrelated module instance
```

Raw output: SCRATCH/issue-1082-pester6-path-scoped-lifecycle-invariants.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
