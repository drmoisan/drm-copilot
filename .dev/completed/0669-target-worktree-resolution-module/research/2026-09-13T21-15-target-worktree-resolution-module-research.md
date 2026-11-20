# Research: Target Worktree Resolution Module (F1, issue #669)

- Feature: `docs/features/active/2026-09-13-target-worktree-resolution-module-669/`
- Epic: `docs/features/epics/worktree-scoped-state-resolution/epic.md` (F1, wave 0, C3, no dependencies)
- Timestamp: 2026-09-13T21-15
- Workspace: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2f77fb06596dbfe7`

## Tooling Limitation Affecting This Research

The Bash tool is disabled in this session (`Error: No such tool available: Bash. Bash is disabled
for this session, in subagents as well as here.`), and no PowerShell execution tool was available.
Every finding below is therefore derived from file reads, glob enumeration, and ripgrep content
search. Three consequences are recorded honestly rather than papered over:

1. No command was executed, so no command-and-exit-code evidence artifact is produced by this
   research. Byte identity of bundle mirrors is asserted only where an in-repo test already asserts
   it (with the test cited); where no such test exists the claim is marked unverified.
2. The timestamp above is not a clock read. It is ordered after the epic manifest's
   `created_at: 2026-09-13T20:45` (`epic.md:4`). Treat it as an ordering marker, not a measurement.
3. Q8's request for "the literal line the successful run prints" cannot be satisfied. The output
   shape is derived from configuration instead, and marked as such.

## Hard Constraints (restated, as required)

- **PowerShell or bash only** for enforcement/hook-adjacent code. **No Python.** A Python leg
  creates a second implementation of the rule that drifts from the first. This is mechanically
  enforced for F1's surface: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1:39-42`
  scans `.claude/hooks` **and `.claude/lib`** recursively for `*.ps1`/`*.psm1`, excluding only
  `.claude/lib/bash/*` (lines 66-68). A new `.claude/lib/` module is inside that scan automatically.
- **No production, test, or reusable script file over 500 lines.** Mechanically enforced for
  `.claude/lib/*.psm1` by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1:123-136`,
  which counts physical lines with `@(Get-Content -LiteralPath $path).Count` (the comment at
  lines 128-129 records that `Measure-Object -Line` under-reports).
- **Tests in `tests/` mirroring production structure; colocation prohibited.**
- **Line coverage >= 85%; Pester measures no branch coverage**, so no branch gate — but the files
  stay in the denominator (`.claude/rules/powershell.md:64`).
- **Determinism:** no temporary files in tests, no wall-clock reads, no external process dependency
  that makes a test environment-sensitive.
- **Must not regress:** gates must still deny when a required document is genuinely absent; epic and
  standalone topologies must behave exactly as now when cwd and target coincide — the module must
  return the session root as the target in that case.

---

## Numeric Derivation Evidence

Required before any numeric claim reaches an approved `spec.md` acceptance criterion.

### N1 — `.claude/lib/` holds exactly 11 module directories

- **Complete Family:** every immediate child directory of `.claude/lib/` in the repository tree.
- **Exhaustive Search Scope:** the whole `.claude/lib/` subtree, recursively, with no extension
  filter (so `.psm1`, `.ps1`, and `.sh` directories are all in scope).
- **Inclusion Rules:** a directory is a member if at least one file exists beneath it.
- **Exclusion Rules:** the `.claude/lib/` root itself; no file-extension exclusion.
- **Primary Search Strategy:** `Glob(pattern=".claude/lib/**/*")`, then take the distinct first path
  segment under `lib/`.
- **Primary Member Set:** `bash`, `blast-radius`, `cleanup-manifest`, `codex-routing`,
  `discovery-validation`, `hook-payload`, `mermaid`, `model-routing`, `orchestrator-state`,
  `project-file-merge`, `requirements`.
- **Primary Count:** 11.
- **Cross-check Search Strategy:** a different tree and a different query —
  `Glob(pattern="extensions/drm-copilot/resources/claude-customizations/.claude/lib/**/*")`, the
  bundled mirror, then take the distinct first path segment under `lib/`.
- **Cross-check Member Set:** `bash`, `blast-radius`, `cleanup-manifest`, `codex-routing`,
  `discovery-validation`, `hook-payload`, `mermaid`, `model-routing`, `orchestrator-state`,
  `project-file-merge`, `requirements`.
- **Cross-check Count:** 11.
- **Member-set Comparison:** normalized (lower-case, separator-insensitive) the two sets are
  identical; the symmetric difference is empty. **Agree.**

Re-verification note: the epic manifest (`epic.md:155-158`) and `issue.md:29-32` both state eleven
modules and name the same eleven. **Re-verified against the current tree: the claim holds exactly.**

### N2 — `.claude/lib/` holds exactly 44 files, and all 44 are registered in `core.json`

- **Complete Family:** every file (any extension) under `.claude/lib/`, and every `.claude/lib/`
  path listed in any `extensions/drm-copilot/resources/claude-customizations/pack-manifests/*.json`.
- **Exhaustive Search Scope:** the full `.claude/lib/` subtree; and all six manifest files
  (`core.json`, `csharp-legacy.json`, `csharp-modern.json`, `powershell.json`, `python.json`,
  `typescript.json`), not `core.json` alone.
- **Inclusion Rules:** any regular file under `.claude/lib/`; any manifest `paths[]` string whose
  value begins `.claude/lib/`.
- **Exclusion Rules:** none within the subtree; the bundled mirror tree is not counted on the
  on-disk side.
- **Primary Search Strategy:** `Glob(pattern=".claude/lib/**/*")` — filesystem enumeration.
- **Primary Member Set:** 11 `.sh` under `bash/`; 8 under `blast-radius/`; 1 under
  `cleanup-manifest/`; 2 under `codex-routing/`; 1 under `discovery-validation/`; 1 under
  `hook-payload/`; 4 under `mermaid/`; 1 under `model-routing/`; 11 under `orchestrator-state/`;
  3 under `project-file-merge/` (2 `.psm1` + `Resolve-MergeableConflict.ps1`); 1 under
  `requirements/`.
- **Primary Count:** 44.
- **Cross-check Search Strategy:** a different mechanism and a different corpus —
  `Grep(pattern="\.claude/lib/", path="extensions/drm-copilot/resources/claude-customizations/pack-manifests", output_mode="content", head_limit=0)`,
  i.e. ripgrep over the manifest JSON rather than the filesystem.
- **Cross-check Member Set:** 44 matched lines, **all in `core.json`** (lines 115-143, 146-156,
  162-165). No other manifest file produced a match.
- **Cross-check Count:** 44.
- **Member-set Comparison:** after normalizing the on-disk paths to forward slashes and prefixing
  `.claude/lib/`, the two sets are identical; every on-disk file appears once and only once in
  `core.json`, and `core.json` lists no `.claude/lib/` path that does not exist on disk.
  **Agree.**

A third, independent count corroborates the file total:
`Grep(pattern="^", path=".claude/lib", output_mode="count", head_limit=0)` reported
`Found 14982 total occurrences across 44 files`.

**Derived sub-counts** (same family, arithmetic over the primary member set): 11 `.sh`, 1 `.ps1`
(`project-file-merge/Resolve-MergeableConflict.ps1`), therefore **32 `.psm1`**. This matters because
`ClaudeLibModuleConvention.Tests.ps1:31` discovers `*.psm1` only, so the `.sh` files and the single
`.ps1` are outside that convention suite.

### N3 — "exactly once in the `paths` array" — mechanical meaning

- **Complete Family:** the elements of the `paths` array in `core.json`.
- **Exhaustive Search Scope:** the whole decoded `paths` array, not a prefix of it.
- **Inclusion Rules:** an element counts when it is string-equal (`-eq`) to the expected module path.
- **Exclusion Rules:** no normalization is applied by the assertion; separator or case variants do
  not count.
- **Primary Search Strategy:** the in-repo assertion
  `@($script:Manifest.paths | Where-Object { $_ -eq $script:ExpectedPath }).Count | Should -Be 1`
  (`tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1:34-37`).
- **Primary Member Set:** for `model-routing`, the single element `.claude/lib/model-routing/ModelRouting.psm1`.
- **Primary Count:** 1.
- **Cross-check Search Strategy:** ripgrep line enumeration of the raw JSON text (different
  mechanism, different representation — text rather than decoded object), from the N2 search.
- **Cross-check Member Set:** exactly one line, `core.json:117`.
- **Cross-check Count:** 1.
- **Member-set Comparison:** identical single-element sets. **Agree.**

---

## Q1 — Module placement and shape

### Conventions observed across the `.claude/lib/` tree

