# F4 Phase 0 — Instructions Read

Timestamp: 2026-06-26T00-23

Policy Order: CLAUDE.md → general-code-change → general-unit-test → typescript → typescript-suppressions → quality-tiers → architecture-boundaries → tonality

## Files Read (Policy)

- `CLAUDE.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/typescript.md`
- `.claude/rules/typescript-suppressions.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/architecture-boundaries.md`
- `.claude/rules/tonality.md`

All eight policy files listed above were read in order before any code or test change.

Note: `.claude/rules/typescript.md` references Vitest, but the `extensions/drm-copilot/` package uses Jest (accepted decision D1 in the plan/spec). The plan and task instructions explicitly direct Jest conventions and the `extensions/drm-copilot/` toolchain commands; those are followed.

## Files Read for Port (P0-T2)

- `extensions/drm-copilot/resources/templates/collect_commit_context.py` (port source, 212 LoC)
- `tests/scripts/dev_tools/test_collect_commit_context.py` (test scenarios to mirror)
- `extensions/drm-copilot/src/lib/subprocess-runner.ts` (F1 reuse: `CommandRunner`, `CommandResult`, `CommandRunOptions`, `SubprocessRunner`)
- `extensions/drm-copilot/src/lib/file-system.ts` (F1 reuse: `FileSystem`, `RealFileSystem`; no `ensureDir` yet)
- `extensions/drm-copilot/src/repo-automation-service.ts` (`collectCommitContext` method, `executeScript`, `RepoAutomationServiceOptions`, `fileSystem` injection)
- `extensions/drm-copilot/src/repo-automation-service-support.ts` (`normalizeGeneratedPath` confirmed at line 65)
- `extensions/drm-copilot/src/mcp-handlers/collect-context-handlers.ts` (`handleCollectCommitContext` — unchanged by F4)
- `extensions/drm-copilot/src/mcp-tool-inputs.ts` (`resolveCollectCommitContextToolInput` returns `WorkspaceToolInput` with `workspaceRoot`)
- `extensions/drm-copilot/src/command-runtime.ts` (`CommandOutput.appendLine(line: string): void` confirmed at line 22)
- `extensions/drm-copilot/test/extension.integration.test.ts` (three collectCommitContext cases at lines 281, 296, 341 assert Python spawn)
- `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` (`collectCommitContext preserves C:/extension on POSIX hosts` at line 151 asserts Python spawn)
- `extensions/drm-copilot/test/mcp-server.test.ts` (fully mocked service; no Python-spawn assertion to change)
- `extensions/drm-copilot/test/lib/file-system.test.ts` (existing `RealFileSystem` tests; `node:fs` mocked)

No file was modified during P0-T2.
