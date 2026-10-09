# P5-T1 BLOCKED: EDIT-SET exceeds the ten group slots (PI-6)

Timestamp: 2026-10-09T03-35
Command: Route C derivation of the EDIT-SET (see evidence/other/edit-set.2026-10-09T03-34.md) and a read-only analysis of that set via the Phase 1 through Phase 4 helpers
EXIT_CODE: 1
Output Summary:
BLOCKED at [P5-T1]: EDIT-GROUP-COUNT is 27, and PI-6 provides ten group slots (P5-T2 through P5-T11), so the plan requires a stop and a plan revision. The edit-set artifact was written with all required fields and every path exists in the tree. [P5-T1] is left unchecked.

Counts (derived at run time from the tree at integration tip 7eef4739, which includes #736, #732, #850 and also #824, #565, #787):
- Suite population: 177 existing suites (125 in claude-hooks, 52 in codex-hooks) plus the three Phase 2 through 4 suites that the guard also discovers, 180 in total at this point.
- Source (a), AC-4 per-suite findings in the guard fail-before run: 104 suites.
- Source (b), AC-6 per-suite probe-presence findings: 18 suites (a subset of source (a)).
- Source (c), local-state differential DIFFERENT: 1 suite (tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1, Failed=1 on both sides because of the local item checkpoint, see DEV-2).
- Source (d), legacy guard after hardening: 0 suites.
- EDIT-SET-COUNT: 105 (76 in tests/scripts/claude-hooks, 29 in tests/scripts/codex-hooks). EDIT-GROUP-COUNT: 27. Capacity of P5-T2 through P5-T11 is 40 suites.
- 73 of the 177 existing suites load a closure with no seam and need no edit.
- Requirements per flagged suite: average 5.7, maximum 15; 27 suites need eight or more seams mocked. 13 flagged suites are at 450 lines or more (for example enforce-epic-worktree-removal-gate.Tests.ps1 at 498, enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 at 499, codex enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 at 496), so they would need the helper form of EP-2.

Cause of the drift. The census predicate of Decision 3 (a read primitive in a function whose name matches Checkpoint, or whose body or file holds an artifacts/ literal) plus Decision 2 (closure-wide over-inclusion) and the union closure of P1-T2 (a hooks/<name>.ps1 literal resolves against both .claude/hooks and .codex/hooks) selects far more seams than the planning-time estimate assumed. Suites whose closure holds the item-resolution module are flagged for Get-WorktreeItemCheckpointText and Get-WorktreeItemLiveRoot (86 suites each), the run-resolution seam (81 suites), the epic-scope seam (40 suites by module, 23 by Codex script scope), and 24 hook-local content seams (for example Get-CheckpointContent in 45 suites, Get-OrchestratorStateCheckpoint in 21, Get-PrAuthorReceiptContent and Get-PrAuthorCheckpointContent in 14 each). The 9 suites that #709 guarded comply only for the epic-scope and worktree-run pairs, so they are flagged as well.

Facts for the revision (no plan text was edited by the executor):
- Phases 0 through 4 are complete and pushed (commit 0edc4ee9 on bug/hook-test-isolation-remaining-gaps-exec-737). The guard, the predicate hardening, the helpers, and the probe are in place and verified.
- Remaining AC-4 failures: 104 per-suite rows. Remaining AC-6 failures: 18 per-suite rows. No other row in the new suites fails.
- A revision can change the slot count and group size, or narrow the census predicate or the union closure, or both. The executor makes no choice among these.
