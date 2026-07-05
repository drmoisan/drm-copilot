import {
  type CommandOutput,
  executeBundledScriptFromExtensionRoot,
} from "./command-runtime";
import {
  parseFirstArtifactPath,
  runCollectCommitContext,
  type ScriptExecutionOptions,
} from "./repo-automation-service-support";
import { type RepoAutomationToolName } from "./repo-automation-tool-names";
import { buildPoshQcWorkflowArguments } from "./repo-automation-args";
import {
  type PushDownServiceDeps,
  runPushDownClaudeCustomizations,
  runPushDownCodexAndAgentsCustomizations,
  runPushDownCopilotCustomizations,
} from "./repo-automation-service-push-down";
import {
  buildTemplateRoot,
  resolvePolicyAuditTemplateAssetResult,
  type ResolvePromptServiceDeps,
  type RunCodexNativeConverterInput,
  runResolveAtomicPlanPrompt,
  runResolveExecuteHardLockPrompt,
} from "./repo-automation-service-workflows";
import { runCodexNativeConverterServiceCall } from "./lib/codex-native-converter/codex-native-converter-service-call";
import {
  type PolicyAuditTemplateAssetSelector,
  type PotentialPromotionType,
  type WorkModeOption,
} from "./workflow-command-arguments";
import { type FileSystem, RealFileSystem } from "./lib/file-system";
import { type CommandRunner, SubprocessRunner } from "./lib/subprocess-runner";
import { validateOrchestrationServiceCall } from "./lib/validate/validate-orchestration-service-call";
import { buildValidateOrchestrationServiceCallInput } from "./lib/validate/build-validate-orchestration-service-call-input";
import { newPotentialBugEntryServiceCall } from "./lib/new-potential-bug-entry-service-call";
import { collectPrContextServiceCall } from "./lib/pr-context/pr-context-service-call";
import { potentialToIssueServiceCall } from "./lib/potential-to-issue/potential-to-issue-service-call";
import { newActiveFeatureFolderServiceCall } from "./lib/new-active-feature-folder/new-active-feature-folder-service-call";
import {
  type PushDownFileSystem,
  RealPushDownFileSystem,
} from "./lib/push-down/filesystem-adapter";

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
    input: PushDownCodexAndAgentsCustomizationsInput,
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
      readonly requireModelRouting?: boolean;
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

export interface PushDownCodexAndAgentsCustomizationsInput extends WorkspaceExecutionInput {
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
  /** Optional push-down filesystem (distinct from {@link FileSystem}); tests inject an in-memory fake, production defaults to {@link RealPushDownFileSystem}. */
  readonly pushDownFileSystem?: PushDownFileSystem;
}

class DefaultRepoAutomationService implements RepoAutomationService {
  private readonly extensionRoot: string;
  private readonly output: CommandOutput;
  private readonly templateRoot: string;
  private readonly fileSystem: FileSystem;
  private readonly runner: CommandRunner;
  private readonly resolvePromptDeps: ResolvePromptServiceDeps;
  private readonly pushDownDeps: PushDownServiceDeps;

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
    this.pushDownDeps = {
      fs: options.pushDownFileSystem ?? new RealPushDownFileSystem(),
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
    // In-process TS port of the pr_context collector (F9): delegate to the
    // extracted helper instead of spawning the bundled Python script.
    return collectPrContextServiceCall({
      runner: this.runner,
      fileSystem: this.fileSystem,
      workspaceRoot: input.workspaceRoot,
      base: input.base,
      log: (message) => this.output.appendLine(message),
    });
  }
  async runCodexNativeConverter(
    input: RunCodexNativeConverterInput,
  ): Promise<RepoAutomationExecutionResult> {
    // In-process TS port of codex_native_converter (F10): delegate to the
    // extracted helper instead of spawning the bundled Python script.
    return runCodexNativeConverterServiceCall({
      fileSystem: this.fileSystem,
      workspaceRoot: input.workspaceRoot,
      mode: input.mode,
      sourceEcosystem: input.sourceEcosystem,
      sourceRoot: input.sourceRoot,
      selectedPaths: input.selectedPaths,
      destinationRoot: input.destinationRoot,
      artifactRoot: input.artifactRoot,
      enableRepoPrompts: input.enableRepoPrompts,
      log: (message) => this.output.appendLine(message),
    });
  }
  async pushDownCopilotCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult> {
    // In-process TS port (F3): delegate to the push-down helper.
    return runPushDownCopilotCustomizations(
      input.workspaceRoot,
      this.pushDownDeps,
    );
  }
  async pushDownCodexAndAgentsCustomizations(
    input: PushDownCodexAndAgentsCustomizationsInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runPushDownCodexAndAgentsCustomizations(input, this.pushDownDeps);
  }
  async pushDownClaudeCustomizations(
    input: PushDownClaudeCustomizationsInput,
  ): Promise<RepoAutomationExecutionResult> {
    // In-process TS port (F3): the helper forwards optional pack/variant/memory.
    return runPushDownClaudeCustomizations(input, this.pushDownDeps);
  }
  async newPotentialBugEntry(
    input: WorkspaceExecutionInput & { readonly shortName: string },
  ): Promise<RepoAutomationExecutionResult> {
    // In-process TS port of new_potential_bug_entry.py (F6): delegate to the
    // extracted helper instead of spawning the bundled Python script. The helper
    // passes a no-op editor launcher so no `code`/`code-insiders` subprocess runs.
    return newPotentialBugEntryServiceCall({
      fileSystem: this.fileSystem,
      runner: this.runner,
      workspaceRoot: input.workspaceRoot,
      shortName: input.shortName,
      templateRoot: this.templateRoot,
      log: (message) => this.output.appendLine(message),
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
    // In-process TS port of potential_to_issue.py (F7): delegate to the extracted
    // helper instead of spawning the bundled Python script. The helper runs the
    // gh calls through the injected runner and preserves the return contract.
    return potentialToIssueServiceCall({
      runner: this.runner,
      workspaceRoot: input.workspaceRoot,
      potentialPath: input.potentialPath,
      promotionType: input.promotionType,
      workMode: input.workMode,
      log: (message) => this.output.appendLine(message),
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
    return newActiveFeatureFolderServiceCall({
      ...input,
      runner: this.runner,
      templateRoot: this.templateRoot,
      log: (message) => this.output.appendLine(message),
    });
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
      readonly requireModelRouting?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult> {
    // Delegate to the extracted helper, which preserves the observable behavior.
    // Request shaping (optional-field omission) lives in the extracted builder.
    return validateOrchestrationServiceCall(
      buildValidateOrchestrationServiceCallInput(this.fileSystem, input),
    );
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
