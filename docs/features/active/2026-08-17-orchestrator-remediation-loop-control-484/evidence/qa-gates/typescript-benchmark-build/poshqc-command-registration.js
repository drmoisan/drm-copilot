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
exports.registerPoshQcCommands = registerPoshQcCommands;
const vscode = __importStar(require("vscode"));
const command_runtime_1 = require("./command-runtime");
const extension_command_helpers_1 = require("./extension-command-helpers");
const file_system_1 = require("./lib/file-system");
const poshqc_folder_picker_1 = require("./poshqc-folder-picker");
const poshqc_terminal_output_1 = require("./poshqc-terminal-output");
const workflow_command_arguments_1 = require("./workflow-command-arguments");
/**
 * Resolve the run context for a single command invocation. When a service
 * factory is configured, build a streaming terminal, tee the `OutputChannel`
 * and the terminal into one sink, and bind a fresh service to that tee;
 * otherwise use the shared service with a no-op reveal.
 *
 * @param options The command-registration options.
 * @returns The service to run against and its terminal-reveal callback.
 */
function resolvePoshQcRunContext(options) {
    if (!options.createService) {
        return { service: options.service, reveal: () => undefined };
    }
    const terminal = (options.createTerminalOutput ?? poshqc_terminal_output_1.createPoshQcTerminalOutput)();
    const teed = (0, poshqc_terminal_output_1.createTeeOutput)(options.output, terminal);
    return {
        service: options.createService(teed),
        reveal: () => terminal.reveal(),
    };
}
function registerPoshQcCommand(options, definition) {
    return vscode.commands.registerCommand(definition.commandId, async (...rawArgs) => {
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, definition.commandId, () => (0, workflow_command_arguments_1.resolveRunPoshQCSuiteInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            const context = resolvePoshQcRunContext(options);
            context.reveal();
            await definition.runOperation(context.service, {
                workspaceRoot,
                invocationId: definition.commandId,
                ...invocation.input,
            });
            return;
        }
        const scopeChoice = await (0, extension_command_helpers_1.promptForChoice)(definition.title, "Choose the scan scope.", ["Scan entire workspace", "Select folders to scan"]);
        if (!scopeChoice) {
            return;
        }
        if (scopeChoice === "Select folders to scan") {
            const selectScanFolders = definition.selectScanFolders ?? extension_command_helpers_1.promptForWorkspaceScanFolders;
            const selectedFolders = await selectScanFolders(workspaceRoot);
            if (!selectedFolders) {
                return;
            }
            const context = resolvePoshQcRunContext(options);
            context.reveal();
            await definition.runOperation(context.service, {
                workspaceRoot,
                invocationId: definition.commandId,
                scanFolders: selectedFolders,
            });
            return;
        }
        const context = resolvePoshQcRunContext(options);
        context.reveal();
        await definition.runOperation(context.service, {
            workspaceRoot,
            invocationId: definition.commandId,
        });
    });
}
function registerPoshQcCommands(options) {
    // Filesystem seam for the test command's seeded multi-select folder picker.
    const fileSystem = options.fileSystem ?? new file_system_1.RealFileSystem();
    return [
        registerPoshQcCommand(options, {
            commandId: "drmCopilotExtension.runPoshQCFormat",
            title: "drm-copilot: Run PoshQC Format",
            runOperation: (service, input) => service.runPoshQCFormat(input),
        }),
        registerPoshQcCommand(options, {
            commandId: "drmCopilotExtension.runPoshQCAnalyze",
            title: "drm-copilot: Run PoshQC Analyze",
            runOperation: (service, input) => service.runPoshQCAnalyze(input),
        }),
        registerPoshQcCommand(options, {
            commandId: "drmCopilotExtension.runPoshQCTest",
            title: "drm-copilot: Run PoshQC Test",
            runOperation: (service, input) => service.runPoshQCTest(input),
            selectScanFolders: (workspaceRoot) => (0, poshqc_folder_picker_1.promptForPoshQcScanFolders)(fileSystem, workspaceRoot),
        }),
        registerPoshQcCommand(options, {
            commandId: "drmCopilotExtension.runPoshQCAnalyzeAutofix",
            title: "drm-copilot: Run PoshQC Analyze Autofix",
            runOperation: (service, input) => service.runPoshQCAnalyzeAutofix(input),
        }),
    ];
}
