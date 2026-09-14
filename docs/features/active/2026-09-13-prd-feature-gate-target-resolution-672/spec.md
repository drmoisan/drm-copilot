# 2026-09-13-prd-feature-gate-target-resolution (Spec)

- **Issue:** #672
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T21-30
- **Status:** Ready for planning
- **Version:** 1.0
- **Epic:** `worktree-scoped-state-resolution` (F4, wave 1, defect ref 3.1)
- **Work Mode:** `full-bug` (`spec.md` is the sole acceptance-criteria source; `user-story.md` is intentionally absent)
- **Research record:** `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/research/2026-09-13T21-05-prd-feature-gate-target-resolution-research.md`

## Context
`.claude/hooks/enforce-prd-feature-before-planner.ps1` resolves the feature folder it gates against the invoking session's current working directory rather than against the worktree the tool call pertains to, and truncates prompt path tokens to a fixed segment count. As a result the hook denies every `Agent(atomic-planner)` delegation issued from a coordinating (parallel or epic) session, even when the required document exists and is committed.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: `Agent(atomic-planner)` delegation from a coordinating orchestration session
- Data source or fixture: TaskMaster parallel run `bugs-2026-09-11`, item 839 (both `spec.md` and `user-story.md` present and committed)

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Create a parallel or epic orchestration topology in which the coordinating session's current working directory is the session root and each child item occupies its own git worktree.
2. Ensure a child item's active feature folder contains the document its work-mode marker requires (for item 839, `spec.md` and `user-story.md` both exist and are committed).
3. From the coordinating session, issue an `Agent(atomic-planner)` delegation whose prompt names that item's feature folder, first in repo-relative form and then in absolute form.

Expected:
The hook resolves the feature folder named in the tool-call payload against the worktree that folder belongs to, finds the required document, and allows the delegation. When the target cannot be identified, the hook denies with a distinct, greppable ambiguity reason code rather than falling back to whatever checkpoint occupies the session root.

Actual:
Verified decision matrix, tested directly during run `bugs-2026-09-11` for item 839:

| envelope | cwd | result |
| --- | --- | --- |
| names its own feature folder | orchestrator session root | DENY |
| identical envelope | the item's own worktree | ALLOW |
| names an absolute path to the same folder | either | DENY |

No remediation cycle can run from a coordinating session, which brought the run to a complete standstill.

Evidence qualification (from the research record, section A.7):

- Rows 1 and 2 are fully explained by a static reading of the current hook. The three relative probes (`issue.md`, each required document, and the checkpoint) resolve against the process working directory, so the same envelope allows under the item worktree and denies under the session root.
- Row 3 (absolute path denies) is **not** explained by the code as read, and was not reproduced in this tree. Under the current match-and-truncate path an absolute token reduces to the same repo-relative candidate as a relative token, so rows 2 and 3 should coincide when the working directory is the item worktree. The leading hypothesis is that the absolute-form prompt carried a second, distinct `docs/features/active/...` citation, which takes the multi-candidate branch, consults the session-root checkpoint, misses, and falls through to positional selection of the earliest-occurring candidate. This is stated as a hypothesis, not as established fact.
- Consequently the absolute-path acceptance criteria below are written **positively** — as the behaviour required of the fixed gate — rather than as a regression from a denial the suite cannot yet demonstrate. Attempting the row-3 reproduction is a plan-sequencing concern, not a spec assertion.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: the denial is the hook's existing missing-required-document reason, which is misleading: the document is present, but the hook tested for it under the wrong root.


## Scope & Non-Goals

- In scope:
  - `.claude/hooks/enforce-prd-feature-before-planner.ps1`: resolve the gated feature folder against the worktree the tool call pertains to, accept absolute path forms, and deny with a distinct ambiguity reason code when the target cannot be identified.
  - A new dot-sourced sibling `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` holding the hook's pure string and collection logic. The extraction is a required part of this change, not optional cleanup: the hook has limited headroom against the 500-line cap and cannot absorb the new import, branch, and documentation in place.
  - Bundled-payload mirrors of both files under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
  - Registration of the new sibling in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and in the `CodeCoverage.Path` allow-list of both copies of `pester.runsettings.psd1`.
  - A third companion Pester suite covering the cwd x path-form x target matrix, with currently-passing rows retained as regression guards.
- Out of scope / non-goals:
  - Changing child-prompt construction. This is the epic's recorded anti-pattern: every child prompt in the originating run already named its own feature folder, so the defect is in the hook's resolution, not in its callers.
  - Re-implementing target derivation, path normalisation, or the ambiguity reason code locally. All three are consumed from the epic's F1 module under `.claude/lib/`.
  - Resolving the worktree inside the hook by walking up from the process working directory or by shelling out to `git worktree list`. Both duplicate F1's contract and reintroduce the working-directory dependence that issue #518's spec already rejected.
  - Any change to the work-mode marker regex, the required-document mapping, the missing-document reason string, the deny payload shape, or the dot-source guard, except where the target-root change forces it.
  - Porting any part of the gate to Python. Enforcement hooks are PowerShell or bash only.
  - Registration of F1's own `.claude/lib/` module and its `*.Manifest.Tests.ps1`. That belongs to F1.
- Explicitly excluded systems, integrations, or datasets:
  - `.codex/hooks/`. Full enumeration of that directory confirms no mirror of this hook and no differently named analogue, so this feature carries no Codex parity work. A reviewer should not look for one.
  - The other six epic defect sites (`enforce-pr-author-skill*.ps1`, `enforce-orchestration-preimplementation-gate*.ps1`, `enforce-model-routing-receipt.ps1`, `enforce-epic-merge-gate.ps1`, `mcp__drm-copilot__collect_pr_context`, and the TaskMaster push-down). Those belong to sibling features.
  - The TaskMaster repository. No change is made or verified there by this feature.

## Root Cause Analysis

All citations below are the research record's re-measured values and supersede the citations carried
from `issue.md`, which had drifted.

### Mechanical root

`.claude/settings.json` registers the hook with a repository-relative script path and no
working-directory override, so the hook process inherits the Claude session's current directory.
Every relative path the script later hands to `Test-Path` or `Get-Content` therefore resolves against
that session directory. The script cannot opt out of this without resolving a root explicitly.

Three `Test-Path -LiteralPath` call sites exist, and each resolves against the process working
directory:

