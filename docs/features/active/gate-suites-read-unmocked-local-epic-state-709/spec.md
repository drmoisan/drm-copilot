# gate-suites-read-unmocked-local-epic-state (Spec)

- **Issue:** #709
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-26
- **Status:** Ready for planning (autonomous mode; no operator review)
- **Version:** 1.0
- **Work Mode:** full-bug
- **Research:** `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/research/research.2026-09-26T23-00.md`

## Context

- Summary: Seven Pester suites for the gate-1 (`enforce-pr-author-skill`), gate-3 (`enforce-model-routing-receipt`) and gate-4 (`enforce-orchestration-preimplementation-gate`) hooks call `Resolve-EpicScopeCheckpoint` in `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` without mocking its read seam `Get-EpicScopeCheckpointText`. The resolver ascends from the current directory to the checkout root and reads `artifacts/orchestration/epic-orchestrator-state.json`. That file is gitignored, so its presence on a developer machine can change suite outcomes. Source finding: #663 code review CR-4 and #663 `evidence/other/follow-ups.md`, item 6.
- Observed environment(s): any developer checkout that contains a leftover `artifacts/orchestration/epic-orchestrator-state.json`, most realistically an epic coordinator or integration worktree. CI (`.github/workflows/_poshqc.yml`, `windows-latest`) has no such file, so CI results are not affected.
- Customer impact and severity: Low. The defect affects test hermeticity only; no production behavior is wrong. Gate-4 suites are the most exposed: when the local file's `integration_branch` equals the checkout HEAD branch, allow rows become denies and assertions on single-feature deny wording fail. Gates 1 and 3 perform the read on every row with a branch signal, but an outcome change requires the local `integration_branch` to equal a fixture branch literal.
- First observed: 2026-09-25, during the #663 code review (`EpicScopeResolution` introduced by #663). Impacted version: the current `main` at commit `2dce111e` (extension 1.1.12).

## Repro & Evidence

- Steps to reproduce:
  1. Place an `artifacts/orchestration/epic-orchestrator-state.json` at the checkout root whose `integration_branch` equals the checkout's HEAD branch.
  2. Run `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` with `Invoke-Pester`.
  3. Observe that rows expecting allow (research section 1 cites lines 98, 162 and 213) or single-feature deny wording (lines 66-67) fail.
- Expected vs actual behavior: Expected, suite results are independent of local gitignored epic state. Actual, the suites read that file through the unmocked seam.
- Logs/screenshots/error snippets: #663 `code-review.2026-09-25T20-26.md` CR-4 (lines 42 and 109); research section 1, "Exposure severity".
- Frequency / determinism: data-dependent. Deterministic given the content of the local file; absent the file, results match CI.

## Scope & Non-Goals

- In scope:
  - Adding an isolating mock of `Get-EpicScopeCheckpointText` to the seven suites that reach `Resolve-EpicScopeCheckpoint` without one (listed under "Files/modules to change").
  - Adding one new standalone regression file that verifies the mock is present in each of the seven suites and that the mock is sufficient to prevent the epic-state read.
- Out of scope / non-goals:
  - Any production code change, including `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`, the gate hooks, and their push-down mirrors under `extensions/drm-copilot/resources/`.
  - An environment-variable or injectable-root seam in production code.
  - The three `*.EpicScope.Tests.ps1` suites and `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`, which already isolate the seam where they reach it.
  - The ten non-reaching suites in the hook family (research section 2, rows 1-6, 9, 15-17).
  - The four hooks that read the epic checkpoint through their own relative-path seam (`.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`) and their suites. Recorded as a follow-up (D8).
- Explicitly excluded systems: `.codex/hooks/` and `tests/scripts/codex-hooks/`. No `.codex` hook imports or calls `EpicScopeResolution` (research section 1, zero matches for `EpicScope` under `.codex/`).

## Root Cause Analysis

