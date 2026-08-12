# P3-T12 Parallel Launch and Resume Lifecycle Evidence

## Scope

- Task: `[P3-T12]`.
- Required command order: authoritative PowerShell, Python, then TypeScript.
- No implementation or test file changed during this proof task.

## Required Command Results

1. `mcp__drm-copilot__run_poshqc_test` with the repository workspace and
   `scan_folders=["tests/scripts/codex-hooks"]`: PASS. The authoritative JUnit
   receipt at `artifacts/pester/pester-junit.xml` records 522 tests, zero
   failures, zero errors, and zero skipped tests.
2. `poetry run pytest -q tests/scripts/dev_tools -k 'parallel or epic'`: PASS,
   1,620 passed, 5 documented fixture skips, and 2,208 deselected.
3. `npm --prefix extensions/drm-copilot run test:unit -- --runInBand`: PASS,
   191/191 suites and 2,654/2,654 tests with zero snapshots.

## Acceptance Proof

- Epic public behavior remains green: the authoritative PowerShell JUnit
  contains 142 passing tests owned by seven epic contract, launcher,
  attestation, execution-gate, provenance, and wave-binding suites. These
  include the thin-adapter public parameter and shared-core compatibility
  assertions.
- Parallel launches are isolated and deterministically bounded: the same JUnit
  contains 39 passing tests across five parallel provenance, launcher,
  lifecycle, resume, and post-session suites. The lifecycle and launcher tests
  explicitly cover max concurrency 1 and greater than 1, ascending persisted
  item order, one bound worktree/branch per item, isolated `CODEX_HOME`, and no
  thread-capacity reordering.
- Invalid lifecycle state cannot emit completion: the passing PowerShell
  post-session suite rejects stale heads, non-green checks, unmerged PRs,
  residual or mismatched worktrees, non-main bases, integration state, and
  fan-in state before terminal persistence. The full Python and TypeScript
  suites also pass the closed-mode and receipt validators that reject unmerged
  items, missing receipt fields, residual worktrees, stale check heads, and
  non-success required checks.
- Interrupted resume remains live-truth authoritative and selects the first
  eligible incomplete item without duplicating launch, worktree, branch, PR,
  mutation, or drift identity.

## Repository Gates

- `.claude/` changed-file count: 0; `.claude/` diff line count: 0.
- `.codex/state` was absent before the authoritative wrapper and remains absent.
- `git diff --check`: PASS.

## Acceptance-Criteria Tracking

- The launcher/resume, per-item PR/removal, and mutation/drift lifecycle test
  conditions now have full PowerShell, Python, and TypeScript regression proof.
- Registered-hook process matrices, portable Bash parity, publisher closure,
  coverage, and final QA criteria remain assigned to later plan phases.