- line 91, inside `Get-PrdFeatureFileExistence`, on the required-document path composed at line 329;
- line 108, inside `Get-PrdFeatureIssueContent`, on the `issue.md` path composed at line 107;
- line 201, inside `Get-PrdFeatureCheckpointFolder`, on the default `artifacts/orchestration/orchestrator-state.json`.

`Get-Content` at lines 113 and 206 inherits the same resolution. No worktree resolution exists
anywhere in the file: no `git worktree`, `$PWD`, `Get-Location`, `Resolve-Path`, or
`$PSScriptRoot`-derived root appears outside the module import at line 78.

The envelope root returned by `Resolve-ClaudeHookToolInput` is available on the parse result but is
never read by this hook; only the nested `tool_input` object is consumed. Any root-level field is
therefore unavailable to the current decision path by construction.

### The three-way distinction, and where each state is conflated today

The fixed gate must distinguish three states and respond differently to each. Conflating any two
either reopens the false denial or creates a new false approval.

1. **Target resolved, required document PRESENT -> ALLOW.** Currently denies. This is the defect.
   `Get-PrdFeatureMissingFile` composes `"$FeatureFolder/$name"` at line 329 from a repo-relative
   folder and probes it against the process working directory. The gate is not asking "does the
   document exist for this target"; it is asking "does a path with this relative spelling exist under
   whatever directory this process happens to be in". When the two roots differ, a present document
   reads as absent and the gate emits the missing-required-document reason. The denial is truthful
   about the wrong root.
2. **Target resolved, required document GENUINELY ABSENT -> DENY with the existing reason.** This is
   the only state reported correctly today, and only when the working directory happens to coincide
   with the target.
3. **Target NOT RESOLVABLE -> DENY with a distinct, greppable ambiguity reason code.** Currently
   conflated in three separate places, not one:
   - **Unconditional checkpoint fallback (lines 368-370).** A prompt that names no feature folder
     falls silently to `Get-PrdFeatureCheckpointFolder`, which reads the checkpoint relative to the
     process working directory. In a coordinating session that is the orchestrator's own checkpoint,
     describing a different item. The gate then validates item A's delegation against item B's state
     and can return `allow`. This fallback is currently asserted as intended behaviour by an existing
     test, so changing it is a deliberate, specified behaviour change.
   - **Positional tie-break (lines 296-307).** With more than one distinct candidate the session-root
     checkpoint is the disambiguator; on a miss, line 307 returns the earliest-occurring candidate
     with no signal that the choice was arbitrary. An ambiguous target is resolved by a positional
     heuristic and reported as if it were determined.
   - **Missing/malformed-marker branch (lines 398-410).** When the folder does not exist under the
     probed root at all, `Get-PrdFeatureIssueContent` returns null, the work mode is indeterminate,
     and the gate emits a reason asserting that the `- Work Mode:` marker is absent, unreadable, or
     unrecognized. The actual condition is "this folder was probed at the wrong root", and the remedy
     the message prescribes would edit the wrong repository's `issue.md`.

### Corrected premise: the gate does not fail closed to `full-feature`

The originating brief stated that the hook falls back to `full-feature` on a missing or malformed
work-mode marker. It does not, and reproducing that would be a regression. The actual semantics:

- A missing or malformed marker takes its own decision path (lines 398-410), denies with its own
  reason, and runs **no** required-file probe. A current test pins the zero-probe assertion.
- The `default` arm of `Get-PrdFeatureRequiredFile` (line 185) returns `spec.md` **alone**, not the
  full-feature pair. The arm is unreachable from the decision path and exists so a direct caller
  passing a null mode cannot receive a permissive empty set. It must never name `user-story.md`,
  because that document is required to be absent for `full-bug` and `minor-audit`. A current test
  pins this.
- The only "fail closed to `full-feature`" rule in the repository is a **producer**-side rule in the
  `feature-promotion-lifecycle` skill, governing what promotion tooling persists. It is not a gate
  rule and must not be imported into the hook.

### Ruling: what the epic's truncation prohibition does and does not cover

The epic states that segment-count truncation is prohibited for path normalisation. The truncation at
lines 272-277 was introduced by the completed fix for issue #518 and solves **depth insensitivity** —
a `research/` or `evidence/` artifact citation and a bare folder citation must resolve to the same
feature folder. Deleting it re-opens #518.

**Ruling, stated so an implementer cannot misread it:** the prohibition applies to truncation used as
a *substitute for locating the containing worktree*. It does not apply to depth normalisation.
Concretely, the current expression performs two jobs:

- **prefix discarding** — an unanchored match beginning at the literal `docs`, plus retention of a
  fixed index window, which makes it impossible to re-attach an absolute or foreign-root prefix. This
  half is **replaced** by F1's path normalisation, which locates the containing worktree.
- **depth collapsing** — reducing a deeper citation to its feature-folder ancestor. This half
  **survives unchanged**, and the existing truncation test block must continue to pass.

A literal reading of "fixed segment-count truncation is prohibited" that deletes lines 272-277
outright is incorrect and regresses #518.

### Anti-pattern (recorded so it is not re-proposed)

The initial hypothesis during the originating run was that child prompts omitted the folder path.
That was wrong. Every child prompt in the run named its own feature folder. The defect is in the
hook's resolution, not in its callers. Do not change prompt construction.


## Proposed Fix

### Design summary (what changes where):

Consume F1's resolution module at the hook's existing
`Import-Module (Join-Path $PSScriptRoot '../lib/...') -Force` seam. Derive the call's target from the
tool-call payload (envelope root plus `tool_input`) using F1's target derivation, normalise any path
token found in the prompt using F1's path normalisation, and thread the resolved target root as
**data** into the two probe-composition sites. Add one new deny branch that emits F1's ambiguity
reason code inside the existing `PRD_FEATURE_BLOCKED:` prefix, and take that branch before any
document probe runs. Extract the hook's pure string and collection logic into a dot-sourced
`-helpers.ps1` sibling for headroom. Leave the work-mode semantics, the required-document mapping,
and the missing-document reason untouched.

This approach is selected because it is the only option that satisfies the four hard constraints
simultaneously: no Python in an enforcement hook, no file over 500 lines, no temporary files in
tests, and no local re-implementation of F1's contract. It reuses three established repository
mechanisms verbatim — the lib-import form, the helpers-extraction form, and the injection-parameter
test seam — so the review surface is the behaviour change alone.

