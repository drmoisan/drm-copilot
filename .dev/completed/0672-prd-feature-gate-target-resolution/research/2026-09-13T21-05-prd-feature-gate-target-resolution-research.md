# Research — prd-feature gate target resolution (Issue #672, epic `worktree-scoped-state-resolution`, F4, wave 1)

- **Timestamp:** 2026-09-13T21-05
- **Worktree:** `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5748b6943baafa3a`
- **Branch base:** `epic/worktree-scoped-state-resolution-integration`
- **Scope:** research only. No source, configuration, or test file was modified.

All line citations below were re-read against this tree on 2026-09-13. Line-count figures were
produced by a whole-file line match (`^`) over the named file, which matches the line numbering
the file reader reports.

---

## 0. Citation drift against the delegation brief and the epic manifest

| claim as supplied | status against this tree |
| --- | --- |
| hook is 448 lines | **Confirmed.** `.claude/hooks/enforce-prd-feature-before-planner.ps1` = 448 lines. |
| `Find-PrdFeatureFolderFromPrompt` at line 219 | **Confirmed** (declaration line 219; body 219-308). |
| `Get-PrdFeatureCheckpointFolder` at line 189 | **Confirmed** (declaration 189; body 189-217). |
| truncation "documented at lines 16-18" | **Partially accurate.** The documented statement spans lines 16-24; lines 16-18 are its first three lines. |
| truncation "applied at line 265" | **Drifted.** Line 265 begins the explanatory comment (265-271). The executable truncation is lines 272-277: split/filter at 272, the `-lt 4` rejection at 273-275, `$segments[0..3] -join '/'` at 277. |
| `Test-Path -LiteralPath` at lines 91, 108, 201 | **Confirmed**, and these are the only three `Test-Path` call sites in the file. |
| no worktree resolution anywhere in the file | **Confirmed.** No `git worktree`, `$PWD`, `Get-Location`, `Resolve-Path`, or `$PSScriptRoot`-derived root appears outside the line-78 module import. |
| `.codex/hooks/` contains no mirror | **Confirmed by enumeration** of all 30 files in `.codex/hooks/`; no `enforce-prd-feature-before-planner.ps1` and no differently named analogue of it. |
| epic manifest: preimplementation helpers = 495 lines | **Drifted.** Actual 349. Also: gate 496 (not 495), modes 480, epic-merge-gate 487 (not 486), `enforce-pr-author-skill.ps1` 312 (not 311). Only the 448 figure for F4's own file is exact. |

Additionally: `quality-tiers.yml` **does not exist at the repository root** (glob `**/quality-tiers.y*ml`
returns nothing), although `.claude/rules/quality-tiers.md` declares it the source of truth. F4
therefore cannot cite a tier classification for this file. The uniform gates still apply
unconditionally: line coverage >= 85%, zero lint findings, zero format drift, zero architecture
violations. PowerShell is exempt from the branch-coverage threshold because Pester does not measure it.

---

## A. Current behaviour — payload intake to allow/deny

### A.1 Invocation and process working directory

`.claude/settings.json:181` registers the hook as:

```
"command": "pwsh -NoProfile -File .claude/hooks/enforce-prd-feature-before-planner.ps1"
```

under `PreToolUse` matcher `"Agent"` (matcher at `.claude/settings.json:177`). The command carries a
**repo-relative** script path and **no working-directory override**. The hook process therefore
inherits the Claude session's current directory, and every relative path the script later hands to
`Test-Path` / `Get-Content` resolves against that session directory. This is the mechanical root of
the cwd coupling; it is not something the script can opt out of without resolving a root explicitly.

### A.2 Prompt acquisition from the PreToolUse payload

1. `L444`: `Invoke-PrdFeatureBeforePlannerDecision -ToolInputRaw (Read-ClaudeHookRawPayload)`.
   `L440-442` is the dot-source guard (`if ($MyInvocation.InvocationName -eq '.') { return }`), so
   tests load the file without running the entrypoint. `L446` writes the compressed decision JSON;
   `L448` exits 0.
2. `Read-ClaudeHookRawPayload` (`.claude/lib/hook-payload/HookPayload.psm1:148-224`) reads stdin
   first — guarded by a `[Console]::IsInputRedirected` probe (`L183`, evaluated `L198`) so a
   non-redirected console does not block — then falls back to `$env:CLAUDE_HOOK_INPUT` (`L187`,
   returned `L215`) and then `$env:CLAUDE_TOOL_INPUT` (`L191`, returned `L219`); `L223` returns the
   empty string when all three are blank.
3. `L348`: `Resolve-ClaudeHookToolInput -Raw $ToolInputRaw` (`HookPayload.psm1:441-484`) parses the
   envelope (`L467`) and strictly extracts the nested `tool_input` object (`L477`). It returns
   `IsValid`, `Value` (the `tool_input` object), **`Envelope` (the parsed root)**, and `Anomaly`.
4. `L361`: `subagent_type` is read from `$envelope.Value` (the nested object) via
   `Get-ClaudeHookToolInputString` (`HookPayload.psm1:410-439`), which returns `''` for an absent
   property.
5. `L366`: `prompt` is read from the same nested object by the same helper.

**The envelope root is never read by this hook.** `$envelope.Envelope` is available on the returned
object but is not consumed anywhere in the file. Any envelope-root field — including the `cwd` field
that Claude Code documents on the PreToolUse payload — is therefore unavailable to the current
decision path by construction, not by omission of a parse.

### A.3 Folder resolution

- `L367`: `$folder = Find-PrdFeatureFolderFromPrompt -Prompt $prompt`.
- `L368-370`: **only when that returns falsy** does `$folder = Get-PrdFeatureCheckpointFolder`.
- `L372-380`: still falsy -> deny (reason R2 below).
- `L382`: `$folderNormalized = ($folder -replace '\\','/').TrimEnd('/')`.

Inside `Find-PrdFeatureFolderFromPrompt` (`L219-308`):

- `L252`: the match pattern is `'docs[\\/]+features[\\/]+active[\\/]+[^\s"''`]+'`. It is **unanchored**,
  so it matches the `docs/...` substring of an absolute path and silently discards everything before
  it. There is no drive letter, UNC prefix, or worktree-prefix capture anywhere.
- `L253-256`: zero matches -> `$null`.
- `L261`: an order-preserving `List[string]` is used for deduplication (issue #518 requirement; a
  hashtable is explicitly forbidden by the comment at `L258-260`).
- `L263`: normalize backslashes to `/` and `TrimEnd('/')`.
- `L272`: `$segments = @($normalized -split '/' | Where-Object { $_ -ne '' -and $_ -ne '.' })`.
- `L273-275`: fewer than four segments -> the candidate is discarded.
- `L277`: `$truncated = ($segments[0..3] -join '/')` — **the fixed segment-count truncation**.
  Because the regex match already began at `docs`, this expression cannot re-attach a prefix; it can
  only ever produce a four-segment repo-relative string.
- `L278-280`: first-occurrence-preserving dedupe.
- `L289-291`: exactly one distinct candidate -> return it, **without consulting the checkpoint**.
- `L296-302`: two or more distinct candidates -> consult `Get-PrdFeatureCheckpointFolder` and prefer
  the candidate equal to its `feature-folder` value.
- `L307`: otherwise return `$candidates[0]` (earliest occurrence).