| aspect | convention | evidence |
| --- | --- | --- |
| directory naming | kebab-case domain noun | `hook-payload/`, `model-routing/`, `cleanup-manifest/`, `orchestrator-state/` |
| file naming | PascalCase noun matching the domain, `.psm1` | `HookPayload.psm1`, `ModelRouting.psm1`, `CleanupWorktreeManifest.psm1` |
| `.psd1` manifest | **none.** No `.psd1` exists anywhere under `.claude/lib/` | `Glob(".claude/lib/**/*")` returned 0 `.psd1` files (N2 member set) |
| `#Requires` | **not used in modules** (used in test files only) | `HookPayload.psm1:1` opens with `<#`; `ClaudeLibModuleConvention.Tests.ps1:1-2` carries `#Requires` |
| header | leading comment-based-help block with `.SYNOPSIS`, `.DESCRIPTION`, often `.NOTES` | `HookPayload.psm1:1-41`, `ModelRouting.psm1:1-22`, `CleanupWorktreeManifest.psm1:1-33` |
| mandatory sentence | the exact token `imports its siblings with -ErrorAction Stop` must appear in the help block **before** the `Set-StrictMode` line | asserted by `ClaudeLibModuleConvention.Tests.ps1:38, 88-107`; present at `HookPayload.psm1:40`, `ModelRouting.psm1:21`, `CleanupWorktreeManifest.psm1:32` |
| fail-fast guard | `Set-StrictMode -Version Latest` immediately followed by `$ErrorActionPreference = 'Stop'` — the guard must be the **very next line** | asserted by `ClaudeLibModuleConvention.Tests.ps1:53-67`; `HookPayload.psm1:43-44`, `ModelRouting.psm1:24-25`, `CleanupWorktreeManifest.psm1:35-36` |
| load-time imports | every column-0 `Import-Module` must carry `-ErrorAction Stop` | asserted by `ClaudeLibModuleConvention.Tests.ps1:69-86`; example `Resolve-MergeableConflict.ps1:36-38` |
| caller preference | importing the module must leave the caller's `$ErrorActionPreference` unchanged | `ClaudeLibModuleConvention.Tests.ps1:109-121` |
| constants | `$script:PascalCase` or `$script:UPPER_SNAKE`, each with a prose comment explaining why the set is narrow | `CleanupWorktreeManifest.psm1:40-68`, `ModelRouting.psm1:30-87`, `HookPayload.psm1:47-64` |
| function naming | approved verb + **module-unique noun prefix** to avoid cross-module collisions | `Get-ClaudeHookToolInput`, `Get-CleanupWorktreeManifestContent`, `Get-OrchestratorStateCheckpoint` |
| parameter attributes | `[CmdletBinding()]`, `[OutputType([...])]`, explicit `[Parameter(Mandatory)]`, and `[AllowNull()]`/`[AllowEmptyString()]`/`[AllowEmptyCollection()]` on tolerant inputs | `HookPayload.psm1:74-76, 98-102, 124-134`; `ModelRouting.psm1:117-123` |
| per-function help | `.SYNOPSIS` always; `.DESCRIPTION`, `.PARAMETER`, `.OUTPUTS` where non-obvious. Verbose by repository standard | `HookPayload.psm1:148-177` (30 lines of help for one function) |
| result shape | a typed `[pscustomobject]` built by a single factory function, never a bare `$null` for malformed input | `ConvertTo-ClaudeHookPayloadResult`, `HookPayload.psm1:113-146` |
| export | `Export-ModuleMember -Function` as the last statement, backtick-continued one name per line when long | `HookPayload.psm1:486-496`; single-line form at `ModelRouting.psm1:231` |
| `.NOTES` mirror sentence | new modules state `Mirrored byte-identically under extensions/drm-copilot/resources/claude-customizations/` | `HookPayload.psm1:38-39`, `CleanupWorktreeManifest.psm1:30-31` |

### File sizes (physical line counts, `Grep(pattern="^", output_mode="count")`)

`HookPayload.psm1` **496**; `DiscoveryValidation.psm1` 500; `OrchestratorState.psm1` 499;
`MermaidValidation.psm1` 498; `MermaidGrammar.psm1` 493; `MermaidLineScanner.psm1` 490;
`BlastRadiusExtraction.psm1` 474; `BlastRadiusConfig.psm1` 473; `OrchestratorStateCompletion.psm1` 434;
`BlastRadius.psm1` 438; `BlastRadiusGlob.psm1` 431; `OrchestratorStateRoutingContract.psm1` 430;
`CleanupWorktreeManifest.psm1` 415; `OrchestratorStateCompletionChecks.psm1` 418;
`OrchestratorStateReceipts.psm1` 410; `CodexTopology.psm1` 394; `OrchestratorStateCheckpointValue.psm1` 385;
`OrchestratorStateRoutingMatrix.psm1` 379; `BlastRadiusValidation.psm1` 374;
`OrchestratorStateModelReceipts.psm1` 368; `ProjectFileMerge.psm1` 355; `ProjectFileMergeGrammar.psm1` 318;
`CodexDeployment.psm1` 314; `OrchestratorStateCodexTopologyReceipts.psm1` 300;
`MermaidMarkdownFences.psm1` 300; `OrchestratorStateCodexModelReceipts.psm1` 299;
`BlastRadiusNormalization.psm1` 297; `BlastRadiusConflict.psm1` 290; `ModelRouting.psm1` 231;
`Resolve-MergeableConflict.ps1` 229; `BlastRadiusTokenShape.psm1` 189;
`OrchestratorStateUnconditional.psm1` 168; `GeneratedDocumentCounters.psm1` 44.

### `HookPayload.psm1` — current size and exports

- **496 physical lines. Headroom against the 500-line cap: 4 lines.**
- Exports 10 functions (`HookPayload.psm1:486-496`): `Read-ClaudeHookRawPayload`,
  `ConvertFrom-ClaudeHookEnvelope`, `Get-ClaudeHookToolInput`, `Resolve-ClaudeHookToolInput`,
  `Get-ClaudeHookEnvelopeValue`, `Test-ClaudeHookEnvelopeHasKey`, `Test-ClaudeHookObjectValue`,
  `Get-ClaudeHookToolInputString`, `Get-ClaudeHookPayloadAnomalyCode`,
  `Get-ClaudeHookPayloadAnomalyReason`.

### Recommendation: **sit BESIDE `hook-payload`, as a new module directory**

Extending `HookPayload.psm1` is not viable and not correct:

1. **500-line cap.** The file has 4 lines of headroom (496/500). A target-resolution contract
   cannot be added in 4 lines, and the cap is mechanically asserted by
   `ClaudeLibModuleConvention.Tests.ps1:123-136`. Extending would force an immediate split, which
   is the change F1 would be making anyway — but with the extra cost of moving existing code.
2. **Separation of concerns** (`.claude/rules/general-code-change.md`, "Design Principles" item 4;
   "Separation of concerns — keep pure logic ... separate from I/O"). `HookPayload.psm1` declares
   itself in its own `.NOTES` as having **"no filesystem access, no subprocess, no network, and no
   wall-clock read"** (`HookPayload.psm1:37-39`). Worktree resolution is inherently a filesystem
   probe — it must locate a `.git` entry. Adding a filesystem read to `HookPayload.psm1` would
   falsify its stated invariant and merge a pure parser with an I/O-bearing locator.
3. **Repository precedent.** `CleanupWorktreeManifest.psm1` is the closest analogue: a later,
   filesystem-touching primitive consumed by two gate hooks was given its own directory
   (`cleanup-manifest/`) rather than appended to an existing module, and it isolates its single
   filesystem read and single clock read behind named seams (`CleanupWorktreeManifest.psm1:26-31,
   70-108`).
4. **I/O boundaries rule** (`.claude/rules/general-code-change.md`, "I/O Boundaries"): isolate I/O
   into specific modules; core domain logic must be testable without touching the filesystem. A
   separate module lets the filesystem probe be one named seam.

**Proposed directory:** `.claude/lib/worktree-resolution/`.

---

## Q2 — The existing defect instance (`enforce-prd-feature-before-planner.ps1`)

**F4's site, characterised here only to shape F1's contract. F1 changes nothing in this file.**

### Line-number re-verification against the current tree

| epic manifest claim (`epic.md:289-293`) | current tree | verdict |
| --- | --- | --- |
| file is 448 lines | last line is 448 (`exit 0` at :448); file ends there | **confirmed** |
| `Find-PrdFeatureFolderFromPrompt` at line 219 | `function Find-PrdFeatureFolderFromPrompt {` at :219 | **confirmed exactly** |
| `Get-PrdFeatureCheckpointFolder` at line 189 | `function Get-PrdFeatureCheckpointFolder {` at :189 | **confirmed exactly** |
| truncation documented at lines 16-18 | the truncation sentence spans **:17-19** inside the help block at :14-24. Line 16 is the preceding sentence about scanning for the path token. | **off by one; report as :17-19** |
| truncation applied at line 265 | line 265 is the **first line of the explanatory comment** (`# Truncate to exactly two segments past the docs/features/active/ prefix,`). The executable truncation is the segment split at **:272**, the four-segment guard at **:273**, and the slice `$segments[0..3]` at **:277**. | **discrepancy; the applied site is :272-277, not :265** |
| `Test-Path -LiteralPath` on relative candidates at 91, 108, 201 | `:91` in `Get-PrdFeatureFileExistence`; `:108` in `Get-PrdFeatureIssueContent`; `:201` in `Get-PrdFeatureCheckpointFolder` | **confirmed exactly** |
| no worktree resolution anywhere in the file | no `gitdir`, `rev-parse`, or `.git` reference appears | **confirmed** |

### What actually causes the false denial — a correction to the epic's characterisation

The epic states (`epic.md:101-103`) that "the four-segment truncation must not discard a valid
prefix." **Against the current tree, the segment truncation is not what discards the prefix.** The
prefix is discarded one step earlier, by the regex anchor:

```
:252    $pattern = 'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'
:253    $matchList = [regex]::Matches($Prompt, $pattern)
```

The pattern is unanchored and begins at the literal `docs`. Given the prompt token
`C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-13T08-30/docs/features/active/<feature>/spec.md`,
`$m.Value` is already `docs/features/active/<feature>/spec.md` — the absolute worktree prefix never
enters the candidate at all. The `$segments[0..3]` slice at `:277` then removes the **suffix**
(`spec.md`, or a `v1/` version folder — the known limitation recorded at `:36-40`), not the prefix.

Both defects converge on the same consequence at `:382`:

```
:382    $folderNormalized = ($folder -replace '\\', '/').TrimEnd('/')
```

`$folderNormalized` is always a bare repo-relative path. It is then probed with
`Test-Path -LiteralPath` at `:108` (via `Get-PrdFeatureIssueContent`, `:388`) and at `:91` (via
`Get-PrdFeatureMissingFile` -> `Get-PrdFeatureFileExistence`, `:417` -> `:330`). A relative
`-LiteralPath` resolves against the **hook process's current directory**, which is the invoking
session's worktree.