Rejected alternatives, each with its reason:

- **Discover the worktree inside the hook** by walking up from the working directory or shelling to
  `git worktree list`. Rejected: duplicates F1's contract, adds process I/O to a fail-closed gate, and
  depends on the process working directory, which `.claude/rules/powershell.md` forbids tests from
  relying on. Issue #518's spec already recorded this rejection for this same file.
- **Change prompt construction** so children always emit absolute paths. Rejected: this is the epic's
  recorded anti-pattern.
- **Skip the extraction and add the logic in place.** Rejected: the current file plus the new import,
  branch, and documentation exceeds the 500-line cap. The epic classifies the extraction as mandatory.
- **Add the new matrix to an existing suite.** Rejected: both existing suites are near the cap; the
  matrix plus its regression guards does not fit in either.

### Boundaries and invariants to preserve:

- The gate stays fail-closed on every path. An empty prerequisite set is never a fail-closed default.
- The gate still denies when the required document is genuinely absent, with the existing reason,
  which leads with the resolved feature folder and then names the missing documents, the work mode,
  and the remedy.
- Every deny reason retains the `PRD_FEATURE_BLOCKED:` prefix. F1's ambiguity code is embedded
  **inside** such a string, not substituted for the prefix.
- The work-mode marker semantics are preserved exactly as they actually are, per the corrected
  premise above: the accepting regex and its legacy `full` normalisation, the required-document
  mapping (`full-feature` -> `spec.md` and `user-story.md`; `full-bug` -> `spec.md`; `minor-audit` ->
  empty set; `default` -> `spec.md` alone), and the indeterminate-marker branch as a distinct decision
  path that runs no required-file probe.
- The depth-collapsing behaviour delivered by the #518 fix survives. Four prompt forms already pinned
  by tests (folder alone; folder plus a `research/` artifact; folder plus an `evidence/` artifact;
  nested artifact alone) must continue to produce the identical decision and the identical reason
  string.
- The multi-candidate selection rule remains distinguishable from plain earliest-occurrence. The
  existing case in which the preferred folder occurs *later* in the prompt is re-specified against
  the new disambiguator, not deleted; deleting it removes the only proof the rule is deliberate.
- The three mock seam names and signatures are unchanged: `Get-PrdFeatureFileExistence`,
  `Get-PrdFeatureIssueContent`, `Get-PrdFeatureCheckpointFolder`. Existing suites keep mocking them.
- The dot-source guard on the entrypoint is unchanged, so suites can load the file without executing
  the decision.
- The PreToolUse allow and deny payload shapes are unchanged, so the schema contract suite passes
  unedited.
- Epic and standalone topologies behave exactly as now when the working directory and the target
  coincide. Removing the silent session-root checkpoint fallback must not turn an allow into a deny in
  the single-worktree topology; when the derived target *is* the session root, the checkpoint fallback
  still applies.
- Two known limitations recorded by #518 — the version-folder limitation and the
  trailing-prose-punctuation limitation — are inherited unchanged and are not silently altered.
- The epic-wide must-not-regress constraints outside this file are honoured by not touching it: the
  pre-implementation gate's pathspec, option, and metacharacter restrictions are not weakened, and the
  epic merge gate's matcher is not widened.

### Dependencies or blocked work:

**F1 (`target-worktree-resolution-module`, wave 0) is an upstream blocking dependency.** It is not
present in this tree. It delivers a new `.claude/lib/` module providing three things this feature
consumes and must not re-implement:

1. **Target derivation** — given a tool-call payload, return the worktree the call pertains to, or an
   explicit "no target" result.
2. **Path normalisation** — given a relative or absolute path, return its repo-relative form by
   locating the containing worktree.
3. **A single distinct, greppable ambiguity reason code** emitted when the correct target cannot be
   identified.

**F1's concrete module name, function names, and reason-code spelling are not yet fixed. They BIND AT
EXECUTION TIME**, when F1 has merged into the integration branch ahead of this feature. This spec is
written against the contract's *semantics* only. No identifier is invented or presented as settled
anywhere in this document, and the acceptance criteria assert behaviour and the distinctness of the
code rather than any literal spelling. The implementing plan must resolve the identifiers by reading
F1's merged source and must not hard-code a guess.

Two further dependency facts:

- The guarded lazy-import variant used by some hooks is **not** appropriate here. This gate must fail
  closed, and an unresolvable resolution module is itself the "target not resolvable" state, which
  must deny loudly rather than degrade.
- Whether the live PreToolUse envelope carries a working-directory field in this runtime is
  **unverified**. No hook in this repository reads one today and no captured payload exists in the
  repository. If F1's target derivation depends on such a field, this feature must capture a real
  payload as evidence before relying on it, and must retain a deny path for the case where the field
  is absent.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

| file | change |
| --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | import F1's module; derive the target; thread the target root into both probe compositions; add the ambiguity deny branch; remove the unconditional session-root checkpoint fallback; retain the three filesystem seams |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | **new.** Dot-sourced sibling holding the pure string and collection logic |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1` | text-identical mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | **new.** Text-identical mirror |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | register the new sibling in `paths`, beside the existing `-helpers` and `-modes` entries |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | add the new sibling to `CodeCoverage.Path` |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | same entry; parity with the copy above is machine-asserted |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | **new.** Third companion suite carrying the matrix |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | amend only the checkpoint-fallback case, which currently asserts the silent fallback as intended behaviour |

**Helpers extraction (specified requirement, not optional cleanup).** The research record measured the
hook's per-function line regions, which sum exactly to the file's measured length. The split moves the
four pure functions — `Resolve-PrdFeatureWorkMode`, `Get-PrdFeatureRequiredFile`,
`Find-PrdFeatureFolderFromPrompt`, and `Get-PrdFeatureMissingFile` — to the sibling, and keeps all
three mocked filesystem seams (`Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`,
`Get-PrdFeatureCheckpointFolder`) in the parent so the existing suites' mock-resolution surface does
not move. The research record's projection is a parent of roughly 266 lines and a sibling of roughly
211 lines, both against the repository's 500-line cap; those figures are the research record's
projections, and the binding requirement is the cap itself, measured on the delivered files.

