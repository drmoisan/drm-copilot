import {
  normalizeWorkspaceDestinationPath,
  normalizeOptionalText,
  normalizeRequiredText,
  normalizeWorkspaceRoot,
  type LinkParentChildInput,
  type NewActiveFeatureFolderInput,
  type NewPotentialEntryInput,
  type PolicyAuditTemplateAssetSelector,
  type PotentialPromotionType,
  type PotentialToIssueInput,
  validatePolicyAuditTemplateAssetSelector,
  type WorkModeOption,
  validateFeatureName,
  validateIssueNumber,
  validatePromotionType,
  validateRequiredIssueNumber,
  validateShortName,
  validateWorkMode,
} from "./workflow-command-arguments";

export interface WorkspaceToolInput {
  readonly workspaceRoot: string;
}

export {
  resolvePushDownClaudeCustomizationsToolInput,
  resolvePushDownCodexAndAgentsCustomizationsToolInput,
} from "./mcp-tool-inputs-push-down";
export { resolvePotentialToIssueToolInput } from "./mcp-tool-inputs-potential-to-issue";
export type {
  PushDownClaudeCustomizationsToolInput,
  PushDownCodexAndAgentsCustomizationsToolInput,
} from "./mcp-tool-inputs-push-down";

export interface CollectPrContextToolInput extends WorkspaceToolInput {
  readonly base: string;
}

export interface RunCodexNativeConverterToolInput extends WorkspaceToolInput {
  readonly mode: "review" | "apply";
  readonly sourceEcosystem: "github-copilot" | "claude";
  readonly sourceRoot: string;
  readonly selectedPaths?: ReadonlyArray<string>;
  readonly destinationRoot?: string;
  readonly artifactRoot?: string;
  readonly enableRepoPrompts?: boolean;
}

export interface NewPotentialEntryToolInput
  extends WorkspaceToolInput, NewPotentialEntryInput {}

export interface LinkParentChildToolInput
  extends WorkspaceToolInput, LinkParentChildInput {}

export interface PotentialToIssueToolInput
  extends WorkspaceToolInput, PotentialToIssueInput {}

export interface NewActiveFeatureFolderToolInput
  extends WorkspaceToolInput, NewActiveFeatureFolderInput {}

export interface ResolveExecuteHardLockPromptToolInput extends WorkspaceToolInput {
  readonly target: string;
}

export interface ResolveAtomicPlanPromptToolInput extends WorkspaceToolInput {
  readonly target: string;
}

export interface ResolvePolicyAuditTemplateAssetToolInput extends WorkspaceToolInput {
  readonly asset: PolicyAuditTemplateAssetSelector;
  readonly targetPath?: string;
}

export interface RunPoshQCSuiteToolInput extends WorkspaceToolInput {
  readonly scanFolders?: ReadonlyArray<string>;
}

export interface ValidateOrchestrationArtifactsToolInput extends WorkspaceToolInput {
  readonly artifactType: string;
  readonly artifactPath: string;
  readonly requireComplete?: boolean;
  readonly requireModelRouting?: boolean;
  readonly requireCodexModelRouting?: boolean;
  readonly requireCodexTopology?: boolean;
  readonly requireReadyForExecution?: boolean;
}

export function asToolArgumentObject(
  rawInput: unknown,
): Readonly<Record<string, unknown>> {
  if (rawInput === undefined) {
    return {};
  }

  if (
    typeof rawInput !== "object" ||
    rawInput === null ||
    Array.isArray(rawInput)
  ) {
    throw new Error("Tool arguments must be an object.");
  }

  return rawInput as Readonly<Record<string, unknown>>;
}

function resolvePromotionTypeField(
  rawValue: unknown,
  fieldName: string,
): PotentialPromotionType {
  return validatePromotionType(
    normalizeRequiredText(rawValue, fieldName),
    fieldName,
  );
}

function resolveWorkModeField(
  rawValue: unknown,
  fieldName: string,
): WorkModeOption {
  return validateWorkMode(
    normalizeRequiredText(rawValue, fieldName),
    fieldName,
  );
}

export function resolveCollectCommitContextToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): WorkspaceToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
  };
}

export function resolveCollectPrContextToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): CollectPrContextToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    base: normalizeRequiredText(args["base"], "base"),
  };
}

export function resolveRunCodexNativeConverterToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunCodexNativeConverterToolInput {
  const args = asToolArgumentObject(rawInput);
  const workspaceRoot = normalizeWorkspaceRoot(
    args["workspace_root"],
    fallbackWorkspaceRoot,
  );
  const mode = normalizeRequiredText(args["mode"], "mode");
  if (mode !== "review" && mode !== "apply") {
    throw new Error("Field 'mode' must be 'review' or 'apply'.");
  }

  const sourceEcosystem = normalizeRequiredText(
    args["source_ecosystem"],
    "source_ecosystem",
  );
  if (sourceEcosystem !== "github-copilot" && sourceEcosystem !== "claude") {
    throw new Error(
      "Field 'source_ecosystem' must be 'github-copilot' or 'claude'.",
    );
  }

  const selectedPaths = args["selected_paths"];
  if (selectedPaths !== undefined && !Array.isArray(selectedPaths)) {
    throw new Error("Field 'selected_paths' must be an array when provided.");
  }

  const destinationRoot = normalizeOptionalText(
    args["destination_root"],
    "destination_root",
  );
  if (mode === "apply" && destinationRoot === undefined) {
    throw new Error(
      "Field 'destination_root' is required when mode is 'apply'.",
    );
  }

  const artifactRoot = normalizeOptionalText(
    args["artifact_root"],
    "artifact_root",
  );
  const enableRepoPrompts = args["enable_repo_prompts"];
  if (
    enableRepoPrompts !== undefined &&
    typeof enableRepoPrompts !== "boolean"
  ) {
    throw new Error(
      "Field 'enable_repo_prompts' must be a boolean when provided.",
    );
  }

  return {
    workspaceRoot,
    mode,
    sourceEcosystem,
    sourceRoot: normalizeWorkspaceDestinationPath(
      normalizeRequiredText(args["source_root"], "source_root"),
      workspaceRoot,
      "source_root",
    ),
    ...(selectedPaths === undefined
      ? {}
      : {
          selectedPaths: selectedPaths.map((selectedPath, index) =>
            normalizeWorkspaceDestinationPath(
              normalizeRequiredText(selectedPath, `selected_paths[${index}]`),
              workspaceRoot,
              `selected_paths[${index}]`,
            ),
          ),
        }),
    ...(destinationRoot === undefined
      ? {}
      : {
          destinationRoot: normalizeWorkspaceDestinationPath(
            destinationRoot,
            workspaceRoot,
            "destination_root",
          ),
        }),
    ...(artifactRoot === undefined
      ? {}
      : {
          artifactRoot: normalizeWorkspaceDestinationPath(
            artifactRoot,
            workspaceRoot,
            "artifact_root",
          ),
        }),
    ...(enableRepoPrompts === true ? { enableRepoPrompts: true } : {}),
  };
}

export function resolvePushDownCopilotCustomizationsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): WorkspaceToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
  };
}

export function resolveNewPotentialBugEntryToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): NewPotentialEntryToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    shortName: validateShortName(
      normalizeRequiredText(args["short_name"], "short_name"),
      "short_name",
    ),
  };
}

export function resolveNewPotentialEntryToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): NewPotentialEntryToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    shortName: validateShortName(
      normalizeRequiredText(args["short_name"], "short_name"),
      "short_name",
    ),
  };
}

export function resolveLinkParentChildToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): LinkParentChildToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    childIssueNumber: validateRequiredIssueNumber(
      normalizeRequiredText(args["child_issue_number"], "child_issue_number"),
      "child_issue_number",
    ),
    parentIssueNumber: validateRequiredIssueNumber(
      normalizeRequiredText(args["parent_issue_number"], "parent_issue_number"),
      "parent_issue_number",
    ),
  };
}

export function resolveNewActiveFeatureFolderToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): NewActiveFeatureFolderToolInput {
  const args = asToolArgumentObject(rawInput);
  const issueNumber = validateIssueNumber(
    normalizeOptionalText(args["issue_number"], "issue_number"),
  );
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    featureName: validateFeatureName(
      normalizeRequiredText(args["feature_name"], "feature_name"),
      "feature_name",
    ),
    type: resolvePromotionTypeField(args["type"], "type"),
    workMode: resolveWorkModeField(args["work_mode"], "work_mode"),
    ...(issueNumber === undefined ? {} : { issueNumber }),
  };
}

export function resolveResolveExecuteHardLockPromptToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ResolveExecuteHardLockPromptToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    target: normalizeRequiredText(args["target"], "target"),
  };
}

export function resolveResolveAtomicPlanPromptToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ResolveAtomicPlanPromptToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    target: normalizeRequiredText(args["target"], "target"),
  };
}

export function resolvePolicyAuditTemplateAssetToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ResolvePolicyAuditTemplateAssetToolInput {
  const args = asToolArgumentObject(rawInput);
  const workspaceRoot = normalizeWorkspaceRoot(
    args["workspace_root"],
    fallbackWorkspaceRoot,
  );
  const targetPath = normalizeOptionalText(args["target_path"], "target_path");

  return {
    workspaceRoot,
    asset: validatePolicyAuditTemplateAssetSelector(
      normalizeRequiredText(args["asset"], "asset"),
      "asset",
    ),
    ...(targetPath === undefined
      ? {}
      : {
          targetPath: normalizeWorkspaceDestinationPath(
            targetPath,
            workspaceRoot,
            "target_path",
          ),
        }),
  };
}

export function resolveRunPoshQCSuiteToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunPoshQCSuiteToolInput {
  const args = asToolArgumentObject(rawInput);
  const scanFolders = args["scan_folders"];
  if (scanFolders === undefined) {
    return {
      workspaceRoot: normalizeWorkspaceRoot(
        args["workspace_root"],
        fallbackWorkspaceRoot,
      ),
    };
  }

  if (!Array.isArray(scanFolders)) {
    throw new Error("Field 'scan_folders' must be an array when provided.");
  }

  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    scanFolders: scanFolders.map((folder, index) =>
      normalizeRequiredText(folder, `scan_folders[${index}]`),
    ),
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
]);

export function resolveValidateOrchestrationArtifactsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ValidateOrchestrationArtifactsToolInput {
  const args = asToolArgumentObject(rawInput);
  const artifactType = normalizeRequiredText(
    args["artifact_type"],
    "artifact_type",
  );

  if (!VALID_ARTIFACT_TYPES.has(artifactType)) {
    throw new Error(
      `Field 'artifact_type' must be one of: ${[...VALID_ARTIFACT_TYPES].join(", ")}. Got '${artifactType}'.`,
    );
  }

  const requireComplete = args["require_complete"];
  const requireModelRouting = args["require_model_routing"];
  const requireCodexModelRouting = args["require_codex_model_routing"];
  const requireCodexTopology = args["require_codex_topology"];
  const requireReadyForExecution = args["require_ready_for_execution"];

  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    artifactType,
    artifactPath: normalizeRequiredText(args["artifact_path"], "artifact_path"),
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
