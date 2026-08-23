"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolvePotentialToIssueToolInput = exports.resolvePushDownCodexAndAgentsCustomizationsToolInput = exports.resolvePushDownClaudeCustomizationsToolInput = void 0;
exports.asToolArgumentObject = asToolArgumentObject;
exports.resolveCollectCommitContextToolInput = resolveCollectCommitContextToolInput;
exports.resolveCollectPrContextToolInput = resolveCollectPrContextToolInput;
exports.resolveRunCodexNativeConverterToolInput = resolveRunCodexNativeConverterToolInput;
exports.resolvePushDownCopilotCustomizationsToolInput = resolvePushDownCopilotCustomizationsToolInput;
exports.resolveNewPotentialBugEntryToolInput = resolveNewPotentialBugEntryToolInput;
exports.resolveNewPotentialEntryToolInput = resolveNewPotentialEntryToolInput;
exports.resolveLinkParentChildToolInput = resolveLinkParentChildToolInput;
exports.resolveNewActiveFeatureFolderToolInput = resolveNewActiveFeatureFolderToolInput;
exports.resolveResolveExecuteHardLockPromptToolInput = resolveResolveExecuteHardLockPromptToolInput;
exports.resolveResolveAtomicPlanPromptToolInput = resolveResolveAtomicPlanPromptToolInput;
exports.resolvePolicyAuditTemplateAssetToolInput = resolvePolicyAuditTemplateAssetToolInput;
exports.resolveRunPoshQCSuiteToolInput = resolveRunPoshQCSuiteToolInput;
exports.resolveValidateOrchestrationArtifactsToolInput = resolveValidateOrchestrationArtifactsToolInput;
const workflow_command_arguments_1 = require("./workflow-command-arguments");
var mcp_tool_inputs_push_down_1 = require("./mcp-tool-inputs-push-down");
Object.defineProperty(exports, "resolvePushDownClaudeCustomizationsToolInput", { enumerable: true, get: function () { return mcp_tool_inputs_push_down_1.resolvePushDownClaudeCustomizationsToolInput; } });
Object.defineProperty(exports, "resolvePushDownCodexAndAgentsCustomizationsToolInput", { enumerable: true, get: function () { return mcp_tool_inputs_push_down_1.resolvePushDownCodexAndAgentsCustomizationsToolInput; } });
var mcp_tool_inputs_potential_to_issue_1 = require("./mcp-tool-inputs-potential-to-issue");
Object.defineProperty(exports, "resolvePotentialToIssueToolInput", { enumerable: true, get: function () { return mcp_tool_inputs_potential_to_issue_1.resolvePotentialToIssueToolInput; } });
function asToolArgumentObject(rawInput) {
    if (rawInput === undefined) {
        return {};
    }
    if (typeof rawInput !== "object" ||
        rawInput === null ||
        Array.isArray(rawInput)) {
        throw new Error("Tool arguments must be an object.");
    }
    return rawInput;
}
function resolvePromotionTypeField(rawValue, fieldName) {
    return (0, workflow_command_arguments_1.validatePromotionType)((0, workflow_command_arguments_1.normalizeRequiredText)(rawValue, fieldName), fieldName);
}
function resolveWorkModeField(rawValue, fieldName) {
    return (0, workflow_command_arguments_1.validateWorkMode)((0, workflow_command_arguments_1.normalizeRequiredText)(rawValue, fieldName), fieldName);
}
function resolveCollectCommitContextToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
    };
}
function resolveCollectPrContextToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        base: (0, workflow_command_arguments_1.normalizeRequiredText)(args["base"], "base"),
    };
}
function resolveRunCodexNativeConverterToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    const workspaceRoot = (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot);
    const mode = (0, workflow_command_arguments_1.normalizeRequiredText)(args["mode"], "mode");
    if (mode !== "review" && mode !== "apply") {
        throw new Error("Field 'mode' must be 'review' or 'apply'.");
    }
    const sourceEcosystem = (0, workflow_command_arguments_1.normalizeRequiredText)(args["source_ecosystem"], "source_ecosystem");
    if (sourceEcosystem !== "github-copilot" && sourceEcosystem !== "claude") {
        throw new Error("Field 'source_ecosystem' must be 'github-copilot' or 'claude'.");
    }
    const selectedPaths = args["selected_paths"];
    if (selectedPaths !== undefined && !Array.isArray(selectedPaths)) {
        throw new Error("Field 'selected_paths' must be an array when provided.");
    }
    const destinationRoot = (0, workflow_command_arguments_1.normalizeOptionalText)(args["destination_root"], "destination_root");
    if (mode === "apply" && destinationRoot === undefined) {
        throw new Error("Field 'destination_root' is required when mode is 'apply'.");
    }
    const artifactRoot = (0, workflow_command_arguments_1.normalizeOptionalText)(args["artifact_root"], "artifact_root");
    const enableRepoPrompts = args["enable_repo_prompts"];
    if (enableRepoPrompts !== undefined &&
        typeof enableRepoPrompts !== "boolean") {
        throw new Error("Field 'enable_repo_prompts' must be a boolean when provided.");
    }
    return {
        workspaceRoot,
        mode,
        sourceEcosystem,
        sourceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceDestinationPath)((0, workflow_command_arguments_1.normalizeRequiredText)(args["source_root"], "source_root"), workspaceRoot, "source_root"),
        ...(selectedPaths === undefined
            ? {}
            : {
                selectedPaths: selectedPaths.map((selectedPath, index) => (0, workflow_command_arguments_1.normalizeWorkspaceDestinationPath)((0, workflow_command_arguments_1.normalizeRequiredText)(selectedPath, `selected_paths[${index}]`), workspaceRoot, `selected_paths[${index}]`)),
            }),
        ...(destinationRoot === undefined
            ? {}
            : {
                destinationRoot: (0, workflow_command_arguments_1.normalizeWorkspaceDestinationPath)(destinationRoot, workspaceRoot, "destination_root"),
            }),
        ...(artifactRoot === undefined
            ? {}
            : {
                artifactRoot: (0, workflow_command_arguments_1.normalizeWorkspaceDestinationPath)(artifactRoot, workspaceRoot, "artifact_root"),
            }),
        ...(enableRepoPrompts === true ? { enableRepoPrompts: true } : {}),
    };
}
function resolvePushDownCopilotCustomizationsToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
    };
}
function resolveNewPotentialBugEntryToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        shortName: (0, workflow_command_arguments_1.validateShortName)((0, workflow_command_arguments_1.normalizeRequiredText)(args["short_name"], "short_name"), "short_name"),
    };
}
function resolveNewPotentialEntryToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        shortName: (0, workflow_command_arguments_1.validateShortName)((0, workflow_command_arguments_1.normalizeRequiredText)(args["short_name"], "short_name"), "short_name"),
    };
}
function resolveLinkParentChildToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        childIssueNumber: (0, workflow_command_arguments_1.validateRequiredIssueNumber)((0, workflow_command_arguments_1.normalizeRequiredText)(args["child_issue_number"], "child_issue_number"), "child_issue_number"),
        parentIssueNumber: (0, workflow_command_arguments_1.validateRequiredIssueNumber)((0, workflow_command_arguments_1.normalizeRequiredText)(args["parent_issue_number"], "parent_issue_number"), "parent_issue_number"),
    };
}
function resolveNewActiveFeatureFolderToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    const issueNumber = (0, workflow_command_arguments_1.validateIssueNumber)((0, workflow_command_arguments_1.normalizeOptionalText)(args["issue_number"], "issue_number"));
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        featureName: (0, workflow_command_arguments_1.validateFeatureName)((0, workflow_command_arguments_1.normalizeRequiredText)(args["feature_name"], "feature_name"), "feature_name"),
        type: resolvePromotionTypeField(args["type"], "type"),
        workMode: resolveWorkModeField(args["work_mode"], "work_mode"),
        ...(issueNumber === undefined ? {} : { issueNumber }),
    };
}
function resolveResolveExecuteHardLockPromptToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        target: (0, workflow_command_arguments_1.normalizeRequiredText)(args["target"], "target"),
    };
}
function resolveResolveAtomicPlanPromptToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        target: (0, workflow_command_arguments_1.normalizeRequiredText)(args["target"], "target"),
    };
}
function resolvePolicyAuditTemplateAssetToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    const workspaceRoot = (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot);
    const targetPath = (0, workflow_command_arguments_1.normalizeOptionalText)(args["target_path"], "target_path");
    return {
        workspaceRoot,
        asset: (0, workflow_command_arguments_1.validatePolicyAuditTemplateAssetSelector)((0, workflow_command_arguments_1.normalizeRequiredText)(args["asset"], "asset"), "asset"),
        ...(targetPath === undefined
            ? {}
            : {
                targetPath: (0, workflow_command_arguments_1.normalizeWorkspaceDestinationPath)(targetPath, workspaceRoot, "target_path"),
            }),
    };
}
function resolveRunPoshQCSuiteToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    const scanFolders = args["scan_folders"];
    if (scanFolders === undefined) {
        return {
            workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        };
    }
    if (!Array.isArray(scanFolders)) {
        throw new Error("Field 'scan_folders' must be an array when provided.");
    }
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        scanFolders: scanFolders.map((folder, index) => (0, workflow_command_arguments_1.normalizeRequiredText)(folder, `scan_folders[${index}]`)),
    };
}
const VALID_ARTIFACT_TYPES = new Set([
    "plan",
    "policy-audit",
    "code-review",
    "feature-audit",
    "orchestrator-state",
    "epic-orchestrator-state",
    "epic-planner-state",
    "epic-kickoff",
    "parallel-orchestrator-state",
    "parallel-planner-state",
    "parallel-kickoff",
]);
function resolveValidateOrchestrationArtifactsToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = asToolArgumentObject(rawInput);
    const artifactType = (0, workflow_command_arguments_1.normalizeRequiredText)(args["artifact_type"], "artifact_type");
    if (!VALID_ARTIFACT_TYPES.has(artifactType)) {
        throw new Error(`Field 'artifact_type' must be one of: ${[...VALID_ARTIFACT_TYPES].join(", ")}. Got '${artifactType}'.`);
    }
    const requireComplete = args["require_complete"];
    const requireModelRouting = args["require_model_routing"];
    const requireCodexModelRouting = args["require_codex_model_routing"];
    const requireCodexTopology = args["require_codex_topology"];
    const requireReadyForExecution = args["require_ready_for_execution"];
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        artifactType,
        artifactPath: (0, workflow_command_arguments_1.normalizeRequiredText)(args["artifact_path"], "artifact_path"),
        ...(requireComplete === true ? { requireComplete: true } : {}),
        ...(requireModelRouting === true ? { requireModelRouting: true } : {}),
        ...(requireCodexModelRouting === true
            ? { requireCodexModelRouting: true }
            : {}),
        ...(requireCodexTopology === true ? { requireCodexTopology: true } : {}),
        ...(requireReadyForExecution === true
            ? { requireReadyForExecution: true }
            : {}),
    };
}
