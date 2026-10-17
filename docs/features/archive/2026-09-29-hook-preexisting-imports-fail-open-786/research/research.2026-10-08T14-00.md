# Research: hook pre-existing imports fail open (#786) and hook-imported modules must not write stdout (#792)

- Issue: #786 (primary), #792 (bundled)
- Epic: #852 enforcement-hook-precision, child C4 (wave 3)
- Branch inspected: `bug/hook-preexisting-imports-fail-open-786` (cut from `origin/epic/enforcement-hook-precision-integration`)
- Researched: 2026-10-08T14-00
- Mode: preparation, research only

## Method and Evidence Limits

- Every file:line citation below was verified in this session with the Read, Grep, and Glob tools against the
  branch working tree.
- This research session had no shell tool (no `git`, no `pwsh`). Consequences, stated once:
  - The AST enumeration command in Q3 was written but **not executed**; the "current tree" table in Q3 was
    derived by Grep plus full file reads, and the executor must run the command and reconcile its output
    with that table before relying on either.
  - The #787 branch diff was **not read**. The command to read it is given in Q3.
  - PowerShell runtime behavior on import failure (Q1 "current behavior") is stated from documented
    PowerShell error semantics and the code shape. It was not observed in a run. Each such statement is
    marked "inferred".
- Claude Code and Codex hook contracts were read from the vendor documentation with WebFetch
  (`https://code.claude.com/docs/en/hooks`, `https://learn.chatgpt.com/docs/hooks`, 2026-10-08).

## Q1. Hook registration and decision contracts

### Registered hooks (both surfaces)

Claude, `.claude/settings.json`:

- PreToolUse, matcher `Bash` (lines 89-126): `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`,
  `enforce-pr-author-skill.ps1`, `enforce-orchestration-preimplementation-gate.ps1`,
  `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`,
  `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-abandon-gate.ps1`.
- PreToolUse, matcher `Write|Edit` (lines 127-175): `check-python-test-purity.ps1`,
  `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`,
  `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`,
  `enforce-orchestration-preimplementation-gate.ps1`, `enforce-feature-folder-order.ps1`,
  `enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1`,
  `enforce-discovery-artifact-gate.ps1`, `enforce-mermaid-validation.ps1`.
- PreToolUse, matcher `Agent` (lines 176-208): `enforce-prd-feature-before-planner.ps1`,
  `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-wave-barrier.ps1`,
  `enforce-model-routing-receipt.ps1`, `enforce-epic-invocation-origin.ps1`,
  `enforce-parallel-cohort-barrier.ps1`, `enforce-parallel-drift-gate.ps1`.
- SubagentStop (lines 210-286): an inline `pwsh -Command` (line 216, no imports),
  `validate-discovery-artifact-gate.ps1`, `validate-feature-review-coverage.ps1`,
  `validate-planner-output.ps1`, `validate-prd-feature-output.ps1`, `validate-pr-author-output.ps1`,
  `validate-orchestrator-output.ps1` (registered three times: lines 265, 274, 283).
- Not registered (verified absent from settings.json): `validate-executor-output.ps1`,
  `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`. SessionStart
  `persist-session-id.ps1` (line 84) is out of scope.

Codex, `.codex/config.toml` (there is no `.codex/hooks.json`; hooks are TOML tables):

- PreToolUse `^Bash$` (lines 119-150): `validate-bash.ps1`, `enforce-promotion-mcp-only.ps1`,
  `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`,
  `enforce-epic-worktree-removal-gate.ps1`.
- PreToolUse `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` (lines 152-183):
  `enforce-epic-root-invocation.ps1`, `enforce-codex-model-routing.ps1`, `enforce-epic-planning-only.ps1`,
  `enforce-epic-wave-barrier.ps1`, `enforce-epic-child-worktree-binding.ps1`.
- PreToolUse `^(apply_patch|Edit|Write)$` (lines 185-234): `check-python-test-purity.ps1`,
  `enforce-python-batch-budget.ps1`, `check-powershell-test-purity.ps1`,
  `enforce-powershell-batch-budget.ps1`, `enforce-evidence-locations.ps1`,
  `enforce-orchestration-preimplementation-gate.ps1`, `enforce-checkpoint-monotonic.ps1`,
  `enforce-completion-consistency.ps1`.
- SubagentStop (lines 236-252): `validate-codex-subagent-routing.ps1`, `validate-feature-review-coverage.ps1`.
- Out of scope (other events): UserPromptSubmit `authorize-root-epic-invocation.ps1` (line 104),
  SubagentStart `record-subagent-routing-attestation.ps1` (line 114).

### Exit-code and output contracts (vendor documentation)

| Surface / event | Exit 0 | Exit 2 | Other non-zero (for example 1, an unhandled throw) | Deny / block shape |
|---|---|---|---|---|
| Claude PreToolUse | stdout parsed as JSON if it starts with `{`; otherwise plain text, no decision | blocks the call; stderr is the reason; overrides any JSON | non-blocking error, action proceeds | `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` |
| Claude SubagentStop | as above | prevents the stop; stderr is the reason | non-blocking | `{"decision":"block","reason":"..."}` |
| Codex PreToolUse | output processed | blocking decision, stderr is the reason | hook failure, non-blocking | same `hookSpecificOutput` deny shape (legacy `{"decision":"block"}` also accepted) |
| Codex SubagentStop / Stop | output processed | block, stderr is the reason | hook failure, non-blocking; plain-text stdout is "invalid for this event" | `{"decision":"block","reason":"..."}` |

Consequences verified against the code:

- Claude PreToolUse hooks in this repo emit the deny JSON at exit 0 through a per-hook constructor (for
  example `Get-PrAuthorSkillBlockDecision`, `.claude/hooks/enforce-pr-author-skill.ps1:214-237`) and
  serialize with `ConvertTo-Json -Compress -Depth 5 | Write-Output` (`:296`). The entry points document
  that exit 1 is non-blocking (`enforce-epic-wave-barrier.ps1:343-347`, `HookPayload.psm1:30-34`).
- There is **no shared deny emitter**. Grep for `^function Get-\w*(Block|Deny)\w*Decision` in
  `.claude/hooks` returned 19 per-hook constructors (for example `enforce-epic-merge-gate-authorization.ps1:69`,
  `enforce-orchestration-preimplementation-gate.ps1:268`, `validate-bash.ps1:348`). `HookPayload.psm1`
  (496 lines) contains no emitter; it exports only payload readers (`:486-496`).
