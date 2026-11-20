# F8 Phase 0 — Instructions Read

Timestamp: 2026-06-26T00-00

Policy Order:
1. CLAUDE.md (standing instructions)
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/typescript.md
5. .claude/rules/typescript-suppressions.md
6. .claude/rules/quality-tiers.md
7. .claude/rules/architecture-boundaries.md
8. .claude/rules/self-explanatory-code-commenting.md
9. .claude/rules/tonality.md

Files Read (all nine):
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\CLAUDE.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\general-code-change.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\general-unit-test.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\typescript.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\typescript-suppressions.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\quality-tiers.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\architecture-boundaries.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\self-explanatory-code-commenting.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\tonality.md

Notes:
- typescript.md names Vitest as the test framework, but the F8 task and plan establish (accepted decision D1) that the `extensions/drm-copilot/` package uses Jest (`jest.config.cjs`, `ts-jest`, `run-jest.cjs`). The Jest toolchain is the binding fact for this feature. Coverage thresholds (line >= 85%, branch >= 75%) from quality-tiers.md and general-unit-test.md still apply.
- self-explanatory-code-commenting.md mandates docstrings on every class/function, intent comments on loops, and decision-logic comments on branches; applied to all new TS modules.

Validator note: The orchestration-artifact MCP validator tool (`mcp__drm-copilot__validate_orchestration_artifacts`) is not available in this execution environment. The plan was provided as approved by the orchestrator; execution proceeds under that approval.

## Files Read for Port (P0-T2)

Timestamp: 2026-06-26T00-00

BUNDLED port sources (parity targets — read, not modified):
- extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_models.py
- extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_markdown.py
- extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_io.py
- extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_docs.py
- extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder_flow.py
- extensions/drm-copilot/resources/scripts/dev_tools/new_active_feature_folder.py (facade __all__)

Wrapper (confirms --template-root injection; no TS port needed):
- extensions/drm-copilot/resources/templates/new_active_feature_folder.py — injects `--template-root` = `<wrapperParent.parent>/feature-templates`, i.e. `<extensionRoot>/resources/feature-templates`. This matches `this.templateRoot = buildTemplateRoot(extensionRoot)`. Confirmed: the service forwards `this.templateRoot` to replicate the wrapper.

Reference copies (root scripts/dev_tools — confirmed present, identical structure):
- scripts/dev_tools/new_active_feature_folder{,_models,_markdown,_io,_docs,_flow}.py

Python scenario tests (mirrored into Jest):
- tests/scripts/dev_tools/test_new_active_feature_folder.py, _part2.py, _part3.py, _part4.py, _bug_template_preserved.py, _markdown_escape.py, _models_coverage.py
- tests/extensions/drm_copilot/resources/templates/test_new_active_feature_folder.py
- Notable: markdown-escape backslash regressions (`set_section`/`update_section_body` must use function-form replacement); models-coverage `copy_tree`/`list_files`/`move`(mkdir→unlink→replace)/`get_est_timestamp`(2024-02-03T04-05) edge cases.

F1 reuse targets (confirmed exports; not modified):
- extensions/drm-copilot/src/lib/subprocess-runner.ts — `CommandRunner.run(args, {cwd?, allowError?})` => `CommandResult{stdout,stderr,code}`; `SubprocessRunner`.
- extensions/drm-copilot/src/lib/file-system.ts — `FileSystem` exposes ONLY glob/isFile/readTextFile/writeTextFile/ensureDir; NO exists/copyFile/copyTree/listFiles/readText/writeText/move (confirmed — port-local `FolderFileSystem` is required). `toPosixPath` exported; `RealFileSystem` exported.
- extensions/drm-copilot/src/lib/prompt-mode-contract.ts — `normalizeRequestedWorkMode(requestedMode, promotionType)`, `ACCEPTED_WORK_MODES` exported.

