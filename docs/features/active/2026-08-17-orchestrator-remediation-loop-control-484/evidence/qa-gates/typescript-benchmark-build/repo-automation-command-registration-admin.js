"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerRepoAutomationAdminCommands = registerRepoAutomationAdminCommands;
const vscode = __importStar(require("vscode"));
const command_runtime_1 = require("./command-runtime");
const extension_command_helpers_1 = require("./extension-command-helpers");
const claude_pack_name_translation_1 = require("./lib/push-down/claude-pack-name-translation");
const mcp_tools_1 = require("./mcp-tools");
const pr_context_branches_1 = require("./pr-context-branches");
const workflow_command_arguments_1 = require("./workflow-command-arguments");
function registerCollectCommitContextCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.collectCommitContext", async () => {
        const commandId = "drmCopilotExtension.collectCommitContext";
        await options.service.collectCommitContext({
            workspaceRoot: (0, command_runtime_1.getWorkspaceRoot)(),
            invocationId: commandId,
        });
    });
}
function registerCollectPrContextCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.collectPrContext", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.collectPrContext";
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => (0, workflow_command_arguments_1.resolveCollectPrContextInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            await options.service.collectPrContext({
                workspaceRoot,
                invocationId: commandId,
                ...invocation.input,
            });
            return;
        }
        options.output.appendLine(`[${commandId}] branch discovery start`);
        let discoveryResult;
        try {
            discoveryResult = (0, pr_context_branches_1.discoverPrBaseBranches)(options.output, commandId, workspaceRoot);
        }
        catch (error) {
            options.output.appendLine(`[${commandId}] branch discovery failure`);
            throw error;
        }
        options.output.appendLine(`[${commandId}] branch discovery success: ${discoveryResult.candidates.join(", ")}`);
        const selectedBase = await (0, pr_context_branches_1.pickPrBaseBranch)(options.output, commandId, discoveryResult.candidates, discoveryResult.defaultBranch);
        if (!selectedBase) {
            return;
        }
        await options.service.collectPrContext({
            workspaceRoot,
            invocationId: commandId,
            base: selectedBase,
        });
    });
}
function registerPushDownCopilotCustomizationsCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.pushDownCopilotCustomizations", async () => {
        const commandId = "drmCopilotExtension.pushDownCopilotCustomizations";
        await options.service.pushDownCopilotCustomizations({
            workspaceRoot: (0, command_runtime_1.getWorkspaceRoot)(),
            invocationId: commandId,
        });
    });
}
const CODEX_PUSH_DOWN_PACK_ITEMS = [
    { label: "Python", pack: "python" },
    { label: "PowerShell", pack: "powershell" },
    { label: "TypeScript", pack: "typescript" },
    { label: "C#", pack: "csharp" },
];
const CODEX_PUSH_DOWN_TITLE = "drm-copilot: Push Down Codex and Agents Customizations";
function registerPushDownCodexAndAgentsCustomizationsCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.pushDownCodexAndAgentsCustomizations", async () => {
        const commandId = "drmCopilotExtension.pushDownCodexAndAgentsCustomizations";
        const packSelection = await vscode.window.showQuickPick(CODEX_PUSH_DOWN_PACK_ITEMS.map((item) => ({
            label: item.label,
            pack: item.pack,
            picked: true,
        })), {
            title: CODEX_PUSH_DOWN_TITLE,
            placeHolder: "Select the language packs to publish (core is always included).",
            canPickMany: true,
            ignoreFocusOut: true,
        });
        if (packSelection === undefined) {
            return;
        }
        const packs = packSelection.map((item) => item.pack);
        let csharpVariant;
        if (packs.includes("csharp")) {
            const variantChoice = await (0, extension_command_helpers_1.promptForChoice)(CODEX_PUSH_DOWN_TITLE, "Choose the C# toolchain variant.", ["modern", "legacy"]);
            if (!variantChoice) {
                return;
            }
            csharpVariant = variantChoice;
        }
        await options.service.pushDownCodexAndAgentsCustomizations({
            workspaceRoot: (0, command_runtime_1.getWorkspaceRoot)(),
            invocationId: commandId,
            packs,
            ...(csharpVariant === undefined ? {} : { csharpVariant }),
            memoryMode: "overwrite",
        });
    });
}
/**
 * Selectable language packs for the Claude push-down command, ordered for the
 * multi-select QuickPick. Each entry maps a human-readable label to the
 * corresponding pack manifest name. `core` is always published by the engine
 * and is therefore not offered as a selectable item here.
 */
