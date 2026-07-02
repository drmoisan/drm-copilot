import {
  getOptionalFlagValue,
  getRequiredFlagValue,
  normalizeRequiredText,
  normalizeStringArguments,
  parseWorkflowCommandArguments,
  POTENTIAL_PROMOTION_TYPES,
  type CollectPrContextInput,
  type LinkParentChildInput,
  type NewActiveFeatureFolderInput,
  type NewPotentialEntryInput,
  type PotentialToIssueInput,
  type ResolvePolicyAuditTemplateAssetInput,
  type RunPoshQCCommandInput,
  type RunPoshQCSuiteInput,
  validateChoice,
  validateFeatureName,
  validateIssueNumber,
  validatePolicyAuditTemplateAssetSelector,
  validateRequiredIssueNumber,
  validateShortName,
  WORK_MODE_OPTIONS,
  type WorkflowCommandInvocation,
} from "./workflow-command-arguments";

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
