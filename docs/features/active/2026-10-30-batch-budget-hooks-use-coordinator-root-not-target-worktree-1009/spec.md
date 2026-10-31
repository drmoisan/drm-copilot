# 2026-10-30-batch-budget-hooks-use-coordinator-root-not-target-worktree (Spec)

- **Issue:** #1009
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T12-40
- **Status:** Ready for planning
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this file only; no `user-story.md`)
- **Branch:** `bug/batch-budget-hooks-coordinator-root-1009`
- **Research:** `research/research.2026-10-30T12-12.md` (this feature folder)

## Context
The batch-budget hooks cap and pool edits by the coordinator session root instead of the worktree being edited. A non-isolated child resuming an item in its own worktree is denied on its 4th distinct production file even though that worktree's checkpoint selects `large`. This is one of four bugs (batch-budget, preimplementation gate, PR authoring, completion stop hook) that share one root cause and one fix: a target-worktree resolver.

This item creates the shared resolver and applies it only to the batch-budget hooks. Sibling issues #1010 (preimplementation gate) and #1011 (`enforce-pr-author-skill.ps1` `--head` resolution) consume the resolver unchanged in later items.

Environment:
- OS/version: not recorded in the report. The defect is platform-independent; the hook suites run on the Windows Pester shards and on the Linux job `poshqc / PowerShell hook suites (Linux)` (case-sensitive file system).
- Python version: not applicable (enforcement hooks do not invoke Python).
- Command/flags used: a coordinating session (`parallel-orchestrator`, `epic-orchestrator`, or a main session acting as coordinator) driving child orchestrators whose items live in separate git worktrees.
- Data source or fixture: hooks `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, and shared `enforce-batch-budget-route.ps1` (Claude under `.claude/hooks/`, Codex under `.codex/hooks/`, plus bundled copies under `extensions/drm-copilot/resources/`).

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The only agent-side workarounds are fabricating a checkpoint at the coordinator root (prohibited by checkpoint hygiene), deleting hook state, or asking the human to start one Claude Code session per item worktree. Agents correctly refuse the first two.


## Repro & Evidence
Steps to Reproduce:
1. Run a coordinating session whose own checkout holds no per-item checkpoint (coordinator-root checkpoint hygiene).
2. Relaunch a child without isolation so it resumes an existing item worktree whose checkpoint selects `large` (or `remediation` / `preparation`) and is non-terminal.
3. Have the child edit a 4th distinct production `.py` or `.ps1` file in that worktree.

Expected:
- The route is read from the checkpoint of the resolved target worktree.
- Budget state is keyed per resolved worktree root.
- Paths under gitignored `artifacts/` are never counted as production files.
- A file outside every registered worktree keeps today's behavior.
- The cap stays as strict as today; only the checkpoint and root evaluated change.

Actual:
The child is denied `PYTHON_LARGE_PATH_REQUIRED` / `POWERSHELL_LARGE_PATH_REQUIRED`. The budget state file is keyed to the session and stored under the coordinator root, so all items in the session share one counter. Gitignored scratch files under any worktree's `artifacts/` are counted as production files.

Code-level evidence (research sections 1.1 to 1.4):
- Claude: `Invoke-*BatchBudgetHook`, `Invoke-*BatchBudgetDecision`, and `ConvertTo-*BatchBudgetState` default `-Root` to `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`, the checkout that holds the hook script. The payload `cwd` is never read. The checkpoint path is `<Root>/artifacts/orchestration/orchestrator-state.json`; state is `<Root>/.claude/state/<kind>-batch-budget.<sessionId>.json`.
- Codex: `Invoke-*BatchBudgetHook -Root` defaults to `(Get-Location).Path`; the registration in `.codex/config.toml` runs the hook from `git rev-parse --show-toplevel`. State is `<Root>/.codex/state/<kind>-batch-budget.<sessionId>.json`. Codex has no containment filter.
- Neither runtime excludes `artifacts/`; a `.py` or `.ps1` under `<root>/artifacts/` counts as production today.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `PYTHON_LARGE_PATH_REQUIRED`, `POWERSHELL_LARGE_PATH_REQUIRED`


## Scope & Non-Goals
- In scope:
  - A new pure PowerShell resolver module `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` exporting `Resolve-HookTargetWorktree` and five pure helpers, its bundled copy, and its Pester suite.
  - A functions-only Codex twin `.codex/hooks/hook-target-worktree.ps1`, its bundled copy, and its parity and behavior suite.
  - Wiring the resolver into the two Claude batch-budget hooks and the two Codex batch-budget hooks (and the four bundled copies): checkpoint read from the resolved target root, worktree-keyed state file name, root-level `artifacts/` exclusion.
  - Pack-manifest entries (Claude `core.json`, Codex `core.json`) and the manifest/contract test lists that enumerate them.
  - Documentation: the execution-environment brief (six byte-identical copies), `.claude/rules/orchestrator-state.md` and its bundled copy, and the help text of the four edited hooks.
- Out of scope / non-goals:
  - Any relaxation of a gate's intent. The cap value, test-file rules, reason codes, and deny-only output are unchanged.
  - Adding containment to the Codex hooks (Codex continues to count a path outside every registered worktree, as today).
  - Any change to worktree-isolation behavior or to checkpoint schemas.
  - A Python or TypeScript port of the resolver (none exists for the batch budget; none is created).
  - Editing the route helper `enforce-batch-budget-route.ps1` (all three copies stay unchanged).
  - Fixing 8.3 short-name and junction path matching (documented limitation, see R6).
- Explicitly excluded systems, integrations, or datasets (consumers of the resolver in sibling items; not edited here):
  - #1010 preimplementation gate: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `-epic-scope.ps1`, `-helpers.ps1`, `-modes.ps1`, `-targets.ps1`; `.codex/hooks/enforce-orchestration-preimplementation-gate*.ps1` (including `-epic-resolution.ps1`); and their bundled copies.
  - #1011 PR authoring gate: `.claude/hooks/enforce-pr-author-skill.ps1`, `enforce-pr-author-skill-helpers.ps1`, `enforce-pr-author-skill.artifact-root.ps1`, `.current-branch.ps1`, `.docs-only.ps1`, `.epic-base-branch.ps1`; and their bundled copies.
  - The completion stop hook defect (fourth sibling bug) is tracked separately.
  - `.claude/hooks/enforce-model-routing-receipt.ps1`, `.claude/settings.json`, `.codex/config.toml`, Claude `python.json` and `powershell.json` pack manifests, and the existing `WorktreeResolution*.psm1` modules.

## Root Cause Analysis
Several hooks derive the repository root from their own script location (`Split-Path (Split-Path $PSScriptRoot)`) and read `<root>/artifacts/orchestration/orchestrator-state.json`. Claude Code loads hook scripts from the session's project directory, so in a coordinating session that root is the coordinator checkout. Worktree isolation hides the defect because an isolated child gets its own session root; it surfaces for non-isolated resumed children, coordinators writing into an item worktree, and subagents (pr-author, atomic-executor) that inherit the coordinator root.

For the batch-budget hooks specifically (research 1.4):
- An item worktree nested under the coordinator checkout (`.claude/worktrees/<name>`) passes containment, so its files count against the coordinator's single per-session counter and are evaluated under the coordinator's checkpoint. This is the reported defect.
- An item worktree in a sibling directory fails containment in Claude, so its files are discarded; in Codex (no containment) they count against the coordinator.

Shared fix: one pure helper, `Resolve-HookTargetWorktree`, that returns the worktree root for a tool call from (1) a file-tool target path, (2) a Bash operand path or branch, (3) an `Agent(...)` delegation identity, or (4) the session root as the final fallback, using `git worktree list --porcelain` through an injectable invoker seam and selecting the nearest enclosing registered worktree. The existing filesystem-based resolvers (`Resolve-WorktreeOperandTarget`, `Resolve-WorktreeCallTarget`) were rejected because they read files, return the nearest `.git` marker rather than the nearest registered worktree, and do not match the required result shape (research 3.3).


## Proposed Fix

### Design summary (what changes where):
- New module `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` holds all resolution logic (porcelain parsing, nearest-enclosing selection, precedence, ambiguity, normalization, worktree key). Hooks add only thin wiring.
- New Codex twin `.codex/hooks/hook-target-worktree.ps1` carries the same functions with identical function text, because Codex hooks cannot import `.claude/lib` in a consumer repository.
- The four batch-budget hooks call the resolver after the scope filter and the route-import check, then use the resolved root for the `artifacts/` exclusion, the checkpoint path, containment, and the state file name.

### Boundaries and invariants to preserve:
- Scope filter unchanged: no `file_path`, or a non-matching extension, allows without resolution, checkpoint read, or state I/O.
- A route-helper import failure still denies an in-scope path before any seam or invoker call.
- The fallback is always the session root, which is today's behavior and fails toward the cap, never toward the exemption.
- Cap value (`-ProdCap` default), test-file classification rules, reason codes and text, and deny-only output are unchanged.
- The route helper keeps exactly its three functions and its byte parity across copies.
- Enforcement hooks invoke only PowerShell and `git`; never Python.
- No file is written into any worktree other than the session root.

### Dependencies or blocked work:
- None upstream. #1010 and #1011 depend on this item's resolver contract (see the dedicated contract section).
- Execution requires the item checkpoint to select an uncapped, non-terminal route (R7, see Assumptions).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
Create:
- `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/HookTargetWorktree.psm1`
- `.codex/hooks/hook-target-worktree.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-target-worktree.ps1`
- `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1`
- `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1`
- `tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1`

Edit:
- `.claude/hooks/enforce-python-batch-budget.ps1` and bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`
- `.claude/hooks/enforce-powershell-batch-budget.ps1` and bundled copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`
- `.codex/hooks/enforce-python-batch-budget.ps1` and bundled copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`
- `.codex/hooks/enforce-powershell-batch-budget.ps1` and bundled copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- The six execution-environment brief copies:
  - `.claude/skills/execution-environment/SKILL.md`
  - `.agents/skills/execution-environment/SKILL.md`
  - `.github/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`

