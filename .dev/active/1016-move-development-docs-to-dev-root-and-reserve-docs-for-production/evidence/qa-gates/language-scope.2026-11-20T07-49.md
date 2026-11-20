# Language Scope and File Size ([P4-T5])

Timestamp: 2026-11-20T07-49
Command: MB=$(git -C <worktree> merge-base origin/epic/shared-agent-harness-layer-integration HEAD); git -C <worktree> diff --name-status $MB HEAD; git -C <worktree> status --porcelain; per-pattern counts over the union of both listings; wc -l over every created or edited file under extensions/drm-copilot/ and packages/mcp-server/
EXIT_CODE: 0
Output Summary: BASE is the merge base of `origin/epic/shared-agent-harness-layer-integration` and HEAD (ruling R6), which equals the INTEGRATION tip. Zero `.py` files, zero files under `.claude/hooks/` or `.codex/hooks/`, zero `.sh` or `.bats` files, zero paths under `docs/engineering/process-reductions/`. Every edited production file is below 700 lines (largest: `jest.config.cjs` 684, `repo-automation-service.ts` 528, `mcp-tools.ts` 495) and no file is above 800 (largest new file: `migration-plan.ts` 587).

## Committed changes, `git diff --name-status <BASE> HEAD` (30 evidence files under `<FEATURE>/evidence/` omitted from this list)

```text
M	<FEATURE>/plan.2026-10-30T18-59.md
M	<FEATURE>/spec.md
M	extensions/drm-copilot/README.md
M	extensions/drm-copilot/jest.config.cjs
A	extensions/drm-copilot/jest.development-docs-migration-coverage.json
A	extensions/drm-copilot/src/lib/development-docs-migration/folder-rename-plan.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/migration-apply.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/migration-decisions.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/migration-git.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/migration-report.ts
A	extensions/drm-copilot/src/lib/development-docs-migration/reference-rewrite.ts
M	extensions/drm-copilot/src/lib/subprocess-runner.ts
A	extensions/drm-copilot/src/mcp-development-docs-tool-definitions.ts
A	extensions/drm-copilot/src/mcp-handlers/development-docs-migration-handler.ts
M	extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts
M	extensions/drm-copilot/src/mcp-server.ts
M	extensions/drm-copilot/src/mcp-tool-definitions.ts
A	extensions/drm-copilot/src/mcp-tool-inputs-development-docs.ts
M	extensions/drm-copilot/src/mcp-tools.ts
A	extensions/drm-copilot/src/migrate-development-docs-cli.ts
M	extensions/drm-copilot/src/repo-automation-service-contract.ts
M	extensions/drm-copilot/src/repo-automation-service.ts
M	extensions/drm-copilot/src/repo-automation-tool-names.ts
A	extensions/drm-copilot/test/development-docs-migration-coverage-contracts.test.ts
A	extensions/drm-copilot/test/lib/development-docs-migration/ (11 files: 10 suites and migration-test-fakes.ts)
M	extensions/drm-copilot/test/lib/subprocess-runner.test.ts
A	extensions/drm-copilot/test/mcp-development-docs-tool-definitions.test.ts
M	extensions/drm-copilot/test/mcp-discovery-authority-tool-definitions.test.ts
A	extensions/drm-copilot/test/mcp-handlers/development-docs-migration-handler.test.ts
M	extensions/drm-copilot/test/mcp-server-test-service.ts
A	extensions/drm-copilot/test/mcp-server.main.test.ts
A	extensions/drm-copilot/test/mcp-tool-inputs-development-docs.test.ts
A	extensions/drm-copilot/test/mcp-tools.development-docs.test.ts
A	extensions/drm-copilot/test/migrate-development-docs-cli.test.ts
A	extensions/drm-copilot/test/repo-automation-service.development-docs.test.ts
M	packages/mcp-server/README.md
```

## Uncommitted and untracked, `git status --porcelain`

```text
 M <FEATURE>/plan.2026-10-30T18-59.md
 M <FEATURE>/spec.md
 M extensions/drm-copilot/test/development-docs-migration-coverage-contracts.test.ts
 M extensions/drm-copilot/test/mcp-server.main.test.ts
?? <FEATURE>/evidence/qa-gates/ (Phase 4 artifacts: ts-static, ts-architecture-contract, ts-test-coverage of both loop passes, coverage-delta)
```

