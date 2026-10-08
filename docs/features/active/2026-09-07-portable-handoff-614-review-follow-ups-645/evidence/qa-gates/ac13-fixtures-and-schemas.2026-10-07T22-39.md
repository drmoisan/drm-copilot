# AC-13 Fixtures and Schemas (P8-T4)

Timestamp: 2026-10-07T22-39
Task: [P8-T4]
Command: git diff --diff-filter=MDR --name-only 08ee030d9584bf15882fbb3654c8e38f34c7c359; git diff --diff-filter=A --name-only 08ee030d9584bf15882fbb3654c8e38f34c7c359; git status --porcelain --untracked-files=all; git diff -U0 08ee030d9584bf15882fbb3654c8e38f34c7c359 -- extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-handoff.ts (DEV-1 diff base)
EXIT_CODE: 0
Output Summary: the MDR list (13 paths) and the porcelain M/D/R entries (none; porcelain held only three `??` evidence files under the feature folder) contain no path under `tests/fixtures/`, `extensions/drm-copilot/test/fixtures/`, `config/`, or `extensions/drm-copilot/resources/config/`. The union of the A list and porcelain `??`/`A` entries restricted to `tests/fixtures/` is exactly `tests/fixtures/codex-hooks/invalid-alias-orchestration-handoff-registry.json` and `tests/fixtures/codex-hooks/invalid-operation-orchestration-handoff-registry.json`. The fourth command shows exactly two added lines, each `readonly failureCause?: string;`, and zero removed lines.

## MDR name-only list

```
extensions/drm-copilot/jest.config.cjs
extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts
extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-production.ts
extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts
extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts
extensions/drm-copilot/src/lib/validate/orchestration-handoff-path-boundary.ts
extensions/drm-copilot/src/mcp-handlers/orchestration-handoff-handlers.ts
extensions/drm-copilot/src/mcp-repo-automation-tool-definitions-handoff.ts
extensions/drm-copilot/src/mcp-tools.ts
extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts
tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1
tests/scripts/dev_tools/orchestration_handoff_taskmaster_469_test_support.py
tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py
```

## A name-only list (non-feature-folder entries)

All other A entries are under `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/` (the feature folder was added on this branch after the diff base).

```
extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts
extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts
tests/fixtures/codex-hooks/invalid-alias-orchestration-handoff-registry.json
tests/fixtures/codex-hooks/invalid-operation-orchestration-handoff-registry.json
```

## Porcelain

```
?? docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/qa-gates/ac12-precedence-unchanged.2026-10-07T22-39.md
?? docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/qa-gates/ac4-hook-parity.2026-10-07T22-39.md
?? docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/qa-gates/ac7-bare-catch.2026-10-07T22-39.md
```

## Tool-definitions diff

```
@@ -55,0 +56 @@ export interface PortableHandoffAuthorityResult {
+  readonly failureCause?: string;
@@ -69,0 +71 @@ export interface TransitionPreparedOrchestrationResult {
+  readonly failureCause?: string;
```

Result: PASS
