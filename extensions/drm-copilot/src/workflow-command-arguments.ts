export interface ParsedFlagArguments {
  readonly values: ReadonlyMap<string, string>;
}

export interface InteractiveInvocation {
  readonly mode: "interactive";
}

export interface DirectInvocation {
  readonly mode: "direct";
  readonly forwardedArgs: ReadonlyArray<string>;
}

export type WorkflowCommandInvocation =
  | InteractiveInvocation
  | DirectInvocation;

const SHORT_NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const FEATURE_NAME_PATTERN = /^[a-z0-9]+(?:[-_][a-z0-9]+)*$/;
const POTENTIAL_PROMOTION_TYPES = ["epic", "feature", "refactor", "bug"];
const WORK_MODE_OPTIONS = ["minor-audit", "full-feature", "full-bug", "full"];

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

function validateShortName(shortName: string, flagName: string): string {
  if (!SHORT_NAME_PATTERN.test(shortName)) {
    throw new Error(
      `${flagName} must use kebab-case letters and numbers only (e.g., api-timeout).`,
    );
  }

  return shortName;
}

function validateChoice(
  value: string,
  flagName: string,
  allowedValues: readonly string[],
): string {
  if (!allowedValues.includes(value)) {
    const readableFlagName = flagName.replace(/^-+/, "").replace(/-/g, " ");
    throw new Error(
      `${readableFlagName} must be one of: ${allowedValues.join(", ")}.`,
    );
  }

  return value;
}

function validateFeatureName(featureName: string): string {
  if (!FEATURE_NAME_PATTERN.test(featureName)) {
    throw new Error(
      "--feature-name must use kebab-case or underscore-case letters and numbers only.",
    );
  }

  return featureName;
}

function validateIssueNumber(
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

/**
 * Resolves invocation mode and forwarded argv for `drmCopilotExtension.newPotentialEntry`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @param templateRoot The bundled template root appended only in direct mode.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode argv.
 */
export function resolveNewPotentialEntryInvocation(
  rawArgs: readonly unknown[],
  templateRoot: string,
): WorkflowCommandInvocation {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, ["-ShortName"]);
  const shortName = validateShortName(
    getRequiredFlagValue(parsedArgs, "-ShortName"),
    "-ShortName",
  );

  return {
    mode: "direct",
    forwardedArgs: ["-ShortName", shortName, "-TemplateRoot", templateRoot],
  };
}

/**
 * Resolves invocation mode and forwarded argv for `drmCopilotExtension.newPotentialBugEntry`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @param templateRoot The bundled template root appended only in direct mode.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode argv.
 */
export function resolveNewPotentialBugEntryInvocation(
  rawArgs: readonly unknown[],
  templateRoot: string,
): WorkflowCommandInvocation {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, ["--short-name"]);
  const shortName = validateShortName(
    getRequiredFlagValue(parsedArgs, "--short-name"),
    "--short-name",
  );

  return {
    mode: "direct",
    forwardedArgs: ["--short-name", shortName, "--template-root", templateRoot],
  };
}

/**
 * Resolves invocation mode and forwarded argv for `drmCopilotExtension.potentialToIssue`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode argv.
 */
export function resolvePotentialToIssueInvocation(
  rawArgs: readonly unknown[],
): WorkflowCommandInvocation {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, [
    "--potential-path",
    "--promotion-type",
    "--work-mode",
  ]);
  const potentialPath = getRequiredFlagValue(parsedArgs, "--potential-path");
  const promotionType = validateChoice(
    getRequiredFlagValue(parsedArgs, "--promotion-type"),
    "--promotion-type",
    POTENTIAL_PROMOTION_TYPES,
  );
  const workMode = validateChoice(
    getRequiredFlagValue(parsedArgs, "--work-mode"),
    "--work-mode",
    WORK_MODE_OPTIONS,
  );

  return {
    mode: "direct",
    forwardedArgs: [
      "--potential-path",
      potentialPath,
      "--promotion-type",
      promotionType,
      "--work-mode",
      workMode,
    ],
  };
}

/**
 * Resolves invocation mode and forwarded argv for `drmCopilotExtension.newActiveFeatureFolder`.
 *
 * @param rawArgs The raw command arguments supplied by VS Code.
 * @param templateRoot The bundled template root appended only in direct mode.
 * @returns Interactive mode when no args are supplied, otherwise validated direct-mode argv.
 */
export function resolveNewActiveFeatureFolderInvocation(
  rawArgs: readonly unknown[],
  templateRoot: string,
): WorkflowCommandInvocation {
  if (rawArgs.length === 0) {
    return { mode: "interactive" };
  }

  const parsedArgs = parseWorkflowCommandArguments(rawArgs, [
    "--feature-name",
    "--type",
    "--issue-number",
    "--work-mode",
  ]);
  const featureName = validateFeatureName(
    getRequiredFlagValue(parsedArgs, "--feature-name"),
  );
  const featureType = validateChoice(
    getRequiredFlagValue(parsedArgs, "--type"),
    "--type",
    POTENTIAL_PROMOTION_TYPES,
  );
  const issueNumber = validateIssueNumber(
    getOptionalFlagValue(parsedArgs, "--issue-number"),
  );
  const workMode = validateChoice(
    getRequiredFlagValue(parsedArgs, "--work-mode"),
    "--work-mode",
    WORK_MODE_OPTIONS,
  );

  const forwardedArgs = ["--feature-name", featureName, "--type", featureType];
  if (issueNumber !== undefined) {
    forwardedArgs.push("--issue-number", issueNumber);
  }

  forwardedArgs.push("--work-mode", workMode, "--template-root", templateRoot);

  return {
    mode: "direct",
    forwardedArgs,
  };
}
