# 2026-09-29-hook-preexisting-imports-fail-open (Spec)

- **Issue:** #786 (primary); bundled #792
- **Parent (optional):** epic #852 enforcement-hook-precision, child C4 (wave 2, 0-indexed; executes after #732, #850, #787)
- **Branch:** `bug/hook-preexisting-imports-fail-open-786`
- **Work Mode:** full-bug (this spec is the only acceptance-criteria source; `user-story.md` is intentionally absent)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Draft
- **Version:** 1.0
- **Research:** `research/research.2026-10-08T14-00.md` (cited below as "research Qn")

## Context

#690 added a guarded import of `WorktreeRunResolution.psm1` to the gates it converted, so a failed import records the failure and denies. Pre-existing module imports and dot-sources in PreToolUse hooks are not guarded in the same way. Examples include `HookPayload.psm1`, the `-helpers` and `-modes` dot-sources, and `EpicScopeReadiness.psm1`. The hooks #690 did not convert are also unguarded, including `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1`, which import `EpicScopeResolution.psm1` and therefore `WorktreeRunResolution.psm1` without a guard. When one of these imports fails, the hook exits non-zero or continues with functions undefined. PreToolUse treats a non-zero exit other than exit 2 as non-blocking, so the gate fails open.

#792 is bundled: a module imported by a PreToolUse or SubagentStop hook must not write to the success or warning output streams, because under `pwsh -File` that text precedes the hook's decision JSON, the harness cannot parse the result, and the result is treated as non-blocking. No repository guard prevents a recurrence.

## Problem Statement