#### Functions/classes/CLI commands impacted:
- New: `Resolve-HookTargetWorktree`, `ConvertFrom-HookTargetWorktreePorcelain`, `Get-HookTargetWorktreeEnclosingRoot`, `ConvertTo-HookTargetWorktreeNormalizedPath`, `Get-HookTargetWorktreeRelativePath`, `Get-HookTargetWorktreeKey`.
- Changed (Claude, both kinds): `Invoke-PythonBatchBudgetHook`, `Invoke-PowerShellBatchBudgetHook` gain a `-WorktreeListInvoker` seam passed to the resolver; checkpoint path, containment root, and state file name derive from the resolved root. `Invoke-*BatchBudgetDecision` and `ConvertTo-*BatchBudgetState` are called with `-Root <resolved root>`; their logic is unchanged.
- Changed (Codex, both kinds): `Invoke-*BatchBudgetHook` resolves each evaluated path (both `source_path` and `file_path` of each mapped edit) and applies the same checkpoint, state-name, and `artifacts/` rules.
- Unchanged: `ConvertFrom-BatchBudgetCheckpoint`, `Get-BatchBudgetSelectedRoute`, `Test-BatchBudgetLargePathRoute`, `Get-*BatchBudgetSessionId`.

#### Data flow and validation changes:
Target hook semantics (research "Behavior Semantics (target)"):
1. Scope filter unchanged.
2. Route-helper import failure denies before any seam or invoker call.
3. `Resolve-HookTargetWorktree -SessionRoot $Root -FilePath $filePath -WorktreeListInvoker <seam>`; `$TargetRoot = WorktreeRoot`. When `Ambiguous` is true or `WorktreeRoot` is `$null`, `$TargetRoot = $Root`.
4. `artifacts/` exclusion: when the path relative to `$TargetRoot` (via `Get-HookTargetWorktreeRelativePath`), or a relative path, starts with `artifacts/`, allow with no state write and no slot consumed. Only the root-level `artifacts/` directory is excluded (matching the `/artifacts` entry in `.gitignore`); a nested directory named `artifacts` still counts.
5. Checkpoint read from `Join-Path $TargetRoot 'artifacts/orchestration/orchestrator-state.json'` through the existing `-ReadCheckpoint` seam.
6. State remains under the session root's state directory (`.claude/state/` for Claude, `.codex/state/` for Codex) with the session id resolved exactly as today (R1). When `$TargetRoot` equals `$Root` (OrdinalIgnoreCase), the file name is unchanged; otherwise it is `<kind>-batch-budget.<sessionId>.<Get-HookTargetWorktreeKey $TargetRoot>.json`. Containment and the rehydrate filter use `-Root $TargetRoot` (Claude).
7. The decision function is unchanged except for `-Root $TargetRoot`.

