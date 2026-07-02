import * as path from "node:path";

export interface ParsedFlagArguments {
  readonly values: ReadonlyMap<string, string>;
}

export interface InteractiveInvocation {
  readonly mode: "interactive";
}

export interface DirectInvocation<TInput> {
  readonly mode: "direct";
  readonly input: TInput;
}

export type WorkflowCommandInvocation<TInput> =
  InteractiveInvocation | DirectInvocation<TInput>;

export const SHORT_NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;
export const FEATURE_NAME_PATTERN = /^[a-z0-9]+(?:[-_][a-z0-9]+)*$/;
export const POTENTIAL_PROMOTION_TYPES = [
  "epic",
  "feature",
  "refactor",
  "bug",
] as const;
export const WORK_MODE_OPTIONS = [
  "minor-audit",
  "full-feature",
  "full-bug",
  "full",
] as const;
export const POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS = [
  "template",
  "agents",
  "code-review-template",
  "feature-audit-template",
] as const;

export type PotentialPromotionType = (typeof POTENTIAL_PROMOTION_TYPES)[number];
export type WorkModeOption = (typeof WORK_MODE_OPTIONS)[number];
export type PolicyAuditTemplateAssetSelector =
  (typeof POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS)[number];

export interface CollectPrContextInput {
  readonly base: string;
}

export interface NewPotentialEntryInput {
  readonly shortName: string;
}

export interface LinkParentChildInput {
  readonly childIssueNumber: string;
  readonly parentIssueNumber: string;
}

export interface PotentialToIssueInput {
  readonly potentialPath: string;
  readonly promotionType: PotentialPromotionType;
  readonly workMode: WorkModeOption;
}

export interface NewActiveFeatureFolderInput {
  readonly featureName: string;
  readonly type: PotentialPromotionType;
  readonly issueNumber?: string;
  readonly workMode: WorkModeOption;
}

export interface RunPoshQCSuiteInput {
  readonly scanFolders?: ReadonlyArray<string>;
}

export type RunPoshQCCommandInput = RunPoshQCSuiteInput;

export interface ResolvePolicyAuditTemplateAssetInput {
  readonly asset: PolicyAuditTemplateAssetSelector;
  readonly targetPath?: string;
}

function formatAllowedFlags(allowedFlags: ReadonlySet<string>): string {
  return [...allowedFlags].join(", ");
}

function normalizeStringArguments(
  rawArgs: readonly unknown[],
): readonly string[] {
  const candidateArgs =
    rawArgs.length === 1 && Array.isArray(rawArgs[0]) ? rawArgs[0] : rawArgs;

  return candidateArgs.map((arg, index) => {
    if (typeof arg !== "string") {
      throw new Error(
        `Workflow command arguments must be strings. Argument ${index + 1} has type ${typeof arg}.`,
      );
    }

    return arg;
  });
}

export function normalizeRequiredText(
  value: unknown,
  fieldName: string,
): string {
  if (typeof value !== "string") {
    throw new Error(`Field '${fieldName}' must be a string.`);
  }

  const trimmed = value.trim();
  if (trimmed.length === 0) {
    throw new Error(`Field '${fieldName}' is required.`);
  }

  return trimmed;
}

export function normalizeOptionalText(
  value: unknown,
  fieldName: string,
): string | undefined {
  if (value === undefined) {
    return undefined;
  }

  return normalizeRequiredText(value, fieldName);
}

function validateChoice<TChoice extends string>(
  value: string,
  fieldName: string,
  allowedValues: readonly TChoice[],
): TChoice {
  const matchedChoice = allowedValues.find(
    (allowedValue) => allowedValue === value,
  );
  if (matchedChoice === undefined) {
    const readableFieldName = fieldName
      .replace(/^-+/, "")
      .replace(/_/g, " ")
      .replace(/-/g, " ");
    throw new Error(
      `${readableFieldName} must be one of: ${allowedValues.join(", ")}.`,
    );
  }

  return matchedChoice;
}

