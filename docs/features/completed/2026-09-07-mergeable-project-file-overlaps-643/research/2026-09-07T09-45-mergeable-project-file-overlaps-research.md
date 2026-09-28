<!-- markdownlint-disable-file -->

# Task Research Notes: mergeable-project-file-overlaps (Issue #643)

- Issue: #643
- Date: 2026-09-07
- Researcher: task-researcher agent
- Primary input: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/issue.md` (the complete objective; `spec.md` and `user-story.md` are untouched templates and were not treated as requirements).
- Method note: this session had Read, Grep, Glob, and WebFetch only. Every claim is grounded in a file read with line references or in a quoted external document. No command was executed; claims that require execution are marked as such and assigned to a test.

## Research Executed

### File Analysis

- `config/blast-radius.json` (43 lines) and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` (29 lines)
  - Both carry `version`, `shared_surfaces`, `shared_surface_globs`, `mandate_reads`, `modules`, `over_breadth_fraction` and no other key. `mandate_reads` is byte-equal across the two copies (self-hosted 20-32, bundled 12-24). The bundled `modules` key holds `config` only (bundled 25-27).
- `scripts/dev_tools/_blast_radius_validation.py` (465 lines)
  - `CONFIG_MANDATE_READS = "mandate_reads"` (67); `config_string_list` (115-133) returns `()` for an absent key and `require_str_tuple` otherwise; `config_mandate_reads` (174-203) is a one-line wrapper over it. `validate_blast_radius` (296-346) applies `exclude_mandate_reads` to the plan-side extraction (330-335) so V1/V2 stay self-consistent; V3 (420-464) counts concrete entries against `over_breadth_fraction`. No rule reads a path-class key.
- `scripts/dev_tools/_blast_radius_normalization.py` (108 lines)
  - `matches_mandate_read` (40-80): exact ordinal equality first, then glob containment for a concrete entry only; a glob entry is never containment-tested. `exclude_mandate_reads` (83-107) returns the sorted, deduplicated survivors. Leaf module importing only `_blast_radius_glob`.
- `scripts/dev_tools/compute_blast_radius.py` (420 lines)
  - `derive_blast_radius` (221-289) reads `config_mandate_reads` (260), drops matching citations before adding the feature-folder glob (272-280). `normalize_declared_radius` (292-361) re-applies the same filter (346). `radius_from_observed_paths` (364-399) takes diff paths verbatim and applies no exclusion. `RADIUS_KEYS` (91-93) is the exact six-key set; `from_dict` rejects unexpected keys (199-207).
- `scripts/dev_tools/_blast_radius_conflicts.py` (242 lines)
  - `conflicts` (152-192): the config argument is validated and otherwise unread ("The relation reads no key from it today", 160-162). Path overlap is decided by `_smallest_path_overlap` (195-224) over the raw `a.paths` x `b.paths` product using `_entries_overlap`; the other three levels are set intersections (182-190). This is the single point at which a `path_overlap` edge is produced.
- `scripts/dev_tools/_blast_radius_glob.py` (317 lines)
  - `_glob_to_regex_text` (74-118): `**` becomes `.*`, so `**/*.csproj` compiles to `.*/[^/]*\.csproj`, which requires at least one `/` in the candidate; a root-level `packages.config` does not match `**/packages.config`. `_entries_overlap` (273-316) fails closed on glob pairs.
- `scripts/dev_tools/_blast_radius_guards.py` (97 lines), `_blast_radius_thresholds.py` (74 lines)
  - Leaf guards; `config_over_breadth_fraction` (50-73) is the only numeric reader.
- `scripts/dev_tools/parallel_cohort_computation.py` (469 lines)
  - `compute_cohorts` (350-416): a key that appears in no edge is an isolated vertex and lands in cohort 0 (371-373); zero edges therefore yield exactly one cohort.
- `scripts/dev_tools/parallel_drift_detection.py` (500 lines)
  - `detect_escaped_paths` (104-139) uses `is_path_subsumed` against the declared `paths` only, so a `.csproj` that stays in `paths` never escapes. `recompute_conflicts_with_observed` (271-338) evaluates `conflicts(observed_radius, peer, config)` at 499, so any exclusion placed inside `conflicts` also governs drift recomputation.
