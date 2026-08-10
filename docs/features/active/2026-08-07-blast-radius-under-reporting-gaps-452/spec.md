# 2026-08-07-blast-radius-under-reporting-gaps (Spec)

- **Issue:** #452
- **Parent (optional):** epic `parallel-orchestration`, F1 follow-up (issue #447)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-08T10-15
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-bug (this document is the sole acceptance-criteria source; no `user-story.md` exists for this item)

## Context

The F1 blast-radius library shipped with two verified under-reporting gaps in radius derivation
and the contention relation. Both are conformant with the approved F1 specification, so neither
blocked F1 delivery, and feature-review recorded zero Blocking findings. Both nonetheless weaken
the epic's fail-closed guarantee (`docs/features/epics/parallel-orchestration/epic.md`,
Shared Design item 7), and epic design section 13.1 names radius under-reporting the dominant
failure mode of the entire parallel-orchestration design.

They are recorded together because they share one root cause class — a radius that omits a
surface two items genuinely share — and one consumer deadline.

The consumer deadline is F4 (`parallel-planner`, issue #443). Design section 5.2 makes the
`declared` radius authoritative for scheduling, and F4 computes the declared radius by calling
`derive_blast_radius`. Plan-time blindness therefore propagates into the authoritative radius
unless F1 is corrected before F4 is executed.

Implementation research for this item is at
`docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/research/2026-08-08T10-15-blast-radius-under-reporting-gaps-research.md`
and is treated as authoritative for implementation detail (call sites, config plumbing,
monotonicity proof, fixture schema, mirror contract, verbatim F1 spec text, file-size relief).

## Repro & Evidence

- Steps to reproduce (with data/flags/inputs):
  1. **Gap 1 (Python).** Call
     `extract_plan_paths("- [ ] [P1-T1] Touch `poetry.lock`.")` from
     `scripts/dev_tools/_blast_radius_extraction.py`. The token `poetry.lock` sits inside a
     backtick-delimited inline-code span and is an exact member of the ten-entry
     `shared_surfaces` list in `config/blast-radius.json`.
  2. **Gap 1 (PowerShell).** Call `Get-PlanPaths` from
     `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` with the same plan text.
  3. **Gap 2 (Python).** Call `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")`
     from `scripts/dev_tools/_blast_radius_conflicts.py`, then call
     `is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])` from
     `scripts/dev_tools/_blast_radius_extraction.py`.
  4. **Gap 2 (PowerShell).** Call `Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB
     'scripts/dev_tools/**'` and `Test-PathSubsumed` with the analogous inputs, both from
     `.claude/lib/blast-radius/BlastRadiusGlob.psm1`.

- Expected vs actual behavior:

  | Reproduction | Actual (current) | Expected (after fix) |
  | --- | --- | --- |
  | `extract_plan_paths("- [ ] [P1-T1] Touch \`poetry.lock\`.")` | `()` | a tuple containing `"poetry.lock"` |
  | `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")` | `False` | `True` |
  | `is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])` | `True` | `True` (unchanged) |

- Logs/screenshots/error snippets: not applicable. Both defects are pure-function return values
  with no logging surface. The code evidence is:
  - `scripts/dev_tools/_blast_radius_extraction.py:243` — `if "/" not in token or token.startswith("/"): return None`.
  - `.claude/lib/blast-radius/BlastRadiusExtraction.psm1:290-293` — `if ($separatorIndex -lt 0 -or $separatorIndex -eq 0) { return $null }`.
  - `scripts/dev_tools/_blast_radius_conflicts.py:198-228` — concrete×concrete branch is string equality only; glob×concrete branch is `fnmatch` only.
  - `.claude/lib/blast-radius/BlastRadiusGlob.psm1:271-322` — structurally identical `Test-EntryOverlap`.
  - `scripts/dev_tools/_blast_radius_extraction.py:458-494` — `is_path_subsumed` applies the anchored listed-directory prefix rule that `_entries_overlap` does not.

- Frequency / determinism (always, intermittent, data-dependent): always, fully deterministic.
  Both are pure functions of their string inputs. Both language implementations reproduce both
  defects identically.

- Adjudication evidence:
  - `docs/features/active/2026-08-07-parallel-blast-radius-447/feature-audit.2026-08-07T17-32.md`
  - `docs/features/active/2026-08-07-parallel-blast-radius-447/code-review.2026-08-07T17-32.md` (finding F-01)

## Scope & Non-Goals

- In scope:
  - **Gap 1 — separator-free repository-root surfaces are unreachable from plan or spec text.**
    `classify_path_token` accepts a token as a concrete repository path only when it contains
    `/`, so separator-free repository-root shared surfaces (`poetry.lock`,
    `package-lock.json`, `quality-tiers.yml` — 3 of the 10 configured `shared_surfaces`
    entries in `config/blast-radius.json`) are unreachable from plan or spec text, so V2 cannot
    fire for them at plan time.
  - **Gap 2 — the `conflicts` path comparison ignores listed-directory semantics that V1
    honours.** The `conflicts` path comparison treats a listed directory and a glob beneath it
    as disjoint, while `is_path_subsumed` treats a file under that directory as covered.
    `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")` returns `False` while
    `is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])` returns `True`.
  - The three adopted resolutions recorded under `## Proposed Fix`.
  - The required amendment of the F1 spec at
    `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md` lines 42 and 118.
  - Extension of the parity fixture corpus at `tests/fixtures/blast_radius/`.
  - The behaviour-preserving structural relief required to stay under the 500-line file limit.

- Out of scope / non-goals:
  - `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md` — the
    repo-wide `pythonRepr` quote-selection divergence in four pre-existing epic/codex validator
    pairs. It is a separate, tracked item and is not touched by this change.
  - The `.claude/rules/parallel-orchestration.md` validator byte-identity qualification, which
    F3 already remediated. No change to that rule file or to those validators is in scope.
  - Any change to the glob×glob branch of the contention relation. Its conservative
    shared-literal-prefix test was independently proven sound during F1 review.
  - Any narrowing change, including excluding configured root surfaces from
    `extract_contract_identifiers`. Narrowing the relation is outside the adopted scope.
  - Adding a new configuration key. The existing `shared_surfaces` list is the sole source.
  - F4 (`parallel-planner`, issue #443) itself. This item unblocks F4; it does not implement it.

- Explicitly excluded systems, integrations, or datasets:
  - `config/blast-radius.json` content (read-only input; no key added, no value changed).
  - `.claude/skills/atomic-plan-contract/SKILL.md`.
  - `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror
    (unchanged because no new `.psm1` is created).
  - `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
    (unchanged for the same reason).
  - The epic orchestration validators and their TypeScript ports.

## Root Cause Analysis

- Current hypothesis or confirmed root cause: **confirmed, by direct source reading.**
  - **Gap 1.** `classify_path_token` (`scripts/dev_tools/_blast_radius_extraction.py:243`)
    rejects a separator-free token before any other acceptance rule runs. The separator test is
    a proxy for "this token names a repository path", and that proxy is wrong for
    repository-root files. The extraction layer has no access to the configured
    `shared_surfaces` list, so it has no basis on which to admit a bare filename. The PowerShell
    mirror (`BlastRadiusExtraction.psm1:290-293`) implements the same proxy identically.
  - **Gap 2.** Two relations that must agree were written against different models of a
    wildcard-free entry. `is_path_subsumed` treats every wildcard-free entry as a possible
    listed directory and applies the anchored prefix rule
    `path.startswith(entry.rstrip("/") + "/")`. `_entries_overlap` applies no directory
    semantics at all: a wildcard-free entry participates only in string equality (concrete
    branch) or as an `fnmatch` candidate (glob branch). The asymmetry is the defect.

- Signals/evidence supporting it:
  - Both reproductions in `issue.md:38` and `issue.md:61-62` were re-confirmed by reading the
    code, not merely by re-running the reported commands (research §A, §C).
  - `matches_glob("scripts/dev_tools/**", "scripts/dev_tools")` translates to the regex
    `scripts/dev_tools/.*`, which cannot match a candidate with no trailing segment. This is why
    the mixed concrete×glob branch fails for a glob rooted at the concrete entry.
  - Verified already-correct case that must not be "fixed":
    `_entries_overlap("scripts/dev_tools", "scripts/**")` is already `True`, because
    `matches_glob("scripts/**", "scripts/dev_tools")` becomes the regex `scripts/.*`, which
    matches. Only the narrower-or-equal-rooted glob and the concrete-file cases are blind.
  - Masking analysis: the coarse `modules` map hides Gap 2 in most realistic cases, because two
    radii sharing a directory usually also share a module. It is not masked for `artifacts/**`
    (accepted by extraction but absent from the module map) or for deserialized radii with an
    empty `modules` list.

- Affected components/modules (paths, services, pipelines):
  - Python: `scripts/dev_tools/_blast_radius_extraction.py`,
    `scripts/dev_tools/_blast_radius_conflicts.py`,
    `scripts/dev_tools/_blast_radius_validation.py`,
    `scripts/dev_tools/compute_blast_radius.py`, plus the new
    `scripts/dev_tools/_blast_radius_glob.py`.
  - PowerShell: `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`,
    `BlastRadiusGlob.psm1`, `BlastRadiusConfig.psm1`, `BlastRadiusValidation.psm1`,
    `BlastRadius.psm1`, each mirrored under
    `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`.
  - Specification: `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md`.
  - Test corpus: `tests/fixtures/blast_radius/` and the two parity drivers.

## Proposed Fix

The three resolutions below are human-approved and fixed. They are not re-litigated, and no
alternative is proposed.

1. Extend path-token classification to recognize a configured set of separator-free root
   surfaces, sourced from the `shared_surfaces` list itself rather than a second hardcoded list.
2. Align the `conflicts` path comparison with `is_path_subsumed` so listed-directory prefixes
   are honoured on both sides of the relation, preserving fail-closed semantics.
3. Update the F1 spec and the parity fixture corpus in the same change, so both language
   implementations and the shared corpus move together.

### Design summary (what changes where):

**Gap 1 — configured root-surface plumbing.** The extraction layer gains an optional,
keyword-only (Python) / named-optional (PowerShell) `root_surfaces` / `-RootSurface` parameter
with an empty default. A new config reader returns the separator-free subset of
`config["shared_surfaces"]`. The two entry points that must produce identical results —
`derive_blast_radius` and `validate_blast_radius` (`Get-BlastRadius` and `Test-BlastRadius`) —
already hold `config`, so both compute the same root-surface set from the same source and no new
coupling is introduced. Acceptance is exact, case-sensitive (ordinal) set membership evaluated
only on tokens already constrained to backtick-delimited inline-code spans; the classification
result is `concrete`.

**Gap 2 — additive directory-prefix disjuncts.** Each of the two non-glob-pair branches of
`_entries_overlap` / `Test-EntryOverlap` gains one directory-prefix disjunct. Nothing is removed.
The concrete×concrete branch adds two-way strict directory containment. The mixed concrete×glob
branch adds a two-way literal-prefix nest between the glob's literal prefix and the concrete
entry's directory prefix — which is definitionally "treat the wildcard-free entry as the glob
`<entry>/**` and apply the existing glob×glob rule", because
`_literal_prefix(dir + "/**") == dir + "/"`. The glob×glob branch is untouched.

**Structural relief.** Three files cannot absorb their change under the 500-line limit
(`_blast_radius_extraction.py` at 494, `_blast_radius_validation.py` at 497,
`BlastRadiusExtraction.psm1` at 486). The authorized relief is a pure move with no behaviour
change (see `### Boundaries and invariants to preserve`, invariant 6).

**Specification.** The F1 spec is amended at lines 42 and 118, plus one added behaviour-semantics
bullet and the Python surface block, each citing issue #452 as the amending authority.

### Boundaries and invariants to preserve:

1. **Both behaviours are spec-conformant today.** Gap 1 matches
   `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md:42`, which defines the
   rule as requiring `/`. Gap 2 matches that spec's line 118, which specifies
   "concrete×concrete: equality". Neither is implementation drift. The F1 spec amendment at
   lines 42 and 118 is therefore **REQUIRED, not optional**, and it must be traceable: the
   amended text must name issue #452 as the amending authority.
2. **Two-language byte-equivalence of behaviour.** The Python implementation
   (`scripts/dev_tools/compute_blast_radius.py` and its `_blast_radius_*.py` siblings) and the
   PowerShell implementation (`.claude/lib/blast-radius/*.psm1`) must remain behaviourally
   byte-equivalent. Neither may be corrected without the other. The shared parity corpus is the
   enforcement mechanism.
3. **Extend, never weaken, the fixture corpus.** `tests/fixtures/blast_radius/` is extended. No existing fixture expectation may be relaxed to make a test pass.
   Research verified that zero existing fixture expectations need to change (all 21 committed fixtures were checked case by case).
   TWO Pester tests assert a defect as intended behaviour and must be inverted; those two inversions are the ONLY authorized assertion changes in this item:
   `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1:309-316` (Gap 2) and `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1:248-262` (Gap 1).
   This invariant originally read "Exactly one Pester test" and named only the Gap 2 test. That count was factually wrong; the corrected count is two, established during execution of issue #452 on direct evidence that the completed Gap 1 fix makes `BlastRadius.Tests.ps1:248-262` fail (`Expected 0, but got 1`, against a config declaring `shared_surfaces = @('poetry.lock', ...)`), which is exactly the behaviour the acceptance criterion for reproduction 1 requires. The extend-never-weaken constraint on `tests/fixtures/blast_radius/` is unaffected by this correction.
4. **Fail-closed semantics — monotonicity is mandatory.** A change that makes the contention
   relation report LESS overlap is a regression, not a fix. The corrected relation's overlap set
   must be a superset of the current one, and strictly larger over the repository's input space.
   Formally: let `O_old` and `O_new` be the sets of entry pairs for which the relation returns
   `True`. The required property is `O_old ⊆ O_new`, with `O_old ⊊ O_new` witnessed by the
   pairs listed under `#### Data flow and validation changes`. Because each branch is rewritten
   as `old_predicate OR new_predicate` and boolean disjunction is monotone, the property holds
   for all inputs by construction, not merely for enumerated cases. Downstream,
   `_smallest_path_overlap` collects all overlapping pairs and returns `min(details)`; a
   superset of pairs can only keep or lower the minimum, never turn a non-`None` into `None`, so
   `conflicts` keeps every previously-true `path_overlap` verdict.
5. **Bundled-mirror contract.** `.claude/lib/**` is mirrored under
   `extensions/drm-copilot/resources/claude-customizations/.claude/lib/**` with content identity
   enforced by
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
   Both trees must move together in the same change. Five mirror files exist today.
   `config/blast-radius.json` has no mirrored copy and needs no mirror edit.
6. **500-line file limit** (`.claude/rules/general-code-change.md`). The authorized,
   research-recommended, behaviour-preserving structural relief is:
   - **Python:** create `scripts/dev_tools/_blast_radius_glob.py` as the counterpart of the
     existing `BlastRadiusGlob.psm1`, receiving `_glob_to_regex_text`, `matches_glob`,
     `is_path_subsumed` (from extraction), `GLOB_WILDCARDS`, `is_glob_entry`,
     `concrete_entries` (from validation), and `_literal_prefix`, `_entries_overlap` (from
     conflicts).
   - **PowerShell:** move `Get-OrdinalSortedEntry` from `BlastRadiusExtraction.psm1` into
     `BlastRadiusGlob.psm1`, where its sibling ordinal primitive `Get-OrdinalSmallestEntry`
     already lives, and re-export it from `BlastRadiusExtraction.psm1` so every existing call
     site and test stays source-compatible. No new `.psm1` is created.

   **This split is a pure move with no behaviour change.** The only logic edits landing in the
   moved code are the Gap 2 disjuncts specified above. Import graph stays acyclic:
   `extraction` (no deps), `glob` (no deps), `validation` (extraction, glob), `conflicts`
   (glob, validation), `compute_blast_radius` (all).
7. **Coverage.** Line coverage >= 85% and branch coverage >= 75%, with no regression on changed
   lines. The new `_blast_radius_glob.py` is a production module and is in the coverage
   denominator; no coverage exclusion may be added for it.
8. **Backward compatibility of every public signature.** All parameter additions are
   keyword-only (Python) or named-optional (PowerShell) with an empty default, so every existing
   call site and every existing test remains source-compatible and byte-identical in behaviour
   when the parameter is omitted.

### Dependencies or blocked work:

- **Blocks:** F4 (`parallel-planner`, issue #443). F4 computes the authoritative `declared`
  radius by calling `derive_blast_radius`; the plan-time blindness propagates into that radius
  unless this item lands first. Resolve before F4 is executed, not merely before the epic closes.
- **Depends on:** F1 (issue #447), already delivered. No other in-flight work touches these
  files.
- **External dependencies:** none. No new library, no new configuration key, no service.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

**Production (Python)**

| File | Change |
| --- | --- |
| `scripts/dev_tools/_blast_radius_glob.py` | **new**; receives the moved glob/subsumption/overlap primitives and the Gap 2 fix |
| `scripts/dev_tools/_blast_radius_extraction.py` | Gap 1 `root_surfaces` on `classify_path_token`, `extract_paths_from_lines`, `extract_plan_paths`; glob helpers moved out |
| `scripts/dev_tools/_blast_radius_validation.py` | new `config_root_surfaces`; call site at line 368 passes it; `is_glob_entry` / `concrete_entries` moved out |
| `scripts/dev_tools/_blast_radius_conflicts.py` | `_literal_prefix` / `_entries_overlap` moved out; imports updated |
| `scripts/dev_tools/compute_blast_radius.py` | lines 251-252 pass `root_surfaces`; re-export set updated for the module split |

**Production (PowerShell; each mirrored byte-for-byte under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`)**

| File | Change |
| --- | --- |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | Gap 1 `-RootSurface`; `Get-OrdinalSortedEntry` moved out and re-exported |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | Gap 2 in `Test-EntryOverlap`; receives `Get-OrdinalSortedEntry` |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | new `Get-ConfigRootSurface` |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | line 348 passes `-RootSurface` |
| `.claude/lib/blast-radius/BlastRadius.psm1` | lines 162-163 pass `-RootSurface` |

**Docs**

| File | Change |
| --- | --- |
| `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md` | amend lines 42 and 118, add one behaviour-semantics bullet, update the Python surface block at line 93 |

**Tests and fixtures** — per `## Test Strategy`. The only modifications to existing expectations are the two
defect-asserting Pester tests named in invariant 3: `BlastRadiusGlob.Tests.ps1:309-316` and `BlastRadius.Tests.ps1:248-262`.

#### Functions/classes/CLI commands impacted:

| Symbol | File | Impact |
| --- | --- | --- |
| `classify_path_token` | `_blast_radius_extraction.py:243` | Gap 1: new keyword-only `root_surfaces` |
| `extract_paths_from_lines` | `_blast_radius_extraction.py:271` | Gap 1: forwards `root_surfaces` |
| `extract_plan_paths` | `_blast_radius_extraction.py:327` | Gap 1: forwards `root_surfaces` (frozen contract literal in the F1 spec line 93) |
| `config_root_surfaces` | new | Gap 1: reads the separator-free subset of `config["shared_surfaces"]` |
| `_entries_overlap`, `_literal_prefix` | moved to `_blast_radius_glob.py` | Gap 2 |
| `matches_glob`, `is_path_subsumed`, `_glob_to_regex_text`, `is_glob_entry`, `concrete_entries`, `GLOB_WILDCARDS` | moved to `_blast_radius_glob.py` | pure move, no behaviour change |
| `derive_blast_radius` | `compute_blast_radius.py:215-263` | passes `root_surfaces` |
| `validate_blast_radius` | `_blast_radius_validation.py:342-379` | passes `root_surfaces` |
| `Get-PathTokenKind`, `Get-PathFromLine`, `Get-PlanPaths` | `BlastRadiusExtraction.psm1` | Gap 1: new `[string[]]$RootSurface = @()` |
| `Get-ConfigRootSurface` | new, `BlastRadiusConfig.psm1` | Gap 1 |
| `Test-EntryOverlap` | `BlastRadiusGlob.psm1:271-322` | Gap 2 |
| `Get-OrdinalSortedEntry` | moved to `BlastRadiusGlob.psm1`, re-exported from Extraction | pure move, no behaviour change |
| `Get-BlastRadius`, `Test-BlastRadius` | `BlastRadius.psm1`, `BlastRadiusValidation.psm1` | pass `-RootSurface` |

No CLI command or MCP surface changes. There is no production consumer of the blast-radius
library outside the library plus its tests (verified by repo-wide grep; F1 is wave 0 and has no
callers yet).

#### Data flow and validation changes:

**Gap 1 data flow.** `config` → `config_root_surfaces(config)` / `Get-ConfigRootSurface -Config` →
`root_surfaces` / `-RootSurface` → `extract_plan_paths` / `Get-PlanPaths` and
`extract_paths_from_lines` / `Get-PathFromLine` → `classify_path_token` / `Get-PathTokenKind`.
Both `derive_blast_radius` and `validate_blast_radius` read the set from the same `config`
mapping, which is what preserves the invariant "a derived radius always passes V1 and V2 against
its own plan".

**Gap 1 containment rule (fixed, narrowest form that reaches all three surfaces):**
- Source the set only from `config["shared_surfaces"]`, filtered to entries with no `/`. From
  the committed `config/blast-radius.json` this is exactly
  `{"package-lock.json", "poetry.lock", "quality-tiers.yml"}`.
- Do **not** source from `shared_surface_globs`.
- Do **not** add an extension-based fallback for separator-free tokens; that would admit
  `README.md`, `settings.json`, `main.ts`, `pyproject.toml` and every other bare filename in
  prose, an unbounded false-positive class with no fail-closed justification.
- Do **not** use substring, suffix, or case-insensitive matching. Membership must stay ordinal
  to match `resolve_shared_surfaces` (`_blast_radius_validation.py:334`, plain `in listed`) and
  the PowerShell `HashSet[string]` with `[StringComparer]::Ordinal`
  (`BlastRadiusConfig.psm1:408-410`). Any looser comparison desynchronizes extraction from
  surface resolution.
- Do **not** introduce a second hardcoded list. Resolution 1 rejects it explicitly, and a second
  list would silently desynchronize from `config/blast-radius.json`, which is itself an
  enumerated shared surface.

**Gap 2 validation changes — pairs whose result changes `False` → `True` (the strict-superset
witnesses):**

| Pair | Before | After | Justification |
| --- | --- | --- | --- |
| `("scripts/dev_tools", "scripts/dev_tools/a.py")` | False | True | the directory contains the file |
| `("scripts/dev_tools/", "scripts/dev_tools/a.py")` | False | True | trailing separator normalised |
| `("docs", "docs/features/active/x/spec.md")` | False | True | directory containment |
| `("scripts/dev_tools", "scripts/dev_tools/**")` | False | True | the issue's reproduction |
| `("scripts/dev_tools", "scripts/dev_tools/*.py")` | False | True | genuine overlap |
| `("scripts/dev_tools", "scripts/*/a.py")` | False | True | genuine (`*` fills `dev_tools`); this is why the nest must be two-way |
| `("config/blast-radius.json", "config/*.yml")` | False | True | accepted conservative over-report; see `## Risks & Mitigations` |

**Pairs that must NOT change (regression guards):**

| Pair | Before | After | Reason |
| --- | --- | --- | --- |
| `("scripts/dev_tools", "scripts/dev_toolsX/a.py")` | False | False | anchored `/` guard |
| `("scripts/dev_tools/a.py", "scripts/dev_tools/b.py")` | False | False | neither is a directory prefix of the other |
| `("docs/features/active/alpha", "docs/features/active/beta/**")` | False | False | prefixes diverge |
| `("scripts/a.py", "tests/**")` | False | False | prefixes diverge |
| any glob×glob pair | unchanged | unchanged | branch untouched |
| `("scripts/dev_tools", "scripts/**")` | True | True | already correct today; must not regress |

#### Error handling and logging updates:

None. Both defects are in pure predicate functions with no I/O, no logging, and no exception
surface. No new exception type, no new `throw`, no new log statement. The library remains free
of subprocess and filesystem I/O; `tracked_file_count` remains a caller-supplied input.

Malformed-input behaviour is unchanged: derivation still never fails on well-formed text inputs,
and malformed inputs (non-string, absent feature folder, unknown `source` string) still raise
specific exceptions / `throw` at construction.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. The change is a behaviour correction that is required to be on. F1 is wave 0
with no production callers, so the blast radius of the change is confined to the library plus
its tests, and rollback is a straightforward revert of the single pull request.

The new parameters default to empty, so a caller that omits them observes byte-identical
pre-change behaviour. That default is a source-compatibility measure, not a runtime kill switch;
both production entry points pass the configured set unconditionally.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

**Python signatures (all additions keyword-only with an empty default):**

```python
# scripts/dev_tools/_blast_radius_extraction.py
def classify_path_token(
    token: str, *, root_surfaces: Sequence[str] = ()
) -> PathTokenKind | None: ...

def extract_paths_from_lines(
    lines: Sequence[str], *, root_surfaces: Sequence[str] = ()
) -> tuple[str, ...]: ...

def extract_plan_paths(
    plan_text: str, *, root_surfaces: Sequence[str] = ()
) -> tuple[str, ...]: ...

# config reader
def config_root_surfaces(config: Mapping[str, object]) -> tuple[str, ...]:
    """Separator-free entries of config["shared_surfaces"], sorted and deduplicated."""
```

`PathTokenKind = Literal["concrete", "glob"]`; `None` continues to mean "not a repository path
reference". A separator-free token that is an exact ordinal member of `root_surfaces` classifies
as `PATH_KIND_CONCRETE`.

**PowerShell signatures (named-optional, defaulting to `@()`):**

```powershell
function Get-PathTokenKind    { param([string]$Token,    [string[]]$RootSurface = @()) }
function Get-PathFromLine     { param([string[]]$Line,   [string[]]$RootSurface = @()) }
function Get-PlanPaths        { param([string]$PlanText, [string[]]$RootSurface = @()) }
function Get-ConfigRootSurface { param([object]$Config) }   # new, in BlastRadiusConfig.psm1
```

`Get-PathTokenKind` continues to return `'concrete'`, `'glob'`, or `$null`.

**Contention relation output format is unchanged.** `conflicts` still returns the verdict plus
all triggered reason kinds, ordered `path_overlap`, `module_overlap`, `shared_surface_overlap`,
`contract_dependency`. `_smallest_path_overlap` still orders the pair ordinally before joining
with `" ~ "`.

#### Required configuration keys and defaults:

No new key. The change reads the existing `config["shared_surfaces"]` list in
`config/blast-radius.json` and filters it to the separator-free subset. `shared_surface_globs`,
`modules`, `over_breadth_fraction`, and `version` are unchanged and unread by the new code path.

Defaults: `root_surfaces = ()` / `-RootSurface = @()`. A config with no `shared_surfaces` key
yields an empty set and therefore pre-change behaviour.

A config-shape assertion is added in both languages: every separator-free `shared_surfaces`
entry must be wildcard-free, so a configured root surface can never classify as a glob.

#### Backward-compatibility expectations:

- Every existing call site and every existing test remains source-compatible. Omitting the new
  parameter yields byte-identical behaviour.
- `extract_plan_paths` / `Get-PlanPaths` remain the frozen contract literals named in the F1
  spec; only an optional parameter is appended.
- The `conflicts` output shape, reason ordering, and detail-string format are unchanged.
- The radius dictionary shape (six keys) is unchanged; no serialization format changes.
- The corrected contention relation is a strict superset of the previous one, so no consumer can
  observe a previously-reported conflict disappearing. The observable change is additional
  conflicts, which is the fail-closed direction.
- The Python module split changes import origins for internal helpers. `compute_blast_radius`
  re-exports are preserved so the public surface is unchanged.

#### Performance constraints (latency/throughput/memory):

No stated latency or throughput budget applies; this library performs in-memory string
operations on plan and spec text with no I/O. The Gap 1 change adds one set-membership test per
token, O(1). The Gap 2 change adds at most two `startswith` comparisons per entry pair, O(len).
`_entries_overlap` is invoked over the Cartesian product of two `paths` lists, which is unchanged
in cardinality. No measurable performance change is expected, and no benchmark baseline is
required or produced by this item.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - `config/blast-radius.json` remains the single source of the `shared_surfaces` list, and the
    three separator-free entries remain `poetry.lock`, `package-lock.json`,
    `quality-tiers.yml` at the time of implementation.
  - Tokens continue to be sourced only from backtick-delimited inline-code spans
    (`INLINE_CODE_SPAN_RE = re.compile(r"`([^`]+)`")`), so the residual false-positive surface
    stays bounded as analysed.
  - Both the Python and PowerShell toolchains are runnable locally (Poetry, Pester via PoshQC
    MCP). If the environment prevents running them, implementation stops and produces proposed
    diffs marked unverified, per `.claude/rules/python.md`.
  - F1 still has no production callers at implementation time.

- Constraints (budget, performance, compatibility):
  - 500-line file limit per `.claude/rules/general-code-change.md`, which forces the structural
    relief authorized in invariant 6.
  - Coverage >= 85% line and >= 75% branch, no regression on changed lines.
  - PowerShell change budget: this item exceeds the direct-mode 2-file cap (5 production
    `.psm1` files plus 5 mirrors), so it is executed through the orchestrated path with batches
    of at most 3 production files and 3 test files per
    `.claude/rules/powershell.md` (`## Change Budget`).
  - Two-language behavioural byte-equivalence (invariant 2).
  - No new dependency may be added.

- External dependencies (services, libraries, releases): none.

## Data / API / Config Impact

- User-facing or API changes: none user-facing. The library API gains three optional Python
  keyword-only parameters, three optional PowerShell named parameters, and two new public
  helpers (`config_root_surfaces`, `Get-ConfigRootSurface`). All are additive.
- Data or migration considerations: none. No persisted artifact schema changes. The
  blast-radius dictionary shape and the parallel-artifact invariants in
  `.claude/rules/parallel-orchestration.md` (invariant 9, `blast_radius` shape) are untouched.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag added, no MCP
  `artifact_type` added, no config-schema version bump. `config/blast-radius.json` `version`
  stays at its current value because no key is added or removed.
- Known documented behaviour change for downstream readers: after Gap 1, a spec that names a
  configured root surface inside a `## Public API Contract` section produces that string at both
  the `paths` / `shared_surfaces` level and the `contracts` level, because
  `extract_contract_identifiers` records any separator-free inline-code token inside an
  interface section. This double-count is fail-closed and is intentionally left in place;
  excluding root surfaces from `contracts` would narrow the relation and is out of scope.

## Test Strategy

- Regression tests to add or update:
  - **Invert exactly two existing tests** (corrected from "exactly one" during execution of issue #452):
    (a) `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1:309-316`
    (`It 'does not treat a directory entry as overlapping a file beneath it'`) asserted the Gap 2
    defect as intended behaviour. Rename to assert the corrected behaviour, flip
    `Should -BeFalse` to `Should -BeTrue`, and rewrite the rationale comment to cite issue #452
    and the `is_path_subsumed` alignment. (b) `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1:248-262` (`It 'cannot reach a separator-free repository-root surface from plan text'`) asserted the Gap 1 defect as intended behaviour. Rename it, change `Should -Be 0` to `Should -Be 1`, additionally assert that the single entry is `poetry.lock`, and rewrite the rationale comment to cite issue #452 as the amending authority.
  - **Add the missing Python counterpart.** No Python test exercises `_entries_overlap`
    directly today. Add direct coverage in `tests/scripts/dev_tools/test_blast_radius_conflicts.py`.
  - Preserve unchanged, as documented correct-behaviour guards:
    `test_classify_path_token_rejects_non_path_tokens`,
    `'rejects a token with no separator'`, `'returns nothing when no line cites a path'`,
    `test_distinct_concrete_paths_do_not_overlap`,
    `test_provably_disjoint_globs_do_not_conflict`,
    `test_two_feature_folder_globs_do_not_overlap`-class glob suites,
    `'reports overlap only for equal entries'`,
    `test_is_path_subsumed_does_not_treat_a_sibling_prefix_as_a_directory`,
    `test_a_derived_radius_passes_v1_against_its_own_plan` and its V2 counterpart,
    `test_widening_a_radius_never_removes_a_conflict`,
    `test_widening_a_disjoint_radius_can_only_create_a_conflict`, and the conflict
    symmetry / reason-symmetry suites.

- Unit tests (pytest) for the fixed behavior and boundaries:
  - `tests/scripts/dev_tools/test_blast_radius_extraction.py`: parametrized positive cases for
    each of the three committed separator-free surfaces through
    `classify_path_token(token, root_surfaces=(...))` → `PATH_KIND_CONCRETE`; negative cases for
    a separator-free token not in the set (`README.md`, `pyproject.toml`,
    `derive_blast_radius`) → `None`; a default-argument case proving `classify_path_token(token)`
    with no `root_surfaces` still returns `None`; a prose-without-backticks case → `()`; a
    case-variant case (`Poetry.Lock`) → `None` (ordinal membership).
  - `tests/scripts/dev_tools/test_blast_radius_validation.py`: V2 fires for a hand-authored
    declared radius that omits `poetry.lock` while the plan cites it.
  - `tests/scripts/dev_tools/test_blast_radius_invariants.py`: extend the `PLANS` table with a
    plan citing a separator-free surface so the existing V1/V2 self-consistency and determinism
    suites cover the new path with no new test bodies.
  - `tests/scripts/dev_tools/test_blast_radius_conflicts.py`: concrete directory vs file beneath
    it → True; concrete directory vs `dir/**` → True; concrete directory vs `scripts/*/a.py` →
    True (the two-way-nest necessity case); sibling-prefix `scripts/dev_toolsX/a.py` vs
    `scripts/dev_tools` → False; `a.py` vs `b.py` → False; trailing-slash
    `scripts/dev_tools/` normalisation.
  - `tests/scripts/dev_tools/test_blast_radius_config.py`: every separator-free
    `shared_surfaces` entry in the committed config is wildcard-free.

- Pester tests for the fixed behavior and boundaries:
  - `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`: the same
    positive / negative / default matrix against `Get-PathTokenKind -RootSurface`.
  - `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1`: `Get-ConfigRootSurface`
    returns exactly the separator-free subset, ordinally sorted, and `@()` for a config with no
    `shared_surfaces`.
  - `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1`: the Gap 2 matrix above,
    plus the inverted `It`.
  - Mirrored config-shape assertion in the `Describe 'Committed blast-radius truth table shape'`
    block of `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`.

- Parity corpus (both languages, automatic pickup — no registration list exists in either
  driver; drop a `.json` file into `tests/fixtures/blast_radius/` and both
  `tests/scripts/dev_tools/test_blast_radius_parity.py` and
  `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` discover it):
  - one Gap 1 positive fixture (plan cites a configured separator-free surface; the derived
    radius enumerates it and lists it under `shared_surfaces`);
  - one Gap 1 negative fixture (plan cites a separator-free token that is not a configured
    surface, such as `README.md`; the radius must not gain it);
  - one Gap 2 concrete×glob fixture (`scripts/dev_tools` vs `scripts/dev_tools/**`,
    `conflict: true`, reason `path_overlap`, detail `scripts/dev_tools ~ scripts/dev_tools/**`);
  - one Gap 2 concrete×concrete fixture (`scripts/dev_tools` vs `scripts/dev_tools/a.py`);
  - one Gap 2 non-regression fixture (`scripts/dev_toolsX/a.py` vs `scripts/dev_tools`,
    `conflict: false`).
  - Gap 2 fixtures must declare empty `modules` so the coarse module map cannot mask the path
    level.
  - Raise the anti-vacuity floor (`MINIMUM_FIXTURE_COUNT` in
    `tests/scripts/dev_tools/test_blast_radius_parity.py:56`; `$minimumFixtureCount` in
    `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1:57`) from 12 to the new
    on-disk fixture count in both drivers.

- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Config with absent or empty `shared_surfaces` → empty root-surface set → pre-change
    behaviour.
  - Case-variant token (`Poetry.Lock`) → not admitted (ordinal membership).
  - Separator-free token outside the configured set → not admitted.
  - Token outside a backtick span → not tokenized at all.
  - Trailing-separator directory entry (`scripts/dev_tools/`) → normalised, same verdict.
  - Sibling-prefix directory (`scripts/dev_toolsX`) → still disjoint.
  - Empty-versus-empty and empty-versus-non-empty radii → still no overlap.

- Error handling and logging verification: not applicable; no error or logging surface is added
  or changed. The existing fail-fast construction behaviour for malformed radii is exercised by
  the unchanged validation suites.

- Coverage impact and targets for changed lines/modules: >= 85% line and >= 75% branch, applied
  to the whole library including the new `scripts/dev_tools/_blast_radius_glob.py`. No coverage
  exclusion may be added. All five PowerShell modules are already in the `CodeCoverage.Path`
  list of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; because no new `.psm1`
  is created, that settings file and its bundled mirror need no edit.

- Toolchain commands to run (format → lint → type-check → test):
  - Python: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` →
    `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Restart from step 1 if any
    step fails or changes files.
  - PowerShell: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` →
    `mcp__drm-copilot__run_poshqc_test` using
    `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Restart from step 1 if any step
    fails or changes files.

- Manual validation steps (if required):
  - Re-run the two reproductions from `## Repro & Evidence` in both languages and confirm the
    corrected values.
  - Confirm `git diff --stat -- tests/fixtures/blast_radius/` lists only added files.
  - Confirm no file in the change set exceeds 500 lines.

## Acceptance Criteria

- [x] `classify_path_token` in `scripts/dev_tools/_blast_radius_extraction.py` accepts a keyword-only `root_surfaces: Sequence[str] = ()` parameter and returns `PATH_KIND_CONCRETE` for a separator-free token that is an exact ordinal member of `root_surfaces`.
- [x] `extract_paths_from_lines` and `extract_plan_paths` in `scripts/dev_tools/_blast_radius_extraction.py` each accept the same keyword-only `root_surfaces: Sequence[str] = ()` parameter and forward it to `classify_path_token`.
- [x] A Python config reader named `config_root_surfaces(config)` exists, returns the sorted, deduplicated separator-free subset of `config["shared_surfaces"]`, and is the only source of separator-free acceptance. `rg -n "poetry\.lock|package-lock\.json|quality-tiers\.yml" scripts/dev_tools/` returns no hit in any production module (the strings appear only in `config/blast-radius.json` and in tests/fixtures).
- [x] `derive_blast_radius` (`scripts/dev_tools/compute_blast_radius.py`) and `validate_blast_radius` (`scripts/dev_tools/_blast_radius_validation.py`) both obtain the root-surface set from the same `config` mapping via `config_root_surfaces`, and `poetry run pytest tests/scripts/dev_tools/test_blast_radius_invariants.py -k "passes_v1_against_its_own_plan or passes_v2"` passes without modifying those tests.
- [x] Ordinal, exact membership is enforced in Python: `classify_path_token("Poetry.Lock", root_surfaces=("poetry.lock",))` returns `None`, and `classify_path_token("README.md", root_surfaces=("poetry.lock", "package-lock.json", "quality-tiers.yml"))` returns `None`.
- [x] Backward compatibility of Gap 1 in Python: `classify_path_token("poetry.lock")` with the parameter omitted still returns `None`.
- [x] `Get-PathTokenKind`, `Get-PathFromLine`, and `Get-PlanPaths` in `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` each accept `[string[]]$RootSurface = @()`, and `Get-PathTokenKind -Token 'poetry.lock' -RootSurface @('poetry.lock')` returns `'concrete'` while `Get-PathTokenKind -Token 'poetry.lock'` returns `$null`.
- [x] `Get-ConfigRootSurface` exists in `.claude/lib/blast-radius/BlastRadiusConfig.psm1`, sources only from the config `shared_surfaces` list, returns `@()` for a config with no `shared_surfaces`, and is passed by `Get-BlastRadius` (`BlastRadius.psm1`) and `Test-BlastRadius` (`BlastRadiusValidation.psm1`).
- [x] Gap 1 two-language equivalence: for each of `poetry.lock`, `package-lock.json`, `quality-tiers.yml`, `Poetry.Lock`, `README.md`, and `derive_blast_radius`, the Python `classify_path_token` and the PowerShell `Get-PathTokenKind` return corresponding results (`concrete` / `$null`) under the same configured surface set, asserted by a shared parity fixture in `tests/fixtures/blast_radius/`.
- [x] Gap 2 corrected in Python, concrete×concrete branch: `_entries_overlap` returns `True` when either entry is a listed-directory prefix of the other, using the anchored rule `entry.rstrip("/") + "/"`, applied in both directions.
- [x] Gap 2 corrected in Python, concrete×glob branch: `_entries_overlap` returns `True` when the glob's literal prefix and the concrete entry's directory prefix nest in either direction, so `_entries_overlap("scripts/dev_tools", "scripts/*/a.py")` returns `True`.
- [x] The Python glob×glob branch of `_entries_overlap` is byte-identical to its pre-change form (verified by reading the diff of `scripts/dev_tools/_blast_radius_glob.py` against the moved source).
- [x] Gap 2 corrected in PowerShell: `Test-EntryOverlap` in `.claude/lib/blast-radius/BlastRadiusGlob.psm1` gains the same two disjuncts using `$Entry.TrimEnd('/') + '/'` and `[System.StringComparison]::Ordinal` on every `StartsWith`, with the glob×glob branch unchanged.
- [x] Reproduction 1 corrected in both languages: `extract_plan_paths("- [ ] [P1-T1] Touch \`poetry.lock\`.", root_surfaces=("poetry.lock",))` returns a tuple containing `"poetry.lock"` (before: `()`), and the PowerShell `Get-PlanPaths` with `-RootSurface @('poetry.lock')` returns the same single entry.
- [x] Reproduction 2 corrected in both languages: `_entries_overlap("scripts/dev_tools", "scripts/dev_tools/**")` returns `True` (before: `False`), and `Test-EntryOverlap -EntryA 'scripts/dev_tools' -EntryB 'scripts/dev_tools/**'` returns `$true` (before: `$false`).
- [x] `is_path_subsumed("scripts/dev_tools/x.py", ["scripts/dev_tools"])` still returns `True` and `Test-PathSubsumed` still returns `$true` for the analogous inputs; `is_path_subsumed` / `Test-PathSubsumed` logic is unmodified apart from relocation.
- [x] Monotonicity is asserted by a test in each language: for the pair table in `#### Data flow and validation changes`, no pair previously reported as overlapping is now reported as disjoint, including `("scripts/dev_tools", "scripts/**")`, `("scripts/dev_tools/**", "scripts/dev_tools/compute_blast_radius.py")`, `("shared.py", "shared.py")`, and `("scripts/*/alpha.py", "scripts/*/beta.py")`.
- [x] The regression guards `("scripts/dev_tools", "scripts/dev_toolsX/a.py")`, `("scripts/dev_tools/a.py", "scripts/dev_tools/b.py")`, `("docs/features/active/alpha", "docs/features/active/beta/**")`, and `("scripts/a.py", "tests/**")` all still return `False` / `$false` in both languages.
- [x] `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md` line 42 is amended to admit a separator-free token that is an exact member of the configured `shared_surfaces` list, and the amended text contains the literal string `issue #452`.
- [x] `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md` line 118 is amended so the concrete×concrete clause states equality **or** listed-directory prefix and the glob×concrete clause states fnmatch **or** literal-prefix nest, and the amended text contains the literal string `issue #452`.
- [x] A bullet is added to the F1 spec's `### Behavior semantics` list recording that listed-directory semantics are honoured symmetrically by V1 and by `conflicts`, and that comparing a concrete entry as a possible directory can over-report when the entry is a file, which is the fail-closed direction.
- [x] The F1 spec's Python surface block (line 93 region) is updated to show the new keyword-only `root_surfaces` parameter on `extract_plan_paths`, and the PowerShell surface list is updated correspondingly for `Get-PlanPaths`.
- [x] At least five new fixture files are added under `tests/fixtures/blast_radius/`: one Gap 1 positive, one Gap 1 negative, one Gap 2 concrete×glob, one Gap 2 concrete×concrete, and one Gap 2 non-regression (`conflict: false`).
- [x] No existing fixture expectation is relaxed: `git diff --name-status -- tests/fixtures/blast_radius/` lists only `A` (added) entries and no `M` (modified) entries.
- [x] The anti-vacuity floors `MINIMUM_FIXTURE_COUNT` (`tests/scripts/dev_tools/test_blast_radius_parity.py`) and `$minimumFixtureCount` (`tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`) are raised from 12 to the new on-disk fixture count, and both parity drivers pass.
- [x] `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1` no longer contains an `It` asserting that a directory entry does not overlap a file beneath it; the block at lines 309-316 is inverted to assert `Should -BeTrue`, is renamed accordingly, and its rationale comment cites issue #452.
- [x] A Python counterpart to the inverted Pester test exists in `tests/scripts/dev_tools/test_blast_radius_conflicts.py`, asserting that `_entries_overlap` treats a directory entry as overlapping a file beneath it.
- [x] Every edited file under `.claude/lib/blast-radius/` has a byte-identical counterpart under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/`, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
- [x] No new `.psm1` module is created, so `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and its bundled mirror are unmodified, and `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` passes.
- [x] The Python structural split is a pure move: `scripts/dev_tools/_blast_radius_glob.py` contains `_glob_to_regex_text`, `matches_glob`, `is_path_subsumed`, `GLOB_WILDCARDS`, `is_glob_entry`, `concrete_entries`, `_literal_prefix`, and `_entries_overlap`, with no logic edit other than the Gap 2 disjuncts, and the import graph remains acyclic (`extraction` and `glob` import no sibling; `validation` imports `extraction` and `glob`; `conflicts` imports `glob` and `validation`).
- [x] The PowerShell structural relief is a pure move: `Get-OrdinalSortedEntry` is defined in `.claude/lib/blast-radius/BlastRadiusGlob.psm1` and re-exported from `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, and every pre-existing caller and test of `Get-OrdinalSortedEntry` compiles and passes without modification.
- [x] No file in the change set exceeds 500 lines, verified for at least `scripts/dev_tools/_blast_radius_extraction.py`, `scripts/dev_tools/_blast_radius_validation.py`, `scripts/dev_tools/_blast_radius_conflicts.py`, `scripts/dev_tools/_blast_radius_glob.py`, `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, and `.claude/lib/blast-radius/BlastRadiusGlob.psm1`.
- [x] A config-shape assertion exists in both languages (`tests/scripts/dev_tools/test_blast_radius_config.py` and the `Describe 'Committed blast-radius truth table shape'` block of `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`) requiring every separator-free `shared_surfaces` entry to be wildcard-free.
- [x] Full Python toolchain passes in a single pass: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov --cov-branch --cov-report=term-missing`, with no new suppression added.
- [x] Coverage thresholds hold: line coverage >= 85% and branch coverage >= 75%, with no regression on changed lines, and no coverage `exclude` entry is added for any production file including `scripts/dev_tools/_blast_radius_glob.py`.
- [ ] Full PowerShell toolchain passes in a single pass: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, and `mcp__drm-copilot__run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, with zero PSScriptAnalyzer findings.
- [x] `config/blast-radius.json` is unmodified (no key added, no value changed), confirmed by `git diff -- config/blast-radius.json` producing no output.
- [x] The declared non-goals are untouched: `git diff --name-only` includes neither `docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md` nor `.claude/rules/parallel-orchestration.md` nor any parallel-state validator file.
- [x] `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` no longer contains an `It` asserting that a configured separator-free repository-root surface cannot be reached from plan text; the block at lines 248-262 is inverted so that a plan citing a configured separator-free root surface yields a `shared_surfaces` count of 1 whose single entry is `poetry.lock`, the `It` is renamed accordingly, and its rationale comment cites issue #452. This is the second of the two authorized assertion changes named in invariant 3.

## Risks & Mitigations

- Technical or operational risks:
  1. **Over-serialization from Gap 2.** Any plan citing a directory-shaped token (for example
     `scripts/dev_tools`, accepted today by the known-top-level-segment rule) will now contend
     with any item citing a glob rooted at or above that directory, which can place more items
     in the same cohort.
  2. **Concrete-file-treated-as-directory over-report.** The relation cannot know whether a
     wildcard-free entry names a file or a directory, so
     `("config/blast-radius.json", "config/*.yml")` becomes `True`.
  3. **V3 (over-breadth) sensitivity from Gap 1.** `_over_breadth_findings` counts
     `len(concrete_entries(radius.paths))`; a plan touching all three separator-free surfaces
     adds at most 3 concrete entries, which could in principle move a radius across the
     `over_breadth_fraction` threshold.
  4. **V1/V2 self-consistency regression from Gap 1.** If derivation and V1 were to receive
     different root-surface sets, a derived radius would stop passing V1 against its own plan.
     This is the single most important regression risk of Gap 1.
  5. **Contract/path double counting.** A spec naming a configured root surface inside a
     `## Public API Contract` section produces that string at both the `paths` and `contracts`
     levels.
  6. **Mirror drift.** An edited `.psm1` that is not copied to the bundled tree breaks the
     content-identity contract.
  7. **File-size limit.** Three files cannot absorb their change within 500 lines.

- Mitigations and rollbacks:
  1. In almost every such case the coarse `modules` map already forced a conflict, so the
     marginal cohort serialization is small. The genuinely new cases are exactly the unmasked
     ones the issue names: `artifacts/**` (accepted by extraction, absent from the module map)
     and deserialized radii with an empty `modules` list. Over-serialization is the fail-closed
     direction and is preferred to mis-scheduling.
  2. Accepted as fail-closed and definitionally identical to the conservatism the glob×glob
     branch already applies. Recorded in the amended F1 spec so a later reader does not treat it
     as a defect.
  3. Verified not to flip any committed fixture: `validation-v3-at-threshold` uses
     `tracked_file_count: 100` (threshold 25) and its plan cites no root surface. This remains a
     theoretical boundary risk for hand-authored plans only, and V3 is Advisory, not Blocking.
  4. Mitigated structurally: both `derive_blast_radius` and `validate_blast_radius` already hold
     `config` and both read the set through the single `config_root_surfaces` reader.
     `test_a_derived_radius_passes_v1_against_its_own_plan` and its V2 counterpart are preserved
     unchanged as the guard, and the `PLANS` table is extended with a plan citing a
     separator-free surface so the guard actually exercises the new path.
  5. Documented under `## Data / API / Config Impact`. The double-count is fail-closed and
     harmless; excluding root surfaces from `contracts` is explicitly rejected because it would
     narrow the relation.
  6. `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` fails on any
     unmirrored `.claude/**` edit with content identity, not mere existence. No additional test
     is required.
  7. Mitigated by the authorized pure-move relief in invariant 6, which also brings the Python
     module set into near-exact structural parity with the five PowerShell modules.

- Rollback: revert the single pull request. F1 is wave 0 with no production callers, so no
  downstream artifact or persisted state depends on the corrected behaviour.

## Rollout & Follow-up

- Release/rollout steps:
  1. Land the correction, the F1 spec amendment, the fixture extension, and the bundled mirror
     in one pull request against `main`, so both language implementations and the shared corpus
     move together (adopted resolution 3).
  2. No deployment, migration, or configuration rollout is required; the change is library code
     plus documentation and tests.
  3. Confirm the F1 feature folder's spec amendment is visible to F4 planning before F4 is
     executed.

- Post-fix monitoring or clean-up tasks:
  - Confirm F4 (`parallel-planner`, issue #443) computes its `declared` radius against the
    corrected `derive_blast_radius` and that no F4-side compensation is added for the
    separator-free surfaces.
  - Re-check the anti-vacuity fixture floors when the corpus next grows.
  - Watch for a first real cohort in which the Gap 2 correction is the sole reason two items
    were serialized; if the coarse `modules` map is consistently the binding constraint, that
    observation belongs in a future refinement item, not this one.

- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/452
  - Defect statement: `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/issue.md`
  - Implementation research: `docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/research/2026-08-08T10-15-blast-radius-under-reporting-gaps-research.md`
  - F1 spec to amend: `docs/features/active/2026-08-07-parallel-blast-radius-447/spec.md` (lines 42, 118)
  - F1 review evidence: `docs/features/active/2026-08-07-parallel-blast-radius-447/feature-audit.2026-08-07T17-32.md`, `docs/features/active/2026-08-07-parallel-blast-radius-447/code-review.2026-08-07T17-32.md` (finding F-01)
  - Epic: `docs/features/epics/parallel-orchestration/epic.md` (Shared Design item 7; design sections 5.2, 13.1)
  - Consumer: issue #443 (F4 `parallel-planner`)
