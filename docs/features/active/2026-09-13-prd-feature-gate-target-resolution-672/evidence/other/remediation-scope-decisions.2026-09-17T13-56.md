# Remediation scope decisions (feature-review cycle 1)

Timestamp: 2026-09-17T13-56

Task: `[P0-T7]` of `remediation-plan.2026-09-17T12-29.md`
Issue: #672. Acceptance-criteria source:
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md`, section
`## Acceptance Criteria`.

This artifact records the five scope decisions of this remediation so a later reviewer does not re-open them.

---

## R1-OPTION: A

**Selected: Option A — delete the absolutely-placed-token pre-filter and hand the call text to
`Resolve-WorktreeCallTarget` unconditionally.** Applied by `[P2-T2]`.

The pre-filter is the four-line block at `.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 242-245:
a comment, an `if ($text -notmatch ...)` test carrying the pattern `[A-Za-z]:[\\/]`, a `return $null`, and the
closing brace. `[P0-T4]` re-measured both its tokens against the current tree and confirmed the citation:
`absolutely-placed` occurs twice, at lines 219 and 242, and `[A-Za-z]:[\\/]` once, at line 243.

Option A satisfies the two PARTIAL criteria as they are written, without re-wording either:

- **Criterion 6** (the line-616 item). With the pre-filter removed, a repo-relative citation whose folder
  exists in no worktree yields zero candidates and an `Ambiguous` status, which the hook denies before any
  probe or marker read. The misleading marker-is-broken remedy becomes unreachable on that path.
- **Criterion 10** (the line-626 item). With the pre-filter removed, a repo-relative citation whose folder
  exists only under the item worktree yields exactly one candidate, an `OtherWorktree` status, a probe path
  composed under that root, and `allow`.

### Rejection rationale for Option B, restated from the plan preamble

**Option B is rejected.** It keeps the pre-filter, so a repo-relative citation still derives no target, still
keeps the bare repo-relative probe path, and still resolves that path against the process working directory.
The remediation inputs state the same conclusion in their own terms: Option B "does not repair the false
denial, so criterion 10 would still need re-wording".

Re-wording an epic-approved acceptance criterion is outside this plan's authority. An option whose adoption
requires such a re-wording therefore cannot be selected, and that is the decisive argument rather than a
preference between the two designs. Option C is unavailable for the same reason and was not considered
further.

### Accepted consequence, recorded because it is a behaviour change

A repo-relative citation that places in more than one worktree now denies with the ambiguity code. Previously
such a call was allowed on the strength of whichever copy the process working directory happened to expose,
which is review diagnostic D5 and the false-approval mode `spec.md` names as risk R1. The new outcome is
fail-closed and carries an actionable remedy already present in the deny text.

---

## R2: APPLIED

Applied by **`[P2-T3]`**.

The `.DESCRIPTION` resolution-order block at `.claude/hooks/enforce-prd-feature-before-planner.ps1`
lines 14-34 documents a branch order the delivered code no longer implements: step 2 claims a positional
tie-break and step 3 claims an unconditional checkpoint fallback, both of which the delivered change removed.
`[P2-T3]` rewrites the block to describe the delivered order, including the derived-target disambiguator, the
unresolved-tie deny, the derivation's own ambiguity deny, and the folder-absent-under-the-target-root deny.

`[P0-T4]` confirmed both stale tokens are present exactly once each, `earliest-occurring candidate` at line 28
and `If no candidate was found in the prompt` at line 31, so the searches `[P2-T3]` asserts have a measured
non-zero pre-change control.

---

## R3: RESOLVED-BY-R1

Resolved by **`[P2-T2]`**. Verified by **`[P2-T4]`**.

R3 names a local derivation-eligibility decision held in the hook rather than in F1's resolution module. The
pre-filter *is* that decision: it decides which calls are eligible to reach the derivation at all. Deleting it
in `[P2-T2]` leaves `Resolve-WorktreeCallTarget` as the single owner of what counts as a placeable signal, so
R3 needs no separate remediation.

`[P2-T4]` is the verification task: it re-asserts criterion 24's no-local-re-implementation property over both
delivered production files after the edits, by measuring a zero count for each of `git worktree`,
`Get-Location`, `$PWD`, and `Resolve-Path` against a named non-zero control file for each token.

---

## R4-ITEM-1: APPLIED

Applied by **`[P2-T5]`**.

The file-level `.DESCRIPTION` of `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` asserts at
line 13 that the file "is loaded for its declarations only", which the file itself contradicts: it carries one
file-scope statement, the resolution-module `Import-Module` at line 21. `[P0-T4]` confirmed the stale sentence
is present exactly once, at line 13.

`[P2-T5]` replaces that sentence with wording that names the one file-scope statement and its rationale,
including that the import is deliberately unguarded so an unloadable module fails the gate closed. Nothing
else in the file changes; `ConvertTo-PrdFeatureFolderToken` and the import statement itself are untouched, and
`[P2-T6]` verifies the #518 four-segment slice survived byte-unmodified.

---

## R4-ITEM-2: DEFERRED

**Not applied in this remediation.** Recorded here for the epic owner.

### The finding, accepted as accurate

Criterion 30 is the `spec.md` line-655 item. Its verbatim current text is:

> - [x] The new suite creates no temporary file or directory, does not change the process working directory,
> and derives no absolute path from the environment, the current directory, the script file location, or a
> source-control query. Its synthetic roots are bare string literals and cwd is supplied as data through an
> injection parameter.

The clause "derives no absolute path from ... the script file location" is contradicted by the delivered
suite, which necessarily resolves the files under test from `$PSScriptRoot`. Re-derived against the current
tree in this task, `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
carries four such derivations:

