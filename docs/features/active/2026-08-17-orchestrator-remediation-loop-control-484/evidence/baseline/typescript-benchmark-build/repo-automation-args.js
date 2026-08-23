"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildPoshQcWorkflowArguments = buildPoshQcWorkflowArguments;
const repo_automation_service_support_1 = require("./repo-automation-service-support");
function buildPoshQcWorkflowArguments(tool, input) {
    const toolConfig = repo_automation_service_support_1.POSH_QC_TOOL_CONFIG[tool];
    const args = ["-WorkspaceRoot", input.workspaceRoot];
    if (input.scanFolders && input.scanFolders.length > 0) {
        if (tool === "run_poshqc_format" ||
            tool === "run_poshqc_analyze" ||
            tool === "run_poshqc_test") {
            args.push("-ScanFoldersJson", JSON.stringify(input.scanFolders));
        }
        else {
            for (const scanFolder of input.scanFolders) {
                args.push("-ScanFolders", scanFolder);
            }
        }
    }
    const summaryTemplate = input.scanFolders && input.scanFolders.length > 0
        ? toolConfig.summaryWithFolders
        : toolConfig.summaryWithoutFolders;
    const summary = summaryTemplate
        .replace("{workspaceRoot}", input.workspaceRoot)
        .replace("{scanFolderCount}", String(input.scanFolders?.length ?? 0));
    return {
        args,
        bundledRelativePath: toolConfig.bundledRelativePath,
        summary,
    };
}
