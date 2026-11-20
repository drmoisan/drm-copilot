# `2026-09-13-target-worktree-resolution-module` — User Story

- Issue: #669
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-13T21-40
- Epic: `docs/features/epics/worktree-scoped-state-resolution/epic.md` (F1, wave 0, complexity C3)
- Spec: `docs/features/active/2026-09-13-target-worktree-resolution-module-669/spec.md`
- Work Mode: `full-feature`

## Story Statement

- As the author of a downstream epic feature (F4 or F5), I want a single primitive that tells me which worktree a tool call pertains to and whether that answer is trustworthy, so that I can write a fail-closed deny path against a named reason code instead of inventing my own resolution heuristic in each hook.
- As an orchestrating session whose current working directory is not the worktree of the item being acted on, I want gate decisions made against my call's target rather than against my cwd, so that a delegation for an item whose documents exist is allowed and a delegation validated against a different item's state is denied.
- As the maintainer of the push-down surface, I want the new module registered and mirrored in the same change that creates it, so that the fix reaches consumer repositories rather than existing only in this tree.

## Problem / Why

`drm-copilot` hooks and MCP tools resolve orchestration state — feature folders, checkpoints, and
diff bases — against the invoking session's current working directory rather than against the
worktree the tool call actually pertains to.

In a single-worktree topology cwd and target coincide, so the defect is invisible. In a parallel or
epic topology the orchestrating session's cwd is a different worktree from the item being acted on,
and the same code path produces two failure modes:

- **False denial** — a gate reads the wrong root, does not find a document that exists, and denies a
  delegation that should have been allowed.
- **False approval** — a gate reads a sibling item's checkpoint, finds it satisfactory, and allows an
  action that was never validated against its own item's state.

The false-approval mode is the more serious. A gate that denies incorrectly stalls a run visibly. A
gate that validates one item's action against a different item's state reports a green that means
nothing, and the run proceeds on an unverified basis.

Verified 2026-09-13 against this tree: `.claude/lib/` holds eleven module directories (`bash`,
`blast-radius`, `cleanup-manifest`, `codex-routing`, `discovery-validation`, `hook-payload`,
`mermaid`, `model-routing`, `orchestrator-state`, `project-file-merge`, `requirements`) and none of
them resolves a worktree or a call target. There is no shared primitive for downstream gates to
consume, so F4 and F5 cannot specify their deny paths until one exists.

A concrete instance of the path-normalisation half of the defect exists today in
`enforce-prd-feature-before-planner.ps1`. The epic attributes the lost absolute prefix to a
four-segment truncation; research re-verified the file and found the prefix is discarded one step
earlier, by the unanchored regex at line 252 that begins matching at the literal `docs`. The slice at
lines 272-277 removes a suffix, not a prefix. The consequence is the same — a bare relative path
probed with `Test-Path -LiteralPath` against the hook process's cwd — but the correction determines
that this feature's signal extractor must preserve an absolute prefix rather than re-derive a bare
relative token.

## Personas & Scenarios

### Persona 1 — the downstream feature author (F4 / F5)

- **Who they are.** The agent or engineer implementing `prd-feature-gate-target-resolution` (F4) or
  `false-approval-elimination-pr-author-model-routing` (F5) in wave 1 of this epic.
- **What they care about.** Writing a deny path that is correct, greppable, and reviewable. They need
  to distinguish "target resolved, document genuinely absent" from "target not resolvable" and deny
  differently in each case; that distinction is the substance of the epic's fix 3.
- **Their constraints.** They may not port anything to Python. They may not widen any existing gate
  matcher. Their hook files sit close to the 500-line cap
  (`enforce-prd-feature-before-planner.ps1` has 52 lines of headroom), so they cannot absorb
  resolution logic in place and must consume a library. They cannot start a subprocess on a
  PreToolUse hot path.
- **Their frustration today.** There is no primitive to call. Each would have to write its own
  worktree locator, its own normaliser, and its own reason code, and the two would drift — exactly
  the "second implementation of the rule" failure the repository has already experienced.
- **What they need from F1.** A result object whose four states are readable without a second lookup,
  a reason code literal they can obtain from an accessor rather than hard-code, and a join helper so
  a resolved worktree root can be turned into an absolute
  `artifacts/orchestration/orchestrator-state.json` path.

### Persona 2 — the orchestrating session whose gate decisions are made on its behalf

- **Who it is.** A parallel or epic orchestrator running in one worktree while coordinating work
  items that live in sibling worktrees. It does not call the resolution module itself; the gates that
  govern its tool calls do, on its behalf.
