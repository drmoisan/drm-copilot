# F7 Phase 0 — Policy Read Evidence

Timestamp: 2026-06-26T00-00

Policy Order:
1. CLAUDE.md (standing instructions)
2. .claude/rules/general-code-change.md (cross-language code change policy)
3. .claude/rules/general-unit-test.md (cross-language unit test policy)
4. .claude/rules/typescript.md (TypeScript toolchain and coding standards)
5. .claude/rules/typescript-suppressions.md (TS/ESLint suppression authorization)
6. .claude/rules/quality-tiers.md (T1-T4 rigor tier system, uniform coverage thresholds)
7. .claude/rules/architecture-boundaries.md (No-COM architecture boundary rules)
8. .claude/rules/tonality.md (required professional tone policy)

Files Read (all eight, in order):
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\CLAUDE.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\general-code-change.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\general-unit-test.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\typescript.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\typescript-suppressions.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\quality-tiers.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\architecture-boundaries.md
- C:\Users\DanMoisan\repos\drm-copilot-wt-2026-06-25-22-10\.claude\rules\tonality.md

Notes:
- Coverage policy (uniform across T1-T4): line >= 85%, branch >= 75%.
- No file may exceed 500 lines (production, test, reusable script).
- Toolchain divergence: `.claude/rules/typescript.md` names Vitest, but the
  `extensions/drm-copilot/` package uses Jest (`jest.config.cjs`, `ts-jest`,
  `run-jest.cjs`). The plan records this as accepted decision D1. Jest is the
  binding test framework for this feature per the plan toolchain facts.
- No `any`; ES modules; kebab-case filenames; AAA test structure.

## Files Read for Port (P0-T2)

Timestamp: 2026-06-26T00-05

Parity-target Python (BUNDLED):
- extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py (workflow + gh client + FileSystem seam)
- extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue_content.py (content/metadata helpers)
- extensions/drm-copilot/resources/templates/potential_to_issue.py (thin wrapper; imports bundled module; NO TS port required)

Reference copies (read; identical contract):
- scripts/dev_tools/potential_to_issue.py and scripts/dev_tools/potential_to_issue_content.py

Python tests to mirror:
- tests/scripts/dev_tools/test_potential_to_issue.py (workflow scenarios; FakeFileSystem + FakeGhClient shape)
- tests/scripts/dev_tools/test_potential_to_issue_content.py (content helper scenarios)
- tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py (missing-label recovery regression; refactor scenario; ensure_label_calls == ["refactor"], create called twice)

F1 reuse targets (confirmed):
- src/lib/subprocess-runner.ts: `CommandRunner.run(args, options?)` has NO stdin/input parameter; `CommandRunOptions` = { cwd?, allowError? }; `CommandResult` = { stdout, stderr, code }.
- src/lib/file-system.ts: `FileSystem` exposes glob/isFile/readTextFile/writeTextFile/ensureDir ONLY. NO exists/move/writeLines/resolvePath. `toPosixPath` exported.
- src/lib/prompt-mode-contract.ts: `normalizeRequestedWorkMode(requestedMode, promotionType)` and `ACCEPTED_WORK_MODES` exported. Error messages: "work_mode must be one of: ...", "full-bug may only be used with bug work", "full-feature may not be used with bug work".

Service + support + precedents:
- src/repo-automation-service.ts: `potentialToIssue` currently calls `this.executeScript({ tool: "potential_to_issue", runtimeKind: "python", bundledRelativePath: "resources/templates/potential_to_issue.py", ... })`. `this.runner`, `this.fileSystem`, `this.output` available. `RepoAutomationExecutionResult` supports `artifacts?: ReadonlyArray<string>` and `destinationPath?`. Line count = 500.
- src/repo-automation-service-support.ts: `normalizeGeneratedPath(filePath)` replaces backslashes with forward slashes; `ScriptExecutionOptions` defined.
- src/lib/new-potential-bug-entry-service-call.ts (101 lines) and src/lib/validate/validate-orchestration-service-call.ts (90 lines): service-call helper precedents.
- src/workflow-command-arguments.ts: `PotentialPromotionType`, `WorkModeOption` exported.
- src/repo-automation-command-registration-feature-workflows.ts: handler `await options.service.potentialToIssue(...)`; a thrown Error propagates as a rejection.

Extension test enumeration (extension.potential-to-issue.test.ts, 456 lines):
- it("registers potentialToIssue") L175 — PRESERVE unchanged.
- it("passes the bundled script path and argument pairs") L183 — REWORK (no `.py` spawn; in-process).
- it("potentialToIssue direct invocation skips active-editor and prompt UI") L210 — PRESERVE UI assertions; remove spawn-arg assertions.
- it("potentialToIssue direct mode rejects unknown flag") L237 — PRESERVE (no spawn).
- it("potentialToIssue direct mode rejects invalid work mode") L261 — PRESERVE (no spawn).
- it("reuses the active potential editor path before falling back to the file picker") L283 — PRESERVE editor resolution; rework spawn-arg assertions.
- it("keeps the promotion-type quick pick after active-editor auto-resolution") L302 — PRESERVE quick-pick; rework spawn-arg assertions.
- it("keeps the work-mode quick pick after active-editor auto-resolution") L327 — PRESERVE quick-pick; rework spawn-arg assertions.
- it("returns early when the file picker is cancelled") L357 — PRESERVE (no spawn).
- it("returns early when the promotion-type quick pick is cancelled") L368 — PRESERVE.
- it("returns early when the work-mode quick pick is cancelled") L382 — PRESERVE.
- it("surfaces a missing python runtime error") L398 — DELETE; replace with success-without-python case.
- it("passes default folder for potential docs to showOpenDialog") L416 — PRESERVE; rework spawn dependency.
- it("surfaces non-zero exit failures") L440 — REPLACE: drive in-process non-zero gh create exit and assert failure-surface, OR remove if covered by service-call tests.

Prior failure-surface contract (from command-runtime.ts):
- Non-zero Python exit threw `"Command exited with code 2"` (command-runtime.ts:82, `Command exited with code ${exitCode}.`).
- Missing python threw `"Python runtime 'python' not found on PATH. On Windows, 'py -3' is also accepted."` (command-runtime.ts:202).
- In-process replacement: the service-call helper throws an `Error` including the emitted gh output lines when `outcome.exitCode !== 0`. The missing-python requirement is intentionally inverted (command succeeds without python).

artifacts/destinationPath decision: `RepoAutomationExecutionResult` already supports both, and no existing extension test asserts the absence of `artifacts`/`destinationPath` for potential_to_issue (the prior path set neither). Therefore the helper WILL set `destinationPath` (normalized promoted path) and `artifacts` (issue url/number when parsed). Existing extension tests only assert no `.py` spawn / UI behavior, not result-record fields, so enrichment is safe.

No file was modified during P0-T2.
