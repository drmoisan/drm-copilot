# Research: merge-gate epic_mode string "false" treated as true (Issue #1001)

- Issue: #1001
- Branch: `bug/merge-gate-epic-mode-string-false-1001`
- Work mode: full-bug
- Researcher route: Read, Grep, Glob, Write only (no `git show`, no `gh`, no command execution). Facts that need a run are marked for the orchestrator to confirm.

## 1. Current State Analysis

### 1.1 The defect site

- File: `.claude/hooks/enforce-epic-merge-gate.ps1`
- Function: `Test-ChildCheckpointAllowsEpicMerge` (branch 1, child-feature path).
- Offending condition (verbatim):

  ```powershell
  if ($props -notcontains 'epic_mode' -or -not [bool]$Checkpoint.epic_mode) {
  ```

- Caller: `Invoke-EpicMergeGateDecision`, which allows the merge when `Test-ChildCheckpointAllowsEpicMerge` and `Test-ChildCheckpointPrGateBinding` (in `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`) both return true.

### 1.2 How `ConvertFrom-Json` represents the values (PowerShell 7)

| JSON value | .NET type after `ConvertFrom-Json` | `[bool]` cast | `-is [bool] -and $v` |
|---|---|---|---|
| `true` | `System.Boolean` (`$true`) | `$true` | `$true` |
| `false` | `System.Boolean` (`$false`) | `$false` | `$false` |
| `"true"` | `System.String` | `$true` (non-empty string) | `$false` |
| `"false"` | `System.String` | `$true` (non-empty string) | `$false` |
| `"0"`, `"no"` | `System.String` | `$true` | `$false` |
| `""` | `System.String` | `$false` | `$false` |
| `1` | `System.Int64` | `$true` | `$false` |
| `0` | `System.Int64` | `$false` | `$false` |
| `null` | `$null` | `$false` | `$false` |
| `{}` | `PSCustomObject` | `$true` | `$false` |

The `[bool]` cast is PowerShell truthiness, so every non-empty string and every non-zero number enters branch 1. The repository already records this pitfall in comment-based help: `Get-EditReplaceAllFlag` in `.claude/hooks/enforce-completion-helpers.ps1` and `Get-FileSizeLimitReplaceAllFlag` in `.claude/hooks/enforce-file-size-limit.ps1` both state "No [bool] cast is used because [bool]'false' is $true in PowerShell."

### 1.3 Other checkpoint-boolean reads in the gate and its dot-sourced helpers

The gate dot-sources `hook-dependency-guard.ps1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1`, `enforce-epic-merge-gate-authorization.ps1`, `enforce-epic-merge-gate-resolution.ps1`, `enforce-epic-merge-gate-command.ps1`, `hook-docs-only-diff.ps1`, and `enforce-epic-merge-gate-green-ci.ps1`, and imports `HookPayload.psm1`.

A search for `epic_mode`, `parallel_mode`, and `[bool]$` across `.claude/hooks/enforce-epic-merge-gate*.ps1` and `.claude/hooks/hook-docs-only-diff.ps1` found:

- `enforce-epic-merge-gate.ps1`: the single `[bool]` cast in `Test-ChildCheckpointAllowsEpicMerge`. No other checkpoint boolean is read in this file. `Test-EpicCheckpointAllowsMerge` and `Test-ParallelCheckpointAllowsMerge` compare strings (`ci_gate.conclusion`, `route_id`, `merge_status`) and parse integers; they have no truthiness test on a checkpoint value.
- `enforce-epic-merge-gate-green-ci.ps1`: `Test-EpicMergeGateGreenCiNotParallel` reads `epic_mode` and `parallel_mode` strictly. Idiom (verbatim):

  ```powershell
  foreach ($marker in @('epic_mode', 'parallel_mode')) {
      if ($props -ccontains $marker -and $null -ne $Checkpoint.$marker -and
          -not (($Checkpoint.$marker -is [bool]) -and -not $Checkpoint.$marker)) {
          return $false
      }
  }
  ```

  Its help states: "epic_mode must be absent, JSON null, or JSON false; epic_mode true belongs to branch 1, and any other value (for example the string "false") fails closed."
