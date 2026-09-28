# Remediation Inputs — Issue #671 (Preimplementation Gate Worktree Selector)

- Timestamp: 2026-09-17T08-40
- Feature folder: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671`
- Base branch: `origin/epic/worktree-scoped-state-resolution-integration` (merge base `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
- Head: `feature/2026-09-13-preimplementation-gate-worktree-selector-671` @ `03f4f305765e15745b9275f3a8fd42758f2c6873`
- Work mode: `full-bug` (AC source: `spec.md`)
- Remediation required: YES
- Blocking findings: 3

## Source Audit Artifacts

- `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/policy-audit.2026-09-17T08-40.md` (PA-1, PA-2, PA-3)
- `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/code-review.2026-09-17T08-40.md` (CR-1, CR-2, CR-3 Blocker; CR-4 Major; CR-5, CR-6 Minor)
- `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/feature-audit.2026-09-17T08-40.md` (AC 5, 19, 20 FAIL)
- Supporting executor evidence:
  - `evidence/qa-gates/poshqc-test-coverage.2026-09-14T01-00.md`
  - `evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md`
  - `evidence/qa-gates/toolchain-single-pass.2026-09-14T01-00.md`
  - `evidence/qa-gates/acceptance-criteria-reconciliation.2026-09-14T01-00.md`
  - `evidence/other/follow-up-candidates.2026-09-14T01-00.md`
  - `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md`

## Precondition: Spec and Plan Amendment

The current spec and plan forbid the edits required below:
- AC 11 confines helpers removals to the pre-change lines 227–236.
- The spec's deny table fixes the L3a/L3b commands.

Before execution, the planner must amend `spec.md` so that it:
1. replaces the L3a and L3b fixture commands with trigger-matching commands;
2. permits a one-line change to the `param` declaration of `Test-ExemptOrchestrationSegmentToken`, and a fail-closed guard in `Test-ExemptOrchestrationStagingCommand`, by widening AC 11's permitted-change set to exactly those edits;
3. adds the new regression rows listed below to the "Matrix — new rows" table.

These are amendments to criterion wording and fixture tables. They add no new feature scope. Record the amendment and its rationale in the spec's Risks & Mitigations section.

## Required Fixes

### RF-1 (Blocking; PA-2 / CR-1): Close the empty-token fail-open

- Files, all four copies, which must stay byte-identical:
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
  - `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
- Change:
  - Add `[AllowEmptyString()]` to the `$Token` parameter of `Test-ExemptOrchestrationSegmentToken` (current line 296).
  - Make `Test-ExemptOrchestrationStagingCommand` return `$false` on any error raised while evaluating a segment, for example `try { ... } catch { return $false }` around the per-segment loop.
- Expected behavior: `Test-ExemptOrchestrationStagingCommand` returns `False` for:
  - `git -C "" add -- docs/features/active/x/spec.md`
  - `git add "" -- src/foo.ps1`
  - `git add -- "" scripts/powershell/Sample.ps1`
  - `git add -- src/foo.ts ""`
- Decision required: whether `git commit -m "" -- docs/features/active/x/spec.md` should allow. With `[AllowEmptyString()]` alone it allows, because the empty value is consumed as the message. Record the decision in the spec and pin it with a row.
- Tests: add deny rows to both command-exemption suites:
  - `issue #671 empty token beside a non-exempt operand`: `git add "" -- src/foo.ps1`
  - `issue #671 trailing empty token after a non-exempt operand`: `git add -- src/foo.ts ""`
  - The existing `LACS L8` row must pass unchanged.
- Verification:
  - Scratchpad probe: dot-source the helpers file and call `Test-ExemptOrchestrationStagingCommand` for each row above. Expect `False` with zero error records.
  - `mcp__drm-copilot__run_poshqc_test`, then parse `artifacts/pester/pester-junit.xml`: the `LACS L8` node and the new nodes report `Passed` in both suites.

### RF-2 (Blocking; PA-1 / CR-2): Replace the L3a and L3b fixtures with trigger-matching commands

- Files:
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- Change: keep the labels `issue #671 LACS L3a - ...` and `issue #671 LACS L3b - ...` so that the `Select-String` tokens in AC 5 still match, and replace only the `Command` values. Candidate commands, to be verified before adoption:
  - L3a: `git -C C:/repo/wt && git add -- docs/features/active/x/spec.md`
  - L3b: `git -C C:/repo/wt --no-pager add -- docs/features/active/x/spec.md`
- Constraint: the existing rows must not be deleted or reversed. AC 7's additive-only rule applies to pre-existing rows only; the L3a/L3b rows were added on this branch.
- Expected behavior: the gate returns `deny` for both rows, and the rejection occurs at the L3 branch of `Test-ExemptOrchestrationSelector` (current lines 252–254).
- Verification:
  - Coverage report `artifacts/pester/powershell-coverage.xml`: helpers line for the L3 `Write-Debug` has `ci > 0`.
  - JUnit: `denies issue #671 LACS L3a ...` and `... L3b ...` report `Passed` in both suites.

