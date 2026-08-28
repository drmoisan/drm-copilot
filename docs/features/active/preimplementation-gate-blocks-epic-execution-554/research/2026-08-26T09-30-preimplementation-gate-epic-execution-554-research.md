# Research: preimplementation gate blocks epic/parallel execution (issue #554)

- **Issue:** #554
- **Feature folder:** `docs/features/active/preimplementation-gate-blocks-epic-execution-554`
- **Research timestamp:** 2026-08-26T09-30
- **Workspace root:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6ce55e95733da015`

## Tooling limitation declared up front

This research session had **no shell tool available** (no Bash tool, no PowerShell tool; only
Read, Grep, Glob, Write, Edit, WebFetch). Consequences, stated explicitly rather than papered
over:

- **SHA-256 hashes for item A3 could not be computed.** Byte-identity between each self-hosted
  copy and its `extensions/drm-copilot/resources/` mirror is reported below from (a) exact
  line-count equality obtained via a ripgrep line count and (b) region-by-region content reads.
  That is strong evidence of textual identity but is **not** a hash and does not observe
  trailing-byte or line-ending differences.
- No test suite was executed. Every claim about test behaviour below is derived by reading the
  suite source, not by running it.
- The item A4 "known-failing locally" claim was checked structurally (see A4) rather than by
  running pytest.

---

## A. Hook surface inventory and parity

### A1. Helpers file content, exports, and headroom

`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` — **349 lines**
(ripgrep line count over `**/enforce-orchestration-preimplementation-gate*.ps1`).

It is a **pure-string, dependency-free pathspec classifier** added by issue #539. Its header
(lines 4-10) states: "Pure string logic only: no disk, process, network, or environment access."
It declares three script-scope constants and four functions:

| Symbol | Line | Kind |
| --- | --- | --- |
| `$script:OrchestrationBookkeepingTrees` | 22 | 5 repo-relative directory prefixes |
| `$script:UnresolvableCommandCharacters` | 33 | `[char[]]@('$', '`', '>', '<')` |
| `$script:PathspecWildcardCharacters` | 37 | `[char[]]@('*', '?', '[')` |
| `Split-OrchestrationCommandLine` | 39 | helper |
| `ConvertTo-OrchestrationCommandToken` | 91 | helper |
| `Test-ExemptOrchestrationOperand` | 148 | helper |
| `Test-ExemptOrchestrationSegmentToken` | 206 | helper |
| `Test-ExemptOrchestrationStagingCommand` | 296 | **the single entry predicate** |

The file is dot-sourced (not a module) and has **no `Export-ModuleMember`**; every function is
visible to the dot-sourcing caller. Only `Test-ExemptOrchestrationStagingCommand` is consumed by
the gate hook (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:139`).

**Headroom under the 500-line cap** (`.claude/rules/general-code-change.md` → File Size Limit;
Markdown is exempt, `.ps1` is not):

| File | Lines | Headroom |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 | **118** |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | **151** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 | **118** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 | **151** |

Note the helpers file is **byte-for-byte the same content on both surfaces** (see A2), so its
headroom is shared: a change there lands identically on Claude and Codex.

### A2. Claude vs Codex diff (the two gate hooks, and the two helpers files)

**The two helpers files are identical.** Both are 349 lines; the `.codex` copy's header
(lines 1-18) is character-for-character the same as the `.claude` copy's, including the
`enforce-pr-author-skill.ps1` headroom-split precedent sentence at lines 16-17 (which is a
Claude-side reference retained verbatim on the Codex side). **A helpers-file change can be
applied verbatim to all four copies.**

**The two gate hooks differ in eight places.** A change to the shared decision logic can be
applied verbatim *except* at difference 6 (the field reader), which must be adapted.

| # | Location | `.claude` copy | `.codex` copy |
| --- | --- | --- | --- |
| 1 | line 1 | file starts at `<#` | file starts with **one blank line** before `<#` |
| 2 | claude:9 / codex:11 | `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force` | `. (Join-Path $PSScriptRoot 'codex-pretooluse-file-mapping.ps1')` — **no HookPayload module** |
| 3 | claude:12-13 / codex:14-15 | comment cites `enforce-pr-author-skill.ps1` precedent | comment cites `enforce-completion-helpers.ps1` precedent |
| 4 | codex:106-109 | absent | extra comment paragraph on apply_patch idempotence inside `Test-ImplementationPath` |
| 5 | codex:128-139 | absent | two extra `[regex]::Matches` loops harvesting `*** Add/Update/Delete File:` and `*** Move to:` apply_patch file markers, each feeding `Test-ImplementationPath` |
| 6 | claude:168,173 / codex:189,194 | `Get-ClaudeHookToolInputString -ToolInput $ToolInput -Name 'subagent_type' \| 'prompt'` | `Get-StringProperty -Value $ToolInput -Name 'subagent_type' \| 'prompt'` (its own local helper) |
| 7 | claude:277-329 / codex:298-346 | `Invoke-...Decision` takes `[AllowNull()][AllowEmptyString()][string] $ToolInputRaw`, calls `Resolve-ClaudeHookToolInput`, and **denies on a payload anomaly** | same function takes a plain `[string] $ToolInputRaw` that is **already the mapped/flat `tool_input`**, returns **allow** on empty, and **throws** on malformed JSON |
| 8 | claude:331-382 / codex:348-382 | `Invoke-OrchestrationPreimplementationGateEntryPoint` (a testable function with a `ReadPayload` scriptblock seam) plus the multi-element pipeline tail | **no entry-point function**; an inline `try { ... } catch { exit 2 }` tail that reads `[Console]::In.ReadToEnd()`, calls `ConvertFrom-CodexPreToolUsePayload`, branches on `tool_name`, and emits decision JSON **only on deny** |

**Load-bearing consequence for the fix.** On the Codex side the delegation leg is effectively
**dead code**. `Invoke-OrchestrationPreimplementationGateDecision` is reached only via:

- the `Bash`/`apply_patch` branch (codex:359-365), which passes the raw `tool_input` — and a
  `Bash`/`apply_patch` `tool_input` carries no `subagent_type`; or
- the `Edit`/`Write` branch (codex:370-377), which synthesizes `@{ file_path = ... }` and
  therefore never reaches `Test-ImplementationDelegation` at all.

There is no `Agent` tool name in the Codex branch table, and there is no `Agent` matcher in
`.codex/config.toml` (see F14). So `Test-ImplementationDelegation` on Codex is only reachable by
an `apply_patch` payload whose `tool_input` has neither `file_path` nor `command`.

### A3. Mirror identity (four pairs) — line-count and region evidence, NOT hashes

Line counts (ripgrep `^` count, one match per line):

| Path | Lines |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 382 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 349 |

