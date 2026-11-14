# Final Pester Gate (cycle 4, [P3-T2])

Timestamp: 2026-11-14T03-08
Command: sh SCRATCH/issue-1160-r4-gate.sh c4p3 (imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root on the worktree, with coverage); counts read from artifacts/pester/pester-junit.xml and coverage from artifacts/pester/powershell-coverage.xml through SCRATCH/issue-1160-r4-summary.sh
EXIT_CODE: 0
Output Summary: one parallel run, 2026-11-14T02-53 to 03-08, 8 shards, wall-clock 878.84 s, exit 0; merged JUnit written 2026-11-14T03-08. 23685 tests, 23675 passed, 0 failures, 0 errors, 10 disabled. Repo-wide line coverage 95.90% (39505/41192); `.claude/hooks` and `.codex/hooks` commands copies each 99.00% (199/201).

## Named confirmations

| Group | Tests in the run | Failed |
|---|---|---|
| Existing-denial rows ED-01 to ED-120 (`classifies existing-denial row` and `denies existing-denial row ... with the generic deny text`, Claude and Codex runners) | 480 | 0 |
| False-positive rows FP-01 to FP-17 (both runners) | 68 | 0 |
| Non-goal rows NG-01 to NG-09 (both runners) | 18 | 0 |
| `subcommand position (decision D19)` cases, Claude and Codex copies (`confirms a host subcommand word that is a global option value (decision D19)`, `confirms a global option before a host subcommand (decision D19)`, `clears a host subcommand directly after the command word (decision D19)`, `clears a host subcommand directly after a transparent wrapper (decision D19)`) | 8 | 0 |
| Decision D16 cases | 40 | 0 |