- Confirmed root cause: `Resolve-EpicScopeCheckpoint` (`EpicScopeResolution.psm1:273-360`) calls `Find-WorktreeResolutionRoot -Path $SessionRoot`, where `$SessionRoot` is `(Get-Location).Path` at every hook call site, then reads `<root>/artifacts/orchestration/epic-orchestrator-state.json` through `Get-EpicScopeCheckpointText` (line 323). The seven suites invoke the hook decision functions from the checkout or from `tests/fixtures/worktree-resolution/...`, whose ascent reaches the checkout root, and none of them mocks `Get-EpicScopeCheckpointText`.
- Signals/evidence: research section 2 table (reach analysis per suite) and Numeric Derivation Evidence claims N1 (17-suite family) and N2 (7 reaching, unmocked suites), each derived by two independent search strategies with identical member sets.
- Affected components (tests only):
  - Gate 1 call site: `.claude/hooks/enforce-pr-author-skill-helpers.ps1:344` (`Get-PrAuthorBypassReason`), reached when `--body-file`, `$ContextExists`, and a branch signal are present.
  - Gate 3 call site: `.claude/hooks/enforce-model-routing-receipt.ps1:247`, reached for a gated `subagent_type` with a branch signal.
  - Gate 4 call site: `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:117`, reached for every implementation-classified path or command leg (`-MatchWorktreeHead` is always set).

## Proposed Fix

### Design summary (what changes where):

Test-only fix. In each of the seven reaching suites, inside the existing top-level `BeforeAll` and directly after the hook dot-source or module-import lines, add:

```powershell
Import-Module (Join-Path <claude root> 'lib/worktree-resolution/EpicScopeResolution.psm1')
Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
```

`<claude root>` is the path expression each suite already uses to locate `.claude/`. The `Import-Module` omits `-Force` so the suite binds to the module instance the hook loaded, following the precedent in the EpicScope suites. Add one new standalone file, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`, containing a structural guard and a resolver-level seam-sufficiency proof.

### Boundaries and invariants to preserve:

- No existing `It`, `Context`, `Describe`, assertion, or fixture row in the seven suites is changed, reordered, or reformatted.
- Expected outcomes of the seven suites do not change: a `$null` seam return reproduces the CI condition (no file present).
- The three `*.EpicScope.Tests.ps1` suites are not edited and keep their pass counts.
- No production file and no push-down mirror is edited, so bundle-parity tests are unaffected.

### Dependencies or blocked work:

- No blocking dependency. Sibling items #707, #708, #710 and #713 may merge in either order relative to this item (D6).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Edited (additive lines inside the existing top-level `BeforeAll` only):

1. `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`
2. `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`
3. `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`
4. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`
5. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`
6. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`
7. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`

Created:

8. `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`

Insertion points are located by content anchor (the hook dot-source or `Import-Module` lines within the top-level `BeforeAll`), not by line number. The research line references (for example `BeforeAll` at lines 22-24 of the TargetResolution suite) are informational only.

#### Functions/classes/CLI commands impacted:

- Mocked in the seven suites: `Get-EpicScopeCheckpointText` in module scope `EpicScopeResolution`.
- Exercised by the new regression file: `Resolve-EpicScopeCheckpoint`, with `Find-WorktreeResolutionRoot`, `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, and `Get-EpicScopeCheckpointText` mocked in `EpicScopeResolution` scope.
- No production function signature or behavior changes.

#### Data flow and validation changes:

- With the mock in place, `Resolve-EpicScopeCheckpoint` returns `IsEpicScope = $false` with reason `epic-checkpoint-absent-or-unparseable` (`EpicScopeResolution.psm1:324-326`) before `Get-EpicScopeWorktreeHeadBranch` or `Test-EpicScopeMergeInProgress` run. This also removes gate 4's HEAD and `MERGE_HEAD` probes from the seven suites.
- The gate-4 delegation-leg read (`Get-EpicCheckpointContent`) is not reached by the seven suites through a path or command leg; it is already isolated by `-EpicCheckpointRaw` binding in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` (research section 2, row 16).

#### Error handling and logging updates:

- None. No production error path or log message changes.

#### Rollback/feature-flag considerations (if applicable):

- Rollback is a revert of the eight test-file changes. No feature flag applies.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

New regression file, two `Describe` blocks. The file loads no hook.

1. Structural guard (expect-fail before the fix).
   - Iterates an explicit list of the seven repository-relative suite paths (no glob), one `It` per path via `-ForEach`, so a failure names the suite.
   - Resolves each path from the repository root derived from `$PSScriptRoot`, and parses the committed file with `[System.Management.Automation.Language.Parser]::ParseFile`.
   - Asserts that the file contains a `CommandAst` named `Mock` that targets `Get-EpicScopeCheckpointText` (positional or `-CommandName`), carries `-ModuleName EpicScopeResolution`, has a script-block body consisting of exactly `$null`, and is nested in the file's outermost `BeforeAll` script block (the file-level `BeforeAll`, or the first-level `Describe` `BeforeAll` where the suite has no file-level block).
   - Assertion messages name the suite path and the missing property.
2. Seam-sufficiency proof (passes before and after the fix).
   - Imports `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` with `-Force` (the file loads no hook, so there is no instance to bind to).
   - In `EpicScopeResolution` scope, mocks `Find-WorktreeResolutionRoot` to return `/synthetic-worktrees/local-checkout`, `Get-WorktreeResolutionGitEntryKind` to return `File`, `Get-WorktreeResolutionGitFileText` to return an in-memory hostile ready epic payload whose `integration_branch` is `epic/hostile-integration`, and `Get-EpicScopeWorktreeHeadBranch` to return `epic/hostile-integration`.
   - Control (non-vacuity): with only the hostile lower seams, `Resolve-EpicScopeCheckpoint` returns `IsEpicScope = $true` for each gate call shape: gate 1 (`gh pr create --head epic/hostile-integration --body-file artifacts/pr_body_1.md`), gate 3 (a prompt carrying `branch: epic/hostile-integration`), and gate 4 (`git add scripts/powershell/Sample.ps1` with `-MatchWorktreeHead`, plus a `-WorktreeSelector` variant).
   - Treatment: adds `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }` and asserts, for each shape, `IsEpicScope = $false`, `Reason = 'epic-checkpoint-absent-or-unparseable'`, `Get-WorktreeResolutionGitFileText` invoked 0 times for a path matching `*epic-orchestrator-state.json`, and `Get-EpicScopeWorktreeHeadBranch` and `Test-EpicScopeMergeInProgress` each invoked 0 times.

#### Required configuration keys and defaults:

- None. The new file is discovered by the existing Pester configuration (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `Run.Path` includes `tests/scripts`).

#### Backward-compatibility expectations:

- No public API, hook contract, or configuration schema changes. Test names and outcomes in the seven edited suites are unchanged.

#### Performance constraints (latency/throughput/memory):

- No measurable constraint. The mock removes filesystem probes from the edited suites; the new file performs seven AST parses and in-memory resolver calls.

## Design Decisions

Autonomous mode: each decision below is adopted without operator review.

- **D1 - Isolation seam.**
  - Options: (a) per-suite module-scoped `Mock Get-EpicScopeCheckpointText`; (b) a shared dot-sourced helper such as `Set-EpicScopeCheckpointAbsent` in a new helpers file; (c) a production seam (environment variable or injectable root).
  - Adopted: (a).
  - Rationale: researcher recommendation (approach A). It follows the precedent in `tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` and `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`. Option (b) still requires a dot-source line and a call in each suite, so it saves no edits and adds a file. Option (c) changes T1-class enforcement code and its push-down mirrors for a test-hygiene defect, contradicts the module's "no environment read" contract (`EpicScopeResolution.psm1:26`), and would add a bypass surface to an enforcement hook.

- **D2 - Mock placement.**
  - Options: (a) the existing top-level `BeforeAll`; (b) per-`Describe`/`Context` `BeforeAll` or `BeforeEach`.
  - Adopted: (a), directly after the hook dot-source or module-import lines.
  - Rationale: a Pester `BeforeAll` mock applies to every child block, so one insertion covers every reaching row, including rows added later by siblings. The edit is a single contiguous hunk per file, which limits merge conflicts (D6). The import must follow the hook dot-source so the hook's `-Force` import has already loaded the module instance the mock binds to.

- **D3 - Mock return value.**
  - Options: (a) `$null`; (b) empty string; (c) a fixed non-epic payload.
  - Adopted: (a).
  - Rationale: `$null` is what the real seam returns when the file is absent (`EpicScopeResolution.psm1:120-138`), which is the CI condition the suites' expected outcomes already encode. It short-circuits at line 324-326 before the HEAD and `MERGE_HEAD` probes. An empty string relies on the parse-failure path instead of the absence path, and a fixed payload would introduce test data that must be kept consistent with every fixture branch literal.

- **D4 - Regression check shape.**
  - Options: (a) a new standalone file with a structural guard and a resolver-level proof; (b) hermeticity assertions added inside each of the seven edited suites.
  - Adopted: (a), `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`.
  - Rationale: researcher recommendation (section 5). The structural guard fails before the fix and names each unprotected suite; the resolver-level proof shows with a hostile injected payload that the one mock blocks the file read, without temporary files or gitignored state. A standalone file loads no hook, so it cannot collide with hook function names and is not edited by any sibling. Reading tracked source files for a structural check follows `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`. Option (b) enlarges each suite's diff and increases merge-conflict exposure.

- **D5 - Codex suites out of scope.**
  - Options: include `tests/scripts/codex-hooks/` suites; exclude them.
  - Adopted: exclude.
  - Rationale: no `.codex/hooks` file imports or calls `EpicScopeResolution` (research section 1). Codex gates read the epic checkpoint through their own relative-path reads; epic-scope work for Codex gates 4 and 5 is tracked by #707.

- **D6 - Merge-order independence with sibling items.**
  - Siblings: #710 (preimplementation-helpers-backslash-chain-operator) and #713 (preimplementation-gate-blocks-attribution-trailers), which are likely to edit gate-4 suites such as `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` or `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`; #707 (codex-gates-4-5-lack-epic-scope), which touches `.codex` only; #708 (completion-consistency-edit-reads-relative-checkpoint), which touches the completion-consistency hook. The #710 and #713 overlap is inferred from item names and the #663 follow-up list; it was not verified against their branches.
  - Options: (a) additive `BeforeAll` lines plus a new standalone file; (b) restructuring suite setup or adding per-row mocks.
  - Adopted: (a).
  - Rationale: sibling changes that add `It` rows or `Context` blocks modify other hunks, so a textual conflict is limited to a sibling that edits the same `BeforeAll` lines. A top-level `BeforeAll` mock also covers any rows a sibling adds. The new file is not touched by any sibling. The plan must re-locate each insertion point by content anchor (the hook dot-source or `Import-Module` line in the top-level `BeforeAll`), not by line number, and must not reflow, reorder, or reformat existing lines. If a sibling merges first, the executor rebases and re-anchors; if this item merges first, siblings inherit the mock.

- **D7 - Work mode.**
  - Options: `minor-audit` (carried in the GitHub issue body); `full-bug` (dispatch instruction).
  - Adopted: `full-bug`, persisted in `issue.md`.
  - Rationale: the dispatch instruction for this run specified `full-bug`. Under `full-bug`, `spec.md` is the sole acceptance-criteria source; no `user-story.md` is created. The acceptance criteria below preserve and refine the five criteria in `issue.md`.

- **D8 - Other epic-reading hooks recorded as a follow-up.**
  - Options: extend scope to `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1` and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` suites; record them as a follow-up.
  - Adopted: follow-up.
  - Rationale: these hooks do not use `EpicScopeResolution`; they read through their own relative-path seam, and whether every row in their suites mocks that seam was not verified (research section 2). They fall outside issue #709's stated scope (gates 1, 3 and 4).