export function validatePromotionType(
  value: string,
  fieldName: string,
): PotentialPromotionType {
  return validateChoice(value, fieldName, POTENTIAL_PROMOTION_TYPES);
}

export function validateWorkMode(
  value: string,
  fieldName: string,
): WorkModeOption {
  return validateChoice(value, fieldName, WORK_MODE_OPTIONS);
}

export function validatePolicyAuditTemplateAssetSelector(
  value: string,
  fieldName: string,
): PolicyAuditTemplateAssetSelector {
  return validateChoice(
    value,
    fieldName,
    POLICY_AUDIT_TEMPLATE_ASSET_SELECTORS,
  );
}

export function validateShortName(
  shortName: string,
  fieldName: string,
): string {
  if (!SHORT_NAME_PATTERN.test(shortName)) {
    throw new Error(
      `${fieldName} must use kebab-case letters and numbers only (e.g., api-timeout).`,
    );
  }

  return shortName;
}

export function validateFeatureName(
  featureName: string,
  fieldName: string = "--feature-name",
): string {
  if (!FEATURE_NAME_PATTERN.test(featureName)) {
    throw new Error(
      `${fieldName} must use kebab-case or underscore-case letters and numbers only.`,
    );
  }

  return featureName;
}

export function validateIssueNumber(
  issueNumber: string | undefined,
): string | undefined {
  if (issueNumber === undefined) {
    return undefined;
  }

  if (!/^\d+$/.test(issueNumber)) {
    throw new Error("Issue number must be digits only when provided.");
  }

  return issueNumber;
}

export function validateRequiredIssueNumber(
  issueNumber: string,
  fieldName: string,
): string {
  const normalizedIssueNumber = normalizeRequiredText(issueNumber, fieldName);
  if (!/^\d+$/.test(normalizedIssueNumber)) {
    throw new Error(`${fieldName} must be digits only.`);
  }

  return normalizedIssueNumber;
}

export function getShortNameValidationMessage(
  value: string,
  fieldName: string,
): string | undefined {
  const trimmed = value.trim();
  if (trimmed.length === 0) {
    return "Short name is required.";
  }

  try {
    validateShortName(trimmed, fieldName);
    return undefined;
  } catch (error: unknown) {
    return error instanceof Error ? error.message : String(error);
  }
}

export function getRequiredIssueNumberValidationMessage(
  value: string,
  fieldName: string,
): string | undefined {
  const trimmed = value.trim();
  if (trimmed.length === 0) {
    return `${fieldName} is required.`;
  }

  return /^\d+$/.test(trimmed)
    ? undefined
    : `${fieldName} must be digits only.`;
}

export function getFeatureNameValidationMessage(
  value: string,
): string | undefined {
  const trimmed = value.trim();
  if (trimmed.length === 0) {
    return "Feature name is required.";
  }

  try {
    validateFeatureName(trimmed, "Feature name");
    return undefined;
  } catch (error: unknown) {
    return error instanceof Error ? error.message : String(error);
  }
}

export function normalizeWorkspaceRoot(
  value: unknown,
  fallbackWorkspaceRoot: string = process.cwd(),
): string {
  if (value === undefined) {
    return fallbackWorkspaceRoot;
  }

  return normalizeRequiredText(value, "workspace_root");
}

export function isAbsolutePathLike(filePath: string): boolean {
  return /^(?:[a-zA-Z]:[\\/]|\\\\|\/)/.test(filePath);
}

export function normalizeWorkspaceDestinationPath(
  value: string,
  workspaceRoot: string,
  fieldName: string,
): string {
  const targetPath = normalizeRequiredText(value, fieldName);
  const resolvedPath = isAbsolutePathLike(targetPath)
    ? targetPath
    : path.join(workspaceRoot, targetPath);
  return resolvedPath.replace(/\\/g, "/");
}

