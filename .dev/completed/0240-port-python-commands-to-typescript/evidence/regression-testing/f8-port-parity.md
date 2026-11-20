# F8 Behavior-Parity Capture

Timestamp: 2026-06-26T00-00
Command: `node run-jest.cjs --coverage --collectCoverageFrom="src/lib/**/*.ts"` (run from `extensions/drm-copilot/`)
EXIT_CODE: 0

Output Summary: 85 suites / 999 tests pass. Each parity property below maps to a passing Jest test.

## Parity properties → tests

- Feature-name / slug validation
  - `validateFeatureName` accepts kebab/underscore, throws byte-identical message — `test/lib/new-active-feature-folder/models.test.ts`.
  - `buildFolderSlug` underscore normalization, potential-stem preference, issue-number suffix, byte-identical invalid-slug throw — `io.test.ts`.

- Type / work-mode handling
  - `createActiveFolder` invalid-type throw `Type must be one of: feature, refactor, epic, bug` — `flow.test.ts`.
  - `normalizeRequestedWorkMode` reused (F1) + `shouldUseMinorAuditMode` [false,'']/[true,'']/out-of-set throw — `docs.test.ts` / `flow.test.ts`.

- Issue title/metadata fetch via `gh`
  - `defaultIssueFetcher` arg vector `gh issue view <n> --json number,title,url,author,updatedAt`, null on missing gh / non-zero exit / blank stdout / invalid JSON, IssueMeta build with name/YYYY-MM-DD fallbacks — `io.test.ts`.

- Template selection by type and work-mode
  - `copyTemplate` bug-branch break-after-timestamped-plan, copies plan.md only when timestamped absent, non-bug copyTree — `io.test.ts`, `flow.test.ts` (bug template preservation).
  - `copyFeatureTemplateForMinorAudit` prefers timestamped then plan.md — `io.test.ts`.

- Template-root resolution
  - `templateRoot/<type>` vs workspace fallback — exercised via `flow.test.ts` (templateRoot supplied) and the missing-template throw `Template folder not found: <dir>`.
  - Service forwards `this.templateRoot` — `new-active-feature-folder-service-call.test.ts` (templateRoot forwarded) and `extension.new-active-feature-folder-inprocess.test.ts` (forwards templateRoot to the bundled feature-templates, no python spawn).

- Markdown section manipulation / escaping
  - `setSection` / `updateSectionBody` backslash regressions (C:\\Outlook\\Objects preserved via function-form replacement) — `markdown.test.ts`.
  - `getSection`, `setHeaderPlaceholder` (placeholders, <issue>/<id>/<status>/<version_number>, bold + plain metadata rewrites, `- Issue:` prepend), `formatChecklist`, `upsertWorkModeMarker` — `markdown.test.ts`.

- Feature-doc updates
  - `updateFeatureDocs` per-type sections/ordering for feature/refactor/epic/bug, `files_to_open` ordering, bug Context/Repro/Root-Cause concatenation with the exact labels, `Test Strategy` `Seeded from issue:` prepend — `docs.test.ts`.

- Minor-audit mode detection + doc routing
  - Potential-file move to issue.md + `upsertWorkModeMarker("minor-audit")`, and the verbatim no-potential `issue.md` body (the five `(not provided in potential file)` sections + the three-line Evidence Checklist) — `flow.test.ts`.

- Created folder/file paths and content
  - Target dir `docs/features/active/<slug>`, materialized `plan.<timestamp>.md`, doc files written — `flow.test.ts`, `extension.new-active-feature-folder.test.ts`.

- Optional VS Code launch (guarded/no-op in service path)
  - Launcher resolves CLI / returns false / emits manual-open warning lines; the service-call helper passes a no-op launcher returning false — `io.test.ts`, `flow.test.ts`, `new-active-feature-folder-service-call.test.ts`.

- EST timestamp deterministic formatting (clock seam)
  - `getEstTimestamp` formats a fixed injected instant as `2024-02-03T04-05` in America/New_York — `models.test.ts`.
  - Documented divergence: the Python naive-datetime `ValueError` guard has no TS analogue because a `Date` is always an absolute instant (no naive form); no spurious throw is introduced. `getEstTimestamp` is the single injectable wall-clock seam (no direct `Date.now()`).

- Exit-code / error-surface preservation
  - Workflow `Error` messages (invalid type, missing template, target exists) propagate through the service-call helper and the command handler — `new-active-feature-folder-service-call.test.ts`, `extension.new-active-feature-folder-inprocess.test.ts` (`Target exists:`).

- Preserved service return contract
  - `tool: "new_active_feature_folder"`, `workspaceRoot`, byte-identical `summary` (`Created a new active <type> feature folder for '<name>'.`), additive `destinationPath` and `artifacts` — `new-active-feature-folder-service-call.test.ts`.

- Preserved MCP input contract
  - `feature_name`, `type`, `issue_number`, `work_mode`, `workspace_root` unchanged; `resolveNewActiveFeatureFolderToolInput` and `handleNewActiveFeatureFolder` not modified; their tests pass unmodified (full suite green).

## Recorded decisions

- artifacts/destinationPath decision (from P0-T2 / P4-T1): No existing extension test asserts the absence of `artifacts`/`destinationPath` for `new_active_feature_folder`, so the enrichment is additive and safe. Success returns `destinationPath = normalizeGeneratedPath(result.target)` and `artifacts = [normalizeGeneratedPath(potentialIssuePath)]` when a potential file was moved.
- Failure-surface contract (from P0-T2 / P4-T1): The prior Python-spawn path threw `Command exited with code <n>.` on a non-zero exit and `Python runtime 'python' not found on PATH.` when python was absent. The in-process path needs no python (the missing-python case is inverted to assert success), and workflow `Error` messages propagate unchanged (re-thrown), preserving the surfaced-failure behavior.