**Why the truncation discards an absolute prefix.** Two independent mechanisms, both at work:
(1) the regex at `L252` is unanchored and starts the match at the literal `docs`, so a prefix such as
`C:/repos/TaskMaster/.worktrees/839/` is never part of the match text; (2) even if it were, `L272`
splits on `/` and `L277` keeps indices 0..3 unconditionally, so any prefix segments would be pushed
out of the retained window. The function's declared return contract (`L235-237`) is "a repo-relative
path normalized to forward slashes, or `$null`" — that is, prefix loss is the *specified* behaviour,
not an accident.

### A.4 Every `Test-Path` call site and the root each resolves against

| line | expression | argument | resolves against |
| --- | --- | --- | --- |
| `L91` | `Test-Path -LiteralPath $Path -PathType Leaf` inside `Get-PrdFeatureFileExistence` | `"$FeatureFolder/$name"` composed at `L329` from a four-segment repo-relative folder | **process cwd** = Claude session directory |
| `L108` | `Test-Path -LiteralPath $issuePath -PathType Leaf` inside `Get-PrdFeatureIssueContent` | `"$FeatureFolder/issue.md"` composed at `L107` | **process cwd** |
| `L201` | `Test-Path -LiteralPath $CheckpointPath -PathType Leaf` inside `Get-PrdFeatureCheckpointFolder` | default parameter `'artifacts/orchestration/orchestrator-state.json'` (`L198`) | **process cwd** |

`Get-Content` at `L113` and `L206` inherits the same relative resolution.

### A.5 Work-mode branch and required-file probe

- `L388`: `Get-PrdFeatureIssueContent -FeatureFolder $folderNormalized`.
- `L389`: `Resolve-PrdFeatureWorkMode -IssueContent $issueContent`.
- `L398-410`: falsy mode -> deny (R3), **without any required-file probe**.
- `L415`: `$required = @(Get-PrdFeatureRequiredFile -WorkMode $workMode)` (array-wrapped so a
  zero-element return does not unravel to `$null` — see the comment at `L412-414`).
- `L417`: `Get-PrdFeatureMissingFile -FeatureFolder $folderNormalized -RequiredFile $required`.
- `L418-420`: empty missing set -> allow.
- `L425-436`: otherwise deny (R4).

### A.6 Complete set of deny reason strings, verbatim

Four decision-path reasons are constructed in this file. Each is reproduced with its concatenation
structure preserved so the plan can prove a given path is unchanged.

**R1 — envelope anomaly (`L354-357`):**

```
'PRD_FEATURE_BLOCKED: payload anomaly - ' +
(Get-ClaudeHookPayloadAnomalyReason -Anomaly $envelope.Anomaly) +
'. The gate fails closed on an envelope it cannot read.'
```

The interpolated clause comes from `HookPayload.psm1:58-64` and is one of exactly five strings:

- `the hook received an empty payload on stdin and on both environment-variable fallbacks`
- `the hook received a payload that is not parseable JSON`
- `the hook received a JSON payload with no tool_input key (the legacy flat root shape is an envelope anomaly, not a supported payload)`
- `the hook received a JSON payload whose tool_input is null`
- `the hook received a JSON payload whose tool_input is not an object`

plus two defensive fallbacks in the same function: `the hook received an unclassified payload anomaly`
(`HookPayload.psm1:105`) and `the hook received an unrecognized payload anomaly ({0})`
(`HookPayload.psm1:110`).

**R2 — no feature folder resolvable (`L377`):**

```
PRD_FEATURE_BLOCKED: atomic-planner delegation must reference a feature folder (either in the prompt or via orchestrator-state.json) so spec.md and user-story.md prerequisites can be verified.
```

**R3 — indeterminate work-mode marker (`L403-407`):**

```
"PRD_FEATURE_BLOCKED: resolved feature folder '$folderNormalized', " +
"but its work mode could not be determined from '$folderNormalized/issue.md' " +
'(the ''- Work Mode:'' marker is absent, unreadable, or unrecognized). ' +
'Confirm that is the intended feature folder, then add or correct the ' +
'''- Work Mode:'' marker in that file so the prerequisite set can be derived.'
```

**R4 — required document genuinely missing (`L426-428`) — this is "the existing reason" the epic's
must-not-regress constraint pins:**

```
"PRD_FEATURE_BLOCKED: resolved feature folder '$folderNormalized' is missing: " +
"$list (work mode: $workMode). Confirm that is the intended feature folder, then " +
'invoke the prd-feature subagent to produce the missing output(s).'
```

where `$list = ($missing -join ', ')` (`L425`).

The single allow shape is emitted at `L363` (out-of-scope subagent) and `L419` (prerequisites
satisfied): `[ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'allow' } }`
with **no** `permissionDecisionReason` member.

### A.7 Reconciling the verified decision matrix with the code

**Row 1 (own folder named, cwd = session root -> DENY) is fully explained.** With the item's feature
folder present at the session root (its `issue.md` is committed at promotion time) but its `spec.md` /
`user-story.md` produced only inside the child worktree and not yet merged, `L108` finds `issue.md`,
the mode resolves, and `L330` finds the required documents absent **at the session root**. The hook
emits **R4** — precisely the "existing missing-required-document reason" `issue.md` reports, and
precisely why the denial is misleading: the probe answered truthfully about the wrong root.

**Row 2 (identical envelope, cwd = item worktree -> ALLOW) is fully explained** by the same three
relative probes resolving under the item worktree, where the documents exist.

**Row 3 (absolute path to the same folder -> DENY under either cwd) is NOT explained by a static
reading of the current code, and I could not verify it in this tree.** Under `L252`/`L272`/`L277`
an absolute token reduces to exactly the same four-segment relative candidate as the relative token,
so rows 2 and 3 should coincide when cwd is the item worktree. Two hypotheses, neither verified:

- **H1 (most likely).** The absolute-form prompt also contained a second, distinct
  `docs/features/active/...` citation. With two distinct candidates, `L296` consults the
  **session-root** checkpoint; that checkpoint belongs to the coordinating session and names a
  different feature, so it is not among the candidates and `L307` selects the earliest-occurring
  candidate instead. If the absolute path occurred later in the prompt than a cross-reference, the
  wrong folder is selected and the gate denies regardless of cwd. This is exactly the silent
  session-root-checkpoint fallback the epic forbids.