Content spot-checks performed: claude mirror lines 1-30 and 180-209 match the self-hosted file
exactly; codex mirror lines 345-382 match the self-hosted codex file exactly.

**Not verified:** SHA-256 equality, trailing-byte equality, and line-ending (CRLF vs LF)
equality. Note that the repository's own parity tests **also cannot see a line-ending
difference**, because they compare `Path.read_text(encoding="utf-8")` results and Python's
default universal-newline translation normalizes `\r\n` to `\n` before comparison
(`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:46-49,123-126`).

### A4. Parity / payload-completeness tests in scope

| Test | Path:line | What it asserts |
| --- | --- | --- |
| `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` | Every repo `.claude/**` file (excluding `.claude/settings.local.json` and `.claude/agent-memory/**`) must exist in `extensions/drm-copilot/resources/claude-customizations/` **with identical UTF-8 text**. |
| `test_bundled_claude_payload_contains_required_runtime_files` | same file:52-65 | Nine anchor files present. Does not name our hooks. |
| `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:207-220` | Same assertion for `SCOPED_ROOTS == (".codex", ".agents")` (`:35`). |
| Codex pack-manifest completeness | `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py:90-105,153-194` | Every bundled `.codex/hooks/*` file must be listed in some `pack-manifests/*.json`, **unless** it is in `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS`. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` **is** in that exception set (`:98`); `-helpers.ps1` is **not**, and is listed in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json:40`. |
| Claude pack manifest | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:35-36` | Lists **both** `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `-helpers.ps1`. |
| PoshQC settings parity | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18,63-81` | Locks `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` to exact text parity with `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. |

