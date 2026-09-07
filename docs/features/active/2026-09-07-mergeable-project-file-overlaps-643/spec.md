# 2026-09-07-mergeable-project-file-overlaps — Spec

- **Issue:** #643
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-07T10-40
- **Status:** Draft
- **Version:** 0.2

## Overview

On 2026-09-07 the TaskMaster run `bugs-2026-09-06` (issues 796, 797, 798, 799) was serialized into three cohorts by five conflict edges. Every edge rested on exactly two things:

- `path_overlap` on a non-SDK project file (`QuickFiler.Test/QuickFiler.Test.csproj`, `TaskMaster.Test/TaskMaster.Test.csproj`, `UtilitiesCS.Test/UtilitiesCS.Test.csproj`), because each item adds a new `.cs` file and every project in the consumer repository carries an explicit `<Compile Include>` list;
- `module_overlap` on the assembly that owns that project (`QuickFiler`, `TaskMaster`, `UtilitiesCS`), because the destination module map is derived from every manifest-bearing directory, so each `.csproj` directory becomes its own module.

Items 796 and 797 share no path and no module and could have run alongside 799 from the start. The maintainer's ruling: "Project files will always overlap. You should always be able to determine how to merge project files upon rebasing and merging with main." A two-sided insertion into one XML item list is a deterministic merge (union both sides, keep ordering), not contention.

This is the same defect class as closed TaskMaster #545 and the earlier local removal of the assembly-level module map, which the next push-down restored. The fix must land in `drm-copilot` so it survives push-down. The consumer copies (`config/blast-radius.json`, `.claude/hooks/enforce-parallel-cohort-barrier.ps1`) are not patched directly.

The design below is the one settled in `research/2026-09-07T09-45-mergeable-project-file-overlaps-research.md`. Its four decisions are treated here as fixed and are not reopened: the merge step is a PowerShell library under `.claude/lib/project-file-merge/`; module derivation treats the .NET manifest family as a structure signal that yields no module and suppresses the top-level-directory fallback; the merge algorithm is a hunk-level keyed union over git's own conflict markers with a higher-version rule and a never-drop post-condition; and `mergeable_conflicts_resolved` is an optional additive item record.

## Behavior

### 1. Mechanically-mergeable path class in the blast-radius truth table

Add an optional `mergeable_paths` list to both truth-table copies — `config/blast-radius.json` and the published copy at `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` — byte-equal (Class 1), with the default list:

```json
"mergeable_paths": ["**/*.csproj", "**/packages.config", "**/app.config", "**/*.vbproj", "**/*.props"]
```

Semantics:

- The key is optional and fail-closed. A truth table that omits it, or carries an empty list, excludes nothing and reproduces current edges exactly.
- A path matching `mergeable_paths` stays in the item's declared `paths`. Derivation, normalization, observed-radius construction, the V1/V2/V3 audits, and `detect_escaped_paths` do not read the key and are unchanged.
- The exclusion is applied at exactly one place per runtime — inside the contention relation, immediately before the path-overlap computation:
  - Python: `conflicts` in `scripts/dev_tools/_blast_radius_conflicts.py`, filtering both radii's `paths` before `_smallest_path_overlap`.
  - PowerShell: `Test-BlastRadiusConflict` in `.claude/lib/blast-radius/BlastRadius.psm1`, filtering both path arrays before `Get-SmallestPathOverlap`.
- Reader and matcher live in new leaf modules, not in the files already near the 500-line limit:
  - `scripts/dev_tools/_blast_radius_mergeable.py` — `CONFIG_MERGEABLE_PATHS`, `config_mergeable_paths`, `matches_mergeable_path`, `exclude_mergeable_paths`. The reader has the `config_string_list` shape (absent key yields an empty tuple; a non-list or blank entry is rejected). The matcher has the `matches_mandate_read` semantics: exact ordinal equality first, then glob containment for a concrete entry only, so a declared glob entry is never treated as mergeable.
  - `.claude/lib/blast-radius/BlastRadiusConflict.psm1` — `Get-ConfigMergeablePath`, `Test-MergeablePath`, `Get-NonMergeablePathEntry`, plus the relocated `Get-SmallestPathOverlap` and `Get-SmallestCommonEntry`.
