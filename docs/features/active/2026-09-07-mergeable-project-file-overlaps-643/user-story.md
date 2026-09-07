# `2026-09-07-mergeable-project-file-overlaps` — User Story

- Issue: #643
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-09-07T10-40

## Story Statement

- As the operator of a parallel run on a .NET consumer repository, I want two items that only add files to the same `.csproj` item list to be scheduled in the same cohort, so that unrelated work is not serialized by a file overlap that has a deterministic merge.
- As the operator of a parallel run on a .NET consumer repository, I want the module map at a destination to name subsystems rather than assemblies, so that two items in the same assembly do not contend merely because they share a project directory.
- As the operator of a parallel run on a .NET consumer repository, I want the orchestrator to resolve a merge conflict confined to project files itself and record what it merged, so that a routine two-sided item-list insertion does not cost a child re-delegation and a remediation cycle.

## Problem / Why

On 2026-09-07 the TaskMaster run `bugs-2026-09-06` (issues 796, 797, 798, 799) was serialized into three cohorts by five conflict edges. Every edge rested on exactly two things:

- `path_overlap` on a non-SDK project file (`QuickFiler.Test/QuickFiler.Test.csproj`, `TaskMaster.Test/TaskMaster.Test.csproj`, `UtilitiesCS.Test/UtilitiesCS.Test.csproj`), because each item adds a new `.cs` file and every project in the consumer repository carries an explicit `<Compile Include>` list;
- `module_overlap` on the assembly that owns that project (`QuickFiler`, `TaskMaster`, `UtilitiesCS`), because the destination module map is derived from every manifest-bearing directory, so each `.csproj` directory becomes its own module.

Items 796 and 797 share no path and no module and could have run alongside 799 from the start. The maintainer's ruling: "Project files will always overlap. You should always be able to determine how to merge project files upon rebasing and merging with main." A two-sided insertion into one XML item list is a deterministic merge (union both sides, keep ordering), not contention.

This is the same defect class as closed TaskMaster #545 and the earlier local removal of the assembly-level module map, which the next push-down restored. The fix must land in `drm-copilot` so it survives push-down. The consumer copies (`config/blast-radius.json`, `.claude/hooks/enforce-parallel-cohort-barrier.ps1`) are not patched directly.

### Why neither signal is contention

A conflict edge exists to prevent two items from producing a result that cannot be reconciled. Neither signal here meets that bar.

- A project-file overlap in a non-SDK .NET repository is structural, not semantic. Adding any source file requires an `<Compile Include>` entry, so every item that adds a file touches its project file. Two such items insert different entries into the same list; the reconciliation is the union of the two entry sets with each side's ordering preserved, and it is decidable without reading either item's intent. Treating a signal that fires for almost every item as contention removes concurrency without removing risk.
- A per-assembly module is an over-broad unit of contention. The module level exists to catch two items working on the same subsystem. When a module is derived from every `.csproj` directory, it names an assembly, and every item that edits any file in that assembly matches it. Under the module-map granularity criterion already recorded in the rule file, a candidate that matches the majority of work items belongs nowhere; the per-assembly module is exactly that candidate.

Removing both signals never weakens the relation below the path level: two items that edit the same `.cs` file still contend on `path_overlap`, two items that edit a declared shared surface still contend on `shared_surface_overlap`, and the project file stays in each item's declared radius, so drift detection still catches an item that wrote a path it did not declare.

## Personas & Scenarios

- Persona: the parallel-run operator on a .NET consumer repository (TaskMaster).
  - Who they are: the maintainer who opens a batch of independent bug issues, runs `parallel-plan` to seed the conflict graph and cohorts, and then supervises `parallel-orchestrate` while it executes items, opens pull requests, and merges on green.
  - What they care about: wall-clock time to land the batch, and confidence that concurrency was constrained only where two items could actually damage each other's work.
  - Their constraints: the repository is a non-SDK .NET solution where every project carries an explicit item list; the runtime is delivered by push-down from `drm-copilot`, so local edits to `config/blast-radius.json` or to the cohort-barrier hook are overwritten by the next push-down; `pwsh` and the .NET toolchain are available, Python is not.
  - Their goals and frustrations: they expect four unrelated bug fixes to run as one cohort. They observed them split into three, and every edge that caused the split named a project file or an assembly-shaped module. They also expect a conflict on a project file at merge time to be handled mechanically, rather than sending the item back through a remediation loop.
  - Their context and motivations: the same map was removed locally once before and came back with the next push-down, so a fix that is not in `drm-copilot` and not published does not hold.