Intended consequence (research 1.4): Claude edits to a sibling-directory worktree, discarded today by containment, become counted against that worktree's own budget unless its checkpoint selects an uncapped route. This tightening follows directly from "budget state is keyed per resolved worktree root" and is tested.

#### Error handling and logging updates:
- The resolver never throws for an unresolvable target; it returns a result with `ReasonCode` and `Detail`. An invoker that throws or returns empty text is treated as "no registered worktrees", yielding the session-root fallback with a `Detail` naming the reason.
- Module load failure in a Claude hook is handled by the standard guarded import (R4): `Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1'`, and the top-level `Get-HookDependencyFailureDecision` denies every in-scope Write and Edit (fail closed). No entries are added to `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`.
- Codex twin load failure is handled by the guarded dot-source with `Add-HookDependencyFailure -Name 'hook-target-worktree.ps1'`.
- No new logging channel; deny reasons keep their existing text.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the change set; the state file name for session-root edits is unchanged, so existing state files remain valid before and after the change. Worktree-keyed state files written after the change are ignored by a reverted hook.

### Technical specifications (interfaces/contracts):

### Shared resolver public contract (consumed by #1010 and #1011)

**Module and import.**
- Claude: `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`. PowerShell 7+, `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'` at module scope, explicit backtick-continued `Export-ModuleMember -Function`. Imports no other module. Functions reference no module-scope `$script:` state (constants live inside functions) so the Codex twin's function text can be byte-compared. The comment-based help carries the `.NOTES` mirror statement and the fail-fast convention line used by sibling `worktree-resolution` modules.
- Codex: `.codex/hooks/hook-target-worktree.ps1`, a functions-only twin whose function names and each function's `Extent.Text` equal the module's.
- Consumer hook import (Claude), one statement per `try`, `-ErrorAction Stop`:
  ```
  try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/HookTargetWorktree.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1' -ErrorRecord $_ }
  ```
  The consumer's decision function returns the dependency-failure decision first (rule S6 of `hook-dependency-guard-completeness.Tests.ps1`). A consumer hook listed in a pack manifest requires the module to be listed in the same or a closure-satisfying manifest (`core.json` for Claude).
- Consumer hook import (Codex): `try { . (Join-Path $PSScriptRoot 'hook-target-worktree.ps1') } catch { Add-HookDependencyFailure -Name 'hook-target-worktree.ps1' -ErrorRecord $_ }`, with the twin listed in Codex `core.json`.

**Signature.**
```
Resolve-HookTargetWorktree
    -SessionRoot <string>                  # Mandatory. Absolute session root (the hook's -Root). Fallback root.
    [-FilePath <string[]>]                 # Source 1. File-tool targets: Write/Edit/MultiEdit/NotebookEdit file_path; Codex source_path and file_path.
    [-CommandOperandPath <string[]>]       # Source 2a. Bash operand paths already parsed by the caller (git -C value, --body-file value, absolute file arguments).
    [-CommandBranch <string>]              # Source 2b. Bash branch operand already parsed by the caller (for example gh pr create --head value).
    [-DelegationPrompt <string>]           # Source 3. Agent(...) prompt text; the resolver reads the 'branch:' label and the canonical issue line.
    [-CheckpointIssueReader <scriptblock>] # Optional, source 3 only. { param($WorktreeRoot) <issue number or $null> }. Caller-owned I/O.
    [-WorktreeListInvoker <scriptblock>]   # { param($SessionRoot) <porcelain text> }. Default runs git -C $SessionRoot worktree list --porcelain.
```
Command parsing stays with the caller (for example `hook-command-invocation.ps1`, `Get-OrchestrationGitSelectorTarget`, `Get-PrAuthorBodyFileValue`); the resolver does not parse command lines.

**Result object** (`[pscustomobject]`, R5):

