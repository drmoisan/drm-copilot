# Research: batch-budget hooks resolve the target worktree (Issue #1009)

- Issue: #1009 (work mode `full-bug`), branch `bug/batch-budget-hooks-coordinator-root-1009`
- Parallel run: bugs-1001-1002-1003-1006, preparation mode
- Inputs read: `issue.md` and `spec.md` in this feature folder, `.claude/skills/execution-environment/SKILL.md` (item-worktree copy), and every source file cited below.
- Scope (operator decision): create `Resolve-HookTargetWorktree` in `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` with tests and Codex and bundled counterparts, and apply it only to the batch-budget hooks. Sibling items #1010 (preimplementation gate) and #1011 (pr-author gate) consume it later and are not planned here.
- Tool limits: this research ran with Read, Grep, Glob, and Write only. No `git`, `gh`, hash, or Pester command was run. Facts that need one of those are marked **ORCHESTRATOR TO CONFIRM**.

## 1. Current behavior of the batch-budget hooks

### 1.1 Claude hooks

The two hooks, `.claude/hooks/enforce-python-batch-budget.ps1` and `.claude/hooks/enforce-powershell-batch-budget.ps1`, have the same structure. Only the function-name prefix (`Python` or `PowerShell`), the extension filter, the test-file rule, and the reason code differ.

- **Registration.** `.claude/settings.json` registers each hook under the `PreToolUse` matcher `Write|Edit` as `pwsh -NoProfile -File .claude/hooks/<hook>.ps1`. The script path is relative, so it resolves against the hook process's working directory, which is the session's project directory.
- **Imports.** Each hook:
  - dot-sources `hook-dependency-guard.ps1` inside the bootstrap `try`;
  - imports `../lib/hook-payload/HookPayload.psm1` inside a guarded single-statement `try`;
  - dot-sources `enforce-batch-budget-route.ps1` into the handler variable `$script:PythonBatchBudgetRouteImportFailure` or `$script:PowerShellBatchBudgetRouteImportFailure`.
- **Repository root.** Each of `Invoke-*BatchBudgetHook`, `Invoke-*BatchBudgetDecision`, and `ConvertTo-*BatchBudgetState` has a `-Root` parameter whose default is `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`. That is the checkout that holds the hook script, which in a coordinating session is the coordinator root. No call reads the `cwd` field of the payload, and none calls `Get-Location`.
- **Payload fields read.**
  - `Invoke-*BatchBudgetHook` calls `Resolve-ClaudeHookToolInput` and then reads only `tool_input.file_path` through `Get-ClaudeHookToolInputString -Name 'file_path'`.
  - The envelope's `session_id` and `cwd` are never read.
  - `Invoke-*BatchBudgetEntryPoint` reads `$env:CLAUDE_SESSION_ID` and passes it as `-SessionId`.
- **Order of evaluation in `Invoke-*BatchBudgetHook`.**
  1. An envelope anomaly denies.
  2. No `file_path` allows.
  3. A path with a non-matching extension allows (`\.py$`; `\.(ps1|psm1|psd1)$`).
  4. A route-helper import failure denies, naming `enforce-batch-budget-route.ps1`.
  5. The state directory and the session id are resolved.
  6. The checkpoint is read.
  7. On the large path, the decision is made with `-LargePathRoute` and no state I/O.
  8. Otherwise the state directory is ensured, state is loaded and filtered, the decision is made, and state is written.
- **Checkpoint.**
  - The path is `Join-Path $Root 'artifacts/orchestration/orchestrator-state.json'`, read through the `-ReadCheckpoint` seam.
  - `Test-BatchBudgetLargePathRoute` and `Get-BatchBudgetSelectedRoute` come from the route helper.
  - An unreadable checkpoint is treated as direct mode.
- **State key and location.**
  - The state directory is `Join-Path $Root '.claude/state'`.
  - The file name is `python-batch-budget.<sessionId>.json` or `powershell-batch-budget.<sessionId>.json`.
  - `Get-*BatchBudgetSessionId` takes the first non-empty of: the `-SessionId` argument, `$env:CLAUDE_SESSION_ID`, the text of `<Root>/.claude/state/current-session-id` (read through the `-ReadSessionIdFile` seam), and `worktree-<leaf>-<8 hex of SHA-256 of normalized Root>`. The result is sanitized by `ConvertTo-*BatchBudgetSafeSegment`.
  - The session-id file is written by `.claude/hooks/persist-session-id.ps1` at `(Get-Location).Path/.claude/state/current-session-id`.
- **Containment.**
  - `Test-*BatchBudgetPathInRoot` normalizes separators to `/` and compares with `OrdinalIgnoreCase`. It admits every relative path and every absolute path equal to or under `Root`.
  - `Invoke-*BatchBudgetDecision` discards an out-of-root candidate (allow, `shouldWriteState = $false`) before the large-path check.
  - `ConvertTo-*BatchBudgetState` drops persisted `prodFiles` entries that fail containment.
- **Production versus test classification** (in `Invoke-*BatchBudgetDecision`):
  - Python: a path is a test file when it matches `(^|/)tests/.*\.py$` or `(^|/)test_[^/]+\.py$`.
  - PowerShell: a path is a test file when it matches `(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$`. A `.psm1` or `.psd1` under `tests/` therefore counts as production.
  - Every other in-extension path is production. Counted paths are deduplicated with `-contains`, which is case-insensitive.
  - The cap is `$State.prodCap`, which the hook default sets to 3 (`-ProdCap 3`). The fourth distinct path is denied with `PYTHON_LARGE_PATH_REQUIRED:` or `POWERSHELL_LARGE_PATH_REQUIRED:`.
- **`artifacts/` exclusion: none.** No rule excludes `artifacts/`. A `.py` or `.ps1` under `<root>/artifacts/` is a production file today. This was confirmed by reading both decision functions in both runtimes.

### 1.2 Route helper

`.claude/hooks/enforce-batch-budget-route.ps1` (139 lines) has no entry point and is pure. It defines exactly:

- `ConvertFrom-BatchBudgetCheckpoint`
- `Get-BatchBudgetSelectedRoute`: `route_id` when present, otherwise `path_selected`, and only when the value is a non-blank string.
- `Test-BatchBudgetLargePathRoute`: true for `large`, `remediation`, or `preparation` (case-sensitive) when `next_step` is not `complete` and `completed_steps` does not contain `S12_complete`.