- `enforce-epic-merge-gate-resolution.ps1`: `Test-ChildCheckpointPrGateBinding` parses `pr_gate.pr_number` with `[int]::TryParse`; no boolean read.
- `enforce-epic-merge-gate-authorization.ps1`, `enforce-epic-merge-gate-command.ps1`, `hook-docs-only-diff.ps1`: no `epic_mode`, `parallel_mode`, or `[bool]$` checkpoint cast.

Conclusion: the defect is confined to one expression in one function. No same-file identical defect exists elsewhere in the gate or its helpers.

### 1.4 Shared helper search

No shared helper returns "value is the JSON boolean true" for hooks:

- `Get-EditReplaceAllFlag` (`enforce-completion-helpers.ps1`) and `Get-FileSizeLimitReplaceAllFlag` (`enforce-file-size-limit.ps1`) accept the string `"true"` case-insensitively, which contradicts the issue's expected behavior (only the JSON boolean `true`).
- The strict idiom `(($v -is [bool]) -and $v)` appears inline in `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1`, `OrchestratorStateRoutingContract.psm1`, and `OrchestratorStateRoutingMatrix.psm1` (module-internal, not dot-sourced by the gate), and in the Codex gate (`Test-CodexChildMergeReady`, below).

### 1.5 Codex copy

`.codex/hooks/enforce-epic-merge-gate.ps1`, function `Test-CodexChildMergeReady`, is already strict (verbatim):

```powershell
$properties -contains 'epic_mode' -and
$Checkpoint.epic_mode -is [bool] -and
[bool]$Checkpoint.epic_mode -and
```

It is pinned by `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1`, context `Test-CodexChildMergeReady requires a boolean epic_mode and a green step 9`, row `reports not ready when epic_mode is the string true rather than the boolean`. The Codex gate is not byte-pinned to the Claude gate (different structure; only `enforce-epic-merge-gate-command.ps1` is described as byte-identical across runtimes). `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` lists the Codex gate by path only. Decision: the Codex gate is out of scope; it has no defect and no change. The fix brings the Claude branch 1 into agreement with the Codex branch 1.

## 2. Candidate Approaches

### A. Inline strict test in `Test-ChildCheckpointAllowsEpicMerge` (recommended)

Replace the condition with:

```powershell
if ($props -notcontains 'epic_mode' -or -not (($Checkpoint.epic_mode -is [bool]) -and $Checkpoint.epic_mode)) {
```

- Advantages: one-line change, same line count; same idiom as the green-CI sibling and the Codex gate; touches one production file plus its bundled mirror (two PowerShell production files, inside the direct-mode batch budget of three).
- Limitations: none material; the idiom is repeated rather than shared, as it already is across the repository.

### B. New shared helper (for example `Test-EpicMergeGateJsonTrue`) in `enforce-epic-merge-gate-green-ci.ps1` or a new helper file

- Rejected: one call site in the gate; it adds a second production file plus its mirror (four PowerShell production files, which exceeds the direct-mode batch budget), and a new file would need pack-manifest entries and dependency-closure coverage (`test_push_down_pack_manifest_dependency_closure.py`). The existing green-CI predicate tests "JSON false", not "JSON true", so it cannot be reused directly.

### Rejected alternatives (summary)

- Accept `"true"` strings case-insensitively (the `Get-EditReplaceAllFlag` pattern): contradicts the issue's expected behavior and the Codex gate.

## 3. Behavior Semantics

Branch 1 after the fix:

