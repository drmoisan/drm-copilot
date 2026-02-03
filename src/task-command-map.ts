/**
 * Maps extension command IDs to their corresponding VS Code task labels.
 *
 * This file intentionally has no dependency on the VS Code API so it can be unit-tested
 * under Jest without launching an Extension Host.
 */

export type TaskExecutionSpec = {
  command: string;
  args: string[];
};

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

export const TASK_EXECUTION_MAP = {
  "drm-copilot.loadOpenAIKey": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "${extensionRoot}/scripts/dev-tools/load-openai-key.ps1",
      "-ItemName",
      "Lexile OpenAI Key",
    ],
  },
  "drm-copilot.qcBlackFormat": {
    command: "poetry",
    args: ["run", "black", "."],
  },
  "drm-copilot.qcRuffLint": {
    command: "poetry",
    args: ["run", "ruff", "check"],
  },
  "drm-copilot.qcRuffFix": {
    command: "poetry",
    args: ["run", "ruff", "check", "--fix"],
  },
  "drm-copilot.qcPyrightTypeCheck": {
    command: "poetry",
    args: ["run", "pyright"],
  },
  "drm-copilot.qcPytestRunTests": {
    command: "poetry",
    args: ["run", "pytest"],
  },
  "drm-copilot.qcPytestRunTestsCoverage": {
    command: "poetry",
    args: [
      "run",
      "pytest",
      "--cov=src/lexile_corpus_tuner",
      "--cov=scripts/dev_tools",
      "--cov-report=term-missing",
    ],
  },
  "drm-copilot.poshQCFormat": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      "& { Import-Module '${extensionRoot}/scripts/powershell/PoshQC'; Invoke-PoshQCFormat -Root '${workspaceFolder}' }",
    ],
  },
  "drm-copilot.poshQCAnalyze": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      "& { Import-Module '${extensionRoot}/scripts/powershell/PoshQC'; Invoke-PoshQCAnalyze -Root '${workspaceFolder}' }",
    ],
  },
  "drm-copilot.poshQCAutofix": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      "& { Import-Module '${extensionRoot}/scripts/powershell/PoshQC'; $files = Get-ChildItem -Path '${workspaceFolder}' -Recurse -Include *.ps1, *.psm1 -File; if ($files) { foreach ($f in $files) { Invoke-ScriptAnalyzer -Path $f.FullName -Settings '${extensionRoot}/scripts/powershell/PoshQC/settings/pssa.settings.psd1' -Severity Error,Warning,Information -Fix } } else { Write-Host 'No PowerShell files found under workspace.' } }",
    ],
  },
  "drm-copilot.poshQCTest": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      "& { Import-Module '${extensionRoot}/scripts/powershell/PoshQC'; Invoke-PoshQCTest -Root '${workspaceFolder}' }",
    ],
  },
  "drm-copilot.qcRunAllChecks": {
    command: "echo",
    args: [
      "QC: Run All Checks is a composite task and should not be executed directly",
    ],
  },
  "drm-copilot.qcFixAll": {
    command: "poetry",
    args: ["run", "python", "-m", "scripts.dev_tools.fix_all"],
  },
  "drm-copilot.jsonFormat": {
    command: "poetry",
    args: ["run", "python", "-m", "scripts.dev_tools.format_json"],
  },
  "drm-copilot.jsonValidate": {
    command: "poetry",
    args: ["run", "python", "-m", "scripts.dev_tools.validate_json"],
  },
  "drm-copilot.formatChatFile": {
    command: "poetry",
    args: [
      "run",
      "python",
      "-m",
      "scripts.dev_tools.markdown_label_formatter",
      "${relativeFile}",
      "--output",
      "${relativeFile}",
    ],
  },
  "drm-copilot.gitCollectCommitContext": {
    command: "poetry",
    args: [
      "run",
      "python",
      "-m",
      "scripts.dev_tools.collect_commit_context",
      "--output",
      "${workspaceFolder}/artifacts/commit_context.txt",
    ],
  },
  "drm-copilot.gitCollectPRContext": {
    command: "poetry",
    args: [
      "run",
      "python",
      "-m",
      "scripts.dev_tools.pr_context.collector",
      "--base",
      "${input:PRBaseBranch}",
    ],
  },
  "drm-copilot.devCopyResearchToActive": {
    command: "poetry",
    args: ["run", "python", "-m", "scripts.dev_tools.copy_research_to_issue"],
  },
  "drm-copilot.devNewGitHubFeatureIssue": {
    command: "gh",
    args: ["issue", "create", "--template", "feature-request.md", "--web"],
  },
  "drm-copilot.devPromotePotentialToIssue": {
    command: "poetry",
    args: [
      "run",
      "python",
      "-m",
      "scripts.dev_tools.potential_to_issue",
      "--potential-path",
      "${relativeFile}",
      "--promotion-type",
      "${input:PotentialPromotionType}",
    ],
  },
  "drm-copilot.devLinkFeatureDocs": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "${extensionRoot}/scripts/dev-tools/link-feature-docs.ps1",
      "-IssueNumber",
      "${input:LinkIssueNumber}",
      "-FeatureName",
      "${input:LinkFeatureName}",
    ],
  },
  "drm-copilot.devLinkParentChild": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "${extensionRoot}/scripts/dev-tools/link-parent-child.ps1",
      "-ChildIssueNumber",
      "${input:ChildIssueNumber}",
      "-ParentIssueNumber",
      "${input:ParentIssueNumber}",
    ],
  },
  "drm-copilot.devCreateActiveFolder": {
    command: "poetry",
    args: [
      "run",
      "python",
      "-m",
      "scripts.dev_tools.new_active_feature_folder",
      "--feature-name",
      "${input:ActiveFeatureName}",
      "--type",
      "${input:ActiveWorkType}",
      "--issue-number",
      "${input:ActiveIssueNumber}",
    ],
  },
  "drm-copilot.devNewGitHubBugIssue": {
    command: "gh",
    args: ["issue", "create", "--template", "bug-report.md", "--web"],
  },
  "drm-copilot.devInstallPowerShellTooling": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      "& { Import-Module '${extensionRoot}/scripts/powershell/PoshQC'; Install-PoshQCTools }",
    ],
  },
  "drm-copilot.devResolveExecutePlanPrompt": {
    command: "poetry",
    args: [
      "run",
      "python",
      "${extensionRoot}/scripts/dev_tools/resolve_execute_plan_prompt.py",
      "--feature",
      "${file}",
      "--agent",
      "${input:ExecutePlanAgent}",
    ],
  },
  "drm-copilot.devNewPotentialBug": {
    command: "poetry",
    args: [
      "run",
      "python",
      "${extensionRoot}/scripts/dev_tools/new_potential_bug_entry.py",
      "--short-name",
      "${input:PotentialBugShortName}",
    ],
  },
  "drm-copilot.devNewPotentialEntry": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "${extensionRoot}/scripts/dev-tools/new-potential-entry.ps1",
      "-ShortName",
      "${input:PotentialShortName}",
    ],
  },
  "drm-copilot.devResolveAtomicPlanPrompt": {
    command: "poetry",
    args: [
      "run",
      "python",
      "scripts/dev_tools/resolve_file_prompt.py",
      "--template",
      "${extensionRoot}/.github/prompts/generate-atomic-plan.prompt.md",
      "--target",
      "${file}",
    ],
  },
  "drm-copilot.atomicExecutorExecute": {
    command: "poetry",
    args: [
      "run",
      "python",
      "-m",
      "scripts.dev_tools.atomic_executor.cli",
      "execute-all",
      "${input:AtomicFeaturePath}",
      "--workspace",
      "${workspaceFolder}",
      "--preferred-model",
      "${input:AtomicPreferredModel}",
      "--max-fix-attempts",
      "10",
    ],
  },
  "drm-copilot.devSyncAgentsFromInstructions": {
    command: "pwsh",
    args: [
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "${extensionRoot}/scripts/dev-tools/sync-agents-from-instructions.ps1",
    ],
  },
  "drm-copilot.npmWatch": {
    command: "npm",
    args: ["run", "watch"],
  },
  "drm-copilot.tsPrettierFormat": {
    command: "npm",
    args: ["run", "format"],
  },
  "drm-copilot.tsEslintLint": {
    command: "npm",
    args: ["run", "lint"],
  },
  "drm-copilot.tsTscTypeCheck": {
    command: "npm",
    args: ["run", "typecheck"],
  },
  "drm-copilot.tsJestUnitTests": {
    command: "npm",
    args: ["run", "test:unit"],
  },
} as const satisfies Record<TaskCommandId, TaskExecutionSpec>;

