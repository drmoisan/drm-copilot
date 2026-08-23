"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolvePushDownClaudeCustomizationsToolInput = resolvePushDownClaudeCustomizationsToolInput;
exports.resolvePushDownCodexAndAgentsCustomizationsToolInput = resolvePushDownCodexAndAgentsCustomizationsToolInput;
const workflow_command_arguments_1 = require("./workflow-command-arguments");
const mcp_tool_inputs_1 = require("./mcp-tool-inputs");
function resolvePacksField(rawValue) {
    // An absent packs field yields the backward-compatible publish-everything
    // default (undefined). When present it must be an array of strings.
    if (rawValue === undefined) {
        return undefined;
    }
    if (!Array.isArray(rawValue)) {
        throw new Error("Field 'packs' must be an array of strings when provided.");
    }
    return rawValue.map((entry, index) => (0, workflow_command_arguments_1.normalizeRequiredText)(entry, `packs[${index}]`));
}
function resolveCsharpVariantField(rawValue) {
    // An absent variant leaves the field undefined so the engine default applies.
    if (rawValue === undefined) {
        return undefined;
    }
    const variant = (0, workflow_command_arguments_1.normalizeRequiredText)(rawValue, "csharp_variant");
    if (variant !== "modern" && variant !== "legacy") {
        throw new Error("Field 'csharp_variant' must be 'modern' or 'legacy'.");
    }
    return variant;
}
function resolveMemoryModeField(rawValue) {
    // An absent memory mode leaves the field undefined so the engine default
    // (overwrite) applies.
    if (rawValue === undefined) {
        return undefined;
    }
    const mode = (0, workflow_command_arguments_1.normalizeRequiredText)(rawValue, "memory_mode");
    if (mode !== "overwrite" && mode !== "merge" && mode !== "skip") {
        throw new Error("Field 'memory_mode' must be 'overwrite', 'merge', or 'skip'.");
    }
    return mode;
}
function resolvePushDownClaudeCustomizationsToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const packs = resolvePacksField(args["packs"]);
    const csharpVariant = resolveCsharpVariantField(args["csharp_variant"]);
    const memoryMode = resolveMemoryModeField(args["memory_mode"]);
    // Spread each optional field only when present so a workspace_root-only
    // invocation resolves to an input with every new field left undefined.
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        ...(packs === undefined ? {} : { packs }),
        ...(csharpVariant === undefined ? {} : { csharpVariant }),
        ...(memoryMode === undefined ? {} : { memoryMode }),
    };
}
function resolvePushDownCodexAndAgentsCustomizationsToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const packs = resolvePacksField(args["packs"]);
    const csharpVariant = resolveCsharpVariantField(args["csharp_variant"]);
    const memoryMode = resolveMemoryModeField(args["memory_mode"]);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        ...(packs === undefined ? {} : { packs }),
        ...(csharpVariant === undefined ? {} : { csharpVariant }),
        ...(memoryMode === undefined ? {} : { memoryMode }),
    };
}