- **H2.** The absolute token carried a character from the excluded class ``[\s"'` ]`` that truncated
  the match, or the two sub-cases of row 3 were both exercised from the session root.

**Action for the plan:** attempt to reproduce row 3 as an `[expect-fail]` Pester case **before**
changing any resolution code. If it cannot be reproduced, restate the corresponding acceptance
criterion positively ("an absolute path to the target folder resolves to the containing worktree and
is allowed when the required document is present there") rather than as a regression from a denial
that cannot be demonstrated. Do not assert a "currently denies" claim that the suite cannot show.

---

## B. Work-mode marker semantics

### B.1 As implemented in the hook

- Read: `Get-PrdFeatureIssueContent` (`L94-118`) probes `"$FeatureFolder/issue.md"` as a leaf
  (`L108`), reads it raw (`L113`), and returns `$null` on a non-leaf path or any `Get-Content`
  exception (`L109`, `L115-117`).
- Parse: `Resolve-PrdFeatureWorkMode` (`L120-153`). Blank input -> `$null` (`L139-141`). The regex at
  `L143` is:
  `(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$`.
  Case-insensitive, multiline, whole-line anchored, leading `- ` required.
- Legacy normalisation: `L148-151` — a captured `full` returns `'full-feature'`; every other captured
  value is returned unchanged.
- Requirement mapping: `Get-PrdFeatureRequiredFile` (`L155-187`), `switch` at `L181-186`:
  `full-feature` -> `@('spec.md','user-story.md')`; `full-bug` -> `@('spec.md')`;
  `minor-audit` -> `@()`; `default` -> `@('spec.md')`.

### B.2 Correction to the delegation brief

The brief states "fail-closed-to-`full-feature` behaviour on a missing/malformed marker". **That is
not what the hook does, and reproducing it would be a regression.** Two distinct facts:

1. On a missing or malformed marker the hook takes its **own decision path** at `L398-410` and denies
   with R3. It runs **no** required-file probe (asserted today by
   `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1:360-371`, which pins
   `Should -Invoke Get-PrdFeatureFileExistence -Times 0 -Exactly`). It does not normalise to
   `full-feature` and it does not name any prerequisite document.
2. The `default` arm of `Get-PrdFeatureRequiredFile` returns **`spec.md` alone**, *not* the
   full-feature pair. The arm is unreachable from the decision path and exists solely so a direct
   caller passing `$null` cannot receive a permissive empty set (`L165-170`). It must never name
   `user-story.md`, because that document is required to be *absent* for `full-bug` and `minor-audit`.
   Pinned by `enforce-prd-feature-before-planner.Tests.ps1:267-273`.

The only "fail closed to `full-feature`" rule in the repository is in the **producer** direction:
`.claude/skills/feature-promotion-lifecycle/SKILL.md:120` requires promotion tooling that rejects a
requested `minor-audit` on eligibility grounds to persist `- Work Mode: full-feature`. That is not a
gate behaviour and F4 must not import it into the hook.

### B.3 Where the hook and the skill disagree today

| topic | SKILL.md | hook | assessment |
| --- | --- | --- | --- |
| marker placement | `:114` — "exactly one marker in `issue.md` metadata **above the first `##` heading**" | regex at `L143` matches anywhere in the file, any number of times (first match wins) | **Divergence.** The hook is strictly more permissive on position and on multiplicity. Pre-existing; out of F4's scope; record it, do not change it. |
| legacy `full` | `:52`, `:119` — accepted only as an alias for `full-feature` | `L148-151` normalises identically | Agree. |
| `full-feature` set | `:110` — `spec.md` and `user-story.md` expected | `L182` | Agree. |
| `full-bug` set | `:111` — `spec.md` expected; `user-story.md` should be absent | `L183` | Agree. |
| `minor-audit` set | `:107`, `:109` — `spec.md`/`user-story.md` intentionally absent and an integrity failure if present | `L184` returns the empty set (does not *forbid* their presence) | Agree on the gate's obligation. The hook does not police unexpected presence; that is the lifecycle verification step at `SKILL.md:66-72`, not this gate. |
| missing/malformed marker | not addressed | `L398-410` deny on a distinct path | No conflict; the hook's behaviour is derived and documented in `L51-60`. |

**Preservation requirement for F4:** every row above must read identically after the change. The
regex at `L143`, the switch at `L181-186`, and the indeterminate branch at `L398-410` should be
touched only if the target-root change forces it, and their assertions in the existing suites must
continue to pass unmodified.

---

## C. F1 upstream contract (semantics only — identifiers are not yet bound)

F1 (`target-worktree-resolution-module`, wave 0) is **not present in this tree**. `.claude/lib/`
holds 33 `.psm1` files across 11 module folders plus 11 `.sh` files under `.claude/lib/bash/`, and
none of them resolves a worktree: a content search for `git worktree`, `worktrees`, `Get-Location`,
`$PWD`, and `Resolve-Path` across `.claude/lib` returns only three hits, all in
`CleanupWorktreeManifest.psm1` (`:7`, `:40`, `:62`) and all naming a manifest path or a tool string.
Confirmed.

**The concrete module name, function names, and reason-code spelling bind at execution time, when F1
has merged into the integration branch ahead of F4. No identifier is invented or asserted below.**
F4's plan must resolve them from F1's merged source and must not hard-code a guess.

### C.1 Module layout and shape convention

- **No `.psd1` manifests exist anywhere under `.claude/lib/`** (glob returns nothing). Modules are
  bare `.psm1` files imported by path.
- Layout is `.claude/lib/<kebab-case-folder>/<PascalCaseName>.psm1`. A folder may hold several
  cohesive modules (`orchestrator-state` holds 11; `blast-radius` holds 8).
- The mandatory module shape is enforced by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`,
  which discovers modules from disk (`:30-33`) so a new module cannot escape it. Required:
  1. `Set-StrictMode -Version Latest` immediately followed by `$ErrorActionPreference = 'Stop'`
     (`:53-67`).
  2. Every **column-0** `Import-Module` carries an explicit `-ErrorAction Stop` (`:69-86`).
  3. The leading comment-based-help block contains the literal sentence fragment
     `imports its siblings with -ErrorAction Stop` (`:88-107`).
  4. Importing the module leaves the caller's `$ErrorActionPreference` unchanged (`:109-121`).
  5. The module is at most 500 lines (`:123-136`).
- Reference exemplars: `HookPayload.psm1:43-44` and `:40`; `CleanupWorktreeManifest.psm1:32`, `:35-36`.
- Exports are declared by an explicit `Export-ModuleMember -Function` list at the file tail
  (`HookPayload.psm1:486-496`). Function names use approved PowerShell verbs; the prefix convention is
  a module-specific noun stem (`ClaudeHook*`, `CleanupWorktree*`, `Orchestration*`,
  `ParallelDriftGate*`).

### C.2 How hooks import `.claude/lib/` modules today — two verbatim call sites

```
.claude/hooks/enforce-pr-author-skill.ps1:51
Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force
```

```
.claude/hooks/enforce-epic-worktree-removal-gate.ps1:65
Import-Module (Join-Path $PSScriptRoot '../lib/cleanup-manifest/CleanupWorktreeManifest.psm1') -Force
```

The same form already appears in F4's own file at `L78` for `HookPayload.psm1`. Twenty hook files use
this exact `Import-Module (Join-Path $PSScriptRoot '../lib/<folder>/<Name>.psm1') -Force` shape.
**F4's hook adopts this mechanism verbatim**, adding one line beside `L78`.

A guarded lazy-import variant exists (`enforce-mermaid-validation.ps1:64,83`;
`enforce-discovery-artifact-gate.ps1:66-72`) that resolves the path into a `$script:` variable and
imports with `-ErrorAction Stop` inside a `try`. It is used where a missing module must degrade rather
than throw. **Not recommended for F4**: this gate must fail closed, and an unresolvable resolution
module is exactly the "target not resolvable" state that must deny loudly.

Note that `$PSScriptRoot` here is the *hook's own* directory — i.e. `<session-root>/.claude/hooks` —
so it identifies the **session** root, not the call's target worktree. It is the right anchor for
locating the module and the wrong anchor for locating the target. `enforce-powershell-batch-budget.ps1:210`
(`$Root = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)`) is the existing precedent for
deriving a repo root from the script location rather than from cwd, and its comment at `:217-219`
already articulates the cross-worktree hazard.

### C.3 `core.json` pack-manifest registration and `*.Manifest.Tests.ps1`

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` carries a `paths`
  array. `.claude/hooks/enforce-prd-feature-before-planner.ps1` is already listed at `core.json:47`.
- The `*.Manifest.Tests.ps1` convention (five instances:
  `tests/scripts/claude-lib/{model-routing,blast-radius,orchestrator-state,project-file-merge,discovery-validation,codex-routing}/*.Manifest.Tests.ps1`)
  asserts two things per module: the path is **contained** in `paths`, and it occurs **exactly once**
  (`ModelRouting.Manifest.Tests.ps1:23-38`). It is a file-read-only assertion that creates no
  temporary file and starts no process (`:9-11`).
- **F1 owns the `.claude/lib/` module registration and its matching `*.Manifest.Tests.ps1`.**
- **F4 nevertheless has its own manifest obligation, and it is not optional.**
  `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` walks the *bundled*
  `.claude/hooks/` directory (`:86-91`) and asserts every enumerated file is present in the union of
  all `pack-manifests/*.json` `paths` arrays, with a frozen three-entry exception set (`:52-58`).
  A new dot-sourced helpers sibling created by F4's extraction is a new file under `.claude/hooks/`,
  so it must be added to `core.json` (beside the existing `-helpers` / `-modes` entries at
  `core.json:36,37,40,42,46`) or this Python test fails.

### C.4 `HookPayload.psm1` — what it exposes and what F4 needs

Exported (`:486-496`): `Read-ClaudeHookRawPayload`, `ConvertFrom-ClaudeHookEnvelope`,
`Get-ClaudeHookToolInput`, `Resolve-ClaudeHookToolInput`, `Get-ClaudeHookEnvelopeValue`,
`Test-ClaudeHookEnvelopeHasKey`, `Test-ClaudeHookObjectValue`, `Get-ClaudeHookToolInputString`,
`Get-ClaudeHookPayloadAnomalyCode`, `Get-ClaudeHookPayloadAnomalyReason`.

Parts F4 needs:

| need | member | status |
| --- | --- | --- |
| raw transport | `Read-ClaudeHookRawPayload` | already used at `L444` |
| envelope + nested `tool_input` in one call | `Resolve-ClaudeHookToolInput` | already used at `L348` |
| `subagent_type`, `prompt` | `Get-ClaudeHookToolInputString` | already used at `L361`, `L366` |
| **the envelope root object** (to reach any root-level field such as `cwd`) | `.Envelope` member on the `Resolve-ClaudeHookToolInput` result (`:481`) | **available but not currently read by this hook.** Precedent for reading it: `enforce-epic-invocation-origin.ps1:224`. |
| **StrictMode-safe read of a root-level key** | `Get-ClaudeHookEnvelopeValue` (`:306-330`) and `Test-ClaudeHookEnvelopeHasKey` (`:276-304`) | exported; usable without modifying the module |
| anomaly -> deny clause | `Get-ClaudeHookPayloadAnomalyReason` | already used at `L355` |

**No change to `HookPayload.psm1` is required by F4.** The envelope root is already surfaced.
**Unverified and load-bearing:** whether the live PreToolUse envelope actually carries a `cwd` field
in this runtime. No hook in this repository reads `cwd` today (content search over `.claude/hooks`
returns only `session_id` references in the batch-budget hooks and `persist-session-id.ps1:57-58`).
If F1's target derivation depends on an envelope `cwd`, F4 must capture a real payload as evidence
before relying on it, and must keep a deny path for the case where the field is absent.

---

## D. Helpers extraction

### D.1 Precedent in this repository

Three self-hosted trios/pairs establish the pattern:

| parent | sibling(s) | mechanism |
| --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.ps1` (496) | `-helpers.ps1` (349), `-modes.ps1` (480) | dot-sourced at `:14` and `:20` |
| `enforce-pr-author-skill.ps1` (312) | `-helpers.ps1` (260), `.epic-base-branch.ps1` | dot-sourced at `:148` and `:144` |
| `enforce-parallel-cohort-barrier.ps1` (283) | `-helpers.ps1` (278) | dot-sourced at `:58` |
| `enforce-parallel-drift-gate.ps1` | `-helpers.ps1` | path into `$script:` var at `:68`, dot-sourced `:69` |
| `enforce-completion-consistency.ps1` | `enforce-completion-helpers.ps1` | path into `$script:` var at `:48`, dot-sourced `:49` |

Codex mirrors the preimplementation trio only (`.codex/hooks/enforce-orchestration-preimplementation-gate{,-helpers,-modes}.ps1`).
**F4 has no Codex obligation** (see F below).

**Naming.** `<parent-stem>-helpers.ps1`, same directory. Sibling files carry a comment-based-help
block, **no `param()` block, no `#Requires`, and no entrypoint**; see
`enforce-orchestration-preimplementation-gate-helpers.ps1:1-18`, whose `:16-17` explicitly states
"dot-sourced by the sibling gate hook, following the headroom-split precedent set by
enforce-pr-author-skill.ps1".

**Import mechanism.** `. (Join-Path $PSScriptRoot '<sibling>.ps1')`, at file scope, immediately after
the `Import-Module` lines and before any function definition.

**Testing.** Two patterns coexist:
- transitive — the suite dot-sources only the parent and exercises sibling functions through it
  (`enforce-parallel-cohort-barrier.Tests.ps1:20-21`);
- explicit — the suite dot-sources the parent *and* the sibling so a future change to the parent's
  dot-source line cannot silently redirect the assertions
  (`enforce-orchestration-preimplementation-gate-classifier.Tests.ps1:34-42`, with the rationale at
  `:37-40`). **Prefer the explicit pattern for F4.**

**Registration obligations for a new sibling `.ps1` under `.claude/hooks/`:**
1. bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<name>.ps1`
   (text-identical — see F);
2. `core.json` `paths` entry (see C.3);
3. `CodeCoverage.Path` allow-list entry in **both** copies of `pester.runsettings.psd1`
   (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
   `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`), whose
   parity is asserted by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16`. Precedent
   entries with their rationale comments: `pester.runsettings.psd1:226-233`.

### D.2 Measured line regions of `enforce-prd-feature-before-planner.ps1`

| region | lines | count |
| --- | --- | --- |
| comment-based help | 1-73 | 73 |
| `[CmdletBinding()]`, `param()`, blanks, `Import-Module` | 74-78 | 5 |
| `Get-PrdFeatureFileExistence` | 79-92 | 14 |
| `Get-PrdFeatureIssueContent` | 94-118 | 25 |
| `Resolve-PrdFeatureWorkMode` | 120-153 | 34 |
| `Get-PrdFeatureRequiredFile` | 155-187 | 33 |
| `Get-PrdFeatureCheckpointFolder` | 189-217 | 29 |
| `Find-PrdFeatureFolderFromPrompt` | 219-308 | 90 |
| `Get-PrdFeatureMissingFile` | 310-335 | 26 |
| `Invoke-PrdFeatureBeforePlannerDecision` | 337-437 | 101 |
| entrypoint guard + invocation + exit | 439-448 | 10 |
| inter-function blank lines | 93, 119, 154, 188, 218, 309, 336, 438 | 8 |
| **total** | | **448** |

### D.3 Recommended split

**New file:** `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`.

**Moves (pure string/collection logic, no `Test-Path`, no `Get-Content`):**

| function | lines moved |
| --- | --- |
| `Resolve-PrdFeatureWorkMode` | 34 |
| `Get-PrdFeatureRequiredFile` | 33 |
| `Find-PrdFeatureFolderFromPrompt` | 90 |
| `Get-PrdFeatureMissingFile` | 26 |
| separating blanks | 3 |
| **subtotal moved** | **186** |

**Stays in the parent:** the three filesystem seams (`Get-PrdFeatureFileExistence` 14,
`Get-PrdFeatureIssueContent` 25, `Get-PrdFeatureCheckpointFolder` 29 = 68 lines), the decision
function, the help block, and the entrypoint. Keeping all three `Mock`-ed seams in the file the
existing suites dot-source minimises the change in mock-resolution surface.

**Projected sizes:**

- parent: 448 − 186 = 262, plus one dot-source line and a 3-line rationale comment ≈ **266 lines**;
  **234 lines of headroom** for the F1 import, the retargeted probe composition, the new ambiguity
  deny branch, and an expanded help block.
- helpers: 186 plus a ~24-line comment-based-help header and a trailing blank ≈ **211 lines**;
  **289 lines of headroom**.

Both are comfortably under 500 with room for the F4 change itself. If the parent still needs more
room after the F1 integration, the next functions to move are `Get-PrdFeatureIssueContent` (25) and
`Get-PrdFeatureFileExistence` (14) — but see the risk below before doing so.

**Risk to verify, not to assume.** After the split, `Invoke-PrdFeatureBeforePlannerDecision` (parent)
calls `Find-PrdFeatureFolderFromPrompt` and `Get-PrdFeatureMissingFile` (helpers), and
`Find-PrdFeatureFolderFromPrompt` (helpers) calls `Get-PrdFeatureCheckpointFolder` (parent, mocked by
15 existing test cases), while `Get-PrdFeatureMissingFile` (helpers) calls
`Get-PrdFeatureFileExistence` (parent, mocked by ~25 cases). PowerShell resolves function names
dynamically through the session-state function table at call time, and dot-sourcing both files into
the test's scope places both in that table, so a Pester 5 `Mock` should be observed by callers in
either file. **This is expected behaviour, not verified in this repository:** no current test mocks a
function that is called from a different dot-sourced file (the preimplementation trio's suites use
injection parameters and register no `Mock` at all —
`enforce-orchestration-preimplementation-gate-classifier.Tests.ps1:25-29`). The plan must include one
cheap smoke case — dot-source both files, `Mock Get-PrdFeatureCheckpointFolder`, assert
`Should -Invoke ... -Times 0 -Exactly` on the single-candidate path — run *before* the rest of the
extraction is committed. The existing `FolderResolution.Tests.ps1:64-79` case is already exactly this
assertion and will fail loudly if the assumption is wrong.

---

## E. Existing test surface, and how to vary cwd without temporary files

### E.1 Files

| path | lines | headroom |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 431 | 69 |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 419 | 81 |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (one `It`, `:140-151`) | — | — |

A repository-wide search for `PrdFeature` / `prd-feature-before-planner` under `tests/` returns
exactly these three plus two unrelated files (`validate-prd-feature-output.Tests.ps1` and
`claude-settings.Tests.ps1`, both concerning the *SubagentStop* validator
`validate-prd-feature-output.ps1`, not this gate).

### E.2 Case inventory

`enforce-prd-feature-before-planner.Tests.ps1` — 8 `Context` blocks:

- *tool input parsing* (`:10-45`) — 5 cases: empty payload, non-`atomic-planner`, missing
  `subagent_type`, legacy flat root, unparseable JSON.
- *atomic-planner delegation* (`:47-165`) — 8 cases: allow with both documents, block on missing
  `spec.md`, block on missing `user-story.md`, block with no folder and no checkpoint, checkpoint
  fallback, prompt-over-checkpoint preference, `.md`-to-parent, backslash separators.
- *Entrypoint transport* (`:167-195`) — 4 cases, including two that call the **real** wrappers
  against synthetic non-existent absolute paths (`:188-194`).
- *Find-PrdFeatureFolderFromPrompt* (`:197-210`) — 4 pure cases.
- *Resolve-PrdFeatureWorkMode* (`:212-248`) — 9 cases including legacy `full` and case-insensitivity.
- *Get-PrdFeatureRequiredFile* (`:250-274`) — 5 cases including the two `default`-arm pins.
- *Get-PrdFeatureIssueContent* (`:276-286`) — 2 cases.
- *work-mode aware prerequisite resolution* (`:288-365`) — 6 cases across all three modes + legacy.
- *fail-closed prerequisite resolution* (`:367-430`) — 4 indeterminate-mode cases.

`enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` — 6 `Context` blocks:

- *four-segment truncation* (`:25-80`) — 6 cases including the degenerate `docs/features/active/.`
  rejection and the zero-checkpoint-invocation dedupe proof.
- *deterministic selection among two folders* (`:82-112`) — 3 cases; the checkpoint-preferred folder
  deliberately occurs **later** in the prompt (`:89-95`) so checkpoint preference cannot agree with
  earliest-occurrence by coincidence.
- *decision equivalence and the reproduction differential* (`:114-201`) — 3 cases.
- *preserved gate behavior* (`:203-282`) — 5 negative/regression cases. **This is the block F4's
  must-not-regress constraint lives in.** Its header comment (`:204-206`) already states the exact
  hazard F4 re-introduces.
- *indeterminate work-mode marker* (`:284-372`) — 6 cases, including the zero-probe assertion.
- *block message* (`:374-418`) — 2 cases: folder-before-remedy ordinal ordering, and the
  `PRD_FEATURE_BLOCKED:` prefix across five payload shapes.

### E.3 Fixture and mocking strategy

Both suites use one uniform strategy:

1. `BeforeAll`: `$script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path` then `. $script:UnderTest`
   (`Tests.ps1:6-7`, `FolderResolution.Tests.ps1:21-22`). The dot-source guard at hook `L440-442`
   suppresses the entrypoint.
2. The PreToolUse payload is an **in-line hashtable piped through `ConvertTo-Json -Compress -Depth 5`**
   — e.g. `Tests.ps1:57-60`. No fixture file exists on disk.
3. Filesystem state is supplied entirely by three `Mock`s: `Get-PrdFeatureIssueContent` (returns
   marker text), `Get-PrdFeatureFileExistence` (returns a bool, often keyed on `$Path`), and
   `Get-PrdFeatureCheckpointFolder` (returns a folder string or `$null`).
4. Probed paths are captured by accumulating into a `$script:` array inside the existence mock
   (`Tests.ps1:120-125`), which is how folder-resolution is asserted without touching disk.
5. **cwd is never varied, and no test sets or reads the current directory.** Content search for
   `worktree` across `tests/scripts/claude-hooks/` shows **1 hit** in
   `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` (a comment) and **0 hits**
   in either prd-feature suite. **No existing test constructs a second worktree, and no existing test
   constructs a sibling checkpoint** other than as a mocked return string.

### E.4 The hard constraint, and the compliant answer

`.claude/rules/general-unit-test.md` states: "**Creation and use of temporary files in tests is
strictly prohibited.**" `.claude/rules/powershell.md:69-76` additionally forbids "implicit
working-directory assumptions" and requires identical results in Terminal and Test Explorer.

**The established pattern in this repository does NOT use temp dirs. It uses synthetic literal path
prefixes plus injection.** The canonical exemplar is
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`,
whose header states the rule outright (`:25-31`):

> Each prefix below is a bare string literal. No absolute path in this suite is derived from the
> runtime environment, the current directory, the script file location, or a source-control query.

It declares three synthetic roots as plain strings (`:32-34`):

```
$WindowsForwardPrefix   = 'C:/synthetic-drive-root/synthetic-checkout'
$PosixAbsolutePrefix    = '/synthetic-posix-root/synthetic-checkout'
$WindowsBackslashPrefix = 'C:\synthetic-drive-root\synthetic-checkout'
```

and builds its case table as a cross product of literal × spelling (`:57-91`), bound with Pester's
`-ForEach` (`:180`, `:188`, `:196`, `:207`, `:215`). Disk state never enters: the decision function
takes an **injection parameter** (`-CheckpointRaw`, hook `:346`) so the on-disk checkpoint is bypassed
(rationale at `:14-18` of the test file — without it the assertion would pass vacuously against the
real, ready checkpoint).

**Concretely, for F4's cwd dimension:** do *not* change the process working directory, and do *not*
create directories. Model cwd as **data**, exactly as the absolute-paths suite models the checkout
root as data:

1. **Two synthetic roots as bare literals**, e.g. `'C:/synthetic-root/session'` (coordinating session)
   and `'C:/synthetic-root/worktrees/item-839'` (the item's worktree). Both are strings; neither is
   derived from `$PWD`, `$PSScriptRoot`, or `git`.
2. **Inject the resolved target** through a new parameter on
   `Invoke-PrdFeatureBeforePlannerDecision` — the `-CheckpointRaw` / `-EpicCheckpointRaw` /
   `-ParallelCheckpointRaw` precedent at hook `:341-361`, including its `ContainsKey`-based binding
   discipline (`:348-353`) so an explicitly supplied empty string suppresses the seam rather than
   falling through to disk. This is the **preferred** seam under `.claude/rules/powershell.md:43-52`
   ("introduce the smallest seam"), and it is what lets a table-driven case say "cwd = session root"
   or "cwd = item worktree" as a value.
3. **Keep the existence probe mocked and key it on the full composed path**, following
   `FolderResolution.Tests.ps1:122-125` (`return $Path -eq 'docs/features/active/<slug>/spec.md'`).
   After the fix the composed path carries the target root, so a row whose target root is the item
   worktree and whose mock only answers `$true` for the item-worktree spelling **fails** if the hook
   still probes the session root. That single change turns the existing mock idiom into the
   discriminator for the whole cwd dimension, with no filesystem at all.
4. **Bind the matrix with `-ForEach`** over a discovery-time array of hashtables
   (`{ Cwd; PathForm; Target; Expected; ExpectedReason }`), per `absolute-paths.Tests.ps1:180`. Note
   the discovery/run phase caveat recorded at `:93-96` of that file: a value assigned inside an `It`
   body is not visible from discovery, so case data must be `-ForEach`-bound.

**Placement.** Both existing suites have under 82 lines of headroom against the 500-line cap. The
epic's required matrix (cwd × path form × target, with regression rows retained) will not fit in
either. Create a **third companion suite**, e.g.
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, and
document the placement decision in its header — the convention is already established twice
(`FolderResolution.Tests.ps1:4-17`, `absolute-paths.Tests.ps1:20-22`).

---

## F. Bundled-payload mirroring

- **Parity requirement: confirmed, and it is machine-enforced.**
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  (`:118-141`) enumerates every file under the repo's `.claude/**` (`SCOPED_ROOTS = (Path(".claude"),)`,
  `:25`), excludes only `.claude/settings.local.json` and `.claude/agent-memory/**` (`:130-134`), and
  asserts for each remaining file both membership in the bundle and **UTF-8 text equality**
  (`:137-141`, via `read_text`, `:63-66`). **A one-sided edit fails CI.**
- **Current state: consistent with byte identity.** Both copies are **448 lines**, and a positional
  spot-check of five distinctive anchors matches exactly on the same line numbers:
  `Import-Module ... HookPayload.psm1` at 78, `function Get-PrdFeatureCheckpointFolder` at 189,
  `function Find-PrdFeatureFolderFromPrompt` at 219, `$segments[0..3]` at 277, `exit 0` at 448. I did
  not run a byte-level `diff` in this session; the orchestrator's byte-identity verification is
  recorded upstream and this evidence is consistent with it.
- **Second parity surface, easily missed:** `tests/scripts/dev_tools/test_poshqc_bundled_parity.py:16`
  pins `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` against
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. A
  `CodeCoverage.Path` entry for the new helpers sibling must be added to **both**.
- **Codex mirror: none.** All 30 files under `.codex/hooks/` were enumerated; there is no
  `enforce-prd-feature-before-planner.ps1` and no differently named analogue of it. `.codex/hooks/`
  does mirror `enforce-orchestration-preimplementation-gate{,-helpers,-modes}.ps1` and
  `enforce-epic-merge-gate.ps1`, which belong to F2 and F3. **F4 has zero Codex parity obligation.**
  Confirmed, not assumed.

**F4's complete write set (production):** 2 `.claude/**` files (hook + new helpers sibling), their
2 bundled mirrors, `core.json`, and 2 `pester.runsettings.psd1` copies. Note that
`.claude/rules/powershell.md:37-40` caps direct mode at 2 production PowerShell files and any batch
at 3 production files; the hook plus its helpers sibling plus their two mirrors is **4 production
PowerShell files**, which exceeds both caps. **The plan must either route through
`powershell-orchestrator` per `powershell-change-budget-router`, or obtain an explicit override, or
split the extraction and the behaviour change into two batches.** Issue #518's spec (`:232`)
explicitly used the 2-file scope to stay inside direct mode; F4 cannot, because the extraction is
mandatory rather than optional.

---

## G. Prior art — issue #518

`docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/`
is a completed `full-bug` fix to this same hook. Its `spec.md` is the authoritative record.

### G.1 What it changed

1. Replaced **longest-match** folder resolution (`Sort-Object -Property Length -Descending`) with the
   four-segment truncation now at `L272-277`, and deleted the `.md`-implies-parent branch
   (`spec.md:109`).
2. Replaced the deduplication `[hashtable]` with an order-preserving collection, because hashtable key
   enumeration order is unspecified and a first-occurrence rule fed by one is non-deterministic
   (`spec.md:156`; realised at hook `L258-261`).
3. Added the **deterministic multi-candidate selection rule**: one candidate used directly; otherwise
   prefer the checkpoint's `feature-folder`; otherwise earliest occurrence (`spec.md:158-161`; hook
   `L287-307`).
4. Made an **indeterminate work mode its own decision path** that runs no required-file probe
   (`spec.md:110`, `:169-181`; hook `L391-410`), because no prerequisite set is knowable when the mode
   is unknown and the empty set fails open.
5. Changed the `default` arm of `Get-PrdFeatureRequiredFile` from `{spec.md, user-story.md}` to
   `{spec.md}` (`spec.md:144`; hook `L185`).
6. Re-led the missing-prerequisite message with the **resolved folder** rather than the remedy
   (`spec.md:111`, `:187`; hook `L422-428`).
7. Created `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` as a companion suite,
   because the original suite had insufficient headroom (`spec.md:263`).

### G.2 Constraints F4 must not regress

Taken verbatim from `spec.md:113-122` and its acceptance criteria, all of which are currently pinned
by passing tests:

- **The gate stays fail-closed on every path.** The empty prerequisite set is never a fail-closed
  default (`spec.md:115`). Locked by `Tests.ps1:367-430`.
- **The gate keeps denying when `prd-feature` genuinely has not run** (`spec.md:116`). Locked by
  `FolderResolution.Tests.ps1:203-282`.
- **Four prompt forms must produce the identical decision and identical reason string** (folder alone;
  folder + `research/` artifact; folder + `evidence/` artifact; nested artifact alone) —
  `FolderResolution.Tests.ps1:119-149`. **F4's target resolution must preserve this equivalence and
  should extend it to a fifth and sixth form: repo-relative-from-a-different-root and absolute.**
- **The selection rule must remain distinguishable from earliest-occurrence**, proven by a case where
  the checkpoint-preferred folder occurs *later* in the prompt (`FolderResolution.Tests.ps1:89-95`).
  If F4 changes the disambiguator from "session-root checkpoint" to "target-derived", this case must
  be **re-specified, not deleted** — deleting it would remove the only proof the rule is deliberate.
- **`Find-PrdFeatureFolderFromPrompt` performs no I/O except through the pre-existing checkpoint
  seam** (`spec.md:117`). The same paragraph explicitly **rejects the filesystem-walk alternative**
  because it "depends on the process working directory, which `.claude/rules/powershell.md:69-76`
  prohibits tests from relying on". **F4 must respect this:** the target root must arrive as data
  (from F1's derivation over the payload) and must not be discovered by walking up from cwd.
- **The three mock seam names and signatures are preserved** (`spec.md:119`) so existing tests keep
  mocking them. F4 must not rename `Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`, or
  `Get-PrdFeatureCheckpointFolder`.
- **The dot-source guard is unchanged** (`spec.md:120`; hook `L440-442`).
- **The PreToolUse deny payload shape is unchanged**, so `PreToolUseSchema.Contract.Tests.ps1` passes
  unedited (`spec.md:121`).
- **Every deny reason retains the `PRD_FEATURE_BLOCKED:` prefix** (`FolderResolution.Tests.ps1:397-417`).
  **F1's ambiguity reason code must therefore be embedded inside a `PRD_FEATURE_BLOCKED:`-prefixed
  string, not substituted for it.**
- The known **version-folder limitation** (`spec.md:78`) and the **trailing-prose-punctuation**
  limitation (`spec.md:79`) are recorded as unchanged. F4 inherits both; do not silently alter either.

### G.3 Are #518's tests the ones F4 extends?

**Partly.** F4 will:

- **Extend** `FolderResolution.Tests.ps1`'s *preserved gate behavior* block conceptually — but it has
  only 81 lines of headroom, so the new regression rows go in the new companion suite and the existing
  block is left byte-untouched as the proof the behaviour did not move.
- **Re-specify** the *deterministic selection* block if the disambiguator changes (see above).
- **Leave untouched** the truncation block (`:25-80`) only if truncation survives. Fix 2 of the epic
  says "segment-count truncation is prohibited" for *path normalisation*. Note the distinction
  carefully: #518's truncation solves **depth-insensitivity** (a `research/` citation and a folder
  citation must resolve to the same folder), which the epic does **not** want reverted. What the epic
  prohibits is using truncation as a substitute for **locating the containing worktree**. The correct
  reading is that F1's normalisation replaces the *prefix-discarding* half while the *depth-collapsing*
  half stays. **The plan must state this explicitly**, because a literal reading of "fixed segment-count
  truncation is prohibited" would delete `L272-277` and re-open issue #518.

---

## H. The three-way distinction

### H.1 Where each state is currently conflated

**(i) Target resolved + required document PRESENT -> should ALLOW; currently DENIES.**

Conflated at the probe composition. `Get-PrdFeatureMissingFile` builds `"$FeatureFolder/$name"` at
`L329` from a four-segment repo-relative folder and passes it to `Get-PrdFeatureFileExistence`, whose
`Test-Path -LiteralPath` at `L91` resolves against the process cwd. The gate is not asking "does the
document exist for this target"; it is asking "does a path with this relative spelling exist under
whatever directory this process happens to be in". When those two roots differ, a present document
reads as absent and the gate emits **R4**.

**Fix sites:** `L329` (probe composition) and `L107` (`issue.md` composition). Both must compose
against the F1-resolved target root. `L198` (the checkpoint default path) must also be reconsidered —
see (iii).

**(ii) Target resolved + required document GENUINELY ABSENT -> DENY with the existing reason.**

This is the only state currently reported correctly, and only when cwd happens to coincide with the
target. Its reason (**R4**, `L426-428`) must be preserved character-for-character apart from the
`$folderNormalized` value. `Get-PrdFeatureRequiredFile` (`L155-187`) and the missing-set computation
(`L327-334`) must not change at all.

**(iii) Target NOT RESOLVABLE -> DENY with F1's distinct ambiguity code; currently three separate
silent fallbacks.**

- **Conflation 1 — `L368-370`.** A prompt that names no feature folder falls silently to
  `Get-PrdFeatureCheckpointFolder`, which reads `artifacts/orchestration/orchestrator-state.json`
  **relative to the process cwd** (`L198`, `L201`). In a coordinating session that is the
  orchestrator's own checkpoint, which describes a different item. The gate then validates item A's
  delegation against item B's state and can return **allow**. This is the epic's false-approval mode
  appearing inside F4's own site, not only in 3.2/3.4. It is currently *tested as a feature*
  (`Tests.ps1:107-116`, "falls back to orchestrator-state.json when prompt has no folder reference"),
  so F4's change to it is a deliberate, specified behaviour change that must be called out in the
  plan and reflected in that test.
- **Conflation 2 — `L296-307`.** With two or more candidates, the session-root checkpoint is the
  disambiguator; on a miss, `L307` returns `$candidates[0]` with no signal that the choice was
  arbitrary. An ambiguous target is resolved by a positional heuristic and reported as if it were
  determined.
- **Conflation 3 — `L398-410`.** When the folder does not exist under the probed root at all,
  `Get-PrdFeatureIssueContent` returns `$null` (`L109`), the mode is indeterminate, and the gate
  emits **R3** — a message asserting that the `- Work Mode:` marker is broken. The actual condition is
  "this folder was probed at the wrong root". The remedy R3 prescribes (edit the marker) is wrong and,
  if followed, would edit the wrong repository's `issue.md`.

**Introduction points for the distinction:**

| location | change |
| --- | --- |
| `L348` / new line after `L366` | obtain F1's target-derivation result from the payload (envelope root + `tool_input`); this is the one new input |
| new branch between `L366` and `L367` | explicit "no target" -> deny with `PRD_FEATURE_BLOCKED:` + F1's ambiguity code |
| `L367-370` | remove the unconditional silent checkpoint fallback; the session-root checkpoint may be consulted **only** when F1 reports the call genuinely has no target *and* the session root is the target |
| `L296-307` | the tie-break disambiguator becomes the F1-derived target, not the session-root checkpoint; `L307`'s positional fallback becomes a deny with the ambiguity code |
| `L107`, `L329` | compose probe paths against the resolved target root |
| `L398-410` | reachable only when the folder *does* exist under the resolved target root and its marker is unreadable; otherwise the ambiguity/absence path takes precedence |
| `L418-420`, `L425-436` | unchanged |

### H.2 Highest regression risk — stated explicitly

**A fix that resolves the target correctly but stops checking the document converts a false denial
into a false approval.** The epic ranks false approval as the more serious mode
(`epic.md:62-64`), and this gate is the only thing standing between an unprepared feature folder and a
planning delegation.

Three concrete ways it happens, each with a specific guard:

1. **The probe is made to return `$true` when the target root cannot be composed.** Guard: the
   ambiguity branch must `return` a deny *before* any probe runs, mirroring the indeterminate branch's
   existing discipline; assert it with `Should -Invoke Get-PrdFeatureFileExistence -Times 0 -Exactly`,
   the idiom already at `FolderResolution.Tests.ps1:360-371`.
2. **The negative rows are written against a different target than the positive rows**, so a probe
   that always answers `$true` still passes them. Guard: every matrix row must use the **same**
   resolved-target root, differing only in whether the mock answers `$true` for that exact composed
   path. The keyed-mock idiom at `FolderResolution.Tests.ps1:122-125` already does this and must be
   extended, not replaced with a blanket `{ $true }`.
3. **The allow path stops probing at all** (e.g. an early `return allow` once the target resolves).
   Guard: add a positive-direction invocation count — `Should -Invoke Get-PrdFeatureFileExistence
   -Times 2 -Exactly` on a `full-feature` allow row and `-Times 1 -Exactly` on a `full-bug` allow row.
   No such assertion exists today; it is the missing half of the zero-invocation assertion.

A fourth, subtler risk: **removing the session-root checkpoint fallback could itself turn an allow into
a deny for the single-worktree topology**, violating `epic.md:130` ("Epic and standalone topologies
must behave exactly as now when cwd and target coincide"). Guard: retain
`Tests.ps1:107-116` in an amended form asserting that when the derived target *is* the session root,
the checkpoint fallback still applies and still allows.

---

## I. Recommended approach

**Selected:** consume F1's module as an imported dependency at the hook's existing
`Import-Module (Join-Path $PSScriptRoot '../lib/...') -Force` seam; extract the four pure functions to
a dot-sourced `-helpers.ps1` sibling for headroom; introduce the target root as an **injected value**
threaded into the two probe-composition sites; add one new deny branch carrying F1's ambiguity code
inside the `PRD_FEATURE_BLOCKED:` prefix; leave the work-mode semantics, the required-file mapping, and
reason R4 untouched.

Justification: it is the only option that satisfies all four hard constraints simultaneously — no
Python, no file over 500 lines, no temporary files in tests, and no re-implementation of F1's three
contract parts (explicitly forbidden by `issue.md:81`). It reuses three established repository
mechanisms verbatim (the lib-import form, the helpers-extraction form, and the
injection-parameter test seam), so the review surface is the behaviour change alone.

**Rejected alternatives, briefly:**

- **Resolve the worktree inside the hook by walking up from cwd or shelling to `git worktree list`.**
  Rejected: duplicates F1's contract (forbidden), adds process I/O to a fail-closed gate, and depends
  on the process working directory, which `.claude/rules/powershell.md:69-76` forbids tests from
  relying on — the same rejection #518 already recorded at its `spec.md:117`.
- **Change prompt construction so children always emit absolute paths.** Rejected — this is the
  epic's recorded anti-pattern (`epic.md:116`, `issue.md:68`). Every child prompt in the originating
  run already named its own feature folder.
- **Skip the extraction and add the logic in place.** Rejected: 448 + the new import, branch, and
  help text exceeds the 500-line cap; the epic already classifies the extraction as mandatory
  (`epic.md:217`).
- **Put the new matrix in the existing suites.** Rejected: 69 and 81 lines of headroom respectively
  against a matrix of at least 12 rows plus regression guards.

---

## J. Test strategy implications (no test code written)

1. **New companion suite** `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`,
   with a header documenting the placement decision per the established convention.
2. **Table-driven `-ForEach`** over the cross product: cwd ∈ {session root, item worktree} ×
   path form ∈ {repo-relative, absolute} × target ∈ {own item, sibling item, absent}, each row
   carrying `Expected` and, for deny rows, an expected reason discriminator. Include the four rows from
   `epic.md:322-326` that apply to this site, retaining currently-passing rows as regression guards.
3. **Zero filesystem, zero temp files, zero process.** Synthetic literal roots only; all state via the
   three existing mocks plus one new injection parameter. Record the determinism statement in the
   suite header, following `absolute-paths.Tests.ps1:25-31` and
   `preimplementation-gate-classifier.Tests.ps1:25-29`.
4. **Both polarities of the probe-invocation count** (zero on the ambiguity branch, exact positive
   counts on allow rows) — see H.2.
5. **Cross-file mock smoke case** run first, before the rest of the extraction (see D.3).
6. **Reason-string regression**: assert R4 and R3 verbatim-by-substring, and assert that the new
   ambiguity reason is distinct from both and greppable as a single literal code.
7. **Unmodified gates to re-run**: `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`,
   `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`,
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
   `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`,
   `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`,
   `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.
8. **Toolchain** (`.claude/rules/powershell.md:13-20`): `run_poshqc_format` -> `run_poshqc_analyze`
   -> `run_poshqc_test`, restarting from step 1 on any failure or auto-fix, then the three Python
   parity tests. Line coverage >= 85% for both the hook and the new helpers sibling, read per-file from
   `artifacts/pester/powershell-coverage.xml`; no branch-coverage gate for PowerShell.

---

## K. Open items the plan must close

| # | item | why it cannot be closed here |
| --- | --- | --- |
| K1 | Row 3 of the decision matrix (absolute path -> DENY) is not explained by a static reading; two hypotheses recorded in A.7. | Requires an `[expect-fail]` Pester reproduction before the fix. |
| K2 | F1's module name, function names, and ambiguity reason-code spelling. | F1 is not in this tree. Binds at execution time after F1 merges to the integration branch. |
| K3 | Whether the live PreToolUse envelope carries a `cwd` root field in this runtime. | No hook reads it today; no captured payload exists in the repository. Capture evidence before depending on it. |
| K4 | Whether Pester `Mock` is observed across the dot-source boundary in this repository. | No existing test exercises it. Verify with the smoke case in D.3. |
| K5 | Change-budget route for 4 production PowerShell files. | `.claude/rules/powershell.md:37-40` caps direct mode at 2 and any batch at 3. Needs a router decision or an explicit override. |
| K6 | Reconciling "fixed segment-count truncation is prohibited" (`epic.md:102-103`) with #518's depth-collapsing truncation, which must survive. | Stated in G.3; needs an explicit ruling in the spec so implementation does not re-open #518. |
| K7 | `quality-tiers.yml` does not exist at the repository root although `.claude/rules/quality-tiers.md` names it the source of truth. | Out of F4's scope; record, do not fix. Uniform gates apply regardless. |