- Matcher residual, handled locally: the shared glob translation compiles a leading `**/` to a form that requires a separator, so a root-level `packages.config` would not match. The mergeable matcher additionally tests a `**/`-prefixed pattern with that prefix removed. `_glob_to_regex_text` and its PowerShell mirror are not modified.
- TypeScript carries the key verbatim through push-down: `mergeable_paths` is appended to `CARRIED_KEYS` in `claude-blast-radius-derive-core.ts` and emitted at the corresponding fixed position in the destination document. There is no TypeScript contention relation to port.
- `.claude/rules/parallel-orchestration.md` documents the class under the Blast-Radius Contention Doctrine, beside `mandate_reads`, with the same three constraints, and updates the key-partition sentence that currently names only `version`, `over_breadth_fraction`, and `mandate_reads` as byte-equal.

### 2. Do not derive one module per C# project directory

The .NET manifest family is treated as a structure signal: it marks a directory as a project root but contributes no module, and its presence suppresses the top-level-directory fallback.

- New `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` holds the manifest constants and predicates, re-exported from `claude-blast-radius-derive-core.ts` so every existing import path and test import keeps working.
- `MANIFEST_SUFFIXES` splits into `MODULE_MANIFEST_SUFFIXES` (empty at this change) and `NON_MODULE_MANIFEST_SUFFIXES` = `.csproj`, `.fsproj`, `.vbproj`, `.sln`, `.slnx`. `.sln`/`.slnx` join the non-module family because, once project directories stop being modules, ancestor pruning no longer removes a nested solution directory and an umbrella glob would reappear.
- `classifyProjectDirectories` returns `{ modulePaths, structureObserved }`. `deriveDestinationModuleMap` computes `derivedPaths = modulePaths.length > 0 ? modulePaths : structureObserved ? [] : topLevelDirectories(observations)`, which is the fallback suppression.
- `assembleModules` and `PAYLOAD_MODULES` are unchanged, so `config` is preserved, the assembled map stays non-empty, and the forbidden-glob guard keeps a non-vacuous input. For a .NET solution layout the derived map is exactly `{ "config": ["config/**"] }`.

The rejected alternative is over-breadth gating of derived modules: derivation runs at push-down time as a pure function of directory observations, with no run or item set available, so a fraction of "the run's items" cannot be evaluated there.

### 3. Deterministic project-file merge in the parallel-orchestrator merge step

A new PowerShell library resolves a conflict confined to `mergeable_paths` in the parent, without re-delegating the child:

- `.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1` (pure) — line and block grammars for the MSBuild item types `Compile`, `Analyzer`, `None`, `Content`, and `EmbeddedResource` (single-line `Include` form and the paired open/close form whose only children are `DependentUpon`, `SubType`, `AutoGen`, `DesignTime`, `Link`, `CopyToOutputDirectory`, `Generator`, `LastGenOutput`), the `<package id= version= />` line, and the `<dependentAssembly>` block keyed on `assemblyIdentity name`. Exposes `Get-MergeableUnit` (`Key`, `Version`, `Lines`) and `Compare-UnitVersion` (`[System.Version]`; an unparseable version on either side escalates).
- `.claude/lib/project-file-merge/ProjectFileMerge.psm1` (pure) — conflict-hunk parser for both `merge` and `diff3`/`zdiff3` marker styles, keyed union per hunk, never-drop post-condition, and a report object.
- `.claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` — the I/O boundary. Reads `mergeable_paths` from `config/blast-radius.json`, lists conflicted paths through the wrapper seam `Invoke-GitExe -GitArgs @('-C', $Worktree, 'diff', '--name-only', '--diff-filter=U')`, classifies them with the blast-radius matcher so scheduling and merging share one matcher, reads stages `:2:` and `:3:` for the post-condition, writes the merged file preserving encoding, BOM, and per-line terminators, and prints one JSON object on stdout: `{ "result": "resolved | escalate", "resolved": [...], "escalate_paths": [...] }`. It stages nothing and commits nothing.

Merge algorithm:

- For each `<<<<<<<` / `=======` / `>>>>>>>` hunk (skipping a `|||||||` base section when present), every line on both sides must parse as a mergeable unit; otherwise the file escalates. Resolution is ours units in ours order, followed by theirs units whose key is absent from ours, in theirs order. Git leaves unconflicted regions in place, so base ordering is preserved outside hunks and each side's insertion order is preserved inside them.
- Version rule: the same key on both sides with a differing `version` (package) or `newVersion` (bindingRedirect) resolves to the higher `[System.Version]`; for a bindingRedirect the `oldVersion` upper bound is set to the chosen `newVersion`. The same key with the same version but differing attributes escalates.
- Never-drop post-condition: the unit-key set of the merged file must equal the union of the unit-key sets of `:2:` and `:3:`, and every key present in `:1:` and in both sides must still be present. Any violation escalates without writing.
- No XML DOM reserialization at any point.