- **D9 - Explicit path list in the structural guard.**
  - Options: an explicit seven-path list; a glob over the hook family.
  - Adopted: explicit list.
  - Rationale: researcher recommendation. A glob would also select the ten non-reaching suites and require the mock where it is not needed, widening the change and its overlap with siblings. Known limit: a future reaching suite is not guarded automatically; this is recorded under Risks.

- **D10 - No mock of `Find-WorktreeResolutionRoot` in the edited suites.**
  - Options: mock the root resolver to a synthetic root as well; leave it unmocked.
  - Adopted: leave unmocked.
  - Rationale: with the text seam returning `$null`, both the root-found and root-unresolved paths yield `IsEpicScope = $false`, so the root result cannot change an outcome (research section 4, approach D). Omitting it keeps each edit to two lines.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - The Pester version in use is 5.x, in which a `Mock` declared in a `BeforeAll` applies to all child blocks and `-ModuleName` injects the mock into module scope. The four precedent suites rely on the same behavior.
  - Importing `EpicScopeResolution.psm1` without `-Force` after the hook's `-Force` import binds to the hook's module instance (precedent: `enforce-model-routing-receipt.EpicScope.Tests.ps1:15-16`).
- Constraints:
  - Test files remain at or below 500 lines. The new file is expected to be well under that limit.
  - PowerShell change budget: at most three test files per batch; the research proposes three batches (gate-4 `.Tests`/`.TriggerScoping`/`.CommandExemption`; gate-4 `-absolute-paths` plus the gate-1 and gate-3 `WorktreeResolution` suites; gate-1 `TargetResolution` plus the new regression file).
  - The agent-worktree isolation guard denies Bash text containing `pwsh`; Pester runs use the PowerShell tool or the MCP PoshQC tools.
