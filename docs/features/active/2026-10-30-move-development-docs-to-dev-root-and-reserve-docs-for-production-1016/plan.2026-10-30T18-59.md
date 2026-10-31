# 2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production - Plan (Stage A)

- **Issue:** #1016 (epic #1018 child 7, wave 4)
- **Parent (optional):** epic #1018 (`docs/features/epics/shared-agent-harness-layer/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T18-59
- **Status:** Draft (stage A, pre-decision)
- **Version:** 1.0
- **Work Mode:** full-feature
- **Branch:** `feature/dev-docs-root-migration-phases-2-3-1016`

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md), [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Scope and Conventions

- Requirements: `spec.md` (`### Stage A — pre-decision plan (Phase 2: tool, tests, dry run; no move)`, `## Design Rule for Unresolved Owner Questions`, `## Behavior`, `## Decision File`, `## Inputs / Outputs`, `## API / CLI Surface`, `## Language Classification`, `## Execution Preconditions`, `## Acceptance Criteria` -> `### Stage A — migration tool and dry run`) and `user-story.md` (`### (a) Maintainer dry run and rename review`, ``### (b) Destination migration via `npx` without the extension``). Research: `research/research.2026-10-30T23-24.md`. Behavior details are specified there and are not restated here; tasks cite the spec heading that governs them.
- Stage A delivers the TypeScript `migrate_development_docs` MCP tool, its `npx` subcommand, its Jest suites, a branch build of `packages/mcp-server`, and a dry run of this repository. Stage A performs no `git mv`, no folder rename, and no `development_docs_root` flip. Version bumps, `CHANGELOG.md`, `.claude/settings.json`, `.codex/config.toml` and `contributes.commands` are unchanged (owner questions OQ-7, OQ-8, OQ-9).
- Child 2 (#1035) is consumed by name: `parseFeatureFolderName`, `formatFeatureFolderName`, `stripDateFirstPrefix` (`extensions/drm-copilot/src/lib/development-docs/feature-folder-name.ts`) and `developmentDocsPath`, `resolveDevelopmentDocsRoot`, `KNOWN_DEVELOPMENT_DOCS_ROOTS` (`extensions/drm-copilot/src/lib/development-docs/root.ts`), with the signatures in child 2's `spec.md` `## API / CLI Surface`. Those files are not on this branch at planning time; [P0-T4] proves them before any edit.
- `<FEATURE>` = `docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016`. `EXT` = `extensions/drm-copilot`.
- `SCRATCH` resolves to `<session scratchpad>/issue-1016/`; every scratch file, launcher script and staged copy lives under it and is recorded only as the token `SCRATCH`.
- `INTEGRATION` = `origin/epic/shared-agent-harness-layer-integration`. `BASE` = the merge base of `INTEGRATION` and `HEAD`, computed when the task runs; every scope diff anchors on `BASE` (or, for the `origin/main` re-check, on the merge base of `origin/main` and `HEAD`), never on a branch tip. This is the derivation used for the spec's "name-status diff against `origin/main`" criterion, because this child merges into `INTEGRATION`.
- Tool routes, launchers, command-text restrictions and CI shape are owned by the `execution-environment` skill; tasks reference it instead of restating it. Jest runs through `node run-jest.cjs` in `EXT`.
- Evidence: every artifact is `<FEATURE>/evidence/<kind>/<name>.<timestamp>.md` with the UTC write-time stamp; a consumer selects the lexicographically greatest match. Each command-step artifact carries `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:` and records no absolute path or host name.
- Loop rule: if any final-QA stage fails or changes a file, restart Phase 4 from [P4-T1].

## Language Classification

Owner language rule (epic `## Shared Design`): TypeScript only for MCP tools and extension commands; anything pushed down to destinations is PowerShell or bash; no new Python; existing Python is extended in place only; owner exception E2.

| Planned artifact | Runs where | Language | Rule status |
| --- | --- | --- | --- |
| Nine modules under `EXT/src/lib/development-docs-migration/` | MCP package | TypeScript (new) | conforms: MCP tool |
| `EXT/src/mcp-development-docs-tool-definitions.ts`, `mcp-tool-inputs-development-docs.ts`, `mcp-handlers/development-docs-migration-handler.ts` | MCP package and extension host | TypeScript (new) | conforms: MCP tool |
| `EXT/src/migrate-development-docs-cli.ts` and the `main()` dispatch in `EXT/src/mcp-server.ts` | MCP package `npx` entry | TypeScript | conforms: MCP tool entry (D-17) |
| Edits to `repo-automation-tool-names.ts`, both definition lists, `mcp-tools.ts`, `repo-automation-service-contract.ts`, `repo-automation-service.ts`, `lib/subprocess-runner.ts` | MCP package and extension | TypeScript (existing) | conforms |
| Jest suites and test support under `EXT/test/` | repository | TypeScript | conforms |
| `EXT/jest.development-docs-migration-coverage.json`, one merge line in `EXT/jest.config.cjs` | repository | JSON / CommonJS config | not production code |
| `packages/mcp-server/README.md`, `EXT/README.md` | repository and npm package | Markdown | not code |
| Dry-run report `.md` and `.json` under `<FEATURE>/evidence/other/` | repository evidence | Markdown / JSON | not code |
| `sh` launcher scripts under `SCRATCH` | agent session only, never committed | shell command text | conforms: not pushed down |

Nothing is pushed down to destination repositories in stage A, and no artifact requires Python, PowerShell or bash. No owner question arises from the classification.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Execution Gate and Baselines

- [ ] [P0-T1] Read the policy files in the `policy-compliance-order` sequence: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, then the authoritative `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`.
  - Acceptance: `<FEATURE>/evidence/baseline/phase0-instructions-read.<timestamp>.md` carries `Timestamp:`, `Policy Order:` and the twelve paths above, written before any file outside `<FEATURE>/evidence/` changes.
- [ ] [P0-T2] Verify the execution preconditions of spec `## Execution Preconditions`: issues 1001, 1002, 1003 and 1006 are closed and each has a pull request merged into `main` (parallel run `bugs-1001-1002-1003-1006`), and epic children 1 to 6 of `docs/features/epics/shared-agent-harness-layer/epic.md` each have a pull request merged into `INTEGRATION`, after a fetch of `origin`.
  - Acceptance: `<FEATURE>/evidence/baseline/execution-preconditions.<timestamp>.md` lists each issue and each child with its pull-request number, base branch and merged state. Any unmet item records `BLOCKED: precondition` and execution stops before [P0-T3] for the orchestrator.
- [ ] [P0-T3] Bring `INTEGRATION` into `HEAD`: when `git merge-base --is-ancestor` reports that `INTEGRATION` is not an ancestor of `HEAD`, merge it without editing the message; a conflict aborts the merge and stops for re-planning.
  - Acceptance: `git merge-base --is-ancestor origin/epic/shared-agent-harness-layer-integration HEAD` exits 0, and `<FEATURE>/evidence/baseline/integration-ancestry.<timestamp>.md` records the command, exit code and whether a merge was made.
- [ ] [P0-T4] Confirm child 2's exports on `HEAD`: read `EXT/src/lib/development-docs/root.ts` and `EXT/src/lib/development-docs/feature-folder-name.ts` and compare each export (`parseFeatureFolderName`, `formatFeatureFolderName`, `stripDateFirstPrefix`, `developmentDocsPath`, `resolveDevelopmentDocsRoot`, `KNOWN_DEVELOPMENT_DOCS_ROOTS`, the `FeatureFolderName` union and the `DevelopmentDocsArea` member `"discovery-templates"`) with child 2's `spec.md` `## API / CLI Surface`.
  - Acceptance: `<FEATURE>/evidence/baseline/child2-exports.<timestamp>.md` holds one row per export with `MATCH` or `DIFFERS`. Any `DIFFERS` row or missing file records `BLOCKED: re-plan` and execution stops.
- [ ] [P0-T5] Re-check every file, symbol and heading in `## Citation Register` and every overlap file in `## Overlap Files` against `origin/main` and `INTEGRATION`. For each ref, list upstream changes with `git diff --name-status <merge base of ref and HEAD> <ref> -- <overlap files>` and confirm the worktree is clean with `git status --porcelain`; then confirm each register symbol and heading is present in its file on `HEAD`.
  - Acceptance: `<FEATURE>/evidence/baseline/tree-recheck.<timestamp>.md` records, per ref, the merge base derivation (not a tip), the changed overlap files, and one `PRESENT` or `MOVED` row per register entry. Any `MOVED` row, or a register file absent on `HEAD`, records `BLOCKED: re-plan` and execution stops before Phase 1.
- [ ] [P0-T6] Confirm tier classification for the new paths: `quality-tiers.yml` classifies `extensions/drm-copilot` as T3, which covers every new `EXT/src/` file, and no new project directory or PowerShell module directory is planned (QT008 not triggered); run `scripts/dev_tools/check_quality_tiers.py` through Poetry.
  - Acceptance: `<FEATURE>/evidence/baseline/quality-tiers.<timestamp>.md` records the T3 entry, `EXIT_CODE: 0` for the checker, and the T3 gate consequences (at most five justified escape hatches per file; no property-test or mutation gate).
- [ ] [P0-T7] Record physical line counts on `HEAD` for `EXT/src/mcp-tools.ts`, `EXT/src/mcp-tool-definitions.ts`, `EXT/src/mcp-repo-automation-tool-definitions.ts`, `EXT/src/repo-automation-service.ts`, `EXT/src/repo-automation-service-contract.ts`, `EXT/src/repo-automation-tool-names.ts`, `EXT/src/mcp-server.ts`, `EXT/src/lib/subprocess-runner.ts`, `EXT/jest.config.cjs`, `EXT/test/mcp-server.test.ts`, `EXT/test/lib/subprocess-runner.test.ts` and `EXT/test/mcp-discovery-authority-tool-definitions.test.ts`, using a physical count per the execution-environment skill.
  - Acceptance: `<FEATURE>/evidence/baseline/file-size.<timestamp>.md` lists each count; a file whose count plus its planned growth (one `case` block, one method, one spread line, one list entry, one merge line) would reach 700 records `BLOCKED: re-plan`.
- [ ] [P0-T8] Capture the TypeScript format baseline with `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` in `EXT`.
  - Acceptance: `<FEATURE>/evidence/baseline/ts-format.<timestamp>.md` records exit code and, on success, the line `All matched files use Prettier code style!`; pre-existing drift is listed, not repaired.
- [ ] [P0-T9] Capture the TypeScript lint baseline with the `EXT` `lint` script.
  - Acceptance: `<FEATURE>/evidence/baseline/ts-lint.<timestamp>.md` records exit code and the error and warning counts, read from the ESLint `problems` summary line, or 0 errors and 0 warnings when ESLint prints no output (its success-case output is empty).
- [ ] [P0-T10] Capture the TypeScript type-check baseline with the `EXT` `typecheck` script (production and test configurations).
  - Acceptance: `<FEATURE>/evidence/baseline/ts-typecheck.<timestamp>.md` records exit code and the diagnostic count, taken as the number of `error TS` lines in the output (0 when `tsc` prints no output, which is its success-case output).
- [ ] [P0-T11] Capture the Jest coverage baseline with the `EXT` `test:coverage` script.
  - Acceptance: `<FEATURE>/evidence/baseline/ts-test-coverage.<timestamp>.md` records suite and test pass/fail counts, the `text-summary` totals for lines and branches, and per-file line and branch percentages, read from `EXT/coverage/lcov.info` (`LH/LF`, `BRH/BRF`), for `mcp-tools.ts`, `mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`, `repo-automation-service.ts`, `repo-automation-tool-names.ts`, `mcp-server.ts` and `lib/subprocess-runner.ts`.

### Phase 1 — Git Seam and Pure Migration Core

All new suites use in-memory fakes from `EXT/test/lib/development-docs-migration/migration-test-fakes.ts`; none creates a file or directory or invokes git. Core modules operate on repository-relative forward-slash paths and import no `vscode`.

- [ ] [P1-T1] Add optional `maxBuffer` to `CommandRunOptions` in `EXT/src/lib/subprocess-runner.ts`; `SubprocessRunner.run` adds it to the `spawnSync` options only when supplied, so every existing call passes byte-identical options. Add the case "passes maxBuffer through to spawnSync when provided" and the case "omits maxBuffer from spawnSync options when not provided" to `EXT/test/lib/subprocess-runner.test.ts`.
  - Existing tests asserting this behavior: `subprocess-runner.test.ts` "passes cwd through to spawnSync when provided" (unchanged: `objectContaining`); every other `EXT/test/` file found by searching for `SubprocessRunner`, `subprocess-runner` and `spawnSync` (for example `collect-commit-context-test-support.ts`, `runtime-test-helpers.ts`, `extension-test-harness.ts`) is unchanged because the option is optional and absent from their calls; the full Jest run in [P4-T5] confirms it.
  - Acceptance: `node run-jest.cjs test/lib/subprocess-runner.test.ts` reports 0 failed including both new cases.
- [ ] [P1-T2] Create `EXT/src/lib/development-docs-migration/migration-git.ts` with `MigrationGit`, `createMigrationGit(runner, cwd)` and the constant `MIGRATION_GIT_MAX_BUFFER`, per spec `### TypeScript seam`; create `migration-test-fakes.ts` (fake `CommandRunner` recording argv and options, in-memory `FileSystem`, fake `MigrationGit` recording `move` calls) and `EXT/test/lib/development-docs-migration/migration-git.test.ts`.
  - Tests: exact argv for each of the five methods; NUL splitting of a path containing a space; `maxBuffer` passed on both listing calls; `isInsideWorkTree` false on a non-zero result; `move` raising on a non-zero result.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/migration-git.test.ts` reports 0 failed.
- [ ] [P1-T3] Create `EXT/src/lib/development-docs-migration/layout-map.ts` (`LEGACY_LAYOUT_MAP` ordered longest prefix first, `mapLegacyPath(path, discoveryTarget)` returning the mapped path or an `unmapped` result) per spec `### Mapping table (research section 5)`, and `layout-map.test.ts`.
  - Tests: every mapping row; longest-prefix ordering (`docs/features/research/` before `docs/features/`); the OQ-1 target taken from the argument; an unmapped entry under `docs/` reported.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/layout-map.test.ts` reports 0 failed.
- [ ] [P1-T4] Create `EXT/src/lib/development-docs-migration/folder-rename-plan.ts` (`planFolderRenames(folders)` returning mechanical renames and held items) using child 2's `parseFeatureFolderName` and `formatFeatureFolderName`, per spec `### Feature-folder rename derivation (research section 6)` rules 1 to 8, and `folder-rename-plan.test.ts`.
  - Tests: inputs F-1 to F-6; formatter errors N-3 to N-5 reported, not thrown; a case-insensitive collision holding both folders; a multi-folder issue number; an issue-first name left unchanged; a trailing-issue name whose earlier embedded number is ignored (`2026-10-03-issue-823-tier-rule-adoption-follow-ups-824` yields 824).
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/folder-rename-plan.test.ts` reports 0 failed.
- [ ] [P1-T5] Create `EXT/src/lib/development-docs-migration/reference-rewrite.ts` (`rewritePrefixes`, `recomputeRelativeLinks`, protected-literal handling) per spec `### Reference rewrite rules (research section 4)`, and `reference-rewrite.test.ts`.
  - Tests: prefix order; token-boundary matching; `Write(`/`Edit(` protected literals; renamed-basename rewriting after a `.dev/<area>/` prefix only; backslash occurrences reported and not rewritten; link recomputation for sources at depths 3, 4 and 5 (including `audit-*/` and `v1/`); links from unmoved files into moved trees; fragments preserved; scheme links unchanged; broken links reported; rewriting its own output is a no-op.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/reference-rewrite.test.ts` reports 0 failed.
- [ ] [P1-T6] Create `EXT/src/lib/development-docs-migration/migration-decisions.ts` (`parseMigrationDecisions`, `computeSourceDigest` as SHA-256 of the sorted candidate folder paths, `buildDecisionSkeleton`) per spec `## Decision File`, and `migration-decisions.test.ts`.
  - Tests: schema validation (version, required globals as present strings); digest computation and mismatch refusal; refusal for a decision naming an unreported source; refusal for a `rename` target that does not parse as issue-first; refusal for an unset required global choice; skeleton values `null`.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/migration-decisions.test.ts` reports 0 failed.
- [ ] [P1-T7] Create `EXT/src/lib/development-docs-migration/migration-plan.ts` (`buildMigrationPlan(inputs)` returning a plan or a list of refusals) per spec `### Refusal rules`, `### Exclusions (D-15 and mapping records)`, `### Untracked-file reporting` and `## Design Rule for Unresolved Owner Questions`; files containing a NUL or U+FFFD after UTF-8 decoding are skipped and reported. Add `migration-plan.test.ts`.
  - Tests: each refusal rule (not a work tree; uncommitted tracked changes in apply mode; non-empty move target; collision; digest mismatch; missing decision file with held items or open global choices; unmapped entry); entry-by-entry planning into an existing directory; D-15 default exclusions and `rewrite_exclusions`; the three `in_tree_rewrite_scope` values; dry-run defaults including the OQ-1 target from `developmentDocsPath(".dev", "discovery-templates")` and separate OQ-2 and OQ-12 alternatives; counts derived from the supplied tracked-file list.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/migration-plan.test.ts` reports 0 failed.
- [ ] [P1-T8] Create `EXT/src/lib/development-docs-migration/migration-apply.ts` (`applyMigrationPlan(plan, { git, fileSystem })`: `ensureDir` on each destination parent, directory moves, folder renames, text rewrites, `docs/README.md` creation only when absent, `commit_split` handling; never commits) per spec `### Idempotence`, and `migration-apply.test.ts`.
  - Tests: an in-memory fixture repository covering moves, renames, rewrites, link recomputation and README creation; a second apply on the result yields an empty plan, issues no `move` call and writes no file; `"moves-then-rewrites"` performs moves on the first call and rewrites on the second; an existing `docs/README.md` left unchanged and reported.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/migration-apply.test.ts` reports 0 failed.
- [ ] [P1-T9] Create `EXT/src/lib/development-docs-migration/migration-report.ts` (`renderMigrationReportMarkdown`, `renderMigrationReportJson`, `migrationReportFileName(now)` producing `dev-docs-migration-dry-run.<yyyy-MM-ddTHH-mm>` in UTC from an injected clock) per spec `### Dry-run report contents`, and `migration-report.test.ts`.
  - Tests: Markdown and JSON contain every listed category, including untracked files, `source_digest` and `decision_skeleton` with `null` values; the file name uses the injected UTC clock; the report carries repository-relative paths only and never the workspace root.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/migration-report.test.ts` reports 0 failed.

### Phase 2 — Tool Surface, CLI and Coverage Gates

- [ ] [P2-T1] Create `EXT/src/lib/development-docs-migration/migrate-development-docs-service-call.ts` (`migrateDevelopmentDocsServiceCall({ fileSystem, runner, now, input })` composing seam, planner, applier and report; writes report files only when `report_directory` is supplied; returns `RepoAutomationExecutionResult` with `artifacts` and the counts `summary` of spec ``### MCP tool `migrate_development_docs` ``), and `migrate-development-docs-service-call.test.ts`.
  - Tests: dry run with and without `report_directory` (written files observed in the in-memory `FileSystem` only under that directory); apply refusal surfaces as a thrown error with the refusal reasons; resolved root reported through `resolveDevelopmentDocsRoot`.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/migrate-development-docs-service-call.test.ts` reports 0 failed.
- [ ] [P2-T2] Declare the optional method `migrateDevelopmentDocs?(input)` on `RepoAutomationService` in `EXT/src/repo-automation-service-contract.ts` and implement it on `DefaultRepoAutomationService` in `EXT/src/repo-automation-service.ts` by delegating to the service call with the injected `fileSystem` and `runner`; add `EXT/test/repo-automation-service.development-docs.test.ts` exercising the delegation through `createRepoAutomationService` with in-memory fakes.
  - Existing full-service fakes, each unchanged because the member is optional: `mcp-server-test-service.ts`, `mcp-tools.workspace-root.test.ts`, `mcp-tools.push-down-claude.test.ts`, `mcp-tools.potential-to-issue-target-repository.test.ts`, `mcp-tools.discovery.test.ts`, `mcp-tools.codex-native-converter.test.ts`, `mcp-server.discovery.test.ts`, `mcp-server-parallel-validation.test.ts`, `mcp-server-epic-validation.test.ts`, `mcp-plan-gate-warning-projection.test.ts`, `mcp-discovery-authority-tools.test.ts`, `extension.discovery-commands.test.ts`, `repo-automation-service-discovery.test.ts` (all under `EXT/test/`).
  - Acceptance: the `EXT` `typecheck` script exits 0 with those thirteen files unmodified, and `node run-jest.cjs test/repo-automation-service.development-docs.test.ts` reports 0 failed.
- [ ] [P2-T3] Create `EXT/src/mcp-tool-inputs-development-docs.ts` (`resolveMigrateDevelopmentDocsToolInput`: required `workspace_root` and `mode` in `"dry-run" | "apply"`, optional `rename_decisions_path` and `report_directory`) and `EXT/test/mcp-tool-inputs-development-docs.test.ts`.
  - Tests: valid inputs; missing and blank `workspace_root`; invalid `mode`; non-string optional fields; unknown keys.
  - Acceptance: `node run-jest.cjs test/mcp-tool-inputs-development-docs.test.ts` reports 0 failed.
- [ ] [P2-T4] Create `EXT/src/mcp-handlers/development-docs-migration-handler.ts` (`handleMigrateDevelopmentDocs(rawInput, service)`) that throws an explicit error naming `migrateDevelopmentDocs` when the service lacks the method, and `EXT/test/mcp-handlers/development-docs-migration-handler.test.ts`.
  - Tests: delegation with resolved input; explicit error when the method is absent; input error propagated.
  - Acceptance: `node run-jest.cjs test/mcp-handlers/development-docs-migration-handler.test.ts` reports 0 failed.
- [ ] [P2-T5] Register the tool: insert `"migrate_development_docs"` into `REPO_AUTOMATION_TOOLS` (`EXT/src/repo-automation-tool-names.ts`) directly after `"render_subagent_tree"`; create `EXT/src/mcp-development-docs-tool-definitions.ts` exporting `DEVELOPMENT_DOCS_TOOL_DEFINITIONS`; spread it before `...DISCOVERY_TOOL_DEFINITIONS` in `REPO_AUTOMATION_TOOL_DEFINITIONS` (`mcp-repo-automation-tool-definitions.ts`) and in `toolDefinitions` (`mcp-tool-definitions.ts`); add the `case "migrate_development_docs":` block calling `handleMigrateDevelopmentDocs` in `dispatchRepoAutomationTool` (`mcp-tools.ts`). Create `EXT/test/mcp-development-docs-tool-definitions.test.ts` (schema properties, `required`, `additionalProperties: false`, identical on both lists). Create the dispatch suite `EXT/test/mcp-tools.development-docs.test.ts`, following the `createMockService` convention of `mcp-tools.workspace-root.test.ts` (an in-memory `RepoAutomationService` object of `jest.fn()` members; only `vscode` is mocked, as a virtual module; no production module, `node:fs` or `node:child_process` is mocked), which calls `dispatchRepoAutomationTool("migrate_development_docs", ...)`.
  - Dispatch tests, per the output rule ("Errors become `ok: false` results through `toFailureToolResult`") under the spec heading ``### MCP tool `migrate_development_docs` ``: (a) with a fake `migrateDevelopmentDocs` resolving a result, the dispatch returns `ok: true`, `tool` `migrate_development_docs`, and the service's `summary` and `artifacts` unchanged, and the fake receives the resolved input; (b) with a fake service that omits `migrateDevelopmentDocs`, the dispatch returns `ok: false` (the `toFailureToolResult` path in the `catch` of `dispatchRepoAutomationTool`) whose `summary` names `migrateDevelopmentDocs`; (c) with an invalid `mode`, the dispatch returns `ok: false` whose `summary` names `mode`, and the fake method is not called; (d) a rejection from `migrateDevelopmentDocs` returns `ok: false` carrying the rejection message.
  - Existing tests: `mcp-server.test.ts` "registers the semantic repo automation tools" updated (name added after `render_subagent_tree`); `mcp-discovery-authority-tool-definitions.test.ts` "advertises all nineteen discovery tools in union order" updated (`REPO_AUTOMATION_TOOLS` length 43 becomes 44; the slice from `validate_discovery_artifacts` is unchanged); `mcp-discovery-tool-definitions.test.ts` "keeps the definition list aligned with the widened union order" unchanged (the last nineteen names remain the discovery tools); `mcp-repo-automation-tool-definitions.test.ts` unchanged (both lists spread one module); `packaging/discovery-resources.test.ts` "exposes one shared tool set to the standalone server and the extension provider" unchanged (the new `case` satisfies it).
  - Acceptance: `node run-jest.cjs` over those five existing files, the new definitions test and `test/mcp-tools.development-docs.test.ts` reports 0 failed, with the four dispatch cases (a) to (d) passing.
- [ ] [P2-T6] Create `EXT/src/migrate-development-docs-cli.ts` (`runMigrateDevelopmentDocsCli(argv, deps)` returning the exit code; flags `--workspace`, `--mode`, `--decisions`, `--report-dir` per spec `### CLI`; Markdown summary on stdout; reasons on stderr; production defaults `RealFileSystem`, `SubprocessRunner`, UTC clock) and `EXT/test/migrate-development-docs-cli.test.ts`.
  - Tests: argv parsing; exit 0 on success; exit 1 on refusal or execution error; exit 2 on an unknown flag, a missing `--workspace` or `--mode`, and an invalid mode; injected streams capture output.
  - Acceptance: `node run-jest.cjs test/migrate-development-docs-cli.test.ts` reports 0 failed.
- [ ] [P2-T7] Change `main()` in `EXT/src/mcp-server.ts` to take an argument list (default `process.argv.slice(2)`) and optional entry points: when the first argument is `migrate-development-docs` it sets `process.exitCode` from the CLI; otherwise it starts the stdio server unchanged. Add `EXT/test/mcp-server.main.test.ts`.
  - Tests: subcommand dispatch with injected entry points; server start for no argument and for another first argument.
  - Existing tests: `packaging/discovery-resources.test.ts` "imports no VS Code host module from the standalone server entry" and "bundles the same server entry for the extension and the standalone package" unchanged; `mcp-server.test.ts` uses `createRepoAutomationMcpServer` and is unaffected.
  - Acceptance: `node run-jest.cjs test/mcp-server.main.test.ts test/packaging/discovery-resources.test.ts test/packaging/mcp-server-prepack.test.ts` reports 0 failed, and `packages/mcp-server/package.json` `bin` and `files` are unchanged against `BASE`.
- [ ] [P2-T8] Create `EXT/test/lib/development-docs-migration/no-vscode-import.test.ts`, the architecture-boundary test: it reads each new production file of this plan and asserts no `from "vscode"` import and no `require("vscode")`.
  - Acceptance: `node run-jest.cjs test/lib/development-docs-migration/no-vscode-import.test.ts` reports 0 failed, and the test names all thirteen new production files.
- [ ] [P2-T9] Create `EXT/jest.development-docs-migration-coverage.json` with one entry `{ "lines": 85, "branches": 75 }` per new production file (the nine `lib/development-docs-migration/` modules, `mcp-development-docs-tool-definitions.ts`, `mcp-tool-inputs-development-docs.ts`, `mcp-handlers/development-docs-migration-handler.ts`, `migrate-development-docs-cli.ts`), merge it into `coverageThreshold` in `EXT/jest.config.cjs` after the discovery map, and create `EXT/test/development-docs-migration-coverage-contracts.test.ts` asserting each entry, that each path is an existing file, that the merge reaches the Jest configuration, and that no `global` key exists.
  - Acceptance: `node run-jest.cjs test/development-docs-migration-coverage-contracts.test.ts test/discovery-coverage-contracts.test.ts` reports 0 failed.
- [ ] [P2-T10] Document the tool in `packages/mcp-server/README.md` (new section `## Development Docs Migration`: `npx` subcommand, flags, exit codes, decision-file requirement for apply mode) and in `EXT/README.md` (`### Exposed MCP Tools` and `### MCP Input Summary` entries for `migrate_development_docs`).
  - Acceptance: `EXT/README.md` lists `migrate_development_docs` under both named headings; `packages/mcp-server/README.md` carries the heading `## Development Docs Migration` and, in that section, the tokens `migrate-development-docs` and `--decisions`.

### Phase 3 — Branch Build and Dry Run

- [ ] [P3-T1] Build the standalone package from the branch (`npm --prefix packages/mcp-server ci`, then its `build` script), launched per the execution-environment skill.
  - Acceptance: `<FEATURE>/evidence/other/mcp-server-branch-build.<timestamp>.md` records `EXIT_CODE: 0` for both steps and that `packages/mcp-server/out/mcp-server.js` exists; `git status --porcelain` captured immediately before and immediately after the build is identical (the build adds no tracked change; earlier uncommitted plan work is present in both captures and is not attributed to the build).
- [ ] [P3-T2] Run the dry run against this repository from the branch build: a `sh` launcher under `SCRATCH` runs `node packages/mcp-server/out/mcp-server.js migrate-development-docs --workspace . --mode dry-run --report-dir <FEATURE>/evidence/other` from the repository root, with no decision file.
  - Acceptance: exit 0; the tool writes `<FEATURE>/evidence/other/dev-docs-migration-dry-run.<timestamp>.md` and `.json`; the newest JSON parses and holds a string `source_digest` and an object `decision_skeleton`; `git status --porcelain` is captured immediately before and immediately after the dry run, and every path added or changed between the two captures is under `<FEATURE>/evidence/other/` (uncommitted Phase 0 to Phase 2 work appears in both captures and is not attributed to the dry run); `<FEATURE>/evidence/other/dev-docs-migration-dry-run-command.<timestamp>.md` records the command, exit code, both porcelain captures and their difference and the report's category counts. No `git mv`, rename or key flip is performed.

### Phase 4 — Final QA Loop, Self-Review and Handoff

- [ ] [P4-T1] Run the format stage: `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` in `EXT`. On failure, run the `EXT` format script, then restart from [P4-T1].
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-format.<timestamp>.md` records `EXIT_CODE: 0` and the line `All matched files use Prettier code style!`.
- [ ] [P4-T2] Run the lint stage with the `EXT` `lint` script.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-lint.<timestamp>.md` records `EXIT_CODE: 0`, 0 errors (no ESLint `problems` summary line with a non-zero error count; a clean run prints no output), and no new suppression comment in a new file.
- [ ] [P4-T3] Run the type-check stage with the `EXT` `typecheck` script.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-typecheck.<timestamp>.md` records `EXIT_CODE: 0`.
- [ ] [P4-T4] Run the architecture-boundary stage: `no-vscode-import.test.ts`, the `quality-tiers.yml` checker, and a file search (not `git grep`, because the suites may be untracked) of every test file this plan creates for the tokens `mkdtemp`, `tmpdir`, `writeFileSync` and `child_process`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-architecture.<timestamp>.md` records 0 failed for the test, `EXIT_CODE: 0` for the checker, and zero matches for each token.
- [ ] [P4-T5] Run the unit stage with coverage using the `EXT` `test:coverage` script.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-test-coverage.<timestamp>.md` records `EXIT_CODE: 0`, suite and test counts with 0 failed, the totals, and per-file line and branch percentages from `EXT/coverage/lcov.info` for the thirteen new files (each at or above 85 and 75) and the seven changed files of [P0-T11].
- [ ] [P4-T6] Compare coverage: baseline ([P0-T11] artifact) against post-change ([P4-T5] artifact) for the seven changed files (including `mcp-tools.ts`, whose new `case` block the [P2-T5] dispatch suite covers) and totals, and record new-code coverage for the thirteen new files.
  - Acceptance: `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md` lists baseline, post-change and delta per file; no changed file's line or branch percentage decreases, else the task fails and Phase 4 restarts after added tests.
- [ ] [P4-T7] Run the contract stage: `mcp-repo-automation-tool-definitions.test.ts`, `mcp-development-docs-tool-definitions.test.ts`, `mcp-discovery-tool-definitions.test.ts`, `mcp-discovery-authority-tool-definitions.test.ts`, `packaging/discovery-resources.test.ts`, `packaging/mcp-server-prepack.test.ts` and `development-docs-migration-coverage-contracts.test.ts`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-contract.<timestamp>.md` records 0 failed across the seven suites.
- [ ] [P4-T8] Run the integration stage: `mcp-server.test.ts`, `mcp-server.main.test.ts` and the dispatch suite `mcp-tools.development-docs.test.ts`, then rebuild `packages/mcp-server` and invoke the built bundle with `migrate-development-docs` and no flags from a `sh` launcher under `SCRATCH`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/ts-integration.<timestamp>.md` records 0 failed for the three suites and `EXIT_CODE: 0` for the build; the bundle invocation is recorded in its own artifact `<FEATURE>/evidence/qa-gates/ts-integration-usage.<timestamp>.md` with `EXIT_CODE: 2`, `ExpectedExitCode: 2` and the usage message from stderr.
- [ ] [P4-T9] Run the isolation check: `node run-jest.cjs --randomize --seed=1016` in `EXT`.
  - Acceptance: `<FEATURE>/evidence/regression-testing/jest-shuffle-seed-1016.<timestamp>.md` records the printed seed line (Jest prints `Seed:` followed by padding spaces and `1016`, so the line is matched on the two tokens, not on a single-space literal) and 0 failed. An order dependence is fixed on both sides and the run repeated.
- [ ] [P4-T10] Measure physical line counts of every file this plan creates or edits.
  - Acceptance: `<FEATURE>/evidence/qa-gates/file-size.<timestamp>.md` lists each count; `mcp-tools.ts`, `mcp-tool-definitions.ts`, `repo-automation-service.ts` and `jest.config.cjs` are below 700, and no file exceeds 800.
- [ ] [P4-T11] Record the language scope of the change: `git diff --name-status <BASE> HEAD` for committed changes plus `git status --porcelain` for uncommitted and untracked files.
  - Acceptance: `<FEATURE>/evidence/qa-gates/language-scope.<timestamp>.md` lists every changed path and records zero `.py` files, zero files under `.claude/hooks/` or `.codex/hooks/`, and zero `.sh` or `.bats` files.
- [ ] [P4-T12] Walk `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against the diff from `BASE`, and the stage A acceptance criteria of `spec.md`.
  - Acceptance: `<FEATURE>/evidence/qa-gates/self-review.<timestamp>.md` holds one PASS, FAIL or N/A row per checklist item and per stage A criterion, with no FAIL row; a FAIL is fixed and Phase 4 re-run before the file is rewritten.
- [ ] [P4-T13] Record the stage A handoff: the orchestrator-owned owner stop follows this plan (spec `### Owner stop (orchestrator-owned, between the plans)`); the executor does not wait for the owner and does not start stage B.
  - Acceptance: `<FEATURE>/evidence/other/stage-a-handoff.<timestamp>.md` names the newest `dev-docs-migration-dry-run.*.json`, its `source_digest`, the held-item and open-global-choice counts, and states that no decision file was written and no move, rename or flip occurred.

## Citation Register

Re-checked by [P0-T5]; the plan names these symbols, headings and tests.

- `EXT/src/repo-automation-tool-names.ts`: `REPO_AUTOMATION_TOOLS`, `RepoAutomationToolName`.
- `EXT/src/mcp-repo-automation-tool-definitions.ts`: `REPO_AUTOMATION_TOOL_DEFINITIONS`. `EXT/src/mcp-tool-definitions.ts`: `toolDefinitions`, `ToolDefinition`. `EXT/src/mcp-discovery-tool-definitions.ts`: `DISCOVERY_TOOL_DEFINITIONS`.
- `EXT/src/mcp-tools.ts`: `dispatchRepoAutomationTool`, `toFailureToolResult`, `toMcpToolResult`, `listRepoAutomationTools`. `EXT/test/mcp-tools.workspace-root.test.ts`: `createMockService` (fake-service convention for [P2-T5]).
- `EXT/src/repo-automation-service-contract.ts`: `RepoAutomationService`, `RepoAutomationExecutionResult`, `resolveOrchestrationTopology?`. `EXT/src/repo-automation-service.ts`: `DefaultRepoAutomationService`, `createRepoAutomationService`.
- `EXT/src/mcp-server.ts`: `main`, `createRepoAutomationMcpServer`. `EXT/src/lib/subprocess-runner.ts`: `CommandRunOptions`, `SubprocessRunner`, `CommandRunner`. `EXT/src/lib/file-system.ts`: `FileSystem`, `RealFileSystem`.
- `EXT/jest.config.cjs`: `coverageThreshold`; `EXT/jest.discovery-coverage.json`; `EXT/run-jest.cjs`; `EXT/package.json` scripts `lint`, `typecheck`, `test:coverage`.
- Tests: `EXT/test/mcp-server.test.ts` "registers the semantic repo automation tools"; `EXT/test/mcp-discovery-authority-tool-definitions.test.ts` "advertises all nineteen discovery tools in union order"; `EXT/test/mcp-discovery-tool-definitions.test.ts` "keeps the definition list aligned with the widened union order"; `EXT/test/mcp-repo-automation-tool-definitions.test.ts` "defines one schema entry for every advertised repo automation tool"; `EXT/test/packaging/discovery-resources.test.ts` "exposes one shared tool set to the standalone server and the extension provider"; `EXT/test/lib/subprocess-runner.test.ts` "passes cwd through to spawnSync when provided"; `EXT/test/discovery-coverage-contracts.test.ts`; `EXT/test/packaging/mcp-server-prepack.test.ts`; the thirteen fake files of [P2-T2].
- `packages/mcp-server/package.json` (`bin`, `files`, `build`); `packages/mcp-server/README.md`; `EXT/README.md` headings `### Exposed MCP Tools`, `### MCP Input Summary`; `quality-tiers.yml` entry `extensions/drm-copilot`; `scripts/dev_tools/check_quality_tiers.py`.
- Child 2 (post-merge): `EXT/src/lib/development-docs/root.ts` and `feature-folder-name.ts` exports of [P0-T4].

## Overlap Files

From spec `## Execution Preconditions` and research section 11; listed by [P0-T5] for both refs. Stage A edits only `EXT/jest.config.cjs` and `EXT/README.md` among them.

- `.claude/agents/epic-orchestrator.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/agents/parallel-planner.md`; `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`; `.claude/skills/{epic-orchestrate,orchestrate,parallel-add,parallel-orchestrate,parallel-plan,parallel-run}/SKILL.md`; `.claude/settings.json`; and each bundle copy under `EXT/resources/claude-customizations/.claude/`.
- The six execution-environment brief copies named in that skill's `## Purpose and Maintenance`; `.codex/config.toml`.
- `docs/features/templates/parallel/parallel-status.md`; the three `docs/features/templates/policy_audit/` templates.
- `config/blast-radius.json`, `EXT/resources/claude-customizations/config/blast-radius.json`, `config/file-size-baseline.json`.
- `EXT/jest.config.cjs`, `EXT/package.json`, `EXT/CHANGELOG.md`, `EXT/README.md`.
- `EXT/resources/claude-customizations/pack-manifests/core.json`, `EXT/resources/codex-and-agents-customizations/pack-manifests/core.json`.
- `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py`, `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`, `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, the push-down contract tests named in the brief's `## Contract Tests That Pin Mirrored Files`, `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1`.
- Every `docs/features/active/2026-10-30-*` folder of the parallel run, plus `EXT/src/mcp-tools.ts`, the tool-definition modules and `EXT/test/mcp-server.test.ts` (epic child 4 overlap).

## Pre-Mortem

- Review checklists: a reviewer finds a stage A criterion unmet or a checklist item failing; [P4-T12] walks all three `policy_audit` templates and every stage A criterion against the `BASE` diff and blocks completion on any FAIL row.
- Coverage: a new production file escapes the per-file gate or coverage is inflated; [P2-T9] gives each of the thirteen new files its own `lines: 85`/`branches: 75` entry and pins them with a contract test, the suites use fakes that run the real planner, rewrite and apply logic (no `jest.mock` of production modules), the dispatch suite of [P2-T5] drives the new `case "migrate_development_docs":` block of `mcp-tools.ts` through both its success return and its `catch` path, and [P4-T6] blocks any decrease on the seven changed files, `mcp-tools.ts` included.
- Mirror parity: not applicable. Stage A edits no mirrored or bundled file (`EXT/README.md` and `packages/mcp-server/README.md` have no copies; nothing under `.claude/`, `.codex/`, `.agents/`, `.github/` or `EXT/resources/` changes), and no fact the execution-environment brief states changes: no CI job, required context, tool route or batch-budget rule is altered, and new files still receive their own entry in the merged `coverageThreshold` map.
- File size: `mcp-tools.ts`, `mcp-tool-definitions.ts`, `repo-automation-service.ts` and `jest.config.cjs` grow by one `case`, one spread line, one delegating method and one merge line; the definitions live in a new module and the thresholds in a sibling JSON map. [P0-T7] stops the plan if growth would reach 700, and [P4-T10] verifies below 700 and none above 800.
- Test isolation: [P4-T9] runs a seeded shuffled Jest run with seed 1016 recorded; no suite creates a file or invokes git. The reversed-order Python run and the three-seed Pester shuffle are not applicable because stage A touches no Python and no PowerShell test or source.
- CI-only behavior: Linux case sensitivity and separators; fixtures use forward-slash, case-explicit repository-relative paths and no drive letters, collision logic is tested with explicit mixed-case inputs, no test reads gitignored `artifacts/` state or diffs against `origin/main`, and the architecture test reads only tracked source files.
- Evidence: every artifact is written under `<FEATURE>/evidence/<kind>/` with a write-time UTC stamp; the dry-run report records repository-relative paths only (asserted in [P1-T9]), `SCRATCH` is recorded as a token, and `git status --porcelain` in [P3-T2] proves the dry run changed nothing outside `<FEATURE>/evidence/other/`.

## Size Justification

The plan carries 45 tasks because stage A ships thirteen new production modules, each with its own suite and acceptance, plus a five-part Phase 0 execution gate the spec requires and a seven-stage final QA loop with one artifact per stage; merging tasks would join independent binary outcomes.

## Test Plan

- Unit: the Phase 1 and Phase 2 suites under `EXT/test/lib/development-docs-migration/`, `EXT/test/mcp-handlers/` and `EXT/test/`, all with in-memory fakes.
- Integration: `mcp-server.test.ts` (in-memory MCP transport), `mcp-server.main.test.ts`, `mcp-tools.development-docs.test.ts` (dispatch through `dispatchRepoAutomationTool`), the branch build, the dry run ([P3-T2]) and the usage-error invocation ([P4-T8]).
- Manual/CLI: none beyond the recorded dry run.
- Coverage evidence: baseline `<FEATURE>/evidence/baseline/ts-test-coverage.<timestamp>.md`; post-change `<FEATURE>/evidence/qa-gates/ts-test-coverage.<timestamp>.md`; comparison `<FEATURE>/evidence/qa-gates/coverage-delta.<timestamp>.md`.

## Open Questions / Notes

- Owner questions OQ-1 to OQ-13 are not decided here; the tool takes OQ-1, OQ-2, OQ-12 and OQ-13 from the decision file per spec `## Design Rule for Unresolved Owner Questions`.
- The orchestrator-owned owner stop follows [P4-T13]; the stage B plan is authored only after `folder-rename-decisions.<timestamp>.json` exists.