The sibling follows the established form: `<parent-stem>-helpers.ps1` in the same directory, carrying
a comment-based-help block and **no** `param()` block, no `#Requires`, and no entrypoint. The parent
dot-sources it at file scope with `. (Join-Path $PSScriptRoot '<sibling>.ps1')`, immediately after the
`Import-Module` lines and before any function definition. Suites dot-source the parent **and** the
sibling explicitly, so a later change to the parent's dot-source line cannot silently redirect the
assertions.

One assumption in the split is unverified in this repository and must be smoke-tested before the rest
of the extraction is committed: whether a Pester `Mock` registered in the test scope is observed by a
caller defined in the *other* dot-sourced file. PowerShell resolves function names through the session
-state function table at call time, so it is expected to work, but no existing test exercises it.

#### Functions/classes/CLI commands impacted:

- `Invoke-PrdFeatureBeforePlannerDecision` — obtains the target-derivation result, gains the new
  ambiguity deny branch, loses the unconditional checkpoint fallback, and passes the resolved target
  root to the two probe-composition sites. Gains an injection parameter for the resolved target,
  following the existing `-CheckpointRaw` precedent and its `ContainsKey`-based binding discipline, so
  an explicitly supplied empty value suppresses the seam rather than falling through to disk.
- `Find-PrdFeatureFolderFromPrompt` — moves to the sibling; its prefix-discarding half is replaced by
  F1's normalisation while its depth-collapsing half is retained; its multi-candidate disambiguator
  becomes the F1-derived target rather than the session-root checkpoint, and its positional fallback
  becomes an ambiguity denial rather than a silent selection.
- `Get-PrdFeatureMissingFile` — moves to the sibling; composes probe paths against the resolved target
  root instead of a bare repo-relative folder.
- `Get-PrdFeatureIssueContent` — stays in the parent; composes the `issue.md` path against the
  resolved target root.
- `Get-PrdFeatureCheckpointFolder` — stays in the parent; may be consulted only when the call
  genuinely has no target **and** the session root is the target.
- `Resolve-PrdFeatureWorkMode` and `Get-PrdFeatureRequiredFile` — move to the sibling **unchanged**.
  No behavioural edit is permitted to either.
- `Get-PrdFeatureFileExistence` — stays in the parent, name and signature unchanged.

#### Data flow and validation changes:

1. The payload is parsed as today; in addition, the envelope root is read so the target derivation has
   the full call context available.
2. The target is derived from the payload. The result is either a target root or an explicit "no
   target".
3. On "no target" with no usable session-root equivalence, the gate denies with the ambiguity code and
   **returns before any probe runs**.
4. Otherwise every path token found in the prompt is normalised through F1's normalisation, producing
   candidate feature folders anchored to a known worktree.
5. Candidate selection: a single distinct candidate is used directly; multiple candidates are
   disambiguated against the derived target; an unresolved tie denies with the ambiguity code rather
   than selecting positionally.
6. The `issue.md` path and each required-document path are composed against the resolved target root
   and probed through the unchanged seams.
7. The work-mode branch, the required-document mapping, the missing-set computation, the allow shape,
   and the missing-document deny shape are unchanged.

#### Error handling and logging updates:

- One new deny reason is added: `PRD_FEATURE_BLOCKED:` followed by F1's ambiguity reason code and an
  explanatory clause naming the ambiguity. It must be distinct from both the missing-document reason
  and the indeterminate-work-mode reason, and greppable as a single literal code.
- The indeterminate-work-mode reason is now reachable only when the folder *does* exist under the
  resolved target root and its marker is unreadable. The ambiguity and absence paths take precedence,
  so the gate no longer misreports "probed at the wrong root" as "your marker is broken" and no longer
  prescribes a remedy that would edit the wrong repository's `issue.md`.
- The missing-document reason, the payload-anomaly reason, and the allow shape are unchanged.
- The gate continues to write its decision as compressed JSON and to exit zero. No new logging sink,
  file write, or process invocation is introduced.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. A fail-closed gate with two code paths selected by a flag would double the behaviour
surface a reviewer must verify and would leave the defective path reachable in production. Rollback is
by reverting the change set, which is self-contained: two `.claude/hooks/` files, their two bundled
mirrors, one manifest entry, two coverage allow-list entries, and the test files. Because the
push-down serves the installed extension's bundled payload, a rollback that reverts only the
repository copies leaves the bundled copies stale; both sides revert together.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- **Input:** the PreToolUse payload on stdin, with the existing environment-variable fallbacks. The
  nested `tool_input` object supplies `subagent_type` and `prompt`; the envelope root supplies the
  remaining call context used for target derivation. Reading root-level keys uses the payload module's
  existing StrictMode-safe accessors; **no change to the payload module is required.**
- **Output (allow):** the existing ordered object with `hookSpecificOutput.hookEventName` =
  `PreToolUse` and `permissionDecision` = `allow`, and **no** `permissionDecisionReason` member.
  Unchanged.
- **Output (deny):** the existing deny shape with a `permissionDecisionReason` string. Unchanged in
  shape; one new reason value is added.
- **F1 contract surface (semantics only; identifiers bind at execution time).** This feature consumes
  exactly three things, and the plan resolves each against F1's merged source rather than against any
  spelling guessed here:

  | consumed capability | required semantics | identifier status |
  | --- | --- | --- |
  | target derivation | payload in; either a target worktree or an explicit "no target" out | binds at execution time |
  | path normalisation | relative or absolute path in; repo-relative form out, obtained by locating the containing worktree; no prefix discarding | binds at execution time |
  | ambiguity reason code | a single distinct literal, greppable, embedded inside a `PRD_FEATURE_BLOCKED:`-prefixed reason | binds at execution time |

#### Required configuration keys and defaults:

- No new configuration key, environment variable, or settings entry. The hook remains registered in
  `.claude/settings.json` under the existing `PreToolUse` `Agent` matcher with its existing command
  line; that registration is not modified.
- Two registration entries are added as delivery metadata rather than runtime configuration: the new
  sibling's path in the `core.json` pack manifest `paths` array, and the same path in the
  `CodeCoverage.Path` allow-list of both copies of `pester.runsettings.psd1`.

#### Backward-compatibility expectations:

- Callers see no interface change. The hook is invoked by the runtime, not by user code.
- One deliberate behaviour change is specified and must be called out in review: the unconditional
  fallback to the session-root checkpoint when the prompt names no feature folder is removed. That
  fallback is currently asserted as intended behaviour by an existing test, which is **amended**, not
  deleted, to assert that the fallback still applies and still allows when the derived target is the
  session root.
- All other decision paths, reason strings, and payload shapes are backward compatible.

#### Performance constraints (latency/throughput/memory):

The hook runs synchronously in the PreToolUse path of every `Agent` delegation, so added cost is paid
on each such call. The change adds no process invocation and no network call. Filesystem access
remains bounded by the same three seams. F1's resolution is expected to be in-process; if its
derivation requires a subprocess, that cost is F1's to characterise and this feature must not add a
second one.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - F1 has merged into `epic/worktree-scoped-state-resolution-integration` before this feature is
    implemented. Its identifiers are read from the merged source at that point.
  - A Pester mock registered in the test scope is observed by callers defined in a different
    dot-sourced file. This is expected from PowerShell's call-time function resolution but is not
    exercised by any existing test in this repository, so it is smoke-tested first.
  - The live PreToolUse envelope's root-level fields are as documented. Whether it carries a
    working-directory field is unverified here; if F1's derivation depends on one, a real payload is
    captured as evidence before that dependence is relied on.
  - `quality-tiers.yml` **does not exist at the repository root** in this tree, although
    `.claude/rules/quality-tiers.md` names it the source of truth. No tier classification can be cited
    for this file, and no acceptance criterion depends on one. The uniform gates apply regardless:
    line coverage at or above 85 percent, zero lint findings, zero format drift, zero architecture
    violations. Recorded as an observation; fixing it is out of scope.
  - The repository and bundled copies of the hook are consistent with byte identity today, per a
    positional spot-check of distinctive anchors at matching line numbers in both files.
- Constraints (budget, performance, compatibility):
  - **No Python anywhere in the enforcement path.** Hooks are PowerShell or bash only; a Python leg
    creates a second implementation of the rule that drifts from the first.
  - **No file over 500 lines** (`.claude/rules/general-code-change.md`), production or test.
  - **No temporary files or directories in tests** (`.claude/rules/general-unit-test.md`), and no
    reliance on implicit working-directory assumptions (`.claude/rules/powershell.md`).
  - **Change-budget conflict.** `.claude/rules/powershell.md` caps direct mode at two production
    PowerShell files and any batch at three production files. This change set is the hook, its new
    sibling, and their two bundled mirrors — four production PowerShell files — which exceeds both
    caps. The extraction is mandatory, so the conflict cannot be avoided by narrowing scope. See Risks
    for the mitigation. No override is assumed.
  - Test files live under `tests/`, mirroring the production structure. Colocation is not permitted.
  - Line coverage must remain at or above 85 percent. Pester does not measure branch coverage, so no
    branch-coverage gate applies to these files; they remain in the coverage denominator.
- External dependencies (services, libraries, releases):
  - The epic's F1 module under `.claude/lib/` (blocking, wave 0).
  - The existing payload-parsing module under `.claude/lib/hook-payload/`, consumed unchanged.
  - No new third-party package, service, or release.

## Data / API / Config Impact

- User-facing or API changes: none. The only externally observable change is the gate's decision for
  payloads whose target differs from the session's working directory, plus one new deny reason string.
- Data or migration considerations: none. No schema, checkpoint field, or persisted artifact format
  changes. The orchestrator-state checkpoint continues to be read through the existing seam and is
  never written by this hook.
- Logging/telemetry updates (if any): none beyond the new deny reason string described above. The hook
  emits only its decision JSON.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI surface. Two delivery-metadata
  registrations are added (the `core.json` pack-manifest `paths` entry and the `CodeCoverage.Path`
  entry in both copies of `pester.runsettings.psd1`), each enforced by an existing test. The bundled
  payload under `extensions/drm-copilot/resources/claude-customizations/.claude/**` must stay
  text-identical to the repository copy; a one-sided edit fails the existing parity test and is inert
  at the push-down surface.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: table-driven Pester over the cross product of cwd (session root vs item worktree), path form (relative vs absolute), and target (own item vs sibling item vs absent), with currently-passing rows retained as regression guards.
- [x] Integration scenario to retest: a coordinating session delegating `Agent(atomic-planner)` for an item whose required document exists.
- [x] Manual verification notes: the gate must still deny when the required document is genuinely absent. A fix that resolves the target correctly but stops checking the document converts a false denial into a false approval, which is the more serious failure mode.