| Field | Type | Value domain |
|---|---|---|
| `WorktreeRoot` | string or `$null` | Normalized forward-slash absolute root; `$null` only when `Ambiguous` is true or `ReasonCode` is `TARGET_WORKTREE_NOT_DERIVABLE` |
| `Source` | string | `FilePath`, `CommandOperand`, `DelegationIdentity`, or `SessionRoot` (the source that decided; `SessionRoot` also when a present path source fell back) |
| `Ambiguous` | bool | `$true` only with `ReasonCode = TARGET_WORKTREE_AMBIGUOUS` |
| `ReasonCode` | string or `$null` | `$null`, `TARGET_WORKTREE_AMBIGUOUS`, or `TARGET_WORKTREE_NOT_DERIVABLE` |
| `Detail` | string | One prose clause describing the decision or fallback reason (may be empty on a clean match) |
| `Candidates` | string[] | Normalized candidate roots considered for an ambiguous or multi-match result; empty otherwise |

**Sources and strict precedence.** Exactly one source decides: the first present source in the order (1) FilePath, (2) CommandOperand (paths and/or branch), (3) DelegationIdentity, (4) SessionRoot. A source is present when it carries a non-blank value. A later source is never consulted when an earlier one is present.
- **No source present:** `WorktreeRoot = SessionRoot`, `Source = SessionRoot`; the invoker is not called.
- **FilePath (1):**
  - A relative path maps to the session root without calling the invoker (R2).
  - Each absolute path maps to its nearest enclosing registered worktree.
  - All paths agree: that root, `Source = FilePath`.
  - Paths disagree: `Ambiguous = $true`, `TARGET_WORKTREE_AMBIGUOUS`, `Candidates` lists the roots.
  - A path inside no registered worktree, or an invoker that throws or returns empty text: `WorktreeRoot = SessionRoot`, `Source = SessionRoot`, `Detail` names the reason (today's behavior).
- **CommandOperand (2):** operand paths follow the FilePath rules. A branch matches porcelain `branch refs/heads/<name>` lines: zero matches `TARGET_WORKTREE_NOT_DERIVABLE`; one match that root; more than one `TARGET_WORKTREE_AMBIGUOUS`. When both paths and a branch are present and disagree, the result is `TARGET_WORKTREE_AMBIGUOUS`.
- **DelegationIdentity (3):** the `branch:` label (same regex shape as `Find-WorktreeResolutionBranchSignal`) resolves through porcelain branch lines. The canonical issue line (`Canonical issue number for this feature is #?N`) resolves only through `-CheckpointIssueReader`; without a reader an issue-only prompt is `TARGET_WORKTREE_NOT_DERIVABLE`. Several distinct issue numbers are `TARGET_WORKTREE_AMBIGUOUS`. A branch is authoritative; a disagreeing issue is `TARGET_WORKTREE_AMBIGUOUS` (as in `Resolve-WorktreeItemTarget`). The session root is never a fallback for a present identity that names no worktree.
- **SessionRoot (4):** applies only when no other source is present.

**Nearest-enclosing-registered-worktree rule.** Registered worktrees come only from `git worktree list --porcelain` output (`bare` stanzas skipped). For a normalized absolute path P, the selected root is the longest normalized registered root R such that P equals R or P starts with `R/`. A worktree nested inside another (for example `/repo/.claude/worktrees/item` inside `/repo`) therefore wins for paths under it. Unregistered nested clones and submodule `.git` files are not treated as worktrees.

**Ambiguity and not-derivable rules.** `TARGET_WORKTREE_AMBIGUOUS` is returned only when the deciding source yields more than one distinct root or its components disagree. `TARGET_WORKTREE_NOT_DERIVABLE` is returned only when a present branch or identity source names no registered worktree (or an issue-only identity has no reader). Path sources never yield `NOT_DERIVABLE`; they fall back to the session root. The two literals are restated in the module and pinned by a test to equal `Get-WorktreeResolutionAmbiguityReasonCode` and `Get-WorktreeResolutionNoTargetReasonCode` (precedent: `validate-orchestrator-output-resolution.ps1`). A consumer gate composes its deny reason from `ReasonCode` and `Detail`.

**Injectable `-WorktreeListInvoker` seam.** Signature `{ param($SessionRoot) <string> }` returning porcelain text. The default body is `& git -C $SessionRoot worktree list --porcelain 2>$null`; a non-zero `$LASTEXITCODE` yields an empty string. The default is unbounded (no module-local timeout, R3). The invoker is called at most once per resolution and only when a present source needs enumeration (never for a relative-only FilePath set or the no-source case). Tests always inject the invoker; `Mock git` is forbidden by `check-powershell-test-purity.ps1`.

**No file reads.** The resolver performs no file, environment, or clock read. Its only I/O is through the injected `-WorktreeListInvoker` (or its default body) and the caller-supplied `-CheckpointIssueReader`.

**Path normalization and comparison.** `\` becomes `/`, repeated `/` collapse, and a trailing `/` is trimmed except from a bare root. All comparisons use `[System.StringComparison]::OrdinalIgnoreCase` unconditionally on every platform. Git for Windows drive-rooted forward-slash output (`C:/...`) and backslash `file_path` values therefore match. Known limitation (R6): an 8.3 short-name or junction-equivalent path that differs textually from git's long path does not match and falls back to the session root.

**Exported pure helpers** (process-free, testable with in-memory text):
- `ConvertFrom-HookTargetWorktreePorcelain -Text <string>`: records with `Root`, `Branch` (short name or `$null` for detached), `Bare`, `Prunable`; `bare` stanzas skipped; tolerates blank lines and CRLF.
- `Get-HookTargetWorktreeEnclosingRoot -Path <string> -Roots <string[]>`: nearest enclosing root or `$null`.
- `ConvertTo-HookTargetWorktreeNormalizedPath -Path <string>`: normalization above.
- `Get-HookTargetWorktreeRelativePath -Path <string> -WorktreeRoot <string>`: forward-slash path relative to the root, or `$null` when outside it.
- `Get-HookTargetWorktreeKey -WorktreeRoot <string>`: `<sanitized leaf>-<8 hex of SHA-256 of normalized root>`, the same algorithm as the existing worktree-derived batch-budget session id.

#### Inputs/outputs and formats:
- Resolver input: strings and scriptblocks as above; porcelain text in git's documented `worktree list --porcelain` format.
- Hook input: unchanged PreToolUse payloads. Hook output: unchanged allow or deny shape.
- State file: unchanged JSON content; name `<kind>-batch-budget.<sessionId>.json` for the session root, `<kind>-batch-budget.<sessionId>.<worktreeKey>.json` for another resolved root.

#### Required configuration keys and defaults:
- No new configuration keys. `-ProdCap` default unchanged. `-WorktreeListInvoker` defaults to the git porcelain invoker.
- `config/poshqc-coverage.json` already includes `.claude/lib` and `.codex/hooks` roots; `config/poshqc-scan.json` already scans `tests/scripts`. No edit expected.

#### Backward-compatibility expectations:
- All existing batch-budget suites use relative `file_path` values and synthetic roots; under R2 they keep the legacy root, checkpoint path, and state-file name and pass unchanged.
- Session-root edits keep the existing state-file name, so existing state remains valid.
- Behavior change limited to: item-worktree edits evaluated against their own checkpoint and counter; root-level `artifacts/` paths no longer counted; Claude sibling-worktree edits counted against that worktree (intended tightening).

#### Performance constraints (latency/throughput/memory):
- At most one `git worktree list --porcelain` process per in-scope Write or Edit with an absolute path, started only after the extension filter and the route-import check. No process for out-of-scope paths, relative paths, or missing `file_path`.
- No timeout is imposed (R3); the cost is accepted as one short-lived git process per qualifying call.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Settled orchestrator decisions R1 to R8:
    - R1: budget state stays under the session root `.claude/state/` (Codex `.codex/state/`) with a worktree-keyed file name via `Get-HookTargetWorktreeKey`; nothing is written into other worktrees.
    - R2: relative paths map to the session root without invoking git.
    - R3: the default porcelain invoker is unbounded (no module-local timeout).
    - R4: the module is imported with the standard guarded import (fail closed); no new import-failure exemption entries.
    - R5: the result object carries `WorktreeRoot`, `Source`, `Ambiguous` plus additive `ReasonCode`, `Detail`, `Candidates`.
    - R6: 8.3 short-name and junction paths fall back to the session root; documented limitation.
    - R7: execution edits more than the direct-mode cap of production PowerShell files, so the item checkpoint must select an uncapped, non-terminal route (`large`, `remediation`, or `preparation`) before execution begins. This is owned by the executing orchestrator.
    - R8: byte identity verified: both Claude hooks, both Codex hooks, and `.claude/rules/orchestrator-state.md` are each byte-identical to their bundled mirrors at the branch base.
  - Claude Write and Edit always supply absolute `file_path` values in live sessions.
  - Bundle mirrors are produced by a copy step after the last edit of each source.
- Constraints (budget, performance, compatibility):
  - File size: the Codex hooks and the Codex twin are pinned at or below the limit enforced by `legacy-codex-hook-contracts.Tests.ps1`; Claude hooks (currently near the 500-line guidance tier) must stay below the 801-line hard block, with logic kept in the module and wiring kept minimal.
  - New hook rows go in new `*.TargetWorktree.Tests.ps1` suites rather than the existing near-limit suites.
  - Tests use slash-rooted synthetic paths (`/repo`, `/repo/.claude/worktrees/item`, `/repo-wt/sibling`) so they behave identically on the Linux hook-suite job; no test reads the real worktree list or gitignored state.
  - The resolver suite under `claude-lib` runs on the Windows shards only; the Codex twin suite runs on the Linux job.
  - The executor has no PowerShell tool; Pester runs go through PoshQC MCP tools or a `sh` launcher under `SCRATCH`, and counts come from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`.
- External dependencies (services, libraries, releases):
  - `git` on PATH for the default invoker at hook runtime. No new library dependency.
  - Branch hooks are not exercised by isolated subagents until merge; proof is by Pester.

## Data / API / Config Impact
- User-facing or API changes: new public module API (`Resolve-HookTargetWorktree` and five helpers) for hook consumers; new `-WorktreeListInvoker` seam parameter on the batch-budget hook functions. No change to deny reason codes.
- Data or migration considerations: new worktree-keyed state file names under the session root state directory; no migration; no schema change to state or checkpoint files.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): `settings.json` and `config.toml` hook registrations unchanged; pack manifests gain one entry each (Claude `core.json`, Codex `core.json`).

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: worktree checkpoint large → uncapped; worktree with no checkpoint → capped; two worktrees in one session → independent counters; an `artifacts/` scratch `.py` / `.ps1` → not counted; a session-root file → unchanged behavior. Tests in every runtime carrying the hook or helper (Claude `.claude/hooks/`, Codex `.codex/hooks/`, and the bundled copies the push-down publishes).
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Documentation and parity: update the execution-environment brief (Batch Budget, Hook Execution Context, Command-Text Restrictions) in all byte-identical copies in the same change; update `.claude/rules/orchestrator-state.md` (hooks now resolve the target worktree, so no coordinator-root checkpoint is ever needed). Contract tests for mirrored and bundled files, pack-manifest completeness, and dependency closure for the new helper module must pass. Enforcement hooks still do not invoke Python.

