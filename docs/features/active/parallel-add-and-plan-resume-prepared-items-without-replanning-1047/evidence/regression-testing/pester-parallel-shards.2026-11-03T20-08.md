# Pester Concurrent-Shard Run (remediation cycle 1)

Timestamp: 2026-11-03T20-08
Task: [P6-T5]
Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-parallel.ps1 importing scripts/powershell/PoshQC/PoshQC.psd1 and calling Invoke-PoshQCParallelTest -Root <worktree> (scan folders from config/poshqc-scan.json, default worker count 8); per-shard counts from each shard's console summary in artifacts/pester/parallel/shard-<n>/shard.log
EXIT_CODE: 1
Output Summary: 8 shard processes, wall clock 523.85 s. Shards 1 and 5 exited 0; shards 2, 3, 4, 6, 7, 8 exited non-zero, so no merged artifact was written. 89 failures in total, all in host-fixture suites under tests/scripts/dev-tools and tests/scripts/powershell/PoshQC; the same failing set reproduces at the merge base 01706c697 with identical counts. No failure is in a suite this item adds or changes. The acceptance condition (every shard and the merge exit 0, zero failures) is NOT met on this Linux host; the task stays unchecked as a host deviation.

| Shard | Exit | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| 1 | 0 | 427 | 0 | 0 |
| 2 | 24 | 1415 | 24 | 0 |
| 3 | 13 | 2337 | 13 | 1 |
| 4 | 1 | 1582 | 1 | 7 |
| 5 | 0 | 1957 | 0 | 0 |
| 6 | 3 | 2209 | 3 | 0 |
| 7 | 255 | 2257 | 30 | 2 |
| 8 | 18 | 1663 | 18 | 0 |

Shard 7 exited 255 because Pester's JUnit export failed on an ANSI escape character (0x1B) in a failure message of activate.Tests.ps1; its counts come from the shard console summary.

## Merge-base comparison (pre-existence)

Command: sh-launched PowerShell 7 script SCRATCH/issue-1047-mb.ps1 running Invoke-PoshQCTest with coverage disabled and JUnit written under SCRATCH, once in the merge-base checkout (01706c697, clean) and once in the item worktree, over the failing suites.

| Suite set | Merge base | Item head | Failed test names identical |
| --- | --- | --- | --- |
| 14 suites (Enter-DrmCopilotShell, HostBootstrap, HostBootstrapWorkspace, HostTooling, SideloadedExtensionPublish.Invoke, SideloadedExtensionPublish, Test-DiscoveryHostCapability.Entry, Test-DiscoveryHostCapability, new-potential-entry.TemplateRoot, post-codex-worktree-session, publish-sideloaded-extension, sync-agents-from-instructions, PoshQC.ScanConfig, PoshQC.TestingCommands) | 156 passed, 59 failed | 156 passed, 59 failed | yes (JUnit failed-case sets compared) |
| activate.Tests.ps1, HostBootstrap.Invoke.Tests.ps1, PoshQC.ScanFolders.Tests.ps1 (shard 7 suites) | 63 passed, 30 failed | 63 passed, 30 failed | counts identical (console summary) |

No path under tests/scripts/dev-tools, scripts/dev-tools, tests/scripts/powershell, scripts/powershell, or scripts/dev_tools differs between the merge base and the item head (git diff --name-only and git status --porcelain both empty for those paths). Causes are Windows-host assumptions (C: drive roots, backslash path expectations, Windows prompt strings). CI runs these suites on the windows-latest shards of poshqc / PowerShell QC.
