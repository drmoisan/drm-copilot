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
exports.registerDocumentWorkflowCommands = registerDocumentWorkflowCommands;
const vscode = __importStar(require("vscode"));
const command_runtime_1 = require("./command-runtime");
const extension_command_helpers_1 = require("./extension-command-helpers");
const workflow_command_arguments_1 = require("./workflow-command-arguments");
async function openBundledDocument(filePath) {
    const document = await vscode.workspace.openTextDocument(vscode.Uri.file(filePath));
    await vscode.window.showTextDocument(document);
}
function registerDocumentWorkflowCommands(options) {
    const resolvePolicyAuditTemplateAssetDisposable = vscode.commands.registerCommand("drmCopilotExtension.resolvePolicyAuditTemplateAsset", async (...rawArgs) => {
        const commandId = "drmCopilotExtension.resolvePolicyAuditTemplateAsset";
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => (0, workflow_command_arguments_1.resolvePolicyAuditTemplateAssetInvocation)(rawArgs));
        if (invocation.mode === "direct") {
            const result = await options.service.resolvePolicyAuditTemplateAsset({
                workspaceRoot,
                invocationId: commandId,
                asset: invocation.input.asset,
                ...(invocation.input.targetPath === undefined
                    ? {}
                    : {
                        targetPath: (0, workflow_command_arguments_1.normalizeWorkspaceDestinationPath)(invocation.input.targetPath, workspaceRoot, "-target"),
                    }),
            });
            if (result.destinationPath === undefined) {
                await openBundledDocument(result.bundledSourcePath ??
                    (() => {
                        throw new Error("Policy-audit asset resolution did not return a bundled source path.");
                    })());
            }
            return;
        }
        const asset = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Resolve Policy Audit Template Asset", "Choose the bundled policy-audit asset to open.", workflow_command_arguments_1.POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS);
        if (!asset) {
            return;
        }
        const result = await options.service.resolvePolicyAuditTemplateAsset({
            workspaceRoot,
            invocationId: commandId,
            asset,
        });
        await openBundledDocument(result.bundledSourcePath ??
            (() => {
                throw new Error("Policy-audit asset resolution did not return a bundled source path.");
            })());
    });
    const resolveExecuteHardLockPromptDisposable = vscode.commands.registerCommand("drmCopilotExtension.resolveExecuteHardLockPrompt", async () => {
        const commandId = "drmCopilotExtension.resolveExecuteHardLockPrompt";
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const planPath = await (0, extension_command_helpers_1.promptForActiveFeaturePlan)(workspaceRoot);
        if (!planPath) {
            return;
        }
        await options.service.resolveExecuteHardLockPrompt({
            workspaceRoot,
            invocationId: commandId,
            target: planPath,
        });
    });
    const resolveAtomicPlanPromptDisposable = vscode.commands.registerCommand("drmCopilotExtension.resolveAtomicPlanPrompt", async () => {
        const commandId = "drmCopilotExtension.resolveAtomicPlanPrompt";
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const planPath = await (0, extension_command_helpers_1.promptForActiveFeaturePlan)(workspaceRoot);
        if (!planPath) {
            return;
        }
        await options.service.resolveAtomicPlanPrompt({
            workspaceRoot,
            invocationId: commandId,
            target: planPath,
        });
    });
    return [
        resolvePolicyAuditTemplateAssetDisposable,
        resolveExecuteHardLockPromptDisposable,
        resolveAtomicPlanPromptDisposable,
    ];
}