- Enters (subject to the unchanged `step9_status == "passed"` and `Test-ChildCheckpointPrGateBinding` checks) only when `epic_mode` is present and is `System.Boolean` `$true`.
- Declines when `epic_mode` is absent, JSON `null`, JSON `false`, any string (including `"true"`, `"false"`, `"0"`, `"no"`, `""`), any number (`1`, `0`), an object, or an array.
- A decline falls through to branches 2, 3, 3b, 4, and the docs-only branch exactly as today. For a checkpoint with `epic_mode: "false"`, branch 3b also declines (`Test-EpicMergeGateGreenCiNotParallel` fails closed on any non-boolean), so such a checkpoint reaches a deny unless branch 2, 3, or 4 allows it. This is the issue's expected outcome: a malformed marker is not treated as either mode.
- Deny reason text: unchanged. The final deny string in `Invoke-EpicMergeGateDecision` (containing "epic_mode == true") is asserted verbatim in four test files (`enforce-epic-merge-gate.MergeQueue.Tests.ps1`, `.DocsOnly.Tests.ps1`, `.Authorization.Tests.ps1`, `.GreenCiDecision.Tests.ps1`); the fix must not edit it.
- No `gh` or `git` call is added; branch 1 stays checkpoint-only.

## 4. Requirements Mapping and File Set

### 4.1 Production changes