- Claude SubagentStop scripts block with `Write-Error` then `exit 1` (`validate-orchestrator-output.ps1:416-418`,
  `validate-discovery-artifact-gate.ps1:251-254`, `validate-prd-feature-output.ps1:90`,
  `validate-pr-author-output.ps1:133`, `validate-planner-output.ps1:407`,
  `validate-feature-review-coverage.ps1:456`), and so does the inline command (`settings.json:216`). Per the
  documentation, exit 1 is non-blocking for SubagentStop. This pre-existing defect is already recorded,
  unpromoted, in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md:39,74`.
  It is outside #786's stated scope; see Open Decision D1.
- Codex hooks wrap the entry tail in `try { ... exit 0 } catch { [Console]::Error.WriteLine(...); exit 2 }`
  (for example `.codex/hooks/enforce-epic-merge-gate.ps1:364-379`,
  `validate-codex-subagent-routing.ps1:146-153`), so an error raised **inside** that `try` blocks. Their
  dot-sources sit **outside** the `try` at file top level (`enforce-epic-merge-gate.ps1:11-12`).

### Current behavior on an import failure (inferred, not executed)

Documented PowerShell semantics: `Import-Module` without `-ErrorAction Stop` on a missing file writes a
non-terminating error and execution continues; `-ErrorAction Stop` (or a module's
`$ErrorActionPreference = 'Stop'`) makes it terminating, and with no enclosing `try` the script ends and
`pwsh -File` exits 1; an undefined command (`CommandNotFoundException`, also what a missing dot-sourced
file raises) is statement-terminating, so the current statement is abandoned and the next statement runs.
Applied to the code:

- Claude, unguarded `-ErrorAction Stop` import (for example `enforce-model-routing-receipt.ps1:53,55`,
  `enforce-pr-author-skill-helpers.ps1:41-49` reached through the dot-source at
  `enforce-pr-author-skill.ps1:150`): the script terminates, exit 1, no JSON. Non-blocking: fail open.
  The comments at `enforce-model-routing-receipt.ps1:51-52` and `enforce-prd-feature-before-planner.ps1:104-110`
  describe "unguarded" as "fail-closed on purpose"; on PreToolUse that premise is incorrect.
- Claude, unguarded import without `-ErrorAction Stop` (every `HookPayload.psm1` import, for example
  `enforce-pr-author-skill.ps1:47`): the script continues with the HookPayload functions undefined. In
  `Invoke-PrAuthorSkillDecision` (`:172-192`) the deny statement at `:174-177` is abandoned because its
  argument calls the undefined `Get-ClaudeHookPayloadAnomalyReason`; execution then reaches `:181-183` and
  returns the **allow** decision at exit 0. In `enforce-model-routing-receipt.ps1:291` the whole
  `$decision = ... (Read-ClaudeHookRawPayload)` statement is abandoned and stdout carries no decision
  object. Both are fail-open, the first as an explicit allow.
- Claude SubagentStop `validate-orchestrator-output.ps1`: `$ErrorActionPreference = 'Stop'` (`:39`) makes the
  unguarded import at `:41` terminating, so exit 1, which is non-blocking.
- Codex: a missing dot-sourced sibling raises `CommandNotFoundException` at top level and execution
  continues; the first call to a missing function inside the entry `try` lands in the `catch` and exits 2,
  which blocks, but the reason names a function, not the dependency. A missing function reached only on
  some paths, or called before the `try`, does not block.

The first regression test of the fix must confirm these inferences under the seam in Q5 before the fix is
applied (expect-fail evidence).

## Q2. The #690 guarded-import pattern

Verbatim reference (`.claude/hooks/enforce-epic-wave-barrier.ps1:43-50`):

```powershell
# Import guard (issue #690): a failed import denies instead of failing open.
$script:EpicWaveBarrierResolutionImportFailure = $null
try {
    Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeRunResolution.psm1') -Force -ErrorAction Stop
}
catch {
    $script:EpicWaveBarrierResolutionImportFailure = 'WorktreeRunResolution.psm1'
}
```

The deny is emitted as the first statement of the decision function (`:284-289`), before the
`Resolve-ClaudeHookToolInput` call, through the hook's own `Get-EpicWaveBarrierBlockDecision`, with the
hook's leading token `EPIC_WAVE_BARRIER_BLOCKED:` and the module name.

The pattern is **copy-pasted, seven times**, each with its own variable and its own deny function:
`enforce-epic-wave-barrier.ps1:43-50`, `enforce-parallel-drift-gate.ps1:72-79`,
`enforce-parallel-cohort-barrier.ps1:57-` (`$script:ParallelCohortBarrierResolutionImportFailure`, `:58`),
`enforce-parallel-worktree-removal-gate.ps1:48-` (`:49`), `enforce-epic-merge-gate-resolution.ps1:29-55`,
`enforce-epic-worktree-removal-gate-resolution.ps1:26-` (`:27`), and the loop form in
`enforce-orchestration-preimplementation-gate-epic-scope.ps1:41-71`. Mirrors are byte-identical under
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (Grep returned the same seven
variable assignments there).

Two weaknesses found in the copies:

- Ordering hazard. `Get-EpicMergeGateImportFailureDecision` (`enforce-epic-merge-gate-resolution.ps1:52`)
  calls `Get-EpicMergeGateBlockDecision`, which is defined in the separately dot-sourced and unguarded
  `enforce-epic-merge-gate-authorization.ps1:69` (dependency stated at `-resolution.ps1:24-25`). If the
  authorization file fails to load, the guard's own deny path calls an undefined function.
- Partial coverage. The epic-scope loop guards three modules but imports `EpicScopeReadiness.psm1`
  unguarded with `-ErrorAction Stop` on the next line (`-epic-scope.ps1:52`). Every guarded hook still
  imports `HookPayload.psm1` unguarded.

## Q3. Current enumeration

Legend: G = inside a `try` body at the import site; U = unguarded; Stop = `-ErrorAction Stop`; Runtime =
inside a function or a scriptblock default, so it runs during the decision rather than at load; DS =
dot-source; M = Import-Module. "Covered" means a guard at a shallower edge would catch a failure of this
edge once that edge is inside a `try` (a terminating error in a nested script or module propagates to the
nearest enclosing `try`).

### Claude PreToolUse (24 registered scripts)

| Hook | Direct edges (file:line, kind, target, guard) | Transitive edges |
|---|---|---|
| validate-bash | `:41` M HookPayload U; `:45` DS hook-command-scanner U; `:46` DS hook-command-invocation U | invocation `:17` DS scanner |
| enforce-promotion-mcp-only | `:33` M HookPayload U; `:38` DS scanner U; `:39` DS invocation U | invocation `:17` |
| enforce-pr-author-skill | `:47` M HookPayload U; `:53` M OrchestratorState U; `:146` DS `enforce-pr-author-skill.epic-base-branch.ps1` U; `:150` DS `enforce-pr-author-skill-helpers.ps1` U | epic-base-branch `:14-15` DS scanner, invocation; helpers `:34-35` DS scanner, invocation; helpers `:41` M WorktreeResolution U Stop, `:42` M WorktreeTargetResolution U Stop, `:46` M WorktreeItemResolution U Stop, `:48` M EpicScopeResolution U Stop, `:49` M EpicScopeReadiness U Stop; EpicScopeResolution `:40-42` M WorktreeResolution, WorktreeTargetResolution, WorktreeRunResolution (Stop); WorktreeRunResolution `:31-33` M WorktreeResolution, WorktreeTargetResolution, WorktreeItemResolution; WorktreeItemResolution `:31-32`; WorktreeTargetResolution `:27`. Runtime: `OrchestratorState.psm1:431` M OrchestratorStateUnconditional (no Stop, inside the `$Invoker` default reached via `Invoke-OrchestratorStatePreflight`, helpers `:364`) and its closure (`OrchestratorStateUnconditional.psm1:51-55`, runtime `:93`) |
| enforce-orchestration-preimplementation-gate | `:9` M HookPayload U; `:14` DS -helpers U; `:20` DS -modes U; `:25` DS -epic-scope U; `:28` DS scanner U; `:29` DS invocation U | -epic-scope `:46` M WorktreeItemResolution / WorktreeRunResolution / EpicScopeResolution **G** (loop); `:52` M EpicScopeReadiness U Stop |
| enforce-epic-merge-gate | `:61` M HookPayload U; `:64-65` DS scanner, invocation U; `:67` DS -authorization U; `:69` DS -resolution U | -resolution `:32` M WorktreeRunResolution **G** |
| enforce-epic-worktree-removal-gate | `:68` M HookPayload U; `:71` M CleanupWorktreeManifest U; `:74-75` DS scanner, invocation U; `:77` DS -resolution U | -resolution `:29` M WorktreeRunResolution **G** |
| enforce-parallel-worktree-removal-gate | `:37` M HookPayload U; `:40` M CleanupWorktreeManifest U; `:45-46` DS scanner, invocation U; `:51` M WorktreeRunResolution **G** | WorktreeRunResolution closure |
| enforce-parallel-abandon-gate | `:37` M HookPayload U; `:51-52` DS scanner, invocation U | |
| check-python-test-purity | `:33` M HookPayload U | |
| enforce-python-batch-budget | `:62` M HookPayload U; `:63` DS enforce-batch-budget-route U | |
| check-powershell-test-purity | `:36` M HookPayload U | |
| enforce-powershell-batch-budget | `:62` M HookPayload U; `:63` DS enforce-batch-budget-route U | |
| enforce-evidence-locations | `:45` M HookPayload U | |
| enforce-feature-folder-order | `:29` M HookPayload U | |
| enforce-checkpoint-monotonic | `:47` M HookPayload U | |
| enforce-completion-consistency | `:49` M HookPayload U; `:53` DS `$script:CompletionHelpersPath` (enforce-completion-helpers.ps1) U | |
| enforce-discovery-artifact-gate | `:37` M HookPayload U; Runtime `:72` M DiscoveryValidation U Stop (preceded by a `Test-Path` that returns ExitCode 1, a deny, for a missing file, `:68-70`) | |
| enforce-mermaid-validation | `:62` M HookPayload U; Runtime `:83` M MermaidValidation **G**, but the catch returns `$false` and the caller returns `$null` (allow) by design (`:73-74`, `:327`) | MermaidValidation `:46-48`; MermaidLineScanner `:39` |
| enforce-prd-feature-before-planner | `:103` M HookPayload U; `:111` M WorktreeTargetResolution U; `:112` M WorktreeItemResolution U; `:113` DS -helpers U | helpers `:27` M WorktreeResolution U |
| enforce-epic-wave-barrier | `:41` M HookPayload U; `:46` M WorktreeRunResolution **G** | |
| enforce-model-routing-receipt | `:50` M HookPayload U; `:53` M WorktreeItemResolution U Stop; `:55` M EpicScopeResolution U Stop | EpicScopeResolution closure (includes WorktreeRunResolution) |
| enforce-epic-invocation-origin | `:47` M HookPayload U | |
| enforce-parallel-cohort-barrier | `:55` M HookPayload U; `:60` M WorktreeRunResolution **G**; `:71` DS -helpers U | |
| enforce-parallel-drift-gate | `:70` M HookPayload U; `:75` M WorktreeRunResolution **G**; `:84` DS `$script:ParallelDriftGateHelpersPath` U | |

### Claude SubagentStop (6 scripts plus the inline command)

| Hook | Edges |
|---|---|
| validate-orchestrator-output | `:41` M OrchestratorState U (with `$ErrorActionPreference = 'Stop'` at `:39`); Runtime `:259` M OrchestratorStateCompletion U, whose closure is `OrchestratorStateCompletion.psm1:56-63` (OrchestratorState, ModelRouting, CheckpointValue, ModelReceipts, Unconditional, CompletionChecks, RoutingContract) and their own imports |
| validate-discovery-artifact-gate | Runtime `:73` M DiscoveryValidation U Stop (after a `Test-Path` at `:69-71`) |
| validate-feature-review-coverage, validate-planner-output, validate-prd-feature-output, validate-pr-author-output | none (Grep for `Import-Module` and dot-source returned no match) |
| inline command (`settings.json:216`) | none |

### Codex PreToolUse (17 scripts) and SubagentStop (2 scripts)

Grep for `Import-Module` in `.codex/hooks` returned no match: the Codex surface imports no module; every
dependency is a sibling dot-source, all at file top level and outside the entry `try`.

| Hook | Edges |
|---|---|
| validate-bash | `:21-22` DS scanner, invocation (invocation `:17` DS scanner) |
| enforce-promotion-mcp-only | `:35-36` DS scanner, invocation |
| enforce-orchestration-preimplementation-gate | `:11` DS codex-pretooluse-file-mapping; `:16` DS -helpers; `:22` DS -modes; `:25` DS -epic-scope (which `:34` DS -epic-resolution); `:27-28` DS scanner, invocation |
| enforce-epic-merge-gate, enforce-epic-worktree-removal-gate | `:11-12` DS scanner, invocation |
| enforce-epic-root-invocation | `:12` DS codex-authority-store |
| enforce-codex-model-routing | `:8` DS codex-authority-store; `:9` DS codex-agent-profile-attestation |
| enforce-epic-planning-only | none |
| enforce-epic-wave-barrier | `:14` DS codex-epic-child-launch-attestation, which conditionally (`if (Test-Path ...)`, `:3-6`) DS `.codex/scripts/epic-child-launch-contract.ps1` |
| enforce-epic-child-worktree-binding | conditional DS `.codex/scripts/epic-child-launch-contract.ps1` (`:14-17`) |
| check-python-test-purity / check-powershell-test-purity / enforce-evidence-locations / enforce-checkpoint-monotonic | DS codex-pretooluse-file-mapping (`:35` / `:38` / `:46` / `:49`) |
| enforce-python-batch-budget / enforce-powershell-batch-budget | `:51` DS file-mapping; `:54` DS enforce-batch-budget-route |
| enforce-completion-consistency | `:46` DS enforce-checkpoint-monotonic.ps1 (an entry script reused as a helper; it returns early when dot-sourced, `:312-314`); `:52` DS file-mapping; `:57` DS `$script:CompletionHelpersPath` |
| validate-codex-subagent-routing (SubagentStop) | `:12` DS codex-authority-store |
| validate-feature-review-coverage (SubagentStop) | none |

The conditional dot-source of `epic-child-launch-contract.ps1` silently skips a missing file. Whether that
is a fail-open depends on whether the functions it provides are required on the deny path; see D3.

### Upstream changes that will alter this set

- #787 (C6) branch `origin/bug/validate-orchestrator-output-session-relative-read-787` exists in the local ref
  store (`.git/refs/remotes/origin/bug/validate-orchestrator-output-session-relative-read-787` =
  `0a3299a3`). Its content was not read (no shell). Per the epic (`epic.md:116-120`, `:157-160`) it adds a
  `WorktreeRunResolution.psm1` import to `validate-orchestrator-output.ps1` and a new PowerShell Layer 2
  module. Read it with:
  `git diff origin/epic/enforcement-hook-precision-integration...origin/bug/validate-orchestrator-output-session-relative-read-787 -- .claude/hooks .claude/lib .codex/hooks | Select-String -Pattern '^\+.*(Import-Module|^\+\s*\.\s)'`
- #732 (C1b): the orchestrator states it is not pushed. Observation: the local ref store contains
  `.git/refs/remotes/origin/bug/exempt-operand-bypass-brace-and-dot-segments-732` = `86d01cca`. Whether that
  ref is current or stale is unknown from this session. Per the epic it changes EpicScopeResolution on both
  surfaces and the preimplementation gate family.
- #850 (C3): not pushed (no matching remote-tracking ref found by Glob). Per the epic it adds worktree
  resolution to `enforce-pr-author-skill.ps1` and the standalone-merge branch of
  `enforce-epic-merge-gate.ps1`, and edits `WorktreeRunResolution.psm1`.

### Mechanical enumeration command (AST based)

Run from the repository root on the integration branch after #732, #850, and #787 merge. It parses
registrations from `.claude/settings.json` and `.codex/config.toml`, walks every `Import-Module` and
dot-source `CommandAst` breadth-first through the transitive closure, statically resolves
`Join-Path`/`Split-Path`/`$PSScriptRoot`/assigned-variable/`foreach`-expanded paths, and reports for each
edge whether it sits in a `try` body (Guarded), whether a shallower guard covers it (Covered), and whether
it is a runtime (function or scriptblock) import. Save it under the session scratchpad (not the
repository) and run `pwsh -NoProfile -File <scratchpad>/enumerate-hook-dependencies.ps1`; for the bundled
mirrors add
`-ClaudeRoot extensions/drm-copilot/resources/claude-customizations -CodexRoot extensions/drm-copilot/resources/codex-and-agents-customizations`.
It was not executed in this session.

```powershell
[CmdletBinding()]
param([string] $ClaudeRoot = (Get-Location).Path, [string] $CodexRoot = (Get-Location).Path)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ClaudeRoot = (Resolve-Path -LiteralPath $ClaudeRoot).Path
$CodexRoot = (Resolve-Path -LiteralPath $CodexRoot).Path