**On the known local failure (issue #510, gitignored `.claude/state/*.json`):** in *this
worktree* a `Glob` for `.claude/state/*` returned **no files**. The directory does not exist
here, so the specific cause recorded in that issue is **not currently reproducible in this
checkout**. I could not run pytest to confirm the test now passes; that remains unverified.

**Narrow verification command for the six files in scope.** Because the two payload-completeness
tests enumerate the whole tree and are therefore vulnerable to unrelated untracked files, prefer
a targeted hash comparison, e.g.:

```powershell
$pairs = @(
  @('.claude/hooks/enforce-orchestration-preimplementation-gate.ps1',
    'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'),
  @('.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1',
    'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1'),
  @('.codex/hooks/enforce-orchestration-preimplementation-gate.ps1',
    'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'),
  @('.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1',
    'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1')
)
foreach ($p in $pairs) {
  $a = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[0]).Hash
  $b = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[1]).Hash
  '{0}  {1}  {2}' -f ($(if ($a -eq $b) { 'MATCH' } else { 'DIFFER' })), $a, $p[0]
}
```

This is a *shape*, not a checked assertion: it was not executed in this session.

---

## B. The payload reader seam

`.claude/lib/hook-payload/HookPayload.psm1` (495 lines, `Set-StrictMode -Version Latest` at
line 42). Exported functions, `:484-494`.

### `Get-ClaudeHookToolInputString` (`:408-437`)

```powershell
param(
    [AllowNull()][object] $ToolInput,
    [Parameter(Mandatory)][string] $Name
)
```

- **Does not throw on a missing field.** It delegates to `Get-ClaudeHookEnvelopeValue` (`:304`),
  which returns `$null` when the key is absent, and then returns `''` (`:432-436`).
  The docstring states it plainly: "an absent property returns an empty string, which every hook
  already treats as 'out of my scope, allow'."
- **Case sensitivity on the field name is not decided by this module.** For a `PSCustomObject`
  it uses `@($Envelope.PSObject.Properties.Name) -contains $Name` (`:301`) — PowerShell
  `-contains` is **case-insensitive** — and then `$Envelope.PSObject.Properties[$Name].Value`
  (`:327`), which is also case-insensitive. For an `IDictionary` it uses `.Contains($Name)`
  (`:296`), whose case sensitivity depends on the dictionary's comparer. **Net: for the
  `ConvertFrom-Json` PSCustomObject shape the hooks actually receive, field lookup is
  case-insensitive.**
- Returns `[string]$value`, so a non-string JSON value is coerced rather than rejected.

### `Resolve-ClaudeHookToolInput` (`:439-482`)

`param([AllowNull()][AllowEmptyString()][string] $Raw)`. Composes `ConvertFrom-ClaudeHookEnvelope`
+ `Get-ClaudeHookToolInput`. Returns `[pscustomobject]@{ IsValid; Value; Envelope; Anomaly }`.
`Envelope` carries the parsed root (added for `enforce-epic-invocation-origin.ps1`'s
`agent_type` read). **Strict: no flat-root fallback** — a payload with no `tool_input` key is the
`MissingToolInput` anomaly (`:391-393`).

### `Get-ClaudeHookPayloadAnomalyReason` (`:85-109`)

Maps one of five codes (`EmptyPayload`, `UnparseableJson`, `MissingToolInput`, `NullToolInput`,
`NonObjectToolInput`; text table at `:56-62`) to a deny-reason clause. Unknown/empty codes get
generic fallbacks rather than throwing.

### `Read-ClaudeHookRawPayload` (`:146-222`)

Ordering: stdin (guarded by `[Console]::IsInputRedirected`), then `$env:CLAUDE_HOOK_INPUT`, then
`$env:CLAUDE_TOOL_INPUT`; first non-whitespace source wins; `''` otherwise. All four boundaries
are injectable scriptblock/string parameters.

### Codex surface

**The Codex surface does not use this module.** `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:11`
dot-sources `codex-pretooluse-file-mapping.ps1` instead, which supplies
`ConvertFrom-CodexPreToolUsePayload` and `ConvertTo-CodexFileEditInput` (used at codex:353 and
codex:370). Field reads on the Codex side go through the hook's own local `Get-StringProperty`
(codex:51-63), which uses `$Value.PSObject.Properties.Name -contains $Name` and `.Trim()` — so
it **trims** where `Get-ClaudeHookToolInputString` does not. That trim difference is a real
behavioural divergence the fix must not silently rely on.

---

## C. The precedent hook — `enforce-epic-wave-barrier.ps1`

Read in full: `.claude/hooks/enforce-epic-wave-barrier.ps1`, **333 lines**.

### It uses a FIXED table, not a prompt-parsed path — verbatim evidence

```powershell
# .claude/hooks/enforce-epic-wave-barrier.ps1:37-40
Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force
$script:EpicCheckpointPath = 'artifacts/orchestration/epic-orchestrator-state.json'
$script:AllowedMergeStatuses = @('merged', 'worktree_removed')
$script:EpicModeMarker = 'Epic mode: true'
```

The checkpoint path is a **script-scope constant**. Nothing in this hook reads a path out of the
prompt. This is exactly the posture #554 requires ("resolve the readiness source polymorphically
from a FIXED table keyed on the recognized mode marker, never from a path parsed out of the
prompt"). The hook is single-mode, so its "table" is one constant; the polymorphic version is a
two-or-three-row extension of the same idea.

### Mode-marker detection — field-scoped, exact substring

```powershell
# :257-265
$subagent = Get-ClaudeHookToolInputString -ToolInput $envelope.Value -Name 'subagent_type'
if (-not $subagent -or $subagent -ne 'orchestrator') {
    return Get-EpicWaveBarrierAllowDecision
}

$prompt = Get-ClaudeHookToolInputString -ToolInput $envelope.Value -Name 'prompt'
if (-not $prompt -or $prompt -notlike "*$script:EpicModeMarker*") {
    return Get-EpicWaveBarrierAllowDecision
}
```

Note the marker literal is `'Epic mode: true'` with **no trailing period**, and the test is a
`-like` wildcard containment (case-insensitive in PowerShell), read from the **`prompt` field**,
not from a serialized whole payload.

### Target resolution out of the prompt

```powershell
# :87-106 (Find-EpicWaveBarrierFeatureFolderFromPrompt)
$pattern = 'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'
$matchList = [regex]::Matches($Prompt, $pattern)
...
$candidates = @(@($unique.Keys) | Sort-Object -Property Length -Descending)
$best = $candidates[0]
if ($best -match '\.md$') { $best = $best -replace '/[^/]+\.md$', '' }
return ($best -split '/')[-1]
```

Longest match wins; a `.md`-suffixed match resolves to its parent directory; the **basename** is
returned. The docstring (`:64-70`) records that this mirrors
`enforce-prd-feature-before-planner.ps1`'s `Find-PrdFeatureFolderFromPrompt`.

The record lookup then compares that basename against `features[].feature_folder` **directly**,
with no normalization on the checkpoint side (`:138-146`).

### Dot-sourced helpers

`enforce-epic-wave-barrier.ps1` dot-sources **nothing**. All five of its functions are inline.
So there is no ready-made helper to reuse; the fix must either duplicate the technique or extract
it. The parallel analogue **does** dot-source
`.claude/hooks/enforce-parallel-cohort-barrier-helpers.ps1` (`:58`), which exports
`Find-ParallelCohortBarrierItemRecord` (:31), `Find-ParallelCohortBarrierItemByKey` (:73),
`Find-ParallelCohortBarrierCohortIndex` (:113),
`Get-ParallelCohortBarrierConflictNeighborList` (:170), `Test-ParallelCohortBarrierClear` (:218).
Those are cohort-barrier-specific and **not reusable** by the preimplementation gate.

---

## D. Other hooks that resolve an epic or parallel checkpoint

### `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (284 lines) — the parallel precedent

```powershell
# :52-54
$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'
$script:AllowedMergeStatuses = @('merged', 'worktree_removed')
$script:ParallelModeMarker = 'Parallel mode: true'
```

Same shape as the epic hook: fixed path constant, field-scoped `subagent_type == 'orchestrator'`
+ `prompt -like "*$marker*"` (`:207-215`), prompt-scan for the target (`:112-152`). It adds
`Get-ParallelCohortBarrierFolderBasename` (`:78-110`), which **normalizes both sides** of the
comparison — the checkpoint's `feature_folder` may be a full path or a bare basename. That is a
strictly better resolution than the epic hook's one-sided comparison and is the one to reuse.

### `.claude/hooks/enforce-epic-merge-gate.ps1` (452 lines) — the closest structural precedent

This hook already resolves **three** checkpoints and is the nearest existing analogue of the
polymorphic readiness table #554 asks for:

```powershell
# :44-46
$script:ChildCheckpointPath    = 'artifacts/orchestration/orchestrator-state.json'
$script:EpicCheckpointPath     = 'artifacts/orchestration/epic-orchestrator-state.json'
$script:ParallelCheckpointPath = 'artifacts/orchestration/parallel-orchestrator-state.json'
```

with three separate read seams (`Get-ChildOrchestratorCheckpointContent` :48,
`Get-EpicOrchestratorCheckpointContent` :66, `Get-ParallelOrchestratorCheckpointContent` :84),
one predicate per checkpoint (`Test-ChildCheckpointAllowsEpicMerge` :160,
`Test-EpicCheckpointAllowsMerge` :189, `Test-ParallelCheckpointAllowsMerge` :247), and a
first-match-wins dispatch at `:383-396`. Its parallel predicate reads `route_id == 'parallel'`
(`:274`) and `items[].merge_status == 'ci_green'` (`:301-304`).

**Important structural difference from what #554 wants:** the merge gate dispatches by *trying
each checkpoint in turn*, not by keying on a recognized mode marker. #554 explicitly requires
marker-keyed dispatch. The merge gate is the precedent for "three predicates, three read seams,
one deny reason naming what failed"; the barrier hooks are the precedent for "marker-keyed,
field-scoped classification".

### Other hits

| Hook | Line | Note |
| --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 26 | fixed `$script:EpicCheckpointPath` |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 33 | fixed `$script:ParallelCheckpointPath` |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 71-72 | fixed path + `$script:ParallelModeMarker = 'Parallel mode: true'`; fires on `subagent_type == 'feature-review'` |
| `.codex/hooks/enforce-epic-wave-barrier.ps1` | 278 | `Join-Path $primaryRoot 'artifacts/orchestration/epic-orchestrator-state.json'` — the **Codex** copy resolves a repository root first |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 129 | `Join-Path $repositoryRoot ...` |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 137 | `Join-Path $repositoryRoot ...` |

**There is no shared mode-resolution helper module.** `.claude/lib/` contains 27 `.psm1` files
across `blast-radius`, `codex-routing`, `discovery-validation`, `hook-payload`, `mermaid`,
`model-routing`, and `orchestrator-state`. **None** of them performs mode-marker recognition or
checkpoint-path resolution. Every hook above re-declares its own constants inline. If the fix
wants a shared table it must create one; if it wants to match repository convention it should
declare constants inline in the gate hook, as all six precedents do.

---

## E. Kickoff-contract markers (reuse verbatim; do not invent)

### E1. Epic execution kickoff — `.claude/skills/epic-orchestrate/SKILL.md:113-118`

> When `epic-orchestrator` delegates a child feature to `Agent(orchestrator)`, the prompt includes
> the literal epic-mode kickoff line:
>
> `Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json. PR base branch MUST be <integration_branch>, not main; pass --base <integration_branch> to gh pr create. Your final report MUST be exactly the bounded return shape (issue_num, feature_folder, merge_status, pr_number, merge_commit_sha, blocked_reason, branch_name, worktree_path) and nothing else; any additional narrative is discarded because the parent re-derives authoritative state regardless.`

Exact literals, with punctuation:

- Marker: `Epic mode: true.` — with a trailing period in the kickoff text. The wave-barrier hook
  matches only `'Epic mode: true'` (no period), so **the period is not part of the matched
  token**. A new predicate should match the same period-free token to agree with the precedent.
- `epic_checkpoint_path: artifacts/orchestration/epic-orchestrator-state.json.` — **confirmed
  emitted**, canonical value `artifacts/orchestration/epic-orchestrator-state.json`.
- `epic_feature_folder: <epic-slug>.` — this is the **epic** slug (a bare slug, not a path),
  not the child's feature folder.
- `integration_branch: epic/<epic-slug>-integration.`

**Gap to flag for the spec.** The epic kickoff contract does **not** mandate that the child's own
`docs/features/active/<basename>` path appear in the prompt. The nearest thing is the dependency
citation line at `:184`:

> `Upstream context for <issue_num>: depends on <dep_issue_num> (spec: <dep_resolved_folder>/spec.md; plan: <dep_resolved_folder>/plan.<ts>.md; merged as PR #<dep_pr_number>, commit <dep_merge_commit_sha>, into <integration_branch>).`

which is emitted **only for a feature with a non-empty `depends_on`** (`:180-182`) and names the
*dependency's* folder, not the target's. `enforce-epic-wave-barrier.ps1` nevertheless resolves the
target by scanning for `docs/features/active/<token>` and **denies** when it finds none
(`:267-270`). A wave-0 epic child with no dependencies therefore has no contractually guaranteed
feature-folder token in its prompt. **This is a latent defect in the epic kickoff contract that
the #554 fix will inherit if its epic predicate resolves the target the same way.**
No `issue_num:` key appears in the epic kickoff marker line at all.

### E2. Parallel execution kickoff — `.claude/skills/parallel-orchestrate/SKILL.md:237-257`

> 1. The literal marker line:
>
>    `Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json. cohort_index: <n>. PR base branch MUST be main; pass --base main to gh pr create.`

- Marker: `Parallel mode: true` — SKILL.md:246 states "The token `Parallel mode: true` must
  appear exactly". Matched period-free by `enforce-parallel-cohort-barrier.ps1:54`.
- `parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json.` —
  **confirmed emitted**, canonical value `artifacts/orchestration/parallel-orchestrator-state.json`.
- `parallel_slug: <slug>.`, `cohort_index: <n>.`

Unlike the epic contract, the parallel contract **explicitly mandates** the target path
(`:249-251`):

> 2. The item's active feature folder path, written literally as `docs/features/active/<basename>`.
>    The child needs it for its own operation, and F7's Layer 1 hook resolves the target item by
>    scanning the prompt for exactly that path shape, so the path is emitted as a bare path token.

and element 3 (`:252`) is "The canonical issue number line, which is the item key" — the *format*
of that line is not specified in the skill text. Element 5 (`:257`) is
`model_budget.fable_policy: <disabled|available|preferred>.`

Negative obligations at `:263-273`: the parallel prompt **never** carries `Preparation mode: true`
and **never** carries the epic-mode marker line.

### E3. Epic preparation kickoff — `.claude/skills/epic-plan/SKILL.md:97-99`

> `Preparation mode: true. route_id: preparation. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. Perform promotion, research, feature documents (spec.md, user-story.md), atomic planning, and preflight clearance only. Atomic execution, PR authoring, and CI monitoring are out of scope for this run and are executed later by epic-orchestrator. After the atomic-executor preflight returns PREFLIGHT: ALL CLEAR, commit the feature folder and plan to the current branch, set out-of-scope step statuses to not-applicable, set next_step to S5_atomic_execution, and stop, reporting the plan-path and preflight status.`

`:103-105` records that this line **deliberately omits** `Epic mode: true` so the wave-barrier
deterrent does not apply to preparation.

### E4. Parallel preparation kickoff — `.claude/skills/parallel-plan/SKILL.md:105-107`

> `Preparation mode: true. route_id: preparation. parallel_slug: <slug>. Perform promotion, research, feature documents (spec.md, user-story.md), atomic planning, and preflight clearance only. Atomic execution, PR authoring, and CI monitoring are out of scope for this run and are executed later by parallel-orchestrator. After the atomic-executor preflight returns PREFLIGHT: ALL CLEAR, commit the feature folder and plan to the current branch, push the current branch to origin, set out-of-scope step statuses to not-applicable, set next_step to S5_atomic_execution, and stop, reporting the plan-path and preflight status.`
>
> `model_budget.fable_policy: <disabled|available|preferred>.`

`:111` records: "The markers `Preparation mode: true.` and `route_id: preparation.` are reused
verbatim." **These two literals include the trailing period**, and the shipped hook matches them
**with** the period (`enforce-orchestration-preimplementation-gate.ps1:37-40`,
`$script:PreparationModeMarkers`), asserted by an existing test at
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1:383-390`.

### E5. Marker-literal summary table (for the fixed dispatch table)

| Mode | Matched marker literal (as currently matched by shipped hooks) | Canonical checkpoint |
| --- | --- | --- |
| preparation | `Preparation mode: true.` **and** `route_id: preparation.` (both, **with** periods) | none — exempt |
| epic execution | `Epic mode: true` (no period) | `artifacts/orchestration/epic-orchestrator-state.json` |
| parallel execution | `Parallel mode: true` (no period) | `artifacts/orchestration/parallel-orchestrator-state.json` |
| default / single-feature | *(no marker)* | `artifacts/orchestration/orchestrator-state.json` |

The prompt-declared `epic_checkpoint_path:` / `parallel_checkpoint_path:` values are **exactly**
the canonical values above, so the #554 "DENY when the prompt-declared path disagrees with the
mode's canonical path" rule has a well-defined comparison target for both modes.

---

## F. Checkpoint schemas for the new predicates

### F1. `artifacts/orchestration/epic-orchestrator-state.json`

From `scripts/dev_tools/validate_epic_orchestrator_state.py:35-60`:

```python
REQUIRED_BASELINE_KEYS = ("objective", "completed_steps", "next_step", "last_updated")
REQUIRED_EPIC_KEYS = ("route_id", "epic_feature_folder", "integration_branch",
                      "max_parallel_features", "waves", "features")
EXPECTED_ROUTE_ID = "epic"
VALID_MERGE_STATUS = {
    "not_started", "worktree_created", "pr_open", "ci_green",
    "merge_conflict", "blocked_conflict_loop_limit", "merged", "worktree_removed",
}
MERGED_STATUSES = {"merged", "worktree_removed"}
```

- `route_id` must be exactly `'epic'` when present (`:92-99`).
- **`epic_manifest_path` is NOT a required key of the orchestrator checkpoint.** It is a required
  key of the *planner* checkpoint (`scripts/dev_tools/validate_epic_planner_state.py:37`) and is
  cross-checked in `scripts/dev_tools/epic_planner_readiness.py:253,296`. Do not assume it on the
  orchestrator side.
- Per-`features[]` fields read by the validator: `feature_folder` (`:186`, uniqueness-checked
  `:210`), `issue_num` (via `build_feature_reference_index`, `:183`), `depends_on` (`:200`),
  `merge_status` (`:234`), `wave_number` (`:353`). `issue_num` is the **primary key**
  (`.claude/skills/epic-orchestrate/SKILL.md:53-55`); `feature_folder` is "a resolvable hint, not
  a stable identifier" (`:56-58`) and may carry an `active/` or `completed/` lifecycle prefix that
  is stripped to the basename during resolution.
- Top-level `epic_merge_pr` object with `pr_number` and `ci_gate.conclusion`
  (`enforce-epic-merge-gate.ps1:215-241`).

**Pre-merge merge_status members** (i.e. everything not terminal-merged):
`not_started`, `worktree_created`, `pr_open`, `ci_green`, `merge_conflict`,
`blocked_conflict_loop_limit`. The two terminal-safe members are `merged`, `worktree_removed`.

### F2. `artifacts/orchestration/parallel-orchestrator-state.json`

Required top-level keys, from `.claude/rules/parallel-orchestration.md` invariant 1:

`objective`, `completed_steps`, `next_step`, `last_updated`, `route_id`, `parallel_slug`,
`parallel_manifest_path`, `parallel_status_doc_path`, `mode`, `max_concurrency`,
`current_cohort`, `recolor_generation`, `cohorts`, `items`, `conflict_edges`, `mutations`,
`drift_events`.

`route_id` must be exactly `'parallel'` (invariant 2).

Per-`items[]`: `issue_num` (positive int, unique, **the primary key**), `feature_folder`
(non-empty string), `state`, `merge_status`, `blast_radius`, plus `pr_number`, `pr_url`,
`branch_name`, `worktree_path`, `merge_commit_sha`, `merged_at`, `worktree_created_at`,
`worktree_removed_at` (cache-doctrine section).

Enums, from `scripts/dev_tools/_parallel_state_common.py:38-51`:

```python
VALID_ITEM_STATES = ("proposed", "admitted", "prepared", "scheduled",
                     "in_flight", "merged", "withdrawn", "blocked")
VALID_MERGE_STATUS = ("not_started", "worktree_created", "pr_open", "ci_green",
                      "merged", "worktree_removed",
                      "blocked_drift", "blocked_ci_loop_limit")
MERGED_MERGE_STATUSES  = ("merged", "worktree_removed")     # :84
BLOCKED_MERGE_STATUSES = ("blocked_drift", "blocked_ci_loop_limit")  # :88
```

**Pre-merge `merge_status` members:** `not_started`, `worktree_created`, `pr_open`, `ci_green`
(plus the two blocked members, which are terminal-failed, not pre-merge).

**Enum ownership warning.** `.claude/rules/parallel-orchestration.md` → "Enum Ownership (F6/F7/F8
consume, never extend)" fixes all nine parallel enums. A #554 predicate **consumes** these
member sets and must not extend them.

### F3. Committed examples

**There is no committed epic or parallel checkpoint in this repository.** `Glob` over
`artifacts/orchestration/*.json` returns exactly one file:
`artifacts/orchestration/orchestrator-state.json`.

The concrete shapes available to cite are **test fixtures**:

- Epic — `tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1:50-53`:
  ```
  {"features":[
    {"feature_folder":"2026-07-02-child-a-300","depends_on":[],"merge_status":"merged"},
    {"feature_folder":"2026-07-02-child-b-301","depends_on":["2026-07-02-child-a-300"],"merge_status":"not_started"}
  ]}
  ```
  Note `feature_folder` here is a **bare basename**, and the paired prompt at `:55` is
  `"Epic mode: true. epic_feature_folder: epic-orchestrate-275. Upstream context for 2026-07-02-child-b-301: docs/features/active/2026-07-02-child-b-301/spec.md"`.
- Parallel — see `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` and
  `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state*.py` for full-shape
  documents (not read line-by-line in this session).

---

## G. Existing test suites, and the item-13 break analysis

### G1. Suite inventory

| Suite | Lines | `It` blocks | Load mechanism | Fixture shape |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | **461** | **28** | Dot-source (`:6-7`) `Resolve-Path "$PSScriptRoot/../../../.claude/hooks/..."`, then direct `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw <json> -CheckpointRaw <json>` | Nested envelopes `{tool_name, tool_input}` built by three factory functions (`:9-37`); a checkpoint factory `ConvertTo-CheckpointRaw` (`:39-53`) emitting `issue-num`/`feature-folder`/`route_id`/`lifecycle_ready` |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | **267** | **12** `It` declarations, several `-ForEach`-expanded | Dot-source; direct decision call | Bash `{tool_name:'Bash', tool_input:{command}}` only |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | **223** | **5** `It` declarations, all `-ForEach`-expanded (≈31 cases) | Dot-source (`:141-142`); wrapper `Get-GateDecisionFor` (`:170-176`) | Write `{tool_name:'Write', tool_input:{file_path, content}}` only; synthetic absolute prefixes declared at `:32-34` |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | **271** | **12** `It` declarations | Dot-source (`:23-25`); direct decision call at `:61`. Header comment `:10` records that the Codex decision function accepts the **MAPPED** `tool_input` JSON, not an envelope | Command text only |

Two additional suites touch the same hook:

- `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` — 8 `It`
  declarations (`:187-240`), including two apply_patch file-marker cases (`:230`, `:236`).
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:65-69` — asserts that
  `Get-OrchestrationPreimplementationGateBlockDecision -Reason 'Orchestration not ready'`
  emits `hookEventName == 'PreToolUse'` and `permissionDecision == 'deny'`. **This pins the
  `Get-...BlockDecision` signature to a single mandatory `-Reason [string]` parameter.**

### G2. ITEM 13 — pre-existing tests the structural fix could break

**Result: no existing `It` block is unconditionally incompatible, but FIVE are conditionally
incompatible and pin two design decisions the spec must make explicitly.**

All five live in
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`, Context
`'issue #535 preparation-mode delegation exemption'`. Every one of them supplies
`subagent_type = 'orchestrator'` (the factory default at `:322`) and asserts **deny**:

| Line | `It` name | Payload | Why it is at risk |
| --- | --- | --- | --- |
| **365** | `'denies an orchestrator delegation whose prompt matches the implementation regex without the markers'` | `subagent_type='orchestrator'`, prompt = `'Delegate to atomic-executor and begin implementation now.'` | Under a **pure `subagent_type` allow-list** classifier, `orchestrator` is not an implementation agent, so this would flip to **allow** and the test would FAIL. |
| **374** | `'denies an orchestrator delegation carrying only one preparation marker'` | prompt = `'Preparation mode: true. Delegate to atomic-executor and begin implementation now.'` | same |
| **383** | `'denies an orchestrator delegation whose first marker is missing its trailing period'` | prompt = `'Preparation mode: true route_id: preparation. Delegate to...'` | same |
| **392** | `'denies markers placed in a non-prompt field while prompt matches the implementation regex'` | prompt = implementation text, `description` = full parallel kickoff | same |
| **356** | `'denies both markers when subagent_type is not orchestrator'` | `subagent_type='atomic-executor'`, prompt = full parallel kickoff | Survives **only if** `atomic-executor` stays in the implementation-agent set. |

**The two design decisions these tests pin:**

1. **`subagent_type == 'orchestrator'` with NO recognized mode marker must still classify as
   implementation**, evaluated against the default single-feature checkpoint
   `artifacts/orchestration/orchestrator-state.json`. If the fix does this, all four of the
   365/374/383/392 cases keep denying and pass unmodified. If the fix instead treats an
   unmarked `orchestrator` delegation as out of scope (allow), all four break.
2. **The implementation-agent set must retain at minimum `atomic-executor`** (test :356) and
   `powershell-typed-engineer` (the `ConvertTo-DelegationToolInput` default at `:31`, asserted
   deny at `:151-160`). The safest reading is to keep the five agent tokens from the current
   regex — `python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`,
   `csharp-typed-engineer`, `atomic-executor` — as a `subagent_type` **exact-match allow-list**,
   and drop only the two prose tokens `implementation` and `execute`.

**Block-reason assertions — all survive a mode-specific reason string.** The complete set of
reason assertions in the four suites:

- `Should -Match 'PREIMPLEMENTATION_GATE_BLOCKED'` — lines 64, 79, 119, 131, 147, 158, 176, 210,
  297, 307 (this suite), 220 (absolute-paths suite). Satisfied by any reason keeping the prefix.
- `Should -Not -Match '#232'` — lines 65, 120, 159. Satisfied trivially.
- `Should -Match 'route metadata'` **and** `Should -Match 'lifecycle readiness'` — lines 66-67,
  **only** in the `It` at `:57`, whose payload is a **Write** to
  `scripts/dev_tools/validate_orchestrator_state.py`. This is the default/single-feature path.
  **Constraint:** the default-mode block reason must continue to contain the substrings
  `route metadata` and `lifecycle readiness`.
- `Should -Match 'not parseable JSON'` (`:182`) and `Should -Match 'no tool_input key'` (`:189`)
  — payload-anomaly reasons from `Get-ClaudeHookPayloadAnomalyReason`. Unchanged by this fix.

**No existing test asserts the literal string `artifacts/orchestration/orchestrator-state.json`
inside a block reason.** I grep-checked every reason assertion listed above. The current message
names that path (hook `:328`) but nothing pins it. So making the reason name the checkpoint
actually consulted is **free** on the Claude side, provided the default-mode wording keeps
`route metadata` and `lifecycle readiness`.

**Signature constraints (not breaks, but pinned):**

- `Get-OrchestrationPreimplementationGateBlockDecision -Reason [string]` — pinned by
  `PreToolUseSchema.Contract.Tests.ps1:67`.
- `Invoke-OrchestrationPreimplementationGateDecision -ToolInputRaw <s> -CheckpointRaw <s>` —
  pinned by every case in all four suites. **A polymorphic readiness source means `-CheckpointRaw`
  can no longer be the only injection point.** Recommended: keep `-CheckpointRaw` as the
  default-mode override (so all ~60 existing cases keep working byte-identically) and add
  *separate, optional* `-EpicCheckpointRaw` / `-ParallelCheckpointRaw` parameters, or a per-mode
  read seam function that tests `Mock` the way the wave-barrier suite mocks
  `Get-EpicWaveBarrierCheckpointContent`. Reusing `-CheckpointRaw` for all three modes would be
  simplest but makes the "which checkpoint did we consult" assertion untestable.
- `Test-OrchestrationReady -Payload $null | Should -BeFalse` (`:238`) and
  `Test-ImplementationDelegation -ToolInput $null | Should -BeFalse` (`:242`) — **both function
  names and both null-tolerant signatures must survive the refactor.**

**Headroom warning.** The main claude suite is at **461 of 500 lines (39 lines of headroom)**.
Its own header does not say so, but the sibling absolute-paths suite's header does
(`enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1:20-22`): "These cases
live in a new sibling suite rather than in `enforce-orchestration-preimplementation-gate.Tests.ps1`
because that file is already at 461 content lines against the 500-line cap." **New cases must go
in a new sibling suite.**

### G3. ITEM 14 — the Codex `Agent` leg is unreachable

`.codex/config.toml` registers the preimplementation gate on exactly two matchers:

- `matcher = "^Bash$"` (`:120`) → hook at `:136-138`
- `matcher = "^(apply_patch|Edit|Write)$"` (`:186`) → hook at `:220-222`

**There is no `Agent` matcher anywhere in `.codex/config.toml`.** The only tool-name matchers in
the file are `^Bash$` (:120), `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` (:153), and
`^(apply_patch|Edit|Write)$` (:186). The three subagent-lifecycle matchers (:110, :237, :246) are
`SubagentStart`/`SubagentStop` matchers keyed on agent names, not `PreToolUse` tool matchers.
**Issue #555's claim is confirmed.**

Compounding this, the Codex hook's own dispatch tail (codex:359-377) handles only
`Bash`/`apply_patch` (raw `tool_input`) and `Edit`/`Write` (synthesized `{file_path}`); the
comment at `:368-369` states "Any other well-formed tool name maps to no records, so the hook
allows."

**Conclusion: test-matrix case 10 (a Codex-surface `Agent` delegation) is NOT reachable.**
Honest alternatives, in decreasing order of value:

1. **Unit-test the shared predicates directly** on the Codex copy — dot-source
   `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and call the new
   classification/readiness functions with constructed inputs, exactly as the existing Codex
   command-exemption suite dot-sources and calls `Invoke-OrchestrationPreimplementationGateDecision`
   (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:23-25,61`).
   This proves parity of logic without claiming a reachable transport.
2. **Assert the unreachability explicitly** — a test that reads `.codex/config.toml` and asserts
   no `PreToolUse` matcher admits an `Agent`/`Task` tool name, so the gap is recorded as a
   deliberate, tested fact rather than an oversight, with a cross-reference to issue #555.
3. **Do not** author a Codex suite that fabricates an `Agent` envelope and asserts a decision;
   that would assert behaviour on a code path the runtime never exercises.

A new Codex-side suite would go at `tests/scripts/codex-hooks/` (the directory is already in the
Pester scan set — see H1).

---

## H. Toolchain

### H1. PowerShell QC invocation

`.claude/rules/powershell.md:13-20`:

> 1. **Formatting — Invoke-Formatter**: ... MCP command: `mcp__drm-copilot__run_poshqc_format`
> 2. **Linting — PSScriptAnalyzer**: ... MCP command: `mcp__drm-copilot__run_poshqc_analyze`.
>    Optional autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`
> 3. **Type checking**: Not applicable for PowerShell; skip to testing.
> 4. **Testing — Pester (v5.x)**: ... MCP command: `mcp__drm-copilot__run_poshqc_test`.
>    Use repo config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
>
> Run the toolchain in order: format → analyze → test. Restart from step 1 if any step fails or
> changes files. Use the MCP server functions; do not substitute VS Code task wrappers.

**Scan folders.** `config/poshqc-scan.json` (6 lines):

```json
{ "version": 1, "test": { "scanFolders": ["scripts", "tests/powershell", "tests/scripts"] } }
```

and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:3`:

```powershell
Path = @('scripts', 'tests/powershell', 'tests/scripts')
```

**`tests/scripts` is in the set, so both `tests/scripts/claude-hooks` and
`tests/scripts/codex-hooks` are covered.** They are covered by tree inclusion, not by a named
entry; no per-directory registration is needed for a new suite in either directory.

**Known-issue workaround (MCP runner reads installed-extension settings).** The direct
self-hosted invocation is:

```powershell
Import-Module <repo>/scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCTest -Root <repo> -SettingsPath <repo>/scripts/powershell/PoshQC/settings/pester.runsettings.psd1
```

`Invoke-PoshQCTest` is defined at `scripts/powershell/PoshQC/PoshQC.Testing.psm1:151`, with
parameters `-Root`, `-ScanFolders`, `-SettingsPath` (defaulting to `$script:PesterSettings`),
`-ExcludeDirs`, `-KoverageOutputPath`, `-DisableKoverageCopy`, plus seven injectable scriptblock
seams (`:160-205`). Formatting and analysis are `Invoke-PoshQCFormat`
(`PoshQC.Analyzer.psm1:15`), `Invoke-PoshQCAnalyze` (`:83`), `Invoke-PoshQCAnalyzeAutofix`
(`:203`). This alternative was **not executed** in this session.

### H2. Coverage configuration

`CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:23-235` is an
**explicit per-file allow-list**, not a glob over `.claude/hooks/**` or `.codex/hooks/**`. There
is **no directory wildcard** for either hooks tree. All four files in scope are already listed:

| Entry | Line | Registering comment |
| --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 131 | issue #415 remediation cycle 1 (R1) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 135 | issue #539 headroom split |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 202 | issue #501 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 206 | issue #539 headroom split |

`CoveragePercentTarget = 0` (`:237`) — the Pester run does **not** fail on percentage; the
coverage threshold in `.claude/rules/quality-tiers.md` (line ≥ 85%, no branch gate for
PowerShell) is enforced elsewhere.

**Consequence for the fix:** if the fix adds a **new** `.ps1`/`.psm1` production file, it must be
appended to this list **and** to the bundled mirror, or the new production file sits outside the
coverage denominator, which `.claude/rules/general-unit-test.md` → Coverage Exclusion Policy
forbids and which feature-review must treat as **Blocking**.

**Current line-coverage headline for these four files: NOT DETERMINABLE without a run.** The
canonical artifact is `artifacts/pester/powershell-coverage.xml` (`:22`), which is a run output
and is not committed. I did not run Pester.

### H3. Change-budget constraint to surface

`.claude/rules/powershell.md:37-41`:

> - Direct-mode overall scope: up to 2 production PowerShell files (plus corresponding tests).
>   Requests exceeding this must be routed to `powershell-orchestrator` per
>   `powershell-change-budget-router`.
> - Per-batch cap in all modes: at most 3 production files and 3 test files unless an explicit
>   override has been approved.

The blast radius below writes **8 production `.ps1` files** (4 logical files × 2 copies each).
Even treating each mirror as a mechanical copy, the logical production count is 4 — above the
direct-mode cap of 2 and at/above the per-batch cap of 3. **The plan must sequence this into
batches or record an approved override.**

---

## I. ITEM 17 — concrete blast-radius path list

All paths are repo-relative from the workspace root. Split into (a) certain, (b) conditional on
a design decision, (c) documentation.

### I.a Production files — CERTAIN (8 files, 4 logical × 2 copies)

Assuming the new mode-dispatch + readiness predicates land in the **existing** helpers sibling
(151 lines of headroom, and the file is identical on both surfaces, so one authored change lands
four times):

1. `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
2. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
3. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
4. `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
5. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
6. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
7. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
8. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

**Caveat on files 2/4/6/8.** The helpers file's own header (lines 4-10) declares it *pure string
logic, no disk access*, and its `.DESCRIPTION` names issue #539's D4 rule table as its normative
contract. Adding a checkpoint **read** there would violate that declared contract. Two clean
options, both of which the spec must choose between explicitly:

- **Option A (recommended):** put the *pure* parts (mode-marker table, marker→canonical-path map,
  the `subagent_type` allow-list, the three readiness predicates, which take an already-parsed
  checkpoint object) in the existing helpers file and amend its header; keep the *read seams*
  (`Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent`) in the main hook. Main hook has
  118 lines of headroom — enough for two ~12-line read seams plus dispatch.
- **Option B:** create a new dot-sourced sibling, which adds four more files (see I.b).

### I.b Production files — CONDITIONAL on Option B (4 more files)

9. `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` *(name illustrative)*
10. `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
11. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
12. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`

### I.c Config / manifest files — CONDITIONAL, triggered ONLY by a new production file (I.b)

13. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — append the two new
    `CodeCoverage.Path` entries.
14. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` —
    **must be updated identically**; pinned to exact text parity by
    `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16,80-81`.
15. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — add
    `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (the existing two
    entries are at `:35-36`).
16. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` —
    add `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`; required by
    `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`
    unless added to `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` (which would be wrong — the
    exception list is for pre-existing unrelated files).

**Under Option A, items 13-16 are NOT touched.** No config change is needed because all four
files in scope are already registered for coverage and in the pack manifests.

### I.d Test files — NEW (2 files)

17. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
    — **must be a new sibling**; the existing suite has only 39 lines of headroom (G2).
18. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
    — direct-predicate parity cases plus the config.toml unreachability assertion (G3).

Both directories are already inside the Pester scan set (H1); no registration needed.

### I.e Test files — MODIFIED

**None.** Per the G2 analysis, all four existing suites pass unmodified **provided** the two
design decisions in G2 are taken (unmarked `orchestrator` → default mode → deny; agent allow-list
retains `atomic-executor` and the four typed-engineer names) and the default-mode block reason
retains the substrings `route metadata` and `lifecycle readiness`.

### I.f Documentation — CONDITIONAL

19. `.claude/skills/epic-orchestrate/SKILL.md` and
20. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`
    — **only if** the spec decides to close the E1 gap by mandating that the epic child kickoff
    prompt carry the child's `docs/features/active/<basename>` token (the parallel contract
    already mandates this at `parallel-orchestrate/SKILL.md:249-251`). Both copies must change
    together: `.claude/**` is inside the byte-parity scope
    (`test_push_down_claude_resource_contracts.py:20,101-126`).

### I.g Feature documents and evidence (this feature's own folder)

21. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` *(currently
    an unfilled template — 100 lines of boilerplate)*
22. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/plan.<ts>.md`
23. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/research/2026-08-26T09-30-preimplementation-gate-epic-execution-554-research.md` *(this file)*
24. `docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/<kind>/...`
    per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`

---

## J. Recommended approach (one, with alternatives rejected briefly)

### Recommendation

**Marker-keyed dispatch with a fixed four-row table, three readiness predicates, and per-mode
read seams — logic in the existing helpers sibling (Option A), read seams in the main hook.**

Shape:

```
Test-ImplementationDelegation(toolInput):
  subagentType := Get-...String(toolInput, 'subagent_type')     # field-scoped
  prompt       := Get-...String(toolInput, 'prompt')            # field-scoped
  if subagentType in {python-typed-engineer, powershell-typed-engineer,
                      typescript-engineer, csharp-typed-engineer, atomic-executor}: implementation
  if subagentType != 'orchestrator': not implementation (allow)
  mode := Resolve-OrchestrationDelegationMode(prompt)           # fixed table, prompt field only
  if mode == preparation: not implementation (allow)
  else: implementation, with readiness source = table[mode].checkpointPath
```

Why this shape:

- It **preserves all five at-risk tests** (G2) because an unmarked `orchestrator` falls to the
  default row.
- It **removes the two prose tokens** `implementation` and `execute` that caused Fault 1, and
  removes the whole-payload `ConvertTo-Json` scan that made a `description` field able to change
  classification.
- It matches the **fixed-constant posture** of all six precedent hooks (C, D) and satisfies
  #554's explicit prohibition on parsing a path out of the prompt.
- The prompt-declared `epic_checkpoint_path:` / `parallel_checkpoint_path:` value is used **only
  as a cross-check that must equal the table value, otherwise DENY** — never as the source. Both
  canonical values are confirmed emitted (E1, E2).
- Option A keeps the file count at 8 and touches **zero** config or manifest files.

### Rejected alternatives

- **Keep the substring regex and just add `execution` to it.** Rejected: it fixes one wording
  and leaves classification dependent on prompt prose, which is Fault 1 itself. It also leaves
  Fault 2 entirely unaddressed.
- **Read the checkpoint path from `epic_checkpoint_path:` in the prompt.** Rejected: #554
  explicitly forbids it, and it would let a delegation choose its own gate.
- **Extract a shared `.claude/lib/orchestration-mode/` module used by all seven hooks.**
  Rejected for this fix: it converts a bug fix into a seven-hook refactor, contradicts the
  measured absence of any such module today (D), multiplies the blast radius across
  `enforce-epic-wave-barrier`, `enforce-parallel-cohort-barrier`, `enforce-parallel-drift-gate`,
  and their four mirrors, and would collide with the Codex copies' different root-resolution
  posture. Worth filing as a separate follow-up.

---

## K. Test strategy implications (no test code written here)

- **Positive, per mode:** epic kickoff prompt + ready epic checkpoint → allow; parallel kickoff +
  ready parallel checkpoint → allow; unmarked orchestrator + ready single-feature checkpoint →
  allow (already covered at `:162-169` for the Write path).
- **Negative, per mode:** epic kickoff + missing/unparseable/not-ready epic checkpoint → deny,
  with the reason naming `artifacts/orchestration/epic-orchestrator-state.json` and the failed
  predicate. Same for parallel.
- **Cross-check:** epic kickoff whose `epic_checkpoint_path:` value differs from the canonical
  value → **deny** (per #554).
- **Field-scoping:** epic marker planted in `description` while `prompt` carries no marker →
  default mode (deny against the single-feature checkpoint), mirroring the existing `:392` case.
- **Classification:** each of the five allow-listed `subagent_type` values → implementation; a
  prompt containing the bare words `implementation` / `execute` with a non-implementation
  `subagent_type` → **allow** (this is the Fault-1 regression case and it is a *new* allow, so
  it must be asserted explicitly).
- **Determinism:** all fixtures are literal strings; no temp files (prohibited by
  `.claude/rules/general-unit-test.md`), no wall-clock, no filesystem. Checkpoint content is
  injected through the decision function's parameters or a `Mock`ed read seam, following
  `enforce-epic-wave-barrier.Tests.ps1:49-54`.
- **Codex parity:** direct-predicate cases only, plus a config.toml unreachability assertion
  (G3).
- **Coverage:** all four production files are already in `CodeCoverage.Path`; under Option A no
  coverage-config change is needed, and the new suites raise measured coverage on the changed
  lines.

---

## L. Open questions the spec must settle

1. **Option A vs Option B** for where the new logic lives (I.a caveat) — this decides whether
   four config/manifest files enter the blast radius.
2. **How the readiness source is injected for tests** — reuse `-CheckpointRaw` for all modes
   (simple, but makes "which checkpoint was consulted" untestable) vs per-mode read seams that
   tests `Mock` (matches the wave-barrier precedent, costs ~24 lines of the main hook's 118).
3. **Whether to close the E1 epic-kickoff gap** (no mandated child feature-folder token for a
   wave-0 child). If the epic readiness predicate resolves its target the way
   `enforce-epic-wave-barrier.ps1` does, it inherits the same latent deny. If it instead resolves
   by `issue_num`, note that the epic kickoff marker line carries **no** `issue_num:` key at all.
4. **The change-budget override** (H3): 4 logical production PowerShell files exceeds the
   per-batch cap of 3.
5. **What the honest Codex deliverable is** for test-matrix case 10 (G3), given the `Agent`
   matcher does not exist and issue #555 owns that gap.
