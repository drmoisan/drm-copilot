import {
  getTaskInputIdsForCommand,
  type TaskCommandId,
} from "../task-command-map";

export type UtilityKind = "external" | "powershell";

export type ExternalUtilitySpec = {
  kind: "external";
  commandId: TaskCommandId;
  env: Record<string, string>;
};

export type PowerShellUtilitySpec = {
  kind: "powershell";
  commandId: TaskCommandId;
  scriptPath: string;
};

export type UtilitySpec = ExternalUtilitySpec | PowerShellUtilitySpec;

export const UTILITY_COMMAND_SPECS: Partial<
  Record<TaskCommandId, UtilitySpec>
> = {
  "drm-copilot.loadOpenAIKey": {
    kind: "powershell",
    commandId: "drm-copilot.loadOpenAIKey",
    scriptPath: "${extensionRoot}/scripts/dev-tools/load-openai-key.ps1",
  },
  "drm-copilot.qcBlackFormat": {
    kind: "external",
    commandId: "drm-copilot.qcBlackFormat",
    env: {},
  },
  "drm-copilot.qcRuffLint": {
    kind: "external",
    commandId: "drm-copilot.qcRuffLint",
    env: {},
  },
  "drm-copilot.qcRuffFix": {
    kind: "external",
    commandId: "drm-copilot.qcRuffFix",
    env: {},
  },
  "drm-copilot.qcPyrightTypeCheck": {
    kind: "external",
    commandId: "drm-copilot.qcPyrightTypeCheck",
    env: {},
  },
  "drm-copilot.qcPytestRunTests": {
    kind: "external",
    commandId: "drm-copilot.qcPytestRunTests",
    env: {},
  },
  "drm-copilot.qcPytestRunTestsCoverage": {
    kind: "external",
    commandId: "drm-copilot.qcPytestRunTestsCoverage",
    env: {},
  },
  "drm-copilot.poshQCFormat": {
    kind: "powershell",
    commandId: "drm-copilot.poshQCFormat",
    scriptPath: "${extensionRoot}/scripts/powershell/PoshQC/PoshQC.psm1",
  },
  "drm-copilot.poshQCAnalyze": {
    kind: "powershell",
    commandId: "drm-copilot.poshQCAnalyze",
    scriptPath: "${extensionRoot}/scripts/powershell/PoshQC/PoshQC.psm1",
  },
  "drm-copilot.poshQCAutofix": {
    kind: "powershell",
    commandId: "drm-copilot.poshQCAutofix",
    scriptPath: "${extensionRoot}/scripts/powershell/PoshQC/PoshQC.psm1",
  },
  "drm-copilot.poshQCTest": {
    kind: "powershell",
    commandId: "drm-copilot.poshQCTest",
    scriptPath: "${extensionRoot}/scripts/powershell/PoshQC/PoshQC.psm1",
  },
  "drm-copilot.qcRunAllChecks": {
    kind: "external",
    commandId: "drm-copilot.qcRunAllChecks",
    env: {},
  },
  "drm-copilot.qcFixAll": {
    kind: "external",
    commandId: "drm-copilot.qcFixAll",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.jsonFormat": {
    kind: "external",
    commandId: "drm-copilot.jsonFormat",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.jsonValidate": {
    kind: "external",
    commandId: "drm-copilot.jsonValidate",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.formatChatFile": {
    kind: "external",
    commandId: "drm-copilot.formatChatFile",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.gitCollectCommitContext": {
    kind: "external",
    commandId: "drm-copilot.gitCollectCommitContext",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.gitCollectPRContext": {
    kind: "external",
    commandId: "drm-copilot.gitCollectPRContext",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devCopyResearchToActive": {
    kind: "external",
    commandId: "drm-copilot.devCopyResearchToActive",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devNewGitHubFeatureIssue": {
    kind: "external",
    commandId: "drm-copilot.devNewGitHubFeatureIssue",
    env: {},
  },
  "drm-copilot.devPromotePotentialToIssue": {
    kind: "external",
    commandId: "drm-copilot.devPromotePotentialToIssue",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devLinkFeatureDocs": {
    kind: "powershell",
    commandId: "drm-copilot.devLinkFeatureDocs",
    scriptPath: "${extensionRoot}/scripts/dev-tools/link-feature-docs.ps1",
  },
  "drm-copilot.devLinkParentChild": {
    kind: "powershell",
    commandId: "drm-copilot.devLinkParentChild",
    scriptPath: "${extensionRoot}/scripts/dev-tools/link-parent-child.ps1",
  },
  "drm-copilot.devCreateActiveFolder": {
    kind: "external",
    commandId: "drm-copilot.devCreateActiveFolder",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devNewGitHubBugIssue": {
    kind: "external",
    commandId: "drm-copilot.devNewGitHubBugIssue",
    env: {},
  },
  "drm-copilot.devInstallPowerShellTooling": {
    kind: "powershell",
    commandId: "drm-copilot.devInstallPowerShellTooling",
    scriptPath: "${extensionRoot}/scripts/powershell/PoshQC/PoshQC.psm1",
  },
  "drm-copilot.devResolveExecutePlanPrompt": {
    kind: "external",
    commandId: "drm-copilot.devResolveExecutePlanPrompt",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devNewPotentialBug": {
    kind: "external",
    commandId: "drm-copilot.devNewPotentialBug",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devNewPotentialEntry": {
    kind: "powershell",
    commandId: "drm-copilot.devNewPotentialEntry",
    scriptPath: "${extensionRoot}/scripts/dev-tools/new-potential-entry.ps1",
  },
  "drm-copilot.devResolveAtomicPlanPrompt": {
    kind: "external",
    commandId: "drm-copilot.devResolveAtomicPlanPrompt",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.atomicExecutorExecute": {
    kind: "external",
    commandId: "drm-copilot.atomicExecutorExecute",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devSyncAgentsFromInstructions": {
    kind: "powershell",
    commandId: "drm-copilot.devSyncAgentsFromInstructions",
    scriptPath:
      "${extensionRoot}/scripts/dev-tools/sync-agents-from-instructions.ps1",
  },
  "drm-copilot.npmWatch": {
    kind: "external",
    commandId: "drm-copilot.npmWatch",
    env: {},
  },
  "drm-copilot.tsPrettierFormat": {
    kind: "external",
    commandId: "drm-copilot.tsPrettierFormat",
    env: {},
  },
  "drm-copilot.tsEslintLint": {
    kind: "external",
    commandId: "drm-copilot.tsEslintLint",
    env: {},
  },
  "drm-copilot.tsTscTypeCheck": {
    kind: "external",
    commandId: "drm-copilot.tsTscTypeCheck",
    env: {},
  },
  "drm-copilot.tsJestUnitTests": {
    kind: "external",
    commandId: "drm-copilot.tsJestUnitTests",
    env: {},
  },
} as const;

/**
 * Returns the utility spec for a known command.
 */
export function getUtilitySpec(commandId: TaskCommandId): UtilitySpec {
  const spec = UTILITY_COMMAND_SPECS[commandId];
  if (!spec) {
    throw new Error(`Unknown utility command ID: ${commandId}`);
  }
  return spec;
}

/**
 * Returns the task input IDs required to run the utility.
 */
export function getRequiredInputIds(commandId: TaskCommandId): string[] {
  return getTaskInputIdsForCommand(commandId);
}