function Get-RegisteredHook {
    $settings = Get-Content -LiteralPath (Join-Path $ClaudeRoot '.claude/settings.json') -Raw | ConvertFrom-Json
    foreach ($hookEvent in 'PreToolUse', 'SubagentStop') {
        foreach ($group in @($settings.hooks.$hookEvent)) {
            foreach ($hook in @($group.hooks)) {
                $found = [regex]::Matches([string]$hook.command, '\.claude/hooks/[\w.-]+\.ps1')
                if ($found.Count -eq 0) { [pscustomobject]@{ Surface = 'claude'; Root = $ClaudeRoot; Event = $hookEvent; Path = 'INLINE' } }
                foreach ($m in $found) { [pscustomobject]@{ Surface = 'claude'; Root = $ClaudeRoot; Event = $hookEvent; Path = [IO.Path]::GetFullPath((Join-Path $ClaudeRoot $m.Value)) } }
            }
        }
    }
    $hookEvent = ''
    foreach ($line in Get-Content -LiteralPath (Join-Path $CodexRoot '.codex/config.toml')) {
        if ($line -match '^\[\[hooks\.(\w+)') { $hookEvent = $Matches[1]; continue }
        if ($line -match '^command\s*=' -and $hookEvent -in 'PreToolUse', 'SubagentStop') {
            foreach ($m in [regex]::Matches($line, '\.codex/hooks/[\w.-]+\.ps1')) { [pscustomobject]@{ Surface = 'codex'; Root = $CodexRoot; Event = $hookEvent; Path = [IO.Path]::GetFullPath((Join-Path $CodexRoot $m.Value)) } }
        }
    }
}

