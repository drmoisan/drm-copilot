# Fail-Before — Decision D17 Rows and Cases (cycle 3, [P1-T4])

Timestamp: 2026-11-14T00-57
Command: sh SCRATCH/issue-1160-r4-gate.sh c3p1 (one Invoke-PoshQCParallelTest run on the branch-current scripts/powershell/PoshQC/PoshQC.psd1, unfixed commands sibling); failures read from the shard JUnit files under artifacts/pester/parallel/shard-<i>/ by sh SCRATCH/issue-1160-r4-shards.sh
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 8 workers, wall clock 713.45 s, run 2026-11-14T00-45 to 2026-11-14T00-57, PARALLEL_EXIT=1 (shards 2, 7, and 8 non-zero; no merged artifact written, as designed for a failing run). Shard totals: 23215 tests, 256 failures, 0 errors, 10 skipped. The 256 failures are exactly the expected tests of [P1-T2] and [P1-T3]; no other test failed.

## Expected failures, by name

- `classifies existing-denial row ED-<n>` and `denies existing-denial row ED-<n> with the generic deny text`, for each of ED-51 to ED-96, in `enforce-orchestration-preimplementation-gate.ps1 classification corpus (issue #1160)` (Claude runner) and `Codex enforce-orchestration-preimplementation-gate classification corpus (issue #1160)` (Codex runner): 46 x 2 x 2 = 184.
- Every case of `unmodelled constructs keep the hit classified (decision D17)` in `enforce-orchestration-preimplementation-gate-commands.ps1 modelled-command rule (decision D17, issue #1160)`, on the `Claude copy of the sibling` and `Codex copy of the sibling` Contexts: 36 x 2 = 72. The 36 names are `confirms ED-51 (subshell)`, `confirms ED-52 (brace group)`, `confirms ED-56 (input process substitution)`, `confirms ED-61 (preceding consumer)`, `confirms ED-63 (output process substitution)`, `confirms ED-67 (here-string)` to `confirms ED-85 (shell-state builtin)` (19), and the twelve named cases `keeps a mention-host consumer through a process substitution classified`, `keeps a group inside a wrapper payload classified`, `keeps a PowerShell expression carrying the word outside a host scriptblock classified`, `keeps a PowerShell stage before the carrying record classified`, `keeps PowerShell -CommandWithArgs arguments after the payload classified`, `keeps an ANSI-C quoted pipe in a wrapper payload classified`, `keeps a $_ expansion after && classified`, `keeps a $_ expansion inside a wrapper payload classified`, `confirms an abbreviated sort --compress-program option`, `keeps a PowerShell assignment statement classified`, `keeps a PowerShell & operator classified`, and `keeps a command substitution inside double quotes classified`.

## Passing as required

- ED-01 to ED-50, FP-01 to FP-17, and NG-01 to NG-09 in both runners (no failure outside the 46 new rows).
- The three guards of `modelled constructs keep a mention unclassified (decision D17)` on both surfaces (0 failures).
- No new row or case passed on the unfixed sibling.