- **What it cares about.** Forward progress that is real. A denial it cannot act on stalls the run; an
  approval granted on another item's state produces work that was never validated.
- **Its constraints.** It cannot change its own cwd per call. Its delegation prompts carry the target
  in whatever form the caller wrote — sometimes a relative feature-folder token, sometimes an
  absolute path.
- **Its frustration today.** Run `bugs-2026-09-11` reached a complete standstill: zero agents
  runnable, three items merged, five blocked behind gates, and one blocked fix that the orchestration
  which produced it was structurally unable to land.
- **What it needs from F1.** Nothing directly. F1 adds no consumers. What it needs is that the
  contract F4 and F5 are built on makes its correct cases allowable and its unverifiable cases deny
  with a reason a human can read.

### Scenario A — a parallel orchestrator at the session root delegates for an item in a sibling worktree

1. A parallel orchestrator is running with its current directory at the session root worktree,
   `W_session`. Its run has several items, each with its own worktree.
2. It reaches the point where item `2026-09-13-some-item-700` is ready for planning, and issues
   `Agent(subagent_type='atomic-planner')` with a prompt that names the item's feature folder in
   absolute form, inside worktree `W_target`.
3. The PreToolUse gate for that call (F4's site, in wave 1) calls `Resolve-WorktreeCallTarget -Text
   $prompt`.
4. `Find-WorktreeResolutionFeatureFolderSignal` matches the feature-folder token **with its absolute
   prefix preserved**. The normaliser walks upward from that path, finds a `.git` file at `W_target`
   whose first line is `gitdir: <main>/.git/worktrees/<name>`, and returns `W_target` as the
   containing worktree root together with the full repo-relative remainder.
5. `W_target` is not `W_session`, so the result is `Status = 'OtherWorktree'`, `WorktreeRoot =
   W_target`, `Signal = 'FeatureFolderPath'`, `Candidates` holding that one root, and `ReasonCode =
   $null`.
6. The gate probes `Join-WorktreeResolutionPath -WorktreeRoot $target.WorktreeRoot -RepoRelativePath
   'docs/features/active/2026-09-13-some-item-700/spec.md'` with `Test-Path -LiteralPath`. The path
   is absolute, the document exists, and the gate allows.
7. **Obstacle variant.** If the prompt had named the folder in relative form instead, the module
   enumerates the candidate worktree set from the session root — main checkout included — and tests
   containment in each. If exactly one candidate holds the folder, the outcome is the same allow. If
   two or more hold it, or none does, the result is `Status = 'Ambiguous'` with `ReasonCode =
   'TARGET_WORKTREE_AMBIGUOUS'` and the gate denies with a message naming the token and the candidate
   set, so the operator can re-issue the delegation with an absolute path.
8. **Expected outcome.** The epic acceptance criterion "A parallel orchestrator whose cwd is the
   session root can delegate `Agent(atomic-planner)` for an item whose `spec.md` exists" becomes
   reachable once F4 consumes this contract. Without the enumerator (Ruling C) the relative-form
   branch of step 7 would be permanently undecidable.

### Scenario B — a standalone single-worktree run where cwd and target coincide

1. An engineer runs a standalone, non-parallel orchestration. There is one worktree. The session root
   and the item's worktree are the same directory.
2. A gate call carries a feature-folder token, relative or absolute, naming a folder inside that one
   worktree.
3. `Resolve-WorktreeCallTarget` locates the containing worktree by the same upward walk and finds the
   worktree the invoking process is already running in.
4. The result is `Status = 'SessionRoot'`, `WorktreeRoot` equal to `SessionRoot`, `Candidates`
   holding exactly that one root, and `ReasonCode = $null`.
5. The gate resolves state against `WorktreeRoot`, which is the same directory it would have used
   before the change.
6. **Expected outcome.** Behaviour is byte-for-byte the same as today. This is the epic's fourth
   must-not-regress constraint, and it is carried as its own acceptance criterion and as an explicit
   regression-guard row in the Pester matrix rather than being omitted as redundant.

### Scenario C — a call whose only available state belongs to a sibling item

1. A coordinating session, cwd at `W_session`, makes a gate-governed call for item B, whose worktree
   is `W_b`. The session root's `artifacts/orchestration/orchestrator-state.json` belongs to item A.
2. Today the gate reads the bare relative literal `artifacts/orchestration/orchestrator-state.json`,
   which resolves against the hook process's current directory, finds item A's checkpoint, considers
   it satisfactory, and allows. Nothing in the log records that the wrong item's state was consulted.
3. With this contract in place, the gate calls `Resolve-WorktreeCallTarget`. Ruling B applies: the
   module never consults a checkpoint, and never consults orchestrator state of any kind, to decide
   which worktree a call pertains to.
4. If the call's signals place it unambiguously in `W_b`, the gate reads item B's checkpoint at
   `Join-WorktreeResolutionPath -WorktreeRoot W_b -RepoRelativePath
   'artifacts/orchestration/orchestrator-state.json'` — item A's checkpoint is never reached.
5. If the call's signals cannot be placed, or two present signals place it in two different
   worktrees, the result is `Status = 'Ambiguous'` with `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`.
   The gate denies. It does not fall back to whatever checkpoint occupies the session root.
6. If the call genuinely carries no target signal at all, the result is `Status = 'NoTarget'` with
   `WorktreeRoot = $null` and `SessionRoot` populated. The gate may fall back to the session root
   deliberately, in an explicit branch, because there is nothing else the call could mean.
7. **Expected outcome.** The false-approval mode is closed by construction rather than by care. The
   decisive property is that the presence of a signal, not the success of resolving it, separates
   `NoTarget` from `Ambiguous`, and both are readable from the result object alone.

## Acceptance Criteria

These criteria are identical in wording to the set mirrored in `spec.md`. Each is one checkbox on one
line.

### Contract surface

- [x] A new module directory `.claude/lib/worktree-resolution/` exposes target derivation via `Resolve-WorktreeCallTarget`, path normalisation via `ConvertTo-WorktreeResolutionRepoRelativePath`, and the ambiguity reason code via `Get-WorktreeResolutionAmbiguityReasonCode`, and this feature rewires no hook, no MCP tool, and no other consumer.
- [x] `Resolve-WorktreeCallTarget` always returns a `[pscustomobject]` and never `$null`, carrying the fields `Status`, `WorktreeRoot`, `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, and `Detail`.
- [x] `Status` takes exactly one of the literal values `SessionRoot`, `OtherWorktree`, `NoTarget`, and `Ambiguous`, and a Pester test asserts that every one of those four values is produced by at least one documented input.
- [x] For every `Status`, the `SessionRoot` field is populated, the `Candidates` field is an array (possibly empty) rather than a scalar or `$null`, and the `Detail` field is a non-empty string.
- [x] `WorktreeRoot` is populated for `Status = 'SessionRoot'` and `Status = 'OtherWorktree'` and is `$null` for both `Status = 'NoTarget'` and `Status = 'Ambiguous'`, so a caller branching on `WorktreeRoot` alone cannot treat an unresolved call as a resolved one.
- [x] Regression guard: when the derived target's containing worktree is the worktree the invoking process is running in, `Status` is `SessionRoot`, `WorktreeRoot` equals `SessionRoot`, `ReasonCode` is `$null`, and `Candidates` holds exactly that one root.
- [x] A payload carrying no target signal at all returns `Status = 'NoTarget'` with `Signal = $null`, `SignalValue = $null`, `WorktreeRoot = $null`, `ReasonCode = $null`, and an empty `Candidates` array.
- [x] A payload carrying a target signal that cannot be placed in exactly one worktree returns `Status = 'Ambiguous'` with `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`, `Signal` naming the signal kind that was present, and `SignalValue` carrying the raw token verbatim.
- [x] The `NoTarget` versus `Ambiguous` distinction is determinable from the returned result object alone, with no further filesystem read, state read, or heuristic required of the caller, and a Pester test asserts both results are distinguishable by `Status` and by `ReasonCode`.
- [x] Every documented `Ambiguous` sub-case is covered by a test: a repo-relative feature-folder token matching two or more candidate worktrees, a repo-relative token matching zero candidate worktrees, an absolute path whose upward walk reaches the filesystem root without finding a `.git` entry, a branch signal matching no worktree, a branch signal matching more than one worktree, and two present signals resolving to different worktree roots.

### Rulings A, B, and C

- [x] Ruling A: `ConvertTo-WorktreeResolutionRepoRelativePath` given a relative input and no `-WorktreeRoot` returns `IsNormalized = $false`, `RepoRelativePath = $null`, `WorktreeRoot = $null`, and `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`, and never returns the input unchanged as though it had been normalised.
- [x] Ruling A complement: `ConvertTo-WorktreeResolutionRepoRelativePath` given a relative input and an explicit `-WorktreeRoot` returns `IsNormalized = $true` with that root normalised into `WorktreeRoot` and the input normalised into `RepoRelativePath`.
- [x] Ruling B: no function in either module reads a checkpoint, an orchestrator-state file, or any other run artifact, and a repository-wide grep of the module sources for `orchestrator-state` and `checkpoint` returns no functional reference.
- [x] Ruling B: two present signals that resolve to different worktree roots return `Status = 'Ambiguous'`, and two present signals that resolve to the same root deduplicate to a single candidate and resolve normally to `SessionRoot` or `OtherWorktree`.
- [x] Ruling B: the documented signal precedence order `FeatureFolderPath`, then `FilePath`, then `Branch` determines only which signal kind is reported in `Signal` and `SignalValue` when the present signals agree on one worktree root, and a test asserts that precedence never suppresses a disagreement.
- [x] Ruling C: the candidate worktree set is derived from the session root with no git subprocess, by treating a `.git` directory as a main checkout and a `.git` file's `gitdir:` line plus that admin directory's `commondir` file as the route from a linked worktree back to the main `.git` directory.
- [x] Ruling C: the candidate worktree set includes the main checkout itself and not only the linked worktrees, and a test asserts the main checkout is returned when the session root is a linked worktree.
- [x] Ruling C: each `<main>/.git/worktrees/<name>/gitdir` file is read as the path to that worktree's own `.git` file, and the worktree root is taken as that file's parent directory.
- [x] Ruling C: containment resolves to exactly one worktree for the resolved states, and both the two-or-more case and the zero case return `Status = 'Ambiguous'`.
- [x] Containment is never tested by string-prefix comparison against a single known root, and a test covers a worktree that is a sibling of the main checkout rather than a descendant of it.

### Path normalisation and composition

- [x] `ConvertTo-WorktreeResolutionRepoRelativePath` returns a `[pscustomobject]` carrying `IsNormalized`, `RepoRelativePath`, `WorktreeRoot`, `ReasonCode`, and `Detail`, with `ReasonCode` set to `TARGET_WORKTREE_AMBIGUOUS` exactly when `IsNormalized` is `$false` and `$null` otherwise.
- [x] An absolute path inside a locatable worktree normalises to the full repo-relative remainder below that worktree root with no path segment lost, and its absolute prefix is recovered into `WorktreeRoot` rather than discarded.
- [x] No fixed segment-count truncation of any path appears anywhere in either module, and a test asserts that a repo-relative remainder deeper than four segments survives normalisation intact.
- [x] Normalised paths use forward slashes regardless of input separator, carry no trailing slash, and carry no leading `./`.
- [x] `Find-WorktreeResolutionFeatureFolderSignal` preserves an absolute worktree prefix present in the scanned token rather than re-deriving a bare repo-relative token, which is the correction to the epic's characterisation of `enforce-prd-feature-before-planner.ps1`.
- [x] `Join-WorktreeResolutionPath -WorktreeRoot <root> -RepoRelativePath <rel>` returns an absolute forward-slash path, giving F4 and F5 a single composition for turning a resolved target into an absolute `artifacts/orchestration/orchestrator-state.json`.

### Reason code

- [x] `Get-WorktreeResolutionAmbiguityReasonCode` returns the exact literal string `TARGET_WORKTREE_AMBIGUOUS`, and a Pester test pins that literal so a rename is a test failure rather than a silent contract break for F4 and F5.
- [x] The ambiguity reason code does not carry a `_BLOCKED` suffix, because F1 owns no gate and the suffix family is reserved for a hook's own leading decision token.
- [x] The `Detail` field of an ambiguous result is a prose clause safe to concatenate directly into a `permissionDecisionReason` after a gate's own `*_BLOCKED` token, and a test asserts the concatenated form contains both the gate token and `TARGET_WORKTREE_AMBIGUOUS`.

### Seams and determinism

- [x] The module's only filesystem contact is three named, script-scoped, injectable seams — `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, and `Get-WorktreeResolutionDirectoryChildName` — each mockable with `Mock -CommandName <seam> -ModuleName '<Module>'`.
- [x] No function in either module starts a subprocess, invokes git, reads a wall clock, accesses the network, or reads an environment variable.
- [x] No test in any of the three suites creates, writes, or reads a temporary file, reads a wall clock, spawns a process, or touches the network, and the suites' comment-based help states that determinism posture explicitly.
- [x] The full required matrix is covered by a table-driven Pester suite spanning the cross product of cwd (session root versus item worktree), path form (relative versus absolute), and target (own item versus sibling item versus absent), with currently-passing rows retained as regression guards.

### Registration, mirroring, and coverage

- [x] `.claude/lib/worktree-resolution/WorktreeResolution.psm1` appears exactly once in the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, asserted by an exact string-equality filter whose survivor count is compared to one.
- [x] `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` appears exactly once in the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, asserted by an exact string-equality filter whose survivor count is compared to one.
- [x] `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` follows the `DiscoveryValidation.Manifest.Tests.ps1` pattern, asserting `-Contain`, exactly-once registration, and that every on-disk `*.psm1` in the module folder is covered by the expected-path list.
- [x] The same manifest suite carries a separate `Describe` asserting SHA-256 byte identity of each repo-side module against its bundle mirror, including a `Test-Path -LiteralPath $bundleFile | Should -BeTrue` guard, following `DiscoveryValidation.Manifest.Tests.ps1` rather than the thinner `ModelRouting.Manifest.Tests.ps1`.
- [x] Both modules are mirrored at `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1` and `.../WorktreeTargetResolution.psm1`, and the mirrored copies are byte-identical to the repo-side copies by SHA-256.
- [x] Both module paths are added to `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- [x] Both module paths are added to `CodeCoverage.Path` in `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and the two runsettings copies remain text-identical so `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes.
- [x] No `extensions/drm-copilot/resources/` path is added to `CodeCoverage.Path` in either runsettings copy.
- [x] Line coverage for both new module files is at or above 85%, read per file from `artifacts/pester/powershell-coverage.xml` keyed on the enclosing `package` element rather than the bare `sourcefile` name, and not inferred from a passing run given `CoveragePercentTarget = 0`.

### Policy compliance

- [x] No Python file is added or edited by this feature, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with the new module inside its scan scope.
- [x] No file created or edited by this feature exceeds 500 physical lines, as counted by the line-count assertion in `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`.
- [x] All Pester suites for this feature live under `tests/scripts/claude-lib/worktree-resolution/` and no test file is colocated with production source.
- [x] Both modules satisfy `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` in full, including the `imports its siblings with -ErrorAction Stop` help sentence before the strict-mode line, `Set-StrictMode -Version Latest` immediately followed by `$ErrorActionPreference = 'Stop'`, `-ErrorAction Stop` on every column-0 `Import-Module`, and an unchanged caller `$ErrorActionPreference` after import.
- [x] The PowerShell toolchain completes in a single pass in order — format, then analyze, then test — with no stage failing and no stage modifying a file, and the observed PoshQC success output is captured under this feature's `evidence/qa-gates/` rather than inferred.

### Must not regress (carried verbatim from the epic)

- [x] Gates must still deny when a required document is genuinely absent.
- [x] Do not weaken the pre-implementation gate's pathspec, option, or metacharacter restrictions.
- [x] Do not widen the merge gate's matcher as a side effect of fixes 1-3.
- [x] Epic and standalone topologies must behave exactly as now when cwd and target coincide.

## Non-Goals

- **No consumers are rewired.** No hook, no MCP tool, and no skill calls the new module in this
  feature. `enforce-prd-feature-before-planner.ps1`, `enforce-pr-author-skill*.ps1`, and
  `enforce-model-routing-receipt.ps1` are unchanged. Rewiring is F4's and F5's scope.
- **No hook file is edited at all**, in either the `.claude/hooks/` tree or the `.codex/hooks/` tree.
  F1 has no Codex parity obligation because it introduces no hook.
- **No Python.** Enforcement and hook-adjacent code is PowerShell or bash only. A Python leg creates
  a second implementation of the rule that drifts from the first, which has already occurred in this
  repository.
- **No widening of any existing gate matcher.** In particular the epic-merge gate's `pr_number`
  matcher is untouched, per the epic's RULING 1, and the pre-implementation gate's pathspec, option,
  and metacharacter restrictions are untouched.
- **No git subprocess.** The module locates and enumerates worktrees by reading git's on-disk
  administrative layout through injectable seams. `git rev-parse --show-toplevel` and every other
  executable invocation are out of scope for this module; if a later feature needs true git ground
  truth, that belongs in an entry-point `.ps1` with an `Invoke-GitExe` wrapper, following the
  `Resolve-MergeableConflict.ps1` precedent.
- **No changes to `HookPayload.psm1`.** It has four lines of headroom against the 500-line cap and
  declares "no filesystem access, no subprocess, no network, and no wall-clock read" as a module
  property; adding a filesystem probe would falsify that invariant.
- **No push-down, no extension rebuild, and no reinstall.** Delivery to consumer repositories is F7's
  scope. F1 only ensures the module is registered and mirrored so that F7 has something to deliver.
- **No new configuration surface.** The module reads no configuration file, no environment variable,
  and no orchestrator state.