Service / wiring (read; service modified only at newActiveFeatureFolder in P4-T3):
- extensions/drm-copilot/src/repo-automation-service.ts — line count = 496 (NOT 500; 4-line headroom). `newActiveFeatureFolder` body (lines 342-353) = `return this.executeScript(buildNewActiveFeatureFolderOptions(input, this.templateRoot));`. Injection: `this.templateRoot` (=buildTemplateRoot), `this.runner`, `this.fileSystem` (F1 FileSystem), `this.output.appendLine`. `RepoAutomationExecutionResult` supports `artifacts?`/`destinationPath?`.
- extensions/drm-copilot/src/repo-automation-service-workflows.ts — `buildNewActiveFeatureFolderOptions` (NOT removed; only the import is dropped from the service). Summary string: `Created a new active ${input.type} feature folder for '${input.featureName}'.`
- extensions/drm-copilot/src/repo-automation-args.ts — `buildNewActiveFeatureFolderArgs`: args `--feature-name <name> --type <type> [--issue-number <n> when defined] --work-mode <mode> --template-root <root>`. Confirms `issueNumber` omitted when undefined.
- extensions/drm-copilot/src/repo-automation-service-support.ts — `normalizeGeneratedPath` (backslash->forward), `buildTemplateRoot`.
- extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts and src/lib/new-potential-bug-entry-service-call.ts — service-call precedents (no-op launcher, additive artifacts/destinationPath, throw on failure preserving `Command exited with code <n>.`).
- extensions/drm-copilot/src/mcp-handlers/feature-entry-handlers.ts (`handleNewActiveFeatureFolder`) and src/mcp-tool-inputs.ts (`resolveNewActiveFeatureFolderToolInput`) — UNCHANGED; input shape `feature_name`, `type`, `issue_number`, `work_mode`, `workspace_root`.
- extensions/drm-copilot/src/repo-automation-command-registration-feature-workflows.ts — command routes through the service.

Existing extension tests asserting the Python spawn (extension.new-active-feature-folder.test.ts, 372 lines):
- `registers newActiveFeatureFolder` (line 144) — PRESERVE unchanged.
- `passes the bundled script path and omits --issue-number when blank` (line 152) — asserts `childProcessMock.spawn` arg vector incl. `resources/templates/new_active_feature_folder.py`; REWORK to in-process (no .py spawn) preserving prompt + omit-issue-number behavior.
- `newActiveFeatureFolder direct invocation forwards issue number without prompts` (line 180) — REWORK: keep UI-skip, drop spawn arg-vector.
- `newActiveFeatureFolder direct invocation omits issue number without prompts` (line 211) — REWORK: keep UI-skip, drop spawn arg-vector.
- `newActiveFeatureFolder direct mode rejects non-digit issue number` (line 239) — PRESERVE (asserts no spawn / arg-parse error).
- `newActiveFeatureFolder direct mode rejects invalid type` (line 263) — PRESERVE (asserts no spawn).
- `returns early when the type quick pick is cancelled` (285) / `feature-name input is cancelled` (296) / `issue-number input is cancelled` (308) / `work-mode quick pick is cancelled` (322) — PRESERVE (no spawn).
- `surfaces a missing python runtime error` (line 338) — asserts `Python runtime 'python' not found on PATH.`; DELETE and INVERT to assert success without Python present.
- `surfaces non-zero exit failures` (line 356) — asserts `Command exited with code 2`; REPLACE with an in-process workflow failure (e.g. target-exists / invalid type) surfacing the preserved failure contract, OR remove if covered by service-call tests.

Prior failure-surface contract (confirmed):
- Missing python runtime: `Python runtime 'python' not found on PATH.` (inverted in F8 — in-process path needs no python).
- Non-zero exit: `Command exited with code <n>.` (e.g. `Command exited with code 2`). The service-call helper preserves this surface by throwing on workflow failure, mirroring potential-to-issue-service-call.ts.

artifacts/destinationPath decision: No existing extension test asserts the ABSENCE of `artifacts`/`destinationPath` for `new_active_feature_folder` (the reworked cases assert in-process execution, not result-record shape). Therefore the enrichment is additive and safe: success returns `destinationPath = normalizeGeneratedPath(result.target)` and `artifacts = [potentialIssuePath when present]`.

No file was modified during P0-T2.

