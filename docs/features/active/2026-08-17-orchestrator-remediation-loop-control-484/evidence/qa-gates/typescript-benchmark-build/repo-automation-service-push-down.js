"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildPushDownClaudeCustomizationsOptions = buildPushDownClaudeCustomizationsOptions;
exports.buildPushDownCodexAndAgentsCustomizationsOptions = buildPushDownCodexAndAgentsCustomizationsOptions;
exports.runPushDownCopilotCustomizations = runPushDownCopilotCustomizations;
exports.runPushDownCodexAndAgentsCustomizations = runPushDownCodexAndAgentsCustomizations;
exports.runPushDownClaudeCustomizations = runPushDownClaudeCustomizations;
const push_down_service_call_1 = require("./lib/push-down/push-down-service-call");
/**
 * Build the forwarded options for the in-process Claude push-down call.
 *
 * Carries the workspace root and only the optional selection fields that were
 * supplied, so a no-field input forwards just the workspace root (matching the
 * backward-compatible publish-everything default).
 *
 * @param input The Claude push-down service input.
 * @returns Forwarded options for `pushDownClaudeCustomizationsServiceCall`.
 */
function buildPushDownClaudeCustomizationsOptions(input) {
    return {
        workspaceRoot: input.workspaceRoot,
        ...(input.packs === undefined ? {} : { packs: input.packs }),
        ...(input.csharpVariant === undefined
            ? {}
            : { csharpVariant: input.csharpVariant }),
        ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
    };
}
function buildPushDownCodexAndAgentsCustomizationsOptions(input) {
    return {
        workspaceRoot: input.workspaceRoot,
        ...(input.packs === undefined ? {} : { packs: input.packs }),
        ...(input.csharpVariant === undefined
            ? {}
            : { csharpVariant: input.csharpVariant }),
        ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
    };
}
/**
 * Run the in-process Copilot push-down service call.
 *
 * @param workspaceRoot Destination workspace root.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
function runPushDownCopilotCustomizations(workspaceRoot, deps) {
    return (0, push_down_service_call_1.pushDownCopilotCustomizationsServiceCall)({
        fs: deps.fs,
        extensionRoot: deps.extensionRoot,
        workspaceRoot,
        log: deps.log,
    });
}
/**
 * Run the in-process Codex/agents push-down service call.
 *
 * @param workspaceRoot Destination workspace root.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
function runPushDownCodexAndAgentsCustomizations(input, deps) {
    const forwarded = buildPushDownCodexAndAgentsCustomizationsOptions(input);
    return (0, push_down_service_call_1.pushDownCodexAndAgentsCustomizationsServiceCall)({
        fs: deps.fs,
        extensionRoot: deps.extensionRoot,
        workspaceRoot: forwarded.workspaceRoot,
        log: deps.log,
        ...(forwarded.packs === undefined ? {} : { packs: forwarded.packs }),
        ...(forwarded.csharpVariant === undefined
            ? {}
            : { csharpVariant: forwarded.csharpVariant }),
        ...(forwarded.memoryMode === undefined
            ? {}
            : { memoryMode: forwarded.memoryMode }),
    });
}
/**
 * Run the in-process Claude push-down service call from a service input.
 *
 * Keeps the optional pack/variant/memory forwarding out of the service file so
 * `repo-automation-service.ts` stays within the 500-line limit. Forwards only
 * the optional fields that were supplied.
 *
 * @param input The Claude push-down service input.
 * @param deps The filesystem, extension root, and log sink from the service.
 * @returns The preserved push-down execution result.
 */
function runPushDownClaudeCustomizations(input, deps) {
    const forwarded = buildPushDownClaudeCustomizationsOptions(input);
    return (0, push_down_service_call_1.pushDownClaudeCustomizationsServiceCall)({
        fs: deps.fs,
        extensionRoot: deps.extensionRoot,
        workspaceRoot: forwarded.workspaceRoot,
        log: deps.log,
        ...(forwarded.packs === undefined ? {} : { packs: forwarded.packs }),
        ...(forwarded.csharpVariant === undefined
            ? {}
            : { csharpVariant: forwarded.csharpVariant }),
        ...(forwarded.memoryMode === undefined
            ? {}
            : { memoryMode: forwarded.memoryMode }),
    });
}
