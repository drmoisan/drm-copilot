# P3-T6 parallel child launch adapter evidence

Task: `[P3-T6] Create the parallel launch-contract, bounded-batch launch, and resume adapters.`

## Delivered seams

- `.codex/scripts/parallel-child-launch-contract.ps1` — 233 physical lines.
- `.codex/scripts/launch-parallel-child-batch.ps1` — 449 physical lines.
- `.codex/scripts/resume-parallel-child.ps1` — 260 physical lines.
- `tests/scripts/codex-hooks/parallel-child-worktree-launcher.Tests.ps1` — 281 physical lines.
- Every reusable production and test file remains within the 500-line limit.

The contract adapter requires the parallel surface, `main` as both base and PR target,
the sealed `origin/main` commit, distinct item/worktree/branch bindings, and exact launch
identity fields. It rejects integration and fan-in state.

The batch adapter uses the shared runtime and persistence cores for a repository-bound
external `codex exec` process, isolated `CODEX_HOME`, semantic batch locking, atomic
launch/terminal status transitions, and exact exit/stdout/stderr capture. It fills no
more than the effective manifest `max_concurrency` and consumes the persisted cohort,
batch, and ascending item-key queue without using available thread capacity to reorder
work. Parallel process environments remove inherited `CODEX_EPIC_*` state.

The resume adapter selects the first incomplete item by persisted cohort, batch, and
item order; verifies the sealed item/worktree/branch/spec/checkpoint/process/status
identity; rejects fan-in/integration state; and delegates live reconciliation to the
shared resume core without duplicating a worktree, branch, PR, mutation, or drift event.

## Scheduler proof

The focused mocked-process case observed start order `101, 202, 303`, maximum active
children `2`, three start calls, and three completion calls. Static composition
assertions verify `Start-CodexChildProcessCore`, `Complete-CodexChildProcessCore`,
`Get-CodexChildAvailableLaunchCount`, `Write-CodexParallelChildStatus`, and the
`Start-CodexParallelChildBatch` invocation from `Invoke-CodexParallelChildBatch`.

## Clean quality-gate pass

- PoshQC format: pass for `.codex/scripts` and `tests/scripts/codex-hooks`.
- PoshQC analyze: pass with zero findings for the same scan set.
- Focused parallel launcher Pester: 7 passed, 0 failed, 0 skipped.
- Epic compatibility Pester: 142 passed, 0 failed, 0 skipped across the seven epic
  contract, launcher, hardening, provenance, execution, attestation, and runtime suites.
- Identical bundled PoshQC test entrypoint: 504 passed, 0 failed, 0 skipped; focused
  coverage processing reported 25.91% across 5,777 commands in 52 files with a 0%
  task-local threshold. Repository coverage gates remain assigned to final QA.
- `git diff --check`: exit 0.
- `.claude` diff: zero.
- `.codex/state`: absent after removal of the verified ephemeral batch-budget receipt.

The first folder-level wrapper run exposed two test-order/state issues: the live
batch-budget receipt violated the state-purity assertion, and inherited
`CODEX_EPIC_CHILD_DELEGATION_ID` crossed into the parallel process environment. The
receipt was removed after the final code/test edit, all inherited `CODEX_EPIC_*` keys
are now removed from parallel start info, and the complete gate was restarted from
formatting before the clean results above were recorded.

## Root/bundle epic compatibility parity

- `epic-child-launch-contract.ps1`:
  `91E43A76031A0B4B526788EA58FE0FF37183BAE25542751D3AAA462CBE8DAAB7`
  for both root and tracked bundle mirror.
- `launch-epic-child-wave.ps1`:
  `00EDE63BA41A642D82BC0B647C7D1E47DCDEDC9266DCB8588E58440F3688A93A`
  for both root and tracked bundle mirror.
- `resume-epic-child.ps1`:
  `FFDAC48113E1912369775CA14E3A90311CDF522F8D7C3810096E9ECF7929DCA2`
  for both root and tracked bundle mirror.
