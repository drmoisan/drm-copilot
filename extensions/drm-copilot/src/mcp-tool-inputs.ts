import {
  normalizeOptionalText,
  normalizeRequiredText,
  normalizeWorkspaceRoot,
  type NewActiveFeatureFolderInput,
  type NewPotentialEntryInput,
  type PotentialPromotionType,
  type PotentialToIssueInput,
  type WorkModeOption,
  validateFeatureName,
  validateIssueNumber,
  validatePromotionType,
  validateShortName,
  validateWorkMode,
} from "./workflow-command-arguments";

export interface WorkspaceToolInput {
  readonly workspaceRoot: string;
}

export interface CollectPrContextToolInput extends WorkspaceToolInput {
  readonly base: string;
}

export interface NewPotentialEntryToolInput
  extends WorkspaceToolInput, NewPotentialEntryInput {}

export interface PotentialToIssueToolInput
  extends WorkspaceToolInput, PotentialToIssueInput {}

export interface NewActiveFeatureFolderToolInput
  extends WorkspaceToolInput, NewActiveFeatureFolderInput {}

export interface ResolveExecuteHardLockPromptToolInput extends WorkspaceToolInput {
  readonly target: string;
}

function asToolArgumentObject(
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

export function resolvePotentialToIssueToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): PotentialToIssueToolInput {
  const args = asToolArgumentObject(rawInput);
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    potentialPath: normalizeRequiredText(
      args["potential_path"],
      "potential_path",
    ),
    promotionType: resolvePromotionTypeField(
      args["promotion_type"],
      "promotion_type",
    ),
    workMode: resolveWorkModeField(args["work_mode"], "work_mode"),
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
