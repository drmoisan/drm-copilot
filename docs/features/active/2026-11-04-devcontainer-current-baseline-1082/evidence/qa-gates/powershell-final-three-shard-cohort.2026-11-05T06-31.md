Timestamp: 2026-11-05T06-31
Started: 2026-11-05T06:21:17.6624407Z
Command: C:/Program Files/Git/bin/sh.exe SCRATCH/issue-1082-final-pester.sh parallel -TargetRoot SCRATCH/stage/current-source-final
EXIT_CODE: 0
Output Summary:

```text
Actual Pester version: 6.2.0
Discovered test-file candidates: 507
Coverage policy: config/poshqc-coverage.json; profiler mode; JaCoCo output; unchanged configured roots
Started 3 shard processes; logs are under SCRATCH\stage\current-source-final\artifacts\pester\parallel.
Shard 1 exited with code 0; log: SCRATCH\stage\current-source-final\artifacts\pester\parallel\shard-1\shard.log
Shard 2 exited with code 0; log: SCRATCH\stage\current-source-final\artifacts\pester\parallel\shard-2\shard.log
Shard 3 exited with code 0; log: SCRATCH\stage\current-source-final\artifacts\pester\parallel\shard-3\shard.log
Wrote the merged JUnit and coverage reports under SCRATCH\stage\current-source-final\artifacts\pester.
Invoke-PoshQCParallelTest: workers=3; wall-clock=600.05s; exit code=0
{
  "ExitCode": 0,
  "WorkerCount": 3,
  "WallClockSeconds": 600.05,
  "Shards": [
    {
      "ShardIndex": 1,
      "ExitCode": 0,
      "LogPath": "SCRATCH\\stage\\current-source-final\\artifacts\\pester\\parallel\\shard-1\\shard.log"
    },
    {
      "ShardIndex": 2,
      "ExitCode": 0,
      "LogPath": "SCRATCH\\stage\\current-source-final\\artifacts\\pester\\parallel\\shard-2\\shard.log"
    },
    {
      "ShardIndex": 3,
      "ExitCode": 0,
      "LogPath": "SCRATCH\\stage\\current-source-final\\artifacts\\pester\\parallel\\shard-3\\shard.log"
    }
  ]
}
```

Raw output: SCRATCH/issue-1082-powershell-final-three-shard-cohort.log

Representation normalized: 2026-11-05T06:45:23.265614+00:00; original command timestamps/results retained, raw logs unchanged.