- `scripts/dev_tools/parallel_drift_resolution.py` (181 lines)
  - `build_observed_radius` (101-137) is the single guarded entry to `radius_from_observed_paths`; no exclusion is applied there.
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` (469 lines)
  - `MANIFEST_SUFFIXES` (79-85) lists `.csproj`, `.fsproj`, `.vbproj`, `.sln`, `.slnx`; `isManifestFileName` (266-273) suffix-matches them; `classifyProjectDirectories` (282-297) promotes every non-root manifest-bearing directory; `pruneAncestors` (309-319); `topLevelDirectories` (328-341) is the step-5 fallback; `assembleModules` (350-374) unions derived paths with `PAYLOAD_MODULES` (148-151, `config` only); `deriveDestinationModuleMap` (439-468) chooses `projectPaths.length > 0 ? projectPaths : topLevelDirectories(observations)` (449-451). `CARRIED_KEYS` (169-175) is the verbatim-carriage list, indexed positionally in the output literal (458-465); a key not in this list is dropped from the destination document.
- `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts` (307 lines)
  - I/O half: breadth-first scan to `SCAN_DEPTH_LIMIT` (163-207) and the `writeTextFile` substitution (282-293). No key logic.
- `.claude/lib/blast-radius/BlastRadiusConfig.psm1` (474 lines)
  - `Get-ConfigStringList` (197-231) and `Get-ConfigMandateRead` (285-313) mirror the Python readers. At 474 lines it cannot take a further ~30-line reader.
- `.claude/lib/blast-radius/BlastRadiusNormalization.psm1` (298 lines)
  - `Test-MandateRead` (187-244) and `Get-NonMandateReadEntry` (246-291) mirror the Python filter; imports Config and Glob (36-38).
- `.claude/lib/blast-radius/BlastRadius.psm1` (496 lines)
  - `Get-BlastRadius` applies the mandate filter (185-187); `Test-BlastRadiusConflict` (406-487) computes `path_overlap` through `Get-SmallestPathOverlap` (347-377) over the raw path arrays, reading no config key (426-428). At 496 lines the file has no headroom.
- `.claude/lib/blast-radius/BlastRadiusValidation.psm1` (375 lines)
  - `Test-BlastRadius` applies the mandate filter to the plan side (358-362); `ConvertTo-NormalizedBlastRadius` rejects unexpected radius keys (109-113).
- `.claude/lib/bash/compute-cohorts.sh` (144 lines), `.claude/lib/bash/parallel-cohorts.sh` (331 lines)
  - Bash consumes an already-computed `--edges "<a>:<b> ..."` list (compute-cohorts.sh 7-9, 128-133); no contention relation exists in bash. The destination runtime computes edges in PowerShell (`Test-BlastRadiusConflict`, `.claude/skills/parallel-plan/SKILL.md:310-314`) and colors them in bash.
- `.claude/agents/parallel-orchestrator.md` (266 lines)
  - Tool allowlist (5-22): `Agent(orchestrator)`, Read/Grep/Glob, `Write`/`Edit` restricted to `docs/features/parallel/**` and `artifacts/orchestration/**`, `Bash(git *)`, `Bash(gh *)`, `Bash(poetry run python -c *)`, `Bash(poetry run python -m *)`, three `Bash(bash .claude/lib/bash/<script>.sh*)` entries, and two MCP tools. No `pwsh`, no `dotnet`, no generic `bash`. The agent "consume[s] that schema and add[s] no field to it" (225).
- `.claude/skills/parallel-orchestrate/SKILL.md` (1056 lines)
  - `## Per-Item Merge-Conflict Handling` (341-380): on a conflicted `gh pr merge --merge` the parent re-delegates the child; the child's `atomic-executor` runs `git fetch origin main`, `git merge --no-commit origin/main`, captures `git diff --name-only --diff-filter=U` and the conflict markers (351-353), writes a synthetic Blocking finding (354-356), and the R1-R5 loop with the shared cap of 3 remediates (359-363); loop exhaustion maps to `blocked_ci_loop_limit` (369-375). "Escalate" today therefore means: re-delegate the child with a Blocking finding. `## Documentation Maintenance Boundaries` (406-441) defines the projection, generated from `docs/features/templates/parallel/parallel-status.md` (412). `## Parallel-Level Checkpoint` (443-483) enumerates per-item fields and states "add no field to it" (447).
- `.claude/rules/parallel-orchestration.md` (413 lines)
  - Invariant 9 (60) fixes the six `blast_radius` keys; invariant 15 (72) fixes the four edge reasons; the Contention Doctrine (222-400) documents `mandate_reads` with its three constraints (237-255), the granularity criterion (321-337), and the key-partition statement "Only `version`, `over_breadth_fraction`, and `mandate_reads` are byte-equal across the two copies" (369-370).
- `scripts/dev_tools/_parallel_state_common.py`
  - `validate_item_record` (336-377) reads `issue_num`, `feature_folder`, `state`, optional `kind`, `merge_status`, and `blast_radius` only. No unknown-key rejection exists on an item record (Grep for `unexpected|unknown` across `_parallel_state_*.py`, `validate_parallel_orchestrator_state.py`, `parallel-state-records.ts`, and `parallel-orchestrator-state-core.ts` returned only `unknown`-typed TypeScript parameters). An additional optional item field is therefore tolerated by every validator today.
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (283 lines)
  - Reads `conflict_edges[]` neighbours only (13, 24-25); it has no knowledge of edge reasons or paths.
- `tests/scripts/dev_tools/test_blast_radius_config_parity.py` (500 lines, at the limit)
  - Class 1 byte-equal parametrized test (182-202) over `BYTE_EQUAL_KEYS`; exhaustiveness test (205-239) fails on any top-level key missing from `DECLARED_TOP_LEVEL_KEYS` or present in one copy only; non-vacuity floor (431-477) special-cases `mandate_reads` (467-477).
- `tests/scripts/dev_tools/blast_radius_parity_test_support.py` (250 lines)
  - `BYTE_EQUAL_KEYS = ("version", "over_breadth_fraction", "mandate_reads")` (105); `DECLARED_TOP_LEVEL_KEYS` derives from it (135-137).
- `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` (269 lines)
  - `$script:ClassOneKeys = @('version', 'over_breadth_fraction', 'mandate_reads')` (30); byte-equality case (68-91); exhaustiveness case (127-165) derives the declared set from the three registries (133).
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` (325 lines)
  - Pins the shape of `mandate_reads` (243-261); a sibling case for the new key belongs here.
- `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py` (225 lines)
  - Reader tests (87-130) and derivation/validation symmetry tests (133-224); the pattern to replicate for the new key.
- `tests/scripts/dev_tools/test_blast_radius_conflicts.py` (372 lines), `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` (435 lines)
  - Both build radii with a minimal config `{version, over_breadth_fraction}` (Python 29; Pester 31) that carries no path-class key; adding a key-reading branch to the relation leaves these cases unchanged because an absent key excludes nothing.
- `tests/scripts/dev_tools/test_blast_radius_parity.py` (469 lines), `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (409 lines)
  - Fixture corpus is discovered by globbing `tests/fixtures/blast_radius/*.json` (Python 174-176; Pester 39); `conflict-*` fixtures carry `input.radius_a`, `input.radius_b`, `input.config` and `expected.conflict`/`expected.reasons` (`conflict-directory-vs-file.json` 3-41). A new fixture needs no registration.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` (483 lines), `blast-radius-derive.test.ts` (472 lines), `claude-config-carriage.test.ts` (461 lines), `config-carriage.test-helpers.ts` (229 lines)
  - Cases that pin a `.csproj` directory becoming a module: derive-core 92-99 (every suffix classifies), 118-124, 193-207; derive 186-203 and 393-401 (`src/App/App.csproj` yields `src/App/**`); config-carriage 301-324 and 371-379 (`"src/App/**"` expected) via `SRC_APP_LAYOUT` (helpers 222-228). `SOURCE_BLAST_RADIUS` (helpers 86-118) is documented as mirroring the bundled copy key for key. The `mandate_reads` carriage cases (derive 421-472) are the model for the new key.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  - `.claude/lib` files are enumerated individually (130-136 for the seven blast-radius modules; 139-149 for the bash library). A new module must be added here to reach a destination.
- `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`
  - Discovers every `.claude/lib/**/*.psm1` from disk (30-33) and enforces `Set-StrictMode` followed by the `$ErrorActionPreference = 'Stop'` guard, `-ErrorAction Stop` on load-time imports, the convention sentence, and the 500-line cap (36-41).
- `.claude/skills/csharp-qa-gate/SKILL.md` and `.claude/rules/csharp.md`
  - Formatter and analyzer commands: `dotnet tool restore`, `dotnet csharpier check .`, `dotnet build` with analyzers enforced through `Directory.Build.props` (SKILL 32-34; rule 14-16).
- `pyproject.toml`
  - `lxml >= 5.3.0` is a declared runtime dependency (27); no XML helper exists under `scripts/dev_tools` (Grep for `import xml|from xml|ElementTree|lxml|xml.dom|minidom|[xml]|System.Xml` across `scripts`, `.claude`, `extensions/drm-copilot/src`, `packages` matched only `.claude/rules/python-suppressions.md:67` and two `[xml]` casts in `.claude/hooks/validate-feature-review-coverage.ps1:193,228`). No `.csproj`, `packages.config`, or `bindingRedirect` handling exists in production code (Grep hits in `scripts/` were limited to the `csproj` extension literal in `_blast_radius_extraction.py:94`).

### Code Search Results

- `mandate_reads|mandateReads|MANDATE_READS`
  - Production consumers: `scripts/dev_tools/compute_blast_radius.py`, `_blast_radius_validation.py`, `_blast_radius_normalization.py`; `.claude/lib/blast-radius/BlastRadius.psm1`, `BlastRadiusConfig.psm1`, `BlastRadiusNormalization.psm1`, `BlastRadiusValidation.psm1` (plus their bundled mirrors); `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` (carriage only). No other TypeScript file reads the key; the only TypeScript reference to the edge-reason vocabulary is the enum literal in `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts:65`. There is no TypeScript contention relation to port.
- `conflicts\(` in `scripts/**/*.py`
  - Definition `_blast_radius_conflicts.py:152`; one production call `parallel_drift_detection.py:499`; docstring mentions only in `parallel_mutation_protocol.py:35,151` and `parallel_cohort_computation.py:29` (both state they never call it).
- `Test-BlastRadiusConflict` in `.claude/**` and `scripts/**`
  - Definition `.claude/lib/blast-radius/BlastRadius.psm1:406`; procedural consumers `.claude/skills/parallel-plan/SKILL.md:195,312`, `.claude/skills/parallel-add/SKILL.md:62`, `.claude/agents/parallel-planner.md:160`.
- `Bash\(dotnet|Bash\(pwsh|Bash\(bash` in `.claude/agents/*.md`
  - `Bash(pwsh *)` on `powershell-typed-engineer.md:9`, `orchestrator.md:15`, `atomic-executor.md:19`; `Bash(dotnet *)` on `csharp-typed-engineer.md:9`; script-scoped `Bash(bash .claude/lib/bash/...)` entries on `parallel-planner.md:17-20` and `parallel-orchestrator.md:18-20`. Both grant shapes have precedent.
- `merge --no-commit|diff-filter=U`
  - `.claude/skills/parallel-orchestrate/SKILL.md:351-352` and `.claude/skills/epic-orchestrate/SKILL.md:205-206`; the conflict-capture command pair is already the repository convention.
- `git add|git commit|PREIMPLEMENTATION` in `.claude/hooks/*.ps1`
  - `enforce-orchestration-preimplementation-gate.ps1` (with `-helpers.ps1` and `-modes.ps1`) gates staging commands; its parallel readiness predicate reads `artifacts/orchestration/parallel-orchestrator-state.json` (main 33, 278; modes 59, 430-454) and requires `route_id == parallel`, a non-empty `parallel_slug`, `parallel_manifest_path`, non-empty `items`, and a resolvable non-terminal target item. A parent-side `git add`/`git commit` in an item worktree passes through this gate and must be verified against it at implementation time.

### External Research

- #fetch:https://git-scm.com/docs/gitrevisions
  - Verbatim: "A colon, optionally followed by a stage number (0 to 3) and a colon, followed by a path, names a blob object in the index at the given path. A missing stage number (and the colon that follows it) names a stage 0 entry. During a merge, stage 1 is the common ancestor, stage 2 is the target branch's version (typically the current branch), and stage 3 is the version from the branch which is being merged." In the item worktree after `git merge --no-commit origin/main`, `:1:<path>` is the base, `:2:<path>` is the item branch (ours), `:3:<path>` is `origin/main` (theirs).
- #fetch:https://git-scm.com/docs/git-show
  - Confirms that during an unresolved merge "file1 is stage 2 aka 'our version', file2 is stage 3 aka 'their version'"; the stage syntax itself is documented in gitrevisions.
- #githubRepo:"drmoisan/drm-copilot mandate_reads exclusion"
  - Not queried; the in-repo landed contract (issue #489 research at `docs/features/completed/2026-08-17-blast-radius-false-conflict-edges-489/research/2026-08-17T23-55-blast-radius-false-conflict-edges-research.md`) is the authoritative precedent for a config-driven, fail-closed exclusion applied symmetrically in Python and PowerShell.

### Project Conventions

- Standards referenced: `CLAUDE.md` (tone, reading order), `.claude/rules/tonality.md`, `.claude/rules/general-code-change.md` (500-line limit, I/O isolation), `.claude/rules/general-unit-test.md` (no temporary files, mirrored `tests/` layout), `.claude/rules/python.md`, `.claude/rules/typescript.md`, `.claude/rules/powershell.md` (wrapper seam `Invoke-<Tool>Exe -<Tool>Args`, mock the wrapper never the executable), `.claude/rules/shell.md`, `.claude/rules/parallel-orchestration.md`, `.claude/rules/csharp.md`.
- Instructions followed: `.claude/skills/research-issue/SKILL.md`; `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` for the artifact timestamp; the `parallel-plan` skill's precedent that an advisory record is "a tolerated extra field, not a validated one; no validator changes for it" (`.claude/skills/parallel-plan/SKILL.md:335-336`).

## Key Discoveries

### Project Structure

The blast-radius contract is a three-runtime surface with one authority and two ports:

- Python authority under `scripts/dev_tools/` (`compute_blast_radius.py` facade; `_blast_radius_{extraction,glob,guards,normalization,thresholds,validation,conflicts}.py` helpers, each a documented leaf or near-leaf to keep the import graph acyclic).
- PowerShell destination-runtime port under `.claude/lib/blast-radius/` (seven modules), mirrored byte-for-byte into `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/` and enumerated in `pack-manifests/core.json:130-136`.
- TypeScript push-down derivation (`claude-blast-radius-derive-core.ts`) that rewrites the module map for a destination and carries every other key verbatim through `CARRIED_KEYS`.
- Bash cohort coloring (`.claude/lib/bash/compute-cohorts.sh`) that consumes edges and never computes them.

The parallel-orchestrator's merge-conflict path is prose in `.claude/skills/parallel-orchestrate/SKILL.md:341-380`, executed by the agent with the allowlist in `.claude/agents/parallel-orchestrator.md:5-22`. The checkpoint item record is validated by `_parallel_state_common.py:336-377`, which tolerates additional keys.

### Implementation Patterns

`mandate_reads` is threaded through exactly four seams, and `mergeable_paths` must follow the same shape with one deliberate difference:

| Seam | `mandate_reads` (existing) | `mergeable_paths` (required) |
| --- | --- | --- |
| Key constant + reader | `_blast_radius_validation.py:67, 174-203`; `BlastRadiusConfig.psm1:44, 285-313` | same reader shape (`config_string_list` / `Get-ConfigStringList`), absent key yields `()` |
| Matcher + filter | `_blast_radius_normalization.py:40-107`; `BlastRadiusNormalization.psm1:187-291` | identical semantics (exact equality, then glob containment for concrete entries only) |
| Application point | derivation harvest (`compute_blast_radius.py:272-280`) and plan-side validation (`_blast_radius_validation.py:330-335`) | **only** the contention relation (`_blast_radius_conflicts.py:175-177`; `BlastRadius.psm1:464-468`), never derivation, normalization, validation, or `radius_from_observed_paths` |
| Push-down carriage | `CARRIED_KEYS` (`derive-core.ts:169-175`) | append as `CARRIED_KEYS[5]`; add to the output literal (458-465) |

The difference is load-bearing: the issue requires the path to stay in `paths` so drift detection and V1-V3 still see it. Because the only producer of a `path_overlap` reason is `_smallest_path_overlap` inside `conflicts` (and `Get-SmallestPathOverlap` inside `Test-BlastRadiusConflict`), filtering both radii's `paths` through the mergeable exclusion immediately before that call removes the edge while leaving every recorded radius byte-identical.

### Complete Examples

Python application point, modelled on the existing mandate-read call (`compute_blast_radius.py:278`) and inserted at `_blast_radius_conflicts.py:175`:

```python
# scripts/dev_tools/_blast_radius_conflicts.py (inside conflicts())
mergeable = config_mergeable_paths(config)
path_detail = _smallest_path_overlap(
    exclude_mergeable_paths(a.paths, mergeable),
    exclude_mergeable_paths(b.paths, mergeable),
)
```

PowerShell mirror, replacing `BlastRadius.psm1:464-465`:

```powershell
$mergeable = [string[]]@(Get-ConfigMergeablePath -Config $Config)
$pathDetail = Get-SmallestPathOverlap `
    -PathA ([string[]]@(Get-NonMergeablePathEntry -Entry ([string[]]@($left['paths'])) -MergeablePath $mergeable)) `
    -PathB ([string[]]@(Get-NonMergeablePathEntry -Entry ([string[]]@($right['paths'])) -MergeablePath $mergeable))
```

Conflict-parity fixture shape (new file `tests/fixtures/blast_radius/conflict-mergeable-csproj-no-edge.json`, following `conflict-directory-vs-file.json:1-42`):

```json
{
  "description": "Two items whose only path overlap is the same .csproj; mergeable_paths removes the path_overlap edge while both radii keep the file in paths.",
  "input": {
    "radius_a": { "paths": ["QuickFiler.Test/QuickFiler.Test.csproj", "QuickFiler.Test/A.cs"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-07T09-00" },
    "radius_b": { "paths": ["QuickFiler.Test/QuickFiler.Test.csproj", "QuickFiler.Test/B.cs"], "modules": [], "shared_surfaces": [], "contracts": [], "source": "declared", "computed_at": "2026-09-07T09-00" },
    "config": { "version": 1, "shared_surfaces": [], "shared_surface_globs": [], "mergeable_paths": ["**/*.csproj", "**/packages.config", "**/app.config", "**/*.vbproj", "**/*.props"], "modules": { "config": ["config/**"] }, "over_breadth_fraction": 0.25 }
  },
  "expected": { "conflict": false, "reasons": [] }
}
```

### API and Schema Documentation

- `conflicts(a, b, config) -> ConflictResult` keeps its frozen three-argument signature (`_blast_radius_conflicts.py:152-154`); the docstring sentence "The relation reads no key from it today" (160-162) and its Pester counterpart (`BlastRadius.psm1:426-428`; `BlastRadius.Conflict.Tests.ps1:29-30`) must be reworded to name `mergeable_paths` as the one key read.
- `BlastRadius.to_dict()` and invariant 9 are unchanged: `mergeable_paths` never enters a radius record.
- Checkpoint item record: `mergeable_conflicts_resolved` is an OPTIONAL list on `items[]`; absent contributes zero errors under every current validator (evidence: `_parallel_state_common.py:353-377` reads six named keys and nothing else). Proposed shape:

```json
"mergeable_conflicts_resolved": [
  {
    "path": "TaskMaster.Test/TaskMaster.Test.csproj",
    "resolved_at": "2026-09-07T10-15",
    "merged_against": "<origin/main sha at resolution>",
    "merge_commit_sha": "<sha of the resolution commit on the item branch>",
    "entries_added_from_ours": ["Compile:Foo.cs"],
    "entries_added_from_theirs": ["Compile:Bar.cs"],
    "version_resolutions": [
      { "key": "package:Newtonsoft.Json", "ours": "13.0.1", "theirs": "13.0.3", "chosen": "13.0.3" }
    ]
  }
]
```

  Entry keys are `<ItemType>:<Include>` for MSBuild items, `package:<id>` for `packages.config`, and `bindingRedirect:<assemblyIdentity name>` for `app.config`, so a reviewer can identify the element without reopening the file. `version_resolutions` is present (possibly empty) only for `packages.config`/`app.config` entries.

- Validator disposition: no invariant is added and none changes. Rule invariant 9 (`parallel-orchestration.md:60`) governs `blast_radius` only. The rule file gains a prose paragraph declaring the field optional, additive, and tolerated-not-validated, following the lane-assertion precedent; the two "add no field" sentences (`parallel-orchestrator.md:225`; `parallel-orchestrate/SKILL.md:447`) must be narrowed to "add no field the rule file does not declare", since they would otherwise contradict the new field.

### Configuration Examples

Both truth-table copies gain the key, byte-equal (Class 1):

```json
"mergeable_paths": ["**/*.csproj", "**/packages.config", "**/app.config", "**/*.vbproj", "**/*.props"]
```

Known matcher residual to record in the rule file: with the shared glob translation (`_blast_radius_glob.py:103-118`) a leading `**/` requires a separator, so a root-level `packages.config` or `app.config` (which can only arrive through an observed radius, since the extractor rejects separator-free tokens that are not root surfaces, `_blast_radius_extraction.py:281-306`) would not match. Recommended local rule inside the mergeable matcher: when a pattern starts with `**/`, also test the pattern with that prefix removed. This keeps `_glob_to_regex_text` and its PowerShell mirror untouched.

Parallel-orchestrator allowlist additions (`.claude/agents/parallel-orchestrator.md:5-22`), each scoped to one command shape following the existing script-scoped precedent:

```yaml
  - "Bash(pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1*)"
  - "Bash(dotnet tool restore*)"
  - "Bash(dotnet csharpier check *)"
  - "Bash(dotnet build *)"
```

### Technical Requirements

1. `mergeable_paths` is optional and fail-closed in all three runtimes; an absent or empty list reproduces today's edges exactly (mirrors `test_derive_with_an_absent_key_matches_an_empty_mandate_read_list`, `test_blast_radius_mandate_reads.py:166-183`).
2. The path stays in `paths`; `derive_blast_radius`, `normalize_declared_radius`, `radius_from_observed_paths`, `validate_blast_radius`, and `detect_escaped_paths` do not read the key.
3. The exclusion applies inside `conflicts` / `Test-BlastRadiusConflict` only, which covers planner seeding (`parallel-plan/SKILL.md:310-314`), add-admission (`parallel-add/SKILL.md:62`), and drift recomputation (`parallel_drift_detection.py:499`) with one change per runtime.
4. Push-down must carry the key (`CARRIED_KEYS`); otherwise the destination copy silently lacks it and the feature is inert where it matters.
5. Module derivation must not emit a per-assembly module for a .NET layout, and must not fall back to top-level directories for such a layout (see Recommended Approach, decision 2).
6. The merge helper must run where the parallel-orchestrator can invoke it at a destination without Python, must never drop an entry, and must escalate on any non-mergeable conflicted path.
7. Every file touched stays under 500 lines; the files already near the limit are `test_blast_radius_config_parity.py` (500), `BlastRadiusConfig.Tests.ps1` (500), `test_blast_radius_config.py` (499), `BlastRadius.psm1` (496), `blast-radius-derive-core.test.ts` (483), `BlastRadiusConfig.psm1` (474), `blast-radius-derive.test.ts` (472), `derive-core.ts` (469), `_blast_radius_validation.py` (465), `claude-config-carriage.test.ts` (461).

**Mandatory unachievable objective callout**:

- Option A exactly as worded in the issue ("exclude `.csproj`/`.vbproj`-manifest directories from module derivation") is **not achievable on its own**: removing those suffixes from manifest classification makes `projectPaths` empty for a solution whose projects are top-level directories (the TaskMaster layout named in the issue), and `deriveDestinationModuleMap` then falls back to `topLevelDirectories(observations)` (`derive-core.ts:449-451`), which re-emits one module per project directory. The fallback must be suppressed when a .NET manifest was observed. The recommendation below (decision 2) includes that suppression.
- Running `dotnet csharpier check` and the analyzer build from the parallel-orchestrator is **not achievable under the current allowlist** (`parallel-orchestrator.md:5-22` grants no `dotnet`); the recommendation adds two narrowly scoped grants. Without them the formatter/analyzer step can only be performed by the child, which is the escalation path the issue asks to avoid.

## Recommended Approach

### Decision 1 — where the deterministic merge logic lives

**Recommendation: a PowerShell library under `.claude/lib/project-file-merge/`, published by push-down, invoked by the parallel-orchestrator through a single `pwsh -NoProfile -File` entry script.**

Files:

- `.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1` (new, ~220 lines): pure. Line and block grammars for the five MSBuild item types (`<Compile|Analyzer|None|Content|EmbeddedResource Include="..." />` on one line, plus the paired open/close form whose only children are `<DependentUpon>`, `<SubType>`, `<AutoGen>`, `<DesignTime>`, `<Link>`, `<CopyToOutputDirectory>`, `<Generator>`, `<LastGenOutput>`), the `<package id= version= ... />` line, and the `<dependentAssembly>...</dependentAssembly>` block keyed on `assemblyIdentity name`. Exposes `Get-MergeableUnit` (returns units with `Key`, `Version`, `Lines`) and `Compare-UnitVersion` (`[System.Version]` for four-part versions; escalate when either side is not `[System.Version]`-parseable, which covers prerelease NuGet versions conservatively).
- `.claude/lib/project-file-merge/ProjectFileMerge.psm1` (new, ~300 lines): pure. Conflict-hunk parser for both `merge` and `diff3`/`zdiff3` marker styles, keyed union per hunk, never-drop post-condition, and a report object.
- `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` (new, ~150 lines): the I/O boundary. Reads `config/blast-radius.json` for `mergeable_paths`, lists conflicted paths through the wrapper seam `Invoke-GitExe -GitArgs @('-C', $Worktree, 'diff', '--name-only', '--diff-filter=U')`, classifies them with `Test-MergeablePath` imported from the blast-radius library (so scheduling and merging share one matcher), reads stages 2 and 3 with `git -C <wt> show :2:<path>` / `:3:<path>` for the post-condition, writes the merged file with the original encoding, BOM, and line terminators preserved, and prints one JSON object on stdout (`{ "result": "resolved | escalate", "resolved": [...], "escalate_paths": [...] }`) following the drift CLI's single-object stdout contract (`parallel-orchestrate/SKILL.md:838-853`). It stages nothing and commits nothing.

Why PowerShell:

- The destination runtime has `pwsh` by construction: every hook in `.claude/settings.json` is `pwsh -NoProfile -File` (84-283), and the planner already requires `pwsh` for `Import-Module` (`parallel-plan/SKILL.md:189-190`). Python is not guaranteed at a destination (issue Constraints; `parallel-orchestrator.md:92-98` describes `poetry run` as the repository-local exception).
- `.claude/lib/**/*.psm1` is the established destination-portable library form (`core.json:113-136`), covered by Pester under `tests/scripts/claude-lib/<dir>/` and by the convention test that discovers new modules automatically.
- The wrapper-seam rule (`powershell.md:47-50`) gives a mockable git boundary, so the merge logic is unit-testable with checked-in fixtures and no temporary files.

Invocation and sequencing, inserted as a new first step of `## Per-Item Merge-Conflict Handling` (the existing steps 1-5 become the escalation path):

1. On a conflicted `gh pr merge --merge`, the parent runs `git -C <worktree_path> fetch origin main` and `git -C <worktree_path> merge --no-commit origin/main` (the same pair the child uses today, 351-352). The child is idle at DONE, so the worktree is clean.
2. The parent runs the entry script against the worktree. `escalate` (any conflicted path outside `mergeable_paths`, any hunk line outside the grammar, or an unparseable version pair) makes the parent run `git -C <worktree_path> merge --abort` and continue with the existing step 1 (child re-delegation with the Blocking finding); `escalate_paths` is included in that finding.
3. On `resolved`, the parent runs `git -C <worktree_path> add <resolved paths>` and `git -C <worktree_path> commit` with a message that lists every entry added and every version choice, then `dotnet tool restore --tool-manifest <worktree_path>/.config/dotnet-tools.json`, `dotnet csharpier check <worktree_path>`, and `dotnet build <worktree_path>/<solution>` (path arguments rather than `cd`, because the Bash tool's cwd resets and cd-chained commands are denied by `validate-bash.ps1`). A failing check reverts the commit (`git -C <worktree_path> reset --hard HEAD~1`) and escalates with the tool output as the finding.
4. On success the parent pushes the item branch, records `mergeable_conflicts_resolved` on the item, sets `merge_status: pr_open`, regenerates `parallel-status.md`, and re-enters `## Per-Item Merge to Main (Merge-on-Green)` at step 2 (durable `gh pr checks` confirmation to `ci_green`, then `gh pr merge`).

"Log it" concretely means four things, all inside the parent's existing write grants: the `version_resolutions` entries on the checkpoint record; the `## Mergeable Conflicts Resolved` projection section in `parallel-status.md`; the resolution commit message body; and one evidence artifact `docs/features/parallel/<slug>/evidence/other/mergeable-conflicts.<yyyy-MM-ddTHH-mm>.md` carrying `Timestamp`, `Command`, `EXIT_CODE`, and the script's JSON output (the parent cannot write into an item's feature folder: `Write(docs/features/parallel/**)` is its only docs grant).

Rejected alternatives:

- Python module under `scripts/dev_tools` invoked with `poetry run python -m`: the grant exists (`parallel-orchestrator.md:17`) and `lxml` is available (`pyproject.toml:27`), but the destination consumer that motivates the feature has no Python, so the helper would be unreachable exactly where it is needed.
- Bash under `.claude/lib/bash`: portable and allowlisted by shape, but the shell toolchain (`shell.md:10-20`) provides no XML parser and a line-oriented merge without a grammar guard is the "wrong merge" outcome the issue rates worse than escalation.
- Child-owned resolution (pass the helper to the child's remediation loop): keeps the parent's allowlist untouched, but it is precisely the escalation the issue asks to remove, and the record would then have to be relayed from a child checkpoint the parent never reads.

### Decision 2 — module derivation for .NET layouts

**Recommendation: treat the .NET manifest family as a structure signal that contributes no module and suppresses the top-level fallback (Option A, corrected).**

Concretely, in a new `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` (~120 lines, re-exported from derive-core so every existing import path and test import keeps working): `MANIFEST_FILENAMES` and `EXCLUDED_DIR_NAMES` move unchanged; `MANIFEST_SUFFIXES` is split into `MODULE_MANIFEST_SUFFIXES` (empty today) and `NON_MODULE_MANIFEST_SUFFIXES = [".csproj", ".fsproj", ".vbproj", ".sln", ".slnx"]`; `classifyProjectDirectories` returns `{ modulePaths, structureObserved }`; `deriveDestinationModuleMap` computes `derivedPaths = modulePaths.length > 0 ? modulePaths : structureObserved ? [] : topLevelDirectories(observations)`. `assembleModules` and `PAYLOAD_MODULES` are unchanged, so `config` is preserved, the assembled map stays non-empty, and `assertNoForbiddenGlob` keeps a non-vacuous input. The nine-`.csproj` fixture yields `{ "config": ["config/**"] }`.

Rationale: the granularity criterion (`parallel-orchestration.md:336-337`) and the doctrine that an over-matching module glob "costs concurrency on every pair of items it touches" (372-377). `.sln`/`.slnx` are included in the non-module family because, once project directories stop being modules, `pruneAncestors` no longer removes a nested solution directory and a `src/**` umbrella would reappear.

Rejected alternative (Option B, over-breadth gating of derived modules): derivation runs at push-down time as a pure function of directory observations (`derive-core.ts:21-31, 439-468`) with no run or item set available, so "more than `over_breadth_fraction` of the run's items" cannot be evaluated there. Moving the gate to planning time would make module membership vary with the item set, add a fourth reader of the truth table on the contention path in two runtimes, and overload a key whose defined meaning is V3's tracked-file fraction (`_blast_radius_thresholds.py:50-73`).

### Decision 3 — the three-way merge algorithm

**Recommendation: hunk-level keyed union over git's own conflict markers, verified by a never-drop post-condition against stages 2 and 3.**

- Sides: after `git merge --no-commit origin/main` in the item worktree, git has already merged every non-conflicting region; base/ours/theirs are `:1:`, `:2:`, `:3:` (gitrevisions, quoted above). A merge, not a rebase, is used because `gh pr merge --merge` lands a merge commit and a rebase would require a force push, which the Bash validator complicates.
- Hunk rule: for each `<<<<<<<` ... `=======` ... `>>>>>>>` hunk (skipping a `|||||||` base section when present), every line on both sides must parse as a mergeable unit (grammar above); otherwise the file escalates. Resolution = ours units in ours order, followed by theirs units whose key is not present in ours, in theirs order. Because git leaves unconflicted lines in place, base ordering is preserved outside hunks and each side's insertion order is preserved inside them; nothing is ever removed.
- Version rule: when the same key appears on both sides with different `version` (package) or `newVersion` (bindingRedirect), keep the unit with the higher `[System.Version]`, and for a bindingRedirect set `oldVersion`'s upper bound to the chosen `newVersion`; record `{key, ours, theirs, chosen}`. Same key, same version, different attributes → escalate.
- Post-condition (the "never drop" guarantee made checkable): the set of unit keys in the merged file must equal the union of unit keys in `:2:` and `:3:`, and every key present in `:1:` and in both sides must still be present. Any violation → escalate without writing.
- Byte preservation: operate on the conflicted worktree file's lines, keeping its BOM, encoding, and per-line terminator; never reserialize through an XML DOM, which would risk formatting drift in files CSharpier does not format.

### Decision 4 — the `mergeable_conflicts_resolved` record

Shape as documented above. It is additive and optional; no validator changes (Python, TypeScript, bash) are needed because no item-record validator rejects unknown keys. `.claude/rules/parallel-orchestration.md` gains a short paragraph in the Blast-Radius Contention Doctrine declaring the field tolerated and unvalidated, and the two "add no field" sentences are narrowed. Invariant 9 is untouched.

### Decision 5 — key-partition tests

`mergeable_paths` joins Class 1. Python: append to `BYTE_EQUAL_KEYS` (`blast_radius_parity_test_support.py:105`), which propagates to the parametrized byte-equal test and the exhaustiveness gate; the non-vacuity assertion for the new key goes into a new test module because `test_blast_radius_config_parity.py` is at 500 lines. Pester: append to `$script:ClassOneKeys` (`KeyPartition.Tests.ps1:30`), which propagates to both cases there; add a shape case beside the `mandate_reads` one in `BlastRadius.TruthTable.Tests.ps1:243-261`. TypeScript: append to `CARRIED_KEYS`, extend `SOURCE_BLAST_RADIUS` in `config-carriage.test-helpers.ts:86-118`, and add carriage cases modelled on `blast-radius-derive.test.ts:421-472` in a new test file (that file is at 472 lines).

## Implementation Guidance

- **Objectives**: remove `path_overlap` and `module_overlap` edges that arise only from .NET project files at a destination; resolve two-sided item-list conflicts mechanically in the parent; keep every radius, audit, and drift check unchanged; survive push-down.
- **Key Tasks**: (1) truth-table key in both copies; (2) Python reader/filter leaf module and the `conflicts` application; (3) PowerShell `BlastRadiusConflict.psm1` relocation plus filter, mirror, and `core.json`; (4) TypeScript carriage and the manifest split with fallback suppression; (5) merge library, entry script, mirror, `core.json`, agent allowlist, skill procedure, status template section; (6) rule-file doctrine text; (7) tests per the section below.
- **Dependencies**: none new. `lxml` is not needed. `[System.Version]` and `pwsh` are already present at every runtime that runs hooks.
- **Success Criteria**: every draft acceptance criterion in `issue.md:66-73` is covered by a named test below; all touched files remain under 500 lines; both truth-table copies pass the extended key-partition gates; the nine-`.csproj` fixture yields `{config}` only; a zero-edge run yields one cohort in Python and through `compute-cohorts.sh`.

## Automation Feasibility

No step of this feature requires human interaction with a third-party UI. Evidence:

- Every production change is a repository file under `config/`, `scripts/dev_tools/`, `.claude/`, `extensions/drm-copilot/`, and `docs/`; the consumer copies are explicitly out of scope (issue.md:21, 77).
- Every proposed test is hermetic: Python fixtures under `tests/fixtures/blast_radius/` are discovered by glob (`test_blast_radius_parity.py:174-176`); TypeScript cases use in-memory observation lists and the in-memory adapter (`blast-radius-derive-core.test.ts:29-33`; `config-carriage.test-helpers.ts:20-25`); Pester cases mock the `Invoke-GitExe` wrapper rather than git (`powershell.md:80-83`), so the merge helper's git reads are replaced by checked-in stage fixtures.
- Verification runs under the existing per-language toolchains (`python.md:13-18`, `typescript.md:13-18`, `powershell.md:15-20`) and CI. The only external system the feature touches at run time is GitHub through `gh`, which the parallel-orchestrator already uses (`parallel-orchestrator.md:15`); implementation and testing of this feature do not require it.

## Testing Implications

Mapped to the five required-change areas of `issue.md:25-62`. New Python test files follow the `tests/scripts/dev_tools/` mirror; new Pester files follow `tests/scripts/claude-lib/<dir>/`; new Jest files follow `extensions/drm-copilot/test/lib/push-down/`.

1. **Mergeable path class (Python, PowerShell, TypeScript carriage).**
   - New `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py`: reader present/absent/non-list/blank (mirroring `test_blast_radius_mandate_reads.py:87-130`); `conflicts` yields no edge for a `.csproj`-only overlap; both radii keep the `.csproj` in `paths`; a glob entry (`Proj/**`) against a `.csproj` still contends; absent key and empty list produce byte-identical `ConflictResult`s; the `**/` root-level matcher rule; `validate_blast_radius` findings unchanged with and without the key (V1/V2/V3); `detect_escaped_paths` unaffected; non-vacuity of the committed `mergeable_paths` in both copies (relocated from the full parity module).
   - New fixtures `tests/fixtures/blast_radius/conflict-mergeable-csproj-no-edge.json` and `conflict-mergeable-glob-still-contends.json`, consumed automatically by `test_blast_radius_parity.py` and `BlastRadius.Parity.Tests.ps1`.
   - New `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1` for `Get-ConfigMergeablePath`, `Test-MergeablePath`, `Get-NonMergeablePathEntry`, and the relocated overlap helpers (`BlastRadiusConfig.Tests.ps1` is at 500 lines and cannot host the reader cases).
   - Extend `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` (435 lines) with the no-edge and glob-still-contends cases against `Test-BlastRadiusConflict`.
   - New `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts`: carries `mergeable_paths` verbatim, emits it at the fixed position, omits it when absent (modelled on `blast-radius-derive.test.ts:421-472`); update the key-order assertions at `blast-radius-derive-core.test.ts:275-291` and `blast-radius-derive.test.ts:448-455`.
   - Extend `tests/scripts/dev_tools/test_blast_radius_mandate_reads.py` only if needed for symmetry; the drift test support under `tests/scripts/dev_tools/` gains one case asserting `recompute_conflicts_with_observed` reports no new pair for a `.csproj`-only observed overlap.
2. **Module derivation.**
   - New `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts`: the nine-`.csproj`-directory fixture (nine sibling observations each carrying `<Name>.csproj`, plus the root) yields exactly `{ config: ["config/**"] }`; a `.sln` in a nested directory yields no module; a mixed layout (`tools/package.json` plus `.csproj` directories) yields `tools` and `config` only; suffix classification splits into module and non-module families.
   - Rewrite the cases that currently expect a `.csproj` module: `blast-radius-derive-core.test.ts:92-99, 118-124, 193-207`; `blast-radius-derive.test.ts:186-203, 393-401`; `claude-config-carriage.test.ts:301-324, 371-379` and `SRC_APP_LAYOUT` (`config-carriage.test-helpers.ts:222-228`) switch to a non-.NET manifest such as `go.mod` so the "derived document differs from the source" property still holds.
   - `tests/scripts/dev_tools/blast_radius_parity_test_support.py:101` (`PAYLOAD_MODULE_NAMES`) is unchanged.
3. **Merge step.**
   - New `tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1` and `ProjectFileMerge.Tests.ps1`: one fixture pair per item type (`Compile`, `Analyzer`, `None`, `Content`, `EmbeddedResource`; single-line and paired-form units), `packages.config` (disjoint ids; same id with higher-version resolution; unparseable version escalates), `app.config` (`dependentAssembly` block union; same assembly with differing `newVersion`), `diff3`-style hunks, a hunk containing a non-grammar line (escalates), a conflicted `.cs` beside a `.csproj` (escalates, names the path), the never-drop post-condition against injected stage texts, and byte preservation (BOM, CRLF). Conflicted-file fixtures live under `tests/fixtures/project_file_merge/` as checked-in text, with `Invoke-GitExe` mocked to return stage texts (`powershell.md:80-83`).
   - New `tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1` (script-level): classification against the committed `mergeable_paths`, JSON stdout shape, `escalate` when any path is non-mergeable, no write on escalate.
   - The existing convention test `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` discovers the two new modules automatically.
4. **Barrier hook and Layer-2 validator.**
   - New case in `test_blast_radius_mergeable_paths.py` (or a small `test_parallel_mergeable_cohort.py`): four items whose only overlaps are `.csproj` files → `conflicts` yields no edge for any pair → `compute_cohorts(keys, [])` returns one cohort holding all four keys; and one case in `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` confirming `compute-cohorts.sh --keys "796 797 798 799" --edges ""` prints `[[796,797,798,799]]` (the existing empty-edge path, cited rather than reimplemented).
   - No change to `enforce-parallel-cohort-barrier.ps1` tests or `_parallel_orchestrator_state_cohort_barrier.py` tests.
5. **Parity gates.**
   - `test_blast_radius_config_parity.py` gains coverage of the new key through `BYTE_EQUAL_KEYS` with no edit to the file; `BlastRadius.KeyPartition.Tests.ps1:30` and `BlastRadius.TruthTable.Tests.ps1` (shape case) are edited; the mirror-file parity tests that enumerate `.claude/lib` (`tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py` and `test_claude_planning_integrity_contracts.py` reference the bundled `.claude` tree) must be run after the `core.json` additions.
   - Checkpoint-record tolerance: one case in the existing parallel-orchestrator-state validator tests asserting that an item carrying `mergeable_conflicts_resolved` produces zero errors in Python and in the TypeScript core.

## Requirements Mapping

Production files (approximate line impact; the 500-line limit is respected by splitting where noted):

| File | Change | Size |
| --- | --- | --- |
| `config/blast-radius.json` | add `mergeable_paths` after `mandate_reads` | +7 (43 → 50) |
| `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` | same, byte-equal | +7 (29 → 36) |
| `scripts/dev_tools/_blast_radius_mergeable.py` | NEW leaf: `CONFIG_MERGEABLE_PATHS`, `config_mergeable_paths`, `matches_mergeable_path` (delegates to `matches_mandate_read` plus the `**/` rule), `exclude_mergeable_paths` | ~110 |
| `scripts/dev_tools/_blast_radius_conflicts.py` | filter both path sets in `conflicts`; docstring | +12 (242 → ~254) |
| `scripts/dev_tools/compute_blast_radius.py` | re-export the reader | +4 (420 → ~424) |
| `.claude/lib/blast-radius/BlastRadiusConflict.psm1` | NEW: `Get-ConfigMergeablePath`, `Test-MergeablePath`, `Get-NonMergeablePathEntry`, relocated `Get-SmallestPathOverlap` and `Get-SmallestCommonEntry` | ~190 |
| `.claude/lib/blast-radius/BlastRadius.psm1` | import the new module; remove the two relocated helpers; filter in `Test-BlastRadiusConflict`; docstring | -50 (496 → ~446) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/*.psm1` | mirror of the two files above | same |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add `BlastRadiusConflict.psm1` and the three project-file-merge files | +4 |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` | NEW: manifest constants and predicates, `NON_MODULE_MANIFEST_SUFFIXES`, classification returning `{modulePaths, structureObserved}` | ~130 |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` | re-export from the new module; fallback suppression; `CARRIED_KEYS` append; output literal | -60 net (469 → ~410) |
| `.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1` | NEW pure grammar | ~220 |
| `.claude/lib/project-file-merge/ProjectFileMerge.psm1` | NEW pure hunk union and post-condition | ~300 |
| `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` | NEW I/O entry with `Invoke-GitExe` seam and JSON stdout | ~150 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/*` | mirrors | same |
| `.claude/agents/parallel-orchestrator.md` (+ mirror) | four allowlist entries; prose on the merge step and the optional field | +25 |
| `.claude/skills/parallel-orchestrate/SKILL.md` (+ mirror) | new first step block in `## Per-Item Merge-Conflict Handling`; new projection section in `## Documentation Maintenance Boundaries`; narrow the "add no field" sentence | +45 (markdown, exempt) |
| `.claude/rules/parallel-orchestration.md` (+ mirror) | `### Mechanically-mergeable path class (issue #643)` with the three constraints; .NET non-module derivation paragraph; byte-equal sentence at 369-370; optional item field paragraph | +40 (markdown, exempt) |
| `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md` (+ mirrors) | one sentence each: the relation now reads `mergeable_paths` | +3 each |
| `docs/features/templates/parallel/parallel-status.md` | `## Mergeable Conflicts Resolved` section | +9 |

Test files:

| File | Change | Size |
| --- | --- | --- |
| `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` | NEW (area 1, 4, and the non-vacuity floor) | ~260 |
| `tests/fixtures/blast_radius/conflict-mergeable-csproj-no-edge.json`, `conflict-mergeable-glob-still-contends.json` | NEW | ~45 each |
| `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | `BYTE_EQUAL_KEYS` append | +1 |
| `tests/scripts/dev_tools/test_blast_radius_parity.py` | none (glob discovery) | 0 |
| `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` | one empty-edge four-key case if not already present | +15 |
| parallel-orchestrator-state validator tests (Python and `extensions/drm-copilot/test/lib/validate/`) | one tolerance case each | +20 |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1` | NEW | ~220 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1` | two cases; reword 29-30 | +40 (435 → ~475) |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | line 30 append | +1 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | shape case for the new key | +18 (325 → ~343) |
| `tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1`, `ProjectFileMerge.Tests.ps1`, `Resolve-MergeableConflict.Tests.ps1` | NEW | ~300, ~380, ~200 |
| `tests/fixtures/project_file_merge/*` | NEW conflicted-file and stage fixtures per item type | text fixtures |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts` | NEW carriage cases | ~120 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts` | NEW nine-`.csproj` fixture and family split | ~180 |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` | rewrite 92-99, 118-124, 193-207; key-order at 275-291 | ~0 net |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive.test.ts` | rewrite 186-203, 393-401; key-order at 448-455 | ~0 net |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | rewrite 301-324, 371-379 | ~0 net |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | `SOURCE_BLAST_RADIUS` key; `SRC_APP_LAYOUT` manifest switch | +8 |

Where new code must go to stay under the limit: no reader in `BlastRadiusConfig.psm1` (474) or `_blast_radius_validation.py` (465); no new cases in `test_blast_radius_config_parity.py` (500), `BlastRadiusConfig.Tests.ps1` (500), or `test_blast_radius_config.py` (499); no additions to `BlastRadius.psm1` without the relocation above; the derive-core edit must be paired with the manifest split.

## Numeric Derivation Evidence

The recommendation asserts that filtering inside the contention relation covers every production edge producer. That assertion rests on one countable family per runtime.

### Family: production call sites of the Python contention relation

- Complete Family: every non-test Python location that invokes `conflicts(...)` from `scripts/dev_tools/_blast_radius_conflicts.py`.
- Exhaustive Search Scope: `scripts/**/*.py` (all production Python; tests excluded by scope).
- Inclusion Rules: a line that calls the relation (an invocation, not a definition and not prose).
- Exclusion Rules: the `def conflicts(` line; docstring or comment mentions.
- Primary Search Strategy or Query Expression: ripgrep `conflicts\(` over `scripts/**/*.py`, then classify each hit by reading the line.
- Primary Member Set: `scripts/dev_tools/parallel_drift_detection.py:499` (call). Non-members observed and excluded: `_blast_radius_conflicts.py:140` (docstring), `:152` (definition), `parallel_mutation_protocol.py:35,151` (docstrings stating "never calls it"), `parallel_cohort_computation.py:29` (docstring).
- Primary Count: 1.
- Cross-check Search Strategy or Query Expression: import-site enumeration — ripgrep (multiline) for import statements naming `conflicts` from `scripts.dev_tools.compute_blast_radius` or `scripts.dev_tools._blast_radius_conflicts`, then read each importing module for its use.
- Cross-check Member Set: `scripts/dev_tools/parallel_drift_detection.py:57-60` (imports and calls at 499); `scripts/dev_tools/compute_blast_radius.py:35-38` (imports for re-export only, `__all__` at 64-75; no call).
- Cross-check Count: 1.
- Member-set Comparison: normalized sets are identical (`{parallel_drift_detection.py}`); the facade re-export is excluded by both rule sets. Assertion admitted: one Python production caller, and it is the drift recomputation, so the exclusion inside `conflicts` also governs drift.

### Family: procedural consumers of the PowerShell contention relation

- Complete Family: every `.claude/**` or `scripts/**` file that names `Test-BlastRadiusConflict` other than its defining module.
- Exhaustive Search Scope: `.claude/**` and `scripts/**` (the destination-runtime surface and the self-hosted scripts; bundled mirrors are byte copies and excluded from the count).
- Inclusion Rules: a file naming the function as the relation to apply.
- Exclusion Rules: `.claude/lib/blast-radius/BlastRadius.psm1` (definition and export).
- Primary Search Strategy or Query Expression: ripgrep `Test-BlastRadiusConflict` with line output.
- Primary Member Set: `.claude/skills/parallel-plan/SKILL.md` (195, 312), `.claude/skills/parallel-add/SKILL.md` (62), `.claude/agents/parallel-planner.md` (160).
- Primary Count: 3.
- Cross-check Search Strategy or Query Expression: ripgrep for the bare noun `BlastRadiusConflict` (which would also catch any `Get-`/`Resolve-` variant) in files-with-matches mode, then subtract the defining module.
- Cross-check Member Set: `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/agents/parallel-planner.md` (and `.claude/lib/blast-radius/BlastRadius.psm1`, excluded).
- Cross-check Count: 3.
- Member-set Comparison: identical. Assertion admitted: seeding and add-admission both reach the relation through `Test-BlastRadiusConflict`, so one PowerShell change covers both.

No other numeric claim in this document is proposed as a `spec.md` acceptance-criterion fact; the "nine `.csproj` directories" and "zero edges, single cohort" values are test-fixture parameters taken from `issue.md:60, 72`, not derived populations.
