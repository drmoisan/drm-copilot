# 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production — Spec

- **Issue:** #1016 (adopted by epic child 7 per owner decision E1; this child closes #1016)
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`), child 7, wave 4 (last)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
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

An entry under `docs/features/` or `docs/` that the table does not map is reported as unmapped, and apply mode refuses while any unmapped entry exists. After apply, `docs/` contains only `docs/README.md` and any production documentation that was not a mapped source.

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

Markdown and JSON (`dev-docs-migration-dry-run.<UTC>.md` and `.json`): planned directory moves; mechanical renames; held items (non-matching folders, multi-folder issue numbers, formatter errors, collisions) with candidates; unmapped entries; files to rewrite with occurrence counts, split into outside-moved-trees and the three in-tree categories; excluded files and protected occurrences; mapping-record candidates; broken relative links; backslash-separated occurrences; untracked and ignored files; `source_digest`; `decision_skeleton`.

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

- Execution of either plan starts only after the parallel run `bugs-1001-1002-1003-1006` (issues 1001, 1002, 1003, 1006, open at the time of writing) has merged to `main`, and after epic children 1 to 6 have merged; this child is wave 4, the last.
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

## Owner Questions

Recorded as questions only. None is decided by this spec.

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

- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/layout-map.test.ts` asserts every row of the mapping table, longest-prefix-first ordering, the OQ-1 target taken from input, and that an unmapped entry is reported; it passes.
- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/folder-rename-plan.test.ts` asserts rename derivation rules 1 to 8 using child 2's parser cases F-1 to F-6 and formatter errors N-3 to N-5 as inputs, including a case-insensitive collision, a multi-folder issue number, an issue-first name left unchanged, and a trailing-issue name whose embedded earlier number is ignored; it passes.
- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/reference-rewrite.test.ts` asserts the prefix rewrite order, token-boundary matching, the `Write(`/`Edit(` protected-literal rule, renamed-basename rewriting, backslash occurrences reported and not rewritten, relative-link recomputation for sources at depths 3, 4 and 5 below the repository root (including `audit-*/` and `v1/` subfolders), links from unmoved files into moved trees, preserved fragments, unchanged scheme links, broken links reported, and that rewriting its own output changes nothing; it passes.
- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/migration-git.test.ts` asserts, with a fake `CommandRunner`, the exact argv of each `MigrationGit` method, `-z` NUL splitting of a path containing a space, and that `maxBuffer` is passed on listing calls; `extensions/drm-copilot/test/lib/subprocess-runner.test.ts` asserts that `SubprocessRunner` forwards `maxBuffer`; both pass.
- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/migration-decisions.test.ts` asserts schema validation, `source_digest` computation and mismatch refusal, refusal for a decision naming an unreported source, refusal for a `rename` target that does not parse as issue-first, and refusal for an unset required global choice; it passes.
- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/migration-plan.test.ts` asserts, with in-memory inputs, the plan for each refusal rule in "Refusal rules" (not a work tree, uncommitted tracked changes in apply mode, non-empty move target, collision, digest mismatch, missing decision file with held items or open global choices, unmapped entry), entry-by-entry planning for a merge into an existing directory, exclusion handling for D-15 fixtures and decision-file `rewrite_exclusions`, the three `in_tree_rewrite_scope` values, and the dry-run defaults in "Design Rule for Unresolved Owner Questions"; it passes.
- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts` applies a plan to an in-memory fixture repository (fake `FileSystem` and fake `MigrationGit`) covering directory moves, folder renames, reference rewrites, link recomputation and `docs/README.md` creation; a second apply on the result yields an empty plan, issues no `move` call and writes no file; the `"moves-then-rewrites"` split performs moves on the first call and rewrites on the second; it passes.
- [ ] `extensions/drm-copilot/test/lib/development-docs-migration/migration-report.test.ts` asserts that the Markdown and JSON reports contain every category listed in "Dry-run report contents", including untracked files and the `decision_skeleton` with `null` values; it passes.
- [ ] Jest suites for the service call, `mcp-tool-inputs-development-docs.ts`, `mcp-handlers/development-docs-migration-handler.ts` and `migrate-development-docs-cli.ts` (under `extensions/drm-copilot/test/` mirroring the source paths) assert input validation, the handler's explicit error when `migrateDevelopmentDocs` is absent, CLI argv parsing, exit codes `0`, `1` and `2`, and that `main()` starts the stdio server when the first argument is not `migrate-development-docs`; they pass.
- [ ] No test in the new suites creates a temporary file or directory or invokes real git; all I/O goes through in-memory fakes.
- [ ] `extensions/drm-copilot/test/mcp-server.test.ts` "registers the semantic repo automation tools" lists `migrate_development_docs`, and `extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts` passes with the new definitions spread into both definition lists.
- [ ] `RepoAutomationService` declares `migrateDevelopmentDocs` as an optional method, and the TypeScript type check passes with every existing full service fake unchanged.
- [ ] `extensions/drm-copilot/test/packaging/discovery-resources.test.ts` and `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts` pass with `packages/mcp-server/package.json` `bin` and `files` unchanged.
- [ ] No module under `extensions/drm-copilot/src/lib/development-docs-migration/` and none of the new `src/` modules import `vscode`, asserted by a test or a dependency-cruiser rule.
- [ ] `extensions/drm-copilot/jest.config.cjs` has a `coverageThreshold` entry with `lines: 85` and `branches: 75` for each new production file, and coverage evidence for the changed TypeScript code meets those thresholds, recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] `packages/mcp-server/README.md` and `extensions/drm-copilot/README.md` document the tool inputs, the `npx` subcommand and the decision-file requirement for apply mode.
- [ ] A dry run against this repository from a branch build writes `<FEATURE>/evidence/other/dev-docs-migration-dry-run.<UTC>.md` and `.json`, the JSON contains a `source_digest` and a `decision_skeleton`, and `git status` after the run shows no change outside `<FEATURE>/evidence/other/`.
- [ ] The stage A change adds no Python file, no PowerShell hook and no bash script, recorded by a name-status diff against the merge base of the integration branch and `HEAD` (ruling R6) stored under `<FEATURE>/evidence/qa-gates/`.
- [ ] The seven-stage toolchain passes in a single pass for the changed TypeScript, and no changed production file exceeds 800 lines.
- [ ] A Phase 0 evidence artifact under `<FEATURE>/evidence/baseline/` records that the parallel run `bugs-1001-1002-1003-1006` and epic children 1 to 6 have merged, and that each named file, symbol and heading was re-checked against `origin/main` and the integration branch before any edit.

