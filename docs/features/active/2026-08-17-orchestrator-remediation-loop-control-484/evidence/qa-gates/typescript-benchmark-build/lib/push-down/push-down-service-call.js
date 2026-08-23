"use strict";
/**
 * In-process service wiring for the three push-down command variants.
 *
 * Purpose:
 *     Hold the bodies that the three `RepoAutomationService` push-down methods
 *     delegate to, so the service file stays within the 500-line limit while
 *     preserving each method's observable return contract exactly. Mirrors the
 *     F2/F4/F5 service-call precedents. Each function resolves the bundled
 *     source root from the extension root, invokes the matching in-process
 *     {@link pushDownCustomizations} port, and returns a
 *     `RepoAutomationExecutionResult`-shaped record preserving the prior `tool`,
 *     `summary`, and single-element `artifacts` contract.
 *
 * Side effects:
 *     Reads bundled source files and writes destination files plus the summary
 *     artifact through the injected {@link PushDownFileSystem}.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.pushDownCopilotCustomizationsServiceCall = pushDownCopilotCustomizationsServiceCall;
exports.pushDownCodexAndAgentsCustomizationsServiceCall = pushDownCodexAndAgentsCustomizationsServiceCall;
exports.pushDownClaudeCustomizationsServiceCall = pushDownClaudeCustomizationsServiceCall;
const repo_automation_service_support_1 = require("../../repo-automation-service-support");
const filesystem_adapter_1 = require("./filesystem-adapter");
const copilot_customizations_1 = require("./copilot-customizations");
const codex_agents_customizations_1 = require("./codex-agents-customizations");
const claude_customizations_1 = require("./claude-customizations");
/**
 * Join the extension root and a bundled relative directory using POSIX slashes.
 *
 * @param extensionRoot Extension root path.
 * @param relativeDir Bundled relative directory.
 * @returns The combined POSIX source root path.
 */
function bundledSourceRoot(extensionRoot, relativeDir) {
    const root = (0, filesystem_adapter_1.toPosixPath)(extensionRoot).replace(/\/+$/, "");
    return `${root}/${relativeDir}`;
}
/**
 * Push the bundled Copilot customizations into the destination workspace.
 *
 * @param input Filesystem, extension root, workspace root, optional clock/log.
 * @returns The preserved result record with the normalized artifact path.
 */
function pushDownCopilotCustomizationsServiceCall(input) {
    const sourceRoot = bundledSourceRoot(input.extensionRoot, "resources/customizations");
    const destinationRoot = (0, filesystem_adapter_1.toPosixPath)(input.workspaceRoot);
    const summary = (0, copilot_customizations_1.pushDownCustomizations)({
        repoRoot: sourceRoot,
        destinationRoot,
        fs: input.fs,
        sourceRoot,
        artifactRoot: destinationRoot,
        ...(input.clock === undefined ? {} : { clock: input.clock }),
    });
    return {
        tool: "push_down_copilot_customizations",
        workspaceRoot: input.workspaceRoot,
        summary: "Pushed bundled Copilot customizations into the destination workspace.",
        artifacts: [(0, repo_automation_service_support_1.normalizeGeneratedPath)(summary.artifactPath)],
    };
}
/**
 * Push the bundled Codex and agents customizations into the workspace.
 *
 * @param input Filesystem, extension root, workspace root, optional clock/log.
 * @returns The preserved result record with the normalized artifact path.
 */
function pushDownCodexAndAgentsCustomizationsServiceCall(input) {
    const sourceRoot = bundledSourceRoot(input.extensionRoot, "resources/codex-and-agents-customizations");
    const destinationRoot = (0, filesystem_adapter_1.toPosixPath)(input.workspaceRoot);
    const packs = input.packs === undefined || input.packs.length === 0
        ? null
        : new Set(input.packs);
    const summary = (0, codex_agents_customizations_1.pushDownCustomizations)({
        repoRoot: sourceRoot,
        destinationRoot,
        fs: input.fs,
        sourceRoot,
        artifactRoot: destinationRoot,
        bundleRoot: sourceRoot,
        packs,
        ...(input.csharpVariant === undefined
            ? {}
            : { csharpVariant: input.csharpVariant }),
        ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
        ...(input.clock === undefined ? {} : { clock: input.clock }),
    });
    return {
        tool: "push_down_codex_and_agents_customizations",
        workspaceRoot: input.workspaceRoot,
        summary: "Pushed bundled Codex and agents customizations into the destination workspace.",
        artifacts: [(0, repo_automation_service_support_1.normalizeGeneratedPath)(summary.artifactPath)],
    };
}
/**
 * Push the bundled Claude Code customizations into the workspace.
 *
 * Threads the optional pack selection, C# variant, and memory mode into the
 * in-process Claude port. The bundled source root is also the bundle root that
 * holds the pack manifests and the legacy variant subtree.
 *
 * @param input Filesystem, extension root, workspace root, and optional
 *   packs/csharpVariant/memoryMode plus clock/log.
 * @returns The preserved result record with the normalized artifact path.
 */
function pushDownClaudeCustomizationsServiceCall(input) {
    const sourceRoot = bundledSourceRoot(input.extensionRoot, "resources/claude-customizations");
    const destinationRoot = (0, filesystem_adapter_1.toPosixPath)(input.workspaceRoot);
    // The bundled source root already is the claude-customizations directory, so
    // it doubles as the bundle root (manifests and legacy variant live beneath).
    const packs = input.packs === undefined || input.packs.length === 0
        ? null
        : new Set(input.packs);
    const summary = (0, claude_customizations_1.pushDownCustomizations)({
        repoRoot: sourceRoot,
        destinationRoot,
        fs: input.fs,
        sourceRoot,
        artifactRoot: destinationRoot,
        bundleRoot: sourceRoot,
        packs,
        ...(input.csharpVariant === undefined
            ? {}
            : { csharpVariant: input.csharpVariant }),
        ...(input.memoryMode === undefined ? {} : { memoryMode: input.memoryMode }),
        ...(input.clock === undefined ? {} : { clock: input.clock }),
    });
    return {
        tool: "push_down_claude_customizations",
        workspaceRoot: input.workspaceRoot,
        summary: "Pushed bundled Claude Code customizations into the destination workspace.",
        artifacts: [(0, repo_automation_service_support_1.normalizeGeneratedPath)(summary.artifactPath)],
    };
}
