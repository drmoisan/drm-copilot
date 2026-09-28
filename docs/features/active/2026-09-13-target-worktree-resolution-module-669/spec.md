# 2026-09-13-target-worktree-resolution-module — Spec

- **Issue:** #669
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T21-40
- **Status:** Draft
- **Version:** 0.2
- **Epic:** `docs/features/epics/worktree-scoped-state-resolution/epic.md` (F1, wave 0, complexity C3, no dependencies)
- **Research:** `docs/features/active/2026-09-13-target-worktree-resolution-module-669/research/2026-09-13T21-15-target-worktree-resolution-module-research.md`
- **Work Mode:** `full-feature` (`spec.md` and `user-story.md` are both authoritative acceptance-criteria sources)

## Overview

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

Verified 2026-09-13 against this tree: `.claude/lib/` holds eleven module directories (`bash`,
`blast-radius`, `cleanup-manifest`, `codex-routing`, `discovery-validation`, `hook-payload`,
`mermaid`, `model-routing`, `orchestrator-state`, `project-file-merge`, `requirements`) and none of
them resolves a worktree or a call target. There is no shared primitive for downstream gates to
consume. The count and the member set were derived twice by independent enumerations and agree
(research, N1 and N2).

**What F1 delivers, stated precisely.** F1 delivers the resolution primitive and its tests, and **no
consumers**. No hook is edited. No MCP tool is edited. No existing gate's behaviour changes. No
existing call site that today spells `artifacts/orchestration/orchestrator-state.json` relative to
cwd is rewired. After F1 merges, the repository contains a new, fully tested, registered, and
mirrored `.claude/lib/` module that nothing yet calls. Rewiring is the scope of F4
(`prd-feature-gate-target-resolution`) and F5
(`false-approval-elimination-pr-author-model-routing`), which are specified against this contract
and cannot be written until it exists. That is the dependency edge that makes the epic wave-layered.

The contract has three parts, per the epic's shared design:

1. **Target derivation** — given the signals available in a tool-call payload, return the worktree
   the call pertains to, or an explicit "no target" result, or an explicit "ambiguous" result.
2. **Path normalisation** — given a path in relative or absolute form, return its repo-relative form
   by locating the containing worktree. Fixed segment-count truncation is prohibited.
3. **Ambiguity reason code** — a single distinct, greppable literal emitted when the correct target
   cannot be identified, so a caller denies with a specific reason instead of falling back to
   whatever checkpoint occupies the session root.

## Correction to the Epic's Characterisation of the F4 Defect Site

The epic manifest states (`epic.md:101-103`, `epic.md:289-293`) that the absolute-path prefix is
discarded by a four-segment truncation applied at line 265 of
`.claude/hooks/enforce-prd-feature-before-planner.ps1`. The research re-read that file in full
against the current tree and found that characterisation inaccurate in two respects. Both
corrections are recorded here so F4's author inherits them, even though F1 changes nothing in that
file.

- **The prefix is discarded one step earlier, by the regex at line 252.** The pattern
  `'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'` is unanchored and begins matching at the
  literal `docs`. Given the prompt token
  `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-13T08-30/docs/features/active/<feature>/spec.md`,
  the match value is already `docs/features/active/<feature>/spec.md`. The absolute worktree prefix
  never enters the candidate string at all.
- **Line 265 is a comment; the slice at lines 272-277 removes a suffix, not a prefix.** Line 265 is
  the first line of the explanatory comment. The executable segment split is at line 272, the
  four-segment guard at line 273, and the slice `$segments[0..3]` at line 277. That slice discards
  the trailing `spec.md` or a `v1/` version folder. It does not discard a leading drive or worktree
  path, because by that point there is none to discard.
- The epic's line references for the documentation of the truncation are also off by one: the
  sentence spans lines 17-19, not 16-18. Lines 189, 219, 91, 108, and 201, and the 448-line file
  length, were re-verified and hold exactly.

**Why this determines an F1 requirement.** Because the prefix loss happens at extraction time, a
correct fix cannot be confined to normalisation. F1's feature-folder signal extractor must
**preserve any absolute prefix present in the token** rather than re-deriving a bare repo-relative
token and handing that to the normaliser. If F1 reproduced the anchored-at-`docs` extraction, the
normaliser would receive a relative token in every case and Ruling A would force `Ambiguous`
everywhere, leaving F4 no better off.

## Settled Rulings

The research closed with four open questions. The orchestrator has settled them. They are recorded
here with their rationale so the planner does not reopen them.

### Ruling A — relative path with no supplied root: fail closed

`ConvertTo-WorktreeResolutionRepoRelativePath` accepts an optional `-WorktreeRoot`. Given a relative
input and no `-WorktreeRoot`, the result is the **unresolved** form: `IsNormalized = $false`,
`RepoRelativePath = $null`, `WorktreeRoot = $null`, `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`. It
must **not** return the input unchanged as if it had been normalised.

