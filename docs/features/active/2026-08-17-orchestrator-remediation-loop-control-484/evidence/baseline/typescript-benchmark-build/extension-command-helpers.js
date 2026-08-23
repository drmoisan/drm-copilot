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
exports.POTENTIAL_DOCS_DIRECTORY = exports.ACTIVE_FEATURE_DOCS_DIRECTORY = void 0;
exports.normalizePath = normalizePath;
exports.getActivePotentialPath = getActivePotentialPath;
exports.getActiveFeaturePlanPath = getActiveFeaturePlanPath;
exports.promptForShortName = promptForShortName;
exports.promptForChoice = promptForChoice;
exports.promptForFeatureName = promptForFeatureName;
exports.promptForIssueNumber = promptForIssueNumber;
exports.promptForRequiredIssueNumber = promptForRequiredIssueNumber;
exports.promptForPotentialPath = promptForPotentialPath;
exports.promptForActiveFeaturePlan = promptForActiveFeaturePlan;
exports.promptForWorkspaceScanFolders = promptForWorkspaceScanFolders;
exports.resolveWorkflowInvocation = resolveWorkflowInvocation;
const vscode = __importStar(require("vscode"));
const workflow_command_arguments_1 = require("./workflow-command-arguments");
/**
 * Directory paths for features in the repository, used to detect context from
 * the active editor when the user has an appropriate file open.
 */
exports.ACTIVE_FEATURE_DOCS_DIRECTORY = "docs/features/active";
exports.POTENTIAL_DOCS_DIRECTORY = "docs/features/potential";
/**
 * Normalize a file path to use forward slashes for cross-platform comparison.
 *
 * @param filePath The path to normalize.
 * @returns The normalized path string.
 */
function normalizePath(filePath) {
    return filePath.replace(/\\/g, "/");
}
function isEligibleActiveFeaturePlanPath(workspaceRoot, filePath) {
    const normalizedWorkspaceRoot = normalizePath(workspaceRoot).toLowerCase();
    const normalizedFilePath = normalizePath(filePath).toLowerCase();
    const normalizedActiveFeatureRoot = `${normalizedWorkspaceRoot}/${exports.ACTIVE_FEATURE_DOCS_DIRECTORY}`;
    if (!normalizedFilePath.endsWith(".md")) {
        return false;
    }
    if (!normalizedFilePath.startsWith(`${normalizedActiveFeatureRoot}/`)) {
        return false;
    }
    const basename = normalizedFilePath.split("/").at(-1);
    return basename?.startsWith("plan") ?? false;
}
function getActiveFeaturePlanValidationMessage() {
    return "This command requires an active or selected plan markdown file under docs/features/active/**/plan*.md.";
}
/**
 * Return the fsPath of the active editor if it is a potential-entry file.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The active editor path when it is under the potential docs folder, or
 *   `undefined` if no qualifying file is open.
 */
function getActivePotentialPath(workspaceRoot) {
    const activeEditorPath = vscode.window.activeTextEditor?.document.uri.fsPath;
    if (!activeEditorPath) {
        return undefined;
    }
    const normalizedWorkspaceRoot = normalizePath(workspaceRoot).toLowerCase();
    const normalizedActiveEditorPath = normalizePath(activeEditorPath).toLowerCase();
    const normalizedPotentialRoot = `${normalizedWorkspaceRoot}/${exports.POTENTIAL_DOCS_DIRECTORY}`;
    if (!normalizedActiveEditorPath.endsWith(".md")) {
        return undefined;
    }
    if (!normalizedActiveEditorPath.startsWith(`${normalizedPotentialRoot}/`)) {
        return undefined;
    }
    return activeEditorPath;
}
/**
 * Return the fsPath of the active editor if it is a feature plan file.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The active editor path when it is under the active feature folder,
 *   or `undefined` if no qualifying file is open.
 */
function getActiveFeaturePlanPath(workspaceRoot) {
    const activeEditorPath = vscode.window.activeTextEditor?.document.uri.fsPath;
    if (!activeEditorPath) {
        return undefined;
    }
    if (!isEligibleActiveFeaturePlanPath(workspaceRoot, activeEditorPath)) {
        return undefined;
    }
    return activeEditorPath;
}
/**
 * Prompt the user to enter a kebab-case short name.
 *
 * @param title The input box title string.
 * @param prompt The input box prompt string.
 * @returns The validated short name, or `undefined` if the user cancelled.
 */
async function promptForShortName(title, prompt) {
    const shortName = await vscode.window.showInputBox({
        title,
        prompt,
        ignoreFocusOut: true,
        validateInput: (value) => (0, workflow_command_arguments_1.getShortNameValidationMessage)(value, "Short name"),
    });
    if (shortName === undefined) {
        return undefined;
    }
    return (0, workflow_command_arguments_1.validateShortName)(shortName.trim(), "Short name");
}
/**
 * Prompt the user to choose one item from a list.
 *
 * @param title The quick-pick title string.
 * @param prompt The quick-pick prompt string.
 * @param items The selectable items.
 * @returns The selected item, or `undefined` if the user cancelled.
 */
async function promptForChoice(title, prompt, items) {
    const selected = await vscode.window.showQuickPick([...items], {
        title,
        prompt,
        ignoreFocusOut: true,
    });
    return selected;
}
/**
 * Prompt the user to enter a feature name string.
 *
 * @param title The input box title string.
 * @param prompt The input box prompt string.
 * @returns The validated feature name, or `undefined` if the user cancelled.
 */