export type TaskInputDefinition = {
  id: string;
  type: "promptString" | "pickString";
  description: string;
  default: string;
  options?: string[];
};

export const TASK_INPUT_DEFINITIONS: TaskInputDefinition[] = [
  {
    id: "PRBaseBranch",
    type: "promptString",
    description: "Base branch for PR comparison (e.g., development, main)",
    default: "development",
  },
  {
    id: "PotentialShortName",
    type: "promptString",
    description: "Short name (kebab-case, e.g., notes-feature)",
    default: "notes-feature",
  },
  {
    id: "PotentialBugShortName",
    type: "promptString",
    description: "Short name (kebab-case, e.g., api-timeout-bug)",
    default: "api-timeout-bug",
  },
  {
    id: "PotentialPromotionType",
    type: "pickString",
    description: "Promotion type / label to apply",
    default: "feature",
    options: ["epic", "feature", "refactor", "bug"],
  },
  {
    id: "ActiveFeatureName",
    type: "promptString",
    description:
      "Feature folder name (kebab/underscore-case, e.g., notes_feature)",
    default: "new_feature",
  },
  {
    id: "ExecutePlanFeatureFolder",
    type: "promptString",
    description:
      "Feature folder under docs/features/active (leave blank to auto-detect)",
    default: "",
  },
  {
    id: "ActiveWorkType",
    type: "pickString",
    description: "Template type",
    default: "feature",
    options: ["feature", "refactor", "epic", "bug"],
  },
  {
    id: "ActiveIssueNumber",
    type: "promptString",
    description: "Issue number (optional, e.g., 14)",
    default: "auto",
  },
  {
    id: "LinkIssueNumber",
    type: "promptString",
    description: "Issue number to update (e.g., 14)",
    default: "",
  },
  {
    id: "LinkFeatureName",
    type: "promptString",
    description: "Feature folder name (e.g., new_feature)",
    default: "new_feature",
  },
  {
    id: "ChildIssueNumber",
    type: "promptString",
    description: "Child issue number to link (e.g., 15)",
    default: "",
  },
  {
    id: "ParentIssueNumber",
    type: "promptString",
    description: "Parent tracking issue number (e.g., 10)",
    default: "10",
  },
  {
    id: "ExecutePlanAgent",
    type: "pickString",
    description: "Agent personality to inject into the template",
    default: "Python Engineer (Strongly Typed, Testable, Pytest-First)",
    options: [
      "Python Engineer (Strongly Typed, Testable, Pytest-First)",
      "Python Execution Only",
      "atomic_executor",
    ],
  },
  {
    id: "AtomicPreferredModel",
    type: "pickString",
    description: "Preferred model passed to --preferred-model",
    default: "gpt-5.2",
    options: [
      "Claude Sonnet 4.5",
      "Claude Haiku 4.5",
      "Claude Opus 4.5",
      "Claude Sonnet 4",
      "GPT-5.2-Codex",
      "GPT-5.1-Codex-Max",
      "GPT-5.1-Codex",
      "GPT-5.2",
      "GPT-5.1",
      "GPT-5",
      "GPT-5.1-Codex-Mini",
      "GPT-5 mini",
      "GPT-4.1",
      "Gemini 3 Pro (Preview)",
    ],
  },
  {
    id: "AtomicFeaturePath",
    type: "promptString",
    description: "Path to feature folder or plan file (relative or absolute)",
    default: "docs/features/active/",
  },
];