The helper reads no file and does not touch the root. The test `codex-batch-budget-route-parity.Tests.ps1` asserts that the file defines exactly these three function names. **Recommendation:** leave the route helper unchanged.

### 1.3 Codex hooks

`.codex/hooks/enforce-python-batch-budget.ps1` (351 lines; line 1 is blank) and `.codex/hooks/enforce-powershell-batch-budget.ps1` (348 lines) differ structurally from the Claude hooks. They are not byte-identical to them.

- **Registration.** `.codex/config.toml` runs `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<hook>.ps1"`. The root is therefore the session working directory's top level, and the same defect applies.
- **Imports.** Each hook dot-sources `hook-dependency-guard.ps1` and `codex-pretooluse-file-mapping.ps1` (guarded) and `enforce-batch-budget-route.ps1` (handler variable).
- **Root.** `Invoke-*BatchBudgetHook -Root` defaults to `(Get-Location).Path`. `Invoke-*BatchBudgetCodexEntryPoint` passes `-RepositoryRoot (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)`.
- **Session id.**
  - The id is the payload `session_id`, which `ConvertFrom-CodexPreToolUsePayload -RequireSessionId` makes mandatory and which is then sanitized.
  - The state file is `<Root>/.codex/state/<kind>-batch-budget.<sessionId>.json`.
  - Paths come from `ConvertTo-CodexFileEditInput`: both `source_path` and `file_path` of each mapped edit, so both sides of an `apply_patch` move are evaluated.
- **No containment.** The Codex `Invoke-*BatchBudgetDecision` has no `-Root` parameter, and `ConvertTo-*BatchBudgetState` has no filter. A path outside the root, such as a scratch file, counts today in Codex but is discarded in Claude. The brief's sentence "Files under `SCRATCH` ... are discarded" is accurate for Claude only.
- **Classification.** The production and test rules are the same as in Claude. There is no `artifacts/` exclusion.

### 1.4 Behavioral consequence

In a coordinating session, the root, the checkpoint, and the state directory all come from the coordinator checkout. Files in an item worktree are handled as follows:

- **Item worktree nested under the coordinator checkout** (this repository places agent worktrees under `.claude/worktrees/<name>`): the files pass containment and are counted against the coordinator's single per-session counter, under the coordinator's checkpoint. This is the defect.
- **Item worktree in a sibling directory** (for example `drm-copilot-wt/<stamp>`): the files fail containment and are discarded in Claude. They are counted against the coordinator in Codex.

After the fix, sibling-worktree files in Claude become counted against that worktree's own budget, unless that worktree's checkpoint selects an uncapped route. This tightens behavior for direct-mode edits to sibling worktrees. The plan must state it as an intended consequence of "budget state is keyed per resolved worktree root".

## 2. Mirror inventory

Line counts were taken with a whole-file line match (Grep `^` count). The counts are equal within each pair. Byte identity was not hashed by this researcher.

| Canonical file | Mirror(s) | Lines (canonical / mirror) | Pinning tests |
|---|---|---|---|
| `.claude/hooks/enforce-python-batch-budget.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1` | 496 / 496 | `test_push_down_claude_resource_contracts.py` (bundle text equality); `enforce-batch-budget.RouteImportFailure.Tests.ps1` (runs every row against the repository copy and the mirror) |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | 493 / 493 | same as above |
| `.claude/hooks/enforce-batch-budget-route.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-batch-budget-route.ps1`; `.codex/hooks/enforce-batch-budget-route.ps1` | 139 / 139 / 139 | `codex-batch-budget-route-parity.Tests.ps1` (Claude and Codex byte-identical; exactly three functions); resource-contract tests |
| `.codex/hooks/enforce-python-batch-budget.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1` | 351 / 351 | `test_push_down_codex_and_agents_resource_contracts.py`; `legacy-codex-hook-contracts.Tests.ps1` ("keeps the canonical hooks byte-identical to their bundled copies"; "keeps every file within 500 lines") |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1` | 348 / 348 | same as above |
| `.codex/hooks/enforce-batch-budget-route.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-batch-budget-route.ps1` | 139 / 139 | same, plus the route-parity suite |

**ORCHESTRATOR TO CONFIRM:** byte identity of each pair through `Get-FileHash` or the two resource-contract pytest modules. CI on `main` enforces these tests, so the pairs are expected to be identical.

Pack manifests that currently list these files:

- Claude `core.json` lists all three hooks.
- Claude `python.json` lists `enforce-python-batch-budget.ps1`.
- Claude `powershell.json` lists `enforce-powershell-batch-budget.ps1`.
- Codex `core.json` lists all three `.codex/hooks` files.

## 3. Existing worktree-resolution code and the recommended resolver contract

### 3.1 What already exists

Issues #669, #673, #687, #690, and #738 left a filesystem-based resolver family in `.claude/lib/worktree-resolution/`.

**`WorktreeResolution.psm1`.**

- Seams: `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, `Get-WorktreeResolutionDirectoryChildName`.
- Path functions: `ConvertTo-WorktreeResolutionNormalizedPath`, and `Find-WorktreeResolutionRoot`, which ascends to the nearest `.git` marker.
- `Get-WorktreeResolutionWorktreeRoot` enumerates registered worktrees by reading `<common .git>/worktrees/*/gitdir`. It starts no process.
- Reason-code accessors: `Get-WorktreeResolutionAmbiguityReasonCode` returns `TARGET_WORKTREE_AMBIGUOUS`, and `Get-WorktreeResolutionNoTargetReasonCode` returns `TARGET_WORKTREE_NOT_DERIVABLE`.

**`WorktreeTargetResolution.psm1`.**

- `Resolve-WorktreeCallTarget` returns a four-state result (`SessionRoot`, `OtherWorktree`, `NoTarget`, `Ambiguous`) with `WorktreeRoot`, `Signal`, `Candidates`, `ReasonCode`, and `Detail`.
- `Find-WorktreeResolutionBranchSignal` reads `--head`, `--branch`, and `branch:`.

**`WorktreeItemResolution.psm1`.**

