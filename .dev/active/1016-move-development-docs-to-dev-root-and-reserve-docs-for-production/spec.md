# 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production — Spec

- **Issue:** #1016 (adopted by epic child 7 per owner decision E1; this child closes #1016)
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 7, wave 4 (last)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-feature (acceptance criteria in this file and in `user-story.md`)
- **Branch:** `feature/dev-docs-root-migration-phases-2-3-1016`
- **Research:** `research/research.2026-10-30T23-24.md` (sections 1 to 11, Pre-Mortem, OQ-1 to OQ-13)
- **Settled decisions:** `docs/features/potential/promoted/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production.md` (D-1 to D-22). This spec does not re-open any decision.
- **Consumed contracts (child 2, #1035, Phase 1):** `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md` — the `development_docs_root` key, `resolveDevelopmentDocsRoot` and resolution cases R-1 to R-8, the area map and `developmentDocsPath`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`, the writer/matcher split, parser cases F-1 to F-6 (`parseFeatureFolderName`), formatter cases N-1 to N-5 (`formatFeatureFolderName`), and the D-16 write-scope literal contract (`write-scopes.ts` and its three-direction checker). That spec marks Phases 2 and 3 as delivered by this child.

## Overview

`docs/features/` holds potential entries, active and completed features, an archive, epics, parallel orchestrations, templates and research. It is development-process material in the folder that conventionally holds production documentation, and the same layout is pushed to every destination repository that uses this toolset. Issue #1016 separates development documentation from production documentation: development records move to a new top-level `.dev/` root and `docs/` is reserved for production documentation. Lifecycle semantics (potential, active, completed, archive) do not change.

Child 2 delivers Phase 1 (resolver, configured key with the default `docs/features`, parser, folder creation by issue number, write-scope contract). This child delivers Phase 2 (the TypeScript migration tool) and Phase 3 (the move of this repository to `.dev`, the feature-folder rename and the default flip).

Target layout (D-6; the `features` level is dropped):

```
.dev/
  potential/  active/  completed/  archive/
  epics/  parallel/
  templates/          (was docs/features/templates and docs/discovery templates)
  research/           (was docs/research and docs/features/research; issue-linked research stays in its feature folder)
  engineering/        (was docs/engineering)
  discovery/          (was docs/discovery)
  backlog.md
docs/
  README.md           (states that docs/ holds production documentation only)
```

The record's layout comment names two targets for the discovery templates (`templates/` and `discovery/`). That conflict is owner question OQ-1 and is not decided here.

## Scope Boundary

| Item | Phase | Delivered by | In scope for this child |
| --- | --- | --- | --- |
| `development_docs_root` key, resolvers in three runtimes, area map, writer/matcher split, R-1 to R-8 | 1 | child 2 (#1035) | No (consumed) |
| Feature-folder name parser F-1 to F-6 and formatter N-1 to N-5; folder creation by issue number | 1 | child 2 | No (consumed) |
| D-16 write-scope literal contract and checker | 1 | child 2 | No (consumed; must keep passing) |
| CI docs-only `.dev/` prefixes (D-12), JSON governance glob (D-14), dot-folder handling (D-13) | 1 | child 2 | No (consumed) |
| TypeScript migration tool `migrate_development_docs` (MCP tool plus `npx` subcommand), pure planner, applier, dry-run report, decision-file consumption (D-9, D-17) | 2 | child 7 | **Yes (stage A)** |
| Dry run of the tool against this repository from a branch build | 2 | child 7 | **Yes (stage A)** |
| Owner decisions on held items and on the owner questions that affect execution | 2/3 | owner, recorded by the orchestrator | **Yes (owner stop)** |
| Move of this repository to `.dev`, `docs/README.md` boundary note (D-1 to D-6, D-10) | 3 | child 7 | **Yes (stage B)** |
| Rename of feature folders in `active`, `completed` and `archive` to `<NNNN>-<feature>` (D-18 to D-22) | 3 | child 7 | **Yes (stage B)** |
| Flip of `development_docs_root` to `.dev` and the dependent updates (tests, prose, templates, blast-radius `path_roots`, frozen-surface pins) | 3 | child 7 | **Yes (stage B)** |
| Historical fixtures frozen and read through the fallback (D-15) | 3 | child 7 | **Yes (stage B)** |
| Removal of the one-release fallback (D-8) | later | not this child unless the owner decides otherwise in OQ-6 | **No (default)** |

## Delivery Stages

An executor plan cannot contain an owner stop. The work is therefore delivered as two plans separated by an orchestrator-owned owner stop.

### Stage A — pre-decision plan (Phase 2: tool, tests, dry run; no move)

1. Phase 0 gate (see "Execution Preconditions").
2. Implement the TypeScript migration tool `migrate_development_docs`:
   - MCP tool in `@danmoisan/drm-copilot-mcp`, implemented in `extensions/drm-copilot/src` and bundled by `packages/mcp-server/esbuild-mcp-server.cjs`. No module of the tool imports `vscode`. No Python.
   - Thin `npx` entry as a subcommand on the existing bin: `npx -y @danmoisan/drm-copilot-mcp migrate-development-docs ...`. The `bin` and `files` entries in `packages/mcp-server/package.json` are unchanged.
   - Injectable `MigrationGit` seam over the existing `CommandRunner`, with `-z` listing and an explicit `maxBuffer`.
   - Pure planner, applier over the `MigrationGit` and `FileSystem` seams, dry-run report (Markdown and JSON), decision-file consumption with the `source_digest` check, idempotence.
3. Register the tool (name list, both definition lists, input module, handler, dispatch case, optional service method), add the CLI subcommand, add `coverageThreshold` entries, update the enumerated-name tests, document the tool in `packages/mcp-server/README.md` and `extensions/drm-copilot/README.md`.
4. Build the package from the branch (`npm --prefix packages/mcp-server run build`) and run the dry run against this repository (`node packages/mcp-server/out/mcp-server.js migrate-development-docs --workspace <repo> --mode dry-run --report-dir <FEATURE>/evidence/other`, launched from a `sh` script file). Write the report to `<FEATURE>/evidence/other/dev-docs-migration-dry-run.<UTC>.md` and `.json`.
5. No `git mv`, no rename and no flip happen in stage A.

### Owner stop (orchestrator-owned, between the plans)

- The orchestrator presents the dry-run report and the owner questions (OQ-1 to OQ-13) to the owner.
- The orchestrator writes the owner's answers to `<FEATURE>/evidence/other/folder-rename-decisions.<UTC>.json` using the schema in "Decision File".
- The stage B plan is authored during preparation with explicitly authorized branches for each owner answer, and its Phase 1 maps the decision file's answers onto those branches; an answer that maps to no branch, or an answer listed under "Orchestrator Rulings (preparation)" as re-entering planning, halts stage B for one plan revision. Owner answers that change stage B scope (OQ-3, OQ-4, OQ-5, OQ-6, OQ-7, OQ-8, OQ-9, OQ-10, OQ-11) are recorded in `global_decisions` and become stage B tasks or exclusions; they are not decided by either plan.

### Stage B — post-decision plan (Phase 3: move, rename, flip, updates)

1. Phase 0 gate (see "Execution Preconditions"), including a fresh dry run whose `source_digest` equals the decision file's `source_digest`.
2. Apply the migration with the decision file (moves, renames, reference rewrites, link recomputation, `docs/README.md`), committed as one commit or as moves-then-rewrites according to `global_decisions.commit_split` (OQ-12).
3. Update the orchestrator checkpoint (`artifacts/orchestration/orchestrator-state.json`) to the post-move feature path in the same step as the self-move; the feature folder becomes `.dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production` unless the decision file states otherwise. Later evidence is written only under the new `<FEATURE>` path.
4. Flip `development_docs_root` to `.dev` in `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json` together (the parity test forbids flipping one copy).
5. Add `.dev` to `path_roots` in the self-hosted `config/blast-radius.json` and to `PINNED_SELF_HOSTED_PATH_ROOTS`. The bundle copy under `extensions/drm-copilot/resources/claude-customizations/config/` keeps its empty Class 2 `path_roots` (ruling R1).
6. Change the relative link depth in the feature plan template in both copies (`.dev/templates/feature/plan.yyyy-MM-ddTHH-mm.md` after the move, and `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md`) so `.github/instructions/...` links resolve from `.dev/active/<folder>/` (OQ-11 records the effect on unmigrated destinations).
7. Update the epic manifest `feature_folder` value for child 2 in `.dev/epics/shared-agent-harness-layer/epic.md` to the renamed folder basename.
8. Create `docs/README.md` (the tool does this in apply mode) and confirm `docs/` contains nothing else.
9. Update tests and prose in the sources. Where epic child 3 has made a surface generated, edit the generator source and re-run the generator with `--check`; do not edit generated outputs. The exact source set is determined by the Phase 0 gate after children 3 to 6 merge.
10. Re-baseline `PINNED_FROZEN_SURFACE_HASHES` with a dated comment for each pinned file whose text changes, and update `KICKOFF_IDENTITY_FRAGMENTS` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` in the same change as any prose rewrite of the pinned surface.
11. Apply the stage B tasks implied by `global_decisions` (for example discovery runtime packaging for OQ-4, FileSizePolicy segment for OQ-10, allow-list entries for OQ-8). An OQ-6 answer that removes the fallback, or an OQ-9 answer that requests an extension command, re-enters planning (ruling R2).
12. Run the full seven-stage toolchain for TypeScript, Python and PowerShell with the key at `.dev`, plus the mirror and contract tests in "Contract Tests".

## Design Rule for Unresolved Owner Questions

This spec does not decide any owner question. Where an open question changes tool behavior, the tool takes the choice as an input from the decision file, so stage A can be built and tested without the answer and stage B applies the answer.

| Question | Decision-file input | Dry-run default when no decision file is supplied | Apply mode |
| --- | --- | --- | --- |
| OQ-1 discovery-templates target | `global_decisions.discovery_templates_target` (repository-relative directory) | `developmentDocsPath(".dev", "discovery-templates")` from child 2's area map (`.dev/discovery/templates`); the report also lists the entry-by-entry plan for the alternative `.dev/templates/` | requires an explicit value when `docs/discovery/` exists |
| OQ-2 in-tree rewrite scope | `global_decisions.in_tree_rewrite_scope`: `"references-and-links"`, `"links-only"` or `"none"` | computes and reports all three categories separately; applies nothing | requires an explicit value when any moved file contains a rewrite candidate |
| OQ-12 commit split | `global_decisions.commit_split`: `"single"` or `"moves-then-rewrites"` | reports both orderings; applies nothing | requires an explicit value whenever the plan contains both moves and text rewrites |
| OQ-13 held folders | `decisions[]` entries | reports every held item with its mechanical candidate | requires one entry per held item |

Apply mode refuses without a decision file when the dry-run report contains any held item or any open global choice, and refuses when the decision file leaves any held item or required global choice unset (`null` or missing). The dry-run JSON includes a `decision_skeleton` object that lists every held item and every open global choice with the value `null`, so a maintainer can fill it in.

Owner questions that do not change tool behavior (OQ-3 to OQ-11) are recorded in `global_decisions` for the stage B plan. OQ-5 and similar answers that exclude files from the rewrite are expressed through `rewrite_exclusions`.

## Behavior

### Mapping table (research section 5)

Applied longest prefix first.

| Old prefix | New prefix | Notes |
| --- | --- | --- |
| `docs/features/potential/` (including `promoted/`, `template.md`, `README.md`) | `.dev/potential/` | names kept (D-22) |
| `docs/features/active/` | `.dev/active/` | folder rename (D-20) |
| `docs/features/completed/` | `.dev/completed/` | folder rename |
| `docs/features/archive/` | `.dev/archive/` | folder rename |
| `docs/features/epics/` | `.dev/epics/` | names kept |
| `docs/features/parallel/` | `.dev/parallel/` | names kept |
| `docs/features/templates/` | `.dev/templates/` | names kept |
| `docs/features/research/` | `.dev/research/` | names kept |
| `docs/features/backlog.md` | `.dev/backlog.md` | |
| `docs/research/` | `.dev/research/` | names kept |
| `docs/engineering/` | `.dev/engineering/` | names kept |
| `docs/discovery/` | `global_decisions.discovery_templates_target` (OQ-1) | contains only `templates/` |

An entry under `docs/features/` that the table does not map is reported as unmapped, and apply mode refuses while any unmapped entry exists. Any other entry under `docs/` that the table does not map is retained production documentation (decision A1): it is reported in its own category, never moved or rewritten, and never causes a refusal. After apply, `docs/` contains only `docs/README.md` and any production documentation that was not a mapped source.

### Feature-folder rename derivation (research section 6)

For each direct child folder `<area>/<name>` of `active`, `completed` and `archive`:

1. Parse the name with `parseFeatureFolderName` (child 2).
2. `date-first` with an issue number (F-1): candidate `formatFeatureFolderName(issueNumber, feature)`; renamed mechanically unless rule 6 or rule 8 applies.
3. `issue-first` (F-3, F-4): already migrated; no rename (idempotence).
4. `other` with an issue number (F-5): candidate `formatFeatureFolderName(issueNumber, feature)`, reported as non-matching and held for the owner (D-21).
5. `date-first` without an issue number (F-2) or `other` without an issue number (F-6): no recoverable number; the name is kept (D-21) and reported.
6. An issue number that yields more than one folder across the three areas: all its folders are reported and held; none is renamed until decided.
7. A formatter error (N-3 to N-5) is reported, not thrown, in dry-run mode, and the folder is held.
8. Target collisions are checked case-insensitively across all three areas, against both other candidates and existing names; a collision is reported and both folders are held.

Versioned subfolders (`v1/`, `v2/`) and nested layouts (`audit-*/`, `evidence/**`) move with their parent and are not renamed. Only the top-level folder name changes.

### Reference rewrite rules (research section 4)

**Prefix rewrite.** In each tracked text file in scope, occurrences of the mapping-table prefixes are replaced longest prefix first: `docs/features/research/` → `.dev/research/`; `docs/features/templates/` → `.dev/templates/`; `docs/features/<area>/` → `.dev/<area>/`; `docs/features/backlog.md` → `.dev/backlog.md`; `docs/features/` → `.dev/`; `docs/research/` → `.dev/research/`; `docs/engineering/` → `.dev/engineering/`; `docs/discovery/` → the OQ-1 target. Renamed folder basenames are rewritten after the prefix rule, from the approved rename map, only where they follow a `.dev/<area>/` prefix. A prefix matches only at a path-token boundary (start of text, or preceded by a character that is not a letter, digit, `.`, `_`, `-` or `/`, with an optional leading `/` or `./`). Backslash-separated occurrences are reported, not rewritten. Idempotence follows because no output contains an input prefix.

**Link recomputation.** For each Markdown file in scope, every relative link is resolved against the file's location before the move. When the link's source file or target moved, the link is recomputed relative to the source's location after the move; otherwise it is left unchanged. Fragments (`#...`) are preserved; links with a URL scheme and root-relative links handled by the prefix rule are not recomputed. A link whose target does not exist before the move is left unchanged and reported. This one rule covers all depths, including `audit-*/` and `v1/` subfolders.

**Scope.** The rewrite reads tracked files only (from `MigrationGit.listTrackedFiles`). Files that contain a NUL byte or are not valid UTF-8 are skipped and reported. Files inside the moved trees are subject to `global_decisions.in_tree_rewrite_scope` (OQ-2); files outside the moved trees are subject to the prefix rule and link recomputation.

### Exclusions (D-15 and mapping records)

The rewrite never changes:

- Historical JSON fixtures under `tests/fixtures/` (D-15) and the historical-run fixtures under `tests/fixtures/blast_radius/historical-runs/`. In this repository the stage B decision file excludes all of `tests/fixtures/**`, including non-JSON fixtures (ruling R3).
- Text that records the old-to-new mapping itself: the promoted record, this feature's spec, user story, research and plans, and child 2's spec, research and plan. A prefix rewrite of these would corrupt the mapping.
- Fallback-support surfaces that must keep the `docs/features` form during the fallback release: child 2's resolver and matcher modules and their tests, the `docs/` entries of `config/ci-docs-only-paths.json`, and every `Write(`/`Edit(` permission literal (the D-16 checker requires both root forms). An occurrence inside a `Write(` or `Edit(` literal is protected by rule; the remaining surfaces are listed as path globs.
- The decision file and the dry-run reports.

Built-in defaults: the tool always excludes its own reports and the decision file, applies the `Write(`/`Edit(` protected-literal rule, and in dry-run mode without a decision file uses `tests/fixtures/**/*.json` and `tests/fixtures/blast_radius/historical-runs/**` as default path exclusions. Repository-specific exclusions (mapping records, fallback-support surfaces, and files the owner excludes under OQ-5) are supplied as `rewrite_exclusions` globs in the decision file; the stage B Phase 0 gate derives the fallback-support list from child 2's merged files. The dry-run report lists every excluded file and every protected occurrence, and flags as a mapping-record candidate any file that contains both an old prefix and its mapped new prefix.

### Refusal rules

The tool fails with an explicit error and changes nothing when:

- `workspace_root` is not inside a git work tree (`MigrationGit.isInsideWorkTree`).
- In apply mode, tracked files have uncommitted changes.
- A planned move target exists and is non-empty (a `git mv` into an existing directory would nest the source, for example `.dev/active/active`). A merge into an existing directory is planned entry by entry, and each entry is checked for collision.
- A rename target or move target collides with another target or an existing path, compared case-insensitively.
- In apply mode, the decision file's `source_digest` differs from the digest of a fresh dry run (the tree changed after approval).
- In apply mode, the decision file is missing while the report contains a held item or an open global choice, or the decision file leaves a held item or a required global choice unset.
- A decision entry names a source that is not a reported folder, or a `rename` target that fails `parseFeatureFolderName` as `issue-first`.
- An unmapped entry exists under a source tree.

### Idempotence

- A second apply on an already migrated tree produces an empty plan, performs no `git mv`, writes no file, and reports zero changes.
- `issue-first` folders are not renamed, no rewrite output contains an input prefix, and `docs/README.md` is created only when absent; an existing `docs/README.md` is left unchanged and reported.
- With `commit_split` `"moves-then-rewrites"`, an apply call performs only the moves while any move is pending, and only the rewrites otherwise; the caller commits between calls. The tool never runs `git commit`.

### Untracked-file reporting

`git mv` of a directory also moves untracked files on disk while re-indexing only tracked files. The dry-run report and the apply result list untracked and ignored files present under each source tree. Their presence does not cause a refusal.

## Decision File

Path: `<FEATURE>/evidence/other/folder-rename-decisions.<UTC>.json`, written by the orchestrator from the owner's answers. The file moves with the feature folder during stage B, so its path is always passed explicitly through `rename_decisions_path`.

```json
{
  "version": 1,
  "dry_run_report": "dev-docs-migration-dry-run.<UTC>.json",
  "source_digest": "<sha256 of the sorted list of candidate folder paths in the dry run>",
  "global_decisions": {
    "discovery_templates_target": "<OQ-1 answer: repository-relative directory>",
    "in_tree_rewrite_scope": "<OQ-2 answer: references-and-links | links-only | none>",
    "commit_split": "<OQ-12 answer: single | moves-then-rewrites>",
    "absent_key_resolves": "<OQ-3 answer>",
    "discovery_runtime_resource_key": "<OQ-4 answer>",
    "rules_mirrors_editable": "<OQ-5 answer>",
    "remove_fallback": "<OQ-6 answer>",
    "run_source": "<OQ-7 answer: published release | branch build, with version-bump timing>",
    "allow_list_tool": "<OQ-8 answer>",
    "extension_command": "<OQ-9 answer>",
    "file_size_excluded_segment": "<OQ-10 answer>",
    "plan_template_link_depth": "<OQ-11 answer>"
  },
  "rewrite_exclusions": ["<glob>"],
  "decisions": [
    { "source": "docs/features/archive/epic-planner-receipt-checks-key-gate-543", "action": "rename", "target": "0543-epic-planner-receipt-checks-key-gate-b" },
    { "source": "docs/features/completed/subagent-tree-command", "action": "keep" }
  ]
}
```

The `decisions` entries are examples of shape only. The tool consumes `discovery_templates_target`, `in_tree_rewrite_scope`, `commit_split`, `rewrite_exclusions` and `decisions`; the other `global_decisions` fields are recorded for the stage B plan and are validated only as present strings. Unreported F-1 folders follow the mechanical rule and need no entry.

## Inputs / Outputs

### MCP tool `migrate_development_docs`

| Input | Type | Required | Meaning |
| --- | --- | --- | --- |
| `workspace_root` | string | yes | repository root to migrate |
| `mode` | `"dry-run"` or `"apply"` | yes | dry run writes nothing outside the report directory; apply moves and rewrites |
| `rename_decisions_path` | string | no | decision file; required by apply per "Design Rule for Unresolved Owner Questions" |
| `report_directory` | string | no | directory for the Markdown and JSON reports; when omitted, the report is returned in the result only and no report file is written |

Output: `RepoAutomationExecutionResult` with `ok`, `artifacts` naming the report files written, and `summary` carrying counts per report category (moves, renames, held items, formatter errors, collisions, files to rewrite with occurrence counts, excluded files, protected occurrences, broken links, untracked files, `source_digest`). Errors become `ok: false` results through `toFailureToolResult`.

### Dry-run report contents

Markdown and JSON (`dev-docs-migration-dry-run.<UTC>.md` and `.json`): planned directory moves; mechanical renames; held items (non-matching folders, multi-folder issue numbers, formatter errors, collisions) with candidates; unmapped entries; retained production documentation under `docs/` (decision A1); files to rewrite with occurrence counts, split into outside-moved-trees and the three in-tree categories; excluded files and protected occurrences; mapping-record candidates; broken relative links; backslash-separated occurrences; untracked and ignored files; `source_digest`; `decision_skeleton`.

### Configuration

- Reads `development_docs_root` through child 2's resolver only to report the current resolved root; the tool does not change the key. The flip is a stage B edit.
- No new configuration key.

## API / CLI Surface

### CLI

```
npx -y @danmoisan/drm-copilot-mcp migrate-development-docs --workspace <path> --mode dry-run|apply [--decisions <path>] [--report-dir <path>]
```

- `src/mcp-server.ts` `main()` delegates to the CLI module when `process.argv[2] === "migrate-development-docs"`; otherwise it starts the stdio server unchanged.
- Exit codes: `0` success; `1` refusal or execution error (reason on stderr); `2` usage error (unknown flag, missing `--workspace` or `--mode`, invalid mode).
- Standard output: the Markdown summary of the report.
- Branch-build form used in this repository before a release: `node packages/mcp-server/out/mcp-server.js migrate-development-docs ...`, launched from a `sh` script file.

### TypeScript seam

```ts
export interface MigrationGit {
  listTrackedFiles(pathspecs: ReadonlyArray<string>): ReadonlyArray<string>; // git ls-files -z -- <pathspecs>
  listUntrackedFiles(pathspecs: ReadonlyArray<string>): ReadonlyArray<string>; // git ls-files -z --others -- <pathspecs>
  hasUncommittedTrackedChanges(): boolean;                                   // git status --porcelain -z --untracked-files=no
  move(from: string, to: string): void;                                       // git mv -- <from> <to>
  isInsideWorkTree(): boolean;                                                // git rev-parse --is-inside-work-tree
}
export function createMigrationGit(runner: CommandRunner, cwd: string): MigrationGit;
```

`CommandRunOptions` in `src/lib/subprocess-runner.ts` gains an optional `maxBuffer`, passed through by `SubprocessRunner` (additive; the default `spawnSync` limit is 1 MiB, and the tracked-file listing of this repository exceeds it). Moves are planned per directory plus one call per renamed folder, not per file. The applier calls `FileSystem.ensureDir` on each destination parent before `move`.

### Files touched (research section 1)

| File | Change |
| --- | --- |
| `extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts` (new) | ordered mapping table and `mapLegacyPath` |
| `.../development-docs-migration/folder-rename-plan.ts` (new) | rename derivation using child 2's parser and formatter |
| `.../development-docs-migration/reference-rewrite.ts` (new) | prefix rewrite, protected-literal rule, link recomputation |
| `.../development-docs-migration/migration-git.ts` (new) | `MigrationGit` seam |
| `.../development-docs-migration/migration-decisions.ts` (new) | decision-file parsing, schema validation, `source_digest` |
| `.../development-docs-migration/migration-plan.ts` (new) | pure planner: tracked paths, decisions, exclusions → plan |
| `.../development-docs-migration/migration-apply.ts` (new) | applies a plan through the seams; idempotent |
| `.../development-docs-migration/migration-report.ts` (new) | Markdown and JSON report, `decision_skeleton` |
| `.../development-docs-migration/migrate-development-docs-service-call.ts` (new) | service-call wrapper |
| `src/mcp-development-docs-tool-definitions.ts` (new) | `DEVELOPMENT_DOCS_TOOL_DEFINITIONS`, spread into both definition lists |
| `src/mcp-tool-inputs-development-docs.ts` (new) | input validation |
| `src/mcp-handlers/development-docs-migration-handler.ts` (new) | handler |
| `src/migrate-development-docs-cli.ts` (new) | argv parsing and execution for the `npx` subcommand |
| `src/repo-automation-tool-names.ts` | add `"migrate_development_docs"` to `REPO_AUTOMATION_TOOLS` |
| `src/mcp-repo-automation-tool-definitions.ts`, `src/mcp-tool-definitions.ts` | spread the new definitions |
| `src/mcp-tools.ts` | one `case` in `dispatchRepoAutomationTool` |
| `src/repo-automation-service-contract.ts` | optional method `migrateDevelopmentDocs?` on `RepoAutomationService` |
| `src/repo-automation-service.ts` | `migrateDevelopmentDocs` on `DefaultRepoAutomationService` |
| `src/mcp-server.ts` | `main()` subcommand dispatch |
| `src/lib/subprocess-runner.ts` | optional `maxBuffer` |
| `extensions/drm-copilot/jest.config.cjs` | one `coverageThreshold` entry per new production file |
| `packages/mcp-server/README.md`, `extensions/drm-copilot/README.md` | tool and `npx` documentation |
| `extensions/drm-copilot/package.json`, `CHANGELOG.md`, `packages/mcp-server/package.json` | version bump and changelog, timing per OQ-7 |

The service method is optional (`migrateDevelopmentDocs?`), as `resolveOrchestrationTopology?` is, so the existing full `RepoAutomationService` fakes (the shared fake `extensions/drm-copilot/test/mcp-server-test-service.ts` and the other files listed in research section 1) keep type-checking; the handler fails with an explicit error when the method is absent. `packages/mcp-server/package.json` `bin` and `files` are unchanged, so `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` keeps passing. `.claude/settings.json`, `.codex/config.toml` `enabled_tools` and `contributes.commands` are not changed in stage A (OQ-8, OQ-9).

## Language Classification

Owner language rule (epic `## Shared Design`): avoid new Python; existing Python is extended in place only; anything pushed down to destinations is PowerShell or bash; TypeScript only for MCP tools and extension commands; owner exception E2 (a language-native analyzer for the same language, shipped only with that language's pack).

| Artifact | Runs where | Language | Rule status |
| --- | --- | --- | --- |
| Migration core modules, service call, definitions, inputs, handler | MCP package | TypeScript | conforms (MCP tool) |
| CLI subcommand and `main()` dispatch | MCP package `npx` entry | TypeScript | conforms (MCP tool entry, D-17) |
| `subprocess-runner.ts` `maxBuffer` option | MCP package and extension | TypeScript, existing file | conforms |
| Jest tests | repository | TypeScript | conforms |
| Prose, templates, `docs/README.md` | repository and pushed-down bundles | Markdown | not code |
| Routing config, `ci-docs-only-paths.json`, `blast-radius.json`, decision file, dry-run JSON | repository and bundles | JSON | not code |
| `sh` launcher for the branch-build dry run | agent session only, not committed | shell command text | conforms (not pushed down) |
| Pytest and Pester test updates | repository | existing files only | conforms (no new Python file) |
| Discovery runtime packaging paths (`packages/discovery-runtime`, `scripts/dev_tools/build_discovery_runtime.py`) | published Python package | existing Python, extend in place | conforms only as an in-place edit; whether it changes at all is OQ-4 |
| FileSizePolicy excluded segment (`Get-FileSizeExcludedSegment` in `.claude/lib/file-size-policy/FileSizePolicy.psm1`) | pushed-down lib | existing PowerShell | conforms; whether it changes is OQ-10 |

No planned artifact requires a new Python file, a new PowerShell hook or a new bash script. No artifact was found that cannot follow the rule; an artifact identified during planning that cannot follow it is raised as an owner question.

## Execution Preconditions

- Execution of either plan starts only after epic children 1 to 6 and 8 to 10 (#1025, #1035, #1028, #1029, #1030, #1032, #1049, #1050, #1051) have merged into the integration branch; this child is the last wave. The earlier precondition on the parallel run `bugs-1001-1002-1003-1006` is obsolete: that run and #1013 merged and issues 1001, 1002, 1003, 1006 and 1013 are closed (verified with `gh issue view` on 2026-11-14).
- Each plan carries a Phase 0 gate that re-checks every named file, symbol and heading against current `origin/main` and the integration branch `epic/shared-agent-harness-layer-integration`, and stops for re-planning when any has moved. The gate records that child 2's exports (`parseFeatureFolderName`, `formatFeatureFolderName`, `stripDateFirstPrefix`, `developmentDocsPath`, `resolveDevelopmentDocsRoot`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`) match the signatures in child 2's spec.
- The stage B Phase 0 gate additionally confirms that no open pull request touches `docs/features/**` or the overlap files below, and that a fresh dry run's `source_digest` equals the decision file's `source_digest`.
- All counts (folders, held items, multi-folder issue numbers, occurrences, files) are derived mechanically by the dry run at execution; the research snapshot counts are not acceptance values.

Overlap files (research section 11), re-checked by the Phase 0 gate:

- `.claude/agents/epic-orchestrator.md`, `parallel-orchestrator.md`, `parallel-planner.md` and bundle copies; `.claude/rules/orchestrator-state.md`, `parallel-orchestration.md` and bundle copies; the `epic-orchestrate`, `orchestrate`, `parallel-add`, `parallel-orchestrate`, `parallel-plan` and `parallel-run` skills and bundle copies; `.claude/settings.json` and bundle copy (only if OQ-8 adds the tool).
- The execution-environment brief, all copies; `.codex/config.toml` (only if OQ-8 enables the tool for Codex).
- `docs/features/templates/parallel/parallel-status.md` and the `policy_audit` templates (moved).
- `config/blast-radius.json` and `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json`; `config/file-size-baseline.json` (read).
- `extensions/drm-copilot/jest.config.cjs`, `package.json`, `CHANGELOG.md`, `README.md`.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (only if a manifested file is added).
- Tests: `parallel_orchestrator_surface_test_support.py`, `test_parallel_planner_surface_contracts.py`, `test_execution_environment_brief_contracts.py`, the push-down contract tests, `claude-architecture-doc.Tests.ps1`.
- Every `docs/features/active/2026-10-30-*` folder of the parallel run and the promoted potential records it lists; the move renames them.
- Epic children 3 to 6 file sets by scope: generators and generated surfaces (child 3), push-down pipeline, pack manifests, `mcp-tools.ts` and tool-definition modules (child 4), hooks (child 5), `.github/skills`, `.github/agents`, `.vscode/settings.json` (child 6). This child overlaps all of them on prose and on `mcp-tools.ts`, the tool-definition modules and `mcp-server.test.ts`.

## Contract Tests

Run in stage B with the key at `.dev` (research section 9): the tests listed in the execution-environment brief `## Contract Tests That Pin Mirrored Files` (resource contracts, pack-manifest completeness and dependency closure, `scripts/dev_tools/generate_codex_agent_variants.py --check`, `test_codex_agent_wrapper_contracts.py`, `test_codex_handoff_contract_parity.py`, `test_claude_rules_frontmatter.py`, `parallel_orchestrator_surface_expectations.py` consumers, `test_quality_checks_workflow_contracts.py`, `test_push_down_issue_824_follow_ups.py`, `test_typescript_toolchain_instruction_contracts.py`, `claude-architecture-doc.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1`), plus `test_execution_environment_brief_contracts.py`, `test_orchestration_routing_config_parity.py`, child 2's write-scope checker suite under `extensions/drm-copilot/test/lib/development-docs/`, the literal-containment `test_*contract*.py` tests that carry `docs/features` fragments (including `test_parallel_planner_surface_contracts.py`, `test_parallel_kickoff_contract.py`, `test_epic_kickoff_contract.py`), and every generator `--check` that child 3 delivers.

## Orchestrator Rulings (preparation)

The orchestrator recorded these rulings on 2026-10-31 after the stage B preflight. They correct spec facts and fix the planning protocol; none of them answers an owner question.

- **R1 (blast-radius bundle copy).** `path_roots` in `extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json` is a Class 2 bundled key that `test_class_two_bundled_path_roots_are_empty` and the Pester case "declares an empty bundled path_roots list" pin to an empty list. Stage B adds `.dev` only to the self-hosted `config/blast-radius.json` and to `PINNED_SELF_HOSTED_PATH_ROOTS`.
- **R2 (answers that re-enter planning).** An OQ-6 answer that removes the fallback conflicts with the D-15 criterion that frozen fixtures pass through the fallback, and an OQ-9 answer that requests an extension command needs design that stage A does not contain. Either answer halts stage B at its owner-answer mapping task, and the stage B plan receives one revision for it. This halt is an accepted branch, not a plan gap.
- **R3 (fixtures).** The stage B decision file lists `tests/fixtures/**` in `rewrite_exclusions`, so non-JSON fixtures that record past runs are frozen together with the D-15 JSON fixtures.
- **R4 (post-apply verification).** The post-apply idempotence check runs the tool in dry-run mode, which never applies the apply-mode refusals. It uses a decision file derived mechanically in `SCRATCH` from the approved file: `decisions` empty, and `rewrite_exclusions` mapped through the mapping table and the approved rename map. It asserts zero moves, zero renames and zero rewrite candidates outside the excluded files.
- **R6 (scope-diff base).** This child merges into the integration branch, so the no-new-Python and language-scope diffs are anchored on the merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD`, not on `origin/main`. Commits from other children are therefore not counted against this child.
- **R5 (execution split).** Stage B pauses for the orchestrator's checkpoint path update after the self-move. Epic execution therefore delegates stage B as two executor runs: the phases up to and including the apply and checkpoint handoff, then the remaining phases.

## Owner Decisions (preparation)

- **H2 (moves-then-rewrites halt, owner decision 2026-10-31, option (b)).** When the decision file sets `global_decisions.commit_split` to `moves-then-rewrites` (OQ-12), the second apply-mode call, after the moves are committed, refuses its own decision file: the fresh `source_digest` differs from the approved one, and the `decisions` sources (the former `docs/features/...` paths) are no longer reported folders. This refusal is not worked around. Stage B stops at that point with a message that tells the user to re-run the dry run against the post-move tree and approve a new decision file, and the halt is recorded as an accepted branch in the same manner as ruling R2. Stage A is not reopened, and the refusal rules under `### Refusal rules` are unchanged. The `single` commit split is unaffected.

## Autonomous Decisions (planning refresh 2026-11-14, OD-1)

The owner placed the epic in autonomous mode on 2026-11-14 (OD-1): the orchestrator takes the best available option and records it here. These decisions answer the owner questions below and replace the owner stop with an orchestrator decision step. Refused classes stay refused: no gate bypass, force push, publish, policy or settings edit, or evidence alteration. Each decision is recorded in the decision file's `global_decisions` by the orchestrator at the decision step, so the tool contract and the decision-file schema are unchanged.

- **A1 (docs-estate coexistence, #1125).** The documentation-estate tooling treats `docs/` as a production documentation root (docs profile at `docs/documentation-estate/docs-profile.json`, docs MCP tools, docs CI). The `.dev` move is its complement: development records leave `docs/`, and production documentation stays. The unmapped-entry refusal therefore applies only to entries under `docs/features/`. Any other entry under `docs/` that the mapping table does not map (production pages, `docs/documentation-estate/` and its receipts and page-check configuration, an existing `docs/README.md`) stays in place, is never moved or rewritten, and is listed in the dry-run report as retained production documentation; it never causes a refusal. `docs/engineering/documentation-estate/` in this repository is development documentation about the tooling and moves with `docs/engineering/`. Rationale: this is the only reading under which the spec's own statement "after apply, `docs/` contains only `docs/README.md` and any production documentation that was not a mapped source" holds in a destination that already uses the docs estate. This repository has no docs profile today.
- **A2 (OQ-1).** `discovery_templates_target` is `.dev/discovery/templates`, matching child 2's area map. Rationale: one source of truth for the area map.
- **A3 (OQ-2).** `in_tree_rewrite_scope` is `links-only`, and the decision file's `rewrite_exclusions` include every `evidence/**` subtree and the process-reduction ledger. Rationale: evidence is append-only and its alteration is a refused class; recomputing links keeps moved plans and specs navigable without rewriting historical command text.
- **A4 (OQ-3).** An absent key or file resolves `docs/features` (R-1/R-2 unchanged). Rationale: unmigrated destinations keep working.
- **A5 (OQ-4).** The discovery runtime keeps its internal resource key; no Python change. Rationale: avoid new or changed Python and a published-package change.
- **A6 (OQ-5).** The flip does not edit `.claude/rules/*.md`, `.github/instructions/*.md` or their bundle copies; their `docs/features` mentions stay valid through the fallback release and are listed as Stay entries and `rewrite_exclusions`. Rationale: policy edits are a refused class.
- **A7 (OQ-6).** The fallback is kept (D-8 removal is later work). Rationale: D-15 fixtures pass only through the fallback; removing it re-enters planning (ruling R2).
- **A8 (OQ-7).** Stage B runs the tool from a branch build (`node packages/mcp-server/out/mcp-server.js` from a `sh` script file). No version bump and no publish in this child. Rationale: publish is a refused class; the release process owns version bumps.
- **A9 (OQ-8, OQ-9).** No `permissions.allow` or `enabled_tools` change and no extension command. Rationale: settings edits are a refused class; an extension command needs design that stage A lacks.
- **A10 (OQ-10).** No FileSizePolicy segment change. Rationale: Markdown is exempt and no covered extension is planned under `.dev`.
- **A11 (OQ-11).** Both plan-template copies change link depth as stage B step 6 states. Rationale: the bundle that carries the new depth ships in the same release as the migration tool that moves a destination; the link is a convenience link to policy text.
- **A12 (OQ-12).** `commit_split` is `single`. Rationale: it avoids the H2 halt branch; with `links-only` and evidence excluded, most moved files are unchanged and rename detection stays exact for them. H2 stays documented for a future `moves-then-rewrites` answer.
- **A13 (OQ-13, mechanical rule for held items).** The orchestrator derives each held item's decision mechanically from the stage A dry-run JSON: an `other` folder with an issue number (F-5) is renamed to its mechanical candidate when that candidate collides with nothing; every folder of a multi-folder issue number, every formatter error and every collision is `keep`. Rationale: deterministic, reproducible by a third party, and never loses a folder. Snapshot on 2026-11-14 (not an acceptance value): 410 folders under `active`, `completed` and `archive` (82, 187, 141), about 366 date-first with an issue number, 37 other-with-number held, 7 without a number kept, and 5 issue numbers with more than one folder (543, 824, 884, 903, 1019). The dry run at execution is authoritative and includes the folders other epic children add.
- **A14 (decision step).** The owner stop between the plans becomes an orchestrator decision step: the epic orchestrator writes `folder-rename-decisions.<UTC>.json` from A2 to A13 and the stage A dry-run JSON without asking the owner. A stage B Phase 1 mapping that meets an answer outside its branches still halts for one plan revision, as before.
- **A5 amendment (stage B planning, 2026-11-14).** `RESOURCE_ROOTS` in `scripts/dev_tools/build_discovery_runtime.py` is both the repository source root and the approval prefix of the staged member key, and `resolve_default_template_root` in `scripts/dev_tools/discovery/init_models.py` joins `docs`, `discovery` and `templates`, so A2 cannot hold without in-place edits of those two existing Python files. Decision: make the two in-place edits and keep A5's intent (internal resource key, staged resource bytes and package version unchanged). Rationale: in-place edits of existing Python are permitted; no new Python file is added.
- **A16 (stage B scope confirmations, 2026-11-14).** Accepted from the stage B planner: the A15 move branch with ledger files excluded from every rewrite; every bundled copy of the plan template is synchronized with the self-hosted copy (mirror parity); every epic manifest `feature_folder` value that names a renamed folder is updated, not only child 2's. Rationale: each keeps a mirror or manifest consistent with the moved tree.
- **A17 (ledger entries that cite moved paths, amends A15; stage B preflight 2026-11-14).** Ledger files stay byte-identical through the apply commit. Afterwards, each entry whose stored patch, revert blocks or pinned contract-test literals name a moved path (at least 0001, 0006 and 0009, whose hunks hold the `docs/features/templates/policy_audit/` literals of `parallel-gate-wording.Tests.ps1` and `less-evidence-contract.Tests.ps1`) is updated under the ledger README rules in its own commit whose subject carries `reduction: NNNN`: the stored patch is regenerated against the moved tree and the entry's text is otherwise unchanged. No new ledger entry is created, because a path move is not a reduction. Rationale: this is the ledger's documented maintenance procedure for wording that lands after an entry; regenerating keeps every entry revertible, which is the ledger's purpose, and changes no recorded reduction.
- **A18 (the ledger applicability bullet).** The `## Process-Reduction Ledger` applicability bullet in the six `atomic-plan-contract` copies, and any other skill that names the ledger folder, is rewritten to `.dev/engineering/process-reductions/`, with a contract test asserting the new path; when the bullet lies inside a stored hunk, A17 applies. Rationale: otherwise the ledger rule silently stops applying in this repository after the move.
- **A19 (production occurrences the tool cannot rewrite).** Stage B enumerates now, from the current tree, every production occurrence of a moved prefix that the prefix rule cannot rewrite (segment-joined paths, relative `../../docs/features` forms, anchored regular expressions). Each is either a Stay entry (fallback-compatible, named test) or a hand edit in a named stage B task with a test that resolves the path through child 2's resolver or accepts both roots. Validators that check a feature-folder path (the `feature_folder_record` rule in Python, TypeScript and PowerShell) accept both `docs/features/active/` and `.dev/active/` during the fallback release, in parity across the three runtimes and with their error strings unchanged, because `.claude/rules/orchestrator-state.md` states those strings and is not edited (A6). The pre-apply search stops only on a match outside the enumerated sets (for example one added by a later epic child). Rationale: the move must not leave a validator that rejects every post-flip feature folder.
- **A20 (R5 split point).** Executor run 1 continues to [P3-T1], which stops with `BLOCKED: checkpoint-path-update-pending` until the orchestrator records the post-move feature path; run 2 resumes there. Rationale: the executor stop hook blocks a run that ends with unchecked tasks unless it stops on a recorded block.
- **A15 (process-reduction ledger).** `docs/engineering/process-reductions/` moves with `docs/engineering/` and its files are byte-identical after the move (excluded from every rewrite). Stage B names each ledger test with its disposition. If a ledger test cannot pass after the move without editing a ledger entry, the folder stays in place as a recorded Stay entry instead, and the plan records which branch applies.
- **A21 (copy counts after #1032, premise refresh 2026-11-20).** The `.github` skill trees are retired, so the `atomic-plan-contract` and `feature-review-workflow` skills have four copies each (the `.claude` and `.agents` copies and their bundle copies, two byte pairs) and the execution-environment brief has four byte-identical copies. Every "six copies" statement of A18 and of the stage B plan reads as these four; patches `0001` and `0008` hold four `atomic-plan-contract` hunks each. Rationale: the tree re-check of stage B [P0-T3] observed four copies and the copy-list tests assert four.
- **A22 (generated surfaces, premise refresh 2026-11-20).** The harness generator of #1028 (`scripts/harness-generation/Invoke-HarnessGeneration.ps1`) generates the `.claude` brief copies from `.agents/skills/execution-environment/SKILL.md` and the epic-orchestrator agent outputs from `scripts/harness-generation/sources/agents/epic-orchestrator.json` and `.md`. Decision: a brief fact change edits the `.agents` source and its bundle copy and regenerates; a rewrite exclusion of any member of a generator family extends to every family member that holds a moved prefix (for the frozen epic-orchestrator agent: its sources, `.codex/agents/epic-orchestrator.toml` and the bundle copies); before the apply the plan checks that closure and that no rewritten output lacks a rewritten source; after the apply the generator check runs at the phase gate, and drift confined to families without an excluded member is resolved by one regeneration in a named task. Rationale: this is the cheapest design under which the committed-tree generator suite stays green and no generated output is hand-edited.
- **A23 (child 2 already satisfies two A19 rows, premise refresh 2026-11-20).** Child 2 (#1035) made the three `feature_folder_record` validators accept `docs/features/active/` and `.dev/active/` with unchanged error strings, added `.dev/active` acceptance cases in all three runtimes and the `.dev` valid fixture, and routed the stage-timing default evidence root through `Resolve-DevelopmentDocsRoot`. Decision: stage B makes no production edit for either row, records them as satisfied by child 2, and adds only one rejection fixture (a record under `.dev/completed/`) so that the rejection is asserted in parity across the three runtimes. The comments and error strings that keep naming `docs/features/active/` are Stay rows. Rationale: an edit would duplicate behavior that child 2 already ships and tests.
- **A24 (A1 premise and ledger-pinned exclusions, premise refresh 2026-11-20).** `.claude/lib/docs/DocsProfile.psm1` holds one `docs/features/` occurrence, a comment, which is a Stay row and already excluded; A1 holds with that row. The test files whose stored-patch regions name moved prefixes (patches `0001`, `0008` and `0010`) are ledger-pinned and are added to `rewrite_exclusions` in a superseding decision file. Rationale: the ledger chain must stay green across the apply, and the comment has no behavior.
- **A25 (the migration tool is excluded from its own rewrite, preflight revision 2026-11-20).** A preflight prototype of the apply rewrote the stage A tool's own sources (the mapping table in `layout-map.ts` gained `.dev/` prefixes, and `migration-report.ts` and `reference-rewrite.ts` changed), and the eight stage A suites and `repo-automation-service.development-docs.test.ts` failed. Decision: the tool (`extensions/drm-copilot/src/lib/development-docs-migration/**`), its tests, the CLI, the MCP handler and input modules, their tests and coverage contract, and the stage A text of `packages/mcp-server/README.md` are a rewrite exclusion and a Stay row. Rationale: the tool's literals are its mapping contract, and the post-apply dry run of ruling R4 reuses the tool.
- **A26 (child 2's merged files are excluded as a set, preflight revision 2026-11-20).** The prototype corrupted the backlog area map of `scripts/dev_tools/json_config.py` and rewrote child 2's dual-root tests, whose cases name both roots on purpose. Decision: exclusion member 4 is every `.ps1`, `.psm1`, `.py` and `.ts` file of child 2's merged file list (pull request 1200), with twin and bundle copies, plus the three routing configuration copies (hand-edited by the flip task). The `potential_record` error string "under docs/features/potential/" in `OrchestratorStateIssueAdoption.psm1`, `_orchestrator_state_issue_adoption.py` and `orchestrator-state-issue-adoption.ts` is a Stay row (it is stated by `.claude/rules/orchestrator-state.md`, A6, and pinned by three frozen fixtures, R3), and the tests that hold it, including the three parity suites, are excluded with it. Rationale: child 2 already made these files root-agnostic, so a prefix rewrite can only break them.
- **A27 (the cleanup consolidation allowlist stays on docs/, preflight revision 2026-11-20).** `Test-CleanupConsolidationRelativePath` in both `hook-cleanup-context.ps1` copies admits only `docs/` and `.claude/agent-memory/`, and the prototype failed 15 cleanup-leg cases whose literals had been rewritten. Decision: Stay row; the cleanup production files and the five cleanup-leg suites are excluded. Rationale: the cleanup leg governs the `documentationandmemories` consolidation branch, whose `docs/` allowlist is the consolidation contract of #1026; widening it to `.dev/` is a policy change outside this item. Known limitation: after the move, a consolidation commit of `.dev/` paths is not admitted by the cleanup leg.
- **A28 (ReviewVerdictEligibility engineering case, preflight revision 2026-11-20).** The case "refuses the listing engineering path" asserts that `docs/engineering/process-reductions/README.md` is not a records-only path; rewritten to `.dev/engineering/...`, the path falls under the known root `.dev/` and the case inverts. Decision: the test and `ReviewVerdictEligibility.psm1` are excluded with child 2's files (A26) and the literal stays `docs/engineering/...`. Rationale: the case pins the predicate's refusal of a non-feature path under the old root, which still holds; how `.dev/engineering/` is classified is child 2 behavior and unchanged here.
- **A29 (mechanical waiver from a rehearsal of the apply, preflight revision 2026-11-20).** The prototype observed 146 Pester, 128 Jest and 117 pytest failures and 395 pytest setup errors, so a hand-enumerated waiver list cannot be trusted. Decision: before the apply, stage B runs the apply in a scratch copy of the tree, runs the three unit gates there before and after a scratch flip of the root key, and dispositions every failing test by fixed rules into an exclusion amendment (which stops the run until the orchestrator writes a superseding decision file), a fix row of a named stage B task, or a re-plan stop; the post-apply phase gate accepts exactly the recorded fix rows. The failures the prototype showed are folded into the superseding decision file in advance, and the discovery test-support reads (`initialization_test_support.py`, `test_domain_neutrality.py`) are fixed in the discovery task, which also owns the expected `build_discovery_runtime --check` failure between the apply and that task. Rationale: this is the cheapest design under which the waiver is reproducible by a third party and a missed case stops before the real apply instead of after it.
- **A30 (excluded tests that pin a literal of rewritten skill text, run-1 rehearsal re-plan 2026-11-20).** The first rehearsal (`apply-rehearsal.2026-11-20T12-13.md`) stopped on two rows that no rehearsal rule covered: `test_epic_run_skill_discovers_kickoff_across_integration_branch` in `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` and "preserves the merged planner lifecycle boundary" in `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`. Both test files are rewrite exclusions and stay unchanged, and both pin `docs/features/epics/<epic-slug>/epic-kickoff.md` against skill text that the tool rewrites to `.dev/epics/<epic-slug>/epic-kickoff.md` (`.claude/skills/epic-run/SKILL.md` and `.agents/skills/epic-plan/SKILL.md`, each with its harness target and bundle copies). Options: (a) keep the skill rewrite and update the pinned literals to the `.dev/epics` form in the dependent-updates task; (b) add the skills and every copy to `rewrite_exclusions`. Decision: option (a). The rehearsal also gains a rule, `FIX-PINNED`, that turns this class (an excluded, unchanged test that pins a mapping-prefix literal against non-excluded text the tool rewrites to the mapped form) into a fix row of the same task instead of a re-plan stop. Each test file keeps its exclusion, because other fragments in it still read excluded text: `test_epic_orchestrator_precondition_establishes_kickoff_presence` reads the frozen `.claude/agents/epic-orchestrator.md` (A15), which keeps the `docs/features/epics` form. Rationale: after the move, epic homes and kickoff artifacts live under `.dev/epics/` (the stage B epic-manifest task edits `.dev/epics/shared-agent-harness-layer/epic.md`, and the post-fan-in allowance of #1035 accepts the `.dev/epics/` status-document form). Keeping the old path in these skills would direct new epics to a tree that no longer holds them, and option (b) would add four or more exclusions for text that is wrong after the move. Known limitation (unchanged by this decision): the frozen epic-orchestrator agent keeps naming `docs/features/epics/` until its digest is re-baselined outside this item.

## Owner Questions

Recorded as questions only; the 2026-11-14 answers are in `## Autonomous Decisions (planning refresh 2026-11-14, OD-1)`.

- **OQ-1.** Where does `docs/discovery/templates` go: `.dev/templates/` (record layout comment), `.dev/discovery/templates/` (record `discovery/` line and child 2's area map), or another target?
- **OQ-2.** Should references inside the moved historical records (completed and archive plans, evidence `Command:` lines, parallel manifests that cite `active/` for completed folders) be rewritten, or left as written?
- **OQ-3.** At the flip, does an absent key or file in a destination resolve `docs/features` (R-1/R-2 unchanged) or `.dev`?
- **OQ-4.** Should the discovery runtime package keep its internal resource key `docs/discovery/templates/v2` while its repository source moves, or change the key (existing Python, published package)?
- **OQ-5.** May the flip edit `.claude/rules/plan-acceptance-gates.md`, `parallel-orchestration.md` and `orchestrator-state.md` and their bundle copies, which mention `docs/features`?
- **OQ-6.** Does child 7 remove the one-release fallback (D-8), given that D-15 fixtures pass only while matchers accept `docs/features`?
- **OQ-7.** Is Phase 3 run from a published release of `@danmoisan/drm-copilot-mcp` (a release between the two plans) or from a branch build, and when are the extension and MCP versions bumped? This answer determines how stage B invokes the tool: a published release makes `mcp__drm-copilot__migrate_development_docs` and the `npx` form available, while a branch build requires the `node packages/mcp-server/out/mcp-server.js` form from a `sh` script file.
- **OQ-8.** Should `migrate_development_docs` be added to `.claude/settings.json` `permissions.allow` and to `.codex/config.toml` `enabled_tools`?
- **OQ-9.** Is a VS Code extension command for the migration wanted in addition to the MCP tool and `npx` entry?
- **OQ-10.** Should `.dev` be added to the FileSizePolicy excluded segments to match today's `docs` exemption?
- **OQ-11.** The bundled plan template's link depth must change for `.dev/active/<x>/`; is a broken link acceptable for destinations still on `docs/features` during the fallback release?
- **OQ-12.** Must moves and text rewrites be one commit (the record's "one mechanical commit"), or may the pure renames be committed first so that every rename is exact?
- **OQ-13.** For each non-matching folder and each multi-folder issue in the dry-run report, which action applies (rename with which target, or keep)?

## Acceptance Criteria

### Stage A — migration tool and dry run

- [x] `extensions/drm-copilot/test/lib/development-docs-migration/layout-map.test.ts` asserts every row of the mapping table, longest-prefix-first ordering, the OQ-1 target taken from input, and that an unmapped entry is reported; it passes.
- [x] `extensions/drm-copilot/test/lib/development-docs-migration/folder-rename-plan.test.ts` asserts rename derivation rules 1 to 8 using child 2's parser cases F-1 to F-6 and formatter errors N-3 to N-5 as inputs, including a case-insensitive collision, a multi-folder issue number, an issue-first name left unchanged, and a trailing-issue name whose embedded earlier number is ignored; it passes.
- [x] `extensions/drm-copilot/test/lib/development-docs-migration/reference-rewrite.test.ts` asserts the prefix rewrite order, token-boundary matching, the `Write(`/`Edit(` protected-literal rule, renamed-basename rewriting, backslash occurrences reported and not rewritten, relative-link recomputation for sources at depths 3, 4 and 5 below the repository root (including `audit-*/` and `v1/` subfolders), links from unmoved files into moved trees, preserved fragments, unchanged scheme links, broken links reported, and that rewriting its own output changes nothing; it passes.
- [x] `extensions/drm-copilot/test/lib/development-docs-migration/migration-git.test.ts` asserts, with a fake `CommandRunner`, the exact argv of each `MigrationGit` method, `-z` NUL splitting of a path containing a space, and that `maxBuffer` is passed on listing calls; `extensions/drm-copilot/test/lib/subprocess-runner.test.ts` asserts that `SubprocessRunner` forwards `maxBuffer`; both pass.
- [x] `extensions/drm-copilot/test/lib/development-docs-migration/migration-decisions.test.ts` asserts schema validation, `source_digest` computation and mismatch refusal, refusal for a decision naming an unreported source, refusal for a `rename` target that does not parse as issue-first, and refusal for an unset required global choice; it passes.
- [x] `extensions/drm-copilot/test/lib/development-docs-migration/migration-plan.test.ts` asserts, with in-memory inputs, the plan for each refusal rule in "Refusal rules" (not a work tree, uncommitted tracked changes in apply mode, non-empty move target, collision, digest mismatch, missing decision file with held items or open global choices, unmapped entry), entry-by-entry planning for a merge into an existing directory, exclusion handling for D-15 fixtures and decision-file `rewrite_exclusions`, the three `in_tree_rewrite_scope` values, and the dry-run defaults in "Design Rule for Unresolved Owner Questions"; it passes.
- [x] `extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts` applies a plan to an in-memory fixture repository (fake `FileSystem` and fake `MigrationGit`) covering directory moves, folder renames, reference rewrites, link recomputation and `docs/README.md` creation; a second apply on the result yields an empty plan, issues no `move` call and writes no file; the `"moves-then-rewrites"` split performs moves on the first call and rewrites on the second; it passes.
- [x] `extensions/drm-copilot/test/lib/development-docs-migration/migration-report.test.ts` asserts that the Markdown and JSON reports contain every category listed in "Dry-run report contents", including untracked files and the `decision_skeleton` with `null` values; it passes.
- [x] Jest suites for the service call, `mcp-tool-inputs-development-docs.ts`, `mcp-handlers/development-docs-migration-handler.ts` and `migrate-development-docs-cli.ts` (under `extensions/drm-copilot/test/` mirroring the source paths) assert input validation, the handler's explicit error when `migrateDevelopmentDocs` is absent, CLI argv parsing, exit codes `0`, `1` and `2`, and that `main()` starts the stdio server when the first argument is not `migrate-development-docs`; they pass.
- [x] No test in the new suites creates a temporary file or directory or invokes real git; all I/O goes through in-memory fakes.
- [x] `extensions/drm-copilot/test/mcp-server.test.ts` "registers the semantic repo automation tools" lists `migrate_development_docs`, and `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` passes with the new definitions spread into both definition lists.
- [x] `RepoAutomationService` declares `migrateDevelopmentDocs` as an optional method, and the TypeScript type check passes with every existing full service fake unchanged.
- [x] `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` and `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` pass with `packages/mcp-server/package.json` `bin` and `files` unchanged.
- [x] No module under `extensions/drm-copilot/src/lib/development-docs-migration/` and none of the new `src/` modules import `vscode`, asserted by a test or a dependency-cruiser rule.
- [x] `extensions/drm-copilot/jest.config.cjs` has a `coverageThreshold` entry with `lines: 85` and `branches: 75` for each new production file, and coverage evidence for the changed TypeScript code meets those thresholds, recorded under `<FEATURE>/evidence/qa-gates/`.
- [x] `packages/mcp-server/README.md` and `extensions/drm-copilot/README.md` document the tool inputs, the `npx` subcommand and the decision-file requirement for apply mode.
- [x] A dry run against this repository from a branch build writes `<FEATURE>/evidence/other/dev-docs-migration-dry-run.<UTC>.md` and `.json`, the JSON contains a `source_digest` and a `decision_skeleton`, and `git status` after the run shows no change outside `<FEATURE>/evidence/other/`.
- [x] The stage A change adds no Python file, no PowerShell hook and no bash script, recorded by a name-status diff against the merge base of the integration branch and `HEAD` (ruling R6) stored under `<FEATURE>/evidence/qa-gates/`.
- [ ] The seven-stage toolchain passes in a single pass for the changed TypeScript, and no changed production file exceeds 800 lines.
- [x] A Phase 0 evidence artifact under `<FEATURE>/evidence/baseline/` records that the parallel run `bugs-1001-1002-1003-1006` and epic children 1 to 6 have merged, and that each named file, symbol and heading was re-checked against `origin/main` and the integration branch before any edit.

### Owner stop

- [x] `<FEATURE>/evidence/other/folder-rename-decisions.<UTC>.json` exists, follows the "Decision File" schema, names the dry-run JSON it answers, carries its `source_digest`, has a decision for every held item in that report, and records an answer in `global_decisions` for every owner question that affects execution.

### Stage B — move, rename and flip

- [x] A Phase 0 evidence artifact under `<FEATURE>/evidence/baseline/` records the stage B gate: preconditions re-checked, no open pull request touching `docs/features/**` or the overlap files, and a fresh dry-run `source_digest` equal to the decision file's.
- [x] After apply, `.dev/` holds the development records in the target layout (with discovery templates at `global_decisions.discovery_templates_target`), `docs/` contains `docs/README.md` stating that `docs/` holds production documentation only and no mapped source remains under `docs/`, and the moves were made with `git mv` (the commit shows renames for unchanged files).
- [x] Every folder renamed under `.dev/active`, `.dev/completed` and `.dev/archive` matches either the mechanical rule or its decision-file entry, every `keep` folder retains its name, and potential records, epics, parallel runs and research keep their names; a mechanical comparison of the post-apply folder list with the dry-run plan and decision file is stored under `<FEATURE>/evidence/other/`.
- [ ] A second dry run after apply reports an empty plan (no moves, renames or rewrites), stored under `<FEATURE>/evidence/other/`.
- [x] `development_docs_root` is `.dev` in `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`, and `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` passes.
- [x] The self-hosted `config/blast-radius.json` lists `.dev` in `path_roots` and `PINNED_SELF_HOSTED_PATH_ROOTS` matches it; the bundle copy keeps its empty Class 2 `path_roots` (ruling R1); and the blast-radius tests pass.
- [x] Both feature plan template copies link to `.github/instructions/` with the depth that resolves from `.dev/active/<folder>/`, and a link check over a plan created from the template after the flip finds no broken link.
- [x] The epic manifest `feature_folder` for child 2 names the renamed folder, and the epic manifest validation passes.
- [x] `PINNED_FROZEN_SURFACE_HASHES` is re-baselined with a dated comment for each pinned file whose text changed, `KICKOFF_IDENTITY_FRAGMENTS` matches the rewritten pinned text, and the parallel-orchestrator surface tests and `test_parallel_planner_surface_contracts.py` pass.
- [x] Historical JSON fixtures under `tests/fixtures/` and `tests/fixtures/blast_radius/historical-runs/` are unchanged by the stage B change (empty diff for those paths), and the tests that read them pass through child 2's matchers with the key at `.dev`.
- [x] Child 2's write-scope checker suite passes all three directions with the key at `.dev`, and every `Write(`/`Edit(` literal keeps both root forms during the fallback release (unless the owner's OQ-6 answer removes the fallback, in which case the checker passes with `.dev` literals only).
- [x] Every mirrored and bundled copy, pack manifest and Codex counterpart touched by the change has the text its contract requires, every generator `--check` reports no drift, and the tests in "Contract Tests" pass.
- [x] A recorded search over production roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`, `extensions/drm-copilot/src`) for `docs/features`, `docs/research`, `docs/engineering` and `docs/discovery` returns only child 2's resolver constants, its matcher unions and recorded Stay or exclusion entries; a link check over moved Markdown reports no link broken by the move; command, output and allowlist are stored under `<FEATURE>/evidence/other/`.
- [x] The orchestrator checkpoint records the post-move `<FEATURE>` path, and every stage B evidence artifact written after the move is under that path.
- [ ] The seven-stage toolchain passes in a single pass for TypeScript, Python and PowerShell with the key at `.dev`, recorded under `<FEATURE>/evidence/qa-gates/`, and no changed production file exceeds 800 lines.
- [x] The stage B change adds no Python file; any Python change is an in-place edit of an existing file, recorded by a name-status diff against the merge base of the integration branch and `HEAD` (ruling R6) stored under `<FEATURE>/evidence/qa-gates/`.
- [x] Each `global_decisions` answer that implies a stage B task (OQ-3, OQ-4, OQ-5, OQ-6, OQ-8, OQ-9, OQ-10, OQ-11) is either implemented with a named test or evidence artifact, or recorded as requiring no change, in the stage B completion evidence.

### Epic-level criteria owned by this child (promoted record)

- [x] `.dev/` holds all development records in the target layout, and `docs/` holds only production documentation plus a README stating its purpose.
- [ ] The TypeScript migration command moves a repository's folders with `git mv`, rewrites references, and a second run changes nothing (the `migration-apply.test.ts` second-apply case and the post-apply dry run).
- [x] The migration command and its tests need no Python.
- [ ] With `development_docs_root` set to `.dev`, the full toolchain passes.
- [x] Historical fixtures stay frozen and still pass through the fallback.
- [x] Mirrored and bundled files, pack manifests, Codex counterparts and contract tests pass.

## Risks and Pre-Mortem

| Risk | Mitigation |
| --- | --- |
| Write/Edit hooks do not see files moved by `git mv` or written by the tool process | dry-run review before apply; post-apply searches, link check and full toolchain |
| The branch tool is not reachable through `mcp__drm-copilot__*` until a release is installed | branch build launched from a `sh` script file; OQ-7 decides stage B |
| `spawnSync` default buffer (1 MiB) truncates the tracked-file listing | explicit `maxBuffer`, tested |
| `git mv` into an existing directory nests the source | non-empty-target refusal; entry-by-entry merge planning |
| Inexact renames when text is rewritten in the same commit as the move weaken rename detection and `git log --follow` (`diff.renameLimit` is unset, so the git default applies) | OQ-12 split option supported by the tool |
| A blind prefix rewrite corrupts mapping records, frozen fixtures, fallback literals and write-scope literals | exclusion globs, protected-literal rule, mapping-record candidate flag, dry-run listing of every excluded and protected occurrence |
| Untracked files move on disk without being re-indexed | listed in the dry run and apply result |
| Self-move: this folder, its plan, evidence and the decision file move during execution | decision file path passed explicitly; checkpoint updated in the same step; later evidence written only under the new path |
| Linux CI: case sensitivity and separators | forward-slash, case-explicit fixtures; case-insensitive collision logic tested with explicit inputs; no test diffs against `origin/main` |
| Prose edits reach generated outputs instead of child 3's sources, or a copy is missed | edit sources, run generators with `--check`, run every contract test, re-baseline pinned hashes and identity fragments |
| File size growth in `mcp-tools.ts`, `mcp-tool-definitions.ts`, `repo-automation-service.ts`, `jest.config.cjs` | definitions in a new module spread into both lists; one `case` and one method; a sibling JSON coverage map if `jest.config.cjs` nears the advisory tier |
| Tests that read moved repository files or the real routing config break after the move | the prefix rewrite updates real-file readers; injected config in unit tests; seeded shuffled runs recorded under `<FEATURE>/evidence/regression-testing/` |
| `.dev` is not an excluded FileSizePolicy segment | no covered extension exists under `docs/` today; OQ-10 |
| Plan template link depth breaks links in destinations still on `docs/features` | OQ-11 |
| Reviewer finds a stale `docs/features` literal or a broken link after the move | recorded production-root search against the Stay/exclusion allowlist and a link check, stored under `<FEATURE>/evidence/other/` |
| Coverage inflated by blanket mocks | seams are fakes that run the real planner and rewrite logic; per-file thresholds |
| The tree changes between approval and apply | `source_digest` check refuses apply |

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or evidence artifacts
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (`packages/mcp-server/README.md`, `extensions/drm-copilot/README.md`, `docs/README.md`)
- [ ] Toolchain pass completed (format → lint → type-check → architecture → test → contract → integration)

## Seeded Test Conditions (from potential)

- [x] Unit coverage areas: migration command including idempotence and link rewriting (this child); resolver, fallback order, dot-folder discovery, write-scope coverage and docs-only scope (child 2).
- [x] Integration scenarios: a full toolchain run with the key at `.dev` (this child); a migration of a fixture repository and a second no-op run (this child, in-memory); a destination without the key (child 2 R-1/R-2, OQ-3).
- [x] CLI/API examples (see "API / CLI Surface")