async function promptForFeatureName(title, prompt) {
    const featureName = await vscode.window.showInputBox({
        title,
        prompt,
        ignoreFocusOut: true,
        validateInput: workflow_command_arguments_1.getFeatureNameValidationMessage,
    });
    if (featureName === undefined) {
        return undefined;
    }
    return (0, workflow_command_arguments_1.validateFeatureName)(featureName.trim(), "Feature name");
}
/**
 * Prompt the user to enter an optional issue number for a new folder.
 *
 * @returns The issue number string, `null` when left blank, or `undefined` if
 *   the user cancelled.
 */
async function promptForIssueNumber() {
    const issueNumber = await vscode.window.showInputBox({
        title: "drm-copilot: New Active Feature Folder",
        prompt: "Enter the issue number, or leave blank to omit it.",
        ignoreFocusOut: true,
        validateInput: (value) => {
            const trimmed = value.trim();
            if (trimmed.length === 0) {
                return undefined;
            }
            return /^\d+$/.test(trimmed)
                ? undefined
                : "Issue number must be digits only when provided.";
        },
    });
    if (issueNumber === undefined) {
        return undefined;
    }
    const trimmed = issueNumber.trim();
    if (trimmed.length === 0) {
        return null;
    }
    return (0, workflow_command_arguments_1.validateIssueNumber)(trimmed);
}
/**
 * Prompt the user to enter a required numeric issue number.
 *
 * @param title The input box title string.
 * @param prompt The input box prompt string.
 * @param fieldName The user-facing field label used in validation messaging.
 * @returns The validated issue number, or `undefined` if the user cancelled.
 */
async function promptForRequiredIssueNumber(title, prompt, fieldName) {
    const issueNumber = await vscode.window.showInputBox({
        title,
        prompt,
        ignoreFocusOut: true,
        validateInput: (value) => (0, workflow_command_arguments_1.getRequiredIssueNumberValidationMessage)(value, fieldName),
    });
    if (issueNumber === undefined) {
        return undefined;
    }
    return (0, workflow_command_arguments_1.validateRequiredIssueNumber)(issueNumber.trim(), fieldName);
}
/**
 * Resolve the path to the potential-entry file to promote.
 *
 * Uses the active editor path when it is a qualifying potential file;
 * otherwise opens a file-picker dialog starting in the potential folder.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The selected file path, or `undefined` if the user cancelled.
 */
async function promptForPotentialPath(workspaceRoot) {
    const activePotentialPath = getActivePotentialPath(workspaceRoot);
    if (activePotentialPath) {
        return activePotentialPath;
    }
    const selectedFile = await vscode.window.showOpenDialog({
        canSelectMany: false,
        openLabel: "Select potential file",
        defaultUri: vscode.Uri.file(`${workspaceRoot}/${exports.POTENTIAL_DOCS_DIRECTORY}`),
        filters: {
            Markdown: ["md"],
        },
    });
    return selectedFile?.[0]?.fsPath;
}
/**
 * Resolve the path to the active feature plan file.
 *
 * Uses the active editor path when it is a qualifying plan file; otherwise
 * opens a file-picker dialog starting in the active features folder.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The selected file path, or `undefined` if the user cancelled.
 */
async function promptForActiveFeaturePlan(workspaceRoot) {
    const activePlanPath = getActiveFeaturePlanPath(workspaceRoot);
    if (activePlanPath) {
        return activePlanPath;
    }
    const selectedFile = await vscode.window.showOpenDialog({
        canSelectMany: false,
        openLabel: "Select feature plan",
        defaultUri: vscode.Uri.file(`${workspaceRoot}/${exports.ACTIVE_FEATURE_DOCS_DIRECTORY}`),
        filters: {
            Markdown: ["md"],
        },
    });
    const selectedPlanPath = selectedFile?.[0]?.fsPath;
    if (selectedPlanPath === undefined) {
        return undefined;
    }
    if (!isEligibleActiveFeaturePlanPath(workspaceRoot, selectedPlanPath)) {
        throw new Error(getActiveFeaturePlanValidationMessage());
    }
    return selectedPlanPath;
}
/**
 * Prompt the user to choose one or more workspace folders to scan.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The selected folder paths, or `undefined` if the user cancelled.
 */
async function promptForWorkspaceScanFolders(workspaceRoot) {
    const selectedFolders = await vscode.window.showOpenDialog({
        canSelectMany: true,
        canSelectFiles: false,
        canSelectFolders: true,
        defaultUri: vscode.Uri.file(workspaceRoot),
        openLabel: "Select folders to scan",
        title: "drm-copilot: Run PoshQC Suite",
    });
    if (!selectedFolders) {
        return undefined;
    }
    return selectedFolders.map((folder) => folder.fsPath);
}
/**
 * Resolve a workflow command invocation, logging its mode to the output channel.
 *
 * @param output The extension output channel for logging.
 * @param commandId The VS Code command ID being resolved.
 * @param resolver A callback that produces the invocation; throws on failure.
 * @returns The resolved invocation.
 * @throws Re-throws any error raised by the resolver after logging the failure.
 */
function resolveWorkflowInvocation(output, commandId, resolver) {
    try {
        const invocation = resolver();
        output.appendLine(`[${commandId}] ${invocation.mode} mode`);
        return invocation;
    }
    catch (error) {
        const detail = error instanceof Error ? error.message : String(error);
        output.appendLine(`[${commandId}] validation failure: ${detail}`);
        throw error;
    }
}
