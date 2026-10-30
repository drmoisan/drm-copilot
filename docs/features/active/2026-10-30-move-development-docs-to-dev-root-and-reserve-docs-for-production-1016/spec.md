# 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production — Spec

- **Issue:** #1016
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-59
- **Status:** Draft
- **Version:** 0.1

## Overview

`docs/features/` has outgrown its name. It holds potential entries, active and completed features, an archive, epics, parallel orchestrations, templates and research, and it is 28,452 of the files under `docs/`. It is development-process material, but it sits in the folder that conventionally holds production documentation. The same layout is pushed to every destination repo that uses this toolset.

Goal: separate development documentation from production documentation. Development records move to a new top-level `.dev/` root. `docs/` is reserved for production documentation.

Most professional repos keep work-tracking state in the issue tracker, and keep design records as one file per decision with a status in the header. This repo uses the folder as the lifecycle (potential, active, completed, archive). That is why a rename is expensive, and why this item moves the tree and changes no lifecycle behavior.


## Behavior

Delivered as ONE feature with three phases, merged as one change set (owner decision). Update 2026-10-30: this feature is now incorporated into epic #1018 (shared agent-harness layer). It is split by its own phases: Phase 1 (resolver and configured root, default unchanged) is child 2 of the epic and runs early so later children use the resolver; Phases 2 and 3 (migration command, the move to `.dev` and the default flip) are child 7, the last child, after the other epic work has merged. The epic takes priority over this item as a standalone feature. Update 2026-10-30 (owner decision E1 on epic #1018): issue #1016 is adopted by child 7 (Phases 2 and 3), so #1016 closes only when the move to `.dev` completes. Phase 1 (child 2) is delivered under a new child issue that references #1016 and does not close it.

**Target layout** (the `features` level is dropped):

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

**Phase 1: resolver and configured root.**

- One configured key, `development_docs_root`, default `docs/features` during Phase 1 so behavior is identical. Every hook, validator, MCP tool and script reads it. No consumer hard-codes the path.
- A resolver in each runtime (Python, PowerShell, TypeScript) fed by the one key. Today there is no shared constant: TypeScript has `ACTIVE_FEATURE_DOCS_DIRECTORY` and `POTENTIAL_DOCS_DIRECTORY` in `extension-command-helpers.ts` and many inlined literals; Python and PowerShell have per-module constants.
- Transition support: resolve `.dev` when it exists and fall back to `docs/features` otherwise, for one release, then remove the fallback.
- Update `config/ci-docs-only-paths.json` so `.dev/**` counts as docs-only for the CI change scope, as `docs/features` does today.
- Add `.dev/**/*.json` to the governed globs in `json-config.ts` (and its Python source) so governance is not dropped.
- Give every Node-glob and ripgrep consumer explicit dot-folder handling, with a test that finds a file under `.dev`. Python and PowerShell include dot folders by default.
- Change every agent and hook write scope from `docs/**` and `docs/features/**` to the `.dev` root, generated or checked as a literal because permission rules cannot read config, with a test that each agent's scope covers the root.
- Add the feature-folder name parser (the old date-first format and the new `<NNNN>-<feature>` format both accepted) and make the folder-creation tool name new folders from the issue number (D-18 to D-22).
- Update the mirrored and bundled copies, pack manifests and Codex counterparts.

**Phase 2: migration command (TypeScript, no Python).**

- A TypeScript command, exposed as an MCP tool in `@danmoisan/drm-copilot-mcp` with a thin `npx` entry point, so agents and destination repos without the extension can run it.
- It moves `docs/features`, `docs/engineering`, `docs/research` and `docs/discovery` into `.dev` with `git mv`, rewrites in-repo path references and links, creates the `docs/README.md` boundary note, and is safe to re-run (idempotent).

**Phase 3: move this repo and flip the default.**

- Run the migration on this repo as one mechanical commit, flip `development_docs_root` to `.dev`, and update the tests and prose.
- Rename the existing feature folders in `active`, `completed` and `archive` to the new format in the same move, reporting non-matching folders and issue-number collisions and stopping for an owner decision on each.
- Historical JSON fixtures that record past runs stay frozen with their `docs/features` paths and are read through the fallback.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- Scale: about 896 files outside `docs/` mention `docs/features` (4,291 occurrences), including 31 in `.claude/hooks` and `.claude/lib`, 18 in the extension source, 29 in `scripts`, 19 in `.github` and 492 in `tests`. Tests alone: about 2,300 occurrences across 324 files (102 Python, 130 PowerShell, 92 TypeScript) plus 245 JSON fixtures (1,191 occurrences).
- The tree is about 28k files, mostly `archive` and `completed`. `git mv` keeps history, but the diff is very large and `git blame` needs `--follow`.
- This conflicts with every in-flight item that cites `docs/features/active/...` paths, so it must run after the other items in the current batch have merged.
- Dot-folder risk: Node glob libraries and ripgrep skip dot folders by default; Python and PowerShell do not.
- Agent permission rules cannot read config, so write scopes become generated or checked literals; a missed scope fails mid-run.
- Enforcement hooks do not invoke Python.
- Decisions D-12 to D-17 were confirmed by the owner on 2026-10-30.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas: resolver in each runtime with the key set to each root; fallback order; migration command including idempotence and link rewriting; dot-folder discovery; write-scope coverage; docs-only scope.
- [x] Integration scenarios: a full toolchain run with the key at `docs/features` and at `.dev`; a migration of a fixture repo and a second no-op run; a destination without the key.
- [ ] CLI/API examples
