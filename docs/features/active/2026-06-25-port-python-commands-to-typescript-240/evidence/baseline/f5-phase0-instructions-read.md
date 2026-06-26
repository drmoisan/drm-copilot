# F5 Phase 0 — Policy Read Evidence

Timestamp: 2026-06-26T01-16

Policy Order: CLAUDE.md → general-code-change → general-unit-test → typescript → typescript-suppressions → quality-tiers → architecture-boundaries → self-explanatory-code-commenting → tonality

Files read (in order):
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/typescript.md`
5. `.claude/rules/typescript-suppressions.md`
6. `.claude/rules/quality-tiers.md`
7. `.claude/rules/architecture-boundaries.md`
8. `.claude/rules/self-explanatory-code-commenting.md`
9. `.claude/rules/tonality.md`

Notes:
- `.claude/rules/typescript.md` names Vitest as the TS test framework, but the binding toolchain fact for the `extensions/drm-copilot/` package is Jest (`jest.config.cjs`, `ts-jest`, `run-jest.cjs`, `npm test = node run-jest.cjs`). This divergence is recorded as accepted decision D1 in the feature spec and is explicitly authorized by the plan's Toolchain Facts section. Ported tests use `@jest/globals`.
- Coverage policy is uniform across tiers: line >= 85%, branch >= 75% on all new `src/lib/resolve/**` files.
- No policy document was modified.

## Files Read for Port:

Timestamp: 2026-06-26T01-16

Python source-of-truth (read; not modified):
- `scripts/dev_tools/resolve_hard_lock_prompt.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_hard_lock_prompt.py` (bundled; authoritative)
- `scripts/dev_tools/resolve_file_prompt.py`
- `extensions/drm-copilot/resources/scripts/dev_tools/resolve_file_prompt.py` (bundled; authoritative)
- `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` (wrapper; injects `--template-root`)
- `extensions/drm-copilot/resources/templates/resolve_atomic_plan_prompt.py` (wrapper; injects `--template`)

F1 reuse targets (read; not re-ported):
- `extensions/drm-copilot/src/lib/file-system.ts` (`FileSystem`, `RealFileSystem`, `toPosixPath`)
- `extensions/drm-copilot/src/lib/prompt-mode-contract.ts` (`resolveSelectedWorkMode`, `buildFallbackReason`, `parseIssueWorkMode`)
- `extensions/drm-copilot/src/lib/subprocess-runner.ts` (`CommandRunner`, `SubprocessRunner`) — not required for this port; clipboard seam defaults to no-op.

Service / wiring files (read):
- `extensions/drm-copilot/src/repo-automation-service.ts`
- `extensions/drm-copilot/src/repo-automation-service-workflows.ts`
- `extensions/drm-copilot/src/repo-automation-args.ts`
- `extensions/drm-copilot/src/repo-automation-service-support.ts` (`normalizeGeneratedPath`)
- `extensions/drm-copilot/src/workflow-command-arguments.ts` (`isAbsolutePathLike`)
- `extensions/drm-copilot/src/mcp-handlers/resolve-execute-hard-lock-prompt-handler.ts` (injects `output`/`quiet`)
- `extensions/drm-copilot/src/mcp-tool-inputs.ts` (resolvers)
- `extensions/drm-copilot/src/lib/validate/validate-orchestration-service-call.ts` (F2 wiring precedent)

Extension tests asserting Python spawn (to be reworked):
- `extensions/drm-copilot/test/repo-automation-hard-lock-prompt.test.ts`
- `extensions/drm-copilot/test/repo-automation-service.resolve-atomic-plan-prompt.test.ts`
- `extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts`
- `extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts`
- `extensions/drm-copilot/test/runtime-test-helpers.ts` (shared helpers)
- `extensions/drm-copilot/test/mcp-server.test.ts`, `mcp-tools.push-down-claude.test.ts`, `mcp-tools.codex-native-converter.test.ts` (mock the whole service; assert dispatch only — no Python-spawn assertion for these two commands; remain unchanged per P2-T6)

### Divergences recorded (bundled is authoritative)

Hard-lock (`resolve_hard_lock_prompt.py`):
- Non-bundled adds `_normalize_prompt_path_value(path)` = `str(path).replace("\\", "/")` for `${plan-path}`. Bundled uses `relative_target.as_posix()` directly (line 300). `as_posix()` already yields forward slashes for `Path` objects; for the TS port the bundled behavior is reproduced by converting the workspace-relative path to forward slashes. Observable result is identical for in-workspace targets. The TS port targets the bundled `as_posix()` behavior.
- All other logic (template selection/probe order, issue.md resolution including `v*` parent fallback and fail-closed, `${plan-path}`/`${work-mode}`/`${fallback-reason}` substitution, `--quiet`/`--output` semantics, error messages, exit codes) is identical between the two variants.

File prompt (`resolve_file_prompt.py`):
- `resolve_prompt` and all helpers (`strip_front_matter`, `_split_path_platform_agnostic`, `_try_relative_to_workspace`, `_resolve_folderpath`, `_resolve_feature_foldername`, `_resolve_name_from_feature_foldername`, `_resolve_spec_path`, `_resolve_user_story_value`, `_resolve_research_value`, `_remove_user_story_clause_when_missing`, `_remove_lines_referencing_variable`, `_insert_after_heading`, `_apply_minor_audit_overrides`, `_extract_template_variables`, `_resolve_work_mode_from_issue`, `_replace_all_variables`) are byte-identical between the two variants. The minor-audit block text is identical (verified: bundled lines 239-249 vs non-bundled lines 431-442; non-bundled wraps one line for the 88-col limit but the assembled string is identical).
- `main()` shell DIFFERS materially:
  - Bundled `main()` returns `int`, accepts `--template`/`--target`/`--workspace`, resolves workspace via `_resolve_workspace_root`, target via `_resolve_target_path`, and on success prints `Successfully resolved prompt and copied to clipboard.` (stdout) then the resolved content (stdout) and returns 0; on clipboard failure prints `Could not copy to clipboard; printing resolved prompt to stdout.` (stderr) then the resolved content (stdout) and returns 0. Error paths: `Error: Template file not found: <path>` (stderr, return 1), `Error: Target file not found: <path>` (stderr, return 1), `Error reading template: <error>` (stderr, return 1), `Error processing prompt: <error>` (stderr, return 1).
  - Non-bundled `main()` returns `None`, accepts only `--template`/`--target`, uses `Path.cwd()`, prints `Successfully resolved prompt and copied to clipboard.` (no content) on success, and on clipboard failure prints `Clipboard copy not available; printing resolved prompt to stdout.` (stderr) then content. This is NOT the service path and is NOT the parity target.
- The TS port targets the BUNDLED `main()` shell for the atomic-plan command behavior.

Template-path / template-root injection:
- Hard-lock wrapper injects `--template-root` = `<extensionRoot>/resources/customizations/.github/codex` (verified template line 53-55).
- Atomic-plan wrapper injects `--template` = `<extensionRoot>/resources/customizations/.github/prompts/generate-atomic-plan.prompt.md` (verified template line 59-65).

No file was modified during P0-T2.
