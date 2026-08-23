"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.executeScriptServiceCall = executeScriptServiceCall;
const command_runtime_1 = require("./command-runtime");
const repo_automation_service_support_1 = require("./repo-automation-service-support");
/**
 * Execute a bundled script and build the service result record.
 *
 * Purpose:
 *     Hold the body that `RepoAutomationService.executeScript` delegates to,
 *     keeping the service file within the 500-line limit while preserving the
 *     observable return contract (tool/workspaceRoot/summary plus parsed
 *     artifacts). Lives in a dedicated module (not
 *     `repo-automation-service-support.ts`) so that the host-bound
 *     `command-runtime` (which imports `vscode`) is not pulled into the
 *     support module consumed by host-neutral lib tests.
 *
 * Side effects:
 *     Spawns the bundled script through
 *     {@link executeBundledScriptFromExtensionRoot}.
 *
 * @param output Output sink for command diagnostics.
 * @param extensionRoot Installed extension root used to resolve the script.
 * @param options Script execution options plus the owning tool name.
 * @returns The result record with any parsed artifact path.
 */
async function executeScriptServiceCall(output, extensionRoot, options) {
    const execution = await (0, command_runtime_1.executeBundledScriptFromExtensionRoot)(output, {
        runtimeKind: options.runtimeKind,
        bundledRelativePath: options.bundledRelativePath,
        commandId: options.invocationId,
        args: options.args,
        extensionRoot,
        workspaceRoot: options.workspaceRoot,
    });
    const parsedArtifactPath = options.stdoutArtifactPattern === undefined
        ? undefined
        : (0, repo_automation_service_support_1.parseFirstArtifactPath)(execution, options.stdoutArtifactPattern);
    const artifacts = options.artifactPaths ??
        (parsedArtifactPath === undefined ? undefined : [parsedArtifactPath]);
    return {
        tool: options.tool,
        workspaceRoot: options.workspaceRoot,
        summary: options.summary,
        ...(artifacts === undefined ? {} : { artifacts }),
    };
}
