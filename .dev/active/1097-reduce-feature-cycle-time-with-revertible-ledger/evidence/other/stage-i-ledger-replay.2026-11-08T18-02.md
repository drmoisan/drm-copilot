# Stage I Pre-Commit Ledger Replay and Reduction Commit (P3-T5)

Timestamp: 2026-11-08T18-02
Command: sh SCRATCH/issue-1097-i-reduce.sh (one helper run: reads the 40 paths of entry 0010 ## Files Changed, stages the 37 paths outside the ledger folder, regenerates patches/0010-early-dependent-starts.patch as git diff --cached --binary --no-renames HEAD over them, runs git apply -R --check, runs SCRATCH/issue-1097-i-replay.ps1 importing scripts/dev-tools/ProcessReductionLedger.psm1 and scripts/dev-tools/ProcessReductionChain.psm1, and only on exit 0 commits the 40 paths with git commit -F and pushes)
EXIT_CODE: 0
Output Summary:
  Stored patch: 37 sections; git apply -R --check exit 0.
  Ledger: Test-ProcessReductionLedger IsValid True, 0 errors, 10 rows, 10 entries. Test-ProcessReductionEntry on 0010-early-dependent-starts.md: IsValid True, PatchPath patches/0010-early-dependent-starts.patch.
  Full chain (entries 0001 to 0010): IsValid True, 0 errors; 17 created paths, 0 present at the end (the PRC-LEDGER-END-STATE-RECORDED condition).
  Every -StopBefore sub-chain (0001 to 0010, 10 runs): IsValid True, 0 errors each.
  -StopBefore 0009-less-evidence.md replay of patch 0010: 16 source paths equal to their HEAD text after line-ending normalization; 12 created files absent, including both created bundle copies of epic-wave-barrier-early-start.ps1; 9 modified bundle copies left to revert step 2 as derived paths; both frozen files hash to the P0-T5 digests (.claude/agents/epic-orchestrator.md e0691d2a..., .claude/skills/epic-orchestrate/SKILL.md 65f34506...).
  Commit: 5988fc822 "feat(1097): early dependent starts for opted-in epic edges (reduction: 0010)", 40 files; git show --name-only equals the ## Files Changed set (entry, patch, README, and parallel_orchestrator_surface_expectations.py included); git status --porcelain empty afterwards; no other commit since the merge base of origin/main and HEAD carries a reduction: token. Pushed.
  First attempt (2026-11-08T18-01), not committed: the replay script lacked the UTF-8 [Console]::OutputEncoding line of the P2-T2 script, so git show HEAD text of the three source files holding non-ASCII text (.claude/agents/epic-orchestrator.md, .claude/skills/epic-orchestrate/SKILL.md, .claude/skills/epic-run/SKILL.md) was mis-decoded and compared unequal while the frozen digests already matched; the helper stopped before the commit as designed. The line was restored and the helper re-run; no tree content changed between the runs.
