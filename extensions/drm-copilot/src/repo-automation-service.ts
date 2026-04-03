import * as path from "node:path";
import {
  type BundledScriptExecutionResult,
  type CommandOutput,
  executeBundledScriptFromExtensionRoot,
  type RuntimeKind,
} from "./command-runtime";
import {
  type PotentialPromotionType,
  type WorkModeOption,
} from "./workflow-command-arguments";

/**
 * Stable semantic workflow names shared by the VS Code and MCP adapters.
 */
export const REPO_AUTOMATION_TOOLS = [
  "collect_commit_context",
  "collect_pr_context",
  "push_down_copilot_customizations",
  "new_potential_bug_entry",
  "new_potential_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "resolve_execute_hard_lock_prompt",
] as const;

/**
 * Stable semantic workflow name.
 */
export type RepoAutomationToolName = (typeof REPO_AUTOMATION_TOOLS)[number];

/**
 * Shared execution result returned by the repo-automation service.
 */
export interface RepoAutomationExecutionResult {
  readonly tool: RepoAutomationToolName;
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: ReadonlyArray<string>;
}

/**
 * Shared service contract consumed by the VS Code and MCP adapters.
 */
export interface RepoAutomationService {
  collectCommitContext(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  collectPrContext(
    input: WorkspaceExecutionInput & { readonly base: string },
  ): Promise<RepoAutomationExecutionResult>;
  pushDownCopilotCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  newPotentialBugEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult>;
  newPotentialEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult>;
  potentialToIssue(
    input: WorkspaceExecutionInput & {
      readonly potentialPath: string;
      readonly promotionType: PotentialPromotionType;
      readonly workMode: WorkModeOption;
    },
  ): Promise<RepoAutomationExecutionResult>;
  newActiveFeatureFolder(
    input: WorkspaceExecutionInput & {
      readonly featureName: string;
      readonly type: PotentialPromotionType;
      readonly issueNumber?: string;
      readonly workMode: WorkModeOption;
    },
  ): Promise<RepoAutomationExecutionResult>;
  resolveExecuteHardLockPrompt(
    input: WorkspaceExecutionInput & { readonly target: string },
  ): Promise<RepoAutomationExecutionResult>;
}

/**
 * Shared input used by all workspace-targeted workflows.
 */
export interface WorkspaceExecutionInput {
  readonly workspaceRoot: string;
  readonly invocationId?: string;
}

/**
 * Factory options for the repo-automation service.
 */
export interface RepoAutomationServiceOptions {
  readonly extensionRoot: string;
  readonly output: CommandOutput;
}

interface ScriptExecutionOptions {
  readonly tool: RepoAutomationToolName;
  readonly runtimeKind: RuntimeKind;
  readonly bundledRelativePath: string;
  readonly workspaceRoot: string;
  readonly invocationId: string;
  readonly args: ReadonlyArray<string>;
  readonly summary: string;
  readonly artifactPaths?: ReadonlyArray<string>;
  readonly stdoutArtifactPattern?: RegExp;
}

function normalizeGeneratedPath(filePath: string): string {
  return filePath.replace(/\\/g, "/");
}

function parseFirstArtifactPath(
  execution: BundledScriptExecutionResult,
  pattern: RegExp,
): string | undefined {
  const match = execution.stdout.match(pattern);
  const capturedPath = match?.[1]?.trim();
  return capturedPath && capturedPath.length > 0
    ? normalizeGeneratedPath(capturedPath)
    : undefined;
}

class DefaultRepoAutomationService implements RepoAutomationService {
  private readonly extensionRoot: string;
  private readonly output: CommandOutput;
  private readonly templateRoot: string;

  constructor(options: RepoAutomationServiceOptions) {
    this.extensionRoot = options.extensionRoot;
    this.output = options.output;
    this.templateRoot = normalizeGeneratedPath(
      path.join(this.extensionRoot, "resources", "feature-templates"),
    );
  }