- `Resolve-WorktreeItemTarget` resolves portable identity: the canonical issue line `Canonical issue number for this feature is #?N` plus a branch signal. It reads each live worktree's checkpoint `issue-num` through `Get-WorktreeItemCheckpointText`.
- `Get-WorktreeItemLiveRoot` returns the registered roots that still carry a marker.

**`WorktreeRunResolution.psm1`.**

- `Resolve-WorktreeOperandTarget -Path -SessionRoot` places a `file_path` or `git -C` operand by marker ascent.
- A blank operand, or an operand in no worktree, falls back to the session worktree.
- A relative operand is joined to the session root.

### 3.2 Current consumers and their seams

| Consumer | Resolution call | Session root | Test seam |
|---|---|---|---|
| Preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`) | `Resolve-OrchestrationGateTarget`: epic or parallel identity, then `Resolve-WorktreeOperandTarget` for `-FilePath` or for the `git -C` value from `Get-OrchestrationEpicScopeSelector`, otherwise `Resolve-WorktreeItemTarget -Text $Prompt`. `Read-OrchestrationGateCheckpoint` turns `NoTarget` or `Ambiguous` into `PREIMPLEMENTATION_GATE_BLOCKED: <ReasonCode>: ...`. | `(Get-Location).Path` | Mocks of the module seams and the checkpoint readers `Get-CheckpointContent`, `Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent` |
| Preimplementation targets (`...-gate-targets.ps1`) | `Get-OrchestrationCommandTarget`, which is pure: rules R0 to R7. `Get-OrchestrationGitSelectorTarget` walks git global options through `Get-CommandLineGlobalOption -CommandWord 'git'` and rejects a relative, backslash, or dot-segment `-C` value. A relative path leg maps to the session root. | `-SessionRoot` argument | None needed (pure) |
| Model-routing gate (`.claude/hooks/enforce-model-routing-receipt.ps1`) | `Resolve-ModelRoutingWorktreeTarget` wraps `Resolve-WorktreeItemTarget -Text $PromptText`. | `(Get-Location).Path` | Tests mock the hook-local wrapper (documented in its help) |
| pr-author gate (`.claude/hooks/enforce-pr-author-skill-helpers.ps1`) | `Resolve-PrAuthorWorktreeTarget` wraps `Resolve-WorktreeItemTarget -Text $CommandText`, then `Resolve-PrAuthorCurrentBranchTarget`. `--body-file` is bound by `Get-PrAuthorBodyPathBindingReason` in `enforce-pr-author-skill.artifact-root.ps1`, which denies `PR_BODY_PATH_NONCANONICAL` and asks for the absolute canonical path when the target is not the session worktree. | `(Get-Location).Path` | Mock the wrapper; git through `Invoke-PrAuthorCurrentBranchGitExe -GitInvoker` and `Invoke-PrAuthorDocsOnlyGitExe -GitInvoker` |
| Codex preimplementation gate (`.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`) | A Codex-local port of the `WorktreeResolution` functions (functions only, dot-sourced). | `(Get-Location).ProviderPath` | Mocks of the ported seams |

**Git-invoker convention.**

- A `[scriptblock] $GitInvoker = { git @args 2>$null }` parameter is used in `enforce-pr-author-skill.current-branch.ps1`, `enforce-pr-author-skill.docs-only.ps1`, and `validate-orchestrator-output-feature-folder.ps1`.
- A bounded variant, `Invoke-DocsOnlyBoundedNative -FileName 'git' ... -TimeoutMilliseconds 3000`, is used in `.claude/hooks/hook-docs-only-diff.ps1`.
- `.claude/hooks/check-powershell-test-purity.ps1` forbids `Mock git` in Pester tests, so a seam is mandatory.
- No hook or lib file runs `git worktree list --porcelain` today. Only the cleanup bash library and the orchestration skill prose use it.

### 3.3 Candidate approaches

**A. Porcelain-backed pure resolver (recommended).**

- A new self-contained module, `HookTargetWorktree.psm1`, enumerates registered worktrees only through an injected invoker. The default invoker runs `git -C <SessionRoot> worktree list --porcelain`.
- The module parses the porcelain text with pure functions, selects the nearest enclosing registered root by the longest normalized prefix, and reads no file.
- Advantages:
  - It matches the issue record and the operator scope.
  - The registered set is git's own answer, so an unregistered nested clone or a submodule `.git` file is not mistaken for a worktree. The marker ascent in `Find-WorktreeResolutionRoot` accepts any `.git` marker.
  - Tests inject porcelain text and need no filesystem mocks.
  - A Codex twin can be text-identical because nothing is imported.
- Limitations:
  - One `git` process per in-scope Write or Edit. This is mitigated by invoking it only after the extension filter and only for absolute paths.
  - The two reason-code literals are restated. A precedent exists in `validate-orchestrator-output-resolution.ps1`, which restates both literals with an equality comment; a test pins equality with the accessors.

**B. Reuse `Resolve-WorktreeOperandTarget` (rejected).**

This approach has no subprocess and is already used by the preimplementation gate, but it was rejected for three reasons:

- It reads files: the `.git` marker ascent and the `gitdir` and `commondir` reads. That contradicts "never reads files itself".
- It returns the nearest marker rather than the nearest registered worktree.
- Its result shape (four statuses) is not the `{ WorktreeRoot, Source, Ambiguous }` contract #1010 and #1011 are to consume.

**C. Inline resolution in each hook (rejected).** It duplicates logic across four hooks and pushes the Claude hooks well past the 500-line guidance tier.

### 3.4 Recommended public contract

The module file is `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`.

- **No imports.** The file is PowerShell 7+, sets `Set-StrictMode -Version Latest`, and uses an explicit `Export-ModuleMember`.
- **No module-scope `$script:` state referenced by functions.** Constants live inside the functions, so the Codex twin's function text can be byte-compared.
- **No file read, no environment read, no clock read.** The only I/O is the default invoker body.

Proposed signature:

```
Resolve-HookTargetWorktree
    -SessionRoot <string>                  # Mandatory; absolute; the caller's root (hook -Root)
    [-FilePath <string[]>]                 # Source 1: file-tool targets (Write/Edit/MultiEdit/NotebookEdit file_path; Codex source_path and file_path)
    [-CommandOperandPath <string[]>]       # Source 2a: Bash operand paths already parsed by the caller (git -C value, --body-file value, absolute file arguments)
    [-CommandBranch <string>]              # Source 2b: Bash branch operand already parsed by the caller (gh pr create --head value)
    [-DelegationPrompt <string>]           # Source 3: Agent(...) prompt text; reads the 'branch:' label and the canonical issue line
    [-CheckpointIssueReader <scriptblock>] # Optional, Source 3 only: { param($WorktreeRoot) <issue number or $null> }; caller-owned I/O
    [-WorktreeListInvoker <scriptblock>]   # { param($SessionRoot) <porcelain text> }; default runs git -C $SessionRoot worktree list --porcelain