**Rationale.** Returning a bare relative path unchanged reproduces exactly the behaviour that the
eleven cwd-relative `artifacts/orchestration/orchestrator-state.json` call sites already exhibit
(`enforce-completion-consistency.ps1:300`, `enforce-epic-merge-gate.ps1:48`,
`enforce-model-routing-receipt.ps1:46`, `enforce-orchestration-preimplementation-gate.ps1:27,35`,
`enforce-orchestration-preimplementation-gate-modes.ps1:60`,
`enforce-pr-author-skill.epic-base-branch.ps1:35`, `enforce-prd-feature-before-planner.ps1:198`,
`enforce-pr-author-skill.ps1:49`, `validate-orchestrator-output.ps1:32,319`,
`.claude/lib/orchestrator-state/OrchestratorState.psm1:427`). A bare relative path handed to
`Test-Path -LiteralPath` resolves against the hook process's current directory. That is the defect.
A primitive whose "success" path returns the defect is not a fix.

### Ruling B — signal precedence: never consult run state to disambiguate

F1 never reads a checkpoint, and never reads orchestrator state of any kind, to disambiguate.

- If two present signals resolve to **different** worktree roots, the result is `Ambiguous`.
- If two present signals resolve to the **same** root, that is a single distinct candidate and
  resolves normally.
- A documented precedence order exists — `FeatureFolderPath`, then `FilePath`, then `Branch` — and
  it governs **only** which signal kind is reported in the result's `Signal` and `SignalValue`
  fields when the present signals agree. It is a reporting order, not a tie-break. It never
  suppresses a genuine disagreement.

**Rationale.** The current prd-feature hook prefers the checkpoint as a disambiguator
(`enforce-prd-feature-before-planner.ps1:294-302`). Under a parallel topology that checkpoint is the
session root's, which belongs to a different item. Consulting it to break a tie is precisely the
false-approval mechanism the epic exists to eliminate (`epic.md:57-64`). A precedence order that
silently picked one of two disagreeing signals would rebuild the same mechanism with a different
input.

### Ruling C — the module includes a worktree enumerator

The enumerator is **in scope**. This is the consequential ruling of the four.

**Rationale.** Without an enumerator, F1 cannot serve F4's headline allow case, and the epic
acceptance criterion "A parallel orchestrator whose cwd is the session root can delegate
`Agent(atomic-planner)` for an item whose `spec.md` exists" (`epic.md:336-337`) would be
unreachable. A delegation prompt that names a feature folder in relative form names a folder that
lives in *some* worktree, and — per the Q2 correction above — the relative form is the common form.
The only way to identify which worktree holds it, without a git subprocess and without reading
someone else's checkpoint, is to enumerate the worktrees reachable from the session root and test
containment in each. Narrowing `Ambiguous` to "signal present, containing worktree not locatable"
would save roughly 40 lines in File 1 and would make F4's primary case permanently undecidable.

Enumeration is derivable from the session root with no git subprocess, using the mechanism the
research verified by direct file reads:

- If the session root's `.git` is a **directory**, the session root is the main checkout. Enumerate
  `<sessionRoot>/.git/worktrees/*/gitdir`.
- If the session root's `.git` is a **file**, read its `gitdir: <path>` line to reach
  `<main>/.git/worktrees/<name>/`, then read that directory's `commondir` file (verified to contain
  `../..`) to reach the main `.git` directory, then enumerate its `worktrees/*/gitdir`.
- Each `gitdir` file contains the path to a worktree's own `.git` **file**; that worktree's root is
  that file's parent directory.
- **The main checkout itself is a member of the candidate set**, not only the linked worktrees.

Candidate resolution outcomes: exactly one containing worktree resolves; two or more is `Ambiguous`;
zero is `Ambiguous`.

Enumeration requires a **third** injectable seam for directory listing, alongside the two the
research proposed. The three seams are named in Implementation Strategy and are the module's only
filesystem contact.

### Ruling D — treat the MCP PoshQC coverage-path gotcha as live until disproved

A prior project memory records that `mcp__drm-copilot__run_poshqc_test` resolves its runsettings from
the **installed VS Code extension**, not from either in-repo copy, so a newly added
`CodeCoverage.Path` entry produces no coverage row until the extension is rebuilt and reinstalled.
**This was not re-verified during research** — the research session had no shell and could not invoke
the MCP tool — and it is therefore treated as unverified but live.

Consequences for this feature:

- The `CodeCoverage.Path` entries are required in **both** in-repo runsettings copies
  (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`). That
  obligation stands independently of the gotcha, because
  `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18` requires the two copies to be
  text-identical.
- Coverage is measured by **direct self-hosted module invocation**, not by the MCP runner:
  `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib')`.
  `PoshQC.Testing.psm1:156` defaults `SettingsPath` to a module-root-derived value, so the
  self-hosted module reads the self-hosted settings and honours entries added in the same change.
- A missing coverage row from the MCP runner is a **tooling-path symptom, not a coverage failure**,
  and must not be treated as evidence that the registration was omitted.
- `CoveragePercentTarget = 0` (`pester.runsettings.psd1:285`). A green PoshQC run is therefore
  **not** evidence that the 85% line-coverage threshold was met. The threshold must be read from
  `artifacts/pester/powershell-coverage.xml`, keyed on the enclosing `package` element (the full
  directory path), never on the bare `sourcefile` name.

## Behavior

Introduce `.claude/lib/worktree-resolution/`, the repository's first worktree/target resolution
primitive, as two PowerShell modules. The module locates a containing worktree by an upward walk for
a `.git` entry, enumerates the sibling worktree set from the session root, normalises paths between
absolute and repo-relative form without truncation, derives a four-state call target from payload
signals, and publishes one ambiguity reason code.

All filesystem contact passes through three named seams. Everything else in the module is pure.

## Inputs / Outputs

**Inputs.** The module takes only in-memory values passed by its caller. It reads no environment
variable, no configuration file, no orchestrator state, and no checkpoint. It has no CLI surface and
no flags.

| input | supplied by | form |
| --- | --- | --- |
| a prompt or payload string to scan for signals | caller (F4, F5) | `string` |
| an explicit branch name | caller | `string` |
| an explicit file path | caller | `string` |
| a path to normalise | caller | `string`, relative or absolute, either separator |
| an optional worktree root to normalise against | caller | `string` |
| the session root | derived internally from the process's current directory via the locator | `string` |

**Outputs.** Two `[pscustomobject]` result shapes and two scalar helpers. No file is written, no log
is emitted, no telemetry is recorded, and no process is started.

**Config keys and defaults.** None. The module owns no configuration. Its only constants are
script-scoped literals declared in its own source: the `.git` entry name, the `gitdir:` line prefix,
the `commondir` file name, the ambiguity reason code, the four `Status` literals, the four `Signal`
literals, and a maximum ascent depth guard.

**Versioning and backward compatibility.** The module is new and has no callers at merge time, so
there is no backward-compatibility constraint to preserve within F1. From F4 onward the field names,
the four `Status` literals, the four `Signal` literals, and the `TARGET_WORKTREE_AMBIGUOUS` literal
are a consumed contract; changing any of them is a breaking change to F4 and F5 and must update both
callers in the same change.

## API / CLI Surface

There is no CLI surface. The public surface is the exported function set of two modules.

### `.claude/lib/worktree-resolution/WorktreeResolution.psm1`

| function | parameters | returns |
| --- | --- | --- |
| `Get-WorktreeResolutionGitEntryKind` | `-Path [string]` (mandatory) | `string`: `'Directory'`, `'File'`, or `'None'` |
| `Get-WorktreeResolutionGitFileText` | `-Path [string]` (mandatory) | `string` or `$null` |
| `Get-WorktreeResolutionDirectoryChildName` | `-Path [string]` (mandatory) | `string[]`, always an array, possibly empty |
| `ConvertTo-WorktreeResolutionNormalizedPath` | `-Path [string]` (mandatory) | `string` or `$null` |
| `Test-WorktreeResolutionRootMarker` | `-Path [string]` (mandatory) | `bool` |
| `Find-WorktreeResolutionRoot` | `-Path [string]` (mandatory), `-MaximumDepth [int]` (optional) | `string` or `$null` |
| `Get-WorktreeResolutionWorktreeRoot` | `-SessionRoot [string]` (mandatory) | `string[]`, always an array, the candidate worktree set including the main checkout |
| `ConvertTo-WorktreeResolutionRepoRelativePath` | `-Path [string]` (mandatory), `-WorktreeRoot [string]` (optional) | normalisation result object (below) |
| `Join-WorktreeResolutionPath` | `-WorktreeRoot [string]` (mandatory), `-RepoRelativePath [string]` (mandatory) | `string`, absolute, forward slashes |
| `Get-WorktreeResolutionAmbiguityReasonCode` | none | `string`, the literal `TARGET_WORKTREE_AMBIGUOUS` |

The three seams (`Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`,
`Get-WorktreeResolutionDirectoryChildName`) are exported so a Pester suite can mock them with
`Mock -CommandName <seam> -ModuleName 'WorktreeResolution'`, following the
`CleanupWorktreeManifest.psm1:70-108` precedent.

### `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`

| function | parameters | returns |
| --- | --- | --- |
| `New-WorktreeResolutionTargetResult` | `-Status [string]` (mandatory), `-SessionRoot [string]` (mandatory), `-WorktreeRoot [string]` (optional), `-Signal [string]` (optional), `-SignalValue [string]` (optional), `-Candidate [string[]]` (optional), `-Detail [string]` (mandatory) | target result object (below) |
| `Find-WorktreeResolutionFeatureFolderSignal` | `-Text [string]` (mandatory) | `string` or `$null`, the matched token **with any absolute prefix preserved** |
| `Find-WorktreeResolutionBranchSignal` | `-Text [string]` (mandatory) | `string` or `$null` |
| `Find-WorktreeResolutionFilePathSignal` | `-Text [string]` (mandatory) | `string` or `$null` |
| `Resolve-WorktreeCallTarget` | `-Text [string]` (optional), `-Branch [string]` (optional), `-FilePath [string]` (optional), `-SessionRoot [string]` (optional; defaults to the locator's answer for the process's current directory) | target result object (below) |

`Resolve-WorktreeCallTarget` is the flagship. It imports `WorktreeResolution.psm1` at column 0 with
`-ErrorAction Stop`, as `ClaudeLibModuleConvention.Tests.ps1:69-86` requires.

### Target result shape

Always a `[pscustomobject]`. **Never `$null`**, following the `ConvertTo-ClaudeHookPayloadResult`
precedent (`HookPayload.psm1:113-146`), so no caller needs a null check before reading a field.

| field | type | meaning |
| --- | --- | --- |
| `Status` | `string` | exactly one of `'SessionRoot'`, `'OtherWorktree'`, `'NoTarget'`, `'Ambiguous'` |
| `WorktreeRoot` | `string` or `$null` | the resolved target worktree root: absolute, forward slashes, no trailing slash. Populated for `SessionRoot` and `OtherWorktree`; `$null` for `NoTarget` and `Ambiguous` |
| `SessionRoot` | `string` | **always populated.** The worktree containing the invoking process, resolved by the same locator. This is the documented fallback for `NoTarget` |
| `Signal` | `string` or `$null` | which signal produced the target: `'FeatureFolderPath'`, `'Branch'`, `'FilePath'`, or `'SessionRoot'`. `$null` for `NoTarget`. For `Ambiguous`, the signal kind that was present but unresolvable |
| `SignalValue` | `string` or `$null` | the raw token the signal was read from, verbatim, for the deny message |
| `Candidates` | `string[]` | **always an array**, possibly empty. Distinct candidate worktree roots considered |
| `ReasonCode` | `string` or `$null` | exactly `'TARGET_WORKTREE_AMBIGUOUS'` when `Status -eq 'Ambiguous'`; `$null` in every other state |
| `Detail` | `string` | **always a non-empty string.** A prose clause safe to concatenate into a `permissionDecisionReason` |

### The four states, with exact field values

| # | condition | `Status` | `WorktreeRoot` | `SessionRoot` | `Signal` | `SignalValue` | `Candidates` | `ReasonCode` | `Detail` | caller action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | a target signal is present and its containing worktree is the worktree the process is running in | `'SessionRoot'` | equal to `SessionRoot` | populated | the signal kind that resolved | the raw token | exactly 1 element, equal to `WorktreeRoot` | `$null` | non-empty | resolve state against `WorktreeRoot`; **identical to today's behaviour** |
| 2 | a target signal is present and resolves to a different worktree | `'OtherWorktree'` | that worktree's root | populated | the signal kind that resolved | the raw token | exactly 1 element, equal to `WorktreeRoot` | `$null` | non-empty | resolve state against `WorktreeRoot` |
| 3 | the payload carries **no** target signal at all | `'NoTarget'` | `$null` | populated | `$null` | `$null` | empty array | `$null` | non-empty | fall back to `SessionRoot` — the epic's "use the session root only when the call genuinely has no target" (`epic.md:99-100`) |
| 4 | a target signal **is** present but the correct worktree cannot be identified | `'Ambiguous'` | `$null` | populated | the signal kind that was present | the raw token | 0 elements, or 2 or more | `'TARGET_WORKTREE_AMBIGUOUS'` | non-empty, naming the signal value and the candidate set | **deny**, concatenating `ReasonCode` and `Detail` into the gate's reason |

The state-3/state-4 boundary is the most consequential line in the contract: **the presence of a
signal, not the success of resolving it, is what separates them.** A payload that names nothing is
`NoTarget` and is safe to serve from the session root. A payload that names something the module
cannot place is `Ambiguous` and must deny. Collapsing the two reintroduces the false-approval mode.

`SessionRoot` is a separate always-populated field rather than being returned in `WorktreeRoot` for
state 3, because a caller that branched only on `$null -ne $result.WorktreeRoot` would otherwise
treat an untargeted call as a resolved one, and the distinction the epic depends on would be
unenforceable from the object.

### `Ambiguous` sub-cases

Every one of these maps to state 4:

- A repo-relative feature-folder token, with no worktree prefix, whose folder exists in **two or
  more** candidate worktrees (`Candidates.Count >= 2`).
- A repo-relative feature-folder token whose folder exists in **no** candidate worktree reachable
  from the session root (`Candidates.Count -eq 0`). A signal was present, so this is not `NoTarget`.
- An absolute path whose upward walk finds no `.git` entry before the filesystem root.
- A branch signal that matches no worktree, or that matches more than one.
- **Two or more present signals that resolve to different worktree roots** (Ruling B). Two present
  signals that resolve to the same root deduplicate to one candidate and resolve normally.

### Normalisation result shape

Returned by `ConvertTo-WorktreeResolutionRepoRelativePath`. Always a `[pscustomobject]`, never
`$null`.

| field | type | meaning |
| --- | --- | --- |
| `IsNormalized` | `bool` | whether a containing worktree was located and a repo-relative remainder produced |
| `RepoRelativePath` | `string` or `$null` | forward slashes, no leading `./`, no trailing `/`. **Never truncated to a fixed segment count and never shortened at all**: the full remainder below the worktree root is preserved |
| `WorktreeRoot` | `string` or `$null` | the located containing worktree root, absolute, forward slashes, no trailing slash |
| `ReasonCode` | `string` or `$null` | `'TARGET_WORKTREE_AMBIGUOUS'` exactly when `IsNormalized` is `$false`; `$null` otherwise |
| `Detail` | `string` | always populated |

Behaviour by input form:

| input | `-WorktreeRoot` supplied | result |
| --- | --- | --- |
| absolute path inside a locatable worktree | irrelevant | `IsNormalized = $true`; `WorktreeRoot` = located root; `RepoRelativePath` = full remainder |
| absolute path with no `.git` entry found on the ascent | irrelevant | `IsNormalized = $false`; `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'` |
| relative path | yes | `IsNormalized = $true`; `WorktreeRoot` = the supplied root, normalised; `RepoRelativePath` = the normalised input |
| relative path | no | **Ruling A**: `IsNormalized = $false`; `RepoRelativePath = $null`; `WorktreeRoot = $null`; `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'` |

One reason code is reused across both halves of the contract: a path whose containing worktree
cannot be located *is* the case "the correct target cannot be identified", which satisfies the
issue's requirement of **a single** distinct greppable code.

### The ambiguity reason code

The literal is `TARGET_WORKTREE_AMBIGUOUS`. It is a **cause** code, not a gate code: F1 owns no
gate, so it must not carry the `_BLOCKED` suffix, which the repository reserves for a hook's own
leading token. It belongs to the same family as `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`,
`PR_CONTEXT_MISSING`, and `EPIC_BASE_BRANCH_MISMATCH`. Verified by two ripgrep passes over the whole
repository, one case-sensitive and one case-insensitive: the literal occurs zero times today.

It is surfaced on three coordinated surfaces, mirroring the `HookPayload` precedent:

1. on the result object, as `ReasonCode`;
2. from the accessor `Get-WorktreeResolutionAmbiguityReasonCode`, so F4 and F5 never hard-code it a
   second time (mirrors `Get-ClaudeHookPayloadAnomalyCode`, `HookPayload.psm1:66-85`);
3. as prose on `Detail`, so a caller can concatenate directly.

### Worked example: how F4 composes a deny reason

A parallel orchestrator whose cwd is worktree `W_session` delegates
`Agent(subagent_type='atomic-planner')` with a prompt naming
`docs/features/active/2026-09-13-some-item-700/`. That folder exists in two of the session's sibling
worktrees. F4's rewired hook calls:

```powershell
$target = Resolve-WorktreeCallTarget -Text $prompt
```

and receives:

```
Status       = 'Ambiguous'
WorktreeRoot = $null
SessionRoot  = 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-13T08-30'
Signal       = 'FeatureFolderPath'
SignalValue  = 'docs/features/active/2026-09-13-some-item-700'
Candidates   = @('C:/Users/DanMoisan/repos/drm-copilot', 'C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-12T11-02')
ReasonCode   = 'TARGET_WORKTREE_AMBIGUOUS'
Detail       = "feature folder token 'docs/features/active/2026-09-13-some-item-700' matched 2 candidate worktrees; supply an absolute path to disambiguate"
```

F4 then writes, with no new logic:

```powershell
permissionDecisionReason = 'PRD_FEATURE_BLOCKED: ' + $target.ReasonCode + ' - ' + $target.Detail
```

producing `PRD_FEATURE_BLOCKED: TARGET_WORKTREE_AMBIGUOUS - feature folder token '...' matched 2
candidate worktrees; supply an absolute path to disambiguate`. The result is greppable by either
token and consistent with the repository's two-family reason-code convention. F5 substitutes its own
gate prefix (`PR_AUTHOR_SKILL_BLOCKED:` or `MODEL_ROUTING_RECEIPT_BLOCKED:`) and changes nothing
else.

Contrast with the allow path: when the same prompt names an absolute path into a single worktree,
`Status` is `'OtherWorktree'` and F4 probes
`Join-WorktreeResolutionPath -WorktreeRoot $target.WorktreeRoot -RepoRelativePath 'docs/features/active/2026-09-13-some-item-700/issue.md'`
with `Test-Path -LiteralPath`, which now names an absolute path rather than a cwd-relative one.

## Data & State

This feature introduces **no persistent state**. It writes no file, no cache, and no artifact. It
requires no migration and no backfill. The only data it reads is the git administrative layout, and
it reads it through the three seams.

### The `.git` entry forms

Verified 2026-09-13 by direct file reads in both topologies:

| location | what `.git` is | content |
| --- | --- | --- |
| a linked worktree, e.g. `<main>/.claude/worktrees/agent-<id>/.git` | a **file** | one line: `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/agent-<id>` |
| a linked worktree outside the main checkout, e.g. `<parent>/drm-copilot-wt/2026-09-13T08-30/.git` | a **file** | one line: `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/2026-09-13T08-30` |
| the main checkout, `C:/Users/DanMoisan/repos/drm-copilot/.git` | a **directory** | (a read attempt returned `EISDIR`) |

So a level is a worktree root when its `.git` child is a directory (main checkout) **or** a file
whose first line matches `^gitdir:\s*(.+)$` (linked worktree). Anything else is not a root and the
ascent continues.

### The `commondir` indirection

`<main>/.git/worktrees/<name>/gitdir` contains the path back to that worktree's own `.git` **file**;
the worktree root is that file's parent directory. This is the reverse mapping that enumerates
worktrees without invoking git.

`<main>/.git/worktrees/<name>/commondir` was read directly and contains `../..`, which resolves from
the per-worktree admin directory to the main `.git` directory. This is the step that lets the module
reach the main checkout's admin directory when it starts from a linked worktree, which is the
ordinary case for a coordinating session.

### A worktree may be a sibling, not a descendant

**Load-bearing.** The two worktrees observed live in different places relative to the main checkout:
one **inside** it (`<main>/.claude/worktrees/agent-<id>`) and one **outside** it
(`<parent>/drm-copilot-wt/<timestamp>`, a sibling of the main checkout directory). A worktree root is
therefore **not** necessarily a descendant of the main checkout.

Consequently **containment must not be tested by string-prefix comparison against a single known
root.** That approach is wrong for the entire `drm-copilot-wt/*` family. The sound tests are the
upward walk for a `.git` entry, and, for the enumerated candidate set, per-candidate containment
against each candidate root in turn. `enforce-powershell-batch-budget.ps1` derives its root as
`Split-Path (Split-Path $PSScriptRoot -Parent) -Parent` (`:210, 269, 315`) and prefix-tests
candidates (`Test-PowerShellBatchBudgetPathInRoot`, `:56-93`); that is sound for bounding a
per-session budget to one root but is not a worktree locator and must not be copied here.

### Path-normalisation invariants

- All emitted paths use **forward slashes**. Input may use either separator or a mix.
- No emitted path carries a **trailing slash**.
- No emitted repo-relative path carries a leading `./`.
- **No path is ever truncated to a fixed segment count.** The remainder below a worktree root is
  preserved in full, however deep.
- Comparison of a candidate path against a worktree root is performed on normalised forms, segment
  by segment, so that a root and a sibling directory sharing a textual prefix are not confused.
- The ascent terminates at the filesystem or drive root, and additionally at a `MaximumDepth` guard,
  so a malformed input cannot loop.

## Implementation Strategy

### Scope of change

Add one module directory with two `.psm1` files, mirror both into the bundled payload, register both
in the core pack manifest, register both in the coverage denominator in both runsettings copies, and
add three Pester suites. Change nothing else.

### Decomposition: two files in `.claude/lib/worktree-resolution/`

A single file would land near 725 estimated lines, over the 500-line cap, and would be rejected by
`ClaudeLibModuleConvention.Tests.ps1:123-136`. A third file would add a third mirror file and a third
coverage entry, pushing the production file count from six to nine and forcing an additional
batch-budget reset for no separation-of-concerns gain. Precedent for multiple modules in one
directory exists: `orchestrator-state/` holds eleven, `blast-radius/` eight, `mermaid/` four.

- **File 1 — `WorktreeResolution.psm1`.** The filesystem-bearing half: the three seams, separator
  normalisation, the root-marker test, the upward ascent, the worktree enumerator, path
  normalisation, `Join-WorktreeResolutionPath`, and `Get-WorktreeResolutionAmbiguityReasonCode`.
  Depends on nothing.
- **File 2 — `WorktreeTargetResolution.psm1`.** Pure given File 1: the result factory, the three
  signal extractors, and the four-state dispatch in `Resolve-WorktreeCallTarget`. Imports File 1 at
  column 0 with `-ErrorAction Stop`.

The split mirrors the epic's own contract decomposition: File 1 is path normalisation, File 2 is
target derivation, and the reason code is declared once in File 1 and re-exported through File 2's
results.

**Line-budget note for the planner.** Ruling C adds the enumerator, the `commondir` indirection, and
the main-checkout-inclusion logic to File 1, which the research's pre-ruling estimate of roughly 380
lines did not include. If File 1 approaches the cap, move `Join-WorktreeResolutionPath` and
`Get-WorktreeResolutionAmbiguityReasonCode` into File 2 — they are leaf helpers with no dependency on
the locator — and re-export the reason code from there. Do not split into a third file.

### The three seams

These are the module's **only** filesystem contact. Every other function in both files is a pure
function of its arguments.

| seam | default body | purpose |
| --- | --- | --- |
| `Get-WorktreeResolutionGitEntryKind -Path <p>` | `Test-Path -LiteralPath -PathType Container` then `-PathType Leaf` | the only existence probe |
| `Get-WorktreeResolutionGitFileText -Path <p>` | `Get-Content -LiteralPath -Raw` | the only content read |
| `Get-WorktreeResolutionDirectoryChildName -Path <p>` | `Get-ChildItem -LiteralPath -Directory -Name` | the only directory enumeration (Ruling C) |

Mocking these three with `Mock -CommandName <seam> -ModuleName '<Module>'` lets a Pester suite model
an arbitrary worktree topology — including the non-nested `drm-copilot-wt/*` case — with no temporary
file, no process, no clock read, and no dependency on the machine's actual git layout. The
determinism constraint is satisfied by construction.

**No git subprocess.** `git rev-parse --show-toplevel` is rejected: no `.claude/lib/` module and no
`.claude/hooks/` script spawns a subprocess today; `HookPayload.psm1:37` and
`CleanupWorktreeManifest.psm1:27` both declare "no subprocess" as a module property; the unit-test
policy forbids external-process dependence; and a PreToolUse hook runs on every matching tool call,
so a process launch would sit on the hot path.

### Module conventions that are mechanically enforced from the first line written

`ClaudeLibModuleConvention.Tests.ps1` discovers modules from disk, so both new files are covered the
moment they exist. Each must carry: a comment-based-help header containing the exact sentence token
`imports its siblings with -ErrorAction Stop` **before** the `Set-StrictMode` line;
`Set-StrictMode -Version Latest` immediately followed on the very next line by
`$ErrorActionPreference = 'Stop'`; `-ErrorAction Stop` on every column-0 `Import-Module`; an import
that leaves the caller's `$ErrorActionPreference` unchanged; and a physical line count at or under
500. Each must also carry the `.NOTES` mirror sentence stating that the file is mirrored
byte-identically under `extensions/drm-copilot/resources/claude-customizations/`.

### Registration and mirroring

`extensions/drm-copilot/resources/claude-customizations/.claude/lib/` is a byte-identical mirror of
the repo-side `.claude/lib/` tree. The push-down serves the **installed extension's** payload, not
the repository tree, so a repo-side-only edit is inert at the push-down surface. Additionally, every
`.claude/lib/` path must appear in the `paths` array of the core pack manifest or push-down does not
deliver the module at all under `--packs core`. Verified: all forty-four `.claude/lib/` files are
listed, and all forty-four listings are in `core.json`; the other five manifests list none. Also
verified: `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` walks
`agents/`, `hooks/`, and `skills/` only and does **not** walk `.claude/lib/`, so an unregistered
module would not be caught there. The per-module `*.Manifest.Tests.ps1` is the only guard.

Follow `DiscoveryValidation.Manifest.Tests.ps1`, not `ModelRouting.Manifest.Tests.ps1`. The former is
the single-module-directory case, is the newer pattern, and carries four assertions: `-Contain`;
exactly-once via `@($manifest.paths | Where-Object { $_ -eq $expected }).Count | Should -Be 1`; every
on-disk `*.psm1` in the module folder covered by the expected-path list; and a separate `Describe`
asserting SHA-256 byte identity against the bundle mirror, including
`Test-Path -LiteralPath $bundleFile | Should -BeTrue`. `ModelRouting.Manifest.Tests.ps1` is the older,
thinner pattern and carries no hash assertion; the byte identity of the `model-routing` mirror is
correspondingly **unverified** (the research compared the first thirty lines by read but could not
compute a hash). Do not take it as a model.

### Coverage registration

`CodeCoverage.Path` in `pester.runsettings.psd1` is an explicit per-file allow-list — the file states
so in seven separate comments. A new module is **not** picked up automatically. `Run.Path` already
includes `tests/scripts`, so test *discovery* needs no change; only the coverage denominator does.
Add the two repo-relative module paths to `CodeCoverage.Path` in both copies, keeping them
text-identical per `test_poshqc_bundled_parity.py`. Do **not** add any
`extensions/drm-copilot/resources/` path to `CodeCoverage.Path`; the existing comment at
`pester.runsettings.psd1:269-271` records the rule, and bundle mirrors are guarded by byte identity
instead.

### The exact ten file paths

**Create (repo-side production):**

1. `.claude/lib/worktree-resolution/WorktreeResolution.psm1`
2. `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`

**Create (bundled mirror, byte-identical):**

3. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`

**Edit (registration):**

5. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — add exactly
   two entries to `paths`:
   `".claude/lib/worktree-resolution/WorktreeResolution.psm1",` and
   `".claude/lib/worktree-resolution/WorktreeTargetResolution.psm1",`

**Edit (coverage denominator):**

6. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
7. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

**Create (tests):**

8. `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`
9. `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1`
10. `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1`

### Test approach

Suites import the module with
`Import-Module (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/worktree-resolution/<Module>.psm1").Path -Force`.
`Resolve-Path` is required, not cosmetic: it normalises separators so Pester coverage breakpoints
bind to the path the run settings name.

The required matrix — cwd (session root vs item worktree) x path form (relative vs absolute) x target
(own item vs sibling item vs absent) — is a `-ForEach` table whose rows are hashtables of injected
`.git` topology plus an expected `Status`/`ReasonCode` pair. Currently-passing cases are included as
regression guards, not omitted as redundant.

### Dependency changes, logging, rollout

No package is added or removed. No logging or telemetry is added; the module returns values and does
not write. There is no feature flag and no staged rollout: the module has no callers at merge time,
so the fallback path is the existing unchanged behaviour of every hook.

## Constraints & Risks

- Enforcement/hook-adjacent code must be PowerShell or bash. No Python: a Python leg creates a second
  implementation of the rule that drifts from the first, which has already occurred in this
  repository. This is mechanically enforced for F1's surface —
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:39-42` scans
  `.claude/hooks` **and `.claude/lib`** recursively, excluding only `.claude/lib/bash/*`.
- No production, test, or reusable script file may exceed 500 lines. Mechanically enforced for
  `.claude/lib/*.psm1` by `ClaudeLibModuleConvention.Tests.ps1:123-136`, which counts physical lines.
- Tests live in a `tests/` tree mirroring production structure
  (`tests/scripts/claude-lib/worktree-resolution/`). Colocation is prohibited.
- Line coverage >= 85%. Pester does not measure branch coverage, so no branch gate applies, but the
  files remain in the coverage denominator.
- Determinism: no temporary files in tests, no wall-clock reads, no external process dependencies
  that make a test environment-sensitive.
- **Batch-budget constraint (surfaced now, not at execution).**
  `.claude/hooks/enforce-powershell-batch-budget.ps1` caps a batch at 3 production and 3 test
  PowerShell files (`.ps1`, `.psm1`, `.psd1`), counting distinct paths per session. The four bundle
  mirror and runsettings files are not under `tests/` and do not match `\.Tests\.ps1$`, so they
  consume **production** slots: F1 has six production PowerShell files against a cap of three.
  `core.json` is `.json` and consumes nothing. The test side is exactly 3 of 3, with zero headroom.
  The plan must schedule at least one sanctioned budget reset, or split F1 across at least two
  batches. A natural split is: Batch A = the two repo-side `.psm1` files plus
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; reset; Batch B = the two mirror
  `.psm1` files plus the mirrored runsettings `.psd1`; Batch C = the three Pester suites.
- **`CoveragePercentTarget = 0` hazard.** `pester.runsettings.psd1:285` sets the runner's coverage
  target to zero, with the comment "Optional: don't fail the run on coverage percentage". A green
  PoshQC run is therefore **not** evidence that the 85% threshold was met. Any acceptance criterion
  phrased as "the suite passes" would not gate coverage. The criterion below reads
  `artifacts/pester/powershell-coverage.xml` instead.
- Related hazard: `Invoke-Pester` returns process exit 0 even with failing tests unless
  `Run.Exit`/`-EnableExit` is set. The repo runsettings do set `Run.Exit = $true`, so the MCP path is
  covered; a direct `Invoke-Pester` outside those settings is not. Prefer `-EnableExit`, or
  `$r = Invoke-Pester -Path <suite> -PassThru; exit $r.FailedCount`.
- **Unverified: the MCP PoshQC coverage-path gotcha** (Ruling D). Treated as live. If it reproduces,
  a rebuild and reinstall of the extension would be required before the MCP runner reports rows for
  the new files; that is not scheduled in F1, and the direct self-hosted invocation is used instead.
- **Unknown: the literal success line a passing PoshQC run prints.** No command could be executed
  during research and no captured run output exists in the tree. The plan must capture the actual
  line on first run and record it under `evidence/qa-gates/`; it must not be inferred.
- **Unverified: byte identity of the `model-routing` bundle mirror.** Only the first thirty lines
  were compared; no hash could be computed. This is why F1 follows
  `DiscoveryValidation.Manifest.Tests.ps1`, which asserts SHA-256 identity, rather than
  `ModelRouting.Manifest.Tests.ps1`, which does not.
- Risk: the contract is consumed by two downstream features that cannot be written until it exists.
  A contract imprecise about the difference between "no target" and "ambiguous target" forces rework
  in F4 and F5. Mitigated by the four-state table and the `Ambiguous` sub-case list above.
- Risk: omitting the `core.json` registration is silent at development time and only fails at F7,
  where push-down delivers nothing. Mitigated by the manifest test.
- Risk: an enumerator that walks the admin directory depends on git's on-disk layout, which is not a
  public API. Mitigated by the fact that the layout was verified directly in this repository, by the
  seams making every branch testable, and by every unlocatable case denying rather than guessing.

## Acceptance Criteria

These criteria are the authoritative set for this feature and are mirrored verbatim in
`user-story.md`. Each is one checkbox on one line.

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

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (unit/integration as applicable)
- [x] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [x] Telemetry/logging added or updated (if applicable)
- [x] Toolchain pass completed (format → lint → type-check → test)
- [x] All four settled rulings (A, B, C, D) are implemented as specified and none was reopened during planning or execution
- [x] The correction to the epic's characterisation of `enforce-prd-feature-before-planner.ps1` (regex at line 252, not truncation at line 265) is carried into F4's inputs
- [x] Coverage evidence is written under this feature's `evidence/qa-gates/` and cites the per-file rows read from `artifacts/pester/powershell-coverage.xml`
- [x] QA-gate evidence, including the verbatim PoshQC output line, is written under this feature's `evidence/qa-gates/`
- [x] The batch-budget split (or an approved reset) was executed as planned and no PowerShell batch-budget denial remains outstanding
- [x] No consumer was rewired: a diff review confirms no file under `.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/src/` was changed

## Seeded Test Conditions (from potential)

- [ ] Table-driven Pester covering the cross product of cwd (session root versus item worktree), path form (relative versus absolute), and target (own item versus sibling item versus absent).
- [ ] The "sibling item is the only state present" row returns the ambiguity result and never a resolved target.
- [ ] cwd and target coincide: target derivation returns the session root (regression guard).
- [ ] Absolute path to a feature folder normalises without losing its prefix (the segment-truncation regression).
- [ ] Manifest test asserting exactly-once registration in `core.json`.
- [ ] Assertions are direct against module functions; this feature has no hook consumers.
