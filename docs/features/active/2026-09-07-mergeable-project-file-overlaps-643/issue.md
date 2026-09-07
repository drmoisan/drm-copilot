# mergeable-project-file-overlaps (Issue #643)

- Date captured: 2026-09-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/mergeable-project-file-overlaps/ (Issue #643)

- Issue: #643
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/643
- Last Updated: 2026-09-07
- Work Mode: full-feature

## Problem / Why

On 2026-09-07 the TaskMaster run `bugs-2026-09-06` (issues 796, 797, 798, 799) was serialized into three cohorts by five conflict edges. Every edge rested on exactly two things:

- `path_overlap` on a non-SDK project file (`QuickFiler.Test/QuickFiler.Test.csproj`, `TaskMaster.Test/TaskMaster.Test.csproj`, `UtilitiesCS.Test/UtilitiesCS.Test.csproj`), because each item adds a new `.cs` file and every project in the consumer repository carries an explicit `<Compile Include>` list;
- `module_overlap` on the assembly that owns that project (`QuickFiler`, `TaskMaster`, `UtilitiesCS`), because the destination module map is derived from every manifest-bearing directory, so each `.csproj` directory becomes its own module.

Items 796 and 797 share no path and no module and could have run alongside 799 from the start. The maintainer's ruling: "Project files will always overlap. You should always be able to determine how to merge project files upon rebasing and merging with main." A two-sided insertion into one XML item list is a deterministic merge (union both sides, keep ordering), not contention.

This is the same defect class as closed TaskMaster #545 and the earlier local removal of the assembly-level module map, which the next push-down restored. The fix must land in `drm-copilot` so it survives push-down. The consumer copies (`config/blast-radius.json`, `.claude/hooks/enforce-parallel-cohort-barrier.ps1`) are not patched directly.

## Proposed Behavior

### 1. Mechanically-mergeable path class in the blast-radius truth table

Add an optional `mergeable_paths` list to `config/blast-radius.json` (both the self-hosted copy and the published copy under `extensions/drm-copilot/resources/claude-customizations/config/`), fail-closed when absent, with the published default:

```json
"mergeable_paths": ["**/*.csproj", "**/packages.config", "**/app.config", "**/*.vbproj", "**/*.props"]
```

Semantics, enforced in `derive_blast_radius` / `validate_blast_radius` and the TypeScript parity port:

- A path matching `mergeable_paths` stays in the item's declared `paths` (drift detection and the V1/V2/V3 audits still see it), but it contributes no `path_overlap` conflict edge.
- Document it in `.claude/rules/parallel-orchestration.md` under the Blast-Radius Contention Doctrine, next to `mandate_reads`, with the same three constraints: the planner still enumerates the write explicitly; the path stays in the declared radius; `detect_escaped_paths` remains the backstop.

### 2. Do not derive one module per C# project directory

`assembleModules` (`claude-blast-radius-derive-core.ts`) turns every manifest-bearing directory into a module. For a .NET solution that means every assembly is a module and any two items in the same assembly conflict, which violates the module-map granularity criterion already recorded in the rule file ("a candidate that matches the majority of work items belongs nowhere").

Required: exclude `.csproj`/`.vbproj`-manifest directories from module derivation (keep `config` and any explicitly declared module), or gate derived modules on the over-breadth fraction so a module that would match more than `over_breadth_fraction` of the run's items is dropped with a logged reason. Either way, the resulting TaskMaster map must not contain per-assembly modules.

### 3. Deterministic project-file merge in the parallel-orchestrator merge step

`parallel-orchestrate`'s per-item merge-conflict handling must resolve a conflict confined to `mergeable_paths` without escalating:

- For MSBuild item-list conflicts (`<Compile Include>`, `<Analyzer Include>`, `<None Include>`, `<Content Include>`, `<EmbeddedResource Include>`), take the union of both sides' entries, preserving the base ordering and appending new entries where each side inserted them; never drop an entry.
- For `packages.config` / `app.config` (`<package>` and `<bindingRedirect>` entries), same union rule keyed on `id` / `name`; on a version disagreement for the same id, take the higher version and log it.
- After resolution run `dotnet tool run csharpier check .` and the analyzer build before re-confirming CI on the new head. A conflict touching any non-mergeable path still escalates as today.
- Record the resolution on the item under a `mergeable_conflicts_resolved` list (path, entries added from each side) so the projection and the PR body can cite it.

### 4. Barrier hook and Layer-2 validator follow the graph

No change to `enforce-parallel-cohort-barrier.ps1` or `PARALLEL_COHORT_BARRIER_VIOLATION` is needed once edges no longer exist for mergeable paths; confirm with a test that a run whose only overlaps are `.csproj` files produces zero edges and a single cohort.

### 5. Tests and parity

- Python and TypeScript: `mergeable_paths` present/absent; `.csproj` overlap yields no edge; the path is still in `paths`; V1/V2/V3 unaffected; key-partition parity test extended with the new key in both copies.
- Module derivation: a fixture with nine `.csproj` directories yields no per-assembly modules.
- Merge step: fixture conflicts for each item type above resolve to the union; a non-mergeable path in the same conflict set escalates.
- Pester mirror of the key-partition test.

## Acceptance Criteria (early draft)

- [ ] `config/blast-radius.json` (self-hosted) and the published copy both carry the `mergeable_paths` key with the default list above, and the key is optional and fail-closed (absent excludes nothing).
- [ ] `derive_blast_radius` / `validate_blast_radius` (Python), the TypeScript parity port, and the PowerShell runtime library treat a `mergeable_paths` match as contributing no `path_overlap` edge while keeping the path in the declared `paths`.
- [ ] V1/V2/V3 audits and `detect_escaped_paths` are unaffected by `mergeable_paths`.
- [ ] `.claude/rules/parallel-orchestration.md` documents `mergeable_paths` under the Blast-Radius Contention Doctrine with the three constraints.
- [ ] `assembleModules` in `claude-blast-radius-derive-core.ts` does not produce per-assembly modules for `.csproj`/`.vbproj` manifest directories; a nine-`.csproj` fixture yields no per-assembly module.
- [ ] The `parallel-orchestrate` merge step resolves conflicts confined to `mergeable_paths` by deterministic union merge (MSBuild item lists; `packages.config`/`app.config` keyed entries with higher-version rule), runs the formatter check and analyzer build after resolution, escalates when any non-mergeable path is in the conflict set, and records `mergeable_conflicts_resolved` on the item.
- [ ] A test confirms that a run whose only overlaps are `.csproj` files produces zero conflict edges and a single cohort.
- [ ] Key-partition parity tests (Python and Pester mirror) are extended with `mergeable_paths` in both copies.

## Constraints & Risks

- The fix must survive push-down: only `drm-copilot` sources and the published resources are changed; consumer copies are not patched.
- Three-language parity (Python, TypeScript, PowerShell) must be preserved for the blast-radius contract.
- The merge step must never drop an item-list entry; a wrong merge is worse than an escalation.
- `mergeable_paths` must not weaken drift detection: the path stays in the declared radius.

## Test Conditions to Consider

- [ ] Unit coverage: `mergeable_paths` present/absent; `.csproj` overlap yields no edge; path remains in `paths`; V1/V2/V3 unaffected.
- [ ] Module derivation fixture with nine `.csproj` directories.
- [ ] Merge-step fixtures per item type; non-mergeable path escalates.
- [ ] Key-partition parity (Python, TypeScript, Pester).
- [ ] Zero-edge single-cohort run whose only overlaps are `.csproj` files.

## Evidence

- Run status: `docs/features/parallel/bugs-2026-09-06/parallel-status.md` on `origin/TaskMaster-wt-2026-09-06T17-16` (edges table, cohorts 0/1/2).
- Consumer module map as pushed down: `config/blast-radius.json` `modules` = one entry per assembly (QuickFiler, QuickFiler.Test, ..., VBFunctions.Test) plus `config`.
- Prior local removal of the same map: TaskMaster commit `7e6e6740` (branch `TaskMaster-wt-2026-09-02T08-47`), overwritten by the following push-down.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/mergeable-project-file-overlaps/` folder from the template