const INPUT_TOKEN_PATTERN = /\$\{input:([^}]+)\}/g;

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

/**
 * Returns the execution spec for a command ID, if defined.
 */
export function getTaskExecutionSpec(
  commandId: TaskCommandId,
): TaskExecutionSpec | undefined {
  return TASK_EXECUTION_MAP[commandId];
}

/**
 * Extracts task input IDs used by a command's argument list.
 */
export function getTaskInputIdsForCommand(commandId: TaskCommandId): string[] {
  const spec = getTaskExecutionSpec(commandId);
  if (!spec) {
    return [];
  }

  const inputIds: string[] = [];
  for (const arg of spec.args) {
    for (const match of arg.matchAll(INPUT_TOKEN_PATTERN)) {
      const inputId = match[1];
      if (inputId && !inputIds.includes(inputId)) {
        inputIds.push(inputId);
      }
    }
  }

  return inputIds;
}

/**
 * Returns the task input definition for a given input ID.
 */
export function getTaskInputDefinition(
  id: string,
): TaskInputDefinition | undefined {
  return TASK_INPUT_DEFINITIONS.find((def) => def.id === id);
}

/**
 * Builds a default input value map for a task command.
 *
 * Purpose:
 *     Some tasks include `${input:<id>}` tokens in their argument lists.
 *     When we need to render tasks before prompting the user (e.g., to list
 *     tasks in the task provider), we still want argument resolution to be
 *     deterministic and not throw.
 *
 * Args:
 *     commandId (TaskCommandId): The task-backed command to inspect.
 *
 * Returns:
 *     Record<string, string>: A map of required input IDs to their default
 *     values, suitable for passing into `resolveTaskArgs`.
 *
 * Raises:
 *     Error: If an input token references an undefined input definition.
 *
 * Side Effects:
 *     None.
 */
