"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveCollectPrContextInvocation = resolveCollectPrContextInvocation;
exports.resolveNewPotentialEntryInvocation = resolveNewPotentialEntryInvocation;
exports.resolveNewPotentialBugEntryInvocation = resolveNewPotentialBugEntryInvocation;
exports.resolveLinkParentChildInvocation = resolveLinkParentChildInvocation;
exports.resolvePotentialToIssueInvocation = resolvePotentialToIssueInvocation;
exports.resolveNewActiveFeatureFolderInvocation = resolveNewActiveFeatureFolderInvocation;
exports.resolveRunPoshQCSuiteInvocation = resolveRunPoshQCSuiteInvocation;
exports.resolveRunPoshQCFormatInvocation = resolveRunPoshQCFormatInvocation;
exports.resolveRunPoshQCAnalyzeInvocation = resolveRunPoshQCAnalyzeInvocation;
exports.resolveRunPoshQCTestInvocation = resolveRunPoshQCTestInvocation;
exports.resolveRunPoshQCAnalyzeAutofixInvocation = resolveRunPoshQCAnalyzeAutofixInvocation;
exports.resolvePolicyAuditTemplateAssetInvocation = resolvePolicyAuditTemplateAssetInvocation;
const workflow_command_arguments_1 = require("./workflow-command-arguments");
function resolveCollectPrContextInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const parsedArgs = (0, workflow_command_arguments_1.parseWorkflowCommandArguments)(rawArgs, ["--base"]);
    return {
        mode: "direct",
        input: {
            base: (0, workflow_command_arguments_1.normalizeRequiredText)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--base"), "--base"),
        },
    };
}
function resolveNewPotentialEntryInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const parsedArgs = (0, workflow_command_arguments_1.parseWorkflowCommandArguments)(rawArgs, ["-ShortName"]);
    return {
        mode: "direct",
        input: {
            shortName: (0, workflow_command_arguments_1.validateShortName)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "-ShortName"), "-ShortName"),
        },
    };
}
function resolveNewPotentialBugEntryInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const parsedArgs = (0, workflow_command_arguments_1.parseWorkflowCommandArguments)(rawArgs, ["--short-name"]);
    return {
        mode: "direct",
        input: {
            shortName: (0, workflow_command_arguments_1.validateShortName)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--short-name"), "--short-name"),
        },
    };
}
function resolveLinkParentChildInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const parsedArgs = (0, workflow_command_arguments_1.parseWorkflowCommandArguments)(rawArgs, [
        "-ChildIssueNumber",
        "-ParentIssueNumber",
    ]);
    return {
        mode: "direct",
        input: {
            childIssueNumber: (0, workflow_command_arguments_1.validateRequiredIssueNumber)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "-ChildIssueNumber"), "-ChildIssueNumber"),
            parentIssueNumber: (0, workflow_command_arguments_1.validateRequiredIssueNumber)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "-ParentIssueNumber"), "-ParentIssueNumber"),
        },
    };
}
function resolvePotentialToIssueInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const parsedArgs = (0, workflow_command_arguments_1.parseWorkflowCommandArguments)(rawArgs, [
        "--potential-path",
        "--promotion-type",
        "--work-mode",
    ]);
    return {
        mode: "direct",
        input: {
            potentialPath: (0, workflow_command_arguments_1.normalizeRequiredText)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--potential-path"), "--potential-path"),
            promotionType: (0, workflow_command_arguments_1.validateChoice)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--promotion-type"), "--promotion-type", workflow_command_arguments_1.POTENTIAL_PROMOTION_TYPES),
            workMode: (0, workflow_command_arguments_1.validateChoice)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--work-mode"), "--work-mode", workflow_command_arguments_1.WORK_MODE_OPTIONS),
        },
    };
}
function resolveNewActiveFeatureFolderInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const parsedArgs = (0, workflow_command_arguments_1.parseWorkflowCommandArguments)(rawArgs, [
        "--feature-name",
        "--type",
        "--issue-number",
        "--work-mode",
    ]);
    const issueNumber = (0, workflow_command_arguments_1.validateIssueNumber)((0, workflow_command_arguments_1.getOptionalFlagValue)(parsedArgs, "--issue-number"));
    return {
        mode: "direct",
        input: {
            featureName: (0, workflow_command_arguments_1.validateFeatureName)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--feature-name"), "--feature-name"),
            type: (0, workflow_command_arguments_1.validateChoice)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--type"), "--type", workflow_command_arguments_1.POTENTIAL_PROMOTION_TYPES),
            workMode: (0, workflow_command_arguments_1.validateChoice)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "--work-mode"), "--work-mode", workflow_command_arguments_1.WORK_MODE_OPTIONS),
            ...(issueNumber === undefined ? {} : { issueNumber }),
        },
    };
}
function resolveRunPoshQCSuiteInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const stringArgs = (0, workflow_command_arguments_1.normalizeStringArguments)(rawArgs);
    const scanFolders = [];
    for (let index = 0; index < stringArgs.length; index += 2) {
        const flag = stringArgs[index];
        if (flag === undefined) {
            break;
        }
        if (flag !== "--scan-folder") {
            throw new Error(`Unknown flag '${flag}'. Accepted flags: --scan-folder.`);
        }
        const value = stringArgs[index + 1];
        if (value === undefined || value.startsWith("-")) {
            throw new Error("Flag '--scan-folder' requires a value.");
        }
        scanFolders.push((0, workflow_command_arguments_1.normalizeRequiredText)(value, "--scan-folder"));
    }
    return {
        mode: "direct",
        input: {
            ...(scanFolders.length === 0 ? {} : { scanFolders }),
        },
    };
}
function resolveRunPoshQCFormatInvocation(rawArgs) {
    return resolveRunPoshQCSuiteInvocation(rawArgs);
}
function resolveRunPoshQCAnalyzeInvocation(rawArgs) {
    return resolveRunPoshQCSuiteInvocation(rawArgs);
}
function resolveRunPoshQCTestInvocation(rawArgs) {
    return resolveRunPoshQCSuiteInvocation(rawArgs);
}
function resolveRunPoshQCAnalyzeAutofixInvocation(rawArgs) {
    return resolveRunPoshQCSuiteInvocation(rawArgs);
}
function resolvePolicyAuditTemplateAssetInvocation(rawArgs) {
    if (rawArgs.length === 0) {
        return { mode: "interactive" };
    }
    const parsedArgs = (0, workflow_command_arguments_1.parseWorkflowCommandArguments)(rawArgs, [
        "-asset",
        "-target",
    ]);
    const asset = (0, workflow_command_arguments_1.validatePolicyAuditTemplateAssetSelector)((0, workflow_command_arguments_1.getRequiredFlagValue)(parsedArgs, "-asset"), "-asset");
    const targetPath = (0, workflow_command_arguments_1.getOptionalFlagValue)(parsedArgs, "-target");
    return {
        mode: "direct",
        input: {
            asset,
            ...(targetPath === undefined
                ? {}
                : { targetPath: (0, workflow_command_arguments_1.normalizeRequiredText)(targetPath, "-target") }),
        },
    };
}
