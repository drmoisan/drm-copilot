"use strict";
/**
 * In-process wiring for the `newActiveFeatureFolder` service method.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.newActiveFeatureFolder`
 *     delegates to, so the service file stays within the 500-line limit while
 *     preserving the method's observable return contract exactly. Mirrors the
 *     F2 `validate-orchestration-service-call.ts`, F5
 *     `resolve-prompts-service-call.ts`, F6 `new-potential-bug-entry-service-
 *     call.ts`, and F7 `potential-to-issue/potential-to-issue-service-call.ts`
 *     precedents.
 *
 * Return contract (preserved):
 *     - `tool: "new_active_feature_folder"`, `workspaceRoot`, and the
 *       byte-identical `summary`:
 *       `Created a new active <type> feature folder for '<featureName>'.`
 *     - On success the result is enriched with `destinationPath` (the normalized
 *       created folder path) and, when a potential file was moved to issue.md,
 *       `artifacts` (the moved issue.md path). No existing extension test
 *       asserts the absence of these fields for `new_active_feature_folder`, so
 *       the enrichment is additive and safe (decision recorded in the P0-T2
 *       Phase 0 artifact).
 *
 * --template-root parity:
 *     The service forwards `this.templateRoot` (the bundled
 *     `resources/feature-templates` directory) as `templateRoot`, replicating
 *     the Python wrapper's `--template-root` injection. The helper passes it to
 *     `createActiveFolder({ templateRoot, ... })`.
 *
 * Failure surface (preserved):
 *     The prior Python-spawn path threw on a non-zero exit
 *     (`Command exited with code <n>.`). A workflow `Error` (invalid type,
 *     invalid name, missing template, target exists, invalid work mode)
 *     propagates here unchanged, preserving its message. This matches the
 *     surfaced-failure behavior the prior path provided.
 *
 * Side effects:
 *     Reads/writes/moves files through the port-local {@link FolderFileSystem}
 *     seam and resolves optional issue metadata via the injected
 *     {@link CommandRunner} (`gh`). Performs no editor launch (a no-op launcher
 *     is passed so the MCP/non-interactive path never spawns `code`).
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.newActiveFeatureFolderServiceCall = newActiveFeatureFolderServiceCall;
const repo_automation_service_support_1 = require("../../repo-automation-service-support");
const index_1 = require("./index");
/**
 * Create a new active feature folder in-process and return the preserved
 * service result record.
 *
 * Binds a {@link defaultIssueFetcher}-style fetcher to the injected runner so
 * the optional `gh` issue-title fetch routes through the F1 runner, and passes
 * a no-op `codeLauncher` so the service/MCP path never spawns an editor (the
 * manual-open warning lines are emitted through the injected log instead).
 *
 * @param input Filesystem (optional), runner, workspace root, feature name,
 *   type, issue number (optional), work mode, template root, and optional log.
 * @returns The preserved result record (`tool`, `workspaceRoot`, exact
 *   `summary`) enriched with `destinationPath` and (when present) `artifacts`.
 * @throws Error When the workflow throws (invalid type/name, missing template,
 *   target exists, invalid work mode); the message is preserved.
 */
function newActiveFeatureFolderServiceCall(input) {
    const result = (0, index_1.createActiveFolder)({
        featureName: input.featureName,
        featureType: input.type,
        issueNumber: input.issueNumber ?? null,
        workMode: input.workMode,
        workspace: input.workspaceRoot,
        templateRoot: input.templateRoot,
        fs: input.fileSystem ?? new index_1.RealFolderFileSystem(),
        // Route the guarded gh issue fetch through the injected F1 runner.
        issueFetcher: (issueNumber) => (0, index_1.defaultIssueFetcher)(issueNumber, input.runner),
        // No-op launcher: the MCP/non-interactive path must never open an editor.
        codeLauncher: () => false,
        ...(input.log === undefined ? {} : { emit: input.log }),
    });
    return {
        tool: "new_active_feature_folder",
        workspaceRoot: input.workspaceRoot,
        summary: `Created a new active ${input.type} feature folder for '${input.featureName}'.`,
        destinationPath: (0, repo_automation_service_support_1.normalizeGeneratedPath)(result.target),
        // Enrich with the moved issue.md path when a potential file was seeded.
        ...(result.potentialIssuePath === null
            ? {}
            : { artifacts: [(0, repo_automation_service_support_1.normalizeGeneratedPath)(result.potentialIssuePath)] }),
    };
}