- External dependencies: none beyond Pester, PSScriptAnalyzer, and PoshQC already used by the repository.

## Data / API / Config Impact

- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: none. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its push-down copy are not changed; the new file is discovered through the existing `Run.Path`.

## Test Strategy

- Regression tests to add or update:
  - Add `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` (structural guard and seam-sufficiency proof, as specified under "Inputs/outputs and formats").
  - Update the seven suites listed under "Files/modules to change" with the two-line `BeforeAll` addition only.
- Fail-before evidence:
  - Before any suite edit, run the new file with `Invoke-Pester`. The structural-guard `Describe` must report seven failing `It` rows, one per suite path, each message naming the suite and stating that the `Get-EpicScopeCheckpointText` mock is missing. The seam-sufficiency `Describe` must pass (control and treatment). Record the command, the Passed/Failed totals, and the failing row names under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/`.
  - After the edits, the same run must report zero failures; record it in the same evidence kind directory.
- Unit tests (Pester) for the fixed behavior and boundaries:
  - Control rows prove the hostile payload yields `IsEpicScope = $true` without the mock, so the treatment assertions are not vacuous.
  - Treatment rows cover all three gate call shapes, including the gate-4 `-MatchWorktreeHead` and `-WorktreeSelector` variants.
- Edge cases and negative scenarios:
  - A suite whose mock targets the wrong command, lacks `-ModuleName EpicScopeResolution`, returns something other than `$null`, or is declared outside the outermost `BeforeAll` fails the structural guard.
  - A suite path in the explicit list that does not exist fails the structural guard with a message naming the path.
- Error handling and logging verification: not applicable; no production error path changes.
- Hermeticity requirements (all tests added or edited):
  - Must not create temporary files (no `New-TemporaryFile`, `TestDrive:`, or writes under `$env:TEMP`).
  - Must not depend on gitignored state, including any file under `artifacts/orchestration/` such as `artifacts/orchestration/epic-orchestrator-state.json` or `artifacts/orchestration/orchestrator-state.json`.
  - Must not depend on `origin/main` or any git history; the CI checkout is depth-1.
  - Must not use Windows-only paths or drive letters. Synthetic roots use the POSIX-style `/synthetic-worktrees/...` form; repository files are located from `$PSScriptRoot` with `Join-Path`.
- Unchanged-behavior checks:
  - Before and after the change, run with `Invoke-Pester` over an explicit file list: the seven edited suites and the three `*.EpicScope.Tests.ps1` suites. Passed/Failed/Skipped totals for each must be identical before and after. Record both runs under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baselines/` (before) and `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/` (after).
  - Counts must come from a direct `Invoke-Pester` run; MCP PoshQC summaries carry no per-test output and are not a valid source for count assertions.
