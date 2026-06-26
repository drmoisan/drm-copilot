import * as path from "node:path";
import {
  type CommandOutput,
  executeBundledScriptFromExtensionRoot,
} from "./command-runtime";
import {
  normalizeGeneratedPath,
  parseFirstArtifactPath,
  runCollectCommitContext,
  type ScriptExecutionOptions,
} from "./repo-automation-service-support";
import { type RepoAutomationToolName } from "./repo-automation-tool-names";
import { buildPoshQcWorkflowArguments } from "./repo-automation-args";
import { buildPushDownClaudeCustomizationsOptions } from "./repo-automation-service-push-down";
import {
  buildNewActiveFeatureFolderOptions,
  buildRunCodexNativeConverterOptions,
  buildTemplateRoot,
  resolvePolicyAuditTemplateAssetResult,
  type ResolvePromptServiceDeps,
  type RunCodexNativeConverterInput,
  runResolveAtomicPlanPrompt,
  runResolveExecuteHardLockPrompt,
} from "./repo-automation-service-workflows";
import {
  type PolicyAuditTemplateAssetSelector,
  type PotentialPromotionType,
  type WorkModeOption,
} from "./workflow-command-arguments";
import { type FileSystem, RealFileSystem } from "./lib/file-system";
import { type CommandRunner, SubprocessRunner } from "./lib/subprocess-runner";
import { validateOrchestrationServiceCall } from "./lib/validate/validate-orchestration-service-call";

export interface RepoAutomationExecutionResult {
  readonly tool: RepoAutomationToolName;
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts?: ReadonlyArray<string>;
  readonly assetId?: string;
  readonly bundledSourcePath?: string;
  readonly destinationPath?: string;
}

