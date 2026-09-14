# 2026-09-13-preimplementation-gate-worktree-selector (Spec)

- **Issue:** #671
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-13T22-10
- **Status:** Draft
- **Version:** 0.2

## Context
The issue #539 orchestration-bookkeeping staging exemption in
`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` models `git add` and
`git commit` as accepting no repository selector, so `git -C <worktree> add <exempt-pathspec>`
is denied. The exemption is therefore reachable only when the invoking shell's current working
directory is already the target worktree, which makes it unreachable from a coordinating
session in a parallel or epic topology.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (the gate is PowerShell only)
- Command/flags used: `git -C <worktree> add docs/features/epics/<epic>/epic.md`
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

During TaskMaster parallel run `bugs-2026-09-11` a rate limit terminated every agent mid-task.
Seven items' preparation output was uncommitted in child worktrees and the coordinating session
could not stage it, because every route to those worktrees required either a `cd` chain or a
`-C` selector. Recovery required messaging each surviving child individually.

This feature is F2 of the epic `worktree-scoped-state-resolution` (wave 0, complexity C3,
`depends_on: []`). It implements the epic's fix 4: "Make the staging exemption reachable from a
coordinating session."


## Repro & Evidence
Steps to Reproduce:
1. Open a coordinating session whose current working directory is the session root worktree.
2. Issue `git add -- docs/features/epics/worktree-scoped-state-resolution/epic.md` as a single
   unchained segment. The gate allows it.
3. Issue the same `git add` chained behind `cd <other-worktree> &&`. The gate denies it with
   `PREIMPLEMENTATION_GATE_BLOCKED`, because the chained `cd` segment is not a recognized
   all-exempt invocation.
4. Issue `git -C <other-worktree> add -- docs/features/active/<folder>/spec.md`. The gate denies
   it, because `Test-ExemptOrchestrationSegmentToken` requires `Token[1]` to be `add` or
   `commit` and `Token[1]` is `-C`.

Expected:
The exemption bounds *what* may be staged or committed, not *from where*. A repository selector
that names an explicit target directory should be permitted while every other constraint stays
in force: restricted pathspec prefixes, `-m` / `--message` as the only modelled option, and no
shell metacharacters.

Actual:
`git -C <worktree> add <exempt-pathspec>` is denied. `Test-ExemptOrchestrationSegmentToken`
enforces D4 row 14 — the command name leads the segment and the subcommand follows it
immediately — so any token between `git` and the subcommand rejects the segment. The comment on
that branch states the rejection is deliberate for "a relocating option", which is exactly the
`-C` form.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED` on a `cd <worktree> && git add -- docs/features/...`
  chain issued 2026-09-13 during epic planning for `worktree-scoped-state-resolution`, alongside
  an allow for the same `git add` issued as a single unchained segment.

Evidence status: the research artifact
`research/2026-09-13T21-15-preimplementation-gate-worktree-selector-671-research.md` records an
eight-row reproduction table for `Test-ExemptOrchestrationStagingCommand`. That table is a
**deterministic hand-trace with per-input terminating-line citations, not an executed run** — the
research session had no shell tool. Its values are **expectations to be confirmed**, not results.
An executed fail-before capture is a Phase 0 obligation of the plan; see `## Test Strategy`.


## Scope & Non-Goals
- In scope:
  - Widening exactly one axis of the issue #539 staging exemption: the **repository selector**
    that may appear between the command name `git` and the subcommand. The new rule is the
    research artifact's **Lexical Absolute-Canonical Selector (LACS)**, conditions L1 through L8,
    adopted verbatim.
  - Editing the prologue of `Test-ExemptOrchestrationSegmentToken` and adding one new predicate
    and one new constant in `enforce-orchestration-preimplementation-gate-helpers.ps1`, on **all
    four surface copies** of that file.
  - Table-driven Pester rows in the two existing command-exemption suites, plus one new
    surface-parity suite asserting SHA256 byte identity across the four helpers copies.
  - Recording the nested-subdirectory escape as an accepted, measured widening in the helpers
    file's comments, following the precedent record the gate file already carries at its lines
    101–110.
- Out of scope / non-goals:
  - **Worktree-set membership verification.** The selector is not required to resolve to the root
    of a worktree in this repository's worktree set, and no such check may be implemented. The
    exemption's invariant is a content-class invariant; membership is the wrong predicate, and a
    membership check evaluated from the hook process's own current working directory would
    reintroduce, inside the fix, the cwd-dependence the epic exists to eliminate.
  - **Any edit to the four gate files** (`enforce-orchestration-preimplementation-gate.ps1` on the
    four surfaces). The two Codex copies sit at exactly 500 lines with zero headroom.
  - **Any edit to the four modes files** (`enforce-orchestration-preimplementation-gate-modes.ps1`).
  - **Any edit to the shared git-option table in `hook-command-invocation.ps1`.** That file is
    dot-sourced by `.claude/hooks/enforce-epic-merge-gate.ps1`, so editing its option table would
    widen the epic-merge gate's matcher as a side effect. That is forbidden by the epic's
    Non-Goals and by the epic's RULING 1. The table may be cited as a cross-check for the option
    survey; it must not be edited and must not be consumed by this fix.
  - **Any Python.** Enforcement hooks in this repository are PowerShell or bash only. A Python leg
    would create a second implementation of the rule that drifts from the first.
  - **Any dependency on the epic's F1 target-worktree resolution module.** F2 declares
    `depends_on: []` and must add no import, no dot-source, and no call into `.claude/lib/`.
  - **Adding `enforce-orchestration-preimplementation-gate-modes.ps1` to the Codex shared-module
    name list** (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, the
    `$script:SharedModuleNames` array at line 30 — verified). That file is currently outside the
    Codex parse check, 500-line check, byte-identity check, and pack-manifest assertion. This is a
    pre-existing gap on a different axis; closing it would consume a test-file slot and widen the
    change beyond the one-axis rule. It is named as a follow-up candidate in
    `## Rollout & Follow-up`.
  - **Any change to the decision JSON, the deny reason strings, or the predicate's return shape.**
    `Test-ExemptOrchestrationStagingCommand` stays `[OutputType([bool])]` and stays allow-side
    only. The epic's "distinct, greppable reason code" NFR is satisfied on this site by
    `Write-Debug` diagnostic tokens emitted from the new predicate, which change no decision.
  - **Any new production file**, any pack-manifest edit, and any edit to
    `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` or its mirror. All four helpers
    copies that are measured are already listed in `CodeCoverage.Path`; the two bundled copies are
    published payload and are deliberately not measured.
