# P3-T10 Parallel Resume Live-Truth Evidence

## Scope

- Task: `[P3-T10]`.
- PowerShell runtime: `.codex/scripts/resume-parallel-child.ps1`.
- Python authority: `_parallel_orchestrator_state_resume_truth.py`, composed into
  `validate_parallel_orchestrator_state.py` through a presence-gated call.
- TypeScript authority: `parallel-orchestrator-state-resume-truth.ts`, composed into
  `parallel-orchestrator-state-core.ts` through the equivalent presence-gated call.

## Acceptance Results

- Resume selects the first incomplete item in persisted cohort, batch, and item-key order.
- Duplicate launch, worktree, branch, or PR identity rejects with
  `PARALLEL_RESUME_IDENTITY_DUPLICATE`; withdrawn items do not reserve identity.
- Live origin/main, repository, worktree, branch, current head, one main-targeted PR, exact PR and
  checks head, required-check conclusion, launch hashes, mutation sequence, drift resolution,
  routing/model bindings, child-status identity, and process state are reconciled before resume.
- Integration and fan-in state, missing truth, stale or mismatched authority, unresolved drift,
  duplicate identity, a still-running process, or an unauthorized relaunch fails closed with a
  stable `PARALLEL_RESUME_*` reason code.
- Cached child-status state remains non-authoritative; live process truth determines whether a
  relaunch is permitted.
- `Get-CodexParallelChildResumeContext` invokes an internal live-truth provider and forwards the
  resulting record into the same validator used by focused tests. Its production default reuses
  the existing GitHub PR/check wrappers and live Git/process seams. The public script parameters
  remain exactly `ReceiptPath`, `Prompt`, and `LastMessagePath`.
- Valid inputs and all rejected inputs remain unmodified.

## PowerShell Toolchain

- Bundled PoshQC format over `.codex/scripts` and `tests/scripts/codex-hooks`: PASS.
- Bundled PoshQC analyze over the same scope: PASS, zero findings.
- Focused live-truth suite: PASS, 6/6 tests, including the actual context/provider path.
- The first terminal wrapper run identified only the expected state-purity assertion because the
  completed current-batch receipts remained under `.codex/state`.
- After deleting only the verified ephemeral receipts and the resulting empty directory, the
  final authoritative `run_poshqc_test` command passed: 517/517 tests, zero failures, errors, or
  skips.

## Python Toolchain

- `poetry run black --check` over the helper, public validator, and focused test: PASS.
- `poetry run ruff check` over the same scope: PASS.
- `poetry run pyright` over the same scope: PASS, 0 errors and 0 warnings.
- Focused resume plus existing core/completion regressions: PASS, 174/174 tests.
- Full parallel/topology/deployment selection: PASS, 1,518 passed, 5 documented fixture skips,
  and 2,308 deselected.

## TypeScript Toolchain

- `npx prettier --check` over the helper, public core, and focused test: PASS.
- `npx eslint` over the same scope: PASS.
- `npx tsc --noEmit`: PASS.
- Focused resume suite: PASS, 17/17 tests.
- Existing core, completion, completion-receipt, and artifact-dispatch regressions: PASS,
  141/141 tests across four suites.
- Full `npx jest --runInBand`: PASS, 191/191 suites and 2,652/2,652 tests.

## Cross-Runtime Parity

- PowerShell, Python, and TypeScript each expose the same 15 unique
  `PARALLEL_RESUME_*` reason codes; normalized pairwise deltas are zero.
- Each runtime covers the same valid, missing-truth, fan-in, deterministic-order,
  duplicate-identity, Git, worktree, GitHub, launch, mutation, drift, routing, child-status,
  process-running, and relaunch-authorization decisions.

## File-Size and Repository Gates

- PowerShell runtime: 472 lines.
- PowerShell focused test: 278 lines.
- Python helper, public validator, and focused test: 285, 368, and 243 lines.
- TypeScript helper, public core, and focused test: 313, 346, and 204 lines.
- Ninety changed reusable production/test files were scanned; none exceeds 500 lines.
- `.claude/` changed-file count: 0.
- `.codex/state` is absent after verified ephemeral-receipt cleanup.
- `git diff --check`: PASS.

## Acceptance-Criteria Tracking

- Checked the matching authoritative-resume criterion in `issue.md`.
- Checked the matching authoritative-resume criterion in `user-story.md`.
- Broader lifecycle, registered-hook, publisher, coverage, and final current-head criteria remain
  unchecked for their later plan tasks.