- Coverage impact: no production file changes, so there is no coverage delta on production lines and no changed production line requires coverage. Record the baseline and final line coverage of `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` from `artifacts/pester/powershell-coverage.xml` to show no decrease below the 85% line threshold. Branch coverage is not measured for PowerShell.
- Toolchain commands to run (format, lint, test; PowerShell has no type-check stage):
  1. PoshQC format on the eight changed files (repository formatter settings); confirm no untouched line in the seven suites changes.
  2. PSScriptAnalyzer via PoshQC analyze with repository settings; zero errors on the eight changed files.
  3. Pester: direct `Invoke-Pester` over the explicit file list (eight changed files plus the three EpicScope suites), then the full configured run via `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
  Restart from step 1 if any stage fails or modifies a file.
- Manual validation steps: optional. With a local `artifacts/orchestration/epic-orchestrator-state.json` whose `integration_branch` equals the checkout HEAD branch, the seven edited suites pass. This is not an acceptance gate because it depends on gitignored state.

## Acceptance Criteria

- [x] Each of the seven suites `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` imports `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` without `-Force` and declares `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }` in its outermost `BeforeAll`, after the hook load; verified by the structural-guard `Describe` in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` passing.
- [x] The new file `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` exists, and its structural-guard `Describe` failed before the suite edits with one failing row per unprotected suite; verified by the fail-before `Invoke-Pester` record under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/`.
- [x] With a hostile injected epic payload, `Resolve-EpicScopeCheckpoint` returns `IsEpicScope = $true` without the mock (control) and, with `Get-EpicScopeCheckpointText` mocked to `$null`, returns `IsEpicScope = $false` with reason `epic-checkpoint-absent-or-unparseable` and never invokes `Get-WorktreeResolutionGitFileText` for the epic checkpoint path, `Get-EpicScopeWorktreeHeadBranch`, or `Test-EpicScopeMergeInProgress`, for the gate-1, gate-3 and gate-4 call shapes; verified by the seam-sufficiency `Describe` in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` passing.
- [ ] `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` creates no temporary file, reads no gitignored file, does not reference `origin/main` or git history, and contains no drive-letter or Windows-only path; verified by code review of the file and by the file passing in the CI `windows-latest` PoshQC job on a depth-1 checkout.
- [x] The Passed/Failed/Skipped totals of the seven edited suites are identical before and after the change; verified by the before and after `Invoke-Pester` records under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/baselines/` and `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/regression-testing/`.
- [x] `tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1` and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` are unmodified and their Passed/Failed/Skipped totals are identical before and after; verified by `git diff --name-only` against the branch base and by the same before and after `Invoke-Pester` records.
- [x] No production file and no push-down mirror is changed; verified by `git diff --name-only` against the branch base listing only the eight test files named in this spec plus files under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/`.
- [x] PoshQC format reports no changes, PSScriptAnalyzer reports zero errors, and Pester reports zero failures for the eight changed test files, and the full configured Pester run (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) reports zero failures; verified by the toolchain records under `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/evidence/`.
- [x] Line coverage of `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` in `artifacts/pester/powershell-coverage.xml` does not decrease from the baseline run to the final run; verified by the recorded baseline and final coverage values in the feature evidence.

## Risks & Mitigations

- Technical or operational risks:
  - A future suite that reaches `Resolve-EpicScopeCheckpoint` is not covered by the explicit-list structural guard (D9).
  - A sibling item (#710, #713) edits the same `BeforeAll` lines, producing a textual merge conflict (D6).
  - The `Import-Module` without `-Force` binds to a different module instance than the hook if the insertion is placed before the hook load, making the mock ineffective.
  - The #710 and #713 file overlap is inferred, not verified.
- Mitigations and rollbacks:
  - Record the explicit-list limit in the new file's header comment and in the follow-up list.
  - Keep each suite edit to one contiguous two-line insertion anchored by content; rebase and re-anchor on conflict.
  - The structural guard requires the mock inside the outermost `BeforeAll`; the unchanged pass counts and the treatment rows detect an ineffective binding only indirectly, so the executor places the lines after the hook dot-source per D2 and confirms placement in code review.
  - Rollback: revert the eight test-file changes; no production state is affected.

## Rollout & Follow-up

- Release/rollout steps: merge through the standard PR flow; no extension version bump is required because no packaged file changes.
- Post-fix monitoring or clean-up tasks:
  - Follow-up (D8): verify and, if needed, isolate the relative-path epic-checkpoint reads in the suites for `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1` and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
  - Follow-up (D9): consider extending the structural guard when a new suite for gates 1, 3 or 4 is added.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/709
  - Research: `docs/features/active/gate-suites-read-unmocked-local-epic-state-709/research/research.2026-09-26T23-00.md`
  - Source finding: `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/code-review.2026-09-25T20-26.md` (CR-4) and `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md` (item 6)
  - Related items: #707, #708, #710, #713