Out of scope: no relaxation of any gate's intent (the budget cap stays as strict as today; only the checkpoint and root evaluated change); no change to worktree-isolation behavior or checkpoint schemas.

- Regression tests to add or update:
  - New: `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1` (resolver behavior, helpers, reason-code equality, default-invoker AST check).
  - New: `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` (twin parity by function name and `Extent.Text`, behavior rows on Linux).
  - New: `tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1`, `tests/scripts/claude-hooks/enforce-powershell-batch-budget.TargetWorktree.Tests.ps1`, `tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1` (hook rows with injected porcelain invoker and in-memory checkpoint and state seams).
  - Updated: `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` (`$script:ExpectedPaths` and the three `-ForEach` lists), `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`$script:SharedModuleNames`).
  - Unchanged and must pass: the ten existing `*batch-budget*` suites in `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`.
  - Python contract tests: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py`, the pack-manifest completeness tests, and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`.
- Unit tests (Pester) for the fixed behavior and boundaries: see Acceptance Criteria; all hook rows inject `-WorktreeListInvoker` returning porcelain for `/repo`, `/repo/.claude/worktrees/item`, and `/repo-wt/sibling`.
- Edge cases and negative scenarios: relative paths; path outside every worktree; nested worktree; sibling worktree; case-variant and backslash inputs; throwing and empty invoker; `bare`, `detached`, `prunable` stanzas; CRLF porcelain; branch with zero, one, multiple matches; identity with and without reader; disagreement; nested non-root `artifacts` directory; Codex `apply_patch` move with source and destination in different worktrees.
- Error handling and logging verification: module load failure denies (B-row auto-discovered); route-helper import failure still denies before any invoker call.
- Coverage impact and targets for changed lines/modules: line coverage at or above the repository threshold (85% default) for `HookTargetWorktree.psm1` and `hook-target-worktree.ps1` read from `artifacts/pester/powershell-coverage.xml`; no regression on changed hook lines. PowerShell has no branch-coverage gate. The default-invoker body is kept minimal.
- Toolchain commands to run (format → lint → type-check → test): PoshQC format (`Invoke-Formatter`), PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`, type check skipped for PowerShell, architecture tests, Pester via `Invoke-PoshQCTest`, contract pytest modules, integration tests; repeat until one clean pass. Run `scripts/dev_tools/generate_codex_agent_variants.py --check` after editing Codex `core.json`.
- Manual validation steps (if required): optional live check by a non-isolated delegation from the item worktree; not required for acceptance.
- Isolation evidence: seeded shuffled file-order run of the touched Pester suites in one process (seed count per the brief's `## Test Isolation Checks`) and a fresh single-process run over `tests/scripts`.


## Acceptance Criteria
Resolver module (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`):
- [x] `HookTargetWorktree.psm1` exists, sets `Set-StrictMode -Version Latest`, imports no module, references no module-scope `$script:` state from its functions, and exports exactly `Resolve-HookTargetWorktree`, `ConvertFrom-HookTargetWorktreePorcelain`, `Get-HookTargetWorktreeEnclosingRoot`, `ConvertTo-HookTargetWorktreeNormalizedPath`, `Get-HookTargetWorktreeRelativePath`, and `Get-HookTargetWorktreeKey` through an explicit `Export-ModuleMember`.
- [x] `Resolve-HookTargetWorktree` has the parameters `-SessionRoot` (mandatory), `-FilePath`, `-CommandOperandPath`, `-CommandBranch`, `-DelegationPrompt`, `-CheckpointIssueReader`, and `-WorktreeListInvoker`, and returns an object with `WorktreeRoot`, `Source`, `Ambiguous`, `ReasonCode`, `Detail`, and `Candidates` whose values stay within the domains in the contract section; verified by rows in `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1`.
- [x] Strict precedence is verified: the first present source among FilePath, CommandOperand, DelegationIdentity, SessionRoot decides and later sources are not consulted; with no source present the result is the session root with `Source = SessionRoot` and the invoker is not called.
- [x] An absolute file path resolves to the nearest enclosing registered worktree by longest normalized root prefix, verified for a nested worktree (`/repo/.claude/worktrees/item` inside `/repo`), a sibling worktree (`/repo-wt/sibling`), and the main worktree.
- [x] A relative file path resolves to the session root without calling the invoker (asserted by an invoker that records or fails on invocation).
- [x] A path inside no registered worktree, an invoker that throws, and an invoker that returns empty text each yield `WorktreeRoot = SessionRoot`, `Source = SessionRoot`, `Ambiguous = $false`, and a non-empty `Detail`.
- [x] Ambiguity and not-derivable rows pass: disagreeing file paths, a branch matching more than one worktree, a path/branch disagreement, multiple distinct issue numbers, and a branch/issue disagreement each return `Ambiguous = $true` with `TARGET_WORKTREE_AMBIGUOUS`; a branch matching no worktree and an issue-only prompt without `-CheckpointIssueReader` each return `TARGET_WORKTREE_NOT_DERIVABLE`; a present identity that names no worktree never falls back to the session root.
- [x] A test asserts that the resolver's `TARGET_WORKTREE_AMBIGUOUS` and `TARGET_WORKTREE_NOT_DERIVABLE` literals equal `Get-WorktreeResolutionAmbiguityReasonCode` and `Get-WorktreeResolutionNoTargetReasonCode`.
- [x] Normalization and `OrdinalIgnoreCase` comparison are verified with backslash, repeated-slash, trailing-slash, drive-rooted forward-slash, and case-variant inputs, producing the same result regardless of platform.
- [x] `ConvertFrom-HookTargetWorktreePorcelain` rows cover the main stanza, linked stanzas, a skipped `bare` stanza, a `detached` stanza, a `prunable` stanza, blank lines, and CRLF line endings supplied in memory.
- [x] `Get-HookTargetWorktreeKey` produces `<sanitized leaf>-<8 hex of SHA-256 of normalized root>` and a test pins equality with the existing worktree-derived batch-budget session-id algorithm for the same root.
- [x] The resolver performs no file, environment, or clock read: a test asserts (by AST inspection) that the module contains no file-reading, environment-reading, or clock cmdlet or .NET call outside the default invoker body, and that the default invoker body runs `git -C <SessionRoot> worktree list --porcelain` with no timeout and returns an empty string on non-zero exit, without spawning git.

Codex twin (`.codex/hooks/hook-target-worktree.ps1`):
- [x] `.codex/hooks/hook-target-worktree.ps1` exists as a functions-only file whose function names and each function's `Extent.Text` equal those of `HookTargetWorktree.psm1`, verified by `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`, which also runs resolver behavior rows on the Linux hook-suite job.
- [x] `hook-target-worktree.ps1` is added to `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and that suite passes (parse, line limit, bundle byte identity, core-manifest membership).

Claude batch-budget hooks:
- [x] Both `.claude/hooks/enforce-python-batch-budget.ps1` and `.claude/hooks/enforce-powershell-batch-budget.ps1` import `HookTargetWorktree.psm1` with the standard one-statement guarded `Import-Module ... -ErrorAction Stop` form; `hook-dependency-guard-completeness.Tests.ps1` passes; the auto-discovered row in `hook-dependency-failure.Claude.Tests.ps1` shows a module load failure denies at exit 0 naming `HookTargetWorktree.psm1`; `HookImportFailureExemptions.Helpers.ps1` gains no entry.
- [x] Repro fixed: with a session root that has no checkpoint and an item worktree whose checkpoint selects `large`, `remediation`, or `preparation` and is non-terminal, an absolute-path edit of a further distinct production file in the item worktree beyond the direct-mode cap is allowed; verified in `enforce-python-batch-budget.TargetWorktree.Tests.ps1` and `enforce-powershell-batch-budget.TargetWorktree.Tests.ps1`, including a row asserting the checkpoint path read is under the item worktree root.
- [x] An item worktree with no checkpoint (or a terminal or non-large route) remains capped: the first edit beyond the cap in that worktree is denied with the unchanged `PYTHON_LARGE_PATH_REQUIRED` or `POWERSHELL_LARGE_PATH_REQUIRED` reason text.
- [x] Budget state is keyed per resolved worktree root: edits in distinct worktrees in one session fill independent counters; the state file for a non-session-root worktree is `<kind>-batch-budget.<sessionId>.<worktreeKey>.json` under the session root `.claude/state/`; the session-root state file name is unchanged; no state is written under any other worktree; containment and the rehydrate filter use the resolved root.
- [x] Paths under the resolved worktree's root-level `artifacts/` directory (absolute, and relative paths beginning `artifacts/`) are allowed without consuming a slot or writing state, for both `.py` and `.ps1`; a production file under a nested directory named `artifacts` elsewhere in the tree still counts.
- [x] A file outside every registered worktree keeps today's behavior: the session root is used for checkpoint, containment, and state-file name, and the existing decision-level containment discards it.
- [x] Claude edits to a sibling-directory registered worktree are counted against that worktree's own budget (intended tightening), covered by a test row and stated in the brief.
- [x] Ordering is preserved: a missing `file_path` or a non-matching extension allows without invoking the resolver, the invoker, the checkpoint reader, or state I/O; a route-helper import failure denies an in-scope path before any invoker call; `enforce-batch-budget.RouteImportFailure.Tests.ps1` passes unchanged.
- [x] The cap is as strict as today: the `-ProdCap` default, test-file classification rules, reason codes and text, and deny-only output of both Claude hooks are unchanged, and an `Ambiguous` or `$null` resolver result falls back to the session root.

Codex batch-budget hooks:
- [x] Both `.codex/hooks/enforce-python-batch-budget.ps1` and `.codex/hooks/enforce-powershell-batch-budget.ps1` dot-source `hook-target-worktree.ps1` through a guarded `try`/`Add-HookDependencyFailure` statement, and the auto-discovered row in `hook-dependency-failure.Codex.Tests.ps1` passes.
- [x] `tests/scripts/codex-hooks/codex-batch-budget.TargetWorktree.Tests.ps1` passes for both Codex hooks with rows for: item checkpoint uncapped; item worktree without checkpoint capped; independent per-worktree counters with worktree-keyed state under the session root `.codex/state/`; root-level `artifacts/` paths not counted; a session-root file with the unchanged state-file name; a path outside every registered worktree counted as today (no containment added); and an `apply_patch` move whose `source_path` and `file_path` resolve to different worktrees, each evaluated against its own root.

Existing suites and unchanged files:
- [x] The existing suites pass without edits: `enforce-python-batch-budget.Tests.ps1`, `enforce-powershell-batch-budget.Tests.ps1`, `enforce-python-batch-budget-routing.Tests.ps1`, `enforce-powershell-batch-budget-routing.Tests.ps1`, `enforce-batch-budget.RouteImportFailure.Tests.ps1` (under `tests/scripts/claude-hooks/`), and `codex-batch-budget-hooks.Tests.ps1`, `codex-python-batch-budget-routing.Tests.ps1`, `codex-powershell-batch-budget-routing.Tests.ps1`, `codex-batch-budget.RouteImportFailure.Tests.ps1`, `codex-batch-budget-route-parity.Tests.ps1` (under `tests/scripts/codex-hooks/`), plus `PreToolUseSchema.Contract.Tests.ps1`.
- [x] `enforce-batch-budget-route.ps1` is unchanged in `.claude/hooks/`, `.codex/hooks/`, and the Claude bundled copy, and the #1010 and #1011 consumer files listed under Scope & Non-Goals, `enforce-model-routing-receipt.ps1`, `.claude/settings.json`, `.codex/config.toml`, the Claude `python.json` and `powershell.json` manifests, and checkpoint schemas are unchanged in the diff.

Mirrors, manifests, and contracts:
- [x] The bundled copies of `HookTargetWorktree.psm1`, `hook-target-worktree.ps1`, and each edited batch-budget hook are byte-identical to their sources, and `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass.
- [x] Claude `pack-manifests/core.json` lists `HookTargetWorktree.psm1` next to the other `worktree-resolution` entries and Codex `pack-manifests/core.json` lists `hook-target-worktree.ps1`; the pack-manifest completeness tests, `test_push_down_pack_manifest_dependency_closure.py`, and `scripts/dev_tools/generate_codex_agent_variants.py --check` pass.
- [x] `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` lists `HookTargetWorktree.psm1` in `$script:ExpectedPaths` and in each of its per-module `-ForEach` lists (core-membership, bundle-hash, and on-disk registration rows), and passes.

Documentation:
- [x] Every execution-environment brief copy listed under "Files/modules to change" (the `.claude/`, `.agents/`, and `.github/` runtime copies and their bundled copies under `extensions/drm-copilot/resources/`) is updated identically: `## Batch Budget` states that the exemption checkpoint is read from the worktree containing the edited file as resolved by `Resolve-HookTargetWorktree` (session root for relative paths or paths in no registered worktree), that state is per session and per resolved worktree root under the session root, that root-level `artifacts/` paths never count, and the sibling-worktree consequence; `## Hook Execution Context` states that the batch-budget hooks evaluate the resolved target worktree's checkpoint and that the other gates are unchanged until #1010 and #1011; `## Preflight Defect Classes the Validator Cannot See` scopes batch-budget exhaustion to one worktree.
- [x] `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` passes, including `test_brief_copies_are_byte_identical` and every phrase pinned by `test_brief_batch_budget_section_states_cap_codes_and_exemptions` (or that test is updated in the same change to the new wording).
- [x] `## Command-Text Restrictions` is reviewed and left unchanged, and the plan or evidence records the reason (the batch-budget hooks see only `Write` and `Edit`; Bash-operand resolution is first consumed by #1010 and #1011).
- [x] `.claude/rules/orchestrator-state.md` and its bundled copy gain an identical statement under `## Enforcement` that the batch-budget hooks read the checkpoint of the resolved target worktree, so a coordinating session never needs a checkpoint at its own root for them.
- [x] The `.DESCRIPTION` help of each edited batch-budget hook (Claude and Codex, Python and PowerShell) no longer states that the checkpoint and state are taken from the hook-script root, and documents the resolved-root behavior and the 8.3 short-name and junction limitation.

Non-functional gates:
- [x] No enforcement hook invokes Python: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes.
- [x] Line coverage for `HookTargetWorktree.psm1` and `hook-target-worktree.ps1`, read from `artifacts/pester/powershell-coverage.xml`, meets the repository line threshold, and changed hook lines do not regress coverage.
- [x] File-size limits hold: the Codex hooks and the Codex twin stay within the limit pinned by `legacy-codex-hook-contracts.Tests.ps1`, and no edited or created file reaches the 801-line hard block.
- [x] The full toolchain loop (format, lint, type-check skip for PowerShell, architecture, Pester, contract, integration) completes in one clean pass, and the isolation checks (seeded shuffled file-order run with the brief's required seed count and a fresh single-process run over `tests/scripts`) pass.
- [x] Evidence artifacts are written under `<FEATURE>/evidence/<kind>/` with write-time UTC stamps, no absolute paths, and pass/fail counts taken from `artifacts/pester/pester-junit.xml`.

## Risks & Mitigations
- Technical or operational risks:
  - Restated reason-code literals could drift from `WorktreeResolution.psm1`. Mitigation: equality test.
  - The sibling-worktree tightening could be read as an unrequested behavior change. Mitigation: stated in this spec and the brief, with a dedicated test row.
  - Default-invoker lines are host-bound and lower module coverage. Mitigation: one or two statements, AST assertion, all other functions covered with injected porcelain.
  - Mirror drift across four parity surfaces (module/bundle, twin/bundle, twin/module function text, hooks/bundles), six brief copies, and the rule file bundle. Mitigation: copy after the last edit, then run both resource-contract tests, manifest tests, dependency closure, and the generator `--check`.
  - Test leakage from `-Force` imports or `$PSDefaultParameterValues`. Mitigation: inject seams through parameters, clean up in `AfterAll`, seeded shuffled runs.
  - Linux-only failures from case or separator differences. Mitigation: slash-rooted synthetic paths and unconditional `OrdinalIgnoreCase`.
  - A module load failure blocks every in-scope Write and Edit (R4, fail closed). Mitigation: the module has no imports; load is covered by the dependency-failure suites.
  - An unbounded git call could stall a hook if git hangs (R3). Accepted; git is invoked only for absolute in-scope paths.
- Mitigations and rollbacks: revert the change set; session-root state files keep their names, so no state cleanup is needed.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; branch hooks take effect for isolated subagents only after merge; the push-down payload changes after the next extension rebuild and release.
- Post-fix monitoring or clean-up tasks: #1010 and #1011 adopt `Resolve-HookTargetWorktree` unchanged; worktree-keyed state files under `.claude/state/` accumulate per session as today (no automatic reset).
- Links: issue #1009 (https://github.com/drmoisan/drm-copilot/issues/1009); sibling issues #1010, #1011; research `research/research.2026-10-30T12-12.md`.
