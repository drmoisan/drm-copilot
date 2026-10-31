# merge-gate-epic-mode-string-false-treated-as-true (Spec)

- **Issue:** #1001
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.2

## Context
Branch 1 of `.claude/hooks/enforce-epic-merge-gate.ps1` casts the checkpoint's `epic_mode` value with `[bool]`, so the string `"false"` evaluates to true and the epic-child branch is entered. Found during the #997 work and recorded in PR #1000.

Research (`research/research.2026-10-30T11-00.md`, section 4.4) found the same defect class in two sibling hooks. The defect class for this item is: **a hook treats a non-boolean checkpoint `epic_mode` value as epic mode.** Repository practice is to fix related findings inside the item, so this spec covers all three hooks named under Scope.

Environment:
- OS/version: Windows 11, PowerShell 7 (the Linux hook-suite CI job also runs the Pester suites under PowerShell 7 on `ubuntu-latest`)
- Python version: not applicable to the fix; Python is used only for the bundled-mirror contract test
- Command/flags used: `gh pr merge <N> --merge` intercepted by the PreToolUse merge gate; `gh pr create` intercepted by the pr-author skill gate; `Agent(pr-author)` delegation intercepted by the model-routing receipt gate
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` with `"epic_mode": "false"` (or `"true"`, or `1`)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

The misparse grants no access beyond what a real `epic_mode: true` already grants. It is a correctness defect in authorization hooks. Per hook:

- Merge gate: a string or non-zero number enters branch 1 (allow direction).
- pr-author epic base-branch check: a string or non-zero number activates the `--base <integration_branch>` requirement (deny direction; can block a standalone `gh pr create`).
- Model-routing receipt gate: the string `"true"` or the number `1` is treated as an epic child and waives the author-asserted autoclose line requirement (allow direction).

## Repro & Evidence
Steps to Reproduce:
1. Write a checkpoint whose `epic_mode` is the JSON string `"false"`.
2. Run the merge gate against `gh pr merge <N> --merge`.
3. Observe that branch 1 treats the checkpoint as epic mode.

Sibling reproductions (from code reading, research section 4.4):
- `Test-EpicBaseBranchOverride` with checkpoint `{"epic_mode":"false","epic_context":{"integration_branch":"epic/x"}}` and `gh pr create` without `--base` returns `EPIC_BASE_BRANCH_MISMATCH` instead of `$null`.
- `Get-ModelRoutingAuthorAssertedReason` with checkpoint `{"issue-num":"1001","epic_mode":"true"}` and a prompt without the author-asserted line returns `$null` instead of `AUTHOR_ASSERTED_AUTOCLOSE_MISSING`.

Expected:
Only the JSON boolean `true` (a `System.Boolean` `$true` after `ConvertFrom-Json`) counts as epic mode in any of the three hooks, as the green-CI branch added in #997 and the Codex merge gate already require.

Actual:
- `[bool]` cast (merge gate, base-branch check): any non-empty string, including `"false"`, and any non-zero number cast to true.
- `-eq $true` comparison (model-routing gate): PowerShell coerces the right operand to the left operand's type, so the string `"true"` (case-insensitive) and the integer `1` compare equal to `$true`.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: none; found by code reading.

## Scope & Non-Goals
- In scope:
  1. `.claude/hooks/enforce-epic-merge-gate.ps1`, function `Test-ChildCheckpointAllowsEpicMerge`, and its comment-based help plus script `.DESCRIPTION` condition 1.
  2. `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, function `Test-EpicBaseBranchOverride`, and its comment-based help.
  3. `.claude/hooks/enforce-model-routing-receipt.ps1`, function `Get-ModelRoutingAuthorAssertedReason`, its comment-based help, and the script `.DESCRIPTION` paragraph "Author-asserted autoclose line (issue #989)".
  4. Byte-identical bundled mirrors (each verified present on this branch):
     - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
     - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
     - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1`
  5. New Pester regression suites (new files only):
     - `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`
     - `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1`
     - `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1`
  6. Feature-folder evidence under `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/evidence/<kind>/`.
- Out of scope / non-goals:
  - `.codex/hooks/` copies. `.codex/hooks/enforce-epic-merge-gate.ps1` (`Test-CodexChildMergeReady`) and `.codex/hooks/enforce-epic-wave-barrier.ps1` are already strict per research sections 1.5 and 4.4.
  - Any change to `.claude/rules/*`, `.github/instructions/*`, or `.claude/skills/execution-environment/SKILL.md`.
  - Any change to a checkpoint validator (Python or PowerShell) or a schema; no validator constrains the `epic_mode` type today and this item does not add one.
  - Any change to deny or reason message text in the three hooks.
  - A shared "is JSON true" helper (research approach B, rejected).
  - The `Get-EditReplaceAllFlag` / `Get-FileSizeLimitReplaceAllFlag` helpers, which intentionally accept the string `"true"` for a different input (tool-input flags, not checkpoint `epic_mode`).
- Explicitly excluded systems, integrations, or datasets: the Copilot `.github/` surface; the VS Code extension TypeScript sources; live checkpoints in other worktrees.

## Root Cause Analysis
Two expression shapes rely on PowerShell type coercion instead of a type test:

| Hook | Function | Current expression | Coercion effect |
|---|---|---|---|
| `enforce-epic-merge-gate.ps1` | `Test-ChildCheckpointAllowsEpicMerge` | `$props -notcontains 'epic_mode' -or -not [bool]$Checkpoint.epic_mode` | `[bool]` truthiness: every non-empty string and non-zero number is `$true` |
| `enforce-pr-author-skill.epic-base-branch.ps1` | `Test-EpicBaseBranchOverride` | `$checkpointProps -notcontains 'epic_mode' -or -not [bool]$checkpoint.epic_mode` | Same as above |
| `enforce-model-routing-receipt.ps1` | `Get-ModelRoutingAuthorAssertedReason` | `$names -contains 'epic_mode' -and $Checkpoint.epic_mode -eq $true` | Right operand coerced to left type: `"true"` (any case) and `1` equal `$true`; `"false"`, `0`, `""` do not |

The repository already documents the `[bool]'false' -eq $true` pitfall in `enforce-completion-helpers.ps1` and `enforce-file-size-limit.ps1`, and the strict idiom `(($v -is [bool]) -and $v)` is used in `enforce-epic-merge-gate-green-ci.ps1` (`Test-EpicMergeGateGreenCiNotParallel`), the Codex merge gate, and `.claude/lib/orchestrator-state/*.psm1`.

## Proposed Fix

### Design summary (what changes where):
Replace each coercing expression with the strict type test so that only a `System.Boolean` `$true` counts as epic mode:

- `Test-ChildCheckpointAllowsEpicMerge`: `if ($props -notcontains 'epic_mode' -or -not (($Checkpoint.epic_mode -is [bool]) -and $Checkpoint.epic_mode)) { return $false }`
- `Test-EpicBaseBranchOverride`: `if ($checkpointProps -notcontains 'epic_mode' -or -not (($checkpoint.epic_mode -is [bool]) -and $checkpoint.epic_mode)) { return $null }`
- `Get-ModelRoutingAuthorAssertedReason`: `if ($null -eq $issue -or ($names -contains 'epic_mode' -and ($Checkpoint.epic_mode -is [bool]) -and $Checkpoint.epic_mode)) { return $null }`

Update the comment-based help in each hook to state that `epic_mode` must be the JSON boolean `true` and that a string or number (for example `"false"` or `"true"`) is not epic mode (issue #1001). Copy each changed hook byte-identically to its bundled mirror.

### Boundaries and invariants to preserve:
- Deny and reason message text in all three hooks is unchanged, including the merge gate's final deny string containing `epic_mode == true` (asserted verbatim by existing suites, including `enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `.DocsOnly.Tests.ps1`, `.Authorization.Tests.ps1`, and `.GreenCiDecision.Tests.ps1`), the `EPIC_BASE_BRANCH_MISMATCH` strings, and the `AUTHOR_ASSERTED_AUTOCLOSE_MISSING` string.
- Behavior for JSON `true`, JSON `false`, JSON `null`, and an absent `epic_mode` property is unchanged in all three hooks.
- Merge gate: branches 2, 3, 3b, 4, and the docs-only branch are unchanged. A branch-1 decline falls through to them as today. Branch 1 stays checkpoint-only (no added `gh` or `git` call).
- Base-branch check: the epic-scope (`$EpicScope.IsEpicScope`) path and the non-create early return are unchanged.
- Model-routing gate: the `issue-num` resolution and the prompt-line regex are unchanged.
- Strict mode safety: property presence is tested before the value is read, as today.
- Each hook and its bundled mirror are byte-identical.

### Dependencies or blocked work:
None. No dependency, manifest, or pack-manifest change; all six production files already exist and are already listed where required.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/hooks/enforce-epic-merge-gate.ps1`
- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- `.claude/hooks/enforce-model-routing-receipt.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1`
- New: `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`
- New: `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1`
- New: `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1`

Existing test suites are not edited. Research section 4.3 found no existing suite that asserts the loose behavior for these three functions (the only non-boolean `epic_mode` fixtures are in `enforce-epic-merge-gate.GreenCi.Tests.ps1`, which targets the unchanged green-CI functions, and the Codex decision-surface suite). If the planner finds an existing suite that asserts the loose behavior, that suite may be updated and the change must be recorded in the plan.

#### Functions/classes/CLI commands impacted:
- `Test-ChildCheckpointAllowsEpicMerge` (and, through it, `Invoke-EpicMergeGateDecision` branch 1)
- `Test-EpicBaseBranchOverride` (sixth ordered check of `enforce-pr-author-skill.ps1`)
- `Get-ModelRoutingAuthorAssertedReason` (called from `Invoke-ModelRoutingReceiptDecision` for `pr-author` delegations)

#### Data flow and validation changes:
Checkpoint JSON is parsed with `ConvertFrom-Json` as today. The only change is the predicate applied to the parsed `epic_mode` value:

| `epic_mode` value (JSON) | Epic mode before (gate / base-branch) | Epic mode before (model-routing) | Epic mode after (all three) |
|---|---|---|---|
| `true` | yes | yes | yes |
| `false` | no | no | no |
| `null` | no | no | no |
| absent | no | no | no |
| `"false"` | yes | no | no |
| `"true"` | yes | yes | no |
| `1` | yes | yes | no |
| `0` | no | no | no |

#### Error handling and logging updates:
None. No new exception paths; non-boolean values take the existing non-epic path. No logging is added.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the six production files; the new test suites would then fail on the `"false"`, `"true"`, and `1` rows, which is the intended signal.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Function signatures, parameter sets, and output types are unchanged:
- `Test-ChildCheckpointAllowsEpicMerge -Checkpoint <object|null>` returns `[bool]`.
- `Test-EpicBaseBranchOverride -CommandText <string> -CheckpointPath <string> [-EpicScope <object|null>]` returns `[string]` or `$null`.
- `Get-ModelRoutingAuthorAssertedReason -Checkpoint <object|null> -PromptText <string>` returns `[string]` or `$null`.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
Checkpoints that record `epic_mode` as a JSON boolean or omit it behave identically. A checkpoint that records `epic_mode` as a string or number is no longer treated as epic mode by any of the three hooks. No writer of such a value was found (research section 9).

#### Performance constraints (latency/throughput/memory):
No measurable change; one type test replaces one cast or comparison per invocation.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): PowerShell 7 `ConvertFrom-Json` returns `System.Boolean` for JSON `true`/`false`, `System.String` for JSON strings, and `System.Int64` for JSON integers (research section 1.2). All checkpoint writers emit `epic_mode` as a JSON boolean.
- Constraints (budget, performance, compatibility): six PowerShell production files change, so the run needs a route that permits more than the direct-mode batch budget of three PowerShell production files (research section 4.4). Every touched file stays at or below 800 logical lines; current sizes are 476 (merge gate), 144 (base-branch), and 349 (model-routing), and help additions should keep each hook below the 500-line guidance tier. Tests must not create temporary files.
- External dependencies (services, libraries, releases): Pester 5 and PSScriptAnalyzer (existing); Pytest for the mirror contract test (existing).

## Data / API / Config Impact
- User-facing or API changes: none beyond the stricter `epic_mode` interpretation described above.
- Data or migration considerations: none; no checkpoint migration.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag, schema, or pack-manifest change. The bundled extension payload changes only by the three mirrored hook files.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: Pester rows for `"false"`, `"true"`, `$true`, `$false`, and absent `epic_mode`.
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Accept only a real boolean `true`. Mirror the change into the extension resources copy.

- Regression tests to add or update: the three new `*.EpicModeStrict.Tests.ps1` suites listed under Scope. Each suite runs one row per `epic_mode` value in the value matrix: JSON `true`, JSON `false`, JSON `null`, absent key, string `"false"`, string `"true"`, integer `1`, integer `0`.
  - Merge gate suite: unit rows on `Test-ChildCheckpointAllowsEpicMerge` with `step9_status: "passed"` (JSON `true` returns `$true`; every other value returns `$false`); decision rows through `Invoke-EpicMergeGateDecision` for `gh pr merge 42 --merge` with a child checkpoint carrying `pr_gate.pr_number: 42` (JSON `true` allows; `"false"` and `"true"` deny with `EPIC_MERGE_GATE_BLOCKED`); one decision row with `"epic_mode":"false"` and an otherwise green standalone checkpoint that denies without calling `Get-EpicMergeGateLivePrHeadSha`. Seams per research section 4.2 (mocked checkpoint-content and resolution functions; synthetic roots under `/synthetic-worktrees`).
  - Base-branch suite: rows on `Test-EpicBaseBranchOverride` for `gh pr create --title x` (no `--base`) with `Get-PrAuthorCheckpointContent` mocked to return the checkpoint JSON text including `epic_context.integration_branch` (JSON `true` returns a string matching `EPIC_BASE_BRANCH_MISMATCH`; every other value returns `$null`).
  - Model-routing suite: rows on `Get-ModelRoutingAuthorAssertedReason` with a checkpoint object built in memory (`ConvertFrom-Json` on a string) recording `issue-num` and a prompt without the author-asserted line (JSON `true` returns `$null`; every other value returns a string matching `AUTHOR_ASSERTED_AUTOCLOSE_MISSING`).
- Unit tests (pytest) for the fixed behavior and boundaries: none added; the existing `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` verifies mirror byte parity.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): absent key and JSON `null` (missing data); string `"false"` and `"true"` (type confusion); integers `1` and `0` (numeric truthiness); null checkpoint on `Test-ChildCheckpointAllowsEpicMerge` is already covered by existing suites.
- Error handling and logging verification: rows assert the exact existing reason codes; no new error paths.
- Coverage impact and targets for changed lines/modules: each changed `.claude/hooks/` file is in the `config/poshqc-coverage.json` population; line coverage of each must be at least 85% and not below its pre-change figure. No branch-coverage gate applies to PowerShell.
- Toolchain commands to run (format -> lint -> type-check -> test): `Invoke-Formatter` check and PSScriptAnalyzer on all touched `.ps1` files (type-check is not applicable to PowerShell); Pester over `tests/scripts/claude-hooks` with coverage; `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; seeded shuffled Pester runs.
- Fail-before evidence: run the new suites against the unfixed hooks and record the failing rows, then record the passing run after the fix.
- Manual validation steps (if required): none.

## Acceptance Criteria
- [x] AC-1: `Test-ChildCheckpointAllowsEpicMerge` in `.claude/hooks/enforce-epic-merge-gate.ps1` returns `$true` only when `epic_mode` is the JSON boolean `true` (with `step9_status: "passed"`). Proven by `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`: the JSON `true` row returns `$true`; the JSON `false`, `null`, absent-key, string `"false"`, string `"true"`, integer `1`, and integer `0` rows each return `$false`.
- [x] AC-2: `Invoke-EpicMergeGateDecision` denies a `gh pr merge <N> --merge` command with a reason matching `EPIC_MERGE_GATE_BLOCKED` when the child checkpoint records `epic_mode` as the string `"false"` or `"true"` (with `step9_status: "passed"` and a `pr_gate.pr_number` equal to the command's PR number), and allows the same command when `epic_mode` is JSON `true`. Proven by decision rows in `enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`, including a row showing that `"epic_mode":"false"` with an otherwise green standalone checkpoint denies and never invokes `Get-EpicMergeGateLivePrHeadSha`.
- [x] AC-3: `Test-EpicBaseBranchOverride` in `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` enforces the `--base <epic_context.integration_branch>` requirement only when `epic_mode` is the JSON boolean `true`. Proven by `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.EpicModeStrict.Tests.ps1`: for `gh pr create` without `--base`, the JSON `true` row returns a string matching `EPIC_BASE_BRANCH_MISMATCH`; the JSON `false`, `null`, absent-key, string `"false"`, string `"true"`, integer `1`, and integer `0` rows each return `$null`.
- [x] AC-4: `Get-ModelRoutingAuthorAssertedReason` in `.claude/hooks/enforce-model-routing-receipt.ps1` waives the author-asserted autoclose line only when `epic_mode` is the JSON boolean `true`; the expression `$Checkpoint.epic_mode -eq $true` is replaced by a `-is [bool]` type test. Proven by `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicModeStrict.Tests.ps1`: with an `issue-num` recorded and no author-asserted line in the prompt, the JSON `true` row returns `$null`; the JSON `false`, `null`, absent-key, string `"false"`, string `"true"`, integer `1`, and integer `0` rows each return a string matching `AUTHOR_ASSERTED_AUTOCLOSE_MISSING`.
- [x] AC-5: Fail-before evidence is recorded under `evidence/regression-testing/` in the feature folder: the new `*.EpicModeStrict.Tests.ps1` suites run against the unfixed hooks show failing rows for string `"false"`, string `"true"`, and integer `1` in the merge-gate and base-branch suites, and for string `"true"` and integer `1` in the model-routing suite; the post-fix run shows all rows passing. Each record carries `Timestamp`, `Command`, `EXIT_CODE`, and an `Output Summary` read from the JUnit result, and contains no absolute paths.
- [x] AC-6: Comment-based help states the JSON-boolean requirement: the `enforce-epic-merge-gate.ps1` script `.DESCRIPTION` condition 1 and the `Test-ChildCheckpointAllowsEpicMerge` help; the `Test-EpicBaseBranchOverride` help; and the `enforce-model-routing-receipt.ps1` script `.DESCRIPTION` "Author-asserted autoclose line" paragraph and the `Get-ModelRoutingAuthorAssertedReason` help. Each states that only the JSON boolean `true` counts as epic mode and that a string or number (for example `"false"`) does not, and cites this item's issue. Verified by reading the diff.
- [x] AC-7: Deny and reason message text is unchanged in each in-scope hook, including the final deny string of `Invoke-EpicMergeGateDecision` containing `epic_mode == true`, both `EPIC_BASE_BRANCH_MISMATCH` strings, and the `AUTHOR_ASSERTED_AUTOCLOSE_MISSING` string. Verified by the diff showing no change to those string literals and by the existing suites that assert them verbatim (including `enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `enforce-epic-merge-gate.DocsOnly.Tests.ps1`, `enforce-epic-merge-gate.Authorization.Tests.ps1`, and `enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`) passing without edits.
- [x] AC-8: Each bundled mirror is byte-identical to its source hook: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, and `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-model-routing-receipt.ps1`. Proven by `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passing, with the result recorded under `evidence/regression-testing/`.
- [x] AC-9: Existing Pester suites for the in-scope hooks pass without edits (`tests/scripts/claude-hooks/enforce-epic-merge-gate*.Tests.ps1`, `enforce-pr-author-skill*.Tests.ps1`, `enforce-model-routing-receipt*.Tests.ps1`). If the planner identifies an existing suite that asserts the loose behavior, the plan names it and records its update; no other existing test file is modified.
- [x] AC-10: PowerShell formatting and analysis are clean for every touched `.ps1` file (each in-scope hook, each mirror, and each new suite): the `Invoke-Formatter` check reports no change and PSScriptAnalyzer reports no findings at the repository's configured severity. Results recorded under `evidence/qa-gates/`.
- [x] AC-11: The full Pester run over `tests/scripts/claude-hooks` passes with coverage enabled, and the per-file line coverage of `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, and `.claude/hooks/enforce-model-routing-receipt.ps1` each meets the line-coverage threshold that governs this repository under `.claude/rules/general-unit-test.md` (Coverage Requirements, including its threshold-precedence rule) and is not below its pre-change figure, as read from the coverage report of a branch-current run and recorded under `evidence/coverage/`. No branch-coverage threshold applies (PowerShell).
- [x] AC-12: Every touched file (each hook, each mirror, and each new suite) passes the hard file-size limit in `.claude/rules/general-code-change.md` (File Size Limit), as enforced by the repository file-size check, and none is added to `config/file-size-baseline.json`.
- [x] AC-13: Test isolation: the new `*.EpicModeStrict.Tests.ps1` suites create no files (no `TestDrive:`, `New-TemporaryFile`, `Set-Content`, `Out-File`, or `New-Item` on the file system); all checkpoints are in-memory JSON strings or objects behind mocked seams. Seeded shuffled Pester runs over the new suites together with the existing suites of the in-scope hooks pass under multiple distinct recorded seeds (the plan fixes the seed set), with each seed and its result recorded under `evidence/regression-testing/`.
- [ ] AC-14: No change outside the scope: the branch diff against `main` touches only the production files and new test files listed under Scope, plus files inside this feature folder (and any existing suite named under AC-9). No file under `.codex/`, `.claude/rules/`, `.github/instructions/`, `.claude/skills/execution-environment/`, or any checkpoint validator is modified. Verified with `git diff --name-only main...HEAD`.

## Risks & Mitigations
- Technical or operational risks:
  - Behavior tightening: a live checkpoint recording `epic_mode` as `"true"` or `1` loses epic treatment in all three hooks (merge gate denies branch 1; base-branch check stops requiring `--base`; model-routing gate requires the author-asserted line). No writer of such a value was found.
  - Mirror drift: editing a source hook without its mirror fails the mirror contract test.
  - Hook execution context: isolated subagents run `main`'s hook copies, so the new behavior is proven by Pester only until merge.
  - Batch budget: six PowerShell production files exceed the direct-mode batch budget; a route that permits this is required.
  - Linux CI: the new suites run on a case-sensitive file system; paths must use `Join-Path` with exact file-name case and no drive letters.
- Mitigations and rollbacks:
  - Deny messages for the merge gate still point to the standalone and green-CI paths.
  - A dedicated task copies each mirror and runs `test_push_down_claude_resource_contracts.py`.
  - Rollback is a revert of the six production files.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; the bundled mirrors ship with the next extension package build. No staged rollout.
- Post-fix monitoring or clean-up tasks: none required. Writers of checkpoint `epic_mode` remain unconstrained by validators (research section 4.4); adding a type constraint is outside this item.
- Links: issue #1001; PR #1000 (where the defect was recorded); issue #997 (green-CI branch with the strict idiom); research `research/research.2026-10-30T11-00.md`.
