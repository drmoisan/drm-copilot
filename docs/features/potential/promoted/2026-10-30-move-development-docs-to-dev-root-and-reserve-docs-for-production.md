# move-development-docs-to-dev-root-and-reserve-docs-for-production (Issue #1016)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/move-development-docs-to-dev-root-and-reserve-docs-for-production/ (Issue #1016)

- Issue: #1016
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1016
- Last Updated: 2026-10-30
## Problem / Why

`docs/features/` has outgrown its name. It holds potential entries, active and completed features, an archive, epics, parallel orchestrations, templates and research, and it is 28,452 of the files under `docs/`. It is development-process material, but it sits in the folder that conventionally holds production documentation. The same layout is pushed to every destination repo that uses this toolset.

Goal: separate development documentation from production documentation. Development records move to a new top-level `.dev/` root. `docs/` is reserved for production documentation.

Most professional repos keep work-tracking state in the issue tracker, and keep design records as one file per decision with a status in the header. This repo uses the folder as the lifecycle (potential, active, completed, archive). That is why a rename is expensive, and why this item moves the tree and changes no lifecycle behavior.

## Proposed Behavior

Delivered as ONE feature with three phases, merged as one change set (owner decision). Update 2026-10-30: this feature is now incorporated into epic #1018 (shared agent-harness layer). It is split by its own phases: Phase 1 (resolver and configured root, default unchanged) is child 2 of the epic and runs early so later children use the resolver; Phases 2 and 3 (migration command, the move to `.dev` and the default flip) are child 7, the last child, after the other epic work has merged. The epic takes priority over this item as a standalone feature.

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

## Acceptance Criteria (early draft)

- [ ] `.dev/` holds all development records in the layout above, and `docs/` holds only production documentation plus a README stating its purpose.
- [ ] One configured key, `development_docs_root`, drives every consumer in Python, PowerShell and TypeScript; no consumer hard-codes the old path.
- [ ] With the default `docs/features` the repo behaves exactly as before Phase 1; with `.dev` set, the full toolchain passes.
- [ ] A destination repo that has not migrated keeps working through the fallback for one release.
- [ ] The TypeScript migration command moves a destination's folders with `git mv`, rewrites references, and a second run changes nothing.
- [ ] The migration command and its tests need no Python.
- [ ] `.dev/**` counts as docs-only in the CI change scope, and `.dev/**/*.json` stays under JSON governance.
- [ ] A test proves every Node-glob and ripgrep consumer finds a record under `.dev`.
- [ ] A test proves every agent and hook write scope covers the configured root.
- [ ] Historical fixtures stay frozen and still pass through the fallback.
- [ ] Mirrored and bundled files, pack manifests, Codex counterparts and contract tests pass.

## Constraints & Risks

- Scale: about 896 files outside `docs/` mention `docs/features` (4,291 occurrences), including 31 in `.claude/hooks` and `.claude/lib`, 18 in the extension source, 29 in `scripts`, 19 in `.github` and 492 in `tests`. Tests alone: about 2,300 occurrences across 324 files (102 Python, 130 PowerShell, 92 TypeScript) plus 245 JSON fixtures (1,191 occurrences).
- The tree is about 28k files, mostly `archive` and `completed`. `git mv` keeps history, but the diff is very large and `git blame` needs `--follow`.
- This conflicts with every in-flight item that cites `docs/features/active/...` paths, so it must run after the other items in the current batch have merged.
- Dot-folder risk: Node glob libraries and ripgrep skip dot folders by default; Python and PowerShell do not.
- Agent permission rules cannot read config, so write scopes become generated or checked literals; a missed scope fails mid-run.
- Enforcement hooks do not invoke Python.
- Decisions D-12 to D-17 were confirmed by the owner on 2026-10-30.

## Decisions

Settled by the owner:

- **D-1** `epics/` and `parallel/` move under `.dev`.
- **D-2** Standalone (non-issue) research moves to `.dev/research/`.
- **D-3** `docs/engineering/` moves to `.dev/engineering/`.
- **D-4** `docs/features/templates/` and `docs/discovery/` move under `.dev`.
- **D-5** `.dev` is a normal, tracked, searchable folder; tools opt in explicitly and `README.md` documents it.
- **D-6** The `features` level is dropped (`.dev/active`, not `.dev/features/active`).
- **D-7** One configured root key, read by every consumer.
- **D-8** One release of fallback to `docs/features`, then removed.
- **D-9** The migration command is TypeScript, needs no Python, and is safe to re-run.
- **D-10** `docs/` keeps only production documentation, starting with a short README.
- **D-11** Delivered as one feature with three phases, run after the current batch merges.

Confirmed by the owner on 2026-10-30:

- **D-12** `.dev/**` is added to `config/ci-docs-only-paths.json`.
- **D-13** Every Node-glob and ripgrep consumer gets explicit dot handling plus a test.
- **D-14** `.dev/**/*.json` is added to the governed globs.
- **D-15** The 245 historical fixtures stay frozen and read through the fallback.
- **D-16** Agent and hook write scopes use a generated or checked literal, with a coverage test.
- **D-17** The migration command is an MCP tool in `@danmoisan/drm-copilot-mcp` with a thin `npx` entry point.
- **D-18** Feature folders are named `<4-digit zero-padded issue number>-<feature>` (four digits, because issue numbers already exceed 999).
- **D-19** Parsers treat `^\d{4}-\d{2}-\d{2}-` as the old date-first format and any other name starting with 4 digits and a dash as the new format.
- **D-20** The 339 existing folders are renamed in the same mass move as the `.dev` migration; parsers accept both formats until then.
- **D-21** The migration reports the 36 non-matching folders and the issue numbers with several folders, and stops for an owner decision on each; folders with no recoverable number keep their names.
- **D-22** Only feature folders in `active`, `completed` and `archive` change; potential records, epics, parallel runs and research keep their names.

## Test Conditions to Consider

- [x] Unit coverage areas: resolver in each runtime with the key set to each root; fallback order; migration command including idempotence and link rewriting; dot-folder discovery; write-scope coverage; docs-only scope.
- [x] Integration scenarios: a full toolchain run with the key at `docs/features` and at `.dev`; a migration of a fixture repo and a second no-op run; a destination without the key.
- [ ] CLI/API examples

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/move-development-docs-to-dev-root-and-reserve-docs-for-production/` folder from the template
