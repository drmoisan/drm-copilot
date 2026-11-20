# Preflight Fixes: Stage I Plan, Version 0.3 (Confirming Round)

Timestamp: 2026-11-08T17-38
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T00-56.md

Each fix edits task text or the plan preamble only. No task was added, removed, reordered, checked, or unchecked.

## Fixes

1. `## Execution Terms`, Commits bullet. Defect class: commit mechanics left implicit. The bullet required only the [P2-T3] commit to be pathspec-limited, while the reduction stays staged until [P3-T5]; a plain commit of gate evidence or a plan check-off in that window would sweep the staged reduction paths into a non-reduction commit. Added that every commit before [P3-T5] is pathspec-limited to its own paths, and that a later repair to either [P2-T3] file is committed the same way with no `reduction:` token.
2. [P2-T3], Change bullet. Defect class: stale description against the Design. Entry `0010` `## Stored Patch` (written in [P2-T1], uncommitted) states that the chain skips the bundle copies as derived paths; after [P2-T3] the chain sets each created bundle copy absent. [P2-T1] requires that section to carry the Design's reasoning, which now includes the chain rule for derived created paths. Added that this sentence is brought in line with the rule, that the entry lies outside the patch so the patch rule does not apply, and that it stays uncommitted until [P3-T5].
3. [P2-T3], chain check (c). Defect class: route detail. A copy of `scripts/dev-tools/ProcessReductionChain.psm1` alone under `SCRATCH` fails to import, because the module imports `ProcessReductionLedger.psm1` from `$PSScriptRoot` (observed in a preflight probe). Added that the ledger module is copied beside the pre-fix copy.
4. [P2-T3], Acceptance. Defect class: acceptance wording that did not match the working-tree state it protects. `git status --porcelain` shows the patch paths staged, the README row modified and unstaged, and the entry and patch untracked; the text required every [P1-T1] to [P2-T2] path to be listed as staged. Reworded to "as before the commit" with those three states named; the assertion (nothing committed, state unchanged) is unchanged. Also stated that `git show --name-only HEAD` is read right after the fix commit, before the evidence commit moves `HEAD`.
5. [P3-T1], first bullet. Defect class: file-set wording. "Every changed or created file of the language" now names the two [P2-T3] files explicitly, so the gate-restart pass covers the file whose change voided the earlier pass.

## Preflight Probe (not a test run)

A PowerShell 7 script stored under `SCRATCH` ran the chain functions in two separate processes, once with the `HEAD` module and once with a `SCRATCH` copy carrying the [P2-T3] change, over `Read-ProcessReductionChainInput` of the item worktree:

- Stored patches 0001, 0006, 0008, and 0009 hold 2, 0, 2, and 1 create hunks; none lies on a derived or mapped path. Patch 0010 holds 12 create hunks, two of them on derived bundle copies.
- Both modules: full chain over 10 entries and every `-StopBefore` sub-chain `IsValid` True with 0 errors.
- `FinalText` differs only for the two created bundle copies (present before the change, absent after).
- `ProcessReductionChain.psm1` line coverage in the merged `artifacts/pester/powershell-coverage.xml` written by the Phase 0 baseline run: 238 of 238; the file predates the failed first [P3-T2] attempt, which wrote no merged file.