```

The result is a `[pscustomobject]` with:

- `WorktreeRoot` (string or `$null`): the normalized forward-slash root.
- `Source`: one of `FilePath`, `CommandOperand`, `DelegationIdentity`, or `SessionRoot`.
- `Ambiguous` (bool).
- Additive fields, recommended so the gates in #1010 and #1011 can compose deny reasons the way existing gates do from `.ReasonCode` and `.Detail`:
  - `ReasonCode`: `$null`, `TARGET_WORKTREE_AMBIGUOUS`, or `TARGET_WORKTREE_NOT_DERIVABLE`.
  - `Detail`: one prose clause.
  - `Candidates`: a string array.

**Precedence.** Exactly one source decides: the first present source in the order 1, 2, 3, 4. A source is present when it carries a non-blank value. Rules for each source:

- **No source present.** `WorktreeRoot = SessionRoot`, `Source = SessionRoot`, and the invoker is not called.
- **FilePath (source 1).**
  - Each absolute path maps to its nearest enclosing registered worktree. "Nearest" means the longest registered root R such that the path equals R or starts with `R/`.
  - All paths agree: that root is the result.
  - Paths disagree: `Ambiguous = $true` with `TARGET_WORKTREE_AMBIGUOUS`.
  - A path inside no registered worktree, or a failed invoker: the session root is used with `Source = SessionRoot` and a Detail naming the reason. This matches the "outside every registered worktree keeps today's behavior" requirement and matches `Resolve-WorktreeOperandTarget`.
  - A relative path maps to the session root without calling the invoker. This matches `Get-OrchestrationCommandTarget`, where a relative path leg maps to the session root. Claude Write and Edit always supply absolute paths. This keeps every existing batch-budget suite, which all use relative paths, process-free and unchanged.
- **CommandOperand (source 2).** Operand paths follow the FilePath rules. A branch matches the porcelain `branch refs/heads/<name>` line:
  - zero matches: `TARGET_WORKTREE_NOT_DERIVABLE`;
  - one match: that root;
  - more than one match: `TARGET_WORKTREE_AMBIGUOUS`.

  When both paths and a branch are present and they disagree, the result is Ambiguous. Command parsing stays with the caller (`hook-command-invocation.ps1`, `Get-OrchestrationGitSelectorTarget`, `Get-PrAuthorBodyFileValue`), so the resolver does not duplicate a parser.
- **DelegationIdentity (source 3).**
  - The branch label (reuse the regex shape of `Find-WorktreeResolutionBranchSignal`) resolves through porcelain branch lines.
  - The canonical issue line resolves only through `-CheckpointIssueReader`. Without a reader, an issue-only prompt is `NOT_DERIVABLE`.
  - Several issue numbers are `AMBIGUOUS`.
  - Agreement and disagreement follow `Resolve-WorktreeItemTarget`: a branch is authoritative, and a disagreeing issue is Ambiguous.
  - The session root is never a fallback for a present identity that names no worktree.
- **SessionRoot (source 4).** This source applies only when no other source is present.

**Exported pure helpers.** These are useful to #1010 and #1011 and testable without a process:

- `ConvertFrom-HookTargetWorktreePorcelain`: text in, records out with `Root`, `Branch`, `Bare`, `Prunable`. `bare` stanzas are skipped.
- `Get-HookTargetWorktreeEnclosingRoot`
- `ConvertTo-HookTargetWorktreeNormalizedPath`
- `Get-HookTargetWorktreeRelativePath`: returns the path relative to a root, or `$null` when the path is outside it.
- `Get-HookTargetWorktreeKey`: `<sanitized leaf>-<8 hex of SHA-256 of normalized root>`, the same algorithm as the existing worktree-derived session id.

**Default invoker.** Its body is `& git -C $SessionRoot worktree list --porcelain 2>$null`, and a non-zero `$LASTEXITCODE` yields an empty string. The resolver treats a thrown or empty result as no registered worktrees. The plan should state whether to bound the invoker with a timeout, as `Invoke-DocsOnlyBoundedNative` does. A lib module cannot import that hook helper, so a bound would need its own small implementation inside the module, or none.

**Path comparison (Windows and Linux).**

- Normalize `\` to `/`, collapse repeated `/`, and trim a trailing `/` except from a bare root.
- Compare with `[System.StringComparison]::OrdinalIgnoreCase` unconditionally. This matches `Test-*BatchBudgetPathInRoot`, the `OrdinalIgnoreCase` deduplication in `Get-WorktreeResolutionWorktreeRoot`, and `Get-OrchestrationCommandTarget`.
- A platform-dependent comparer would make a case-variant test row pass on Windows and fail in the Linux hook-suite job.
- Git for Windows emits drive-rooted forward-slash paths (`C:/...`), while the Claude `file_path` uses backslashes; normalization covers the difference.
- Known limit: an 8.3 short-name path or a junction-equivalent path that differs textually from git's long path does not match. It falls back to the session root, which is today's behavior. It cannot be fixed without a filesystem read.
- Test data: new hook-suite rows use slash-rooted synthetic paths (`/repo`, `/repo/.claude/worktrees/item`, `/repo-wt/sibling`) so they behave the same on the Linux job. The suites already carry drive-letter strings only as pure string data.

## 4. Library-module conventions and manifest entries

- **Layout.** `.claude/lib/<area>/<Name>.psm1`. The comment-based help header carries a `.NOTES` line stating "Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/" and the line "CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop." The module sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at module scope and ends with an explicit backtick-continued `Export-ModuleMember -Function`.
- **Hook import (guarded, one statement per edge).** For example:

  ```
  try { Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/HookTargetWorktree.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'HookTargetWorktree.psm1' -ErrorRecord $_ }
  ```

  This is pinned by `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`:
  - S2: one statement per `try`.
  - S3: `-ErrorAction Stop`.
  - S4: transitive edges must be terminating or covered. The new module has no imports.
  - S6: the decision function returns the dependency decision first. Both `Invoke-*BatchBudgetDecision` functions already do.

  `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (and its Codex counterpart) discovers edges from the abstract syntax tree, so a new guarded edge automatically gains a B1 row. That row requires the hook to deny at exit 0, naming `HookTargetWorktree.psm1`.

  With the standard guard, a load failure of the new module denies every Write and Edit through the top-level `Get-HookDependencyFailureDecision`, the same as a `HookPayload.psm1` failure. The route helper instead uses the scope-limited handler pattern (H11 and H12 in `tests/scripts/claude-runtime/HookImportFailureExemptions.Helpers.ps1`). **Recommendation:** use the standard guard and add no exemption.
