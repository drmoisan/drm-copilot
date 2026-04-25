import * as path from "node:path";
import {
  type CommandOutput,
  executeBundledScriptFromExtensionRoot,
} from "./command-runtime";
import {
  copyBundledPolicyAuditTemplateAsset,
  resolveBundledPolicyAuditTemplateAsset,
} from "./policy-audit-template-assets";
import {
  normalizeGeneratedPath,
  parseFirstArtifactPath,
  type ScriptExecutionOptions,
} from "./repo-automation-service-support";
import { type RepoAutomationToolName } from "./repo-automation-tool-names";
import {
  buildNewActiveFeatureFolderArgs,
  buildPoshQcWorkflowArguments,
  buildResolveExecuteHardLockPromptArguments,
  buildValidateOrchestrationArtifactsArgs,
} from "./repo-automation-args";
import {
  type PolicyAuditTemplateAssetSelector,
  type PotentialPromotionType,
  type WorkModeOption,
} from "./workflow-command-arguments";

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
  pushDownCopilotCustomizations(
    input: WorkspaceExecutionInput,
  ): Promise<RepoAutomationExecutionResult>;
  pushDownCodexAndAgentsCustomizations(
    input: WorkspaceExecutionInput,
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

export interface RepoAutomationServiceOptions {
  readonly extensionRoot: string;
  readonly output: CommandOutput;
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
    const args = buildNewActiveFeatureFolderArgs(input, this.templateRoot);
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
    const resolvedAsset = resolveBundledPolicyAuditTemplateAsset(
      this.extensionRoot,
      input.asset,
    );
    const destinationPath =
      input.targetPath === undefined
        ? undefined
        : copyBundledPolicyAuditTemplateAsset(
            resolvedAsset.bundledSourcePath,
            input.targetPath,
          );

    return {
      tool: "resolve_policy_audit_template_asset",
      workspaceRoot: input.workspaceRoot,
      summary:
        destinationPath === undefined
          ? `Resolved bundled policy-audit asset '${input.asset}'.`
          : `Copied bundled policy-audit asset '${input.asset}' to '${destinationPath}'.`,
      artifacts:
        destinationPath === undefined
          ? [resolvedAsset.bundledSourcePath]
          : [resolvedAsset.bundledSourcePath, destinationPath],
      assetId: resolvedAsset.assetId,
      bundledSourcePath: resolvedAsset.bundledSourcePath,
      ...(destinationPath === undefined ? {} : { destinationPath }),
    };
  }

  async resolveExecuteHardLockPrompt(
    input: WorkspaceExecutionInput & {
      readonly target: string;
      readonly output?: string;
      readonly quiet?: boolean;
    },
  ): Promise<RepoAutomationExecutionResult> {
    const { args, artifactPaths } =
      buildResolveExecuteHardLockPromptArguments(input);

    return this.executeScript({
      tool: "resolve_execute_hard_lock_prompt",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/resolve_hard_lock_prompt.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "resolve_execute_hard_lock_prompt",
      args,
      summary: `Resolved the execute hard-lock prompt for '${input.target}'.`,
      ...(artifactPaths === undefined ? {} : { artifactPaths }),
    });
  }

  async resolveAtomicPlanPrompt(
    input: WorkspaceExecutionInput & { readonly target: string },
  ): Promise<RepoAutomationExecutionResult> {
    return this.executeScript({
      tool: "resolve_atomic_plan_prompt",
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/resolve_atomic_plan_prompt.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "resolve_atomic_plan_prompt",
      args: ["--target", input.target, "--workspace", input.workspaceRoot],
      summary: `Resolved the atomic-plan prompt for '${input.target}'.`,
    });
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
    const args = buildValidateOrchestrationArtifactsArgs(input);

    return this.executeScript({
      tool: "validate_orchestration_artifacts",
      runtimeKind: "python",
      bundledRelativePath:
        "resources/templates/validate_orchestration_artifacts.py",
      workspaceRoot: input.workspaceRoot,
      invocationId: input.invocationId ?? "validate_orchestration_artifacts",
      args,
      summary: `Validated ${input.artifactType} artifact at '${input.artifactPath}'.`,
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
