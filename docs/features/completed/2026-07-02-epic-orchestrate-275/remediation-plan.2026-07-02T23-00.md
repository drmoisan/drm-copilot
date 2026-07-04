# epic-orchestrate (#275) — Remediation Plan

- **Issue:** #275
- **Remediation cycle entry timestamp:** 2026-07-02T23-00
- **Source:** `docs/features/active/2026-07-02-epic-orchestrate-275/remediation-inputs.2026-07-02T23-00.md`
- **Head commit under review:** `25a4a3644c9767d27a79d72c2033d68c8561eaf2` (branch `drm-copilot-wt-2026-07-02-19-03`)
- **Base branch:** `main` (merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
- **Status:** Draft

## Required References

- Standing instructions: [`CLAUDE.md`](../../../../CLAUDE.md)
- General Code Change Policy: [`.claude/rules/general-code-change.md`](../../../../.claude/rules/general-code-change.md)
- General Unit Test Policy: [`.claude/rules/general-unit-test.md`](../../../../.claude/rules/general-unit-test.md)
- Python: [`.claude/rules/python.md`](../../../../.claude/rules/python.md), [`.claude/rules/python-suppressions.md`](../../../../.claude/rules/python-suppressions.md)
- PowerShell: [`.claude/rules/powershell.md`](../../../../.claude/rules/powershell.md)
- TypeScript: [`.claude/rules/typescript.md`](../../../../.claude/rules/typescript.md), [`.claude/rules/typescript-suppressions.md`](../../../../.claude/rules/typescript-suppressions.md)
- Quality tiers / coverage floor: [`.claude/rules/quality-tiers.md`](../../../../.claude/rules/quality-tiers.md)
- Code commenting: [`.claude/rules/self-explanatory-code-commenting.md`](../../../../.claude/rules/self-explanatory-code-commenting.md)
- Remediation inputs: [`remediation-inputs.2026-07-02T23-00.md`](remediation-inputs.2026-07-02T23-00.md)
- Source audits: [`policy-audit.2026-07-02T23-00.md`](policy-audit.2026-07-02T23-00.md), [`code-review.2026-07-02T23-00.md`](code-review.2026-07-02T23-00.md), [`feature-audit.2026-07-02T23-00.md`](feature-audit.2026-07-02T23-00.md)
- Spec: [`spec.md`](spec.md); User Story: [`user-story.md`](user-story.md)

**All work must comply with these policies; do not duplicate their content here.**

Evidence for every baseline/QA/coverage artifact in this plan is written under
`docs/features/active/2026-07-02-epic-orchestrate-275/evidence/<kind>/` per
`evidence-and-timestamp-conventions`. No task in this plan writes evidence under
`artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or any other non-canonical
path. Remediation baseline artifacts use `evidence/remediation-baseline/` (distinct from the
original feature's `evidence/baseline/`) so the two cycles' baselines remain independently
auditable.

## Scope

This plan implements the 5 fixes enumerated in `remediation-inputs.2026-07-02T23-00.md` and
no other change. Per that document's "Do Not Do" section:

- No behavior change to any hook's allow/deny decision logic or reason-string wording while
  fixing #1 (structural refactor only).
- No dropped TypeScript coverage-report formats while fixing #2 (`lcov` is added alongside
  existing reporters, not in place of them).
- No expansion beyond these 5 fixes (no unrelated hook refactors, no epic checkpoint schema
  changes, no wave-barrier/merge-gate decision-logic changes).
- No check-off of the AC2/AC14/Generic-closing-item checkboxes in `spec.md` or the item-2
  checkbox in `user-story.md` — those remain unchecked until a subsequent `feature-review`
  re-audit pass independently re-verifies each fix.
- No dependency-cruiser/architecture-boundary configuration introduced.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Baseline Capture & Policy Reads

- [x] [P0-T1] Read, in order, `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, then write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/phase0-instructions-read.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Policy Order:`, and an explicit list of the 9 files read, in the order read.

- [x] [P0-T2] Capture PowerShell line-count baseline for the fix-1 target: run `(Get-Content .claude/hooks/enforce-pr-author-skill.ps1 | Measure-Object -Line).Lines`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/powershell-linecount-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording the value `543`.

- [x] [P0-T3] Capture PowerShell format baseline: run `mcp__drm-copilot__run_poshqc_format` (check mode) against `.claude/hooks` and `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/powershell-format-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (pass/fail and file count).

- [x] [P0-T4] Capture PowerShell analyze baseline: run `mcp__drm-copilot__run_poshqc_analyze` against `.claude/hooks` and `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/powershell-analyze-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (rule-violation count).

- [x] [P0-T5] Capture PowerShell test baseline (with coverage): run `mcp__drm-copilot__run_poshqc_test` against `tests/scripts/claude-hooks/` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/powershell-test-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` recording 467/467 passing (0 failed) and the per-file coverage figures for the 5 pre-existing curated-scope files, confirming the 5 new/modified hook files are still absent from `CodeCoverage.Path` at this baseline point.

- [x] [P0-T6] Capture Python line-count baseline for the fix-4 target: run `(Get-Content tests/scripts/dev_tools/test_validate_orchestration_artifacts.py | Measure-Object -Line).Lines`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-linecount-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording the value `739`.

- [x] [P0-T7] Capture Python format baseline: run `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-format-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.

- [x] [P0-T8] Capture Python lint baseline: run `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-lint-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (violation count).

- [x] [P0-T9] Capture Python type-check baseline: run `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-typecheck-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (error count).

- [x] [P0-T10] Capture Python test baseline (with coverage): run `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/python-test-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` recording 1184 passed + 19 skipped (0 failed) and numeric line/branch coverage percentages.

- [x] [P0-T11] Capture TypeScript lcov-artifact-absence baseline for the fix-2 target: from `extensions/drm-copilot`, confirm `coverage/lcov.info` does not exist (`Test-Path coverage/lcov.info`); write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/typescript-lcov-absence-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` confirming the file is absent (`$false`).

- [x] [P0-T12] Capture TypeScript test baseline (pre-fix reporter set): from `extensions/drm-copilot`, run `npx jest --config jest.config.cjs --coverage --coverageReporters=text-summary --coverageReporters=json-summary`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/typescript-test-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording numeric statements/branches/lines coverage percentages and total tests passed, consistent with the figures already recorded in `evidence/qa-gates/coverage-delta-verification.2026-07-02T22-30.md`.

- [x] [P0-T13] Capture bundled-mirror-parity baseline: run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -v`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/remediation-baseline/bundled-mirror-parity-baseline.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` (pass count, zero failures) confirming the dynamic `.claude/`-tree parity test passes before any change in this plan.

### Phase 1 — Fix #1: `enforce-pr-author-skill.ps1` File-Size Extraction

- [x] [P1-T1] Create `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` containing the extracted `Get-PrAuthorCheckpointContent` and `Test-EpicBaseBranchOverride` function definitions (including their existing comment-based help blocks), copied verbatim from `.claude/hooks/enforce-pr-author-skill.ps1` with no logic changes, plus a short file-level comment stating this file is dot-sourced by `enforce-pr-author-skill.ps1` to stay under the 500-line limit
  - Acceptance: file exists at `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`; contains `function Get-PrAuthorCheckpointContent` and `function Test-EpicBaseBranchOverride`; a line-by-line diff of each function body against the pre-edit `enforce-pr-author-skill.ps1` shows no changes beyond whitespace/location.

- [x] [P1-T2] Edit `.claude/hooks/enforce-pr-author-skill.ps1` to remove the `Get-PrAuthorCheckpointContent` and `Test-EpicBaseBranchOverride` function definitions (now living in P1-T1's sibling file) and add a single dot-source line (`. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.epic-base-branch.ps1')`) positioned before `Test-PrAuthorReceiptVerification`'s first call to `Test-EpicBaseBranchOverride`, with no other line in the file changed
  - Acceptance: `Select-String -Path .claude/hooks/enforce-pr-author-skill.ps1 -Pattern '^function Get-PrAuthorCheckpointContent|^function Test-EpicBaseBranchOverride'` returns no matches; `Select-String -Path .claude/hooks/enforce-pr-author-skill.ps1 -Pattern 'enforce-pr-author-skill.epic-base-branch.ps1'` returns exactly one match.

- [x] [P1-T3] Run `(Get-Content .claude/hooks/enforce-pr-author-skill.ps1 | Measure-Object -Line).Lines` and confirm the result is <= 500
  - Acceptance: recorded line count is <= 500 (down from the P0-T2 baseline of 543).

- [x] [P1-T4] Copy the updated `.claude/hooks/enforce-pr-author-skill.ps1` and the new `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` into `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, overwriting the existing mirror of the first file and adding the second
  - Acceptance: `Compare-Object (Get-Content .claude/hooks/enforce-pr-author-skill.ps1 -Raw) (Get-Content extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1 -Raw)` and the equivalent comparison for the sibling file both report zero differences.

- [x] [P1-T5] If `packages/mcp-server/resources/claude-customizations/.claude/hooks/` exists in the working tree, copy the same two files into it; otherwise record that the mirror is absent and out of scope for this task
  - Acceptance: when the directory exists, both files are byte-identical to their canonical counterparts (`Compare-Object`/`cmp` report zero differences); when the directory is absent, the evidence artifact for this task states `MIRROR_ABSENT: packages/mcp-server/resources/claude-customizations/.claude/hooks/ not present in working tree`.

- [x] [P1-T6] Run `git diff --stat -- tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` and confirm the output is empty
  - Acceptance: command output is empty, proving no existing test was weakened, removed, or altered to accommodate the extraction.

- [x] [P1-T7] Run PowerShell format check (`mcp__drm-copilot__run_poshqc_format`, check mode) scoped to `.claude/hooks` and `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-fix1-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero files requiring reformatting.

- [x] [P1-T8] Run PowerShell analyze (`mcp__drm-copilot__run_poshqc_analyze`) scoped to `.claude/hooks` and `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-fix1-analyze.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero findings.

- [x] [P1-T9] Run PowerShell test (`mcp__drm-copilot__run_poshqc_test`) scoped to `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-fix1-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording a pass count >= 467 with 0 failed, including explicit confirmation that `enforce-pr-author-skill.Tests.ps1` and `enforce-pr-author-skill.epic-base-branch.Tests.ps1` both pass unmodified, evidencing no allow/deny behavior change.

### Phase 2 — Fix #2: TypeScript `lcov` Coverage Artifact

- [x] [P2-T1] From `extensions/drm-copilot`, run `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`
  - Acceptance: `EXIT_CODE: 0`; all Jest test suites pass with 0 failures.

- [x] [P2-T2] Confirm `extensions/drm-copilot/coverage/lcov.info` exists and is non-empty after the P2-T1 run (`Test-Path` plus a non-zero file size check)
  - Acceptance: file exists; file size > 0 bytes.

- [x] [P2-T3] Compare P2-T1's statements/branches/lines coverage percentages against the TypeScript figures recorded in `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/coverage-delta-verification.2026-07-02T22-30.md` (96.88% statements, 88.27% branches, 96.88% lines) and confirm no regression (each metric equal to or higher than the recorded figure, or within the same immaterial-rounding tolerance already documented there)
  - Acceptance: recorded delta for each of the three metrics is >= 0.00pp, or is accompanied by the same changed/new-code justification already used in the referenced evidence file.

- [x] [P2-T4] Write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/typescript-coverage-lcov.<timestamp>.md` recording the P2-T1 command, `EXIT_CODE`, the confirmed `extensions/drm-copilot/coverage/lcov.info` path, and the P2-T1/P2-T3 coverage figures
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` with numeric coverage values and the literal path `extensions/drm-copilot/coverage/lcov.info`.

### Phase 3 — Fix #3: PowerShell Coverage-Scope Allowlist

- [x] [P3-T1] Edit `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — append these 6 entries to the `CodeCoverage.Path` array, after the 5 pre-existing curated entries and without reordering or modifying them: `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.ps1`, `.claude/hooks/validate-orchestrator-output.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` (the sixth entry is the new sibling module created in P1-T1; it must also be measured because `general-unit-test.md`'s Coverage Exclusion Policy forbids omitting any production source file from coverage measurement)
  - Acceptance: the `CodeCoverage.Path` array contains all 6 new literal paths; the 5 pre-existing entries (`validate-bash.ps1`, `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, the release-script entries) remain textually unchanged and in their original order.

- [x] [P3-T2] Run `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks` with the updated `pester.runsettings.psd1`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-coverage-allowlist-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording a pass count equal to P1-T9's pass count (no new failures introduced by the coverage-scope change).

- [x] [P3-T3] Inspect `artifacts/pester/powershell-coverage.xml` generated by the P3-T2 run and confirm per-file entries exist for all 6 newly-added files with line coverage >= 85%; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/powershell-coverage-allowlist-inspection.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with a per-file table listing all 6 files and their line-coverage percentages, each >= 85%.

- [x] [P3-T4] Confirm the 5 pre-existing curated-scope files' line-coverage percentages recorded in the P3-T3 run are unchanged (0.00pp delta) relative to the P0-T5 baseline
  - Acceptance: recorded delta is 0.00pp for each of the 5 pre-existing curated-scope files, confirming the allowlist expansion introduced no regression to existing curated-scope numbers.

### Phase 4 — Fix #4: Split Oversized Python Test File

- [x] [P4-T1] Create `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` containing, moved verbatim (unchanged bodies, assertions, and docstrings) from `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`: the CLI-dispatch integration tests `test_validate_from_args_returns_unsupported_artifact_type`, `test_main_returns_exit_code_1_for_an_invalid_plan_artifact`, `test_main_returns_zero_for_valid_policy_audit`, `test_main_orchestrator_state_require_complete_returns_1_for_invalid`, `test_main_orchestrator_state_require_complete_returns_0_for_valid`, and the new `epic-orchestrator-state` dispatch tests `build_valid_epic_orchestrator_state`, `test_build_parser_epic_orchestrator_state_accepts_require_complete`, `test_validate_from_args_dispatches_epic_orchestrator_state`, `test_main_epic_orchestrator_state_require_complete_returns_0_for_valid`, `test_main_epic_orchestrator_state_require_complete_returns_1_for_invalid`; import the shared builder helpers (`build_valid_orchestrator_state`, `build_complete_large_orchestrator_state`, `get_first_receipt`, `build_read_text_stub`) from `tests.scripts.dev_tools.test_validate_orchestration_artifacts` rather than duplicating them, following the sibling-module convention already used by `test_validate_epic_orchestrator_state.py`
  - Acceptance: new file exists; contains all 10 named functions with unchanged bodies/assertions; `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py -q` collects and passes all moved tests with 0 failures.

- [x] [P4-T2] Edit `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` to remove the 10 functions moved in P4-T1, leaving every other existing test and helper in place and unmodified
  - Acceptance: `Select-String -Path tests/scripts/dev_tools/test_validate_orchestration_artifacts.py -Pattern 'def test_validate_from_args_dispatches_epic_orchestrator_state|def test_main_epic_orchestrator_state_require_complete'` returns no matches; no other `def test_` function present before P4-T1 was removed from this file.

- [x] [P4-T3] Run `(Get-Content tests/scripts/dev_tools/test_validate_orchestration_artifacts.py | Measure-Object -Line).Lines` and record the result; if it exceeds 500, record the residual gap and the specific remaining functions that could not be relocated without breaking shared-fixture cohesion
  - Acceptance: recorded line count is <= 500, or, if not fully achievable, is lower than the P0-T6 baseline of 739 with the residual gap and rationale explicitly documented in the task's evidence artifact.

- [x] [P4-T4] Run `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; confirm zero files require reformatting
  - Acceptance: `EXIT_CODE: 0`; zero files listed as needing reformatting.

- [x] [P4-T5] Run `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`; confirm zero violations
  - Acceptance: `EXIT_CODE: 0`; zero violations reported.

- [x] [P4-T6] Run `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`; confirm zero errors
  - Acceptance: `EXIT_CODE: 0`; zero errors reported.

- [x] [P4-T7] Run `poetry run pytest tests/scripts/dev_tools -q`; confirm total passed >= 1184 (+19 skipped), 0 failures
  - Acceptance: `EXIT_CODE: 0`; recorded pass count >= the P0-T10 baseline of 1184 passed + 19 skipped, 0 failed.

- [x] [P4-T8] Write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/python-test-split.<timestamp>.md` consolidating the P4-T3 through P4-T7 results
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each of the four toolchain stages plus the final line-count figure.

### Phase 5 — Fix #5: Tested Wave-Computation Reference Implementation

- [x] [P5-T1] Create `scripts/dev_tools/epic_wave_computation.py` implementing a pure, fully-typed function that computes `wave(f) = 0` when `depends_on(f)` is empty, else `1 + max(wave(d) for d in depends_on(f))`, over a mapping of `feature_folder -> depends_on` entries, using memoized recursion with cycle detection that raises a dedicated exception (e.g. `EpicWaveCycleError`) when a `feature_folder` is encountered while still being resolved, with Google-style docstrings per `.claude/rules/self-explanatory-code-commenting.md`
  - Acceptance: file exists; exports a public function accepting a `Mapping[str, Sequence[str]]` of `feature_folder -> depends_on` and returning a `dict[str, int]` of wave numbers; raises `EpicWaveCycleError` (or equivalently named dedicated exception) on a cyclic input.

- [x] [P5-T2] Create `tests/scripts/dev_tools/test_epic_wave_computation.py` with, at minimum, three test functions: (a) a diamond-DAG test matching `user-story.md`'s scenario (`child-a` no deps; `child-b` and `child-c` each depend on `child-a`; `child-d` depends on both `child-b` and `child-c`) asserting `child-a == 0`, `child-b == 1`, `child-c == 1`, `child-d == 2`; (b) a linear-chain test (`a <- b <- c <- d`) asserting waves `0, 1, 2, 3` respectively; (c) a cyclic-manifest test (`a` depends on `b`, `b` depends on `a`) asserting the dedicated cycle exception is raised
  - Acceptance: file exists; `poetry run pytest tests/scripts/dev_tools/test_epic_wave_computation.py -v` collects and passes all 3 scenarios (plus any additional edge-case tests) with 0 failures.

- [x] [P5-T3] Run `poetry run black --check scripts/dev_tools/epic_wave_computation.py tests/scripts/dev_tools/test_epic_wave_computation.py`; confirm zero files require reformatting
  - Acceptance: `EXIT_CODE: 0`.

- [x] [P5-T4] Run `poetry run ruff check scripts/dev_tools/epic_wave_computation.py tests/scripts/dev_tools/test_epic_wave_computation.py`; confirm zero violations
  - Acceptance: `EXIT_CODE: 0`.

- [x] [P5-T5] Run `poetry run pyright scripts/dev_tools/epic_wave_computation.py tests/scripts/dev_tools/test_epic_wave_computation.py`; confirm zero errors
  - Acceptance: `EXIT_CODE: 0`.

- [x] [P5-T6] Run `poetry run pytest tests/scripts/dev_tools/test_epic_wave_computation.py -v --cov=scripts.dev_tools.epic_wave_computation --cov-branch --cov-report=term-missing`; confirm line coverage >= 85% and branch coverage >= 75% for the new module
  - Acceptance: `EXIT_CODE: 0`; recorded line coverage >= 85% and branch coverage >= 75% for `scripts/dev_tools/epic_wave_computation.py`.

- [x] [P5-T7] Write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/wave-computation-module.<timestamp>.md` consolidating the P5-T3 through P5-T6 results
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` for each of the four toolchain stages.

- [x] [P5-T8] Edit `.claude/skills/epic-orchestrate/SKILL.md` — immediately after the existing wave-formula code block in the `## Wave Assignment` section (the `wave(f) = 0 ...` / `wave(f) = 1 + max(...)` lines), append one sentence citing `scripts/dev_tools/epic_wave_computation.py` as the canonical tested reference implementation of the formula, with no other change to the section's pre-existing text
  - Acceptance: the file contains a literal reference to `scripts/dev_tools/epic_wave_computation.py`; the pre-existing formula text and surrounding prose are textually unchanged aside from the appended sentence.

- [x] [P5-T9] Edit `.claude/agents/epic-orchestrator.md` — immediately after the existing wave-scheduling sentence in the `## Wave Scheduling` section, append one sentence citing `scripts/dev_tools/epic_wave_computation.py` as the canonical tested reference implementation of the formula, with no other change to the section's pre-existing text
  - Acceptance: the file contains a literal reference to `scripts/dev_tools/epic_wave_computation.py`; the pre-existing sentence and surrounding prose are textually unchanged aside from the appended sentence.

- [x] [P5-T10] Copy the updated `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/agents/epic-orchestrator.md` into `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` respectively, overwriting the existing mirrors
  - Acceptance: `Compare-Object`/`cmp` between each canonical file and its mirror reports zero differences for both files.

- [x] [P5-T11] If `packages/mcp-server/resources/claude-customizations/.claude/` exists in the working tree, copy the same two files into their mirrored locations under it; otherwise record that the mirror is absent and out of scope for this task
  - Acceptance: when the directory exists, both files are byte-identical to their canonical counterparts; when absent, the evidence artifact for this task states `MIRROR_ABSENT: packages/mcp-server/resources/claude-customizations/.claude/ not present in working tree`.

### Phase 6 — Final QA Loop, Bundled-Mirror Parity, and Checkbox-State Confirmation

- [x] [P6-T1] Run PowerShell format check (`mcp__drm-copilot__run_poshqc_format`, check mode) against `.claude/hooks` and `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-powershell-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero files requiring reformatting.

- [x] [P6-T2] Run PowerShell analyze (`mcp__drm-copilot__run_poshqc_analyze`) against `.claude/hooks` and `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-powershell-analyze.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero findings.

- [x] [P6-T3] Run PowerShell test with coverage (`mcp__drm-copilot__run_poshqc_test`) against `tests/scripts/claude-hooks`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-powershell-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording the total pass count (0 failed) and numeric line/branch coverage figures for all 6 files in the expanded `CodeCoverage.Path`, each >= 85% line / 75% branch, with 0.00pp regression on the 5 pre-existing curated-scope files.

- [x] [P6-T4] Run Python format check: `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`.

- [x] [P6-T5] Run Python lint: `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-lint.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero violations.

- [x] [P6-T6] Run Python type-check: `poetry run pyright scripts/dev_tools tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-typecheck.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero errors.

- [x] [P6-T7] Run Python test with coverage: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-python-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording a pass count >= the P0-T10 baseline plus the new `epic_wave_computation` tests, 0 failed, and numeric line/branch coverage figures with no regression relative to the P0-T10 baseline.

- [x] [P6-T8] Run TypeScript format check: `npm run format -- --check` in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-typescript-format.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:`.

- [x] [P6-T9] Run TypeScript lint: `npm run lint` in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-typescript-lint.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero violations.

- [x] [P6-T10] Run TypeScript type-check: `npm run typecheck` in `extensions/drm-copilot`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-typescript-typecheck.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording zero errors.

- [x] [P6-T11] Run TypeScript test with coverage including the `lcov` reporter: from `extensions/drm-copilot`, run `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary`; write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-typescript-test.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording numeric statements/branches/lines coverage with no regression relative to the 96.88%/88.27%/96.88% figures in `evidence/qa-gates/coverage-delta-verification.2026-07-02T22-30.md`, and confirming `extensions/drm-copilot/coverage/lcov.info` exists after the run.

- [x] [P6-T12] Run `poetry run pytest tests/scripts/dev_tools/` (the full directory, not a single file); write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/final-bundled-mirror-parity.<timestamp>.md`
  - Acceptance: artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, `Output Summary:` recording 0 failures and explicit confirmation that `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (the dynamic full-`.claude/`-tree parity test) passes, verifying the Phase 1 and Phase 5 mirror updates are byte-identical to their canonical sources.

- [x] [P6-T13] Confirm `spec.md`'s AC2 checkbox (`- [ ] AC2: ... wave-computation implementation derives wave numbers via the longest-path-layering function ...`) remains unchecked (`[ ]`) at the end of this plan's execution, since check-off is reserved for a subsequent independent `feature-review` re-audit pass; do not edit `spec.md` in this task
  - Acceptance: `Select-String -Path docs/features/active/2026-07-02-epic-orchestrate-275/spec.md -Pattern '^- \[ \] AC2:'` returns exactly one match; `spec.md` is unmodified by this task.

- [x] [P6-T14] Confirm `spec.md`'s AC14 checkbox (`- [ ] AC14: All four quality toolchains pass with no coverage regression ...`) remains unchecked (`[ ]`) for the same reason; do not edit `spec.md` in this task
  - Acceptance: `Select-String -Path docs/features/active/2026-07-02-epic-orchestrate-275/spec.md -Pattern '^- \[ \] AC14:'` returns exactly one match; `spec.md` is unmodified by this task.

- [x] [P6-T15] Confirm `spec.md`'s Generic closing item `- [ ] Toolchain pass completed (format → lint → type-check → test)` remains unchecked (`[ ]`) for the same reason; do not edit `spec.md` in this task
  - Acceptance: `Select-String -Path docs/features/active/2026-07-02-epic-orchestrate-275/spec.md -Pattern '^- \[ \] Toolchain pass completed'` returns exactly one match; `spec.md` is unmodified by this task.

- [x] [P6-T16] Confirm `user-story.md`'s item-2 checkbox (`- [ ] A deterministic epic dependency manifest format ... computes wave assignment from it via longest-path-layering topological sort ...`) remains unchecked (`[ ]`) for the same reason; do not edit `user-story.md` in this task
  - Acceptance: `Select-String -Path docs/features/active/2026-07-02-epic-orchestrate-275/user-story.md -Pattern '^- \[ \] A deterministic epic dependency manifest format'` returns exactly one match; `user-story.md` is unmodified by this task.

- [x] [P6-T17] Write `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/qa-gates/remediation-cycle-2026-07-02T23-00-final-summary.<timestamp>.md` consolidating the pass/fail state of all 5 fixes (Phases 1-5) and the Phase 6 final-QA results, and stating that the next step per `remediation-inputs.2026-07-02T23-00.md` is a subsequent `feature-review` pass producing new `code-review`, `feature-audit`, and `policy-audit` artifacts at a new exit timestamp, which alone may re-evaluate AC2/AC14/Generic-closing-item/user-story-item-2 for check-off
  - Acceptance: artifact contains `Timestamp:` and a per-fix (1 through 5) pass/fail line referencing the specific evidence file(s) produced in that fix's phase.
