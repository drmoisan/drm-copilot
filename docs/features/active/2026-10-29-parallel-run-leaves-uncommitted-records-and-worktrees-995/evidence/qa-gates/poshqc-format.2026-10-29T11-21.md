# PoshQC Format (loop pass 3)

Timestamp: 2026-10-29T11-21
Task: [P6-T1] (restarted after the [P6-T3] pass-2 full run reported four guard-suite failures)
Command: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <repo root> -GetFileList <the 26 files listed below> (PowerShell 7 launched by `sh SCRATCH/issue-995-format.sh`, which records `git status --porcelain` and `git hash-object` for each file before and after)
EXIT_CODE: 0
Output Summary: the formatter printed "Already formatted:" for all 26 files. The before and after `git hash-object` lists are identical (26 of 26) and the before and after `git status --porcelain` listings are identical (byte comparison of the two captured listings). No file was rewritten.

Pass-2 context: the pass-2 full Pester run failed four guard rows, fixed before this pass: (1) and (2) `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` AC-4 for the two new gate RelativeRecord suites, fixed by adding the baseline null mocks for every closure read seam to their outermost BeforeAll and an interception-probe row; (3) `WorktreeResolution.Manifest.Tests.ps1` "registers every on-disk worktree-resolution module", fixed by listing WorktreeRunRecordPath.psm1 in that suite's expected-path lists (entries added only); (4) `test-name-uniqueness.Tests.ps1`, fixed by renaming the two new matrix rows to "denies the relative-record case when <Case>". The file list gained `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`.

## git hash-object (before and after; identical)

```text
43e44e6b59d713ec7050e8396eb176087be5cbe4 .claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1
f09f293e5f54143325aca021b3c5c1fc7784b200 .claude/lib/worktree-resolution/WorktreeRunResolution.psm1
5f684dc811b6fdfb47af06c2ef5209dc9a1f0758 .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1
f857c11cd4b19538fb85aa13b1ac4cbe503761bd .claude/hooks/enforce-parallel-worktree-removal-gate.ps1
77b830fa47fd421f1cfc4e3999facbdb762a34e9 .claude/hooks/enforce-epic-worktree-removal-gate.ps1
52a35d364234d2c4d99624e7022db2dee7ab2cbe .claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1
c6f952f6a79fb7886bd36fe4e9786d22f67eba78 tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1
ed96ab2e0e91061759d4d56fd9ededf261481979 tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1
6d7f807b22d51d1e12b2cd2efa95d0a91d766d5a tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1
521743d85f0b7336d85eafd2d230960ddfdeb04f tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1
f34615c8b949a5f646988190773625197ad34bf5 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1
8b91b91659ebe668a875ca6e28549e21ff7c8c3f tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1
8b01733aa47dd50fe2a455d9f6b603d2c41400b4 tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
fa642a1f54efa1824a2d4103039e5bfaa83481a3 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
a7d05d3990ffe5f38f2820cc67ad7096160777ee tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
c34c2329a0a97ac2de2d60af9fb88cec3031a5e7 tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
589d376f447f7237288c44ec194db6775b93964b tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
17971c218e959574bb3730d2233ec845b1911c1d tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
49bcccb8029172ad604b352bb784c44eb4cb6308 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
58b6b0bd6a12ae891365eb3f6ab2e73675ab409a tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
8aeebf97c873c28a608a0774f2fc5eddc30be7af tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
405e3048994d7f89e71c1a3891a2367265139da8 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
02c3730fc3a8abc3714e35036d4dfe5965120e9b tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
31b7f0b767714f85ba3ad02c943658b648791eb6 tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
cebe9548334cb13f1e223c379b0ddf0c7c1417fb tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1
8f53d5195f48e3132ee034165094c5101c0afa8b tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
```
