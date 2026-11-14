# `2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production` — User Story

- Issue: #1016 (adopted by epic #1018 child 7 per owner decision E1; this child closes #1016)
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-10-30
- Work Mode: full-feature (acceptance criteria in this file and in `spec.md`)
- Spec: `spec.md` (stages A and B, owner stop, decision file, refusal rules, owner questions OQ-1 to OQ-13)
- Consumed contracts: `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/spec.md` (child 2, #1035)

## Story Statement

- As a maintainer of this repository, I want to run the migration as a dry run and review every planned move, rename and rewrite, so that nothing changes until the plan has been checked.
- As a maintainer of a destination repository that does not install the VS Code extension, I want to migrate my development records with `npx`, so that I can adopt the `.dev` layout without the extension or Python.
- As the owner, I want every non-matching folder, multi-folder issue number and open design question presented to me with the evidence, so that I decide them once and the tool applies exactly those decisions.
- As a contributor working in this repository after the flip, I want development records under `.dev/` and the tools resolving `.dev`, so that `docs/` holds only production documentation and every workflow still works.

## Problem / Why

`docs/features/` holds potential entries, active and completed features, an archive, epics, parallel orchestrations, templates and research. It is development-process material in the folder that conventionally holds production documentation, and the same layout is pushed to every destination repository. Child 2 (#1035) adds the configured root and the folder-name parser with the default unchanged. This child provides the migration tool, moves this repository to `.dev`, renames feature folders to `<NNNN>-<feature>` and flips the default. A repository-wide move with folder renames cannot be undone cheaply, so it needs a dry run, an owner decision step and a refusal when the tree changes after approval.

## Personas & Scenarios

- Persona: repository maintainer (agent or human operating the orchestrator in this repository)
  - Cares about a reviewable, reversible change and about not breaking hooks, mirrors and contract tests.
  - Constraint: the MCP surface runs the installed package, so a branch-built tool runs through `node packages/mcp-server/out/mcp-server.js` from a `sh` script file.
- Persona: destination-repository maintainer
  - Uses the pushed-down toolset without the extension; may have local feature folders and links that must keep working.
  - Constraint: no Python; only `npx` is available.
- Persona: owner
  - Decides held items and owner questions; does not want the tool or the plans to decide them implicitly.
- Persona: contributor after the flip
  - Creates features, plans and evidence; expects new folders under `.dev/active/<NNNN>-<feature>/` and working template links.

- Scenario (a): dry run and review
  1. After children 1 to 6 and the parallel run `bugs-1001-1002-1003-1006` merge, the stage A plan builds the tool and runs a dry run against this repository from a branch build.
  2. The report lists moves, mechanical renames, held items, files to rewrite, exclusions, protected occurrences, broken links and untracked files, and nothing outside the report directory changes.
- Scenario (b): destination migration via `npx`
  1. The maintainer runs `npx -y @danmoisan/drm-copilot-mcp migrate-development-docs --workspace . --mode dry-run --report-dir <dir>`.
  2. The maintainer fills the `decision_skeleton` from the report into a decision file and runs `--mode apply --decisions <file>`, then commits.
  3. A repeated apply changes nothing.
- Scenario (c): owner decisions
  1. The orchestrator presents the dry-run report and OQ-1 to OQ-13.
  2. The owner answers; the orchestrator writes `folder-rename-decisions.<UTC>.json` with the report's `source_digest`.
  3. If the tree changes before apply, the tool refuses and a new dry run and decision are needed.
- Scenario (d): this repository after the flip
  1. Stage B applies the decisions, flips `development_docs_root` to `.dev` and updates tests, prose, templates and pins.
  2. Contributors create folders under `.dev/active/`, and the full toolchain passes with the key at `.dev`.

## Acceptance Criteria

### (a) Maintainer dry run and rename review

- [ ] A dry run of `migrate_development_docs` against this repository from a branch build writes `dev-docs-migration-dry-run.<UTC>.md` and `.json` under `<FEATURE>/evidence/other/`, and `git status` after the run shows no change outside that directory.
- [ ] The dry-run report lists planned directory moves, mechanical renames, held items with their candidates (non-matching folders, multi-folder issue numbers, formatter errors, case-insensitive collisions), unmapped entries, files to rewrite with occurrence counts, excluded files, protected occurrences, mapping-record candidates, broken links, backslash-separated occurrences, untracked files, a `source_digest` and a `decision_skeleton`, as asserted by `migration-report.test.ts`.
- [ ] Counts in the report are derived mechanically from the tracked-file listing at run time; no count is taken from the research snapshot.
- [ ] Without a decision file, the dry run reports the OQ-1 discovery-templates target from `developmentDocsPath(".dev", "discovery-templates")` and reports the OQ-2 and OQ-12 alternatives separately, applying nothing, as asserted by `migration-plan.test.ts`.

### (b) Destination migration via `npx` without the extension

- [ ] `npx -y @danmoisan/drm-copilot-mcp migrate-development-docs --workspace <path> --mode dry-run|apply [--decisions <path>] [--report-dir <path>]` runs the same planner and applier as the MCP tool, with exit codes `0` (success), `1` (refusal or error) and `2` (usage error), as asserted by the CLI Jest suite.
- [ ] `packages/mcp-server/package.json` `bin` and `files` are unchanged, and `discovery-resources.test.ts` passes.
- [ ] Apply mode refuses and changes nothing when the decision file is missing while the report has a held item or an open global choice, when a required decision is unset, when `source_digest` differs, when a move target is non-empty, when targets collide case-insensitively, when an unmapped entry exists, when tracked files have uncommitted changes, or when the workspace is not a git work tree, as asserted by `migration-plan.test.ts` and `migration-decisions.test.ts`.
- [ ] Applying to an in-memory fixture repository moves the trees with `git mv` calls, renames folders, rewrites references, recomputes relative links and creates `docs/README.md`, and a second apply issues no `move` call and writes no file, as asserted by `migration-apply.test.ts`.
- [ ] The migration tool, its CLI entry and its tests contain no Python and do not import `vscode`.
- [ ] `packages/mcp-server/README.md` documents the `npx` subcommand, its flags and the decision-file requirement for apply mode.

### (c) Owner decisions on held items

- [ ] The orchestrator presents the dry-run report and OQ-1 to OQ-13 to the owner as questions, and neither plan decides them.
- [ ] `<FEATURE>/evidence/other/folder-rename-decisions.<UTC>.json` records a `rename` (with an issue-first target) or `keep` action for every held item in the dry-run report, the report's `source_digest`, the `rewrite_exclusions` globs, and a `global_decisions` answer for each owner question that affects execution.
- [ ] Apply honors each decision exactly: `keep` folders retain their names, `rename` folders receive the stated target, and unreported date-first folders with an issue number follow the mechanical rule; a mechanical comparison against the decision file is stored under `<FEATURE>/evidence/other/`.
- [ ] A change to the tree after approval causes apply to refuse on the `source_digest` check until a new dry run and decision file are produced.

### (d) This repository after the flip

- [ ] `.dev/` holds the development records in the target layout, and `docs/` contains `docs/README.md` stating that it holds production documentation only and no mapped source remains under `docs/`.
- [ ] `development_docs_root` is `.dev` in `config/orchestration-routing.json`, `extensions/drm-copilot/resources/config/orchestration-routing.json` and `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`, and `test_orchestration_routing_config_parity.py` passes.
- [ ] Feature folders under `.dev/active`, `.dev/completed` and `.dev/archive` use `<NNNN>-<feature>` names except the folders kept by rule or decision; potential records, epics, parallel runs and research keep their names.
- [ ] A plan created from the feature plan template after the flip has working `.github/instructions/` links, and both template copies carry the same link depth.
- [ ] Historical JSON fixtures under `tests/fixtures/` are unchanged and their tests pass through the fallback with the key at `.dev`.
- [ ] Child 2's write-scope checker, every generator `--check`, and the contract tests listed in `spec.md` "Contract Tests" pass.
- [ ] The full seven-stage toolchain passes for TypeScript, Python and PowerShell with the key at `.dev`, recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] A post-apply dry run reports an empty plan, recorded under `<FEATURE>/evidence/other/`.
- [ ] No new Python file is added by this child.

## Non-Goals

- Re-opening any settled decision (D-1 to D-22) or deciding any owner question (OQ-1 to OQ-13).
- Child 2's resolver, parser, formatter, area map and write-scope contract (consumed, not changed except as an owner answer requires).
- Removing the one-release fallback (D-8), unless the owner's OQ-6 answer assigns it to this child.
- Renaming potential records, epics, parallel runs or research folders (D-22).
- Rewriting git history or historical JSON fixtures (D-15).
- Adding the tool to permission allow-lists, Codex `enabled_tools` or a VS Code extension command, unless the owner's OQ-8 or OQ-9 answer requires it.
- Changing lifecycle semantics of potential, active, completed and archive.