**Input that produces the false denial.** A parallel or epic orchestrator whose cwd is worktree
`W_session` delegates `Agent(subagent_type='atomic-planner')` with a prompt naming
`docs/features/active/<feature>/` (relative form) or the absolute path to that folder inside worktree
`W_target`. `<feature>` exists in `W_target` and not in `W_session`. The hook resolves
`docs/features/active/<feature>`, probes `<cwd=W_session>/docs/features/active/<feature>/issue.md`,
finds nothing, `Resolve-PrdFeatureWorkMode` returns `$null` (`:139-141`), and the `-not $workMode`
branch at `:398-410` denies with `PRD_FEATURE_BLOCKED: resolved feature folder '<f>', but its work
mode could not be determined`. The document exists; the gate read the wrong root.

**What correct normalisation would return instead.** Given the same absolute token, a correct
normaliser returns two values, not one: the containing worktree root
(`C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-13T08-30`) **and** the repo-relative remainder
(`docs/features/active/<feature>`). The probe is then `Join-Path <worktreeRoot> <relative>`, an
absolute path that exists. For the relative form, the normaliser has no prefix to recover from the
token, so the worktree must come from a different signal — which is precisely why F1's contract has
a target-derivation half as well as a path-normalisation half.

### The false-approval seed in the same file

`Get-PrdFeatureCheckpointFolder` defaults to the bare relative
`artifacts/orchestration/orchestrator-state.json` (`:198`) and is reached from two places: the
multi-candidate tiebreak (`:296`) and the no-candidate fallback (`:369`). Under a parallel topology
that path resolves to **the session root's** checkpoint, which belongs to a different item. The hook
then resolves a sibling's `feature-folder` and validates this delegation against it. This is the
"sibling item's state is the only state present" row of the epic's test matrix
(`epic.md:328`).

The same bare relative literal is used repository-wide. `Grep(pattern="artifacts/orchestration/orchestrator-state\.json", path=".claude", glob="*.ps1")`
found it at: `enforce-completion-consistency.ps1:300`, `enforce-epic-merge-gate.ps1:48`,
`enforce-model-routing-receipt.ps1:46`, `enforce-orchestration-preimplementation-gate.ps1:27,35`,
`enforce-orchestration-preimplementation-gate-modes.ps1:60`,
`enforce-pr-author-skill.epic-base-branch.ps1:35`, `enforce-prd-feature-before-planner.ps1:198`,
`enforce-pr-author-skill.ps1:49`, `validate-orchestrator-output.ps1:32,319`, and
`.claude/lib/orchestrator-state/OrchestratorState.psm1:427`. **Every one is cwd-relative.**

**Contract implication for F1:** F4 and F5 need more than a worktree root. They need to turn a
resolved target into an absolute checkpoint path. F1 should therefore expose repo-relative-to-
absolute composition against a resolved worktree root, not only absolute-to-repo-relative.

---

## Q3 — Locating a containing worktree in PowerShell, deterministically

### Direct inspection of `.git` in both topologies (the crux)

| location | what `.git` is | evidence |
| --- | --- | --- |
| this agent worktree, `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2f77fb06596dbfe7/.git` | a **FILE** whose single line is `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/agent-a2f77fb06596dbfe7` | `Read` succeeded and returned that one line |
| a session worktree, `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-09-13T08-30/.git` | a **FILE** whose single line is `gitdir: C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/2026-09-13T08-30` | `Read` succeeded and returned that one line |
| the main checkout, `C:/Users/DanMoisan/repos/drm-copilot/.git` | a **DIRECTORY** | `Read` failed with `EISDIR: illegal operation on a directory, read 'C:\Users\DanMoisan\repos\drm-copilot\.git'` |

Two further facts read directly from the admin directory:

- `C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/agent-a2f77fb06596dbfe7/gitdir` contains
  `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2f77fb06596dbfe7/.git` — the path
  back to the worktree's `.git` **file**, so the worktree root is its parent directory. This is the
  reverse mapping that enumerates worktrees without invoking git.
- `C:/Users/DanMoisan/repos/drm-copilot/.git/worktrees/agent-a2f77fb06596dbfe7/commondir` contains
  `../..`, resolving to the main `.git` directory.

**Load-bearing topology finding.** The two worktrees observed live in *different* places relative to
the main checkout: one **inside** it (`<main>/.claude/worktrees/agent-<id>`) and one **outside** it
(`<parent>/drm-copilot-wt/<timestamp>`, a sibling of `drm-copilot`). A worktree root is therefore
**not** necessarily a descendant of the main checkout. Any containment test built on string-prefix
comparison against a single known root is wrong for the `drm-copilot-wt/*` family. The only sound
test is an **upward walk for a `.git` entry**.

This also falsifies the simplification used by `enforce-powershell-batch-budget.ps1`, which derives
its root as `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent` (`:210, 269, 315`) and then
containment-tests candidates by prefix (`Test-PowerShellBatchBudgetPathInRoot`, `:56-93`). That is
sound for its own purpose (bounding a per-session budget to one root) but is not a worktree locator.

### Option evaluation

**Option A — walk parent directories for a `.git` entry (directory or file).**
- *Mechanics:* from the starting path, ascend; at each level test for a `.git` child. If it is a
  directory, the level is a main checkout root. If it is a file, read its first line; a line matching
  `^gitdir:\s*(.+)$` confirms a linked worktree and the level is the worktree root. Stop at the first
  hit or at the filesystem root.
- *Testability under Pester:* **fully testable behind two seams** — one that reports what kind of
  `.git` entry exists at a candidate level, and one that returns the `.git` file's text. Both are
  pure functions of injected values; no temporary file, no process, no clock.
- *Correctness:* handles both observed topologies, including the non-nested `drm-copilot-wt/*` case.
- *Cost:* the ascent is O(depth); each level is one existence probe.

**Option B — read `.git/worktrees/<name>/` from the admin directory.**
- *Mechanics:* enumerate `<main>/.git/worktrees/*/gitdir`, read each, strip the trailing `/.git` to
  get each worktree root; build a root-set and pick the longest root that prefixes the input path.
- *Testability:* testable behind a directory-enumeration seam plus a read seam, but it requires the
  **main checkout's** location as an input, which is the very thing that is hard to obtain from an
  arbitrary path. Circular for the primary use case.
- *Useful as:* a secondary capability (enumerate the sibling worktrees of a known one) if a later
  feature needs it. Not the primary locator.