1. `.claude/hooks/enforce-epic-merge-gate.ps1`
   - `Test-ChildCheckpointAllowsEpicMerge`: the one-line condition change in section 2A.
   - `Test-ChildCheckpointAllowsEpicMerge` comment-based help: add a `.DESCRIPTION` stating that `epic_mode` must be the JSON boolean `true` and that a string or number (for example `"false"`) declines (issue #1001).
   - Script `.DESCRIPTION`, condition 1: reword "epic_mode == true" to state the JSON boolean `true` (help text only).
2. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`: byte-identical copy of file 1. Both copies are currently 476 logical lines and both contain the same defect expression and help text (verified by search); byte equality is pinned by `test_bundled_claude_payload_contains_all_repo_runtime_contracts` in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

No pack manifest changes: the file already exists in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (search hit), and no file is added. `test_push_down_codex_and_agents_resource_contracts.py` is unaffected because no `.codex` or `.agents` file changes.

### 4.2 Test changes

3. New file `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1` (follows the `enforce-epic-merge-gate.<Topic>.Tests.ps1` naming of the existing suites). Rationale for a new file instead of extending `enforce-epic-merge-gate.Tests.ps1`: that file is 471 logical lines and the added rows would cross the 500-line guidance tier.

   Proposed rows (no test code here):
   - Unit rows on `Test-ChildCheckpointAllowsEpicMerge`, each with `step9_status: "passed"` parsed through `ConvertFrom-EpicMergeGateJson -Raw '<json>'` (in-memory, no file): `epic_mode` JSON `true` returns true; JSON `false`, `"false"`, `"true"`, `"0"`, `1`, `null`, and absent each return false. The `"false"` and `"true"` rows fail before the fix.
   - Decision rows through `Invoke-EpicMergeGateDecision` for `gh pr merge 42 --merge` with a child checkpoint `{"epic_mode":"false","step9_status":"passed","pr_gate":{"pr_number":42}}` and the same with `"true"`: permission decision `deny` with reason matching `EPIC_MERGE_GATE_BLOCKED`; JSON `true` row: `allow` (control). The `"false"` and `"true"` decision rows fail before the fix (today they allow).
   - Decision row: `"epic_mode":"false"` with a fully green standalone checkpoint (`ci_gate.conclusion: "success"`, `ci_gate.head_sha`, `pr_gate.pr_number: 42`) denies and never calls `Get-EpicMergeGateLivePrHeadSha` (`Should -Invoke ... -Times 0 -Exactly`), proving branch 3b's fail-closed handling still applies after branch 1 declines.

   Test seams to reuse (all present in `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` `BeforeAll`): dot-source the hook; `. (Join-Path $PSScriptRoot 'EpicStateIsolation.Baseline.Helpers.ps1')` and the `Invoke-EpicStateInterceptionProbe` baseline row; import `WorktreeItemResolution.psm1` and `WorktreeRunResolution.psm1` and mock `Get-WorktreeItemCheckpointText`, `Get-WorktreeItemLiveRoot`, `Get-WorktreeRunCheckpointText` with `-ModuleName`; mock `Get-ChildOrchestratorCheckpointContent`, `Get-EpicOrchestratorCheckpointContent`, `Get-ParallelOrchestratorCheckpointContent` to return JSON text; mock `Get-EpicMergeGateSessionWorktreeRoot`, `Resolve-EpicMergeGateItemTarget` (Status `SessionRoot`), `Resolve-EpicMergeGateRunTarget` (Status `NoTarget`); mock `Invoke-DocsOnlyGhExe`, `Invoke-DocsOnlyGitExe`, and `Get-EpicMergeGateLivePrHeadSha`. Synthetic roots use `Join-Path '/synthetic-worktrees' '<name>'` (no drive letter, Linux-safe). The envelope is built in memory with `ConvertTo-Json`.

### 4.3 Test disposition table

| Test file | Rows touching branch 1 / `epic_mode` | Non-boolean `epic_mode` fixture? | Disposition |
|---|---|---|---|
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | Context `allow via child-feature checkpoint ...` (JSON `true`); context `Test-ChildCheckpointAllowsEpicMerge helper (direct branch coverage)` (null, JSON `false`, JSON `true` with and without `step9_status`); seam rows reading `{"epic_mode":true}` | No | Unchanged: every fixture is a JSON boolean or null, outcomes identical |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1` | `branch 1 still allows epic_mode true ...`; `Test-ChildCheckpointAllowsEpicMerge still returns false for epic_mode false` | No | Unchanged: outcomes identical. Its `.DESCRIPTION` calls the function "unedited" in the #997 context; the statement concerns #997's scope and the rows still pass |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1` | Child fixtures `{"epic_mode":true,...}` | No | Unchanged |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1` | `$script:ChildPassed` and child fixtures with JSON `true` | No | Unchanged |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCi.Tests.ps1` | `Test-EpicMergeGateGreenCiNotParallel` / `Test-ChildCheckpointGreenCiRecorded` rows incl. `'false'` and `1` | Yes (green-CI function only) | Unchanged: the green-CI file is not edited |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiDecision.Tests.ps1`, `.MergeQueue.Tests.ps1`, `.DocsOnly.Tests.ps1`, `.Authorization.Tests.ps1` | Assert the final deny string containing "epic_mode == true" | No | Unchanged: deny string is not edited |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1`, `.TriggerScoping.Tests.ps1`, `.Coverage.Tests.ps1` | No `epic_mode` fixture | No | Unchanged |
| `tests/scripts/claude-hooks/hook-dependency-failure.*.Tests.ps1`, `session-root-reads-850.Constraints.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, `hook-command-consumers.Issue824.Tests.ps1` | Reference the gate file; Issue824 fixture uses JSON `true` for the pr-author hook | No | Unchanged |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-*.Tests.ps1`, `epic-execution-gates.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1` | Codex gate only | Codex decision-surface has `"true"` (already strict) | Unchanged: Codex files not edited |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Mirror byte equality | n/a | Unchanged; must pass after mirror update |
| New `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1` | Regression rows in 4.2 | Yes (by design) | Added |

Search basis: `epic_mode` across `tests/`, plus a regex search for non-boolean JSON or hashtable `epic_mode` values (`epic_mode":"`, `epic_mode":<digit>`, `epic_mode = '<...>'`, `epic_mode = <digit>`) across `tests/`. The only non-boolean fixtures found are in `enforce-epic-merge-gate.GreenCi.Tests.ps1` (`'false'`, `1`) and the Codex decision-surface suite (`"true"`).

### 4.4 Other consumers of `epic_mode` (report only; not in the delegated scope)

No Python, TypeScript, or PowerShell validator constrains `epic_mode` to a boolean: a search for `epic_mode` in `scripts/**/*.py`, `scripts/**/*.ps1|psm1`, `extensions/drm-copilot/src/**/*.ts`, `.claude/lib/**`, and any `*.schema.json` found only a comment in `.claude/lib/ci-gate/Invoke-CiGateParser.ps1`. The Python test `test_epic_mode_checkpoint_with_step9_passed_validates` and the Pester row `passes base validation for an epic_mode checkpoint recording step9_status passed` set JSON `true` only; the type is not validated.

Hooks outside the gate that read `epic_mode`:

- `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, `Test-EpicBaseBranchOverride`: the identical expression `-not [bool]$checkpoint.epic_mode`. Effect of a string `"false"`: the `--base <integration_branch>` requirement is enforced on `gh pr create` (stricter, fail-closed direction; it can deny a standalone PR creation). Different file, so outside the delegated scope; the issue's "Suspected Cause" asks to check sibling hooks for the same cast, so this is surfaced for an orchestrator decision. Fixing it here adds two more PowerShell production files (file plus its bundled mirror), which takes the item to four and exceeds the direct-mode batch budget (`POWERSHELL_LARGE_PATH_REQUIRED`) unless the run uses a large/remediation route. File size 144 lines.
- `.claude/hooks/enforce-model-routing-receipt.ps1`: `$Checkpoint.epic_mode -eq $true`. PowerShell coerces the right operand to the left operand's type, so `"true"` (case-insensitive string compare with `"True"`) and `1` count as epic and relax the autoclose-line requirement; `"false"` does not. Different defect shape; report only.
- `.codex/hooks/enforce-epic-wave-barrier.ps1`: already strict (`-isnot [bool]` check).

Recommendation: keep #1001 to the merge gate as delegated. The orchestrator decides whether the `epic-base-branch` cast is fixed inside this item (remediation cycle, with a route that lifts the batch cap) or filed separately; the `-eq $true` coercion in the model-routing hook is a distinct defect class.

## 5. File Sizes (logical lines)

| File | Lines | Tier after change | In `config/file-size-baseline.json` |
|---|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 476 | about 478 to 480 with the help additions; below 500 guidance | No |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | 476 | same as above | No |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1` (new) | 0 | expected under 200 | No |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` (not edited) | 471 | n/a | No |

The baseline lists only `scripts/dev_tools/agentic_sync.py`. Counts are per-line search counts (a trailing terminator adds no line). The help additions must keep the hook below 500 lines; a budget of at most 23 added lines is available.

## 6. Coverage and CI

- `config/poshqc-coverage.json` roots include `.claude/hooks`, so the hook is in the PowerShell coverage population (line threshold 85%, no branch gate for Pester). The bundled copy under `extensions/` is outside the listed roots.
- The changed line is executed by the existing `Test-ChildCheckpointAllowsEpicMerge` rows; the new rows exercise both outcomes of the strict test.
- CI: `poshqc / PowerShell hook suites (Linux)` runs `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` on `ubuntu-latest` without coverage; the shard jobs `poshqc / PowerShell QC shard 1..3` run the scan folders on `windows-latest` with coverage, and the aggregator `poshqc / PowerShell QC` checks shard completeness against Pester discovery. The new test file is assigned to a shard automatically. `quality-checks7` runs the Python mirror contract tests.

## 7. Documentation and Brief Impact

- `.claude/skills/execution-environment/SKILL.md`: no stated fact changes (no CI job, required context, tool route, or batch-budget rule changes). No brief update task is needed.
- `.claude/rules/orchestrator-state.md`, `## Green-CI standalone merge (issue #997)`, step 3 already states the JSON-false requirement for the green-CI branch. The rule does not describe branch 1's value type, so no rule edit is needed. No `.github/instructions/*` file mentions `epic_mode`.
- Doc touch is limited to the hook's own comment-based help (script `.DESCRIPTION` condition 1 and the function help), mirrored byte-identically.

## 8. Recommended Minimal Fix (summary)

- Change one expression in `Test-ChildCheckpointAllowsEpicMerge` to the strict idiom `(($Checkpoint.epic_mode -is [bool]) -and $Checkpoint.epic_mode)`; update the function and script help text; copy the file byte-identically to the bundled mirror.
- Add `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1` with the rows in 4.2.
- Exact write set: `.claude/hooks/enforce-epic-merge-gate.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`; `tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1`; plus feature-folder evidence under `docs/features/active/2026-10-30-merge-gate-epic-mode-string-false-treated-as-true-1001/evidence/<kind>/`.

## 9. Risks

- Behavior tightening: a live checkpoint that today records `epic_mode` as a string `"true"` or the number `1` loses branch-1 merge permission. No writer of such a value was found (all fixtures and the Python and Pester validator tests use JSON `true`), and the Codex gate already rejects it. Likelihood low; mitigation: the deny still points to the standalone and green-CI paths.
- Mirror drift: editing one copy only fails `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Mitigation: write the mirror from the same content and run that test.
- Hook execution context: isolated subagents run `main`'s hook copy, so branch behavior is proven by Pester only.
- Scope creep: the `epic-base-branch` cast is the same pattern in a different file; including it changes the batch-budget route (see 4.4).

## Numeric Derivation Evidence

No numeric `spec.md` acceptance criterion is proposed by this research. Counts in this document (line counts, file counts) are descriptive and are not proposed as acceptance assertions.

## Automation Feasibility

No human interaction is required. The change is a code edit, a mirror copy, and Pester and Pytest runs, all executable by the executor through the PoshQC MCP tools or a `sh`-launched PowerShell 7 script under `SCRATCH`, and `poetry run python -m pytest` for the mirror contract. The only decision point is the orchestrator's choice on the out-of-scope `epic-base-branch` finding in 4.4, which does not need the user.

## Pre-Mortem

- Review checklists: a reviewer may flag that the issue asks to check sibling hooks and the identical cast in `enforce-pr-author-skill.epic-base-branch.ps1` is not fixed. Mitigation: the plan records the finding and the orchestrator's disposition (in-item remediation with a large route, or a separate issue) explicitly, and states why the Codex gate is unchanged (already strict, pinned by its decision-surface suite).
- Coverage: the changed line is in `.claude/hooks` (in the coverage population); a run that does not load the new suite could still pass but not prove both outcomes. Mitigation: read per-file line coverage for `enforce-epic-merge-gate.ps1` from `artifacts/pester/powershell-coverage.xml` after a branch-current `Invoke-PoshQCTest` run and confirm it does not fall below the pre-change figure.
- Mirror parity: the bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` must be byte-identical. Mitigation: a dedicated task copies the file and runs `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; no execution-environment brief update is needed because no brief fact changes.
- File size: the hook is at 476 lines, 24 below the 500 guidance tier, and `enforce-epic-merge-gate.Tests.ps1` is at 471. Mitigation: help additions are capped so the hook stays below 500, and new rows go into a new test file rather than the 471-line suite.
- Test isolation: the new suite must create no files and must not leak mocks or script-scope state into other merge-gate suites. Mitigation: all checkpoints are in-memory JSON strings, mocks are declared in `BeforeAll`/`It` scope, synthetic roots use `/synthetic-worktrees`, and the seeded shuffled multi-seed Pester run plus a fresh single-process run over `tests/scripts` are recorded under `evidence/regression-testing/`.
- CI-only behavior: the Linux hook-suite job runs the new file on a case-sensitive file system. Mitigation: use `Join-Path` with forward-slash relative paths, exact file-name case for the dot-sourced hook and helpers, and no drive letters or backslash literals; read no gitignored `artifacts/` state.
- Evidence: fail-before must be shown for the `"false"` and `"true"` rows. Mitigation: run the new suite against the unfixed hook first and record the failing run under `evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` (read from the JUnit file, since `Invoke-Pester` without `-EnableExit` exits 0), then record the passing run after the fix; no absolute paths in any artifact.
