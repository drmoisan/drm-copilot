# AC Check-Off — Seams and determinism (4 criteria; spec.md and user-story.md)

Timestamp: 2026-09-17T08:47:34-04:00 (file write time)
Command: per-criterion review against the named evidence, then '- [ ] ' -> '- [x] ' for the lines between '### Seams and determinism' and the next heading in spec.md and user-story.md (criterion text unchanged)
EXIT_CODE: 0
Output Summary: 4 of 4 criteria verified and checked off in both files.

| # | Criterion (abridged) | Verified by |
| --- | --- | --- |
| 1 | Only filesystem contact is the three named seams, each mockable with -ModuleName | worktree-resolution-suite: the three "seam default bodies" tests ([P1-T6]) exercise the real bodies; every other test mocks the seams with `-ModuleName 'WorktreeResolution'`. A search of both modules for Test-Path, Get-Content, Get-ChildItem, Get-Item, Set-Content, Out-File, New-Item, Remove-Item, and System.IO found matches only at WorktreeResolution.psm1 lines 71, 74 (existence seam), 94 (content seam), and 111 (directory seam). WorktreeTargetResolution.psm1 reaches the filesystem only through File 1 functions (its only other external call is Get-Location for the default session root, which reads the process location, not a file) |
| 2 | No function starts a subprocess, invokes git, reads a clock, uses the network, or reads an environment variable | evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md: the fourteen forbidden-construct searches return 0 in both modules (re-run after the final repair: 0) |
| 3 | No test creates/writes/reads a temporary file, reads a clock, spawns a process, or uses the network; the suites' help states it | .DESCRIPTION of WorktreeResolution.Tests.ps1 and WorktreeTargetResolution.Tests.ps1: "No test creates, writes, or reads a temporary file, reads a wall clock, spawns a process, or touches the network."; WorktreeResolution.Manifest.Tests.ps1: "it creates no temporary file, reads no wall clock, touches no network, and invokes no external process." The suites read tracked repository files only (seam default bodies, manifest, module hashes) and model every topology in memory |
| 4 | Full matrix (cwd x path form x target) is a table-driven suite with passing rows kept as regression guards | worktree-target-resolution-suite: twelve "required matrix row" tests from one `-ForEach` table ([P2-T6]), covering 2 cwd values x 2 path forms x 3 targets; the four own-target rows are the cwd-equals-target regression guards |

Evidence files: evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md,
evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md,
evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md.