## Pattern counts over the union

| Pattern | Count |
| --- | --- |
| `.py` files | 0 |
| `.claude/hooks/` | 0 |
| `.codex/hooks/` | 0 |
| `.sh` or `.bats` files | 0 |
| `docs/engineering/process-reductions/` | 0 |

## Physical line counts (`wc -l`)

| File | Lines |
| --- | --- |
| `extensions/drm-copilot/jest.config.cjs` (edited config) | 684 |
| `extensions/drm-copilot/jest.development-docs-migration-coverage.json` | 48 |
| `extensions/drm-copilot/README.md` | 323 |
| `src/lib/development-docs-migration/folder-rename-plan.ts` | 217 |
| `src/lib/development-docs-migration/layout-map.ts` | 156 |
| `src/lib/development-docs-migration/migrate-development-docs-service-call.ts` | 212 |
| `src/lib/development-docs-migration/migration-apply.ts` | 106 |
| `src/lib/development-docs-migration/migration-decisions.ts` | 346 |
| `src/lib/development-docs-migration/migration-git.ts` | 85 |
| `src/lib/development-docs-migration/migration-plan.ts` | 587 |
| `src/lib/development-docs-migration/migration-report.ts` | 222 |
| `src/lib/development-docs-migration/reference-rewrite.ts` | 333 |
| `src/lib/subprocess-runner.ts` (edited) | 149 |
| `src/mcp-development-docs-tool-definitions.ts` | 42 |
| `src/mcp-handlers/development-docs-migration-handler.ts` | 30 |
| `src/mcp-repo-automation-tool-definitions.ts` (edited) | 438 |
| `src/mcp-server.ts` (edited) | 172 |
| `src/mcp-tool-definitions.ts` (edited) | 475 |
| `src/mcp-tool-inputs-development-docs.ts` | 72 |
| `src/mcp-tools.ts` (edited) | 495 |
| `src/migrate-development-docs-cli.ts` | 143 |
| `src/repo-automation-service.ts` (edited) | 528 |
| `src/repo-automation-service-contract.ts` (edited) | 346 |
| `src/repo-automation-tool-names.ts` (edited) | 56 |
| `test/development-docs-migration-coverage-contracts.test.ts` | 82 |
| `test/lib/development-docs-migration/folder-rename-plan.test.ts` | 156 |
| `test/lib/development-docs-migration/layout-map.test.ts` | 134 |
| `test/lib/development-docs-migration/migrate-development-docs-service-call.test.ts` | 296 |
| `test/lib/development-docs-migration/migration-apply.test.ts` | 235 |
| `test/lib/development-docs-migration/migration-decisions.test.ts` | 284 |
| `test/lib/development-docs-migration/migration-git.test.ts` | 139 |
| `test/lib/development-docs-migration/migration-plan.test.ts` | 502 |
| `test/lib/development-docs-migration/migration-report.test.ts` | 181 |
| `test/lib/development-docs-migration/migration-test-fakes.ts` | 196 |
| `test/lib/development-docs-migration/no-vscode-import.test.ts` | 44 |
| `test/lib/development-docs-migration/reference-rewrite.test.ts` | 317 |
| `test/lib/subprocess-runner.test.ts` (edited) | 173 |
| `test/mcp-development-docs-tool-definitions.test.ts` | 47 |
| `test/mcp-discovery-authority-tool-definitions.test.ts` (edited) | 198 |
| `test/mcp-handlers/development-docs-migration-handler.test.ts` | 71 |
| `test/mcp-server.main.test.ts` | 111 |
| `test/mcp-server-test-service.ts` (edited) | 230 |
| `test/mcp-tool-inputs-development-docs.test.ts` | 75 |
| `test/mcp-tools.development-docs.test.ts` | 107 |
| `test/migrate-development-docs-cli.test.ts` | 171 |
| `test/repo-automation-service.development-docs.test.ts` | 53 |
| `packages/mcp-server/README.md` | 69 |

`<FEATURE>` = `docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016`; `src/` and `test/` rows are under `extensions/drm-copilot/`.
