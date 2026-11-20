# Claude Preimplementation-Gate Suites (Issue #1026, P2-T5)

Timestamp: 2026-11-03T13-22
Command: sh SCRATCH/issue-1026-ps.sh SCRATCH/issue-1026-pester.txt @SCRATCH/issue-1026-list-p2.txt (Invoke-Pester over the 27 suites listed below in one process, JUnit to artifacts/pester/pester-junit.xml, coverage disabled)
EXIT_CODE: 0
Output Summary: JUnit testcases 1454, passed 1454, failed 0, skipped 0; no failed container. The new suite enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1 contributes 39 testcases. All 17 AC1-AC6 test names appear in the JUnit testcase names (SCRATCH/issue-1026-namecheck.txt: expected 17, missing 0). The REPORT lines printed by the Discovery guard are its informational census of process-spawning suites and do not fail it.

Suites run:

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` (new)
- every existing `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate*.Tests.ps1` suite (23 files: `-absolute-paths`, `-classifier`, `-helpers.ChainEscape`, `-helpers.OperandNormalization`, `-helpers.Parity`, `-mode-resolution.TargetFolder`, `-mode-resolution`, `-targets.Parity`, `-targets.PathNotLocal`, `-targets`, `.AttributionTrailer`, `.C1bCoverage`, `.CommandExemption`, `.EpicScope`, `.EpicScopeHelperParity`, `.EpicScopeTargets`, `.OperandBypass`, `.OperandResolution`, `.Parity`, `.TargetWorktree`, the base `.Tests.ps1`, `.TriggerScoping`, `.WorktreeResolution`)
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`

AC1-AC6 names confirmed (each 1 hit):

- `allows a Write of the session-root cleanup manifest with valid tool and schema_version and no checkpoint`
- `denies a manifest Write whose tool is not cleanup-merged-worktrees`
- `denies a manifest Write whose schema_version is not 1`
- `denies a manifest Write at a path other than the session-root spelling`
- `denies an Edit of the cleanup manifest without a checkpoint`
- `allows git -C <consolidation root> add of docs/ and .claude/agent-memory/ operands`
- `denies git add in the consolidation worktree when any operand is outside the allowlist`
- `allows git -C <consolidation root> commit -F when the staged index is non-empty and entirely allowlisted`
- `denies the commit when the staged index holds a non-allowlisted path`
- `denies the commit when the staged index is empty or the staged-index seam fails`
- `denies the commit with -a, --amend, --pathspec-from-file, or a pathspec operand`
- `identifies the consolidation worktree by porcelain branch documentationandmemories and not by path`
- `allows a Write under the temporary root in its long-name spelling outside every worktree and the session root`
- `allows a Write under the temporary root in its 8.3 short-name spelling`
- `denies a scratch-named Write inside a registered worktree, inside the session root, or at a non-local path`
- `allows the pr-author receipt Write of artifacts/pr_body_<digits>.receipt.json beneath the consolidation worktree`
- `denies the same receipt path beneath a non-consolidation worktree`

Observation recorded for the plan: Pester 5.9.0 expands `<name>` in every `It` name, whether or not the block carries `-ForEach` data, so an unescaped `<consolidation root>` failed to parse and `<digits>` rendered empty. The three AC names that contain angle brackets are written with the backtick escape that `enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` already uses (`` `<wt`> ``); the rendered JUnit names are the AC text verbatim.

Discovery-guard compliance of the new suite (Get-EpicStateSuiteCompliance): 0 findings; probe seams Get-EpicScopeCheckpointText, Get-WorktreeItemCheckpointText, Get-WorktreeItemLiveRoot, Get-WorktreeRunCheckpointText, all exercised by its `baseline mock interception probe` row. Line counts: gate 473 (471 + 2), gate sibling 421, new suite 441, baseline helper 200.
