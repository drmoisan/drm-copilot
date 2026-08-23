# 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths (Spec)

- **Issue:** #502
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-22T23-40
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (this document is the sole acceptance-criteria source; `user-story.md` is intentionally absent per `.claude/skills/feature-promotion-lifecycle/SKILL.md`)

## Token-Hygiene Note For This Document

`derive_blast_radius` harvests inline-code tokens from `spec.md` as well as from the plan. A
placeholder example written inside backticks in this document would therefore be admitted into this
item's own declared radius by the pre-fix classifier and would make this item contend spuriously
with the twelve other plans that cite the same token. Every placeholder example below is therefore
rendered either inside a fenced block or as backslash-escaped prose, never inside an inline-code
span. Inline-code spans in this document are reserved for paths this item genuinely writes or for
identifiers that carry no path separator. Read-only references to high-contention files are written
without backticks for the same reason.

## Context

The blast-radius extractor admits placeholder and interpolation tokens as if they were real
repository paths. A token such as \<FEATURE\>/spec.md documents a path *shape*; it is not a write
claim. Because a `path_overlap` edge requires only string-level agreement between two radii, every
pair of plans that restates the same placeholder conflicts, inflating the parallel conflict graph and
suppressing concurrency that should be available.

The defect is present in both runtimes of the extractor: `scripts/dev_tools/_blast_radius_extraction.py`
(`classify_path_token`) and `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (`Get-PathTokenKind`).
Each applies three shape rules — reject a wildcard-free token whose final component names a directory,
reject a `docs/features/` glob whose wildcard truncates the feature-folder segment, reject a contract
token carrying no ASCII letter — and neither applies a placeholder rule.

The asymmetry with the sibling rule set is the stated motivation. `.claude/rules/plan-acceptance-gates.md`
already defines a placeholder guard for acceptance-gate search literals over exactly the marker set
`<`, `>`, `${`, `$(`, `%`, and records a preflight measurement justifying it. The blast-radius
extractor does not apply that guard, so the two subsystems disagree about whether a placeholder is
real. This fix makes them agree by reusing the same marker set rather than inventing a second one.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- PowerShell 7.6.5; Python via Poetry (both runtimes in scope)
- Entry points exercised: `Get-BlastRadius`, `Test-BlastRadiusConflict` from `.claude/lib/blast-radius/BlastRadius.psm1`; `derive_blast_radius`, `conflicts` from `scripts/dev_tools/compute_blast_radius.py`
- Data source or fixture: first reproduced in the destination repository `drmoisan/TaskMaster` at `b9a9b92c`; independently confirmed present in this repository in both runtimes

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium. The defect fails **closed**, so it costs concurrency rather than correctness — the opposite
direction from the missing-shared-surfaces defect, which fails open. In TaskMaster it contributed to a
measured conflict-graph density of 83.3% over the committed plans, where `compute-cohorts.sh` produced
11 cohorts for 16 items with a maximum parallel width of 2, rendering a large `max_concurrency` inert.
In this repository the measured incidence is larger in absolute terms: 22 of 58 top-level plans under
`docs/features/active/` carry at least one accepted placeholder token, and nine thematically unrelated
plans share one identical token, forming a complete nine-item clique that requires at least nine
cohort colours and therefore executes strictly serially at any `max_concurrency`.

## Repro & Evidence

Steps to Reproduce:
1. Import `.claude/lib/blast-radius/BlastRadius.psm1` and load `config/blast-radius.json`.
2. Build two radii from structured plan text. Each task line must be a well-formed `- [ ] [P1-T1]`
   entry with inline-code tokens, since that is the only form the extractor harvests. Give item A the
   placeholder token \<FEATURE\>/spec.md plus a real file under one feature area, and item B the same
   placeholder plus a real file under a different feature area — different feature folders, disjoint
   real files.
3. Inspect `paths` on each radius.
4. Call `Test-BlastRadiusConflict` on the pair.
5. Repeat steps 2 through 4 with the placeholder removed, as a negative control.

Expected:
A placeholder is not a write claim. The extractor should reject a token containing any marker in the
set `<`, `>`, `${`, `$(`, `%`, matching the treatment `.claude/rules/plan-acceptance-gates.md` already
applies to documented command shapes, and the two disjoint items should report `conflict=False`.

Actual:
The placeholder is harvested into `paths` verbatim and the pair conflicts:

```text
paths          : <FEATURE>/spec.md | QuickFiler/Real.cs | docs/features/active/probe-1/**
placeholder-only overlap  -> conflict=True
   {"detail":"<FEATURE>/spec.md ~ <FEATURE>/spec.md","kind":"path_overlap"}
control, no placeholder   -> conflict=False
```

The control isolates the cause: the only difference between the two runs is the placeholder token, and
it alone flips the verdict.

### Retracted premise — the defect is not specific to the angle-bracket shape

An earlier report carried a scope correction asserting that the interpolation form was already
rejected and that the defect was specific to the angle-bracket shape. **That correction is retracted
in `issue.md` and must not be reproduced.** It instructed re-testing each form, and the re-test
overturned it. All five markers are accepted as `concrete` by both runtimes. Measured with
single-quoted probes against `classify_path_token` and `Get-PathTokenKind`:

```text
classify_path_token (scripts/dev_tools/_blast_radius_extraction.py)
  <FEATURE>/spec.md -> concrete   ${FEATURE}/spec.md -> concrete
  ${VAR}/y.cs       -> concrete   $(VAR)/y.cs        -> concrete
  %VAR%/y.cs        -> concrete

Get-PathTokenKind (.claude/lib/blast-radius/BlastRadiusExtraction.psm1)
  identical results for all five tokens
```

The original mis-measurement is explained by PowerShell string interpolation in the probe harness.
Inside a double-quoted PowerShell string, an unset `${VAR}` expands to the empty string, yielding the
literal `/y.cs`, which the leading-separator guard rejects — an artifact of the probe, not of the
classifier. The same idiom appears in this repository's own test file
`tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1` at line 50, so the
pattern is idiomatic here and easy to trip over.

Two consequences bind this specification:
1. The fix is scoped to the **full five-marker set**, not to angle brackets alone.
2. Every PowerShell probe string in the new tests must be single-quoted or built by character
   concatenation, and each probe must assert its own literal content before classification, so a
   recurrence of the interpolation artifact fails the test rather than passing it silently.

Code-trace corroboration: `classify_path_token` is pure with five straight-line branches, and no
branch in either runtime distinguishes an interpolation-form leading segment from an angle-bracket one
— both are wildcard-free, colon-free leading segments followed by a recognized extension. Corpus
corroboration: the interpolation form is in live use, with 71 accepted tokens of that shape in the
plan for issue #485 and one in the plan for issue #487.

### Measured incidence in this repository

Denominator: 58 top-level plan documents under `docs/features/active/*/plan*.md`.

| Measurement | Files | Occurrences |
| --- | --- | --- |
| Plans carrying at least one classifier-accepted placeholder token | 22 of 58 (38%) | 414 |
| Plans carrying at least one angle-bracket feature-folder token | 12 | 332 |
| Plans carrying at least one interpolation-form token | 2 | 72 |
| Plans carrying a command-substitution-bearing accepted token | 0 | 0 |
| Plans carrying a percent-bearing accepted token | 0 | 0 |

Spurious cliques, keyed on exact token identity rather than on marker family:

| Exact token (rendered escaped) | Distinct plan files | Spurious edges induced |
| --- | --- | --- |
| \<FEATURE\>/evidence/baseline/phase0-instructions-read.md | 9 | 36 |
| \<FEATURE\>/spec.md, \<FEATURE\>/issue.md, \<FEATURE\>/plan.md, \<FEATURE\>/user-story.md | 8 | up to 28 |
| .claude/state/powershell-batch-budget.\<session_id\>.json | 4 | 6 |

The nine plans sharing the phase0 token are for issues 334, 344, 369, 396, 413, 423, 442, 462, and
479 — thematically unrelated work. The union with the feature-doc family is ten files with an
intersection of seven, so those ten items form one dense connected component whose densest subgraph
is a complete nine-item clique.

The root cause is structurally identical to the two defects issue #489 fixed: the dominant token
originates in a **mandated** artifact. `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
declares the evidence path scheme non-overridable, so every compliant plan restates it, and a signal
that fires on every compliant plan carries no information about contention.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- The conflict snippet is inlined under **Actual** above; the five-marker probe output is inlined
  under the retraction subsection above.

## Scope & Non-Goals

In scope:
- A placeholder-marker rejection predicate over the marker set `<`, `>`, `${`, `$(`, `%`, implemented
  once per runtime in a new leaf module and called from the classifier seam.
- Relocation of the existing feature-corpus-span predicate and its two constants out of the two
  extraction modules, which is what makes the change fit under the 500-line limit.
- Registration of the new PowerShell module in the pack manifest and in the Pester coverage
  allow-list, plus the byte-identical bundled mirrors.
- New parity fixtures and unit tests in both runtimes, plus both corpus-floor counter bumps.
- A before/after conflict-graph density and cohort measurement with an exact positive control.
- A prose amendment to `.claude/rules/parallel-orchestration.md` and its bundled mirror.

Out of scope / non-goals:
- **No diagnostic or warning channel.** The rejected token is dropped silently. See Root Cause
  Analysis for the decisive argument.
- **No change to `config/blast-radius.json`.** The marker set is a token-syntax fact, not a
  repository-specific path list, and is hardcoded as a module constant in each runtime.
- **No change to `.claude/rules/plan-acceptance-gates.md`.** Its guard is unaffected; the
  cross-reference is one-directional from the parallel-orchestration rule file.
- **No bash change.** No bash surface performs path-token extraction; the bash layer parses an
  already-declared `blast_radius` block and colours a supplied edge list.
- **No TypeScript production change.** There is no TypeScript port of the extractor. The push-down
  derivation core is unaffected because no `config/blast-radius.json` key is added.
- **No widening of the marker set to closing delimiters** to cover the whitespace-split residual
  described under Behaviour Semantics.
- **No JSON Schema.** Enforcement for the parallel surface is prose plus validator logic and never an
  imported schema.
- No change to the module map, to `shared_surface_globs`, or to the finding-rule contract literal.
- No retroactive rewrite of committed plan text to remove placeholder tokens.

Explicitly excluded systems, integrations, or datasets:
- The epic and standard orchestrator artifacts and their validators.
- Issue #508's push-down config-carriage work.
- The remaining under-reporting work of issue #452.

## Root Cause Analysis

### The classifier admits marker-bearing tokens

`classify_path_token` (`scripts/dev_tools/_blast_radius_extraction.py`, lines 284-363) decides in five
steps: exact ordinal root-surface membership, then a separator guard rejecting a token with no `/`, a
leading `/`, or a `:` in the leading segment, then extension computation over the final component,
then acceptance of a wildcard-free token if and only if it has a recognized extension, then the
wildcard rules. `Get-PathTokenKind` (`.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, lines
290-398) reproduces the same five steps in the same order. A marker-bearing token such as
\<FEATURE\>/spec.md passes the separator guard (its leading segment carries no colon) and carries a
recognized extension, so step four accepts it as `concrete`. No step inspects for a marker.

### The classifier is the correct seam, not the extraction entry point

Three consumers read the classifier, and only a fix at the classifier reaches all three:

| Consumer | Route to the classifier | Reached by a fix in the classifier | Reached by a fix in the extraction entry point |
| --- | --- | --- | --- |
| `derive_blast_radius` | plan harvest plus a separate spec-text harvest | Yes, both harvests | No — the spec harvest bypasses the plan entry point |
| `validate_blast_radius` V1/V2 | plan harvest | Yes | Yes |
| `normalize_declared_radius` | direct per-entry classifier call | Yes | **No** |

The third row is decisive. `normalize_declared_radius` exists to re-filter radii recorded by an older
extractor, and it is the mechanism by which the issue #489 fix was demonstrated against already
recorded data. A guard in the classifier retroactively cleans every recorded manifest and checkpoint
radius; a guard at the extraction entry point leaves them dirty.

The classifier seam also delivers V1/V2 symmetry without extra arrangement: validation filters the
plan side through the same harvest, so a token dropped at derivation is also dropped at validation and
a derived radius keeps validating clean against its own plan.

### Rejecting a marker-bearing token cannot remove a true edge

A `path_overlap` edge requires string-level agreement between two radii's entries. A marker-bearing
token can agree only with another marker-bearing token spelled identically, never with a real
repository path, because no tracked path contains a marker character. `<` and `>` are
Win32/NTFS-reserved and cannot appear in a Windows file name at all, so that half of the rejection is
lossless by construction rather than merely lossless today. `$` and `%` are legal on Windows but
absent from the tracked tree.

The consequence is that the fix removes only spurious edges. A token expressing genuine write intent
through an abbreviation was already a broken contention signal, because it can never match the
spelled-out path another item would cite; dropping it forfeits no detectable true edge.

### The false-negative class documented for the sibling guard largely does not transfer

`.claude/rules/plan-acceptance-gates.md` records a false-negative class for its guard: a TypeScript
generic, a version constraint, a comparison operator, a markup tag. Those were measured against
search literals, which carry no shape requirement. A path token must additionally satisfy the
classifier's shape rules, and each documented example fails them independently of any marker — a
generic and a markup tag carry no `/`, and a version constraint and a comparison are split on
whitespace into tokens that carry no `/`. Measured over this corpus, zero accepted tokens contain `%`
and zero contain the command-substitution form, so the false-positive exposure is materially smaller
here.

### Silent drop is the correct behaviour, not a diagnostic

The issue asks whether a rejected token should be recorded as a diagnostic. It should not, in this
fix, for four reasons:

1. **No channel exists at the seam.** The classifier returns a kind or nothing in both runtimes.
   Emitting a diagnostic requires widening that return type, which propagates to four call sites per
   runtime.
2. **A diagnostic cannot reach validation without a second unfiltered pass.** V1/V2 read the plan
   through the same harvest, so post-fix the placeholder is gone before V1 sees it. Reporting it
   requires a second, unfiltered harvest — a new API in both runtimes, byte-mirrored, with
   fixture-corpus consequences.
3. **It would be inconsistent with four sibling rejections.** Directory-shaped tokens, corpus-spanning
   documentation globs, letterless contract tokens, and the removal of the artifacts segment from the
   known-top-level set are all silent drops. Singling out the fifth has no principled basis.
4. **Authoring quality is already owned elsewhere and better.** The concern that a plan citing a
   placeholder is under-specified is a plan-authoring concern. `.claude/rules/plan-acceptance-gates.md`
   owns that domain, applies the identical marker set to plan text, carries the authoring guidance,
   and has a working non-blocking warning channel with an exit code derived from the error channel
   alone. Duplicating the signal inside the classifier would put two subsystems in the business of
   judging plan wording.

If a diagnostic is wanted later, its correct home is a new plan-gate warning rule in
`.claude/rules/plan-acceptance-gates.md`, measured the way the existing G5 and G6 rules were measured.
That is a separate feature.

### One fail-open exposure, measured empty

`resolve_shared_surfaces` matches concrete entries against the configured shared-surface globs, so a
placeholder-bearing concrete token whose shape matches such a glob is currently reported as a touched
shared surface. Dropping the token loses that V2 signal. This is the only fail-open direction the fix
introduces, and it moves against the direction of issue #452, so it must be recorded rather than
glossed. Measured exposure over `docs/features/active/**`: zero matches. No committed plan exercises
the case. Handling: accept the exposure, pin it with an explicit regression test whose docstring
records the trade, and restate the planner's explicit-enumeration obligation in the rule-file
amendment.

## Proposed Fix

### Design summary (what changes where)

Add a placeholder-marker predicate to a new leaf module in each runtime and call it from the
classifier, immediately after the root-surface test and before the separator test. Relocate the
existing feature-corpus-span predicate and its two constants into the same new module to buy the
headroom the change needs. Register the new PowerShell module in the pack manifest and the Pester
coverage allow-list, mirror every bundled copy byte-for-byte, extend the shared fixture corpus and
both parity floors, and amend the parallel-orchestration rule prose from three rejected token shapes
to four.

### Boundaries and invariants to preserve

- **File-size limit (verified, and the reason relocation is mandatory).**
  `scripts/dev_tools/_blast_radius_extraction.py` is **497** lines and
  `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` is **498** lines, against the hard 500-line
  limit in `.claude/rules/general-code-change.md`. Headroom is 3 and 2 lines respectively. A minimum
  in-place Python edit is roughly 13 lines once the marker constant, the guarded branch with its
  mandatory decision-logic comment, and the docstring amendment are counted; the PowerShell edit is
  worse. **An in-place guard is arithmetically impossible.** The predicate must live in a new leaf
  module in each runtime. There is direct precedent in both runtimes for relocating a helper for
  exactly this reason.
- **No import cycle.** `BlastRadiusNormalization.psm1` imports `BlastRadiusExtraction.psm1`, so
  Extraction cannot import Normalization and the PowerShell predicate cannot be hosted there despite
  that module's available headroom. A new leaf module in both runtimes is the only design that
  satisfies both the size limit and the cycle constraint, and it keeps the one-to-one port mapping the
  module headers assert.
- **Guard ordering.** The marker test runs after the root-surface test and before the separator test.
  A configured root surface is an exact ordinal match against a real repository path and is
  separator-free and marker-free by construction, so testing it first costs nothing and keeps the
  issue #452 rule's precedence visible; running the marker test before the separator test means a
  marker-bearing token is rejected for the stated reason rather than incidentally.
- **Pure narrowing.** No radius gains an entry. Every existing fixture whose plan text is marker-free
  must produce a byte-identical result in both runtimes.
- **Determinism.** The predicate is pure containment over a fixed constant tuple: no clock, no
  randomness, no I/O. Output collections stay deduplicated and ordinally sorted so the two runtimes
  remain byte-comparable.
- **Export preservation.** The relocated PowerShell predicate must remain exported from the extraction
  module by re-import and re-export, following the existing precedent for the relocated ordinal-sort
  helper.
- **No coverage exclusion.** Per `.claude/rules/general-unit-test.md`, no production file may be
  excluded from coverage measurement. Both new modules enter the denominator.

### Dependencies or blocked work

- **Issue #500** (blast-radius umbrella module serializes all work) amends the same rule file and its
  mirror. The two fixes are independent in mechanism — #500 is a module-map defect, #502 is a
  token-shape defect — and complementary in effect. They collide on exactly one file pair. The
  planner must record a sequencing decision: either sequence the two items, or accept and declare the
  single `path_overlap` edge on the rule file.
- **Issue #508** (push-down config carriage has no merge decorator) is avoided entirely by the
  decision not to add a `config/blast-radius.json` key. Had the config route been chosen, this item
  would have landed inside that contested file.
- **Issue #452** (under-reporting gaps) shares `_blast_radius_extraction.py` and moves in the opposite
  direction: #452 is fail-open, #502 is fail-closed. The file-level collision is real; if #452's
  remaining work is scheduled concurrently, one `path_overlap` edge is correct and expected.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

*Production*
1. `scripts/dev_tools/_blast_radius_token_shapes.py` — **new** leaf module holding the marker tuple,
   the placeholder predicate, and the relocated feature-corpus-span predicate with its two constants.
2. `scripts/dev_tools/_blast_radius_extraction.py` — import the new module, call the guard in the
   classifier, relocate the span predicate and its constants out.
3. `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` — **new** leaf module, port of item 1.
4. `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` — mirror of item 2; import the new module and
   re-export the relocated predicate.

*Byte-identical bundled mirrors*
5. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`
6. `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1`

*Registration and policy*
7. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` — a bundled
   `.claude/lib/**` file absent from every manifest is silently dropped from a pack-scoped push-down.
   This path is deliberately outside the `.claude` byte-parity scope and has no repo-root counterpart.
8. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` — the `CodeCoverage.Path` entry is an
   explicit per-file allow-list of six blast-radius modules at lines 148-153. A new module omitted from
   it falls outside the coverage denominator, which the Coverage Exclusion Policy prohibits. **This
   file is a declared shared surface**, so this item's `shared_surfaces` must enumerate it.
9. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` — byte mirror
   of item 8.
10. `.claude/rules/parallel-orchestration.md` — the prose amendment described below.
11. `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` —
    byte-identical mirror of item 10.

*Tests, fixtures, and evidence* — per the Test Strategy section.

Relocation safety, verified: the Python span predicate has exactly two references repo-wide, both
inside its own module, and no test and no other module imports it. The PowerShell counterpart has
three references, all inside its own module, and no Pester file references it, so the only obligation
is to preserve the existing export.

#### Functions/classes/CLI commands impacted

- `classify_path_token` and `Get-PathTokenKind` gain one guarded rejection branch each.
- `spans_multiple_feature_folders` and `Test-MultipleFeatureFolderSpan` move module without a
  behaviour change; the PowerShell export surface is unchanged.
- `extract_paths_from_lines`, `extract_plan_paths`, `derive_blast_radius`,
  `normalize_declared_radius`, `validate_blast_radius`, and their PowerShell counterparts change
  behaviour only through the classifier. **No signature and no return type changes anywhere.**
- No CLI command, MCP tool, artifact type, or flag is added or changed.

#### Data flow and validation changes

Derivation harvests fewer `paths` entries; `modules` and `shared_surfaces` are re-resolved from the
narrowed path set, so a module or shared surface implied only by a placeholder token also disappears.
Validation stays self-consistent because V1/V2 read the plan through the same harvest.
`normalize_declared_radius` strips placeholder entries from already-recorded radii and re-resolves
their derived levels, which is what makes the fix retroactive over committed manifests and
checkpoints.

#### Error handling and logging updates

None. The rejection is a silent drop returning the same no-classification value the four sibling
rejections return. No exception is introduced, no log line is emitted, and no finding rule is added.
Degenerate input — the empty string, a marker-only token, and a token that is exactly a bare bracket
pair — must be handled without raising; the PowerShell parameter already declares empty strings
allowed.

#### Rollback/feature-flag considerations

No flag. The change is a pure narrowing of an accepted set inside a pure function, so rollback is a
revert of the diff. No persisted data format changes, and no migration is required: recorded radii are
cleaned lazily by `normalize_declared_radius` on next read and remain readable either way.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Input: a single whitespace-free inline-code token, as produced by the existing inline-code token
  extractor.
- Output: unchanged in type. A token containing any marker yields no classification and appears at no
  radius level.
- The marker test is **containment, not prefix**. A marker in the filename position and a marker in
  the leading segment are both rejected; the corpus contains both forms.

#### Required configuration keys and defaults

**None.** The marker set is a module constant in each runtime, deliberately not a configuration key:
it is a token-syntax fact of the same category as the recognized-extension and known-top-level-segment
constants, a new key would force an addition to the push-down carriage key list and its test, and it
would land inside issue #508's contested file.

#### Backward-compatibility expectations

- Pure narrowing: no radius gains an entry, so no previously absent conflict edge can appear.
- All 32 existing shared fixtures must produce byte-identical results in both runtimes.
- No public signature, return type, artifact type, CLI flag, MCP input-schema property, or finding-rule
  literal changes.
- Recorded radii from before the fix remain valid input and are cleaned on next normalization.

#### Performance constraints (latency/throughput/memory)

One substring containment test over a five-element constant tuple per token, executed on a token
stream already bounded by plan and spec length. The effect on derivation time is not measurable at
this scale, and no performance gate applies. The intended performance effect is in the opposite
direction and is the point of the fix: removing spurious edges reduces cohort count and raises
achievable parallel width.

### Rule-file amendment (recorded here; applied by the executor)

The paragraph at `.claude/rules/parallel-orchestration.md` lines 236-240, inside the
read-by-mandate subsection of the blast-radius contention doctrine, currently states that the
extractor rejects **three** token shapes. It must become **four**, with:

1. The count changed and the fourth shape appended: a token containing a placeholder or interpolation
   marker.
2. The marker set stated explicitly, with a cross-reference naming
   `.claude/rules/plan-acceptance-gates.md` as its origin, so the two subsystems are documented as
   agreeing by construction rather than coincidentally.
3. The two-part rationale recorded: a marker-bearing token can never string-match a tracked path
   (including the Windows-reserved-character argument for the angle brackets), and the dominant
   instance originates in a mandated artifact whose scheme
   `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` declares non-overridable, so every
   compliant plan restates it.
4. The planner obligation restated in the existing constraint form: when an item will actually write a
   path it expressed as a shape, it appends the concrete path to the declared radius after
   normalization.
5. The fail-open trade and its measured-empty exposure recorded, so a later reader does not mistake
   the omission for an oversight.
6. The whitespace-split residual recorded as a known residual rather than assumed away.

Enforcement remains prose plus validator logic. **No JSON Schema is authored, imported, or read**, and
the foreign-schema prohibition already in that file is unaffected. `.claude/rules/plan-acceptance-gates.md`
requires no change.

## Assumptions, Constraints, Dependencies

Assumptions:
- Both libraries are pure and importable in-process in their respective runtimes, so every
  verification step is executable locally and offline with no network, no external service, and no
  interactive prompt.
- The 58-plan corpus under `docs/features/active/*/plan*.md` is the measurement denominator; the six
  QA-gate evidence artifacts and the one plan-reconciliation artifact under `evidence/` are excluded.
- No tracked file name contains any of the five marker characters. Verified for `$` and `%` by tree
  search; guaranteed for the angle brackets by the Windows path-character rules.

Constraints:
- 500-line hard limit; the two extraction modules stand at 497 and 498 lines, so relocation is
  mandatory rather than stylistic.
- `BlastRadiusNormalization.psm1` cannot host the PowerShell predicate because it imports the
  extraction module.
- Every changed or added file under `.claude/` requires a byte-identical bundled mirror, enforced by a
  test that text-compares every repository `.claude` file except the local settings file and the agent
  memory tree.
- Line coverage >= 85% for both runtimes; branch coverage >= 75% for Python. PowerShell is exempt from
  the branch threshold only, not from measurement.
- Tests live under `tests/` mirroring the production layout; colocation is prohibited; temporary files
  in tests are prohibited. Every test input is an in-memory literal or a committed fixture.
- All PowerShell probe strings must be single-quoted or built by character concatenation.
- This item's declared radius must enumerate `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
  in `shared_surfaces`; omitting it produces a V2 Blocking finding at validation time.

External dependencies: none. No new library, service, or release is required.

## Data / API / Config Impact

- **User-facing or API changes:** none. No signature, artifact type, CLI flag, or MCP input-schema
  property changes. The observable change is that fewer `paths` entries are produced.
- **Data or migration considerations:** no persisted format change and no migration. Radii recorded
  before the fix are cleaned lazily by `normalize_declared_radius` on next read.
- **Logging/telemetry updates:** none, by design.
- **Compatibility notes:** `config/blast-radius.json` is unchanged, so the push-down derivation core
  and its carriage key list are unaffected. `pack-manifests/core.json` gains one entry and the two
  Pester settings copies gain one coverage path each; both are additive.

## Test Strategy

Layout follows `.claude/rules/general-unit-test.md`: tests mirror production layout, no colocation, no
temporary files, every input an in-memory literal or a committed fixture.

### New unit-test modules

- `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` — the placeholder predicate and the
  relocated span predicate. Cases: one per marker, each rejected; a marker in the filename position
  rejected; a marker-free real path accepted; the empty string, a marker-only token, and a bare
  bracket pair handled without raising.
- `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` — the character-for-character
  mirror. **Every probe string must be single-quoted or built by concatenation**, and that constraint
  must appear as a comment in the file, not only in the plan. Each case asserts the probe's literal
  content before asserting rejection, so an interpolation artifact fails rather than passes.

The new PowerShell cases go in this new file, not in
`tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`, which is 460 lines and
has only 40 lines of headroom.

### Extension of the existing shape-rule suite

- `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` — a parametrized test asserting the
  classifier yields no classification for each of the five marker probes, plus a companion test
  asserting a real path cited on the **same** plan line is still harvested. This is the issue's stated
  unit requirement.
- The equivalent PowerShell pair goes in the new token-shape test file.

### New shared fixtures

Each takes the same input/expected shape as the existing directory-shaped-rejection fixture, and each
is automatically asserted by **both** parity suites:

| Fixture | Purpose |
| --- | --- |
| `derivation-placeholder-token-rejected.json` | A plan citing two placeholder feature-doc tokens and one real path; expected paths contain the real path and the own-feature-folder glob only |
| `derivation-placeholder-marker-variants.json` | One task line per marker, all rejected — the fixture that makes the five-marker determination executable in both runtimes |
| `conflict-placeholder-only-overlap.json` | Two radii whose only shared entry is a placeholder token, with disjoint real files; expected conflict false |
| `validation-placeholder-self-consistent.json` | A radius derived from a placeholder-citing plan validates clean against that same plan; expected findings empty |

The negative control for preserved real-path conflict is either a new
`conflict-real-path-overlap-preserved.json` or a documented reuse of the existing
`conflict-path-overlap.json`. **The planner must record which, and record the reuse explicitly if it
reuses.**

### Retrospective-cleaning and trade tests

- A case asserting the normalization entry point strips a placeholder entry from an already-recorded
  radius while preserving its real entries and re-resolving `modules` and `shared_surfaces`. This is
  what proves the seam choice.
- A case asserting a placeholder-bearing token whose shape matches a configured shared-surface glob is
  dropped and therefore no longer reported as a touched shared surface, with a docstring recording
  that this is the accepted fail-open trade and citing the planner's explicit-enumeration obligation.

### Corpus measurement with an exact positive control

One evidence artifact at \<FEATURE\>/evidence/qa-gates/conflict-graph-density.\<timestamp\>.md
recording, for the same item set, before and after (the canonical evidence location per
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`; the path is written escaped here rather
than in an inline-code span for the reason given in the token-hygiene note above):

1. **Item set** — the 58 top-level plans, enumerated deterministically and sorted, with the count
   asserted non-zero so a broken glob fails loudly instead of passing vacuously.
2. **Radius per item** — derived with a constant `computed_at` so the run is deterministic; sibling
   spec text when present, empty otherwise.
3. **Edge set** — every canonical ascending pair, each edge recorded with its reason kind and detail.
4. **Density** — edges over pair count, to one decimal place.
5. **Cohorts** — cohort count and maximum cohort width.
6. **Positive control, three independent guards against a density collapse:**
   - **Total-entry accounting.** The total number of `paths` entries across all radii before and
     after, plus the exact set difference. **Every dropped entry must contain a marker character; a
     marker-free drop is a defect.** This is the strongest control because it is exact rather than
     statistical.
   - **Named survivor assertions.** A fixed list of real paths must survive, including one per
     acceptance rule: a recognized-extension file, a line-suffixed citation, a known-segment subtree
     glob, a configured root surface, and an own-feature-folder documentation glob.
   - **Surviving-edge identity.** A known-genuine edge must survive with its reason unchanged. The
     issue #489 capture supplies one: the 486-487 pair must still conflict on the shared MCP tools
     source file. A fix that collapsed density would delete that edge too.
7. **Falsifiable prediction.** The nine-item clique on the phase0 evidence token disappears entirely
   and the 36 edges it induced are removed unless the same pair also shares a real path. **The
   numeric edge-count delta must be fixed before the measurement is run**, so an unexpectedly larger
   delta is visible as a signal rather than absorbed as success.

### Baseline evidence

A baseline artifact under \<FEATURE\>/evidence/baseline/ recording the executed, single-quoted
five-marker probe in **both** runtimes pre-fix, converting the code-trace determination into an
executed result. If any marker proves already rejected, the marker tuple narrows accordingly and the
design is unchanged in shape.

### Counter bumps

Both corpus floors must move together or the floor goes stale. Current state, verified: 32 fixtures
present; `MINIMUM_FIXTURE_COUNT` is 26 at `tests/scripts/dev_tools/test_blast_radius_parity.py` line
56 and `$minimumFixtureCount` is 26 at
`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` line 57. Both must be raised to
26 plus the number of newly added fixtures, and must remain equal to each other.

### Toolchain commands

- Python: `poetry run black .` then `poetry run ruff check .` then `poetry run pyright` then
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`, restarting from the first stage on
  any failure or auto-fix, until all stages pass in a single pass.
- PowerShell: PoshQC format, then analyze, then test with coverage.
- TypeScript: the existing suites, expected to be a no-op pass, run to confirm the manifest
  completeness suites still pass.

### Manual validation

None required. Every step is executable unattended.

## Acceptance Criteria

Each criterion below is verifiable by a named test or a stated command.

### A. Marker rejection in both runtimes, paired per runtime

- [x] **AC-1** `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` contains a parametrized
  test over all five marker probes asserting the placeholder predicate reports each as
  marker-bearing; `poetry run pytest tests/scripts/dev_tools/test_blast_radius_token_shapes.py` passes.
- [x] **AC-2** `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py` contains a parametrized
  test asserting the classifier yields no classification for each of the same five probes — the
  paired classifier-level assertion for the Python runtime.
- [x] **AC-3** `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` contains, for
  each of the five probes, a paired assertion: the predicate reports the token as marker-bearing
  **and** `Get-PathTokenKind` returns no classification for it.
- [x] **AC-4** Every probe string in that Pester file is single-quoted or built by character
  concatenation, each case asserts the probe's literal content before classification, and the
  single-quote constraint is stated as a comment inside the file.
- [x] **AC-5** A marker in the filename position is rejected in both runtimes, asserted by a named
  test in each.
- [x] **AC-6** The empty string, a marker-only token, and a bare bracket pair are handled without
  raising in both runtimes, asserted by a named test in each.

### B. Real-path acceptance preserved (negative controls)

- [x] **AC-7** A real path cited on the **same** plan task line as a rejected placeholder is still
  harvested, asserted in both runtimes by a named test and by
  `tests/fixtures/blast_radius/derivation-placeholder-token-rejected.json`.
- [x] **AC-8** Two radii whose only shared entry is a placeholder token, with disjoint real files,
  report conflict false in both runtimes, asserted by a named normalization-plus-conflict test in
  each. ~~`tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` exists~~ —
  **the fixture clause is withdrawn as unsatisfiable.** A conflict fixture supplies literal recorded
  radii to a harness that never invokes `classify_path_token`, whose only two callers are
  `_blast_radius_extraction.py` and `normalize_declared_radius`; the conflict chain calls neither.
  Such a fixture's verdict is therefore invariant under this fix — satisfiable or discriminating,
  never both. A derivation-pair fixture cannot carry it either: the parity harness dispatches on
  exactly two fixture shapes and `derive_fixture_radius` returns a single radius. The named tests
  are strictly stronger than the fixture would have been, because each also asserts the
  pre-normalization pair does conflict, so the test fails on a tree without the guard.
- [x] **AC-9** Two items sharing a real file still conflict on `path_overlap`, asserted by a fixture
  with expected conflict true, and the planner's decision to add
  `conflict-real-path-overlap-preserved.json` or to reuse the existing
  `tests/fixtures/blast_radius/conflict-path-overlap.json` is recorded explicitly in the plan.
- [x] **AC-10** All 32 pre-existing fixtures under `tests/fixtures/blast_radius/` produce unchanged
  expected results in both parity suites, with no fixture edited to accommodate the change.
- [x] **AC-11** A named test asserts the normalization entry point strips a placeholder entry from an
  already-recorded radius while preserving its real entries and re-resolving `modules` and
  `shared_surfaces`.
- [x] **AC-12** `tests/fixtures/blast_radius/validation-placeholder-self-consistent.json` exists and
  a radius derived from a placeholder-citing plan validates clean against that same plan, with an
  empty findings list, in both parity suites.
- [x] **AC-13** A named test pins the fail-open trade: a placeholder-bearing token whose shape matches
  a configured shared-surface glob is dropped and is no longer reported as a touched shared surface,
  with a docstring recording the trade and citing the planner's explicit-enumeration obligation.

### C. Corpus measurement, before and after, with positive control

- [x] **AC-14** A baseline artifact under
  `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/`
  records the executed, single-quoted five-marker probe results for **both** runtimes pre-fix.
- [x] **AC-15** One evidence artifact under that folder's `evidence/qa-gates/` directory records,
  before and after: item count (asserted non-zero), edge count, density to one decimal place, cohort
  count, and maximum cohort width, over the 58 top-level plans with a constant derivation timestamp.
- [x] **AC-16** The same artifact records the total `paths`-entry count before and after and the exact
  set difference, and asserts that **every** dropped entry contains a marker character. A marker-free
  drop fails this criterion.
- [x] **AC-17** The same artifact records the named-survivor assertion result for a fixed list
  containing at least one path per acceptance rule: a recognized-extension file, a line-suffixed
  citation, a known-segment subtree glob, a configured root surface, and an own-feature-folder
  documentation glob. All must survive.
- [x] **AC-18** The same artifact records that the known-genuine 486-487 edge survives with its reason
  unchanged.
- [x] **AC-19** The numeric edge-count delta prediction is recorded in the plan **before** the
  after-measurement is run, and the artifact reports prediction against actual, with any deviation
  explained rather than absorbed.
- [x] **AC-20** The artifact reports that the nine-item clique on the mandated evidence-path token is
  gone, and that any surviving edge among those nine pairs is attributable to a shared real path.

### D. Parity fixtures and corpus-floor counters

- [x] **AC-21** Every new fixture carries the same input/expected shape as the existing
  directory-shaped-rejection fixture and is asserted by **both**
  `tests/scripts/dev_tools/test_blast_radius_parity.py` and
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`.
- [x] **AC-22** `MINIMUM_FIXTURE_COUNT` in `tests/scripts/dev_tools/test_blast_radius_parity.py` and
  `$minimumFixtureCount` in `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` are
  both raised from 26 to 30 and are equal to each other. The value was fixed at 30 when four
  fixtures were planned; three were added, so a literal reading of the original wording gives 29.
  30 is retained deliberately as the stricter bound: it is non-vacuous against the 35 fixtures on
  disk, exceeds the pre-change 26, and satisfies the floor's purpose — anti-vacuity plus
  cross-runtime equality — more strictly than 29 would. Lowering it to match the arithmetic would
  weaken a live gate to satisfy prose.
- [x] **AC-23** Both parity suites pass with byte-comparable radius, findings, conflict verdict, and
  conflict-reason results across the whole corpus, and the three non-vacuity tests in each suite still
  pass.

### E. Byte-mirror parity and registration surfaces

- [x] **AC-24** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  passes, confirming a byte-identical bundled mirror for **every** new or changed file under
  `.claude/` — the new `BlastRadiusTokenShape.psm1`, the changed `BlastRadiusExtraction.psm1`, and the
  amended `.claude/rules/parallel-orchestration.md`.
- [x] **AC-25** `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  lists the new bundled module; the manifest Pester suite and the pack-manifest-completeness Jest suite
  both pass.
- [x] **AC-26** The new module appears in the `CodeCoverage.Path` allow-list in **both**
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror, and
  `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes.
- [x] **AC-27** No coverage `exclude` entry matching a production source path is added anywhere, and
  both new production modules appear in their runtime's coverage denominator.
- [x] **AC-28** This item's declared blast radius enumerates
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` in `shared_surfaces`, and blast-radius
  validation reports no V2 Blocking finding.

### F. Rule-file prose amendment

- [x] **AC-29** `.claude/rules/parallel-orchestration.md` states **four** rejected token shapes, names
  the fourth as a placeholder or interpolation marker, states the marker set explicitly, and
  cross-references `.claude/rules/plan-acceptance-gates.md` as the set's origin.
- [x] **AC-30** The same amendment records: the never-matches-a-tracked-path rationale including the
  Windows-reserved-character argument; the mandated-artifact origin of the dominant token; the planner
  obligation to append a concrete path when an item really writes one; the fail-open trade with its
  measured-empty exposure; and the whitespace-split residual as a known residual.
- [x] **AC-31** The amendment introduces no JSON Schema file and no schema reference; enforcement
  remains prose plus validator logic.
- [x] **AC-32** `git diff` shows `.claude/rules/plan-acceptance-gates.md` and every file under
  `.github/` unmodified.

### G. Structural limits, toolchain, and scope containment

- [x] **AC-33** After the change, `scripts/dev_tools/_blast_radius_extraction.py`,
  `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, and both new modules are each at or under
  500 lines, verified by a line count over each file.
- [x] **AC-34** The relocated feature-corpus-span predicate remains exported from
  `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, verified by a module-export assertion or an
  existing consumer test.
- [x] **AC-35** The Python toolchain completes in a single pass with no failure and no auto-fix:
  `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`,
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Line coverage >= 85% and branch
  coverage >= 75%, with no regression on changed lines.
- [x] **AC-36** The PowerShell toolchain completes in a single pass: format, analyze, test with
  coverage. Line coverage >= 85%, with the new module measured.
- [x] **AC-37** The TypeScript suites pass, confirming the change is a no-op for that runtime.
- [x] **AC-38** No signature, return type, artifact type, CLI flag, MCP input-schema property,
  finding-rule literal, or `config/blast-radius.json` key is added or changed, verified by inspecting
  the diff.
- [x] **AC-39** No diagnostic, warning, or advisory finding is emitted for a rejected token, verified
  by the absence of any new finding rule in the diff and by the unchanged expected-findings blocks of
  all pre-existing fixtures.
- [x] **AC-40** The repro from the Repro & Evidence section reports conflict false post-fix in both
  runtimes, recorded in the QA-gate evidence artifact.
- [x] **AC-41** The issue #500 rule-file sequencing decision is recorded in the plan: either the two
  items are sequenced, or the single `path_overlap` edge on the rule file is declared and accepted.

### Traceability to `issue.md`

No criterion from `issue.md` is dropped, weakened, or reinterpreted.

| `issue.md` item | Covered by |
| --- | --- |
| Unit coverage — placeholder feature-doc tokens not harvested | AC-1, AC-2, AC-3, AC-7 |
| Unit coverage — a real path on the same task line still is | AC-7 |
| Unit coverage — interpolation forms behave as separately specified rather than by assumption | AC-1, AC-2, AC-3, AC-14 (executed per-marker determination, replacing assumption) |
| Integration — two-item conflict probe reports conflict false with the placeholder | AC-8, AC-40 |
| Integration — existing conflict true preserved for two items sharing a real file | AC-9, AC-10, AC-18 |
| Manual verification — re-derive radii over committed plans, record density and cohort count before and after | AC-15, AC-20 |
| Manual verification — keep a positive control; a fix that drops real paths must be caught immediately | AC-16, AC-17, AC-18, AC-19 |
| Reuse the marker set from `.claude/rules/plan-acceptance-gates.md` rather than inventing a second one | AC-29, AC-32, AC-38 |
| Decide silent drop versus diagnostic | AC-39 (decision: silent drop; rationale in Root Cause Analysis) |
| Accept the false-negative trade knowingly, or narrow to bracket pairs | AC-29, AC-30 (decision: reuse the five-marker set; the narrowing alternative is rejected under Risks) |
| Logs attached | Inlined under Repro & Evidence; AC-14 and AC-15 supersede with executed evidence |

## Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| The fix moves in the fail-open direction of issue #452 by narrowing the radius | The never-matches-a-tracked-path argument bounds the loss to zero detectable true edges; the one genuine fail-open case is the shared-surface glob, measured empty over the corpus, pinned by AC-13, and recorded in the rule prose |
| An over-broad guard silently drops real paths and collapses density, reading as success | Three independent positive controls (AC-16 exact set-difference accounting, AC-17 named survivors, AC-18 surviving-edge identity) plus the pre-registered numeric prediction of AC-19 |
| A PowerShell probe written with double quotes silently re-creates the original mis-measurement | AC-4: single-quoted or concatenated probes, an in-file comment stating the constraint, and a content assertion on each probe before classification |
| The 500-line limit is discovered mid-execution and forces an unplanned redesign | Pre-empted: relocation is mandated in the design, with the verified 497/498 line counts stated as the reason |
| A registration surface is missed and fails only at a late gate | Pre-empted by the explicit file-change map (items 7 through 9) and by AC-25, AC-26, AC-27 |
| The declared radius omits the shared surface and produces a V2 Blocking finding | AC-28 requires the enumeration explicitly |
| Concurrent work on issue #500 collides on the rule file | AC-41 requires the sequencing decision to be recorded before execution |
| Narrowing the marker set to bracket pairs is proposed as an alternative | Rejected: as stated it leaves the 72 live interpolation-form corpus tokens accepted, introduces a second definition where the issue asks for agreement, and adds a cross-runtime regex-parity hazard for no measured false-positive reduction |
| A future tracked file legitimately contains `$` or `%` in its name | A real but currently empty exposure: no tracked file carries either character today. The angle-bracket half is lossless by construction under Windows path rules. Recorded in the rule prose so a later reader can re-measure |
| The whitespace-split residual leaves a command-substitution fragment accepted | Not a regression; corpus incidence is zero. Recorded as a known residual in the rule prose rather than mitigated by widening the marker set to closing delimiters |

## Rollout & Follow-up

Release/rollout steps:
1. Land the two new leaf modules, the two classifier edits, and the two relocations.
2. Land the bundled mirrors, the pack-manifest entry, and both Pester settings entries.
3. Land the tests, fixtures, and both counter bumps.
4. Land the rule-file amendment and its mirror.
5. Produce the baseline and QA-gate evidence artifacts.
6. Run all three toolchains to a clean single pass.

Post-fix monitoring or clean-up tasks:
- Re-run the density and cohort measurement after the next batch of plans lands, to confirm the
  improvement holds as the corpus grows.
- Revisit whether a plan-gate warning rule for placeholder path tokens is worth adding in
  `.claude/rules/plan-acceptance-gates.md`, measured the way its existing G5 and G6 rules were
  measured. That is a separate feature and is explicitly out of scope here.
- Re-measure the `$` and `%` exposure if a tracked file is ever added whose name contains either
  character.

Links:
- Issue: https://github.com/drmoisan/drm-copilot/issues/502
- Origin report: drmoisan/TaskMaster issue #580
- Research: `research/2026-08-22T23-15-placeholder-path-token-rejection-research.md`
- Related open issues: #500 (rule-file overlap, complementary fix), #508 (avoided by the no-config
  decision), #452 (same file, opposite direction)
</content>

## Outcome — issue #502 resolved

The placeholder-shape defect is fixed in both runtimes. A token containing any of the five placeholder
or interpolation markers is now rejected by the path classifier before it can become a radius entry, so
two items that cite the same mandated artifact shape no longer acquire a `path_overlap` conflict edge on
a string that names no file.

**What changed.** Two new leaf modules hold the shape predicates —
`scripts/dev_tools/_blast_radius_token_shapes.py` and
`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` — and the guard is wired into
`classify_path_token` and `Get-PathTokenKind`, after the root-surface test and before the separator
guard. The new modules were mandatory rather than stylistic: the two extraction modules stood at 497 and
498 lines against a hard 500-line limit, so an in-place guard was arithmetically impossible. Both
finished at 475 and 472 lines, with more headroom than they started with. The rejection is silent,
returning the same no-classification value the four sibling rejections return; no diagnostic channel, no
finding rule, and no signature change on any pre-existing surface was added.

**Measured effect over the 58-plan corpus**, before and after, with a constant derivation timestamp and a
byte-identical item list:

| Quantity | Before | After |
| --- | --- | --- |
| conflict edges | 1282 | 1267 |
| density | 77.6% | 76.6% |
| cohorts | 32 | 32 |
| maximum cohort width | 4 | 4 |
| total radius path entries | 3729 | 2472 |

1257 path entries were dropped and **every single one contains a marker character**; zero marker-free
entries were dropped and zero entries were added. The nine-item clique induced by the mandated
evidence-path shape is gone as a clique: all 36 of its pairs lost the placeholder reason, 12 edges
disappeared outright, and the 24 that survive do so on unrelated reasons, none marker-bearing. Cohort
count and maximum width did not move: at this density the graph still needs the same number of cohorts,
so the gain is in the edge set and the entry count, not yet in the schedule.

**The three planner decisions, by name.**

- **AC-9 — reuse, do not add.** `tests/fixtures/blast_radius/conflict-path-overlap.json` was reused
  unmodified as the real-path negative control instead of adding a near-duplicate. A pre-existing fixture
  written before the fix existed and committed unmodified proves the fix did not perturb an
  independently authored assertion; a control authored alongside the fix proves only that its author
  expected it to pass. Verified by a zero-exit diff against the anchor. The decision was taken when four
  fixtures were planned; three were added, and the corpus floors deliberately stay at 30.
- **AC-19 — pre-registered edge-count delta of 53.** Fixed before any code change, witnessed by a
  recorded commit SHA and a clean working tree across all three edited locations. **The actual delta is
  15**, at or below the one-sided upper bound. The measured pair set is 63, of which 50 pairs still
  conflict on non-placeholder reasons and 13 were removed; the two remaining removed edges are
  placeholder-induced through the module level and through a glob-versus-placeholder match, which the
  plan's single-equation identity did not anticipate. Both halves of the corrected accounting balance
  exactly and the deviation is explained rather than absorbed.
- **AC-41 — declare the edge, do not sequence.** The single `path_overlap` edge with issue #500 on
  `.claude/rules/parallel-orchestration.md` and its bundled mirror is declared and accepted. Under the
  per-edge cohort barrier the two items are already mutually excluded, and a dependency key is
  prohibited on this surface, so declaring the edge *is* the sequencing decision. In the event the
  question resolved itself: #500 merged as pull request #514 before this execution completed.

**Final toolchain state.** Python: 4095 tests passing, line coverage 92.61% and branch coverage 89.82%,
both marginally above the 92.60% and 89.81% baseline, with changed-line coverage 100% on both touched
modules. PowerShell: 3389 tests, zero failures, line coverage 96.46% against a 96.47% baseline with the
missed-line count identical at 211, so no line regressed. TypeScript: a confirmed no-op at 195 suites
and 2654 tests, unchanged from baseline. All ten toolchain gates passed in a single uninterrupted pass.

**One acceptance criterion is withdrawn as unsatisfiable.** AC-8 required a conflict fixture asserting
that a placeholder-only overlap yields no conflict. That fixture cannot be both satisfiable and
discriminating: a conflict fixture supplies literal recorded radii straight to the conflict relation, and
`classify_path_token` has exactly two callers — the extraction module and the declared-radius
normalization entry point — neither of which the conflict chain calls. Its verdict is therefore invariant
under this fix. The literal clause is withdrawn and its substance is discharged twice over: by a named
normalization-plus-conflict test in each runtime, each asserting both that the pre-normalization pair
conflicts and that the normalized pair does not, and by the post-fix integration repro that is the
issue's own Steps to Reproduce. Both runtimes report conflict false post-fix with the negative control
still false.

**One acceptance criterion is partial.** AC-36's "with the new module measured" clause is not observable
through the MCP Pester tool, which executes from a published npm package whose bundled coverage
allow-list predates this change. Both in-repository allow-lists carry the entry, and a direct measurement
against the repository allow-list shows the module at 100% line coverage (19 of 19 lines). The MCP runtime
picks it up at the next publish with no further change.

**Acceptance criteria.** Of the 41 numbered criteria, 39 pass, 1 is partial (AC-36), and 1 is withdrawn
(AC-8). All 11 traceability rows pass. No item is unverified and none is a failure. AC-22 passes with a
documented one-count discrepancy: its literal arithmetic reads 29 while the executed floors are 30, which
is the more conservative value and still non-vacuous against 35 fixtures on disk. The full mapping, with a
named artifact per item, is at `evidence/qa-gates/acceptance-criteria-status.md`.
