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
  "drm-copilot.devPromotePotentialToIssue": {
    kind: "external",
    commandId: "drm-copilot.devPromotePotentialToIssue",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
  },
  "drm-copilot.devCreateActiveFolder": {
    kind: "external",
    commandId: "drm-copilot.devCreateActiveFolder",
    env: {
      PYTHONPATH: "${extensionRoot}",
    },
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
  "drm-copilot.devNewPotentialEntry": {
    kind: "powershell",
    commandId: "drm-copilot.devNewPotentialEntry",
    scriptPath: "${extensionRoot}/scripts/dev-tools/new-potential-entry.ps1",
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
