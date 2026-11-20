# Research: gate-suites-read-unmocked-local-epic-state (Issue #709)

- Issue: #709
- Branch: bug/gate-suites-read-unmocked-local-epic-state-709
- Work mode: full-bug
- Timestamp: 2026-09-26T23-00
- Source finding: #663 code review CR-4 (`docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/code-review.2026-09-25T20-26.md`, line 42 and line 109) and `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md`, item 6 (line 21). Both were located and read; the findings below were re-verified against the code and do not depend on them.

All paths are repository-relative. Line numbers refer to the worktree based on `origin/main` at commit `2dce111e`.

## 1. Where the epic-state read lives and how it resolves the path

### Definition

| Symbol | Location |
|---|---|
| Module `EpicScopeResolution` | `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (mirrored byte-identically at `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1`) |
| `$script:EpicCheckpointRelativePath = 'artifacts/orchestration/epic-orchestrator-state.json'` | `EpicScopeResolution.psm1:40` |
| `Get-EpicScopeCheckpointText -Path` (read seam, exported) | `EpicScopeResolution.psm1:120-138`. Returns `$null` unless `Get-WorktreeResolutionGitEntryKind -Path` is `File`, then `Get-WorktreeResolutionGitFileText -Path`. |
| `Resolve-EpicScopeCheckpoint` (the only caller of the seam) | `EpicScopeResolution.psm1:273-360`; seam call at line 323 |
| Lower-level seams | `.claude/lib/worktree-resolution/WorktreeResolution.psm1:61-82` (`Get-WorktreeResolutionGitEntryKind`, `Test-Path`) and `:84-99` (`Get-WorktreeResolutionGitFileText`, `Get-Content -Raw`) |
| Branch-signal regex | `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:61` (`--head`, `--branch`, or `branch:` label, case-insensitive) |

No `.codex/hooks` file imports or calls `EpicScopeResolution` (verified by searching `.codex/` for `EpicScope`; zero matches). The Codex gates read the epic checkpoint through their own relative-path reads and are out of scope here.

### Path resolution

`Resolve-EpicScopeCheckpoint` (lines 314-323):

1. `Find-WorktreeResolutionBranchSignal -Text`. If no branch signal and `-MatchWorktreeHead` is not set, it returns `no-branch-signal` **before any filesystem contact**.
2. `Find-WorktreeResolutionRoot -Path $SessionRoot` ascends from the session root to the first level with a `.git` directory or a valid `gitdir:` file (`WorktreeResolution.psm1:228-293`).
3. The checkpoint path is `<root>/artifacts/orchestration/epic-orchestrator-state.json`; one call to `Get-EpicScopeCheckpointText`.
4. With `-MatchWorktreeHead`, a non-null checkpoint leads to `Get-EpicScopeWorktreeHeadBranch` (reads `<gitdir>/HEAD`) and `Test-EpicScopeMergeInProgress` (probes `MERGE_HEAD`).

`$SessionRoot` is always `(Get-Location).Path` at the three hook call sites. No environment variable is read (module header line 26). The ascent from any directory inside a checkout, including `tests/fixtures/worktree-resolution/...`, reaches the checkout root, because git cannot track a path component named `.git` and the fixture tree contains none. The gitignored `artifacts/orchestration/epic-orchestrator-state.json` at the checkout root is therefore the file read.

### Hook call sites

| Gate | Hook file | Import | Call | Reach condition |
|---|---|---|---|---|
| 1 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (dot-sourced by `.claude/hooks/enforce-pr-author-skill.ps1`) | line 48, `-Force` | line 344, inside `Get-PrAuthorBypassReason` | `--body-file` present **and** `$ContextExists` **and** a branch signal in the command |
| 3 | `.claude/hooks/enforce-model-routing-receipt.ps1` | line 55, `-Force` | line 247 | gated `subagent_type` **and** a branch signal in the prompt |
| 4 | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (dot-sourced by the gate at line 24) | line 30, `-Force` | line 117 in `Get-OrchestrationEpicScopeDecision`, invoked from `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:389-394` | any implementation-classified **path or command** leg. `-MatchWorktreeHead` is always set, so there is no branch-signal short-circuit. |

Gate 4 has a second epic-state read: the delegation leg in `Epic mode: true` calls `Get-EpicCheckpointContent` (`enforce-orchestration-preimplementation-gate-epic-scope.ps1:36-46`, `Test-Path`/`Get-Content` on the relative path) unless `-EpicCheckpointRaw` is bound (`enforce-orchestration-preimplementation-gate.ps1:399-401`). Section 2 shows this read is already isolated in every non-EpicScope suite.

### Exposure severity

- **Gate 4 (realistic).** Every implementation-classified path or command row reads the local file. The row becomes epic scope when that file's `integration_branch` equals the checkout's HEAD branch, as it does in an epic coordinator or integration worktree. The decision then comes from `Get-EpicCommandLegReadinessFailure`. The deny reason still begins `PREIMPLEMENTATION_GATE_BLOCKED`, so plain deny assertions still pass. Assertions on the single-feature wording fail, for example `enforce-orchestration-preimplementation-gate.Tests.ps1:66-67` (`route metadata`, `lifecycle readiness`), and allow rows (`:98`, `:162`, `:213`) turn into denies unless epic readiness passes and a merge is in progress.
- **Gates 1 and 3 (read occurs, flip unlikely).** The read runs on every row that has a branch signal. The result changes only if the local `integration_branch` equals a fixture branch literal (`feature/item-701`, `feature/self`, `feature/shared`, `f5-fixture-own`, `f5-fixture-missing`, `f5-fixture-sibling`). This is still a non-hermetic filesystem read.

## 2. Suite inventory: reachability and existing isolation

The complete family is every `tests/scripts/claude-hooks/enforce-{pr-author-skill,model-routing-receipt,orchestration-preimplementation-gate}*.Tests.ps1` except the three `*.EpicScope.Tests.ps1`: 17 files. No `.codex` hook uses `EpicScopeResolution`, so the Codex test suites under `tests/scripts/codex-hooks/` are outside the family. `tests/scripts/claude-runtime/*` and `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` only read the hook files as text; neither calls a decision function.

| # | Suite | Reaches `Resolve-EpicScopeCheckpoint` unmocked? | Evidence | Isolated today? |
|---|---|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | No | No branch signal in any command (case-insensitive search for `--head`, `--branch`, `branch:` returns 0) | n/a |
| 2 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1` | No | same search, 0 | n/a |
| 3 | `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | No | same search, 0 | n/a |
| 4 | `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | No | same search, 0 | n/a |
| 5 | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | No | same search, 0 | n/a |
| 6 | `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | Only in Context `issue #663 epic scope` (lines 123-203) | `--head` at 153, 169, 182, 195 | **Yes**, that context mocks it (lines 130, 142-148). Other contexts have no branch signal. |
| 7 | `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` | **Yes**: rows at 38, 55, 86 | `Get-PrAuthorBypassReason ... --head ... --body-file ... -ContextExists $true` at 48, 65, 92; cwd is the checkout | **No** |
| 8 | `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | **Yes**: every row that uses `$script:OwnBranchCommand` (line 65) or `f5-fixture-missing` (278) | Rows run in `tests/fixtures/worktree-resolution/pr-author/*` through `Invoke-WorktreeResolutionFixtureCall` (`tests/scripts/claude-hooks/WorktreeResolutionFixture.Helpers.ps1:45-78`); the ascent reaches the checkout root | **No** |
| 9 | `tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1` | No | branch-signal search, 0 | n/a |
| 10 | `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | **Yes**: rows with `branch:` prompts (155, 187, 230, 245, 276) | same fixture-cwd mechanism | **No** |
| 11 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | **Yes**: every implementation path or command row (for example 57, 98, 112, 123, 135, 162, 206, 213, 225, 290, 300) | Describe-level `BeforeAll` dot-sources the gate (line 7); no mocks in the file | **No** |
| 12 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | **Yes**: the deny rows (163-330) | `BeforeAll` at 46-48 | **No** |
| 13 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | **Yes**: the deny rows (165-360) | `BeforeAll` at 16-18 | **No** |
| 14 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | **Yes**: `ImplementationDenyCases` (215) and the case rows (207) | `BeforeAll` at 140-142 | **No** |
| 15 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | No | Its one decision call (154) is an Agent payload, so no path or command leg | n/a |
| 16 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | No | Every decision call is an Agent payload. Epic-mode rows bind `-EpicCheckpointRaw` (397, 410, 486), and line 483 shadows `Get-EpicCheckpointContent` to throw. The delegation-leg epic read is already isolated. | n/a (delegation read isolated) |
| 17 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | No | Hashes files only; loads no hook | n/a |

Seven suites reach the read without a mock: rows 7, 8, 10, 11, 12, 13, and 14.

### Out-of-scope candidates (reported only)

These hooks read `artifacts/orchestration/epic-orchestrator-state.json` through their own relative-path seam (`Test-Path` plus `Get-Content`), not through `EpicScopeResolution`:

- `.claude/hooks/enforce-epic-merge-gate.ps1:64,97-100`
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:70,90-93`
- `.claude/hooks/enforce-epic-wave-barrier.ps1:38,54-57`
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:49,89-92`

Their docstrings say tests mock the read seam (for example `enforce-epic-merge-gate.ps1:88-89`). Whether every row in their suites does so was not verified. They are candidates for a separate follow-up, not for #709. Gate 4's delegation leg also reads `parallel-orchestrator-state.json` through `Get-ParallelCheckpointContent`; that is parallel state, not epic state, and every parallel-mode row in suite 16 binds `-ParallelCheckpointRaw`.

## 3. Repository precedent for isolating the read

Four suites isolate the seam: `tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1:25,49-53`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1:24-61`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:28-30,72-78`, and `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1:128-149`. They share one pattern:

1. **Dot-source the hook first.** Its `Import-Module ... -Force` loads the module instance.
2. **Then `Import-Module .../EpicScopeResolution.psm1` without `-Force`**, "so the suite binds to the module instance the hook loaded" (`enforce-model-routing-receipt.EpicScope.Tests.ps1:15-16`; `enforce-pr-author-skill.epic-base-branch.Tests.ps1:129`).
3. **`Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { ... }`.** The mock is module-scoped because the caller, `Resolve-EpicScopeCheckpoint`, lives in the same module. Several suites wrap the mock in a helper function (`Set-EpicCheckpointSeam`) that is called from `BeforeEach` or `It`. That shows a mock registered from inside a helper function takes effect.
4. **Invocation-count assertions work against this mock.** `Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly` (`enforce-pr-author-skill.epic-base-branch.Tests.ps1:201`) passes, and its fail-before run is recorded at `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/regression-testing/fail-before-b3.md:80-82`.

The module-level suite `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1:22,48-54` imports with `-Force` because it loads no hook.

## 4. Candidate approaches

### A. Per-suite module-scoped mock in the existing `BeforeAll` (recommended)

In each of the seven reaching suites, directly after the hook dot-source or module imports, add:

```powershell
Import-Module (Join-Path <claude root> 'lib/worktree-resolution/EpicScopeResolution.psm1')
Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }
```

- Advantages: test-only; reuses the exact precedent in section 3. A `$null` return makes `Resolve-EpicScopeCheckpoint` return `epic-checkpoint-absent-or-unparseable` at line 324-326, before `Get-EpicScopeWorktreeHeadBranch` or `Test-EpicScopeMergeInProgress` run, so one mock also removes gate 4's HEAD and `MERGE_HEAD` probes. It reproduces what CI sees today (no file), so expected outcomes do not change. Each edit is additive and 2-3 lines.
- Limitations: seven files are edited, and later suites must remember the mock. The structural guard in section 5 addresses the second point.

### B. Shared dot-sourced helper, for example `Set-EpicScopeCheckpointAbsent` in a new `tests/scripts/claude-hooks/EpicScopeIsolation.Helpers.ps1`

This has the same effect as A with one definition. Rejected as primary: each suite still needs a dot-source line plus a call, so the helper saves no edits. It also adds a file that `WorktreeResolutionFixture.Helpers.ps1` would sit beside with a different contract.

### C. Production seam (environment variable or injectable root)

Rejected. It changes enforcement code (T1-class gate hooks) and its byte-identical push-down mirrors for a test-hygiene defect. The module header states "no environment read" (`EpicScopeResolution.psm1:26`). An environment-variable override in an enforcement hook would also be a bypass surface.

### D. Mock `Find-WorktreeResolutionRoot` to a synthetic root as well

Not required. With the text seam returning `$null`, both the root-found and root-unresolved paths yield `IsEpicScope = $false`, so the root result cannot change any outcome. Leave it unmocked to minimise the change.

## 5. Regression-check design

The design uses no temporary file, no gitignored state, no `origin/main`, and no drive-letter paths. All synthetic roots use the POSIX-style `/synthetic-worktrees/...` form that existing suites already use on Windows runners.

Create one new standalone file, `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`. It loads no hook, so it cannot collide with hook function names and edits no shared block. It has two Describes.

1. **Structural guard (fails before the fix; this is the Phase 2 expect-fail test).** For each suite in an explicit seven-path list, parse the committed file with `[System.Management.Automation.Language.Parser]::ParseFile`. Assert it contains a `CommandAst` named `Mock` that:
   - targets `Get-EpicScopeCheckpointText` (positional or `-CommandName`),
   - carries `-ModuleName EpicScopeResolution`,
   - has a script-block body that is exactly `$null`,
   - is nested in a `BeforeAll` script block.

   Reading tracked source files is permitted; `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` is the precedent. Use one `It` per path via `-ForEach`, so a failure names the suite. Use an explicit list rather than a glob, so the guard matches the seven-suite scope exactly.

2. **Seam-sufficiency proof (passes before and after; shows that mocking the one seam is enough).** Import `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` with `-Force`. In `EpicScopeResolution` scope, mock `Find-WorktreeResolutionRoot` to return `/synthetic-worktrees/local-checkout`. Mock `Get-WorktreeResolutionGitEntryKind` to return `File` and `Get-WorktreeResolutionGitFileText` to return a hostile ready epic JSON whose `integration_branch` is `epic/hostile-integration`. Mock `Get-EpicScopeWorktreeHeadBranch` to return `epic/hostile-integration`.
   - *Control (non-vacuity):* with only the hostile lower seams, `Resolve-EpicScopeCheckpoint` returns `IsEpicScope = $true` for each gate call shape:
     - gate 1: `gh pr create --head epic/hostile-integration --body-file artifacts/pr_body_1.md`
     - gate 3: a prompt carrying `branch: epic/hostile-integration`
     - gate 4: `git add scripts/powershell/Sample.ps1` with `-MatchWorktreeHead`, plus a `-WorktreeSelector` variant
   - *Treatment:* add `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }`. For each shape, assert:
     - `IsEpicScope = $false`, and `Reason` is `epic-checkpoint-absent-or-unparseable`;
     - `Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 0 -Exactly -ParameterFilter { $Path -like '*epic-orchestrator-state.json' }`;
     - `Should -Invoke Get-EpicScopeWorktreeHeadBranch -ModuleName EpicScopeResolution -Times 0 -Exactly`;
     - `Should -Invoke Test-EpicScopeMergeInProgress -ModuleName EpicScopeResolution -Times 0 -Exactly`.

   This shows that `Test-Path` and `Get-Content` interception are not needed. The three gates reach epic state only through `Resolve-EpicScopeCheckpoint` (the call-site table in section 1), and that function reaches the file only through `Get-EpicScopeCheckpointText`.

The two parts together show hermeticity for AC2: every reaching suite carries the mock (part 1), and the mock cuts off every epic-state filesystem path (part 2). The gate-4 delegation-leg read is already bound by `-EpicCheckpointRaw` in suite 16, as listed in section 2.

Unchanged-behaviour check (AC4): run the three `*.EpicScope.Tests.ps1` suites before and after the change and compare pass counts. None of them is edited.

## 6. Merge-order independence

`gh issue view` could not be run: this agent has no shell tool. No feature folder or document for #707, #708, #710, or #713 exists on this branch (search of `docs/` for those numbers returned zero). The overlap analysis below is inferred from the #663 follow-up list (`follow-ups.md`, items 1-8) and the current branch name.

- **#707:** the branch name `bug/codex-gates-4-5-lack-epic-scope-707` matches follow-up item 1. Its targets are `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`, and presumably `tests/scripts/codex-hooks/*`. **No file overlap** with #709.
- **Likely other siblings (unverified mapping):**
  - item 2 touches `.claude/hooks/enforce-completion-consistency.ps1`; no overlap.
  - item 3 touches `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (header text); no overlap.
  - item 7 touches the #663 `spec.md`; no overlap.
  - item 8 touches `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and its three copies. That is the one plausible **test overlap**, because such a fix would likely add rows to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` or `.TriggerScoping.Tests.ps1`, and possibly touch `...-helpers.Parity.Tests.ps1`.

Edit shape that tolerates either merge order:

- Put each suite edit as a 2-3 line insertion **inside the existing top-level `BeforeAll`, directly after the hook dot-source or module-import lines**. Siblings adding `It` rows or `Context` blocks change other hunks, so a textual conflict is limited to a sibling that also edits those exact `BeforeAll` lines.
- Do not reflow, reorder, or reformat any existing line in the seven suites. Run the PoshQC formatter only on the changed files and confirm it leaves the untouched lines unchanged.
- Put the regression check in a **new standalone file** (section 5). No sibling edits it, and it loads no hook, so a sibling's hook change cannot break it.
- Touch no production file and no push-down mirror, so the bundle-parity tests cannot conflict.
- If a sibling adds a new reaching suite, the explicit-list guard will not require the mock there. Record that as a known limit rather than switching to a glob, because a glob would also pull in the ten non-reaching suites and widen overlap.

## 7. Baseline and how the suites run

- Pester configuration: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
  - `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')` (line 3).
  - JUnit output: `artifacts/pester/pester-junit.xml` (line 15).
  - Coverage output: `artifacts/pester/powershell-coverage.xml` (line 22). `CodeCoverage.Path` is an explicit per-file allow-list that already includes `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (line 307).
  - A byte-identical copy is at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- Scan configuration: `config/poshqc-scan.json` (`test.scanFolders` = `scripts`, `tests/powershell`, `tests/scripts`).
- CI: `.github/workflows/ci.yml:24` calls `.github/workflows/_poshqc.yml`, which runs on **`windows-latest`** (line 10). Its steps are Format, Analyze, and `Invoke-PoshQCTest` (lines 22-42). The premise that Linux CI runs these Pester suites was not confirmed: no `ubuntu-latest` job invokes Pester. The design is platform-neutral regardless.
- Local runner: MCP `mcp__drm-copilot__run_poshqc_test`. Summaries from that runner carry no per-test output, and it reads installed-extension settings. For per-suite pass counts, capture baselines with a direct `Invoke-Pester` run over an explicit file list (the seven suites, the three EpicScope suites, and the new file) and record the reported Passed/Failed/Skipped totals.
- Approximate static `It` counts (runtime counts are higher for `-ForEach` rows):

  | Suite | Static `It` | `-ForEach` rows |
  |---|---|---|
  | `enforce-pr-author-skill.TargetResolution.Tests.ps1` | 5 | 0 |
  | `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 17 | 1 |
  | `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | 18 | 2 |
  | `enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | 0 |
  | `enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 19 | 0 |
  | `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 22 | 11 |
  | `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 5 | 5 |
  | the three `*.EpicScope.Tests.ps1` | 5 / 4 / 16 | 0 / 0 / 2 |

  Take the authoritative baseline from the Pester run, not from these static counts.
- Coverage: the change touches no production code, so production coverage cannot regress. Record the baseline and final `powershell-coverage.xml` line coverage for `EpicScopeResolution.psm1` to show no change.

## 8. Automation feasibility

No automation-feasibility concern was found. Every step (edit tests, format, analyze, run Pester, parse ASTs) is local, deterministic, and needs no network, GitHub, live git state, or manual operation. Two execution notes:

- The agent-worktree isolation guard denies Bash text containing `pwsh`, so Pester runs should use the PowerShell tool or the MCP PoshQC tools.
- Do not base a plan assertion on counts reported in the MCP PoshQC summary.

## Numeric Derivation Evidence

### Claim N1: the complete family of non-EpicScope suites for the three hooks has 17 members

- Complete Family: Pester suite files under `tests/scripts/claude-hooks/` whose names begin with `enforce-pr-author-skill`, `enforce-model-routing-receipt`, or `enforce-orchestration-preimplementation-gate` and end with `.Tests.ps1`, excluding `*.EpicScope.Tests.ps1`.
- Exhaustive Search Scope: every file under `tests/` (the second glob scanned `tests/**`, which also surfaced the five `tests/scripts/codex-hooks/` files, excluded by rule).
- Inclusion Rules: file name matches one of the three hook prefixes; located in `tests/scripts/claude-hooks/`.
- Exclusion Rules: `*.EpicScope.Tests.ps1`; files under `tests/scripts/codex-hooks/` (Codex hooks do not use `EpicScopeResolution`).
- Primary Search Strategy or Query Expression: Glob `tests/scripts/claude-hooks/enforce-{pr-author-skill,model-routing-receipt,orchestration-preimplementation-gate}*` gives 20 files; remove the 3 EpicScope files.
- Primary Member Set:
  - pr-author: `.Tests`, `.Payload`, `.OrchestratorStatePreflight`, `.TriggerScoping`, `.epic-base-branch`, `.epic-base-branch.TriggerScoping`, `.TargetResolution`, `.WorktreeResolution`
  - model-routing: `.Tests`, `.WorktreeResolution`
  - preimplementation gate: `.Tests`, `.TriggerScoping`, `.CommandExemption`, `-absolute-paths`, `-classifier`, `-mode-resolution`, `-helpers.Parity`
- Primary Count: 17.
- Cross-check Search Strategy or Query Expression: content Grep over `tests/` for the regex `hooks/enforce-(pr-author-skill|model-routing-receipt|orchestration-preimplementation-gate)(\.ps1|-helpers|-epic-scope)`, files-with-matches. It returned 27 files. Restrict to `tests/scripts/claude-hooks/` (19 files), remove the 3 EpicScope files (16), then reconcile against the file-name family.
- Cross-check Member Set: the same members as the primary set except `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`. That file composes the helpers path from variables (lines 17-27), so the regex does not match it; it is added back after reconciliation because it satisfies the file-name inclusion rule.
- Cross-check Count: 16 by content match, plus 1 reconciled = 17.
- Member-set Comparison: after normalisation to file names, the two sets are identical (17 = 17). The one-member gap before reconciliation is explained by the content-versus-file-name difference above.

### Claim N2: 7 suites in the family reach `Resolve-EpicScopeCheckpoint` without an isolating mock

- Complete Family: the 17 suites of N1.
- Exhaustive Search Scope: all 17 suite files, plus the three hook call sites (section 1) that set the reach conditions.
- Inclusion Rules:
  - gates 1 and 3: a row supplies a branch signal (`--head`, `--branch`, `branch:`; case-insensitive) on a path that reaches the call site, with no `Get-EpicScopeCheckpointText` mock in scope;
  - gate 4: a row supplies an implementation-classified path or command leg, with no such mock in scope.
- Exclusion Rules:
  - rows whose only reaching context already mocks the seam (`enforce-pr-author-skill.epic-base-branch.Tests.ps1`, Context at 123-203);
  - suites whose gate-4 decision calls are all Agent (delegation) payloads;
  - suites that load no hook.
- Primary Search Strategy or Query Expression, as a union of two parts:
  - gates 1 and 3: case-insensitive Grep for `--head|--branch|branch:` over `enforce-{pr-author-skill,model-routing-receipt}*.Tests.ps1`; files with count > 0, minus EpicScope files, minus mocked-context-only files;
  - gate 4: Grep count of `Invoke-OrchestrationPreimplementationGate(Decision|EntryPoint)` per file, minus EpicScope, minus files whose calls are all Agent payloads (read at classifier 154 and mode-resolution 34, 123, 397-486).
- Primary Member Set:
  - `enforce-pr-author-skill.TargetResolution`
  - `enforce-pr-author-skill.WorktreeResolution`
  - `enforce-model-routing-receipt.WorktreeResolution`
  - `enforce-orchestration-preimplementation-gate.Tests`
  - `enforce-orchestration-preimplementation-gate.TriggerScoping`
  - `enforce-orchestration-preimplementation-gate.CommandExemption`
  - `enforce-orchestration-preimplementation-gate-absolute-paths`
- Primary Count: 7.
- Cross-check Search Strategy or Query Expression: search the 17 suites for any existing `Get-EpicScopeCheckpointText` mock. Only `enforce-pr-author-skill.epic-base-branch.Tests.ps1` has one, context-scoped. Then walk each of the 17 files and classify its decision calls by payload leg, per the section 2 table.
- Cross-check Member Set: the section 2 table rows 7, 8, 10, 11, 12, 13, 14, which are the same seven files.
- Cross-check Count: 7.
- Member-set Comparison: identical sets after normalisation to file names (7 = 7).

## Recommendations

1. Adopt approach A. In each of the seven reaching suites, insert into the existing top-level `BeforeAll`, directly after the hook dot-source or module imports:
   - `Import-Module <.claude>/lib/worktree-resolution/EpicScopeResolution.psm1`, without `-Force`, to bind the hook's instance, per the precedent;
   - `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }`.

   Do not change any existing row or assertion.
2. Do not change production code or push-down mirrors. Do not add an environment-variable seam.
3. Add the new standalone regression file with the structural guard (the expect-fail test) and the seam-sufficiency proof described in section 5.
4. Capture Pester baselines, before and after, for the seven edited suites, the three EpicScope suites, and the new file with a direct `Invoke-Pester` run. The pass counts of the seven edited suites and the three EpicScope suites must not change.
5. Record the out-of-scope candidates in section 2 (the four relative-path epic-read hooks and their suites) as a follow-up, not as #709 scope.
6. Batching under the PowerShell change budget (at most 3 test files per batch): 8 test files split into three batches:
   - gate 4: `.Tests`, `.TriggerScoping`, `.CommandExemption`;
   - gate 4 `-absolute-paths` plus the gates 1 and 3 `WorktreeResolution` suites;
   - pr-author `TargetResolution` plus the new regression file.

## Files to change

- `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` (edit: `BeforeAll` at lines 22-24)
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` (edit: root `BeforeAll` at lines 42-50)
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` (edit: root `BeforeAll` at lines 40-45)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` (edit: Describe `BeforeAll` at lines 5-7)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` (edit: `BeforeAll` at lines 46-48)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (edit: `BeforeAll` at lines 16-18)
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` (edit: `BeforeAll` at lines 140-142)
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` (new: structural guard and seam-sufficiency proof)

Not changed: every production file, the three `*.EpicScope.Tests.ps1` suites, `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` (already isolated where it reaches), and the ten non-reaching suites.