**Option C — `git rev-parse --show-toplevel`.**
- *Mechanics:* one subprocess per query, run with the candidate directory as cwd or via `-C`.
- *Testability:* the repository mandates a wrapper seam for this — `.claude/rules/powershell.md:47-50`
  ("Wrapper function seam (preferred) — extract external executable calls into a wrapper function:
  `Invoke-<Tool>Exe -<Tool>Args <string[]>`") and `:80` ("never mock `git` ... directly. Mock the
  wrapper function"). So it *can* be mocked. But:
  - `.claude/rules/general-unit-test.md`, "External Dependencies": "Unit tests must not depend on
    ... external processes."
  - No `.claude/lib/` module and no `.claude/hooks/` script invokes git today. `Grep` for
    `Start-Process|& git|\bgit \b|Invoke-Expression|git\.exe` across `.claude/lib` returned only
    prose comments (`Resolve-MergeableConflict.ps1:53,64`; `ProjectFileMerge.psm1:27,79`). The one
    real git invocation in the tree is `Invoke-GitExe` at `Resolve-MergeableConflict.ps1:48-69`,
    and that is a `.ps1` **entry-point script**, not a hook-consumed `.psm1` module.
  - `HookPayload.psm1:37` and `CleanupWorktreeManifest.psm1:27` both explicitly declare "no
    subprocess" as a module property. A hook-consumed `.psm1` that spawns git would break that
    established property of the hook library surface.
  - PreToolUse hooks run on every matching tool call; a subprocess per call is a latency cost paid
    on the hot path.

### Existing injectable seams in this repository (two concrete examples, as requested)

1. **Scriptblock seam with a safe default** — `HookPayload.psm1:181-183`:
   ```
   [scriptblock] $ReadStandardInput = { [Console]::In.ReadToEnd() },
   [scriptblock] $TestStandardInputRedirected = { [Console]::IsInputRedirected },
   ```
   Documented rationale at `:164-166`: "The guard lives in this function body rather than inside the
   read seam's default so a test can drive both polarities by injection."

2. **Script-scoped function seam mocked with `-ModuleName`** —
   `CleanupWorktreeManifest.psm1:70-90` (`Get-CleanupWorktreeManifestContent`, "The only filesystem
   read in this module ... Tests mock this function (read seam)") and `:92-108`
   (`Get-CleanupWorktreeManifestUtcNow`, "The only wall-clock read in this module"). The consuming
   tests register the mocks at `tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1:36-39`:
   ```
   Mock -CommandName Get-CleanupWorktreeManifestContent -ModuleName 'CleanupWorktreeManifest' -MockWith { $null }
   Mock -CommandName Get-CleanupWorktreeManifestUtcNow  -ModuleName 'CleanupWorktreeManifest' -MockWith { ... }
   ```

Two further precedents worth naming: the wrapper-function seam
`Get-PrdFeatureFileExistence` (`enforce-prd-feature-before-planner.ps1:79-92`, "Wrapper around
Test-Path for sibling-file existence checks. Tests mock this"), and the `-Invoker` delegate seam
`Invoke-OrchestratorStatePreflight` (`OrchestratorState.psm1:401-471`), whose default explicitly
"runs the portable in-process validation and starts no subprocess" (`:408-410`).

### Recommendation for F1

**Adopt Option A, behind two script-scoped function seams, in the `CleanupWorktreeManifest` style.**

- `Get-WorktreeResolutionGitEntryKind -Path <candidate .git path>` -> `'Directory' | 'File' | 'None'`.
  The **only** existence probe in the module. Default body uses `Test-Path -LiteralPath ... -PathType
  Container` / `-PathType Leaf`.
- `Get-WorktreeResolutionGitFileText -Path <candidate .git path>` -> `string | $null`. The **only**
  content read in the module. Default body uses `Get-Content -LiteralPath ... -Raw`.

Everything else — separator normalisation, ascent, `gitdir:` line parsing, prefix arithmetic,
signal extraction, result construction — is pure and directly testable. Mocking two functions with
`-ModuleName` lets a Pester suite model an arbitrary worktree topology (including the non-nested
`drm-copilot-wt/*` case) with **no temporary file, no process, no clock read, and no dependency on
the machine's actual git layout**. The whole determinism constraint is satisfied by construction.

Do **not** add a git subprocess to this module. If a later feature needs true git ground truth, that
belongs in an entry-point `.ps1` with an `Invoke-GitExe` wrapper, following the
`Resolve-MergeableConflict.ps1` precedent — not in a hook-consumed `.psm1`.

---

## Q4 — Registration and mirroring

### `ModelRouting.Manifest.Tests.ps1` in full — what it asserts

`tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1` is 39 lines.

- **Locating the manifest** (`:17-18`):
  ```
  $repoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
  $manifestPath = Join-Path $repoRoot 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
  ```
  Four levels up: `model-routing` -> `claude-lib` -> `scripts` -> `tests` -> repo root (comment at
  `:15-16`). It is decoded once in `BeforeAll` with
  `Get-Content -Path $manifestPath -Raw | ConvertFrom-Json` (`:19`).
- **Assertion 1** (`:24-30`): `@($script:Manifest.paths) | Should -Contain $script:ExpectedPath`.
- **Assertion 2** (`:32-38`), the "exactly once" one:
  ```
  $occurrences = @($script:Manifest.paths | Where-Object { $_ -eq $script:ExpectedPath }).Count
  $occurrences | Should -Be 1
  ```
  **Mechanically:** the decoded `paths` array is filtered with a string-equality predicate (`-eq`,
  PowerShell's case-insensitive scalar comparison), the survivors are array-wrapped so a single
  survivor does not unravel to a scalar, and `.Count` must equal 1. Separator variants and
  substring matches do not count; only an exact element match does.
- **Determinism posture** (`:9-11`): "a file-read-only assertion ... It creates no temporary files
  and invokes no external process."

### The `core.json` `paths` entry for `model-routing` (quoted exactly)

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:117`:

```
    ".claude/lib/model-routing/ModelRouting.psm1",
```

That is the only `model-routing` entry (N3 above). Entries are flat POSIX-separator strings relative
to the repository root, four-space indented inside a single top-level `paths` array that closes at
`:175`. The `.claude/lib/` entries are not contiguous: they occupy `:115-143`, `:146-156`, and
`:162-165`, interleaved with `.claude/rules/` and `.claude/skills/` entries — the array is grouped by
the change that added each block, not sorted.

### Is `model-routing` also mirrored as a file tree? — yes

`Glob("extensions/drm-copilot/resources/claude-customizations/.claude/lib/**/*")` returns 44 files
whose relative structure is identical to the repo-side `.claude/lib/` tree, including
`.../\.claude/lib/model-routing/ModelRouting.psm1`.

**Byte identity:** the first 30 lines of the mirrored `ModelRouting.psm1` were read and are
character-for-character identical to the repo-side file's first 30 lines, including the
`CONVENTION:` sentence at `:21`. A byte-level hash comparison **could not be executed** in this
session (Bash disabled), so full byte identity for `model-routing` specifically is **not
independently verified here**.

However, the repository asserts this class of identity itself, for other modules:

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1:91-105` —
  `Describe 'OrchestratorState bundle mirror byte identity'`, comparing
  `(Get-FileHash -Algorithm SHA256 -LiteralPath $repoFile).Hash` to the bundle file's hash for all
  eleven modules.
- `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1:61-75` — the
  same `Describe` for a single-module directory.

**`ModelRouting.Manifest.Tests.ps1` carries no such `Describe`.** It is the *older, thinner* pattern.
Its sibling `ModelRouting.Parity.Tests.ps1` is a **config**-parity suite (pinning module constants to
`config/orchestration-routing.json`), not a bundle-mirror suite — confirmed by reading it in full.
So `model-routing`'s mirror is currently unguarded by any hash assertion.

### The definitive convention F1 must follow

Follow **`DiscoveryValidation.Manifest.Tests.ps1`**, not `ModelRouting.Manifest.Tests.ps1`. It is the
single-module-directory case (exactly F1's shape), it is the newer pattern, and
`OrchestratorState.Manifest.Tests.ps1:12` names itself as the pattern `DiscoveryValidation` mirrors.
Its four assertions are:

1. the module path is `-Contain`ed in `paths`;
2. it appears exactly once (`Where-Object { $_ -eq $expected }` -> `.Count | Should -Be 1`);
3. **every on-disk `*.psm1` in the module folder is covered by the expected-path list**
   (`:48-58`) — this is what stops a later second module in the same folder from going unregistered;
4. a separate `Describe` asserting SHA-256 byte identity against the bundle mirror (`:61-75`),
   including `Test-Path -LiteralPath $bundleFile | Should -BeTrue`.

### Other manifests

`Grep(pattern="\.claude/lib/", path="extensions/drm-copilot/resources/claude-customizations/pack-manifests", head_limit=0)`
matched **44 lines, all in `core.json`**. `csharp-legacy.json`, `csharp-modern.json`,
`powershell.json`, `python.json`, and `typescript.json` list **zero** `.claude/lib/` paths. F1
touches `core.json` only.

Supporting mechanism: `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`
asserts that every bundled `.claude` **agent, hook, and skill** appears in some manifest
(`:61-102, 139-159`). Note its enumeration covers `agents/`, `hooks/`, and `skills/` only — it does
**not** walk `.claude/lib/`. So an unregistered `.claude/lib/` module would **not** be caught by that
completeness test. The per-module `*.Manifest.Tests.ps1` is the only guard. This raises the cost of
omitting the manifest test, and confirms `issue.md:94-95`'s risk statement.

### Exact file paths F1 must create or edit, in both trees

**Create (repo-side production):**
1. `.claude/lib/worktree-resolution/WorktreeResolution.psm1`
2. `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`

**Create (bundled mirror, byte-identical):**
3. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1`
4. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`

**Edit (registration):**
5. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — add exactly
   two entries to `paths`:
   ```
       ".claude/lib/worktree-resolution/WorktreeResolution.psm1",
       ".claude/lib/worktree-resolution/WorktreeTargetResolution.psm1",
   ```

**Edit (coverage denominator — see Q7):**
6. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — add the same two repo-relative
   paths to `CodeCoverage.Path`.
7. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — the same
   two entries, for parity.

**Create (tests):**
8. `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`
9. `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1`
10. `tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1`

Do **not** add any `extensions/drm-copilot/resources/` path to `CodeCoverage.Path`. The existing
comment at `pester.runsettings.psd1:269-271` states the rule: "No
extensions/drm-copilot/resources/ path is added, because the list holds zero entries under that
prefix and every bundle mirror is guarded by byte identity instead."

---

## Q5 — Existing deny reason-code vocabulary

### Full list from `.claude/hooks/`

`Grep(pattern="\b[A-Z][A-Z0-9]*(_[A-Z0-9]+){1,5}:", path=".claude/hooks", -o, head_limit=0)` —
distinct codes with first-occurrence sites:

| code | file:line (first) |
| --- | --- |
| `CHECKPOINT_MONOTONIC_BLOCKED` | `enforce-checkpoint-monotonic.ps1:216` |
| `CHECKPOINT_ORDER_BLOCKED` | `enforce-checkpoint-monotonic.ps1` (2 occurrences) |
| `COMPLETION_CONSISTENCY_BLOCKED` | `enforce-completion-consistency.ps1:343` |
| `DISCOVERY_ARTIFACT_GATE_BLOCKED` | `enforce-discovery-artifact-gate.ps1:174`; also `validate-discovery-artifact-gate.ps1` |
| `EPIC_BASE_BRANCH_MISMATCH` | `enforce-pr-author-skill.epic-base-branch.ps1` (2 occurrences) |
| `EPIC_INVOCATION_ORIGIN_BLOCKED` | `enforce-epic-invocation-origin.ps1:243` |
| `EPIC_MERGE_GATE_BLOCKED` | `enforce-epic-merge-gate.ps1:382, 433` |
| `EPIC_WAVE_BARRIER_BLOCKED` | `enforce-epic-wave-barrier.ps1:252, 269` |
| `EPIC_WORKTREE_REMOVAL_BLOCKED` | `enforce-epic-worktree-removal-gate.ps1:367` |
| `EVIDENCE_LOCATION_BLOCKED` | `enforce-evidence-locations.ps1:130` |
| `FEATURE_FOLDER_ORDER_BLOCKED` | `enforce-feature-folder-order.ps1:113` |
| `MERMAID_MANAGED_DIAGRAM_BLOCKED` | `enforce-mermaid-validation.ps1` |
| `MERMAID_VALIDATION_BLOCKED` | `enforce-mermaid-validation.ps1:312` |
| `MODEL_ROUTING_BLOCKED` | `validate-orchestrator-output.ps1` |
| `MODEL_ROUTING_RECEIPT_BLOCKED` | `enforce-model-routing-receipt.ps1:142` |
| `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` | `enforce-pr-author-skill-helpers.ps1` |
| `PARALLEL_COHORT_BARRIER_BLOCKED` | `enforce-parallel-cohort-barrier.ps1:202, 219` |
| `PARALLEL_DRIFT_GATE_BLOCKED` | `enforce-parallel-drift-gate.ps1:288, 307` |
| `PARALLEL_INVOCATION_ORIGIN_BLOCKED` | `enforce-epic-invocation-origin.ps1` |
| `PARALLEL_WORKTREE_REMOVAL_BLOCKED` | `enforce-parallel-worktree-removal-gate.ps1:233` |
| `PRD_FEATURE_BLOCKED` | `enforce-prd-feature-before-planner.ps1:354, 377, 403, 426` |
| `PREIMPLEMENTATION_GATE_BLOCKED` | `enforce-orchestration-preimplementation-gate.ps1:366, 442` |
| `PROMOTION_MCP_ONLY_BLOCKED` | `enforce-promotion-mcp-only.ps1:41, 43, 234` |
| `PR_AUTHOR_OUTPUT_EMPTY` | `validate-pr-author-output.ps1:110` |
| `PR_AUTHOR_OUTPUT_MALFORMED` | `validate-pr-author-output.ps1:102` |
| `PR_AUTHOR_OUTPUT_MISSING` | `validate-pr-author-output.ps1:93` |
| `PR_AUTHOR_OUTPUT_NO_PR` | `validate-pr-author-output.ps1:120` |
| `PR_AUTHOR_RECEIPT_HASH_MISMATCH` | `enforce-pr-author-skill-helpers.ps1` |
| `PR_AUTHOR_RECEIPT_MISSING` | `enforce-pr-author-skill-helpers.ps1` |
| `PR_AUTHOR_RECEIPT_NUMBER_MISMATCH` | `enforce-pr-author-skill-helpers.ps1` |
| `PR_AUTHOR_RECEIPT_STALE` | `enforce-pr-author-skill-helpers.ps1` |
| `PR_AUTHOR_SKILL_BLOCKED` | `enforce-pr-author-skill.ps1:173`; `enforce-pr-author-skill-helpers.ps1` |
| `PR_BODY_PATH_NONCANONICAL` | `enforce-pr-author-skill-helpers.ps1` |
| `PR_CONTEXT_MISSING` | `enforce-pr-author-skill-helpers.ps1` |
| `ROUTING_CONTRACT_BLOCKED` | `validate-orchestrator-output.ps1` |

### Naming convention

- `SCREAMING_SNAKE_CASE`, ASCII only, underscore-separated, no digits observed.
- Two families:
  - **Gate-decision prefixes** ending in `_BLOCKED` — one per hook, used as the leading token of the
    whole `permissionDecisionReason` string (e.g. every `PRD_FEATURE_BLOCKED:` in
    `enforce-prd-feature-before-planner.ps1`). These name the *gate*, not the *cause*.
  - **Cause codes** naming a specific failure and **not** ending in `_BLOCKED` —
    `ORCHESTRATOR_STATE_PREFLIGHT_FAILED`, `PR_AUTHOR_RECEIPT_STALE`, `PR_CONTEXT_MISSING`,
    `EPIC_BASE_BRANCH_MISMATCH`, `PR_BODY_PATH_NONCANONICAL`. These are embedded *inside* a reason
    whose leading token is the gate's `_BLOCKED` code (`enforce-pr-author-skill-helpers.ps1` carries
    both families).
- Every code is followed immediately by `: ` and then prose.
- Codes are written as literals inside PowerShell strings; there is no shared constants module for
  them today.

### Where the codes surface

Uniformly in the PreToolUse decision JSON, as the leading token of
`hookSpecificOutput.permissionDecisionReason`. Canonical shape
(`enforce-prd-feature-before-planner.ps1:350-358`):

```
return [ordered]@{
    hookSpecificOutput = [ordered]@{
        hookEventName            = 'PreToolUse'
        permissionDecision       = 'deny'
        permissionDecisionReason = 'PRD_FEATURE_BLOCKED: ...'
    }
}
```

Emitted with `$decision | ConvertTo-Json -Compress -Depth 5 | Write-Output; exit 0` (`:446-448`).
The exit is always 0 — `HookPayload.psm1:31-34` records why: "Exit code 1 is non-blocking for
PreToolUse, so a throwing hook is itself a fail-open."

No code is thrown as an exception, and no code is returned as an object field today. The closest
precedent for a *library-supplied* code is `HookPayload.psm1`'s `Anomaly` property plus
`Get-ClaudeHookPayloadAnomalyReason` (`:87-111`), which maps a code to a prose clause the hook
concatenates into its own `<GATE>_BLOCKED: ...` reason. **That is exactly F1's situation.**

### Recommended literal: `TARGET_WORKTREE_AMBIGUOUS`

Rationale: it is a *cause* code, not a gate code — F1 has no gate of its own, and F4/F5 already own
`PRD_FEATURE_BLOCKED:` and `PR_AUTHOR_SKILL_BLOCKED:` / `MODEL_ROUTING_RECEIPT_BLOCKED:`
respectively. It therefore belongs to the second family and must **not** end in `_BLOCKED`, matching
`ORCHESTRATOR_STATE_PREFLIGHT_FAILED` and `PR_CONTEXT_MISSING`. `TARGET_WORKTREE` names the subject;
`AMBIGUOUS` names the condition; the whole is greppable as one token.

**Confirmed absent from the tree.** `Grep(pattern="TARGET_WORKTREE_AMBIGUOUS|WORKTREE_TARGET|TARGET_UNRESOLVED|NoTarget|Ambiguous", output_mode="count", head_limit=0)`
over the entire repository returned 5 matches, in
`examples/discovery/v1/unspecified-behavior-record.example.json`,
`tests/fixtures/discovery_schemas/v1/unspecified-behavior-record.invalid.json`,
`docs/features/active/2026-08-07-parallel-orchestrator-surface-441/code-review.2026-08-08T20-25.md`,
`docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/user-story.md`, and
`.../spec.md` — every one the ordinary English word `Ambiguous`. A separate case-insensitive grep for
`TARGET_WORKTREE|WORKTREE_AMBIGUOUS|TARGET_RESOLUTION|TARGET_AMBIGU` returned only lower-case
`ambiguous`/`unambiguous` prose. **The literal `TARGET_WORKTREE_AMBIGUOUS` occurs zero times.**

### How it should be surfaced

Three coordinated surfaces, mirroring the `HookPayload` precedent:

1. **On the result object**, as the `ReasonCode` field — populated with exactly
   `'TARGET_WORKTREE_AMBIGUOUS'` when `Status -eq 'Ambiguous'`, and `$null` in every other state.
2. **From an accessor**, `Get-WorktreeResolutionAmbiguityReasonCode`, returning the literal, so F4
   and F5 never hard-code it a second time (mirrors `Get-ClaudeHookPayloadAnomalyCode`,
   `HookPayload.psm1:66-85`).
3. **As a prose clause**, on the result's `Detail` field, so a caller can concatenate directly.

F4 then writes, with no new logic:

```
permissionDecisionReason = 'PRD_FEATURE_BLOCKED: ' + $target.ReasonCode + ' - ' + $target.Detail
```

producing `PRD_FEATURE_BLOCKED: TARGET_WORKTREE_AMBIGUOUS - ...`, which is greppable by either
token and consistent with the two-family convention. F5 substitutes its own gate prefix.

---

## Q6 — "No target" versus "ambiguous": the result shape

This is the contract F4 and F5 are specified against. Four states must be distinguishable, and the
caller's branch for each must be unambiguous from the object alone.

### Recommended return shape for `Resolve-WorktreeCallTarget`

A `[pscustomobject]` built by a single factory (`New-WorktreeResolutionTargetResult`), following the
`ConvertTo-ClaudeHookPayloadResult` precedent (`HookPayload.psm1:113-146`) — **always an object,
never `$null`**, so no caller tests for null first.

| field | type | meaning |
| --- | --- | --- |
| `Status` | `string` | exactly one of `'SessionRoot'`, `'OtherWorktree'`, `'NoTarget'`, `'Ambiguous'` |
| `WorktreeRoot` | `string` or `$null` | the resolved target worktree root, absolute, forward slashes, no trailing slash. Populated for `SessionRoot` and `OtherWorktree`; `$null` for `NoTarget` and `Ambiguous` |
| `SessionRoot` | `string` | **always populated.** The worktree containing the invoking process, resolved by the same locator. This is the documented fallback for `NoTarget` |
| `Signal` | `string` or `$null` | which payload signal produced the target: `'FeatureFolderPath'`, `'Branch'`, `'FilePath'`, or `'SessionRoot'`. `$null` for `NoTarget`; for `Ambiguous` it names the signal *kind* that was present but unresolvable |
| `SignalValue` | `string` or `$null` | the raw token the signal was read from, verbatim, for the deny message |
| `Candidates` | `string[]` | **always an array** (possibly empty). Distinct candidate worktree roots considered. Empty for `NoTarget`; empty-or-multiple for `Ambiguous`; exactly one for the resolved states |
| `ReasonCode` | `string` or `$null` | exactly `'TARGET_WORKTREE_AMBIGUOUS'` when `Status -eq 'Ambiguous'`; `$null` otherwise |
| `Detail` | `string` | **always a non-empty string.** A prose clause safe to concatenate into a `permissionDecisionReason` |

### The four states enumerated

| # | condition | `Status` | `WorktreeRoot` | `Signal` | `Candidates` | `ReasonCode` | caller action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | a target signal exists and its containing worktree is the same worktree the process is running in | `'SessionRoot'` | = `SessionRoot` | the signal kind that resolved | 1 element | `$null` | resolve state against `WorktreeRoot` — **identical to today's behaviour** |
| 2 | a target signal exists and resolves to a different worktree | `'OtherWorktree'` | that worktree's root | the signal kind that resolved | 1 element | `$null` | resolve state against `WorktreeRoot` |
| 3 | the payload carries **no** target signal at all | `'NoTarget'` | `$null` | `$null` | empty | `$null` | fall back to `SessionRoot` — the epic's "use the session root only when the call genuinely has no target" (`epic.md:99-100`) |
| 4 | a target signal **is** present but the correct worktree cannot be identified | `'Ambiguous'` | `$null` | the signal kind | 0 or >= 2 | `'TARGET_WORKTREE_AMBIGUOUS'` | **deny**, with `ReasonCode` + `Detail` in the reason |

Sub-cases that must all map to state 4 (`Ambiguous`):

- A bare repo-relative feature-folder token with no worktree prefix, where the folder exists in
  **two or more** known worktrees (`Candidates.Count >= 2`).
- A bare repo-relative token where the folder exists in **no** worktree reachable from the session
  root (`Candidates.Count -eq 0`) — a signal was present, so this is not `NoTarget`.
- An absolute path whose upward walk finds no `.git` entry before the filesystem root.
- A branch signal that matches no worktree, or more than one.

The state-3/state-4 boundary is the single most consequential line in the contract: **the presence
of a signal, not the success of resolving it, is what separates them.** A payload that names nothing
is `NoTarget` and is safe to serve from the session root. A payload that names something the module
cannot place is `Ambiguous` and must deny. Collapsing the two is exactly the false-approval mode the
epic exists to eliminate (`epic.md:57-64`).

### Why `SessionRoot` is a separate always-populated field

If `NoTarget` returned `WorktreeRoot = <session root>`, a caller that branches only on
`$null -ne $result.WorktreeRoot` would silently treat an untargeted call as a resolved one — and the
distinction the epic depends on would be unenforceable from the object. Keeping `WorktreeRoot` null
for both unresolved states forces the caller to write one explicit branch per state. `SessionRoot`
being always populated means the `NoTarget` branch is still a one-liner.

### Rejected alternatives for the shape (brief)

- **Boolean pair (`IsResolved` + `IsAmbiguous`).** Four states encoded in two booleans admits an
  unrepresentable fourth combination and needs a documented convention to exclude it. A single
  four-valued `Status` string cannot be malformed.
- **An `IsSessionRoot` convenience boolean.** Derivable as `$Status -eq 'SessionRoot'`. Two sources
  of truth for one fact, against the simplicity-first rule. Dropped.
- **Returning `$null` for `NoTarget`.** Contradicts the `ConvertTo-ClaudeHookPayloadResult`
  precedent and forces every caller to null-check before reading any field.

### Path normalisation's return shape

`ConvertTo-WorktreeResolutionRepoRelativePath -Path <relative or absolute>` returns a
`[pscustomobject]`:

| field | type | meaning |
| --- | --- | --- |
| `IsNormalized` | `bool` | whether a containing worktree was located |
| `RepoRelativePath` | `string` or `$null` | forward-slash, no leading `./`, no trailing `/`. **Never truncated to a fixed segment count**, and never shortened at all: the full remainder below the worktree root is preserved |
| `WorktreeRoot` | `string` or `$null` | the located containing worktree root |
| `ReasonCode` | `string` or `$null` | `'TARGET_WORKTREE_AMBIGUOUS'` when `IsNormalized` is `$false` |
| `Detail` | `string` | always populated |

One code, reused: a path whose containing worktree cannot be located *is* the case "the correct
target cannot be identified", satisfying `issue.md:50-52`'s requirement of **a single** distinct
greppable code.

A relative input is normalised against a supplied `-WorktreeRoot` when the caller has already
resolved one; with no root supplied, a relative input is returned as-is with
`IsNormalized = $true` and `WorktreeRoot = $null` **only** if the caller passed an explicit switch
acknowledging the ambiguity. The safer default is `Ambiguous`. Record this as an open decision for
the spec author; the research does not have evidence to settle which F4 needs, because F4's prompt
scan produces relative tokens by construction (Q2) and will most often supply a root from the target
derivation half.

### Composition helper (derived from Q2)

`Join-WorktreeResolutionPath -WorktreeRoot <root> -RepoRelativePath <rel>` -> absolute forward-slash
path. F4 and F5 need this to turn a resolved target into an absolute
`artifacts/orchestration/orchestrator-state.json`, which is the literal every hook currently spells
relatively (Q2, eleven sites). Without it, each consumer re-implements the join.

---

## Q7 — Test obligations and existing Pester conventions

### Location and naming

`tests/scripts/claude-lib/<module-directory>/<ModuleName>.Tests.ps1`, mirroring
`.claude/lib/<module-directory>/<ModuleName>.psm1`. Verified across all 11 module directories by
`Glob("tests/scripts/claude-lib/**/*")`. Supplementary suites append a qualifier before `.Tests.ps1`:
`*.Manifest.Tests.ps1` (registration + mirror), `*.Parity.Tests.ps1` (config parity),
`*.TruthTable.Tests.ps1`, `*.VersionFloor.Tests.ps1`. A per-function suite may take the function's
own name (`Get-ComplexityFloor.Tests.ps1`, `Resolve-DelegationModel.Tests.ps1`).

There is also a tree-wide convention suite at
`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, which **discovers modules from disk**
(`:30-33`) and therefore covers F1's new files automatically — the module must satisfy the strict-mode
guard, the `-ErrorAction Stop` import rule, the `CONVENTION:` help sentence, and the 500-line cap from
the moment it is written.

### Representative test file, read in full: `CleanupWorktreeManifest.Tests.ps1`

- **Header** (`:1-19`): `#Requires -Version 7.0` and
  `#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }` on lines 1-2, then a
  comment-based-help block whose `.DESCRIPTION` states the determinism posture explicitly: "No test
  creates, writes, or reads a temporary file, reads a wall clock, spawns a process, or touches the
  network."
- **`BeforeAll` import style** (`:21-27`):
  ```
  $script:CleanupManifestModulePath = (Resolve-Path "$PSScriptRoot/../../../../.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1").Path
  Import-Module $script:CleanupManifestModulePath -Force
  ```
  The comment at `:23-24` records why `Resolve-Path` matters: "Resolve-Path normalizes separators so
  **Pester coverage breakpoints bind to the path the run settings name**." F1's suites must do the
  same or their coverage rows will not appear.
- **Nesting**: `Describe '<ModuleName>'` -> nested `BeforeAll` registering default seam mocks
  (`:30-40`) -> `Context '<concern>'` (`'vocabulary constants'`, `'path normalization'`,
  `'removal record lookup'`, `'allow predicate'`) -> `It '<behaviour sentence>'`.
- **Mocking style** (`:36-39`): `Mock -CommandName <seam> -ModuleName '<ModuleName>' -MockWith { ... }`.
  The comment at `:31-35` records the gotcha: "The literals are inline rather than read from a shared
  variable because a `-ModuleName` mock body executes in the module's session state, where a
  test-scope variable does not resolve." Inner registrations override for one test only (`:120-125`).
- **Internal state assertions** use `InModuleScope '<ModuleName>' { $script:Constant }` (`:45, 55`).
- **Arrange / Act / Assert** comments are mandatory in practice — every `It` in every file read
  carries all three, with the Assert comment stating *why* the assertion matters, not what it does.
- **Table-driven `-ForEach`** is used where a case list exists. Two forms appear:
  - inline hashtable rows with `<key>` interpolation in the `It` name —
    `ModelRouting.Parity.Tests.ps1:30-32` (`It 'pins BASE_COMPLEXITY_TO_MODEL[<band>] ...' -ForEach @(@{ band = 'C1' }, ...)`);
  - `<_>` for a bare value list — `Get-ComplexityFloor.Tests.ps1:43, 87, 126`;
  - a precomputed variable when the rows are built in the discovery phase —
    `BlastRadius.Parity.Tests.ps1:239` (`-ForEach $derivationCase`), with the comment at `:33`
    explaining that the list must be built at discovery time for `-ForEach` to generate `It` blocks.

**F1's required matrix (`issue.md:99-107`) is a natural `-ForEach` table:** cwd (session root vs item
worktree) x path form (relative vs absolute) x target (own item vs sibling vs absent). With the two
filesystem seams mocked, each row is a hashtable of injected `.git` topology plus an expected
`Status`/`ReasonCode` pair.

### Coverage configuration — and the gap F1 must close

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`:

- `Run.Path = @('scripts', 'tests/powershell', 'tests/scripts')` (`:3`) — so a suite under
  `tests/scripts/claude-lib/worktree-resolution/` **is discovered automatically**. No change needed
  for discovery.
- `Run.Exit = $true` (`:4`).
- `CodeCoverage.Enabled = $true` (`:18`), `OutputFormat = 'CoverageGutters'` (`:21`),
  `OutputPath = 'artifacts/pester/powershell-coverage.xml'` (`:22`).
- **`CodeCoverage.Path` is an explicit per-file allow-list** (`:23-283`). The file says so itself,
  repeatedly and in almost identical words at `:159`, `:212-215`, `:218-222`, `:241-245`,
  `:248-253`, `:256-260`, `:265-271`. Example (`:211-216`):
  > Issue #635 added the sanctioned-removal manifest module read by both worktree removal gate
  > hooks. CodeCoverage.Path is an explicit per-file allow-list, so an unregistered production file
  > would sit outside the coverage denominator, which the Coverage Exclusion Policy forbids.
  > Registered here beside the other .claude/lib modules.
- Every existing `.claude/lib/*.psm1` that is measured is listed individually — `:66, 70-71, 96,
  100-102, 106-113, 163-169, 174, 180-182, 207-210, 216, 223`.
- `CoveragePercentTarget = 0` (`:285`) with the comment "Optional: don't fail the run on coverage
  percentage". **The 85% threshold is therefore a policy gate evaluated by review, not a runner
  gate.** A passing PoshQC test run is not evidence that the threshold was met.

**Answer to the explicit question: a new module is NOT picked up automatically. It needs two
explicit entries**, one in each runsettings copy.

**Parity obligation.** `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18` lists
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` among the files required to be
text-identical to their mirror under `extensions/drm-copilot/resources/powershell/PoshQC/` (the
path rewrite is at `:56-59`). Both copies exist (`Glob("extensions/drm-copilot/resources/powershell/PoshQC/settings/*")`).
So the coverage entry must be added **twice**.

### The MCP PoshQC coverage gotcha — status

A prior session's project memory (`mcp-poshqc-test-reads-installed-extension-settings`, written
2026-08-25, 20 days old at the time of this research) records that
`mcp__drm-copilot__run_poshqc_test` resolves its runsettings from the **installed VS Code
extension**, at a path like
`C:\Users\DanMoisan\.vscode-insiders\extensions\danmoisan.drm-copilot-<version>\resources\powershell\PoshQC\settings\pester.runsettings.psd1`,
and reads **neither** in-repo copy — so a newly added `CodeCoverage.Path` entry produces no coverage
row until the extension is rebuilt and reinstalled.

**Verification status in this session: NOT re-verified.** The MCP tool could not be invoked and no
shell was available to inspect the installed extension directory. The memory is consistent with what
is observable in-repo — the two in-repo copies exist and are parity-bound, and nothing in
`PoshQC.Testing.psm1` reads a repo-root path by default (`SettingsPath = $script:PesterSettings`,
`:156`, is module-root-derived) — but that is corroboration, not confirmation.

**Recommended plan handling.** Treat the gotcha as live until disproved:

1. Add the two entries to **both** in-repo runsettings copies (the parity obligation, independent of
   the gotcha).
2. Measure coverage by invoking the self-hosted module directly rather than via MCP:
   `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -ScanFolders @('tests/scripts/claude-lib')`.
   `PoshQC.Testing.psm1:156` defaults `SettingsPath` to `$script:PesterSettings`, which the module
   sets from its own module root — so the self-hosted module reads the self-hosted settings and
   honours entries added in the same change.
3. **Do not conclude the registration failed** if the MCP runner reports no rows for the new files.
   That is the tooling-path symptom, not a coverage failure.
4. Parse `artifacts/pester/powershell-coverage.xml` per file by keying on the enclosing `package`
   element (full directory path), never the bare `sourcefile` name.

### What the F1 test suite must cover to reach 85% line coverage

- Both filesystem seams, both polarities each (entry present as directory, present as file, absent;
  file text well-formed, malformed, empty, `$null`).
- The ascent: hit at depth 0, hit at depth > 0, no hit before filesystem root, and the
  drive-root termination case on Windows.
- All four `Status` states, plus each `Ambiguous` sub-case listed in Q6.
- Separator normalisation: backslash input, forward-slash input, trailing slash, mixed.
- The full required matrix from `issue.md:99-107`, table-driven.
- `Get-WorktreeResolutionAmbiguityReasonCode` returning the exact literal (this is the F4/F5
  contract pin).
- The `New-WorktreeResolutionTargetResult` factory's field invariants: `Candidates` always an array,
  `Detail` never empty, `ReasonCode` null unless `Ambiguous`.

---

## Q8 — Batch-budget and hook constraints on execution

### `.claude/hooks/enforce-powershell-batch-budget.ps1`

- **What it gates:** `PreToolUse` on `Write` and `Edit`, for `.ps1`, `.psm1`, and `.psd1` targets
  (`:6-8`, regex at `:273` and `:348`). Non-PowerShell paths pass through.
- **Caps:** **3 production PowerShell files and 3 test PowerShell files per batch** (`:10-11`;
  defaults `[int] $ProdCap = 3, [int] $TestCap = 3` at `:316-317`).
- **Batch scope:** the current Claude Code session (`:13`).
- **Distinctness:** only distinct file paths are counted; repeated edits to the same file consume one
  slot (`:15`, enforced at `:289-291`).
- **Test classification** (`:284`): `(^|/)tests/.*\.ps1$` **or** `\.Tests\.ps1$`. Everything else
  `.ps1`/`.psm1`/`.psd1` is production (`:34-35`).
- **State file:** `<Root>/.claude/state/powershell-batch-budget.<session_id>.json` (`:14`; state dir
  composed at `:352`). `<Root>` defaults to `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`
  (`:210, 269, 315`) — the hook's own `.claude/hooks` -> `.claude` -> root.
- **Session id resolution** (`:17-22`): first non-empty of `CLAUDE_SESSION_ID`, the contents of
  `<root>/.claude/state/current-session-id`, or a worktree-derived identifier built from the root's
  leaf name plus a short stable hash of its normalized path (`:162-167`). Sanitized before being
  composed into a filename (`:95-109`).
- **Containment:** a candidate resolving outside the root is discarded — allow, no slot consumed, no
  state written (`:24-28`, `:277-282`). Persisted entries failing the same test are dropped on
  rehydrate (`:221-224`), so a state file carried between worktrees cannot spend this worktree's
  budget.
- **Deny reason** (`:296`): prose, **not** a `*_BLOCKED` code —
  `"PowerShell per-batch budget exceeded: $kind file cap is $cap and is already full (...). Requested new file: $normalized. Split the work into a new batch, raise the cap via CLAUDE_POWERSHELL_BUDGET_$kindUpper environment variable with approved scope, or reset the batch by deleting $StateFile."`
- **How a plan schedules a reset:** three sanctioned routes, all named in that reason and at
  `:37-45`:
  1. delete the state file `<root>/.claude/state/powershell-batch-budget.<session_id>.json`;
  2. set `CLAUDE_POWERSHELL_BUDGET_PROD` / `CLAUDE_POWERSHELL_BUDGET_TEST` to a positive integer
     **before the session starts** (`:37-40`) — not usable mid-session;
  3. write `{"prodCap": N, "testCap": M}` into the state file (`:39-40`).
  `.claude/rules/powershell.md:40-41` adds the policy framing: "Per-batch cap in all modes: at most
  3 production files and 3 test files unless an explicit override has been approved. If a batch would
  exceed the cap, split the work into smaller batches."

### F1's file count against the cap — a planning constraint that must be surfaced now

From Q4's file list, classified by the hook's own rule at `:284`:

**Production PowerShell files (6):**
1. `.claude/lib/worktree-resolution/WorktreeResolution.psm1`
2. `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`
3. `extensions/.../claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1`
4. `extensions/.../claude-customizations/.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`
5. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
6. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

The four bundle-mirror and runsettings files are **not** under `tests/` and do not match
`\.Tests\.ps1$`, and `.psd1` is inside the extension regex at `:273`. They therefore consume
production slots. `core.json` is `.json` and consumes nothing.

**Test PowerShell files (3):** the three suites under `tests/scripts/claude-lib/worktree-resolution/`.

**Consequence: 6 production files against a cap of 3.** The plan must schedule **at least one
budget reset**, or split F1 across at least two batches. The test side (3 of 3) fits exactly, with
zero headroom — any additional test file forces a second reset. A natural split:

- **Batch A (3 prod):** the two repo-side `.psm1` files + `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- **reset**
- **Batch B (3 prod):** the two mirror `.psm1` files + the mirrored runsettings `.psd1`.
- **Batch C (3 test):** the three Pester suites.

### PowerShell toolchain commands the plan must use

From `.claude/rules/powershell.md:13-20`, run **in order, restarting from step 1 if any step fails or
changes files**:

1. **Format** — `mcp__drm-copilot__run_poshqc_format`
2. **Lint** — `mcp__drm-copilot__run_poshqc_analyze` (optional autofix:
   `mcp__drm-copilot__run_poshqc_analyze_autofix`)
3. **Type check** — not applicable to PowerShell; skip (`:17`)
4. **Test** — `mcp__drm-copilot__run_poshqc_test`, using the repo config at
   `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (`:18`)

`.claude/rules/powershell.md:20` adds: "Use the MCP server functions; do not substitute VS Code task
wrappers." The direct self-hosted invocation recommended in Q7 is a **coverage-measurement
supplement**, not a substitute for the MCP gate; run both and record both.

Scan scope for the test stage comes from `config/poshqc-scan.json`:
```json
{ "version": 1, "test": { "scanFolders": ["scripts", "tests/powershell", "tests/scripts"] } }
```
`tests/scripts/claude-lib/worktree-resolution/` is inside `tests/scripts`, so no change is needed
there. Note `config/poshqc-scan.json` carries **no coverage configuration at all** — coverage lives
solely in the runsettings.

**Coverage-mode invocation and its terminal output.** Coverage is not a separate mode: it is on
unconditionally via `CodeCoverage.Enabled = $true` (`pester.runsettings.psd1:18`). Output verbosity
is `Detailed` (`:10`) and `TestResult` writes JUnit XML to `artifacts/pester/pester-junit.xml`
(`:12-15`), with coverage to `artifacts/pester/powershell-coverage.xml` in CoverageGutters format
(`:21-22`).

**The literal success line could not be observed.** No command could be executed in this session
(Bash disabled; no PowerShell tool available), and no captured PoshQC run output exists in the tree
that could be quoted verbatim. **This is unknown and must not be inferred.** The plan should capture
the actual line on first run and record it in `evidence/qa-gates/`.

Two recorded gate hazards the plan must avoid, both from prior project memory and both consistent
with the configuration read here:

- `Invoke-Pester` returns process exit 0 even with failing tests unless `Run.Exit`/`-EnableExit` is
  set. The repo runsettings **do** set `Run.Exit = $true` (`:4`), so the MCP path is covered; a
  direct `Invoke-Pester` outside those settings is not. Prefer `-EnableExit`, or
  `$r = Invoke-Pester -Path <suite> -PassThru; exit $r.FailedCount`.
- `CoveragePercentTarget = 0` means a green test run says nothing about the 85% threshold. Any
  acceptance criterion phrased as "the suite passes" does not gate coverage; the criterion must read
  the coverage XML.

---

## Q9 — Line-count headroom and file decomposition

### Basis for the estimate

Comment-based help in this repository is verbose. Measured ratios from files read in full:

- `HookPayload.psm1`: 496 lines, 10 exported functions, ~50 lines per function including help.
  `Read-ClaudeHookRawPayload` alone spends 30 lines on help (`:149-177`) for a 44-line body.
- `CleanupWorktreeManifest.psm1`: 415 lines, 6 functions (~69 lines each), plus 33 lines of module
  header and 29 lines of constants.
- `ModelRouting.psm1`: 231 lines, 2 functions, 22-line header, 61 lines of commented constants.

A realistic planning figure is **45-60 lines per function** and **30-40 lines of module header plus
constants**.

### Proposed decomposition: two `.psm1` files in one directory

Precedent for multiple modules in one directory: `orchestrator-state/` holds 11,
`blast-radius/` holds 8, `mermaid/` holds 4.

**File 1 — `.claude/lib/worktree-resolution/WorktreeResolution.psm1` (~300-360 lines)**

The worktree locator and path normaliser. No payload knowledge; depends on nothing.

| element | est. lines |
| --- | --- |
| module header (`.SYNOPSIS`/`.DESCRIPTION`/`.NOTES`, `CONVENTION:` sentence, strict-mode guard) | 35 |
| constants (`$script:GitEntryName = '.git'`, `$script:GitDirPrefix = 'gitdir:'`, `$script:AmbiguityReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`, `$script:MaximumAscentDepth`) with prose comments | 30 |
| `Get-WorktreeResolutionGitEntryKind` (existence seam) | 35 |
| `Get-WorktreeResolutionGitFileText` (read seam) | 30 |
| `ConvertTo-WorktreeResolutionNormalizedPath` (separator + trailing-slash normalisation) | 30 |
| `Test-WorktreeResolutionRootMarker` (is this level a worktree root? classifies Directory / valid `gitdir:` File / neither) | 50 |
| `Find-WorktreeResolutionRoot` (the upward ascent) | 60 |
| `ConvertTo-WorktreeResolutionRepoRelativePath` (+ its result construction) | 55 |
| `Join-WorktreeResolutionPath` | 25 |
| `Get-WorktreeResolutionAmbiguityReasonCode` | 20 |
| `Export-ModuleMember` | 10 |
| **total** | **~380** |

Headroom at the cap: ~120 lines. Adequate but not generous; if the ascent or the normaliser grows,
move `Join-WorktreeResolutionPath` and `Get-WorktreeResolutionAmbiguityReasonCode` into File 2.

**File 2 — `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (~330-390 lines)**

Payload-signal extraction and the four-state target derivation. Imports File 1 at column 0 with
`-ErrorAction Stop` (required by `ClaudeLibModuleConvention.Tests.ps1:69-86`).

| element | est. lines |
| --- | --- |
| module header + strict-mode guard + `Import-Module ... -ErrorAction Stop` | 40 |
| constants: the four `Status` literals, the four `Signal` literals, the feature-folder path pattern, the branch pattern — each with a comment explaining why the set is narrow (the `CleanupWorktreeManifest.psm1:42-59` style) | 40 |
| `New-WorktreeResolutionTargetResult` (the single factory; field invariants) | 55 |
| `Find-WorktreeResolutionFeatureFolderSignal` (scan a prompt for feature-folder path tokens, **preserving any absolute prefix** — the Q2 correction) | 55 |
| `Find-WorktreeResolutionBranchSignal` | 35 |
| `Find-WorktreeResolutionFilePathSignal` | 35 |
| `Resolve-WorktreeCallTarget` (signal precedence, candidate dedup, four-state dispatch) | 75 |
| `Export-ModuleMember` | 10 |
| **total** | **~345** |

**Total new production PowerShell: ~725 lines across 2 files, both comfortably under the cap.**

### Why two files and not one, or three

- **One file** would land at ~725 lines, over the 500-line cap, and would be rejected by
  `ClaudeLibModuleConvention.Tests.ps1:123-136`.
- **Three files** would add a third mirror file and a third coverage entry, pushing the production
  file count from 6 to 9 and adding a third batch-budget reset (Q8) for no separation-of-concerns
  gain. The split at locator-versus-derivation is the natural seam: File 1 is the filesystem-bearing
  half and File 2 is pure given File 1.
- The split also mirrors the epic's own contract decomposition: File 1 is "path normalisation", File
  2 is "target derivation", and the reason code is declared once in File 1 and re-exported through
  File 2's results.

### Function-naming check (approved verbs)

`Get-`, `Find-`, `Test-`, `ConvertTo-`, `New-`, `Join-`, `Resolve-` are all approved PowerShell
verbs; PSScriptAnalyzer's `PSUseApprovedVerbs` will pass. `Resolve-` already appears in this tree on
`Resolve-DelegationModel` (`ModelRouting.psm1:148`) and `Resolve-ClaudeHookToolInput`
(`HookPayload.psm1:441`), so the flagship's shorter name (`Resolve-WorktreeCallTarget`, without the
full module prefix) has precedent.

---

## Rejected Alternatives (brief)

- **Extend `HookPayload.psm1`.** 4 lines of headroom (496/500) and it would falsify that module's
  stated "no filesystem access" property (`HookPayload.psm1:37-39`). Q1.
- **`git rev-parse --show-toplevel` as the locator.** Mockable via the mandated `Invoke-GitExe`
  wrapper, but no `.claude/lib` module or `.claude/hooks` script spawns a subprocess today, the unit
  test policy forbids external-process dependence, and it puts a process launch on the PreToolUse hot
  path. Q3.
- **Enumerating `<main>/.git/worktrees/*/gitdir` as the primary locator.** Requires the main
  checkout's path as an input, which is the thing being derived. Retain as a possible secondary
  capability only. Q3.
- **Prefix-comparison containment against a single known root.** Directly falsified: the
  `drm-copilot-wt/<timestamp>` worktree is a sibling of the main checkout, not a descendant. Q3.
- **Boolean-pair or `IsSessionRoot` result encodings.** Admit unrepresentable combinations or
  duplicate a single fact. Q6.
- **A `*_BLOCKED`-suffixed reason code for F1.** F1 owns no gate; the suffix family is reserved for
  a hook's own leading token. Q5.

---

## Open Questions for the Spec Author

1. **Relative-path normalisation with no supplied root.** Should
   `ConvertTo-WorktreeResolutionRepoRelativePath` treat a bare relative input with no
   `-WorktreeRoot` as `Ambiguous`, or return it unchanged? Research recommends `Ambiguous` as the
   fail-closed default but has no evidence of which F4 needs. Q6.
2. **Signal precedence.** When a payload carries more than one signal kind (a feature-folder path
   *and* a branch), which wins? The current prd-feature hook prefers the checkpoint as a
   disambiguator (`enforce-prd-feature-before-planner.ps1:294-302`), but that is the very behaviour
   F5 must eliminate. Recommend: never consult a checkpoint inside F1; if two signals resolve to
   different worktrees, return `Ambiguous`.
3. **Does the module need a worktree enumerator?** The `Candidates.Count >= 2` sub-case of
   `Ambiguous` implies knowing the set of sibling worktrees, which needs Option B's
   `.git/worktrees/*/gitdir` walk. If the spec narrows `Ambiguous` to "signal present, containing
   worktree not locatable" only, no enumerator is needed and File 1 shrinks by ~40 lines. This is a
   real scope fork and should be settled before planning.
4. **The MCP PoshQC coverage-path gotcha** is unverified in this session (Q7). Whether it still
   reproduces determines whether the plan needs an extension rebuild step.

---

## Verification Ledger

| claim | how verified |
| --- | --- |
| `.claude/lib/` holds 11 module dirs / 44 files, none a worktree resolver | Glob + ripgrep, two independent enumerations (N1, N2). Epic claim **re-verified, holds** |
| `HookPayload.psm1` is 496 lines | `Grep(pattern="^", output_mode="count")` |
| `enforce-prd-feature-before-planner.ps1` is 448 lines; functions at :189 and :219; `Test-Path` at :91, :108, :201 | full file read. **Re-verified, holds** |
| truncation "documented at 16-18, applied at 265" | full file read. **Discrepancy: documented :17-19, applied :272-277** |
| absolute-prefix loss is caused by the regex anchor at :252, not the segment slice | full file read of `Find-PrdFeatureFolderFromPrompt` (:219-308). **Correction to the epic's characterisation** |
| worktree `.git` is a file containing `gitdir: <abspath>` | direct `Read` of two different worktrees' `.git` |
| main checkout `.git` is a directory | `Read` returned `EISDIR` |
| a worktree may live outside the main checkout | `drm-copilot-wt/2026-09-13T08-30/.git` read directly |
| `.git/worktrees/<n>/gitdir` points back at the worktree's `.git` file; `commondir` is `../..` | direct `Read` of both files |
| `model-routing` mirror is byte-identical | **NOT verified** — first 30 lines compared by read; no hash could be computed (Bash disabled). Byte identity is asserted in-repo only for `orchestrator-state` and `discovery-validation` |
| only `core.json` lists `.claude/lib/` paths | ripgrep over all six manifests |
| `CodeCoverage.Path` is an explicit per-file allow-list | `pester.runsettings.psd1:23-283` plus its own seven self-describing comments |
| runsettings parity is enforced | `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:9-18, 56-59` |
| `TARGET_WORKTREE_AMBIGUOUS` occurs zero times | two ripgrep passes, one case-sensitive and one case-insensitive, whole repo |
| MCP PoshQC reads installed-extension settings | **NOT verified this session.** Prior project memory, 20 days old; corroborated only indirectly |
| the literal success line PoshQC prints | **UNKNOWN.** No command could be executed |