Sequencing, inserted as a new first step of `## Per-Item Merge-Conflict Handling` in `.claude/skills/parallel-orchestrate/SKILL.md` (the existing steps become the escalation path):

1. On a conflicted `gh pr merge --merge`, the parent runs `git -C <worktree_path> fetch origin main` and `git -C <worktree_path> merge --no-commit origin/main`.
2. The parent runs the entry script against the worktree. `escalate` makes the parent run `git -C <worktree_path> merge --abort` and continue with the existing child re-delegation, including `escalate_paths` in the Blocking finding.
3. On `resolved`, the parent stages and commits the resolved paths with a message listing every entry added and every version choice, then runs `dotnet tool restore --tool-manifest <worktree_path>/.config/dotnet-tools.json`, `dotnet csharpier check <worktree_path>`, and `dotnet build <worktree_path>/<solution>`. Path arguments are used rather than `cd`. A failing check reverts the commit with `git -C <worktree_path> reset --hard HEAD~1` and escalates with the tool output as the finding.
4. On success the parent pushes the item branch, records `mergeable_conflicts_resolved`, sets `merge_status: pr_open`, regenerates `parallel-status.md`, and re-enters merge-on-green at the durable `gh pr checks` confirmation step.

`.claude/agents/parallel-orchestrator.md` (and its mirror) gains four narrowly scoped allowlist entries: the single `pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` shape, `dotnet tool restore`, `dotnet csharpier check`, and `dotnet build`.

### 4. Barrier hook and Layer-2 validator follow the graph

No change is made to `.claude/hooks/enforce-parallel-cohort-barrier.ps1` or to `PARALLEL_COHORT_BARRIER_VIOLATION`. The hook reads `conflict_edges[]` neighbours only and has no knowledge of edge reasons or paths, so removing an edge is sufficient. A test confirms that a set of items whose only overlaps are `.csproj` files produces an empty edge list and a single cohort holding every item key, in Python and through `.claude/lib/bash/compute-cohorts.sh`.

### 5. Tests and parity

`mergeable_paths` joins Class 1 of the key partition in both the Python and the Pester registries. New parity fixtures under `tests/fixtures/blast_radius/` are discovered by glob and consumed by both the Python and the Pester parity suites. New Pester suites cover the two project-file-merge modules and the entry script with checked-in conflicted-file and stage fixtures, with `Invoke-GitExe` mocked rather than git executed. New Jest suites cover the carriage of the new key and the non-module manifest family. No test creates a temporary file.

## Inputs / Outputs

- Inputs
  - `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`: new optional top-level key `mergeable_paths` (list of exact paths and `**` globs). Default published value is the five-entry list in Behavior 1.
  - `Resolve-MergeableConflict.ps1`: `-Worktree <path>` (item worktree with an in-progress, conflicted `git merge --no-commit origin/main`), and the truth-table path.
  - Push-down: destination-layout observations consumed by `deriveDestinationModuleMap`.
- Outputs
  - `Resolve-MergeableConflict.ps1`: one JSON object on stdout, `{ "result": "resolved | escalate", "resolved": [...], "escalate_paths": [...] }`; merged file contents written in place for `resolved`; nothing written for `escalate`.
  - Checkpoint: optional `mergeable_conflicts_resolved` list on an item record.
  - Projection: `## Mergeable Conflicts Resolved` section in `parallel-status.md`, generated from `docs/features/templates/parallel/parallel-status.md`.
  - Evidence: `docs/features/parallel/<slug>/evidence/other/mergeable-conflicts.<yyyy-MM-ddTHH-mm>.md` carrying `Timestamp`, `Command`, `EXIT_CODE`, and the script's JSON output.
  - Resolution commit message body listing every entry added and every version choice; the same content cited in the PR body.
- Config keys and defaults: `mergeable_paths`, optional, default absent means "exclude nothing".
- Versioning or backward-compatibility constraints: the `blast_radius` record schema and rule invariant 9 are unchanged; `mergeable_paths` never enters a radius record. The `conflicts(a, b, config)` and `Test-BlastRadiusConflict` signatures are unchanged; only their docstrings change, to name `mergeable_paths` as the one config key the relation reads.

## API / CLI Surface