- line 99: `$script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner.ps1").Path`
- line 100: `$script:Helpers = (Resolve-Path "$PSScriptRoot/../../../.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1").Path`
- line 109: `Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeResolution.psm1").Path -Force`
- line 110: `Import-Module (Resolve-Path "$PSScriptRoot/../../../.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1").Path -Force`

Those four derivations are not a defect. A Pester suite cannot dot-source the file under test without locating
it, and locating it relative to the suite's own path is the form every sibling suite in this tree uses. The
criterion's intent — that no *modelled* root, cwd, or feature-folder value be derived from ambient state — is
satisfied in full: every synthetic root in the suite is a bare string literal, and cwd is supplied as data
through an injection parameter.

### Proposed replacement wording, verbatim

> - [x] The new suite creates no temporary file or directory, does not change the process working directory,
> and derives no absolute path from the environment, the current directory, or a source-control query. The
> only paths it derives from the script file location are the `$PSScriptRoot`-relative locations of the files
> it dot-sources and the modules it imports, which locating the code under test requires. Every modelled
> value — each synthetic worktree root, each modelled cwd, and each feature-folder token — is a bare string
> literal, and cwd is supplied as data through an injection parameter.

### Reason the change is not applied here

The acceptance criteria in `spec.md` are the epic-approved contract for this child feature, and this plan
re-words none of them. Applying the narrower wording would mean an executor editing an approved contract to
match what was delivered, which inverts the direction of the check the criteria exist to perform.

The criterion stays `- [x]`. The feature audit judged the delivered suite to satisfy its intent fully and
rated the finding Minor, so the correct disposition is a recorded deferral to the epic owner rather than
either an executor-side edit or an unchecked criterion.

### Related instance, recorded but out of scope

The same over-broad clause appears in the suite's own header determinism statement, which states that "no
absolute path here is derived from the runtime environment, the current directory, the script file location,
or a source-control query". That prose carries the same inaccuracy as criterion 30 and for the same reason. No
task in this plan authorises editing it: `[P1-T7]` edits only lines 11-13 of that header, which are the stale
sibling line counts. It is recorded here so the epic owner can narrow both statements in one pass if the
proposed wording above is accepted.

---

Acceptance: the artifact carries `Timestamp:` and all five section labels; the `R1-OPTION:` value is exactly
`A`; and the `R4-ITEM-2:` section contains a proposed wording and a rationale sentence. Satisfied.