- Explicitly excluded systems, integrations, or datasets:
  - The Codex `codex-pretooluse-file-mapping.ps1` mapping layer and the `apply_patch` file-marker
    scan that is unique to the Codex gate copies.
  - `enforce-epic-merge-gate.ps1`, `enforce-prd-feature-before-planner.ps1`,
    `enforce-pr-author-skill*.ps1`, and `enforce-model-routing-receipt.ps1` — the other epic sites.
  - The TypeScript `collect_pr_context` surface (epic F6) and the push-down/resume delivery
    (epic F7).
  - The `.claude/settings.json` registration surface. The gate's three PreToolUse matchers are
    unchanged.

## Root Cause Analysis
- `Test-ExemptOrchestrationSegmentToken` rejects any token between the command name and the
  subcommand, per D4 row 14. Verified by direct read: the rejecting branch is
  `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` **lines 230–236**. The
  `-C` form is rejected by the **second** conjunct, at **line 235**: for
  `git -C <dir> add ...` the tokenizer yields `[git, -C, <dir>, add, ...]`, so `$Token[1]` is the
  literal `-C`, which is neither `add` nor `commit`. The stated rationale is the comment at lines
  227–229: a relocating option "moves the pathspec base".
- Ordering consequence: the subcommand check runs **before** the modelled option table at lines
  253–274, so the `-C` form is rejected before that table is consulted. No existing code path can
  be widened by adding an entry to the option table; the fix must change the prologue of
  `Test-ExemptOrchestrationSegmentToken`.
- `Test-ExemptOrchestrationOperand` rejects rooted, drive-lettered, and UNC **operand** spellings
  (D4 row 16), so an absolute `-C` **selector** is not covered by the existing operand classifier
  and needs its own rule. The operand classifier itself is unchanged: an absolute *pathspec*
  operand still denies.

### Line-count correction (supersedes the epic manifest and the prior draft of this section)

Two line numbers carried by upstream documents are wrong, and a downstream reader who trusts them
will plan a helpers extraction that is not needed.

| Claim | Stated where | Re-verified value | Method |
| --- | --- | --- | --- |
| `…-gate-helpers.ps1` is 495 lines | `epic.md` line 218 | **349 lines**, on every surface | full read; the file ends at line 349 |
| `…-gate.ps1` is 495 lines | `epic.md` line 211 and the prior draft of this section | **496 lines** (Claude), **500 lines** (Codex) | line count of each file |

The 495/496 figure belongs to the **gate** file, not the helpers file. With the corrected number
the helpers file has **151 lines of headroom**, so **no helpers extraction is required** for F2.
The epic manifest's statement that "F2 … requires a helpers extraction as part of the change"
rests on the incorrect 495 premise and does not apply.

### Surface correction — four surfaces, not three

The prior draft of this section and the epic manifest describe three surfaces and nine files.
The research artifact establishes **four surfaces and twelve production copies** of the three-file
hook set, with independent primary and cross-check derivations recorded under its
`## Numeric Derivation Evidence` claim N2:

| # | Surface | Root |
| --- | --- | --- |
| 1 | Claude canonical | `.claude/hooks/` |
| 2 | Codex canonical | `.codex/hooks/` |
| 3 | Claude bundle | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` |
| 4 | Codex bundle | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` |