### Owner stop

- [ ] `<FEATURE>/evidence/other/folder-rename-decisions.<UTC>.json` exists, follows the "Decision File" schema, names the dry-run JSON it answers, carries its `source_digest`, has a decision for every held item in that report, and records an answer in `global_decisions` for every owner question that affects execution.

### Stage B — move, rename and flip

- [ ] A Phase 0 evidence artifact under `<FEATURE>/evidence/baseline/` records the stage B gate: preconditions re-checked, no open pull request touching `docs/features/**` or the overlap files, and a fresh dry-run `source_digest` equal to the decision file's.
- [ ] After apply, `.dev/` holds the development records in the target layout (with discovery templates at `global_decisions.discovery_templates_target`), `docs/` contains `docs/README.md` stating that `docs/` holds production documentation only and no mapped source remains under `docs/`, and the moves were made with `git mv` (the commit shows renames for unchanged files).
- [ ] Every folder renamed under `.dev/active`, `.dev/completed` and `.dev/archive` matches either the mechanical rule or its decision-file entry, every `keep` folder retains its name, and potential records, epics, parallel runs and research keep their names; a mechanical comparison of the post-apply folder list with the dry-run plan and decision file is stored under `<FEATURE>/evidence/other/`.
- [ ] A second dry run after apply reports an empty plan (no moves, renames or rewrites), stored under `<FEATURE>/evidence/other/`.
- [ ] `development_docs_root` is `.dev` in `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`, and `tests/scripts/dev_tools/test_orchestration_routing_config_parity.py` passes.
- [ ] The self-hosted `config/blast-radius.json` lists `.dev` in `path_roots` and `PINNED_SELF_HOSTED_PATH_ROOTS` matches it; the bundle copy keeps its empty Class 2 `path_roots` (ruling R1); and the blast-radius tests pass.
- [ ] Both feature plan template copies link to `.github/instructions/` with the depth that resolves from `.dev/active/<folder>/`, and a link check over a plan created from the template after the flip finds no broken link.
- [ ] The epic manifest `feature_folder` for child 2 names the renamed folder, and the epic manifest validation passes.
- [ ] `PINNED_FROZEN_SURFACE_HASHES` is re-baselined with a dated comment for each pinned file whose text changed, `KICKOFF_IDENTITY_FRAGMENTS` matches the rewritten pinned text, and the parallel-orchestrator surface tests and `test_parallel_planner_surface_contracts.py` pass.
- [ ] Historical JSON fixtures under `tests/fixtures/` and `tests/fixtures/blast_radius/historical-runs/` are unchanged by the stage B change (empty diff for those paths), and the tests that read them pass through child 2's matchers with the key at `.dev`.
- [ ] Child 2's write-scope checker suite passes all three directions with the key at `.dev`, and every `Write(`/`Edit(` literal keeps both root forms during the fallback release (unless the owner's OQ-6 answer removes the fallback, in which case the checker passes with `.dev` literals only).
- [ ] Every mirrored and bundled copy, pack manifest and Codex counterpart touched by the change has the text its contract requires, every generator `--check` reports no drift, and the tests in "Contract Tests" pass.
- [ ] A recorded search over production roots (`.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`, `extensions/drm-copilot/src`) for `docs/features`, `docs/research`, `docs/engineering` and `docs/discovery` returns only child 2's resolver constants, its matcher unions and recorded Stay or exclusion entries; a link check over moved Markdown reports no link broken by the move; command, output and allowlist are stored under `<FEATURE>/evidence/other/`.
- [ ] The orchestrator checkpoint records the post-move `<FEATURE>` path, and every stage B evidence artifact written after the move is under that path.
- [ ] The seven-stage toolchain passes in a single pass for TypeScript, Python and PowerShell with the key at `.dev`, recorded under `<FEATURE>/evidence/qa-gates/`, and no changed production file exceeds 800 lines.
- [ ] The stage B change adds no Python file; any Python change is an in-place edit of an existing file, recorded by a name-status diff against the merge base of the integration branch and `HEAD` (ruling R6) stored under `<FEATURE>/evidence/qa-gates/`.
- [ ] Each `global_decisions` answer that implies a stage B task (OQ-3, OQ-4, OQ-5, OQ-6, OQ-8, OQ-9, OQ-10, OQ-11) is either implemented with a named test or evidence artifact, or recorded as requiring no change, in the stage B completion evidence.

### Epic-level criteria owned by this child (promoted record)

- [ ] `.dev/` holds all development records in the target layout, and `docs/` holds only production documentation plus a README stating its purpose.
- [ ] The TypeScript migration command moves a repository's folders with `git mv`, rewrites references, and a second run changes nothing (the `migration-apply.test.ts` second-apply case and the post-apply dry run).
- [ ] The migration command and its tests need no Python.
- [ ] With `development_docs_root` set to `.dev`, the full toolchain passes.
- [ ] Historical fixtures stay frozen and still pass through the fallback.
- [ ] Mirrored and bundled files, pack manifests, Codex counterparts and contract tests pass.

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