/**
 * Parses a CLI-style flag array for the extension workflow commands.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @param allowedFlags The exact set of flags accepted for the target workflow.
 * @returns The validated flag-value map for the supplied arguments.
 * @throws Error when an argument is not a string, a flag is unknown or duplicated,
 * a flag is missing a value, or a value appears without a preceding flag.
 */
export function parseWorkflowCommandArguments(
  rawArgs: readonly unknown[],
  allowedFlags: readonly string[],
): ParsedFlagArguments {
  const stringArgs = normalizeStringArguments(rawArgs);
  const allowedFlagSet = new Set(allowedFlags);
  const values = new Map<string, string>();

  for (let index = 0; index < stringArgs.length; index += 2) {
    const flag = stringArgs[index];
    if (flag === undefined) {
      break;
    }

    if (!flag.startsWith("-")) {
      throw new Error(
        `Unexpected value '${flag}' without a preceding flag. Accepted flags: ${formatAllowedFlags(allowedFlagSet)}.`,
      );
    }

    if (!allowedFlagSet.has(flag)) {
      throw new Error(
        `Unknown flag '${flag}'. Accepted flags: ${formatAllowedFlags(allowedFlagSet)}.`,
      );
    }

    if (values.has(flag)) {
      throw new Error(`Duplicate flag '${flag}' is not allowed.`);
    }

    const value = stringArgs[index + 1];
    if (value === undefined || value.startsWith("-")) {
      throw new Error(`Flag '${flag}' requires a value.`);
    }

    values.set(flag, value);
  }

  return { values };
}

/**
 * Looks up an optional parsed flag value.
 *
 * @param parsedArgs The parsed flag map returned by {@link parseWorkflowCommandArguments}.
 * @param flag The flag to read.
 * @returns The parsed value when present; otherwise `undefined`.
 */
export function getOptionalFlagValue(
  parsedArgs: ParsedFlagArguments,
  flag: string,
): string | undefined {
  return parsedArgs.values.get(flag);
}

/**
 * Looks up a required parsed flag value.
 *
 * @param parsedArgs The parsed flag map returned by {@link parseWorkflowCommandArguments}.
 * @param flag The flag that must be present.
 * @returns The parsed value associated with the flag.
 * @throws Error when the required flag is missing.
 */
export function getRequiredFlagValue(
  parsedArgs: ParsedFlagArguments,
  flag: string,
): string {
  const value = parsedArgs.values.get(flag);
  if (value === undefined) {
    throw new Error(`Missing required flag '${flag}'.`);
  }

  return value;
}

export function resolveCollectPrContextInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<CollectPrContextInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, ["--base"]);
  return {
    mode: "direct",
    input: {
      base: normalizeRequiredText(
        getRequiredFlagValue(parsedArgs, "--base"),
        "--base",
      ),
    },
  };
}

/**
 * Resolves invocation mode for `drmCopilotExtension.newPotentialEntry`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode input.
 */
export function resolveNewPotentialEntryInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<NewPotentialEntryInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, ["-ShortName"]);
  return {
    mode: "direct",
    input: {
      shortName: validateShortName(
        getRequiredFlagValue(parsedArgs, "-ShortName"),
        "-ShortName",
      ),
    },
  };
}

/**
 * Resolves invocation mode for `drmCopilotExtension.newPotentialBugEntry`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode input.
 */
export function resolveNewPotentialBugEntryInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<NewPotentialEntryInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, ["--short-name"]);
  return {
    mode: "direct",
    input: {
      shortName: validateShortName(
        getRequiredFlagValue(parsedArgs, "--short-name"),
        "--short-name",
      ),
    },
  };
}

/**
 * Resolves invocation mode for `drmCopilotExtension.linkParentChild`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode input.
 */
export function resolveLinkParentChildInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<LinkParentChildInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, [
    "-ChildIssueNumber",
    "-ParentIssueNumber",
  ]);
  return {
    mode: "direct",
    input: {
      childIssueNumber: validateRequiredIssueNumber(
        getRequiredFlagValue(parsedArgs, "-ChildIssueNumber"),
        "-ChildIssueNumber",
      ),
      parentIssueNumber: validateRequiredIssueNumber(
        getRequiredFlagValue(parsedArgs, "-ParentIssueNumber"),
        "-ParentIssueNumber",
      ),
    },
  };
}