Surface 4 is omitted by both the epic manifest and the prior draft. It is governed by a
hash-binding contract test (verified:
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` lines 111–114 compare
`Get-FileHash` of `.codex/hooks/<name>` against the bundle copy), so omitting it fails CI.

### Line counts and headroom against the 500-line cap

| Surface | File | Lines | Headroom | Changed by F2? |
| --- | --- | --- | --- | --- |
| Claude canonical | `…-gate.ps1` | 496 (verified) | 4 | no |
| Claude canonical | `…-gate-helpers.ps1` | 349 (verified) | 151 | **yes** |
| Claude canonical | `…-gate-modes.ps1` | 480 | 20 | no |
| Claude bundle | `…-gate.ps1` | 496 | 4 | no |
| Claude bundle | `…-gate-helpers.ps1` | 349 | 151 | **yes** |
| Claude bundle | `…-gate-modes.ps1` | 480 | 20 | no |
| Codex canonical | `…-gate.ps1` | **500** (verified) | **0** | no |
| Codex canonical | `…-gate-helpers.ps1` | 349 | 151 | **yes** |
| Codex canonical | `…-gate-modes.ps1` | 477 | 23 | no |
| Codex bundle | `…-gate.ps1` | **500** | **0** | no |
| Codex bundle | `…-gate-helpers.ps1` | 349 | 151 | **yes** |
| Codex bundle | `…-gate-modes.ps1` | 477 | 23 | no |

The two Codex gate files have zero headroom. Under LACS they are not edited, so the zero-headroom
condition is never tested. Projected post-change helpers count is **approximately 404 lines**
(349 plus a ceiling estimate of about 55 lines: a constant block, one fully documented advanced
function, and the prologue absorption), leaving approximately **96 lines of headroom** — under the
500-line cap on all four copies. An implementation that would add more than roughly 150 lines is a
signal that the design has drifted beyond one axis and must be re-reviewed rather than split into a
new file.


## Proposed Fix

### Design summary (what changes where):

Adopt the **Lexical Absolute-Canonical Selector (LACS)** design. A single `-C <selector>` is
permitted between `git` and the subcommand when, and only when, the already-tokenized,
already-quote-stripped selector token satisfies all eight of the following purely lexical
conditions:

| # | Condition |
| --- | --- |
| L1 | The selector option is exactly the token `-C`, compared case-sensitively (`-ceq`), matching the existing case-sensitive posture at helpers lines 230, 234, 246, and 260. |
| L2 | `-C` appears at token index 1 (immediately after `git`) and at most once in the segment. |
| L3 | A value token exists at index 2 and the subcommand is at index 3. |
| L4 | After `\` to `/` normalization, the value matches `^[A-Za-z]:/` or `^/` and does **not** start `//`. |
| L5 | No path segment of the normalized value is `..` or `.`. |
| L6 | The value contains no character from `$script:PathspecWildcardCharacters` (`*`, `?`, `[`). |
| L7 | The value contains no `:` other than the drive colon at index 1. |
| L8 | The value is non-empty. |

**The reasoning, stated plainly.** The issue #539 exemption exists to bound *what* may be staged,
not who stages it. Its invariant is a content class: every pathspec operand must resolve inside one
of five orchestration-bookkeeping trees. That invariant is already indifferent to who runs the
command and when; the correct extension is that it is also indifferent to *from where*. A selector
naming some other directory — even a directory in a different repository — cannot introduce
implementation content into a governed repository, because the operand class is unchanged. What
must deny is therefore not a selector that points somewhere unexpected, but a selector that is
**undecidable from the hook payload**. The Bash leg of this gate reads exactly one field, the
`command` string; it has no current-working-directory input. A relative, `..`-bearing, empty,
repeated, UNC, or globbed selector cannot be resolved from that string at all, and D3 of the #539
specification makes undecidable equal deny. L1 through L8 are precisely the conditions under which
the selector is decidable from the payload alone.

Everything after the subcommand is unchanged: the modelled option table, the `--` separator
handling, operand collection, the all-operands-exempt loop, and the repo-relative prefix test.
Exactly one function body changes — the prologue of `Test-ExemptOrchestrationSegmentToken` — plus
one new predicate and one new constant.

### Boundaries and invariants to preserve:

- **INV-1 — Helpers purity.** The helpers module's declared contract at its lines 5–10 must
  survive **verbatim**: "Pure string logic only: no disk, process, network, or environment access…
  Every parse ambiguity answers false." No subprocess (`git worktree list` or any other), no
  filesystem probe (`Test-Path`, `Get-Item`, `Resolve-Path`), no environment read (`$env:`), and no
  `Invoke-Expression` may be introduced. The sibling `-modes.ps1` file was created for issue #554
  specifically so this contract would not have to be repealed; repealing it here would contradict
  that rationale.
- **INV-2 — Single-axis change.** D4 rows 1–13 and 15–19 are unchanged in text and in behavior.
  Only row 14's disposition narrows, from "every relocating spelling is NEVER EXEMPT" to "every
  relocating spelling except a lexically-resolvable single `-C` selector is NEVER EXEMPT".
- **INV-3 — Allow-side, boolean-only predicate.** `Test-ExemptOrchestrationStagingCommand` keeps
  `[OutputType([bool])]`. A `$false` result restores the caller's unchanged classification and
  never suppresses the trigger. The decision JSON and all three
  `PREIMPLEMENTATION_GATE_BLOCKED` reason literals are byte-unchanged, including the phrases
  `route metadata` and `lifecycle readiness` that existing suites assert.
- **INV-4 — Gate and modes files untouched.** The four gate files and four modes files are not
  edited by this feature. This is load-bearing because the two Codex gate files are at exactly the
  500-line cap.
- **INV-5 — Shared parser untouched.** `hook-command-invocation.ps1` and its git global-option
  table are neither edited nor consumed, so the epic-merge gate's matcher cannot be widened as a
  side effect.
- **INV-6 — Chaining semantics unchanged.** The all-segments rule
  (`Test-ExemptOrchestrationStagingCommand`, helpers lines 342–347) stays byte-unchanged. LACS is
  evaluated per segment.
- **INV-7 — Surface parity.** All four `-helpers.ps1` copies stay byte-identical to one another
  after the change.

### Dependencies or blocked work:

- None. F2 declares `depends_on: []`. LACS adds no module import, no dot-source, no call into
  `.claude/lib/`, and no new file.
- If the epic's F1 resolution module later ships, the LACS rule composes with it upstream without
  a schema change — the same posture D4 row 16 already takes toward issue #516 (helpers lines
  176–177).

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

Production PowerShell (4 files — one per surface, identical content):

1. `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
2. `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
3. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

Test PowerShell (3 files):

1. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` (modified)
2. `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (modified)
3. `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` (new; follows the existing `*.Parity.Tests.ps1` convention used by `CodexDeployment.Parity.Tests.ps1` and `ModelRouting.Parity.Tests.ps1`)

No other production or test file is edited. In particular: no gate file, no modes file, no
`hook-command-invocation.ps1`, no pack manifest, no runsettings file, and no Python file.

#### Functions/classes/CLI commands impacted:

| Element | File | Kind | Estimated size |
| --- | --- | --- | --- |
| `$script:OrchestrationSelectorOptionName` plus a short comment block | `-helpers.ps1` | new constant | about 6 lines |
| `Test-ExemptOrchestrationSelector` — the L1–L8 predicate, `[CmdletBinding()]`, `[OutputType([bool])]`, comment-based help citing D4 row 14 and this spec | `-helpers.ps1` | new advanced function | about 35 lines |
| `Test-ExemptOrchestrationSegmentToken` — selector absorption in the prologue, between the current lines 232 and 233 | `-helpers.ps1` | modified | about 14 changed or added lines |
| `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand` | `-helpers.ps1` | **unchanged** | 0 |
| `$script:OrchestrationBookkeepingTrees`, `$script:UnresolvableCommandCharacters`, `$script:PathspecWildcardCharacters` | `-helpers.ps1` | **unchanged** | 0 |
| Everything in `-gate.ps1` and `-modes.ps1` | — | **unchanged** | 0 |

