# Frozen Digests After Main Merge — Remediation Cycle 1, P2-T1 repeat of P1-T5 (Issue 1162)

Timestamp: 2026-11-14T09-02
Command: git -C <worktree> show HEAD:.claude/agents/epic-orchestrator.md | sha256sum; git -C <worktree> show HEAD:.claude/skills/epic-orchestrate/SKILL.md | sha256sum (HEAD is the merge commit of origin/main); sh SCRATCH/issue-1162-tc2.sh "" "tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1"; sh SCRATCH/issue-1162-pyt.sh tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py
EXIT_CODE: 0
Output Summary:
- `.claude/agents/epic-orchestrator.md` SHA-256 (merged bytes, #1156 plus #1162): 5561f79d2942aef31b168027564256f80bdfe501b7c19fc80c962abcece4af03.
- `.claude/skills/epic-orchestrate/SKILL.md` SHA-256 (merged bytes, #1156 plus #1162): e334237b27c2188d2aafd0dc6d4f97c6493ba3f59a0b72772d86f74830e77e80.
- Both entries of `PINNED_FROZEN_SURFACE_HASHES` hold these values. The `# RE-BASELINED by issue #1162.` paragraph states that remediation cycle 1 added the status-mapping (D7) paragraph and that the digests were recomputed after the merge that brought in #1156.
- 0010-early-dependent-starts.patch: the expectations-file hunk is `@@ -219,46 +219,55 @@`. Its `+` digest lines hold the two values above, and the #1162 re-baseline block is carried as context.
- PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS pass (5 of 5 tests in the file). test_frozen_epic_surface_matches_pinned_baseline_digest passes for both surfaces (38 of 38 in the file).
- The merge commit carries the subject token `reduction: 0010`.
