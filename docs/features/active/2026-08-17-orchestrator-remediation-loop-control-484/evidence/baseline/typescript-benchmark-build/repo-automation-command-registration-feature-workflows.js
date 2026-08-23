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
exports.registerRepoAutomationFeatureWorkflowCommands = registerRepoAutomationFeatureWorkflowCommands;
const vscode = __importStar(require("vscode"));
const command_runtime_1 = require("./command-runtime");
const extension_command_helpers_1 = require("./extension-command-helpers");
const workflow_command_arguments_1 = require("./workflow-command-arguments");
function registerNewPotentialBugEntryCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.newPotentialBugEntry", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.newPotentialBugEntry";
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => (0, workflow_command_arguments_1.resolveNewPotentialBugEntryInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            await options.service.newPotentialBugEntry({
                workspaceRoot,
                invocationId: commandId,
                ...invocation.input,
            });
            return;
        }
        const shortName = await (0, extension_command_helpers_1.promptForShortName)("drm-copilot: New Potential Bug Entry", "Enter a kebab-case short name for the potential bug entry.");
        if (!shortName) {
            return;
        }
        await options.service.newPotentialBugEntry({
            workspaceRoot,
            invocationId: commandId,
            shortName,
        });
    });
}
function registerNewPotentialEntryCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.newPotentialEntry", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.newPotentialEntry";
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => (0, workflow_command_arguments_1.resolveNewPotentialEntryInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            await options.service.newPotentialEntry({
                workspaceRoot,
                invocationId: commandId,
                ...invocation.input,
            });
            return;
        }
        const shortName = await (0, extension_command_helpers_1.promptForShortName)("drm-copilot: New Potential Entry", "Enter a kebab-case short name for the potential entry.");
        if (!shortName) {
            return;
        }
        await options.service.newPotentialEntry({
            workspaceRoot,
            invocationId: commandId,
            shortName,
        });
    });
}
function registerLinkParentChildCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.linkParentChild", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.linkParentChild";
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => (0, workflow_command_arguments_1.resolveLinkParentChildInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            await options.service.linkParentChild({
                workspaceRoot,
                invocationId: commandId,
                ...invocation.input,
            });
            return;
        }
        const childIssueNumber = await (0, extension_command_helpers_1.promptForRequiredIssueNumber)("drm-copilot: Link Parent/Child Issues", "Enter the child issue number.", "Child issue number");
        if (!childIssueNumber) {
            return;
        }
        const parentIssueNumber = await (0, extension_command_helpers_1.promptForRequiredIssueNumber)("drm-copilot: Link Parent/Child Issues", "Enter the parent tracking issue number.", "Parent issue number");
        if (!parentIssueNumber) {
            return;
        }
        await options.service.linkParentChild({
            workspaceRoot,
            invocationId: commandId,
            childIssueNumber,
            parentIssueNumber,
        });
    });
}
function registerPotentialToIssueCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.potentialToIssue", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.potentialToIssue";
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => (0, workflow_command_arguments_1.resolvePotentialToIssueInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            await options.service.potentialToIssue({
                workspaceRoot,
                invocationId: commandId,
                ...invocation.input,
            });
            return;
        }
        const potentialPath = await (0, extension_command_helpers_1.promptForPotentialPath)(workspaceRoot);
        if (!potentialPath) {
            return;
        }
        const promotionType = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Potential To Issue", "Choose a promotion type.", workflow_command_arguments_1.POTENTIAL_PROMOTION_TYPES);
        if (!promotionType) {
            return;
        }
        const workMode = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Potential To Issue", "Choose a work mode.", workflow_command_arguments_1.WORK_MODE_OPTIONS);
        if (!workMode) {
            return;
        }
        await options.service.potentialToIssue({
            workspaceRoot,
            invocationId: commandId,
            potentialPath,
            promotionType,
            workMode,
        });
    });
}
function registerNewActiveFeatureFolderCommand(options) {
    return vscode.commands.registerCommand("drmCopilotExtension.newActiveFeatureFolder", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.newActiveFeatureFolder";
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => (0, workflow_command_arguments_1.resolveNewActiveFeatureFolderInvocation)(rawArgs));
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        if (invocation.mode === "direct") {
            await options.service.newActiveFeatureFolder({
                workspaceRoot,
                invocationId: commandId,
                ...invocation.input,
            });
            return;
        }
        const featureType = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: New Active Feature Folder", "Choose the feature folder type.", workflow_command_arguments_1.POTENTIAL_PROMOTION_TYPES);
        if (!featureType) {
            return;
        }
        const featureName = await (0, extension_command_helpers_1.promptForFeatureName)("drm-copilot: New Active Feature Folder", "Enter the feature name (kebab-case or underscore-case).");
        if (!featureName) {
            return;
        }
        const issueNumber = await (0, extension_command_helpers_1.promptForIssueNumber)();
        if (issueNumber === undefined) {
            return;
        }
        const workMode = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: New Active Feature Folder", "Choose a work mode.", workflow_command_arguments_1.WORK_MODE_OPTIONS);
        if (!workMode) {
            return;
        }
        await options.service.newActiveFeatureFolder({
            workspaceRoot,
            invocationId: commandId,
            featureName,
            type: featureType,
            workMode,
            ...(issueNumber === null ? {} : { issueNumber }),
        });
    });
}
function registerRepoAutomationFeatureWorkflowCommands(options) {
    return [
        registerNewPotentialBugEntryCommand(options),
        registerNewPotentialEntryCommand(options),
        registerLinkParentChildCommand(options),
        registerPotentialToIssueCommand(options),
        registerNewActiveFeatureFolderCommand(options),
    ];
}