#### Data flow and validation changes:

The Bash payload path is unchanged end to end. `Invoke-OrchestrationPreimplementationGateDecision`
reads the `command` field, the trigger regex matches, and index 0 consults
`Test-ExemptOrchestrationStagingCommand`. Inside that predicate the line is split into segments,
each segment is tokenized, and each token array is passed to
`Test-ExemptOrchestrationSegmentToken`. The only new step is inside that last function: when
`$Token[1]` is `-C`, the segment is offered to `Test-ExemptOrchestrationSelector`; if all eight
conditions hold, the subcommand index advances by two and parsing continues exactly as before;
otherwise the function returns `$false` as it does today.

Operand validation is untouched. A relative operand is still prefix-tested against the five exempt
trees; an absolute operand still denies under D4 row 16 even when an absolute selector is present.

#### Error handling and logging updates:

The predicate remains boolean and emits no reason string. To satisfy the epic NFR "every ambiguity
denies with a distinct, greppable reason code" without changing the decision JSON, the new
predicate emits `Write-Debug` diagnostic tokens. `Write-Debug` is already used in this hook set for
this purpose (`-modes.ps1` line 94), is silent at normal verbosity, and is neither disk, process,
network, nor environment access, so INV-1 is preserved.

| Token | Emitted when | LACS condition |
| --- | --- | --- |
| `PREIMPL_SELECTOR_UNMODELLED_OPTION` | a token between `git` and the subcommand that is not exactly `-C` | L1 |
| `PREIMPL_SELECTOR_REPEATED` | more than one `-C` in the segment | L2 |
| `PREIMPL_SELECTOR_MALFORMED` | `-C` with no value token, the subcommand not immediately after the value, or an empty value | L3, L8 |
| `PREIMPL_SELECTOR_NOT_ROOTED` | the value is relative or is a UNC spelling | L4 |
| `PREIMPL_SELECTOR_TRAVERSAL` | the value carries a `..` or `.` segment | L5 |
| `PREIMPL_SELECTOR_NOT_LITERAL` | the value carries a wildcard or a stray colon | L6, L7 |

These tokens are diagnostic, not contractual. Tests must assert the **decision**, never the debug
text.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. The change is a single-axis widening of a pure classifier on four copies of one
file; rollback is a revert of the commit. Adding a runtime flag would require reading configuration
or environment state inside the helpers module, which INV-1 forbids.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `Test-ExemptOrchestrationSelector -Token <string[]>` (exact parameter naming is an
  implementation choice; it must be a named parameter with `[Parameter(Mandatory)]`) returns
  `[bool]`. It performs no I/O.
- `Test-ExemptOrchestrationSegmentToken -Token <string[]>` returns `[bool]`. Signature unchanged.
- `Test-ExemptOrchestrationStagingCommand -CommandText <string>` returns `[bool]`. Signature and
  contract unchanged.
- The gate's decision JSON shape, `permissionDecision` values, and `permissionDecisionReason`
  literals are unchanged.

#### Required configuration keys and defaults:

None. No new configuration key, no settings entry, no manifest entry, no runsettings entry.

#### Backward-compatibility expectations:

- **Every command line that is allowed today stays allowed.** LACS only adds an accepting path; it
  removes none. The eight existing allow fixtures in each command-exemption suite are unmodified
  and must still pass.
- **Every command line that is denied today stays denied, except the LACS-conforming `-C` form.**
  All 45 existing deny fixtures in each suite are unmodified and must still pass, including the
  three D4 row 14 fixtures: `git -C ../other add …` (relative selector), `git --git-dir=… commit …`,
  and `git --work-tree=… add …`. The research artifact establishes that the only existing `-C`
  fixture uses a relative selector, so **zero assertion reversals** are required.
- **Chained segments are permitted (settled ruling).** LACS is applied per segment and the
  all-segments rule is byte-unchanged, so
  `git -C C:/repo/wt add -- docs/features/active/x/spec.md && git -C C:/repo/wt commit -m "msg" -- docs/features/active/x/spec.md`
  **allows**. The rationale is that this feature widens exactly one axis; introducing a new
  single-segment restriction would itself be a change to an axis that must be left alone, and it
  would make the selector rule inconsistent with the rest of the D4 table for no safety gain.
- **A `cd` chain still denies.** `cd C:/repo/wt && git add -- docs/features/active/x/spec.md`
  **denies**, because `cd` is not a recognized segment: the first segment tokenizes to
  `[cd, C:/repo/wt]` and fails the `$Token[0] -cne 'git'` test at helpers line 230.

#### Performance constraints (latency/throughput/memory):

The gate runs as a `pwsh -NoProfile` process on three PreToolUse matchers (Bash, `Write|Edit`, and
`Agent`), so it executes before every governed tool call. LACS adds only in-memory string
comparisons on segments that already tokenize, and adds no process start, no filesystem access,
and no allocation beyond the token array that already exists. Measurable added latency is expected
to be negligible. A design that added a `git worktree list` subprocess would put a second process
start plus repository discovery on every governed tool call and is excluded for that reason among
others.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The hook receives only the `command` string on the Bash leg. There is no current-working-directory
    field in the payload, so no cwd-dependent rule is implementable at this site.
  - Git's documented spelling of the selector is space-separated `-C <path>`; the manual documents
    no attached `-C<path>` form. This was not verified by execution. LACS denies the attached form
    either way, which is fail-closed regardless of git's actual behavior, so the residual
    uncertainty does not affect the design.
  - Repeated `-C` composes per the manual (a non-absolute second path is resolved relative to the
    first), which is the ambiguity L2 excludes.