export function getDefaultInputValuesForCommand(
  commandId: TaskCommandId,
): Record<string, string> {
  const inputValues: Record<string, string> = {};

  // Collect required input IDs from the command's argument list and map them
  // to defaults to keep provider-side resolution deterministic.
  for (const inputId of getTaskInputIdsForCommand(commandId)) {
    const def = getTaskInputDefinition(inputId);
    if (!def) {
      throw new Error(
        `Task input is referenced but not defined: ${inputId} (command: ${commandId})`,
      );
    }
    inputValues[inputId] = def.default;
  }

  return inputValues;
}

/**
 * Resolves task argument tokens with provided context values.
 *
 * Supported tokens:
 * - ${workspaceFolder}: workspace root path
 * - ${extensionRoot}: extension installation path
 * - ${file}: active file absolute path
 * - ${relativeFile}: active file relative to workspace
 * - ${input:<id>}: input value from inputValues map
 *
 * @throws Error when ${input:<id>} token is missing from inputValues
 */
export function resolveTaskArgs(
  args: string[],
  context: {
    workspaceRoot: string;
    extensionRoot: string;
    activeFilePath?: string;
    activeRelativePath?: string;
    inputValues: Record<string, string>;
  },
): string[] {
  return args.map((arg) => {
    let resolved = arg;

    // Replace ${workspaceFolder}
    resolved = resolved.replace(
      /\$\{workspaceFolder\}/g,
      context.workspaceRoot,
    );

    // Replace ${extensionRoot}
    resolved = resolved.replace(/\$\{extensionRoot\}/g, context.extensionRoot);

    // Replace ${file}
    if (context.activeFilePath) {
      resolved = resolved.replace(/\$\{file\}/g, context.activeFilePath);
    }

    // Replace ${relativeFile}
    if (context.activeRelativePath) {
      resolved = resolved.replace(
        /\$\{relativeFile\}/g,
        context.activeRelativePath,
      );
    }

    // Replace ${input:<id>}
    resolved = resolved.replace(INPUT_TOKEN_PATTERN, (match, inputId) => {
      const value = context.inputValues[inputId];
      if (value === undefined) {
        throw new Error(`Missing input value: ${inputId}`);
      }
      return value;
    });

    return resolved;
  });
}