function Resolve-StaticPath {
    param($Node, [string] $Dir, [hashtable] $Vars)
    if ($Node -is [System.Management.Automation.Language.ParenExpressionAst]) { $Node = $Node.Pipeline }
    if ($Node -is [System.Management.Automation.Language.PipelineAst] -and $Node.PipelineElements.Count -eq 1) { $Node = $Node.PipelineElements[0] }
    if ($Node -is [System.Management.Automation.Language.CommandExpressionAst]) { $Node = $Node.Expression }
    if ($Node -is [System.Management.Automation.Language.StringConstantExpressionAst]) { return $Node.Value }
    if ($Node -is [System.Management.Automation.Language.VariableExpressionAst]) {
        $name = $Node.VariablePath.UserPath -replace '^script:', ''
        if ($name -eq 'PSScriptRoot') { return $Dir }
        if ($Vars.ContainsKey($name)) { return $Vars[$name] }
        return
    }
    if ($Node -is [System.Management.Automation.Language.ExpandableStringExpressionAst]) {
        $loop = $Node.Parent
        while ($null -ne $loop -and $loop -isnot [System.Management.Automation.Language.ForEachStatementAst]) { $loop = $loop.Parent }
        if ($null -eq $loop) { return }
        $token = '$' + $loop.Variable.VariablePath.UserPath
        foreach ($item in $loop.Condition.FindAll({ param($n) $n -is [System.Management.Automation.Language.StringConstantExpressionAst] }, $true)) { $Node.Value.Replace($token, $item.Value) }
        return
    }
    if ($Node -is [System.Management.Automation.Language.CommandAst]) {
        $operands = @($Node.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] })
        $commandName = $Node.GetCommandName()
        if ($commandName -eq 'Join-Path' -and $operands.Count -ge 2) {
            foreach ($left in @(Resolve-StaticPath $operands[0] $Dir $Vars)) {
                foreach ($right in @(Resolve-StaticPath $operands[1] $Dir $Vars)) {
                    $combined = [IO.Path]::Combine($left, $right)
                    if ([IO.Path]::IsPathRooted($combined)) { [IO.Path]::GetFullPath($combined) } else { $combined }
                }
            }
        }
        elseif ($commandName -eq 'Split-Path' -and $operands.Count -ge 1) {
            foreach ($p in @(Resolve-StaticPath $operands[0] $Dir $Vars)) { Split-Path -Path $p -Parent }
        }
    }
}

function Get-StaticVariable {
    param($Ast, [string] $Dir)
    $vars = @{}
    $assignments = $Ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and $n.Left -is [System.Management.Automation.Language.VariableExpressionAst] }, $true)
    foreach ($a in $assignments) {
        $values = @(Resolve-StaticPath $a.Right $Dir $vars)
        if ($values.Count -eq 1) { $vars[($a.Left.VariablePath.UserPath -replace '^script:', '')] = [string]$values[0] }
    }
    return $vars
}

function Get-DependencyEdge {
    param([string] $File)
    $tokens = $null; $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$tokens, [ref]$parseErrors)
    $dir = Split-Path -Path $File -Parent
    $vars = Get-StaticVariable -Ast $ast -Dir $dir
    foreach ($cmd in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true)) {
        if ($cmd.InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Dot) { $kind = 'DotSource'; $targetNode = $cmd.CommandElements[0] }
        elseif ($cmd.GetCommandName() -eq 'Import-Module') {
            $kind = 'Module'
            $targetNode = @($cmd.CommandElements | Select-Object -Skip 1 | Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] }) | Select-Object -First 1
        }
        else { continue }
        $guarded = $false; $runtime = $false; $conditional = $false
        $child = $cmd; $parent = $cmd.Parent
        while ($null -ne $parent) {
            if ($parent -is [System.Management.Automation.Language.TryStatementAst] -and [object]::ReferenceEquals($parent.Body, $child)) { $guarded = $true }
            if ($parent -is [System.Management.Automation.Language.FunctionDefinitionAst] -or $parent -is [System.Management.Automation.Language.ScriptBlockExpressionAst]) { $runtime = $true }
            if ($parent -is [System.Management.Automation.Language.IfStatementAst]) { $conditional = $true }
            $child = $parent; $parent = $parent.Parent
        }
        $targets = @(if ($null -ne $targetNode) { Resolve-StaticPath $targetNode $dir $vars })
        if ($targets.Count -eq 0) { $targets = @('UNRESOLVED: ' + $cmd.Extent.Text) }
        foreach ($t in $targets) {
            [pscustomobject]@{ File = $File; Line = $cmd.Extent.StartLineNumber; Kind = $kind; Target = $t; Guarded = $guarded; Runtime = $runtime; Conditional = $conditional; ErrorActionStop = ($cmd.Extent.Text -match '-ErrorAction\s+Stop') }
        }
    }
}