- Constraints (budget, performance, compatibility):
  - **Enforcement hooks are PowerShell or bash only. No Python leg, ever** — a second
    implementation of the rule drifts from the first.
  - **No file may exceed 500 lines.** Projected helpers count after the change is about 404.
  - **Tests live under `tests/` mirroring the production structure. Colocation is prohibited.**
  - **Line coverage must remain at or above 85%.** Pester does not measure branch coverage, so no
    branch-coverage gate applies to PowerShell; the PowerShell production files nevertheless remain
    in the coverage denominator.
  - **PowerShell per-batch cap: 3 production files and 3 test files.** This change touches
    **4 production `.ps1` files** and **3 test `.ps1` files**, so **exactly one batch-budget reset
    point is required** on the production side (between the third and fourth helpers edit) and
    **none** on the test side. The plan must schedule that reset explicitly; the batch-budget hook
    denies the fourth production file with a message naming the state file to delete.
  - PowerShell 7+ compatibility; PSScriptAnalyzer clean with repository settings.
- External dependencies (services, libraries, releases):
  - None. No new package, no new module, no network access at hook time.

## Data / API / Config Impact
- User-facing or API changes: none. The hook's decision JSON schema, `permissionDecision` values,
  and reason strings are unchanged. The observable behavior change is that one previously denied
  command form is now allowed.
- Data or migration considerations: none. No checkpoint schema field is added, read, or written.
- Logging/telemetry updates (if any): six new `Write-Debug` diagnostic tokens, listed above.
  They are silent at normal verbosity and are explicitly non-contractual.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag, no config schema, no
  version bump. The four bundled-payload copies must be updated in the same change so the push-down
  publishes the new content rather than stale content.

## Test Strategy

The gate is session-agnostic: `Invoke-OrchestrationPreimplementationGateDecision` accepts only
`ToolInputRaw`, `CheckpointRaw`, `EpicCheckpointRaw`, and `ParallelCheckpointRaw`, and the Bash leg
reads only the `command` field. There is no current-working-directory input to vary. The epic's
required cross product is therefore **re-expressed** at this site, without losing any row:

| Epic axis | Re-expression at this site |
| --- | --- |
| **cwd** (session root vs item worktree) | selector **absent** (equivalent to cwd = target) vs selector **present** (equivalent to cwd is not the target) |
| **path form** (relative vs absolute) | **selector** form: absolute vs relative vs `..`-bearing vs `.`-bearing vs UNC vs empty vs repeated vs globbed vs attached. The **operand** form stays repo-relative on every row, because D4 row 16 is unchanged and an absolute operand still denies; one deny row pins that. |
| **target** (own item / sibling / absent) | selector naming the own item worktree root / a sibling item worktree root / a directory that is not a worktree at all. All three are lexically indistinguishable and must produce the same decision; the rows remain in the table as explicit pins of that fact. |

### Envelope construction (the pattern new rows must follow)

The Claude command-exemption suite defines three helpers inside `BeforeAll`
(lines 20–60) and the Codex suite mirrors them with a `$script:RepoRoot` / `Join-Path` resolution
at its lines 23–25. New rows must reuse these helpers rather than introducing a new arrangement:

- `ConvertTo-ExemptionCommandPayload` builds
  `@{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5`.
- `ConvertTo-NotReadyCheckpointRaw` builds an explicitly **not-ready** checkpoint
  (`route_id = ''`, `lifecycle_ready = $false`), so any `allow` must come from the exemption alone.
- `Get-ExemptionDecisionForCommand` is the single Act step.

No disk I/O, no child process, and no temporary file. This satisfies the repository's prohibition
on temporary files in tests and its determinism requirements.

### Matrix — new rows

Added as two new `Context` blocks per suite, using the existing `-ForEach` table-driven shape
(`It 'allows <Label>'` and `It 'denies <Label>'`). The label text is part of the contract, because
the acceptance criteria key on the expanded node names. The same 24 rows are added to both suites.

Context `issue #671 worktree selector allow cases` — 7 rows, all NEW:

| Label | Command | Expected |
| --- | --- | --- |
| `issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand` | `git -C C:/repo/wt add -- docs/features/active/x/spec.md` | allow |
| `issue #671 LACS allow 2 - POSIX-rooted absolute selector on the add subcommand` | `git -C /repo/wt add -- docs/features/active/x/spec.md` | allow |
| `issue #671 LACS allow 3 - backslash-spelled absolute selector normalized before the rooting test` | `git -C C:\repo\wt add -- docs/features/active/x/spec.md` | allow |
| `issue #671 LACS allow 4 - absolute selector on the message-bearing commit form` | `git -C C:/repo/wt commit -m "epic scaffold" -- docs/features/active/x/spec.md` | allow |
| `issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector` | `git -C C:/repo/wt add -- docs/features/active/x/spec.md && git -C C:/repo/wt commit -m "epic scaffold" -- docs/features/active/x/spec.md` | allow |
| `issue #671 LACS allow 6 - absolute selector naming a sibling item worktree root` | `git -C C:/repo/wt-sibling add -- docs/features/active/y/spec.md` | allow |
| `issue #671 LACS allow 7 - absolute selector naming a directory outside every worktree` | `git -C C:/elsewhere add -- docs/features/active/x/spec.md` | allow |

Context `issue #671 worktree selector deny cases` — 17 rows, all NEW:

| Label | Command | Expected |
| --- | --- | --- |
| `issue #671 LACS L1a - attached selector spelling` | `git -CC:/repo/wt add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L1b - config-injection selector` | `git -c core.worktree=C:/repo/wt add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L2 - repeated selector` | `git -C C:/repo/wt -C C:/repo/other add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L3a - selector with no subcommand after the value` | `git -C C:/repo/wt` | deny |
| `issue #671 LACS L3b - subcommand not immediately after the selector value` | `git -C C:/repo/wt -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L4a - bare relative selector` | `git -C subdir add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L4b - UNC selector` | `git -C //server/share/wt add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L5a - parent-directory segment in the selector` | `git -C C:/repo/wt/../other add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L5b - current-directory segment in the selector` | `git -C C:/repo/./wt add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L6 - wildcard in the selector` | `git -C C:/repo/wt-? add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L7 - stray colon in the selector` | `git -C C:/repo/wt:branch add -- docs/features/active/x/spec.md` | deny |
| `issue #671 LACS L8 - empty selector value` | `git -C "" add -- docs/features/active/x/spec.md` | deny |
| `issue #671 selector with a non-exempt pathspec operand` | `git -C C:/repo/wt add -- scripts/powershell/Sample.ps1` | deny |
| `issue #671 selector with the tree-wide all flag` | `git -C C:/repo/wt add -A` | deny |
| `issue #671 selector with an absolute pathspec operand` | `git -C C:/repo/wt add -- C:/repo/wt/docs/features/active/x/spec.md` | deny |
| `issue #671 selector with an output redirection` | `git -C C:/repo/wt add -- docs/features/active/x/spec.md > staged.txt` | deny |
| `issue #671 cd chain into the target worktree` | `cd C:/repo/wt && git add -- docs/features/active/x/spec.md` | deny |

The wildcard row uses `?` rather than `*` deliberately: `*` is also a wildcard on the operand side
and the row must isolate the selector axis.

### Matrix — existing rows retained as REGRESSION GUARDS

These rows already exist and must be **retained unmodified, not dropped as redundant**. Their file
positions are recorded so a reviewer can confirm they were not rewritten.

| Guard | Claude suite | Codex suite |
| --- | --- | --- |
| Eight allow cases covering all five exempt trees, the quoted form, the backslash form, the `-m … --` integration form, and a chained all-exempt line | `It` nodes at lines 64–158 | mirrored at lines 68–162 |
| Mixed exempt-plus-production operand deny set | `It 'denies an exempt operand paired with a <Extension> production operand'`, line 165 | line 169 |
| The full D4 fail-closed deny table, 45 `-ForEach` rows under `It 'denies <Label>'` | lines 188–233 | lines 192–237 |
| D4 row 14a / 14c / 14d (env-style prefix, `--git-dir`, `--work-tree`) — must stay deny, **no assertion reversal** | lines 222, 224, 225 | lines 226, 228, 229 |
| D4 row 14b — the relative `-C ../other` chain — must stay deny | line 223 | line 227 |
| Residual whole-command-text behavior (D3 and D8) | `It` nodes at lines 246 and 275 | lines 250 and 281 |

### Surface parity and untouched-file assertions

New suite
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`:

- `It 'keeps all four surface copies of the helpers module byte-identical by SHA256 hash'` —
  compares `(Get-FileHash -LiteralPath <path>).Hash` across the four `-helpers.ps1` paths and
  asserts a single distinct value. A real hash is required here: the current assertions would not
  catch a divergence that is invisible in decoded text. The Codex pair is already hash-asserted by
  `legacy-codex-hook-contracts.Tests.ps1` line 111, but the Claude pair is only **text**-asserted by
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` line 140, which decodes as
  UTF-8 and would not detect a byte-order-mark or line-ending difference.
- `It 'keeps every surface copy of the helpers module under the 500-line cap'` — asserts
  `(Get-Content -LiteralPath <path>).Count` is at most 500 for each of the four copies, mirroring
  the expression the existing Codex contract test uses at line 106.

The assertion that **the four gate files and four modes files are unchanged by this feature** is a
property of the change, not a durable invariant, so it is verified by diff rather than by a unit
test. See the acceptance criteria.

### Fail-before and pass-after evidence (Phase 0 obligation)

The research artifact's eight-row reproduction table is a hand-trace, **not an executed run**. The
plan's **Phase 0** must execute it and capture the output before any production edit. The capture
is written to the canonical location
`docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/`
and must carry `Timestamp:`, `Command:`, and `EXIT_CODE:` per the evidence conventions. The
hand-traced values below are **expectations to be confirmed by that run**, not results.

Invocation (one PowerShell session, read-only, no residue; the helpers file declares constants and
functions only, so dot-sourcing it executes nothing):

```powershell
# Run from the worktree root.
. .\.claude\hooks\enforce-orchestration-preimplementation-gate-helpers.ps1
@(
  'git add -- docs/features/active/x/spec.md'
  'git -C C:/some/worktree add -- docs/features/active/x/spec.md'
  'git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md'
  'git add -A -- docs/features/active/x/spec.md'
  'git add -- src/foo.ts'
  'cd C:/some/worktree && git add -- docs/features/active/x/spec.md'
  'git add -- docs/features/active/x/spec.md | tee out.txt'
  'git add -- "docs/features/active/x/spec.md'
) | ForEach-Object {
  [pscustomobject]@{
    Command = $_
    Result  = Test-ExemptOrchestrationStagingCommand -CommandText $_
  }
} | Format-Table -AutoSize
```

| # | Input | Expected before the fix | Expected after the fix |
| --- | --- | --- | --- |
| 1 | `git add -- docs/features/active/x/spec.md` | `True` | `True` (unchanged) |
| 2 | `git -C C:/some/worktree add -- docs/features/active/x/spec.md` | `False` | **`True`** |
| 3 | `git -C C:/some/worktree commit -m "msg" -- docs/features/active/x/spec.md` | `False` | **`True`** |
| 4 | `git add -A -- docs/features/active/x/spec.md` | `False` | `False` (unchanged) |
| 5 | `git add -- src/foo.ts` | `False` | `False` (unchanged) |
| 6 | `cd C:/some/worktree && git add -- docs/features/active/x/spec.md` | `False` | `False` (unchanged) |
| 7 | `git add -- docs/features/active/x/spec.md \| tee out.txt` | `False` | `False` (unchanged) |
| 8 | `git add -- "docs/features/active/x/spec.md` | `False` | `False` (unchanged) |

Rows 2 and 3 are the fail-before rows the acceptance criteria cite. Rows 1 and 4–8 must return the
same value before and after.

### Coverage