- **`$PSScriptRoot` dependency closure.** `test_push_down_pack_manifest_dependency_closure.py` recognizes the positional form `Join-Path $PSScriptRoot '<child>'` (F1). The batch-budget hooks are in Claude `core.json`, so the new module must be listed in Claude `core.json` next to the other seven `worktree-resolution` entries. Listing it in `python.json` or `powershell.json` alone would fail closure.
- **Codex.**
  - Codex has no `.codex/lib`. The header of `.codex/hooks/file-size-policy.ps1` states that Codex hooks cannot import `.claude/lib` in a consumer repository.
  - The convention is a functions-only twin under `.codex/hooks/`, dot-sourced through a guarded `try { . (Join-Path $PSScriptRoot '<twin>.ps1') } catch { Add-HookDependencyFailure ... }`. A parity test compares each function's `Extent.Text` with the module's (`tests/scripts/codex-hooks/file-size-policy.Tests.ps1`).
  - Recommended twin: `.codex/hooks/hook-target-worktree.ps1`, listed in Codex `core.json`, mirrored to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-target-worktree.ps1`, and added to `$script:SharedModuleNames` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. That list drives the rows that parse each file, keep it at 500 lines or fewer, keep it byte-identical to its bundle copy, and require it in the core manifest.
- **Generator.** `scripts/dev_tools/generate_codex_agent_variants.py` manages only agent families in the Codex pack manifests (`PACK_FAMILIES`). Hook entries are hand-maintained. Run its `--check` after editing Codex `core.json`.
- **Coverage population.** `config/poshqc-coverage.json` roots include `.claude/lib` and `.codex/hooks`, so both new files enter the coverage denominator automatically. `config/poshqc-scan.json` scans `tests/scripts`, so new suites are sharded automatically.

## 5. Existing Pester suites and their disposition

All existing hook-level calls pass relative `file_path` values and an explicit synthetic `-Root` (`/repo`, `/synthetic-root`, or `/synthetic-absent-root`). This was verified by searching the ten `*batch-budget*` suites for absolute `file_path` values at hook level; none was found. Under the recommended rule that a relative path maps to the session root without calling the invoker, those calls keep the legacy root, checkpoint path, and state-file name.

| Suite | What it asserts about root, state, and exemption | Disposition |
|---|---|---|
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | State-file leaf `python-batch-budget.<id>.json` from the environment, the session file, or `worktree-repo-<8hex>`; session-file path `/repo/.claude/state/current-session-id`; containment (relative admitted, case-insensitive, sibling-prefix discarded, out-of-root `C:/synthetic-out-of-root/...` discarded at decision level); rehydrate filter | Unchanged (relative paths; decision-level containment unchanged). Add new rows: absolute path in an injected registered item worktree, two worktrees in one session with independent counters, `artifacts/` path not counted, file outside every registered worktree unchanged, invoker failure falls back to the session root |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | Same as the Python suite | Same as the Python suite |
| `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` | Checkpoint path `'/repo/artifacts/orchestration/orchestrator-state.json'`; large-path routes; test-path exemptions; no checkpoint read for out-of-scope paths or a missing `file_path` | Unchanged. Optionally add a row asserting that the checkpoint path is read under the injected item worktree root |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` | Same as the Python routing suite | Same as the Python routing suite |
| `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1` | BB0 to BB4 on the repository and mirror roots; BB2 asserts that no seam runs when the route helper fails | Unchanged, provided resolution runs after the route-import check. A relative `InScope` path never calls the invoker. A B-row for the new module edge is added automatically by the dependency-failure suite |
| `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` | Relative production and test paths with `-Root $script:RepoRoot`; injected state seams | Unchanged. Add Codex rows for an absolute item-worktree path and an `artifacts/` path |
| `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` | `-Root '/repo'`, `-RepositoryRoot '/repo'`, checkpoint path under the root, deny reason omits `.codex/state` | Unchanged; add one target-worktree checkpoint row |
| `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` | Same as the Codex Python routing suite | Same as the Codex Python routing suite |
| `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1` | CB0 to CB3 | Unchanged |
| `tests/scripts/codex-hooks/codex-batch-budget-route-parity.Tests.ps1` | Route helper byte parity and exactly three functions | Unchanged (route helper not edited) |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1` | Abstract-syntax-tree-discovered edge rows | No edit; new rows appear automatically and must pass |
| `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` | S1 to S8 structure | No edit; the new import must follow the guarded form |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (the "denies ... through their pure decisions" row) | Deny shape and pure decision with relative paths | Unchanged. `legacy-codex-hook-contracts.Tests.ps1` needs `hook-target-worktree.ps1` added to `$script:SharedModuleNames` |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | The row "registers every on-disk worktree-resolution module" enumerates `*.psm1` in the folder against `$script:ExpectedPaths`; per-module core-membership and bundle-hash rows | **Must be updated.** It fails as soon as `HookTargetWorktree.psm1` exists unless the path is added to `$script:ExpectedPaths` and to the three `-ForEach` lists |
| `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` | `test_brief_copies_are_byte_identical`; `test_brief_batch_budget_section_states_cap_codes_and_exemptions` requires the phrases "fourth distinct non-test PowerShell file", the two reason codes, "`large`, `remediation`, or `preparation`", "Bundle mirror copies", "count against the cap", "resolves inside the worktree root", "Files under `SCRATCH`", "without consuming a slot", and "Files written by Bash, by a copy script, or by a generator are not seen" | The brief rewrite must keep every listed phrase, or the plan must update this test in the same task |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | No hook invokes Python | Unaffected (`git` is not Python) |

New suites:

- `tests/scripts/claude-lib/worktree-resolution/HookTargetWorktree.Tests.ps1`. This runs on the Windows shards only, because the Linux job runs only `claude-hooks` and `codex-hooks`.
- `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1`. This holds the twin parity checks and behavior rows, and it runs on the Linux job.

## 6. Documentation that becomes stale

The six brief copies, verified by Glob and matching the brief's own maintenance statement:

1. `.claude/skills/execution-environment/SKILL.md`
2. `.agents/skills/execution-environment/SKILL.md`
3. `.github/skills/execution-environment/SKILL.md`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
5. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
6. `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`

Facts that become stale:

- **`## Batch Budget`, exemption bullet.** "in the worktree that holds the hook script" becomes "in the worktree that contains the edited file (the nearest enclosing worktree registered in `git worktree list --porcelain`, resolved by `Resolve-HookTargetWorktree` in `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`; the session root when the path is relative or lies in no registered worktree)". The isolated-subagent sentence stays true.
- **`## Batch Budget`, state bullet.** "Budget state is kept per session under `.claude/state/`" becomes "per session and per resolved worktree root", with the location stated as the plan decides (see the risks section). Codex: `.codex/state/`.
- **`## Batch Budget`, new fact.** Paths under the resolved worktree's root-level `artifacts/` directory never count.
- **`## Batch Budget`, scratch bullet.** Keep "resolves inside the worktree root" (it is pinned) and clarify "a registered worktree root". The "Files under `SCRATCH` ... discarded" sentence remains accurate for Claude. Codex has no containment and counts such files today. The plan should either state that or leave it unchanged with a note, because Codex containment is out of scope.
- **`## Hook Execution Context`.** Add one bullet: the batch-budget hooks evaluate the checkpoint of the resolved target worktree, not the session root, so a coordinator root never needs a checkpoint for them. The other gates still resolve as before until #1010 and #1011.
- **`## Preflight Defect Classes the Validator Cannot See`.** "Batch-budget exhaustion across a session" becomes "... across a session within one worktree".
- **`## Command-Text Restrictions`.** No fact stated there changes in #1009. The batch-budget hooks see only Write and Edit, and Bash-operand resolution is first used by #1010 and #1011. The issue record asks for this section to be updated, but the planner should record "no change" with that reason rather than invent text.

