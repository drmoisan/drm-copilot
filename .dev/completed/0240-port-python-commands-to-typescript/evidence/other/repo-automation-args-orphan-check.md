# P3-T2 — repo-automation-args.ts Orphan Check (F11)

Timestamp: 2026-06-26T09-01

SearchScope: `extensions/drm-copilot/src`, `extensions/drm-copilot/test`
SearchPatterns: `buildNewActiveFeatureFolderArgs`, `buildResolveExecuteHardLockPromptArguments`, `buildValidateOrchestrationArtifactsArgs`, `buildResolveAtomicPlanPromptArgs`
Command: `rg -n 'buildNewActiveFeatureFolderArgs|buildResolveExecuteHardLockPromptArguments|buildValidateOrchestrationArtifactsArgs|buildResolveAtomicPlanPromptArgs' extensions/drm-copilot/src extensions/drm-copilot/test`

SearchResult (after P3-T1 removed the four dead Python option builders that were the only callers):
- `buildResolveExecuteHardLockPromptArguments` — only its own definition in `repo-automation-args.ts` plus one stale JSDoc mention in `lib/resolve/resolve-prompts-service-call.ts`; no live caller. ORPHANED.
- `buildNewActiveFeatureFolderArgs` — only its own definition. ORPHANED.
- `buildValidateOrchestrationArtifactsArgs` — only its own definition. ORPHANED.
- `buildResolveAtomicPlanPromptArgs` — does not exist (the dead `buildResolveAtomicPlanPromptOptions` built its args inline; no separate arg-builder).
- No dedicated test file referenced any of these arg-builders (`rg -ln ... extensions/drm-copilot/test` returned no matches).

## Determination: REMOVED

The three orphaned arg-builders and the now-unused `ResolveExecuteHardLockPromptArguments` interface were removed from `repo-automation-args.ts`. The in-process service path (`runResolveExecuteHardLockPrompt`/`runResolveAtomicPlanPrompt` -> `resolve-prompts-service-call.ts`) computes its own arguments and does not use these builders. The live PowerShell arg-builder `buildPoshQcWorkflowArguments` is unchanged.

Imports rendered unused by the removal were also deleted from `repo-automation-args.ts`: `node:path` (`path`), `normalizeGeneratedPath`, `isAbsolutePathLike`, `PotentialPromotionType`, `WorkModeOption`. Remaining imports (`POSH_QC_TOOL_CONFIG`, `WorkspaceExecutionInput`, `RepoAutomationToolName`) are still used by `buildPoshQcWorkflowArguments`.

The stale JSDoc mention in `lib/resolve/resolve-prompts-service-call.ts` was reworded to not reference the deleted symbol.

Verification: `npm run typecheck` EXIT 0; `npm run lint` EXIT 0 (no unused-import/unused-var findings).