export interface RepoAutomationService {
  collectCommitContext(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  collectPrContext(
    input: WorkspaceExecutionInput & { readonly base: string },
  ): Promise<RepoAutomationExecutionResult>;
  runCodexNativeConverter(
    input: RunCodexNativeConverterInput,
  ): Promise<RepoAutomationExecutionResult>;
  pushDownCopilotCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  pushDownCodexAndAgentsCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  pushDownClaudeCustomizations(
    input: PushDownClaudeCustomizationsInput,
  ): Promise<RepoAutomationExecutionResult>;
  newPotentialBugEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult>;
  newPotentialEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult>;
  linkParentChild(
    input: WorkspaceExecutionInput & {
      readonly parentIssueNumber: string;
      readonly childIssueNumber: string;
    },
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
  runPoshQCFormat(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCAnalyze(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCTest(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCAnalyzeAutofix(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  runPoshQCSuite(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult>;
  resolvePolicyAuditTemplateAsset(
    input: WorkspaceExecutionInput & {
      readonly asset: PolicyAuditTemplateAssetSelector;
      readonly targetPath?: string;
    },
  ): Promise<RepoAutomationExecutionResult>;
  resolveExecuteHardLockPrompt(
    input: WorkspaceExecutionInput & {
      readonly target: string;
      readonly output?: string;
      readonly quiet?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult>;
  resolveAtomicPlanPrompt(
    input: WorkspaceExecutionInput & { readonly target: string },
  ): Promise<RepoAutomationExecutionResult>;
  validateOrchestrationArtifacts(
    input: WorkspaceExecutionInput & {
      readonly artifactType: string;
      readonly artifactPath: string;
      readonly requireComplete?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult>;
}

export interface WorkspaceExecutionInput {
  readonly workspaceRoot: string;
  readonly invocationId?: string;
}

export interface PushDownClaudeCustomizationsInput extends WorkspaceExecutionInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}

export interface RepoAutomationServiceOptions {
  readonly extensionRoot: string;
  readonly output: CommandOutput;
  /**
   * Optional filesystem injection. Tests supply an in-memory implementation to
   * keep `validateOrchestrationArtifacts` hermetic; production defaults to a
   * {@link RealFileSystem}.
   */
  readonly fileSystem?: FileSystem;
  /** Command-runner for the in-process `collectCommitContext` git calls; defaults to {@link SubprocessRunner}, faked in tests. */
  readonly runner?: CommandRunner;
}

class DefaultRepoAutomationService implements RepoAutomationService {
  private readonly extensionRoot: string;
  private readonly output: CommandOutput;
  private readonly templateRoot: string;
  private readonly fileSystem: FileSystem;
  private readonly runner: CommandRunner;
  private readonly resolvePromptDeps: ResolvePromptServiceDeps;

  constructor(options: RepoAutomationServiceOptions) {
    this.extensionRoot = options.extensionRoot;
    this.output = options.output;
    this.templateRoot = buildTemplateRoot(this.extensionRoot);
    this.fileSystem = options.fileSystem ?? new RealFileSystem();
    this.runner = options.runner ?? new SubprocessRunner();
    this.resolvePromptDeps = {
      fileSystem: this.fileSystem,
      extensionRoot: this.extensionRoot,
      log: (message) => this.output.appendLine(message),
    };
  }
  async collectCommitContext(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult> {
    // In-process TS port of collect_commit_context.py (F4): delegate to the
    // support helper instead of spawning the bundled Python script.
    return runCollectCommitContext({
      runner: this.runner,
      fileSystem: this.fileSystem,
      workspaceRoot: input.workspaceRoot,
      log: (message) => this.output.appendLine(message),
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
  async runCodexNativeConverter(
    input: RunCodexNativeConverterInput,
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript(buildRunCodexNativeConverterOptions(input));
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
  async pushDownCodexAndAgentsCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "push_down_codex_and_agents_customizations",
      runtimeKind: "python",
      bundledRelativePath:
        "resources/templates/push_down_codex_and_agents_customizations.py",
      workspaceRoot: input.workspaceRoot,
      invocationId:
        input.invocationId ?? "push_down_codex_and_agents_customizations",
      args: ["--destination", input.workspaceRoot],
      summary:
        "Pushed bundled Codex and agents customizations into the destination workspace.",
      stdoutArtifactPattern: /Wrote push-down summary artifact to:\s*(.+)/i,
    });
  }
  async pushDownClaudeCustomizations(
    input: PushDownClaudeCustomizationsInput,
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript(buildPushDownClaudeCustomizationsOptions(input));
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
  async linkParentChild(
    input: WorkspaceExecutionInput & {
      readonly parentIssueNumber: string;
      readonly childIssueNumber: string;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "link_parent_child",
      runtimeKind: "powershell",
      bundledRelativePath: "resources/templates/link-parent-child.ps1",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "link_parent_child",
      args: [
        "-ParentIssueNumber",
        input.parentIssueNumber,
        "-ChildIssueNumber",
        input.childIssueNumber,
      ],
      summary: `Linked child issue #${input.childIssueNumber} to parent issue #${input.parentIssueNumber} using the bundled workflow.`,
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
    return this.executeScript(
      buildNewActiveFeatureFolderOptions(input, this.templateRoot),
    );
  }
  async runPoshQCFormat(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return this.runPoshQcWorkflow("run_poshqc_format", input);
  }
  async runPoshQCAnalyze(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return this.runPoshQcWorkflow("run_poshqc_analyze", input);
  }
  async runPoshQCTest(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return this.runPoshQcWorkflow("run_poshqc_test", input);
  }
  async runPoshQCAnalyzeAutofix(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return this.runPoshQcWorkflow("run_poshqc_analyze_autofix", input);
  }
  async runPoshQCSuite(
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return this.runPoshQcWorkflow("run_poshqc_suite", input);
  }

  async resolvePolicyAuditTemplateAsset(
    input: WorkspaceExecutionInput & {
      readonly asset: PolicyAuditTemplateAssetSelector;
      readonly targetPath?: string;
    },
  ): Promise<RepoAutomationExecutionResult> {
    return resolvePolicyAuditTemplateAssetResult(this.extensionRoot, input);
  }

  async resolveExecuteHardLockPrompt(
    input: WorkspaceExecutionInput & {
      readonly target: string;
      readonly output?: string;
      readonly quiet?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult> {
    // In-process TS port of resolve_hard_lock_prompt.py (F5).
    return runResolveExecuteHardLockPrompt(this.resolvePromptDeps, input);
  }

  async resolveAtomicPlanPrompt(
    input: WorkspaceExecutionInput & { readonly target: string },
  ): Promise<RepoAutomationExecutionResult> {
    // In-process TS port of the bundled resolve_file_prompt.py (F5).
    return runResolveAtomicPlanPrompt(this.resolvePromptDeps, input);
  }

  private async runPoshQcWorkflow(
    tool:
      | "run_poshqc_format"
      | "run_poshqc_analyze"
      | "run_poshqc_test"
      | "run_poshqc_analyze_autofix"
      | "run_poshqc_suite",
    input: WorkspaceExecutionInput & {
      readonly scanFolders?: ReadonlyArray<string>;
    },
  ): Promise<RepoAutomationExecutionResult> {
    const { args, bundledRelativePath, summary } = buildPoshQcWorkflowArguments(
      tool,
      input,
    );

    return this.executeScript({
      tool: tool as RepoAutomationToolName,
      runtimeKind: "powershell",
      bundledRelativePath,
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? tool,
      args,
      summary,
    });
  }

  async validateOrchestrationArtifacts(
    input: WorkspaceExecutionInput & {
      readonly artifactType: string;
      readonly artifactPath: string;
      readonly requireComplete?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult> {
    // Delegate to the extracted helper, which preserves the observable behavior.
    return validateOrchestrationServiceCall({
      fileSystem: this.fileSystem,
      workspaceRoot: input.workspaceRoot,
      artifactType: input.artifactType,
      artifactPath: input.artifactPath,
      ...(input.requireComplete === undefined
        ? {}
        : { requireComplete: input.requireComplete }),
    });
  }

  private async executeScript(
    options: ScriptExecutionOptions & { readonly tool: RepoAutomationToolName },
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

export function createRepoAutomationService(
  options: RepoAutomationServiceOptions,
): RepoAutomationService {
  return new DefaultRepoAutomationService(options);
}
