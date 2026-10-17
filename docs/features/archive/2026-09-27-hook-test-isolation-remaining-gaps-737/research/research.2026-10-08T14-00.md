# Research: hook test isolation and parity (Issue #737, bundled #746; epic #852 child C5b)

- Date: 2026-10-08
- Branch: `bug/hook-test-isolation-remaining-gaps-737` (from `origin/epic/enforcement-hook-precision-integration`)
- Mode: preparation research. No source, test, or configuration file was changed.
- Work mode: full-bug.

## Verification method and limits

All findings below were verified by reading files and by Grep searches against the current tree of this worktree. No shell or PowerShell tool was available in this research session, so no Pester run, AST parse, or hash comparison was executed. Statements about what a proposed rule "selects" were derived by applying the rule to Grep and Read output by hand; they are marked "static" and must be re-derived by running the rule on the integration branch at execution time (the issue requires this, because #736, #732, and #850 change suites first). Paths in this document are repository-relative.

## 1. Current state of the #709 mock mechanism (Q1)

### 1.1 Mechanism

Two module-level read seams are mocked by the guarded suites. Both are the only filesystem read of their module and are documented as "the seam a test mocks":

| Seam | Defined | Used by | Mock form in suites |
| --- | --- | --- | --- |
| `Get-EpicScopeCheckpointText` | `.claude/lib/worktree-resolution/EpicScopeResolution.psm1:125` | `Resolve-EpicScopeCheckpoint`, call at `:361` | `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }` |
| `Get-WorktreeRunCheckpointText` | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1:99` | `Get-WorktreeRunCheckpoint`, call at `:187` | `Mock Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution { $null }` |

`EpicScopeResolution.psm1:40-42` imports `WorktreeRunResolution.psm1` (and two siblings), so the WRR seam is reached through the epic-scope resolver as well. Each suite's outermost `BeforeAll` dot-sources the hook, then runs `Import-Module <module> ` without `-Force`, then declares the `$null` mock (so the mock binds to the instance the hook loaded). This is the #709 spec decisions D1 to D3 (`docs/features/completed/gate-suites-read-unmocked-local-epic-state-709/spec.md:147-160`) extended by #690 with the WRR pair.

### 1.2 The suite list the guard enumerates

The issue and the #709 follow-ups say seven suites; the current tree has eight. The guard header says "Eight hook suites" (`tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1:9`). The explicit list is the `-ForEach` data at `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1:38-47` (rows at lines 39-46):

| Suite | ESR mock line | WRR mock line |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1` | 26 | 38 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 51 | 102 |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | 46 | 93 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 9 | 58 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1` | 50 | 94 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 20 | 65 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 144 | 181 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` (added by #690) | 24 | 26 |

The known-limit note (decision D9) is at `enforce-gate-suites.EpicStateIsolation.Tests.ps1:24-25`. The structural predicate lives in `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` (198 lines): `Get-EpicStateIsolationPairFinding` (96-145), `Get-EpicStateIsolationFinding` (147-173), `Get-EpicStateIsolationSuiteFinding` (175-198). The guard test file is 373 lines. The file also holds nine predicate-discrimination rows (59-265), a missing-path row (267-278), and the seam-sufficiency `Describe` (292-373; its `BeforeDiscovery` is at 282-290, after the first `Describe`, which is CR-6).

Numeric note: the "eight" count is a current-state observation, verified by two independent reads (the header sentence at line 9 and the eight `@{ Path = ... }` rows at lines 39-46). No numeric acceptance criterion is proposed from it (see "Numeric Derivation Evidence").

## 2. D8: other suites that read orchestration state (Q2)

### 2.1 Stale premises in the issue

1. The #709 follow-up says the epic merge gate, epic worktree-removal gate, epic wave barrier, and parallel worktree-removal gate read the epic checkpoint "through their own relative-path seam". After #690 each reads through an absolute-path seam (`[ValidatePattern('^([A-Za-z]:[\\/]|/)')]` on `-Path`) beneath a root produced by a resolver:
   - merge gate: `.claude/hooks/enforce-epic-merge-gate-resolution.ps1:57, 77, 97` (three `Get-*OrchestratorCheckpointContent` seams), `:117-129` (`Get-EpicMergeGateSessionWorktreeRoot`, which resolves from `(Get-Location).Path`), `:131` (`Resolve-EpicMergeGateRunTarget`); call sites `.claude/hooks/enforce-epic-merge-gate.ps1:358, 362, 375-376, 381, 386`.
   - wave barrier: `.claude/hooks/enforce-epic-wave-barrier.ps1:55` (seam), `:310` (`Resolve-EpicWaveBarrierTarget`), `:320` (read).
   - epic removal gate: `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1:54, 74` (seams), `:94-112` (`Resolve-EpicWorktreeGateRunTarget`, session root at `:112`).
   - parallel removal gate: `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:62, 82` (seams), `:108-126` (`Resolve-ParallelWorktreeGateRunTarget`, session root at `:126`).
2. The batch-budget hook no longer counts test files (`.claude/hooks/enforce-powershell-batch-budget.ps1:298-300`; header "Test files are never counted", line 25). The "three test files per batch" constraint recorded in #709 plan line 219 is obsolete; C5b changes no production PowerShell file.

### 2.2 Verified exposure for the four named hook families

Established idiom: each gate suite's outermost `BeforeAll` mocks the hook's run-target resolver to a synthetic root, `WorktreeRoot = '/synthetic-worktrees/default-session'`, with detail text "default SessionRoot target (issue #690)". Verified instances:

- merge gate: `enforce-epic-merge-gate.Tests.ps1:12`, `enforce-epic-merge-gate.TriggerScoping.Tests.ps1:39`, `enforce-epic-merge-gate.Authorization.Tests.ps1:75`.
- epic removal gate: `enforce-epic-worktree-removal-gate.Tests.ps1:28` (and `:439`), `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1:46`, `CleanupWorktreeManifestGateMatrix.Tests.ps1:222`.
- parallel removal gate: `enforce-parallel-worktree-removal-gate.Tests.ps1:22` (and `:409`), `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1:46`, `enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1:26`, `CleanupWorktreeManifestGateMatrix.Tests.ps1:275`.
- wave barrier: `enforce-epic-wave-barrier.Tests.ps1:12`.
- the same idiom appears in `enforce-parallel-cohort-barrier.Tests.ps1:22`, `enforce-parallel-cohort-barrier.Payload.Tests.ps1:22`, `enforce-parallel-drift-gate.Tests.ps1:55`, `hook-command-parser.AcceptanceCases.Tests.ps1:69-70`.

Consequence: reads that go through a resolver-derived root land under a non-existent synthetic path and return absent, so these suites are hermetic by construction even where a row does not mock the content seam. The `*.WorktreeResolution.Tests.ps1` suites for the same hooks mock the lower seams (`Get-WorktreeItemLiveRoot` and `Get-WorktreeRunCheckpointText` in module scope `WorktreeRunResolution`) inside a topology helper that every row calls (verified for the merge gate at `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:44-69` and the same pattern at the removal, wave, cohort, and drift suites per the Mock listing).

Residual real-filesystem reads that were verified:

1. Merge gate session root. `Get-EpicMergeGateSessionWorktreeRoot` (`enforce-epic-merge-gate-resolution.ps1:117-129`) is mocked only at `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:141`. In `enforce-epic-merge-gate.Tests.ps1`, `.TriggerScoping.Tests.ps1`, and `.Authorization.Tests.ps1` it is not mocked, so `$sessionRoot` (`enforce-epic-merge-gate.ps1:358`) is the real current worktree. For a bare `gh pr merge --merge` the epic and parallel roots equal `$sessionRoot` (`:372-373`), so any row that does not mock a given seam reads `<real worktree>/artifacts/orchestration/...`. Example: `enforce-epic-merge-gate.Tests.ps1:52-61` mocks the child and epic seams but not `Get-ParallelOrchestratorCheckpointContent`, and the hook reaches the parallel read at `enforce-epic-merge-gate.ps1:386`. The outcome cannot change for a bare command, because `Test-ParallelCheckpointAllowsMerge` returns false when the command PR number is null (asserted at `enforce-epic-merge-gate.Tests.ps1:256`), so this is a real but outcome-neutral read. C3 (#850) changes this branch, so the exposure must be re-derived after C3.
2. Default-parameter seams. `Invoke-PowerShellBatchBudgetHook` and its Python twin default `$Root` to the repository root and default `-ReadCheckpoint`, `-ReadState`, and `-ReadSessionIdFile` to scriptblocks that call `Get-Content` (`.claude/hooks/enforce-powershell-batch-budget.ps1:329-351`; checkpoint path built at `:386`). The routing suites inject all of them (for example `enforce-powershell-batch-budget-routing.Tests.ps1:70-71, 325-326, 339-340`). A call that omits the injection reads real state. No omission was searched for exhaustively; this class is reported for the census, not as a verified defect.
3. Codex `mode-routing` rows. See section 3.

No row in the four named suites families was found where a local `epic-orchestrator-state.json` could change an outcome. This is a static conclusion from the resolver mocks and the per-row seam mocks listed above; it is not a statement that every row of every suite was traced. The first implementation task must therefore be a measure-only census (section 12, unit U1).

### 2.3 Other suites already at risk and not covered by the guard (static)

The guard covers eight suites; more suites load hook closures that import `EpicScopeResolution.psm1` or `WorktreeRunResolution.psm1`. Closure facts (verified by reading the import lines):

- ESR (with nested WRR) is imported by `enforce-pr-author-skill-helpers.ps1:48` (loaded by `enforce-pr-author-skill.ps1:150`), `enforce-model-routing-receipt.ps1:55`, and `enforce-orchestration-preimplementation-gate-epic-scope.ps1:44-46` (loaded by `enforce-orchestration-preimplementation-gate.ps1:25`; the module names are string literals inside an array, so a literal-token scan finds them).
- WRR is imported directly by `enforce-epic-merge-gate-resolution.ps1:32`, `enforce-epic-worktree-removal-gate-resolution.ps1:29`, `enforce-parallel-worktree-removal-gate.ps1:51`, `enforce-parallel-cohort-barrier.ps1:60`, `enforce-parallel-drift-gate.ps1:75`, `enforce-epic-wave-barrier.ps1:46`.

Static status of suites that load these closures and are not in the guard list (mock locations from the Mock listing; "-" = no mock of that seam anywhere in the file):

| Suite | ESR mock | WRR mock | Note |
| --- | --- | --- | --- |
| `enforce-pr-author-skill.Tests.ps1`, `.Payload`, `.OrchestratorStatePreflight`, `.TriggerScoping`, `.epic-base-branch.TriggerScoping` | - | - | #709 classified these non-reaching because no command carries a branch signal (`research.2026-09-26T23-00.md:58-62`); that reach is data-dependent |
| `enforce-pr-author-skill.epic-base-branch.Tests.ps1` | `:149` (payload, nested context) | `:132` (`$null`, nested context) | not in outermost `BeforeAll` |
| `enforce-pr-author-skill.EpicScope.Tests.ps1` | `:53` (payload) | `:64` (`$null`) | payload-driven seam-under-test suite |
| `enforce-model-routing-receipt.Tests.ps1` | - | - | non-reaching per #709 row 9 |
| `enforce-model-routing-receipt.EpicScope.Tests.ps1` | `:60` (payload) | `:76` (`$null`) | |
| `enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` | - | `:65` (inside the per-row topology helper) | Agent-leg suite |
| `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` | `:76` (payload) | `:82` (`$null`) | |
| `enforce-orchestration-preimplementation-gate-classifier.Tests.ps1`, `-mode-resolution.Tests.ps1`, `.AttributionTrailer.Tests.ps1`, `hook-command-parser.AcceptanceCases.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1` | - | - | Agent-payload or exempt-staging rows (#709 rows 15 and 16) |

### 2.4 Mechanical discovery rules (no fixed list)

The rules are written so a guard can compute everything at test time from the committed tree. They are pure text and AST operations (no process, no temporary file).

**R1. Suite discovery.** Every `*.Tests.ps1` directly under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`. The set is computed by directory enumeration; the guard asserts only that each surface yields at least one suite (non-vacuity), never a literal count.

**R2. Loaded-source closure.** For a suite, collect every string literal matching `hooks/([A-Za-z0-9._-]+\.ps1)` in the suite text. This matches all three forms in use: `"$PSScriptRoot/../../../.claude/hooks/x.ps1"` (e.g. `enforce-pr-author-skill.TargetResolution.Tests.ps1:23`), `Join-Path $script:HookRoot 'hooks/x.ps1'` (e.g. `enforce-pr-author-skill.WorktreeResolution.Tests.ps1:46`), and `.codex/hooks/x.ps1` (e.g. `enforce-completion-consistency-codex.Tests.ps1:9`). Resolve each name against `.claude/hooks` and `.codex/hooks` (union when it exists in both). Expand transitively: in each loaded file, every string literal ending `.ps1` or `.psm1` that resolves to an existing file beside it, or beneath `../lib/<dir>/`, is added; repeat for modules (module `Import-Module (Join-Path $PSScriptRoot 'X.psm1')` lines). Literal scanning (not dot-source statement scanning) is required because the closure includes variable-driven loads such as `. $script:CompletionHelpersPath` (`enforce-completion-consistency.ps1:53`) and the array loop at `enforce-orchestration-preimplementation-gate-epic-scope.ps1:44`.

**R3. Seam census over the closure.** A seam is a `FunctionDefinitionAst` in a closure file whose body contains a read primitive (`Get-Content`, `[System.IO.File]::ReadAllText`, `ReadAllLines`) and either (a) whose name matches `Checkpoint` or (b) whose body or defining file contains the literal `artifacts/orchestration/`. Classes:
- A. Module text seams: `Get-EpicScopeCheckpointText`, `Get-WorktreeRunCheckpointText` (and, as an advisory class, `Get-WorktreeItemCheckpointText`, `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:131`).
- B. Hook-local content seams: `Get-ChildOrchestratorCheckpointContent` and siblings (`enforce-epic-merge-gate-resolution.ps1:57,77,97`), `Get-EpicWaveBarrierCheckpointContent`, `Get-EpicWorktreeGateCheckpointContent`, `Get-ParallelWorktreeRemovalGateCheckpointContent`, `Get-CheckpointContent`/`Get-EpicCheckpointContent`/`Get-ParallelCheckpointContent` (`enforce-orchestration-preimplementation-gate-epic-scope.ps1:76,87,98`), `Get-PrAuthorCheckpointContent` (`enforce-pr-author-skill.epic-base-branch.ps1:17`), `Get-ParallelDriftGateCheckpointContent`, `Get-ParallelCohortBarrierCheckpointContent`, `Get-ModelRoutingCheckpoint` (`enforce-model-routing-receipt.ps1:56`).
- C. Cwd-derived resolvers: functions whose body contains `(Get-Location).Path` (all `Resolve-*Target`/`*RunTarget` functions listed in 2.2, `Get-EpicMergeGateSessionWorktreeRoot`, `Resolve-PrAuthorWorktreeTarget` at `enforce-pr-author-skill-helpers.ps1:71`, `Resolve-ModelRoutingWorktreeTarget` at `enforce-model-routing-receipt.ps1:161`).
- D. Default-parameter seams: `[scriptblock]` parameters whose default body reads (batch-budget hooks, `enforce-completion-consistency.ps1:195,339`). Report-only unless a call omits the injection.

**R4. Compliance forms.** A suite satisfies a seam by one of:
- F1 (baseline default-deny): a direct statement of the outermost `BeforeAll` (not a nested script block, not a nested `Context`/`Describe` `BeforeAll`) declares `Mock <seam>` returning `$null`/`''` (class A requires `-ModuleName` and a preceding `Import-Module` without `-Force`, both after the hook dot-source; a script-defined class B or Codex seam is mocked without `-ModuleName`, after the dot-source). Row-level mocks in child scopes override a root mock; this was probed in #709 (`docs/features/completed/gate-suites-read-unmocked-local-epic-state-709/evidence/baseline/pester-root-beforeall-mock-probe.2026-09-27T09-59.md`, task P0-T6).
- F2 (seam-under-test): the suite invokes the seam directly (a `CommandAst` named as the seam outside `Mock`/`Should`), every such call passes a literal path beginning `/synthetic-worktrees/`, and the suite mocks `Test-Path` and `Get-Content` with a `-ParameterFilter` on a `/synthetic-worktrees/` literal. Verified existing instances: `enforce-epic-wave-barrier.Tests.ps1:177-190`, `enforce-epic-merge-gate.Tests.ps1:233-244, 292-314`. A blanket F1 mock would break these rows (the real function could no longer be called), which is why F2 exists.
- F3 (resolver pinned): for class C only, the outermost `BeforeAll` mocks the resolver to a `/synthetic-worktrees/` root (the established idiom in 2.2).

**R5. Result for the current tree (static).** Class A applied to every suite that loads an ESR-importing closure selects the eight guarded suites plus the suites in the table in 2.3; the unguarded ones would currently fail F1 (no root-level mock). Class A applied to WRR-only closures selects the merge, removal, wave-barrier, cohort-barrier, and drift-gate suites; these pass F3 for the resolver and would fail F1 for `Get-WorktreeRunCheckpointText` unless they are given the one-line baseline (their `*.WorktreeResolution` variants set the mock per row, which satisfies behavior but not the root-level form). Class C: the merge-gate `Tests`, `TriggerScoping`, and `Authorization` suites fail on `Get-EpicMergeGateSessionWorktreeRoot` (not mocked outside `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:141`).

**R6. Over-inclusion trade-off.** R2-R4 select by what a suite loads, not by what a row reaches. Reach (does any row carry a branch signal) is data-dependent (#709 rows 1-5 and 9 turn on grep results over command strings) and is not mechanical. The #709 decision D9 chose an explicit list because a closure-wide rule would add mocks to non-reaching suites; that cost is now accepted by the epic ("discovery guards", `docs/features/epics/enforcement-hook-precision/epic.md:126-130`). A baseline `$null` mock in a suite that never reaches the seam changes no outcome and is the same two to four lines per suite as #709.

### 2.5 Effect of upstream children on the rules

The rules take the closure from the files as they exist when the plan executes. #732 (C1b) changes the preimplementation gate family; the seam census and F1 form do not name any function that C1b is stated to rewrite (`Test-ExemptOrchestrationOperand` is in the helpers file and is not a seam). #850 (C3) changes `enforce-pr-author-skill.ps1`, the standalone-merge branch of the merge gate, and both removal gates, and adds reads of the PR context, body, receipt, and authorization record beneath a resolved item worktree (epic.md:109-112). Those reads are under `artifacts/` but not `artifacts/orchestration/`; the census predicate (R3b) should be widened to any `artifacts/` literal in a read path if the plan wants them covered (decision O3 in section 12). #736 (C5a) replaces the working-directory-dependent completion-consistency tests with a reader seam (class D); census class D then reports whether every call injects.

## 3. D5: Codex suites and `.codex/hooks` (Q3)

### 3.1 Stale premise

#709 D5 states "no `.codex` hook uses `EpicScopeResolution`". That remains true by name, but #707 ported the epic-scope resolver into the Codex gate family and added mocks. The Codex seam is a script-scope function, so it is mocked without `-ModuleName`:

- seam `Get-EpicScopeCheckpointText`: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1:295` (calls `Get-WorktreeResolutionGitEntryKind` then `Get-WorktreeResolutionGitFileText`, `:309-312`); resolver `Resolve-EpicScopeCheckpoint` at `:432`, read at `:465`; caller `Get-OrchestrationEpicScopeDecision` at `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:150`, `Resolve-EpicScopeCheckpoint` call at `:179`; reached from `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:410-411` for the path and command legs only.
- existing mocks: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:27`, `.../enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1:52`, `.../codex-preimplementation-gate-absolute-paths.Tests.ps1:135`, `.../codex-pretooluse-transport.Tests.ps1:11`, `.../legacy-codex-hook-contracts.Tests.ps1:35` (comment at `:33`: "Issue #707 (D10)"). The two resolver suites mock a payload per row: `enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1:81`, `...-epic-scope.Tests.ps1:106`.

Codex suites that load the gate closure and have no mock: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` and `.../enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` (both drive Agent legs, which skip the epic-scope call at `gate.ps1:410`), and the `codex` runtime rows of `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1:13-16` (admit rows return allow before an epic read, as its header states, lines 7-9).

### 3.2 Other Codex reads

- Codex gate item checkpoint: `Get-CheckpointContent` reads the cwd-relative `$script:CheckpointPath` (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:31, 281-290`) when `-CheckpointRaw` is empty (`:438-440`). The Codex suites inject `-CheckpointRaw` with a not-ready object (for example `...-command-exemption.Tests.ps1:40-65`, `...-trigger-scoping.Tests.ps1:66-89`), so they do not read it. `Get-CheckpointContent` is tested directly in `legacy-codex-hook-contracts.Tests.ps1:402, 412`.
- Codex per-mode seams `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` (`.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:43-65`) read a cwd-relative path from the mode table. `enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1:171-192` deliberately omits the injection in two rows (`Get-EpicCheckpointContent`/`Get-ParallelCheckpointContent` supply the text), and states the deny holds whether or not the local file exists (`:19-24`). These two rows are real reads of local state that are outcome-neutral by argument. They can be made hermetic without losing their purpose by mocking `Test-Path` to `$false` for the canonical path, so the seam returns `''` and the deny reason still names the canonical path.
- Codex epic gates (merge, removal, wave barrier, planning-only) take raw checkpoint text as parameters (`Invoke-CodexEpicMergeDecision -ChildCheckpointRaw -EpicCheckpointRaw`) and read files only in the script tail after `if ($MyInvocation.InvocationName -eq '.') { return }` (`.codex/hooks/enforce-epic-merge-gate.ps1:360-371`, `enforce-epic-worktree-removal-gate.ps1:156-169`, `enforce-epic-wave-barrier.ps1:252-284`, `enforce-epic-planning-only.ps1:325-337`). Suites that dot-source these hooks never execute the tail. `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1:8-14` documents the same defect class and fixes it with a committed fixture for the in-process planning decision.
- Process-spawning suites run hook scripts as child processes from the real repository root, so the script tail reads real checkpoints: `codex-pretooluse-integration.Tests.ps1:76-107`, `codex-pretooluse-transport.Tests.ps1:63-66`, `legacy-codex-hook-contracts.Tests.ps1:63-93`, `epic-execution-gates.Tests.ps1:28-58` (this one passes fixture paths), `codex-bundle-hook-probe.Tests.ps1`, `epic-child-worktree-launcher.Tests.ps1`, `epic-child-launch-hardening.Tests.ps1`, and the trigger-scoping suites for validate-bash and the gate (Grep count of `ProcessStartInfo`/`-File`). Whether each payload can reach a local-state-dependent branch needs the census (benign payloads such as `README.md` and `git status` in `codex-pretooluse-integration.Tests.ps1:58-73` classify as non-implementation, so the gate allows before any read; planning-only reads its checkpoint unconditionally at `enforce-epic-planning-only.ps1:332-337`).

### 3.3 Mechanical rule for the Codex surface

R1-R4 apply unchanged with the Codex binding: closure edges come from `.codex/hooks`; a class A/B seam defined in a dot-sourced `.codex` file is mocked without `-ModuleName` and without `Import-Module`, after the dot-source; the `ParseFile`-based predicate needs a variant that omits the import requirement. Add one rule for process-spawning suites: R7. A suite whose text contains `ProcessStartInfo` (or the composed process-start token) and names a hook script is reported by the census with the hook it launches; it is compliant only when it passes a fixture path or an environment/working-directory binding that is not the real repository root (this is the shape `epic-execution-gates.Tests.ps1` already uses). R7 is report-first because the compliance form is not uniform.

## 4. CR-1: proving that the mock intercepts (Q4)

CR-1 gap: the structural guard checks placement; the sufficiency proof imports its own instance with `-Force` (`enforce-gate-suites.EpicStateIsolation.Tests.ps1:296`). No row in any suite asserts that the suite's own mock binds to the instance the hook uses.

Recommended proof (P1, no temporary file, no gitignored read): add a shared probe function to `EpicStateIsolation.Helpers.ps1` (or a sibling helper) and require each in-scope suite to call it from one `It`. The probe runs inside the suite's own scope, after the suite's baseline mock exists:

1. In module scope `EpicScopeResolution`, mock the lower seams so a read that escapes the baseline mock would see a hostile ready epic checkpoint: `Find-WorktreeResolutionRoot`, `Get-WorktreeResolutionGitEntryKind` (`File`), `Get-WorktreeResolutionGitFileText` (hostile JSON), `Get-EpicScopeWorktreeHeadBranch`. This is the set the existing `Set-HostileEpicSeam` already registers (`enforce-gate-suites.EpicStateIsolation.Tests.ps1:301-320`).
2. Call the exported `Resolve-EpicScopeCheckpoint` by name (the same name resolution the hook uses).
3. Assert `IsEpicScope` is false with reason `epic-checkpoint-absent-or-unparseable`, and `Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution -Times 1 -Exactly` and `Should -Invoke Get-WorktreeResolutionGitFileText -ModuleName EpicScopeResolution -Times 0 -Exactly`.
4. Repeat for `Get-WorktreeRunCheckpointText` through an exported WRR entry that reads it (`Resolve-WorktreeRunTargetByRecord` over a mocked `Get-WorktreeItemLiveRoot`), asserting one invocation of the suite's mock.

If the baseline mock is bound to a different instance (for example the hook re-imported the module with `-Force` after the mock), step 3 fails because the hostile payload is read and the mock invocation count is zero. This is the "deliberately present local checkpoint must not change the result" requirement, expressed with an in-memory payload instead of a file. The guard then requires each in-scope suite to contain a call to the probe inside an `It` (AST check), so omission is caught mechanically.

Rejected alternatives: (a) `Mock -Verifiable` plus `Should -InvokeVerifiable` in `AfterAll` of every suite fails for suites in which no row reaches the seam; (b) running the target suites from a nested `Invoke-Pester` inside a test is slow and not deterministic in isolation; (c) mocking `Test-Path`/`Get-Content` globally cannot intercept `[System.IO.File]::ReadAllText`, which the WRR and WIR seams use (`WorktreeRunResolution.psm1:117`, `WorktreeItemResolution.psm1:148`).

Assumption to confirm at implementation: `Should -Invoke` counts a root-`BeforeAll` mock's calls made inside an `It`. #709's probe established that a root `BeforeAll` mock applies to child blocks; the count semantics should be confirmed by a first probe run in the same way (task P0-T6 pattern).

## 5. CR-2, CR-3, and additional guard false-pass paths (Q5)

Locations are in `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`.

CR-2 false-pass paths (confirmed by reading the code):
1. Ordering is checked against the first dot-source, not the hook dot-source. `Get-EpicStateIsolationFinding` selects `$dotSource` as the first command with the dot invocation operator (`:169`) and `Get-EpicStateIsolationPairFinding` compares import and mock offsets to it (`:140-143`). A suite that dot-sources a helper (for example `. (Join-Path $PSScriptRoot 'WorktreeResolutionFixture.Helpers.ps1')`) before the hook, with the import and mock placed between that helper and the hook, passes while binding to the wrong module instance.
2. Nested script blocks are searched. `$blockExpression.ScriptBlock.FindAll($isCommand, $true)` (`:168`) returns commands inside function bodies and other script blocks defined in the `BeforeAll`; a `Mock`/`Import-Module` inside a function that is never invoked satisfies the guard. The existing nested-row fixture (`enforce-gate-suites.EpicStateIsolation.Tests.ps1:147-165`) covers only a nested `Context` `BeforeAll`, which the outermost-`BeforeAll` selection (`:157-159`) already handles.

Additional false-pass paths found while reading (not in the #709 review):
3. Only the first outermost `BeforeAll` is checked (`Select-Object -First 1` after sorting by depth then offset, `:157-159`). A file with two top-level `Describe` blocks, each with its own `BeforeAll`, passes if only the first isolates.
4. The first matching `Mock` is taken and the loop breaks (`:113-121`); a second `Mock` of the same command with a non-`$null` body later in the same block is not seen.
5. The import match is a regex over the joined element text (`:123-126`), so an `Import-Module` of any path containing the file name satisfies it, including one whose argument is a comment-like string.

CR-3 untested branches (the review lists three; the code has more). With `file:line` in the helper:
- no outermost `BeforeAll` (`:163-166`): no predicate row;
- parse error returned as a finding (`:191-194`): no row (the missing-file row at test `:267-278` covers `:184-187` only);
- `Import-Module` present for `EpicScopeResolution.psm1` while the ESR mock is absent is covered in the other direction only; the ESR-side "import absent, mock present" case has no row (the WRR-side case exists at test `:225-238`);
- additional: no dot-source at all in the `BeforeAll` (`$DotSource` null makes `$ordered` false, `:140-143`); the `-ModuleName:value` colon-bound form (`:54-55`); a `MockWith` body that has a `param` block, `begin`, or `process` block (`Test-EpicStateIsolationNullBody`, `:91`); a non-string module-name element (`Get-EpicStateIsolationElementText`, `:38`).

## 6. CR-7: stale comment (Q6)

The comment says "the three library modules are imported without -Force", but the block imports four modules before the ESR mock and a fifth (WRR) later:
- `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1:43-44` (imports at `:47-50`, WRR import at `:101`).
- `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1:38-39` (imports at `:42-45`, WRR import at `:92`).

A comment edit changes no behavior; it can be bundled with any baseline-mock edit to the same suites (both are already guarded suites).

## 7. #707: no-Python guard scan roots (Q7)

File: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (exactly 500 lines). Scan roots are defined at lines 34-42 as `$script:ScanRoot = @('<repo>/.claude/hooks', '<repo>/.claude/lib')`; the comment at lines 34-38 states "Exactly two scan roots" and that the bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/**` is out of scope because allowlist keys are repo-root-relative. `Get-GuardedPowerShellFile` (50-76) enumerates `.ps1`/`.psm1` under the roots, excluding `.claude/lib/bash/*`. The 'repository scan' context asserts the enumerated paths lie under exactly those two roots (lines 451-471). The detection helper is `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` (exactly 500 lines; classes 1-4 and carve-outs (a) and (b) in its header, lines 25-49).

Extension requirements:
1. Add `<repo>/.codex/hooks` to the root list; keep the `extensions/*` exclusion assertion; update the "exactly two" comment and the roots assertion (`Relative -notlike '.claude/hooks/*' -and ... -notlike '.claude/lib/*'` at 460) to include `.codex/hooks/*`. `.codex/hooks` contains only `.ps1` files (Glob of `.codex/hooks/**`), so no shell-script exclusion is needed. The bundled Codex mirror is `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`; it stays excluded by the same `extensions/*` assertion.
2. File-size cap. Both the test and its helper are at the 500-line cap; a net-positive edit fails the cap. Move the scan-root definition and the `Get-GuardedPowerShellFile`/`Get-RepositoryPythonInvocationFinding` functions (test lines 34-96) into a new small helper file in the same directory and replace them with one dot-source plus a call; this frees lines in the test file and gives one definition of the root list for both surfaces.
3. Would the extended guard fail today? Static scan of `.codex/hooks`: no command-position `python`, `python3`, `py`, `poetry`, `pip`, or `uv`; no `Invoke-Expression`/`iex`; no `Start-Process` command (the `Start-Process` text at `.codex/hooks/check-powershell-test-purity.ps1:124` is inside a regex string literal). Dynamic-invocation sites all fall under the carve-outs: `& $FolderExistsCheck` and `& $RoutingMatrixReader` (`enforce-completion-helpers.ps1:103,150`; parameters declared at `:79,127`), `& $CheckpointReader` (`enforce-completion-consistency.ps1:308`; declared at `:292,339`), `& $ReadCheckpoint/$TestPathExists/$EnsureDirectory/$ReadState/$WriteState` (`enforce-python-batch-budget.ps1:228-258`, `enforce-powershell-batch-budget.ps1:225-255`; parameters declared at `:184-194`, `:181-191`), and dot-sourced path variables (`. $contractPath` at `enforce-epic-child-worktree-binding.ps1:16` and `codex-epic-child-launch-attestation.ps1:5`, `. $script:CompletionHelpersPath` at `enforce-completion-consistency.ps1:57`), which are carve-out (b). The inline `. (Join-Path $PSScriptRoot '<x>.ps1')` loads are the carve-out (b) inline form. Conclusion (static): no `.codex/hooks` finding is expected. The first implementation step must run the extended guard to confirm this before treating it as established.

## 8. Preimplementation-gate parity (Q8)

### 8.1 File inventory

| Surface | Files |
| --- | --- |
| `.claude/hooks` | `enforce-orchestration-preimplementation-gate.ps1`, `-helpers.ps1`, `-modes.ps1`, `-epic-scope.ps1` (no `-epic-resolution`) |
| `.codex/hooks` | `enforce-orchestration-preimplementation-gate.ps1`, `-helpers.ps1`, `-modes.ps1`, `-epic-scope.ps1`, `-epic-resolution.ps1` |
| Claude bundle (`extensions/drm-copilot/resources/claude-customizations/.claude/hooks`) | the four Claude files |
| Codex bundle (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`) | the five Codex files |

### 8.2 Existing parity tests

- Helpers module byte parity across four surfaces by SHA256: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:14-54` (issue #671). The helpers file is the only member of the family that is byte-identical across Claude and Codex.
- Codex root vs bundle byte identity for all Codex hooks and shared modules: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:114-120`.
- Claude root vs bundle byte identity for every distributable `.claude` file: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`.
- Logic parity by shared inputs, not text: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` (per `docs/features/completed/preimplementation-gate-blocks-epic-execution-554/spec.md:342-346`, "asserting the same outcomes the Claude-side tests assert") and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1:13-16, 43-102`, which runs one case table once per runtime with `Describe ... -ForEach @(@{ Runtime = 'claude'; GateRelativePath = ... }, @{ Runtime = 'codex'; ... })`, dot-sourcing the gate inside the per-runtime `BeforeAll` so the two gates' identical function names never collide.

### 8.3 Actual diff between the two main gates (static, by reading both)

The Claude gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, 454+ lines) and the Codex gate (`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, 453+ lines) share these function names: `ConvertFrom-CheckpointJson`, `Get-StringProperty`, `Test-FeatureDocumentationOrEvidencePath`, `Test-ImplementationPath`, `Test-ImplementationCommand`, `Test-PreparationModeDelegation`, `Test-ImplementationDelegation`, `Test-OrchestrationReady`, `Get-OrchestrationPreimplementationGateAllowDecision`, `Get-OrchestrationPreimplementationGateBlockDecision`, `Invoke-OrchestrationPreimplementationGateDecision`. Bodies differ by design:
- Codex `Test-ImplementationCommand` adds the two `apply_patch` marker legs (`*** Add|Update|Delete File:` and `*** Move to:`) before the shared pattern loop (`.codex/hooks/...gate.ps1:140-151`); the Claude copy has none.
- Codex uses its own `Get-StringProperty` for field reads in `Test-PreparationModeDelegation` and `Test-ImplementationDelegation` (`:203, 208, 239, 247`); Claude uses `Get-ClaudeHookToolInputString` (`.claude/hooks/...gate.ps1:182, 187, 213, 221`). The Codex comment states the former trims where the latter does not (`.codex` `:226-229`).
- Codex defines `Get-CheckpointContent` and `Get-OrchestrationModeDenyReason` in the gate file (`:281, 325`); Claude defines `Invoke-OrchestrationPreimplementationGateEntryPoint` (`:415`) and imports `HookPayload.psm1` (`:9`). Claude resolves a target worktree (`Resolve-OrchestrationGateTarget`, #690); Codex does not.
- The shared `-helpers.ps1` file is byte-identical (section 8.2); `-modes.ps1`, `-epic-scope.ps1` differ (Codex adds `-epic-resolution.ps1`).

### 8.4 What "parity" should mean

Byte identity and normalized-text identity are not achievable for the main gate and would pin intentional divergences. The repository's own precedent for pairs that diverge in implementation is behavioral parity over a shared case table (AttributionTrailer, the Codex mode-resolution suite). Recommended definition:

1. A shared case table (data only) of inputs for the pure classifiers: path classification (`Test-ImplementationPath` with repo-relative, absolute, case, checkpoint-name, feature-document, and extension rows), command classification (`Test-ImplementationCommand` for the non-`apply_patch` forms), delegation classification (`Test-PreparationModeDelegation`, `Test-ImplementationDelegation`), `Test-OrchestrationReady`, and `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw -CheckpointRaw` decision rows. Each row has one `Expected` value that both runtimes must produce.
2. Divergences are first-class: a row may declare `Surfaces = @('codex')` or per-surface expected values with a written reason. The guard asserts that the set of rows with differing per-surface expectations equals a declared set, so an unlisted divergence fails.
3. A function-inventory check by AST: the set of function names defined in each gate equals the shared set plus a declared per-surface-only set with reasons (Codex: `Get-CheckpointContent`, `Get-OrchestrationModeDenyReason`; Claude: `Invoke-OrchestrationPreimplementationGateEntryPoint`). A new function added to one surface without a declaration fails.
4. Per-runtime isolation in the style of AttributionTrailer (`Describe -ForEach` over the two runtimes, dot-sourcing in the per-runtime `BeforeAll`), plus the Claude `Resolve-OrchestrationGateTarget` resolver mock to `/synthetic-worktrees/default-session` (as at `AttributionTrailer.Tests.ps1:40`) and the baseline epic-state mocks.

Robustness to C1b (#732): the table is authored against the post-C1b gates at execution time; the helpers file stays covered by the existing four-way hash test, so the parity test does not re-assert it. No text comparison is used, so C1b's edits to either gate cannot make the test fail unless behavior diverges.

Bundle copies of both gates are covered by the existing root/bundle byte-identity tests (8.2); the parity test reads only the canonical `.claude/hooks` and `.codex/hooks` files.

## 9. `GENERATED_AGENT_FAMILIES` parity (Q9)

Copies of the 12-family list (verified by reading each):
- Python authority: `scripts/dev_tools/resolve_codex_deployment.py:32-47` (a `frozenset` literal).
- PowerShell: `.claude/lib/codex-routing/CodexDeployment.psm1:66-79` (`$script:GENERATED_AGENT_FAMILIES`, consumed with the case-sensitive `-cnotcontains` at `:279`). Bundled copies: `extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1` and `extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1` (both list the symbol at `:66` and `:279`).
- Central config: `config/orchestration-routing.json:341-354` (`codex_model_policy.generated_agent_families`); bundled copy `extensions/drm-copilot/resources/config/orchestration-routing.json` is asserted byte-identical to the root file at `tests/scripts/dev_tools/test_codex_model_policy_config_parity.py:76-83`.
- TypeScript: `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts:39-52` (a `Set`, different order; set-equal today).
- A hard-coded copy in a test: `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1:104-115` (drift-prone; it would not detect a Python-only addition).

Existing Python-to-config parity: `tests/scripts/dev_tools/test_codex_model_policy_config_parity.py:66-73` asserts `set(policy["generated_agent_families"]) == GENERATED_AGENT_FAMILIES`. There is no PowerShell-side pin; this is the #646 drift (`docs/features/potential/promoted/2026-09-07-codex-deployment-allowlist-drift.md`, suspected-cause paragraph).

Static pattern for the PowerShell side, from `tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1:14-26, 37-43`: import the module with `-Force`, read `config/orchestration-routing.json` with `Get-Content | ConvertFrom-Json`, and read module constants with `InModuleScope 'ModelRouting' { $script:X }`. The `CodexDeployment` module variable is script-scope, so `InModuleScope 'CodexDeployment' { $script:GENERATED_AGENT_FAMILIES }` works the same way.

Recommended test (new file, for example `tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1`): three assertions, none of which runs Python:
1. PowerShell set equals the config array (via `InModuleScope`), case-sensitive ordinal comparison of sorted sets.
2. PowerShell set equals the families parsed from the text of `scripts/dev_tools/resolve_codex_deployment.py` (regex over the `GENERATED_AGENT_FAMILIES: frozenset[str] = frozenset({ ... })` literal, then quoted tokens). This satisfies the issue wording "pinning ... between the Python authority and `CodexDeployment.psm1`" without launching an interpreter. Add in-memory extractor rows (zero declarations fail; a divergent fixture fails) in the style of `tests/scripts/dev_tools/test_push_down_claude_parity.py:348-376`.
3. Non-vacuity floor on each parsed set using the leading-comma idiom, because #711 documented that `@($null).Count` is 1 (`docs/features/completed/2026-09-26-remaining-cannot-fail-count-assertions-711/spec.md:127-131`).
Optional: include the TypeScript set by the same text-read method.

A pytest alternative (read the PowerShell file text from Python) is viable and sits beside the existing pytest sibling; Pester was chosen because the PowerShell constant is the artifact under pin, the module-scope read is exact, and the PoshQC run already executes the directory. Tests may run Python; hooks may not (`enforcement-hooks-must-not-use-python`), and this design avoids Python in either place.

Bundle mirror: `CodexDeployment.psm1` is mirrored; a drift fix (not currently needed, all four sets match) would require editing the three copies. Byte parity of the copies is enforced by `tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1:74` and `tests/scripts/dev_tools/test_push_down_codex_and_agents_virtual_paths.py:173-174`, and by `test_push_down_claude_resource_contracts.py:89-110`.

## 10. #746 (Q10)

Helper: `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1:16-56` (test-local, inside the `Describe` `BeforeAll`); the unrolling statement is `return $registrations.ToArray()` at line 55. Caller: `$script:Registrations = Get-CodexPreToolUseRegistration -ConfigPath $script:ConfigPath` at line 126; `$script:RegisteredHookNames` at 127. The file is 210 lines.

Mechanics: with zero registrations the function emits nothing and the caller binds `$null`; with one registration it emits a scalar object. `,$registrations.ToArray()` wraps the array so the caller always receives an array object (zero, one, or many), the idiom used by the other producers examined in #711.

#711 workarounds (spec decisions: `docs/features/completed/2026-09-26-remaining-cannot-fail-count-assertions-711/spec.md:276-281`, AC-5 at `:401-409`):
- Line 133: `@($script:Registrations | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0` compensates for `@($null).Count` being 1. After the comma fix `$script:Registrations` is never `$null` for the zero case, so the filter is no longer needed for that reason. The replacement must still fail for an empty array and for a missing (`$null`) result; `@($script:Registrations).Count` alone would pass vacuously for `$null`. Recommended: `$script:Registrations.Count | Should -BeGreaterThan 0` (fails for `@()`), plus `$null -ne $script:Registrations | Should -BeTrue` so a regression that returns `$null` also fails.
- Line 134: `@($script:Registrations | ForEach-Object { $_.Matcher } | Select-Object -Unique).Count` keeps its `@()` because the pipeline result can be scalar; #711 D4 classified it as sound (`spec.md:271-275`). No change.
- Lines 204-209 (`Context 'Non-vacuity floor for the registration count'`): documents the legacy expression `@($null).Count -gt 0` is `$true` while the filtered form is `$false`. It tests PowerShell, not the helper. After the fix it can be replaced by two rows that call the helper directly with `Get-Content` mocked to return in-memory lines (no temporary file): one registration yields an array with `Count` 1, zero registrations yields an empty array (not `$null`). The helper is a script-scope function defined in `BeforeAll`, so it is callable from an `It`. The acceptance condition "affected assertions still fail on an empty or missing set" is met by those rows.

Mirror: no copy of this test or helper exists under `extensions/drm-copilot/resources/` (Glob of `extensions/drm-copilot/resources/**/*.Tests.ps1` and `**/*Helpers.ps1` returned nothing). No bundle-parity test covers it. The `codex-pretooluse-integration` test reads `.codex/hooks` and `.codex/config.toml` only; the registered hooks' bundle copies are covered by the Codex root/bundle hash test (8.2).

## 11. Bundle mirrors and toolchain (Q11, Q12, Q13)

### 11.1 Mirrors per changed file

| File class | Mirror under `extensions/drm-copilot/resources/` | Parity enforced by |
| --- | --- | --- |
| All `tests/**/*.Tests.ps1` and test helpers (`EpicStateIsolation.Helpers.ps1`, `EnforcementHooksNoPythonInvocation.Helpers.ps1`, new helpers) | None (verified by Glob; the helper header says "NOT mirrored", `EnforcementHooksNoPythonInvocation.Helpers.ps1:59`) | not applicable |
| `.claude/hooks/*`, `.claude/lib/**` (not changed by C5b) | `claude-customizations/.claude/**` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` |
| `.codex/hooks/*` (not changed by C5b) | `codex-and-agents-customizations/.codex/hooks/**` | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:114-120` |
| `CodexDeployment.psm1` (changed only if a drift is found) | `claude-customizations/.claude/lib/codex-routing/`, `resources/lib/codex-routing/` | `CodexRouting.Manifest.Tests.ps1:74`, `test_push_down_codex_and_agents_virtual_paths.py:173-174` |

All C5b deliverables identified here are test-only. Unless the census reveals a production defect, no mirror update is required.

### 11.2 Toolchain

- Rule order: format, analyze, test (`.claude/rules/powershell.md:13-20`); MCP tools `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`; config `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`Run.Path` = `scripts`, `tests/powershell`, `tests/scripts`; coverage format CoverageGutters to `artifacts/pester/powershell-coverage.xml`; no coverage `Path`, population derived from the workspace per issue #527).
- Counts must come from a direct `Invoke-Pester` run over an explicit file list; MCP test results carry no per-test output (repository memory and #709 spec line 238). The #709 executor used a scratch script run via `pwsh -NoProfile -File` for targeted lists (`fail-before.2026-09-27T10-09.md`) and `Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest` for the full configured run (about 177 s, 5452 passed at that time; `pester-full.2026-09-27T10-20.md`).
- Coverage: no production file changes, so no production coverage delta; line coverage is the only PowerShell gate (>= 85%), branch is not measured.
- 500-line cap: line counts (Grep `^`) of files C5b may edit: `enforcement-hooks-no-python-invocation.Tests.ps1` 500, `EnforcementHooksNoPythonInvocation.Helpers.ps1` 500, `enforce-epic-worktree-removal-gate.Tests.ps1` 497, `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` 493, `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` 492, `enforce-powershell-batch-budget.Tests.ps1` 490, `enforce-orchestration-preimplementation-gate.Tests.ps1` 467, `enforce-parallel-worktree-removal-gate.Tests.ps1` 466, `enforce-epic-merge-gate.Tests.ps1` 456, `enforce-pr-author-skill.Tests.ps1` 456, `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` 399, `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` 396, `enforce-gate-suites.EpicStateIsolation.Tests.ps1` 373, `EpicStateIsolation.Helpers.ps1` 198, `codex-pretooluse-integration.Tests.ps1` 210. Suites within about ten lines of the cap can take at most a one- or two-line baseline mock; a four-line add (import plus mock for both seams) does not fit in the 490-500 range, so those suites need the guard to accept a helper-based baseline (dot-source one shared `Set-EpicStateBaselineMock`-style function that registers the mocks, which the AST rule recognizes by name) or the suite must be trimmed. The new discovery guard and probe should go in new files, not the 373-line guard file.
- Constraints honored by the design: no Python in hooks (no hook is touched); no temporary files (all inputs are committed files or in-memory strings; mocks of `Get-Content`/`Test-Path` replace file creation); 500-line cap (new files for discovery, probe, scan roots, parity tests); determinism (no clock, no network).

## 12. Candidate approaches and recommendation

### Approaches compared (discovery guard)

- A. Closure-based discovery plus baseline default-deny mocks (recommended). Selection by what a suite loads, computed from the tree; compliance forms F1/F2/F3; per-suite interception probe. Advantages: no list, catches new suites automatically, cost per suite is a few lines, consistent with #709 D1/D2 and the epic's "discovery" requirement. Limits: over-inclusive (non-reaching suites get a mock); needs an AST closure helper; helper-form recognition needed for suites near the 500-line cap.
- B. Call-graph reach analysis. Select only suites that invoke a function from which a seam is transitively callable. Advantages: fewer edits. Limits: the decision entry points are called by nearly every decision-driving suite, so it differs from A only for helper-only suites; adds a call-graph builder; still cannot tell data-dependent reach. Rejected for complexity versus benefit.
- C. Extend the explicit list. Directly contradicts the issue (D9) and the epic. Rejected.

### Recommended parity approach: behavioral parity over a shared case table with declared divergences (8.4). Rejected: byte identity (impossible; bodies differ by design) and normalized text identity (pins comments and intentional divergences).

## Numeric Derivation Evidence

Not applicable. This research proposes no numeric count, enumeration, or population as a `spec.md` acceptance criterion. The counts quoted (eight guarded suites; 12 families; line counts) are current-state observations. The guards are specified to assert non-vacuity (a non-empty discovered set per surface) and zero findings, never a literal member count, so that upstream children and future suites do not invalidate them. If the planner wants a literal count in an acceptance criterion, the two-strategy derivation must be added first: for the guarded-suite list, strategy 1 is the `-ForEach` rows at `enforce-gate-suites.EpicStateIsolation.Tests.ps1:39-46` and strategy 2 is a file-level Grep for suites whose root `BeforeAll` contains both seam mocks; they must be compared as member sets.

## Testing implications

- All verification is Pester. Fail-before evidence for each guard: run it against the unmodified suites and record the findings (as #709 did: 7 failed rows before the edits). Fail-after: zero findings.
- Each new guard needs predicate-discrimination rows over in-memory fixtures (compliant forms, and each non-compliant shape), a non-vacuity row, and a missing/unparseable-suite row, matching the existing guard's structure.
- Before-and-after Passed/Failed/Skipped equality for every edited suite, from a direct `Invoke-Pester` run.
- Interception probe rows are themselves tests of the baseline mocks; they must pass in the repository's normal run and in a depth-1 CI checkout.
- Verification that must be run on the integration branch (cannot be done in this session): the census output (section 2.4 rules R1-R7) with the suite list it selects; the extended no-Python scan; `Should -Invoke` counting semantics for a root-level mock.

## Automation Feasibility

No step requires human interaction. Every step is file reading, AST parsing, mock registration, and Pester execution through the PoshQC MCP tools or a direct `Invoke-Pester` run. The only environmental dependency is a shell route that can run PowerShell (the agent-worktree guard denies `pwsh` text in Bash; the PowerShell tool or the MCP tools are the routes used in #709). The census output and the extended no-Python guard run are the only items whose results are unknown until executed.

## Recommendations

Proposed decomposition into implementation units (test-only; no production or mirror change expected):

- U1. Census and discovery helpers (measure-only first). New helper file (suggested `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`) implementing R1 to R4 as pure functions over file text and AST, plus a census `It` that records, per surface, the selected suites and the findings. Run it on the integration branch after #736, #732, and #850 merge; the output is the fail-before record and the authoritative suite list. Decide open question O1 and O2 below from the output.
- U2. Discovery guard. New file (suggested `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`) with `BeforeDiscovery` that dot-sources the helpers and builds `-ForEach` rows from the discovered suites (Pester 5 requires the helper functions at discovery; define them by dot-sourcing in `BeforeDiscovery`, not `BeforeAll`). Keep the existing 373-line file's fixed list only if U2 removes it; otherwise replace the fixed `-ForEach` list (lines 38-47) with the discovered set and delete the D9 note (lines 24-25). Include CR-2 fixes (hook dot-source identification by closure name, direct-statement-only search, all top-level `BeforeAll` blocks, all `Mock`s of a seam) and CR-3 rows in `EpicStateIsolation.Helpers.ps1` and the predicate-row file (split predicate rows into a second file to respect the 500-line cap).
- U3. Baseline mocks for non-compliant suites found by U1/U2, in small groups: Claude ESR/WRR pairs (unguarded pr-author, model-routing, preimplementation suites), WRR-only suites (merge, removal, wave, cohort, drift), `Get-EpicMergeGateSessionWorktreeRoot` for the merge-gate suites (or its post-#850 equivalent), Codex script-scope mocks for `mode-resolution`, `mode-routing`, and the AttributionTrailer `codex` runtime, and the two `mode-routing` canonical-read rows (hermetic via `Test-Path` mock). Each edit requires unchanged Passed/Failed/Skipped counts before and after. Suites within about ten lines of the cap use the shared baseline helper form.
- U4. CR-1 interception probe: shared probe function plus one `It` per in-scope module-seam suite; guard requires the call (AST). Include the CR-7 comment fix in the same edit of the two `*.WorktreeResolution.Tests.ps1` suites.
- U5. No-Python guard extension: new scan-root helper, `.codex/hooks` added, "exactly two" comment and roots assertion updated, mirror-exclusion assertion kept; keep both existing files at or below 500 lines.
- U6. Preimplementation-gate parity test: shared case table, `Describe -ForEach` over the two runtimes, declared-divergence set, AST function-inventory check.
- U7. `GENERATED_AGENT_FAMILIES` parity test (section 9), including extractor rows and non-vacuity.
- U8. #746: `,$registrations.ToArray()` at `codex-pretooluse-integration.Tests.ps1:55`; replace the workaround at line 133; replace the documentation `Context` at 204-209 with direct helper rows (mocked `Get-Content`); no mirror.

Order: U1 first (measurement), then U2 and U4 together (guard and probe define the required shape), then U3 (edits driven by the guard's findings), then U5 to U8 (independent; can run in parallel with U3).

Mechanical discovery rules to carry into the spec: R1 to R4 (sections 2.4 and 3.3), with R5 recorded as a baseline observation only (not as an acceptance count).

Open decisions for the planner:
- O1. Include the item-checkpoint seam `Get-WorktreeItemCheckpointText` and `Get-WorktreeItemLiveRoot` (class A advisory) in the required set? `Get-WorktreeItemLiveRoot` enumerates real sibling worktrees through `git worktree list`; including it widens scope to a larger leak than epic state. This research kept it advisory.
- O2. Over-inclusion (closure-wide baseline mocks, option A) versus a stricter exemption for helper-only suites (option B). Recommendation: A.
- O3. Widen the census read predicate from `artifacts/orchestration/` to any `artifacts/` read (PR context, body file, receipt) to cover C3's new reads.
- O4. Process-spawning Codex suites (R7): report-only in C5b, or enforce a fixture/working-directory binding.

## Rejected alternatives (brief)

- Extending the fixed seven/eight-suite list: contradicts the issue and the epic.
- Production seam (environment variable or injectable root) for the read: rejected in #709 D1(c) for adding a bypass surface to enforcement code; still applies.
- Byte or normalized-text parity of the main preimplementation gates: not achievable.
- Python-run parity for `GENERATED_AGENT_FAMILIES`: unnecessary; the source text and config are static files.