The helpers file is already an explicit entry in `CodeCoverage.Path` on both surfaces
(`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), so no runsettings edit is required
and the changed lines are inside an already-measured file. The runsettings sets
`CoveragePercentTarget = 0`, so the 85% threshold is a policy gate evaluated against the emitted
report rather than enforced by the runner; the numeric value must therefore be captured and
recorded rather than assumed. Pester reports command and line coverage only; branch coverage is not
measurable for PowerShell and no branch-coverage gate applies.

### Toolchain

Run in order and restart from step 1 on any failure or auto-fix, per the repository's mandatory
loop: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` →
`mcp__drm-copilot__run_poshqc_test`. Type checking is not applicable to PowerShell. The Python
push-down contract tests are run as part of the verification set even though no Python file is
edited, because they assert the bundle parity this change depends on.

### Manual validation

After the toolchain passes, execute the pass-after capture described above and diff it against the
Phase 0 fail-before capture. No manual step substitutes for an executed capture.


## Acceptance Criteria
- [ ] The seven `issue #671 LACS allow` rows all pass in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`, under `Context 'issue #671 worktree selector allow cases'`, verified by a Pester run listing node `allows issue #671 LACS allow 1 - drive-letter absolute selector on the add subcommand` as Passed.
- [ ] The same seven allow rows, with identical label text, all pass in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
- [ ] The chained-segment allow is pinned: node `allows issue #671 LACS allow 5 - chained add and commit segments each carrying the same absolute selector` passes in both command-exemption suites.
- [ ] The `cd`-chain denial is pinned: node `denies issue #671 cd chain into the target worktree` passes in both command-exemption suites.
- [ ] Each LACS condition L1 through L8 has at least one deny row in both suites, and all of them pass: `Select-String -SimpleMatch` for each of the tokens `LACS L1a`, `LACS L1b`, `LACS L2`, `LACS L3a`, `LACS L3b`, `LACS L4a`, `LACS L4b`, `LACS L5a`, `LACS L5b`, `LACS L6`, `LACS L7`, and `LACS L8` returns at least one line in each suite file, and the Pester run reports every matching node as Passed.
- [ ] The pathspec, option, and metacharacter restrictions are not weakened (epic must-not-regress). Nodes `denies issue #671 selector with a non-exempt pathspec operand`, `denies issue #671 selector with the tree-wide all flag`, `denies issue #671 selector with an absolute pathspec operand`, and `denies issue #671 selector with an output redirection` pass in both suites.
- [ ] No existing assertion is reversed. `git diff --merge-base main -- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` contains no removed content line (a line beginning with a single `-` that is not the `---` file header), and all 45 pre-existing `D4 row` deny rows plus all eight pre-existing allow rows in each suite report Passed.
- [ ] The four gate files are byte-unchanged: `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` produces empty output.
- [ ] The four modes files are byte-unchanged: the same `git diff --merge-base main` command run against the four `enforce-orchestration-preimplementation-gate-modes.ps1` paths produces empty output.
- [ ] The epic-merge gate's matcher is not widened (epic must-not-regress). `git diff --merge-base main -- .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 .claude/hooks/enforce-epic-merge-gate.ps1` produces empty output, and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` and `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` both pass.
- [ ] The helpers diff is confined to one axis: in `git diff --merge-base main -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, every removed content line's text occurs within the pre-change lines 227–236 block, and no hunk removes or modifies a line inside `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationStagingCommand`, or the three pre-existing `$script:` constant blocks.
- [ ] Gates still deny when a required document is genuinely absent (epic must-not-regress). Nodes `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` and `blocks an implementation write when the checkpoint omits the feature folder` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` both pass.
- [ ] Epic and standalone topologies behave exactly as now when cwd and target coincide (epic must-not-regress). Nodes `allows staging an epic document under the epics tree` and `allows a chained two-segment line whose every segment is independently exempt` pass unmodified in both command-exemption suites, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` all pass with zero failures.
- [ ] Node `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` in the new suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` passes, comparing `Get-FileHash` output across all four `-helpers.ps1` paths.
- [ ] Bundled-payload mirroring is complete. `git diff --merge-base main --name-only` lists all four `enforce-orchestration-preimplementation-gate-helpers.ps1` paths (the two canonical and the two bundled), node `keeps the canonical hooks byte-identical to their bundled copies` in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [ ] No file exceeds the 500-line cap. Node `keeps every surface copy of the helpers module under the 500-line cap` passes, the post-change line count of each of the four helpers copies is recorded in the QA-gate evidence artifact, and the existing Codex 500-line contract assertion in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` passes.
- [ ] An **executed** fail-before capture exists at `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/regression-testing/`, produced before any production edit, carrying `Timestamp:`, `Command:`, and `EXIT_CODE:` fields and the eight-row result table, with rows 2 and 3 recorded as `False`. A hand-trace does not satisfy this criterion.
- [ ] An **executed** pass-after capture exists at the same canonical evidence location, with rows 2 and 3 recorded as `True` and rows 1, 4, 5, 6, 7, and 8 identical to the fail-before capture.
- [ ] Line coverage is at or above 85% for the PowerShell coverage run, with the numeric percentage recorded in a QA-gate evidence artifact under `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/qa-gates/`, and coverage on the changed lines of the helpers file does not regress. Pester does not measure branch coverage, so no branch-coverage gate applies to PowerShell.
- [ ] The full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format` reports no file changed on a second invocation, `mcp__drm-copilot__run_poshqc_analyze` reports zero findings for the four edited helpers copies and the three test files, and `mcp__drm-copilot__run_poshqc_test` reports zero failed tests.
- [ ] No Python leg is introduced: `git diff --merge-base main --name-only` contains no path ending in `.py`.
- [ ] The change adds no new production file and no F1 dependency: `git diff --merge-base main --name-only` lists exactly four production `.ps1` paths, all of them `enforce-orchestration-preimplementation-gate-helpers.ps1`, and `Select-String -SimpleMatch 'Import-Module'` over those four files returns no line.
- [ ] The helpers module's declared purity survives: `Select-String -SimpleMatch 'Pure string logic only: no disk, process, network, or environment access'` returns exactly one line in each of the four helpers copies, and `Select-String -SimpleMatch` for each of `git worktree`, `Test-Path`, `Start-Process`, `Resolve-Path`, `Invoke-Expression`, and `env:` returns no line in any of the four copies.
- [ ] The nested-subdirectory widening is recorded in the helpers file: `Select-String -SimpleMatch 'Accepted widening'` returns at least one line in each of the four helpers copies, and the surrounding comment states the measured exposure (seven Markdown test fixtures under the `resolve_execute_plan_prompt` fixture tree) and notes that the epic's F1 resolution module composes upstream to close it later without a schema change.

## Risks & Mitigations
- Technical or operational risks:
  - **Central risk — inadvertent narrowing or widening of an axis other than the selector.** The
    D4 table has nineteen rows and this change is entitled to move exactly one. A regression on any
    other row either re-blocks legitimate orchestration bookkeeping (narrowing) or admits
    implementation content past a fail-closed gate (widening). Widening is the more serious mode,
    because it produces no visible failure.
  - **Accepted widening — the nested-subdirectory escape.** A `-C` naming a nested subdirectory
    inside a worktree passes LACS lexically while relocating what a relative operand denotes:
    `docs/features/active/X` under `-C <root>/tests/fixtures/resolve_execute_plan_prompt` resolves
    to `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/X`. This is the only case
    that both passes a purely lexical constraint and changes the operand's repository-relative
    meaning.
  - **Surface drift.** Four copies of one file must stay byte-identical. An edit applied to three
    of four publishes stale content at the push-down surface and fails the Codex hash contract.
  - **Batch-budget interruption.** The production file count (4) exceeds the per-batch cap (3), so
    the fourth edit will be denied unless a reset is scheduled. An unplanned denial mid-change is
    the most likely cause of a partially applied edit, which is the surface-drift risk above.
- Mitigations and rollbacks:
  - **Against the central risk:** the claim that every other axis is unchanged is made **provable
    by diff, not asserted in prose**. Four acceptance criteria are diff-based — the four gate files
    empty, the four modes files empty, the shared parser and merge gate empty, and the helpers diff
    confined to the pre-change 227–236 block — and a fifth requires the two test suites' diffs to be
    additive only, with no removed content line. A reviewer can fail any of these mechanically.
    Behaviorally, all 45 pre-existing deny rows and all eight pre-existing allow rows in each suite
    are retained as regression guards and must pass unmodified; the research establishes that zero
    assertion reversals are required, so any reversal a reviewer encounters is a defect signal.
  - **Against the accepted widening:** it is accepted and recorded, not silently absorbed. Its
    exposure is measured at seven Markdown files under
    `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/`, every one of which the
    gate's own `file_path` leg already classifies as non-implementation, because
    `Test-ImplementationPath` matches only `.py`, `.ps1`, `.psm1`, `.ts`, `.tsx`, `.js`, `.jsx`,
    `.cs`, `.json`, `.yml`, and `.yaml`, and `.md` is absent. Staging those files through a nested
    selector therefore grants nothing the gate withholds elsewhere. The record follows the
    precedent the gate file already carries for an accepted widening of the same shape at its lines
    101–110. The epic's F1 resolution module composes upstream to close the escape later without a
    schema change, in the same way D4 row 16 was written to compose with issue #516.
  - **Against surface drift:** a new SHA256-based parity assertion covers all four copies, closing
    the gap that the existing decoded-text assertions leave open for byte-order-mark and
    line-ending divergence.
  - **Against batch-budget interruption:** the spec records the file counts (4 production, 3 test)
    and states that exactly one production-side reset point is required; the plan schedules it
    between the third and fourth helpers edit.
  - **Rollback:** revert the single commit. There is no schema change, no configuration key, and no
    persisted state, so revert is complete and immediate. The pre-change behavior is the denial the
    issue reports.

## Rollout & Follow-up
- Release/rollout steps:
  1. Land the four helpers edits and three test files on the feature branch, with the one scheduled
     batch-budget reset.
  2. Full PowerShell toolchain pass plus the two Python push-down contract tests.
  3. Merge into the epic integration branch `epic/worktree-scoped-state-resolution-integration`.
  4. Delivery to consumer repositories is **not** part of F2. The extension rebuild, reinstall, and
     push-down belong to epic feature F7 (`taskmaster-push-down-and-resume`). F2's obligation is
     only that the two bundled copies are updated in this change, so F7 publishes current content.
- Post-fix monitoring or clean-up tasks:
  - Confirm, during the next parallel or epic run, that a coordinating session can stage and commit
    exempt pathspecs in a child worktree with `git -C`. This is an epic-level acceptance criterion,
    observed at F7 time.
  - **Follow-up candidate (not filed, not in F2 scope):** upstream closure of the
    nested-subdirectory escape once the epic's F1 target-worktree resolution module exists. F1
    composes upstream of LACS and can reject a selector that is not a worktree root without any
    change to the LACS schema or to the helpers module's purity contract.
  - **Follow-up candidate (not filed, not in F2 scope):** add
    `enforce-orchestration-preimplementation-gate-modes.ps1` to `$script:SharedModuleNames` in
    `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. That file is listed in the
    Codex `core.json` pack manifest but is currently outside the Codex parse check, 500-line check,
    byte-identity check, and pack-manifest assertion. This is a pre-existing gap on a different
    axis.
  - **Open verification item, non-blocking:** whether git accepts the attached spelling `-C<dir>`.
    The manual documents only the space-separated form. LACS denies the attached form either way,
    so this affects documentation accuracy only.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/671
  - Epic manifest: `docs/features/epics/worktree-scoped-state-resolution/epic.md` (F2)
  - Research: `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/research/2026-09-13T21-15-preimplementation-gate-worktree-selector-671-research.md`
  - Normative rule table (D4): `docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md`