  async collectCommitContext(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "collect_commit_context",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/collect_commit_context.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "collect_commit_context",
      args: ["--output", "artifacts/commit_context.txt"],
      summary: "Collected commit context into artifacts/commit_context.txt.",
      artifactPaths: [
        normalizeGeneratedPath(
          path.join(input.workspaceRoot, "artifacts/commit_context.txt"),
        ),
      ],
    });
  }

  async collectPrContext(
    input: WorkspaceExecutionInput & { readonly base: string },
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "collect_pr_context",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/collect_pr_context.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "collect_pr_context",
      args: [
        "--base",
        input.base,
        "--repo-root",
        input.workspaceRoot,
        "--out",
        "artifacts/pr_context.summary.txt",
        "--appendix-out",
        "artifacts/pr_context.appendix.txt",
      ],
      summary: `Collected PR context against base '${input.base}'.`,
      artifactPaths: [
        normalizeGeneratedPath(
          path.join(input.workspaceRoot, "artifacts/pr_context.summary.txt"),
        ),
        normalizeGeneratedPath(
          path.join(input.workspaceRoot, "artifacts/pr_context.appendix.txt"),
        ),
      ],
    });
  }

  async pushDownCopilotCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "push_down_copilot_customizations",
      runtimeKind: "python",
      bundledRelativePath:
        "resources/templates/push_down_copilot_customizations.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "push_down_copilot_customizations",
      args: ["--destination", input.workspaceRoot],
      summary:
        "Pushed bundled Copilot customizations into the destination workspace.",
      stdoutArtifactPattern: /Wrote push-down summary artifact to:\s*(.+)/i,
    });
  }

  async newPotentialBugEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "new_potential_bug_entry",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/new_potential_bug_entry.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "new_potential_bug_entry",
      args: [
        "--short-name",
        input.shortName,
        "--template-root",
        this.templateRoot,
      ],
      summary: `Created a new potential bug entry for '${input.shortName}'.`,
    });
  }

  async newPotentialEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "new_potential_entry",
      runtimeKind: "powershell",
      bundledRelativePath: "resources/templates/new-potential-entry.ps1",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "new_potential_entry",
      args: ["-ShortName", input.shortName, "-TemplateRoot", this.templateRoot],
      summary: `Created a new potential entry for '${input.shortName}'.`,
      stdoutArtifactPattern: /^Created:\s*(.+)$/im,
    });
  }

  async potentialToIssue(
    input: WorkspaceExecutionInput & {
      readonly potentialPath: string;
      readonly promotionType: PotentialPromotionType;
      readonly workMode: WorkModeOption;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "potential_to_issue",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/potential_to_issue.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "potential_to_issue",
      args: [
        "--potential-path",
        input.potentialPath,
        "--promotion-type",
        input.promotionType,
        "--work-mode",
        input.workMode,
      ],
      summary: `Promoted '${input.potentialPath}' as a ${input.promotionType} workflow in ${input.workMode} mode.`,
    });
  }

  async newActiveFeatureFolder(
    input: WorkspaceExecutionInput & {
      readonly featureName: string;
      readonly type: PotentialPromotionType;
      readonly issueNumber?: string;
      readonly workMode: WorkModeOption;
    },
  ): Promise<RepoAutomationExecutionResult> {
    const args = ["--feature-name", input.featureName, "--type", input.type];
    if (input.issueNumber !== undefined) {
      args.push("--issue-number", input.issueNumber);
    }

    args.push(
      "--work-mode",
      input.workMode,
      "--template-root",
      this.templateRoot,
    );
    return this.executeScript({
      tool: "new_active_feature_folder",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/new_active_feature_folder.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "new_active_feature_folder",
      args,
      summary: `Created a new active ${input.type} feature folder for '${input.featureName}'.`,
    });
  }

  async resolveExecuteHardLockPrompt(
    input: WorkspaceExecutionInput & { readonly target: string },
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "resolve_execute_hard_lock_prompt",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/resolve_hard_lock_prompt.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "resolve_execute_hard_lock_prompt",
      args: ["--target", input.target, "--workspace", input.workspaceRoot],
      summary: `Resolved the execute hard-lock prompt for '${input.target}'.`,
    });
  }

  private async executeScript(
    options: ScriptExecutionOptions,
  ): Promise<RepoAutomationExecutionResult> {
    const execution = await executeBundledScriptFromExtensionRoot(this.output, {
      runtimeKind: options.runtimeKind,
      bundledRelativePath: options.bundledRelativePath,
      commandId: options.invocationId,
      args: options.args,
      extensionRoot: this.extensionRoot,
      workspaceRoot: options.workspaceRoot,
    });

    const parsedArtifactPath =
      options.stdoutArtifactPattern === undefined
        ? undefined
        : parseFirstArtifactPath(execution, options.stdoutArtifactPattern);
    const artifacts =
      options.artifactPaths ??
      (parsedArtifactPath === undefined ? undefined : [parsedArtifactPath]);

    return {
      tool: options.tool,
      workspaceRoot: options.workspaceRoot,
      summary: options.summary,
      ...(artifacts === undefined ? {} : { artifacts }),
    };
  }
}

/**
 * Creates the shared repo-automation service.
 *
 * @param options Construction options describing the extension resource root and output sink.
 * @returns A service that executes bundled repo-automation workflows.
 */
export function createRepoAutomationService(
  options: RepoAutomationServiceOptions,
): RepoAutomationService {
  return new DefaultRepoAutomationService(options);
}
