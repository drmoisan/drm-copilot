# Frozen Digests and 0010 Ledger Refresh — Remediation Cycle 1, P1-T5 (Issue 1162)

Timestamp: 2026-11-14T08-26
Command: sha256sum .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md (LF bytes, identical to the bytes committed with this task); sh SCRATCH/issue-1162-tc2.sh "" "tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1"; sh SCRATCH/issue-1162-pyt.sh tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py
EXIT_CODE: 0
Output Summary:
- `.claude/agents/epic-orchestrator.md` SHA-256: 8ba9e581ffacc89e049eb0f5c20731e7be1ffbf7473d7787c674636dd3ac2683 (previous pin 9ea1c87caf5781acb15942e6e3eaff5c0dcf9858550826f6a6d6ad081a5dc329).
- `.claude/skills/epic-orchestrate/SKILL.md` SHA-256: 7eb85f0bf7abf3942872708a34c438a1e05ca2d337eedb8a123dcf9a0525afbe (previous pin eefac39e879a755228ae92428c5930951f18462bef733aaa0b7ef36f5eeb6203).
- `PINNED_FROZEN_SURFACE_HASHES` in tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py now holds both new digests. The `# RE-BASELINED by issue #1162.` paragraph gained a sentence stating that remediation cycle 1 added the status-mapping (D7) paragraph to both surfaces and that both digests moved again. That sentence adds 2 lines.
- 0010-early-dependent-starts.patch: before the refresh, the chain test reported only the expectations-file hunk as not applying ("Current text of the hunk at +249 ... was not found"). That hunk's header moved from `+249,11` to `+251,11`, and its two `+` digest lines now hold the new digests. No other hunk failed: the status-mapping paragraphs lie outside every recorded hunk and only shift positions. The patch diff is 3 lines changed.
- Before the refresh, an attempt to use the scratch regeneration route from the earlier execution (SCRATCH/issue-1162-ledger-regen.sh) exited 3 without writing anything. That route reverses 0010 against origin/main, which no longer applies now that the patch carries #1162 content. Nothing was written to the tree by that attempt.
- Task check: ProcessReductionChain.Ledger.Tests.ps1 passed=5 failed=0 (PRC-LEDGER-CHAIN-HOLDS and PRC-LEDGER-SUBCHAIN-HOLDS pass). test_parallel_orchestrator_surface_contracts.py: 38 passed, including test_frozen_epic_surface_matches_pinned_baseline_digest for both surfaces.
- The commit for this task carries the subject token `reduction: 0010`.
