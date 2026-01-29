/**
 * Maps extension command IDs to their corresponding VS Code task labels.
 *
 * This file intentionally has no dependency on the VS Code API so it can be unit-tested
 * under Jest without launching an Extension Host.
 */
export const TASK_COMMAND_MAP = {
  "drm-copilot.loadOpenAIKey": "Load OpenAI Key",
  "drm-copilot.qcBlackFormat": "QC: 1 Black: format",
  "drm-copilot.qcRuffLint": "QC: 2 Ruff: lint",
  "drm-copilot.qcRuffFix": "QC: 2 Ruff: fix",
  "drm-copilot.qcPyrightTypeCheck": "QC: 3 Pyright: type-check",
  "drm-copilot.qcPytestRunTests": "QC: 4 Pytest: run tests",
  "drm-copilot.qcPytestRunTestsCoverage":
    "QC: 4 Pytest: run tests with coverage",
  "drm-copilot.poshQCFormat": "PoshQC: 1 format",
  "drm-copilot.poshQCAnalyze": "PoshQC: 2 analyze",
  "drm-copilot.poshQCAutofix": "PoshQC: 2b autofix (PSSA -Fix)",
  "drm-copilot.poshQCTest": "PoshQC: 4 test (Pester)",
  "drm-copilot.qcRunAllChecks": "QC: 5 Run All Checks",
  "drm-copilot.qcFixAll": "QC: 0 Fix All",
  "drm-copilot.jsonFormat": "JSON: format",
  "drm-copilot.jsonValidate": "JSON: validate",
  "drm-copilot.formatChatFile": "Copilot MD: format current chat file",
  "drm-copilot.gitCollectCommitContext": "Git: Collect Commit Context",
  "drm-copilot.gitCollectPRContext": "Git: Collect Pull Request Context",
  "drm-copilot.devCopyResearchToActive": "Dev: Copy Research to Active Folder",
  "drm-copilot.devNewGitHubFeatureIssue":
    "Dev: New GitHub Feature Issue (manual)",
  "drm-copilot.devPromotePotentialToIssue":
    "Dev: 2 Promote Potential to GitHub Issue",
  "drm-copilot.devLinkFeatureDocs": "Dev: 5 Link Feature Docs to GitHub",
  "drm-copilot.devLinkParentChild": "Dev: 4 Link GitHub Parent/Child Issues",
  "drm-copilot.devCreateActiveFolder": "Dev: 3 Create Active Folder",
  "drm-copilot.devNewGitHubBugIssue": "Dev: New GitHub Bug Issue",
  "drm-copilot.devInstallPowerShellTooling": "Dev: Install PowerShell Tooling",
  "drm-copilot.devResolveExecutePlanPrompt": "Dev: Resolve Execute Plan Prompt",
  "drm-copilot.devNewPotentialBug": "Dev: 1A New Potential Bug",
  "drm-copilot.devNewPotentialEntry": "Dev: 1 New Potential Entry",
  "drm-copilot.devResolveAtomicPlanPrompt": "Dev: Resolve Atomic Plan Prompt",
  "drm-copilot.atomicExecutorExecute": "Atomic Executor: Execute (prompted)",
  "drm-copilot.devSyncAgentsFromInstructions":
    "Dev: Sync AGENTS.md from Instructions",
  "drm-copilot.npmWatch": "npm: watch",

  "drm-copilot.tsPrettierFormat": "TS: 1 Prettier: format",
  "drm-copilot.tsEslintLint": "TS: 2 ESLint: lint",
  "drm-copilot.tsTscTypeCheck": "TS: 3 TSC: type-check",
  "drm-copilot.tsJestUnitTests": "TS: 4 Jest: unit tests",
} as const satisfies Record<string, string>;

export type TaskCommandId = keyof typeof TASK_COMMAND_MAP;

/**
 * Returns the VS Code task label for a command ID, if the command is task-backed.
 */
export function getTaskLabelForCommandId(
  commandId: string,
): string | undefined {
  return TASK_COMMAND_MAP[commandId as TaskCommandId];
}

/**
 * Returns all registered task command IDs.
 */
export function getAllTaskCommandIds(): TaskCommandId[] {
  return Object.keys(TASK_COMMAND_MAP) as TaskCommandId[];
}