1. **Unguarded imports fail open (#786).** Inferred from documented PowerShell error semantics and the code shape (research Q1, "Current behavior on an import failure"; not yet observed in a run):
   - Claude, unguarded `Import-Module ... -ErrorAction Stop` (for example `enforce-model-routing-receipt.ps1:53,55`): the script terminates, `pwsh -File` exits 1, no JSON is emitted. Exit 1 is non-blocking for PreToolUse.
   - Claude, unguarded `Import-Module` without `-ErrorAction Stop` (every `HookPayload.psm1` import): the script continues with HookPayload functions undefined. In `enforce-pr-author-skill.ps1` the deny statement is abandoned and the **allow** decision is returned at exit 0.
   - Claude SubagentStop `validate-orchestrator-output.ps1`: `$ErrorActionPreference = 'Stop'` makes the unguarded import terminating; exit 1 is non-blocking.
   - Codex: every dependency is a top-level sibling dot-source outside the entry `try`; a missing sibling raises `CommandNotFoundException` and execution continues. A block occurs only if a missing function is later called inside the entry `try`, and the reason then names a function rather than the dependency.
2. **The #690 pattern is duplicated and has defects (research Q2).** The guard block is copy-pasted per hook with its own variable and deny function. `enforce-epic-merge-gate-resolution.ps1` calls a deny function defined in the unguarded `-authorization.ps1` sibling (ordering hazard), and the epic-scope loop guards three modules while importing `EpicScopeReadiness.psm1` unguarded on the next line.
3. **No stdout guard for hook-imported modules (#792).** Nothing prevents a future `Write-Warning`, `Write-Host`, `Write-Output`, or `Write-Information` in a module or helper in a hook's import closure. The research Grep on this branch found zero current offenders (research Q6, "Current-tree result"); the defect is the missing guard.

## Goals

- G1. Every module import and every dot-source reachable from every registered PreToolUse and SubagentStop hook on both surfaces (Claude and Codex) is guarded so that a load failure produces a blocking result that names the failed dependency.
- G2. One shared, import-free helper implements failure recording and blocking-result construction; the duplicated #690 copies are migrated to it.
- G3. A repository guard test (#792) prevents success- and warning-stream writes in modules and dot-sourced helpers that registered hooks import.
- G4. Structural tests discover hooks from the registrations, so new hooks and new imports are covered without editing a fixed list.
- G5. No behavior change when all dependencies load.

## Non-Goals

- NG1. The existing SubagentStop block paths that use `Write-Error` then `exit 1` (`validate-orchestrator-output.ps1`, `validate-discovery-artifact-gate.ps1`, `validate-prd-feature-output.ps1`, `validate-pr-author-output.ps1`, `validate-planner-output.ps1`, `validate-feature-review-coverage.ps1`, and the inline `settings.json` SubagentStop command) are not changed. That defect is recorded separately in `docs/features/potential/2026-08-21-subagentstop-validators-read-undocumented-envelope.md` (operator decision D1).
- NG2. Any bash or Python port of a hook, and any Python invocation from a hook (epic non-goal; repository rule that enforcement hooks must not use Python).
- NG3. The #737 (C5b) scope: making gate suites hermetic, converting existing structural guards to discovery, extending the no-Python guard to `.codex/hooks`, the preimplementation Claude/Codex parity test, the `GENERATED_AGENT_FAMILIES` parity test, and #746. C4 does not edit `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` or `EnforcementHooksNoPythonInvocation.Helpers.ps1` (operator decision D5).
- NG4. Hooks registered for events other than PreToolUse and SubagentStop (SessionStart `persist-session-id.ps1`, Codex UserPromptSubmit `authorize-root-epic-invocation.ps1`, Codex SubagentStart `record-subagent-routing-attestation.ps1`), and scripts present on disk but not registered (`validate-executor-output.ps1`, `validate-required-artifact-output.ps1`, `validate-task-researcher-output.ps1`).
- NG5. Detection of implicit output (an uncaptured expression value at module top level). Command-name matching cannot detect it; the gap is recorded, not closed (research Q6).
- NG6. Converting the `enforce-mermaid-validation.ps1` designed fail-open on a missing `MermaidValidation` module (operator decision D2).

## Operator Decisions (binding requirements)

| ID | Decision |
|---|---|
| D1 | Dependency-failure blocks on SubagentStop use exit 2 with the reason on stderr on both surfaces. Existing exit-1 SubagentStop block paths stay out of scope (NG1). |
| D2 | `enforce-mermaid-validation.ps1` keeps its designed fail-open on a missing `MermaidValidation` module, as a named, justified exemption recorded in the structural test. Its other dependencies (for example `HookPayload.psm1`) are guarded. |
| D3 | Codex conditional dot-source of `.codex/scripts/epic-child-launch-contract.ps1`: absence of the file stays a skip; a load failure when the file is present is a guarded dependency failure. |
| D4 | `validate-bash.ps1` dependency-failure deny uses the leading token `HOOK_DEPENDENCY_LOAD_FAILED:`. All other hooks keep their existing leading tokens (or existing prose prefix where no token exists), and the reason names the failed dependency. |
| D5 | C4 creates the hook-discovery test helper as a new test-support file and does not edit the no-Python guard files targeted by #737. |

## Repro & Evidence

- Steps to reproduce (in-process, no file changes): in a Pester test, register `Mock Import-Module { throw 'simulated' } -ParameterFilter { $Name -like '*HookPayload.psm1' }` (and `Mock Import-Module { }` for other names), dot-source `.claude/hooks/enforce-pr-author-skill.ps1`, and invoke its decision function with a payload that the gate would deny. The precedent seam is `tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1:160-181`.
- Expected: a deny decision naming `HookPayload.psm1` with the hook's leading token.
- Actual (inferred, research Q1): an allow decision, no decision JSON, or a non-blocking exit 1, depending on the hook.
- Frequency: deterministic for any environment in which a dependency file is missing, unreadable, or fails to parse.
- The first regression tests of this feature must confirm the inferred behavior on the unmodified integration branch before the fix (AC-1).

## Root Cause Analysis

- Confirmed root cause (code reading, research Q1-Q3): imports and dot-sources execute at hook script scope outside any `try`; most `Import-Module` calls lack `-ErrorAction Stop`; entry points read the payload through `HookPayload.psm1` before any guard check; there is no shared deny emitter, so the #690 guard was duplicated per hook.
- Contributing: comments at `enforce-model-routing-receipt.ps1:51-52` and `enforce-prd-feature-before-planner.ps1:104-110` describe an unguarded `-ErrorAction Stop` import as fail-closed; on PreToolUse that premise is incorrect because exit 1 is non-blocking.
- Affected components: every registered PreToolUse and SubagentStop hook under `.claude/hooks/` and `.codex/hooks/`, their dot-sourced siblings, the `.claude/lib` modules in their closures (read-only for this feature unless a change is unavoidable), and the bundle mirrors under `extensions/drm-copilot/resources/`.

## Functional Requirements

### FR-1 Shared helper `hook-dependency-guard.ps1`

- FR-1.1 A new sibling script `hook-dependency-guard.ps1` exists, byte-identical, at:
  - `.claude/hooks/hook-dependency-guard.ps1`
  - `.codex/hooks/hook-dependency-guard.ps1`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-dependency-guard.ps1`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-dependency-guard.ps1`
- FR-1.2 The helper contains no `Import-Module` and no dot-source, uses built-in cmdlets and .NET types only, and writes nothing to any output stream.
- FR-1.3 The helper records dependency failures in a script-scope list (recommended `$script:HookDependencyFailures`), initializing the list only when absent so that a hook that dot-sources another hook entry (Codex `enforce-completion-consistency.ps1` dot-sources `enforce-checkpoint-monotonic.ps1`) does not discard earlier records.
- FR-1.4 The helper exposes, at minimum, functions equivalent to the research Q4 proposal (names are recommendations; approved verbs required):
  - `Add-HookDependencyFailure -Name <string> [-ErrorRecord <ErrorRecord>]`
  - `Test-HookDependencyFailure` returning `[bool]`
  - `Get-HookDependencyFailureReason -ReasonPrefix <string>` returning `"<prefix> the dependency '<name>' failed to load (<first exception line>); the gate fails closed."`
  - `Get-HookDependencyFailureDecision -HookEvent PreToolUse|SubagentStop -ReasonPrefix <string>` returning `$null` when nothing failed; for `PreToolUse`, the ordered deny object `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}`; for `SubagentStop`, a result that carries exit code 2 and the reason text for the hook to write to stderr (D1).
- FR-1.5 The helper calls no function defined by a hook or by any guarded dependency.
- FR-1.6 The helper is listed in both core pack manifests (`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`) and in `$script:SharedModuleNames` of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.

### FR-2 Per-edge guards in every registered hook

- FR-2.1 The set of hooks is every script registered for PreToolUse or SubagentStop in `.claude/settings.json` and `.codex/config.toml`, discovered from the registrations.
- FR-2.2 Each module import and each dot-source at hook script scope (direct edges, including the dot-source of the helper itself) is wrapped in its own `try` whose body contains only that one statement; the `catch` records the failure through `Add-HookDependencyFailure` with the dependency file name.
- FR-2.3 Every guarded `Import-Module` uses `-ErrorAction Stop`.
- FR-2.4 A failure inside a nested import or nested dot-source (for example `EpicScopeReadiness.psm1` imported by `enforce-pr-author-skill-helpers.ps1`) propagates to and is reported as the failure of the enclosing top-level edge. Every transitive edge must be covered by a guard at its own site or at a shallower edge.
- FR-2.5 Guard statements stay at hook script scope so dot-sourced definitions land in the hook's scope, and the dot-source shape remains the literal `. (Join-Path $PSScriptRoot '<sibling>.ps1')` form recognized by the existing no-Python carve-out (b), so the no-Python guard needs no change.
- FR-2.6 A `try` must not enclose any statement other than the single import or dot-source, so a parse or runtime defect elsewhere in the hook is not converted into a dependency-failure deny.

### FR-3 Ordering

- FR-3.1 The entry point checks `Test-HookDependencyFailure` before acquiring the payload; when a failure is recorded, no HookPayload function and no function from any guarded dependency is called.
- FR-3.2 The decision function's first statement returns the helper's dependency-failure decision when it is non-null (matching the #690 placement), so in-process tests that call the decision function directly also receive the deny.
- FR-3.3 SubagentStop validators that set `$ErrorActionPreference = 'Stop'` reach the dependency-failure check without a script-terminating error.

### FR-4 Blocking result per surface and event

- FR-4.1 PreToolUse (both surfaces): deny JSON at exit 0 in the `hookSpecificOutput` shape, with the hook's existing leading token (or existing prose prefix) followed by a reason that names the failed dependency.
- FR-4.2 `validate-bash.ps1` (both surfaces): the dependency-failure reason begins with `HOOK_DEPENDENCY_LOAD_FAILED:` (D4).
- FR-4.3 SubagentStop (both surfaces): the reason, naming the dependency, is written to stderr (`[Console]::Error.WriteLine`) and the process exits 2 (D1).

### FR-5 Helper-bootstrap fallback

- FR-5.1 Each hook dot-sources the helper inside a `try`; the `catch` sets a script-scope flag (recommended `$script:HookDependencyGuardLoadFailed`) without calling any function.
- FR-5.2 The hook tail, placed after the existing `$MyInvocation.InvocationName -eq '.'` dot-source early return, checks the flag first and, when set, writes `<TOKEN>: hook-dependency-guard.ps1 failed to load; the gate fails closed.` to stderr and exits 2 on every event and both surfaces.
- FR-5.3 Tests that dot-source a hook never reach the `exit 2` statement.

### FR-6 Migration of the #690 copies

- FR-6.1 Every #690 guard copy (identified by a `$script:<Name>ImportFailure` variable or the comment `Import guard (issue #690)` under `.claude/hooks`) is replaced with the shared helper pattern.
- FR-6.2 The reason wording keeps the shape that existing assertions match (the module name and `deny`).
- FR-6.3 The merge-gate ordering hazard is removed: the dependency-failure deny path in `enforce-epic-merge-gate-resolution.ps1` no longer calls a function defined in `enforce-epic-merge-gate-authorization.ps1`.
- FR-6.4 Existing suites that reset `$script:<Hook>ResolutionImportFailure` (the `*.WorktreeResolution.Tests.ps1` files under `tests/scripts/claude-hooks/`) are updated to reset the helper's failure list.

### FR-7 Runtime (lazy) imports

- FR-7.1 Every runtime import in a hook closure (an `Import-Module` inside a function or scriptblock default, for example `OrchestratorState.psm1` loading `OrchestratorStateUnconditional.psm1`, `validate-orchestrator-output.ps1` loading `OrchestratorStateCompletion.psm1`, and the `DiscoveryValidation` loads in both discovery-artifact gates) is pre-loaded eagerly under a per-edge guard at hook load, so the existing `if (-not (Get-Command ...))` lazy branch is skipped and a load failure blocks.
- FR-7.2 The `enforce-mermaid-validation.ps1` runtime `MermaidValidation` import is exempt (D2) and is listed as a named exemption with its justification in the structural completeness test.
- FR-7.3 Whether a hook-level import satisfies a `Get-Command` issued inside module scope is inferred, not verified (research Q4). The first runtime-import test must confirm it. If it is disproved, the executor records the finding and chooses an alternative that keeps every at-cap file within 500 lines, recorded as a plan deviation.

### FR-8 Codex conditional contract dot-source (D3)

- FR-8.1 When `.codex/scripts/epic-child-launch-contract.ps1` is absent, the conditional dot-source in `codex-epic-child-launch-attestation.ps1` and `enforce-epic-child-worktree-binding.ps1` remains a skip with no deny.
- FR-8.2 When the file is present and its dot-source fails, the failure is recorded and the hook denies naming `epic-child-launch-contract.ps1`.

### FR-9 Dependency enumeration (derived at execution time)

- FR-9.1 The hook dependency list is not fixed in this spec. It is derived mechanically on `epic/enforcement-hook-precision-integration` after #732, #850, and #787 have merged, by running the AST enumeration script given verbatim in research Q3, section "Mechanical enumeration command (AST based)", saved under the session scratchpad and run as `pwsh -NoProfile -File <scratchpad>/enumerate-hook-dependencies.ps1` from the repository root, and again with `-ClaudeRoot extensions/drm-copilot/resources/claude-customizations -CodexRoot extensions/drm-copilot/resources/codex-and-agents-customizations` for the mirrors.
- FR-9.2 The executor applies the research Q3 reconciliation rule: every row of the research Q3 tables appears in the output (at integration-branch line numbers), every additional row is explained by an upstream child's diff, and every `UNRESOLVED` row is resolved by reading the file before the guard list is fixed.
- FR-9.3 The research Q3 tables are planning context only and are not a requirement.

### FR-10 Structural completeness test (#786)

- FR-10.1 A new structural test discovers hooks from `.claude/settings.json` and `.codex/config.toml` (no fixed hook list) and the transitive import and dot-source closure of each, using the AST, through the shared test-support discovery helper (FR-12).
- FR-10.2 It fails when any registered hook lacks the helper bootstrap (FR-5.1) or the tail check (FR-5.2), when any discovered edge is neither guarded at its site nor covered by a shallower guard, or when a runtime edge is not pre-loaded under a guard, excluding only the named exemptions (D2; D3 absence path) with their justification text.
- FR-10.3 It runs over the repository roots and the bundle mirror roots.

### FR-11 #792 stdout guard

- FR-11.1 A repository guard test discovers registered PreToolUse and SubagentStop hooks on both surfaces from the registrations and walks the transitive closure of imported modules and dot-sourced helper scripts (not a fixed list).
- FR-11.2 Detection uses the PowerShell AST on script text and flags, case-insensitively:
  - `CommandAst` whose command name is `Write-Output`, `write`, `echo`, `Write-Host`, `Write-Information`, `Write-Warning`, or `Out-Host`;
  - `InvokeMemberExpressionAst` on `[Console]` or `[System.Console]` with member `Write` or `WriteLine`, and any `Write*` member on `[Console]::Out` or `[System.Console]::Out`.
- FR-11.3 Not flagged: `[Console]::Error.*` (the sanctioned diagnostic route), `Write-Error`, `Write-Verbose`, `Write-Debug`, and text inside comments or string literals.
- FR-11.4 Registered hook entry scripts are outside the guard's scope, including when another hook dot-sources an entry script.
- FR-11.5 The detector accepts script text and a source label (no file read inside the detector), and the discovery helper accepts an injectable text reader, so fixtures are here-strings and no file is written.
- FR-11.6 The guard runs over the Claude hooks, the Codex hooks, and both bundle mirror roots; mirror findings equal repository findings.
- FR-11.7 Diagnostics from hook-imported modules use `[Console]::Error.WriteLine`. If the guard finds an offender on the integration branch, the offending call is changed to `[Console]::Error.WriteLine` (with the mirror updated) rather than exempted.

### FR-12 Test-support files (D5)

- FR-12.1 The discovery logic lives in one new test-support file (recommended `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1`) consumed by both the FR-10 structural test and the FR-11 guard. It is not mirrored, not listed in a pack manifest, and not a coverage target.
- FR-12.2 Recommended test files: `tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1` (FR-11), a structural completeness test under `tests/scripts/claude-runtime/` (FR-10), helper unit tests at `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1` and `tests/scripts/codex-hooks/hook-dependency-guard.Tests.ps1` (one per production copy, so each copy is measured for coverage), and per-hook import-failure cases in the existing or new suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`.

## Constraints

- C1. No Python in any hook or helper; no new Python invocation.
- C2. 500-line cap per production, test, and test-support file. Files at or near the cap on the research branch (research Q4; counts must be re-measured on the integration branch after the upstream merges before line budgets are planned):
  - At risk (>= 480 lines): Claude `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`; Codex `enforce-orchestration-preimplementation-gate.ps1`.
  - Watch: Claude `enforce-prd-feature-before-planner.ps1`, `enforce-parallel-worktree-removal-gate.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `validate-feature-review-coverage.ps1`.
  - Must remain unchanged unless unavoidable (at or near the cap): `HookPayload.psm1`, `WorktreeRunResolution.psm1`, `WorktreeResolution.psm1`, `OrchestratorState.psm1`, Claude and Codex `enforce-orchestration-preimplementation-gate-helpers.ps1`, Codex `enforce-orchestration-preimplementation-gate-epic-resolution.ps1`, `hook-command-scanner.ps1`, `hook-command-invocation.ps1` (both surfaces).
  - The no-Python guard test and helper are at the cap and are not edited (D5, NG3).
- C3. Import-failure tests use Pester mocks as the only seam: `Mock Import-Module ... -ParameterFilter { $Name -like '*<module>' }` for module imports and `Mock Join-Path { throw ... } -ParameterFilter { $ChildPath -eq '<sibling>.ps1' }` for dot-sources and the helper bootstrap. No file is renamed, moved, created, or deleted by a test; no temporary files; no environment-variable or parameter seam in production code (research Q5, rejected seams).
- C4. Bundle-parity, pack-manifest completeness, and `legacy-codex-hook-contracts.Tests.ps1` stay green.
- C5. Fail closed is the norm for an unresolvable dependency (epic Shared Design), with only the D2 and D3-absence exemptions.
- C6. Deny reasons keep their existing leading tokens (epic Shared Design); only `validate-bash.ps1` gains a new token (D4).
- C7. Every changed file under `.claude/hooks`, `.claude/lib`, `.codex/hooks`, or `.codex/scripts` is copied byte-for-byte to its bundle mirror; there is no sync script.
- C8. Evidence is written under `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/<kind>/` (`baseline/`, `regression-testing/`, `qa-gates/`, `other/`).

## Proposed Fix

### Design summary

One shared, import-free, byte-identical sibling helper on both surfaces and in both mirrors; every import and dot-source wrapped individually in a script-scope `try` that records through the helper; module imports gain `-ErrorAction Stop`; dependency-failure checks at the top of the decision function and before payload acquisition; an exit-2 bootstrap fallback in the hook tail; the #690 copies migrated; runtime imports pre-loaded; AST-based structural and #792 guards built on one discovery helper (research "Recommended Approach").

Hook-side pattern (illustrative, research Q4):

```powershell
try { . (Join-Path $PSScriptRoot 'hook-dependency-guard.ps1') } catch { $script:HookDependencyGuardLoadFailed = $true }
try { Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookPayload.psm1' -ErrorRecord $_ }
try { . (Join-Path $PSScriptRoot 'hook-command-scanner.ps1') } catch { Add-HookDependencyFailure -Name 'hook-command-scanner.ps1' -ErrorRecord $_ }
```

### Rejected alternatives (research "Recommended Approach")

- Per-hook copies of the #690 block: duplicates the pattern and keeps the ordering hazard.
- Shared helper as a `.psm1` under `.claude/lib`: unavailable to Codex hooks and itself needs a guarded import.
- One `try/catch` around each hook's whole entry point: catches too broadly and masks defects in the hook itself, contrary to the issue constraint.
- Extending `HookPayload.psm1` with an emitter: the module is near the cap and is itself a guarded dependency.

### Backward compatibility

- With all dependencies loaded, decisions, exit codes, and output for existing payloads are unchanged.
- Leading tokens are unchanged except the new `validate-bash.ps1` dependency-failure token.
- No configuration keys are added; no registration in `.claude/settings.json` or `.codex/config.toml` changes.

### Performance

- Each guard adds one `try` per import at hook load; eager pre-load of runtime imports moves existing load cost from the decision path to hook load. No measurable latency budget is defined; none is asserted.

## Assumptions, Constraints, Dependencies

- Upstream: #732 (C1b), #850 (C3), and #787 (C6) are merged into `epic/enforcement-hook-precision-integration` before execution; this branch is rebased on that state.
- PowerShell 7 (`pwsh`) and Pester 5 as used by PoshQC.
- Vendor hook contracts as read in research Q1 (Claude Code and Codex documentation, 2026-10-08): exit 2 blocks with stderr as the reason on both surfaces for PreToolUse and SubagentStop; other non-zero exits are non-blocking.

## Test Strategy

- Regression-first: per-hook import-failure tests written and run on the unmodified integration branch; expected failure modes are an allow decision, no decision JSON, or a non-blocking exit. Results recorded in `evidence/baseline/` before the fix.
- Per registered hook with at least one dependency (both surfaces): one in-process test per direct edge using the C3 mocks, asserting deny/block, the hook's leading token, and the dependency name; one test that the entry point emits the deny without calling any HookPayload function (`Should -Invoke ... -Times 0` or equivalent).
- Nested-failure tests proving FR-2.4 for at least one nested module edge and one nested dot-source edge.
- Helper unit tests on both copies: record, test, reason text, PreToolUse decision shape, SubagentStop result (exit code 2 and reason), `$null` when nothing failed, no reset on re-dot-source, no output-stream writes.
- Structural tests (FR-10) and the #792 guard (FR-11) with here-string fixtures proving each can fail.
- Existing suites: the `*.WorktreeResolution.Tests.ps1` suites updated for the migrated variable; all other existing hook suites pass unchanged.
- Toolchain (PowerShell, `.claude/rules/powershell.md`): format, analyze, test via the PoshQC MCP tools, with counts and per-file coverage taken from a direct in-repo `Invoke-PoshQCTest` run and the coverage XML keyed by the enclosing `package` element (research Q9), because the MCP results carry no counts. Parity: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`.
- Coverage: Pester measures line coverage only; no branch gate applies. The per-hook `exit 2` bootstrap statement is unreachable in-process and is recorded as a known uncovered line in the coverage comparison.

## Acceptance Criteria

- [x] AC-1: Regression-first evidence. The per-hook import-failure tests (AC-6, AC-7, AC-8) are run against the unmodified integration branch before any production change, and the failing results (allow decision, missing decision JSON, or non-blocking exit) are recorded under `evidence/baseline/`.
- [x] AC-2: Mechanical enumeration. The research Q3 AST enumeration script is run on the integration branch after #732, #850, and #787 merge, for the repository roots and the bundle mirror roots; the outputs and the FR-9.2 reconciliation (explained additional rows, resolved `UNRESOLVED` rows) are recorded under `evidence/other/`.
- [x] AC-3: `hook-dependency-guard.ps1` exists at every FR-1.1 path, all copies are byte-identical, the file contains no `Import-Module` and no dot-source, and it is listed in both core pack manifests and in `$script:SharedModuleNames` of `legacy-codex-hook-contracts.Tests.ps1`.
- [x] AC-4: Helper unit tests pass for both production copies and cover recording, `Test-HookDependencyFailure`, reason text (prefix, dependency name, first exception line), the PreToolUse deny shape, the SubagentStop result (exit code 2 and reason), `$null` when nothing failed, preservation of earlier records on re-dot-source, and absence of output-stream writes.
- [x] AC-5: In every registered PreToolUse and SubagentStop hook on both surfaces, each script-scope import and dot-source is in its own `try` whose body contains only that statement, and every guarded `Import-Module` uses `-ErrorAction Stop`; verified by the AC-11 structural test.
- [ ] AC-6: For every registered Claude PreToolUse hook with dependencies, a test per direct edge simulates that edge's failure with the C3 mocks and asserts a deny decision whose reason begins with the hook's existing leading token (or existing prose prefix) and names the failed dependency; the entry point returns exit code 0 with the deny JSON and calls no HookPayload function.
- [x] AC-7: For every registered Codex PreToolUse hook with dependencies, a test per direct edge simulates that edge's failure with the C3 mocks and asserts a deny decision with the hook's existing leading token (or existing prose prefix) naming the failed dependency.
- [x] AC-8: For every registered SubagentStop hook with dependencies on both surfaces, a test simulates each direct edge's failure and asserts the blocking result is exit code 2 with a stderr reason naming the dependency, including validators that set `$ErrorActionPreference = 'Stop'`; the existing exit-1 block paths are unchanged.
- [x] AC-9: Nested failures are reported as the enclosing top-level edge: a test simulates a failure of a module imported inside a dot-sourced helper (for example `EpicScopeReadiness.psm1` under `enforce-pr-author-skill-helpers.ps1`) and of a nested dot-source, and each produces a blocking result naming the top-level dependency.
- [x] AC-10: Helper bootstrap. A test simulating a `hook-dependency-guard.ps1` load failure (`Mock Join-Path` seam) shows the bootstrap flag is set without a function call, and the structural test asserts every registered hook on both surfaces carries the bootstrap `try` and a tail check, after the dot-source early return, that writes the reason to stderr and exits 2.
- [x] AC-11: A structural completeness test discovers hooks from `.claude/settings.json` and `.codex/config.toml` (no fixed hook list), walks the transitive closure with the AST on repository and mirror roots, and fails when an edge is unguarded and uncovered, when a runtime edge is not pre-loaded under a guard, or when a hook lacks the bootstrap or tail check; the only exemptions are named, each with its justification, in the exemption list the test consumes (`tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`): D2, the D3 absence path, and the named handler exemptions of the 2026-10-09 Change Log entry that passed their fail-closed proof; here-string fixtures prove each failure condition is reported.
- [x] AC-12: No `$script:<Name>ImportFailure` variable and no `Import guard (issue #690)` comment remains under `.claude/hooks` or its bundle mirror, except the scoped failure variables of the named handler exemptions in the 2026-10-09 Change Log entry (`$script:FeatureFolderOrderResolutionImportFailure`, `$script:OrchestrationFeatureFolderResolutionImportFailure`, `$script:PrdFeatureFolderResolutionImportFailure`, `$script:EpicWaveBarrierResolutionImportFailure`, `$script:ParallelDriftGateResolutionImportFailure`, `$script:ParallelCohortBarrierResolutionImportFailure`, `$script:OrchestratorOutputResolverImportFailure`, `$script:OrchestratorOutputWaveBarrierImportFailure`), each permitted only while its handler is a named exemption with a recorded fail-closed proof; the updated `*.WorktreeResolution.Tests.ps1` suites pass; the `enforce-epic-merge-gate-resolution.ps1` dependency-failure path calls no function from `enforce-epic-merge-gate-authorization.ps1`, verified by a test that fails the authorization dot-source and still receives a deny.
- [x] AC-13: Each runtime import in a hook closure (except the D2 exemption) is pre-loaded under a guard at hook load; a test confirms the lazy-load branch is not taken when the pre-load succeeds and that a pre-load failure blocks naming the module. Any FR-7.3 deviation is recorded in the plan.
- [x] AC-14: `enforce-mermaid-validation.ps1` with `MermaidValidation` unavailable still returns no deny (D2), while a simulated `HookPayload.psm1` failure in the same hook produces a deny naming `HookPayload.psm1`.
- [x] AC-15: Codex `epic-child-launch-contract.ps1`: when the file is absent, the conditional dot-source is skipped with no deny; when present and its dot-source fails, the hook denies naming `epic-child-launch-contract.ps1` (D3); both cases are tested on each hook that performs the conditional dot-source.
- [x] AC-16: `validate-bash.ps1` on both surfaces denies a dependency failure with a reason beginning `HOOK_DEPENDENCY_LOAD_FAILED:` and naming the dependency; tests for other hooks confirm their existing leading tokens are unchanged.
- [x] AC-17: With all dependencies loaded, every pre-existing hook test suite on both surfaces passes with no assertion changes other than the AC-12 variable-reset updates.
- [x] AC-18: The #792 guard test discovers registered PreToolUse and SubagentStop hooks on both surfaces from the registrations (not a fixed list), walks the transitive closure of imported modules and dot-sourced helpers, and fails when any of them calls `Write-Output`, `Write-Host`, `Write-Information`, or `Write-Warning`, or a FR-11.2 alias or `[Console]`/`[Console]::Out` write.
- [x] AC-19: The #792 guard is proven able to fail through a text seam with no file written: here-string fixtures for each FR-11.2 form are reported as offenders; fixtures for `[Console]::Error.WriteLine`, a comment, a string literal, and `Write-Verbose` are not reported; a synthetic registration, hook, and module supplied through the injectable text reader reports an offender in the transitively imported module.
- [x] AC-20: Hook entry-point scripts are outside the #792 guard's scope: the synthetic graph test shows a `Write-Output` in a registered entry script is not reported, including an entry script dot-sourced by another hook.
- [x] AC-21: Diagnostics from hook-imported modules go to `[Console]::Error.WriteLine`, and the #792 guard passes on this branch after rebase onto the integration branch containing #732, #850, and #787.
- [x] AC-22: The #792 guard runs over the Claude hooks, the Codex hooks, and both bundle mirror roots under `extensions/drm-copilot/resources/`, and the mirror findings equal the repository findings.
- [x] AC-23: Every file changed or created under `.claude/hooks`, `.claude/lib`, `.codex/hooks`, or `.codex/scripts` is byte-identical to its bundle mirror, and the push-down parity and pack-manifest pytest suites named in the Test Strategy and `legacy-codex-hook-contracts.Tests.ps1` pass.
- [ ] AC-24: Line coverage is >= 85% for each changed or created PowerShell production file (each hook, each dot-sourced sibling, and both helper copies), measured per file from the Pester coverage XML and recorded under `evidence/qa-gates/`, with the bootstrap `exit 2` lines listed as known uncovered lines; no changed line loses coverage.
- [x] AC-25: Every changed or created PowerShell file (production, test, and test-support) is at most 500 lines on the final branch, measured and recorded under `evidence/qa-gates/`; the C2 near-cap files are re-measured on the integration branch before line budgets are planned.
- [x] AC-26: No hook or helper invokes Python; the no-Python guard test and `EnforcementHooksNoPythonInvocation.Helpers.ps1` are unmodified and pass; the discovery helper is a new test-support file (D5).
- [x] AC-27: The PowerShell toolchain passes in a single pass (format, analyze with zero errors and warnings on changed files, Pester), with results recorded under `evidence/qa-gates/`.

## Risks & Mitigations

- R1. Merge overlap with #737 (C5b, same wave). High: the no-Python guard pair (mitigated by not editing it, D5, and by keeping the carve-out (b) dot-source shape) and `legacy-codex-hook-contracts.Tests.ps1` (C4 adds a name to a fixed list that #737 may convert to discovery; resolve by rebase, keeping the helper name in whichever form lands). Medium: gate suites that C4 extends and #737 makes hermetic, and two discovery helpers if #737 adds its own (C4 owns `HookDependencyGraph.Helpers.ps1`; #737 may reuse it after merge). Low: preimplementation gate prologues read by the #737 parity test.
- R2. Shared-helper bootstrap. If the helper fails to load, later `catch` blocks call an undefined `Add-HookDependencyFailure` (a statement-terminating error inside a `catch`). Mitigation: the tail checks the bootstrap flag first and exits 2 before any decision is attempted; tests assert the flag and the structural test asserts the tail. The `exit 2` statement itself is not reachable in-process and is a recorded uncovered line.
- R3. Upstream changes alter the dependency set. Mitigation: FR-9 derives the list on the integration branch; structural tests discover from registrations.
- R4. Over-broad guards masking hook defects. Mitigation: FR-2.6 single-statement `try` bodies, asserted structurally.
- R5. 500-line cap pressure on near-cap hooks. Mitigation: re-measure after upstream merge; the migration of #690 copies offsets some additions; extract to a sibling helper (guarded and mirrored) where a hook would exceed the cap.
- R6. Inferred PowerShell behavior (research Q1, Q4) may differ in practice. Mitigation: AC-1 regression-first evidence and the FR-7.3 confirmation test.
- R7. Residual #792 gap: implicit output is not detected (NG5).

## Rollout & Follow-up

- Delivered in one pull request into `epic/enforcement-hook-precision-integration`, closing #786 and #792.
- Follow-up candidates (not in scope): correct the exit-1 SubagentStop block paths (potential entry dated 2026-08-21); consolidate hook discovery with #737 after both merge.
- Links: #786, #792, epic #852 (`docs/features/epics/enforcement-hook-precision/epic.md`), #690, #737, research `research/research.2026-10-08T14-00.md`.

## Change Log

- 2026-10-09 — operator decision (option 1, named exemptions)
  - Decision: the scoped import-failure handlers that issues #565, #787, #840, and #850 added are kept, with their deny codes, as named exemptions in addition to D2 and the D3 absence path, subject to the fail-closed condition below. Issue #850 added no separately scoped handler: its `WorktreeItemResolution.psm1` guard in `enforce-epic-merge-gate-resolution.ps1` records into the #690 variable `$script:EpicMergeGateResolutionImportFailure` and denies through the #690 decision function, so it is migrated with that #690 copy.
  - Named handler exemption candidates: H1 `$script:FeatureFolderOrderResolutionImportFailure` (#565, `FEATURE_FOLDER_ORDER_BLOCKED:`); H2 `$script:OrchestrationFeatureFolderResolutionImportFailure` (#565, readiness failure `feature-folder-resolution-import`, Claude and Codex surfaces); H3 `$script:PrdFeatureFolderResolutionImportFailure` (#565, `PRD_FEATURE_BLOCKED:`); H4 `$script:EpicWaveBarrierResolutionImportFailure` (#565, `EPIC_WAVE_BARRIER_BLOCKED:`); H5 `$script:ParallelDriftGateResolutionImportFailure` (#565, `PARALLEL_DRIFT_GATE_BLOCKED:`); H6 `$script:ParallelCohortBarrierResolutionImportFailure` (#565, `PARALLEL_COHORT_BARRIER_BLOCKED:`); H7 `$script:OrchestratorOutputResolverImportFailure` (#787, `RESOLVER_IMPORT_FAILED`); H8 `$script:OrchestratorOutputWaveBarrierImportFailure` (#840, `EPIC_WAVE_BARRIER_UNEVALUABLE:`).
  - Fail-closed condition: a handler is exempted only after a recorded proof (a Pester test that forces its import or dot-source to fail, or a cited code path) shows that when its dependency fails to load it denies or blocks and never allows. For a PreToolUse hook, blocking is a deny decision; for a SubagentStop hook, blocking is exit code 2 (D1), and a block that reaches the process only through `Write-Error` followed by `exit 1` is not blocking.
  - Conversion rule: a handler whose proof shows fail-open behaviour is converted to the uniform helper-based deny of this specification; the affected test assertions are updated, and each changed assertion is recorded with its reason for the pull request body and the feature audit. For such a handler only, this decision takes precedence over AC-17.
  - Feature-folder-order rule (BF-1): if the resolver failure causes `enforce-feature-folder-order.ps1` to skip a check that it performs for a write when the resolver loads, the hook fails open for that write and is converted, with the assertion of test F18 changed and the reason recorded; if non-plan writes are never subject to a resolver-dependent check, the allow of a non-plan write while the resolver cannot load is not an allow on import failure, and the handler is exempted with that reasoning recorded.
  - Acceptance-criteria edits: AC-11 and AC-12 are amended to admit the named handler exemptions and their scoped failure variables. AC-17 is unchanged.
