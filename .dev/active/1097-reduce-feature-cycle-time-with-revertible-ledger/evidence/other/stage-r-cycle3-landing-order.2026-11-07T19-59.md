# Stage R Cycle 3 Landing Order (F1, PR #1112)

Timestamp: 2026-11-07T19-59
Command: git show of origin/main for docs/engineering/process-reductions/0001-parallel-only-test-gates.md and .claude/skills/execution-environment/SKILL.md; reads of patches/0001-parallel-only-test-gates.patch, patches/0006-test-suite-baseline-restored.patch, and entries 0002 to 0006; then the sh-launched PowerShell 7 script SCRATCH/c3/issue-1097-c3-chain.ps1 (parse check, Read-ProcessReductionChainInput, Invoke-ProcessReductionChain, -StopBefore for each stored-patch entry, Get-ProcessReductionLanding of 0001, Test-ProcessReductionLedger) on the pre-merge ledger
EXIT_CODE: 0
Output Summary:
  Pre-merge chain: 6 entries, 2 patches, 285 paths; IsValid True, 0 errors. -StopBefore 0001-parallel-only-test-gates.md and -StopBefore 0006-test-suite-baseline-restored.md: IsValid True, 0 errors each. Get-ProcessReductionLanding of 0001 before the merge: first (4 blocks). Test-ProcessReductionLedger: valid, 0 errors. Parse errors: 0 in each of the three PowerShell files.
  Overlap analysis: no #1096 region overlaps a target-file region of 0002 to 0006, and the #1096 brief block overlaps 0001's own stored patch. Details below.

## Overlap Analysis

- #1096 paths in 0002 to 0006: of the thirteen #1096 paths, none occurs in an entry `0002` to `0006` or in `patches/0006-test-suite-baseline-restored.patch` (fixed-string search of each path, 0 files each). The only #1096 path that those entries list is `.claude/skills/execution-environment/SKILL.md`.
- Brief, #1096 block: on origin/main the block covers the `## Test Runtime` bullets from `Second, build an expensive immutable fixture` to `A candidate fix can be measured`.
- Brief, 0006: the 0006 patch hunk in the brief changes the per-file figures bullet of `## Coverage and File-Size Gates`, and its last context line is the `## Test Runtime` heading, four bullets above the #1096 block. Its other brief hunk is in `## Contract Tests That Pin Mirrored Files`.
- Brief, 0002 and 0003: their blocks sit in `## Command-Text Restrictions`, `## Hook Execution Context`, `## MCP Surfaces Run the Installed Extension`, `## CI Shape and Required Checks`, and `## Contract Tests That Pin Mirrored Files`, outside `## Test Runtime`.
- Brief, 0001 patch: the `@@ -145,17 +148,19 @@` hunk adds the pytest bullet ending `and of the parallel VS Code tasks, never in addopts`, which the #1096 landing rewrote to add the `fix_all` step and the atomic executor commands. Newest-first by number cannot order two landings of one entry, so the order rule changes: within 0001's turn the `### Later Landing: #1096` blocks are reverted before the patch.
- Leak-scan bullets on origin/main with no block: after the `Invoke-Pester` bullet of `## PowerShell Route and PoshQC MCP Limits` (inside the `@@ -39,7 +39,8 @@` hunk), after `Files in one shard share a process` in `## CI-Only Failure Classes` (inside the `@@ -88,7 +89,7 @@` hunk), and at the end of `## Test Isolation Checks` (the `@@ -145,17 +148,19 @@` hunk, which has no trailing context and anchors at the end of the file).
- 0001 entry edits by #1096 inside 0006 hunks: `## Revert Steps` step 1 (0006 hunk 1) and the first `## Revert Signals` bullet (0006 hunk 2).

## Change

- `scripts/dev-tools/ProcessReductionChain.psm1`: new exported `Get-ProcessReductionLanding`; private `Merge-ProcessReductionTouch`; `Invoke-ProcessReductionChain` reverts each entry's later landings first, last heading first, with errors prefixed `<entry> (later landing <label>)`, then the first landing, and takes `-StopBefore`.
- `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1`: new `Describe 'Later landings'` with PRC-LANDING-SPLITS-PRIOR-TEXT, PRC-LANDING-EMPTY-THROWS, PRC-CHAIN-LATER-LANDING-OVERLAPS-OWN-PATCH, PRC-CHAIN-LATER-LANDINGS-NEWEST-FIRST, PRC-CHAIN-LATER-LANDING-ON-BLOCK-ENTRY, PRC-CHAIN-LATER-LANDING-OVER-HIGHER-ENTRY-FAILS, and PRC-CHAIN-STOP-BEFORE.
- `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1`: PRC-README-REVERT-ORDER-STATED also asserts `Later Landing`; new PRC-LEDGER-SUBCHAIN-HOLDS.
- `docs/engineering/process-reductions/README.md`: `## Entry Format` states the `### Later Landing: #N` heading and the patch check after the entry's later landings; `## Revert Order` states the later-landing order rule.