- Scenario: four independent bug items, each adding one test file.
  - Who is acting: the operator, then the orchestrator on their behalf.
  - What triggers it: the operator opens four bug issues in the consumer repository and starts a parallel run.
  - Steps: the planner derives each item's blast radius. Each radius lists a new `.cs` file and the `.csproj` of the project that owns it. The relation compares each pair: the `.cs` files are distinct, so no path edge; the shared `.csproj` matches the published `mergeable_paths` list, so it contributes no path edge; the destination module map names subsystems, not assemblies, so no module edge. The edge list is empty and all four items land in one cohort. The orchestrator launches them together.
  - Obstacles and decisions: one item's pull request cannot merge because `origin/main` moved and another item already added its own entry to the same `<Compile Include>` list. The orchestrator merges `origin/main` into that item's worktree, runs the project-file merge helper, and finds the only conflicted path is the `.csproj`. It unions the two entry sets, verifies that no entry from either side was lost, commits the resolution, runs the formatter check and the analyzer build, and re-confirms CI. Had the conflict set also contained a `.cs` file, or any line the grammar does not recognise, the helper would have declined and the orchestrator would have escalated to the child exactly as it does today.
  - Expected outcome: all four items merge; the run status projection and the pull request body state which project file was merged and which entries came from each side; the operator sees one cohort where they previously saw three, and no manual conflict resolution.

## Acceptance Criteria

- [x] For a set of items whose only shared paths are project files matching the published `mergeable_paths` list, the operator observes an empty conflict-edge list in the run's projection.
- [x] Those items are placed in a single cohort and are launched together, rather than being serialized across cohorts.
- [x] Each item's declared blast radius still lists the project file it touches, so the operator can see the write and drift detection still reports an undeclared write.
- [x] Two items in the same assembly, touching different files, produce no `module_overlap` edge; the destination module map the operator receives from push-down names no per-assembly module.
- [x] The operator receives the behavior through a normal push-down: no manual edit to the consumer repository's `config/blast-radius.json` or cohort-barrier hook is required, and the behavior survives the next push-down.
- [x] When a pull request cannot merge because of a conflict confined to project files, the orchestrator resolves it without re-delegating the item, and every entry present on either side is present in the merged file.
- [x] When the same package or binding-redirect entry appears on both sides at differing versions, the higher version is selected and the choice is reported to the operator.
- [x] When the conflict set contains any path outside the mergeable list, or any line the merge grammar does not recognise, the orchestrator escalates as it does today and names the paths that caused the escalation.
- [x] After a resolution the orchestrator runs the formatter check and the analyzer build before re-confirming CI, and reverts the resolution and escalates if either fails.
- [x] The resolution is cited where the operator reads run outcomes: the `## Mergeable Conflicts Resolved` section of the run status projection, the pull request body, the resolution commit message, and an evidence artifact under the run's evidence folder.
- [x] A run in which no project-file conflict occurs, or a destination whose truth table lacks the `mergeable_paths` key, behaves exactly as it does today; the operator sees no change in cohorts or escalations.

## Non-Goals

- The consumer repository's own copies are not patched. `config/blast-radius.json` and `.claude/hooks/enforce-parallel-cohort-barrier.ps1` in a destination are changed only by the next push-down of `drm-copilot` sources and published resources.
- `PARALLEL_COHORT_BARRIER_VIOLATION` semantics are unchanged. The barrier hook is not modified and continues to read `conflict_edges[]` neighbours only; the operator sees the same violation behavior for any edge that does exist.
- The mergeable class does not suppress any other contention level. Path overlaps on non-mergeable files, shared-surface overlaps, contract overlaps, and module overlaps outside the .NET manifest family are unaffected.
- Automatic resolution of semantic conflicts inside a project file (for example the same entry added with differing metadata) is out of scope; those escalate.
- SDK-style projects that carry no explicit item list need no handling and are unaffected.