### RF-3 (Blocking; PA-3 / CR-3): Restore helpers-file coverage

- Files: the same two command-exemption suites.
- Change: add a trigger-matching deny row where an accepted selector is followed by a non-`add`/`commit` subcommand, for example `issue #671 selector followed by an unmodelled subcommand`: `git -C C:/repo/wt status && git add -- docs/features/active/x/spec.md`.
- Expected behavior: `deny`, with the rejection at the subcommand check in `Test-ExemptOrchestrationSegmentToken` (current line 319).
- Verification: parse `artifacts/pester/powershell-coverage.xml`.
  - The `.claude/hooks` `enforce-orchestration-preimplementation-gate-helpers.ps1` sourcefile covers the L3 lines, the L8 lines, and the post-absorption subcommand rejection line.
  - Per-file line coverage is at or above the baseline of 94.92%.
  - Repo-wide line coverage is at or above 85%.
  - Record the numbers in a new `evidence/qa-gates/coverage-comparison.<ts>.md`.

### RF-4 (Required; AC 20): Close the PowerShell toolchain loop in a single pass

- Sequence:
  1. `mcp__drm-copilot__run_poshqc_format`
  2. `mcp__drm-copilot__run_poshqc_analyze`, with direct `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per touched path
  3. `mcp__drm-copilot__run_poshqc_test` with coverage
- Expected result: no file rewritten; 0 analyzer findings on the four helpers copies and the three test files; JUnit `failures` at or below the baseline of 2, with 0 failing nodes whose name contains `issue #671`.
- Also re-run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`, resetting `.claude/state/powershell-batch-budget.*.json` first (issue #510 pattern).
- Evidence: new timestamped files under `evidence/qa-gates/`.

### RF-5 (Required): Re-verify invariants after the edits

- Hash parity: the four helpers copies have one distinct SHA256 value, and the parity suite passes.
- Line cap: each helpers copy has at most 500 lines.
- Diff confinement: the four gate files, the four modes files, the four `hook-command-invocation.ps1` copies, and `enforce-epic-merge-gate.ps1` show an empty diff against the merge base.
- Purity literals: none of `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, `env:`, or `Import-Module` appears in any copy. Note that the fail-closed guard in RF-1 must not introduce any of them.
- Re-run the 20-row reproduction as a new pass-after capture, then compare:
  - Rows 2, 3, and 9 must be `True`.
  - Row 20 is expected to change from `True` to `False`; record this as the intended RF-1 outcome.
  - All other rows must be unchanged.

### RF-6 (Non-blocking; CR-4, CR-5): Predicate-level rows and L3 clarity

- Add a Context that calls `Test-ExemptOrchestrationSelector -Token @(...)` directly for each of L1–L8 (positive and negative), using a dot-source of the helpers file in `BeforeAll`. This must not require a new test file beyond the batch cap; if it does, defer it and record the deferral.
- Either check subcommand identity inside the predicate, or state in its comment-based help that the caller enforces it.

### RF-7 (Non-blocking; CR-6): Plan and spec bookkeeping

- Reconcile the plan checkboxes (P0-T5, P3-T7, P4-T4, P5-T10, P6-T8) with the delivered evidence.
- After RF-1 to RF-5 pass, check off spec AC 5, 19, and 20 individually, with evidence.

## Do Not Do

- Do not edit the four gate files, the four modes files, any `hook-command-invocation.ps1` copy, or `enforce-epic-merge-gate.ps1`.
- Do not add a Python leg, a new production file, an `Import-Module`, or any disk, process, network, or environment access to the helpers module.
- Do not delete, reverse, or weaken any pre-existing D4 row or allow row. Do not change the labels of the new `issue #671` rows.
- Do not assert on `Write-Debug` text.
- Do not add runsettings `exclude` entries or lower any coverage threshold.
- Do not create temporary files in tests.
- Do not check off spec criteria before their verification passes.
- Do not implement the follow-up candidates (F1 upstream closure; `SharedModuleNames` for the modes file; `PARALLEL_WORKTREE_REMOVAL_BLOCKED` misclassification). They remain out of scope.
- Respect the PowerShell batch cap: 4 production files require one scheduled batch-budget reset.

## Handoff

Route these inputs through `remediation-handoff-atomic-planner`:
1. atomic-planner authors the remediation plan, including the spec amendment above.
2. atomic-executor runs preflight.
3. atomic-executor executes the plan.
4. feature-review re-audits.

This review agent does not author the remediation plan.