const CLAUDE_PUSH_DOWN_PACK_ITEMS = [
    { label: "Python", pack: "python" },
    { label: "PowerShell", pack: "powershell" },
    { label: "TypeScript", pack: "typescript" },
    { label: "C#", pack: "csharp" },
];
const CLAUDE_PUSH_DOWN_TITLE = "drm-copilot: Push Down Claude Code Customizations";
function registerPushDownClaudeCustomizationsCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.pushDownClaudeCustomizations", async () => {
        const commandId = "drmCopilotExtension.pushDownClaudeCustomizations";
        // Step 1: multi-select the language packs to publish. All packs are
        // pre-picked so the default selection matches the prior publish-all
        // behavior. Cancellation (undefined) aborts without invoking the service.
        const packSelection = await vscode.window.showQuickPick(CLAUDE_PUSH_DOWN_PACK_ITEMS.map((item) => ({
            label: item.label,
            pack: item.pack,
            picked: true,
        })), {
            title: CLAUDE_PUSH_DOWN_TITLE,
            placeHolder: "Select the language packs to publish (core is always included).",
            canPickMany: true,
            ignoreFocusOut: true,
        });
        if (packSelection === undefined) {
            return;
        }
        const packs = packSelection.map((item) => item.pack);
        // Step 2: when the C# pack is selected, choose the C# variant. The prompt
        // is skipped entirely when C# was not selected.
        let csharpVariant;
        if (packs.includes("csharp")) {
            const variantChoice = await (0, extension_command_helpers_1.promptForChoice)(CLAUDE_PUSH_DOWN_TITLE, "Choose the C# toolchain variant.", ["modern", "legacy"]);
            if (!variantChoice) {
                return;
            }
            csharpVariant = variantChoice;
        }
        // Step 3: choose the agent-memory mode.
        const memoryMode = await (0, extension_command_helpers_1.promptForChoice)(CLAUDE_PUSH_DOWN_TITLE, "Choose the agent-memory handling mode.", ["overwrite", "merge", "skip"]);
        if (!memoryMode) {
            return;
        }
        // Step 4: translate the selected pack names so a `csharp` selection is
        // forwarded as its variant-qualified manifest name
        // (`csharp-modern` / `csharp-legacy`). Non-C# names are unchanged.
        const translatedPacks = (0, claude_pack_name_translation_1.translateSelectedPackNames)(packs, csharpVariant);
        try {
            await options.service.pushDownClaudeCustomizations({
                workspaceRoot: (0, command_runtime_1.getWorkspaceRoot)(),
                invocationId: commandId,
                packs: translatedPacks,
                ...(csharpVariant === undefined ? {} : { csharpVariant }),
                memoryMode,
            });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            options.output.appendLine(`[${commandId}] push-down failure: ${message}`);
            throw error;
        }
    });
}
function registerRunCodexNativeConverterCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.runCodexNativeConverter", async () => {
        const commandId = "drmCopilotExtension.runCodexNativeConverter";
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const mode = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Run Codex-native Converter", "Choose the converter mode.", ["review", "apply"]);
        if (!mode) {
            return;
        }
        const sourceEcosystem = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Run Codex-native Converter", "Choose the source ecosystem.", ["github-copilot", "claude"]);
        if (!sourceEcosystem) {
            return;
        }
        const sourceRoot = await vscode.window.showInputBox({
            title: "drm-copilot: Run Codex-native Converter",
            prompt: "Enter the source runtime root.",
            value: workspaceRoot,
            ignoreFocusOut: true,
        });
        if (sourceRoot === undefined || sourceRoot.trim().length === 0) {
            return;
        }
        let destinationRoot;
        if (mode === "apply") {
            destinationRoot = await vscode.window.showInputBox({
                title: "drm-copilot: Run Codex-native Converter",
                prompt: "Enter the destination root for native output.",
                value: workspaceRoot,
                ignoreFocusOut: true,
            });
            if (destinationRoot === undefined ||
                destinationRoot.trim().length === 0) {
                return;
            }
        }
        const enableRepoPromptsChoice = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Run Codex-native Converter", "Enable repository-convention .codex/prompts output?", ["No", "Yes"]);
        if (!enableRepoPromptsChoice) {
            return;
        }
        await options.service.runCodexNativeConverter({
            workspaceRoot,
            invocationId: commandId,
            mode,
            sourceEcosystem,
            sourceRoot,
            ...(destinationRoot === undefined ? {} : { destinationRoot }),
            enableRepoPrompts: enableRepoPromptsChoice === "Yes",
        });
    });
}
function registerSyncAgentsFromInstructionsCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.syncAgentsFromInstructions", async () => {
        const commandId = "drmCopilotExtension.syncAgentsFromInstructions";
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        await (0, command_runtime_1.executeBundledScript)(options.context, options.output, {
            runtimeKind: "powershell",
            bundledRelativePath: "resources/templates/sync-agents-from-instructions.ps1",
            commandId,
            args: ["-RepoRoot", workspaceRoot],
        });
    });
}
function registerListMcpToolsCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.listMcpTools", async () => {
        const commandId = "drmCopilotExtension.listMcpTools";
        const toolItems = (0, mcp_tools_1.listRepoAutomationTools)().map((tool) => ({
            label: tool.name,
            description: tool.description,
            detail: tool.inputSchema.required === undefined ||
                tool.inputSchema.required.length === 0
                ? "Required inputs: none"
                : `Required inputs: ${tool.inputSchema.required.join(", ")}`,
        }));
        options.output.appendLine(`[${commandId}] available MCP tools:`);
        for (const toolItem of toolItems) {
            options.output.appendLine(`- ${toolItem.label}: ${toolItem.description} (${toolItem.detail})`);
        }
        await vscode.window.showQuickPick(toolItems, {
            title: "drm-copilot: List MCP Tools",
            placeHolder: "Available tools on the drmCopilotExtension MCP server.",
            matchOnDescription: true,
            matchOnDetail: true,
        });
    });
}
function registerRepoAutomationAdminCommands(options) {
    return [
        registerCollectCommitContextCommand(options),
        registerCollectPrContextCommand(options),
        registerPushDownCopilotCustomizationsCommand(options),
        registerPushDownCodexAndAgentsCustomizationsCommand(options),
        registerPushDownClaudeCustomizationsCommand(options),
        registerRunCodexNativeConverterCommand(options),
        registerSyncAgentsFromInstructionsCommand(options),
        registerListMcpToolsCommand(options),
    ];
}