- Python (`scripts/dev_tools/_blast_radius_mergeable.py`, re-exported from `compute_blast_radius.py`)
  - `config_mergeable_paths(config) -> tuple[str, ...]`
  - `matches_mergeable_path(entry, mergeable) -> bool`
  - `exclude_mergeable_paths(entries, mergeable) -> tuple[str, ...]`
- PowerShell (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`)
  - `Get-ConfigMergeablePath -Config <hashtable>`
  - `Test-MergeablePath -Entry <string> -MergeablePath <string[]>`
  - `Get-NonMergeablePathEntry -Entry <string[]> -MergeablePath <string[]>`
  - relocated `Get-SmallestPathOverlap`, `Get-SmallestCommonEntry`
- PowerShell merge library (`.claude/lib/project-file-merge/`)
  - `Get-MergeableUnit`, `Compare-UnitVersion` (grammar module)
  - hunk parse, keyed union, and post-condition entry points (merge module)
  - `pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1 -Worktree <path>`
- TypeScript (`claude-blast-radius-derive-manifests.ts`, re-exported from `claude-blast-radius-derive-core.ts`)
  - `MODULE_MANIFEST_SUFFIXES`, `NON_MODULE_MANIFEST_SUFFIXES`, `isManifestFileName`, `classifyProjectDirectories` returning `{ modulePaths, structureObserved }`
- Contracts and validation rules: the entry script's stdout is a single JSON object, matching the drift CLI's single-object stdout contract. No JSON Schema is authored, imported, or read for any part of this feature.

## Data & State

- Truth table: one additional optional top-level key in each of the two committed copies, byte-equal between them, carried verbatim into a destination by push-down.
- Radius records: unchanged. The mergeable path stays in `paths`; the exclusion exists only inside the contention relation, so every recorded radius is byte-identical to what it is today.
- Conflict graph: a pair whose only path overlap is a mergeable path acquires no `path_overlap` edge. Module, shared-surface, and contract levels are untouched.
- Destination module map: for a .NET layout, `{ "config": ["config/**"] }` instead of one module per assembly.
- Checkpoint item record: optional additive `mergeable_conflicts_resolved` list, shape:

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

  Entry keys are `<ItemType>:<Include>` for MSBuild items, `package:<id>` for `packages.config`, and `bindingRedirect:<assemblyIdentity name>` for `app.config`. `version_resolutions` is present, possibly empty, only for `packages.config`/`app.config` entries.

- Migration or backfill: none. An existing checkpoint without the field, and an existing truth table without the key, are both valid and behave as today.

## Non-Goals

- Consumer copies are not patched. `config/blast-radius.json` and `.claude/hooks/enforce-parallel-cohort-barrier.ps1` in destination repositories (including TaskMaster) are left untouched; the fix reaches them only through push-down of `drm-copilot` sources and published resources.
- `PARALLEL_COHORT_BARRIER_VIOLATION` semantics are unchanged. The barrier hook is not modified, no new violation code is introduced, and the hook's tests are not edited.
- No new orchestrator invariant is added and none is changed; rule invariant 9 (the six `blast_radius` keys) and invariant 15 (the four edge reasons) stand as written.
- No JSON Schema is authored, imported, or read for `mergeable_paths` or for `mergeable_conflicts_resolved`.
- Over-breadth gating of derived modules at planning time is out of scope; the structure-signal approach replaces it.
- A Python or bash implementation of the merge step is out of scope; the destination runtime that motivates the feature is not guaranteed to have Python, and the shell toolchain provides no grammar guard.
- Rebase-based conflict resolution is out of scope; the merge step operates on the merge commit that `gh pr merge --merge` lands.
- SDK-style project files that carry no explicit item list need no handling; they do not conflict in the first place.

## Constraints & Risks

Constraints:

- **Three-runtime parity.** Python under `scripts/dev_tools/` is the authority; the PowerShell library under `.claude/lib/blast-radius/` is the destination runtime port; TypeScript under `extensions/drm-copilot/src/lib/push-down/` carries the key at push-down. The reader shape, matcher semantics, and application point must agree across the three, and the parity fixtures must produce identical results in the Python and Pester suites.
- **Push-down survivability.** Every new or changed runtime file must reach a destination: the two PowerShell library additions and the three project-file-merge files must be mirrored under `extensions/drm-copilot/resources/claude-customizations/` and enumerated in `pack-manifests/core.json`, and `mergeable_paths` must be in `CARRIED_KEYS`. A change that is not published is inert exactly where the defect occurs.
- **Never-drop merge post-condition.** A wrong merge is worse than an escalation. The merged unit-key set must equal the union of the two sides' key sets, checked against stages `:2:` and `:3:` before any write; any doubt — an unparseable version, a non-grammar line, a non-mergeable path in the conflict set — escalates.
- **Drift detection unaffected.** The mergeable path stays in the declared radius, so `detect_escaped_paths` still catches an item that wrote a path it did not declare, and the V1/V2/V3 audits see the same inputs as today.
- Every touched or created source and test file stays under 500 lines. No test creates a temporary file; git access in tests goes through the mocked `Invoke-GitExe` wrapper seam.

Risks:

- The parent gains `dotnet` grants it did not have. They are scoped to three command shapes and are exercised only after a resolution commit exists; a failing check reverts that commit and escalates.
- The grammar is deliberately narrow. A project file using a form outside it escalates, which is the safe direction but reduces the benefit until the grammar is widened.
- The `**/` root-level matcher rule is local to the mergeable matcher. If the shared glob translation is changed later, the local rule must be re-examined so the two do not diverge.

## Numeric Assertions

Two numeric claims are admitted, each backed by a complete two-strategy derivation in `## Numeric Derivation Evidence` of `research/2026-09-07T09-45-mergeable-project-file-overlaps-research.md`:

- The Python contention relation has one production call site (`scripts/dev_tools/parallel_drift_detection.py:499`); the facade re-export in `compute_blast_radius.py` is not a call. Derived by a ripgrep invocation scan over `scripts/**/*.py` and cross-checked by import-site enumeration; member sets identical.
- The PowerShell contention relation has three procedural consumers outside its defining module (`.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/agents/parallel-planner.md`). Derived by a `Test-BlastRadiusConflict` line scan over `.claude/**` and `scripts/**` and cross-checked by a bare-noun `BlastRadiusConflict` file scan; member sets identical.

No other count is asserted as fact in the acceptance criteria. The research explicitly declines to derive the "nine `.csproj` directories" figure quoted in `issue.md`, classifying it as a stipulated fixture parameter rather than a derived population; the acceptance criterion below therefore states the fixture's construction rule and the exact expected module map instead of a count, and the implementer may size the fixture as `issue.md` suggests. Assertions such as "the edge list is empty" and "a single cohort" are output-shape assertions verified directly by the named test, not enumerations of a code population.

## Acceptance Criteria

- [x] Both `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` carry `mergeable_paths` with exactly the entries `**/*.csproj`, `**/packages.config`, `**/app.config`, `**/*.vbproj`, `**/*.props`, byte-equal between the copies — verified by the Class 1 byte-equal case in `tests/scripts/dev_tools/test_blast_radius_config_parity.py` driven by `BYTE_EQUAL_KEYS` and by the mirrored case in `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`.
- [x] The key is optional and fail-closed: for a config omitting `mergeable_paths` and for a config carrying an empty list, `conflicts` and `Test-BlastRadiusConflict` return results identical to the pre-change behavior — verified by an absent-key/empty-list equivalence case in `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` and in `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1`.
- [x] `config_mergeable_paths` (`scripts/dev_tools/_blast_radius_mergeable.py`) and `Get-ConfigMergeablePath` (`.claude/lib/blast-radius/BlastRadiusConflict.psm1`) return an empty sequence for an absent key and reject a non-list value or a blank entry, matching the existing string-list reader shape — verified by reader unit tests in `test_blast_radius_mergeable_paths.py` and `BlastRadiusConflict.Tests.ps1`.
- [x] A pair of radii whose only path overlap is a `.csproj` produces no `path_overlap` reason and no conflict, while both radii still list that `.csproj` in `paths` — verified by `tests/fixtures/blast_radius/conflict-mergeable-csproj-no-edge.json` consumed by both `tests/scripts/dev_tools/test_blast_radius_parity.py` and `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`.
- [x] A declared glob entry that would contain a mergeable path (for example `Proj/**`) still contends, because the matcher applies glob containment to concrete entries only — verified by `tests/fixtures/blast_radius/conflict-mergeable-glob-still-contends.json` in both parity suites.
- [x] A pattern beginning with `**/` also matches the corresponding root-level file (for example `packages.config` at the repository root) inside the mergeable matcher, without any change to `_glob_to_regex_text` or its PowerShell mirror — verified by a root-level matcher case in `test_blast_radius_mergeable_paths.py` and `BlastRadiusConflict.Tests.ps1`.
- [x] The exclusion is applied only inside the contention relation: `derive_blast_radius`, `normalize_declared_radius`, `radius_from_observed_paths`, `validate_blast_radius`, and `detect_escaped_paths` read no `mergeable_paths` key, and V1/V2/V3 findings are identical with and without the key — verified by validation-symmetry and escaped-path cases in `test_blast_radius_mergeable_paths.py`.
- [x] Drift recomputation inherits the exclusion through the single Python production call site of `conflicts` (`scripts/dev_tools/parallel_drift_detection.py:499`, count derived in the research record): `recompute_conflicts_with_observed` reports no new pair for a `.csproj`-only observed overlap — verified by a drift case under `tests/scripts/dev_tools/`.
- [x] `.claude/lib/blast-radius/BlastRadiusConflict.psm1` exists with `Get-ConfigMergeablePath`, `Test-MergeablePath`, `Get-NonMergeablePathEntry`, and the relocated `Get-SmallestPathOverlap` and `Get-SmallestCommonEntry`; `Test-BlastRadiusConflict` imports it and filters both path arrays before the overlap computation — verified by `tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1` and by no-edge and glob-still-contends cases added to `BlastRadius.Conflict.Tests.ps1`.
- [ ] The three PowerShell procedural consumers of the relation (`.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/agents/parallel-planner.md`; count derived in the research record) inherit the exclusion without code change, and the prose in each states that the relation now reads `mergeable_paths` — verified by review of the three files and their published mirrors.
- [x] `mergeable_paths` is appended to `CARRIED_KEYS` in `claude-blast-radius-derive-core.ts` and emitted at the corresponding fixed position of the derived destination document, and is omitted when the source document lacks it — verified by `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-mergeable.test.ts` plus updated key-order assertions in `blast-radius-derive-core.test.ts` and `blast-radius-derive.test.ts`.
- [ ] `.claude/rules/parallel-orchestration.md` documents the mechanically-mergeable path class under the Blast-Radius Contention Doctrine beside `mandate_reads`, stating all three constraints: the planner remains obliged to enumerate a genuine write explicitly; the path stays in the declared radius so the audits still see it; `detect_escaped_paths` remains the backstop at execution time — verified by review of the rule file and its published mirror.
- [ ] `.claude/rules/parallel-orchestration.md` updates the key-partition sentence so `mergeable_paths` is named alongside `version`, `over_breadth_fraction`, and `mandate_reads` as byte-equal across the two copies — verified by review against the extended Class 1 registries.
- [x] `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts` exists and splits the manifest suffixes into `MODULE_MANIFEST_SUFFIXES` and `NON_MODULE_MANIFEST_SUFFIXES` (`.csproj`, `.fsproj`, `.vbproj`, `.sln`, `.slnx`), re-exported from `claude-blast-radius-derive-core.ts` so existing import paths keep working — verified by the family-split cases in `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts`.
- [x] For a fixture in which every project directory of a multi-project .NET layout carries a `.csproj` (fixture size stipulated by the test), the derived destination module map is exactly `{ "config": ["config/**"] }`: no per-assembly module is emitted and the top-level-directory fallback does not fire — verified by `blast-radius-derive-manifests.test.ts`.
- [x] A nested `.sln` or `.slnx` yields no module, and a mixed layout containing a non-.NET manifest directory still yields that directory's module alongside `config` — verified by `blast-radius-derive-manifests.test.ts`.
- [x] `assembleModules` and `PAYLOAD_MODULES` are unchanged, the assembled map is non-empty for every derived layout, and the forbidden-glob guard still receives a non-vacuous input — verified by the existing `blast-radius-derive-core.test.ts` guard cases, with the cases that currently expect a `.csproj`-derived module re-pointed at a non-.NET manifest.
- [ ] `.claude/lib/project-file-merge/ProjectFileMergeGrammar.psm1`, `ProjectFileMerge.psm1`, and `Resolve-MergeableConflict.ps1` exist, are mirrored under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/project-file-merge/`, and are enumerated in `pack-manifests/core.json` — verified by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` (auto-discovery, strict mode, error-action guard, 500-line cap) and by the push-down pack end-to-end test.
- [ ] A conflicted-file fixture for each MSBuild item type `Compile`, `Analyzer`, `None`, `Content`, and `EmbeddedResource`, in both the single-line `Include` form and the paired open/close form, resolves to the keyed union with ours entries in ours order followed by theirs-only entries in theirs order — verified by `tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1` against fixtures in `tests/fixtures/project_file_merge/`.
- [ ] A `packages.config` fixture with disjoint `id` values resolves to the union, and a `packages.config` fixture with the same `id` at differing versions resolves to the higher `[System.Version]` and records `{key, ours, theirs, chosen}` — verified by `ProjectFileMerge.Tests.ps1`.
- [ ] An `app.config` fixture unions `dependentAssembly` blocks keyed on `assemblyIdentity name`, and for the same assembly at differing `newVersion` selects the higher version and sets the `oldVersion` upper bound to the chosen `newVersion` — verified by `ProjectFileMerge.Tests.ps1`.
- [ ] An unparseable version on either side, and the same key at the same version with differing attributes, both escalate rather than resolving — verified by `ProjectFileMergeGrammar.Tests.ps1` and `ProjectFileMerge.Tests.ps1`.
- [ ] Both `merge`-style and `diff3`/`zdiff3`-style conflict hunks are parsed, and a hunk containing any line outside the grammar escalates the file — verified by `ProjectFileMerge.Tests.ps1`.
- [ ] The never-drop post-condition holds: the merged file's unit-key set equals the union of the `:2:` and `:3:` key sets, every key present in `:1:` and both sides survives, and a violation escalates without writing — verified by `ProjectFileMerge.Tests.ps1` with injected stage texts through a mocked `Invoke-GitExe`.
- [ ] The merged file preserves the original BOM, encoding, and per-line terminators, and no XML DOM reserialization occurs — verified by CRLF and BOM fixtures in `ProjectFileMerge.Tests.ps1`.
- [ ] A conflict set containing any path outside `mergeable_paths` (for example a conflicted `.cs` file beside a `.csproj`) produces `{"result": "escalate"}` with that path in `escalate_paths`, writes no file, and leaves the worktree unmodified — verified by `tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1`.
- [ ] `Resolve-MergeableConflict.ps1` prints exactly one JSON object on stdout with `result`, `resolved`, and `escalate_paths`, classifies paths using the committed `mergeable_paths` and the shared blast-radius matcher, and neither stages nor commits — verified by `Resolve-MergeableConflict.Tests.ps1`.
- [ ] `.claude/skills/parallel-orchestrate/SKILL.md` documents, as the new first step of `## Per-Item Merge-Conflict Handling`, that after a successful resolution the parent runs `dotnet tool restore --tool-manifest <worktree_path>/.config/dotnet-tools.json`, `dotnet csharpier check <worktree_path>`, and `dotnet build <worktree_path>/<solution>` with path arguments before re-confirming CI, and that a failing check reverts the resolution commit with `git -C <worktree_path> reset --hard HEAD~1` and escalates with the tool output as the finding — verified by review of the skill and its mirror.
- [ ] `.claude/skills/parallel-orchestrate/SKILL.md` documents that an `escalate` result makes the parent run `git -C <worktree_path> merge --abort` and fall through to the existing child re-delegation with a Blocking finding that includes `escalate_paths` — verified by review of the skill and its mirror.
- [ ] `.claude/agents/parallel-orchestrator.md` and its mirror carry exactly the four scoped allowlist entries required by the step: the single `pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1` shape, `dotnet tool restore`, `dotnet csharpier check`, and `dotnet build` — verified by review of the agent frontmatter.
- [ ] An item record carrying `mergeable_conflicts_resolved` with the documented shape (`path`, `resolved_at`, `merged_against`, `merge_commit_sha`, `entries_added_from_ours`, `entries_added_from_theirs`, `version_resolutions`, with entry keys `<ItemType>:<Include>`, `package:<id>`, `bindingRedirect:<name>`) produces zero validator errors, and an item record omitting it also produces zero errors — verified by one tolerance case in the Python parallel-orchestrator-state validator tests and one in `extensions/drm-copilot/test/lib/validate/`.
- [ ] `.claude/rules/parallel-orchestration.md` declares `mergeable_conflicts_resolved` optional, additive, and tolerated-not-validated, and the two "add no field" sentences in `.claude/agents/parallel-orchestrator.md` and `.claude/skills/parallel-orchestrate/SKILL.md` are narrowed to permit a field the rule file declares; invariant 9 is unchanged — verified by review of the three files and their mirrors.
- [ ] `docs/features/templates/parallel/parallel-status.md` gains a `## Mergeable Conflicts Resolved` section, and the skill states that the resolution is cited in the projection, the resolution commit message body, the PR body, and an evidence artifact at `docs/features/parallel/<slug>/evidence/other/mergeable-conflicts.<yyyy-MM-ddTHH-mm>.md` carrying `Timestamp`, `Command`, `EXIT_CODE`, and the script's JSON output — verified by review of the template and the skill.
- [ ] For a set of items whose only path overlaps are `.csproj` files, the contention relation yields no edge for any pair and the computed edge list is empty, and `compute_cohorts` places every item key in a single cohort — verified by a cohort case in `tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py` (or a dedicated `test_parallel_mergeable_cohort.py`) and by an empty-edge case in `tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py` exercising `.claude/lib/bash/compute-cohorts.sh`.
- [ ] `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, the `PARALLEL_COHORT_BARRIER_VIOLATION` code and its semantics, the hook's tests, and the cohort-barrier validator tests are unmodified — verified by the absence of those files from the change set and by those suites passing unchanged.
- [x] The key-partition registries are extended in both copies: `BYTE_EQUAL_KEYS` in `tests/scripts/dev_tools/blast_radius_parity_test_support.py` and `$script:ClassOneKeys` in `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` each gain `mergeable_paths`, which propagates to the byte-equal and exhaustiveness cases in both languages — verified by both suites passing with the new key classified.
- [x] A shape case for `mergeable_paths` is added beside the `mandate_reads` case in `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`, and a non-vacuity assertion for the committed `mergeable_paths` list is added in the new Python test module rather than in `test_blast_radius_config_parity.py` — verified by both suites.
- [ ] Every file created or touched by this feature is under 500 lines, achieved by the named relocations and splits: `BlastRadiusConflict.psm1` takes the new readers plus the two helpers relocated out of `BlastRadius.psm1` (496); `claude-blast-radius-derive-manifests.ts` takes the manifest constants and classification out of `claude-blast-radius-derive-core.ts` (469); `_blast_radius_mergeable.py` is a new leaf rather than an addition to `_blast_radius_validation.py` (465); new test modules `test_blast_radius_mergeable_paths.py`, `BlastRadiusConflict.Tests.ps1`, and `blast-radius-derive-mergeable.test.ts` are used instead of adding cases to `test_blast_radius_config_parity.py` (500), `BlastRadiusConfig.Tests.ps1` (500), `test_blast_radius_config.py` (499), `BlastRadiusConfig.psm1` (474), or `blast-radius-derive.test.ts` (472) — verified by a line-count check over the change set and by the module convention test.
- [ ] The seven-stage toolchain (format, lint, type-check, architecture, unit tests, contract checks, integration tests) passes in a single pass for Python, TypeScript, and PowerShell, with line coverage at or above 85% and branch coverage at or above 75% for the languages whose tooling measures it, and no test creates a temporary file — verified by the per-language QA gate evidence recorded under `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/qa/`.

## Implementation Strategy

- Implementation scope: the two truth-table copies; a new Python leaf module plus the application point in `_blast_radius_conflicts.py` and a facade re-export; a new PowerShell blast-radius module plus the relocation and application point in `BlastRadius.psm1`; a new TypeScript manifest module plus carriage and fallback suppression in `claude-blast-radius-derive-core.ts`; a new PowerShell merge library with three files; published mirrors and `pack-manifests/core.json`; the parallel-orchestrator agent allowlist and prose; the `parallel-orchestrate`, `parallel-plan`, and `parallel-add` skill prose; the rule file doctrine text; the parallel-status template; and the test files listed in the acceptance criteria.
- New functions and commands: as enumerated in API / CLI Surface.
- Dependency changes: none. No XML library is added; `[System.Version]` and `pwsh` are already present wherever the hooks run.
- Logging and telemetry: version resolutions on the checkpoint record; the `## Mergeable Conflicts Resolved` projection section; the resolution commit message body; and one evidence artifact per resolution under `docs/features/parallel/<slug>/evidence/other/`.
- Rollout: no feature flag. The optional, fail-closed key is the rollout control — a destination that has not yet received the published truth table behaves exactly as today, and the merge step escalates rather than resolving whenever the key is absent.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage: `mergeable_paths` present/absent; `.csproj` overlap yields no edge; path remains in `paths`; V1/V2/V3 unaffected.
- [x] Module derivation fixture with nine `.csproj` directories.
- [ ] Merge-step fixtures per item type; non-mergeable path escalates.
- [x] Key-partition parity (Python, TypeScript, Pester).
- [ ] Zero-edge single-cohort run whose only overlaps are `.csproj` files.