/**
 * Resolves invocation mode for `drmCopilotExtension.potentialToIssue`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode input.
 */
export function resolvePotentialToIssueInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<PotentialToIssueInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, [
    "--potential-path",
    "--promotion-type",
    "--work-mode",
  ]);
  return {
    mode: "direct",
    input: {
      potentialPath: normalizeRequiredText(
        getRequiredFlagValue(parsedArgs, "--potential-path"),
        "--potential-path",
      ),
      promotionType: validateChoice(
        getRequiredFlagValue(parsedArgs, "--promotion-type"),
        "--promotion-type",
        POTENTIAL_PROMOTION_TYPES,
      ),
      workMode: validateChoice(
        getRequiredFlagValue(parsedArgs, "--work-mode"),
        "--work-mode",
        WORK_MODE_OPTIONS,
      ),
    },
  };
}

/**
 * Resolves invocation mode for `drmCopilotExtension.newActiveFeatureFolder`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode input.
 */
export function resolveNewActiveFeatureFolderInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<NewActiveFeatureFolderInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, [
    "--feature-name",
    "--type",
    "--issue-number",
    "--work-mode",
  ]);
  const issueNumber = validateIssueNumber(
    getOptionalFlagValue(parsedArgs, "--issue-number"),
  );
  return {
    mode: "direct",
    input: {
      featureName: validateFeatureName(
        getRequiredFlagValue(parsedArgs, "--feature-name"),
        "--feature-name",
      ),
      type: validateChoice(
        getRequiredFlagValue(parsedArgs, "--type"),
        "--type",
        POTENTIAL_PROMOTION_TYPES,
      ),
      workMode: validateChoice(
        getRequiredFlagValue(parsedArgs, "--work-mode"),
        "--work-mode",
        WORK_MODE_OPTIONS,
      ),
      ...(issueNumber === undefined ? {} : { issueNumber }),
    },
  };
}

/**
 * Resolves invocation mode for `drmCopilotExtension.runPoshQCSuite`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode input.
 */
export function resolveRunPoshQCSuiteInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<RunPoshQCSuiteInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const stringArgs = normalizeStringArguments(rawArgs);
  const scanFolders: string[] = [];

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

    scanFolders.push(normalizeRequiredText(value, "--scan-folder"));
  }

  return {
    mode: "direct",
    input: {
      ...(scanFolders.length === 0 ? {} : { scanFolders }),
    },
  };
}

export function resolveRunPoshQCFormatInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<RunPoshQCCommandInput> {
  return resolveRunPoshQCSuiteInvocation(rawArgs);
}

export function resolveRunPoshQCAnalyzeInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<RunPoshQCCommandInput> {
  return resolveRunPoshQCSuiteInvocation(rawArgs);
}

export function resolveRunPoshQCTestInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<RunPoshQCCommandInput> {
  return resolveRunPoshQCSuiteInvocation(rawArgs);
}

export function resolveRunPoshQCAnalyzeAutofixInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<RunPoshQCCommandInput> {
  return resolveRunPoshQCSuiteInvocation(rawArgs);
}

export function resolvePolicyAuditTemplateAssetInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation<ResolvePolicyAuditTemplateAssetInput> {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, [
    "-asset",
    "-target",
  ]);
  const asset = validatePolicyAuditTemplateAssetSelector(
    getRequiredFlagValue(parsedArgs, "-asset"),
    "-asset",
  );
  const targetPath = getOptionalFlagValue(parsedArgs, "-target");

  return {
    mode: "direct",
    input: {
      asset,
      ...(targetPath === undefined
        ? {}
        : { targetPath: normalizeRequiredText(targetPath, "-target") }),
    },
  };
}