$rows = [System.Collections.Generic.List[object]]::new()
foreach ($hook in @(Get-RegisteredHook | Sort-Object Surface, Event, Path -Unique)) {
    if ($hook.Path -eq 'INLINE') { $rows.Add([pscustomobject]@{ Surface = $hook.Surface; Event = $hook.Event; Hook = 'INLINE'; Via = ''; Line = 0; Kind = ''; Target = '(no imports)'; Guarded = ''; Covered = ''; Runtime = ''; Conditional = ''; ErrorActionStop = '' }); continue }
    $relative = { param($p) if ($p -like 'UNRESOLVED*') { $p } else { [IO.Path]::GetRelativePath($hook.Root, $p) -replace '\\', '/' } }
    $queue = [System.Collections.Generic.Queue[object]]::new()
    $queue.Enqueue(@($hook.Path, $false))
    $seen = @{}
    while ($queue.Count -gt 0) {
        $file, $inherited = $queue.Dequeue()
        if ($seen.ContainsKey("$file|$inherited")) { continue }
        $seen["$file|$inherited"] = $true
        foreach ($edge in @(Get-DependencyEdge -File $file)) {
            $covered = [bool]$inherited -or $edge.Guarded
            $rows.Add([pscustomobject]@{ Surface = $hook.Surface; Event = $hook.Event; Hook = (& $relative $hook.Path); Via = (& $relative $file); Line = $edge.Line; Kind = $edge.Kind; Target = (& $relative $edge.Target); Guarded = $edge.Guarded; Covered = $covered; Runtime = $edge.Runtime; Conditional = $edge.Conditional; ErrorActionStop = $edge.ErrorActionStop })
            if ($edge.Target -notlike 'UNRESOLVED*' -and (Test-Path -LiteralPath $edge.Target -PathType Leaf)) { $queue.Enqueue(@($edge.Target, $covered)) }
        }
    }
}
$rows | Sort-Object Surface, Event, Hook, Via, Line | Format-Table -AutoSize | Out-String -Width 500
```

Reconciliation rule for the executor: every row in the Q3 tables above must appear in the command's
output (with the line numbers of the integration branch), any additional row must be explained by an
upstream child's diff, and any `UNRESOLVED` row must be resolved by reading the file before the guard list
is fixed. The same discovery logic should be promoted into the test-support helper proposed in Q6 so the
#792 guard and a #786 structural completeness test consume one implementation.

## Q4. Ordering hazard and shared-helper design

### What a deny needs

- PreToolUse deny: an ordered hashtable and `ConvertTo-Json` (built-ins). No HookPayload function is
  needed. The per-hook constructors are themselves built-in-only (for example
  `enforce-pr-author-skill.ps1:230-236`).
- SubagentStop block: either `{"decision":"block","reason":...}` on stdout at exit 0, or
  `[Console]::Error.WriteLine(...)` plus `exit 2`. Both are built-in-only and both block on both surfaces.
- The hazard is call order, not the constructor: entry points call `Read-ClaudeHookRawPayload`
  (HookPayload) before the decision function (`enforce-epic-wave-barrier.ps1:363-370`,
  `enforce-model-routing-receipt.ps1:291`), and decision functions call `Resolve-ClaudeHookToolInput`
  before anything else. Under `$ErrorActionPreference = 'Stop'` (the SubagentStop validators) a missing
  HookPayload function would be script-terminating before any guard check could run.
- Hook-specific hazard confirmed: the merge gate's #690 guard depends on a function from an unguarded
  sibling (Q2).

### Recommended design (single shared helper)

New file, byte-identical in three places: `.claude/hooks/hook-dependency-guard.ps1`,
`.codex/hooks/hook-dependency-guard.ps1`, and the two bundle mirrors. A sibling `.ps1` (not a `.psm1`)
because: Codex hooks never load `.claude/lib` (Q3), so a lib module is not available on that surface;
the sibling-script pattern already ships byte-identically on both surfaces (`hook-command-scanner.ps1`,
483 lines each); and loading it needs no `Import-Module`. The file has no imports and uses built-ins only.
Proposed API (approved verbs; names are recommendations):

- `Add-HookDependencyFailure -Name <string> [-ErrorRecord <ErrorRecord>]`: appends to
  `$script:HookDependencyFailures` (a list in the hook's script scope, initialized by the helper only if
  absent, so a hook that dot-sources another hook entry, as Codex `enforce-completion-consistency.ps1:46`
  does, does not wipe earlier records).
- `Test-HookDependencyFailure`: `[bool]`.
- `Get-HookDependencyFailureReason -ReasonPrefix <string>`: `"<prefix> the dependency '<name>' failed to load (<first exception line>); the gate fails closed."`. The prefix is the
  hook's existing leading token (`PR_AUTHOR_SKILL_BLOCKED:`, `PREIMPLEMENTATION_GATE_BLOCKED:`, and so on).
  Hooks whose denies have no token use their existing prose prefix (for example
  `check-python-test-purity.ps1:73` "Python unit test purity hook ..."; `validate-bash.ps1` has none and
  needs a decision, D4).
- `Get-HookDependencyFailureDecision -HookEvent PreToolUse|SubagentStop -ReasonPrefix <string>`: returns
  the ordered deny (`hookSpecificOutput` shape) for PreToolUse or the ordered `decision = 'block'` object
  for SubagentStop, or `$null` when nothing failed. No hook-defined function is called.

Hook-side pattern (all statements stay at hook script scope, so dot-sourced definitions land in the
hook's scope and the existing no-Python carve-out (b) still recognizes the literal
`. (Join-Path $PSScriptRoot '<sibling>.ps1')` shape, `EnforcementHooksNoPythonInvocation.Helpers.ps1:275-326`):

```powershell
try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-scanner.ps1' -ErrorRecord $_ }
```

- Every module import gains `-ErrorAction Stop`, otherwise a missing file is non-terminating and the
  `catch` never runs.
- The decision function's first statement returns `Get-HookDependencyFailureDecision ...` when non-null
  (matches the #690 placement and keeps the existing in-process tests' style).
- The entry point checks `Test-HookDependencyFailure` before acquiring the payload, so no HookPayload
  function is called when HookPayload failed.
- Bootstrap (the helper itself failing to load): the hook tail, after the
  `$MyInvocation.InvocationName -eq '.'` early return, runs
  `if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('<TOKEN>: hook-dependency-guard.ps1 failed to load; the gate fails closed.'); exit 2 }`.
  Exit 2 blocks on both surfaces for both events (Q1 table) and needs no function. If the helper failed,
  the later `catch` blocks call an undefined `Add-HookDependencyFailure`; that is a statement-terminating
  error inside a `catch` and does not change the outcome, because the tail exits 2 first. Because the tail
  is after the dot-source early return, tests that dot-source a hook never reach `exit`.
- Runtime (lazy) imports: pre-load them eagerly under the guard at hook load so the existing
  `if (-not (Get-Command ...))` lazy branches are skipped (`OrchestratorState.psm1:430-432`,
  `validate-orchestrator-output.ps1:258-260`, `OrchestratorStateUnconditional.psm1:92-93`). This keeps
  `OrchestratorState.psm1` (492 lines) unedited. Whether a hook-level import satisfies a `Get-Command`
  issued inside module scope must be confirmed by the first test (inferred from PowerShell's documented
  default of importing script-file-level modules into the global session state). The discovery-gate
  runtime imports (`enforce-discovery-artifact-gate.ps1:72`, `validate-discovery-artifact-gate.ps1:73`) can
  use the same eager pre-load.
- Migrate the seven #690 copies to the helper (removes the ordering hazard in Q2 and seven duplicate
  blocks). Keep their reason wording shape ("the worktree-resolution module '<name>' failed to import") so
  existing assertions that match the module name and `deny` still hold; existing W7-style tests that reset
  `$script:<Hook>ResolutionImportFailure` must be updated to reset `$script:HookDependencyFailures`.
- Constraint from the issue honored: each `try` contains only the import or dot-source statement, so a
  parse error elsewhere in the hook is not swallowed.

### 500-line cap (current counts; Grep line count per file)

Files expected to change and their current length. Each guarded hook is estimated at +4 to +8 lines
(bootstrap line, decision check, entry check, tail check; the import lines themselves are replaced
one-for-one).

- At risk (>= 480 now): Claude `enforce-python-batch-budget.ps1` 489, `enforce-powershell-batch-budget.ps1`
  486; Codex `enforce-orchestration-preimplementation-gate.ps1` 487.
- Watch (466-479): Claude `enforce-prd-feature-before-planner.ps1` 477,
  `enforce-parallel-worktree-removal-gate.ps1` 474 (offset by removing its #690 copy),
  `enforce-orchestration-preimplementation-gate.ps1` 466, `enforce-epic-merge-gate.ps1` 459,
  `enforce-epic-worktree-removal-gate.ps1` 457, `validate-feature-review-coverage.ps1` 459.
- Files that are dependency targets but need no change under this design, and must stay unchanged because
  they are at the cap: `HookPayload.psm1` 496, `WorktreeRunResolution.psm1` 497, `WorktreeResolution.psm1`
  500, Claude and Codex `enforce-orchestration-preimplementation-gate-helpers.ps1` 497, Codex
  `-epic-resolution.ps1` 493, `hook-command-scanner.ps1` / `hook-command-invocation.ps1` 483 (both surfaces).
- Upstream children edit several of these files (#732: preimplementation family; #850: pr-author and merge
  gates and `WorktreeRunResolution.psm1`; #787: `validate-orchestrator-output.ps1`). Re-measure on the
  integration branch before planning line budgets.

## Q5. Test seam for import failure

Existing precedent (in-process, no file changes): `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1:160-181`
mocks the cmdlet before dot-sourcing the hook:

```powershell
Mock Import-Module { }
Mock Import-Module { throw 'simulated import failure (issue #690)' } -ParameterFilter { $Name -like '*WorktreeRunResolution.psm1' }
. (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-epic-wave-barrier.ps1").Path
```

and asserts the decision denies naming the module and the entry point returns 0 with deny JSON. The same
reset-in-`finally` pattern appears in the other six #690 suites (Grep: seven `ImportFailure = $null`
resets under `tests/scripts/claude-hooks/`).

Recommended seams:

- Module imports: the same `Mock Import-Module ... -ParameterFilter { $Name -like '*<module>' }`.
- Dot-sources: Pester cannot mock the `.` operator, but the target expression is a literal
  `Join-Path` call, so `Mock Join-Path { throw 'simulated' } -ParameterFilter { $ChildPath -eq '<sibling>.ps1' }`
  registered before dot-sourcing the hook makes that dot-source's `try` fail. Dot-source the guard helper
  in the test before registering mocks so `Add-HookDependencyFailure` resolves.
- Nested failures: a failure inside a dot-sourced helper's own import (for example
  `enforce-pr-author-skill-helpers.ps1:48`) is simulated by the module-import mock and must surface as a
  failure of the top-level edge (`enforce-pr-author-skill-helpers.ps1`), which proves transitive coverage.
- Bootstrap: `Mock Join-Path { throw } -ParameterFilter { $ChildPath -eq 'hook-dependency-guard.ps1' }`
  sets `$script:HookDependencyGuardLoadFailed`. The tail `exit 2` line is not reachable in-process; a
  structural (AST) test should assert every registered hook carries the bootstrap and the tail check. The
  `exit 2` statement is one uncovered command per hook; record it in the coverage comparison.
- A mock seam provides no override in production: Pester mocks exist only in the test runspace, so the seam
  cannot be used to disable a gate.

Rejected seams:

- An environment variable that forces a named dependency to fail. It would be safe in direction (a forced
  failure denies), but it adds a production code path that exists only for tests and gives any process
  that sets the variable a way to deny every call.
- A hook parameter that injects a dependency root or path. Hooks run as `pwsh -File` with `param()`; a
  root parameter would let a caller redirect the hook to a different module, which could load permissive
  code. Unsafe.
- Renaming, moving, or creating files: prohibited by the issue and by `.claude/rules/general-unit-test.md`.

On the "$Invoker seam in enforce-pr-author-skill.ps1" named in the delegation: Grep found no `$Invoker` in
that hook. The seam lives in the module it imports, `OrchestratorState.psm1:423-464`
(`Invoke-OrchestratorStatePreflight -Invoker`), with a parallel one in `validate-orchestrator-output.ps1:251-288`.
Both are `[scriptblock]` defaults, carve-out (a) of the no-Python guard.

## Q6. #792 guard design

### Scope

- In scope: every `.psm1` in the transitive import closure of every registered PreToolUse and SubagentStop
  hook on both surfaces (from the Q3 discovery), plus every dot-sourced sibling `.ps1` in that closure that
  is not itself a registered hook entry script. Rationale for including dot-sourced helpers: they execute in
  the hook's own scope, so top-level output from them reaches stdout exactly as module output does, and
  the current tree has zero offenders among them, so including them costs nothing now and closes a
  recurrence path.
- Out of scope: registered hook entry scripts, including when another hook dot-sources one (Codex
  `enforce-completion-consistency.ps1:46` dot-sources `enforce-checkpoint-monotonic.ps1`, whose
  `Write-Output` at `:331` sits after its dot-source early return at `:312-314` and never runs when
  dot-sourced).
- Mirrors: run the same discovery with the mirror roots (Q3 command parameters). The mirrors are
  byte-identical by test, so their findings must equal the repository findings.

### Detection (AST, text in, findings out)

- `CommandAst` whose `GetCommandName()` is, case-insensitively, `Write-Output`, `write`, `echo`,
  `Write-Host`, `Write-Information`, `Write-Warning`, or `Out-Host`.
- `InvokeMemberExpressionAst` on `[Console]` or `[System.Console]` whose member is `Write` or `WriteLine`,
  and on `[Console]::Out` / `[System.Console]::Out` with any `Write*` member. `[Console]::Error.*` is
  allowed and is the sanctioned diagnostic route (issue AC).
- Not flagged: `Write-Error`, `Write-Verbose`, `Write-Debug` (silent by default; one existing use at
  `EpicScopeResolution.psm1:171`), strings and comments (the AST excludes them).
- Residual gap, recorded: implicit output (an uncaptured expression value at module top level) also
  reaches stdout and is not detectable by command-name matching.

### Proof the guard can fail

Follow the no-Python guard precedent (`EnforcementHooksNoPythonInvocation.Helpers.ps1:328-424`): the
detector takes `-ScriptText` and `-SourceLabel`, and fixtures are here-strings in the test, so no file is
written. Required fixtures: one per flagged form (including `echo`, `write`, and `[Console]::Out.WriteLine`),
negatives for `[Console]::Error.WriteLine`, a comment, a string literal, and `Write-Verbose`. The discovery
helper should accept an injectable text reader (`[scriptblock] $ReadText`) so a test can feed a synthetic
`settings.json`, `config.toml`, hook, and module and assert that an offender in a transitively imported
module is reported and an offender in an entry script is not.

### Current-tree result

- Grep over `.claude/lib` for `Write-(Output|Host|Information|Warning)`, `echo`, `[Console]::Out`, and
  `[System.Console]::Out` returned two code hits: `project-file-merge/Resolve-MergeableConflict.ps1:227`
  and `parallel-drift/Invoke-ParallelDriftDetection.ps1:333`. Both are CLI scripts; neither is referenced
  by any file in `.claude/hooks` (Grep for both names in `.claude/hooks` returned no match), so neither is
  in a hook's closure. All other hits were comments.
- Grep for `Write-\w+` in `.claude/lib/**/*.psm1` returned only `Write-Debug` (`EpicScopeResolution.psm1:171`)
  and three comment occurrences of "Write-intent".
- In `.claude/hooks` and `.codex/hooks`, every `Write-Output` and `[Console]::Out.WriteLine` hit is in a
  registered entry script (listed by the Grep in this session); no non-entry helper has one.
- Result: zero offenders on this branch, consistent with the issue's statement for main at ae7c7779. This
  is a Grep result; the AST guard must reproduce it.

### Placement

New test file and helper, not an edit of `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`
(500 lines) or its helper (500 lines), which are at the cap and which #737 will edit. Proposed:
`tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` and
`tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` (test support; not mirrored, not in a pack
manifest, not a coverage target, matching the no-Python helper's stated scope at its `:59`).

## Q7. Codex surface, bundle mirrors, parity tests

- Claude-to-Codex correspondences that exist on both surfaces: validate-bash, enforce-promotion-mcp-only,
  enforce-orchestration-preimplementation-gate (plus -helpers, -modes, -epic-scope; Codex also has
  -epic-resolution), enforce-epic-merge-gate, enforce-epic-worktree-removal-gate, enforce-epic-wave-barrier,
  check-python-test-purity, check-powershell-test-purity, enforce-python-batch-budget,
  enforce-powershell-batch-budget, enforce-batch-budget-route, enforce-evidence-locations,
  enforce-checkpoint-monotonic, enforce-completion-consistency, enforce-completion-helpers,
  hook-command-scanner, hook-command-invocation, validate-feature-review-coverage. Codex-only hooks:
  enforce-epic-root-invocation, enforce-codex-model-routing, enforce-epic-planning-only,
  enforce-epic-child-worktree-binding, validate-codex-subagent-routing, and helpers codex-authority-store,
  codex-agent-profile-attestation, codex-epic-child-launch-attestation, codex-pretooluse-file-mapping. The
  Codex copies are separate implementations, not byte copies of the Claude files (for example the Codex
  merge gate is 379 lines and imports nothing).
- Mirror roots (verified by Glob):
  - `.claude/hooks` -> `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`
  - `.claude/lib` -> `extensions/drm-copilot/resources/claude-customizations/.claude/lib/`
  - `.codex/hooks` -> `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`
  - `.codex/scripts` -> `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/scripts/`
- Parity tests (pytest):
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`:89-110`): every distributable `.claude` file exists in the bundle with identical text.
  - `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (`:215-228`): the same for `.codex` and `.agents`.
  - Pack manifests must list a new helper: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (lists `.claude/hooks/hook-command-scanner.ps1` at `:56`) and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (`:46`); completeness is tested by `test_push_down_claude_pack_manifest_completeness.py` and `test_push_down_codex_and_agents_pack_manifest_completeness.py`.
  - Pester: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` holds a fixed `$script:SharedModuleNames` list (`:30`) checked for parse, 500-line cap, root/bundle byte identity, and core-manifest membership (`:138-139`); a new Codex helper must be added there.
  - Run: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`.
- Sync script: none found. Grep for the two bundle root names under `scripts/` and in
  `extensions/drm-copilot` package scripts found only push-down tooling that copies from the bundle to a
  destination repository (`scripts/dev_tools/push_down_claude_customizations.py`,
  `push_down_codex_and_agents_customizations.py`). Mirrors are updated by copying the changed file
  byte-for-byte.

## Q8. Structural guard tests and overlap with #737

- No-Python guard: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` with
  `EnforcementHooksNoPythonInvocation.Helpers.ps1`. Discovery is directory-based: `Get-ChildItem -Recurse`
  over exactly `.claude/hooks` and `.claude/lib` (`Tests.ps1:39-42`, `:50-76`); `.codex/hooks` is not
  scanned and the mirror is deliberately excluded (`:34-38`).
- Epic-state isolation guard (#709): `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`
  and `EpicStateIsolation.Helpers.ps1`; per `docs/features/potential/promoted/2026-09-27-hook-test-isolation-remaining-gaps.md:27`
  it checks a hard-coded list of seven suites.
- Codex static contract list: `legacy-codex-hook-contracts.Tests.ps1:10-31` (fixed names).
- #737 scope (`epic.md:126-130` and the promoted record above): make the suites hermetic, make structural
  guards discover their targets, extend the no-Python guard to `.codex/hooks`, add the preimplementation
  Claude/Codex parity test and the `GENERATED_AGENT_FAMILIES` parity test.
- Merge-overlap risk with #737 (both children in wave 3):
  - High: the no-Python guard pair (both at 500 lines). C4 must not edit them; the dot-source shape in Q4
    is chosen so carve-out (b) needs no change.
  - High: `legacy-codex-hook-contracts.Tests.ps1` (C4 adds a helper name to `:30`; #737 may convert the list
    to discovery).
  - Medium: every gate suite under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/` that C4
    extends with import-failure cases and that #737 makes hermetic (for example the seven
    `*.WorktreeResolution.Tests.ps1` files that C4 must update for the migrated #690 variable).
  - Medium: a discovery helper. If #737 introduces its own target discovery, the two children may each add
    one. Recommend C4 own `HookDependencyGraph.Helpers.ps1` and #737 reuse it after merge, or the reverse,
    decided at epic level (D5).
  - Low: `.claude/hooks/enforce-orchestration-preimplementation-gate*.ps1` (C4 import prologue; #737 adds a
    parity test that reads them).

## Q9. Toolchain

- PowerShell toolchain per `.claude/rules/powershell.md:13-20`: format (`mcp__drm-copilot__run_poshqc_format`),
  analyze (`mcp__drm-copilot__run_poshqc_analyze`), test (`mcp__drm-copilot__run_poshqc_test`), with Pester
  settings `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (JUnit to
  `artifacts/pester/pester-junit.xml`, `:12-16`; CoverageGutters coverage to
  `artifacts/pester/powershell-coverage.xml`, `:17-27`; `CoveragePercentTarget = 0`, so the 85% floor must
  be compared explicitly).
- Coverage denominator: `config/poshqc-coverage.json` roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`,
  `.codex/scripts`, `scripts` (`:3-9`). The new helper in both hook directories is automatically in the
  denominator. Test scan folders: `config/poshqc-scan.json` (`scripts`, `tests/powershell`, `tests/scripts`).
- Known MCP limitations (repository memory, re-verified only to the extent of the settings paths above):
  the MCP test runner reads the installed extension's runsettings, and the MCP PoshQC tools return a
  pre-composed summary with no counts. Use the MCP calls as the policy route and take numbers from a direct
  invocation of the in-repo module:
  - Format: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -ScanFolders @('.claude/hooks','.codex/hooks','tests/scripts/claude-hooks','tests/scripts/codex-hooks','tests/scripts/claude-runtime')"`
  - Analyze: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path"`; for per-file findings, `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information`.
  - Test with coverage: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-hooks','tests/scripts/codex-hooks','tests/scripts/claude-runtime')"`, then read totals from the JUnit XML and per-file coverage from the coverage XML keyed by the enclosing `package` element (the same file names exist under `.claude/hooks` and `.codex/hooks`).
- Evidence goes to `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/<kind>/`.

## Behavior Semantics (for the spec)

- Success: every registered PreToolUse and SubagentStop hook on both surfaces, when any statically
  enumerated dependency fails to load, produces a blocking result naming that dependency: PreToolUse deny
  JSON at exit 0 with the hook's existing leading token; SubagentStop exit 2 with the reason on stderr
  (or block JSON, per D1); helper-bootstrap failure exit 2 with stderr on any event.
- No change when all dependencies load: byte-identical decisions for existing test payloads.
- Ordering: dependency failure is checked before the payload is read and before any function from a
  guarded dependency is called.
- Edge cases: failure inside a nested import or nested dot-source (reported as the top-level edge);
  runtime lazy imports (pre-loaded eagerly); a hook that dot-sources another hook entry (shared failure
  list, no reset); the mermaid gate's designed fail-open (D2); conditional Codex contract dot-source (D3).

## Recommended Approach

One shared, import-free, byte-identical sibling helper (`hook-dependency-guard.ps1`) on both surfaces and
in both mirrors; every import and dot-source wrapped individually in a script-scope `try` that records
through the helper; module imports gain `-ErrorAction Stop`; checks at the top of the decision function
and before payload acquisition; exit-2 bootstrap fallback in the hook tail; the seven #690 copies migrated;
runtime lazy imports pre-loaded eagerly; Pester `Import-Module`/`Join-Path` mocks as the only failure seam;
a new AST-based #792 guard plus a structural completeness test built on one discovery helper.

Rejected alternatives:

- Per-hook copies of the #690 block: duplicates the pattern about 45 times and keeps the ordering hazard.
- Shared helper as a `.psm1` under `.claude/lib`: not available to Codex hooks, and needs its own guarded
  `Import-Module`.
- A single `try/catch` around each hook's whole entry point that denies on any exception: catches too
  broadly and would mask defects in the hook itself, contrary to the issue's constraint.
- Extending `HookPayload.psm1` with an emitter: the module is at 496 lines and is itself one of the
  dependencies whose failure must be reported.

## Open Decisions for the Operator

- D1. Claude SubagentStop scripts block today with `exit 1`, which the documentation defines as
  non-blocking. Should C4 emit its dependency-failure block with exit 2 (recommended; correct on both
  surfaces) while leaving the existing exit-1 paths to the 2026-08-21 potential entry, or also correct those
  paths? Correcting them is outside #786's stated scope.
- D2. `enforce-mermaid-validation.ps1:73-88` fails open on a missing MermaidValidation module by design
  ("a consumer repository ... must not be bricked"). Keep (exempt from the guard, documented) or convert to
  deny?
- D3. The Codex conditional dot-source of `.codex/scripts/epic-child-launch-contract.ps1` skips silently when
  the file is absent. Keep, or treat absence as a dependency failure?
- D4. `validate-bash.ps1` deny reasons have no leading token. Choose a token for its dependency-failure
  deny.
- D5. Ownership of the hook-discovery test helper between C4 and #737.

## Testing Implications

- Per registered hook with at least one dependency (both surfaces): one in-process test per direct edge
  using the Q5 mocks, asserting deny/block, the hook's leading token, and the dependency name; one test that
  the entry point emits the deny without calling a HookPayload function.
- Helper unit tests: record, test, reason, decision for both events, no-reset on re-dot-source.
- Structural tests: (a) every registered hook carries the bootstrap and tail check; (b) every edge from
  the discovery is `Covered` and, if `Runtime`, pre-loaded; (c) #792 guard over the closure on repository
  and mirror roots, with text fixtures proving it fails.
- Regression-first: the import-failure tests are written first and must fail on the current code (expected
  failure modes: allow decision, no JSON, or exit 1), recorded as baseline evidence.
- Existing suites to update: the seven #690 `*.WorktreeResolution.Tests.ps1` files.
- Bundle parity and pack-manifest pytest suites and `legacy-codex-hook-contracts.Tests.ps1` must pass.
- Coverage: line coverage >= 85% for every changed PowerShell file (no branch gate for Pester); the
  bootstrap `exit 2` lines are a known small uncovered set to be recorded.

## Numeric Derivation Evidence

The counts below are informational context for planning; no numeric acceptance criterion is proposed by
this research. Any numeric criterion must be re-derived on the integration branch with the Q3 command.

### Claude registered PreToolUse scripts = 24

- Complete Family: distinct `.claude/hooks/*.ps1` paths in `hooks.PreToolUse[*].hooks[*].command` of `.claude/settings.json`.
- Exhaustive Search Scope: `.claude/settings.json` lines 89-208 (all three PreToolUse matcher groups).
- Inclusion Rules: script path appears in a PreToolUse command. Exclusion Rules: duplicates counted once; SessionStart and SubagentStop entries excluded.
- Primary Search Strategy: full Read of `.claude/settings.json` and manual listing per matcher group.
- Primary Member Set: validate-bash, enforce-promotion-mcp-only, enforce-pr-author-skill, enforce-orchestration-preimplementation-gate, enforce-epic-merge-gate, enforce-epic-worktree-removal-gate, enforce-parallel-worktree-removal-gate, enforce-parallel-abandon-gate, check-python-test-purity, enforce-python-batch-budget, check-powershell-test-purity, enforce-powershell-batch-budget, enforce-evidence-locations, enforce-feature-folder-order, enforce-checkpoint-monotonic, enforce-completion-consistency, enforce-discovery-artifact-gate, enforce-mermaid-validation, enforce-prd-feature-before-planner, enforce-epic-wave-barrier, enforce-model-routing-receipt, enforce-epic-invocation-origin, enforce-parallel-cohort-barrier, enforce-parallel-drift-gate.
- Primary Count: 24.
- Cross-check Search Strategy: Grep `-o` for `\.claude/hooks/[\w.-]+\.ps1` on `.claude/settings.json`, keeping lines 95-205 and deduplicating.
- Cross-check Member Set: 27 occurrences on lines 95-205; enforce-orchestration-preimplementation-gate occurs three times (107, 152, 185); after deduplication the same 24 names.
- Cross-check Count: 24.
- Member-set Comparison: identical sets.

### Claude registered SubagentStop scripts = 6 (plus one inline command)

- Complete Family: distinct `.claude/hooks/*.ps1` paths in `hooks.SubagentStop[*].hooks[*].command`.
- Exhaustive Search Scope: `.claude/settings.json` lines 210-286.
- Inclusion / Exclusion: script paths counted once; the inline `-Command` at line 216 counted separately.
- Primary Strategy and Member Set: full Read; validate-discovery-artifact-gate, validate-feature-review-coverage, validate-planner-output, validate-prd-feature-output, validate-pr-author-output, validate-orchestrator-output. Primary Count: 6.
- Cross-check Strategy and Member Set: the same Grep, lines 220-283: 8 occurrences, validate-orchestrator-output three times (265, 274, 283); deduplicated to the same 6. Cross-check Count: 6.
- Member-set Comparison: identical sets.

### Codex registered PreToolUse scripts = 17; SubagentStop scripts = 2

- Complete Family: distinct `.codex/hooks/*.ps1` paths in `command` keys under `[[hooks.PreToolUse]]` and `[[hooks.SubagentStop]]` tables of `.codex/config.toml`.
- Exhaustive Search Scope: `.codex/config.toml` lines 119-252.
- Inclusion / Exclusion: `command` and `command_windows` name the same script and count once; UserPromptSubmit and SubagentStart excluded; duplicates counted once.
- Primary Strategy and Member Set: full Read; PreToolUse: validate-bash, enforce-promotion-mcp-only, enforce-orchestration-preimplementation-gate, enforce-epic-merge-gate, enforce-epic-worktree-removal-gate, enforce-epic-root-invocation, enforce-codex-model-routing, enforce-epic-planning-only, enforce-epic-wave-barrier, enforce-epic-child-worktree-binding, check-python-test-purity, enforce-python-batch-budget, check-powershell-test-purity, enforce-powershell-batch-budget, enforce-evidence-locations, enforce-checkpoint-monotonic, enforce-completion-consistency; SubagentStop: validate-codex-subagent-routing, validate-feature-review-coverage. Primary Counts: 17 and 2.
- Cross-check Strategy and Member Set: Grep `-o` for `\.codex/hooks/[\w.-]+\.ps1`; PreToolUse lines 124-233 give 36 occurrences = 18 registrations (two keys each), with enforce-orchestration-preimplementation-gate at 136 and 220, deduplicated to 17; SubagentStop lines 241-251 give 4 occurrences = 2. Cross-check Counts: 17 and 2.
- Member-set Comparison: identical sets.

### #690 guard copies = 7

- Complete Family: script-scope `$script:<Name>ImportFailure = $null` initializations in `.claude/hooks`.
- Exhaustive Search Scope: all files under `.claude/hooks`.
- Primary Strategy: Grep `\$script:\w+ImportFailure = \$null`. Primary Member Set: enforce-parallel-worktree-removal-gate, enforce-parallel-drift-gate, enforce-parallel-cohort-barrier, enforce-orchestration-preimplementation-gate-epic-scope, enforce-epic-worktree-removal-gate-resolution, enforce-epic-wave-barrier, enforce-epic-merge-gate-resolution. Primary Count: 7.
- Cross-check Strategy: Grep `Import guard \(issue #690\)`. Cross-check Member Set: the same seven files. Cross-check Count: 7.
- Member-set Comparison: identical sets.

### #792 offenders on this branch = 0

- Complete Family: success- or warning-stream writes in `.psm1` files under `.claude/lib` and non-entry dot-sourced helpers under `.claude/hooks` and `.codex/hooks`.
- Exhaustive Search Scope: `.claude/lib` (all files), `.claude/hooks`, `.codex/hooks`.
- Primary Strategy: Grep `Write-(Output|Host|Information|Warning)|\becho\b|\[Console\]::(Out|Write)|\[System\.Console\]::(Out|Write)|Out-Host` and classification of each hit (comment, CLI script outside the closure, or entry script). Primary Member Set: empty. Primary Count: 0.
- Cross-check Strategy: Grep `Write-\w+` restricted to `*.psm1` under `.claude/lib`, enumerating every distinct cmdlet. Cross-check Member Set: `Write-Debug` (not in the family) and comment text only; empty within the family. Cross-check Count: 0.
- Member-set Comparison: both empty.

## Automation Feasibility

No human interaction is required for research, implementation, or verification: every seam is in-process
Pester, every check is a scripted test or command, and the parity suites run under `poetry run pytest`.
Operator input is required only for the five design decisions D1-D5 above, which can be resolved in the
spec before execution. The enumeration must be re-run by the executor on the integration branch after
#732, #850, and #787 merge.