`.claude/rules/orchestrator-state.md` (bundled copy: `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`) currently says nothing about coordinator roots or the batch budget. The update is an addition, for example under `## Enforcement`: the batch-budget hooks read the checkpoint of the resolved target worktree, so a coordinating session never needs a checkpoint at its own root. Checkpoint hygiene (issue #673) is stated in `.claude/skills/orchestrate/SKILL.md` step 4 and remains valid.

Help text in the four hook files also becomes stale and must be revised: the `.DESCRIPTION` paragraphs "detected from <root>/artifacts/...", "persisted under .claude/state/...", and "Known limitation: a stale non-terminal large-path checkpoint left at the root ...".

## 7. Line counts

Physical lines were counted by a whole-file Grep line match. A trailing terminator is not counted.

| File | Lines | Tier note |
|---|---|---|
| `.claude/hooks/enforce-python-batch-budget.ps1` (+ mirror) | 496 | 4 lines below the 500 guidance tier; any wiring crosses it (non-blocking) |
| `.claude/hooks/enforce-powershell-batch-budget.ps1` (+ mirror) | 493 | 7 lines below 500 |
| `.claude/hooks/enforce-batch-budget-route.ps1` (+ 2 copies) | 139 | not edited |
| `.codex/hooks/enforce-python-batch-budget.ps1` (+ mirror) | 351 | **pinned to at most 500** by `legacy-codex-hook-contracts.Tests.ps1` |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` (+ mirror) | 348 | same pin |
| `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` | 481 | adding rows crosses 500; prefer a new suite file |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` | 490 | same |
| `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1` | 369 | room |
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` | 354 | room |
| `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` | 275 | room |
| `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1` | 390 | room |
| `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` | 383 | room |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` | 108 | room |
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | 500 | not edited (reference only) |

`config/file-size-baseline.json` lists none of these files. This was verified by a search for `batch-budget`, `worktree-resolution`, and `HookTargetWorktree`, which returned no match. Markdown files are exempt.

**Recommendation:** keep hook wiring to about 15 to 20 lines per Claude hook by placing all logic in the module. Put new hook-level rows in new suites rather than in the 481-line and 490-line files, for example `tests/scripts/claude-hooks/enforce-python-batch-budget.TargetWorktree.Tests.ps1` and the PowerShell counterpart.

## 8. Python port

None exists. No `.py` or `.ts` file implements the batch budget, the route helper, or a worktree resolver. Searches for `batch.budget`, `LARGE_PATH_REQUIRED`, and `TARGET_WORKTREE` in `*.py`, `*.ts`, and `*.sh` found only:

- test fixtures and contract tests that name the state-file path or the hook file names (`test_claude_payload_scope_support.py`, the push-down tests, the brief contract tests);
- `scripts/dev_tools/validate_parallel_orchestrator_state.py`, which mentions `worktree list` in a validator, not in a resolver.

No Python counterpart is planned. Enforcement hooks keep invoking only PowerShell and `git`, consistent with `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.

## Behavior Semantics (target)

1. **Scope filter unchanged.** No `file_path`, or a path with a non-matching extension, allows without resolution, checkpoint read, or state I/O.
2. **Route-helper import failure** still denies an in-scope path before any seam or invoker call.
3. **Resolve.** `Resolve-HookTargetWorktree -SessionRoot $Root -FilePath $filePath` with the hook's `-WorktreeListInvoker` seam. `$TargetRoot = result.WorktreeRoot`. If `Ambiguous` is true or the root is null, which cannot happen for a single path source, use `$Root`. The fallback is always the session root, which is today's behavior and fails toward the cap rather than toward the exemption.
4. **`artifacts/` exclusion.** If `Get-HookTargetWorktreeRelativePath -Path $filePath -WorktreeRoot $TargetRoot` starts with `artifacts/`, or a relative path starts with `artifacts/`, allow with no state write. Only the root-level directory is excluded, matching the `/artifacts` entry in `.gitignore`. Nested fixture directories named `artifacts` still count.
5. **Checkpoint** is read from `Join-Path $TargetRoot 'artifacts/orchestration/orchestrator-state.json'`.
6. **State** stays under the session root's state directory (`.claude/state/` or `.codex/state/`), with the session id resolved exactly as today.
   - When `$TargetRoot` equals `$Root` (`OrdinalIgnoreCase`), the file name is unchanged.
   - Otherwise it is `<kind>-batch-budget.<sessionId>.<Get-HookTargetWorktreeKey $TargetRoot>.json`.
   - Containment and the rehydrate filter use `-Root $TargetRoot`.
7. **Decision function unchanged** except that it is called with `-Root $TargetRoot`. Cap value, test rules, reason text, and deny-only output are unchanged.

## Requirements Mapping

| Expected behavior (issue) | Mechanism |
|---|---|
| Route is read from the resolved target worktree's checkpoint | Semantics 3 and 5 |
| Budget state is keyed per resolved worktree root | Semantics 6 (worktree key in the file name; containment against the target root) |
| `artifacts/` paths are never counted | Semantics 4 |
| A file outside every registered worktree keeps today's behavior | Resolver falls back to the session root; existing decision-level containment discards it (Claude) or counts it (Codex), as today |
| Unit areas: large checkpoint means uncapped; no checkpoint means capped; two worktrees have independent counters; `artifacts/` scratch is not counted; a session-root file is unchanged | New rows in the new hook suites for both runtimes plus the resolver suites, all with an injected porcelain invoker and in-memory seams |

## Numeric Derivation Evidence

No numeric acceptance criterion is proposed for `spec.md`. The cap value 3 is an existing routing constant and is not re-derived. One enumeration is recorded because the plan will name it.

**Claim: the execution-environment brief exists in exactly six copies.**

- **Complete Family:** every file named `SKILL.md` under a directory named `execution-environment` anywhere in the repository.
- **Exhaustive Search Scope:** the whole item worktree, including `extensions/drm-copilot/resources/**`.
- **Inclusion Rules:** the path ends in `/execution-environment/SKILL.md`.
- **Exclusion Rules:** none.
- **Primary Search Strategy or Query Expression:** Glob `**/execution-environment/SKILL.md`.
- **Primary Member Set:**
  - `.agents/skills/execution-environment/SKILL.md`
  - `.claude/skills/execution-environment/SKILL.md`
  - `.github/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
  - `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- **Primary Count:** 6.
- **Cross-check Search Strategy or Query Expression:** read `## Purpose and Maintenance` in `.claude/skills/execution-environment/SKILL.md`, which names three runtime paths "and their bundled copies under `extensions/drm-copilot/resources/`", and map each runtime path to its bundle root.
- **Cross-check Member Set:** `.claude/...`, `.agents/...`, `.github/...`, and the bundled `claude-customizations/.claude/...`, `codex-and-agents-customizations/.agents/...`, and `customizations/.github/...` copies.
- **Cross-check Count:** 6.
- **Member-set Comparison:** after normalization the two sets are identical (6 = 6), with no member missing from either side.

The set of existing batch-budget suites is not given as a single number. A file-name glob (`tests/**/*batch-budget*.Tests.ps1`: 10 files) and a function-reference search (`Invoke-(Python|PowerShell)BatchBudget(Hook|EntryPoint|CodexEntryPoint)`: 12 files, of which 3 do not match the glob and 1 glob member, the route-parity suite, does not match the reference search) enumerate different families by design. Section 5 lists every member with its disposition instead.

## Testing Implications

- **Resolver suites.**
  - These cover the porcelain parser (main stanza, linked stanzas, `bare`, `detached`, `prunable`, blank lines, CRLF supplied in memory), nearest-enclosing selection with a nested worktree (`/repo` and `/repo/.claude/worktrees/item`), sibling worktrees, and the outside-all fallback.
  - They also cover the relative-path short circuit (the invoker is not called), case-variant and backslash inputs, a throwing or empty invoker, and the branch source with zero, one, and two matches.
  - They cover delegation identity with and without `-CheckpointIssueReader`, disagreement producing Ambiguous, the no-source case (invoker not called), and reason-code equality with `Get-WorktreeResolutionAmbiguityReasonCode` and `Get-WorktreeResolutionNoTargetReasonCode`.
  - The default-invoker body is covered without spawning git by asserting its abstract syntax tree (git argument list). Otherwise its few lines remain uncovered and count against the 85% line threshold; the plan must budget for that.
- **Hook suites (new files).** These rows inject `-WorktreeListInvoker` returning porcelain text for `/repo` plus `/repo/.claude/worktrees/item` and `/repo-wt/sibling`, and use in-memory state and checkpoint seams:
  - item checkpoint `large` means uncapped;
  - no item checkpoint means the fourth path is denied;
  - two worktrees fill independent counters and state files;
  - `artifacts/x.py` and `artifacts/x.ps1` are not counted;
  - a session-root file keeps the legacy state-file name;
  - a path outside every worktree is discarded (Claude);
  - an invoker failure produces session-root behavior.
- **Codex twin.** A parity suite asserts that function names and `Extent.Text` are identical to the module, and the hook rows above are repeated for both Codex hooks.
- **Isolation evidence** (brief `## Test Isolation Checks`): a seeded shuffled file-order run of the touched Pester suites in one process with at least three seeds, and a fresh single-process run over `tests/scripts`.

## Automation Feasibility

The work is fully automatable. Every change is a repository file edit, and every proof is a Pester or pytest run in the existing toolchain. No third-party UI, credential, or manual step is involved. Constraints that remain:

- The executor has no PowerShell tool. Pester runs go through the PoshQC MCP tools, whose results carry no output, or through a `sh` launcher under `SCRATCH` (brief `## Tool Routes by Agent`).
- Branch hooks are not exercised by isolated subagents (brief `## Hook Execution Context`). Proof is by Pester. A live check needs a non-isolated delegation from the item worktree and is optional.
- Batch budget during execution:
  - This change edits more than three production PowerShell files: two Claude hooks, two Claude mirrors, two Codex hooks, two Codex mirrors, the module and its mirror, and the twin and its mirror.
  - The item worktree's checkpoint must select `preparation`, `large`, or `remediation` and be non-terminal, or the executor will be denied the fourth file.
  - Bundle mirrors are best produced by a copy step, which the hook matcher `Write|Edit` does not see; that approach is consistent with the brief.

## Pre-Mortem

- **Review checklists:** A reviewer could flag the restated `TARGET_WORKTREE_*` literals in `HookTargetWorktree.psm1` as a duplicated definition. Mitigation: a resolver test asserts equality with the `WorktreeResolution.psm1` accessors, and the module help cites the precedent in `validate-orchestrator-output-resolution.ps1`. A reviewer could also flag the sibling-worktree tightening (section 1.4) as an unrequested behavior change. Mitigation: the plan states it as the intended effect of per-worktree keying and adds a test row for it.
- **Coverage:** The default-invoker body and any timeout branch are host-bound lines in a `.claude/lib` file, which is in the coverage denominator, so per-file line coverage could fall below 85%. Mitigation: keep the default invoker to one or two statements and cover every other function with injected porcelain. Read per-file figures from `artifacts/pester/powershell-coverage.xml`, not from the PoshQC MCP result.
- **Mirror parity:** The next review or CI run fails if any mirrored copy drifts from its source.
  - Four parity surfaces can drift: the module and its bundle copy (`WorktreeResolution.Manifest.Tests.ps1`, the resource-contract pytest), the Codex twin and its bundle copy (`legacy-codex-hook-contracts.Tests.ps1`), the twin and the module function text (the new parity suite), and the four edited hooks and their bundle copies.
  - The six brief copies must stay byte-identical (`test_brief_copies_are_byte_identical`) and keep the pinned Batch Budget phrases.
  - `.claude/rules/orchestrator-state.md` has a bundled copy.
  - Mitigation: one brief-update task covers all six copies. The plan's mirror task copies each file after its last edit and then runs both resource-contract tests, both manifest-completeness tests, the dependency-closure test, and the Codex generator `--check`.
- **File size:** The Claude hooks are at 496 and 493 lines, so any wiring crosses the 500 guidance tier (non-blocking). The Codex hooks are pinned to 500 or fewer by `legacy-codex-hook-contracts.Tests.ps1`, and so is the new twin. The two Claude unit suites are at 481 and 490 lines. Mitigation: all logic goes in the module, hook wiring is limited to about 15 to 20 lines, new hook rows go in new suite files, and the twin is kept under 500 lines.
- **Test isolation:** Each hook suite imports the module with `-Force` at dot-source, and shard or single-process runs expose leaked module state and `$PSDefaultParameterValues` entries. Mitigation: new suites inject the invoker through parameters rather than global defaults, remove any default they set in `AfterAll`, and never call the real `git` (`Mock git` is also forbidden by `check-powershell-test-purity.ps1`). Run a seeded shuffled file-order run with at least three seeds and a fresh single-process run over `tests/scripts`.
- **CI-only behavior:** The Linux job `poshqc / PowerShell hook suites (Linux)` runs `claude-hooks` and `codex-hooks` on a case-sensitive file system, and the resolver suite under `claude-lib` runs only on the Windows shards. Mitigation: new hook-suite rows use slash-rooted synthetic paths, forward slashes, and `Join-Path`. Resolver comparison is `OrdinalIgnoreCase` unconditionally, so results do not depend on the platform. No test reads gitignored `artifacts/` state or the real worktree list.
- **Evidence:** Proof rests on PoshQC MCP results, which carry no counts, so evidence could cite unverifiable pass counts. Mitigation: evidence artifacts record pass and fail counts from `artifacts/pester/pester-junit.xml` and coverage from `artifacts/pester/powershell-coverage.xml`, under `<FEATURE>/evidence/<kind>/` with write-time UTC stamps and no absolute paths.

## Recommended File Inventory

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

- `.claude/hooks/enforce-python-batch-budget.ps1`
- `.claude/hooks/enforce-powershell-batch-budget.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-python-batch-budget.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
- `.codex/hooks/enforce-python-batch-budget.ps1`
- `.codex/hooks/enforce-powershell-batch-budget.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-python-batch-budget.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`
- `.claude/skills/execution-environment/SKILL.md`
- `.agents/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `.claude/rules/orchestrator-state.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`

Not edited (verified unaffected): `.claude/hooks/enforce-batch-budget-route.ps1` and its two copies, `.claude/settings.json`, `.codex/config.toml`, the Claude `python.json` and `powershell.json` manifests, all five preimplementation-gate files, `enforce-pr-author-skill*.ps1`, and `enforce-model-routing-receipt.ps1`.

## Open Risks and Decisions for the Planner

1. **State location.** The recommendation keeps state under the session root with a worktree-keyed file name, which preserves the session-id file lookup and writes nothing into another worktree. The alternative is `<target root>/.claude/state/`. It would write gitignored files into item worktrees and move the `current-session-id` lookup. Whether gitignored files block `git worktree remove` without `--force` was not verified (**ORCHESTRATOR TO CONFIRM** if that alternative is chosen).
2. **Relative-path rule.** The recommendation maps relative paths to the session root without enumeration, for process-free tests and consistency with `Get-OrchestrationCommandTarget`. A Codex coordinator that patches a nested worktree through a relative `apply_patch` path keeps today's attribution to the session root.
3. **Default invoker timeout.** Decide between an unbounded `git -C` call and a module-local bounded call. Git process start cost is incurred once per in-scope Write or Edit with an absolute path.
4. **Import-failure posture.** The standard guard denies every Write and Edit if the module fails to load. The alternative is a scope-limited handler like H11 and H12, which would need entries in `HookImportFailureExemptions.Helpers.ps1`.
5. **Additive result fields.** `ReasonCode`, `Detail`, and `Candidates` go beyond the mandated `{ WorktreeRoot, Source, Ambiguous }`. They are recommended so #1010 and #1011 can compose deny reasons without a second resolution. Confirm with the operator if the contract must be exactly three fields.
6. **Short-name and junction paths.** These fall back to the session root because textual comparison cannot equate them with git's long paths. This is documented, not fixed.
7. **Execution batch budget.** More than three production PowerShell files are edited, so the item checkpoint must select an uncapped, non-terminal route before execution begins.
8. **Byte identity.** The current hook-to-mirror byte identity was inferred from equal line counts and green contract tests, not hashed (**ORCHESTRATOR TO CONFIRM**).