Fix direction (fixes 1 and 2 of the parent epic's five):

1. Resolve against the call's target, not the session's cwd. Derive the target worktree from the tool-call payload. Use the session root only when the call genuinely has no target.
2. Accept absolute paths. Normalise to repo-relative by locating the containing worktree instead of truncating to a fixed segment count. Read this together with the ruling in Root Cause Analysis: the prohibition covers truncation used as a substitute for locating the containing worktree, not depth normalisation, which must survive.

Upstream dependency: the target-derivation, path-normalisation, and ambiguity-reason-code contract is delivered by the parent epic's F1 module under `.claude/lib/`. Consume that contract; do not re-implement any of its three parts locally. Its concrete identifiers bind at execution time.

Bundled-payload mirroring: every edit under `.claude/**` must also be applied at `extensions/drm-copilot/resources/claude-customizations/.claude/**`. The two copies of this hook are consistent with byte identity as re-checked on 2026-09-13: both report the same length and five distinctive anchors match at the same line numbers in each. A byte-level diff was not re-run during research; the parity test is the authoritative check and is run as delivery evidence.

### Mandatory test matrix

Table-driven Pester over the cross product of **cwd** (session root vs item worktree) x **path form**
(relative vs absolute) x **target** (own item vs sibling item vs absent). The rows below are
mandatory. Currently-passing rows are **regression guards and must not be dropped as redundant.**

| case | expected |
| --- | --- |
| own folder named, cwd = session root | allow (currently denies) |
| own folder named, cwd = item worktree | allow (unchanged) |
| absolute path to own folder | allow (stated positively; see the evidence qualification above) |
| sibling's checkpoint is the only state present | deny, distinct ambiguity reason code |
| required doc genuinely missing | deny (unchanged reason) |
| each work mode (`full-feature` / `full-bug` / `minor-audit`) against its required document set | per existing semantics (unchanged) |

### How cwd is varied without temporary files

Temporary files and directories are prohibited in tests. The compliant pattern already established in
this repository is used instead, and its exemplar is
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`,
whose header (lines 25-31) states the rule outright.

1. **Synthetic absolute prefixes as bare string literals.** No absolute path in the new suite is
   derived from the runtime environment, the current directory, the script file location, or a
   source-control query. Two synthetic roots model the coordinating session and the item's worktree.
2. **cwd is modelled as data, not as process state.** The process working directory is never changed
   and no directory is created. The resolved target arrives through an injection parameter on the
   decision function, following the existing injection-parameter precedent and its `ContainsKey`-based
   binding discipline, so disk is never read.
3. **The existence mock is keyed on the full composed path.** A row whose target root is the item
   worktree, with a mock that answers true only for the item-worktree spelling, **fails** if the hook
   still probes the session root. This turns the existing mock idiom into the discriminator for the
   whole cwd dimension with no filesystem access at all.
4. **Rows are bound with `-ForEach`** over a discovery-time array of case hashtables, because a value
   assigned inside an `It` body is not visible from Pester's discovery phase.

### False-approval guards (the highest regression risk)

A fix that resolves the target correctly but stops checking the document converts a false denial into
a false approval. **False approval is the more serious failure mode**: a false denial stalls a run
visibly, whereas a false approval reports a green that means nothing and the run proceeds on an
unverified basis. Three concrete ways it can happen, each with a required guard:

- The probe is made to return true when the target root cannot be composed. **Guard:** the ambiguity
  branch returns a deny *before* any probe runs, asserted with a zero-invocation count on the
  existence seam.
- The negative rows are written against a different target than the positive rows, so a probe that
  always answers true still passes them. **Guard:** every matrix row uses the same resolved-target
  root, differing only in whether the mock answers true for that exact composed path. The keyed mock
  is extended, never replaced with a blanket always-true mock.
- The allow path stops probing at all. **Guard:** positive-direction exact invocation counts on allow
  rows, matching the required-document count for the row's work mode. No such assertion exists today;
  it is the missing half of the zero-invocation assertion.

A fourth, subtler risk: removing the session-root checkpoint fallback could itself turn an allow into
a deny in the single-worktree topology. **Guard:** the existing checkpoint-fallback case is retained
in amended form, asserting that when the derived target *is* the session root the fallback still
applies and still allows.

### Test placement

A **third companion suite** at
`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`. Both
existing suites are close enough to the 500-line cap that the matrix plus its regression guards does
not fit in either. The suite header documents the placement decision and the determinism statement,
following the convention already established twice in this directory.

### Remaining test-strategy items

- Regression tests to add or update: retain the existing truncation and preserved-gate-behaviour
  blocks byte-untouched as proof the behaviour did not move; re-specify the deterministic-selection
  case against the new disambiguator rather than deleting it; amend the checkpoint-fallback case to
  the session-root-is-target form.
- Unit tests for the fixed behaviour and boundaries: Pester, not pytest — this is a PowerShell hook.
  The seeded template wording is corrected here. The new suite covers the three-way distinction, the
  full matrix, and both polarities of the probe-invocation count.
- Edge cases and negative scenarios: prompt naming no folder; prompt naming two distinct folders that
  cannot be disambiguated against the derived target; folder that does not exist under the resolved
  target root; absolute path form; backslash separators; nested artifact citations at differing
  depths; indeterminate work-mode marker; payload anomalies.
- Error handling and logging verification: assert the missing-document and indeterminate-marker
  reasons by substring so their text is pinned, assert the new ambiguity reason is distinct from both
  and greppable as a single literal code, and assert every deny reason retains the
  `PRD_FEATURE_BLOCKED:` prefix.
- Coverage impact and targets for changed lines/modules: line coverage at or above 85 percent for the
  hook and for the new sibling, read per file from the Pester coverage report. No branch-coverage gate
  applies to PowerShell. No production file is excluded from measurement.
- Toolchain commands to run: `mcp__drm-copilot__run_poshqc_format` ->
  `mcp__drm-copilot__run_poshqc_analyze` -> `mcp__drm-copilot__run_poshqc_test`, restarting from the
  first step on any failure or auto-fix, until all pass in a single pass. Type checking is not
  applicable to PowerShell.
- Unmodified gates to re-run as regression evidence: the PreToolUse schema contract suite, the
  `.claude/lib/` module convention suite, the enforcement-hooks-no-Python suite, and the three Python
  delivery tests — `test_push_down_claude_resource_contracts.py`,
  `test_push_down_claude_pack_manifest_completeness.py`, and `test_poshqc_bundled_parity.py`.
- Manual validation steps (if required): none required for this feature. End-to-end confirmation that
  the originating run resumes belongs to the epic's delivery feature, not here.


## Acceptance Criteria

Each criterion is independently verifiable and is written so that it can fail. No criterion depends on
an F1 identifier spelling, which is not yet fixed; the criteria assert behaviour and the distinctness
of the ambiguity code instead.

**The three-way distinction**

- [ ] **State 1 — target resolved, required document present -> ALLOW.** A Pester case supplies a payload whose prompt names the target feature folder while the modelled session root is a different worktree, mocks document existence to answer true only for the path composed against the target root, and asserts the decision is `allow`. The same case fails if the hook composes the probe against the session root.
- [ ] **State 2 — target resolved, required document genuinely absent -> DENY with the existing reason.** A Pester case asserts the deny reason still leads with the resolved feature folder, then names the missing document list, the work mode, and the existing remedy, and retains the `PRD_FEATURE_BLOCKED:` prefix. The reason text is unchanged apart from the resolved-folder value.
- [ ] **State 3 — target not resolvable -> DENY with the ambiguity reason code.** A Pester case asserts the deny reason embeds F1's ambiguity reason code inside a `PRD_FEATURE_BLOCKED:`-prefixed string, that the code is greppable as a single literal, and that the reason is distinct from both the missing-document reason and the indeterminate-work-mode reason. No silent fallback to the session-root checkpoint occurs on this path.

**All three current conflation sites are addressed**

- [ ] The unconditional post-prompt fallback to the session-root checkpoint is removed. The checkpoint is consulted only when the call genuinely has no target **and** the session root is the derived target. A Pester case asserts that a prompt naming no folder, issued from a session whose checkpoint describes a different item, denies with the ambiguity code rather than validating against that checkpoint.
- [ ] The positional tie-break is removed. With more than one distinct candidate, the disambiguator is the derived target; when the tie cannot be resolved against it, the gate denies with the ambiguity code instead of selecting the earliest-occurring candidate. A Pester case asserts the denial rather than a silent selection.
- [ ] The missing/malformed-marker branch is reached only when the feature folder **does** exist under the resolved target root and its `- Work Mode:` marker is unreadable. A Pester case asserts that a folder absent from the resolved target root produces the ambiguity or absence reason, not the marker-is-broken reason, so the gate no longer prescribes a remedy that would edit the wrong repository's `issue.md`.

**False-approval guards (highest regression risk)**

- [ ] The ambiguity branch returns its deny **before** any document probe runs, asserted with a zero-invocation count on `Get-PrdFeatureFileExistence`.
- [ ] Allow rows assert an exact positive invocation count on `Get-PrdFeatureFileExistence` matching the required-document set for the row's work mode, so an implementation that returns `allow` without probing fails the suite.
- [ ] Every matrix row uses the same resolved-target root and differs only in whether the existence mock answers true for that exact composed path. No row uses a blanket always-true existence mock.

**Mandatory test-matrix rows (regression guards retained, not dropped)**

- [ ] Row — own folder named, cwd modelled as the session root: `allow`. This row currently denies and is the defect's direct proof.
- [ ] Row — own folder named, cwd modelled as the item worktree: `allow`, unchanged. Retained as a regression guard.
- [ ] Row — an absolute path to the own feature folder: `allow` when the required document is present under the containing worktree, for both modelled cwd values.
- [ ] Row — a sibling item's checkpoint is the only state present: `deny` with the distinct ambiguity reason code. This row never returns `allow`.
- [ ] Row — the required document is genuinely absent under the resolved target root: `deny`, with the existing missing-document reason, unchanged.
- [ ] Rows — each work mode against its required document set, per existing semantics and unchanged: `full-feature` requires `spec.md` and `user-story.md`; `full-bug` requires `spec.md`; `minor-audit` requires neither; legacy `full` normalises to `full-feature`.

**Must not regress**

- [ ] The gate still denies when a required document is genuinely absent.
- [ ] The pre-implementation gate's pathspec, option, and metacharacter restrictions are not weakened. No file matching `enforce-orchestration-preimplementation-gate*` is modified by this change set, and its suites pass unmodified.
- [ ] The epic merge gate's matcher is not widened. `enforce-epic-merge-gate.ps1` is not modified by this change set, and its suites pass unmodified.
- [ ] Epic and standalone topologies behave exactly as now when cwd and target coincide. A Pester case asserts that when the derived target is the session root, the checkpoint fallback still applies and still allows; the existing checkpoint-fallback case is amended to this form rather than deleted.
- [ ] The #518 depth-insensitivity fix survives: the depth-collapsing behaviour is retained while the prefix-discarding behaviour is replaced by F1's normalisation. The existing truncation `Context` block and the existing preserved-gate-behaviour `Context` block in `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` pass byte-unmodified, and the already-pinned prompt forms — folder alone; folder plus a `research/` artifact; folder plus an `evidence/` artifact; nested artifact alone — still produce the identical decision and the identical reason string.
- [ ] The multi-candidate selection rule remains distinguishable from plain earliest-occurrence. The existing case in which the preferred folder occurs later in the prompt is re-specified against the new disambiguator, not deleted.
- [ ] The work-mode marker semantics are preserved exactly as they are today: the accepting regex and its legacy `full` normalisation are unchanged; the required-document mapping is unchanged; the `default` arm of `Get-PrdFeatureRequiredFile` returns `spec.md` alone and never names `user-story.md`; and the indeterminate-marker branch remains a distinct decision path that runs no required-file probe. No fail-closed-to-`full-feature` behaviour is introduced into the gate.
- [ ] The mock seam names and signatures — `Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`, and `Get-PrdFeatureCheckpointFolder` — the entrypoint dot-source guard, and the PreToolUse allow and deny payload shapes are unchanged. `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` passes unedited.

**F1 consumption**

- [ ] Target derivation, path normalisation, and the ambiguity reason code are consumed from F1's `.claude/lib/` module through the established `Import-Module (Join-Path $PSScriptRoot '../lib/...') -Force` form. None of these capabilities is re-implemented in the hook or its helpers sibling: neither file contains worktree-discovery logic (`git worktree`, `Get-Location`, `$PWD`, or a `Resolve-Path`-derived root) and neither defines its own ambiguity code literal.
- [ ] Every F1 symbol referenced by the delivered code resolves against F1's merged source on the integration branch. No guessed or placeholder identifier appears in the delivered code, and the module is imported so that an unresolvable dependency fails the gate closed rather than degrading to a permissive path.

**Helpers extraction and the file-size cap**

- [ ] `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` exists and holds `Resolve-PrdFeatureWorkMode`, `Get-PrdFeatureRequiredFile`, `Find-PrdFeatureFolderFromPrompt`, and `Get-PrdFeatureMissingFile`. `Get-PrdFeatureFileExistence`, `Get-PrdFeatureIssueContent`, and `Get-PrdFeatureCheckpointFolder` remain in the parent hook. The sibling carries a comment-based-help block and contains no `param()` block, no `#Requires`, and no entrypoint; the parent dot-sources it at file scope.
- [ ] `Resolve-PrdFeatureWorkMode` and `Get-PrdFeatureRequiredFile` are moved without any behavioural edit.
- [ ] Every production and test file in the change set is at or under the 500-line cap required by `.claude/rules/general-code-change.md`, measured on the delivered files.
- [ ] A smoke case proves that a Pester mock registered in the test scope is observed by a caller defined in the other dot-sourced file, and it is run before the remainder of the extraction is committed.
- [ ] The new suite creates no temporary file or directory, does not change the process working directory, and derives no absolute path from the environment, the current directory, the script file location, or a source-control query. Its synthetic roots are bare string literals and cwd is supplied as data through an injection parameter.

**Bundled-payload mirroring and delivery registration**

- [ ] Both `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` have text-identical counterparts under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [ ] The new helpers sibling's path appears exactly once in the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` passes.
- [ ] The new helpers sibling is added to `CodeCoverage.Path` in both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes.
- [ ] No Codex mirror is added or expected. `.codex/hooks/` contains no mirror of this hook, so this feature carries no Codex parity work, and review does not look for one.

**Toolchain and coverage**

- [ ] No Python is introduced into the enforcement path. The hook and its sibling are PowerShell only, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes.
- [ ] Line coverage is at or above 85 percent for both `.claude/hooks/enforce-prd-feature-before-planner.ps1` and `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, read per file from the Pester coverage report, with neither file excluded from measurement.
- [ ] The PowerShell toolchain (`run_poshqc_format` -> `run_poshqc_analyze` -> `run_poshqc_test`) completes with zero format drift, zero analyzer findings, and zero test failures in a single pass, restarting from the first step after any failure or auto-fix.
- [ ] The new suite is placed at `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` and its header records the placement decision and the determinism statement.

## Risks & Mitigations

- Technical or operational risks:
  - **R1 — False approval replaces false denial (highest risk).** A fix that resolves the target
    correctly but stops checking the document turns a visible stall into a green that means nothing.
    False approval is the more serious failure mode: a false denial stalls a run visibly, a false
    approval lets the run proceed on an unverified basis.
  - **R2 — Deleting the depth-collapsing truncation re-opens issue #518.** A literal reading of the
    epic's "fixed segment-count truncation is prohibited" removes the whole expression, after which a
    `research/` or `evidence/` artifact citation no longer resolves to its feature folder.
  - **R3 — Change-budget conflict.** The change set is four production PowerShell files (the hook, the
    new sibling, and their two bundled mirrors) against a direct-mode cap of two and a per-batch cap of
    three in `.claude/rules/powershell.md`. The helpers extraction is mandatory, so the conflict cannot
    be removed by narrowing scope. Issue #518 stayed inside direct mode by keeping to a two-file scope;
    this feature cannot.
  - **R4 — Cross-file mock resolution is unverified here.** After the split, functions in the parent
    and the sibling call each other. Pester mocks are expected to be observed across that boundary, but
    no existing test in this repository exercises it. If the expectation is wrong, a large number of
    existing cases fail at once.
  - **R5 — F1's identifiers are unsettled.** Implementing against a guessed module name, function name,
    or reason-code spelling produces code that does not compile or, worse, a locally defined literal
    that duplicates F1's contract.
  - **R6 — One-sided bundled edit.** A repository-side-only edit is inert at the push-down surface and
    causes the epic's delivery feature to verify against stale content.
  - **R7 — Removing the checkpoint fallback could deny in the single-worktree topology**, violating the
    epic's must-not-regress constraint that epic and standalone topologies behave exactly as now when
    cwd and target coincide.
  - **R8 — The absolute-path reproduction (matrix row 3) may not reproduce.** Its cause is a hypothesis,
    not an established fact, so a plan that gates progress on reproducing it first could stall.
- Mitigations and rollbacks:
  - **R1:** the three false-approval guards specified in Test Strategy and pinned as acceptance
    criteria — a zero-invocation assertion on the ambiguity branch, exact positive invocation counts on
    allow rows, and a keyed existence mock shared across positive and negative rows.
  - **R2:** the explicit ruling recorded in Root Cause Analysis, which separates prefix discarding
    (replaced) from depth collapsing (retained), plus the acceptance criterion that the existing
    truncation `Context` block passes byte-unmodified.
  - **R3:** split the work into batches so no batch exceeds the per-batch cap — for example, the
    extraction and its mirrors as one batch and the behaviour change as the next — or route through
    `powershell-orchestrator` per `powershell-change-budget-router`. No override is assumed, and the
    plan must record which route it takes.
  - **R4:** run the cross-file mock smoke case before the rest of the extraction is committed. An
    existing single-candidate zero-invocation case already makes the assertion and will fail loudly if
    the expectation is wrong.
  - **R5:** resolve every F1 identifier from F1's merged source on the integration branch at
    implementation time. This spec deliberately contains no invented identifier.
  - **R6:** an existing parity test asserts text equality for every file under `.claude/**`; both
    copies are edited together and the parity test is run as delivery evidence.
  - **R7:** retain the existing checkpoint-fallback case in amended form, asserting that the fallback
    still applies and still allows when the derived target is the session root.
  - **R8:** state the absolute-path criterion positively, as behaviour required of the fixed gate.
    Reproduction sequencing is a plan concern; failure to reproduce does not block the fix.

## Rollout & Follow-up

- Release/rollout steps:
  1. Land F1 on `epic/worktree-scoped-state-resolution-integration` and read its identifiers from the
     merged source.
  2. Implement, in batches that respect the PowerShell change budget, running the full toolchain to a
     clean single pass after each batch.
  3. Run the delivery tests as evidence: the bundled-payload parity test, the pack-manifest
     completeness test, and the PoshQC bundled-parity test.
  4. Merge into the epic integration branch. The extension rebuild, reinstall, push-down, and
     confirmation that the originating run resumes belong to the epic's delivery feature, not here.
- Post-fix monitoring or clean-up tasks:
  - Confirm during the next parallel or epic run that no gate denial is attributable to a cwd/target
    mismatch at this site, and that no allow is returned on the basis of a sibling item's checkpoint.
  - Recorded, not fixed here: `quality-tiers.yml` is absent from the repository root although
    `.claude/rules/quality-tiers.md` names it the source of truth.
  - Recorded, not fixed here: the hook accepts a `- Work Mode:` marker anywhere in `issue.md` and any
    number of times (first match wins), while the `feature-promotion-lifecycle` skill requires exactly
    one marker above the first `##` heading. The hook is strictly the more permissive of the two. This
    divergence pre-dates this feature and is out of scope.
  - Recorded, not fixed here: the version-folder and trailing-prose-punctuation limitations inherited
    from issue #518.
- Links:
  - Issue: <https://github.com/drmoisan/drm-copilot/issues/672>
  - Epic manifest: `docs/features/epics/worktree-scoped-state-resolution/epic.md`
  - Research record: `docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/research/2026-09-13T21-05-prd-feature-gate-target-resolution-research.md`
  - Prior art: `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/`
